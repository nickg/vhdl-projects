-------------------------------------------------------------------------------
-- Title      : UVVM Testbench for Bit Stream Processor (BSP)
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_bsp_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    :
-- Created    : 2019-07-20
-- Last update: 2020-08-26
-- Platform   :
-- Target     : Questasim
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UVVM testbench for the Bit Stream Processor (BSP) in the
--              Canola CAN controller.
--              The BSP is tested using an instance of the BTL, with the
--              Tx output and Rx input of the BTL connected together to a
--              shared bus signal with pullup. Data is transmitted on the Tx
--              interface of the BSP, and it is verified that the Rx interface
--              of the BSP receives the same data. Tests performed:
--              - Send/receive random data without bit stuffing
--              - Send/receive random data with bit stuffing
--              - Send ACK
--              CRC generation is also tested, and verified against CRC
--              function in CAN bus BFM.
-- Todo       : BSP testbench is broken..
--              With recent changes to BSP I can't both receive and transmit
--              at the same time with the same BSP. So have to rethink this
--              testbench, or make some changes to the BSP..
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2019-07-20  1.0      svn                     Created
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
use work.can_bfm_pkg.all;

-- test bench entity
entity canola_bsp_tb is
end canola_bsp_tb;

architecture tb of canola_bsp_tb is

  constant C_CLK_PERIOD : time       := 100 ns; -- 10 Mhz
  constant C_CLK_FREQ   : integer    := 1e9 ns / C_CLK_PERIOD;

  constant C_CAN_BAUD_PERIOD  : time    := 10000 ns;  -- 100 kHz
  constant C_CAN_BAUD_FREQ    : integer := 1e9 ns / C_CLK_PERIOD;

  -- Indicates where in a bit the Rx sample point should be
  -- Real value from 0.0 to 1.0.
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

  signal s_reset            : std_logic := '0';
  signal s_clk              : std_logic := '0';
  signal s_can_tx, s_can_rx : std_logic;

  signal s_bsp_tx_data                : std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
  signal s_bsp_tx_data_count          : natural range 0 to C_BSP_DATA_LENGTH;
  signal s_bsp_tx_data_count_bits     : std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
  signal s_bsp_tx_write_en            : std_logic         := '0';
  signal s_bsp_tx_bit_stuff_en        : std_logic         := '1';
  signal s_bsp_tx_rx_mismatch         : std_logic;
  signal s_bsp_tx_rx_stuff_mismatch   : std_logic;
  signal s_bsp_tx_done                : std_logic;
  signal s_bsp_tx_crc_calc            : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
  signal s_bsp_tx_active              : std_logic         := '0';
  signal s_bsp_rx_active              : std_logic;
  signal s_bsp_rx_ifs                 : std_logic;
  signal s_bsp_rx_data                : std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
  signal s_bsp_rx_data_count          : natural range 0 to C_BSP_DATA_LENGTH;
  signal s_bsp_rx_data_count_bits     : std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
  signal s_bsp_rx_data_clear          : std_logic         := '0';
  signal s_bsp_rx_data_overflow       : std_logic;
  signal s_bsp_rx_bit_destuff_en      : std_logic         := '0';
  signal s_bsp_rx_stop                : std_logic         := '0';
  signal s_bsp_rx_bit_stuff_error     : std_logic;
  signal s_bsp_rx_crc_calc            : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
  signal s_bsp_rx_send_ack            : std_logic         := '0';
  signal s_bsp_rx_active_error_flag   : std_logic;
  signal s_bsp_rx_passive_error_flag  : std_logic;
  signal s_bsp_send_error_flag        : std_logic         := '0';
  signal s_eml_recv_11_recessive_bits : std_logic;
  signal s_eml_error_state            : can_error_state_t := ERROR_ACTIVE;
  signal s_eml_error_state_bits       : std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);
  signal s_btl_tx_bit_value           : std_logic         := '0';
  signal s_btl_tx_bit_valid           : std_logic         := '0';
  signal s_btl_tx_rdy                 : std_logic         := '0';
  signal s_btl_tx_done                : std_logic         := '0';
  signal s_btl_rx_bit_value           : std_logic         := '0';
  signal s_btl_rx_bit_valid           : std_logic         := '0';
  signal s_btl_rx_synced              : std_logic         := '0';
  signal s_btl_rx_stop                : std_logic         := '0';
  signal s_bsp_rx_fsm_state           : std_logic_vector(C_BSP_RX_FSM_STATE_BITSIZE-1 downto 0);
  signal s_bsp_tx_fsm_state           : std_logic_vector(C_BSP_TX_FSM_STATE_BITSIZE-1 downto 0);
  signal s_btl_sync_fsm_state         : std_logic_vector(C_BTL_SYNC_FSM_STATE_BITSIZE-1 downto 0);

  signal s_prop_seg        : std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0)   := "0111";
  signal s_phase_seg1      : std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0) := "0111";
  signal s_phase_seg2      : std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0) := "0111";

  signal s_sync_jump_width : unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0)
    := to_unsigned(2, C_SYNC_JUMP_WIDTH_BITSIZE);

  signal s_time_quanta_pulse   : std_logic := '0';
  signal s_time_quanta_restart : std_logic := '0';
  signal s_time_quanta_count   : std_logic_vector(C_TIME_QUANTA_SCALE_WIDTH_DEFAULT-1 downto 0);

  signal can_bus_signal    : std_logic;

  signal s_rx_tx_mismatch_rst       : std_logic := '0';
  signal s_got_rx_tx_mismatch       : std_logic := '0';
  signal s_got_rx_tx_stuff_mismatch : std_logic := '0';
  signal s_crc_exp                  : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
  signal s_rand_bsp_data            : std_logic_vector(0 to C_BSP_DATA_LENGTH-1);

