-------------------------------------------------------------------------------
-- Title      : Receive FSM for CAN frames - TMR Wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_frame_rx_fsm_tmr_wrapper.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-28
-- Last update: 2020-08-28
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Wrapper for Triple Modular Redundancy (TMR) for the receive
--              FSM for CAN frames in the Canola CAN controller.
--              The wrapper creates three instances of the Rx frame FSM entity,
--              and votes the FSM state registers and outputs.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-28  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;
use work.tmr_pkg.all;

entity canola_frame_rx_fsm_tmr_wrapper is
  generic (
    G_SEE_MITIGATION_EN   : boolean := false;
    G_MISMATCH_OUTPUT_EN  : boolean := false);
  port (
    CLK               : in  std_logic;
    RESET             : in  std_logic;
    RX_MSG_OUT        : out can_msg_t;
    RX_MSG_VALID      : out std_logic;
    TX_ARB_WON        : in  std_logic;  -- Tx FSM signal that we are transmitting and won arbitration

    -- Signals to/from BSP
    BSP_RX_ACTIVE             : in  std_logic;
    BSP_RX_IFS                : in  std_logic;  -- High in inter frame spacing period
    BSP_RX_DATA               : in  std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
    BSP_RX_DATA_COUNT         : in  std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
    BSP_RX_DATA_CLEAR         : out std_logic;
    BSP_RX_DATA_OVERFLOW      : in  std_logic;
    BSP_RX_BIT_DESTUFF_EN     : out std_logic;  -- Enable bit destuffing on data
                                                -- that is currently being received
    BSP_RX_STOP               : out std_logic;  -- Tell BSP to stop we've got EOF
    BSP_RX_CRC_CALC           : in  std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_RX_SEND_ACK           : out std_logic;
    BSP_RX_ACTIVE_ERROR_FLAG  : in  std_logic;  -- Active error flag received
    BSP_RX_PASSIVE_ERROR_FLAG : in  std_logic;  -- Passive error flag received
    BSP_SEND_ERROR_FLAG       : out std_logic;  -- When pulsed, BSP cancels
                                                -- whatever it is doing, and sends
                                                -- an error flag of 6 bits
    BSP_ERROR_FLAG_DONE             : in std_logic;  -- Pulsed
    BSP_ACTIVE_ERROR_FLAG_BIT_ERROR : in std_logic;  -- Bit error was detected while
                                                     -- transmitting active error flag

    -- Signals from BTL
    BTL_RX_BIT_VALID          : in  std_logic;
    BTL_RX_BIT_VALUE          : in  std_logic;

    -- Signals to/from EML
    EML_TX_BIT_ERROR                   : out std_logic;
    EML_RX_STUFF_ERROR                 : out std_logic;
    EML_RX_CRC_ERROR                   : out std_logic;
    EML_RX_FORM_ERROR                  : out std_logic;
    EML_RX_ACTIVE_ERROR_FLAG_BIT_ERROR : out std_logic;
    EML_ERROR_STATE                    : in  std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

    -- Indicates mismatch in any of the TMR voters
    VOTER_MISMATCH        : out std_logic
    );
end entity canola_frame_rx_fsm_tmr_wrapper;


architecture structural of canola_frame_rx_fsm_tmr_wrapper is

  constant C_MISMATCH_OUTPUT_REG : boolean := true;

