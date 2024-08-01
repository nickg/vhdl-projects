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
-- Project       : I8086/I80186                                              --
-- Module        : Mod/RM Table                                              --
-- Library       : I8088                                                     --
--                                                                           --
-- Scantable3, rev 0.9 format [Opcode][Mod-Reg-RM] => dout <= value          --
-------------------------------------------------------------------------------
--  mtable4 rev 0.6 HABT03                                                   --
--  M  SI  M11 EA                                                            --
--  --------------------------------------                                   --
--  0   x   x   x     ; muxout=IREG   00 000 000                             --
--  1   0   x   0     ; muxout=IREG  MOD 000 000  not(mod=00 & RM=110)       --
--  1   0   x   1     ; muxout=IREG   00 000 110  mod=00 & RM=110            --
--  1   1   0   0     ; muxout=IREG  MOD IST 000  IST=Part of Instruc, mod=* --
--  1   1   0   1     ; muxout=IREG   00 IST 110  IST=Part of Instruction    --
--  1   1   1   0     ; muxout=IREG   11 IST 000  IST=Part of Instruction    --
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity m_table is
  port ( ireg  : in std_logic_vector(7 downto 0);
         modrrm: in std_logic_vector(7 downto 0);
         muxout: out std_logic_vector(7 downto 0));
end m_table;


architecture rtl of m_table is

  signal lutout_s: std_logic_vector(1 downto 0);
  signal ea_s    : std_logic;     -- Asserted if mod=00 and rm=110
  signal m11_s   : std_logic;     -- Asserted if mod=11
  signal mux_s   : std_logic_vector(3 downto 0);

