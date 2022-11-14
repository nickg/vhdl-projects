--------------------------------------------------------------------------------
-- np6532.vhd                                                                 --
-- np6532 CPU top level (np65 with 32 bit RAM, 64 bit MDR DMA port)           --
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

package np6532_pkg is

  component np6532 is
    generic (
      clk_ratio     : integer;
      ram_size_log2 : integer;
      jmp_rst       : std_logic_vector(15 downto 0);
      vec_nmi       : std_logic_vector(15 downto 0) := x"FFFA";
      vec_irq       : std_logic_vector(15 downto 0) := x"FFFE";
      vec_brk       : std_logic_vector(15 downto 0) := x"FFFE"
    );
    port (

      rsti          : in    std_logic;
      rsto          : out   std_logic;

      clk_cpu       : in    std_logic;
      clk_mem       : in    std_logic;
      clken         : out   std_logic_vector(0 to clk_ratio-1);

      hold          : in    std_logic;
      nmi           : in    std_logic;
      irq           : in    std_logic;

      if_al         : out   std_logic_vector(15 downto 0);
      if_ap         : in    std_logic_vector(ram_size_log2-1 downto 0);
      if_z          : in    std_logic;

      ls_al         : out   std_logic_vector(15 downto 0);
      ls_ap         : in    std_logic_vector(ram_size_log2-1 downto 0);
      ls_en         : out   std_logic;
      ls_re         : out   std_logic;
      ls_we         : out   std_logic;
      ls_wp         : in    std_logic;
      ls_z          : in    std_logic;
      ls_ext        : in    std_logic;
      ls_drx        : in    std_logic_vector(7 downto 0);
      ls_dwx        : out   std_logic_vector(7 downto 0);

      trace_stb     : out   std_logic;
      trace_nmi     : out   std_logic;
      trace_irq     : out   std_logic;
      trace_op      : out   std_logic_vector(23 downto 0);
      trace_pc      : out   std_logic_vector(15 downto 0);
      trace_s       : out   std_logic_vector(7 downto 0);
      trace_p       : out   std_logic_vector(7 downto 0);
      trace_a       : out   std_logic_vector(7 downto 0);
      trace_x       : out   std_logic_vector(7 downto 0);
      trace_y       : out   std_logic_vector(7 downto 0);

      dma_en        : in    std_logic;
      dma_a         : in    std_logic_vector(ram_size_log2-1 downto 3);
      dma_bwe       : in    std_logic_vector(7 downto 0);
      dma_dw        : in    std_logic_vector(63 downto 0);
      dma_dr        : out   std_logic_vector(63 downto 0)

    );
  end component np6532;

end package np6532_pkg;

--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.np6532_core_pkg.all;
  use work.np6532_ram_pkg.all;
  use work.np6532_cache_pkg.all;

entity np6532 is
  generic (
    clk_ratio     : integer;                                          -- memory:CPU clock ratio (1,2,3...)
    ram_size_log2 : integer;                                          -- 16 = 64kbytes, 17 = 128kbytes...
    jmp_rst       : std_logic_vector(15 downto 0);                    -- reset jump address
    vec_nmi       : std_logic_vector(15 downto 0) := x"FFFA";         -- NMI vector address
    vec_irq       : std_logic_vector(15 downto 0) := x"FFFE";         -- IRQ vector address
    vec_brk       : std_logic_vector(15 downto 0) := x"FFFE"          -- BRK vector address
  );
  port (

    rsti          : in    std_logic;                                  -- reset in (asynchronous)
    rsto          : out   std_logic;                                  -- reset out (synchronous)

    clk_cpu       : in    std_logic;                                  -- CPU clock
    clk_mem       : in    std_logic;                                  -- memory/DMA clock
    clken         : out   std_logic_vector(0 to clk_ratio-1);         -- clken(0) is asserted for coincidence of clk_mem and clk_cpu

    hold          : in    std_logic;                                  -- pause CPU (and enable DMA) on this cycle
    nmi           : in    std_logic;                                  -- NMI
    irq           : in    std_logic;                                  -- IRQ

    if_al         : out   std_logic_vector(15 downto 0);              -- instruction fetch logical address
    if_ap         : in    std_logic_vector(ram_size_log2-1 downto 0); -- instruction fetch physical address
    if_z          : in    std_logic;                                  -- instruction fetch physical address is empty/bad (read zero)

    ls_al         : out   std_logic_vector(15 downto 0);              -- load/store logical address
    ls_ap         : in    std_logic_vector(ram_size_log2-1 downto 0); -- load/store physical address of data
    ls_en         : out   std_logic;                                  -- load/store enable
    ls_re         : out   std_logic;                                  -- load/store read enable
    ls_we         : out   std_logic;                                  -- load/store write enable
    ls_wp         : in    std_logic;                                  -- load/store physical address is write protected
    ls_z          : in    std_logic;                                  -- load/store physical address is empty/bad (reads zero)
    ls_ext        : in    std_logic;                                  -- load/store physical address is external (e.g. h/w register)
    ls_drx        : in    std_logic_vector(7 downto 0);               -- load/store external (hardware) read data
    ls_dwx        : out   std_logic_vector(7 downto 0);               -- load/store external (hardware) write data

    trace_stb     : out   std_logic;                                  -- trace: instruction strobe (complete)
    trace_nmi     : out   std_logic;                                  -- trace: in NMI handler
    trace_irq     : out   std_logic;                                  -- trace: in IRQ handler
    trace_op      : out   std_logic_vector(23 downto 0);              -- trace opcode and operand
    trace_pc      : out   std_logic_vector(15 downto 0);              -- trace register PC
    trace_s       : out   std_logic_vector(7 downto 0);               -- trace register S
    trace_p       : out   std_logic_vector(7 downto 0);               -- trace register P
    trace_a       : out   std_logic_vector(7 downto 0);               -- trace register A
    trace_x       : out   std_logic_vector(7 downto 0);               -- trace register X
    trace_y       : out   std_logic_vector(7 downto 0);               -- trace register Y

    dma_en        : in    std_logic;                                  -- DMA enable on this clk_mem cycle
    dma_a         : in    std_logic_vector(ram_size_log2-1 downto 3); -- DMA address (Qword aligned)
    dma_bwe       : in    std_logic_vector(7 downto 0);               -- DMA byte write enables
    dma_dw        : in    std_logic_vector(63 downto 0);              -- DMA write data
    dma_dr        : out   std_logic_vector(63 downto 0)               -- DMA read data

  );
