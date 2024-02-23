-------------------------------------------------------------------------------
-- Title      : UVVM Testbench for TMR counters
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : tmr_counters_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    :
-- Created    : 2020-01-31
-- Last update: 2020-05-29
-- Platform   :
-- Target     : Questasim
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UVVM testbench for up_counter and counter for, with and
--              without Triple Modular Redundancy (TMR).
--              The test bench only tests the functionality of the counters,
--              the TMR voters are tested in a separate test bench and are
--              assumed to be working properly.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2020-01-31  1.0      svn                     Created
-------------------------------------------------------------------------------

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library work;
use work.tmr_pkg.all;

entity tmr_counters_tb is
end tmr_counters_tb;

architecture tb of tmr_counters_tb is
  constant C_CLK_PERIOD : time := 100 ns;  -- 10 Mhz
  constant C_CLK_FREQ : integer := 1e9 ns / C_CLK_PERIOD;

  shared variable seed1     : positive := 32564482;
  shared variable seed2     : positive := 89536898;

  signal s_clk : std_logic := '0';

  -- Generate a clock with a given period,
  -- based on clock_gen from Bitvis IRQC testbench
  procedure clock_gen(
    signal clock_signal : inout std_logic;
    constant clock_period : in time
    ) is
    variable v_first_half_clk_period : time;
  begin
    loop
      v_first_half_clk_period := clock_period / 2;

      wait for v_first_half_clk_period;
      clock_signal <= not clock_signal;
      wait for (clock_period - v_first_half_clk_period);
      clock_signal <= not clock_signal;
    end loop;
  end;

  constant C_BIT_WIDTH : natural := 6;
  constant C_INCR_WIDTH : natural := 6;
  constant C_COUNTER_ZERO : std_logic_vector(0 to C_BIT_WIDTH-1) := (others => '0');
  constant C_COUNTER_MAX : std_logic_vector(0 to C_BIT_WIDTH-1) := (others => '1');

  signal s_clear      : std_logic;
  signal s_reset      : std_logic;
  signal s_count_up   : std_logic;
  signal s_count_down : std_logic;
  signal s_set        : std_logic;
  signal s_set_value  : std_logic_vector(C_BIT_WIDTH-1 downto 0);

  signal s_upcounter_non_saturating_no_tmr_out : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_upcounter_non_saturating_tmr_out : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_upcounter_saturating_no_tmr_out : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_upcounter_saturating_tmr_out : std_logic_vector(C_BIT_WIDTH-1 downto 0);

  signal s_counter_saturating_no_tmr_out_a : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_counter_saturating_no_tmr_out_b : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_counter_saturating_no_tmr_out_c : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_counter_saturating_tmr_out_a : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_counter_saturating_tmr_out_b : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_counter_saturating_tmr_out_c : std_logic_vector(C_BIT_WIDTH-1 downto 0);
  signal s_counter_incr : std_logic_vector(C_BIT_WIDTH-1 downto 0);

