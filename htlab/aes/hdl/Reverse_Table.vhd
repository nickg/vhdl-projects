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
-- Reverse Table
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity RT_table is
  port ( addr  : in  std_logic_vector(7 downto 0);
         dout  : out std_logic_vector(31 downto 0));
end RT_table;


architecture rtl of RT_table is

begin

  process (addr)
  begin
    case addr is
       when "00000000" => dout <= X"51F4A750";
       when "00000001" => dout <= X"7E416553";
       when "00000010" => dout <= X"1A17A4C3";
       when "00000011" => dout <= X"3A275E96";
       when "00000100" => dout <= X"3BAB6BCB";
       when "00000101" => dout <= X"1F9D45F1";
       when "00000110" => dout <= X"ACFA58AB";
       when "00000111" => dout <= X"4BE30393";
       when "00001000" => dout <= X"2030FA55";
       when "00001001" => dout <= X"AD766DF6";
       when "00001010" => dout <= X"88CC7691";
       when "00001011" => dout <= X"F5024C25";
       when "00001100" => dout <= X"4FE5D7FC";
       when "00001101" => dout <= X"C52ACBD7";
       when "00001110" => dout <= X"26354480";
       when "00001111" => dout <= X"B562A38F";
       when "00010000" => dout <= X"DEB15A49";
       when "00010001" => dout <= X"25BA1B67";
       when "00010010" => dout <= X"45EA0E98";
       when "00010011" => dout <= X"5DFEC0E1";
       when "00010100" => dout <= X"C32F7502";
       when "00010101" => dout <= X"814CF012";
       when "00010110" => dout <= X"8D4697A3";
       when "00010111" => dout <= X"6BD3F9C6";
       when "00011000" => dout <= X"038F5FE7";
       when "00011001" => dout <= X"15929C95";
       when "00011010" => dout <= X"BF6D7AEB";
       when "00011011" => dout <= X"955259DA";
       when "00011100" => dout <= X"D4BE832D";
       when "00011101" => dout <= X"587421D3";
       when "00011110" => dout <= X"49E06929";
       when "00011111" => dout <= X"8EC9C844";
       when "00100000" => dout <= X"75C2896A";
       when "00100001" => dout <= X"F48E7978";
       when "00100010" => dout <= X"99583E6B";
       when "00100011" => dout <= X"27B971DD";
       when "00100100" => dout <= X"BEE14FB6";
       when "00100101" => dout <= X"F088AD17";
       when "00100110" => dout <= X"C920AC66";
       when "00100111" => dout <= X"7DCE3AB4";
       when "00101000" => dout <= X"63DF4A18";
       when "00101001" => dout <= X"E51A3182";
       when "00101010" => dout <= X"97513360";
       when "00101011" => dout <= X"62537F45";
       when "00101100" => dout <= X"B16477E0";
       when "00101101" => dout <= X"BB6BAE84";
       when "00101110" => dout <= X"FE81A01C";
       when "00101111" => dout <= X"F9082B94";
       when "00110000" => dout <= X"70486858";
       when "00110001" => dout <= X"8F45FD19";
       when "00110010" => dout <= X"94DE6C87";
       when "00110011" => dout <= X"527BF8B7";
       when "00110100" => dout <= X"AB73D323";
       when "00110101" => dout <= X"724B02E2";
       when "00110110" => dout <= X"E31F8F57";
       when "00110111" => dout <= X"6655AB2A";
       when "00111000" => dout <= X"B2EB2807";
       when "00111001" => dout <= X"2FB5C203";
       when "00111010" => dout <= X"86C57B9A";
       when "00111011" => dout <= X"D33708A5";
       when "00111100" => dout <= X"302887F2";
       when "00111101" => dout <= X"23BFA5B2";
       when "00111110" => dout <= X"02036ABA";
       when "00111111" => dout <= X"ED16825C";
       when "01000000" => dout <= X"8ACF1C2B";
       when "01000001" => dout <= X"A779B492";
       when "01000010" => dout <= X"F307F2F0";
       when "01000011" => dout <= X"4E69E2A1";
       when "01000100" => dout <= X"65DAF4CD";
       when "01000101" => dout <= X"0605BED5";
       when "01000110" => dout <= X"D134621F";
       when "01000111" => dout <= X"C4A6FE8A";
       when "01001000" => dout <= X"342E539D";
       when "01001001" => dout <= X"A2F355A0";
       when "01001010" => dout <= X"058AE132";
       when "01001011" => dout <= X"A4F6EB75";
       when "01001100" => dout <= X"0B83EC39";
       when "01001101" => dout <= X"4060EFAA";
       when "01001110" => dout <= X"5E719F06";
       when "01001111" => dout <= X"BD6E1051";
       when "01010000" => dout <= X"3E218AF9";
       when "01010001" => dout <= X"96DD063D";
       when "01010010" => dout <= X"DD3E05AE";
       when "01010011" => dout <= X"4DE6BD46";
       when "01010100" => dout <= X"91548DB5";
       when "01010101" => dout <= X"71C45D05";
       when "01010110" => dout <= X"0406D46F";
       when "01010111" => dout <= X"605015FF";
       when "01011000" => dout <= X"1998FB24";
       when "01011001" => dout <= X"D6BDE997";
       when "01011010" => dout <= X"894043CC";
       when "01011011" => dout <= X"67D99E77";
       when "01011100" => dout <= X"B0E842BD";
       when "01011101" => dout <= X"07898B88";
       when "01011110" => dout <= X"E7195B38";
       when "01011111" => dout <= X"79C8EEDB";
       when "01100000" => dout <= X"A17C0A47";
       when "01100001" => dout <= X"7C420FE9";
       when "01100010" => dout <= X"F8841EC9";
       when "01100011" => dout <= X"00000000";
       when "01100100" => dout <= X"09808683";
       when "01100101" => dout <= X"322BED48";
       when "01100110" => dout <= X"1E1170AC";
       when "01100111" => dout <= X"6C5A724E";
       when "01101000" => dout <= X"FD0EFFFB";
       when "01101001" => dout <= X"0F853856";
       when "01101010" => dout <= X"3DAED51E";
       when "01101011" => dout <= X"362D3927";
       when "01101100" => dout <= X"0A0FD964";
       when "01101101" => dout <= X"685CA621";
       when "01101110" => dout <= X"9B5B54D1";
       when "01101111" => dout <= X"24362E3A";
       when "01110000" => dout <= X"0C0A67B1";
       when "01110001" => dout <= X"9357E70F";
       when "01110010" => dout <= X"B4EE96D2";
       when "01110011" => dout <= X"1B9B919E";
       when "01110100" => dout <= X"80C0C54F";
       when "01110101" => dout <= X"61DC20A2";
       when "01110110" => dout <= X"5A774B69";
       when "01110111" => dout <= X"1C121A16";
       when "01111000" => dout <= X"E293BA0A";
       when "01111001" => dout <= X"C0A02AE5";
       when "01111010" => dout <= X"3C22E043";
       when "01111011" => dout <= X"121B171D";
       when "01111100" => dout <= X"0E090D0B";
       when "01111101" => dout <= X"F28BC7AD";
       when "01111110" => dout <= X"2DB6A8B9";
       when "01111111" => dout <= X"141EA9C8";
       when "10000000" => dout <= X"57F11985";
       when "10000001" => dout <= X"AF75074C";
       when "10000010" => dout <= X"EE99DDBB";
       when "10000011" => dout <= X"A37F60FD";
       when "10000100" => dout <= X"F701269F";
       when "10000101" => dout <= X"5C72F5BC";
       when "10000110" => dout <= X"44663BC5";
       when "10000111" => dout <= X"5BFB7E34";
       when "10001000" => dout <= X"8B432976";
       when "10001001" => dout <= X"CB23C6DC";
       when "10001010" => dout <= X"B6EDFC68";
       when "10001011" => dout <= X"B8E4F163";
       when "10001100" => dout <= X"D731DCCA";
       when "10001101" => dout <= X"42638510";
       when "10001110" => dout <= X"13972240";
       when "10001111" => dout <= X"84C61120";
       when "10010000" => dout <= X"854A247D";
       when "10010001" => dout <= X"D2BB3DF8";
       when "10010010" => dout <= X"AEF93211";
       when "10010011" => dout <= X"C729A16D";
       when "10010100" => dout <= X"1D9E2F4B";
       when "10010101" => dout <= X"DCB230F3";
       when "10010110" => dout <= X"0D8652EC";
       when "10010111" => dout <= X"77C1E3D0";
       when "10011000" => dout <= X"2BB3166C";
       when "10011001" => dout <= X"A970B999";
       when "10011010" => dout <= X"119448FA";
       when "10011011" => dout <= X"47E96422";
       when "10011100" => dout <= X"A8FC8CC4";
       when "10011101" => dout <= X"A0F03F1A";
       when "10011110" => dout <= X"567D2CD8";
       when "10011111" => dout <= X"223390EF";
       when "10100000" => dout <= X"87494EC7";
       when "10100001" => dout <= X"D938D1C1";
       when "10100010" => dout <= X"8CCAA2FE";
       when "10100011" => dout <= X"98D40B36";
       when "10100100" => dout <= X"A6F581CF";
       when "10100101" => dout <= X"A57ADE28";
       when "10100110" => dout <= X"DAB78E26";
       when "10100111" => dout <= X"3FADBFA4";
       when "10101000" => dout <= X"2C3A9DE4";
       when "10101001" => dout <= X"5078920D";
       when "10101010" => dout <= X"6A5FCC9B";
       when "10101011" => dout <= X"547E4662";
       when "10101100" => dout <= X"F68D13C2";
       when "10101101" => dout <= X"90D8B8E8";
       when "10101110" => dout <= X"2E39F75E";
       when "10101111" => dout <= X"82C3AFF5";
       when "10110000" => dout <= X"9F5D80BE";
       when "10110001" => dout <= X"69D0937C";
       when "10110010" => dout <= X"6FD52DA9";
       when "10110011" => dout <= X"CF2512B3";
       when "10110100" => dout <= X"C8AC993B";
       when "10110101" => dout <= X"10187DA7";
       when "10110110" => dout <= X"E89C636E";
       when "10110111" => dout <= X"DB3BBB7B";
       when "10111000" => dout <= X"CD267809";
       when "10111001" => dout <= X"6E5918F4";
       when "10111010" => dout <= X"EC9AB701";
       when "10111011" => dout <= X"834F9AA8";
       when "10111100" => dout <= X"E6956E65";
       when "10111101" => dout <= X"AAFFE67E";
       when "10111110" => dout <= X"21BCCF08";
       when "10111111" => dout <= X"EF15E8E6";
       when "11000000" => dout <= X"BAE79BD9";
       when "11000001" => dout <= X"4A6F36CE";
       when "11000010" => dout <= X"EA9F09D4";
       when "11000011" => dout <= X"29B07CD6";
       when "11000100" => dout <= X"31A4B2AF";
       when "11000101" => dout <= X"2A3F2331";
       when "11000110" => dout <= X"C6A59430";
       when "11000111" => dout <= X"35A266C0";
       when "11001000" => dout <= X"744EBC37";
       when "11001001" => dout <= X"FC82CAA6";
       when "11001010" => dout <= X"E090D0B0";
       when "11001011" => dout <= X"33A7D815";
       when "11001100" => dout <= X"F104984A";
       when "11001101" => dout <= X"41ECDAF7";
       when "11001110" => dout <= X"7FCD500E";
       when "11001111" => dout <= X"1791F62F";
       when "11010000" => dout <= X"764DD68D";
       when "11010001" => dout <= X"43EFB04D";
       when "11010010" => dout <= X"CCAA4D54";
       when "11010011" => dout <= X"E49604DF";
       when "11010100" => dout <= X"9ED1B5E3";
       when "11010101" => dout <= X"4C6A881B";
       when "11010110" => dout <= X"C12C1FB8";
       when "11010111" => dout <= X"4665517F";
       when "11011000" => dout <= X"9D5EEA04";
       when "11011001" => dout <= X"018C355D";
       when "11011010" => dout <= X"FA877473";
       when "11011011" => dout <= X"FB0B412E";
       when "11011100" => dout <= X"B3671D5A";
       when "11011101" => dout <= X"92DBD252";
       when "11011110" => dout <= X"E9105633";
       when "11011111" => dout <= X"6DD64713";
       when "11100000" => dout <= X"9AD7618C";
       when "11100001" => dout <= X"37A10C7A";
       when "11100010" => dout <= X"59F8148E";
       when "11100011" => dout <= X"EB133C89";
       when "11100100" => dout <= X"CEA927EE";
       when "11100101" => dout <= X"B761C935";
       when "11100110" => dout <= X"E11CE5ED";
       when "11100111" => dout <= X"7A47B13C";
       when "11101000" => dout <= X"9CD2DF59";
       when "11101001" => dout <= X"55F2733F";
       when "11101010" => dout <= X"1814CE79";
       when "11101011" => dout <= X"73C737BF";
       when "11101100" => dout <= X"53F7CDEA";
       when "11101101" => dout <= X"5FFDAA5B";
       when "11101110" => dout <= X"DF3D6F14";
       when "11101111" => dout <= X"7844DB86";
       when "11110000" => dout <= X"CAAFF381";
       when "11110001" => dout <= X"B968C43E";
       when "11110010" => dout <= X"3824342C";
       when "11110011" => dout <= X"C2A3405F";
       when "11110100" => dout <= X"161DC372";
       when "11110101" => dout <= X"BCE2250C";
       when "11110110" => dout <= X"283C498B";
       when "11110111" => dout <= X"FF0D9541";
       when "11111000" => dout <= X"39A80171";
       when "11111001" => dout <= X"080CB3DE";
       when "11111010" => dout <= X"D8B4E49C";
       when "11111011" => dout <= X"6456C190";
       when "11111100" => dout <= X"7BCB8461";
       when "11111101" => dout <= X"D532B670";
       when "11111110" => dout <= X"486C5C74";
       when "11111111" => dout <= X"D0B85742";
       when others     => dout <= "--------------------------------";
    end case;
  end process;
end rtl;