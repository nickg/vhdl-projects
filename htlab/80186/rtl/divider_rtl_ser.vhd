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
-- Module        : Signed/Unsigned Restoring Divider                         --
-- Library       : I80186                                                    --
--                                                                           --
--  0.1       HT-Lab          18/07/02      Tested on Modelsim SE 5.6        --
--  0.2       HT-Lab          03/07/11      Fixed signed division 16/8       --
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


ENTITY divider IS
   GENERIC( 
      WIDTH_DIVID : integer := 32;                      -- Width Dividend
      WIDTH_DIVIS : integer := 16;                      -- Width Divisor
      WIDTH_SHORT : Integer := 8                        -- Check Overflow against short Byte/Word
   );
   PORT( 
      clk       : IN     std_logic;                                  -- System Clock
      reset     : IN     std_logic;                                  -- Active high
      dividend  : IN     std_logic_vector (WIDTH_DIVID-1 DOWNTO 0);
      divisor   : IN     std_logic_vector (WIDTH_DIVIS-1 DOWNTO 0);
      quotient  : OUT    std_logic_vector (WIDTH_DIVIS-1 DOWNTO 0);
      remainder : OUT    std_logic_vector (WIDTH_DIVIS-1 DOWNTO 0);
      twocomp   : IN     std_logic;
      w         : IN     std_logic;                     -- Word or byte                
      overflow  : OUT    std_logic;
      start     : IN     std_logic;
      done      : OUT    std_logic
   );
END divider ;

ARCHITECTURE rtl_ser OF divider IS

signal dividend_s     : std_logic_vector(WIDTH_DIVID downto 0);         -- Add extra guard bit
signal divisor_s      : std_logic_vector(WIDTH_DIVIS downto 0);         -- Add extra guard bit

signal divis_rect_s   : std_logic_vector(WIDTH_DIVIS-1 downto 0);       -- Divisor rectified for comparsion
               
signal signquot_s     : std_logic;                        

signal signdividend_s : std_logic;     
signal signdivisor_s  : std_logic;     

signal accumulator_s  : std_logic_vector(WIDTH_DIVID downto 0); 
signal aluout_s       : std_logic_vector(WIDTH_DIVIS downto 0);         -- +1 bit
signal newaccu_s      : std_logic_vector(WIDTH_DIVID downto 0);         -- +1 bit

-- Unsigned quotient and remainder results
signal quot_s         : std_logic_vector (WIDTH_DIVIS-1 downto 0);
signal remain_s       : std_logic_vector (WIDTH_DIVIS-1 downto 0);

constant null_s       : std_logic_vector(31 downto 0) := X"00000000";   

signal count_s        : std_logic_vector (3 downto 0);                  -- Number of iterations

signal overflow_s     : std_logic; --_vector (WIDTH_DIVIS downto 0);
signal sremainder_s   : std_logic_vector (WIDTH_DIVIS-1 downto 0);
signal squotient_s    : std_logic_vector (WIDTH_DIVIS-1 downto 0);

signal signfailure_s  : std_logic;                                      -- incorrect result sign for signed division

signal zeroq_s        : std_logic;                                      -- Zero Quotient
signal zerod_s        : std_logic;                                      -- Zero Dividend

signal pos_s          : std_logic;
signal neg_s          : std_logic;

type   states is (s0,s1,s2);                                            -- FSM 
signal state,nextstate: states;

function rectifys (r  : in  std_logic_vector (WIDTH_DIVIS-1 downto 0);  -- Rectifier for divisor
                  twoc: in  std_logic)                                  -- Signed/Unsigned
  return std_logic_vector is 
  variable rec_v      : std_logic_vector (WIDTH_DIVIS-1 downto 0);                
begin
    if ((r(WIDTH_DIVIS-1) AND twoc)='1') then 
        rec_v := NOT(r); 
    else 
        rec_v := r;
    end if;
    return (rec_v + (r(WIDTH_DIVIS-1) AND twoc));        
end; 


