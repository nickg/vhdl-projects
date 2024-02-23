-------------------------------------------------------------------------------
-- Title      : UVVM Testbench for Bit Timing Logic (BTL)
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_btl_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    :
-- Created    : 2019-07-16
-- Last update: 2020-09-17
-- Platform   :
-- Target     : Questasim
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UVVM testbench for Bit Timing Logic (BTL) in the
--              Canola CAN controller.
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2019-07-16  1.0      svn                     Created
-------------------------------------------------------------------------------

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library work;
use work.canola_pkg.all;
use work.canola_tb_pkg.all;

entity canola_btl_tb is
end canola_btl_tb;

architecture tb of canola_btl_tb is

  constant C_CLK_PERIOD : time       := 100 ns; -- 10 Mhz
  constant C_CLK_FREQ   : integer    := 1e9 ns / C_CLK_PERIOD;

  constant C_CAN_BAUD_PERIOD  : time    := 10000 ns;  -- 100 kHz
  constant C_CAN_BAUD_FREQ    : integer := 1e9 ns / C_CAN_BAUD_PERIOD;

  -- Indicates where in a bit the Rx sample point should be
  -- Real value from 0.0 to 1.0. Not used by BTL.
  constant C_CAN_SAMPLE_POINT : real    := 0.7;

  constant C_TIME_QUANTA_CLOCK_SCALE_VAL : natural := 9;

  constant C_DATA_LENGTH_MAX : natural := 1000;
  constant C_NUM_ITERATIONS  : natural := 10;


  -- Generate a clock with a given period,
  -- based on clock_gen from Bitvis IRQC testbench
  procedure clock_gen(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in    boolean;
    constant clock_period        : in    time
    ) is
    variable v_first_half_clk_period : time;
  begin
    loop
      if not clock_ena then
        wait until clock_ena;
      end if;

      v_first_half_clk_period := clock_period / 2;

      wait for v_first_half_clk_period;
      clock_signal <= not clock_signal;
      wait for (clock_period - v_first_half_clk_period);
      clock_signal <= not clock_signal;
    end loop;
  end;

  -- Generate a clock with a given period and configurable error
  -- Based on clock_gen from Bitvis IRQC testbench
  procedure clock_error_gen(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in    boolean;
    constant clock_period        : in    time;
    signal clock_error_percent   : in    real
    ) is
    variable v_clock_period          : time;
    variable v_first_half_clk_period : time;
  begin
    loop
      if not clock_ena then
        wait until clock_ena;
      end if;

      v_clock_period := clock_period + clock_period*(clock_error_percent/100.0);

      v_first_half_clk_period := v_clock_period / 2;

      wait for v_first_half_clk_period;
      clock_signal <= not clock_signal;
      wait for (v_clock_period - v_first_half_clk_period);
      clock_signal <= not clock_signal;
    end loop;
  end;

  signal s_clock_ena      : boolean   := false;
  signal s_can_baud_clk   : std_logic := '0';
  signal s_can_baud_error : real      := 0.0;

  signal s_reset            : std_logic := '0';
  signal s_clk              : std_logic := '0';
  signal s_can_tx, s_can_rx : std_logic;

  signal s_time_quanta_pulse   : std_logic := '0';
  signal s_time_quanta_restart : std_logic := '0';
  signal s_time_quanta_count   : std_logic_vector(C_TIME_QUANTA_SCALE_WIDTH_DEFAULT-1 downto 0);

  signal s_btl_tx_bit_value   : std_logic := '0';
  signal s_btl_tx_bit_valid   : std_logic := '0';
  signal s_btl_tx_rdy         : std_logic;
  signal s_btl_tx_active      : std_logic := '0';
  signal s_btl_rx_bit_value   : std_logic;
  signal s_btl_rx_bit_valid   : std_logic;
  signal s_btl_rx_synced      : std_logic;
  signal s_btl_rx_stop        : std_logic := '0';
  signal s_btl_sync_fsm_state : std_logic_vector(C_BTL_SYNC_FSM_STATE_BITSIZE-1 downto 0);

  signal s_data_transmit     : std_logic_vector(0 to C_DATA_LENGTH_MAX-1) := (others => '0');
  signal s_btl_data_received : std_logic_vector(0 to C_DATA_LENGTH_MAX-1) := (others => '0');
  signal s_bus_data_received : std_logic_vector(0 to C_DATA_LENGTH_MAX-1) := (others => '0');

  signal s_btl_recv_data_count : natural := 0;
  signal s_bus_recv_data_count : natural := 0;

  signal s_prop_seg        : std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0);
  signal s_phase_seg1      : std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0);
  signal s_phase_seg2      : std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0);

  signal s_sync_jump_width : unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0);


  shared variable seed1     : positive := 32564482;
  shared variable seed2     : positive := 89536898;

