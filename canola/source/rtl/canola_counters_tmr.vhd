-------------------------------------------------------------------------------
-- Title      : Status counters for Canola CAN controller
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_counters_tmr.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-02-12
-- Last update: 2020-09-12
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Status counters for Canola CAN controller
--              Uses the TMR wrappers for the up_counter instances,
--              which allows for triplication.
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-02-12  1.0      svn     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;

entity canola_counters_tmr is
  generic (
    G_SEE_MITIGATION_EN   : boolean := true; -- Enable TMR
    G_MISMATCH_OUTPUT_EN  : boolean := true; -- Enable TMR voter mismatch output
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
    RX_STUFF_ERROR_COUNT_VALUE : out std_logic_vector(G_COUNTER_WIDTH-1 downto 0);

    VOTER_MISMATCH : out std_logic
    );

end entity canola_counters_tmr;

architecture struct of canola_counters_tmr is

  -- Voter mismatch for status counters
  constant C_mismatch_tx_msg_sent_count    : integer := 0;
  constant C_mismatch_tx_failed_count      : integer := 1;
  constant C_mismatch_tx_ack_error_count   : integer := 2;
  constant C_mismatch_tx_arb_lost_count    : integer := 3;
  constant C_mismatch_tx_bit_error_count   : integer := 4;
  constant C_mismatch_tx_retransmit_count  : integer := 5;
  constant C_mismatch_rx_msg_recv_count    : integer := 6;
  constant C_mismatch_rx_crc_error_count   : integer := 7;
  constant C_mismatch_rx_form_error_count  : integer := 8;
  constant C_mismatch_rx_stuff_error_count : integer := 9;
  constant C_MISMATCH_WIDTH                : integer := 10;
  signal s_mismatch_vector                 : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0);

  -- Register mismatch outputs from counters
  constant C_MISMATCH_OUTPUT_REG : boolean := true;

begin  -- architecture struct

  -- Register mismatch output when TMR is enabled
  if_TMR_gen : if G_SEE_MITIGATION_EN generate
    proc_mismatch_reg : process (CLK) is
    begin
      if rising_edge(CLK) then
        VOTER_MISMATCH <= or_reduce(s_mismatch_vector);
      end if;
    end process proc_mismatch_reg;
  end generate if_TMR_gen;

  if_not_TMR_gen : if not G_SEE_MITIGATION_EN generate
    VOTER_MISMATCH <= '0';
  end generate if_not_TMR_gen;

  -----------------------------------------------------------------------------
  -- Status counters (messages sent/received, error counts)
  -----------------------------------------------------------------------------
  INST_tx_msg_sent_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_MSG_SENT_COUNT,
      COUNT_UP       => TX_MSG_SENT_COUNT_UP,
      COUNT_OUT      => TX_MSG_SENT_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_tx_msg_sent_count));

  INST_tx_failed_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_FAILED_COUNT,
      COUNT_UP       => TX_FAILED_COUNT_UP,
      COUNT_OUT      => TX_FAILED_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_tx_failed_count));

  INST_tx_ack_error_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_ACK_ERROR_COUNT,
      COUNT_UP       => TX_ACK_ERROR_COUNT_UP,
      COUNT_OUT      => TX_ACK_ERROR_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_tx_ack_error_count));

  INST_tx_arb_lost_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_ARB_LOST_COUNT,
      COUNT_UP       => TX_ARB_LOST_COUNT_UP,
      COUNT_OUT      => TX_ARB_LOST_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_tx_arb_lost_count));

  INST_tx_bit_error_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_BIT_ERROR_COUNT,
      COUNT_UP       => TX_BIT_ERROR_COUNT_UP,
      COUNT_OUT      => TX_BIT_ERROR_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_tx_bit_error_count));

  INST_tx_retransmit_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_TX_RETRANSMIT_COUNT,
      COUNT_UP       => TX_RETRANSMIT_COUNT_UP,
      COUNT_OUT      => TX_RETRANSMIT_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_tx_retransmit_count));

  INST_rx_msg_recv_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_MSG_RECV_COUNT,
      COUNT_UP       => RX_MSG_RECV_COUNT_UP,
      COUNT_OUT      => RX_MSG_RECV_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_rx_msg_recv_count));

  INST_rx_crc_error_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_CRC_ERROR_COUNT,
      COUNT_UP       => RX_CRC_ERROR_COUNT_UP,
      COUNT_OUT      => RX_CRC_ERROR_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_rx_crc_error_count));

  INST_rx_form_error_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_FORM_ERROR_COUNT,
      COUNT_UP       => RX_FORM_ERROR_COUNT_UP,
      COUNT_OUT      => RX_FORM_ERROR_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_rx_form_error_count));

  INST_rx_stuff_error_counter: entity work.up_counter_tmr_wrapper
    generic map (
      BIT_WIDTH             => G_COUNTER_WIDTH,
      IS_SATURATING         => G_SATURATING_COUNTERS,
      VERBOSE               => false,
      G_SEE_MITIGATION_EN   => G_SEE_MITIGATION_EN,
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
    port map (
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => CLEAR_RX_STUFF_ERROR_COUNT,
      COUNT_UP       => RX_STUFF_ERROR_COUNT_UP,
      COUNT_OUT      => RX_STUFF_ERROR_COUNT_VALUE,
      MISMATCH       => s_mismatch_vector(C_mismatch_rx_stuff_error_count));

end architecture struct;
