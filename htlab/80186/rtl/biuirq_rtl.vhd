-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2011 HT-LAB                                           --
--                                                                           --
--  Web          : http://www.ht-lab.com                                     --
--  Contact      : support@ht-lab.com                                        --
--  Sales        : sales@ht-lab.com                                          --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Please review the terms of the license agreement before using this file.  --
-- If you are not an authorized user, please destroy this source code file   --
-- and notify HT-Lab immediately that you inadvertently received an un-      --
-- authorized copy.                                                          --
-------------------------------------------------------------------------------
-- Project       : HTL80186                                                  --
-- Module        : Bus Interface Interrupt logic                             --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 0.1  01/12/2007   Created HT-LAB                          --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY I80186;
USE I80186.cpu86instr.ALL;
USE I80186.cpu86pack.ALL;

ENTITY biuirq IS
   GENERIC( 
      EN8086 : integer := 0
   );
   PORT( 
      bound_error  : IN     std_logic;
      clk          : IN     std_logic;
      decode_state : IN     std_logic;
      divide_error : IN     std_logic;
      halt         : IN     std_logic;
      intr         : IN     std_logic;
      irq_block    : IN     std_logic;
      irq_clr      : IN     std_logic;
      nmi          : IN     std_logic;
      esc_error    : IN     std_logic;
      proc_error   : IN     std_logic;
      reset        : IN     std_logic;
      status       : IN     status_out_type;
      irq_req      : OUT    std_logic;
      irq_type     : OUT    std_logic_vector (3 DOWNTO 0)
   );
END biuirq ;

ARCHITECTURE rtl OF biuirq IS

signal nmi_s        : std_logic;
signal instr_trace_s: std_logic;
signal irq_req_s    : std_logic;

TYPE STATE_TYPE IS (irqs0,irqs1,irqs2);
signal current_state: STATE_TYPE;

signal clr_nmi      : std_logic;
signal irq_type_s   : std_logic_vector(3 downto 0);

COMPONENT rise_edge
   GENERIC (
      REDGECLR  : integer   := 0;
      RESLEVEL  : std_logic := '1';
      RESDEFOUT : std_logic := '0'
   );
   PORT (
      clk     : IN     std_logic;
      reset   : IN     std_logic;
      strobe  : IN     std_logic;
      clrflag : IN     std_logic;
      pulse   : OUT    std_logic;
      flag    : OUT    std_logic
   );
END COMPONENT;

FOR ALL : rise_edge USE ENTITY I80186.rise_edge;

BEGIN
   --  NMI Edge triggered interrupt
    REDGE1 : rise_edge
        GENERIC MAP (
            REDGECLR  => 0,
            RESLEVEL  => '1',
            RESDEFOUT => '0')
        PORT MAP (
            clk     => clk,
            reset   => reset,
            strobe  => nmi,
            clrflag => clr_nmi,
            pulse   => OPEN,
            flag    => nmi_s);
    
--    -- metastability sync
--    process(reset,clk) -- ireg
--    begin
--       if reset='1' then
--          nmipre_s <= "00";      
--        elsif rising_edge(clk) then
--          nmipre_s <= nmipre_s(0) & nmi;
--       end if;
--    end process;
--
--    -- set/reset FF
--    process(reset, clk) -- ireg
--        begin
--           if (reset='1') then
--                nmi_s <= '0';   
--            elsif rising_edge(clk) then
--                if (irq_clr='1') then
--                    nmi_s <= '0';   
--                else 
--                    nmi_s <= nmi_s or ((not nmipre_s(1)) and nmipre_s(0));
--                end if;
--           end if;
--    end process;

    -------------------------------------------------------------------------
    -- Instruction trace flag, the trace flag is latched by the decode_state signal. This will
    -- result in the instruction after setting the trace flag not being traced (required).
    -- The instr_trace_s flag is not set if the current instruction is a HLT
    -------------------------------------------------------------------------
    process(reset, clk) 
        begin
           if (reset='1') then
              instr_trace_s <= '0';   
           elsif rising_edge(clk) then
              if (decode_state='1' and halt='0') then
                  instr_trace_s <= status.flag(8);   
               end if;
           end if;
    end process;


    -------------------------------------------------------------------------
    -- irq_req drives BIUFSM
    --
    -- int0_req=Divider
    -- int5_req=bound
    -- int6_req=unknown instr (proc error)
    -- status(8)=TF
    -- status(9)=IF
    -------------------------------------------------------------------------
    GEN86: if EN8086=1 generate                 -- 8086
        begin
            irq_req_s <= '1' when ((divide_error='1' or bound_error='1' or instr_trace_s='1' or esc_error='1' 
                                    or nmi_s='1' or (status.flag(9)='1' and intr='1')) 
                                    and irq_block='0') 
                                    else '0';  
    end generate GEN86;

    GEN186: if EN8086=0 generate                -- 80186, include proc_error which result in an INT6
        begin
            irq_req_s <= '1' when ((divide_error='1' or bound_error='1' or proc_error='1' or instr_trace_s='1' 
                                    or esc_error='1' or nmi_s='1' or (status.flag(9)='1' and intr='1')) 
                                    and irq_block='0') 
                                    else '0';  
    end generate GEN186;
                            

    -------------------------------------------------------------------------
    -- INT0 = Divide Overflow Interrupt
    -- INT1 = Trace Flag Interrupt
    -- INT2 = External NMI
    -- INT3
    -- INT4 = INT0 Overflow Interrupt
    -- INT5 = Out of Bound Interrupt
    -- INT6 = Unknown Instruction
    -- INT7 = ESC/CoProcessor Trap
    -- INTx = Exernal Interrupt, read vector from the databus
    -- Priority, NMI, then errors then trace then external IRQ
    -------------------------------------------------------------------------
    process (clk,reset)
        begin
            if (reset = '1') then
                current_state <= irqs0;
                irq_type_s      <= (others =>'0');
                irq_req <= '0';
                clr_nmi <= '0';
            elsif rising_edge(clk) then
                irq_req <= '0';                     -- default value
                clr_nmi <= '0';
                case current_state is
                    when irqs0 => 
                        if (irq_req_s='1') then 
                            current_state <= irqs1;
							irq_req <= not irq_block; 	-- Version 1.6
							
                            if nmi_s='1' then           -- Highest Priority
                                irq_type_s <= "0010";   -- NMI result in INT2
                            elsif divide_error='1' then      
                                irq_type_s <= "0000";   -- Divide by 0 int
                            elsif bound_error='1' then
                                irq_type_s <= "0101";   -- Out of Bounds int
                            elsif proc_error='1' then
                                irq_type_s <= "0110";   -- Unknown Instruction INT6 
                            elsif esc_error='1' then
                                irq_type_s <= "0111";   -- ESC/Coprocessor
                                                                                
                            elsif instr_trace_s='1' then
                                irq_type_s <= "0001";   -- TF result in INT1
                            else
                                irq_type_s <= "1111";   -- INTR result in INT <DBUS>
                            end if;                     -- What about INT3?
                        else
                            current_state <= irqs0;
                        end if;
                    when irqs1 => 
                        irq_req <= not irq_block; --'1';
                        
                        if (irq_clr='1') then 
                            current_state <= irqs0;
                            if irq_type_s="0010" then   -- Clear Edge triggered NMI
                               clr_nmi<='1';
                            end if;     
                        else
                            current_state <= irqs1;     -- Wait
                        end if;
                    when others =>
                        current_state <= irqs0;
                end case;
            end if;
    end process;                            
                            
    irq_type<=irq_type_s;                                                            
    
END ARCHITECTURE rtl;
