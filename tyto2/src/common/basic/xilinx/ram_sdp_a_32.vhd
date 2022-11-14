--------------------------------------------------------------------------------
-- ram_sdp_a_32.vhd                                                           --
-- Simple dual port RAM, asynchronous read, 32 words deep.                    --
-- Built from Xilinx ram64x1d primitive.                                      --
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

package ram_sdp_a_32_pkg is

  component ram_sdp_a_32 is
    generic (
      width : integer
    );
    port (
      clk   : in    std_logic;
      ce    : in    std_logic;
      we    : in    std_logic;
      wa    : in    std_logic_vector(4 downto 0);
      wd    : in    std_logic_vector(width-1 downto 0);
      ra    : in    std_logic_vector(4 downto 0);
      rd    : out   std_logic_vector(width-1 downto 0)
    );
  end component ram_sdp_a_32;

end package ram_sdp_a_32_pkg;

--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

entity ram_sdp_a_32 is
  generic (
    width : integer
  );
  port (
    clk   : in    std_logic;
    ce    : in    std_logic;
    we    : in    std_logic;
    wa    : in    std_logic_vector(4 downto 0);
    wd    : in    std_logic_vector(width-1 downto 0);
    ra    : in    std_logic_vector(4 downto 0);
    rd    : out   std_logic_vector(width-1 downto 0)
  );
end entity ram_sdp_a_32;

architecture struct of ram_sdp_a_32 is

begin

  gen_bit: for i in 0 to width-1 generate

    RAM : component ram64x1d
      port map (
        wclk  => clk,
        a0    => wa(0),
        a1    => wa(1),
        a2    => wa(2),
        a3    => wa(3),
        a4    => wa(4),
        a5    => ce,
        we    => we,
        d     => wd(i),
        spo   => open,
        dpra0 => ra(0),
        dpra1 => ra(1),
        dpra2 => ra(2),
        dpra3 => ra(3),
        dpra4 => ra(4),
        dpra5 => '1',
        dpo   => rd(i)
      );

  end generate gen_bit;

end architecture struct;
