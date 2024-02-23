-------------------------------------------------------------------------------
-- Title      : Top-level UVVM Testbench for Canola CAN Controller
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_top_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    : Western Norway University of Applied Sciences
-- Created    : 2019-08-05
-- Last update: 2024-02-23
-- Platform   :
-- Target     :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Top-level UVVM testbench for the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2019-08-05  1.0      svn                     Created
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
use work.can_uvvm_bfm_pkg.all;

-- test bench entity
entity canola_top_tb is
  generic (
    G_TMR_TOP_MODULE_EN : boolean := false;  -- Use canola_top_tmr instead of canola_top
    G_SEE_MITIGATION_EN : boolean := false); -- Enable TMR in canola_top_tmr
end canola_top_tb;

architecture tb of canola_top_tb is

  constant C_CLK_PERIOD : time       := 25 ns; -- 40 Mhz
  constant C_CLK_FREQ   : integer    := 1e9 ns / C_CLK_PERIOD;

  -- Note: C_TIME_QUANTA_CLOCK_SCALE_VAL needs to reflect the value of C_CAN_BAUD_PERIOD
  constant C_CAN_BAUD_PERIOD  : time    := 1000 ns;  -- 1 MHz
  constant C_CAN_BAUD_FREQ    : integer := 1e9 ns / C_CAN_BAUD_PERIOD;

  constant C_CAN_CTRL1_TO_CTRL2_DELAY : time := 0.5*(C_CAN_BAUD_PERIOD/10);
  constant C_CAN_CTRL1_TO_CTRL3_DELAY : time := 1.5*(C_CAN_BAUD_PERIOD/10);
  constant C_CAN_CTRL2_TO_CTRL3_DELAY : time := 1.0*(C_CAN_BAUD_PERIOD/10);


  -- Indicates where in a bit the Rx sample point should be
  -- Real value from 0.0 to 1.0.
  constant C_CAN_SAMPLE_POINT : real    := 0.7;

  -- Note: C_TIME_QUANTA_CLOCK_SCALE_VAL needs to reflect the value of C_CAN_BAUD_PERIOD
  constant C_TIME_QUANTA_CLOCK_SCALE_VAL : natural := 3;

  constant C_DATA_LENGTH_MAX : natural := 1000;
  constant C_NUM_ITERATIONS  : natural := 1;  -- 100

  constant C_COUNTER_WIDTH : natural := 16;

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

  ------------------------------------------------------------------------------
  -- Signals for CAN controller #1
  ------------------------------------------------------------------------------
  signal s_can_ctrl1_reset                : std_logic;
  signal s_can_ctrl1_tx                   : std_logic;
  signal s_can_ctrl1_rx                   : std_logic;
  signal s_can_ctrl1_rx_msg               : can_msg_t;
  signal s_can_ctrl1_tx_msg               : can_msg_t;
  signal s_can_ctrl1_rx_msg_valid         : std_logic;
  signal s_can_ctrl1_tx_start             : std_logic                                := '0';
  signal s_can_ctrl1_tx_retransmit_en     : std_logic                                := '0';
  signal s_can_ctrl1_tx_busy              : std_logic;
  signal s_can_ctrl1_tx_done              : std_logic;
  signal s_can_ctrl1_tx_failed            : std_logic;
  signal s_can_ctrl1_sample_point_tx      : std_logic;
  signal s_can_ctrl1_tx_fsm_state         : work.canola_pkg.can_frame_tx_fsm_state_t := ST_IDLE;
  signal s_can_ctrl1_recessive_bits_count : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);

  signal s_can_ctrl1_prop_seg        : std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0)   := "0111";
  signal s_can_ctrl1_phase_seg1      : std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0) := "0111";
  signal s_can_ctrl1_phase_seg2      : std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0) := "0111";

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
  -- Signals for CAN controller #2
  ------------------------------------------------------------------------------
  signal s_can_ctrl2_reset            : std_logic;
  signal s_can_ctrl2_tx               : std_logic;
  signal s_can_ctrl2_rx               : std_logic;
  signal s_can_ctrl2_rx_msg           : can_msg_t;
  signal s_can_ctrl2_tx_msg           : can_msg_t;
  signal s_can_ctrl2_rx_msg_valid     : std_logic;
  signal s_can_ctrl2_tx_start         : std_logic := '0';
  signal s_can_ctrl2_tx_retransmit_en : std_logic := '0';
  signal s_can_ctrl2_tx_busy          : std_logic;
  signal s_can_ctrl2_tx_done          : std_logic;
  signal s_can_ctrl2_tx_failed        : std_logic;

  signal s_can_ctrl2_prop_seg        : std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0)   := "0111";
  signal s_can_ctrl2_phase_seg1      : std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0) := "0111";
  signal s_can_ctrl2_phase_seg2      : std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0) := "0111";

  signal s_can_ctrl2_sync_jump_width : unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0)
    := to_unsigned(2, C_SYNC_JUMP_WIDTH_BITSIZE);

  signal s_can_ctrl2_transmit_error_count : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_can_ctrl2_receive_error_count  : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_can_ctrl2_error_state          : can_error_state_t;

  -- Count up signals
  signal s_can_ctrl2_tx_msg_sent_count_up    : std_logic;
  signal s_can_ctrl2_tx_failed_count_up      : std_logic;
  signal s_can_ctrl2_tx_ack_error_count_up   : std_logic;
  signal s_can_ctrl2_tx_arb_lost_count_up    : std_logic;
  signal s_can_ctrl2_tx_bit_error_count_up   : std_logic;
  signal s_can_ctrl2_tx_retransmit_count_up  : std_logic;
  signal s_can_ctrl2_rx_msg_recv_count_up    : std_logic;
  signal s_can_ctrl2_rx_crc_error_count_up   : std_logic;
  signal s_can_ctrl2_rx_form_error_count_up  : std_logic;
  signal s_can_ctrl2_rx_stuff_error_count_up : std_logic;

  -- Counters
  signal s_can_ctrl2_reg_tx_msg_sent_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_tx_failed_count      : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_tx_ack_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_tx_arb_lost_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_tx_bit_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_tx_retransmit_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_rx_msg_recv_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_rx_crc_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_rx_form_error_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl2_reg_rx_stuff_error_count : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);

  ------------------------------------------------------------------------------
  -- Signals for CAN controller #3
  ------------------------------------------------------------------------------
  signal s_can_ctrl3_reset            : std_logic;
  signal s_can_ctrl3_tx               : std_logic;
  signal s_can_ctrl3_rx               : std_logic;
  signal s_can_ctrl3_rx_msg           : can_msg_t;
  signal s_can_ctrl3_tx_msg           : can_msg_t;
  signal s_can_ctrl3_rx_msg_valid     : std_logic;
  signal s_can_ctrl3_tx_start         : std_logic := '0';
  signal s_can_ctrl3_tx_retransmit_en : std_logic := '0';
  signal s_can_ctrl3_tx_busy          : std_logic;
  signal s_can_ctrl3_tx_done          : std_logic;
  signal s_can_ctrl3_tx_failed        : std_logic;

  signal s_can_ctrl3_prop_seg        : std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0)   := "0111";
  signal s_can_ctrl3_phase_seg1      : std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0) := "0111";
  signal s_can_ctrl3_phase_seg2      : std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0) := "0111";

  signal s_can_ctrl3_sync_jump_width : unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0)
    := to_unsigned(2, C_SYNC_JUMP_WIDTH_BITSIZE);

  signal s_can_ctrl3_transmit_error_count : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_can_ctrl3_receive_error_count  : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
  signal s_can_ctrl3_error_state          : can_error_state_t;

  -- Count up signals
  signal s_can_ctrl3_tx_msg_sent_count_up    : std_logic;
  signal s_can_ctrl3_tx_failed_count_up      : std_logic;
  signal s_can_ctrl3_tx_ack_error_count_up   : std_logic;
  signal s_can_ctrl3_tx_arb_lost_count_up    : std_logic;
  signal s_can_ctrl3_tx_bit_error_count_up   : std_logic;
  signal s_can_ctrl3_tx_retransmit_count_up  : std_logic;
  signal s_can_ctrl3_rx_msg_recv_count_up    : std_logic;
  signal s_can_ctrl3_rx_crc_error_count_up   : std_logic;
  signal s_can_ctrl3_rx_form_error_count_up  : std_logic;
  signal s_can_ctrl3_rx_stuff_error_count_up : std_logic;

  -- Counters
  signal s_can_ctrl3_reg_tx_msg_sent_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_tx_failed_count      : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_tx_ack_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_tx_arb_lost_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_tx_bit_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_tx_retransmit_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_rx_msg_recv_count    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_rx_crc_error_count   : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_rx_form_error_count  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
  signal s_can_ctrl3_reg_rx_stuff_error_count : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);

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
  signal s_can_bus_signal3    : std_logic; -- At controller #3

  -- Used by p_can_ctrl_rx_msg which monitors
  -- when the CAN controller receives a message
  signal s_msg_ctrl1_received : std_logic := '0';
  signal s_msg_ctrl2_received : std_logic := '0';
  signal s_msg_ctrl3_received : std_logic := '0';
  signal s_msg_reset          : std_logic := '0';
  signal s_msg_ctrl1          : can_msg_t;
  signal s_msg_ctrl2          : can_msg_t;
  signal s_msg_ctrl3          : can_msg_t;


