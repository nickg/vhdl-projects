--------------------------------------------------------------------------------
-- tyto_types_pkg.vhd                                                         --
-- Useful type declarations.                                                  --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>                        --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with The Tyto Project. If not, see     --
-- https://www.gnu.org/licenses/.                                             --
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

package tyto_types_pkg is

  type    sl2d_t is array(natural range <>, natural range <>) of std_logic;
  type    slv_31_0_t is array(natural range <>) of std_logic_vector(31 downto 0);
  type    slv_1_0_t is array(natural range <>) of std_logic_vector(1 downto 0);
  type    slv_3_0_t is array(natural range <>) of std_logic_vector(3 downto 0);
  type    slv_7_0_t is array(natural range <>) of std_logic_vector(7 downto 0);
  type    slv_7_2_t is array(natural range <>) of std_logic_vector(7 downto 2);
  type    slv_7_3_t is array(natural range <>) of std_logic_vector(7 downto 3);
  type    slv_8_0_t is array(natural range <>) of std_logic_vector(8 downto 0);
  type    slv_9_0_t is array(natural range <>) of std_logic_vector(9 downto 0);
  type    slv_7_0_2d_t is array(natural range <>, natural range <>) of std_logic_vector(7 downto 0);
  type    slv_3_0_2d_t is array(natural range <>, natural range <>) of std_logic_vector(3 downto 0);

  subtype uint8_t is integer range 0 to 255;
  type    uint8_array_t is array(natural range <>) of uint8_t;

  type    int_array_t is array(natural range <>) of integer;

  type    pixel_t is array(0 to 2) of uint8_t;
  type    bmp_t is array(natural range <>, natural range <>) of pixel_t;

  type    real_array_t is array(natural range <>) of real;

  type    file_char_t is file of character;

end package tyto_types_pkg;