begin

  ea_s <= '1' when (modrrm(7 downto 6)="00" and modrrm(2 downto 0)="110") else '0';

  m11_s<= '1' when modrrm(7 downto 6)="11" else '0';

  mux_s <= lutout_s & m11_s & ea_s;

  process (mux_s,modrrm)
  begin
      case mux_s is
         when "1000" => muxout <= modrrm(7 downto 6)&"000000";   -- only check mod value
         when "1010" => muxout <= modrrm(7 downto 6)&"000000";   -- only check mod value
         when "1001" => muxout <= "00000110";                    -- mod000rm
         when "1011" => muxout <= "00000110";                    -- mod000rm
         when "1100" => muxout <= modrrm(7 downto 3)&"000";         -- mod IST 000
         when "1101" => muxout <= "00"&modrrm(5 downto 3)&"110"; -- 00 IST 110 
         when "1110" => muxout <= "11"&modrrm(5 downto 3)&"000"; -- 11 IST 000 
       when others => muxout <= (others => '0');               -- single instruction
    end case;
  end process;

  process(ireg)
  begin
    case ireg is
       when "11111111" => lutout_s <= "11"; -- jmp  bx                       
       when "10001000" => lutout_s <= "10"; -- mov  bl,bl                    
       when "10001001" => lutout_s <= "10"; -- mov  bx,bx                    
       when "10001010" => lutout_s <= "10"; -- mov  bl,al                    
       when "10001011" => lutout_s <= "10"; -- mov  bx,ax                    
       when "11000110" => lutout_s <= "11"; -- mov  byte ptr [bx],0abh       
       when "11000111" => lutout_s <= "11"; -- mov  [bx],0abcdh              
       when "10001110" => lutout_s <= "10"; -- mov  ds,bx                    
       when "10001100" => lutout_s <= "10"; -- mov  bx,ds                    
       when "10001111" => lutout_s <= "11"; -- pop [bx]                      
       when "10000110" => lutout_s <= "10"; -- xchg bl,bl                    
       when "10000111" => lutout_s <= "10"; -- xchg bx,bx                    
       when "10001101" => lutout_s <= "10"; -- lea  bx,12h                   
       when "11000101" => lutout_s <= "10"; -- lds  si,01234h                
       when "11000100" => lutout_s <= "10"; -- les  si,12h                   
       when "00000000" => lutout_s <= "10"; -- add  bl,cl                    
       when "00000001" => lutout_s <= "10"; -- add  bx,cx                    
       when "00000010" => lutout_s <= "10"; -- add  bl,bl                    
       when "00000011" => lutout_s <= "10"; -- add  bx,bx                    
       when "10000000" => lutout_s <= "11"; -- add  bl,0cdh                  
       when "10000001" => lutout_s <= "11"; -- add  bx,0abcdh                
       when "10000011" => lutout_s <= "11"; -- add  bx,05bh                  
       when "00010000" => lutout_s <= "10"; -- adc  bl,cl                    
       when "00010001" => lutout_s <= "10"; -- adc  bx,cx                    
       when "00010010" => lutout_s <= "10"; -- adc  bl,bl                    
       when "00010011" => lutout_s <= "10"; -- adc  bx,bx                    
       when "00101000" => lutout_s <= "10"; -- sub  bl,cl                    
       when "00101001" => lutout_s <= "10"; -- sub  bx,cx                    
       when "00101010" => lutout_s <= "10"; -- sub  bl,bl                    
       when "00101011" => lutout_s <= "10"; -- sub  bx,bx                    
       when "00011000" => lutout_s <= "10"; -- sbb  bl,cl                    
       when "00011001" => lutout_s <= "10"; -- sbb  bx,cx                    
       when "00011010" => lutout_s <= "10"; -- sbb  bl,bl                    
       when "00011011" => lutout_s <= "10"; -- sbb  bx,bx                    
       when "11111110" => lutout_s <= "11"; -- inc  cl                       
       when "00111010" => lutout_s <= "10"; -- cmp  bl,bl                    
       when "00111011" => lutout_s <= "10"; -- cmp  bx,bx                    
       when "00111000" => lutout_s <= "10"; -- cmp  [0cdefh],bl              
       when "00111001" => lutout_s <= "10"; -- cmp  [0cdefh],bx              
       when "11110110" => lutout_s <= "11"; -- neg  bl                       
       when "11110111" => lutout_s <= "11"; -- neg  bx                       
       when "11010000" => lutout_s <= "10"; -- rol  bl,1                     
       when "11010001" => lutout_s <= "10"; -- rol  bx,1                     
       when "11010010" => lutout_s <= "10"; -- rol  bl,cl                    
       when "11010011" => lutout_s <= "10"; -- rol  bx,cl                    
       when "00100000" => lutout_s <= "10"; -- and  al,bl                    
       when "00100001" => lutout_s <= "10"; -- and  ax,bx                    
       when "00100010" => lutout_s <= "10"; -- and  bl,bl                    
       when "00100011" => lutout_s <= "10"; -- and  bx,bx                    
       when "00001000" => lutout_s <= "10"; -- or   [0cdefh],bl              
       when "00001001" => lutout_s <= "10"; -- or   [0cdefh],bx              
       when "00001010" => lutout_s <= "10"; -- or   bl,bl                    
       when "00001011" => lutout_s <= "10"; -- or   bx,bx                    
       when "10000100" => lutout_s <= "10"; -- test [0cdefh],bl              
       when "10000101" => lutout_s <= "10"; -- test [0cdefh],bx              
       when "00110000" => lutout_s <= "10"; -- or  [0cdefh],bl              
       when "00110001" => lutout_s <= "10"; -- or  [0cdefh],bx              
       when "00110010" => lutout_s <= "10"; -- or  bl,bl                    
       when "00110011" => lutout_s <= "10"; -- or  bx,bx                    
       when "01100010" => lutout_s <= "10"; -- db 062h, 07h                  
       when "11000000" => lutout_s <= "10"; -- rol  bl,1eh                   
       when "11000001" => lutout_s <= "10"; -- rol  bx,1eh                   
       when "01101011" => lutout_s <= "10"; -- mul    ax,bx,08h                             
       when "01101001" => lutout_s <= "10"; -- mul    ax,bx,128h                            
       when "11011000" => lutout_s <= "10"; -- db 0D8h, 01Eh, 034h, 12h      
       when "11011001" => lutout_s <= "10"; -- db 0D9h, 01Eh, 034h, 12h      
       when "11011010" => lutout_s <= "10"; -- db 0DAh, 01Eh, 034h, 12h      
       when "11011011" => lutout_s <= "10"; -- db 0DBh, 01Eh, 034h, 12h      
       when "11011100" => lutout_s <= "10"; -- db 0DCh, 01Eh, 034h, 12h      
       when "11011101" => lutout_s <= "10"; -- db 0DDh, 01Eh, 034h, 12h      
       when "11011110" => lutout_s <= "10"; -- db 0DEh, 01Eh, 034h, 12h      
       when "11011111" => lutout_s <= "10"; -- db 0DFh, 01Eh, 034h, 12h      
       when others     => lutout_s <= "00"; -- M=0
    end case;
  end process;
end rtl;