--------------------------------------------------------------------------------
-- np6532_functest.vhd                                                        --
-- Simulation of np6532 core running Klaus Dormann's 6502 functional test.    --
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
  use ieee.math_real.all; -- for uniform function
  use ieee.std_logic_textio.all;

library std;
  use std.textio.all;
  use std.env.all;

library work;
  use work.np6532_pkg.all;
  use work.np65_decoder_pkg.all;

entity np6532_functest is
  generic (
    vector_init       : integer;
    start_address     : integer;
    ref_file          : string;
    progress_interval : integer := 100000
  );
end entity np6532_functest;

architecture sim of np6532_functest is

  constant ram_size_log2  : integer := 17;                -- at least 128k required for DMA testing
  constant clk_ratio      : integer := 3;
  constant clk_mem_period : time := 10 ns;
  constant test_hold      : boolean := true;
  constant test_dma       : boolean := true;
  constant test_nmi       : boolean := true;
  constant test_irq       : boolean := true;

  type     slv_127_0_t is array(natural range <>) of std_logic_vector(127 downto 0);

  constant init_seed      : slv_127_0_t :=
  (
    x"0123456789ABCDEF0123456789ABCDEF",
    x"123456789ABCDEF0123456789ABCDEF0"
  );

  signal   clk_phase      : integer range 0 to (clk_ratio*2)-1 := 0;
  signal   clk_cpu        : std_logic;
  signal   clk_mem        : std_logic;
  signal   clken          : std_logic_vector(0 to clk_ratio-1);

  signal   rst            : std_logic;
  signal   rsto           : std_logic;

  signal   hold           : std_logic;
  signal   nmi            : std_logic;
  signal   irq            : std_logic;
  signal   if_al          : std_logic_vector(15 downto 0);
  signal   if_ap          : std_logic_vector(ram_size_log2-1 downto 0);
  signal   if_z           : std_logic;
  signal   ls_al          : std_logic_vector(15 downto 0);
  signal   ls_ap          : std_logic_vector(ram_size_log2-1 downto 0);
  signal   ls_en          : std_logic;
  signal   ls_re          : std_logic;
  signal   ls_we          : std_logic;
  signal   ls_wp          : std_logic;
  signal   ls_z           : std_logic;
  signal   ls_ext         : std_logic;
  signal   ls_drx         : std_logic_vector(7 downto 0);
  signal   ls_dwx         : std_logic_vector(7 downto 0);
  signal   trace_stb      : std_logic;
  signal   trace_nmi      : std_logic;
  signal   trace_irq      : std_logic;
  signal   trace_op       : std_logic_vector(23 downto 0);
  signal   trace_pc       : std_logic_vector(15 downto 0);
  signal   trace_s        : std_logic_vector(7 downto 0);
  signal   trace_p        : std_logic_vector(7 downto 0);
  signal   trace_a        : std_logic_vector(7 downto 0);
  signal   trace_x        : std_logic_vector(7 downto 0);
  signal   trace_y        : std_logic_vector(7 downto 0);
  signal   dma_en         : std_logic;
  signal   dma_a          : std_logic_vector(ram_size_log2-1 downto 3);
  signal   dma_bwe        : std_logic_vector(7 downto 0);
  signal   dma_dw         : std_logic_vector(63 downto 0);
  signal   dma_dr         : std_logic_vector(63 downto 0);

  signal   trace_pc_prev  : std_logic_vector(15 downto 0);
  signal   started        : boolean;
  signal   count_i        : integer;
  signal   count_c        : integer;

  signal   interval_nmi   : integer;
  signal   count_nmi      : integer;
  signal   interval_irq   : integer;
  signal   count_irq      : integer;

  signal   count_hold     : integer range 0 to 3;
  signal   count_hold_0   : integer range 0 to 3;
  signal   count_hold_1   : integer range 0 to 3;

  signal   test_case      : std_logic_vector(7 downto 0); -- functest code's test case - use to avoid stack test (case 3)

  signal   dma_en1        : std_logic;
  signal   dma_r_w        : std_logic;
  signal   dma_rrdy       : std_logic;
  signal   dma_error      : std_logic;
  signal   dma_check      : std_logic;

  signal   prng_reseed    : std_logic;
  signal   prng_seed      : slv_127_0_t(0 to 1);
  signal   prng_ok        : std_logic_vector(0 to 1);
  signal   prng_en        : std_logic;
  signal   prng_d         : std_logic_vector(63 downto 0);

