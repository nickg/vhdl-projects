-------------------------------------------------------------------------------
-- Title      : Status counters for Canola CAN controller
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_counters.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-02-12
-- Last update: 2020-09-12
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Status counters for Canola CAN controller
--              Uses up_counter instances directly without TMR wrapper
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-02-12  1.0      svn     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;

entity canola_counters is
  generic (
    G_COUNTER_WIDTH       : natural;
    G_SATURATING_COUNTERS : boolean  -- True: saturate, False: Wrap-around
    );
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    -- Clear counters
    CLEAR_TX_MSG_SENT_COUNT    : in std_logic;
    CLEAR_TX_FAILED_COUNT      : in std_logic;
    CLEAR_TX_ACK_ERROR_COUNT   : in std_logic;
    CLEAR_TX_ARB_LOST_COUNT    : in std_logic;
    CLEAR_TX_BIT_ERROR_COUNT   : in std_logic;
    CLEAR_TX_RETRANSMIT_COUNT  : in std_logic;
    CLEAR_RX_MSG_RECV_COUNT    : in std_logic;
    CLEAR_RX_CRC_ERROR_COUNT   : in std_logic;
    CLEAR_RX_FORM_ERROR_COUNT  : in std_logic;
    CLEAR_RX_STUFF_ERROR_COUNT : in std_logic;

    -- Signals to count up counters
    TX_MSG_SENT_COUNT_UP    : in std_logic;
    TX_FAILED_COUNT_UP      : in std_logic;
    TX_ACK_ERROR_COUNT_UP   : in std_logic;
    TX_ARB_LOST_COUNT_UP    : in std_logic;
    TX_BIT_ERROR_COUNT_UP   : in std_logic;
    TX_RETRANSMIT_COUNT_UP  : in std_logic;
    RX_MSG_RECV_COUNT_UP    : in std_logic;
    RX_CRC_ERROR_COUNT_UP   : in std_logic;
    RX_FORM_ERROR_COUNT_UP  : in std_logic;
    RX_STUFF_ERROR_COUNT_UP : in std_logic;

    -- Counter values
    TX_MSG_SENT_COUNT_VALUE    : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    TX_FAILED_COUNT_VALUE      : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    TX_ACK_ERROR_COUNT_VALUE   : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    TX_ARB_LOST_COUNT_VALUE    : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    TX_BIT_ERROR_COUNT_VALUE   : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    TX_RETRANSMIT_COUNT_VALUE  : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    RX_MSG_RECV_COUNT_VALUE    : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    RX_CRC_ERROR_COUNT_VALUE   : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    RX_FORM_ERROR_COUNT_VALUE  : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
    RX_STUFF_ERROR_COUNT_VALUE : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0)
    );

end entity canola_counters;

architecture struct of canola_counters is
  signal s_tx_msg_sent_count_value    : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_tx_failed_count_value      : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_tx_ack_error_count_value   : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_tx_arb_lost_count_value    : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_tx_bit_error_count_value   : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_tx_retransmit_count_value  : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_rx_msg_recv_count_value    : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_rx_crc_error_count_value   : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_rx_form_error_count_value  : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
  signal s_rx_stuff_error_count_value : std_logic_vector(G_COUNTER_WIDTH-1 downto 0);
begin  -- architecture struct

  TX_MSG_SENT_COUNT_VALUE    <= s_tx_msg_sent_count_value;
  TX_FAILED_COUNT_VALUE      <= s_tx_failed_count_value;
  TX_ACK_ERROR_COUNT_VALUE   <= s_tx_ack_error_count_value;
  TX_ARB_LOST_COUNT_VALUE    <= s_tx_arb_lost_count_value;
  TX_BIT_ERROR_COUNT_VALUE   <= s_tx_bit_error_count_value;
  TX_RETRANSMIT_COUNT_VALUE  <= s_tx_retransmit_count_value;
  RX_MSG_RECV_COUNT_VALUE    <= s_rx_msg_recv_count_value;
  RX_CRC_ERROR_COUNT_VALUE   <= s_rx_crc_error_count_value;
  RX_FORM_ERROR_COUNT_VALUE  <= s_rx_form_error_count_value;
  RX_STUFF_ERROR_COUNT_VALUE <= s_rx_stuff_error_count_value;


  -----------------------------------------------------------------------------
  -- Status counters (messages sent/received, error counts)
  -----------------------------------------------------------------------------
  INST_tx_msg_sent_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_MSG_SENT_COUNT,
      COUNT_UP       => TX_MSG_SENT_COUNT_UP,
      COUNT_OUT      => s_tx_msg_sent_count_value,
      COUNT_VOTED_IN => s_tx_msg_sent_count_value);

  INST_tx_failed_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_FAILED_COUNT,
      COUNT_UP       => TX_FAILED_COUNT_UP,
      COUNT_OUT      => s_tx_failed_count_value,
      COUNT_VOTED_IN => s_tx_failed_count_value);

  INST_tx_ack_error_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_ACK_ERROR_COUNT,
      COUNT_UP       => TX_ACK_ERROR_COUNT_UP,
      COUNT_OUT      => s_tx_ack_error_count_value,
      COUNT_VOTED_IN => s_tx_ack_error_count_value);

  INST_tx_arb_lost_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_ARB_LOST_COUNT,
      COUNT_UP       => TX_ARB_LOST_COUNT_UP,
      COUNT_OUT      => s_tx_arb_lost_count_value,
      COUNT_VOTED_IN => s_tx_arb_lost_count_value);

  INST_tx_bit_error_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_BIT_ERROR_COUNT,
      COUNT_UP       => TX_BIT_ERROR_COUNT_UP,
      COUNT_OUT      => s_tx_bit_error_count_value,
      COUNT_VOTED_IN => s_tx_bit_error_count_value);

  INST_tx_retransmit_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_RETRANSMIT_COUNT,
      COUNT_UP       => TX_RETRANSMIT_COUNT_UP,
      COUNT_OUT      => s_tx_retransmit_count_value,
      COUNT_VOTED_IN => s_tx_retransmit_count_value);

  INST_rx_msg_recv_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_MSG_RECV_COUNT,
      COUNT_UP       => RX_MSG_RECV_COUNT_UP,
      COUNT_OUT      => s_rx_msg_recv_count_value,
      COUNT_VOTED_IN => s_rx_msg_recv_count_value);

  INST_rx_crc_error_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_CRC_ERROR_COUNT,
      COUNT_UP       => RX_CRC_ERROR_COUNT_UP,
      COUNT_OUT      => s_rx_crc_error_count_value,
      COUNT_VOTED_IN => s_rx_crc_error_count_value);

  INST_rx_form_error_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_FORM_ERROR_COUNT,
      COUNT_UP       => RX_FORM_ERROR_COUNT_UP,
      COUNT_OUT      => s_rx_form_error_count_value,
      COUNT_VOTED_IN => s_rx_form_error_count_value);

  INST_rx_stuff_error_counter: entity work.up_counter
    generic map (
      BIT_WIDTH     => G_COUNTER_WIDTH,
      IS_SATURATING => G_SATURATING_COUNTERS,
      VERBOSE       => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_STUFF_ERROR_COUNT,
      COUNT_UP       => RX_STUFF_ERROR_COUNT_UP,
      COUNT_OUT      => s_rx_stuff_error_count_value,
      COUNT_VOTED_IN => s_rx_stuff_error_count_value);

end architecture struct;