begin

  clock_gen(s_clk, C_CLK_PERIOD);


  INST_up_counter_non_saturating_no_tmr : entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => C_BIT_WIDTH,
      IS_SATURATING         => false,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => false,
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK       => s_clk,
      RESET     => s_reset,
      CLEAR     => s_clear,
      COUNT_UP  => s_count_up,
      COUNT_OUT => s_upcounter_non_saturating_no_tmr_out,
      MISMATCH  => open);

  INST_up_counter_non_saturating_tmr : entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => C_BIT_WIDTH,
      IS_SATURATING         => false,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => true,
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK       => s_clk,
      RESET     => s_reset,
      CLEAR     => s_clear,
      COUNT_UP  => s_count_up,
      COUNT_OUT => s_upcounter_non_saturating_tmr_out,
      MISMATCH  => open);

  INST_up_counter_saturating_no_tmr : entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => C_BIT_WIDTH,
      IS_SATURATING         => true,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => false,
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK       => s_clk,
      RESET     => s_reset,
      CLEAR     => s_clear,
      COUNT_UP  => s_count_up,
      COUNT_OUT => s_upcounter_saturating_no_tmr_out,
      MISMATCH  => open);

  INST_up_counter_saturating_tmr : entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => C_BIT_WIDTH,
      IS_SATURATING         => true,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => true,
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK       => s_clk,
      RESET     => s_reset,
      CLEAR     => s_clear,
      COUNT_UP  => s_count_up,
      COUNT_OUT => s_upcounter_saturating_tmr_out,
      MISMATCH  => open);

  INST_counter_saturating_no_tmr : entity work.counter_saturating_tmr_wrapper_triplicated
    generic map (
      BIT_WIDTH             => C_BIT_WIDTH,
      INCR_WIDTH            => C_INCR_WIDTH,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => false,
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK         => s_clk,
      RESET       => s_reset,
      CLEAR       => s_clear,
      SET         => s_set,
      SET_VALUE   => s_set_value,
      COUNT_UP    => s_count_up,
      COUNT_DOWN  => s_count_down,
      COUNT_INCR  => s_counter_incr,
      COUNT_OUT_A => s_counter_saturating_no_tmr_out_a,
      COUNT_OUT_B => s_counter_saturating_no_tmr_out_b,
      COUNT_OUT_C => s_counter_saturating_no_tmr_out_c,
      MISMATCH    => open);

  INST_counter_saturating_tmr : entity work.counter_saturating_tmr_wrapper_triplicated
    generic map (
      BIT_WIDTH             => C_BIT_WIDTH,
      INCR_WIDTH            => C_INCR_WIDTH,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => true,
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK         => s_clk,
      RESET       => s_reset,
      CLEAR       => s_clear,
      SET         => s_set,
      SET_VALUE   => s_set_value,
      COUNT_UP    => s_count_up,
      COUNT_DOWN  => s_count_down,
      COUNT_INCR  => s_counter_incr,
      COUNT_OUT_A => s_counter_saturating_tmr_out_a,
      COUNT_OUT_B => s_counter_saturating_tmr_out_b,
      COUNT_OUT_C => s_counter_saturating_tmr_out_c,
      MISMATCH    => open);



  p_main : process
    constant C_SCOPE               : string  := C_TB_SCOPE_DEFAULT;
    constant C_INCR_TEST_VALUE     : natural := 5;
    constant C_NUM_SET_VALUE_TESTS : natural := 64;

    variable v_count_value            : std_logic_vector(C_BIT_WIDTH-1 downto 0);
    variable v_iteration_num          : natural := 0;
    variable v_rand_real              : real;
    variable v_rand_counter_value     : natural;

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    set_log_file_name("log/tmr_counters_tb_log.txt");


    s_counter_incr <= (others => '0');
    s_set_value    <= (others => '0');
    s_count_up     <= '0';
    s_count_down   <= '0';
    s_clear        <= '0';
    s_set          <= '0';


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test up_counter - COUNT_UP continuously high", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    s_reset <= '1';
    wait until rising_edge(s_clk);
    s_reset <= '0';
    wait until rising_edge(s_clk);

    check_value(s_upcounter_non_saturating_no_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_upcounter_non_saturating_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_upcounter_saturating_no_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_upcounter_saturating_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after reset");

    s_count_up <= '1';
    wait until rising_edge(s_clk);

    for i in 1 to (2**C_BIT_WIDTH)-1 loop
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(i, C_BIT_WIDTH));

      check_value(s_upcounter_non_saturating_no_tmr_out, v_count_value, error, "Check count value");
      check_value(s_upcounter_non_saturating_tmr_out, v_count_value, error, "Check count value");
      check_value(s_upcounter_saturating_no_tmr_out, v_count_value, error, "Check count value");
      check_value(s_upcounter_saturating_tmr_out, v_count_value, error, "Check count value");

    end loop;  -- i

    wait until rising_edge(s_clk);

    check_value(s_upcounter_non_saturating_no_tmr_out, C_COUNTER_ZERO, error, "Check non-saturating wrap around");
    check_value(s_upcounter_non_saturating_tmr_out, C_COUNTER_ZERO, error, "Check non-saturating wrap around");
    check_value(s_upcounter_saturating_no_tmr_out, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_upcounter_saturating_tmr_out, C_COUNTER_MAX, error, "Check saturating at max");

    s_count_up <= '0';

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test up_counter - COUNT_UP pulsed", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    s_clear <= '1';
    wait until rising_edge(s_clk);
    s_clear <= '0';
    wait until rising_edge(s_clk);

    check_value(s_upcounter_non_saturating_no_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_upcounter_non_saturating_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_upcounter_saturating_no_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_upcounter_saturating_tmr_out, C_COUNTER_ZERO, error, "Check counter is zero after clear");

    for i in 1 to (2**C_BIT_WIDTH)-1 loop
      s_count_up <= '1';
      wait until rising_edge(s_clk);
      s_count_up <= '0';
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(i, C_BIT_WIDTH));

      check_value(s_upcounter_non_saturating_no_tmr_out, v_count_value, error, "Check count value");
      check_value(s_upcounter_non_saturating_tmr_out, v_count_value, error, "Check count value");
      check_value(s_upcounter_saturating_no_tmr_out, v_count_value, error, "Check count value");
      check_value(s_upcounter_saturating_tmr_out, v_count_value, error, "Check count value");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

    end loop;  -- i


    s_count_up <= '1';
    wait until rising_edge(s_clk);
    s_count_up <= '0';
    wait until rising_edge(s_clk);

    check_value(s_upcounter_non_saturating_no_tmr_out, C_COUNTER_ZERO, error, "Check non-saturating wrap around");
    check_value(s_upcounter_non_saturating_tmr_out, C_COUNTER_ZERO, error, "Check non-saturating wrap around");
    check_value(s_upcounter_saturating_no_tmr_out, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_upcounter_saturating_tmr_out, C_COUNTER_MAX, error, "Check saturating at max");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_UP continuously high - increase by 1", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    s_reset <= '1';
    wait until rising_edge(s_clk);
    s_reset <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after reset");

    s_counter_incr <= std_logic_vector(to_unsigned(1, C_BIT_WIDTH));
    s_count_up <= '1';
    wait until rising_edge(s_clk);

    for i in 1 to (2**C_BIT_WIDTH)-1 loop
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(i, C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

    end loop;  -- i

    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");

    s_count_up <= '0';


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_DOWN continuously high - decrease by 1", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    wait until rising_edge(s_clk);

    s_count_down <= '1';
    wait until rising_edge(s_clk);

    for i in (2**C_BIT_WIDTH)-2 downto 0 loop
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(i, C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

    end loop;  -- i

    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");

    s_count_down <= '0';


-----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_UP pulsed - increase by 1", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    -- Count up a few times to test clear
    s_count_up <= '1';
    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);
    s_count_up <= '0';

    s_clear <= '1';
    wait until rising_edge(s_clk);
    s_clear <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after clear");

    for i in 1 to (2**C_BIT_WIDTH)-1 loop
      s_count_up <= '1';
      wait until rising_edge(s_clk);
      s_count_up <= '0';
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(i, C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

    end loop;  -- i

    s_count_up <= '1';
    wait until rising_edge(s_clk);
    s_count_up <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");

    s_count_up <= '0';

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_DOWN pulsed - decrease by 1", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    for i in (2**C_BIT_WIDTH)-2 downto 0 loop
      s_count_down <= '1';
      wait until rising_edge(s_clk);
      s_count_down <= '0';
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(i, C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

    end loop;  -- i

    s_count_down <= '1';
    wait until rising_edge(s_clk);
    s_count_down <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_UP continuously high - increase by 5", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    s_reset <= '1';
    wait until rising_edge(s_clk);
    s_reset <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after reset");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after reset");

    v_iteration_num := 1;
    s_counter_incr <= std_logic_vector(to_unsigned(C_INCR_TEST_VALUE, C_BIT_WIDTH));
    s_count_up <= '1';
    wait until rising_edge(s_clk);

    while v_iteration_num*C_INCR_TEST_VALUE < (2**C_BIT_WIDTH)-1 loop
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(v_iteration_num*C_INCR_TEST_VALUE, C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

      v_iteration_num := v_iteration_num + 1;
    end loop;

    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");

    s_count_up <= '0';


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_DOWN continuously high - decrease by 5", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    wait until rising_edge(s_clk);

    v_iteration_num := 1;
    s_count_down <= '1';
    wait until rising_edge(s_clk);

    while v_iteration_num*C_INCR_TEST_VALUE < (2**C_BIT_WIDTH)-1 loop
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned((2**C_BIT_WIDTH)-1-(v_iteration_num*C_INCR_TEST_VALUE),
                                                    C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

      v_iteration_num := v_iteration_num + 1;
    end loop;

    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");

    s_count_down <= '0';


-----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_UP pulsed - increase by 5", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    -- Count up a few times to test clear
    s_count_up <= '1';
    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);
    s_count_up <= '0';

    s_clear <= '1';
    wait until rising_edge(s_clk);
    s_clear <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after clear");

    v_iteration_num := 1;

    while v_iteration_num*C_INCR_TEST_VALUE < (2**C_BIT_WIDTH)-1 loop
      s_count_up <= '1';
      wait until rising_edge(s_clk);
      s_count_up <= '0';
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned(v_iteration_num*C_INCR_TEST_VALUE, C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

      v_iteration_num := v_iteration_num + 1;
    end loop;

    s_count_up <= '1';
    wait until rising_edge(s_clk);
    s_count_up <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_MAX, error, "Check saturating at max");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_MAX, error, "Check saturating at max");

    s_count_up <= '0';

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - COUNT_DOWN pulsed - decrease by 5", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_iteration_num := 1;

    while v_iteration_num*C_INCR_TEST_VALUE < (2**C_BIT_WIDTH)-1 loop
      s_count_down <= '1';
      wait until rising_edge(s_clk);
      s_count_down <= '0';
      wait until rising_edge(s_clk);

      v_count_value := std_logic_vector(to_unsigned((2**C_BIT_WIDTH)-1-(v_iteration_num*C_INCR_TEST_VALUE),
                                                    C_BIT_WIDTH));

      check_value(s_counter_saturating_no_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_no_tmr_out_c, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_a, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_b, v_count_value, error, "Check count value");
      check_value(s_counter_saturating_tmr_out_c, v_count_value, error, "Check count value");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

      v_iteration_num := v_iteration_num + 1;
    end loop;

    s_count_down <= '1';
    wait until rising_edge(s_clk);
    s_count_down <= '0';
    wait until rising_edge(s_clk);

    check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check saturating at zero");
    check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check saturating at zero");

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test counter - SET_VALUE", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    s_count_up <= '0';
    s_count_down <= '0';

    s_clear <= '1';
    wait until rising_edge(s_clk);
    s_clear <= '0';
    wait until rising_edge(s_clk);

    for i in 0 to C_NUM_SET_VALUE_TESTS-1 loop
      -- Generate random value to set counter to
      uniform(seed1, seed2, v_rand_real);
      v_rand_counter_value := integer(round(v_rand_real * real((2**C_BIT_WIDTH)-1)));

      s_set_value <= std_logic_vector(to_unsigned(v_rand_counter_value, C_BIT_WIDTH));
      s_set       <= '1';
      wait until rising_edge(s_clk);
      s_set       <= '0';
      wait until rising_edge(s_clk);

      check_value(s_counter_saturating_no_tmr_out_a, s_set_value, error, "Check count set to set value");
      check_value(s_counter_saturating_no_tmr_out_b, s_set_value, error, "Check count set to set value");
      check_value(s_counter_saturating_no_tmr_out_c, s_set_value, error, "Check count set to set value");
      check_value(s_counter_saturating_tmr_out_a, s_set_value, error, "Check count set to set value");
      check_value(s_counter_saturating_tmr_out_b, s_set_value, error, "Check count set to set value");
      check_value(s_counter_saturating_tmr_out_c, s_set_value, error, "Check count set to set value");

      s_clear <= '1';
      wait until rising_edge(s_clk);
      s_clear <= '0';
      wait until rising_edge(s_clk);

      check_value(s_counter_saturating_no_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after clear");
      check_value(s_counter_saturating_no_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after clear");
      check_value(s_counter_saturating_no_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after clear");
      check_value(s_counter_saturating_tmr_out_a, C_COUNTER_ZERO, error, "Check counter is zero after clear");
      check_value(s_counter_saturating_tmr_out_b, C_COUNTER_ZERO, error, "Check counter is zero after clear");
      check_value(s_counter_saturating_tmr_out_c, C_COUNTER_ZERO, error, "Check counter is zero after clear");
    end loop;  -- i in range 0 to C_NUM_TESTS-1

    wait for 100 ns;  -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end tb;
