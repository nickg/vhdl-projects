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
-- Project       : I80188/I80186                                             --
-- Module        : Queue controller                                          --
-- Library       : I8088                                                     --
--                                                                           --
-- Version       : 1.0  20/01/2002   Created HT-LAB                          --
--               : 1.1a 05/05/2008   Changed queue from 9 to 7 bytes.        --
--                                   9 bytes are not utilised.               --
--               : 1.1b 14/06/2008   Added bus8 signal for 80188 8bits bus   --
--               : 1.2  12/09/2009   Added A20 address line, required for    --
--                                   memory managers                         --
--               : 1.3  16/01/2010   Changed HLT detection (done in proc)    --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

LIBRARY I80186;
USE I80186.cpu86instr.ALL;
USE I80186.cpu86pack.ALL;

entity newbiushift is
   generic(
      en8086 : INTEGER := 0
   );
   port(
      bus8         : in     std_logic;
      turbo186     : in     std_logic;                  -- Enable extended addressing
      clk          : in     std_logic;
      dbus_in      : in     std_logic_vector (15 downto 0);
      dbusdp_out   : in     std_logic_vector (15 downto 0);
      flush_ack    : in     std_logic;
      irq_ack      : in     std_logic;
      irq_cycle2   : in     std_logic;
      irq_type     : in     std_logic_vector (3 downto 0);
      mux_addr     : in     std_logic_vector (2 downto 0);
      mux_data     : in     std_logic_vector (3 downto 0);
      mux_reg      : in     std_logic_vector (2 downto 0);
      nbreq        : in     std_logic_vector (2 downto 0);
      opc_ack      : in     std_logic;
      reset        : in     std_logic;
      rw_cycle     : in     std_logic;
      rw_cycle2    : in     std_logic;
      word         : in     std_logic;
      wr_mdbus     : in     std_logic;
      wrq          : in     std_logic;
      abus         : out    std_logic_vector (23 downto 0);
      dbus_out     : out    std_logic_vector (15 downto 0);
      instr        : out    instruction_type;
      lutbus       : out    std_logic_vector (15 downto 0);
      mdbus_out    : out    std_logic_vector (15 downto 0);
      qs           : out    std_logic_vector (1 downto 0);
      regcnt       : out    std_logic_vector (3 downto 0);
      regnbok      : out    std_logic;
      csbus        : in     std_logic_vector (15 downto 0);
      ipbus        : in     std_logic_vector (15 downto 0)
   );
end newbiushift ;

ARCHITECTURE rtl OF newbiushift IS

signal queue_s  : std_logic_vector(55 downto 0);        -- 7 byte pre-fetch!
signal regcnt_s : std_logic_vector(3 downto 0);         -- Note need 7 byte positions, change to 3 bits?
signal abus_s   : std_logic_vector(23 downto 0);        -- 24 bits address bus
signal abusdp_s : std_logic_vector(23 downto 0);        -- Used for odd/even mdbus addresses

signal mdbus_sel: std_logic_vector(1 downto 0);

signal ireg_s   : std_logic_vector(7 downto 0);         -- Latched version of Instr record
signal mod_s    : std_logic_vector(1 downto 0);
signal rm_s     : std_logic_vector(2 downto 0);
signal opcreg_s : std_logic_vector(2 downto 0);
signal opcdata_s: std_logic_vector(15 downto 0);
signal opcaddr_s: std_logic_vector(15 downto 0);
signal nbreq_s  : std_logic_vector(2 downto 0);

-- 80186 specific signals
signal abusdp_out : std_logic_vector(23 downto 0);      -- Temp combined CSBUS:IPBUS

-- 8086 specific signals
signal ipbusbiu_s : std_logic_vector(15 downto 0);
signal csbusbiu_s : std_logic_vector(15 downto 0);
signal ipbusp1_s  : std_logic_vector(15 downto 0);
signal inst_186_s : std_logic;                          -- Asserted when 186 instruction detected

