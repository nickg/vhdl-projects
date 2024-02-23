-------------------------------------------------------------------------------
-- Title      : Testbench to test Canola vs OpenCores CAN Controllers
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_vs_opencores_can_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    : Western Norway University of Applied Sciences
-- Created    : 2020-01-06
-- Last update: 2020-09-18
-- Platform   :
-- Target     :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Testbench to test communication between Canola CAN controller
--              and the controller available on opencores.com
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2020-01-06  1.0      svn                     Created
-------------------------------------------------------------------------------

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.wishbone_bfm_pkg.all;

library work;
use work.canola_pkg.all;
use work.canola_tb_pkg.all;
use work.can_bfm_pkg.all;
use work.can_uvvm_bfm_pkg.all;
use work.can_register_pkg.all; -- OpenCores controller registers

-- test bench entity
entity canola_vs_opencores_can_tb is
end canola_vs_opencores_can_tb;

architecture tb of canola_vs_opencores_can_tb is

  constant C_CLK_PERIOD : time    := 6.25 ns;  -- 160 Mhz
  constant C_CLK_FREQ   : integer := 1e9 ns / C_CLK_PERIOD;
  signal s_clk_period   : time    := C_CLK_PERIOD;

  constant WB_DATA_WIDTH : natural := 8;
  constant WB_ADDR_WIDTH : natural := 8;

  constant C_WB_CFG : t_wishbone_bfm_config := (
    max_wait_cycles          => 20,
    max_wait_cycles_severity => failure,
    clock_period             => C_CLK_PERIOD,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => 1 ns,
    hold_time                => 1 ns,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL);

  constant C_CAN_BAUD_PERIOD_250kbit  : time    := 4000 ns;  -- 250 kHz
  constant C_CAN_BAUD_FREQ_250kbit    : integer := 1e9 ns / C_CAN_BAUD_PERIOD_250kbit;

  constant C_CAN_BAUD_PERIOD_1000kbit  : time    := 1000 ns;  -- 250 kHz
  constant C_CAN_BAUD_FREQ_1000kbit    : integer := 1e9 ns / C_CAN_BAUD_PERIOD_1000kbit;

  signal s_can_baud_period : time    := C_CAN_BAUD_PERIOD_1000kbit;
  signal s_can_baud_freq   : integer := C_CAN_BAUD_FREQ_1000kbit;

  signal s_can_ctrl1_to_ctrl2_delay : time := 0 ns;

  -- Indicates where in a bit the Rx sample point should be
  -- Real value from 0.0 to 1.0.
  constant C_CAN_SAMPLE_POINT : real    := 0.7;

  constant C_TIME_QUANTA_CLOCK_SCALE_250kbit  : natural := 63;
  constant C_TIME_QUANTA_CLOCK_SCALE_1000kbit : natural := 15;
  constant C_TIME_QUANTA_CLOCK_SCALE_WIDTH    : natural := integer(ceil(log2(1.0+real(C_TIME_QUANTA_CLOCK_SCALE_250kbit))));

  constant C_DATA_LENGTH_MAX : natural := 1000;
  constant C_NUM_ITERATIONS  : natural := 1000;

  constant C_COUNTER_WIDTH : natural := 16;

  -- Generate a clock with a period that may change.
  -- Based on clock_gen from Bitvis IRQC testbench
  procedure clock_gen(
    signal clock_signal : inout std_logic;
    signal clock_ena    : in    boolean;
    signal clock_period : in    time
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

  ------------------------------------------------------------------------------
  -- Signals for CAN controller #1
  ------------------------------------------------------------------------------
  signal s_can_ctrl1_reset            : std_logic;
  signal s_can_ctrl1_tx               : std_logic;
  signal s_can_ctrl1_rx               : std_logic;
  signal s_can_ctrl1_rx_msg           : can_msg_t;
  signal s_can_ctrl1_tx_msg           : can_msg_t;
  signal s_can_ctrl1_rx_msg_valid     : std_logic;
  signal s_can_ctrl1_tx_start         : std_logic := '0';
  signal s_can_ctrl1_tx_retransmit_en : std_logic := '0';
  signal s_can_ctrl1_tx_busy          : std_logic;
  signal s_can_ctrl1_tx_done          : std_logic;
  signal s_can_ctrl1_tx_failed        : std_logic;

  signal s_can_ctrl1_prop_seg        : std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0)   := "0111";
  signal s_can_ctrl1_phase_seg1      : std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0) := "0111";
  signal s_can_ctrl1_phase_seg2      : std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0) := "0111";

  signal s_can_ctrl1_clk_scale       : unsigned(C_TIME_QUANTA_CLOCK_SCALE_WIDTH-1 downto 0);
  signal s_can_ctrl1_sync_jump_width : unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0)
    := to_unsigned(2, C_SYNC_JUMP_WIDTH_BITSIZE);

  signal s_can_ctrl1_transmit_error_count : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_can_ctrl1_receive_error_count  : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_can_ctrl1_error_state          : can_error_state_t;

  -- Count up signals
  signal s_can_ctrl1_tx_msg_sent_count_up    : std_logic;
  signal s_can_ctrl1_tx_failed_count_up      : std_logic;
  signal s_can_ctrl1_tx_ack_error_count_up   : std_logic;
  signal s_can_ctrl1_tx_arb_lost_count_up    : std_logic;
  signal s_can_ctrl1_tx_bit_error_count_up   : std_logic;
  signal s_can_ctrl1_tx_retransmit_count_up  : std_logic;
  signal s_can_ctrl1_rx_msg_recv_count_up    : std_logic;
  signal s_can_ctrl1_rx_crc_error_count_up   : std_logic;
  signal s_can_ctrl1_rx_form_error_count_up  : std_logic;
  signal s_can_ctrl1_rx_stuff_error_count_up : std_logic;

  -- Counters
  signal s_can_ctrl1_reg_tx_msg_sent_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_tx_failed_count      : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_tx_ack_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_tx_arb_lost_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_tx_bit_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_tx_retransmit_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_rx_msg_recv_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_rx_crc_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_rx_form_error_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl1_reg_rx_stuff_error_count : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);

  ------------------------------------------------------------------------------
  -- Signals for OpenCores CAN controller
  ------------------------------------------------------------------------------
  signal wbm_opcores_can_if : t_wishbone_if (dat_o(WB_DATA_WIDTH-1 downto 0), adr_o(WB_ADDR_WIDTH-1 downto 0),
                                             dat_i(WB_DATA_WIDTH-1 downto 0)) := init_wishbone_if_signals(8, 8);

  signal s_opcores_can_out        : std_logic;
  signal s_opcores_can_rx         : std_logic := '0';
  signal s_opcores_can_tx         : std_logic := '0';
  signal s_opcores_can_bus_off_on : std_logic := '1';
  signal s_opcores_can_irq_n      : std_logic := '0';
  signal s_opcores_can_reset      : std_logic := '0';

  ------------------------------------------------------------------------------
  -- Other signals
  ------------------------------------------------------------------------------
  signal s_clock_ena    : boolean   := false;
  signal s_can_baud_clk : std_logic := '0';
  signal s_clk          : std_logic := '0';

  -- CAN signals used by BFM
  signal s_can_bfm_tx        : std_logic                      := '1';
  signal s_can_bfm_rx        : std_logic                      := '1';

  -- Shared CAN bus signals accounting for cable delays between controllers
  signal s_can_bus_signal1    : std_logic; -- At controller #1 and BFM
  signal s_can_bus_signal2    : std_logic; -- At controller #2

  -- Used by p_can_ctrl_rx_msg which monitors
  -- when the CAN controller receives a message
  signal s_msg_ctrl1_received : std_logic := '0';
  signal s_msg_reset          : std_logic := '0';
  signal s_msg_ctrl1          : can_msg_t;