begin

  -- Set up clock generators
  clock_gen(s_clk, s_clock_ena, C_CLK_PERIOD);
  clock_gen(s_can_baud_clk, s_clock_ena, C_CAN_BAUD_PERIOD);

  can_bus_signal <= 'H';
  can_bus_signal <= '0' when s_can_tx = '0' else 'Z';
  s_can_rx       <= '1' ?= can_bus_signal;

  s_bsp_rx_bit_stuff_error <= s_bsp_rx_bit_destuff_en and
                              (s_bsp_rx_active_error_flag or s_bsp_rx_passive_error_flag);

  s_eml_error_state_bits <= std_logic_vector(to_unsigned(can_error_state_t'pos(s_eml_error_state),
                                                         C_CAN_ERROR_STATE_BITSIZE));

  s_bsp_tx_data_count_bits <= std_logic_vector(to_unsigned(s_bsp_tx_data_count, C_BSP_DATA_LEN_BITSIZE));
  s_bsp_rx_data_count      <= to_integer(unsigned(s_bsp_rx_data_count_bits));

  INST_canola_bsp : entity work.canola_bsp
    port map (
      CLK                        => s_clk,
      RESET                      => s_reset,
      BSP_TX_DATA                => s_bsp_tx_data,
      BSP_TX_DATA_COUNT          => s_bsp_tx_data_count_bits,
      BSP_TX_WRITE_EN            => s_bsp_tx_write_en,
      BSP_TX_BIT_STUFF_EN        => s_bsp_tx_bit_stuff_en,
      BSP_TX_RX_MISMATCH         => s_bsp_tx_rx_mismatch,
      BSP_TX_RX_STUFF_MISMATCH   => s_bsp_tx_rx_stuff_mismatch,
      BSP_TX_DONE                => s_bsp_tx_done,
      BSP_TX_CRC_CALC_O          => s_bsp_tx_crc_calc,
      BSP_TX_ACTIVE              => s_bsp_tx_active,
      BSP_RX_ACTIVE              => s_bsp_rx_active,
      BSP_RX_IFS                 => s_bsp_rx_ifs,
      BSP_RX_DATA                => s_bsp_rx_data,
      BSP_RX_DATA_COUNT          => s_bsp_rx_data_count_bits,
      BSP_RX_DATA_CLEAR          => s_bsp_rx_data_clear,
      BSP_RX_DATA_OVERFLOW       => s_bsp_rx_data_overflow,
      BSP_RX_BIT_DESTUFF_EN      => s_bsp_rx_bit_destuff_en,
      BSP_RX_STOP                => s_bsp_rx_stop,
      BSP_RX_CRC_CALC_O          => s_bsp_rx_crc_calc,
      BSP_RX_SEND_ACK            => s_bsp_rx_send_ack,
      BSP_RX_ACTIVE_ERROR_FLAG   => s_bsp_rx_active_error_flag,
      BSP_RX_PASSIVE_ERROR_FLAG  => s_bsp_rx_passive_error_flag,
      BSP_SEND_ERROR_FLAG        => s_bsp_send_error_flag,
      EML_RECV_11_RECESSIVE_BITS => s_eml_recv_11_recessive_bits,
      EML_ERROR_STATE            => s_eml_error_state_bits,
      BTL_TX_BIT_VALUE           => s_btl_tx_bit_value,
      BTL_TX_BIT_VALID           => s_btl_tx_bit_valid,
      BTL_TX_RDY                 => s_btl_tx_rdy,
      BTL_TX_DONE                => s_btl_tx_done,
      BTL_RX_BIT_VALUE           => s_btl_rx_bit_value,
      BTL_RX_BIT_VALID           => s_btl_rx_bit_valid,
      BTL_RX_SYNCED              => s_btl_rx_synced,
      BTL_RX_STOP                => s_btl_rx_stop,
      RX_FSM_STATE_O             => s_bsp_rx_fsm_state,
      RX_FSM_STATE_VOTED_I       => s_bsp_rx_fsm_state,
      TX_FSM_STATE_O             => s_bsp_tx_fsm_state,
      TX_FSM_STATE_VOTED_I       => s_bsp_tx_fsm_state,
      BSP_TX_CRC_CALC_VOTED_I    => s_bsp_tx_crc_calc,
      BSP_RX_CRC_CALC_VOTED_I    => s_bsp_rx_crc_calc);

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
      BTL_TX_DONE             => s_btl_tx_done,
      BTL_TX_ACTIVE           => s_bsp_tx_active,
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

  -- Detect if BSP_TX_RX_MISMATCH or BSP_TX_RX_STUFF_MISMATCH goes high
  p_rx_tx_mismatch_detect: process (s_clk) is
  begin
    if rising_edge(s_clk) then
      if s_rx_tx_mismatch_rst then
        s_got_rx_tx_mismatch       <= '0';
        s_got_rx_tx_stuff_mismatch <= '0';
      end if;
    else
      if s_bsp_tx_rx_mismatch = '1' then
        s_got_rx_tx_mismatch <= '1';
      end if;

      if s_bsp_tx_rx_stuff_mismatch = '1' then
        s_got_rx_tx_stuff_mismatch <= '1';
      end if;
    end if;
  end process p_rx_tx_mismatch_detect;


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


    -- purpose: Reset Rx CRC and data outputs
    procedure reset_rx_bsp_crc_and_data is
    begin
      wait until rising_edge(s_clk);
      s_bsp_tx_active     <= '0';
      s_bsp_rx_data_clear <= '1';
      wait until rising_edge(s_clk);
      s_bsp_rx_data_clear <= '0';
      wait until rising_edge(s_clk);
    end procedure reset_rx_bsp_crc_and_data;

    variable seed1         : positive := 53267458;
    variable seed2         : positive := 90832486;
    variable v_count       : natural;
    variable v_test_num    : natural;
    variable v_data_length : natural;

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    set_log_file_name("log/canola_bsp_tb_log.txt");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Start simulation of Bit Stream Processor (BSP) for CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------

    s_clock_ena <= true;                -- to start clock generator
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test sending random sequence without bit stuffing", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_frame_size(v_data_length, C_BSP_DATA_LENGTH, seed1, seed2);
      generate_random_data_for_btl(s_bsp_tx_data, v_data_length, seed1, seed2);

      log(ID_SEQUENCER,
          "Iteration " & to_string(v_test_num) & ", " & to_string(v_data_length) & " bits.",
          C_SCOPE);

      s_crc_exp <= calc_can_crc15(s_bsp_tx_data(0 to v_data_length-1));

      reset_rx_bsp_crc_and_data;

      wait until rising_edge(s_clk);
      s_bsp_tx_active         <= '0';
      wait until rising_edge(s_clk);
      s_bsp_tx_active         <= '1';
      wait until rising_edge(s_clk);
      s_bsp_tx_data_count     <= v_data_length;
      s_bsp_tx_bit_stuff_en   <= '0';
      s_bsp_rx_bit_destuff_en <= '0';
      s_bsp_tx_write_en       <= '1';
      s_rx_tx_mismatch_rst    <= '1';

      wait until rising_edge(s_clk);
      s_bsp_tx_write_en    <= '0';
      s_rx_tx_mismatch_rst <= '0';

      wait until s_bsp_tx_done = '1'
        for (v_data_length+10)*C_CAN_BAUD_PERIOD;

      check_value(s_bsp_tx_done, '1', error, "Check that Tx is done.");

      wait until s_bsp_rx_data_count = v_data_length
        for C_CAN_BAUD_PERIOD;

      check_value(s_got_rx_tx_mismatch, '0', error, "Check if there was Rx/Tx mismatch.");
      check_value(s_got_rx_tx_stuff_mismatch, '0', error, "Check if there was Rx/Tx bit stuff mismatch.");

      check_value(s_bsp_rx_data_count, v_data_length, error, "Check number of bits received.");
      check_value(s_bsp_rx_data(0 to v_data_length-1),
                  s_bsp_tx_data(0 to v_data_length-1),
                  error, "Verify that BSP received same data that it transmitted.");
      check_value(s_bsp_tx_crc_calc, s_crc_exp, error, "Check that BSP Tx CRC matches expected");
      check_value(s_bsp_rx_crc_calc, s_crc_exp, error, "Check that BSP Rx CRC matches expected");

      s_bsp_tx_active <= '0';
      s_bsp_rx_stop   <= '1';
      wait until rising_edge(s_clk);
      s_bsp_rx_stop   <= '0';
      wait until rising_edge(s_clk);

      wait until s_bsp_rx_ifs = '0' for C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_ifs, '1', error, "Check that BSP is waiting for Inter Frame Space (IFS)");

      wait until s_bsp_rx_ifs = '0' for C_IFS_LENGTH*C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_ifs, '0', error, "Check that BSP is done waiting for Inter Frame Space (IFS)");

      v_test_num := v_test_num + 1;
    end loop;



    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test sending random sequence with bit stuffing", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_frame_size(v_data_length, C_BSP_DATA_LENGTH, seed1, seed2);
      generate_random_data_for_btl(s_rand_bsp_data, v_data_length, seed1, seed2);

      log(ID_SEQUENCER,
          "Iteration " & to_string(v_test_num) & ", " & to_string(v_data_length) & " bits.",
          C_SCOPE);

      s_crc_exp <= calc_can_crc15(s_rand_bsp_data(0 to v_data_length-1));

      -- The random data generated by generate_random_data_for_btl contains
      -- the 7 EOF bits at the end. We'll send the data before EOF first
      -- with stuffing enabled, and then we send the EOF bits with stuffing
      -- disabled.
      s_bsp_tx_data(0 to v_data_length-(1+work.canola_pkg.C_EOF_LENGTH)) <=
        s_rand_bsp_data(0 to v_data_length-(1+work.canola_pkg.C_EOF_LENGTH));

      reset_rx_bsp_crc_and_data;

      wait until rising_edge(s_clk);
      s_bsp_tx_active         <= '0';
      wait until rising_edge(s_clk);
      s_bsp_tx_active         <= '1';
      wait until rising_edge(s_clk);
      s_bsp_tx_data_count     <= v_data_length-work.canola_pkg.C_EOF_LENGTH;
      s_bsp_tx_bit_stuff_en   <= '1';
      s_bsp_rx_bit_destuff_en <= '1';
      s_bsp_tx_write_en       <= '1';
      s_rx_tx_mismatch_rst    <= '1';

      wait until rising_edge(s_clk);
      s_bsp_tx_write_en    <= '0';
      s_rx_tx_mismatch_rst <= '0';

      wait until s_bsp_tx_done = '1'
        for (v_data_length+10)*C_CAN_BAUD_PERIOD;

      check_value(s_bsp_tx_done, '1', error, "Check that Tx is done.");

      wait until s_bsp_rx_data_count = s_bsp_tx_data_count
        for C_CAN_BAUD_PERIOD;

      check_value(s_bsp_rx_data_count, s_bsp_tx_data_count, error, "Check number of bits received.");

      wait until rising_edge(s_clk);
      -- Setup EOF bits, and send them without bit stuffing
      s_bsp_tx_data(0 to work.canola_pkg.C_EOF_LENGTH-1) <= (others => C_EOF_VALUE);
      s_bsp_tx_data_count                                <= work.canola_pkg.C_EOF_LENGTH;
      s_bsp_tx_write_en                                  <= '1';

      -- Disable bit stuffing on EOF bits
      s_bsp_tx_bit_stuff_en   <= '0';
      s_bsp_rx_bit_destuff_en <= '0';

      wait until rising_edge(s_clk);
      s_bsp_tx_write_en    <= '0';

      wait until s_bsp_tx_done = '1'
        for (v_data_length+10)*C_CAN_BAUD_PERIOD;

      check_value(s_bsp_tx_done, '1', error, "Check that Tx is done.");

      wait until s_bsp_rx_data_count = v_data_length
        for C_CAN_BAUD_PERIOD;



      check_value(s_got_rx_tx_mismatch, '0', error, "Check if there was Rx/Tx mismatch.");
      check_value(s_got_rx_tx_stuff_mismatch, '0', error, "Check if there was Rx/Tx bit stuff mismatch.");

      check_value(s_bsp_rx_data_count, v_data_length, error, "Check number of bits received.");
      check_value(s_bsp_rx_data(0 to v_data_length-1),
                  s_rand_bsp_data(0 to v_data_length-1),
                  error, "Verify that BSP received same data that it transmitted.");
      check_value(s_bsp_tx_crc_calc, s_crc_exp, error, "Check that BSP Tx CRC matches expected");
      check_value(s_bsp_rx_crc_calc, s_crc_exp, error, "Check that BSP Rx CRC matches expected");

      s_bsp_tx_active <= '0';
      s_bsp_rx_stop   <= '1';
      wait until rising_edge(s_clk);
      s_bsp_rx_stop   <= '0';
      wait until rising_edge(s_clk);

      wait until s_bsp_rx_ifs = '0' for C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_ifs, '1', error, "Check that BSP is waiting for Inter Frame Space (IFS)");

      wait until s_bsp_rx_ifs = '0' for C_IFS_LENGTH*C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_ifs, '0', error, "Check that BSP is done waiting for Inter Frame Space (IFS)");

      v_test_num := v_test_num + 1;
    end loop;


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test sending ACK", C_SCOPE);
    -----------------------------------------------------------------------------------------------

    -- This test is a bit "artificial", it only sends the ACK pulse and checks
    -- that it is received. Preferably the test should have been done with an
    -- ACK inside a CAN frame.

    v_test_num := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      reset_rx_bsp_crc_and_data;

      s_crc_exp <= calc_can_crc15(C_ACK_TEST_SEQUENCE_EXP);

      wait until rising_edge(s_clk);
      s_bsp_tx_active      <= '0';
      s_bsp_tx_write_en    <= '0';
      s_rx_tx_mismatch_rst <= '0';

      -- Wait for a few baud periods
      wait for 10*C_CAN_BAUD_PERIOD;

      wait until rising_edge(s_clk);
      s_bsp_rx_send_ack <= '1';

      wait until rising_edge(s_clk);
      s_bsp_rx_send_ack <= '0';

      wait until s_btl_tx_done = '1'
        for C_CAN_BAUD_PERIOD;
      check_value(s_btl_tx_done, '1', error, "Check that BTL has processed bit.");

      wait until s_bsp_rx_data_count > 0
        for C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_active, '1', error, "Check that Rx went active due to low ack pulse.");
      check_value(s_bsp_rx_data_count, 1, error, "Check that one bit was received.");
      check_value(s_bsp_rx_data(0), '0', error, "Check that low value (ACK) was received.");

      -- Wait for a few baud periods
      wait for 10*C_CAN_BAUD_PERIOD;

      -- Clear and stop Rx
      s_bsp_rx_stop       <= '1';
      s_bsp_rx_data_clear <= '1';
      wait until rising_edge(s_clk);
      s_bsp_rx_stop       <= '0';
      s_bsp_rx_data_clear <= '0';
      wait until rising_edge(s_clk);

      wait until s_bsp_rx_ifs = '0' for C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_ifs, '1', error, "Check that BSP is waiting for Inter Frame Space (IFS)");

      wait until s_bsp_rx_ifs = '0' for C_IFS_LENGTH*C_CAN_BAUD_PERIOD;
      check_value(s_bsp_rx_ifs, '0', error, "Check that BSP is done waiting for Inter Frame Space (IFS)");

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
