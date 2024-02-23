-------------------------------------------------------------------------------
-- Title      : Transmit FSM for CAN frames - TMR Wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_frame_tx_fsm_tmr_wrapper.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-29
-- Last update: 2020-08-30
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Wrapper for Triple Modular Redundancy (TMR) for the transmit
--              FSM for CAN frames in the Canola CAN controller.
--              The wrapper creates three instances of the Tx frame FSM entity,
--              and votes the FSM state registers and outputs.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-29  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;
use work.tmr_pkg.all;

entity canola_frame_tx_fsm_tmr_wrapper is
  generic (
    G_SEE_MITIGATION_EN    : boolean := false;
    G_MISMATCH_OUTPUT_EN   : boolean := false;
    G_RETRANSMIT_COUNT_MAX : natural);
  port (
    CLK                            : in  std_logic;
    RESET                          : in  std_logic;
    TX_MSG_IN                      : in  can_msg_t;
    TX_START                       : in  std_logic;  -- Start sending TX_MSG
    TX_RETRANSMIT_EN               : in  std_logic;
    TX_BUSY                        : out std_logic;  -- FSM busy
    TX_DONE                        : out std_logic;  -- Transmit complete, ack received
    TX_ARB_LOST                    : out std_logic;  -- Arbitration was lost
    TX_ARB_WON                     : out std_logic;  -- Arbitration was won (pulsed)
    TX_FAILED                      : out std_logic;  -- (Re)transmit failed (arb lost or error)
    TX_RETRANSMITTING              : out std_logic;  -- Attempting retransmit

    -- Signals to/from BSP
    BSP_TX_DATA                     : out std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
    BSP_TX_DATA_COUNT               : out std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
    BSP_TX_WRITE_EN                 : out std_logic;
    BSP_TX_BIT_STUFF_EN             : out std_logic;
    BSP_TX_RX_MISMATCH              : in  std_logic;
    BSP_TX_RX_STUFF_MISMATCH        : in  std_logic;
    BSP_TX_DONE                     : in  std_logic;
    BSP_TX_CRC_CALC                 : in  std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_TX_ACTIVE                   : out std_logic;
    BSP_RX_ACTIVE                   : in  std_logic;
    BSP_RX_IFS                      : in  std_logic;
    BSP_SEND_ERROR_FLAG             : out std_logic;
    BSP_ERROR_FLAG_DONE             : in  std_logic;
    BSP_ACTIVE_ERROR_FLAG_BIT_ERROR : in  std_logic;

    -- Signals to/from EML
    EML_TX_BIT_ERROR                   : out std_logic;  -- Mismatch transmitted vs. monitored bit
    EML_TX_ACK_ERROR                   : out std_logic;  -- No ack received
    EML_TX_ARB_STUFF_ERROR             : out std_logic;  -- Stuff error during arbitration field
    EML_TX_ACTIVE_ERROR_FLAG_BIT_ERROR : out std_logic;
    EML_ERROR_STATE                    : in  std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

    -- Indicates mismatch in any of the TMR voters
    VOTER_MISMATCH        : out std_logic);
end entity canola_frame_tx_fsm_tmr_wrapper;


architecture structural of canola_frame_tx_fsm_tmr_wrapper is

  constant C_MISMATCH_OUTPUT_REG : boolean := true;

