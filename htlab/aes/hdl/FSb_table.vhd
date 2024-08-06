-------------------------------------------------------------------------------
--                                                                           --
--  AES86 - VHDL 128bits AES IP Core                                         --
--                                                                           --
--  AES86 is released as open-source under the GNU GPL license. This means   --
--  that designs based on AES86 must be distributed in full source code      --
--  under the same license.                                                  --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
--  This library is free software; you can redistribute it and/or            --
--  modify it under the terms of the GNU Lesser General Public               --
--  License as published by the Free Software Foundation; either             --
--  version 2.1 of the License, or (at your option) any later version.       --
--                                                                           --
--  This library is distributed in the hope that it will be useful,          --
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        --
--  Lesser General Public License for more details.                          --
--                                                                           --
--  Full details of the license can be found in the file "copying.txt".      --
--                                                                           --
--  You should have received a copy of the GNU Lesser General Public         --
--  License along with this library; if not, write to the Free Software      --
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  --
--                                                                           --
-------------------------------------------------------------------------------
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
--  Forward S-Box Table
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity FSb_table is
  port ( addr  : in  std_logic_vector(7 downto 0);
         dout  : out std_logic_vector(7 downto 0));
end FSb_table;


architecture rtl of FSb_table is

begin

  process (addr)
  begin
    case addr is
       when "00000000" => dout <= X"63";
       when "00000001" => dout <= X"7C";
       when "00000010" => dout <= X"77";
       when "00000011" => dout <= X"7B";
       when "00000100" => dout <= X"F2";
       when "00000101" => dout <= X"6B";
       when "00000110" => dout <= X"6F";
       when "00000111" => dout <= X"C5";
       when "00001000" => dout <= X"30";
       when "00001001" => dout <= X"01";
       when "00001010" => dout <= X"67";
       when "00001011" => dout <= X"2B";
       when "00001100" => dout <= X"FE";
       when "00001101" => dout <= X"D7";
       when "00001110" => dout <= X"AB";
       when "00001111" => dout <= X"76";
       when "00010000" => dout <= X"CA";
       when "00010001" => dout <= X"82";
       when "00010010" => dout <= X"C9";
       when "00010011" => dout <= X"7D";
       when "00010100" => dout <= X"FA";
       when "00010101" => dout <= X"59";
       when "00010110" => dout <= X"47";
       when "00010111" => dout <= X"F0";
       when "00011000" => dout <= X"AD";
       when "00011001" => dout <= X"D4";
       when "00011010" => dout <= X"A2";
       when "00011011" => dout <= X"AF";
       when "00011100" => dout <= X"9C";
       when "00011101" => dout <= X"A4";
       when "00011110" => dout <= X"72";
       when "00011111" => dout <= X"C0";
       when "00100000" => dout <= X"B7";
       when "00100001" => dout <= X"FD";
       when "00100010" => dout <= X"93";
       when "00100011" => dout <= X"26";
       when "00100100" => dout <= X"36";
       when "00100101" => dout <= X"3F";
       when "00100110" => dout <= X"F7";
       when "00100111" => dout <= X"CC";
       when "00101000" => dout <= X"34";
       when "00101001" => dout <= X"A5";
       when "00101010" => dout <= X"E5";
       when "00101011" => dout <= X"F1";
       when "00101100" => dout <= X"71";
       when "00101101" => dout <= X"D8";
       when "00101110" => dout <= X"31";
       when "00101111" => dout <= X"15";
       when "00110000" => dout <= X"04";
       when "00110001" => dout <= X"C7";
       when "00110010" => dout <= X"23";
       when "00110011" => dout <= X"C3";
       when "00110100" => dout <= X"18";
       when "00110101" => dout <= X"96";
       when "00110110" => dout <= X"05";
       when "00110111" => dout <= X"9A";
       when "00111000" => dout <= X"07";
       when "00111001" => dout <= X"12";
       when "00111010" => dout <= X"80";
       when "00111011" => dout <= X"E2";
       when "00111100" => dout <= X"EB";
       when "00111101" => dout <= X"27";
       when "00111110" => dout <= X"B2";
       when "00111111" => dout <= X"75";
       when "01000000" => dout <= X"09";
       when "01000001" => dout <= X"83";
       when "01000010" => dout <= X"2C";
       when "01000011" => dout <= X"1A";
       when "01000100" => dout <= X"1B";
       when "01000101" => dout <= X"6E";
       when "01000110" => dout <= X"5A";
       when "01000111" => dout <= X"A0";
       when "01001000" => dout <= X"52";
       when "01001001" => dout <= X"3B";
       when "01001010" => dout <= X"D6";
       when "01001011" => dout <= X"B3";
       when "01001100" => dout <= X"29";
       when "01001101" => dout <= X"E3";
       when "01001110" => dout <= X"2F";
       when "01001111" => dout <= X"84";
       when "01010000" => dout <= X"53";
       when "01010001" => dout <= X"D1";
       when "01010010" => dout <= X"00";
       when "01010011" => dout <= X"ED";
       when "01010100" => dout <= X"20";
       when "01010101" => dout <= X"FC";
       when "01010110" => dout <= X"B1";
       when "01010111" => dout <= X"5B";
       when "01011000" => dout <= X"6A";
       when "01011001" => dout <= X"CB";
       when "01011010" => dout <= X"BE";
       when "01011011" => dout <= X"39";
       when "01011100" => dout <= X"4A";
       when "01011101" => dout <= X"4C";
       when "01011110" => dout <= X"58";
       when "01011111" => dout <= X"CF";
       when "01100000" => dout <= X"D0";
       when "01100001" => dout <= X"EF";
       when "01100010" => dout <= X"AA";
       when "01100011" => dout <= X"FB";
       when "01100100" => dout <= X"43";
       when "01100101" => dout <= X"4D";
       when "01100110" => dout <= X"33";
       when "01100111" => dout <= X"85";
       when "01101000" => dout <= X"45";
       when "01101001" => dout <= X"F9";
       when "01101010" => dout <= X"02";
       when "01101011" => dout <= X"7F";
       when "01101100" => dout <= X"50";
       when "01101101" => dout <= X"3C";
       when "01101110" => dout <= X"9F";
       when "01101111" => dout <= X"A8";
       when "01110000" => dout <= X"51";
       when "01110001" => dout <= X"A3";
       when "01110010" => dout <= X"40";
       when "01110011" => dout <= X"8F";
       when "01110100" => dout <= X"92";
       when "01110101" => dout <= X"9D";
       when "01110110" => dout <= X"38";
       when "01110111" => dout <= X"F5";
       when "01111000" => dout <= X"BC";
       when "01111001" => dout <= X"B6";
       when "01111010" => dout <= X"DA";
       when "01111011" => dout <= X"21";
       when "01111100" => dout <= X"10";
       when "01111101" => dout <= X"FF";
       when "01111110" => dout <= X"F3";
       when "01111111" => dout <= X"D2";
       when "10000000" => dout <= X"CD";
       when "10000001" => dout <= X"0C";
       when "10000010" => dout <= X"13";
       when "10000011" => dout <= X"EC";
       when "10000100" => dout <= X"5F";
       when "10000101" => dout <= X"97";
       when "10000110" => dout <= X"44";
       when "10000111" => dout <= X"17";
       when "10001000" => dout <= X"C4";
       when "10001001" => dout <= X"A7";
       when "10001010" => dout <= X"7E";
       when "10001011" => dout <= X"3D";
       when "10001100" => dout <= X"64";
       when "10001101" => dout <= X"5D";
       when "10001110" => dout <= X"19";
       when "10001111" => dout <= X"73";
       when "10010000" => dout <= X"60";
       when "10010001" => dout <= X"81";
       when "10010010" => dout <= X"4F";
       when "10010011" => dout <= X"DC";
       when "10010100" => dout <= X"22";
       when "10010101" => dout <= X"2A";
       when "10010110" => dout <= X"90";
       when "10010111" => dout <= X"88";
       when "10011000" => dout <= X"46";
       when "10011001" => dout <= X"EE";
       when "10011010" => dout <= X"B8";
       when "10011011" => dout <= X"14";
       when "10011100" => dout <= X"DE";
       when "10011101" => dout <= X"5E";
       when "10011110" => dout <= X"0B";
       when "10011111" => dout <= X"DB";
       when "10100000" => dout <= X"E0";
       when "10100001" => dout <= X"32";
       when "10100010" => dout <= X"3A";
       when "10100011" => dout <= X"0A";
       when "10100100" => dout <= X"49";
       when "10100101" => dout <= X"06";
       when "10100110" => dout <= X"24";
       when "10100111" => dout <= X"5C";
       when "10101000" => dout <= X"C2";
       when "10101001" => dout <= X"D3";
       when "10101010" => dout <= X"AC";
       when "10101011" => dout <= X"62";
       when "10101100" => dout <= X"91";
       when "10101101" => dout <= X"95";
       when "10101110" => dout <= X"E4";
       when "10101111" => dout <= X"79";
       when "10110000" => dout <= X"E7";
       when "10110001" => dout <= X"C8";
       when "10110010" => dout <= X"37";
       when "10110011" => dout <= X"6D";
       when "10110100" => dout <= X"8D";
       when "10110101" => dout <= X"D5";
       when "10110110" => dout <= X"4E";
       when "10110111" => dout <= X"A9";
       when "10111000" => dout <= X"6C";
       when "10111001" => dout <= X"56";
       when "10111010" => dout <= X"F4";
       when "10111011" => dout <= X"EA";
       when "10111100" => dout <= X"65";
       when "10111101" => dout <= X"7A";
       when "10111110" => dout <= X"AE";
       when "10111111" => dout <= X"08";
       when "11000000" => dout <= X"BA";
       when "11000001" => dout <= X"78";
       when "11000010" => dout <= X"25";
       when "11000011" => dout <= X"2E";
       when "11000100" => dout <= X"1C";
       when "11000101" => dout <= X"A6";
       when "11000110" => dout <= X"B4";
       when "11000111" => dout <= X"C6";
       when "11001000" => dout <= X"E8";
       when "11001001" => dout <= X"DD";
       when "11001010" => dout <= X"74";
       when "11001011" => dout <= X"1F";
       when "11001100" => dout <= X"4B";
       when "11001101" => dout <= X"BD";
       when "11001110" => dout <= X"8B";
       when "11001111" => dout <= X"8A";
       when "11010000" => dout <= X"70";
       when "11010001" => dout <= X"3E";
       when "11010010" => dout <= X"B5";
       when "11010011" => dout <= X"66";
       when "11010100" => dout <= X"48";
       when "11010101" => dout <= X"03";
       when "11010110" => dout <= X"F6";
       when "11010111" => dout <= X"0E";
       when "11011000" => dout <= X"61";
       when "11011001" => dout <= X"35";
       when "11011010" => dout <= X"57";
       when "11011011" => dout <= X"B9";
       when "11011100" => dout <= X"86";
       when "11011101" => dout <= X"C1";
       when "11011110" => dout <= X"1D";
       when "11011111" => dout <= X"9E";
       when "11100000" => dout <= X"E1";
       when "11100001" => dout <= X"F8";
       when "11100010" => dout <= X"98";
       when "11100011" => dout <= X"11";
       when "11100100" => dout <= X"69";
       when "11100101" => dout <= X"D9";
       when "11100110" => dout <= X"8E";
       when "11100111" => dout <= X"94";
       when "11101000" => dout <= X"9B";
       when "11101001" => dout <= X"1E";
       when "11101010" => dout <= X"87";
       when "11101011" => dout <= X"E9";
       when "11101100" => dout <= X"CE";
       when "11101101" => dout <= X"55";
       when "11101110" => dout <= X"28";
       when "11101111" => dout <= X"DF";
       when "11110000" => dout <= X"8C";
       when "11110001" => dout <= X"A1";
       when "11110010" => dout <= X"89";
       when "11110011" => dout <= X"0D";
       when "11110100" => dout <= X"BF";
       when "11110101" => dout <= X"E6";
       when "11110110" => dout <= X"42";
       when "11110111" => dout <= X"68";
       when "11111000" => dout <= X"41";
       when "11111001" => dout <= X"99";
       when "11111010" => dout <= X"2D";
       when "11111011" => dout <= X"0F";
       when "11111100" => dout <= X"B0";
       when "11111101" => dout <= X"54";
       when "11111110" => dout <= X"BB";
       when "11111111" => dout <= X"16";
       when others     => dout <= "--------";
    end case;
  end process;
end rtl;