end entity np6532;

architecture synth of np6532 is

  signal   rst_s     : std_logic_vector(0 to 1); -- reset synchroniser
  signal   rst       : std_logic;                -- synchronous reset

  signal   clk_phdet : std_logic_vector(0 to 1);
  signal   clk_phase : integer range 0 to clk_ratio-1;
  signal   clken_i   : std_logic_vector(0 to clk_ratio-1);

  signal   if_en     : std_logic;
  signal   if_z_ram  : std_logic;
  signal   if_brk    : std_logic;
  signal   if_d      : std_logic_vector(31 downto 0);

  signal   ls_a      : std_logic_vector(15 downto 0);
  signal   ls_en_cpu : std_logic;
  signal   ls_we_cpu : std_logic;
  signal   ls_we_ram : std_logic;
  signal   ls_sz     : std_logic_vector(1 downto 0);
  signal   ls_ext_1  : std_logic;
  signal   ls_dr_cpu : std_logic_vector(31 downto 0);
  signal   ls_dr_ram : std_logic_vector(31 downto 0);
  signal   ls_dw_cpu : std_logic_vector(31 downto 0);

  signal   cz_a      : std_logic_vector(7 downto 0);
  signal   cz_d      : std_logic_vector(31 downto 0);
  signal   cs_a      : std_logic_vector(7 downto 0);
  signal   cs_d      : std_logic_vector(31 downto 0);

  constant base_z    : std_logic_vector(ram_size_log2-1 downto 0) := (others => '0');
  constant base_s    : std_logic_vector(ram_size_log2-1 downto 0) := (8 => '1', others => '0');

  -- Xilinx attributes
  attribute keep_hierarchy : string;
  attribute keep_hierarchy of CPU     : label is "yes";
  attribute keep_hierarchy of RAM     : label is "yes";
  attribute keep_hierarchy of CACHE_Z : label is "yes";
  attribute keep_hierarchy of CACHE_S : label is "yes";
  attribute keep : string;
  attribute keep of if_d              : signal is "true";
  attribute keep of ls_dr_cpu         : signal is "true";
  attribute keep of cz_d              : signal is "true";
  attribute keep of cs_d              : signal is "true";

