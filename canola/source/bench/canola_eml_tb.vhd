-------------------------------------------------------------------------------
-- Title      : UVVM Testbench for Error Management Logic (EML)
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_eml_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    :
-- Created    : 2019-09-17
-- Last update: 2020-09-04
-- Platform   :
-- Target     : Questasim
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UVVM testbench for Error Management Logic (EML) in the
--              Canola CAN controller.
--              Verifies that the EML conforms to the CAN 2.0B specification.
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2019-09-17  1.0      svn                     Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- This test bench verifies that the EML conforms to part 7 (Error Handling)
-- and part 8 (Fault Confinement) of the CAN 2.0B specification
--
-- Test tests performed and the rules from CAN 2.0B part 8 which they
-- are supposed to test, are listed below.
-------------------------------------------------------------------------------

-- Test 1: Reset values
-- Counters should be zero
-- ERROR ACTIVE mode

-- Test 2: CAN 2.0B 8.1
-- Test counting up receive error count on receive errors.
-- Test that receive error count saturates and does not overflow/reset.
-- Check that receive error count increases by 1 for receive errors:
-- * STUFF ERROR
-- * CRC ERROR
-- * FORM ERROR

-- Test 3: CAN 2.0B 8.3
-- Test counting up transmit error count on transmit errors.
-- Test that transmit error count saturates and does not overflow/reset.
-- Check that transmit error count increases by 8 for transmit errors:
-- * BIT ERROR
-- * ACK ERROR
--    * If in ERROR ACTIVE mode
--    * If in ERROR PASSIVE mode and a dominant bit is detected while
--      transmitting PASSIVE ERROR flag
-- * Bit error while sending ACTIVE ERROR flag

-- Test 4: CAN 2.0B 8.2 and 8.5:
-- Check that receive error count increases by 8 when detecting a dominant bit
-- in the next bit after sending an ERROR flag.
-- Check that receive error count increases by 8 when detecting a bit error
-- while sending ACTIVE ERROR flag or OVERLOAD flag.

-- Test 5: CAN 2.0B 8.8
-- Test counting down receive error count by 1 on successful transmissions:
-- * If error count is less than 128.
-- Test that receive error count decreases to 120 on successful transmission:
-- * If error count is equal to or greater than 128.
-- Test that receive error count "saturates" at 0 and does not underflow.

-- Test 6: CAN 2.0B 8.7:
-- Test counting down transmit error count by 1 on successful transmissions.
-- Test that transmit error count "saturates" at 0 and does not underflow.

-- Test 7: CAN 2.0B 8.9
-- Check that error state is ERROR ACTIVE when transmit error count and
-- receive error count are both below 128. Count both up to 127 and check
-- that state is still ERROR_ACTIVE.
-- Check that error state becomes ERROR PASSIVE when transmit error count
-- is equal to or larger than 128, but less than 256.
-- Check that error state becomes ERROR PASSIVE when receive error count
-- is equal to or larger than 128, and transmit error count is less than 128.
-- Check that error state is ERROR PASSIVE when both receive and transmit
-- error counts are equal to or larger than 128.

-- Test 8: CAN 2.0B 8.10
-- Check that error state is BUS OFF when transmit error count is equal to
-- or larger than 256, regardless of receive error count

-- Test 9: CAN 2.0B 8.11
-- Check that error state returns ERROR ACTIVE again when transmit and
-- receive error counts decrease to 127 or less

-- Test 10: CAN 2.0B 8.12
-- Check that error state returns from BUS OFF to ERROR ACTIVE and that both
-- transmit and receive error counts are set to 0, after 11 consecutive
-- recessive bits have been monitored 128 times

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

entity canola_eml_tb is
end canola_eml_tb;

