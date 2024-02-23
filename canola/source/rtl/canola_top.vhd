-------------------------------------------------------------------------------
-- Title      : Top level entity for Canola CAN controller
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_top.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-07-10
-- Last update: 2020-09-12
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Top level module for the Canola CAN controller
--              Provides a direct signal for interfacing and configuration
--              of the module.
--              To interact with the module via a bus interface, use one of the
--              other top level entities for the desired bus interface.
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-07-10  1.0      svn     Created
-- 2019-09-19  1.1      svn     Add outputs for counter register, error
--                              counters and error state
-- 2020-02-12  1.2      svn     Made counters external
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;

entity canola_top is
  generic (
    G_TIME_QUANTA_SCALE_WIDTH : natural := C_TIME_QUANTA_SCALE_WIDTH_DEFAULT;
    G_RETRANSMIT_COUNT_MAX    : natural := C_RETRANSMIT_COUNT_MAX_DEFAULT);
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    -- CAN bus interface signals
    CAN_TX : out std_logic;
    CAN_RX : in  std_logic;

    -- Rx interface
    RX_MSG       : out can_msg_t;
    RX_MSG_VALID : out std_logic;

    -- Tx interface
    TX_MSG           : in  can_msg_t;
    TX_START         : in  std_logic;
    TX_RETRANSMIT_EN : in  std_logic;
    TX_BUSY          : out std_logic;
    TX_DONE          : out std_logic;
    TX_FAILED        : out std_logic;

    -- BTL configuration
    BTL_TRIPLE_SAMPLING : in std_logic;
    BTL_PROP_SEG        : in std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0);
    BTL_PHASE_SEG1      : in std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0);
    BTL_PHASE_SEG2      : in std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0);
    BTL_SYNC_JUMP_WIDTH : in unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0);

    -- Clock scale value to divide system CLK by to generate time quantas
    TIME_QUANTA_CLOCK_SCALE : in unsigned(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);

    -- Error state and counters
    -- Note: transmit/receive error counters do not hold absolute of the
    -- number of tx/rx errors, they are internal count registers controlled and
    -- used by the EML to determine the error state.
    TRANSMIT_ERROR_COUNT : out unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
    RECEIVE_ERROR_COUNT  : out unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);
    ERROR_STATE          : out can_error_state_t;

    -- Signals that can be used to count up external status counters
    -- (e.g. in canola_counters.vhd)
    TX_MSG_SENT_COUNT_UP    : out std_logic;
    TX_FAILED_COUNT_UP      : out std_logic;
    TX_ACK_ERROR_COUNT_UP   : out std_logic;
    TX_ARB_LOST_COUNT_UP    : out std_logic;
    TX_BIT_ERROR_COUNT_UP   : out std_logic;
    TX_RETRANSMIT_COUNT_UP  : out std_logic;
    RX_MSG_RECV_COUNT_UP    : out std_logic;
    RX_CRC_ERROR_COUNT_UP   : out std_logic;
    RX_FORM_ERROR_COUNT_UP  : out std_logic;
    RX_STUFF_ERROR_COUNT_UP : out std_logic
    );

end entity canola_top;

