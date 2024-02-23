-------------------------------------------------------------------------------
-- Title      : UVVM Testbench for TMR voters
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : tmr_voters_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    :
-- Created    : 2020-01-30
-- Last update: 2020-05-29
-- Platform   :
-- Target     : Questasim
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UVVM testbench for majority voters for
--              Triple Modular Redundancy (TMR) in the Canola CAN controller.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2020-01-30  1.0      svn                     Created
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

entity tmr_voters_tb is
end tmr_voters_tb;

architecture tb of tmr_voters_tb is
  constant C_CLK_PERIOD : time       := 100 ns; -- 10 Mhz
  constant C_CLK_FREQ   : integer    := 1e9 ns / C_CLK_PERIOD;

  shared variable seed1     : positive := 32564482;
  shared variable seed2     : positive := 89536898;

  constant C_LENGTH : natural := 8;
  type t_tmr_vector is array (0 to C_K_TMR-1) of std_logic_vector(C_LENGTH-1 downto 0);

  signal s_clk : std_logic := '0';

  -- Generate a clock with a given period,
  -- based on clock_gen from Bitvis IRQC testbench
  procedure clock_gen(
    signal clock_signal          : inout std_logic;
    constant clock_period        : in    time
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


  -----------------------------------------------------------------------------
  -- Signals for voters with 3x single inputs and one voted output
  -----------------------------------------------------------------------------
  signal s_single_voter_input                 : std_logic_vector(0 to C_K_TMR-1);
  signal s_single_voter_no_mismatch_output    : std_logic;
  signal s_single_voter_mismatch_unreg_output : std_logic;
  signal s_single_voter_mismatch_reg_output   : std_logic;
  signal s_single_voter_mismatch_unreg_val    : std_logic;
  signal s_single_voter_mismatch_reg_val      : std_logic;

  -----------------------------------------------------------------------------
  -- Voters with 3x single inputs and 3x voted outputs
  -----------------------------------------------------------------------------
  signal s_single_voter_tri_input                 : std_logic_vector(0 to C_K_TMR-1);
  signal s_single_voter_tri_no_mismatch_output    : std_logic_vector(0 to C_K_TMR-1);
  signal s_single_voter_tri_mismatch_unreg_output : std_logic_vector(0 to C_K_TMR-1);
  signal s_single_voter_tri_mismatch_reg_output   : std_logic_vector(0 to C_K_TMR-1);
  signal s_single_voter_tri_mismatch_unreg_val    : std_logic;
  signal s_single_voter_tri_mismatch_reg_val      : std_logic;

  -----------------------------------------------------------------------------
  -- Signals for voters with 3x array inputs and one voted array output
  -----------------------------------------------------------------------------
  signal s_array_voter_input                 : t_tmr_vector;
  signal s_array_voter_no_mismatch_output    : std_logic_vector(C_LENGTH-1 downto 0);
  signal s_array_voter_mismatch_unreg_output : std_logic_vector(C_LENGTH-1 downto 0);
  signal s_array_voter_mismatch_reg_output   : std_logic_vector(C_LENGTH-1 downto 0);
  signal s_array_voter_mismatch_unreg_val    : std_logic;
  signal s_array_voter_mismatch_reg_val      : std_logic;


  -----------------------------------------------------------------------------
  -- Voters with 3x array inputs and 3x voted array outputs
  -----------------------------------------------------------------------------
  signal s_array_voter_tri_input                 : t_tmr_vector;
  signal s_array_voter_tri_no_mismatch_output    : t_tmr_vector;
  signal s_array_voter_tri_mismatch_unreg_output : t_tmr_vector;
  signal s_array_voter_tri_mismatch_reg_output   : t_tmr_vector;
  signal s_array_voter_tri_mismatch_unreg_val    : std_logic;
  signal s_array_voter_tri_mismatch_reg_val      : std_logic;

begin

  clock_gen(s_clk, C_CLK_PERIOD);

  -----------------------------------------------------------------------------
  -- Voters with 3x single inputs and one voted output
  -----------------------------------------------------------------------------
  INST_tmr_voter_no_mismatch: entity work.tmr_voter
    generic map (
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK       => s_clk,
      INPUT_A   => s_single_voter_input(0),
      INPUT_B   => s_single_voter_input(1),
      INPUT_C   => s_single_voter_input(2),
      VOTER_OUT => s_single_voter_no_mismatch_output,
      MISMATCH  => open);

  INST_tmr_voter_mismatch_unreg : entity work.tmr_voter
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK       => s_clk,
      INPUT_A   => s_single_voter_input(0),
      INPUT_B   => s_single_voter_input(1),
      INPUT_C   => s_single_voter_input(2),
      VOTER_OUT => s_single_voter_mismatch_unreg_output,
      MISMATCH  => s_single_voter_mismatch_unreg_val);

  INST_tmr_voter_mismatch_reg : entity work.tmr_voter
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK       => s_clk,
      INPUT_A   => s_single_voter_input(0),
      INPUT_B   => s_single_voter_input(1),
      INPUT_C   => s_single_voter_input(2),
      VOTER_OUT => s_single_voter_mismatch_reg_output,
      MISMATCH  => s_single_voter_mismatch_reg_val);


  -----------------------------------------------------------------------------
  -- Voters with 3x single inputs and 3x voted outputs
  -----------------------------------------------------------------------------
  INST_tmr_voter_triplicated_no_mismatch: entity work.tmr_voter_triplicated
    generic map (
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK         => s_clk,
      INPUT_A     => s_single_voter_tri_input(0),
      INPUT_B     => s_single_voter_tri_input(1),
      INPUT_C     => s_single_voter_tri_input(2),
      VOTER_OUT_A => s_single_voter_tri_no_mismatch_output(0),
      VOTER_OUT_B => s_single_voter_tri_no_mismatch_output(1),
      VOTER_OUT_C => s_single_voter_tri_no_mismatch_output(2),
      MISMATCH    => open);

  INST_tmr_voter_triplicated_mismatch_unreg: entity work.tmr_voter_triplicated
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK         => s_clk,
      INPUT_A     => s_single_voter_tri_input(0),
      INPUT_B     => s_single_voter_tri_input(1),
      INPUT_C     => s_single_voter_tri_input(2),
      VOTER_OUT_A => s_single_voter_tri_mismatch_unreg_output(0),
      VOTER_OUT_B => s_single_voter_tri_mismatch_unreg_output(1),
      VOTER_OUT_C => s_single_voter_tri_mismatch_unreg_output(2),
      MISMATCH    => s_single_voter_tri_mismatch_unreg_val);

  INST_tmr_voter_triplicated_mismatch_reg: entity work.tmr_voter_triplicated
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK         => s_clk,
      INPUT_A     => s_single_voter_tri_input(0),
      INPUT_B     => s_single_voter_tri_input(1),
      INPUT_C     => s_single_voter_tri_input(2),
      VOTER_OUT_A => s_single_voter_tri_mismatch_reg_output(0),
      VOTER_OUT_B => s_single_voter_tri_mismatch_reg_output(1),
      VOTER_OUT_C => s_single_voter_tri_mismatch_reg_output(2),
      MISMATCH    => s_single_voter_tri_mismatch_reg_val);


  -----------------------------------------------------------------------------
  -- Voters with 3x array inputs and one voted array output
  -----------------------------------------------------------------------------
  INST_tmr_voter_array_no_mismatch: entity work.tmr_voter_array
    generic map (
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK       => s_clk,
      INPUT_A   => s_array_voter_input(0),
      INPUT_B   => s_array_voter_input(1),
      INPUT_C   => s_array_voter_input(2),
      VOTER_OUT => s_array_voter_no_mismatch_output,
      MISMATCH  => open);

  INST_tmr_voter_array_mismatch_unreg: entity work.tmr_voter_array
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK       => s_clk,
      INPUT_A   => s_array_voter_input(0),
      INPUT_B   => s_array_voter_input(1),
      INPUT_C   => s_array_voter_input(2),
      VOTER_OUT => s_array_voter_mismatch_unreg_output,
      MISMATCH  => s_array_voter_mismatch_unreg_val);

  INST_tmr_voter_array_mismatch_reg: entity work.tmr_voter_array
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK       => s_clk,
      INPUT_A   => s_array_voter_input(0),
      INPUT_B   => s_array_voter_input(1),
      INPUT_C   => s_array_voter_input(2),
      VOTER_OUT => s_array_voter_mismatch_reg_output,
      MISMATCH  => s_array_voter_mismatch_reg_val);


  -----------------------------------------------------------------------------
  -- Voters with 3x array inputs and 3x voted array outputs
  -----------------------------------------------------------------------------
  INST_tmr_voter_triplicated_array_no_mismatch: entity work.tmr_voter_triplicated_array
    generic map (
      G_MISMATCH_OUTPUT_EN  => false,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK         => s_clk,
      INPUT_A     => s_array_voter_tri_input(0),
      INPUT_B     => s_array_voter_tri_input(1),
      INPUT_C     => s_array_voter_tri_input(2),
      VOTER_OUT_A => s_array_voter_tri_no_mismatch_output(0),
      VOTER_OUT_B => s_array_voter_tri_no_mismatch_output(1),
      VOTER_OUT_C => s_array_voter_tri_no_mismatch_output(2),
      MISMATCH    => open);

  INST_tmr_voter_triplicated_array_mismatch_unreg: entity work.tmr_voter_triplicated_array
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => false)
    port map (
      CLK         => s_clk,
      INPUT_A     => s_array_voter_tri_input(0),
      INPUT_B     => s_array_voter_tri_input(1),
      INPUT_C     => s_array_voter_tri_input(2),
      VOTER_OUT_A => s_array_voter_tri_mismatch_unreg_output(0),
      VOTER_OUT_B => s_array_voter_tri_mismatch_unreg_output(1),
      VOTER_OUT_C => s_array_voter_tri_mismatch_unreg_output(2),
      MISMATCH    => s_array_voter_tri_mismatch_unreg_val);

  INST_tmr_voter_triplicated_array_mismatch_reg: entity work.tmr_voter_triplicated_array
    generic map (
      G_MISMATCH_OUTPUT_EN  => true,
      G_MISMATCH_OUTPUT_REG => true)
    port map (
      CLK         => s_clk,
      INPUT_A     => s_array_voter_tri_input(0),
      INPUT_B     => s_array_voter_tri_input(1),
      INPUT_C     => s_array_voter_tri_input(2),
      VOTER_OUT_A => s_array_voter_tri_mismatch_reg_output(0),
      VOTER_OUT_B => s_array_voter_tri_mismatch_reg_output(1),
      VOTER_OUT_C => s_array_voter_tri_mismatch_reg_output(2),
      MISMATCH    => s_array_voter_tri_mismatch_reg_val);



  p_main: process
    constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;

    -- Log overloads for simplification
    procedure log(
      msg   : string) is
    begin
      log(ID_SEQUENCER, msg, C_SCOPE);
    end;

    constant C_NUM_TESTS : natural := 1000;

    variable v_test_num    : natural;
    variable v_data_length : natural;

    variable input_mismatch : std_logic := '0';
    variable majority_value : std_logic := '0';

    variable rand_bit_idx   : natural range 0 to C_LENGTH-1;
    variable rand_input_num : natural range 0 to C_K_TMR-1;
    variable rand_input_vec : std_logic_vector(C_LENGTH-1 downto 0);
    variable rand_real      : real;

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    set_log_file_name("log/tmr_voters_tb_log.txt");


    s_single_voter_input       <= (others => '0');
    s_single_voter_tri_input   <= (others => '0');
    s_array_voter_input(0)     <= (others => '0');
    s_array_voter_input(1)     <= (others => '0');
    s_array_voter_input(2)     <= (others => '0');
    s_array_voter_tri_input(0) <= (others => '0');
    s_array_voter_tri_input(1) <= (others => '0');
    s_array_voter_tri_input(2) <= (others => '0');

    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test single voter with single output", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    for test_num in 0 to (2**3)-1 loop
      s_single_voter_input <= std_logic_vector(to_unsigned(test_num, 3));

      -- Short wait before checking unregistered mismatch
      wait for 1 ns;

      input_mismatch := (s_single_voter_input(0) xor s_single_voter_input(1)) or
                        (s_single_voter_input(1) xor s_single_voter_input(2));

      majority_value := (s_single_voter_input(0) and s_single_voter_input(1)) or
                        (s_single_voter_input(0) and s_single_voter_input(2)) or
                        (s_single_voter_input(1) and s_single_voter_input(2));

      check_value(s_single_voter_mismatch_unreg_val, input_mismatch, error, "Check unregistered mismatch.");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

      check_value(s_single_voter_mismatch_reg_val, input_mismatch, error, "Check registered mismatch.");

      check_value(s_single_voter_no_mismatch_output, majority_value,
                  error, "Check voter output (no mismatch).");

      check_value(s_single_voter_mismatch_unreg_output, majority_value,
                  error, "Check voter output (mismatch unreg).");

      check_value(s_single_voter_mismatch_reg_output, majority_value,
                  error, "Check voter output (mismatch reg).");

    end loop;  -- test_num


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test single voter with triple outputs", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    for test_num in 0 to (2**3)-1 loop
      s_single_voter_tri_input <= std_logic_vector(to_unsigned(test_num, 3));

      -- Short wait before checking unregistered mismatch
      wait for 1 ns;

      input_mismatch := (s_single_voter_tri_input(0) xor s_single_voter_tri_input(1)) or
                        (s_single_voter_tri_input(1) xor s_single_voter_tri_input(2));

      majority_value := (s_single_voter_tri_input(0) and s_single_voter_tri_input(1)) or
                        (s_single_voter_tri_input(0) and s_single_voter_tri_input(2)) or
                        (s_single_voter_tri_input(1) and s_single_voter_tri_input(2));

      check_value(s_single_voter_tri_mismatch_unreg_val, input_mismatch, error, "Check unregistered mismatch.");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

      check_value(s_single_voter_tri_mismatch_reg_val, input_mismatch, error, "Check registered mismatch.");

      check_value(s_single_voter_tri_no_mismatch_output(0), majority_value,
                  error, "Check voter output 0 (no mismatch).");
      check_value(s_single_voter_tri_no_mismatch_output(1), majority_value,
                  error, "Check voted output 1 (no mismatch).");
      check_value(s_single_voter_tri_no_mismatch_output(2), majority_value,
                  error, "Check voted output 2 (no mismatch).");

      check_value(s_single_voter_tri_mismatch_unreg_output(0), majority_value,
                  error, "Check voter output 0 (mismatch unreg).");
      check_value(s_single_voter_tri_mismatch_unreg_output(1), majority_value,
                  error, "Check voter output 1 (mismatch unreg).");
      check_value(s_single_voter_tri_mismatch_unreg_output(2), majority_value,
                  error, "Check voter output 2 (mismatch unreg).");

      check_value(s_single_voter_tri_mismatch_reg_output(0), majority_value,
                  error, "Check voter output 0 (mismatch reg).");
      check_value(s_single_voter_tri_mismatch_reg_output(1), majority_value,
                  error, "Check voter output 1 (mismatch reg).");
      check_value(s_single_voter_tri_mismatch_reg_output(2), majority_value,
                  error, "Check voter output 2 (mismatch reg).");

    end loop;  -- test_num


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test array voter with single output", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    for test_num in 0 to C_NUM_TESTS-1 loop
      uniform(seed1, seed2, rand_real);
      rand_input_vec := std_logic_vector(to_unsigned(integer(round(rand_real * real((2**C_LENGTH)-1))), C_LENGTH));

      s_array_voter_input(0) <= rand_input_vec;
      s_array_voter_input(1) <= rand_input_vec;
      s_array_voter_input(2) <= rand_input_vec;

      uniform(seed1, seed2, rand_real);
      if rand_real > 0.5 then
        input_mismatch := '1';

        uniform(seed1, seed2, rand_real);
        rand_bit_idx   := integer(round(rand_real*real(C_LENGTH-1)));

        uniform(seed1, seed2, rand_real);
        rand_input_num   := integer(round(rand_real*real(C_K_TMR-1)));

        -- Flip a random bit
        s_array_voter_input(rand_input_num)(rand_bit_idx) <= not rand_input_vec(rand_bit_idx);
      else
        input_mismatch := '0';
      end if;

      -- Short wait before checking unregistered mismatch
      wait for 1 ns;

      check_value(s_array_voter_mismatch_unreg_val, input_mismatch, error, "Check unregistered mismatch.");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

      check_value(s_array_voter_mismatch_reg_val, input_mismatch, error, "Check registered mismatch.");

      check_value(s_array_voter_no_mismatch_output, rand_input_vec,
                  error, "Check voter output (no mismatch).");

      check_value(s_array_voter_mismatch_unreg_output, rand_input_vec,
                  error, "Check voter output (mismatch unreg).");

      check_value(s_array_voter_mismatch_reg_output, rand_input_vec,
                  error, "Check voter output (mismatch reg).");

    end loop;  -- test_num


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test array voter with triple outputs", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    for test_num in 0 to C_NUM_TESTS-1 loop
      uniform(seed1, seed2, rand_real);
      rand_input_vec := std_logic_vector(to_unsigned(integer(round(rand_real * real((2**C_LENGTH)-1))), C_LENGTH));

      s_array_voter_tri_input(0) <= rand_input_vec;
      s_array_voter_tri_input(1) <= rand_input_vec;
      s_array_voter_tri_input(2) <= rand_input_vec;

      uniform(seed1, seed2, rand_real);
      if rand_real > 0.5 then
        input_mismatch := '1';

        uniform(seed1, seed2, rand_real);
        rand_bit_idx   := integer(round(rand_real*real(C_LENGTH-1)));

        uniform(seed1, seed2, rand_real);
        rand_input_num   := integer(round(rand_real*real(C_K_TMR-1)));

        -- Flip a random bit
        s_array_voter_tri_input(rand_input_num)(rand_bit_idx) <= not rand_input_vec(rand_bit_idx);
      else
        input_mismatch := '0';
      end if;

      -- Short wait before checking unregistered mismatch
      wait for 1 ns;

      check_value(s_array_voter_tri_mismatch_unreg_val, input_mismatch, error, "Check unregistered mismatch.");

      wait until rising_edge(s_clk);
      wait until rising_edge(s_clk);

      check_value(s_array_voter_tri_mismatch_reg_val, input_mismatch, error, "Check registered mismatch.");

      check_value(s_array_voter_tri_no_mismatch_output(0), rand_input_vec,
                  error, "Check voter output 0 (no mismatch).");
      check_value(s_array_voter_tri_no_mismatch_output(1), rand_input_vec,
                  error, "Check voter output 1 (no mismatch).");
      check_value(s_array_voter_tri_no_mismatch_output(2), rand_input_vec,
                  error, "Check voter output 2 (no mismatch).");

      check_value(s_array_voter_tri_mismatch_unreg_output(0), rand_input_vec,
                  error, "Check voter output 0 (mismatch unreg).");
      check_value(s_array_voter_tri_mismatch_unreg_output(1), rand_input_vec,
                  error, "Check voter output 1 (mismatch unreg).");
      check_value(s_array_voter_tri_mismatch_unreg_output(2), rand_input_vec,
                  error, "Check voter output 2 (mismatch unreg).");

      check_value(s_array_voter_tri_mismatch_reg_output(0), rand_input_vec,
                  error, "Check voter output 0 (mismatch reg).");
      check_value(s_array_voter_tri_mismatch_reg_output(1), rand_input_vec,
                  error, "Check voter output 0 (mismatch reg).");
      check_value(s_array_voter_tri_mismatch_reg_output(2), rand_input_vec,
                  error, "Check voter output 0 (mismatch reg).");

    end loop;  -- test_num

    wait for 100 ns;            -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end tb;