begin

  -- simple outputs

  rsto      <= rst;
  clken     <= clken_i;
  ls_al     <= ls_a;
  ls_en     <= ls_en_cpu;
  ls_we     <= ls_we_cpu;
  ls_dr_cpu <= x"000000" & ls_drx when ls_ext_1 = '1' else ls_dr_ram;
  ls_dwx    <= ls_dw_cpu(7 downto 0);

  -- reset and clock enables

  DO_RST: process (rsti, clk_cpu) is
  begin
    if rsti = '1' then
      rst_s(0 to 1) <= (others => '1');
      rst           <= '1';
      clk_phdet(0)  <= '0';
      ls_ext_1      <= '0';
    elsif rising_edge(clk_cpu) then
      rst_s(0 to 1) <= rsti & rst_s(0);
      rst           <= rst_s(1);
      if rst = '0' then
        if clk_ratio = 1 then
          clk_phdet(0) <= '0';
        else
          clk_phdet(0) <= not clk_phdet(0);
        end if;
        ls_ext_1 <= ls_ext;
      end if;
    end if;
  end process DO_RST;

  DO_CLKEN: process (rsti, hold, clk_mem) is
  begin
    if rsti = '1' then
      clk_phdet(1) <= '0';
      clk_phase    <= 0;
      if clk_ratio = 1 then
        clken_i <= (others => '1');
      else
        clken_i <= (others => '0');
      end if;
    elsif rising_edge(clk_mem) and clk_ratio > 1 then
      clken_i <= (others => '0');
      if rst_s(1) = '0' then
        clk_phdet(1) <= clk_phdet(0);
        if clk_phdet(1) /= clk_phdet(0) then
          clk_phase <= 1;
        else
          clk_phase <= (clk_phase+1) mod clk_ratio;
        end if;
        if (clk_phase+2) mod clk_ratio = 0 then
          clken_i(0) <= '1';
        end if;
        if (clk_phase+1) mod clk_ratio = 0 then
          clken_i(1) <= '1';
        end if;
      end if;
      if rst = '0' then
        clken_i((clk_phase+2) mod clk_ratio) <= '1';
      end if;
    end if; -- rising_edge(clk_mem) and clk_ratio > 1
  end process DO_CLKEN;

  -- main blocks

  CPU: component np6532_core
    generic map (
      jmp_rst   => jmp_rst,
      vec_nmi   => vec_nmi,
      vec_irq   => vec_irq,
      vec_brk   => vec_brk
    )
    port map (
      clk       => clk_cpu,
      rst       => rst,
      hold      => hold,
      nmi       => nmi,
      irq       => irq,
      if_a      => if_al,
      if_en     => if_en,
      if_brk    => if_brk,
      if_d      => if_d,
      ls_a      => ls_a,
      ls_en     => ls_en_cpu,
      ls_re     => ls_re,
      ls_we     => ls_we_cpu,
      ls_sz     => ls_sz,
      ls_dw     => ls_dw_cpu,
      ls_dr     => ls_dr_cpu,
      cz_a      => cz_a,
      cz_d      => cz_d,
      cs_a      => cs_a,
      cs_d      => cs_d,
      trace_stb => trace_stb,
      trace_nmi => trace_nmi,
      trace_irq => trace_irq,
      trace_op  => trace_op,
      trace_pc  => trace_pc,
      trace_s   => trace_s,
      trace_p   => trace_p,
      trace_a   => trace_a,
      trace_x   => trace_x,
      trace_y   => trace_y
    );

  if_z_ram  <= if_z or if_brk;
  ls_we_ram <= ls_we_cpu and not (ls_ext or ls_wp);

  RAM: component np6532_ram
    generic map (
      size_log2 => ram_size_log2
    )
    port map (
      clk_cpu   => clk_cpu,
      clk_mem   => clk_mem,
      clken_0   => clken_i(0),
      if_a      => if_ap,
      if_en     => if_en,
      if_z      => if_z_ram,
      if_d      => if_d,
      ls_a      => ls_ap,
      ls_en     => ls_en_cpu,
      ls_z      => ls_z,
      ls_we     => ls_we_ram,
      ls_sz     => ls_sz,
      ls_dw     => ls_dw_cpu,
      ls_dr     => ls_dr_ram,
      dma_en    => dma_en,
      dma_a     => dma_a,
      dma_bwe   => dma_bwe,
      dma_dw    => dma_dw,
      dma_dr    => dma_dr
    );

  CACHE_Z: component np6532_cache
    generic map (
      base     => base_z
    )
    port map (
      clk_mem  => clk_mem,
      clken_0  => clken_i(0),
      dma_en   => dma_en,
      dma_a    => dma_a,
      dma_bwe  => dma_bwe,
      dma_dw   => dma_dw,
      ls_a     => ls_a,
      ls_we    => ls_we_ram,
      ls_sz    => ls_sz,
      ls_dw    => ls_dw_cpu,
      cache_a  => cz_a,
      cache_dr => cz_d
    );

  CACHE_S: component np6532_cache
    generic map (
      base     => base_s
    )
    port map (
      clk_mem  => clk_mem,
      clken_0  => clken_i(0),
      dma_en   => dma_en,
      dma_a    => dma_a,
      dma_bwe  => dma_bwe,
      dma_dw   => dma_dw,
      ls_a     => ls_a,
      ls_we    => ls_we_ram,
      ls_sz    => ls_sz,
      ls_dw    => ls_dw_cpu,
      cache_a  => cs_a,
      cache_dr => cs_d
    );

end architecture synth;