architecture struct of canola_top is

  -- Signals for Tx Frame FSM
  signal s_tx_fsm_arb_lost                    : std_logic;  -- Arbitration was lost
  signal s_tx_fsm_arb_won                     : std_logic;  -- Arbitration was won
  signal s_tx_fsm_retransmitting              : std_logic;  -- Attempting retransmit

  -- BSP interface to Tx Frame FSM
  signal s_bsp_tx_data              : std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
  signal s_bsp_tx_data_count        : std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
  signal s_bsp_tx_write_en          : std_logic;
  signal s_bsp_tx_bit_stuff_en      : std_logic;  -- Enable bit stuffing on current data
  signal s_bsp_tx_rx_mismatch       : std_logic;  -- Mismatch Tx and Rx
  signal s_bsp_tx_rx_stuff_mismatch : std_logic;  -- Mismatch Tx/Rx (stuff bit)
  signal s_bsp_tx_done              : std_logic;
  signal s_bsp_tx_crc_calc          : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
  signal s_bsp_tx_active            : std_logic;  -- Resets bit stuff counter and CRC

  -- BSP interface to Rx Frame FSM
  signal s_bsp_rx_active               : std_logic;
  signal s_bsp_rx_ifs                  : std_logic;
  signal s_bsp_rx_data                 : std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
  signal s_bsp_rx_data_count           : std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
  signal s_bsp_rx_data_clear           : std_logic;
  signal s_bsp_rx_data_overflow        : std_logic;
  signal s_bsp_rx_bit_destuff_en       : std_logic;
  signal s_bsp_rx_stop                 : std_logic;
  signal s_bsp_rx_crc_calc             : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
  signal s_bsp_rx_send_ack             : std_logic;

  -- BSP interface for error flag
  signal s_bsp_send_error_flag             : std_logic;
  signal s_bsp_send_error_flag_tx_fsm      : std_logic;
  signal s_bsp_send_error_flag_rx_fsm      : std_logic;
  signal s_bsp_rx_active_error_flag        : std_logic;
  signal s_bsp_rx_passive_error_flag       : std_logic;
  signal s_bsp_error_flag_done             : std_logic;
  signal s_bsp_active_error_flag_bit_error : std_logic;

  -- BTL signals
  signal s_btl_tx_bit_value    : std_logic;
  signal s_btl_tx_bit_valid    : std_logic;
  signal s_btl_tx_rdy          : std_logic;
  signal s_btl_tx_active       : std_logic;
  signal s_btl_tx_done         : std_logic;
  signal s_btl_rx_bit_value    : std_logic;
  signal s_btl_rx_bit_valid    : std_logic;
  signal s_btl_rx_synced       : std_logic;
  signal s_btl_rx_stop         : std_logic;

  -- Time Quanta Generator signals
  signal s_time_quanta_pulse   : std_logic;
  signal s_time_quanta_restart : std_logic;
  signal s_time_quanta_count   : std_logic_vector(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);

  -- EML signals
  signal s_eml_rx_stuff_error                   : std_logic;
  signal s_eml_rx_crc_error                     : std_logic;
  signal s_eml_rx_form_error                    : std_logic;
  signal s_eml_rx_active_error_flag_bit_error   : std_logic;
  signal s_eml_tx_bit_error_rx_fsm              : std_logic;
  signal s_eml_tx_bit_error_tx_fsm              : std_logic;
  signal s_eml_tx_ack_error                     : std_logic;
  signal s_eml_tx_arb_stuff_error               : std_logic;
  signal s_eml_tx_active_error_flag_bit_error   : std_logic;
  signal s_eml_recv_11_recessive_bits           : std_logic;
  signal s_eml_error_state                      : std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

  -- EML counter signals
  -- These counters are actively used by the EML
  -- to determine error state for the controller
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

  -- State registers
  signal s_btl_sync_fsm_state : std_logic_vector(C_BTL_SYNC_FSM_STATE_BITSIZE-1 downto 0);
  signal s_bsp_rx_fsm_state   : std_logic_vector(C_BSP_RX_FSM_STATE_BITSIZE-1 downto 0);
  signal s_bsp_tx_fsm_state   : std_logic_vector(C_BSP_TX_FSM_STATE_BITSIZE-1 downto 0);
  signal s_frame_rx_fsm_state : std_logic_vector(C_FRAME_RX_FSM_STATE_BITSIZE-1 downto 0);
  signal s_frame_tx_fsm_state : std_logic_vector(C_FRAME_TX_FSM_STATE_BITSIZE-1 downto 0);