architecture tb of canola_eml_tb is

  constant C_CLK_PERIOD : time       := 100 ns; -- 10 Mhz
  constant C_CLK_FREQ   : integer    := 1e9 ns / C_CLK_PERIOD;

  constant C_CAN_BAUD_PERIOD  : time    := 10000 ns;  -- 100 kHz
  constant C_CAN_BAUD_FREQ    : integer := 1e9 ns / C_CLK_PERIOD;

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

  signal s_clock_ena      : boolean   := false;
  signal s_can_baud_clk   : std_logic := '0';
  signal s_can_baud_error : real      := 0.0;

  signal s_reset            : std_logic := '0';
  signal s_clk              : std_logic := '0';

  -- EML signals
  signal s_eml_rx_stuff_error                   : std_logic := '0';
  signal s_eml_rx_crc_error                     : std_logic := '0';
  signal s_eml_rx_form_error                    : std_logic := '0';
  signal s_eml_rx_active_error_flag_bit_error   : std_logic := '0';
  signal s_eml_rx_overload_flag_bit_error       : std_logic := '0';
  signal s_eml_rx_dominant_bit_after_error_flag : std_logic := '0';
  signal s_eml_tx_bit_error                     : std_logic := '0';
  signal s_eml_tx_ack_error                     : std_logic := '0';
  signal s_eml_tx_active_error_flag_bit_error   : std_logic := '0';
  signal s_eml_transmit_success                 : std_logic := '0';
  signal s_eml_receive_success                  : std_logic := '0';
  signal s_eml_recv_11_recessive_bits           : std_logic := '0';
  signal s_eml_tec_count_value                  : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_eml_tec_count_incr                   : std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
  signal s_eml_tec_count_up                     : std_logic;
  signal s_eml_tec_count_down                   : std_logic;
  signal s_eml_tec_clear                        : std_logic;
  signal s_eml_tec_set                          : std_logic;
  signal s_eml_tec_set_value                    : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_eml_rec_count_value                  : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_eml_rec_count_incr                   : std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
  signal s_eml_rec_count_up                     : std_logic;
  signal s_eml_rec_count_down                   : std_logic;
  signal s_eml_rec_clear                        : std_logic;
  signal s_eml_rec_set                          : std_logic;
  signal s_eml_rec_set_value                    : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_eml_recessive_bit_count_value        : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_eml_recessive_bit_count_up           : std_logic;
  signal s_eml_recessive_bit_count_clear        : std_logic;
  signal s_eml_error_state                      : can_error_state_t;
  signal s_eml_error_state_bits                 : std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

  signal s_eml_transmit_error_count             : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_eml_receive_error_count              : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);

