-------------------------------------------------------------------------------
-- Title      : Package for Canola CAN Controller
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_pkg.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-06-26
-- Last update: 2020-09-04
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Package with definitions used in the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-06-26  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.tmr_pkg.all;

package canola_pkg is
  -----------------------------------------------------------------------------
  -- Definitions specific for CAN protocol
  -----------------------------------------------------------------------------

  constant C_SOF_VALUE          : std_logic := '0';
  constant C_IDE_STD_VALUE      : std_logic := '0';
  constant C_IDE_EXT_VALUE      : std_logic := '1';
  constant C_SRR_VALUE          : std_logic := '1';
  constant C_R0_VALUE           : std_logic := '0';
  constant C_R1_VALUE           : std_logic := '0';
  constant C_CRC_DELIM_VALUE    : std_logic := '1';
  constant C_ACK_VALUE          : std_logic := '0'; -- Ack value sent by receiver
  constant C_ACK_TRANSMIT_VALUE : std_logic := '1'; -- Ack value sent by transmitter
  constant C_ACK_DELIM_VALUE    : std_logic := '1';
  constant C_EOF_VALUE          : std_logic := '1'; -- End Of Frame
  constant C_IFS_VALUE          : std_logic := '1'; -- Inter Frame Spacing

  constant C_ID_A_LENGTH : natural := 11;   -- Standard arbitration ID
  constant C_ID_B_LENGTH : natural := 18;   -- Extended arbitration ID
                                            -- (ID A + B)

  constant C_DLC_LENGTH    : natural := 4;
  constant C_DLC_MAX_VALUE : natural := 8;

  constant C_EOF_LENGTH      : natural := 7;  -- 7 End Of Frame bits (recessive 1)
  constant C_IFS_LENGTH      : natural := 3;  -- 3 Interframe Spacing bits (recessive 1)

  constant C_EOF : std_logic_vector(0 to C_EOF_LENGTH-1) := (others => C_EOF_VALUE);
  constant C_IFS : std_logic_vector(0 to C_IFS_LENGTH-1) := (others => C_IFS_VALUE);

  constant C_BASIC_ARB_ID_LENGTH : natural := 11;
  constant C_EXT_ARB_ID_LENGTH   : natural := 29;

  constant C_CAN_CRC_WIDTH : natural := 15;

  -----------------------------------------------------------------------------
  -- Definitions specific for the Canola CAN controller implementation
  -----------------------------------------------------------------------------
  constant C_TIME_QUANTA_SCALE_WIDTH_DEFAULT : natural := 5;

  constant C_PROP_SEG_WIDTH    : natural := 4;
  constant C_PHASE_SEG1_WIDTH  : natural := 4;
  constant C_PHASE_SEG2_WIDTH  : natural := 4;
  constant C_SEGMENT_WIDTH_MAX : natural := maximum(C_PROP_SEG_WIDTH, maximum(C_PHASE_SEG1_WIDTH,
                                                                              C_PHASE_SEG2_WIDTH));
  constant C_SYNC_JUMP_WIDTH_MAX     : natural := 4;
  constant C_SYNC_JUMP_WIDTH_BITSIZE : natural := integer(ceil(log2(1.0+real(C_SYNC_JUMP_WIDTH_MAX))));

  -- Longest field that BSP will be transmitting/receiving is the payload,
  -- which is 8 bytes
  constant C_BSP_DATA_LENGTH      : natural := 8*8;
  constant C_BSP_DATA_LEN_BITSIZE : natural := integer(ceil(log2(1.0+real(C_BSP_DATA_LENGTH))));

  constant C_STUFF_BIT_THRESHOLD : natural := 5;

  constant C_ACCEPTANCE_FILTERS_MAX : natural := 256;

  -- Maximum number of retransmit attempts after a message failed to send
  -- (default and value to use to attempt retransmits forever until it succeeds)
  constant C_RETRANSMIT_COUNT_MAX_DEFAULT : natural := 4;
  constant C_RETRANSMIT_COUNT_FOREVER     : natural := 0;

  type can_payload_t is array (0 to 7) of std_logic_vector(7 downto 0);

  type can_msg_t is record
    arb_id_a       : std_logic_vector(C_ID_A_LENGTH-1 downto 0);
    arb_id_b       : std_logic_vector(C_ID_B_LENGTH-1 downto 0);
    remote_request : std_logic;
    ext_id         : std_logic;
    data           : can_payload_t;
    data_length    : std_logic_vector(C_DLC_LENGTH-1 downto 0);
  end record can_msg_t;


  -----------------------------------------------------------------------------
  -- Declarations for error handling
  -----------------------------------------------------------------------------
  constant C_ERROR_FLAG_LENGTH       : natural := 6;
  constant C_ERROR_DELIMITER_LENGTH  : natural := 8;

  constant C_ERROR_PASSIVE_THRESHOLD : natural := 128;
  constant C_BUS_OFF_THRESHOLD       : natural := 256;

  -- Number of counts of 11 consecutive recessive bits required to exit BUS OFF
  constant C_11_RECESSIVE_EXIT_BUS_OFF_THRESHOLD : natural := 128;

  -- Receive error counter will jump to this value when successfully receiving
  -- a message, but only in the case when the receive error counter is equal to
  -- or higher than 128 (C_ERROR_PASSIVE_THRESHOLD).
  constant C_REC_SUCCES_ERROR_PASSIVE_JUMP_VALUE : natural := 120;

  -- Receive Error Counter (REC) decrease on successful receive when in error passive
  constant C_REC_SUCCES_ERROR_PASSIVE_DECREASE : natural := 8;

  -- Receive Error Counter (REC) decrease on successful receive when in error active
  constant C_REC_SUCCES_ERROR_ACTIVE_DECREASE : natural := 1;

  -- Receive Error Counter (REC) increase on stuff error
  constant C_REC_STUFF_ERROR_INCREASE : natural := 1;

  -- Receive Error Counter (REC) increase on CRC error
  constant C_REC_CRC_ERROR_INCREASE : natural := 1;

  -- Receive Error Counter (REC) increase on form error
  constant C_REC_FORM_ERROR_INCREASE : natural := 1;

  -- Receive Error Counter (REC) increase on active error flag bit error
  constant C_REC_ACTIVE_ERR_FLAG_BIT_ERROR_INCREASE : natural := 8;

  -- Receive Error Counter (REC) increase on overload flag bit error
  constant C_REC_OVERLOAD_FLAG_BIT_ERROR_INCREASE : natural := 8;

  -- Receive Error Counter (REC) increase on dominant bit after error flag
  constant C_REC_DOMINANT_BIT_AFTER_ERR_FLAG_INCREASE : natural := 8;

  -- Transmit Error Counter (TEC) decrease on successful transmit
  constant C_TEC_SUCCESS_DECREASE : natural := 1;

  -- Transmit Error Counter (TEC) increase on bit error
  constant C_TEC_BIT_ERROR_INCREASE : natural := 8;

  -- Transmit Error Counter (TEC) increase on ack error
  constant C_TEC_ACK_ERROR_INCREASE : natural := 8;

  -- Transmit Error Counter (TEC) increase on active error flag bit error
  constant C_TEC_ACTIVE_ERR_FLAG_BIT_ERROR_INCREASE : natural := 8;

  constant C_ERROR_COUNT_LENGTH      : natural := 9;
  constant C_ERROR_COUNT_INCR_LENGTH : natural := 4;

  constant C_ACTIVE_ERROR_FLAG_DATA  : std_logic_vector(0 to C_ERROR_FLAG_LENGTH-1) := "000000";
  constant C_PASSIVE_ERROR_FLAG_DATA : std_logic_vector(0 to C_ERROR_FLAG_LENGTH-1) := "111111";

  constant C_ACTIVE_ERROR_FLAG_VALUE  : std_logic := '0';
  constant C_PASSIVE_ERROR_FLAG_VALUE : std_logic := '1';

  type can_error_state_t is (ERROR_ACTIVE, ERROR_PASSIVE, BUS_OFF);

  -----------------------------------------------------------------------------
  -- Declarations for acceptance filtering
  -----------------------------------------------------------------------------
  -- Acceptance filter type
  type can_acf_t is array (integer range <>) of std_logic_vector(C_EXT_ARB_ID_LENGTH-1 downto 0);


  -----------------------------------------------------------------------------
  -- Definitions for FSM state registers
  -----------------------------------------------------------------------------

  -- Type definition for BTL FSM state register
  type btl_sync_fsm_state_t is (ST_SYNC_SEG,
                          ST_PROP_SEG,
                          ST_PHASE_SEG1,
                          ST_PHASE_SEG2);

  -- Type definition for BSP Rx FSM state register
  type bsp_rx_fsm_state_t is (ST_IDLE,
                        ST_WAIT_BTL_RX_RDY,
                        ST_PROCESS_BIT,
                        ST_DATA_BIT,
                        ST_BIT_DESTUFF,
                        ST_WAIT_BUS_IDLE,
                        ST_CHECK_BUS_IDLE);

  -- Type definition for BSP Tx FSM state register
  type bsp_tx_fsm_state_t is (ST_IDLE,
                        ST_WAIT_TX_DATA,
                        ST_PROCESS_NEXT_TX_BIT,
                        ST_WAIT_BTL_TX_RDY,
                        ST_WAIT_BTL_TX_DONE,
                        ST_WAIT_BTL_RX_VALID,
                        ST_SEND_ERROR_FLAG);

  -- Type definition for Rx Frame FSM state register
  type can_frame_rx_fsm_state_t is (ST_IDLE,
                                    ST_RECV_SOF,
                                    ST_RECV_ID_A,
                                    ST_RECV_SRR_RTR,
                                    ST_RECV_IDE,
                                    ST_RECV_ID_B,
                                    ST_RECV_EXT_FRAME_RTR,
                                    ST_RECV_R1,
                                    ST_RECV_R0,
                                    ST_RECV_DLC,
                                    ST_RECV_DATA,
                                    ST_RECV_CRC,
                                    ST_RECV_CRC_DELIM,
                                    ST_SEND_RECV_ACK,
                                    ST_RECV_ACK_DELIM,
                                    ST_RECV_EOF,
                                    ST_ERROR,
                                    ST_WAIT_ERROR_FLAG,
                                    ST_DONE,
                                    ST_WAIT_BUS_IDLE);

  -- Type definition for Tx Frame FSM state register
  type can_frame_tx_fsm_state_t is (ST_IDLE,
                              ST_WAIT_FOR_BUS_IDLE,
                              ST_SETUP_SOF,
                              ST_SETUP_ID_A,
                              ST_SETUP_SRR_RTR,
                              ST_SETUP_IDE,
                              ST_SETUP_ID_B,
                              ST_SETUP_EXT_RTR,
                              ST_SETUP_R1,
                              ST_SETUP_R0,
                              ST_SETUP_DLC,
                              ST_SETUP_DATA,
                              ST_SETUP_CRC,
                              ST_SETUP_CRC_DELIM,
                              ST_SETUP_ACK_SLOT,
                              ST_SETUP_ACK_DELIM,
                              ST_SETUP_EOF,
                              ST_SETUP_ERROR_FLAG,
                              ST_SEND_SOF,
                              ST_SEND_ID_A,
                              ST_SEND_SRR_RTR,
                              ST_SEND_IDE,
                              ST_SEND_ID_B,
                              ST_SEND_EXT_RTR,
                              ST_SEND_R1,
                              ST_SEND_R0,
                              ST_SEND_DLC,
                              ST_SEND_DATA,
                              ST_SEND_CRC,
                              ST_SEND_CRC_DELIM,
                              ST_SEND_RECV_ACK_SLOT,
                              ST_SEND_ACK_DELIM,
                              ST_SEND_EOF,
                              ST_SEND_ERROR_FLAG,
                              ST_ARB_LOST,
                              ST_BIT_ERROR,
                              ST_ACK_ERROR,
                              ST_RETRANSMIT,
                              ST_DONE);

  -- Calculate number of bits needed to represent the error states
  constant C_CAN_ERROR_STATE_BITSIZE : natural :=
    integer(ceil(log2(1.0+real(can_error_state_t'pos(can_error_state_t'high)))));

  -- Calculate number of bits needed to represent states in BTL sync FSM state register
  constant C_BTL_SYNC_FSM_STATE_BITSIZE : natural :=
    integer(ceil(log2(1.0+real(btl_sync_fsm_state_t'pos(btl_sync_fsm_state_t'high)))));

  -- Calculate number of bits needed to represent states in BSP Rx FSM state register
  constant C_BSP_RX_FSM_STATE_BITSIZE : natural :=
    integer(ceil(log2(1.0+real(bsp_rx_fsm_state_t'pos(bsp_rx_fsm_state_t'high)))));

  -- Calculate number of bits needed to represent states in BSP Tx FSM state register
  constant C_BSP_TX_FSM_STATE_BITSIZE : natural :=
    integer(ceil(log2(1.0+real(bsp_tx_fsm_state_t'pos(bsp_tx_fsm_state_t'high)))));

  -- Calculate number of bits needed to represent states in Rx Frame FSM state register
  constant C_FRAME_RX_FSM_STATE_BITSIZE : natural :=
    integer(ceil(log2(1.0+real(can_frame_rx_fsm_state_t'pos(can_frame_rx_fsm_state_t'high)))));

  -- Calculate number of bits needed to represent states in Tx Frame FSM state register
  constant C_FRAME_TX_FSM_STATE_BITSIZE : natural :=
    integer(ceil(log2(1.0+real(can_frame_tx_fsm_state_t'pos(can_frame_tx_fsm_state_t'high)))));



  -----------------------------------------------------------------------------
  -- Definitions for triplicated types for TMR
  -----------------------------------------------------------------------------

  -- Todo: Maybe this should go in tmr_pkg.vhd instead
  type t_eml_counter_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);

end canola_pkg;