begin  -- architecture struct

  -- Some of these signals are already available on a different output port
  -- But for clarity each counter has been given a dedicated port signal
  TX_MSG_SENT_COUNT_UP    <= TX_DONE;
  TX_FAILED_COUNT_UP      <= TX_FAILED;
  TX_ACK_ERROR_COUNT_UP   <= s_eml_tx_ack_error;
  TX_ARB_LOST_COUNT_UP    <= s_tx_fsm_arb_lost;
  TX_BIT_ERROR_COUNT_UP   <= s_eml_tx_bit_error_rx_fsm or s_eml_tx_bit_error_tx_fsm;
  TX_RETRANSMIT_COUNT_UP  <= s_tx_fsm_retransmitting;
  RX_MSG_RECV_COUNT_UP    <= RX_MSG_VALID;
  RX_CRC_ERROR_COUNT_UP   <= s_eml_rx_crc_error;
  RX_FORM_ERROR_COUNT_UP  <= s_eml_rx_form_error;
  RX_STUFF_ERROR_COUNT_UP <= s_eml_rx_stuff_error;

  TRANSMIT_ERROR_COUNT <= unsigned(s_eml_tec_count_value);
  RECEIVE_ERROR_COUNT  <= unsigned(s_eml_rec_count_value);
  ERROR_STATE          <= can_error_state_t'val(to_integer(unsigned(s_eml_error_state)));

  s_bsp_send_error_flag <= s_bsp_send_error_flag_tx_fsm or s_bsp_send_error_flag_rx_fsm;

  -- Transmit state machine
  INST_canola_frame_tx_fsm : entity work.canola_frame_tx_fsm
    generic map (
      G_RETRANSMIT_COUNT_MAX => G_RETRANSMIT_COUNT_MAX)
    port map (
      CLK                                => CLK,
      RESET                              => RESET,
      TX_MSG_IN                          => TX_MSG,
      TX_START                           => TX_START,
      TX_RETRANSMIT_EN                   => TX_RETRANSMIT_EN,
      TX_BUSY                            => TX_BUSY,
      TX_DONE                            => TX_DONE,
      TX_ARB_LOST                        => s_tx_fsm_arb_lost,
      TX_ARB_WON                         => s_tx_fsm_arb_won,
      TX_FAILED                          => TX_FAILED,
      TX_RETRANSMITTING                  => s_tx_fsm_retransmitting,
      BSP_TX_DATA                        => s_bsp_tx_data,
      BSP_TX_DATA_COUNT                  => s_bsp_tx_data_count,
      BSP_TX_WRITE_EN                    => s_bsp_tx_write_en,
      BSP_TX_BIT_STUFF_EN                => s_bsp_tx_bit_stuff_en,
      BSP_TX_RX_MISMATCH                 => s_bsp_tx_rx_mismatch,
      BSP_TX_RX_STUFF_MISMATCH           => s_bsp_tx_rx_stuff_mismatch,
      BSP_TX_DONE                        => s_bsp_tx_done,
      BSP_TX_CRC_CALC                    => s_bsp_tx_crc_calc,
      BSP_TX_ACTIVE                      => s_bsp_tx_active,
      BSP_RX_ACTIVE                      => s_bsp_rx_active,
      BSP_RX_IFS                         => s_bsp_rx_ifs,
      BSP_SEND_ERROR_FLAG                => s_bsp_send_error_flag_tx_fsm,
      BSP_ERROR_FLAG_DONE                => s_bsp_error_flag_done,
      BSP_ACTIVE_ERROR_FLAG_BIT_ERROR    => s_bsp_active_error_flag_bit_error,
      EML_TX_BIT_ERROR                   => s_eml_tx_bit_error_tx_fsm,
      EML_TX_ACK_ERROR                   => s_eml_tx_ack_error,
      EML_TX_ARB_STUFF_ERROR             => s_eml_tx_arb_stuff_error,
      EML_TX_ACTIVE_ERROR_FLAG_BIT_ERROR => s_eml_tx_active_error_flag_bit_error,
      EML_ERROR_STATE                    => s_eml_error_state,
      FSM_STATE_O                        => s_frame_tx_fsm_state,
      FSM_STATE_VOTED_I                  => s_frame_tx_fsm_state);

  -- Receive state machine
  INST_canola_frame_rx_fsm : entity work.canola_frame_rx_fsm
    port map (
      CLK                                => CLK,
      RESET                              => RESET,
      RX_MSG_OUT                         => RX_MSG,
      RX_MSG_VALID                       => RX_MSG_VALID,
      TX_ARB_WON                         => s_tx_fsm_arb_won,
      BSP_RX_ACTIVE                      => s_bsp_rx_active,
      BSP_RX_IFS                         => s_bsp_rx_ifs,
      BSP_RX_DATA                        => s_bsp_rx_data,
      BSP_RX_DATA_COUNT                  => s_bsp_rx_data_count,
      BSP_RX_DATA_CLEAR                  => s_bsp_rx_data_clear,
      BSP_RX_DATA_OVERFLOW               => s_bsp_rx_data_overflow,
      BSP_RX_BIT_DESTUFF_EN              => s_bsp_rx_bit_destuff_en,
      BSP_RX_STOP                        => s_bsp_rx_stop,
      BSP_RX_CRC_CALC                    => s_bsp_rx_crc_calc,
      BSP_RX_SEND_ACK                    => s_bsp_rx_send_ack,
      BSP_RX_ACTIVE_ERROR_FLAG           => s_bsp_rx_active_error_flag,
      BSP_RX_PASSIVE_ERROR_FLAG          => s_bsp_rx_passive_error_flag,
      BSP_SEND_ERROR_FLAG                => s_bsp_send_error_flag_rx_fsm,
      BSP_ERROR_FLAG_DONE                => s_bsp_error_flag_done,
      BSP_ACTIVE_ERROR_FLAG_BIT_ERROR    => s_bsp_active_error_flag_bit_error,
      BTL_RX_BIT_VALUE                   => s_btl_rx_bit_value,
      BTL_RX_BIT_VALID                   => s_btl_rx_bit_valid,
      EML_TX_BIT_ERROR                   => s_eml_tx_bit_error_rx_fsm,
      EML_RX_STUFF_ERROR                 => s_eml_rx_stuff_error,
      EML_RX_CRC_ERROR                   => s_eml_rx_crc_error,
      EML_RX_FORM_ERROR                  => s_eml_rx_form_error,
      EML_RX_ACTIVE_ERROR_FLAG_BIT_ERROR => s_eml_rx_active_error_flag_bit_error,
      EML_ERROR_STATE                    => s_eml_error_state,
      FSM_STATE_O                        => s_frame_rx_fsm_state,
      FSM_STATE_VOTED_I                  => s_frame_rx_fsm_state);

  -- Bit Stream Processor (BSP)
  -- Responsible for bit stuffing/destuffing and
  -- CRC calculation of larger stream of bits.
  -- Acts as a layer between the BTL and Tx/Rx state machines
  INST_canola_bsp : entity work.canola_bsp
    port map (
      CLK                             => CLK,
      RESET                           => RESET,
      BSP_TX_DATA                     => s_bsp_tx_data,
      BSP_TX_DATA_COUNT               => s_bsp_tx_data_count,
      BSP_TX_WRITE_EN                 => s_bsp_tx_write_en,
      BSP_TX_BIT_STUFF_EN             => s_bsp_tx_bit_stuff_en,
      BSP_TX_RX_MISMATCH              => s_bsp_tx_rx_mismatch,
      BSP_TX_RX_STUFF_MISMATCH        => s_bsp_tx_rx_stuff_mismatch,
      BSP_TX_DONE                     => s_bsp_tx_done,
      BSP_TX_CRC_CALC_O               => s_bsp_tx_crc_calc,
      BSP_TX_ACTIVE                   => s_bsp_tx_active,
      BSP_RX_ACTIVE                   => s_bsp_rx_active,
      BSP_RX_IFS                      => s_bsp_rx_ifs,
      BSP_RX_DATA                     => s_bsp_rx_data,
      BSP_RX_DATA_COUNT               => s_bsp_rx_data_count,
      BSP_RX_DATA_CLEAR               => s_bsp_rx_data_clear,
      BSP_RX_DATA_OVERFLOW            => s_bsp_rx_data_overflow,
      BSP_RX_BIT_DESTUFF_EN           => s_bsp_rx_bit_destuff_en,
      BSP_RX_STOP                     => s_bsp_rx_stop,
      BSP_RX_CRC_CALC_O               => s_bsp_rx_crc_calc,
      BSP_RX_SEND_ACK                 => s_bsp_rx_send_ack,
      BSP_RX_ACTIVE_ERROR_FLAG        => s_bsp_rx_active_error_flag,
      BSP_RX_PASSIVE_ERROR_FLAG       => s_bsp_rx_passive_error_flag,
      BSP_SEND_ERROR_FLAG             => s_bsp_send_error_flag,
      BSP_ERROR_FLAG_DONE             => s_bsp_error_flag_done,
      BSP_ACTIVE_ERROR_FLAG_BIT_ERROR => s_bsp_active_error_flag_bit_error,
      EML_RECV_11_RECESSIVE_BITS      => s_eml_recv_11_recessive_bits,
      EML_ERROR_STATE                 => s_eml_error_state,
      BTL_TX_BIT_VALUE                => s_btl_tx_bit_value,
      BTL_TX_BIT_VALID                => s_btl_tx_bit_valid,
      BTL_TX_RDY                      => s_btl_tx_rdy,
      BTL_TX_DONE                     => s_btl_tx_done,
      BTL_RX_BIT_VALUE                => s_btl_rx_bit_value,
      BTL_RX_BIT_VALID                => s_btl_rx_bit_valid,
      BTL_RX_SYNCED                   => s_btl_rx_synced,
      BTL_RX_STOP                     => s_btl_rx_stop,
      RX_FSM_STATE_O                  => s_bsp_rx_fsm_state,
      RX_FSM_STATE_VOTED_I            => s_bsp_rx_fsm_state,
      TX_FSM_STATE_O                  => s_bsp_tx_fsm_state,
      TX_FSM_STATE_VOTED_I            => s_bsp_tx_fsm_state,
      BSP_TX_CRC_CALC_VOTED_I         => s_bsp_tx_crc_calc,
      BSP_RX_CRC_CALC_VOTED_I         => s_bsp_rx_crc_calc);

  s_btl_tx_active <= s_bsp_tx_active;

  -- Bit Timing Logic (BTL)
  -- Responsible for bit timing, synchronization
  -- and input/output of individual bits.
  INST_canola_btl : entity work.canola_btl
    generic map (
      G_TIME_QUANTA_SCALE_WIDTH => G_TIME_QUANTA_SCALE_WIDTH)
    port map (
      CLK                     => CLK,
      RESET                   => RESET,
      CAN_TX                  => CAN_TX,
      CAN_RX                  => CAN_RX,
      BTL_TX_BIT_VALUE        => s_btl_tx_bit_value,
      BTL_TX_BIT_VALID        => s_btl_tx_bit_valid,
      BTL_TX_RDY              => s_btl_tx_rdy,
      BTL_TX_DONE             => s_btl_tx_done,
      BTL_TX_ACTIVE           => s_btl_tx_active,
      BTL_RX_BIT_VALUE        => s_btl_rx_bit_value,
      BTL_RX_BIT_VALID        => s_btl_rx_bit_valid,
      BTL_RX_SYNCED           => s_btl_rx_synced,
      BTL_RX_STOP             => s_btl_rx_stop,
      TRIPLE_SAMPLING         => BTL_TRIPLE_SAMPLING,
      PROP_SEG                => BTL_PROP_SEG,
      PHASE_SEG1              => BTL_PHASE_SEG1,
      PHASE_SEG2              => BTL_PHASE_SEG2,
      SYNC_JUMP_WIDTH         => BTL_SYNC_JUMP_WIDTH,
      TIME_QUANTA_PULSE       => s_time_quanta_pulse,
      TIME_QUANTA_RESTART     => s_time_quanta_restart,
      SYNC_FSM_STATE_O        => s_btl_sync_fsm_state,
      SYNC_FSM_STATE_VOTED_I  => s_btl_sync_fsm_state);

  -- Generates a 1 (system) clock cycle pulse for each time quanta
  INST_canola_time_quanta_gen : entity work.canola_time_quanta_gen
    generic map (
      G_TIME_QUANTA_SCALE_WIDTH => G_TIME_QUANTA_SCALE_WIDTH)
    port map (
      CLK               => CLK,
      RESET             => RESET,
      RESTART           => s_time_quanta_restart,
      CLK_SCALE         => TIME_QUANTA_CLOCK_SCALE,
      TIME_QUANTA_PULSE => s_time_quanta_pulse,
      COUNT_OUT         => s_time_quanta_count,
      COUNT_IN          => s_time_quanta_count);

  -- Error Management Logic (EML)
  -- Keeps track of errors occuring in other modules,
  -- and calculates an "error state" for the whole system,
  -- which determines to what degree the controller is allowed to interface
  -- with the BUS.
  INST_canola_eml: entity work.canola_eml
    port map (
      CLK                              => CLK,
      RESET                            => RESET,
      RX_STUFF_ERROR                   => s_eml_rx_stuff_error,
      RX_CRC_ERROR                     => s_eml_rx_crc_error,
      RX_FORM_ERROR                    => s_eml_rx_form_error,
      RX_ACTIVE_ERROR_FLAG_BIT_ERROR   => s_eml_rx_active_error_flag_bit_error,
      RX_OVERLOAD_FLAG_BIT_ERROR       => '0', -- Note: Overload flag not implemented
      RX_DOMINANT_BIT_AFTER_ERROR_FLAG => '0', -- Todo: Not detected yet
      TX_BIT_ERROR                     => s_eml_tx_bit_error_rx_fsm or s_eml_tx_bit_error_tx_fsm,
      TX_ACK_ERROR                     => s_eml_tx_ack_error,
      TX_ACTIVE_ERROR_FLAG_BIT_ERROR   => s_eml_tx_active_error_flag_bit_error,
      TRANSMIT_SUCCESS                 => TX_DONE,
      RECEIVE_SUCCESS                  => RX_MSG_VALID,
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
      ERROR_STATE                      => s_eml_error_state);


  -----------------------------------------------------------------------------
  -- EML counters
  -----------------------------------------------------------------------------

  -- Receive Error Counter (REC) used by EML
  INST_receive_error_counter: entity work.counter_saturating
    generic map (
      BIT_WIDTH  => C_ERROR_COUNT_LENGTH,
      INCR_WIDTH => C_ERROR_COUNT_INCR_LENGTH,
      VERBOSE    => false)
    port map (
      CLK            => CLK,
      RESET          => RESET,
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
      CLK            => CLK,
      RESET          => RESET,
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
      CLK            => CLK,
      RESET          => RESET,
      CLEAR          => s_eml_recessive_bit_count_clear,
      COUNT_UP       => s_eml_recessive_bit_count_up,
      COUNT_OUT      => s_eml_recessive_bit_count_value,
      COUNT_VOTED_IN => s_eml_recessive_bit_count_value);

end architecture struct;