begin

  assert (C_CAN_SAMPLE_POINT >= 0.0 and C_CAN_SAMPLE_POINT <= 1.0)
    report "Illegal value for C_CAN_SAMPLE_POINT" severity error;

  -- Set up clock generators
  clock_gen(s_clk, s_clock_ena, C_CLK_PERIOD);

  s_eml_error_state <= can_error_state_t'val(to_integer(unsigned(s_eml_error_state_bits)));

  INST_canola_eml: entity work.canola_eml
    port map (
      CLK                              => s_clk,
      RESET                            => s_reset,
      RX_STUFF_ERROR                   => s_eml_rx_stuff_error,
      RX_CRC_ERROR                     => s_eml_rx_crc_error,
      RX_FORM_ERROR                    => s_eml_rx_form_error,
      RX_ACTIVE_ERROR_FLAG_BIT_ERROR   => s_eml_rx_active_error_flag_bit_error,
      RX_OVERLOAD_FLAG_BIT_ERROR       => s_eml_rx_overload_flag_bit_error,
      RX_DOMINANT_BIT_AFTER_ERROR_FLAG => s_eml_rx_dominant_bit_after_error_flag,
      TX_BIT_ERROR                     => s_eml_tx_bit_error,
      TX_ACK_ERROR                     => s_eml_tx_ack_error,
      TX_ACTIVE_ERROR_FLAG_BIT_ERROR   => s_eml_tx_active_error_flag_bit_error,
      TRANSMIT_SUCCESS                 => s_eml_transmit_success,
      RECEIVE_SUCCESS                  => s_eml_receive_success,
      RECV_11_RECESSIVE_BITS           => s_eml_recv_11_recessive_bits,
      TEC_COUNT_VALUE                  => s_eml_tec_count_value,
      TEC_COUNT_INCR                   => s_eml_tec_count_incr,
      TEC_COUNT_UP                     => s_eml_tec_count_up,
      TEC_COUNT_DOWN                   => s_eml_tec_count_down,
      TEC_CLEAR                        => s_eml_tec_clear,
      TEC_SET                          => s_eml_tec_set,
      TEC_SET_VALUE                    => s_eml_tec_set_value,
      REC_COUNT_VALUE                  => s_eml_rec_count_value,
      REC_COUNT_INCR                   => s_eml_rec_count_incr,
      REC_COUNT_UP                     => s_eml_rec_count_up,
      REC_COUNT_DOWN                   => s_eml_rec_count_down,
      REC_CLEAR                        => s_eml_rec_clear,
      REC_SET                          => s_eml_rec_set,
      REC_SET_VALUE                    => s_eml_rec_set_value,
      RECESSIVE_BIT_COUNT_VALUE        => s_eml_recessive_bit_count_value,
      RECESSIVE_BIT_COUNT_UP           => s_eml_recessive_bit_count_up,
      RECESSIVE_BIT_COUNT_CLEAR        => s_eml_recessive_bit_count_clear,
      ERROR_STATE                      => s_eml_error_state_bits);

  -- Receive Error Counter (REC) used by EML
  INST_receive_error_counter: entity work.counter_saturating
    generic map (
      BIT_WIDTH  => C_ERROR_COUNT_LENGTH,
      INCR_WIDTH => C_ERROR_COUNT_INCR_LENGTH,
      VERBOSE    => false)
    port map (
      CLK            => s_clk,
      RESET          => s_reset,
      CLEAR          => s_eml_rec_clear,
      SET            => s_eml_rec_set,
      SET_VALUE      => s_eml_rec_set_value,
      COUNT_UP       => s_eml_rec_count_up,
      COUNT_DOWN     => s_eml_rec_count_down,
      COUNT_INCR     => s_eml_rec_count_incr,
      COUNT_OUT      => s_eml_rec_count_value,
      COUNT_VOTED_IN => s_eml_rec_count_value);

  -- Transmit Error Counter (TEC) used by EML
  INST_transmit_error_counter: entity work.counter_saturating
    generic map (
      BIT_WIDTH  => C_ERROR_COUNT_LENGTH,
      INCR_WIDTH => C_ERROR_COUNT_INCR_LENGTH,
      VERBOSE    => false)
    port map (
      CLK            => s_clk,
      RESET          => s_reset,
      CLEAR          => s_eml_tec_clear,
      SET            => s_eml_tec_set,
      SET_VALUE      => s_eml_tec_set_value,
      COUNT_UP       => s_eml_tec_count_up,
      COUNT_DOWN     => s_eml_tec_count_down,
      COUNT_INCR     => s_eml_tec_count_incr,
      COUNT_OUT      => s_eml_tec_count_value,
      COUNT_VOTED_IN => s_eml_tec_count_value);

  -- Counter for sequences of 11 recessive bits used by EML
  INST_recessive_bit_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => C_ERROR_COUNT_LENGTH,
      IS_SATURATING => true,
      VERBOSE       => false)
    port map (
      CLK            => s_clk,
      RESET          => s_reset,
      CLEAR          => s_eml_recessive_bit_count_clear,
      COUNT_UP       => s_eml_recessive_bit_count_up,
      COUNT_OUT      => s_eml_recessive_bit_count_value,
      COUNT_VOTED_IN => s_eml_recessive_bit_count_value);


  s_eml_transmit_error_count <= unsigned(s_eml_tec_count_value);
  s_eml_receive_error_count  <= unsigned(s_eml_rec_count_value);


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

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    set_log_file_name("log/canola_eml_tb_log.txt");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Start simulation of Error Management Logic (EML) for CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------

    --set_inputs_passive(VOID);
    s_clock_ena <= true;                -- to start clock generator
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

    wait for 10*C_CLK_PERIOD;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #1: Reset values", C_SCOPE);
    ---------------------------------------------------------------------------
    check_value(s_eml_error_state, ERROR_ACTIVE,
                ERROR, "Check that EML is in ERROR ACTIVE state after reset.");

    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #2: CAN 2.0B 8.1...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receive error counter increase by 1 on Rx STUFF ERROR", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    for i in 1 to 2**s_eml_receive_error_count'length-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_stuff_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_stuff_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 1");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_rx_stuff_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_stuff_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count does not overflow.");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receive error counter increase by 1 on Rx CRC ERROR", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    for i in 1 to 2**s_eml_receive_error_count'length-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_crc_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_crc_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 1");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_rx_crc_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_crc_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count does not overflow");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receive error counter increase by 1 on Rx FORM ERROR", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    for i in 1 to 2**s_eml_receive_error_count'length-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 1");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_rx_form_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_form_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count does not overflow");




    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #3: CAN 2.0B 8.3...", C_SCOPE);
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test transmit error counter increase by 8 on BIT ERROR", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    for i in 1 to (2**s_eml_transmit_error_count'length/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_transmit_error_count, to_unsigned(i*8, s_eml_transmit_error_count'length),
                  ERROR, "Check transmit error count increase by 8");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(2**s_eml_transmit_error_count'length-1, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count does not overflow");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test transmit error counter increase by 8 on ACK ERROR", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    for i in 1 to C_ERROR_PASSIVE_THRESHOLD/8 loop
      check_value(s_eml_error_state, ERROR_ACTIVE,
                  ERROR, "Check that error state is ERROR ACTIVE");

      wait until rising_edge(s_clk);
      s_eml_tx_ack_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_ack_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_transmit_error_count, to_unsigned(i*8, s_eml_transmit_error_count'length),
                  ERROR, "Check transmit error count increase by 8");
    end loop;

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is now ERROR PASSIVE");

    wait until rising_edge(s_clk);
    s_eml_tx_ack_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_ack_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD, s_eml_transmit_error_count'length),
                ERROR, "Transmit error count no increase on ACK error in ERROR PASSIVE.");

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test transmit error counter increase by 8 on BIT ERROR in ACTIVE ERROR FLAG", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    for i in 1 to (2**s_eml_transmit_error_count'length/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_tx_active_error_flag_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_active_error_flag_bit_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_transmit_error_count, to_unsigned(i*8, s_eml_transmit_error_count'length),
                  ERROR, "Check transmit error count increase by 8 on BIT ERROR in ACTIVE ERROR FLAG");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_tx_active_error_flag_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_active_error_flag_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(2**s_eml_transmit_error_count'length-1, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count saturates and does not reset.");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #4: CAN 2.0B 8.2 and 8.5...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Receive error counter increase by 8 on dominant bit after ERROR flag", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    for i in 1 to (2**s_eml_receive_error_count'length/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_dominant_bit_after_error_flag <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_dominant_bit_after_error_flag <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i*8, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 8 on dominant bit after ERROR flag.");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_rx_dominant_bit_after_error_flag <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_dominant_bit_after_error_flag <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count saturates and does not reset.");

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Receive error counter increase by 8 on BIT ERROR in ACTIVE ERROR flag", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    for i in 1 to (2**s_eml_receive_error_count'length/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_active_error_flag_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_active_error_flag_bit_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i*8, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 8 on BIT ERROR in ACTIVE ERROR FLAG");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_rx_active_error_flag_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_active_error_flag_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count saturates and does not reset.");

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Receive error counter increase by 8 on BIT ERROR in OVERLOAD flag", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    for i in 1 to (2**s_eml_receive_error_count'length/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_overload_flag_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_overload_flag_bit_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i*8, s_eml_receive_error_count'length),
                  ERROR, "Receive error count increase by 8 on BIT ERROR in OVERLOAD flag");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_rx_overload_flag_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_overload_flag_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count saturates and does not reset.");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #5: CAN 2.0B 8.8...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test receive error counter decrease by 1 on receive success", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    -- Count up to 10 receive errors
    for i in 1 to 10 loop
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 1");
    end loop;

    -- Count down 10 receive errors on receive success
    for i in 9 downto 0 loop
      wait until rising_edge(s_clk);
      s_eml_receive_success <= '1';
      wait until rising_edge(s_clk);
      s_eml_receive_success <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process success signal,
      -- and an additional clock cycle for the counter module to decrease
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count decrease by 1 on receive success");
    end loop;

    check_value(s_eml_receive_error_count,
                to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count is zero.");

    wait until rising_edge(s_clk);
    s_eml_receive_success <= '1';
    wait until rising_edge(s_clk);
    s_eml_receive_success <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count is still zero and did not underflow.");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Receive error counter decrease to 120 on receive success when higher than 128", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");

    -- Count up to 128 (ERROR PASSIVE threshold) + 10 receive errors
    for i in 1 to C_ERROR_PASSIVE_THRESHOLD+10 loop
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_receive_error_count, to_unsigned(i, s_eml_receive_error_count'length),
                  ERROR, "Check receive error count increase by 1");
    end loop;

    wait until rising_edge(s_clk);
    s_eml_receive_success <= '1';
    wait until rising_edge(s_clk);
    s_eml_receive_success <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(C_REC_SUCCES_ERROR_PASSIVE_JUMP_VALUE, s_eml_receive_error_count'length),
                ERROR, "Check receive error count jump to below error passive threshold");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #6: CAN 2.0B 8.7...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test transmit error counter decrease by 1 on transmit success", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check receive error count after reset");

    -- Count up to 10 transmit errors (8 error count per error)
    for i in 1 to 10 loop
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_transmit_error_count, to_unsigned(i*8, s_eml_transmit_error_count'length),
                  ERROR, "Check receive error count increase by 8 on Tx BIT ERROR");
    end loop;

    -- Count down 10*8 transmit errors on transmit success
    for i in (10*8)-1 downto 0 loop
      wait until rising_edge(s_clk);
      s_eml_transmit_success <= '1';
      wait until rising_edge(s_clk);
      s_eml_transmit_success <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process success signal,
      -- and an additional clock cycle for the counter module to decrease
      wait until rising_edge(s_clk);

      check_value(s_eml_transmit_error_count, to_unsigned(i, s_eml_transmit_error_count'length),
                  ERROR, "Check transmit error count decrease by 1 on transmit success");
    end loop;

    check_value(s_eml_transmit_error_count,
                to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count is zero.");

    wait until rising_edge(s_clk);
    s_eml_transmit_success <= '1';
    wait until rising_edge(s_clk);
    s_eml_transmit_success <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count is still zero and did not underflow.");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #7: CAN 2.0B 8.9...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test ERROR ACTIVE state with Tx/Rx error counts below 128 (ERROR PASSIVE threshold)",
        C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");
    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    for i in 1 to C_ERROR_PASSIVE_THRESHOLD-1 loop
      -- Pulse signals that lead to increase by 1 in Rx error counter
      wait until rising_edge(s_clk);
      s_eml_rx_stuff_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_stuff_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_error_state, ERROR_ACTIVE,
                  ERROR, "Check that error state is ERROR ACTIVE");
    end loop;

    -- Tx error counter increases by 8 on tx bit error
    for i in 1 to (C_ERROR_PASSIVE_THRESHOLD/8)-1 loop
      -- Pulse signals that lead to increase by 8 in Tx error counter
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error   <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error   <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_error_state, ERROR_ACTIVE,
                  ERROR, "Check that error state is ERROR ACTIVE");
    end loop;

    check_value(s_eml_receive_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count is 127 (1 count below ERROR PASSIVE threshold)");

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD-8, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count is 120 (8 counts below ERROR PASSIVE threshold)");

    -- Bring Rx error counter up to 128, which should bring
    -- the error state to ERROR PASSIVE
    wait until rising_edge(s_clk);
    s_eml_rx_stuff_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_stuff_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD, s_eml_receive_error_count'length),
                ERROR, "Check receive error count is 128 (ie. ERROR PASSIVE threshold)");

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is ERROR PASSIVE");

    -- Bring Tx error counter up to 128 (error passive threshold), and check that error state
    -- is also ERROR PASSIVE with both counters at and above the threshold
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count is 128 (ie. ERROR PASSIVE threshold)");

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is ERROR PASSIVE");

    -- Reset and check that error state goes to ERROR PASSIVE when Tx error
    -- counter alone is at or above ERROR PASSIVE threshold
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");
    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    for i in 1 to (C_ERROR_PASSIVE_THRESHOLD/8)-1 loop
      -- Pulse signals that lead to increase by 1 in both Rx and Tx error counters
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error   <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error   <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_error_state, ERROR_ACTIVE,
                  ERROR, "Check that error state is ERROR ACTIVE");
    end loop;

    -- Bring transmit error count up to 128 (error passive threshold)
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is ERROR PASSIVE");

    -- Bring transmit error count down to 127 (1 count below error passive threshold)
    wait until rising_edge(s_clk);
    s_eml_transmit_success <= '1';
    wait until rising_edge(s_clk);
    s_eml_transmit_success <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD-1, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count is at 127 (1 count below ERROR PASSIVE threshold)");

    check_value(s_eml_error_state, ERROR_ACTIVE,
                ERROR, "Check that error state is ERROR ACTIVE");

    -- Bring Tx error counter up to 135 (above ERROR PASSIVE threshold),
    -- which should bring the error state to ERROR PASSIVE
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD-1+8, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count is above ERROR PASSIVE threshold");

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is ERROR PASSIVE");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #8: CAN 2.0B 8.10...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test BUS OFF state only when Tx error counter reaches 256 (BUS OFF threshold)", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");
    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    -- Count up receive error counter to maximum value
    for i in 1 to 2**s_eml_receive_error_count'length loop
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(2**s_eml_receive_error_count'length-1, s_eml_receive_error_count'length),
                ERROR, "Check receive error count is at maximum value");

    -- Only Tx error counter at 256 and above (BUS OFF threshold)
    -- can bring the controller into BUS OFF state
    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is ERROR PASSIVE");

    -- Count up transmit error counter to just below BUS OFF threshold
    for i in 1 to (C_BUS_OFF_THRESHOLD/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_BUS_OFF_THRESHOLD-8, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count at 248 (8 below BUS OFF threshold)");

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is still ERROR PASSIVE");

    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_transmit_error_count,
                to_unsigned(C_BUS_OFF_THRESHOLD, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count at 256 (BUS OFF threshold)");

    check_value(s_eml_error_state, BUS_OFF,
                ERROR, "Check that error state is now bus OFF");

    -- Keep counting up transmit error counter and
    -- verify that error state is still BUS OFF
    for i in C_BUS_OFF_THRESHOLD to 2**s_eml_transmit_error_count'length loop
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '0';
      wait until rising_edge(s_clk);

      -- It takes one clock cycle for EML to process error signal,
      -- and an additional clock cycle for the counter module to increase
      wait until rising_edge(s_clk);

      check_value(s_eml_error_state, BUS_OFF,
                  ERROR, "Check that error state is bus OFF");
    end loop;


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #9: CAN 2.0B 8.11...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Check return to ERROR ACTIVE after successful transmits", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");
    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    -- Count up transmit error counter to just below BUS OFF threshold
    for i in 1 to (C_BUS_OFF_THRESHOLD/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_PASSIVE, ERROR, "Check that error state is ERROR PASSIVE");

    -- Count down transmit error to ERROR PASSIVE threshold
    for i in C_BUS_OFF_THRESHOLD-(8+1) downto C_ERROR_PASSIVE_THRESHOLD loop
      wait until rising_edge(s_clk);
      s_eml_transmit_success <= '1';
      wait until rising_edge(s_clk);
      s_eml_transmit_success <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_PASSIVE, ERROR, "Check that error state is still ERROR PASSIVE");

    -- Count down transmit error by one, bringing it below ERROR PASSIVE threshold
    wait until rising_edge(s_clk);
    s_eml_transmit_success <= '1';
    wait until rising_edge(s_clk);
    s_eml_transmit_success <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_ACTIVE, ERROR, "Check that error state is now ERROR ACTIVE");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Check return to ERROR ACTIVE after successful receptions", C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");
    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    -- Count up receive error counter to one below ERROR PASSIVE threshold
    for i in 1 to C_ERROR_PASSIVE_THRESHOLD-1 loop
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_rx_form_error <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_ACTIVE, ERROR, "Check that error state is still ERROR ACTIVE");

    -- Count up receive error counter to ERROR PASSIVE threshold
    wait until rising_edge(s_clk);
    s_eml_rx_form_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_rx_form_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(C_ERROR_PASSIVE_THRESHOLD, s_eml_receive_error_count'length),
                ERROR, "Check receive error count");
    check_value(s_eml_error_state, ERROR_PASSIVE, ERROR, "Check that error state is ERROR PASSIVE");

    wait until rising_edge(s_clk);
    s_eml_receive_success <= '1';
    wait until rising_edge(s_clk);
    s_eml_receive_success <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process success signal,
    -- and an additional clock cycle for the counter module to decrease
    wait until rising_edge(s_clk);

    check_value(s_eml_receive_error_count,
                to_unsigned(C_REC_SUCCES_ERROR_PASSIVE_JUMP_VALUE, s_eml_receive_error_count'length),
                ERROR, "Check receive error count jumped below passive threshold");
    check_value(s_eml_error_state, ERROR_ACTIVE, ERROR, "Check that error state is now ERROR ACTIVE");


    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #10: CAN 2.0B 8.12...", C_SCOPE);
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Check bus OFF->ERROR ACTIVE after receiving 128x11 consecutive recessive bits",
        C_SCOPE);
    ---------------------------------------------------------------------------
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
    wait for 10*C_CLK_PERIOD;

    check_value(s_eml_receive_error_count, to_unsigned(0, s_eml_receive_error_count'length),
                ERROR, "Check receive error count after reset");
    check_value(s_eml_transmit_error_count, to_unsigned(0, s_eml_transmit_error_count'length),
                ERROR, "Check transmit error count after reset");

    -- Counts of 11 consecutive recessive bits should only count after the
    -- controller has gone into BUS OFF state.
    -- Start off with some counts of 11 consecutive recessive bits before
    -- entering BUS OFF, to verify that 128 new instances of 11 recessive bits
    -- is required AFTER entering BUS OFF
    for i in 1 to 10 loop
      wait until rising_edge(s_clk);
      s_eml_recv_11_recessive_bits <= '1';
      wait until rising_edge(s_clk);
      s_eml_recv_11_recessive_bits <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- Bring number of transmit errors up to just below BUS OFF threshold
    for i in 1 to (C_BUS_OFF_THRESHOLD/8)-1 loop
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '1';
      wait until rising_edge(s_clk);
      s_eml_tx_bit_error <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_PASSIVE,
                ERROR, "Check that error state is ERROR PASSIVE");

    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '1';
    wait until rising_edge(s_clk);
    s_eml_tx_bit_error <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process error signal,
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, BUS_OFF,
                ERROR, "Check that error state is bus OFF");

    -- Bring number of sequences of 11 recessive bits up to just below the
    -- threshold required to bring controller out of BUS OFF
    for i in 1 to C_11_RECESSIVE_EXIT_BUS_OFF_THRESHOLD-1 loop
      wait until rising_edge(s_clk);
      s_eml_recv_11_recessive_bits <= '1';
      wait until rising_edge(s_clk);
      s_eml_recv_11_recessive_bits <= '0';
      wait until rising_edge(s_clk);
    end loop;

    -- It takes one clock cycle for EML to process the 11-bit sequence signal
    -- and an additional clock cycle for the counter module to increase
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, BUS_OFF,
                ERROR, "Check that error state is still bus OFF");

    wait until rising_edge(s_clk);
    s_eml_recv_11_recessive_bits <= '1';
    wait until rising_edge(s_clk);
    s_eml_recv_11_recessive_bits <= '0';
    wait until rising_edge(s_clk);

    -- It takes one clock cycle for EML to process the 11-bit sequence signal,
    -- one clock cycle for the 11-bit sequence counter module to increase,
    -- one clock cycle for EML to reset REC/TEC based on 11-bit sequence count,
    -- and an additional clock cycle for bus state to update based on new REC/TEC
    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);

    check_value(s_eml_error_state, ERROR_ACTIVE,
                ERROR, "Check that error state is ERROR ACTIVE after sequence of 11 recessive bits");



    ---------------------------------------------------------------------------
    -- SIMULATION COMPLETED
    ---------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end tb;
