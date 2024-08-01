-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2013 HT-LAB                                           --
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
-- Purpose       : TXCHAR Port Monitor                                       --
--               : Characters received on I/O port 0x54 are displayed as a   --
--               : text string. The string is displayed after receiving      -- 
--               : MAXCHAR_C characters.                                     --
--                                                                           --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  01/12/2007   Created HT-LAB                          --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY std;
USE std.TEXTIO.all;

USE work.utils.all;

ENTITY port_mon_debug IS
   GENERIC( 
      MAXCHAR_C : integer := 40
   );
   PORT( 
      mio      : IN     std_logic;
      resoutn  : IN     std_logic;
      wrn      : IN     std_logic;
      dbus_out : IN     std_logic_vector (15 DOWNTO 0);
      abus     : IN     std_logic_vector (19 DOWNTO 0)
   );
END port_mon_debug ;

ARCHITECTURE behavioral OF port_mon_debug IS
    signal wrpulse_s: std_logic;
    signal udbus_s  : std_logic_vector(7 downto 0); -- just for the waveform only

BEGIN

    wrpulse_s<='1' when (mio='0' and wrn='0' and abus(15 downto 0)=X"0054") else '0';

    -- Display string after MAXCHAR_C characters or CR character is received   
    process (wrpulse_s,resoutn) 
       variable L   : line;
       variable i_v : integer;
          begin
             if resoutn='0' then
                 i_v := 0;                              -- clear character counter
                 udbus_s <= X"20";
             elsif (rising_edge(wrpulse_s)) then        
                  if i_v=0 then 
                    write(L,string'("PORT_MON : "));
                    if (dbus_out(7 downto 0)/=X"0D" and dbus_out(7 downto 0)/=X"0A") then 
                       write(L,std_to_char(dbus_out(7 downto 0))); 
                       udbus_s <= dbus_out(7 downto 0); 
                    end if;         
                    i_v := i_v+1;
                 elsif (i_v=MAXCHAR_C or dbus_out(7 downto 0)=X"0D") then                
                    writeline(output,L);
                    i_v:=0;
                 else 
                    if (dbus_out(7 downto 0)/=X"0D" and dbus_out(7 downto 0)/=X"0A") then 
                       write(L,std_to_char(dbus_out(7 downto 0)));
                       udbus_s <= dbus_out(7 downto 0);
                    end if;         
                    i_v := i_v+1;
                 end if;
              end if;   
    end process;
END ARCHITECTURE behavioral;