begin  -- architecture structural

  -- -----------------------------------------------------------------------
  -- Generate single instance of Rx Frame FSM when TMR is disabled
  -- -----------------------------------------------------------------------
  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    no_tmr_block : block is
      signal s_fsm_state_no_tmr : std_logic_vector(C_FRAME_RX_FSM_STATE_BITSIZE-1 downto 0);
    begin

      VOTER_MISMATCH <= '0';

      -- Create instance of Rx Frame FSM which connects directly to the wrapper's outputs
      -- The state register output from the Rx Frame FSM is routed directly back to its
      -- state register input without voting.
      INST_canola_frame_rx_fsm : entity work.canola_frame_rx_fsm
        port map (
          CLK                                => CLK,
          RESET                              => RESET,
          RX_MSG_OUT                         => RX_MSG_OUT,
          RX_MSG_VALID                       => RX_MSG_VALID,
          TX_ARB_WON                         => TX_ARB_WON,
          BSP_RX_ACTIVE                      => BSP_RX_ACTIVE,
          BSP_RX_IFS                         => BSP_RX_IFS,
          BSP_RX_DATA                        => BSP_RX_DATA,
          BSP_RX_DATA_COUNT                  => BSP_RX_DATA_COUNT,
          BSP_RX_DATA_CLEAR                  => BSP_RX_DATA_CLEAR,
          BSP_RX_DATA_OVERFLOW               => BSP_RX_DATA_OVERFLOW,
          BSP_RX_BIT_DESTUFF_EN              => BSP_RX_BIT_DESTUFF_EN,
          BSP_RX_STOP                        => BSP_RX_STOP,
          BSP_RX_CRC_CALC                    => BSP_RX_CRC_CALC,
          BSP_RX_SEND_ACK                    => BSP_RX_SEND_ACK,
          BSP_RX_ACTIVE_ERROR_FLAG           => BSP_RX_ACTIVE_ERROR_FLAG,
          BSP_RX_PASSIVE_ERROR_FLAG          => BSP_RX_PASSIVE_ERROR_FLAG,
          BSP_SEND_ERROR_FLAG                => BSP_SEND_ERROR_FLAG,
          BSP_ERROR_FLAG_DONE                => BSP_ERROR_FLAG_DONE,
          BSP_ACTIVE_ERROR_FLAG_BIT_ERROR    => BSP_ACTIVE_ERROR_FLAG_BIT_ERROR,
          BTL_RX_BIT_VALID                   => BTL_RX_BIT_VALID,
          BTL_RX_BIT_VALUE                   => BTL_RX_BIT_VALUE,
          EML_TX_BIT_ERROR                   => EML_TX_BIT_ERROR,
          EML_RX_STUFF_ERROR                 => EML_RX_STUFF_ERROR,
          EML_RX_CRC_ERROR                   => EML_RX_CRC_ERROR,
          EML_RX_FORM_ERROR                  => EML_RX_FORM_ERROR,
          EML_RX_ACTIVE_ERROR_FLAG_BIT_ERROR => EML_RX_ACTIVE_ERROR_FLAG_BIT_ERROR,
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
      type t_fsm_state_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_FRAME_RX_FSM_STATE_BITSIZE-1 downto 0);
      signal s_fsm_state_out, s_fsm_state_voted : t_fsm_state_tmr;

      type t_can_msg_tmr is array (0 to C_K_TMR-1) of can_msg_t;
      signal s_rx_msg_out_tmr                         : t_can_msg_tmr;
      signal s_rx_msg_valid_tmr                       : std_logic_vector(0 to C_K_TMR-1);
      --signal s_inter_frame_space_tmr                  : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_data_clear_tmr                  : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_bit_destuff_en_tmr              : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_stop_tmr                        : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_send_ack_tmr                    : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_send_error_flag_tmr                : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_tx_bit_error_tmr                   : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_rx_stuff_error_tmr                 : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_rx_crc_error_tmr                   : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_rx_form_error_tmr                  : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_rx_active_error_flag_bit_error_tmr : std_logic_vector(0 to C_K_TMR-1);

      attribute DONT_TOUCH                                             : string;
      attribute DONT_TOUCH of s_fsm_state_out                          : signal is "TRUE";
      attribute DONT_TOUCH of s_fsm_state_voted                        : signal is "TRUE";
      attribute DONT_TOUCH of s_rx_msg_out_tmr                         : signal is "TRUE";
      attribute DONT_TOUCH of s_rx_msg_valid_tmr                       : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_data_clear_tmr                  : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_bit_destuff_en_tmr              : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_stop_tmr                        : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_send_ack_tmr                    : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_send_error_flag_tmr                : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_tx_bit_error_tmr                   : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_rx_stuff_error_tmr                 : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_rx_crc_error_tmr                   : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_rx_form_error_tmr                  : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_rx_active_error_flag_bit_error_tmr : signal is "TRUE";

      constant C_mismatch_fsm_state                          : integer := 0;
      constant C_mismatch_rx_msg_arb_id_a                    : integer := 1;
      constant C_mismatch_rx_msg_arb_id_b                    : integer := 2;
      constant C_mismatch_rx_msg_remote_request              : integer := 3;
      constant C_mismatch_rx_msg_ext_id                      : integer := 4;
      constant C_mismatch_rx_msg_data0                       : integer := 5;
      constant C_mismatch_rx_msg_data1                       : integer := 6;
      constant C_mismatch_rx_msg_data2                       : integer := 7;
      constant C_mismatch_rx_msg_data3                       : integer := 8;
      constant C_mismatch_rx_msg_data4                       : integer := 9;
      constant C_mismatch_rx_msg_data5                       : integer := 10;
      constant C_mismatch_rx_msg_data6                       : integer := 11;
      constant C_mismatch_rx_msg_data7                       : integer := 12;
      constant C_mismatch_rx_msg_data_len                    : integer := 13;
      constant C_mismatch_rx_msg_valid                       : integer := 14;
      constant C_mismatch_bsp_rx_data_clear                  : integer := 15;
      constant C_mismatch_bsp_rx_bit_destuff_en              : integer := 16;
      constant C_mismatch_bsp_rx_stop                        : integer := 17;
      constant C_mismatch_bsp_rx_send_ack                    : integer := 18;
      constant C_mismatch_bsp_send_error_flag                : integer := 19;
      constant C_mismatch_eml_tx_bit_error                   : integer := 20;
      constant C_mismatch_eml_rx_stuff_error                 : integer := 21;
      constant C_mismatch_eml_rx_crc_error                   : integer := 22;
      constant C_mismatch_eml_rx_form_error                  : integer := 23;
      constant C_mismatch_eml_rx_active_error_flag_bit_error : integer := 24;
      constant C_MISMATCH_WIDTH                              : integer := 25;

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
        INST_canola_frame_rx_fsm : entity work.canola_frame_rx_fsm
          port map (
            CLK                                => CLK,
            RESET                              => RESET,
            RX_MSG_OUT                         => s_rx_msg_out_tmr(i),
            RX_MSG_VALID                       => s_rx_msg_valid_tmr(i),
            TX_ARB_WON                         => TX_ARB_WON,
            BSP_RX_ACTIVE                      => BSP_RX_ACTIVE,
            BSP_RX_IFS                         => BSP_RX_IFS,
            BSP_RX_DATA                        => BSP_RX_DATA,
            BSP_RX_DATA_COUNT                  => BSP_RX_DATA_COUNT,
            BSP_RX_DATA_CLEAR                  => s_bsp_rx_data_clear_tmr(i),
            BSP_RX_DATA_OVERFLOW               => BSP_RX_DATA_OVERFLOW,
            BSP_RX_BIT_DESTUFF_EN              => s_bsp_rx_bit_destuff_en_tmr(i),
            BSP_RX_STOP                        => s_bsp_rx_stop_tmr(i),
            BSP_RX_CRC_CALC                    => BSP_RX_CRC_CALC,
            BSP_RX_SEND_ACK                    => s_bsp_rx_send_ack_tmr(i),
            BSP_RX_ACTIVE_ERROR_FLAG           => BSP_RX_ACTIVE_ERROR_FLAG,
            BSP_RX_PASSIVE_ERROR_FLAG          => BSP_RX_PASSIVE_ERROR_FLAG,
            BSP_SEND_ERROR_FLAG                => s_bsp_send_error_flag_tmr(i),
            BSP_ERROR_FLAG_DONE                => BSP_ERROR_FLAG_DONE,
            BSP_ACTIVE_ERROR_FLAG_BIT_ERROR    => BSP_ACTIVE_ERROR_FLAG_BIT_ERROR,
            BTL_RX_BIT_VALID                   => BTL_RX_BIT_VALID,
            BTL_RX_BIT_VALUE                   => BTL_RX_BIT_VALUE,
            EML_TX_BIT_ERROR                   => s_eml_tx_bit_error_tmr(i),
            EML_RX_STUFF_ERROR                 => s_eml_rx_stuff_error_tmr(i),
            EML_RX_CRC_ERROR                   => s_eml_rx_crc_error_tmr(i),
            EML_RX_FORM_ERROR                  => s_eml_rx_form_error_tmr(i),
            EML_RX_ACTIVE_ERROR_FLAG_BIT_ERROR => s_eml_rx_active_error_flag_bit_error_tmr(i),
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

      INST_rx_msg_arb_id_a_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rx_msg_out_tmr(0).arb_id_a,
          INPUT_B   => s_rx_msg_out_tmr(1).arb_id_a,
          INPUT_C   => s_rx_msg_out_tmr(2).arb_id_a,
          VOTER_OUT => RX_MSG_OUT.arb_id_a,
          MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_arb_id_a));

      INST_rx_msg_arb_id_b_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rx_msg_out_tmr(0).arb_id_b,
          INPUT_B   => s_rx_msg_out_tmr(1).arb_id_b,
          INPUT_C   => s_rx_msg_out_tmr(2).arb_id_b,
          VOTER_OUT => RX_MSG_OUT.arb_id_b,
          MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_arb_id_b));

      INST_rx_msg_remote_request_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rx_msg_out_tmr(0).remote_request,
          INPUT_B   => s_rx_msg_out_tmr(1).remote_request,
          INPUT_C   => s_rx_msg_out_tmr(2).remote_request,
          VOTER_OUT => RX_MSG_OUT.remote_request,
          MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_remote_request));

      INST_rx_msg_ext_id_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rx_msg_out_tmr(0).ext_id,
          INPUT_B   => s_rx_msg_out_tmr(1).ext_id,
          INPUT_C   => s_rx_msg_out_tmr(2).ext_id,
          VOTER_OUT => RX_MSG_OUT.ext_id,
          MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_ext_id));

      for_TMR_payload_generate : for byte_num in 0 to 7 generate
        INST_rx_msg_data_voter : entity work.tmr_voter_array
          generic map (
            G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
            G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
          port map (
            CLK       => CLK,
            INPUT_A   => s_rx_msg_out_tmr(0).data(byte_num),
            INPUT_B   => s_rx_msg_out_tmr(1).data(byte_num),
            INPUT_C   => s_rx_msg_out_tmr(2).data(byte_num),
            VOTER_OUT => RX_MSG_OUT.data(byte_num),
            MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_data0 + byte_num));
      end generate for_TMR_payload_generate;

      INST_rx_msg_data_length_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rx_msg_out_tmr(0).data_length,
          INPUT_B   => s_rx_msg_out_tmr(1).data_length,
          INPUT_C   => s_rx_msg_out_tmr(2).data_length,
          VOTER_OUT => RX_MSG_OUT.data_length,
          MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_data_len));

      INST_rx_msg_valid_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rx_msg_valid_tmr(0),
          INPUT_B   => s_rx_msg_valid_tmr(1),
          INPUT_C   => s_rx_msg_valid_tmr(2),
          VOTER_OUT => RX_MSG_VALID,
          MISMATCH  => s_mismatch_vector(C_mismatch_rx_msg_valid));

      INST_bsp_rx_data_clear_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_data_clear_tmr(0),
          INPUT_B   => s_bsp_rx_data_clear_tmr(1),
          INPUT_C   => s_bsp_rx_data_clear_tmr(2),
          VOTER_OUT => BSP_RX_DATA_CLEAR,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_data_clear));

      INST_bsp_rx_bit_destuff_en_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_bit_destuff_en_tmr(0),
          INPUT_B   => s_bsp_rx_bit_destuff_en_tmr(1),
          INPUT_C   => s_bsp_rx_bit_destuff_en_tmr(2),
          VOTER_OUT => BSP_RX_BIT_DESTUFF_EN,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_bit_destuff_en));

      INST_bsp_rx_stop_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_stop_tmr(0),
          INPUT_B   => s_bsp_rx_stop_tmr(1),
          INPUT_C   => s_bsp_rx_stop_tmr(2),
          VOTER_OUT => BSP_RX_STOP,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_stop));

      INST_bsp_rx_send_ack_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_send_ack_tmr(0),
          INPUT_B   => s_bsp_rx_send_ack_tmr(1),
          INPUT_C   => s_bsp_rx_send_ack_tmr(2),
          VOTER_OUT => BSP_RX_SEND_ACK,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_send_ack));

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

      INST_eml_rx_stuff_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_rx_stuff_error_tmr(0),
          INPUT_B   => s_eml_rx_stuff_error_tmr(1),
          INPUT_C   => s_eml_rx_stuff_error_tmr(2),
          VOTER_OUT => EML_RX_STUFF_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_rx_stuff_error));

      INST_eml_rx_crc_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_rx_crc_error_tmr(0),
          INPUT_B   => s_eml_rx_crc_error_tmr(1),
          INPUT_C   => s_eml_rx_crc_error_tmr(2),
          VOTER_OUT => EML_RX_CRC_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_rx_crc_error));

      INST_eml_rx_form_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_rx_form_error_tmr(0),
          INPUT_B   => s_eml_rx_form_error_tmr(1),
          INPUT_C   => s_eml_rx_form_error_tmr(2),
          VOTER_OUT => EML_RX_FORM_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_rx_form_error));

      INST_eml_rx_active_error_flag_bit_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_rx_active_error_flag_bit_error_tmr(0),
          INPUT_B   => s_eml_rx_active_error_flag_bit_error_tmr(1),
          INPUT_C   => s_eml_rx_active_error_flag_bit_error_tmr(2),
          VOTER_OUT => EML_RX_ACTIVE_ERROR_FLAG_BIT_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_rx_active_error_flag_bit_error));

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