begin   

    -- Sign Extend dividend to 32 bits and two complements if negative
    process(twocomp,w,dividend)
        begin
            if (twocomp='1') then
                if (w='1') then
                    signdividend_s <=dividend(31);
                    if (dividend(31)='1') then    -- 32 bits negative
                        dividend_s <= NOT(dividend(31)&dividend)+'1';    -- inv+1
                    else
                        dividend_s <= '0'&dividend;
                    end if;
                else
                    signdividend_s <=dividend(15);
                    if (dividend(15)='1') then    -- 16 bits sign extend to 32 bits
                        dividend_s <= NOT('1'& X"FFFF" & dividend(15 downto 0))+'1';
                    else 
                        dividend_s <= '0' & dividend;
                    end if;
                end if;
            else 
                signdividend_s <='0';
                dividend_s <= '0' & dividend;
            end if;
    end process;
    
    -- Sign Extend divisor to 16 bits and two complements if negative
    process(twocomp,w,divisor)
        begin
            if (twocomp='1') then
                if (w='1') then
                    signdivisor_s  <= divisor(15);
                    if (divisor(15)='1') then    -- 16 bits negative, leave negative
                        divisor_s <= '1'&divisor;                        
                    else
                        divisor_s <= NOT('0'&divisor)+'1';    -- if positive make negative, inv+1
                    end if;
                else
                    signdivisor_s  <= divisor(7);
                    if (divisor(7)='1') then    -- 7 bits sign extend to 16 bits
                        divisor_s <= '1' & X"FF" & divisor(7 downto 0); -- sign extend to                        
                    else 
                        divisor_s <= NOT('0'& X"00" & divisor(7 downto 0))+'1';
                    end if;
                end if;
            else 
                signdivisor_s  <= '0';
                if (w='1') then 
                    divisor_s <= NOT('0'&divisor)+'1';    -- if positive make negative, inv+1
                else 
                    divisor_s <= NOT('0'& X"00" & divisor(7 downto 0))+'1';
                end if;
            end if;
    end process;

    --  Subtractor (Adder, WIDTH_DIVIS+1)
    aluout_s      <= accumulator_s(WIDTH_DIVID downto WIDTH_DIVID-WIDTH_DIVIS) + divisor_s;

    --  Append Quotient section to aluout_s
    newaccu_s     <= aluout_s & accumulator_s(WIDTH_DIVID-WIDTH_DIVIS-1 downto 0);   

    process (clk,reset)                         
        begin
            if (reset='1') then                     
                accumulator_s   <= (others => '0');
            elsif (rising_edge(clk)) then  
                if start='1' then                                           
                    accumulator_s <= dividend_s(WIDTH_DIVID-1 downto 0) & '0';   -- Load Dividend in remainder +shl
                elsif pos_s='1' then                                             -- Positive, remain=shl(remain,1)
                    accumulator_s <= newaccu_s(WIDTH_DIVID-1 downto 0) & '1';    -- Use sub result   
                elsif neg_s='1' then                                             -- Negative, shl(remainder,0)
                    accumulator_s <= accumulator_s(WIDTH_DIVID-1 downto 0) & '0';-- Use original remainder
                end if;                               
            end if;   
    end process;    

    -- 2 Process Control FSM
    process (clk,reset)       
        begin
            if (reset = '1') then     
                state   <= s0; 
                count_s <= (others => '0');             
            elsif (rising_edge(clk)) then    
                state <= nextstate;   
                if (state=s1) then
                    count_s <= count_s - '1';
                elsif (state=s0) then
                    count_s <=  CONV_STD_LOGIC_VECTOR(WIDTH_DIVIS-1, 4);     -- extra step CAN REDUCE BY 1 since DONE is latched!!
                end if;
            end if;   
    end process;  

    process(state,start,aluout_s,count_s)
        begin  
            case state is
              when s0 => 
                    pos_s <= '0';
                    neg_s <= '0';                                           
                    if  start='1' then 
                        nextstate <= s1; 
                    else 
                        nextstate <= s0;
                    end if; 
              when s1 =>
                    neg_s <= aluout_s(WIDTH_DIVIS);      
                    pos_s <= not(aluout_s(WIDTH_DIVIS)); 
                    if (count_s=null_s(3 downto 0)) then nextstate <= s2;     -- Done 
                                                    else nextstate <= s1;     -- Next sub&shift
                    end if;
              when s2=>
                    pos_s <= '0';
                    neg_s <= '0';                                           
                    nextstate <= s0;  
              when others => 
                    pos_s <= '0';
                    neg_s <= '0';                                           
                    nextstate <= s0;              
            end case;                   
    end process;    

    -- Correct remainder (SHR,1)
    -- Overflow? if lsb remainder is 1 which is shifted out
    remain_s        <= accumulator_s(WIDTH_DIVID downto WIDTH_DIVID-WIDTH_DIVIS+1);

    -- bottom part of remainder is quotient
    quot_s          <=  accumulator_s(WIDTH_DIVIS-1 downto 0);

    -- Overflow if remainder>divisor or divide by 0 or sign error. Change all to positive.
    divis_rect_s    <= rectifys(divisor, twocomp);
    overflow_s      <= '1' when ((remain_s>=divis_rect_s) OR (zerod_s='1') OR (w='0' AND quot_s(15 downto 8)/=X"00")) else '0';

    -- Remainder Result
    sremainder_s    <= ((not(remain_s)) + '1') when signdividend_s='1' else remain_s;
    remainder       <= sremainder_s;

    -- Qotient Result
    squotient_s     <= ((not(quot_s)) + '1')  when (signdividend_s XOR signdivisor_s)='1' else quot_s;    
    quotient        <= squotient_s;
    
    signquot_s        <= squotient_s(15) when w='1' else squotient_s(7);
    
    -- Detect zero vector
    zeroq_s         <= '1' when (twocomp='1' AND squotient_s=null_s(WIDTH_DIVIS-1 downto 0)) else '0';
    zerod_s         <= '1' when (divisor=null_s(WIDTH_DIVIS-1 downto 0)) else '0';
	
    -- Detect Sign failure            
    signfailure_s   <= '1' when (zeroq_s='0' AND twocomp='1' AND (signdividend_s XOR signdivisor_s)/=signquot_s) else '0';
                            
                            
    done     <= '1' when state=s2 else '0';    
    overflow <= '1' when (state=s2 AND (overflow_s='1' OR signfailure_s='1')) else '0';
    
end architecture rtl_ser;
