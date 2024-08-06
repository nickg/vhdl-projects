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
--  Forward Table
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity FT_table is
  port ( addr  : in  std_logic_vector(7 downto 0);
         dout  : out std_logic_vector(31 downto 0));
end FT_table;


architecture rtl of FT_table is

begin

  process (addr)
  begin
    case addr is
       when "00000000" => dout <= X"C66363A5";
       when "00000001" => dout <= X"F87C7C84";
       when "00000010" => dout <= X"EE777799";
       when "00000011" => dout <= X"F67B7B8D";
       when "00000100" => dout <= X"FFF2F20D";
       when "00000101" => dout <= X"D66B6BBD";
       when "00000110" => dout <= X"DE6F6FB1";
       when "00000111" => dout <= X"91C5C554";
       when "00001000" => dout <= X"60303050";
       when "00001001" => dout <= X"02010103";
       when "00001010" => dout <= X"CE6767A9";
       when "00001011" => dout <= X"562B2B7D";
       when "00001100" => dout <= X"E7FEFE19";
       when "00001101" => dout <= X"B5D7D762";
       when "00001110" => dout <= X"4DABABE6";
       when "00001111" => dout <= X"EC76769A";
       when "00010000" => dout <= X"8FCACA45";
       when "00010001" => dout <= X"1F82829D";
       when "00010010" => dout <= X"89C9C940";
       when "00010011" => dout <= X"FA7D7D87";
       when "00010100" => dout <= X"EFFAFA15";
       when "00010101" => dout <= X"B25959EB";
       when "00010110" => dout <= X"8E4747C9";
       when "00010111" => dout <= X"FBF0F00B";
       when "00011000" => dout <= X"41ADADEC";
       when "00011001" => dout <= X"B3D4D467";
       when "00011010" => dout <= X"5FA2A2FD";
       when "00011011" => dout <= X"45AFAFEA";
       when "00011100" => dout <= X"239C9CBF";
       when "00011101" => dout <= X"53A4A4F7";
       when "00011110" => dout <= X"E4727296";
       when "00011111" => dout <= X"9BC0C05B";
       when "00100000" => dout <= X"75B7B7C2";
       when "00100001" => dout <= X"E1FDFD1C";
       when "00100010" => dout <= X"3D9393AE";
       when "00100011" => dout <= X"4C26266A";
       when "00100100" => dout <= X"6C36365A";
       when "00100101" => dout <= X"7E3F3F41";
       when "00100110" => dout <= X"F5F7F702";
       when "00100111" => dout <= X"83CCCC4F";
       when "00101000" => dout <= X"6834345C";
       when "00101001" => dout <= X"51A5A5F4";
       when "00101010" => dout <= X"D1E5E534";
       when "00101011" => dout <= X"F9F1F108";
       when "00101100" => dout <= X"E2717193";
       when "00101101" => dout <= X"ABD8D873";
       when "00101110" => dout <= X"62313153";
       when "00101111" => dout <= X"2A15153F";
       when "00110000" => dout <= X"0804040C";
       when "00110001" => dout <= X"95C7C752";
       when "00110010" => dout <= X"46232365";
       when "00110011" => dout <= X"9DC3C35E";
       when "00110100" => dout <= X"30181828";
       when "00110101" => dout <= X"379696A1";
       when "00110110" => dout <= X"0A05050F";
       when "00110111" => dout <= X"2F9A9AB5";
       when "00111000" => dout <= X"0E070709";
       when "00111001" => dout <= X"24121236";
       when "00111010" => dout <= X"1B80809B";
       when "00111011" => dout <= X"DFE2E23D";
       when "00111100" => dout <= X"CDEBEB26";
       when "00111101" => dout <= X"4E272769";
       when "00111110" => dout <= X"7FB2B2CD";
       when "00111111" => dout <= X"EA75759F";
       when "01000000" => dout <= X"1209091B";
       when "01000001" => dout <= X"1D83839E";
       when "01000010" => dout <= X"582C2C74";
       when "01000011" => dout <= X"341A1A2E";
       when "01000100" => dout <= X"361B1B2D";
       when "01000101" => dout <= X"DC6E6EB2";
       when "01000110" => dout <= X"B45A5AEE";
       when "01000111" => dout <= X"5BA0A0FB";
       when "01001000" => dout <= X"A45252F6";
       when "01001001" => dout <= X"763B3B4D";
       when "01001010" => dout <= X"B7D6D661";
       when "01001011" => dout <= X"7DB3B3CE";
       when "01001100" => dout <= X"5229297B";
       when "01001101" => dout <= X"DDE3E33E";
       when "01001110" => dout <= X"5E2F2F71";
       when "01001111" => dout <= X"13848497";
       when "01010000" => dout <= X"A65353F5";
       when "01010001" => dout <= X"B9D1D168";
       when "01010010" => dout <= X"00000000";
       when "01010011" => dout <= X"C1EDED2C";
       when "01010100" => dout <= X"40202060";
       when "01010101" => dout <= X"E3FCFC1F";
       when "01010110" => dout <= X"79B1B1C8";
       when "01010111" => dout <= X"B65B5BED";
       when "01011000" => dout <= X"D46A6ABE";
       when "01011001" => dout <= X"8DCBCB46";
       when "01011010" => dout <= X"67BEBED9";
       when "01011011" => dout <= X"7239394B";
       when "01011100" => dout <= X"944A4ADE";
       when "01011101" => dout <= X"984C4CD4";
       when "01011110" => dout <= X"B05858E8";
       when "01011111" => dout <= X"85CFCF4A";
       when "01100000" => dout <= X"BBD0D06B";
       when "01100001" => dout <= X"C5EFEF2A";
       when "01100010" => dout <= X"4FAAAAE5";
       when "01100011" => dout <= X"EDFBFB16";
       when "01100100" => dout <= X"864343C5";
       when "01100101" => dout <= X"9A4D4DD7";
       when "01100110" => dout <= X"66333355";
       when "01100111" => dout <= X"11858594";
       when "01101000" => dout <= X"8A4545CF";
       when "01101001" => dout <= X"E9F9F910";
       when "01101010" => dout <= X"04020206";
       when "01101011" => dout <= X"FE7F7F81";
       when "01101100" => dout <= X"A05050F0";
       when "01101101" => dout <= X"783C3C44";
       when "01101110" => dout <= X"259F9FBA";
       when "01101111" => dout <= X"4BA8A8E3";
       when "01110000" => dout <= X"A25151F3";
       when "01110001" => dout <= X"5DA3A3FE";
       when "01110010" => dout <= X"804040C0";
       when "01110011" => dout <= X"058F8F8A";
       when "01110100" => dout <= X"3F9292AD";
       when "01110101" => dout <= X"219D9DBC";
       when "01110110" => dout <= X"70383848";
       when "01110111" => dout <= X"F1F5F504";
       when "01111000" => dout <= X"63BCBCDF";
       when "01111001" => dout <= X"77B6B6C1";
       when "01111010" => dout <= X"AFDADA75";
       when "01111011" => dout <= X"42212163";
       when "01111100" => dout <= X"20101030";
       when "01111101" => dout <= X"E5FFFF1A";
       when "01111110" => dout <= X"FDF3F30E";
       when "01111111" => dout <= X"BFD2D26D";
       when "10000000" => dout <= X"81CDCD4C";
       when "10000001" => dout <= X"180C0C14";
       when "10000010" => dout <= X"26131335";
       when "10000011" => dout <= X"C3ECEC2F";
       when "10000100" => dout <= X"BE5F5FE1";
       when "10000101" => dout <= X"359797A2";
       when "10000110" => dout <= X"884444CC";
       when "10000111" => dout <= X"2E171739";
       when "10001000" => dout <= X"93C4C457";
       when "10001001" => dout <= X"55A7A7F2";
       when "10001010" => dout <= X"FC7E7E82";
       when "10001011" => dout <= X"7A3D3D47";
       when "10001100" => dout <= X"C86464AC";
       when "10001101" => dout <= X"BA5D5DE7";
       when "10001110" => dout <= X"3219192B";
       when "10001111" => dout <= X"E6737395";
       when "10010000" => dout <= X"C06060A0";
       when "10010001" => dout <= X"19818198";
       when "10010010" => dout <= X"9E4F4FD1";
       when "10010011" => dout <= X"A3DCDC7F";
       when "10010100" => dout <= X"44222266";
       when "10010101" => dout <= X"542A2A7E";
       when "10010110" => dout <= X"3B9090AB";
       when "10010111" => dout <= X"0B888883";
       when "10011000" => dout <= X"8C4646CA";
       when "10011001" => dout <= X"C7EEEE29";
       when "10011010" => dout <= X"6BB8B8D3";
       when "10011011" => dout <= X"2814143C";
       when "10011100" => dout <= X"A7DEDE79";
       when "10011101" => dout <= X"BC5E5EE2";
       when "10011110" => dout <= X"160B0B1D";
       when "10011111" => dout <= X"ADDBDB76";
       when "10100000" => dout <= X"DBE0E03B";
       when "10100001" => dout <= X"64323256";
       when "10100010" => dout <= X"743A3A4E";
       when "10100011" => dout <= X"140A0A1E";
       when "10100100" => dout <= X"924949DB";
       when "10100101" => dout <= X"0C06060A";
       when "10100110" => dout <= X"4824246C";
       when "10100111" => dout <= X"B85C5CE4";
       when "10101000" => dout <= X"9FC2C25D";
       when "10101001" => dout <= X"BDD3D36E";
       when "10101010" => dout <= X"43ACACEF";
       when "10101011" => dout <= X"C46262A6";
       when "10101100" => dout <= X"399191A8";
       when "10101101" => dout <= X"319595A4";
       when "10101110" => dout <= X"D3E4E437";
       when "10101111" => dout <= X"F279798B";
       when "10110000" => dout <= X"D5E7E732";
       when "10110001" => dout <= X"8BC8C843";
       when "10110010" => dout <= X"6E373759";
       when "10110011" => dout <= X"DA6D6DB7";
       when "10110100" => dout <= X"018D8D8C";
       when "10110101" => dout <= X"B1D5D564";
       when "10110110" => dout <= X"9C4E4ED2";
       when "10110111" => dout <= X"49A9A9E0";
       when "10111000" => dout <= X"D86C6CB4";
       when "10111001" => dout <= X"AC5656FA";
       when "10111010" => dout <= X"F3F4F407";
       when "10111011" => dout <= X"CFEAEA25";
       when "10111100" => dout <= X"CA6565AF";
       when "10111101" => dout <= X"F47A7A8E";
       when "10111110" => dout <= X"47AEAEE9";
       when "10111111" => dout <= X"10080818";
       when "11000000" => dout <= X"6FBABAD5";
       when "11000001" => dout <= X"F0787888";
       when "11000010" => dout <= X"4A25256F";
       when "11000011" => dout <= X"5C2E2E72";
       when "11000100" => dout <= X"381C1C24";
       when "11000101" => dout <= X"57A6A6F1";
       when "11000110" => dout <= X"73B4B4C7";
       when "11000111" => dout <= X"97C6C651";
       when "11001000" => dout <= X"CBE8E823";
       when "11001001" => dout <= X"A1DDDD7C";
       when "11001010" => dout <= X"E874749C";
       when "11001011" => dout <= X"3E1F1F21";
       when "11001100" => dout <= X"964B4BDD";
       when "11001101" => dout <= X"61BDBDDC";
       when "11001110" => dout <= X"0D8B8B86";
       when "11001111" => dout <= X"0F8A8A85";
       when "11010000" => dout <= X"E0707090";
       when "11010001" => dout <= X"7C3E3E42";
       when "11010010" => dout <= X"71B5B5C4";
       when "11010011" => dout <= X"CC6666AA";
       when "11010100" => dout <= X"904848D8";
       when "11010101" => dout <= X"06030305";
       when "11010110" => dout <= X"F7F6F601";
       when "11010111" => dout <= X"1C0E0E12";
       when "11011000" => dout <= X"C26161A3";
       when "11011001" => dout <= X"6A35355F";
       when "11011010" => dout <= X"AE5757F9";
       when "11011011" => dout <= X"69B9B9D0";
       when "11011100" => dout <= X"17868691";
       when "11011101" => dout <= X"99C1C158";
       when "11011110" => dout <= X"3A1D1D27";
       when "11011111" => dout <= X"279E9EB9";
       when "11100000" => dout <= X"D9E1E138";
       when "11100001" => dout <= X"EBF8F813";
       when "11100010" => dout <= X"2B9898B3";
       when "11100011" => dout <= X"22111133";
       when "11100100" => dout <= X"D26969BB";
       when "11100101" => dout <= X"A9D9D970";
       when "11100110" => dout <= X"078E8E89";
       when "11100111" => dout <= X"339494A7";
       when "11101000" => dout <= X"2D9B9BB6";
       when "11101001" => dout <= X"3C1E1E22";
       when "11101010" => dout <= X"15878792";
       when "11101011" => dout <= X"C9E9E920";
       when "11101100" => dout <= X"87CECE49";
       when "11101101" => dout <= X"AA5555FF";
       when "11101110" => dout <= X"50282878";
       when "11101111" => dout <= X"A5DFDF7A";
       when "11110000" => dout <= X"038C8C8F";
       when "11110001" => dout <= X"59A1A1F8";
       when "11110010" => dout <= X"09898980";
       when "11110011" => dout <= X"1A0D0D17";
       when "11110100" => dout <= X"65BFBFDA";
       when "11110101" => dout <= X"D7E6E631";
       when "11110110" => dout <= X"844242C6";
       when "11110111" => dout <= X"D06868B8";
       when "11111000" => dout <= X"824141C3";
       when "11111001" => dout <= X"299999B0";
       when "11111010" => dout <= X"5A2D2D77";
       when "11111011" => dout <= X"1E0F0F11";
       when "11111100" => dout <= X"7BB0B0CB";
       when "11111101" => dout <= X"A85454FC";
       when "11111110" => dout <= X"6DBBBBD6";
       when "11111111" => dout <= X"2C16163A";
       when others     => dout <= "--------------------------------";
    end case;
  end process;
end rtl;