begin

  assert (C_CAN_SAMPLE_POINT >= 0.0 and C_CAN_SAMPLE_POINT <= 1.0)
    report "Illegal value for C_CAN_SAMPLE_POINT" severity error;

  s_prop_seg        <= "0111";
  s_phase_seg1      <= "0111";
  s_phase_seg2      <= "0111";
  s_sync_jump_width <= to_unsigned(2, C_SYNC_JUMP_WIDTH_BITSIZE);

  -- Set up clock generators
  clock_gen(s_clk, s_clock_ena, C_CLK_PERIOD);
  clock_error_gen(s_can_baud_clk, s_clock_ena, C_CAN_BAUD_PERIOD, s_can_baud_error);

  -- Generates a 1 (system) clock cycle pulse for each time quanta
  INST_canola_time_quanta_gen : entity work.canola_time_quanta_gen
    generic map (
      G_TIME_QUANTA_SCALE_WIDTH => C_TIME_QUANTA_SCALE_WIDTH_DEFAULT)
    port map (
      CLK               => s_clk,
      RESET             => s_reset,
      RESTART           => s_time_quanta_restart,
      CLK_SCALE         => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                       C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),
      TIME_QUANTA_PULSE => s_time_quanta_pulse,
      COUNT_OUT         => s_time_quanta_count,
      COUNT_IN          => s_time_quanta_count);

  INST_canola_btl : entity work.canola_btl
    generic map (
      G_TIME_QUANTA_SCALE_WIDTH => C_TIME_QUANTA_SCALE_WIDTH_DEFAULT)
    port map (
      CLK                     => s_clk,
      RESET                   => s_reset,
      CAN_TX                  => s_can_tx,
      CAN_RX                  => s_can_rx,
      BTL_TX_BIT_VALUE        => s_btl_tx_bit_value,
      BTL_TX_BIT_VALID        => s_btl_tx_bit_valid,
      BTL_TX_RDY              => s_btl_tx_rdy,
      BTL_TX_ACTIVE           => s_btl_tx_active,
      BTL_RX_BIT_VALUE        => s_btl_rx_bit_value,
      BTL_RX_BIT_VALID        => s_btl_rx_bit_valid,
      BTL_RX_SYNCED           => s_btl_rx_synced,
      BTL_RX_STOP             => s_btl_rx_stop,
      TRIPLE_SAMPLING         => '0',
      PROP_SEG                => s_prop_seg,
      PHASE_SEG1              => s_phase_seg1,
      PHASE_SEG2              => s_phase_seg2,
      SYNC_JUMP_WIDTH         => s_sync_jump_width,
      TIME_QUANTA_PULSE       => s_time_quanta_pulse,
      TIME_QUANTA_RESTART     => s_time_quanta_restart,
      SYNC_FSM_STATE_O        => s_btl_sync_fsm_state,
      SYNC_FSM_STATE_VOTED_I  => s_btl_sync_fsm_state);

  -- Process for collecting bits received with BTL.
  -- Puts the received bits in a vector. Vector and count is reset on start of frame.
  p_btl_receive: process (s_clk) is
    variable v_data_count : natural := 0;
    variable v_receiving  : boolean := false;
  begin  -- process p_btl_receive
    if rising_edge(s_clk) then
      if s_reset = '1' then
        v_receiving           := false;
        v_data_count          := 0;
        s_btl_recv_data_count <= 0;
      else

        if s_btl_rx_synced = '1' and v_receiving = false then
          -- Reset count etc. at start of frame
          v_data_count        := 0;
          v_receiving         := true;
          s_btl_data_received <= (others => '0');
        elsif s_btl_rx_synced = '0' then
          v_receiving := false;
        end if;

        if s_btl_rx_bit_valid = '1' and v_receiving = true and v_data_count < s_btl_data_received'length then
        --if s_btl_rx_bit_valid = '1' and v_receiving = true then
          s_btl_data_received(v_data_count) <= s_btl_rx_bit_value;
          v_data_count                      := v_data_count + 1;
        end if;

        s_btl_recv_data_count <= v_data_count;
      end if;
    end if;
  end process p_btl_receive;


  -- Process for receiving bits that were transmitted via BTL off the bus line
  -- Puts the received bits in a vector. Vector and count is reset on start of frame.
  p_bus_receive: process is
    variable v_data_count          : natural := 0;
    variable v_recessive_bit_count : natural := 0;
    variable v_dominant_bit_count  : natural := 0;
    variable v_receiving           : boolean := false;
    constant C_first_half_period   : time    := C_CAN_BAUD_PERIOD*C_CAN_SAMPLE_POINT;
    constant C_second_half_period  : time    := C_CAN_BAUD_PERIOD - C_first_half_period;
  begin  -- process p_btl_receive
    loop
      wait until falling_edge(s_can_tx);

      -- Got falling edge, receiving data
      v_receiving           := true;
      v_data_count          := 0;
      v_recessive_bit_count := 0;
      v_dominant_bit_count  := 0;
      s_bus_data_received   <= (others => '0');

      while v_receiving = true loop
        wait for C_first_half_period;

        -- Sample value
        s_bus_data_received(v_data_count) <= s_can_tx;

        if v_data_count > 0 then
          if s_can_tx /= s_bus_data_received(v_data_count-1) then
            v_recessive_bit_count := 0;
            v_dominant_bit_count  := 0;
          end if;
        end if;

        v_data_count          := v_data_count + 1;

        if s_can_tx = '1' then
          v_recessive_bit_count := v_recessive_bit_count + 1;
        elsif s_can_tx = '0' then
          v_dominant_bit_count := v_dominant_bit_count + 1;
        end if;

        if v_recessive_bit_count = C_EOF_LENGTH then
          v_receiving := false;
        end if;

        s_bus_recv_data_count <= v_data_count;

        wait for C_second_half_period;
      end loop;
    end loop;

  end process p_bus_receive;


  p_main: process
    constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;

    -- Pulse a signal for a number of clock cycles.
    -- Source: irqc_tb.vhd from Bitvis UVVM 1.4.0
    procedure pulse(
      signal   target          : inout std_logic;
      signal   clock_signal    : in    std_logic;
      constant num_periods     : in    natural;
      constant msg             : in    string
    ) is
    begin
      if num_periods > 0 then
        wait until falling_edge(clock_signal);
        target  <= '1';
        for i in 1 to num_periods loop
          wait until falling_edge(clock_signal);
        end loop;
      else
        target  <= '1';
        wait for 0 ns;  -- Delta cycle only
      end if;
      target  <= '0';
      log(ID_SEQUENCER_SUB, msg, C_SCOPE);
    end;

    -- Pulse a signal for a number of clock cycles.
    -- Source: irqc_tb.vhd from Bitvis UVVM 1.4.0
    procedure pulse(
      signal   target        : inout  std_logic_vector;
      constant pulse_value   : in     std_logic_vector;
      signal   clock_signal  : in     std_logic;
      constant num_periods   : in     natural;
      constant msg           : in     string) is
    begin
      if num_periods > 0 then
        wait until falling_edge(clock_signal);
        target <= pulse_value;
        for i in 1 to num_periods loop
          wait until falling_edge(clock_signal);
        end loop;
      else
        target <= pulse_value;
        wait for 0 ns;  -- Delta cycle only
      end if;
      target(target'range) <= (others => '0');
      log(ID_SEQUENCER_SUB, "Pulsed to " & to_string(pulse_value, HEX, AS_IS, INCL_RADIX) & ". " & msg, C_SCOPE);
    end;


    -- Log overloads for simplification
    procedure log(
      msg   : string) is
    begin
      log(ID_SEQUENCER, msg, C_SCOPE);
    end;

    procedure transmit_on_bus (
      constant data_length : in natural;
      constant data        : in std_logic_vector)
    is
      variable count : natural := 0;
    begin
      wait until rising_edge(s_can_baud_clk);

      while count < data_length loop
        s_can_rx <= data(count);
        wait until rising_edge(s_can_baud_clk);
        count    := count + 1;
      end loop;
    end;

    procedure transmit_with_btl (
      constant data_length : in natural;
      constant data        : in std_logic_vector)
    is
      variable count : natural := 0;
    begin
      while count < data_length loop
        wait until rising_edge(s_clk);

        if s_btl_tx_rdy = '1' then
          s_btl_tx_bit_value <= data(count);
          s_btl_tx_bit_valid <= '1';
          count              := count + 1;

          wait until rising_edge(s_clk);
          s_btl_tx_bit_valid <= '0';
        end if;
      end loop;
    end;

    variable v_count       : natural;
    variable v_test_num    : natural;
    variable v_data_length : natural;

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    set_log_file_name("log/canola_btl_tb_log.txt");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Start simulation of Bit Timing Logic (BTL) for CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------

    s_can_rx <= '1';
    --set_inputs_passive(VOID);
    s_clock_ena <= true;                -- to start clock generator
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

    wait for 10*C_CAN_BAUD_PERIOD;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test BTL sync after start of frame (falling edge)", C_SCOPE);
    ---------------------------------------------------------------------------

    check_value(s_btl_rx_synced, '0', ERROR, "Check that BTL is not synced.");

    wait until rising_edge(s_can_baud_clk);
    s_can_rx <= '0';
    log(ID_SEQUENCER, "Sending dominant bit", C_SCOPE);

    wait until rising_edge(s_can_baud_clk);
    s_can_rx <= '1';

    v_count := 0;

    -- BTL should be synced after first dominant bit
    while v_count <= C_EOF_LENGTH loop
      check_value(s_btl_rx_synced, '1', error, "Check that BTL is synced.");
      v_count := v_count + 1;
      wait until rising_edge(s_can_baud_clk);
    end loop;

    s_btl_rx_stop <= '1';
    wait until rising_edge(s_clk);
    s_btl_rx_stop <= '0';
    wait until rising_edge(s_clk);
    wait until rising_edge(s_can_baud_clk);

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receiving with BTL", C_SCOPE);
    ---------------------------------------------------------------------------
    v_test_num := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_frame_size(v_data_length, C_DATA_LENGTH_MAX, seed1, seed2);
      generate_random_data_for_btl(s_data_transmit, v_data_length, seed1, seed2);

      log(ID_SEQUENCER,
          "Iteration " & to_string(v_test_num) & ", " & to_string(v_data_length) & " bits.",
          C_SCOPE);

      transmit_on_bus(v_data_length, s_data_transmit);

      check_value(s_btl_rx_synced, '1', error, "Check that BTL has synced.");
      check_value(s_btl_recv_data_count, v_data_length, error, "Check number of bits received.");
      check_value(s_btl_data_received(0 to v_data_length-1),
                  s_data_transmit(0 to v_data_length-1),
                  error, "Verify data received by BTL.");

      s_btl_rx_stop <= '1';
      wait until rising_edge(s_clk);
      s_btl_rx_stop <= '0';
      wait until rising_edge(s_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receiving with BTL - with positive clock error", C_SCOPE);
    ---------------------------------------------------------------------------
    s_can_baud_error <= 1.5;            -- 1.5% error in clock period
    v_test_num       := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_frame_size(v_data_length, C_DATA_LENGTH_MAX, seed1, seed2);
      generate_random_data_for_btl(s_data_transmit, v_data_length, seed1, seed2);

      log(ID_SEQUENCER,
          "Iteration " & to_string(v_test_num) & ", " & to_string(v_data_length) & " bits.",
          C_SCOPE);

      transmit_on_bus(v_data_length, s_data_transmit);

      check_value(s_btl_rx_synced, '1', error, "Check that BTL has synced.");
      check_value(s_btl_recv_data_count, v_data_length, error, "Check number of bits received.");
      check_value(s_btl_data_received(0 to v_data_length-1),
                  s_data_transmit(0 to v_data_length-1),
                  error, "Verify data received by BTL.");

      s_btl_rx_stop <= '1';
      wait until rising_edge(s_clk);
      s_btl_rx_stop <= '0';
      wait until rising_edge(s_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receiving with BTL - with negative clock error", C_SCOPE);
    ---------------------------------------------------------------------------
    s_can_baud_error <= -1.5; -- -1.5% error in clock period
    v_test_num       := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_frame_size(v_data_length, C_DATA_LENGTH_MAX, seed1, seed2);
      generate_random_data_for_btl(s_data_transmit, v_data_length, seed1, seed2);

      log(ID_SEQUENCER,
          "Iteration " & to_string(v_test_num) & ", " & to_string(v_data_length) & " bits.",
          C_SCOPE);

      transmit_on_bus(v_data_length, s_data_transmit);

      check_value(s_btl_rx_synced, '1', error, "Check that BTL has synced.");
      check_value(s_btl_recv_data_count, v_data_length, error, "Check number of bits received.");
      check_value(s_btl_data_received(0 to v_data_length-1),
                  s_data_transmit(0 to v_data_length-1),
                  error, "Verify data received by BTL.");

      s_btl_rx_stop <= '1';
      wait until rising_edge(s_clk);
      s_btl_rx_stop <= '0';
      wait until rising_edge(s_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test transmitting with BTL", C_SCOPE);
    ---------------------------------------------------------------------------
    s_can_baud_error <= 0.0;
    v_test_num       := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_frame_size(v_data_length, C_DATA_LENGTH_MAX, seed1, seed2);
      generate_random_data_for_btl(s_data_transmit, v_data_length, seed1, seed2);

      log(ID_SEQUENCER,
          "Iteration " & to_string(v_test_num) & ", " & to_string(v_data_length) & " bits.",
          C_SCOPE);

      transmit_with_btl(v_data_length, s_data_transmit);

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      check_value(s_bus_recv_data_count, v_data_length, error, "Check number of bits transmitted by BTL.");
      check_value(s_bus_data_received(0 to v_data_length-1),
                  s_data_transmit(0 to v_data_length-1),
                  error, "Verify data transmitted by BTL.");

      v_test_num := v_test_num + 1;
    end loop;


    wait for 10000 ns;            -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end tb;