begin

  -- Set up clock generators
  clock_gen(s_clk, s_clock_ena, s_clk_period);
  clock_gen(s_can_baud_clk, s_clock_ena, s_can_baud_period);

  s_can_ctrl1_to_ctrl2_delay <= 0.5*(s_can_baud_period/10);

  -- Bus signal at controller 1 and BFM
  s_can_bus_signal1 <= 'H';
  s_can_bus_signal1 <= '0' when s_can_ctrl1_tx = '0' else 'Z';
  s_can_bus_signal1 <= transport '0' after s_can_ctrl1_to_ctrl2_delay when s_opcores_can_tx = '0'
                       else 'Z' after s_can_ctrl1_to_ctrl2_delay;
  s_can_bus_signal1 <= '0' when s_can_bfm_tx  = '0' else 'Z';
  s_can_ctrl1_rx    <= '1' ?= s_can_bus_signal1;
  s_can_bfm_rx      <= '1' ?= s_can_bus_signal1;

  -- Bus signal at controller 2 (open cores)
  s_can_bus_signal2 <= 'H';
  s_can_bus_signal2 <= '0' when s_opcores_can_tx  = '0' else 'Z';
  s_can_bus_signal2 <= transport '0' after s_can_ctrl1_to_ctrl2_delay when s_can_ctrl1_tx  = '0' else 'Z';
  s_can_bus_signal2 <= transport '0' after s_can_ctrl1_to_ctrl2_delay when s_can_bfm_tx    = '0' else 'Z';
  s_opcores_can_rx       <= '1' ?= s_can_bus_signal2;

  INST_canola_top_1 : entity work.canola_top
    generic map (
      G_TIME_QUANTA_SCALE_WIDTH => C_TIME_QUANTA_CLOCK_SCALE_WIDTH)
    port map (
      CLK   => s_clk,
      RESET => s_can_ctrl1_reset,

      -- CAN bus interface signals
      CAN_TX => s_can_ctrl1_tx,
      CAN_RX => s_can_ctrl1_rx,

      -- Rx interface
      RX_MSG       => s_can_ctrl1_rx_msg,
      RX_MSG_VALID => s_can_ctrl1_rx_msg_valid,

      -- Tx interface
      TX_MSG           => s_can_ctrl1_tx_msg,
      TX_START         => s_can_ctrl1_tx_start,
      TX_RETRANSMIT_EN => s_can_ctrl1_tx_retransmit_en,
      TX_BUSY          => s_can_ctrl1_tx_busy,
      TX_DONE          => s_can_ctrl1_tx_done,
      TX_FAILED        => s_can_ctrl1_tx_failed,

      BTL_TRIPLE_SAMPLING         => '0',
      BTL_PROP_SEG                => s_can_ctrl1_prop_seg,
      BTL_PHASE_SEG1              => s_can_ctrl1_phase_seg1,
      BTL_PHASE_SEG2              => s_can_ctrl1_phase_seg2,
      BTL_SYNC_JUMP_WIDTH         => s_can_ctrl1_sync_jump_width,

      TIME_QUANTA_CLOCK_SCALE     => s_can_ctrl1_clk_scale,

      -- Error state and counters
      TRANSMIT_ERROR_COUNT => s_can_ctrl1_transmit_error_count,
      RECEIVE_ERROR_COUNT  => s_can_ctrl1_receive_error_count,
      ERROR_STATE          => s_can_ctrl1_error_state,

      -- Counter signals
      TX_MSG_SENT_COUNT_UP    => s_can_ctrl1_tx_msg_sent_count_up,
      TX_FAILED_COUNT_UP      => s_can_ctrl1_tx_failed_count_up,
      TX_ACK_ERROR_COUNT_UP   => s_can_ctrl1_tx_ack_error_count_up,
      TX_ARB_LOST_COUNT_UP    => s_can_ctrl1_tx_arb_lost_count_up,
      TX_BIT_ERROR_COUNT_UP   => s_can_ctrl1_tx_bit_error_count_up,
      TX_RETRANSMIT_COUNT_UP  => s_can_ctrl1_tx_retransmit_count_up,
      RX_MSG_RECV_COUNT_UP    => s_can_ctrl1_rx_msg_recv_count_up,
      RX_CRC_ERROR_COUNT_UP   => s_can_ctrl1_rx_crc_error_count_up,
      RX_FORM_ERROR_COUNT_UP  => s_can_ctrl1_rx_form_error_count_up,
      RX_STUFF_ERROR_COUNT_UP => s_can_ctrl1_rx_stuff_error_count_up
      );

  INST_canola_counters_1 : entity work.canola_counters
    generic map (
      G_COUNTER_WIDTH       => C_COUNTER_WIDTH,
      G_SATURATING_COUNTERS => true)
    port map (
      CLK   => s_clk,
      RESET => s_can_ctrl1_reset,

      CLEAR_TX_MSG_SENT_COUNT    => '0',
      CLEAR_TX_FAILED_COUNT      => '0',
      CLEAR_TX_ACK_ERROR_COUNT   => '0',
      CLEAR_TX_ARB_LOST_COUNT    => '0',
      CLEAR_TX_BIT_ERROR_COUNT   => '0',
      CLEAR_TX_RETRANSMIT_COUNT  => '0',
      CLEAR_RX_MSG_RECV_COUNT    => '0',
      CLEAR_RX_CRC_ERROR_COUNT   => '0',
      CLEAR_RX_FORM_ERROR_COUNT  => '0',
      CLEAR_RX_STUFF_ERROR_COUNT => '0',

      TX_MSG_SENT_COUNT_UP    => s_can_ctrl1_tx_msg_sent_count_up,
      TX_FAILED_COUNT_UP      => s_can_ctrl1_tx_failed_count_up,
      TX_ACK_ERROR_COUNT_UP   => s_can_ctrl1_tx_ack_error_count_up,
      TX_ARB_LOST_COUNT_UP    => s_can_ctrl1_tx_arb_lost_count_up,
      TX_BIT_ERROR_COUNT_UP   => s_can_ctrl1_tx_bit_error_count_up,
      TX_RETRANSMIT_COUNT_UP  => s_can_ctrl1_tx_retransmit_count_up,
      RX_MSG_RECV_COUNT_UP    => s_can_ctrl1_rx_msg_recv_count_up,
      RX_CRC_ERROR_COUNT_UP   => s_can_ctrl1_rx_crc_error_count_up,
      RX_FORM_ERROR_COUNT_UP  => s_can_ctrl1_rx_form_error_count_up,
      RX_STUFF_ERROR_COUNT_UP => s_can_ctrl1_rx_stuff_error_count_up,

      TX_MSG_SENT_COUNT_VALUE    => s_can_ctrl1_reg_tx_msg_sent_count,
      TX_FAILED_COUNT_VALUE      => s_can_ctrl1_reg_tx_failed_count,
      TX_ACK_ERROR_COUNT_VALUE   => s_can_ctrl1_reg_tx_ack_error_count,
      TX_ARB_LOST_COUNT_VALUE    => s_can_ctrl1_reg_tx_arb_lost_count,
      TX_BIT_ERROR_COUNT_VALUE   => s_can_ctrl1_reg_tx_bit_error_count,
      TX_RETRANSMIT_COUNT_VALUE  => s_can_ctrl1_reg_tx_retransmit_count,
      RX_MSG_RECV_COUNT_VALUE    => s_can_ctrl1_reg_rx_msg_recv_count,
      RX_CRC_ERROR_COUNT_VALUE   => s_can_ctrl1_reg_rx_crc_error_count,
      RX_FORM_ERROR_COUNT_VALUE  => s_can_ctrl1_reg_rx_form_error_count,
      RX_STUFF_ERROR_COUNT_VALUE => s_can_ctrl1_reg_rx_stuff_error_count
      );

  INST_opencores_can : entity work.can_top
    port map
    (
      clk_i      => s_clk,
      rx_i       => s_opcores_can_rx,
      tx_o       => s_opcores_can_tx,
      bus_off_on => s_opcores_can_bus_off_on,
      irq_on     => s_opcores_can_irq_n,
      clkout_o   => open,
      wb_clk_i   => s_clk,
      wb_rst_i   => s_opcores_can_reset,
      wb_dat_i   => wbm_opcores_can_if.dat_o,
      wb_dat_o   => wbm_opcores_can_if.dat_i,
      wb_cyc_i   => wbm_opcores_can_if.cyc_o,
      wb_stb_i   => wbm_opcores_can_if.stb_o,
      wb_we_i    => wbm_opcores_can_if.we_o,
      wb_adr_i   => wbm_opcores_can_if.adr_o,
      wb_ack_o   => wbm_opcores_can_if.ack_i
      );


  -- Monitor CAN controller and indicate when it has received a message (rx_msg_valid is pulsed)
  p_can_ctrl_rx_msg: process (s_can_ctrl1_rx_msg_valid, s_msg_reset) is
  begin
    if s_msg_reset = '1' then
      s_msg_ctrl1_received <= '0';
    else
      if s_can_ctrl1_rx_msg_valid = '1' then
        s_msg_ctrl1_received <= '1';
        s_msg_ctrl1          <= s_can_ctrl1_rx_msg;
      end if;
    end if;
  end process p_can_ctrl_rx_msg;


  p_main: process
    constant C_SCOPE          : string                := C_TB_SCOPE_DEFAULT;
    variable v_can_bfm_config : t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;

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

    variable seed1         : positive := 53267458;
    variable seed2         : positive := 90832486;
    variable v_count       : natural;
    variable v_test_num    : natural;
    variable v_data_length : natural;

    -- Todo 1: Put this in a package file?
    -- Todo 2: Define one message type for use both with BFM and RTL code,
    --         and define can_payload_t in one place..
    procedure generate_random_can_message (
      variable arb_id             : out std_logic_vector(28 downto 0);
      variable data               : out work.can_bfm_pkg.can_payload_t;
      variable data_length        : out natural;
      variable remote_frame       : out std_logic;
      constant extended_id        : in  std_logic := '0';
      constant allow_remote_frame : in  std_logic := '1'
      ) is
      variable rand_real : real;
      variable rand_id   : natural;
      variable rand_byte : natural;
    begin
      uniform(seed1, seed2, rand_real);
      data_length := natural(round(rand_real * real(8)));

      uniform(seed1, seed2, rand_real);
      if rand_real > 0.5 and allow_remote_frame = '1' then
        remote_frame := '1';
      else
        remote_frame := '0';
      end if;

      uniform(seed1, seed2, rand_real);
      if extended_id = '1' then
        rand_id             := natural(round(rand_real * real(2**29-1)));
        arb_id(28 downto 0) := std_logic_vector(to_unsigned(rand_id, 29));
      else
        rand_id              := natural(round(rand_real * real(2**11-1)));
        arb_id               := (others => '0');
        arb_id(28 downto 18) := std_logic_vector(to_unsigned(rand_id, 11));
      end if;

      if remote_frame = '0' then
        for byte_num in 0 to 7 loop
          if byte_num < data_length then
            uniform(seed1, seed2, rand_real);
            rand_byte      := natural(round(rand_real * real(255)));
            data(byte_num) := std_logic_vector(to_unsigned(rand_byte, 8));
          else
            data(byte_num) := x"00";
          end if;
        end loop;  -- byte_num
      end if;

    end procedure generate_random_can_message;

    ---------------------------------------------------------------------------
    -- Procedures for wb_bfm
    ---------------------------------------------------------------------------
    procedure wb_check (
      constant addr_value   : in    natural;
      constant data_exp     : in    std_logic_vector;
      constant alert_level  : in    t_alert_level         := error;
      constant msg          : in    string;
      signal wb_if          : inout t_wishbone_if;
      constant scope        : in    string                := C_SCOPE;
      constant msg_id_panel : in    t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in    t_wishbone_bfm_config := C_WB_CFG
      ) is
    begin
      wishbone_check(to_unsigned(addr_value, WB_ADDR_WIDTH), data_exp, msg, s_clk, wb_if, alert_level, scope, msg_id_panel, config);
      -- Wait a clock cycle before next transaction
      wait until rising_edge(s_clk);
    end procedure wb_check;

    procedure wb_write (
      constant addr_value   : in    natural;
      constant data_value   : in    std_logic_vector;
      constant msg          : in    string;
      signal wb_if          : inout t_wishbone_if;
      constant scope        : in    string                := C_SCOPE;
      constant msg_id_panel : in    t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in    t_wishbone_bfm_config := C_WB_CFG
      ) is
    begin
      wishbone_write(to_unsigned(addr_value, WB_ADDR_WIDTH), data_value, msg, s_clk, wb_if, scope, msg_id_panel, config);
      -- Wait a clock cycle before next transaction
      wait until rising_edge(s_clk);
    end procedure wb_write;

    procedure wb_read (
      constant addr_value   : in    natural;
      variable data_value   : out   std_logic_vector;
      constant msg          : in    string;
      signal wb_if          : inout t_wishbone_if;
      constant scope        : in    string                := C_SCOPE;
      constant msg_id_panel : in    t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in    t_wishbone_bfm_config := C_WB_CFG
      ) is
    begin
      wishbone_read(to_unsigned(addr_value, WB_ADDR_WIDTH), data_value, msg, s_clk, wb_if, scope, msg_id_panel, config);
      -- Wait a clock cycle before next transaction
      wait until rising_edge(s_clk);
    end procedure wb_read;

    procedure can_ctrl_enable_basic_mode_operation (
      constant acceptance_code : in std_logic_vector(7 downto 0);
      constant acceptance_mask : in std_logic_vector(7 downto 0);
      constant baud_freq       : in natural)
    is
      -- Using 10 quantas per baud
      constant clk_scale    : natural := (C_CLK_FREQ/(20*baud_freq))-1;
      variable v_btr0_value : std_logic_vector(7 downto 0);
    begin
      -- First two bits: max sync jump width
      -- Last six bits: clock scale
      v_btr0_value := "00" & std_logic_vector(to_unsigned(clk_scale, 6));

      log(ID_LOG_HDR, "Check that CAN controller is in RESET mode", C_SCOPE);
      ------------------------------------------------------------
      wb_check(C_CAN_CMR, x"FF", error, "Reading CMR should return FF in basic mode", wbm_opcores_can_if);
      wb_check(C_CAN_BM_CR, "001----1", error, "Check that reset request bit is set (reset mode)", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Setting up CAN controller acceptance code and mask", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BM_ACR, acceptance_code, "CAN acceptance code", wbm_opcores_can_if);
      wb_write(C_CAN_BM_AMR, acceptance_mask, "CAN acceptance mask", wbm_opcores_can_if);

      wb_check(C_CAN_BM_ACR, acceptance_code, error, "CAN acceptance code", wbm_opcores_can_if);
      wb_check(C_CAN_BM_AMR, acceptance_mask, error, "CAN acceptance mask", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Setting up CAN controller bus timing register for 1Mbps", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BTR0, v_btr0_value, "Set up baud prescale and use minimum synch jump width time", wbm_opcores_can_if);
      wb_write(C_CAN_BTR1, x"25", "7 baud clocks before and 3 after sampling point, tSEG1=6 and tSEG2=3", wbm_opcores_can_if);

      wb_check(C_CAN_BTR0, v_btr0_value, error, "Set up baud prescale and use minimum synch jump width time", wbm_opcores_can_if);
      wb_check(C_CAN_BTR1, x"25", error, "7 baud clocks before and 3 after sampling point, tSEG1=6 and tSEG2=3, for CAN0", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Configure CAN controller for Operation Mode", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BM_CR, "00111110", "Interrupts enabled, operation mode", wbm_opcores_can_if);
      wb_check(C_CAN_BM_CR, "00111110", error, "Interrupts enabled, operation mode", wbm_opcores_can_if);
    end procedure can_ctrl_enable_basic_mode_operation;


    procedure can_ctrl_enable_ext_mode_operation(
      constant acceptance_code : in std_logic_vector(28 downto 0);
      constant acceptance_mask : in std_logic_vector(28 downto 0);
      constant baud_freq       : in natural)
    is
      -- Using 10 quantas per baud
      constant clk_scale    : natural := (C_CLK_FREQ/(20*baud_freq))-1;
      variable v_btr0_value : std_logic_vector(7 downto 0);
    begin
      -- First two bits: max sync jump width
      -- Last six bits: clock scale
      v_btr0_value := "00" & std_logic_vector(to_unsigned(clk_scale, 6));

      log(ID_LOG_HDR, "Check that CAN controller is in RESET mode", C_SCOPE);
      ------------------------------------------------------------
      wb_check(C_CAN_CMR, x"FF", error, "Reading CMR should return FF (basic mode) after reset", wbm_opcores_can_if);
      wb_check(C_CAN_BM_CR, "001----1", error, "Check that reset request bit is set (reset mode)", wbm_opcores_can_if);

      log(ID_LOG_HDR, "Configure CAN controller for PeliCAN (ext) mode", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_CDR, x"80", "Set CAN mode bit", wbm_opcores_can_if);
      wb_check(C_CAN_CDR, x"80", error, "CAN mode bit", wbm_opcores_can_if);

      wb_check(C_CAN_CMR, x"00", error, "Reading CMR should return 00 in PeliCAN (ext) mode", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Setting up CAN controller acceptance code and mask", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_EM_ACR0, acceptance_code(28 downto 21), "Acceptance code 0", wbm_opcores_can_if);
      wb_write(C_CAN_EM_ACR1, acceptance_code(20 downto 13), "Acceptance code 1", wbm_opcores_can_if);
      wb_write(C_CAN_EM_ACR2, acceptance_code(12 downto 5),  "Acceptance code 2", wbm_opcores_can_if);
      -- Bit 2: RTR, Bit 1:0: Not used - Don't care about RTR, mask bit is set
      wb_write(C_CAN_EM_ACR3, acceptance_code(4 downto 0) & "000", "Acceptance code 3", wbm_opcores_can_if);

      wb_check(C_CAN_EM_ACR0, acceptance_code(28 downto 21), error, "Acceptance code 0", wbm_opcores_can_if);
      wb_check(C_CAN_EM_ACR1, acceptance_code(20 downto 13), error, "Acceptance code 1", wbm_opcores_can_if);
      wb_check(C_CAN_EM_ACR2, acceptance_code(12 downto 5),  error, "Acceptance code 2", wbm_opcores_can_if);
      wb_check(C_CAN_EM_ACR3, acceptance_code(4 downto 0) & "000", error, "Acceptance code 3", wbm_opcores_can_if);

      wb_write(C_CAN_EM_AMR0, acceptance_mask(28 downto 21), "Acceptance mask 0", wbm_opcores_can_if);
      wb_write(C_CAN_EM_AMR1, acceptance_mask(20 downto 13), "Acceptance mask 1", wbm_opcores_can_if);
      wb_write(C_CAN_EM_AMR2, acceptance_mask(12 downto 5),  "Acceptance mask 2", wbm_opcores_can_if);
      -- Bit 2: RTR, Bit 1:0: Not used - Mask bit hardcoded to accept any RTR
      wb_write(C_CAN_EM_AMR3, acceptance_mask(4 downto 0) & "100", "Acceptance mask 0", wbm_opcores_can_if);

      wb_check(C_CAN_EM_AMR0, acceptance_mask(28 downto 21), error, "Acceptance mask 0", wbm_opcores_can_if);
      wb_check(C_CAN_EM_AMR1, acceptance_mask(20 downto 13), error, "Acceptance mask 1", wbm_opcores_can_if);
      wb_check(C_CAN_EM_AMR2, acceptance_mask(12 downto 5),  error, "Acceptance mask 2", wbm_opcores_can_if);
      wb_check(C_CAN_EM_AMR3, acceptance_mask(4 downto 0) & "100", error, "Acceptance mask 0", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Setting up CAN controller bus timing register for 1Mbps", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BTR0, v_btr0_value, "Set up baud prescale and use minimum synch jump width time", wbm_opcores_can_if);
      wb_write(C_CAN_BTR1, x"25", "7 baud clocks before and 3 after sampling point, tSEG1=6 and tSEG2=3", wbm_opcores_can_if);

      wb_check(C_CAN_BTR0, v_btr0_value, error, "Set up baud prescale and use minimum synch jump width time", wbm_opcores_can_if);
      wb_check(C_CAN_BTR1, x"25", error, "7 baud clocks before and 3 after sampling point, tSEG1=6 and tSEG2=3, for CAN0", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Enable interrupts", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_EM_IER, x"FF", "Enable all interrupts", wbm_opcores_can_if);
      wb_check(C_CAN_EM_IER, x"FF", error, "all interrupts enabled", wbm_opcores_can_if);


      log(ID_LOG_HDR, "Configure CAN controller for Operation Mode", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_EM_MOD, x"00", "Bring controller out of reset mode", wbm_opcores_can_if);
      wb_check(C_CAN_EM_MOD, x"00", error, "Interrupts enabled, operation mode", wbm_opcores_can_if);
    end procedure can_ctrl_enable_ext_mode_operation;


    procedure can_ctrl_send_basic_mode (
      constant arb_id_a     : in std_logic_vector(10 downto 0);
      constant data         : in work.can_bfm_pkg.can_payload_t;
      constant data_length  : in natural;
      constant remote_frame : in std_logic;
      constant msg          : in string;
      constant timeout      : in time                  := 1 ms;
      constant scope        : in string                := C_SCOPE;
      constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
      variable proc_name    :    string                := "can_ctrl_send_basic_mode")
    is
      variable tx_id1      : std_logic_vector(7 downto 0);
      variable tx_id2      : std_logic_vector(7 downto 0);
      variable can_irq_reg : std_logic_vector(7 downto 0);
      variable v_proc_call : line;
    begin
      wb_read(C_CAN_IR, can_irq_reg, "Read out IR register to clear interrupts", wbm_opcores_can_if);

      -- Format procedure call string
      write(v_proc_call, to_string("can_ctrl_send_basic_mode(ID:"));
      write(v_proc_call, to_string(arb_id_a, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", Length:"));
      write(v_proc_call, to_string(data_length, 1));

      -- Format procedure call string for remote frame
      if remote_frame = '1' then
        write(v_proc_call, to_string(", RTR"));
      end if;

      tx_id1 := arb_id_a(10 downto 3);
      tx_id2 := arb_id_a(2 downto 0) & remote_frame & std_logic_vector(to_unsigned(data_length, 4));

      wb_write(C_CAN_BM_TXB_ID1, tx_id1, "Set TXID1", wbm_opcores_can_if);
      wb_write(C_CAN_BM_TXB_ID2, tx_id2, "Set TXID2", wbm_opcores_can_if);

      -- Write payload bytes to TX buffer and
      -- format procedure call string with data
      if remote_frame = '0' and data_length > 0 then
        write(v_proc_call, to_string(", Data:0x"));

        for byte_num in 0 to data_length-1 loop
          wb_write(C_CAN_BM_TXB_DATA1+byte_num,
                   data(byte_num),
                   "Write byte " & to_string(byte_num, 1) & " to TX buffer.",
                   wbm_opcores_can_if);

          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;
      write(v_proc_call, to_string(")"));

      wb_write(C_CAN_CMR, x"01", "Request transmission on CAN0", wbm_opcores_can_if);

      if proc_name = "can_ctrl_send_basic_mode" then
        log(config.id_for_bfm, v_proc_call.all & "=> completed. " & msg, scope, msg_id_panel);
      end if;
    end procedure can_ctrl_send_basic_mode;


    procedure can_ctrl_send_ext_mode (
      constant arb_id_a     : in std_logic_vector(10 downto 0);
      constant arb_id_b     : in std_logic_vector(17 downto 0);
      constant data         : in work.can_bfm_pkg.can_payload_t;
      constant data_length  : in natural;
      constant remote_frame : in std_logic;
      constant msg          : in string;
      constant timeout      : in time                  := 1 ms;
      constant scope        : in string                := C_SCOPE;
      constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
      variable proc_name    :    string                := "can_ctrl_send_ext_mode")
    is
      variable tx_id1          : std_logic_vector(7 downto 0);
      variable tx_id2          : std_logic_vector(7 downto 0);
      variable tx_id3          : std_logic_vector(7 downto 0);
      variable tx_id4          : std_logic_vector(7 downto 0);
      variable tx_frame_format : std_logic_vector(7 downto 0);
      variable can_irq_reg     : std_logic_vector(7 downto 0);
      variable v_proc_call     : line;
    begin

      wb_read(C_CAN_IR, can_irq_reg, "Read out IR register to clear interrupts", wbm_opcores_can_if);

      -- Format procedure call string
      write(v_proc_call, to_string("can_ctrl_send_ext_mode(ID A:"));
      write(v_proc_call, to_string(arb_id_a, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", ID B:"));
      write(v_proc_call, to_string(arb_id_b, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", Length:"));
      write(v_proc_call, to_string(data_length, 1));

      -- Format procedure call string for remote frame
      if remote_frame = '1' then
        write(v_proc_call, to_string(", RTR"));
      end if;

      tx_id1 := arb_id_a(10 downto 3);
      tx_id2 := arb_id_a(2 downto 0) & arb_id_b(17 downto 13);
      tx_id3 := arb_id_b(12 downto 5);
      tx_id4 := arb_id_b(4 downto 0) & "000"; -- Last 3 bits: don't care

      -- Tx Frame Information register:
      -- Bit 7: Frame Format (FF): 1=ext, 0=base
      -- Bit 6: RTR
      -- Bit 5-4: Don't care
      -- Bit 3-0: DLC (Data Length Code)
      tx_frame_format := '1' & remote_frame & "00" & std_logic_vector(to_unsigned(data_length, 4));

      wb_write(C_CAN_EM_EFF_TXB_ID1, tx_id1, "Set TXID1", wbm_opcores_can_if);
      wb_write(C_CAN_EM_EFF_TXB_ID2, tx_id2, "Set TXID2", wbm_opcores_can_if);
      wb_write(C_CAN_EM_EFF_TXB_ID3, tx_id3, "Set TXID3", wbm_opcores_can_if);
      wb_write(C_CAN_EM_EFF_TXB_ID4, tx_id4, "Set TXID4", wbm_opcores_can_if);
      wb_write(C_CAN_EM_EFF, tx_frame_format, "Set Frame Format (FF)", wbm_opcores_can_if);

      -- Write payload bytes to TX buffer and
      -- format procedure call string with data
      if remote_frame = '0' and data_length > 0 then
        write(v_proc_call, to_string(", Data:0x"));

        for byte_num in 0 to data_length-1 loop
          wb_write(C_CAN_EM_EFF_TXB_DATA1+byte_num,
                   data(byte_num),
                   "Write byte " & to_string(byte_num, 1) & " to TX buffer.",
                   wbm_opcores_can_if);

          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;
      write(v_proc_call, to_string(")"));

      wb_write(C_CAN_CMR, x"01", "Request transmission on CAN0", wbm_opcores_can_if);

      if proc_name = "can_ctrl_send_ext_mode" then
        log(config.id_for_bfm, v_proc_call.all & "=> completed. " & msg, scope, msg_id_panel);
      end if;
    end procedure can_ctrl_send_ext_mode;


    procedure can_ctrl_wait_and_clr_irq(
      variable timeout : in time := 1 ms)
    is
      variable can_irq_reg : std_logic_vector(7 downto 0);
    begin
      if s_opcores_can_irq_n = '1' then
        wait until s_opcores_can_irq_n = '0' for timeout;
      end if;

      wb_read(C_CAN_IR, can_irq_reg, "Read out IR register to clear interrupts", wbm_opcores_can_if);
    end procedure can_ctrl_wait_and_clr_irq;

    procedure can_ctrl_recv_basic_mode (
      variable arb_id       : out std_logic_vector(10 downto 0);
      variable data         : out work.can_bfm_pkg.can_payload_t;
      variable data_length  : out natural;
--      variable extended_mode : out std_logic;
      variable remote_frame : out std_logic;
      constant msg          : in  string;
      constant timeout      : in  time                  := 1 ms;
      constant scope        : in  string                := C_SCOPE;
      constant msg_id_panel : in  t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
      variable proc_name    :     string                := "can_ctrl_recv_basic_mode")
    is
      variable rx_id1      : std_logic_vector(7 downto 0);
      variable rx_id2      : std_logic_vector(7 downto 0);
      variable can_irq_reg : std_logic_vector(7 downto 0);
      variable v_proc_call : line;
    begin
      -- Wait for interrupt (if it is not active)
      if s_opcores_can_irq_n = '1' then
        wait until s_opcores_can_irq_n = '0' for timeout;
      end if;

      if s_opcores_can_irq_n /= '0' then
        alert(warning, "Timeout while waiting for CAN controller to assert interrupt.", C_SCOPE);
        return;
      end if;

      wb_check(C_CAN_IR, "-------1", error, "Check that receive interrupt was set", wbm_opcores_can_if);

      wb_read(C_CAN_BM_RXB_ID1, rx_id1, "Read out RXID1", wbm_opcores_can_if);
      wb_read(C_CAN_BM_RXB_ID2, rx_id2, "Read out RXID2", wbm_opcores_can_if);

      arb_id(10 downto 3) := rx_id1;
      arb_id(2 downto 0) := rx_id2(7 downto 5);
      remote_frame := rx_id2(4);
      data_length := to_integer(unsigned(rx_id2(3 downto 0)));

      -- Format procedure call string
      write(v_proc_call, to_string("can_ctrl_recv_basic_mode() => ID: "));
      write(v_proc_call, to_string(arb_id, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", Length: "));
      write(v_proc_call, to_string(data_length, 1));

      -- Format procedure call string for remote frame
      if remote_frame = '1' then
        write(v_proc_call, to_string(", RTR"));

      -- Read in data from buffer, and
      -- format procedure call string for data frame
      elsif remote_frame = '0' and data_length > 0 then
        write(v_proc_call, to_string(", Data: 0x"));

        for byte_num in 0 to data_length-1 loop
          wb_read(C_CAN_BM_RXB_DATA1+byte_num,
                  data(byte_num),
                  "Read byte " & to_string(byte_num, 1) & " from RX buffer.",
                  wbm_opcores_can_if);

          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;

      wb_write(C_CAN_CMR, "00000100", "Release receive buffer", wbm_opcores_can_if);

      if proc_name = "can_ctrl_recv_basic_mode" then
        log(config.id_for_bfm, v_proc_call.all & ". " & msg, scope, msg_id_panel);
      end if;

    end procedure can_ctrl_recv_basic_mode;

    procedure can_ctrl_recv_ext_mode (
      variable arb_id_a     : out std_logic_vector(10 downto 0);
      variable arb_id_b     : out std_logic_vector(17 downto 0);
      variable data         : out work.can_bfm_pkg.can_payload_t;
      variable data_length  : out natural;
      variable ext_id       : out std_logic;
      variable remote_frame : out std_logic;
      constant msg          : in  string;
      constant timeout      : in  time                  := 1 ms;
      constant scope        : in  string                := C_SCOPE;
      constant msg_id_panel : in  t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
      variable proc_name    :     string                := "can_ctrl_recv_ext_mode")
    is
      variable rx_buff_start_addr : natural; -- Different from ext and standard frames
      variable rx_frame_format    : std_logic_vector(7 downto 0);
      variable rx_id1             : std_logic_vector(7 downto 0);
      variable rx_id2             : std_logic_vector(7 downto 0);
      variable rx_id3             : std_logic_vector(7 downto 0);
      variable rx_id4             : std_logic_vector(7 downto 0);
      variable can_irq_reg        : std_logic_vector(7 downto 0);
      variable v_proc_call        : line;
    begin
      -- Wait for interrupt (if it is not active)
      if s_opcores_can_irq_n = '1' then
        wait until s_opcores_can_irq_n = '0' for timeout;
      end if;

      if s_opcores_can_irq_n /= '0' then
        alert(warning, "Timeout while waiting for CAN controller to assert interrupt.", C_SCOPE);
        return;
      end if;

      wb_check(C_CAN_IR, "-------1", error, "Check that receive interrupt was set", wbm_opcores_can_if);

      wb_read(C_CAN_EM_EFF, rx_frame_format, "Read Frame Format (FF)", wbm_opcores_can_if);

      ext_id       := rx_frame_format(7);
      remote_frame := rx_frame_format(6);
      data_length  := to_integer(unsigned(rx_frame_format(3 downto 0)));

      if ext_id = '1' then
        -- Extended frame
        wb_read(C_CAN_EM_EFF_RXB_ID1, rx_id1, "Read out RXID1", wbm_opcores_can_if);
        wb_read(C_CAN_EM_EFF_RXB_ID2, rx_id2, "Read out RXID2", wbm_opcores_can_if);
        wb_read(C_CAN_EM_EFF_RXB_ID3, rx_id3, "Read out RXID3", wbm_opcores_can_if);
        wb_read(C_CAN_EM_EFF_RXB_ID4, rx_id4, "Read out RXID4", wbm_opcores_can_if);

        arb_id_b := rx_id2(4 downto 0) & rx_id3 & rx_id4(7 downto 3);

        rx_buff_start_addr := C_CAN_EM_EFF_RXB_DATA1;
      else
        -- Standard frame
        wb_read(C_CAN_EM_SFF_RXB_ID1, rx_id1, "Read out RXID1", wbm_opcores_can_if);
        wb_read(C_CAN_EM_SFF_RXB_ID2, rx_id2, "Read out RXID2", wbm_opcores_can_if);

        arb_id_b := (others => '0');

        rx_buff_start_addr := C_CAN_EM_SFF_RXB_DATA1;
      end if;

      arb_id_a(10 downto 3) := rx_id1;
      arb_id_a(2 downto 0)  := rx_id2(7 downto 5);

      -- Format procedure call string
      write(v_proc_call, to_string("can_ctrl_recv_ext_mode() => ID A: "));
      write(v_proc_call, to_string(arb_id_a, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", ID B: "));
      write(v_proc_call, to_string(arb_id_b, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", Length: "));
      write(v_proc_call, to_string(data_length, 1));

      -- Format procedure call string for remote frame
      if remote_frame = '1' then
        write(v_proc_call, to_string(", RTR"));

      -- Read in data from buffer, and
      -- format procedure call string for data frame
      elsif remote_frame = '0' and data_length > 0 then
        write(v_proc_call, to_string(", Data: 0x"));

        for byte_num in 0 to data_length-1 loop
          wb_read(rx_buff_start_addr+byte_num,
                  data(byte_num),
                  "Read byte " & to_string(byte_num, 1) & " from RX buffer.",
                  wbm_opcores_can_if);

          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;

      wb_write(C_CAN_CMR, "00000100", "Release receive buffer", wbm_opcores_can_if);

      if proc_name = "can_ctrl_recv_ext_mode" then
        log(config.id_for_bfm, v_proc_call.all & ". " & msg, scope, msg_id_panel);
      end if;

    end procedure can_ctrl_recv_ext_mode;


    variable v_can_bfm_tx        : std_logic                      := '1';
    variable v_can_bfm_rx        : std_logic                      := '1';
    variable v_xmit_arb_id       : std_logic_vector(28 downto 0);
    variable v_xmit_ext_id       : std_logic                      := '0';
    variable v_xmit_data         : work.can_bfm_pkg.can_payload_t := (others => x"00");
    variable v_xmit_data_length  : natural;
    variable v_xmit_remote_frame : std_logic;
    variable v_xmit_arb_lost     : std_logic     := '0';

    variable v_recv_arb_id       : std_logic_vector(28 downto 0);
    variable v_recv_data         : work.can_bfm_pkg.can_payload_t;
    variable v_recv_ext_id       : std_logic     := '0';
    variable v_recv_remote_frame : std_logic     := '0';
    variable v_recv_data_length  : natural       := 0;
    variable v_recv_timeout      : std_logic;

    variable v_can_tx_status    : can_tx_status_t;
    variable v_can_rx_error_gen : can_rx_error_gen_t := C_CAN_RX_NO_ERROR_GEN;

    variable v_arb_lost_count       : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_ack_recv_count       : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_tx_error_count       : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_msg_count         : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_crc_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_form_error_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_stuff_error_count : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_receive_error_count  : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);

    variable v_rand_baud_delay : natural;
    variable v_rand_real       : real;
  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    set_log_file_name("log/canola_vs_opencores_can_tb_log.txt");


    for testbench_pass_num in 0 to 1 loop

      if testbench_pass_num = 0 then
        -------------------------------------------------------------------------------------------
        log(ID_LOG_HDR, "Run testbench at 1 Mbit baud clock", C_SCOPE);
        -------------------------------------------------------------------------------------------
        s_can_ctrl1_clk_scale <= to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_1000kbit,
                                             C_TIME_QUANTA_CLOCK_SCALE_WIDTH);
        s_can_baud_period       <= C_CAN_BAUD_PERIOD_1000kbit;
        s_can_baud_freq         <= C_CAN_BAUD_FREQ_1000kbit;
      else
        -------------------------------------------------------------------------------------------
        log(ID_LOG_HDR, "Run testbench at 250 kbit baud clock", C_SCOPE);
        -------------------------------------------------------------------------------------------
        s_can_ctrl1_clk_scale <= to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_250kbit,
                                             C_TIME_QUANTA_CLOCK_SCALE_WIDTH);
        s_can_baud_period       <= C_CAN_BAUD_PERIOD_250kbit;
        s_can_baud_freq         <= C_CAN_BAUD_FREQ_250kbit;
      end if;


      ---------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Simulate basic-frame from OpenCores --> Canola controller", C_SCOPE);
      ---------------------------------------------------------------------------------------------

      s_clock_ena <= true;              -- to start clock generator
      pulse(s_can_ctrl1_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
      pulse(s_opcores_can_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

      can_ctrl_enable_basic_mode_operation(x"AA", x"FF", s_can_baud_freq);

      ---------------------------------------------------------------------------
      -- Test basic-frame transmission from OpenCores CAN controller to Canola
      ---------------------------------------------------------------------------
      for rand_test_num in 0 to C_NUM_ITERATIONS-1 loop
        log(ID_SEQUENCER, "Iteration #" & to_string(rand_test_num), C_SCOPE);

        wait for 200 ns;

        log(ID_SEQUENCER, "Generate random msg and transmit with OpenCores controller", C_SCOPE);
        ------------------------------------------------------------
        generate_random_can_message (v_xmit_arb_id,
                                     v_xmit_data,
                                     v_xmit_data_length,
                                     v_xmit_remote_frame,
                                     '0');
        v_xmit_ext_id := '0';

        can_ctrl_send_basic_mode(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                                 v_xmit_data,
                                 v_xmit_data_length,
                                 v_xmit_remote_frame,
                                 "Send msg with OpenCores CAN controller");


        log(ID_SEQUENCER, "Receive random message with Canola controller", C_SCOPE);
        ------------------------------------------------------------

        wait until s_msg_ctrl1_received = '1' for 300*s_can_baud_period;
        wait until s_opcores_can_irq_n = '0' for 300*s_can_baud_period;

        check_value(s_opcores_can_irq_n, '0', error, "Check that OC Controller finished transmit.");
        check_value(s_msg_ctrl1_received, '1', error, "Check that CAN controller received msg.");
        check_value(s_msg_ctrl1.ext_id, v_xmit_ext_id, error, "Check extended ID bit");

        if v_xmit_ext_id = '1' then
          v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH) := s_msg_ctrl1.arb_id_a;
          v_recv_arb_id(C_ID_B_LENGTH-1 downto 0)                           := s_msg_ctrl1.arb_id_b;
          check_value(v_recv_arb_id, v_xmit_arb_id, error, "Check received ID");
        else
          -- Only check the relevant ID bits for non-extended ID
          check_value(s_msg_ctrl1.arb_id_a,
                      v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                      error,
                      "Check received ID");
        end if;

        check_value(s_msg_ctrl1.remote_request, v_xmit_remote_frame, error, "Check received RTR bit");

        check_value(s_msg_ctrl1.data_length,
                    std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH)),
                    error, "Check data length");

        -- Don't check data for remote frame requests
        if v_xmit_remote_frame = '0' then
          for idx in 0 to v_xmit_data_length-1 loop
            check_value(s_msg_ctrl1.data(idx), v_xmit_data(idx), error, "Check received data");
          end loop;
        end if;

        pulse(s_msg_reset, s_clk, 1, "Reset received message signal");
        log(ID_SEQUENCER, "", C_SCOPE);

      end loop;


      ---------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Simulate basic-frame from Canola --> OpenCores controller", C_SCOPE);
      ---------------------------------------------------------------------------------------------
      s_clock_ena <= true;              -- to start clock generator
      pulse(s_can_ctrl1_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
      pulse(s_opcores_can_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

      can_ctrl_enable_basic_mode_operation(x"AA", x"FF", s_can_baud_freq);

      -- The OpenCores controller waits for 11 recessive bits before it is ready
      -- (see SJA1000 datasheet)
      wait for 11*s_can_baud_period;

      ---------------------------------------------------------------------------
      -- Test basic-frame transmission from Canola to OpenCores CAN controller
      ---------------------------------------------------------------------------
      for rand_test_num in 0 to C_NUM_ITERATIONS-1 loop
        log(ID_SEQUENCER, "Iteration #" & to_string(rand_test_num), C_SCOPE);

        wait for 200 ns;

        log(ID_SEQUENCER, "Generate random msg and transmit with Canola controller", C_SCOPE);
        ------------------------------------------------------------
        generate_random_can_message (v_xmit_arb_id,
                                     v_xmit_data,
                                     v_xmit_data_length,
                                     v_xmit_remote_frame,
                                     '0');

        s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
        s_can_ctrl1_tx_msg.arb_id_b       <= (others => '0');
        s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;
        s_can_ctrl1_tx_msg.ext_id         <= '0';
        s_can_ctrl1_tx_msg.data           <= work.canola_pkg.can_payload_t(v_xmit_data);
        s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));

        wait until rising_edge(s_clk);
        s_can_ctrl1_tx_start <= '1';
        wait until rising_edge(s_clk);
        s_can_ctrl1_tx_start <= '0';
        wait until rising_edge(s_clk);

        log(ID_SEQUENCER, "Receive random message with OpenCores controller", C_SCOPE);
        ------------------------------------------------------------
        v_recv_arb_id       := (others => '0');
        v_recv_data         := (others => x"00");
        v_recv_data_length  := 0;
        v_recv_remote_frame := '0';

        can_ctrl_recv_basic_mode(v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                                 v_recv_data,
                                 v_recv_data_length,
                                 v_recv_remote_frame,
                                 "Receive message with OpenCores controller");

        -- Only check the relevant ID bits for non-extended ID
        check_value(v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                    v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                    error, "Check received ID");

        check_value(v_recv_remote_frame, v_xmit_remote_frame, error, "Check received RTR bit");
        check_value(v_recv_data_length, v_xmit_data_length, error, "Check data length");

        -- Don't check data for remote frame requests
        if v_xmit_remote_frame = '0' then
          for idx in 0 to v_xmit_data_length-1 loop
            check_value(v_recv_data(idx), v_xmit_data(idx), error, "Check received data");
          end loop;
        end if;

        log(ID_SEQUENCER, "", C_SCOPE);

      end loop;


      ---------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Simulate ext-frame from OpenCores --> Canola controller", C_SCOPE);
      ---------------------------------------------------------------------------------------------
      s_clock_ena <= true;              -- to start clock generator
      pulse(s_can_ctrl1_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
      pulse(s_opcores_can_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

      -- Accept any ID code
      can_ctrl_enable_ext_mode_operation(x"FFFFFFF" & '1', x"FFFFFFF" & '1', s_can_baud_freq);

      ---------------------------------------------------------------------------
      -- Test extended-frame transmission from OpenCores CAN controller to Canola
      ---------------------------------------------------------------------------
      for rand_test_num in 0 to C_NUM_ITERATIONS-1 loop
        log(ID_SEQUENCER, "Iteration #" & to_string(rand_test_num), C_SCOPE);

        wait for 200 ns;

        log(ID_SEQUENCER, "Generate random msg and transmit with OpenCores controller", C_SCOPE);
        ------------------------------------------------------------
        generate_random_can_message (v_xmit_arb_id,
                                     v_xmit_data,
                                     v_xmit_data_length,
                                     v_xmit_remote_frame,
                                     '1');

        can_ctrl_send_ext_mode(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                               v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                               v_xmit_data,
                               v_xmit_data_length,
                               v_xmit_remote_frame,
                               "Send msg with OpenCores CAN controller");


        log(ID_SEQUENCER, "Receive random message with Canola controller", C_SCOPE);
        ------------------------------------------------------------

        wait until s_msg_ctrl1_received = '1' for 300*s_can_baud_period;
        wait until s_opcores_can_irq_n = '0' for 300*s_can_baud_period;

        check_value(s_opcores_can_irq_n, '0', error, "Check that OC Controller finished transmit.");
        check_value(s_msg_ctrl1_received, '1', error, "Check that CAN controller received msg.");
        check_value(s_msg_ctrl1.ext_id, '1', error, "Check extended ID bit");

        v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH) := s_msg_ctrl1.arb_id_a;
        v_recv_arb_id(C_ID_B_LENGTH-1 downto 0)                           := s_msg_ctrl1.arb_id_b;
        check_value(v_recv_arb_id, v_xmit_arb_id, error, "Check received ID");

        check_value(s_msg_ctrl1.remote_request, v_xmit_remote_frame, error, "Check received RTR bit");

        check_value(s_msg_ctrl1.data_length,
                    std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH)),
                    error, "Check data length");

        -- Don't check data for remote frame requests
        if v_xmit_remote_frame = '0' then
          for idx in 0 to v_xmit_data_length-1 loop
            check_value(s_msg_ctrl1.data(idx), v_xmit_data(idx), error, "Check received data");
          end loop;
        end if;

        pulse(s_msg_reset, s_clk, 1, "Reset received message signal");
        log(ID_SEQUENCER, "", C_SCOPE);

      end loop;


      ---------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Simulate ext-frame from Canola --> OpenCores controller", C_SCOPE);
      ---------------------------------------------------------------------------------------------
      s_clock_ena <= true;              -- to start clock generator
      pulse(s_can_ctrl1_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");
      pulse(s_opcores_can_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

      -- Accept any ID code
      can_ctrl_enable_ext_mode_operation(x"FFFFFFF" & '1', x"FFFFFFF" & '1', s_can_baud_freq);

      -- The OpenCores controller waits for 11 recessive bits before it is ready
      -- (see SJA1000 datasheet)
      wait for 11*s_can_baud_period;

      ---------------------------------------------------------------------------
      -- Test ext-frame transmission from Canola to OpenCores CAN controller
      ---------------------------------------------------------------------------
      for rand_test_num in 0 to C_NUM_ITERATIONS-1 loop
        log(ID_SEQUENCER, "Iteration #" & to_string(rand_test_num), C_SCOPE);

        wait for 200 ns;

        log(ID_SEQUENCER, "Generate random msg and transmit with Canola controller", C_SCOPE);
        ------------------------------------------------------------
        v_xmit_ext_id := '1';

        generate_random_can_message (v_xmit_arb_id,
                                     v_xmit_data,
                                     v_xmit_data_length,
                                     v_xmit_remote_frame,
                                     v_xmit_ext_id);

        s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
        s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);
        s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;
        s_can_ctrl1_tx_msg.ext_id         <= '1';
        s_can_ctrl1_tx_msg.data           <= work.canola_pkg.can_payload_t(v_xmit_data);
        s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));

        wait until rising_edge(s_clk);
        s_can_ctrl1_tx_start <= '1';
        wait until rising_edge(s_clk);
        s_can_ctrl1_tx_start <= '0';
        wait until rising_edge(s_clk);

        log(ID_SEQUENCER, "Receive random message with OpenCores controller", C_SCOPE);
        ------------------------------------------------------------
        v_recv_arb_id       := (others => '0');
        v_recv_data         := (others => x"00");
        v_recv_data_length  := 0;
        v_recv_remote_frame := '0';
        v_recv_ext_id       := '0';

        can_ctrl_recv_ext_mode(v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                               v_recv_arb_id(C_ID_B_LENGTH-1 downto 0),
                               v_recv_data,
                               v_recv_data_length,
                               v_recv_ext_id,
                               v_recv_remote_frame,
                               "Receive message with OpenCores controller");

        check_value(v_recv_ext_id, v_xmit_ext_id, error, "Check that ext. msg was received.");
        check_value(v_recv_arb_id, v_xmit_arb_id, error, "Check received ID");
        check_value(v_recv_remote_frame, v_xmit_remote_frame, error, "Check received RTR bit");
        check_value(v_recv_data_length, v_xmit_data_length, error, "Check data length");

        -- Don't check data for remote frame requests
        if v_xmit_remote_frame = '0' then
          for idx in 0 to v_xmit_data_length-1 loop
            check_value(v_recv_data(idx), v_xmit_data(idx), error, "Check received data");
          end loop;
        end if;

        log(ID_SEQUENCER, "", C_SCOPE);

      end loop;

    end loop;  -- testbench_pass_num

    -----------------------------------------------------------------------------------------------
    -- Simulation complete
    -----------------------------------------------------------------------------------------------
    wait for 10000 ns;            -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

end process p_main;

end tb;
