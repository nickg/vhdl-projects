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
-- Module        : Segment Register File                                     --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 0.1  01/12/2007   Created HT-LAB                          --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY I80186;
USE I80186.cpu86pack.ALL;

ENTITY segregfile IS
   PORT( 
      selsreg : IN     std_logic_vector (1 DOWNTO 0);
      sibus   : IN     std_logic_vector (15 DOWNTO 0);
      wrs     : IN     std_logic;
      reset   : IN     std_logic;
      clk     : IN     std_logic;
      sdbus   : OUT    std_logic_vector (15 DOWNTO 0);
      dimux   : IN     std_logic_vector (2 DOWNTO 0);
      es_s    : OUT    std_logic_vector (15 DOWNTO 0);
      cs_s    : OUT    std_logic_vector (15 DOWNTO 0);
      ss_s    : OUT    std_logic_vector (15 DOWNTO 0);
      ds_s    : OUT    std_logic_vector (15 DOWNTO 0)
   );
END segregfile ;

architecture rtl of segregfile is

signal  esreg_s : std_logic_vector(15 downto 0);
signal  csreg_s : std_logic_vector(15 downto 0);
signal  ssreg_s : std_logic_vector(15 downto 0);
signal  dsreg_s : std_logic_vector(15 downto 0);

signal  sdbus_s     : std_logic_vector (15 downto 0);   -- internal sdbus
signal  dimux_s     : std_logic_vector (2 downto 0);    -- replaced dimux


begin

----------------------------------------------------------------------------
-- 4 registers of 16 bits each
----------------------------------------------------------------------------
  process (clk,reset)
    begin
        if reset='1' then
            esreg_s <= RESET_ES_C;
            csreg_s <= RESET_CS_C;      -- Only CS set after reset
            ssreg_s <= RESET_SS_C;
            dsreg_s <= RESET_DS_C;
        elsif rising_edge(clk) then        
         if (wrs='1') then     
            case selsreg is 
                when "00"   => esreg_s <= sibus;
                when "01"   => csreg_s <= sibus;
                when "10"   => ssreg_s <= sibus;
                when others => dsreg_s <= sibus; 
            end case;                                                                                                             
         end if;
      end if;   
    end process;  
  
  dimux_s <= dimux; 

  process (dimux_s,esreg_s,csreg_s,ssreg_s,dsreg_s)
    begin
      case dimux_s is               -- Only 2 bits required
            when "100"  => sdbus_s <= esreg_s;
            when "101"  => sdbus_s <= csreg_s;
            when "110"  => sdbus_s <= ssreg_s;
            when others => sdbus_s <= dsreg_s; 
      end case;     
  end process;

  sdbus <= sdbus_s;             -- Connect to entity

  es_s <= esreg_s;
  cs_s <= csreg_s;
  ss_s <= ssreg_s;
  ds_s <= dsreg_s;

end rtl;