begin

  clk_phase <= (clk_phase+1) mod (clk_ratio*2) after clk_mem_period/2;
  clk_mem   <= '1' when clk_phase mod 2 = 0 else '0';
  clk_cpu   <= '1' when clk_phase = 0 else '0';

  if_ap(15 downto 0)               <= if_al;
  if_ap(ram_size_log2-1 downto 16) <= (others => '0');
  if_z                             <= '0';
  ls_ap(15 downto 0)               <= ls_al;
  ls_ap(ram_size_log2-1 downto 16) <= (others => '0');
  ls_wp                            <= '0';
  ls_z                             <= '0';
  ls_ext                           <= '0';

  DO_TEST: process is
    file     f                                 : text open read_mode is ref_file;
    variable l                                 : line;
    variable ref_pc                            : std_logic_vector(15 downto 0);
    variable ref_s, ref_p, ref_a, ref_x, ref_y : std_logic_vector(7 downto 0);
  begin
    count_c <= 1;
    rst     <= '1';
    wait for 20 ns;
    rst     <= '0';
    while not endfile(f) loop
      wait until rising_edge(clk_cpu);
      if started and hold = '0' and trace_nmi = '0' and trace_irq = '0' then
        count_c <= count_c + 1;
      end if;
      if trace_stb = '1' and trace_nmi = '0' and trace_irq = '0' then
        if count_i > 0 and count_i mod progress_interval = 0 then
          report "instruction count: " & integer'image(count_i) & "  cycle count: " & integer'image(count_c);
        end if;
        if trace_pc_prev /= "UUUUUUUUUUUUUUUU" and trace_pc_prev = trace_pc then
          report "PC = " & to_hstring(to_bitvector(trace_pc))
                 & "  S = " & to_hstring(to_bitvector(trace_s))
                 & "  P = " & to_hstring(to_bitvector(trace_p))
                 & "  A = " & to_hstring(to_bitvector(trace_a))
                 & "  X = " & to_hstring(to_bitvector(trace_x))
                 & "  Y = " & to_hstring(to_bitvector(trace_y));
          report "*** INFINITE LOOP ***";
          report "instruction count: " & integer'image(count_i) & "  cycle count: " & integer'image(count_c);
          finish;
        end if;
        if started then
          readline(f, l);
          hread(l, ref_pc);
          hread(l, ref_s);
          hread(l, ref_p);
          hread(l, ref_a);
          hread(l, ref_x);
          hread(l, ref_y);
          if trace_pc /= ref_pc or trace_s /= ref_s or trace_p /= ref_p or trace_a /= ref_a or trace_x /= ref_x or trace_y /= ref_y then
            report "PC = " & to_hstring(to_bitvector(trace_pc)) & "/" & to_hstring(to_bitvector(ref_pc))
                   & "  S = " & to_hstring(to_bitvector(trace_s)) & "/" & to_hstring(to_bitvector(ref_s))
                   & "  P = " & to_hstring(to_bitvector(trace_p)) & "/" & to_hstring(to_bitvector(ref_p))
                   & "  A = " & to_hstring(to_bitvector(trace_a)) & "/" & to_hstring(to_bitvector(ref_a))
                   & "  X = " & to_hstring(to_bitvector(trace_x)) & "/" & to_hstring(to_bitvector(ref_x))
                   & "  Y = " & to_hstring(to_bitvector(trace_y)) & "/" & to_hstring(to_bitvector(ref_y));
            report "*** MISMATCH ***";
            report "instruction count: " & integer'image(count_i) & "  cycle count: " & integer'image(count_c);
            finish;
          end if;
        end if;
      end if;
      if dma_check = '1' and dma_error = '1' then
        report "DMA error!";
        finish;
      end if;
    end loop;
    report "instruction count: " & integer'image(count_i) & "  cycle count: " & integer'image(count_c);
    report "*** END OF FILE ***";
    report "instruction count: " & integer'image(count_i) & "  cycle count: " & integer'image(count_c);
    finish;
  end process DO_TEST;

  DO_TRACK: process (rst, clk_cpu) is
  begin
    if rst = '1' then
      started       <= false;
      count_i       <= 0;
      trace_pc_prev <= (others => 'U');
    elsif falling_edge(clk_cpu) then
      if trace_stb = '1' and trace_nmi = '0' and trace_irq = '0' then
        if to_integer(unsigned(trace_pc)) = start_address then
          count_i <= 1;
          started <= true;
        else
          count_i <= count_i+1;
        end if;
      end if;
    elsif rising_edge(clk_cpu) then
      if trace_stb = '1' then
        trace_pc_prev <= trace_pc;
      end if;
    end if;
  end process DO_TRACK;

  DUT: component np6532
    generic map (
      clk_ratio     => clk_ratio,
      ram_size_log2 => ram_size_log2,
      jmp_rst       => std_logic_vector(to_unsigned(vector_init,16)),
      vec_irq       => x"FFF8" -- hijack IRQ to make it invisible to functional test code
    )
    port map (
      rsti          => rst,
      rsto          => rsto,
      clk_cpu       => clk_cpu,
      clk_mem       => clk_mem,
      clken         => clken,
      hold          => hold,
      nmi           => nmi,
      irq           => irq,
      if_al         => if_al,
      if_ap         => if_ap,
      if_z          => if_z,
      ls_al         => ls_al,
      ls_ap         => ls_ap,
      ls_en         => ls_en,
      ls_re         => ls_re,
      ls_we         => ls_we,
      ls_wp         => ls_wp,
      ls_z          => ls_z,
      ls_ext        => ls_ext,
      ls_drx        => ls_drx,
      ls_dwx        => ls_dwx,
      trace_stb     => trace_stb,
      trace_nmi     => trace_nmi,
      trace_irq     => trace_irq,
      trace_op      => trace_op,
      trace_pc      => trace_pc,
      trace_s       => trace_s,
      trace_p       => trace_p,
      trace_a       => trace_a,
      trace_x       => trace_x,
      trace_y       => trace_y,
      dma_en        => dma_en,
      dma_a         => dma_a,
      dma_bwe       => dma_bwe,
      dma_dw        => dma_dw,
      dma_dr        => dma_dr
    );

  -- NMI and IRQ testing

  DO_INT: process (clk_cpu) is
    variable seed1, seed2 : integer := 123;
    impure function rand_int (min, max : integer) return integer is
      variable r : real;
    begin
      uniform(seed1, seed2, r);
      return integer(round(r*real(max-min+1)+real(min)-0.5));
    end function;

  begin
    if rising_edge(clk_cpu) then
      if rsto = '1' then
        nmi          <= '0';
        irq          <= '0';
        interval_nmi <= 0;
        count_nmi    <= 0;
        interval_irq <= 0;
        count_irq    <= 0;
        test_case    <= (others => '0');
      elsif trace_stb = '1' then                                -- advex => instruction advance
        if trace_p(5) = '1' then                                -- flag X set = init done
          if test_nmi and nmi = '0' and test_case /= x"03" then
            if interval_nmi = 0 then
              nmi          <= '1';
              interval_nmi <= rand_int(0, 15);
            else
              interval_nmi <= interval_nmi-1;
            end if;
          end if;
          if test_irq and irq = '0' and test_case /= x"03" then
            if interval_irq = 0 then
              irq          <= '1';
              interval_irq <= rand_int(0, 15);
            else
              interval_irq <= interval_irq-1;
            end if;
          end if;
        end if;
        -- nmi/irq ack registers/counters
        if ls_we = '1' then
          if ls_al = x"FE3E" then                               -- NMI ack
            count_nmi <= count_nmi+1;
            nmi       <= '0';
          elsif ls_al = x"FE3F" then                            -- IRQ ack
            count_irq <= count_irq+1;
            irq       <= '0';
          end if;
        end if;
        -- test case
        if ls_we = '1' and ls_al = x"0200" then
          test_case <= ls_dwx;
        end if;
      end if;
    end if;
  end process DO_INT;

  -- hold generation
  -- try combinations of 1-4 cycle assertions and 1-4 cycle gaps

  DO_HOLD: process (clk_cpu) is
  begin
    if rising_edge(clk_cpu) then
      if rsto = '1' then
        hold         <= '0';
        count_hold   <= 0;
        count_hold_0 <= 0;
        count_hold_1 <= 0;
      elsif test_hold then
        if hold = '0' then
          if count_hold = count_hold_0 then
            hold       <= '1';
            count_hold <= 0;
          else
            count_hold <= (count_hold+1) mod 4;
          end if;
        else -- hold = '1'
          if count_hold = count_hold_1 then
            hold         <= '0';
            count_hold   <= 0;
            count_hold_1 <= (count_hold_1+1) mod 4;
            if count_hold_1 = 0 then
              count_hold_0 <= (count_hold_0+1) mod 4;
            end if;
          else
            count_hold <= count_hold+1;
          end if;
        end if;
      end if;
    end if;
  end process DO_HOLD;

  -- DMA test
  -- fill then test top 64k of RAM (so 128k minimum required)

  DO_DMA_EN: process (hold, clken) is
  begin
    if test_dma then
      dma_en <= hold;
      if clk_ratio > 1 then
        if unsigned(clken(1 to clk_ratio-1)) /= 0 then
          dma_en <= '1';
        end if;
      end if;
    else
      dma_en <= '0';
    end if;
  end process DO_DMA_EN;

  dma_bwe <= (others => prng_en and not dma_r_w);
  dma_dw  <= prng_d;

  DO_DMA: process (clk_mem) is
  begin
    if rst = '1' then
      dma_en1     <= '0';
      dma_r_w     <= '1';
      dma_error   <= '0';
      dma_check   <= '0';
      dma_a       <= (others => '1');
      prng_reseed <= '0';
      prng_seed   <= init_seed;
    elsif rising_edge(clk_mem) and test_dma then
      if ram_size_log2 > 16 then
        dma_a(ram_size_log2-1 downto 16) <= (others => '1');
      end if;
      dma_en1     <= dma_en;
      dma_rrdy    <= '0';
      prng_reseed <= '0';
      if dma_en = '1' and prng_reseed = '0' and unsigned(not prng_ok) = 0 then
        dma_a(15 downto 3) <= std_logic_vector(unsigned(dma_a(15 downto 3))+1);
        dma_rrdy           <= dma_r_w;
        if unsigned(not dma_a(15 downto 3)) = 0 then -- all 1s
          dma_r_w     <= not dma_r_w;
          prng_reseed <= '1';
          if dma_r_w = '1' then
            prng_seed(0) <= prng_d & not prng_d;
            prng_seed(1) <= not prng_d & prng_d;
          end if;
        end if;
      end if;
      if dma_rrdy = '1' and dma_dr /= prng_d then
        dma_error <= '1';
      end if;
      dma_check <= prng_reseed and not dma_r_w;
      if dma_check = '1' then
        dma_error <= '0';
      end if;
    end if;
  end process DO_DMA;

  -- random number generators (2 x 32 bits)

  prng_en <= '1' when prng_reseed = '0' and unsigned(not prng_ok) = 0 and ((dma_r_w = '0' and dma_en = '1') or (dma_rrdy = '1'))  else '0';

  gen_prng: for i in 0 to 1 generate

    PRNG: entity work.rng_xoshiro128plusplus
      generic map (
        init_seed => (others => '0'),
        pipeline  => true
      )
      port map (
        clk       => clk_mem,
        rst       => rst,
        reseed    => prng_reseed,
        newseed   => prng_seed(i),
        out_ready => prng_en,
        out_valid => prng_ok(i),
        out_data  => prng_d(31+(i*32) downto i*32)
      );

  end generate gen_prng;

end architecture sim;
