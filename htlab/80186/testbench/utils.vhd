-------------------------------------------------------------------------------
-- Project       :                                                           --
-- Purpose       : Testbench Support Package                                 --
-- Library       :                                                           --
--                                                                           --
-- Version       : 1.0  20/01/2002                                           --
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
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package utils is
   
  function to_std_logic_vector(c: character) return std_logic_vector;

  function std_to_string    (inp    : std_logic_vector) return string;
  function std_to_char      (inp    : std_logic_vector) return character;
  function std_to_hex       (Vec    : std_logic_vector) return string; -- Std to hex string
        
end;

package body utils is

  -- converts a character into a std_logic_vector
  function to_std_logic_vector(c: character) return std_logic_vector is
      variable sl: std_logic_vector(7 downto 0);
      begin
        case c is
          when ' ' => sl:=X"20";
          when '0' => sl:=X"30";
          when '1' => sl:=X"31";
          when '2' => sl:=X"32";
          when '3' => sl:=X"33";
          when '4' => sl:=X"34";
          when '5' => sl:=X"35";
          when '6' => sl:=X"36";
          when '7' => sl:=X"37";
          when '8' => sl:=X"38";
          when '9' => sl:=X"39";
          when 'A' => sl:=X"41";
          when 'B' => sl:=X"42";
          when 'C' => sl:=X"43";
          when 'D' => sl:=X"44";
          when 'E' => sl:=X"45";
          when 'F' => sl:=X"46";
          when 'G' => sl:=X"47";
          when 'H' => sl:=X"48";
          when 'I' => sl:=X"49";
          when 'J' => sl:=X"4A";
          when 'K' => sl:=X"4B";
          when 'L' => sl:=X"4C";
          when 'M' => sl:=X"4D";
          when 'N' => sl:=X"4E";
          when 'O' => sl:=X"4F";
          when 'P' => sl:=X"50";
          when 'Q' => sl:=X"51";
          when 'R' => sl:=X"52";
          when 'S' => sl:=X"53";
          when 'T' => sl:=X"54";
          when 'U' => sl:=X"55";
          when 'V' => sl:=X"56";
          when 'W' => sl:=X"57";
          when 'X' => sl:=X"58";
          when 'Y' => sl:=X"59";
          when 'Z' => sl:=X"5A";
          when LF =>sl:=X"0A";
          when CR =>sl:=X"0B";
          when ESC=>sl:=X"1B";
          when others =>
              assert false
                report "ERROR: to_std_logic_vector()-> failed to convert input character";
                sl := X"00"; 
        end case;
     return sl;
    end to_std_logic_vector;
                                        
function std_to_string(inp: std_logic_vector) return string is
   variable temp: string((inp'left)+1 downto (inp'right)+1) := (others => 'X');   
 begin
   for i in inp'left downto inp'right loop
        if (inp(i) = '1') then
             temp(i+1) := '1';
          elsif (inp(i) = '0') then
              temp(i+1) := '0'; 
          end if;
       end loop;
       return temp;
 end std_to_string;

function std_to_char(inp: std_logic_vector) return character is
   constant ASCII_TABLE : string (1 to 256) :=
    ".......... .. .................. !" & '"' &
    "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI"  &
    "JKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnop"  &
    "qrstuvwxyz{|}~........................."  &
    "......................................."  &
    "......................................."  &
    "..........................";

   variable temp : integer;
 begin  
--  if inp=X"0A" then
--      return LF;
--  elsif inp=X"0D" then
--      return CR;
--  else
        temp:=CONV_INTEGER(inp)+1;
        return ASCII_TABLE(temp);
--  end if;
 end std_to_char;

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

end;
