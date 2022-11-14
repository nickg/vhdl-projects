--------------------------------------------------------------------------------
-- ldce.vhd                                                                   --
-- D-type transparent bus latch with async clear and gate enable.             --
-- Built from AMD/Xilinx ldce primitive.                                      --
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

package ldce_bus_pkg is

  component ldce_bus is
    generic (
      width : integer
    );
    port (
      clr   : in    std_logic;
      g     : in    std_logic;
      ge    : in    std_logic;
      d     : in    std_logic_vector(width-1 downto 0);
      q     : out   std_logic_vector(width-1 downto 0)
    );
  end component ldce_bus;

end package ldce_bus_pkg;

--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library unisim;
  use unisim.vcomponents.all;

entity ldce_bus is
  generic (
    width : integer
  );
  port (
    clr   : in    std_logic;
    g     : in    std_logic;
    ge    : in    std_logic;
    d     : in    std_logic_vector(width-1 downto 0);
    q     : out   std_logic_vector(width-1 downto 0)
  );
end entity ldce_bus;

architecture struct of ldce_bus is

begin

  gen : for i in 0 to width - 1 generate

    LATCH: component ldce
      port map (
        clr => clr,
        g   => g,
        ge  => ge,
        d   => d(i),
        q   => q(i)
      );

  end generate gen;

end architecture struct;
