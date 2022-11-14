--------------------------------------------------------------------------------
-- np6532_ram.vhd                                                             --
-- RAM for np6532 CPU (32 bit CPU ports, 64 bit MDR DMA port)                 --
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

package np6532_ram_pkg is

  component np6532_ram is
    generic (
      size_log2 : integer
    );
    port (

      clk_cpu   : in    std_logic;
      clk_mem   : in    std_logic;
      clken_0   : in    std_logic;

      if_a      : in    std_logic_vector(size_log2-1 downto 0);
      if_en     : in    std_logic;
      if_z      : in    std_logic;
      if_d      : out   std_logic_vector(31 downto 0);

      ls_a      : in    std_logic_vector(size_log2-1 downto 0);
      ls_en     : in    std_logic;
      ls_z      : in    std_logic;
      ls_we     : in    std_logic;
      ls_sz     : in    std_logic_vector(1 downto 0);
      ls_dw     : in    std_logic_vector(31 downto 0);
      ls_dr     : out   std_logic_vector(31 downto 0);

      dma_en    : in    std_logic;
      dma_a     : in    std_logic_vector(size_log2-1 downto 3);
      dma_bwe   : in    std_logic_vector(7 downto 0);
      dma_dw    : in    std_logic_vector(63 downto 0);
      dma_dr    : out   std_logic_vector(63 downto 0)

    );
  end component np6532_ram;

end package np6532_ram_pkg;

--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.tyto_types_pkg.all;
  use work.tyto_utils_pkg.all;
  use work.np6532_ram_init_pkg.all;
  use work.ram_tdp_s_pkg.all;
  use work.ldce_bus_pkg.all;

entity np6532_ram is
  generic (
    size_log2 : integer                                       -- 16 = 64kbytes, 17 = 128kbytes...
  );
  port (

    clk_cpu   : in    std_logic;                              -- CPU clock
    clk_mem   : in    std_logic;                              -- memory/DMA clock
    clken_0   : in    std_logic;                              -- asserted when edges are coincident (start of clock phase 0)

    if_a      : in    std_logic_vector(size_log2-1 downto 0); -- instruction fetch address
    if_en     : in    std_logic;                              -- instruction fetch enable
    if_z      : in    std_logic;                              -- instruction fetch zero (BRK)
    if_d      : out   std_logic_vector(31 downto 0);          -- instruction fetch data

    ls_a      : in    std_logic_vector(size_log2-1 downto 0); -- load/store address
    ls_en     : in    std_logic;                              -- load/store enable
    ls_z      : in    std_logic;                              -- load/store zero
    ls_we     : in    std_logic;                              -- load/store write enable (indicates store)
    ls_sz     : in    std_logic_vector(1 downto 0);           -- load/store transfer size (bytes) = 1+ls_sz
    ls_dw     : in    std_logic_vector(31 downto 0);          -- store data (writes)
    ls_dr     : out   std_logic_vector(31 downto 0);          -- load data (reads)

    dma_en    : in    std_logic;                              -- DMA enable on this clk_mem cycle
    dma_a     : in    std_logic_vector(size_log2-1 downto 3); -- DMA address (Qword aligned)
    dma_bwe   : in    std_logic_vector(7 downto 0);           -- DMA byte write enables
    dma_dw    : in    std_logic_vector(63 downto 0);          -- DMA write data
    dma_dr    : out   std_logic_vector(63 downto 0)           -- DMA read data

  );
end entity np6532_ram;

architecture synth of np6532_ram is

  type   ram_addr is array(natural range <>) of std_logic_vector(size_log2-1 downto 2);

  signal if_en_1     : std_logic;                    -- if_en, latched
  signal if_i        : integer range 0 to 3;         -- 2 LSBs of if_a, latched
  signal ls_en_1     : std_logic;                    -- ls_en, latched
  signal ls_i        : integer range 0 to 3;         -- 2 LSBs of ls_a, latched
  signal ls_bwe      : std_logic_vector(3 downto 0); -- ls byte write enables

  signal ram_ce_a    : std_logic;
  signal ram_we_a    : std_logic_vector(3 downto 0);
  signal ram_addr_a  : ram_addr(3 downto 0);
  signal ram_din_a   : std_logic_vector(31 downto 0);
  signal ram_dout_a  : std_logic_vector(31 downto 0);
  signal ram_dout_al : std_logic_vector(31 downto 0);

  signal ram_ce_b    : std_logic;
  signal ram_we_b    : std_logic_vector(3 downto 0);
  signal ram_addr_b  : ram_addr(3 downto 0);
  signal ram_din_b   : std_logic_vector(31 downto 0);
  signal ram_dout_b  : std_logic_vector(31 downto 0);
  signal ram_dout_bl : std_logic_vector(31 downto 0);

  function rambank2sl2d (constant x : ram_bank_t) return sl2d_t is
    variable r : sl2d_t(0 to (2**(size_log2-2))-1, 7 downto 0);
  begin
    for i in 0 to r'length-1 loop
      for j in 0 to 7 loop
        r(i,j) := x(i)(j);
      end loop;
    end loop;
    return r;
  end function rambank2sl2d;

