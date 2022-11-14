--------------------------------------------------------------------------------
-- tyto_sim_pkg.vhd                                                           --
-- Simulation support procedures etc.                                         --
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
  use ieee.numeric_std.all;

library std;
  use std.textio.all;

library work;
  use work.tyto_types_pkg.all;

package tyto_sim_pkg is

  procedure stim_clock (signal clock : inout std_logic; period : in time);

  procedure stim_reset (signal reset : inout std_logic; level : in std_logic; period : in time);

  procedure write_bmp (
    name       : in string;
    img        : in bmp_t;
    width      : in integer;
    hieght     : in integer;
    interlaced : in boolean
  );

  impure function read_bin (filename : string; size : integer) return uint8_array_t;

end package tyto_sim_pkg;

package body tyto_sim_pkg is

  procedure stim_clock (signal clock : inout std_logic; period : in time) is
  begin
    if clock = '1' then
      clock <= '0' after period/2;
    elsif clock = '0' then
      clock <= '1' after period/2;
    else
      clock <= '1';
    end if;
  end procedure stim_clock;

  procedure stim_reset (signal reset : inout std_logic; level : in std_logic; period : in time) is
  begin
    if reset = level then
      reset <= not level after period;
    elsif reset = not level then
      null;
    else
      reset <= level;
    end if;
  end procedure stim_reset;

  procedure write_bmp (
    name       : in string;
    img        : in bmp_t;
    width      : in integer;
    hieght     : in integer;
    interlaced : in boolean
  ) is
    type     char_file_t is file of character;

    file     f            : char_file_t;
    type     bmp_hdr_t is array (0 to 53) of unsigned(7 downto 0);

    variable bmp_filesize : unsigned(31 downto 0) := unsigned(to_unsigned(bmp_hdr_t'length+(3*width*hieght), 32));
    variable bmp_size_x   : unsigned(31 downto 0) := unsigned(to_unsigned(width, 32));
    variable bmp_size_y   : unsigned(31 downto 0) := unsigned(to_unsigned(hieght, 32));
    variable bmp_imgsize  : unsigned(31 downto 0) := unsigned(to_unsigned(3*width*hieght, 32));
    variable bmp_header   : bmp_hdr_t :=
            (
              x"42", x"4D",
             bmp_filesize(7 downto 0), bmp_filesize(15 downto 8), bmp_filesize(23 downto 16), bmp_filesize(31 downto 24),
              x"00", x"00", x"00", x"00", x"36", x"00", x"00", x"00", x"28", x"00", x"00", x"00",
             bmp_size_x(7 downto 0), bmp_size_x(15 downto 8), bmp_size_x(23 downto 16), bmp_size_x(31 downto 24),
              bmp_size_y(7 downto 0), bmp_size_y(15 downto 8), bmp_size_y(23 downto 16), bmp_size_y(31 downto 24),
              x"01", x"00", x"18", x"00", x"00", x"00", x"00", x"00",
             bmp_imgsize(7 downto 0), bmp_imgsize(15 downto 8), bmp_imgsize(23 downto 16), bmp_imgsize(31 downto 24),
              x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
           );
    variable y            : integer;
  begin
    file_open(f, name&".bmp", WRITE_MODE);
    for i in 0 to bmp_header'length-1 loop
      write(f, character'val(to_integer(bmp_header(i))));
    end loop;
    for y_raw in hieght-1 downto 0 loop -- BMP origin is bottom left
      if interlaced then
        y := (y_raw/2);
        if y_raw mod 2 = 1 then
          y := y+(hieght/2);
        end if;
      else
        y := y_raw;
      end if;
      for x in 0 to width-1 loop
        write(f, character'val(img(x,y)(2)));
        write(f, character'val(img(x,y)(1)));
        write(f, character'val(img(x,y)(0)));
      end loop;
    end loop;
  end procedure write_bmp;

  impure function read_bin (filename : string; size : integer) return uint8_array_t is
    variable r : uint8_array_t(0 to size-1);
    file f : file_char_t open read_mode is filename;
    variable c : character;
  begin
    for i in 0 to size-1 loop
      read(f, c);
      r(i) := character'pos(c);
    end loop;
    return r;
  end function read_bin;

end package body tyto_sim_pkg;
