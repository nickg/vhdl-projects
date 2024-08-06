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
PACKAGE BODY AES_pack IS

-- pragma synthesis_off
function std_to_hex(Vec : std_logic_vector) return string is
    constant L       : natural := Vec'length;
    alias MyVec      : std_logic_vector(L - 1 downto 0) is Vec;
    constant LVecFul : natural := ((L - 1)/4 + 1)*4;
    variable VecFul  : std_logic_vector(LVecFul - 1 downto 0) 
                                    := (others => '0');
    constant StrLgth : natural := LVecFul/4;
    variable Res     : string(1 to StrLgth) := (others => ' ');
    variable TempVec : std_logic_vector(3 downto 0);
    variable i       : integer := LVecFul - 1;
    variable Index   : natural := 1;
  begin
    assert L > 1 report "(std_to_hex) requires a vector!" severity error;
    
    VecFul(L - 1 downto 0) := MyVec(L -1 downto 0);
    
    while (i - 3 >= 0) loop
      TempVec(3 downto 0) := VecFul(i downto i - 3);
      case TempVec(3 downto 0) is
         when "0000" => Res(Index) := '0';
         when "0001" => Res(Index) := '1';
         when "0010" => Res(Index) := '2';
         when "0011" => Res(Index) := '3';
         when "0100" => Res(Index) := '4';
         when "0101" => Res(Index) := '5';
         when "0110" => Res(Index) := '6';
         when "0111" => Res(Index) := '7';
         when "1000" => Res(Index) := '8';
         when "1001" => Res(Index) := '9';
         when "1010" => Res(Index) := 'A';
         when "1011" => Res(Index) := 'B';
         when "1100" => Res(Index) := 'C';
         when "1101" => Res(Index) := 'D';
         when "1110" => Res(Index) := 'E';
         when "1111" => Res(Index) := 'F';
         when others => Res(Index) := 'x';
      end case; -- TempVec(3 downto 0) 
      Index := Index + 1;
      i := i - 4;
    end loop;
    
    return Res;
end std_to_hex;

-- pragma synthesis_on

END AES_pack;