begin

  -- Set up clock generators
  clock_gen(s_clk, s_clock_ena, C_CLK_PERIOD);
  clock_gen(s_can_baud_clk, s_clock_ena, C_CAN_BAUD_PERIOD);

  -- Bus signal at controller 1 and BFM
  s_can_bus_signal1 <= 'H';
  s_can_bus_signal1 <= '0' when s_can_ctrl1_tx = '0' else 'Z';
  s_can_bus_signal1 <= transport '0' after C_CAN_CTRL1_TO_CTRL2_DELAY when s_can_ctrl2_tx  = '0' else 'Z';
  s_can_bus_signal1 <= transport '0' after C_CAN_CTRL1_TO_CTRL3_DELAY when s_can_ctrl3_tx  = '0' else 'Z';
  s_can_bus_signal1 <= '0' when s_can_bfm_tx  = '0' else 'Z';
  s_can_ctrl1_rx    <= '1' ?= s_can_bus_signal1;
  s_can_bfm_rx      <= '1' ?= s_can_bus_signal1;

  -- Bus signal at controller 2
  s_can_bus_signal2 <= 'H';
  s_can_bus_signal2 <= '0' when s_can_ctrl2_tx  = '0' else 'Z';
  s_can_bus_signal2 <= transport '0' after C_CAN_CTRL1_TO_CTRL2_DELAY when s_can_ctrl1_tx  = '0' else 'Z';
  s_can_bus_signal2 <= transport '0' after C_CAN_CTRL1_TO_CTRL2_DELAY when s_can_bfm_tx    = '0' else 'Z';
  s_can_bus_signal2 <= transport '0' after C_CAN_CTRL2_TO_CTRL3_DELAY when s_can_ctrl3_tx  = '0' else 'Z';
  s_can_bus_signal2 <= '0' when s_can_ctrl2_tx  = '0' else 'Z';
  s_can_ctrl2_rx    <= '1' ?= s_can_bus_signal2;

  -- Bus signal at controller 3
  s_can_bus_signal3 <= 'H';
  s_can_bus_signal3 <= '0' when s_can_ctrl3_tx  = '0' else 'Z';
  s_can_bus_signal3 <= transport '0' after C_CAN_CTRL1_TO_CTRL3_DELAY when s_can_ctrl1_tx  = '0' else 'Z';
  s_can_bus_signal3 <= transport '0' after C_CAN_CTRL1_TO_CTRL3_DELAY when s_can_bfm_tx    = '0' else 'Z';
  s_can_bus_signal3 <= transport '0' after C_CAN_CTRL2_TO_CTRL3_DELAY when s_can_ctrl2_tx  = '0' else 'Z';
  s_can_bus_signal3 <= '0' when s_can_ctrl3_tx  = '0' else 'Z';
  s_can_ctrl3_rx    <= '1' ?= s_can_bus_signal3;


  -----------------------------------------------------------------------------
  -- Generate instances of canola_top_tmr when G_TMR_TOP_MODULE_EN is set
  -----------------------------------------------------------------------------
  if_TMR_generate : if G_TMR_TOP_MODULE_EN generate
    INST_canola_top_1 : entity work.canola_top_tmr
      generic map (
        G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN)
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
        TIME_QUANTA_CLOCK_SCALE     => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                                   C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),

        -- Error state and counters
        TRANSMIT_ERROR_COUNT => s_can_ctrl1_transmit_error_count,
        RECEIVE_ERROR_COUNT  => s_can_ctrl1_receive_error_count,
        ERROR_STATE          => s_can_ctrl1_error_state,

        -- Counter signals
        TX_MSG_SENT_COUNT_UP       => s_can_ctrl1_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP         => s_can_ctrl1_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP      => s_can_ctrl1_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP       => s_can_ctrl1_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP      => s_can_ctrl1_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP     => s_can_ctrl1_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP       => s_can_ctrl1_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP      => s_can_ctrl1_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP     => s_can_ctrl1_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP    => s_can_ctrl1_rx_stuff_error_count_up,

        VOTER_MISMATCH => open
        );

    INST_canola_top_2 : entity work.canola_top_tmr
      generic map (
        G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN)
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl2_reset,

        -- CAN bus interface signals
        CAN_TX => s_can_ctrl2_tx,
        CAN_RX => s_can_ctrl2_rx,

        -- Rx interface
        RX_MSG       => s_can_ctrl2_rx_msg,
        RX_MSG_VALID => s_can_ctrl2_rx_msg_valid,

        -- Tx interface
        TX_MSG           => s_can_ctrl2_tx_msg,
        TX_START         => s_can_ctrl2_tx_start,
        TX_RETRANSMIT_EN => s_can_ctrl2_tx_retransmit_en,
        TX_BUSY          => s_can_ctrl2_tx_busy,
        TX_DONE          => s_can_ctrl2_tx_done,
        TX_FAILED        => s_can_ctrl2_tx_failed,

        BTL_TRIPLE_SAMPLING         => '0',
        BTL_PROP_SEG                => s_can_ctrl2_prop_seg,
        BTL_PHASE_SEG1              => s_can_ctrl2_phase_seg1,
        BTL_PHASE_SEG2              => s_can_ctrl2_phase_seg2,
        BTL_SYNC_JUMP_WIDTH         => s_can_ctrl2_sync_jump_width,

        TIME_QUANTA_CLOCK_SCALE     => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                                   C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),

        -- Error state and counters
        TRANSMIT_ERROR_COUNT => s_can_ctrl2_transmit_error_count,
        RECEIVE_ERROR_COUNT  => s_can_ctrl2_receive_error_count,
        ERROR_STATE          => s_can_ctrl2_error_state,

        -- Counter signals
        TX_MSG_SENT_COUNT_UP       => s_can_ctrl2_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP         => s_can_ctrl2_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP      => s_can_ctrl2_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP       => s_can_ctrl2_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP      => s_can_ctrl2_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP     => s_can_ctrl2_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP       => s_can_ctrl2_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP      => s_can_ctrl2_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP     => s_can_ctrl2_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP    => s_can_ctrl2_rx_stuff_error_count_up,

        VOTER_MISMATCH => open
        );

    INST_canola_top_3 : entity work.canola_top_tmr
      generic map (
        G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN)
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl3_reset,

        -- CAN bus interface signals
        CAN_TX => s_can_ctrl3_tx,
        CAN_RX => s_can_ctrl3_rx,

        -- Rx interface
        RX_MSG       => s_can_ctrl3_rx_msg,
        RX_MSG_VALID => s_can_ctrl3_rx_msg_valid,

        -- Tx interface
        TX_MSG           => s_can_ctrl3_tx_msg,
        TX_START         => s_can_ctrl3_tx_start,
        TX_RETRANSMIT_EN => s_can_ctrl3_tx_retransmit_en,
        TX_BUSY          => s_can_ctrl3_tx_busy,
        TX_DONE          => s_can_ctrl3_tx_done,
        TX_FAILED        => s_can_ctrl3_tx_failed,

        BTL_TRIPLE_SAMPLING         => '0',
        BTL_PROP_SEG                => s_can_ctrl3_prop_seg,
        BTL_PHASE_SEG1              => s_can_ctrl3_phase_seg1,
        BTL_PHASE_SEG2              => s_can_ctrl3_phase_seg2,
        BTL_SYNC_JUMP_WIDTH         => s_can_ctrl3_sync_jump_width,

        TIME_QUANTA_CLOCK_SCALE     => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                                   C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),

        -- Error state and counters
        TRANSMIT_ERROR_COUNT => s_can_ctrl3_transmit_error_count,
        RECEIVE_ERROR_COUNT  => s_can_ctrl3_receive_error_count,
        ERROR_STATE          => s_can_ctrl3_error_state,

        -- Counter signals
        TX_MSG_SENT_COUNT_UP       => s_can_ctrl3_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP         => s_can_ctrl3_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP      => s_can_ctrl3_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP       => s_can_ctrl3_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP      => s_can_ctrl3_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP     => s_can_ctrl3_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP       => s_can_ctrl3_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP      => s_can_ctrl3_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP     => s_can_ctrl3_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP    => s_can_ctrl3_rx_stuff_error_count_up,

        VOTER_MISMATCH => open
        );

    INST_canola_counters_1 : entity work.canola_counters_tmr
      generic map (
        G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
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
        RX_STUFF_ERROR_COUNT_VALUE => s_can_ctrl1_reg_rx_stuff_error_count,

        VOTER_MISMATCH => open
        );

    INST_canola_counters_2 : entity work.canola_counters_tmr
      generic map (
        G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
        G_COUNTER_WIDTH       => C_COUNTER_WIDTH,
        G_SATURATING_COUNTERS => true)
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl2_reset,

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

        TX_MSG_SENT_COUNT_UP    => s_can_ctrl2_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP      => s_can_ctrl2_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP   => s_can_ctrl2_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP    => s_can_ctrl2_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP   => s_can_ctrl2_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP  => s_can_ctrl2_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP    => s_can_ctrl2_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP   => s_can_ctrl2_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP  => s_can_ctrl2_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP => s_can_ctrl2_rx_stuff_error_count_up,

        TX_MSG_SENT_COUNT_VALUE    => s_can_ctrl2_reg_tx_msg_sent_count,
        TX_FAILED_COUNT_VALUE      => s_can_ctrl2_reg_tx_failed_count,
        TX_ACK_ERROR_COUNT_VALUE   => s_can_ctrl2_reg_tx_ack_error_count,
        TX_ARB_LOST_COUNT_VALUE    => s_can_ctrl2_reg_tx_arb_lost_count,
        TX_BIT_ERROR_COUNT_VALUE   => s_can_ctrl2_reg_tx_bit_error_count,
        TX_RETRANSMIT_COUNT_VALUE  => s_can_ctrl2_reg_tx_retransmit_count,
        RX_MSG_RECV_COUNT_VALUE    => s_can_ctrl2_reg_rx_msg_recv_count,
        RX_CRC_ERROR_COUNT_VALUE   => s_can_ctrl2_reg_rx_crc_error_count,
        RX_FORM_ERROR_COUNT_VALUE  => s_can_ctrl2_reg_rx_form_error_count,
        RX_STUFF_ERROR_COUNT_VALUE => s_can_ctrl2_reg_rx_stuff_error_count,

        VOTER_MISMATCH => open
        );

    INST_canola_counters_3 : entity work.canola_counters_tmr
      generic map (
        G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
        G_COUNTER_WIDTH       => C_COUNTER_WIDTH,
        G_SATURATING_COUNTERS => true)
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl3_reset,

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

        TX_MSG_SENT_COUNT_UP    => s_can_ctrl3_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP      => s_can_ctrl3_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP   => s_can_ctrl3_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP    => s_can_ctrl3_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP   => s_can_ctrl3_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP  => s_can_ctrl3_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP    => s_can_ctrl3_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP   => s_can_ctrl3_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP  => s_can_ctrl3_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP => s_can_ctrl3_rx_stuff_error_count_up,

        TX_MSG_SENT_COUNT_VALUE    => s_can_ctrl3_reg_tx_msg_sent_count,
        TX_FAILED_COUNT_VALUE      => s_can_ctrl3_reg_tx_failed_count,
        TX_ACK_ERROR_COUNT_VALUE   => s_can_ctrl3_reg_tx_ack_error_count,
        TX_ARB_LOST_COUNT_VALUE    => s_can_ctrl3_reg_tx_arb_lost_count,
        TX_BIT_ERROR_COUNT_VALUE   => s_can_ctrl3_reg_tx_bit_error_count,
        TX_RETRANSMIT_COUNT_VALUE  => s_can_ctrl3_reg_tx_retransmit_count,
        RX_MSG_RECV_COUNT_VALUE    => s_can_ctrl3_reg_rx_msg_recv_count,
        RX_CRC_ERROR_COUNT_VALUE   => s_can_ctrl3_reg_rx_crc_error_count,
        RX_FORM_ERROR_COUNT_VALUE  => s_can_ctrl3_reg_rx_form_error_count,
        RX_STUFF_ERROR_COUNT_VALUE => s_can_ctrl3_reg_rx_stuff_error_count,

        VOTER_MISMATCH => open
        );

    if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
      -- Aliases to some signals deep in the controller hierarchy
      -- that the testbench needs access to.
      -- Have to do this separately with/without G_SEE_MITIGATION_EN,
      -- because the hierarchy differs based on that generic.
      process is
        alias a_can_ctrl1_sample_point_tx is << signal .canola_top_tb.if_TMR_generate.INST_canola_top_1.INST_canola_btl_tmr.if_NOMITIGATION_generate.no_tmr_block.INST_canola_btl.s_sample_point_tx : std_logic >>;

        alias a_can_ctrl1_tx_fsm_state is << signal .canola_top_tb.if_TMR_generate.INST_canola_top_1.INST_canola_frame_tx_fsm_tmr.if_NOMITIGATION_generate.no_tmr_block.INST_canola_frame_tx_fsm.s_fsm_state_voted : work.canola_pkg.can_frame_tx_fsm_state_t >>;

        alias a_can_ctrl1_recessive_bits_count is << signal .canola_top_tb.if_TMR_generate.INST_canola_top_1.s_eml_recessive_bit_count_value : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0) >>;
      begin
        while true loop
          s_can_ctrl1_sample_point_tx      <= a_can_ctrl1_sample_point_tx;
          s_can_ctrl1_tx_fsm_state         <= a_can_ctrl1_tx_fsm_state;
          s_can_ctrl1_recessive_bits_count <= unsigned(a_can_ctrl1_recessive_bits_count);

          -- Update on changes to any of these signals
          wait on a_can_ctrl1_tx_fsm_state,
            a_can_ctrl1_sample_point_tx,
            a_can_ctrl1_recessive_bits_count;

        end loop;
      end process;
    end generate if_NOMITIGATION_generate;


    if_MITIGATION_generate : if G_SEE_MITIGATION_EN generate
      -- Aliases to some signals deep in the controller hierarchy
      -- that the testbench needs access to.
      -- Have to do this separately with/without G_SEE_MITIGATION_EN,
      -- because the hierarchy differs based on that generic.
      process is
        alias a_can_ctrl1_sample_point_tx is << signal .canola_top_tb.if_TMR_generate.INST_canola_top_1.INST_canola_btl_tmr.if_TMR_generate.tmr_block.for_TMR_generate(0).INST_canola_btl.s_sample_point_tx : std_logic >>;

        alias a_can_ctrl1_tx_fsm_state is << signal .canola_top_tb.if_TMR_generate.INST_canola_top_1.INST_canola_frame_tx_fsm_tmr.if_TMR_generate.tmr_block.for_TMR_generate(0).INST_canola_frame_tx_fsm.s_fsm_state_voted : work.canola_pkg.can_frame_tx_fsm_state_t >>;

        alias a_can_ctrl1_recessive_bits_count is << signal .canola_top_tb.if_TMR_generate.INST_canola_top_1.s_eml_recessive_bit_count_value : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0) >>;
      begin
        while true loop
          s_can_ctrl1_sample_point_tx      <= a_can_ctrl1_sample_point_tx;
          s_can_ctrl1_tx_fsm_state         <= a_can_ctrl1_tx_fsm_state;
          s_can_ctrl1_recessive_bits_count <= unsigned(a_can_ctrl1_recessive_bits_count);

          -- Update on changes to any of these signals
          wait on a_can_ctrl1_tx_fsm_state,
            a_can_ctrl1_sample_point_tx,
            a_can_ctrl1_recessive_bits_count;

        end loop;
      end process;
    end generate if_MITIGATION_generate;

  end generate if_TMR_generate;


  -----------------------------------------------------------------------------
  -- Generate instances of canola_top when G_TMR_TOP_MODULE_EN is not set
  -----------------------------------------------------------------------------
  if_not_TMR_generate : if not G_TMR_TOP_MODULE_EN generate
    INST_canola_top_1 : entity work.canola_top
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

        TIME_QUANTA_CLOCK_SCALE     => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                                   C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),

        -- Error state and counters
        TRANSMIT_ERROR_COUNT => s_can_ctrl1_transmit_error_count,
        RECEIVE_ERROR_COUNT  => s_can_ctrl1_receive_error_count,
        ERROR_STATE          => s_can_ctrl1_error_state,

        -- Counter signals
        TX_MSG_SENT_COUNT_UP       => s_can_ctrl1_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP         => s_can_ctrl1_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP      => s_can_ctrl1_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP       => s_can_ctrl1_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP      => s_can_ctrl1_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP     => s_can_ctrl1_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP       => s_can_ctrl1_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP      => s_can_ctrl1_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP     => s_can_ctrl1_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP    => s_can_ctrl1_rx_stuff_error_count_up
        );

    INST_canola_top_2 : entity work.canola_top
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl2_reset,

        -- CAN bus interface signals
        CAN_TX => s_can_ctrl2_tx,
        CAN_RX => s_can_ctrl2_rx,

        -- Rx interface
        RX_MSG       => s_can_ctrl2_rx_msg,
        RX_MSG_VALID => s_can_ctrl2_rx_msg_valid,

        -- Tx interface
        TX_MSG           => s_can_ctrl2_tx_msg,
        TX_START         => s_can_ctrl2_tx_start,
        TX_RETRANSMIT_EN => s_can_ctrl2_tx_retransmit_en,
        TX_BUSY          => s_can_ctrl2_tx_busy,
        TX_DONE          => s_can_ctrl2_tx_done,
        TX_FAILED        => s_can_ctrl2_tx_failed,

        BTL_TRIPLE_SAMPLING         => '0',
        BTL_PROP_SEG                => s_can_ctrl2_prop_seg,
        BTL_PHASE_SEG1              => s_can_ctrl2_phase_seg1,
        BTL_PHASE_SEG2              => s_can_ctrl2_phase_seg2,
        BTL_SYNC_JUMP_WIDTH         => s_can_ctrl2_sync_jump_width,

        TIME_QUANTA_CLOCK_SCALE     => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                                   C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),

        -- Error state and counters
        TRANSMIT_ERROR_COUNT => s_can_ctrl2_transmit_error_count,
        RECEIVE_ERROR_COUNT  => s_can_ctrl2_receive_error_count,
        ERROR_STATE          => s_can_ctrl2_error_state,

        -- Counter signals
        TX_MSG_SENT_COUNT_UP       => s_can_ctrl2_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP         => s_can_ctrl2_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP      => s_can_ctrl2_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP       => s_can_ctrl2_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP      => s_can_ctrl2_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP     => s_can_ctrl2_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP       => s_can_ctrl2_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP      => s_can_ctrl2_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP     => s_can_ctrl2_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP    => s_can_ctrl2_rx_stuff_error_count_up
        );

    INST_canola_top_3 : entity work.canola_top
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl3_reset,

        -- CAN bus interface signals
        CAN_TX => s_can_ctrl3_tx,
        CAN_RX => s_can_ctrl3_rx,

        -- Rx interface
        RX_MSG       => s_can_ctrl3_rx_msg,
        RX_MSG_VALID => s_can_ctrl3_rx_msg_valid,

        -- Tx interface
        TX_MSG           => s_can_ctrl3_tx_msg,
        TX_START         => s_can_ctrl3_tx_start,
        TX_RETRANSMIT_EN => s_can_ctrl3_tx_retransmit_en,
        TX_BUSY          => s_can_ctrl3_tx_busy,
        TX_DONE          => s_can_ctrl3_tx_done,
        TX_FAILED        => s_can_ctrl3_tx_failed,

        BTL_TRIPLE_SAMPLING         => '0',
        BTL_PROP_SEG                => s_can_ctrl3_prop_seg,
        BTL_PHASE_SEG1              => s_can_ctrl3_phase_seg1,
        BTL_PHASE_SEG2              => s_can_ctrl3_phase_seg2,
        BTL_SYNC_JUMP_WIDTH         => s_can_ctrl3_sync_jump_width,

        TIME_QUANTA_CLOCK_SCALE     => to_unsigned(C_TIME_QUANTA_CLOCK_SCALE_VAL,
                                                   C_TIME_QUANTA_SCALE_WIDTH_DEFAULT),

        -- Error state and counters
        TRANSMIT_ERROR_COUNT => s_can_ctrl3_transmit_error_count,
        RECEIVE_ERROR_COUNT  => s_can_ctrl3_receive_error_count,
        ERROR_STATE          => s_can_ctrl3_error_state,

        -- Counter signals
        TX_MSG_SENT_COUNT_UP       => s_can_ctrl3_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP         => s_can_ctrl3_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP      => s_can_ctrl3_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP       => s_can_ctrl3_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP      => s_can_ctrl3_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP     => s_can_ctrl3_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP       => s_can_ctrl3_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP      => s_can_ctrl3_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP     => s_can_ctrl3_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP    => s_can_ctrl3_rx_stuff_error_count_up
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

    INST_canola_counters_2 : entity work.canola_counters
      generic map (
        G_COUNTER_WIDTH       => C_COUNTER_WIDTH,
        G_SATURATING_COUNTERS => true)
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl2_reset,

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

        TX_MSG_SENT_COUNT_UP    => s_can_ctrl2_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP      => s_can_ctrl2_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP   => s_can_ctrl2_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP    => s_can_ctrl2_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP   => s_can_ctrl2_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP  => s_can_ctrl2_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP    => s_can_ctrl2_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP   => s_can_ctrl2_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP  => s_can_ctrl2_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP => s_can_ctrl2_rx_stuff_error_count_up,

        TX_MSG_SENT_COUNT_VALUE    => s_can_ctrl2_reg_tx_msg_sent_count,
        TX_FAILED_COUNT_VALUE      => s_can_ctrl2_reg_tx_failed_count,
        TX_ACK_ERROR_COUNT_VALUE   => s_can_ctrl2_reg_tx_ack_error_count,
        TX_ARB_LOST_COUNT_VALUE    => s_can_ctrl2_reg_tx_arb_lost_count,
        TX_BIT_ERROR_COUNT_VALUE   => s_can_ctrl2_reg_tx_bit_error_count,
        TX_RETRANSMIT_COUNT_VALUE  => s_can_ctrl2_reg_tx_retransmit_count,
        RX_MSG_RECV_COUNT_VALUE    => s_can_ctrl2_reg_rx_msg_recv_count,
        RX_CRC_ERROR_COUNT_VALUE   => s_can_ctrl2_reg_rx_crc_error_count,
        RX_FORM_ERROR_COUNT_VALUE  => s_can_ctrl2_reg_rx_form_error_count,
        RX_STUFF_ERROR_COUNT_VALUE => s_can_ctrl2_reg_rx_stuff_error_count
        );

    INST_canola_counters_3 : entity work.canola_counters
      generic map (
        G_COUNTER_WIDTH       => C_COUNTER_WIDTH,
        G_SATURATING_COUNTERS => true)
      port map (
        CLK   => s_clk,
        RESET => s_can_ctrl3_reset,

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

        TX_MSG_SENT_COUNT_UP    => s_can_ctrl3_tx_msg_sent_count_up,
        TX_FAILED_COUNT_UP      => s_can_ctrl3_tx_failed_count_up,
        TX_ACK_ERROR_COUNT_UP   => s_can_ctrl3_tx_ack_error_count_up,
        TX_ARB_LOST_COUNT_UP    => s_can_ctrl3_tx_arb_lost_count_up,
        TX_BIT_ERROR_COUNT_UP   => s_can_ctrl3_tx_bit_error_count_up,
        TX_RETRANSMIT_COUNT_UP  => s_can_ctrl3_tx_retransmit_count_up,
        RX_MSG_RECV_COUNT_UP    => s_can_ctrl3_rx_msg_recv_count_up,
        RX_CRC_ERROR_COUNT_UP   => s_can_ctrl3_rx_crc_error_count_up,
        RX_FORM_ERROR_COUNT_UP  => s_can_ctrl3_rx_form_error_count_up,
        RX_STUFF_ERROR_COUNT_UP => s_can_ctrl3_rx_stuff_error_count_up,

        TX_MSG_SENT_COUNT_VALUE    => s_can_ctrl3_reg_tx_msg_sent_count,
        TX_FAILED_COUNT_VALUE      => s_can_ctrl3_reg_tx_failed_count,
        TX_ACK_ERROR_COUNT_VALUE   => s_can_ctrl3_reg_tx_ack_error_count,
        TX_ARB_LOST_COUNT_VALUE    => s_can_ctrl3_reg_tx_arb_lost_count,
        TX_BIT_ERROR_COUNT_VALUE   => s_can_ctrl3_reg_tx_bit_error_count,
        TX_RETRANSMIT_COUNT_VALUE  => s_can_ctrl3_reg_tx_retransmit_count,
        RX_MSG_RECV_COUNT_VALUE    => s_can_ctrl3_reg_rx_msg_recv_count,
        RX_CRC_ERROR_COUNT_VALUE   => s_can_ctrl3_reg_rx_crc_error_count,
        RX_FORM_ERROR_COUNT_VALUE  => s_can_ctrl3_reg_rx_form_error_count,
        RX_STUFF_ERROR_COUNT_VALUE => s_can_ctrl3_reg_rx_stuff_error_count
        );


    -- Aliases to some signals deep in the controller hierarchy
    -- that the testbench needs access to
    process is
      alias a_can_ctrl1_sample_point_tx is << signal INST_canola_top_1.INST_canola_btl.s_sample_point_tx : std_logic >>;

      alias a_can_ctrl1_tx_fsm_state is << signal INST_canola_top_1.INST_canola_frame_tx_fsm.s_fsm_state_voted : work.canola_pkg.can_frame_tx_fsm_state_t >>;

      alias a_can_ctrl1_recessive_bits_count is << signal INST_canola_top_1.s_eml_recessive_bit_count_value : std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0) >>;
    begin
      while true loop
        s_can_ctrl1_sample_point_tx      <= a_can_ctrl1_sample_point_tx;
        s_can_ctrl1_tx_fsm_state         <= a_can_ctrl1_tx_fsm_state;
        s_can_ctrl1_recessive_bits_count <= unsigned(a_can_ctrl1_recessive_bits_count);

        -- Update on changes to any of these signals
        wait on a_can_ctrl1_tx_fsm_state,
          a_can_ctrl1_sample_point_tx,
          a_can_ctrl1_recessive_bits_count;

      end loop;
    end process;
  end generate if_not_TMR_generate;



  -- Monitor CAN controller and indicate when it has received a message (rx_msg_valid is pulsed)
  p_can_ctrl_rx_msg: process (s_can_ctrl1_rx_msg_valid, s_can_ctrl2_rx_msg_valid,
                              s_can_ctrl3_rx_msg_valid, s_msg_reset) is
  begin
    if s_msg_reset = '1' then
      s_msg_ctrl1_received <= '0';
      s_msg_ctrl2_received <= '0';
      s_msg_ctrl3_received <= '0';
    else
      if s_can_ctrl1_rx_msg_valid = '1' then
        s_msg_ctrl1_received <= '1';
        s_msg_ctrl1          <= s_can_ctrl1_rx_msg;
      end if;

      if s_can_ctrl2_rx_msg_valid = '1' then
        s_msg_ctrl2_received <= '1';
        s_msg_ctrl2          <= s_can_ctrl2_rx_msg;
      end if;

      if s_can_ctrl3_rx_msg_valid = '1' then
        s_msg_ctrl3_received <= '1';
        s_msg_ctrl3          <= s_can_ctrl3_rx_msg;
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
        rand_id                 := natural(round(rand_real * real(2**11-1)));
        arb_id                  := (others => '0');
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

    variable v_tx_msg_sent_count               : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_arb_lost_count                  : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_ack_error_count                 : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_tx_bit_error_count              : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_msg_count                    : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_crc_error_count              : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_form_error_count             : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_rx_stuff_error_count            : std_logic_vector(C_COUNTER_WIDTH-1 downto 0);
    variable v_receive_error_count             : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
    variable v_11_recessive_bits_count_prev    : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);

    variable v_rand_baud_delay : natural;
    variable v_rand_real       : real;

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);

    if G_TMR_TOP_MODULE_EN and G_SEE_MITIGATION_EN then
      set_log_file_name("log/canola_top_tb_tmr_wrap_tmr_log.txt");
    elsif G_TMR_TOP_MODULE_EN and not G_SEE_MITIGATION_EN then
      set_log_file_name("log/canola_top_tb_tmr_wrap_no_tmr_log.txt");
    else
      set_log_file_name("log/canola_top_tb_no_tmr_log.txt");
    end if;


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Start simulation of CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------

    s_clock_ena <= true;                -- to start clock generator
    pulse(s_can_ctrl1_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

    -- Disable controller 2 and 3 by putting them in reset
    s_can_ctrl2_reset <= '1';
    s_can_ctrl3_reset <= '1';

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #1: Basic ID msg from BFM to Canola CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '0';

    while v_test_num < C_NUM_ITERATIONS loop
      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);



      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      wait until rising_edge(s_clk);

      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send random message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     C_CAN_RX_NO_ERROR_GEN);

      wait until s_msg_ctrl1_received = '1' for 10*C_CAN_BAUD_PERIOD;

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

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    check_value(to_integer(unsigned(s_can_ctrl1_reg_rx_msg_recv_count)), C_NUM_ITERATIONS,
                error, "Check number of received messages in CAN controller.");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #2: Basic ID msg from Canola CAN controller to BFM", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '0';

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);
      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      can_uvvm_check(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     '0', -- Don't send remote request and expect response
                     v_xmit_data,
                     v_xmit_data_length,
                     "Receive and check message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     error);

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    check_value(to_integer(unsigned(s_can_ctrl1_reg_tx_msg_sent_count)), C_NUM_ITERATIONS,
                error, "Check number of transmitted messages from CAN controller.");
    check_value(to_integer(unsigned(s_can_ctrl1_reg_tx_ack_error_count)), 0,
                error, "Check number of acknowledge errors in CAN controller.");

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #3: Extended ID msg from BFM to Canola CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    while v_test_num < C_NUM_ITERATIONS loop
      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      wait until rising_edge(s_clk);

      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send random message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     C_CAN_RX_NO_ERROR_GEN);

      wait until s_msg_ctrl1_received = '1' for 10*C_CAN_BAUD_PERIOD;

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

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    check_value(to_integer(unsigned(s_can_ctrl1_reg_rx_msg_recv_count)), C_NUM_ITERATIONS*2,
                error, "Check number of received messages in CAN controller.");

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #4: Extended ID msg from Canola CAN controller to BFM", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    while v_test_num < C_NUM_ITERATIONS loop
      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);
      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      can_uvvm_check(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     '0', -- Don't send remote request and expect response
                     v_xmit_data,
                     v_xmit_data_length,
                     "Receive and check message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     error);

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    check_value(to_integer(unsigned(s_can_ctrl1_reg_tx_msg_sent_count)), C_NUM_ITERATIONS*2,
                error, "Check number of transmitted messages from CAN controller.");
    check_value(to_integer(unsigned(s_can_ctrl1_reg_tx_ack_error_count)), 0,
                error, "Check number of acknowledge errors in CAN controller.");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #5: Test loss of arbitration", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    -- Start with retransmits disabled for this test
    s_can_ctrl1_tx_retransmit_en <= '0';

    while v_test_num < C_NUM_ITERATIONS loop
      log(ID_SEQUENCER, "Iteration #" & to_string(v_test_num), C_SCOPE);

      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      -- Todo
      -- Start can_uvvm_write() with a higher priority ID at the same time as
      -- transmitting with Canola controller
      -- Check that we still receive the message sent from the BFM?
      -- Check that counter for arbitration loss increases
      -- Check that message is retransmitted? (need to include this in controller...)
      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);
      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;

      -- Make arbitration ID for BFM lower than ID used by CAN controller,
      -- so that BFM will win the arbitration
      if unsigned(v_xmit_arb_id) = 0 then
        s_can_ctrl1_tx_msg.arb_id_a(0) <= '1';
      else
        v_xmit_arb_id := std_logic_vector(unsigned(v_xmit_arb_id) - 1);
      end if;

      wait until rising_edge(s_can_ctrl1_sample_point_tx);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      wait until rising_edge(s_can_ctrl1_sample_point_tx);

      -- Start transmitting from BFM
      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send higher priority message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     C_CAN_RX_NO_ERROR_GEN);

      -- The CAN controller should be able to receive the message that was
      -- sent by the BFM, even though the CAN controller was attempting to send
      -- its own message and lost arbitration.
      -- Verify that we were able to receive the BFM's message
      check_value(s_msg_ctrl1_received, '1', error, "Check that Canola received msg that arb. was lost to.");

      check_value(to_integer(unsigned(s_can_ctrl1_reg_tx_arb_lost_count)), v_test_num+1,
                  error, "Check arbitration loss count in CAN controller.");

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

      if s_can_ctrl1_tx_retransmit_en = '1' then
        -- Now verify that the Canola controller successfully retransmits the message
        can_uvvm_check(s_can_ctrl1_tx_msg.arb_id_a,
                       s_can_ctrl1_tx_msg.arb_id_b,
                       v_xmit_ext_id,
                       v_xmit_remote_frame,
                       '0',  -- Don't send remote request and expect response
                       v_xmit_data,
                       v_xmit_data_length,
                       "Receive and check message with CAN BFM",
                       s_clk,
                       s_can_bfm_tx,
                       s_can_bfm_rx,
                       error);
      else
        check_value(s_can_ctrl1_tx_busy, '0', error, "Retransmit disabled: controller should not be busy");
        -- Todo: Check that Tx failed.. but since it's pulsed it has to be done
        -- at the right time. Or I can just check the counter??
      end if;

      -- Alternate between having retransmits enabled or not
      s_can_ctrl1_tx_retransmit_en <= not s_can_ctrl1_tx_retransmit_en;

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;

      log(ID_SEQUENCER, "", C_SCOPE);
    end loop;

    -- Disable retransmits again
    s_can_ctrl1_tx_retransmit_en <= '0';

    check_value(to_integer(unsigned(s_can_ctrl1_reg_tx_arb_lost_count)), v_test_num,
                error, "Check number of lost arbitrations in CAN controller.");
    check_value(to_integer(unsigned(s_can_ctrl1_reg_rx_msg_recv_count)), C_NUM_ITERATIONS*3,
                error, "Check number of received messages in CAN controller.");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #6: Test winning arbitration, and missing ack", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    v_can_bfm_config.ack_missing_severity := NO_ALERT;

    while v_test_num < C_NUM_ITERATIONS loop
      if s_can_ctrl1_error_state /= ERROR_ACTIVE then
        pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");
      end if;

      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      v_arb_lost_count := s_can_ctrl1_reg_tx_arb_lost_count;
      v_ack_error_count := s_can_ctrl1_reg_tx_ack_error_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;

      if unsigned(v_xmit_arb_id) = 0 then
        v_xmit_arb_id(0) := '1';
      end if;

      -- Make arbitration ID for CAN controller 1 lower than ID used by BFM,
      -- so that the CAN controller will win the arbitration
      v_xmit_arb_id := std_logic_vector(unsigned(v_xmit_arb_id) - 1);

      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      v_xmit_arb_id := std_logic_vector(unsigned(v_xmit_arb_id) + 1);

      wait until rising_edge(s_can_ctrl1_sample_point_tx);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      wait until rising_edge(s_can_ctrl1_sample_point_tx);

      -- Start transmitting from BFM. It should lose the arbitration
      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send higher priority message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     C_CAN_RX_NO_ERROR_GEN);

      -- Expect error flag from CAN controller due to missing ACK,
      -- since BFM should have lost arbitration and was not receiving
      -- so no ACK has been sent
      can_uvvm_recv_active_error_flag(200, "Receive error flag with CAN BFM", s_can_bfm_rx);

      wait until s_can_ctrl1_tx_busy = '0'
        for 200*C_CAN_BAUD_PERIOD;

      check_value(s_can_ctrl1_tx_busy, '0', error, "Check that CAN controller is not busy anymore.");

      -- Arbitration loss count should not have increased
      check_value(s_can_ctrl1_reg_tx_arb_lost_count, v_arb_lost_count,
                  error, "Check arbitration loss count in CAN controller.");

      -- Ack error count should have increased, because when
      -- can_uvvm_write() failed mid-transaction due to arbitration loss, there
      -- was no way for the BFM to receive the message and acknowledge it
      check_value(unsigned(s_can_ctrl1_reg_tx_ack_error_count),
                  unsigned(v_ack_error_count)+1,
                  error, "Check ACK received count in CAN controller.");

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    v_can_bfm_config.ack_missing_severity := FAILURE;

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #7: Test CRC error in received message", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num := 0;

    while v_test_num < C_NUM_ITERATIONS loop

      if s_can_ctrl1_error_state /= ERROR_ACTIVE then
        pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");
      end if;

      v_can_bfm_config.crc_error_severity := NOTE;

      v_rx_msg_count         := s_can_ctrl1_reg_rx_msg_recv_count;
      v_rx_crc_error_count   := s_can_ctrl1_reg_rx_crc_error_count;
      v_rx_form_error_count  := s_can_ctrl1_reg_rx_form_error_count;
      v_rx_stuff_error_count := s_can_ctrl1_reg_rx_stuff_error_count;
      v_receive_error_count  := s_can_ctrl1_receive_error_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      v_can_rx_error_gen := (crc_error   => true,
                             stuff_error => false,
                             form_error  => false);

      -- Start transmitting from BFM
      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send message with CRC error with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     v_can_rx_error_gen,
                     v_can_bfm_config);

      check_value(v_can_tx_status.got_active_error_flag, true, error,
                  "Check that active error flag was received from CAN controller");

      check_value(v_can_tx_status.crc_error_flag, true, error,
                  "Check that error flag was issued due to CRC error");

      -- Received message count should not have increased, because receiving this
      -- message was supposed to fail..
      check_value(s_can_ctrl1_reg_rx_msg_recv_count, v_rx_msg_count,
                  error, "Check received message count in CAN controller.");

      -- Expecting increase by one since we asked to generate a CRC error
      check_value(unsigned(s_can_ctrl1_reg_rx_crc_error_count),
                  unsigned(v_rx_crc_error_count)+1,
                  error, "Check received CRC error count in CAN controller.");

      -- Not expecting increase, we did not generate a stuff error
      check_value(s_can_ctrl1_reg_rx_stuff_error_count, v_rx_stuff_error_count,
                  error, "Check received stuff error count in CAN controller.");

      -- Not expecting increase, we did not generate a form error
      check_value(s_can_ctrl1_reg_rx_form_error_count, v_rx_form_error_count,
                  error, "Check received form error count in CAN controller.");

      -- TODO: Add this test after EML is connected to Rx Frame FSM....
      -- Expecting increase by one in receive error count
      --check_value(s_can_ctrl1_receive_error_count, v_receive_error_count+1,
      --            error, "Check receive error count in CAN controller.");

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);


      v_test_num := v_test_num + 1;
    end loop;

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #8: Test stuff error in received message", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num := 0;
    v_can_bfm_config.crc_error_severity  := failure;

    while v_test_num < C_NUM_ITERATIONS loop

      if s_can_ctrl1_error_state /= ERROR_ACTIVE then
        pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");
      end if;

      v_rx_msg_count         := s_can_ctrl1_reg_rx_msg_recv_count;
      v_rx_crc_error_count   := s_can_ctrl1_reg_rx_crc_error_count;
      v_rx_form_error_count  := s_can_ctrl1_reg_rx_form_error_count;
      v_rx_stuff_error_count := s_can_ctrl1_reg_rx_stuff_error_count;
      v_receive_error_count  := s_can_ctrl1_receive_error_count;

      -- Generate random data frame. To guarantee that stuff errors can be
      -- generated in the frame, we want a data frame where we can force a byte
      -- of data to one value.
      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id,
                                   '0');  -- Don't allow remote frame

      -- Ensure that message will have at least one stuff bit,
      -- by forcing data frames with minimum 1 byte data length
      v_xmit_remote_frame := '0';
      if v_xmit_data_length = 0 then
        v_xmit_data_length := 1;
      end if;
      v_xmit_data(0) := (others => '1');

      v_can_rx_error_gen := (crc_error   => false,
                             stuff_error => true,
                             form_error  => false);

      -- Start transmitting from BFM
      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send message with stuff error with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     v_can_rx_error_gen);

      -- Expect error flag from CAN controller due to missing ACK,
      -- since BFM should have lost arbitration and was not receiving
      -- so no ACK has been sent
      can_uvvm_recv_active_error_flag(200, "Receive error flag with CAN BFM", s_can_bfm_rx);

      -- Wait for a baud before checking error counters
      wait until rising_edge(s_can_baud_clk);

      -- Received message count should not have increased, because receiving this
      -- message was supposed to fail..
      check_value(s_can_ctrl1_reg_rx_msg_recv_count, v_rx_msg_count,
                  error, "Check received message count in CAN controller.");

      -- Not expecting increase, we did not generate a CRC error
      check_value(s_can_ctrl1_reg_rx_crc_error_count, v_rx_crc_error_count,
                  error, "Check received CRC error count in CAN controller.");

      -- Expecting increase by one since we asked to generate a stuff error
      check_value(unsigned(s_can_ctrl1_reg_rx_stuff_error_count),
                  unsigned(v_rx_stuff_error_count)+1,
                  error, "Check received stuff error count in CAN controller.");

      -- Not expecting increase, we did not generate a form error
      check_value(s_can_ctrl1_reg_rx_form_error_count, v_rx_form_error_count,
                  error, "Check received form error count in CAN controller.");

      -- TODO: Add this test after EML is connected to Rx Frame FSM....
      -- Expecting increase by one in receive error count
      --check_value(unsigned(s_can_ctrl1_receive_error_count),
      --            unsigned(v_receive_error_count)+1,
      --            error, "Check receive error count in CAN controller.");

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #9: Test form error in received message", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num                           := 0;
    v_xmit_ext_id                        := '1';
    v_can_bfm_config.form_error_severity := note;

    while v_test_num < C_NUM_ITERATIONS loop

      if s_can_ctrl1_error_state /= ERROR_ACTIVE then
        pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");
      end if;

      v_rx_msg_count         := s_can_ctrl1_reg_rx_msg_recv_count;
      v_rx_crc_error_count   := s_can_ctrl1_reg_rx_crc_error_count;
      v_rx_form_error_count  := s_can_ctrl1_reg_rx_form_error_count;
      v_rx_stuff_error_count := s_can_ctrl1_reg_rx_stuff_error_count;
      v_receive_error_count  := s_can_ctrl1_receive_error_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      v_can_rx_error_gen := (crc_error   => false,
                             stuff_error => false,
                             form_error  => true);

      -- Start transmitting from BFM
      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send message with form error with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     v_can_rx_error_gen,
                     v_can_bfm_config);

      -- Wait two bauds before checking error counters
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      check_value(v_can_tx_status.got_active_error_flag, true, error,
                  "Check that active error flag was received from CAN controller");

      check_value(v_can_tx_status.form_error_flag, true, error,
                  "Check that error flag was issued due to Form error");

      -- Received message count should not have increased, because receiving this
      -- message was supposed to fail..
      check_value(s_can_ctrl1_reg_rx_msg_recv_count, v_rx_msg_count,
                  error, "Check received message count in CAN controller.");

      -- Not expecting increase, we did not generate a CRC error
      check_value(s_can_ctrl1_reg_rx_crc_error_count, v_rx_crc_error_count,
                  error, "Check received CRC error count in CAN controller.");

      -- Not expecting increase, we did not generate a stuff error
      check_value(s_can_ctrl1_reg_rx_stuff_error_count, v_rx_stuff_error_count,
                  error, "Check received stuff error count in CAN controller.");

      -- Expecting increase by one since we asked to generate a form error
      check_value(unsigned(s_can_ctrl1_reg_rx_form_error_count),
                  unsigned(v_rx_form_error_count)+1,
                  error, "Check received form error count in CAN controller.");

      -- TODO: Add this test after EML is connected to Rx Frame FSM....
      -- Expecting increase by one in receive error count
      --check_value(s_can_ctrl1_receive_error_count, v_receive_error_count+1,
      --            error, "Check receive error count in CAN controller.");

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #10: Test ERROR ACTIVE->PASSIVE on missing ACKs, but not BUS OFF", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");

    -- In this test the CAN controller sends messages, but receives no ACK.
    -- This should increase the transmit error counter to the error passive threshold,
    -- causing the controller to become error passive. But the counter should not
    -- increase further on missing ACK after that.
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    v_can_bfm_config.ack_missing_severity := NO_ALERT;

    -- Transmit Error Count (TEC) increases by 8 per missing ack
    -- Run test till twice the amount of time it would take to bring the
    -- controller into BUS OFF, if the TEC increased by 8 every time.
    -- The controller should not actually go into BUS OFF for missing ack,
    -- it should stop in ERROR PASSIVE, and we want to verify that
    while v_test_num < 2*C_BUS_OFF_THRESHOLD/8 loop
      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      v_arb_lost_count    := s_can_ctrl1_reg_tx_arb_lost_count;
      v_ack_error_count   := s_can_ctrl1_reg_tx_ack_error_count;
      v_tx_msg_sent_count := s_can_ctrl1_reg_tx_msg_sent_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;
      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      if s_can_ctrl1_error_state = ERROR_ACTIVE then
        -- Expect error flag from CAN controller due to missing ACK
        -- (but only when in ERROR ACTIVE state)
        can_uvvm_recv_active_error_flag(200,
                                        "Expect active error flag when controller is error active",
                                        s_can_bfm_rx);
      end if;

      wait until s_can_ctrl1_tx_busy = '0'
        for 200*C_CAN_BAUD_PERIOD;

      check_value(s_can_ctrl1_tx_busy, '0', error, "Check that CAN controller is not busy anymore.");

      -- Arbitration loss count should not have increased
      check_value(s_can_ctrl1_reg_tx_arb_lost_count, v_arb_lost_count,
                  error, "Check arbitration loss count in CAN controller.");

      -- Message sent count should not increase when no ACK is received
      check_value(s_can_ctrl1_reg_tx_msg_sent_count, v_tx_msg_sent_count,
                  error, "Check msg sent count no increase in CAN controller.");

      check_value(unsigned(s_can_ctrl1_reg_tx_ack_error_count),
                  unsigned(v_ack_error_count)+1,
                  error, "Check ACK received count in CAN controller.");

      -- Error count should only increase while ERROR ACTIVE
      if s_can_ctrl1_transmit_error_count < C_ERROR_PASSIVE_THRESHOLD then
        check_value(to_integer(s_can_ctrl1_transmit_error_count), (v_test_num+1) * 8,
                    error, "Check that transmit error count increased by eight");
      else
        check_value(to_integer(s_can_ctrl1_transmit_error_count), C_ERROR_PASSIVE_THRESHOLD,
                    error, "Check no transmit error count increase on missing ACK in error passive");
      end if;

      if s_can_ctrl1_transmit_error_count < C_ERROR_PASSIVE_THRESHOLD then
        check_value(s_can_ctrl1_error_state, ERROR_ACTIVE, error, "Check that controller is error active");
      else
        check_value(s_can_ctrl1_error_state, ERROR_PASSIVE, error, "Check that controller is error passive");
      end if;

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;


    -----------------------------------------------------------------------------------------------
    -- Now test that the controller returns to error active after a succesful transmit
    -----------------------------------------------------------------------------------------------
    v_test_num := 0;

    while v_test_num < C_ERROR_PASSIVE_THRESHOLD loop
      v_arb_lost_count    := s_can_ctrl1_reg_tx_arb_lost_count;
      v_ack_error_count   := s_can_ctrl1_reg_tx_ack_error_count;
      v_tx_msg_sent_count := s_can_ctrl1_reg_tx_msg_sent_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;
      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      can_uvvm_check(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     '0',  -- Don't send remote request and expect response
                     v_xmit_data,
                     v_xmit_data_length,
                     "Receive and check message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     error);

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      -- Arbitration loss count should not have increased
      check_value(s_can_ctrl1_reg_tx_arb_lost_count, v_arb_lost_count,
                  error, "Check arbitration loss count in CAN controller.");

      -- Message sent count should increase when ACK is received
      check_value(unsigned(s_can_ctrl1_reg_tx_msg_sent_count),
                  unsigned(v_tx_msg_sent_count)+1,
                  error, "Check msg sent count increase in CAN controller.");

      -- Ack error count should not have increased
      check_value(s_can_ctrl1_reg_tx_ack_error_count, v_ack_error_count,
                  error, "Check ACK error count should not increase in CAN controller.");

      -- Message should be successfully sent, which indicates ACK was received
      check_value(unsigned(s_can_ctrl1_reg_tx_msg_sent_count), unsigned(v_tx_msg_sent_count)+1,
                  error, "Check msg sent count increased in CAN controller.");

      check_value(to_integer(s_can_ctrl1_transmit_error_count), C_ERROR_PASSIVE_THRESHOLD-(v_test_num+1),
                  error, "Check that transmit error count decreased on successful transmit");

      check_value(s_can_ctrl1_error_state, ERROR_ACTIVE, error, "Check that controller is now error active");

      v_test_num := v_test_num + 1;

    end loop;


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #12: Test that BUS OFF state is reached after too many Tx errors", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");

    -- In this test the CAN controller sends messages, and the BFM is not listening.
    -- After the controller is done with the arbitration field, a bit error is
    -- generated on the bus signals, which should be interpreted as a Tx bit
    -- error by the controller.
    -- These bit errors should cause the Transmit Error Counter (TEC) to increase,
    -- and the controller will go into error passive and eventually bus off state.
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    v_can_bfm_config.ack_missing_severity := FAILURE;

    while s_can_ctrl1_error_state /= BUS_OFF loop
      v_arb_lost_count     := s_can_ctrl1_reg_tx_arb_lost_count;
      v_tx_msg_sent_count  := s_can_ctrl1_reg_tx_msg_sent_count;
      v_ack_error_count    := s_can_ctrl1_reg_tx_ack_error_count;
      v_tx_bit_error_count := s_can_ctrl1_reg_tx_bit_error_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i)      <= v_xmit_data(i);
      end loop;

      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;
      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      log(ID_SEQUENCER, "Transmit from CAN controller", C_SCOPE);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait for 0 ns;  -- Delta cycle only
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      -- Wait till we're after the (extended) arbitration field
      wait until s_can_ctrl1_tx_fsm_state = ST_SETUP_EXT_RTR for 50*C_CAN_BAUD_PERIOD;

      uniform(seed1, seed2, v_rand_real);

      -- Wait for a random number of bauds, from 0 to 8
      v_rand_baud_delay := natural(round(v_rand_real * real(8)));
      wait for v_rand_baud_delay*C_CAN_BAUD_PERIOD;

      wait until s_can_bfm_rx = '0' for 7*C_CAN_BAUD_PERIOD;
      -- Wait till beginning of a high bit from CAN controller
      wait until rising_edge(s_can_bfm_rx) for 6*C_CAN_BAUD_PERIOD;

      check_value(s_can_bfm_rx, '1', error,
                  "Waited for 6 bauds and no high bit from CAN controller");

      -- Overwrite controller's high bit (recessive) with a low (dominant) value
      s_can_bfm_tx <= '0';
      wait for 0 ns;  -- Delta cycle only
      s_can_bfm_tx <= transport '1' after C_CAN_BAUD_PERIOD;

      wait for C_CAN_BAUD_PERIOD;

      -- Controller should generate an error flag
      if s_can_ctrl1_error_state = ERROR_ACTIVE then
        can_uvvm_recv_active_error_flag(0, -- Expect error active flag immediately in ERROR ACTIVE
                                        "Expect active error flag when controller is error active",
                                        s_can_bfm_rx);

      elsif s_can_ctrl1_error_state = ERROR_PASSIVE then
        can_uvvm_recv_passive_error_flag(0, -- Expect error passive flag immediately in ERROR PASSIVE
                                         "Expect passive error flag when controller is error passive",
                                         s_can_bfm_rx);
      end if;

      -- Wait beyond IFS after error flag
      wait until s_can_ctrl1_tx_busy = '0' for (C_IFS_LENGTH+1)*C_CAN_BAUD_PERIOD;

      check_value(s_can_ctrl1_tx_busy, '0', error, "Check that CAN controller is not busy");

      -- Arbitration loss count should not have increased
      check_value(s_can_ctrl1_reg_tx_arb_lost_count, v_arb_lost_count,
                  error, "Check arbitration loss count in CAN controller.");

      -- Message sent count should not have increased when ACKs are not received
      check_value(s_can_ctrl1_reg_tx_msg_sent_count, v_tx_msg_sent_count,
                  error, "Check msg sent count no increase in CAN controller.");

      -- Ack error count should not have increased
      check_value(s_can_ctrl1_reg_tx_ack_error_count, v_ack_error_count,
                  error, "Check ACK error count no increase in CAN controller.");

      -- Tx bit error count should have increased
      check_value(unsigned(s_can_ctrl1_reg_tx_bit_error_count),
                  unsigned(v_tx_bit_error_count)+1,
                  error, "Check Tx bit error increase in CAN controller.");

      check_value(to_integer(s_can_ctrl1_transmit_error_count), (v_test_num+1)*8,
                  error, "Check that transmit error count increase by 8");

      if unsigned(s_can_ctrl1_transmit_error_count) >= C_BUS_OFF_THRESHOLD then
        check_value(s_can_ctrl1_error_state, BUS_OFF, error, "Check error state.");
      elsif unsigned(s_can_ctrl1_transmit_error_count) >= C_ERROR_PASSIVE_THRESHOLD then
        check_value(s_can_ctrl1_error_state, ERROR_PASSIVE, error, "Check error state.");
      else
        check_value(s_can_ctrl1_error_state, ERROR_ACTIVE, error, "Check error state.");
      end if;

      v_test_num := v_test_num + 1;

    end loop;

    ----------------------------------------------------------------------------
    -- Controller should now be in BUS OFF state. Test that it will not transmit
    ----------------------------------------------------------------------------
    check_value(s_can_ctrl1_error_state, BUS_OFF, error, "Check error state.");

    wait for 6*C_CAN_BAUD_PERIOD;

    log(ID_SEQUENCER, "Attempt transmit with CAN controller in BUS OFF", C_SCOPE);

    -- Start transmitting from CAN controller
    wait until falling_edge(s_clk);
    s_can_ctrl1_tx_start <= '1';
    wait for 0 ns;  -- Delta cycle only
    s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

    wait until s_can_bfm_rx = '0' for 200*C_CAN_BAUD_PERIOD;
    check_value(s_can_bfm_rx, '1', error, "Check that no dominant bits were transmitted");

    ----------------------------------------------------------------------------
    -- Wait for 128 counts of 11 consecutive recessive bits,
    -- which should bring the controller back into ERROR ACTIVE.
    ----------------------------------------------------------------------------
    v_11_recessive_bits_count_prev := s_can_ctrl1_recessive_bits_count;

    while s_can_ctrl1_recessive_bits_count < C_11_RECESSIVE_EXIT_BUS_OFF_THRESHOLD-1 loop
      wait for 11*C_CAN_BAUD_PERIOD;

      check_value(s_can_ctrl1_recessive_bits_count,
                  v_11_recessive_bits_count_prev+1,
                  error, "Check count of 11 consecutive recess. bits increase");

      check_value_in_range(to_integer(s_can_ctrl1_transmit_error_count),
                           C_BUS_OFF_THRESHOLD,
                           2**s_can_ctrl1_transmit_error_count'length-1,
                           error,
                           "Check transmit error count >= BUS OFF threshold.");

      check_value(s_can_ctrl1_error_state, BUS_OFF, error, "Check error state is BUS OFF.");

      v_11_recessive_bits_count_prev := s_can_ctrl1_recessive_bits_count;
    end loop;

    -- Next increase in count of 11 recessive bits should bring us out of BUS OFF
    wait for 11*C_CAN_BAUD_PERIOD;

    -- Wait an additional baud to ensure that the 11 bits have been processed
    wait for C_CAN_BAUD_PERIOD;

    check_value(to_integer(s_can_ctrl1_recessive_bits_count), 0, error,
                "Check count of 11 consecutive recess. bits now zero.");

    check_value(s_can_ctrl1_error_state, ERROR_ACTIVE, error, "Check error state not bus off.");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #13: Test ERROR PASSIVE/ACTIVE states when receiving", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");
    v_test_num := 0;

    -- Generate errors till receive error count saturates
    while unsigned(s_can_ctrl1_receive_error_count) < C_BUS_OFF_THRESHOLD loop
      v_can_bfm_config.crc_error_severity   := NO_ALERT;
      v_can_bfm_config.form_error_severity  := NO_ALERT;
      v_can_bfm_config.ack_missing_severity := NO_ALERT;

      v_rx_msg_count         := s_can_ctrl1_reg_rx_msg_recv_count;
      v_rx_crc_error_count   := s_can_ctrl1_reg_rx_crc_error_count;
      v_rx_form_error_count  := s_can_ctrl1_reg_rx_form_error_count;
      v_rx_stuff_error_count := s_can_ctrl1_reg_rx_stuff_error_count;
      v_receive_error_count  := s_can_ctrl1_receive_error_count;

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      -- Alternate between generating CRC, stuff and form errors
      if v_test_num mod 3 = 0 then
        v_can_rx_error_gen := (crc_error   => true,
                               stuff_error => false,
                               form_error  => false);

        can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                       v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                       v_xmit_ext_id,
                       v_xmit_remote_frame,
                       v_xmit_data,
                       v_xmit_data_length,
                       "Send message with CRC error with CAN BFM",
                       s_clk,
                       s_can_bfm_tx,
                       s_can_bfm_rx,
                       v_can_tx_status,
                       v_can_rx_error_gen,
                       v_can_bfm_config);

      elsif v_test_num mod 3 = 1 then
        v_can_rx_error_gen := (crc_error   => false,
                               stuff_error => true,
                               form_error  => false);

        -- Ensure that message will have at least one stuff bit,
        -- by forcing data frames with minimum 1 byte data length
        v_xmit_remote_frame := '0';
        if v_xmit_data_length = 0 then
          v_xmit_data_length := 1;
        end if;
        v_xmit_data(0) := (others => '1');

        can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                       v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                       v_xmit_ext_id,
                       v_xmit_remote_frame,
                       v_xmit_data,
                       v_xmit_data_length,
                       "Send message with stuff error with CAN BFM",
                       s_clk,
                       s_can_bfm_tx,
                       s_can_bfm_rx,
                       v_can_tx_status,
                       v_can_rx_error_gen,
                       v_can_bfm_config);
      else
        v_can_rx_error_gen := (crc_error   => false,
                               stuff_error => false,
                               form_error  => true);

        can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                       v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                       v_xmit_ext_id,
                       v_xmit_remote_frame,
                       v_xmit_data,
                       v_xmit_data_length,
                       "Send message with form error with CAN BFM",
                       s_clk,
                       s_can_bfm_tx,
                       s_can_bfm_rx,
                       v_can_tx_status,
                       v_can_rx_error_gen,
                       v_can_bfm_config);
      end if;

      wait until v_receive_error_count /= s_can_ctrl1_receive_error_count
        for 20*C_CAN_BAUD_PERIOD;

      -- CRC, stuff and form errors increase receive error count by 1
      check_value(unsigned(s_can_ctrl1_receive_error_count),
                  unsigned(v_receive_error_count)+1,
                  error, "Check receive error count increase.");

      -- Check that correct error types were detected
      if v_can_rx_error_gen.crc_error then
        check_value(unsigned(s_can_ctrl1_reg_rx_crc_error_count),
                    unsigned(v_rx_crc_error_count)+1,
                    error, "Check received CRC error count in CAN controller.");
      elsif v_can_rx_error_gen.stuff_error then
        check_value(unsigned(s_can_ctrl1_reg_rx_stuff_error_count),
                    unsigned(v_rx_stuff_error_count)+1,
                    error, "Check received stuff error count in CAN controller.");
      else
        check_value(unsigned(s_can_ctrl1_reg_rx_form_error_count),
                    unsigned(v_rx_form_error_count)+1,
                    error, "Check received form error count in CAN controller.");
      end if;

      -- Wait one clock cycle to allow error state to update
      wait until rising_edge(s_clk);

      -- Check error state
      if unsigned(s_can_ctrl1_receive_error_count) >= C_ERROR_PASSIVE_THRESHOLD then
        check_value(s_can_ctrl1_error_state, ERROR_PASSIVE, error, "Check error state.");
      else
        check_value(s_can_ctrl1_error_state, ERROR_ACTIVE, error, "Check error state.");
      end if;


      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);


      v_test_num := v_test_num + 1;
    end loop;

    check_value(to_integer(unsigned(s_can_ctrl1_receive_error_count)), C_BUS_OFF_THRESHOLD,
                error, "Receive error count should be at BUS OFF threshold now.");

    check_value(s_can_ctrl1_error_state, ERROR_PASSIVE, error, "Receive errors should not cause BUS OFF");

    v_can_bfm_config.crc_error_severity   := FAILURE;
    v_can_bfm_config.form_error_severity  := FAILURE;

    -- Send some messages from BFM with wrong CRC or something, to increase error counters
    -- beyond error passive threshold
    -- Check that controller becomes error passive
    -- Check that controller sends passive error flags on errors now
    -- Check that controller returns to error active after succesfully receiving some messages


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #14: Test with multiple CAN controllers", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    pulse(s_can_ctrl1_reset, s_clk, 10, "Reset CAN controller to put it back in ACTIVE ERROR state");

    -- Bring controller #2 out of reset
    wait for 10*C_CLK_PERIOD;
    s_can_ctrl2_reset <= '0';

    -- Bring controller #3 out of reset
    wait for 10*C_CLK_PERIOD;
    s_can_ctrl3_reset <= '0';

    v_test_num := 0;

    while v_test_num < C_NUM_ITERATIONS loop
      --------------------------------------------------------------------------
      -- Transmit from CAN controller #1, receive with controller #2 and #3
      --------------------------------------------------------------------------
      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl1_tx_msg.data(i) <= v_xmit_data(i);
      end loop;

      s_can_ctrl1_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl1_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl1_tx_msg.remote_request <= v_xmit_remote_frame;
      s_can_ctrl1_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl1_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      log(ID_SEQUENCER, "Transmit from CAN controller #1", C_SCOPE);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl1_tx_start <= '1';
      wait for 0 ns;                    -- Delta cycle only
      s_can_ctrl1_tx_start <= transport '0' after C_CLK_PERIOD;

      wait until s_can_ctrl1_tx_busy = '0'
        for 200*C_CAN_BAUD_PERIOD;

      wait until s_msg_ctrl2_received = '1'
        for 10*C_CAN_BAUD_PERIOD;
      wait until s_msg_ctrl3_received = '1'
        for 10*C_CAN_BAUD_PERIOD;

      -- Check received messages
      check_value(s_msg_ctrl2_received, '1', error, "Check that CAN controller #2 received msg.");
      check_value(s_msg_ctrl3_received, '1', error, "Check that CAN controller #3 received msg.");

      check_value(s_msg_ctrl2, s_can_ctrl1_tx_msg, error, "Check msg received by #2");
      check_value(s_msg_ctrl3, s_can_ctrl1_tx_msg, error, "Check msg received by #3");


      --------------------------------------------------------------------------
      -- Transmit from CAN controller #2, receive with controller #1 and #3
      --------------------------------------------------------------------------
      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl2_tx_msg.data(i) <= v_xmit_data(i);
      end loop;

      s_can_ctrl2_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl2_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl2_tx_msg.remote_request <= v_xmit_remote_frame;
      s_can_ctrl2_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl2_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      log(ID_SEQUENCER, "Transmit from CAN controller #2", C_SCOPE);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl2_tx_start <= '1';
      wait for 0 ns;                    -- Delta cycle only
      s_can_ctrl2_tx_start <= transport '0' after C_CLK_PERIOD;

      wait until s_can_ctrl2_tx_busy = '0'
        for 200*C_CAN_BAUD_PERIOD;

      wait until s_msg_ctrl1_received = '1'
        for 10*C_CAN_BAUD_PERIOD;
      wait until s_msg_ctrl3_received = '1'
        for 10*C_CAN_BAUD_PERIOD;

      -- Check received messages
      check_value(s_msg_ctrl1_received, '1', error, "Check that CAN controller #1 received msg.");
      check_value(s_msg_ctrl3_received, '1', error, "Check that CAN controller #3 received msg.");

      check_value(s_msg_ctrl1, s_can_ctrl2_tx_msg, error, "Check msg received by #1");
      check_value(s_msg_ctrl3, s_can_ctrl2_tx_msg, error, "Check msg received by #3");


      --------------------------------------------------------------------------
      -- Transmit from CAN controller #3, receive with controller #1 and #2
      --------------------------------------------------------------------------
      s_msg_reset <= '1';
      wait until rising_edge(s_clk);
      s_msg_reset <= '0';
      wait until rising_edge(s_clk);

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      for i in 0 to 7 loop
        s_can_ctrl3_tx_msg.data(i) <= v_xmit_data(i);
      end loop;

      s_can_ctrl3_tx_msg.ext_id         <= v_xmit_ext_id;
      s_can_ctrl3_tx_msg.data_length    <= std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));
      s_can_ctrl3_tx_msg.remote_request <= v_xmit_remote_frame;
      s_can_ctrl3_tx_msg.arb_id_a       <= v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      s_can_ctrl3_tx_msg.arb_id_b       <= v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      log(ID_SEQUENCER, "Transmit from CAN controller #3", C_SCOPE);

      -- Start transmitting from CAN controller
      wait until falling_edge(s_clk);
      s_can_ctrl3_tx_start <= '1';
      wait for 0 ns;                    -- Delta cycle only
      s_can_ctrl3_tx_start <= transport '0' after C_CLK_PERIOD;

      wait until s_can_ctrl3_tx_busy = '0'
        for 200*C_CAN_BAUD_PERIOD;

      wait until s_msg_ctrl1_received = '1'
        for 10*C_CAN_BAUD_PERIOD;
      wait until s_msg_ctrl2_received = '1'
        for 10*C_CAN_BAUD_PERIOD;

      -- Check received messages
      check_value(s_msg_ctrl1_received, '1', error, "Check that CAN controller #1 received msg.");
      check_value(s_msg_ctrl2_received, '1', error, "Check that CAN controller #2 received msg.");

      check_value(s_msg_ctrl1, s_can_ctrl3_tx_msg, error, "Check msg received by #1");
      check_value(s_msg_ctrl2, s_can_ctrl3_tx_msg, error, "Check msg received by #2");


      v_test_num := v_test_num + 1;
    end loop;

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