-- pragma synthesis_off
signal reg48_s  : std_logic_vector(47 downto 0);        -- Latched version of queue_s used for signal hwmon only
-- pragma synthesis_on



BEGIN

    GEN186: if EN8086=0 generate                        -- 80186
    begin
        inst_186_s <= '0';
    end generate GEN186;

    GEN86: if EN8086=1 generate                         -- 8086
    begin
        process(queue_s)
        begin
            case (queue_s(55 downto 48)) is

                -- Illegal 8086 Instructions
                when X"60" => inst_186_s <= '1';        --PUSHA
                when X"61" => inst_186_s <= '1';        --POPA
                when X"C8" => inst_186_s <= '1';        --ENTER
                when X"C9" => inst_186_s <= '1';        --LEAVE
                when X"62" => inst_186_s <= '1';        --BOUND
                when X"6C" => inst_186_s <= '1';        --INS
                when X"6D" => inst_186_s <= '1';
                when X"6E" => inst_186_s <= '1';        --OUTS
                when X"6F" => inst_186_s <= '1';

                --Illegal 8086/80186 Instructions
                when X"0F" => inst_186_s <= '1';
                when X"63" => inst_186_s <= '1';
                when X"64" => inst_186_s <= '1';
                when X"65" => inst_186_s <= '1';
                when X"66" => inst_186_s <= '1';
                when X"67" => inst_186_s <= '1';
                when X"82" => inst_186_s <= '1';
                when X"D6" => inst_186_s <= '1';
                when X"F1" => inst_186_s <= '1';

                when X"C0" => if (queue_s(45 downto 43)="110") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- Shift C0 XX-110-XXX
                              end if;
                when X"C1" => if (queue_s(45 downto 43)="110") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- Shift C1 XX-110-XXX
                              end if;
                when X"D0" => if (queue_s(45 downto 43)="110") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- Shift XX-110-XXX
                              end if;
                when X"D1" => if (queue_s(45 downto 43)="110") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- Shift XX-110-XXX
                              end if;
                when X"D2" => if (queue_s(45 downto 43)="110") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- Shift XX-110-XXX
                              end if;
                when X"D3" => if (queue_s(45 downto 43)="110") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- Shift XX-110-XXX
                              end if;
                when X"F6" => if (queue_s(45 downto 43)="001") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- F6 XX-001-XXX
                              end if;
                when X"F7" => if (queue_s(45 downto 43)="001") then
                                  inst_186_s <= '1'; else inst_186_s <= '0';-- F6 XX-001-XXX
                              end if;
                when X"FE" => if ((queue_s(45 downto 43)="000") OR (queue_s(45 downto 43)="001")) then  -- FE only XX-000/001-XXX
                                  inst_186_s <= '0'; else inst_186_s <= '1';                            -- valid
                              end if;
                when others=> inst_186_s <= '0';
          end case;
        end process;
    end generate GEN86;

    instr.ireg  <= ireg_s;
    instr.xmod  <= mod_s;
    instr.rm    <= rm_s;
    instr.reg   <= opcreg_s;
    instr.data  <= opcdata_s(7 downto 0)&opcdata_s(15 downto 8);
    instr.disp  <= opcaddr_s(7 downto 0)&opcaddr_s(15 downto 8);
    instr.nb    <= nbreq_s;

    regnbok  <= '1' when (regcnt_s>='0'&nbreq OR inst_186_s='1') else '0';-- regcnt must be >= nb required

    lutbus <= queue_s(55 downto 40);                    -- Top 16bits for opcode LUT decoder

    -------------------------------------------------------------------------
    -- reg counter (how many bytes are available in pre-fetch queue)
    -------------------------------------------------------------------------
    process(reset,clk)
    begin
        if reset='1' then
            regcnt_s <= (others => '0');                -- wrap around after first pulse!
        elsif rising_edge(clk) then

            if wrq='1' then                             -- During T4 Increase queue counter
                if abus_s(0)='1' OR bus8='1' then       -- Read instruction from odd/188 address
                    regcnt_s <= regcnt_s + '1';
                else
                    regcnt_s <= regcnt_s + "10";
                end if;
            end if;

            if opc_ack='1' then                         -- if acknowledge opcode then reduce queue counter
                if (inst_186_s='1') then                -- If illegal instr detected then replace with NOP
                    if  (queue_s(55 downto 49)="0110110") then  --INSb/INSw is used for detecting 8086, need to skip 2 bytes!
                        regcnt_s <= regcnt_s - "0010";  -- Skip 2 bytes
                    else
                        regcnt_s <= regcnt_s - '1';     -- Skip 1 bytes, single NOP replaces illegal instruction in 8086
                    end if;
                else                                    -- Normal 80186 operations
                    regcnt_s <= regcnt_s - ('0'&nbreq);
                end if;
            end if;



            if flush_ack='1' then
                regcnt_s <= (others => '0');        -- flush the pre-fetch queue
            end if;

        end if;
    end process;
    regcnt <= regcnt_s;

    -------------------------------------------------------------------------
    -- Load instruction into 56 bits prefetch queue (7 bytes)
    -- ** Different ** 6 bytes for original 186/86
    -- ** Different ** 4 bytes for original 188/88
    -------------------------------------------------------------------------
    process(reset,clk)
    begin
        if reset='1' then
            queue_s <= NOP & X"000000000000";       --(others => '0');
            qs      <= "00";                        -- Queue Status Signals QS1 and QS0
        elsif rising_edge(clk) then

            -----------------------------------------------------------------
            -- Q status signals
            -----------------------------------------------------------------
            if flush_ack='1' then
                qs<= "10";                          -- empty the queue
            elsif (wrq='1' and abus_s(0)='1') OR (wrq='1' and regcnt_s="0000") then
                qs<= "01";                          -- Read first byte into queue
            elsif (wrq='1' and regcnt_s<="0101") then
                qs<= "11";                          -- Subsequent bytes from the queue
            else
                qs<= "00";                          -- No Operation
            end if;

            if wrq='1' then                         -- wrq is asserted during T4

                if bus8='1' then                    -- 80188

                    case regcnt_s is                -- Load new data, shift in lsb bytes first
                       when "0000"  => queue_s <= dbus_in(7 downto 0) & "------------------------------------------------";
                       when "0001"  => queue_s <= queue_s(55 downto 48) & dbus_in(7 downto 0) & "----------------------------------------";
                       when "0010"  => queue_s <= queue_s(55 downto 40) & dbus_in(7 downto 0) & "--------------------------------";
                       when "0011"  => queue_s <= queue_s(55 downto 32) & dbus_in(7 downto 0) & "------------------------";
                       when "0100"  => queue_s <= queue_s(55 downto 24) & dbus_in(7 downto 0) & "----------------";
                       when "0101"  => queue_s <= queue_s(55 downto 16) & dbus_in(7 downto 0) & "--------";
                       when "0110"  => queue_s <= queue_s(55 downto 8)  & dbus_in(7 downto 0);
                       when others  => queue_s <= "--------------------------------------------------------";
                            -- pragma synthesis_off
                            assert FALSE report "**** Incorrect regcnt_s value in queue_s " severity error;
                            -- pragma synthesis_on
                    end case;

                else                                -- 80186

                    if abus_s(0)='1' then           -- Read instruction from odd address
                        queue_s<= dbus_in(15 downto 8)&"------------------------------------------------";
                    else
                        case regcnt_s is                    -- Load new data, shift in lsb bytes first
                           when "0000"  => queue_s <= dbus_in(7 downto 0) & dbus_in(15 downto 8)&"----------------------------------------";
                           when "0001"  => queue_s <= queue_s(55 downto 48) & dbus_in(7 downto 0) & dbus_in(15 downto 8)&"--------------------------------";
                           when "0010"  => queue_s <= queue_s(55 downto 40) & dbus_in(7 downto 0) & dbus_in(15 downto 8)&"------------------------";
                           when "0011"  => queue_s <= queue_s(55 downto 32) & dbus_in(7 downto 0) & dbus_in(15 downto 8)&"----------------";
                           when "0100"  => queue_s <= queue_s(55 downto 24) & dbus_in(7 downto 0) & dbus_in(15 downto 8)&"--------";
                           when "0101"  => queue_s <= queue_s(55 downto 16) & dbus_in(7 downto 0) & dbus_in(15 downto 8);
                           when "0110"  => queue_s <= queue_s(55 downto 8)  & dbus_in(7 downto 0);
                           when others  => queue_s <= "--------------------------------------------------------";
                                -- pragma synthesis_off
                                assert FALSE report "**** Incorrect regcnt_s value in queue_s " severity error;
                                -- pragma synthesis_on
                        end case;
                    end if;
                end if;
            end if;


            if opc_ack='1' then                     -- Opcode is acknowledged and passed on to proc
                case nbreq is                       -- remove nb byte(s) when latcho is active
                    when "001"  => queue_s <= queue_s(47 downto 0) & "--------"; -- smaller synth results than "00000000"
                    when "010"  => queue_s <= queue_s(39 downto 0) & "----------------";
                    when "011"  => queue_s <= queue_s(31 downto 0) & "------------------------";
                    when "100"  => queue_s <= queue_s(23 downto 0) & "--------------------------------";
                    when "101"  => queue_s <= queue_s(15 downto 0) & "----------------------------------------";
                    when "110"  => queue_s <= queue_s(7  downto 0) & "------------------------------------------------";
                    when others => queue_s <= queue_s;
                        -- pragma synthesis_off
                        assert FALSE report "**** Incorrect nbreq value for queue_s " severity error;
                        -- pragma synthesis_on
                end case;
            end if;

        end if;
    end process;


    -------------------------------------------------------------------------
    -- Instruction Record Opcode Data
    -- Note format LSB-MSB
    -------------------------------------------------------------------------
    process(reset,clk)
    begin
        if reset='1' then
            opcdata_s <= (others => '0');
        elsif rising_edge(clk) then
            if opc_ack='1' then
                case mux_data is
                    when "0000" => opcdata_s <= (others => '0');
                    when "0001" => opcdata_s <= queue_s(47 downto 40) & X"00";
                    when "0010" => opcdata_s <= queue_s(47 downto 32);
                    when "0011" => opcdata_s <= queue_s(39 downto 32) & X"00";
                    when "0100" => opcdata_s <= queue_s(39 downto 24);
                    when "0101" => opcdata_s <= queue_s(31 downto 24) & X"00";
                    when "0110" => opcdata_s <= queue_s(31 downto 16);
                    when "0111" => opcdata_s <= queue_s(23 downto 16) & X"00";
                    when "1000" => opcdata_s <= queue_s(23 downto 8);
                    when others => opcdata_s <= "----------------";   -- generate Error?
                    --assert FALSE report "**** Incorrect mux_data in Opcode Data Register" severity error;
                end case;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Instruction Record Opcode Address/Offset/Displacement
    -- Format LSB, MSB!
    -- Single Displacement byte sign extended
    -------------------------------------------------------------------------
    process(reset,clk)
    begin
        if reset='1' then
            opcaddr_s <= (others => '0');
        elsif rising_edge(clk) then

            if irq_ack='1' then
                opcaddr_s <= "0000" & irq_type & X"00";     -- irq_type=0..7, 15=external INTR
            end if;

            if irq_cycle2='1' then                          -- irq_cycle2 is asserted during second inta cycle
                opcaddr_s <= dbus_in(7 downto 0) & X"00";   -- Read 8 bits vector
            end if;

            if opc_ack='1' then
                case mux_addr is
                    when "000"  => opcaddr_s <= (others => '0');  -- Correct ????
                    when "001"  => opcaddr_s <= queue_s(47 downto 40) & queue_s(47)& queue_s(47)& queue_s(47)& queue_s(47)&
                                                queue_s(47)& queue_s(47)& queue_s(47)& queue_s(47); -- MSB Sign extended
                    when "010"  => opcaddr_s <= queue_s(47 downto 32);
                    when "011"  => opcaddr_s <= queue_s(39 downto 32) & queue_s(39)& queue_s(39)& queue_s(39)& queue_s(39)&
                                                queue_s(39)& queue_s(39)& queue_s(39)& queue_s(39); -- MSB Sign Extended
                    when "100"  => opcaddr_s <= queue_s(39 downto 24);
                    when "101"  => opcaddr_s <= queue_s(47 downto 40) & X"00"; -- No sign extend, MSB=0
                    when "110"  => opcaddr_s <= X"0300";    -- INT3 type=3
                    when others => opcaddr_s <= X"0400";    -- INTO type=4
                end case;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Instruction Record Opcode Register
    -- Note : "11" is push segment reg[2]=0 reg[1..0]=reg
    --      : Note reg[2]=0 if mux_reg=011
    -------------------------------------------------------------------------
    process(reset,clk)
    begin
        if reset='1' then
            opcreg_s <= (others => '0');
        elsif rising_edge(clk) then
            if opc_ack='1' then
                case mux_reg is
                    when "000"  => opcreg_s <= (others => '0');                       -- Correct ??
                    when "001"  => opcreg_s <= queue_s(45 downto 43);
                    when "010"  => opcreg_s <= queue_s(50 downto 48);
                    when "011"  => opcreg_s <= '0' & queue_s(52 downto 51); -- bit2 forced to 0
                    when "100"  => opcreg_s <= queue_s(42 downto 40);
                    when others => opcreg_s <= "---";
                    --assert FALSE report "**** Incorrect mux_reg in Opcode Regs Register" severity error;
                end case;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Opcode, Mod R/M Register, and latched nbreq!
    -- Create fake xmod and rm if offset (addr_mux) is 1,2,5,6,7. In this case
    -- there is no second opcode byte. The fake xmod and rm result in an
    -- EA=Displacement.
    --
    -- For 8086 use inst_186_s to force a NOP instruction. To further reduce
    -- area utilisation you might need to prune proc_rtl.vhd and remove any
    -- 186 opcodes.
    -------------------------------------------------------------------------
    process(reset,clk) -- ireg
    begin
        if reset='1' then
            ireg_s  <=  NOP;                            -- default instr
            mod_s   <= (others => '0');                 -- default mod
            rm_s    <= (others => '0');                 -- default rm
            nbreq_s <= "001";                           -- single NOP
        elsif rising_edge(clk) then

            if irq_ack='1' then                         -- Interrupt load instr register with INT instruction
                 ireg_s <= INT;
                 nbreq_s<= "000";                       -- used in datapath to add to IP address
                 mod_s  <= "00";                        -- Fake mod (select displacement for int type)
                 rm_s   <= "110";                       -- Fake rm
            end if;

            if opc_ack='1' then

                if (inst_186_s='1') then                -- If illegal instr detected then replace with NOP
                    ireg_s  <=  NOP;                    -- default instr
                    mod_s   <= (others => '0');         -- default mod   change to don't care ??????????????????????
                    rm_s    <= (others => '0');         -- default rm
                    if  (queue_s(55 downto 49)="0110110") then  --INSb/INSw is used for detecting 8086, need to skip 2 bytes!
                        nbreq_s <= "010";               -- Skip 2 bytes
                    else
                        nbreq_s <= "001";               -- single NOP
                    end if;
                else
                    ireg_s <= queue_s(55 downto 48);
                    nbreq_s<= nbreq;
                    if  (mux_addr= "001" or mux_addr= "010" or mux_addr= "101"
                                         or mux_addr= "110" or mux_addr= "111") then
                        mod_s  <= "00";                 -- Fake mod
                        rm_s   <= "110";                -- Fake rm
                    else
                        mod_s  <= queue_s(47 downto 46);
                        rm_s   <= queue_s(42 downto 40);
                    end if;
                end if;
            end if;
        end if;
    end process;


    -----------------------------------------------------------------------------
    -- Generate different architectures for 80186 and 8086
    -- 8086 wraps address from IPBUS=FFFF back to 0000
    -- 80186 increases segment by 1.
    -----------------------------------------------------------------------------
    NOBUSWRAP: if EN8086=0 generate                     -- 80186
    begin

        -------------------------------------------------------------------------
        -- Check for Turbo186 Mode
        -- If this signal is asserted then the segment register is shifted 8 places
        -- to the left before adding the IP register. This in effect gives a 16MByte
        -- Real Mode address range. Note this requires a special compiler and
        -- locator (like Paradigm C++)
        -------------------------------------------------------------------------
        process(turbo186,csbus,ipbus)
            begin
                if turbo186='0' then
                    abusdp_out <= ("0000"&csbus&"0000")+("00000000"&ipbus);-- 21 bits address CS:IP
                else
                    abusdp_out <= (csbus&X"00")+(X"00"&ipbus);  -- 24 bits address CS:IP
                end if;
        end process;

        -------------------------------------------------------------------------
        -- Address Bus
        -- When a flush_ack pulse is received then the new address comes from
        -- the datapath (csbus/ipbus).
        -------------------------------------------------------------------------
        process(reset,clk)
        begin
            if reset='1' then
                abus_s <= RESET_VECTOR_C;               -- A20 is zero during reset (see cpu86pack.vhd for definition)!
            elsif rising_edge(clk) then

                if wrq='1' then                         -- Update address
                    if abus_s(0)='1' OR bus8='1' then   -- Read instruction from odd/80188 address
                        abus_s <= abus_s+'1';
                    else
                        abus_s <= abus_s+"10";
                    end if;
                end if;

                if flush_ack='1' then
                    abus_s <= abusdp_out;               -- get new address after flush
                end if;

            end if;
        end process;

        -------------------------------------------------------------------------
        -- Bus Stearing
        -- rw_cycle asserted during single or dual rw cycles
        -- rw_cycle2 only asserted during last dual rw cycle
        -- Do not latch output, address bus be valid so that ALE can latch it
        -- Adding registers will result in the wrong values being latched!
        -------------------------------------------------------------------------
        abusdp_s <= abusdp_out when rw_cycle2='0' else (abusdp_out+'1');

        -------------------------------------------------------------------------
        -- abus is not latched. No solution found to do this, address must be valid
        -- sometime during T1. Use ALE and external latch if required.
        -- Select datapath abus when read or write cycle.
        -------------------------------------------------------------------------
        abus<=abusdp_s when rw_cycle='1' else abus_s;


    end generate NOBUSWRAP;

    -----------------------------------------------------------------------------
    -- 8086 wraps address from IPBUS=FFFF back to 0000
    -----------------------------------------------------------------------------
    BUSWRAP: if EN8086=1 generate                       -- 8086
    begin

        -------------------------------------------------------------------------
        -- IP Prefetch unit
        -- When a flush_ack pulse is received then the new IP address comes from
        -- the datapath (ipbus).
        -------------------------------------------------------------------------
        process(reset,clk)
        begin
            if reset='1' then
                ipbusbiu_s <= RESET_IP_C;               -- start 0x0000, CS=FFFF
                csbusbiu_s <= RESET_CS_C;
            elsif rising_edge(clk) then

                if wrq='1' then                         -- Update address
                    if ipbusbiu_s(0)='1' OR bus8='1' then -- Read instruction from odd/80188 address
                        ipbusbiu_s <= ipbusbiu_s+'1';
                    else
                        ipbusbiu_s <= ipbusbiu_s+"10";
                    end if;
                end if;

                if flush_ack='1' then
                    ipbusbiu_s <= ipbus;                -- get new address after flush
                    csbusbiu_s <= csbus;
                end if;

            end if;
        end process;

        abus_s(0)<= ipbusbiu_s(0);

        -------------------------------------------------------------------------
        -- IPBus Stearing
        -- rw_cycle asserted during single or dual rw cycles
        -- rw_cycle2 only asserted during last dual rw cycle
        -------------------------------------------------------------------------
        ipbusp1_s <= ipbus+'1';
        --abusdp_s  <= "00000"&ipbus when rw_cycle2='0' else "00000"&ipbusp1_s;
        abusdp_s  <= X"00"&ipbus when rw_cycle2='0' else X"00"&ipbusp1_s;

        -------------------------------------------------------------------------
        -- abus is not latched. No solution found to do this, address must be valid
        -- sometime during T1. Use ALE and external latch if required.
        -- Select datapath abus when read or write cycle.
        -------------------------------------------------------------------------
        process(rw_cycle,csbus,abus_s,abusdp_s,csbusbiu_s,ipbusbiu_s)
        begin
            if (rw_cycle='1') then
                --abus <= ('0'&csbus&"0000") + abusdp_s;      -- 20 bits address CS:IP
                abus <= ("0000"&csbus&"0000") + abusdp_s;   -- 24 bits address CS:IP
            else
                --abus <= ('0'&csbusbiu_s&"0000") + ("00000"&ipbusbiu_s);
                abus <= ("0000"&csbusbiu_s&"0000") + ("00000000"&ipbusbiu_s);
            end if;
        end process;

    end generate BUSWRAP;


    -------------------------------------------------------------------------
    -- Read: memory(dbus_in) to datapath(mdbus_out)
    -------------------------------------------------------------------------
    mdbus_sel <= word&abusdp_s(0) when bus8='0' else word&'0';

    process(reset,clk)
    begin
        if reset='1' then
            mdbus_out <= (others => '0');
        elsif rising_edge(clk) then
            if wr_mdbus='1' then                        -- Update mdbus
                case mdbus_sel is                       -- Byte Stearing
                    when "00"   => mdbus_out <= X"00" & dbus_in(7 downto 0); -- Byte transfer even address
                    when "01"   => mdbus_out <= X"00" & dbus_in(15 downto 8);-- Byte transfer odd address

                    when "10"   => if (rw_cycle2='1') then                    -- Word transfer even address
                                      mdbus_out(15 downto 8)<=dbus_in(7 downto 0);
                                   else
                                      mdbus_out<= dbus_in;
                                   end if;
                    when others => mdbus_out(7 downto 0)<=dbus_in(15 downto 8);-- Word transfer to odd address
                end case;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- Write: datapath(dbusdp_out) to memory (dbus_out)
    -- mdbus_sel<=word&abusdp_s(0);
    -------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            case mdbus_sel is                               -- Byte Stearing
                when "00"   => dbus_out <= dbusdp_out(7 downto 0)&dbusdp_out(7 downto 0);  --dbusdp_out;--    -- Byte transfer even address
                when "01"   => dbus_out <= dbusdp_out(7 downto 0)&dbusdp_out(7 downto 0);  --dbusdp_out;--    -- Byte transfer odd address
                when "10"   => if (rw_cycle2='1') then                              -- Word transfer even address
                                    dbus_out <= dbusdp_out(15 downto 8)&dbusdp_out(15 downto 8);
                               else
                                    dbus_out <= dbusdp_out;
                               end if;
                when others => dbus_out <= dbusdp_out(7 downto 0)&dbusdp_out(7 downto 0);-- Word transfer to odd address
            end case;
        end if;
    end process;

    -- pragma synthesis_off
    ---------------------------------------------------------------------------
    ---- Latched reg48_s signal since the BIU continous reads bytes during shift
    ---------------------------------------------------------------------------
    process(reset,clk) -- ireg
    begin
        if reset='1' then
            reg48_s <= (others => '0');
        elsif rising_edge(clk) then
            if opc_ack='1' then
                reg48_s <= queue_s(55 downto 8);
            end if;
        end if;
    end process;
    -- pragma synthesis_on


END ARCHITECTURE rtl;