begin

  INDEX: process (clk_cpu) is
  begin
    if rising_edge(clk_cpu) then
      if if_en = '1' then
        if_i <= to_integer(unsigned(if_a(1 downto 0)));
      end if;
      if ls_en = '1' then
        ls_i <= to_integer(unsigned(ls_a(1 downto 0)));
      end if;
    end if;
  end process INDEX;

  ram_ce_a <= dma_en or (clken_0 and if_en);
  ram_ce_b <= dma_en or (clken_0 and ls_en);

  gen_ram: for i in 0 to 3 generate
    -- Xilinx synthesis attributes
    attribute keep_hierarchy : string;
    attribute keep_hierarchy of RAM : label is "yes";
  begin

    ls_bwe(i) <= ls_we when i <= ls_sz else '0';

    ram_addr_a(i) <= dma_a & '0' when dma_en = '1' else if_a(size_log2-1 downto 2) + (i < if_a(1 downto 0));

    ram_addr_b(i)(size_log2-1 downto 8) <= dma_a(size_log2-1 downto 8) when dma_en = '1' else ls_a(size_log2-1 downto 8);

    -- multi byte writes wrap within page (because they are all stack pushes - for now)
    ram_addr_b(i)(7 downto 2) <= dma_a(7 downto 3) & '1' when dma_en = '1' else ls_a(7 downto 2) + (i < ls_a(1 downto 0));

    ram_we_a(i) <= dma_bwe(i) when dma_en = '1' else '0';

    ram_we_b(i) <= dma_bwe(4+i) when dma_en = '1' else ls_bwe((i+(4-ls_a(1 downto 0))) mod 4);

    ram_din_a(7+(8*i) downto 8*i) <= dma_dw(7+(8*i) downto 8*i);

    ram_din_b(7+(8*i) downto 8*i) <= dma_dw(7+(8*(4+i)) downto 8*(4+i)) when dma_en = '1' else
                                     ls_dw(7+(8*((i+1) mod 4)) downto 8*((i+1) mod 4)) when ls_a(1 downto 0) = "11" else
                                     ls_dw(7+(8*((i+2) mod 4)) downto 8*((i+2) mod 4)) when ls_a(1 downto 0) = "10" else
                                     ls_dw(7+(8*((i+3) mod 4)) downto 8*((i+3) mod 4)) when ls_a(1 downto 0) = "01" else
                                     ls_dw(7+(8*((i+0) mod 4)) downto 8*((i+0) mod 4));

    RAM: component ram_tdp_s
      generic map (
        width      => 8,
        depth_log2 => size_log2-2,
        init       => rambank2sl2d(ram_init(i))
      )
      port map (
        clk        => clk_mem,
        ce_a       => ram_ce_a,
        we_a       => ram_we_a(i),
        addr_a     => ram_addr_a(i),
        din_a      => ram_din_a(7+(8*i) downto 8*i),
        dout_a     => ram_dout_a(7+(8*i) downto 8*i),
        ce_b       => ram_ce_b,
        we_b       => ram_we_b(i),
        addr_b     => ram_addr_b(i),
        din_b      => ram_din_b(7+(8*i) downto 8*i),
        dout_b     => ram_dout_b(7+(8*i) downto 8*i)
      );

    if_d(7+(8*i) downto 8*i)           <= ram_dout_al(7+(8*((i+if_i) mod 4)) downto 8*((i+if_i) mod 4));
    ls_dr(7+(8*i) downto 8*i)          <= ram_dout_bl(7+(8*((i+ls_i) mod 4)) downto 8*((i+ls_i) mod 4));
    dma_dr(7+(8*i) downto 8*i)         <= ram_dout_a(7+(8*i) downto 8*i);
    dma_dr(7+(8*(4+i)) downto 8*(4+i)) <= ram_dout_b(7+(8*i) downto 8*i);

  end generate gen_ram;

  LATCH_IF_EN: process (clk_cpu, if_en) is
  begin
    if clk_cpu = '0' then if_en_1 <= if_en; end if;
  end process LATCH_IF_EN;

  LATCH_A: component ldce_bus
    generic map (
      width => 32
    )
    port map (
      clr   => if_z,
      g     => clk_cpu,
      ge    => if_en_1,
      d     => ram_dout_a,
      q     => ram_dout_al
    );

  LATCH_LS_EN: process (clk_cpu, ls_en) is
  begin
    if clk_cpu = '0' then ls_en_1 <= ls_en; end if;
  end process LATCH_LS_EN;

  LATCH_B: component ldce_bus
    generic map (
      width => 32
    )
    port map (
      clr   => ls_z,
      g     => clk_cpu,
      ge    => ls_en_1,
      d     => ram_dout_b,
      q     => ram_dout_bl
    );

end architecture synth;