begin  -- architecture structural

  -- -----------------------------------------------------------------------
  -- Generate single instance of Tx Frame FSM when TMR is disabled
  -- -----------------------------------------------------------------------
  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    no_tmr_block : block is
      signal s_fsm_state_no_tmr : std_logic_vector(C_FRAME_TX_FSM_STATE_BITSIZE-1 downto 0);
    begin

      VOTER_MISMATCH <= '0';

      INST_canola_frame_tx_fsm: entity work.canola_frame_tx_fsm
        generic map (
          G_RETRANSMIT_COUNT_MAX => G_RETRANSMIT_COUNT_MAX)
        port map (
          CLK                                => CLK,
          RESET                              => RESET,
          TX_MSG_IN                          => TX_MSG_IN,
          TX_START                           => TX_START,
          TX_RETRANSMIT_EN                   => TX_RETRANSMIT_EN,
          TX_BUSY                            => TX_BUSY,
          TX_DONE                            => TX_DONE,
          TX_ARB_LOST                        => TX_ARB_LOST,
          TX_ARB_WON                         => TX_ARB_WON,
          TX_FAILED                          => TX_FAILED,
          TX_RETRANSMITTING                  => TX_RETRANSMITTING,
          BSP_TX_DATA                        => BSP_TX_DATA,
          BSP_TX_DATA_COUNT                  => BSP_TX_DATA_COUNT,
          BSP_TX_WRITE_EN                    => BSP_TX_WRITE_EN,
          BSP_TX_BIT_STUFF_EN                => BSP_TX_BIT_STUFF_EN,
          BSP_TX_RX_MISMATCH                 => BSP_TX_RX_MISMATCH,
          BSP_TX_RX_STUFF_MISMATCH           => BSP_TX_RX_STUFF_MISMATCH,
          BSP_TX_DONE                        => BSP_TX_DONE,
          BSP_TX_CRC_CALC                    => BSP_TX_CRC_CALC,
          BSP_TX_ACTIVE                      => BSP_TX_ACTIVE,
          BSP_RX_ACTIVE                      => BSP_RX_ACTIVE,
          BSP_RX_IFS                         => BSP_RX_IFS,
          BSP_SEND_ERROR_FLAG                => BSP_SEND_ERROR_FLAG,
          BSP_ERROR_FLAG_DONE                => BSP_ERROR_FLAG_DONE,
          BSP_ACTIVE_ERROR_FLAG_BIT_ERROR    => BSP_ACTIVE_ERROR_FLAG_BIT_ERROR,
          EML_TX_BIT_ERROR                   => EML_TX_BIT_ERROR,
          EML_TX_ACK_ERROR                   => EML_TX_ACK_ERROR,
          EML_TX_ARB_STUFF_ERROR             => EML_TX_ARB_STUFF_ERROR,
          EML_TX_ACTIVE_ERROR_FLAG_BIT_ERROR => EML_TX_ACTIVE_ERROR_FLAG_BIT_ERROR,
          EML_ERROR_STATE                    => EML_ERROR_STATE,
          FSM_STATE_O                        => s_fsm_state_no_tmr,
          FSM_STATE_VOTED_I                  => s_fsm_state_no_tmr);

    end block no_tmr_block;
  end generate if_NOMITIGATION_generate;


    -- -----------------------------------------------------------------------
  -- Generate three instances of BSP when TMR is enabled
  -- -----------------------------------------------------------------------
  if_TMR_generate : if G_SEE_MITIGATION_EN generate
    tmr_block : block is
      type t_fsm_state_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_FRAME_TX_FSM_STATE_BITSIZE-1 downto 0);
      signal s_fsm_state_out, s_fsm_state_voted : t_fsm_state_tmr;

      type t_bsp_tx_data_tmr is array (0 to C_K_TMR-1) of std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
      type t_bsp_tx_data_count_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);

      signal s_tx_busy_tmr                            : std_logic_vector(0 to C_K_TMR-1);
      signal s_tx_done_tmr                            : std_logic_vector(0 to C_K_TMR-1);
      signal s_tx_arb_lost_tmr                        : std_logic_vector(0 to C_K_TMR-1);
      signal s_tx_arb_won_tmr                         : std_logic_vector(0 to C_K_TMR-1);
      signal s_tx_failed_tmr                          : std_logic_vector(0 to C_K_TMR-1);
      signal s_tx_retransmitting_tmr                  : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_tx_data_tmr                        : t_bsp_tx_data_tmr;
      signal s_bsp_tx_data_count_tmr                  : t_bsp_tx_data_count_tmr;
      signal s_bsp_tx_write_en_tmr                    : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_tx_bit_stuff_en_tmr                : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_tx_active_tmr                      : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_send_error_flag_tmr                : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_tx_bit_error_tmr                   : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_tx_ack_error_tmr                   : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_tx_arb_stuff_error_tmr             : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_tx_active_error_flag_bit_error_tmr : std_logic_vector(0 to C_K_TMR-1);

      attribute DONT_TOUCH                                             : string;
      attribute DONT_TOUCH of s_fsm_state_out                          : signal is "TRUE";
      attribute DONT_TOUCH of s_fsm_state_voted                        : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_busy_tmr                            : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_done_tmr                            : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_arb_lost_tmr                        : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_arb_won_tmr                         : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_failed_tmr                          : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_retransmitting_tmr                  : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_data_tmr                        : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_data_count_tmr                  : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_write_en_tmr                    : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_bit_stuff_en_tmr                : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_active_tmr                      : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_send_error_flag_tmr                : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_tx_bit_error_tmr                   : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_tx_ack_error_tmr                   : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_tx_arb_stuff_error_tmr             : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_tx_active_error_flag_bit_error_tmr : signal is "TRUE";

      constant C_mismatch_fsm_state                          : integer := 0;
      constant C_mismatch_tx_busy                            : integer := 1;
      constant C_mismatch_tx_done                            : integer := 2;
      constant C_mismatch_tx_arb_lost                        : integer := 3;
      constant C_mismatch_tx_arb_won                         : integer := 4;
      constant C_mismatch_tx_failed                          : integer := 5;
      constant C_mismatch_tx_retransmitting                  : integer := 6;
      constant C_mismatch_bsp_tx_data                        : integer := 7;
      constant C_mismatch_bsp_tx_data_count                  : integer := 8;
      constant C_mismatch_bsp_tx_write_en                    : integer := 9;
      constant C_mismatch_bsp_tx_bit_stuff_en                : integer := 10;
      constant C_mismatch_bsp_tx_active                      : integer := 11;
      constant C_mismatch_bsp_send_error_flag                : integer := 12;
      constant C_mismatch_eml_tx_bit_error                   : integer := 13;
      constant C_mismatch_eml_tx_ack_error                   : integer := 14;
      constant C_mismatch_eml_tx_arb_stuff_error             : integer := 15;
      constant C_mismatch_eml_tx_active_error_flag_bit_error : integer := 16;
      constant C_MISMATCH_WIDTH                              : integer := 17;

      constant C_MISMATCH_NONE : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0) := (others => '0');
      signal s_mismatch_vector : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0);

    begin

      if_mismatch_gen : if G_MISMATCH_OUTPUT_EN generate
        proc_mismatch : process (CLK) is
        begin  -- process proc_mismatch
          if rising_edge(CLK) then
            VOTER_MISMATCH <= or_reduce(s_mismatch_vector);
          end if;
        end process proc_mismatch;
      end generate if_mismatch_gen;

      if_not_mismatch_gen : if not G_MISMATCH_OUTPUT_EN generate
        VOTER_MISMATCH <= '0';
      end generate if_not_mismatch_gen;


      for_TMR_generate : for i in 0 to C_K_TMR-1 generate
        INST_canola_frame_tx_fsm : entity work.canola_frame_tx_fsm
          generic map (
            G_RETRANSMIT_COUNT_MAX => G_RETRANSMIT_COUNT_MAX)
          port map (
            CLK                                => CLK,
            RESET                              => RESET,
            TX_MSG_IN                          => TX_MSG_IN,
            TX_START                           => TX_START,
            TX_RETRANSMIT_EN                   => TX_RETRANSMIT_EN,
            TX_BUSY                            => s_tx_busy_tmr(i),
            TX_DONE                            => s_tx_done_tmr(i),
            TX_ARB_LOST                        => s_tx_arb_lost_tmr(i),
            TX_ARB_WON                         => s_tx_arb_won_tmr(i),
            TX_FAILED                          => s_tx_failed_tmr(i),
            TX_RETRANSMITTING                  => s_tx_retransmitting_tmr(i),
            BSP_TX_DATA                        => s_bsp_tx_data_tmr(i),
            BSP_TX_DATA_COUNT                  => s_bsp_tx_data_count_tmr(i),
            BSP_TX_WRITE_EN                    => s_bsp_tx_write_en_tmr(i),
            BSP_TX_BIT_STUFF_EN                => s_bsp_tx_bit_stuff_en_tmr(i),
            BSP_TX_RX_MISMATCH                 => BSP_TX_RX_MISMATCH,
            BSP_TX_RX_STUFF_MISMATCH           => BSP_TX_RX_STUFF_MISMATCH,
            BSP_TX_DONE                        => BSP_TX_DONE,
            BSP_TX_CRC_CALC                    => BSP_TX_CRC_CALC,
            BSP_TX_ACTIVE                      => s_bsp_tx_active_tmr(i),
            BSP_RX_ACTIVE                      => BSP_RX_ACTIVE,
            BSP_RX_IFS                         => BSP_RX_IFS,
            BSP_SEND_ERROR_FLAG                => s_bsp_send_error_flag_tmr(i),
            BSP_ERROR_FLAG_DONE                => BSP_ERROR_FLAG_DONE,
            BSP_ACTIVE_ERROR_FLAG_BIT_ERROR    => BSP_ACTIVE_ERROR_FLAG_BIT_ERROR,
            EML_TX_BIT_ERROR                   => s_eml_tx_bit_error_tmr(i),
            EML_TX_ACK_ERROR                   => s_eml_tx_ack_error_tmr(i),
            EML_TX_ARB_STUFF_ERROR             => s_eml_tx_arb_stuff_error_tmr(i),
            EML_TX_ACTIVE_ERROR_FLAG_BIT_ERROR => s_eml_tx_active_error_flag_bit_error_tmr(i),
            EML_ERROR_STATE                    => EML_ERROR_STATE,
            FSM_STATE_O                        => s_fsm_state_out(i),
            FSM_STATE_VOTED_I                  => s_fsm_state_voted(i));

      end generate for_TMR_generate;

      -- -----------------------------------------------------------------------
      -- TMR voters
      -- -----------------------------------------------------------------------
      INST_fsm_state_voter : entity work.tmr_voter_triplicated_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK         => CLK,
          INPUT_A     => s_fsm_state_out(0),
          INPUT_B     => s_fsm_state_out(1),
          INPUT_C     => s_fsm_state_out(2),
          VOTER_OUT_A => s_fsm_state_voted(0),
          VOTER_OUT_B => s_fsm_state_voted(1),
          VOTER_OUT_C => s_fsm_state_voted(2),
          MISMATCH    => s_mismatch_vector(C_mismatch_fsm_state));

      INST_tx_busy_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tx_busy_tmr(0),
          INPUT_B   => s_tx_busy_tmr(1),
          INPUT_C   => s_tx_busy_tmr(2),
          VOTER_OUT => TX_BUSY,
          MISMATCH  => s_mismatch_vector(C_mismatch_tx_busy));

      INST_tx_done_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tx_done_tmr(0),
          INPUT_B   => s_tx_done_tmr(1),
          INPUT_C   => s_tx_done_tmr(2),
          VOTER_OUT => TX_DONE,
          MISMATCH  => s_mismatch_vector(C_mismatch_tx_done));

      INST_tx_arb_lost_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tx_arb_lost_tmr(0),
          INPUT_B   => s_tx_arb_lost_tmr(1),
          INPUT_C   => s_tx_arb_lost_tmr(2),
          VOTER_OUT => TX_ARB_LOST,
          MISMATCH  => s_mismatch_vector(C_mismatch_tx_arb_lost));

      INST_tx_arb_won_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tx_arb_won_tmr(0),
          INPUT_B   => s_tx_arb_won_tmr(1),
          INPUT_C   => s_tx_arb_won_tmr(2),
          VOTER_OUT => TX_ARB_WON,
          MISMATCH  => s_mismatch_vector(C_mismatch_tx_arb_won));

      INST_tx_failed_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tx_failed_tmr(0),
          INPUT_B   => s_tx_failed_tmr(1),
          INPUT_C   => s_tx_failed_tmr(2),
          VOTER_OUT => TX_FAILED,
          MISMATCH  => s_mismatch_vector(C_mismatch_tx_failed));

      INST_tx_retransmitting_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tx_retransmitting_tmr(0),
          INPUT_B   => s_tx_retransmitting_tmr(1),
          INPUT_C   => s_tx_retransmitting_tmr(2),
          VOTER_OUT => TX_RETRANSMITTING,
          MISMATCH  => s_mismatch_vector(C_mismatch_tx_retransmitting));

      INST_bsp_tx_data_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_data_tmr(0),
          INPUT_B   => s_bsp_tx_data_tmr(1),
          INPUT_C   => s_bsp_tx_data_tmr(2),
          VOTER_OUT => BSP_TX_DATA,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_data));

      INST_bsp_tx_data_count_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_data_count_tmr(0),
          INPUT_B   => s_bsp_tx_data_count_tmr(1),
          INPUT_C   => s_bsp_tx_data_count_tmr(2),
          VOTER_OUT => BSP_TX_DATA_COUNT,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_data_count));

      INST_bsp_tx_write_en_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_write_en_tmr(0),
          INPUT_B   => s_bsp_tx_write_en_tmr(1),
          INPUT_C   => s_bsp_tx_write_en_tmr(2),
          VOTER_OUT => BSP_TX_WRITE_EN,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_write_en));

      INST_bsp_tx_bit_stuff_en_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_bit_stuff_en_tmr(0),
          INPUT_B   => s_bsp_tx_bit_stuff_en_tmr(1),
          INPUT_C   => s_bsp_tx_bit_stuff_en_tmr(2),
          VOTER_OUT => BSP_TX_BIT_STUFF_EN,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_bit_stuff_en));

      INST_bsp_tx_active_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_active_tmr(0),
          INPUT_B   => s_bsp_tx_active_tmr(1),
          INPUT_C   => s_bsp_tx_active_tmr(2),
          VOTER_OUT => BSP_TX_ACTIVE,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_active));

      INST_bsp_send_error_flag_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_send_error_flag_tmr(0),
          INPUT_B   => s_bsp_send_error_flag_tmr(1),
          INPUT_C   => s_bsp_send_error_flag_tmr(2),
          VOTER_OUT => BSP_SEND_ERROR_FLAG,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_send_error_flag));

      INST_eml_tx_bit_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_tx_bit_error_tmr(0),
          INPUT_B   => s_eml_tx_bit_error_tmr(1),
          INPUT_C   => s_eml_tx_bit_error_tmr(2),
          VOTER_OUT => EML_TX_BIT_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_tx_bit_error));

      INST_eml_tx_ack_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_tx_ack_error_tmr(0),
          INPUT_B   => s_eml_tx_ack_error_tmr(1),
          INPUT_C   => s_eml_tx_ack_error_tmr(2),
          VOTER_OUT => EML_TX_ACK_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_tx_ack_error));

      INST_eml_tx_arb_stuff_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_tx_arb_stuff_error_tmr(0),
          INPUT_B   => s_eml_tx_arb_stuff_error_tmr(1),
          INPUT_C   => s_eml_tx_arb_stuff_error_tmr(2),
          VOTER_OUT => EML_TX_ARB_STUFF_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_tx_arb_stuff_error));

      INST_eml_tx_active_error_flag_bit_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_tx_active_error_flag_bit_error_tmr(0),
          INPUT_B   => s_eml_tx_active_error_flag_bit_error_tmr(1),
          INPUT_C   => s_eml_tx_active_error_flag_bit_error_tmr(2),
          VOTER_OUT => EML_TX_ACTIVE_ERROR_FLAG_BIT_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_tx_active_error_flag_bit_error));

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
