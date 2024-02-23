-------------------------------------------------------------------------------
-- Title      : Bit Stream Processor (BSP) for CAN bus - TMR Wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_bsp.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-27
-- Last update: 2020-02-13
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Wrapper for Triple Modular Redundancy (TMR) for
--              Bit Stream Processor (BSP) for the Canola CAN controller.
--              The wrapper creates three instances of the BSP entity,
--              and votes the FSM state registers and outputs.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-27  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;
use work.tmr_pkg.all;

entity canola_bsp_tmr_wrapper is
  generic (
    G_SEE_MITIGATION_EN  : boolean := true;
    G_MISMATCH_OUTPUT_EN : boolean := true);
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    -- Interface to Tx FSM
    BSP_TX_DATA              : in  std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
    BSP_TX_DATA_COUNT        : in  std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
    BSP_TX_WRITE_EN          : in  std_logic;
    BSP_TX_BIT_STUFF_EN      : in  std_logic;  -- Enable bit stuffing on current data
    BSP_TX_RX_MISMATCH       : out std_logic;  -- Mismatch Tx and Rx. Also used
                                               -- for ACK detection
    BSP_TX_RX_STUFF_MISMATCH : out std_logic;  -- Mismatch Tx and Rx for stuff bit
    BSP_TX_DONE              : out std_logic;
    BSP_TX_CRC_CALC          : out std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_TX_ACTIVE            : in  std_logic;  -- Resets bit stuff counter and CRC

    -- Interface to Rx FSM
    BSP_RX_ACTIVE          : out std_logic;
    BSP_RX_IFS             : out std_logic;  -- High in inter frame spacing period
    BSP_RX_DATA            : out std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
    BSP_RX_DATA_COUNT      : out std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
    BSP_RX_DATA_CLEAR      : in  std_logic;
    BSP_RX_DATA_OVERFLOW   : out std_logic;
    BSP_RX_BIT_DESTUFF_EN  : in  std_logic;  -- Enable bit destuffing on data
                                             -- that is currently being received
    BSP_RX_STOP            : in std_logic;   -- Tell BSP to stop when we've got EOF
    BSP_RX_CRC_CALC        : out std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_RX_SEND_ACK        : in  std_logic;  -- Pulsed input

    BSP_RX_ACTIVE_ERROR_FLAG  : out std_logic;  -- Active error flag received
    BSP_RX_PASSIVE_ERROR_FLAG : out std_logic;  -- Passive error flag received
    BSP_SEND_ERROR_FLAG       : in  std_logic;  -- When pulsed, BSP cancels
                                                -- whatever it is doing, and sends
                                                -- an error flag. The type of flag
                                                -- depends on BSP_ERROR_STATE input
    BSP_ERROR_FLAG_DONE             : out std_logic;  -- Pulsed
    BSP_ACTIVE_ERROR_FLAG_BIT_ERROR : out std_logic;  -- Bit error was detected while
                                                      -- transmitting active error flag

    -- Interface to EML
    EML_RECV_11_RECESSIVE_BITS : out std_logic;
    EML_ERROR_STATE            : in  std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

    -- Interface to BTL
    BTL_TX_BIT_VALUE           : out std_logic;
    BTL_TX_BIT_VALID           : out std_logic;
    BTL_TX_RDY                 : in  std_logic;
    BTL_TX_DONE                : in  std_logic;
    BTL_RX_BIT_VALUE           : in  std_logic;
    BTL_RX_BIT_VALID           : in  std_logic;
    BTL_RX_SYNCED              : in  std_logic;
    BTL_RX_STOP                : out std_logic;

    -- Indicates mismatch in any of the TMR voters
    VOTER_MISMATCH             : out std_logic);

end entity canola_bsp_tmr_wrapper;

architecture structural of canola_bsp_tmr_wrapper is

  constant C_MISMATCH_OUTPUT_REG : boolean := true;

begin  -- architecture structural

    -- -----------------------------------------------------------------------
  -- Generate single instance of BSP when TMR is disabled
  -- -----------------------------------------------------------------------
  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    no_tmr_block : block is
      signal s_rx_fsm_state_no_tmr    : std_logic_vector(C_BSP_RX_FSM_STATE_BITSIZE-1 downto 0);
      signal s_tx_fsm_state_no_tmr    : std_logic_vector(C_BSP_TX_FSM_STATE_BITSIZE-1 downto 0);
      signal s_bsp_tx_crc_calc_no_tmr : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
      signal s_bsp_rx_crc_calc_no_tmr : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    begin

      VOTER_MISMATCH <= '0';

      BSP_TX_CRC_CALC <= s_bsp_tx_crc_calc_no_tmr;
      BSP_RX_CRC_CALC <= s_bsp_rx_crc_calc_no_tmr;

      -- Create instance of BSP which connects directly to the wrapper's outputs
      -- The state register output from the BSP is routed directly back to its
      -- state register input without voting.
      INST_canola_bsp : entity work.canola_bsp
        port map (
          CLK                             => CLK,
          RESET                           => RESET,
          BSP_TX_DATA                     => BSP_TX_DATA,
          BSP_TX_DATA_COUNT               => BSP_TX_DATA_COUNT,
          BSP_TX_WRITE_EN                 => BSP_TX_WRITE_EN,
          BSP_TX_BIT_STUFF_EN             => BSP_TX_BIT_STUFF_EN,
          BSP_TX_RX_MISMATCH              => BSP_TX_RX_MISMATCH,
          BSP_TX_RX_STUFF_MISMATCH        => BSP_TX_RX_STUFF_MISMATCH,
          BSP_TX_DONE                     => BSP_TX_DONE,
          BSP_TX_CRC_CALC_O               => s_bsp_tx_crc_calc_no_tmr,
          BSP_TX_ACTIVE                   => BSP_TX_ACTIVE,
          BSP_RX_ACTIVE                   => BSP_RX_ACTIVE,
          BSP_RX_IFS                      => BSP_RX_IFS,
          BSP_RX_DATA                     => BSP_RX_DATA,
          BSP_RX_DATA_COUNT               => BSP_RX_DATA_COUNT,
          BSP_RX_DATA_CLEAR               => BSP_RX_DATA_CLEAR,
          BSP_RX_DATA_OVERFLOW            => BSP_RX_DATA_OVERFLOW,
          BSP_RX_BIT_DESTUFF_EN           => BSP_RX_BIT_DESTUFF_EN,
          BSP_RX_STOP                     => BSP_RX_STOP,
          BSP_RX_CRC_CALC_O               => s_bsp_rx_crc_calc_no_tmr,
          BSP_RX_SEND_ACK                 => BSP_RX_SEND_ACK,
          BSP_RX_ACTIVE_ERROR_FLAG        => BSP_RX_ACTIVE_ERROR_FLAG,
          BSP_RX_PASSIVE_ERROR_FLAG       => BSP_RX_PASSIVE_ERROR_FLAG,
          BSP_SEND_ERROR_FLAG             => BSP_SEND_ERROR_FLAG,
          BSP_ERROR_FLAG_DONE             => BSP_ERROR_FLAG_DONE,
          BSP_ACTIVE_ERROR_FLAG_BIT_ERROR => BSP_ACTIVE_ERROR_FLAG_BIT_ERROR,
          EML_RECV_11_RECESSIVE_BITS      => EML_RECV_11_RECESSIVE_BITS,
          EML_ERROR_STATE                 => EML_ERROR_STATE,
          BTL_TX_BIT_VALUE                => BTL_TX_BIT_VALUE,
          BTL_TX_BIT_VALID                => BTL_TX_BIT_VALID,
          BTL_TX_RDY                      => BTL_TX_RDY,
          BTL_TX_DONE                     => BTL_TX_DONE,
          BTL_RX_BIT_VALUE                => BTL_RX_BIT_VALUE,
          BTL_RX_BIT_VALID                => BTL_RX_BIT_VALID,
          BTL_RX_SYNCED                   => BTL_RX_SYNCED,
          BTL_RX_STOP                     => BTL_RX_STOP,
          RX_FSM_STATE_O                  => s_rx_fsm_state_no_tmr,
          RX_FSM_STATE_VOTED_I            => s_rx_fsm_state_no_tmr,
          TX_FSM_STATE_O                  => s_tx_fsm_state_no_tmr,
          TX_FSM_STATE_VOTED_I            => s_tx_fsm_state_no_tmr,
          BSP_TX_CRC_CALC_VOTED_I         => s_bsp_tx_crc_calc_no_tmr,
          BSP_RX_CRC_CALC_VOTED_I         => s_bsp_rx_crc_calc_no_tmr);
    end block no_tmr_block;
  end generate if_NOMITIGATION_generate;


  -- -----------------------------------------------------------------------
  -- Generate three instances of BSP when TMR is enabled
  -- -----------------------------------------------------------------------
  if_TMR_generate : if G_SEE_MITIGATION_EN generate
    tmr_block : block is
      type t_rx_fsm_state_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_BSP_RX_FSM_STATE_BITSIZE-1 downto 0);
      type t_tx_fsm_state_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_BSP_TX_FSM_STATE_BITSIZE-1 downto 0);
      signal s_rx_fsm_state_out, s_rx_fsm_state_voted : t_rx_fsm_state_tmr;
      signal s_tx_fsm_state_out, s_tx_fsm_state_voted : t_rx_fsm_state_tmr;

      type t_bsp_crc_calc_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
      type t_bsp_rx_data_tmr is array (0 to C_K_TMR-1) of std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
      type t_bsp_rx_data_count is array (0 to C_K_TMR-1) of std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);

      signal s_bsp_tx_rx_mismatch_tmr              : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_tx_rx_stuff_mismatch_tmr        : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_tx_done_tmr                     : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_tx_crc_calc_tmr                 : t_bsp_crc_calc_tmr;
      signal s_bsp_rx_crc_calc_tmr                 : t_bsp_crc_calc_tmr;
      signal s_bsp_rx_active_tmr                   : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_ifs_tmr                      : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_data_tmr                     : t_bsp_rx_data_tmr;
      signal s_bsp_rx_data_count_tmr               : t_bsp_rx_data_count;
      signal s_bsp_rx_data_overflow_tmr            : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_active_error_flag_tmr        : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_rx_passive_error_flag_tmr       : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_error_flag_done_tmr             : std_logic_vector(0 to C_K_TMR-1);
      signal s_bsp_active_error_flag_bit_error_tmr : std_logic_vector(0 to C_K_TMR-1);
      signal s_eml_recv_11_recessive_bits_tmr      : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_tx_bit_value_tmr                : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_tx_bit_valid_tmr                : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_rx_stop_tmr                     : std_logic_vector(0 to C_K_TMR-1);

      signal s_bsp_tx_crc_calc_voted  : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
      signal s_bsp_rx_crc_calc_voted  : std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);

      attribute DONT_TOUCH                                          : string;
      attribute DONT_TOUCH of s_rx_fsm_state_out                    : signal is "TRUE";
      attribute DONT_TOUCH of s_rx_fsm_state_voted                  : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_fsm_state_out                    : signal is "TRUE";
      attribute DONT_TOUCH of s_tx_fsm_state_voted                  : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_rx_mismatch_tmr              : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_rx_stuff_mismatch_tmr        : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_done_tmr                     : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_tx_crc_calc_tmr                 : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_crc_calc_tmr                 : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_active_tmr                   : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_ifs_tmr                      : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_data_tmr                     : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_data_count_tmr               : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_data_overflow_tmr            : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_active_error_flag_tmr        : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_rx_passive_error_flag_tmr       : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_error_flag_done_tmr             : signal is "TRUE";
      attribute DONT_TOUCH of s_bsp_active_error_flag_bit_error_tmr : signal is "TRUE";
      attribute DONT_TOUCH of s_eml_recv_11_recessive_bits_tmr      : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_tx_bit_value_tmr                : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_tx_bit_valid_tmr                : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_rx_stop_tmr                     : signal is "TRUE";

      constant C_mismatch_rx_fsm_state                    : integer := 0;
      constant C_mismatch_tx_fsm_state                    : integer := 1;
      constant C_mismatch_bsp_tx_rx_mismatch              : integer := 2;
      constant C_mismatch_bsp_tx_rx_stuff_mismatch        : integer := 3;
      constant C_mismatch_bsp_tx_done                     : integer := 4;
      constant C_mismatch_bsp_tx_crc_calc                 : integer := 5;
      constant C_mismatch_bsp_rx_crc_calc                 : integer := 6;
      constant C_mismatch_bsp_rx_active                   : integer := 7;
      constant C_mismatch_bsp_rx_ifs                      : integer := 8;
      constant C_mismatch_bsp_rx_data                     : integer := 9;
      constant C_mismatch_bsp_rx_data_count               : integer := 10;
      constant C_mismatch_bsp_rx_data_overflow            : integer := 11;
      constant C_mismatch_bsp_rx_active_error_flag        : integer := 12;
      constant C_mismatch_bsp_rx_passive_error_flag       : integer := 13;
      constant C_mismatch_bsp_error_flag_done             : integer := 14;
      constant C_mismatch_bsp_active_error_flag_bit_error : integer := 15;
      constant C_mismatch_eml_recv_11_recessive_bits      : integer := 16;
      constant C_mismatch_btl_tx_bit_value                : integer := 17;
      constant C_mismatch_btl_tx_bit_valid                : integer := 18;
      constant C_mismatch_btl_rx_stop                     : integer := 19;
      constant C_MISMATCH_WIDTH                           : integer := 20;

      constant C_MISMATCH_NONE : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0) := (others => '0');
      signal s_mismatch_vector : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0);

    begin

      BSP_TX_CRC_CALC <= s_bsp_tx_crc_calc_voted;
      BSP_RX_CRC_CALC <= s_bsp_rx_crc_calc_voted;

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
        INST_canola_bsp: entity work.canola_bsp
        port map (
          CLK                             => CLK,
          RESET                           => RESET,
          BSP_TX_DATA                     => BSP_TX_DATA,
          BSP_TX_DATA_COUNT               => BSP_TX_DATA_COUNT,
          BSP_TX_WRITE_EN                 => BSP_TX_WRITE_EN,
          BSP_TX_BIT_STUFF_EN             => BSP_TX_BIT_STUFF_EN,
          BSP_TX_RX_MISMATCH              => s_bsp_tx_rx_mismatch_tmr(i),
          BSP_TX_RX_STUFF_MISMATCH        => s_bsp_tx_rx_stuff_mismatch_tmr(i),
          BSP_TX_DONE                     => s_bsp_tx_done_tmr(i),
          BSP_TX_CRC_CALC_O               => s_bsp_tx_crc_calc_tmr(i),
          BSP_TX_ACTIVE                   => BSP_TX_ACTIVE,
          BSP_RX_ACTIVE                   => s_bsp_rx_active_tmr(i),
          BSP_RX_IFS                      => s_bsp_rx_ifs_tmr(i),
          BSP_RX_DATA                     => s_bsp_rx_data_tmr(i),
          BSP_RX_DATA_COUNT               => s_bsp_rx_data_count_tmr(i),
          BSP_RX_DATA_CLEAR               => BSP_RX_DATA_CLEAR,
          BSP_RX_DATA_OVERFLOW            => s_bsp_rx_data_overflow_tmr(i),
          BSP_RX_BIT_DESTUFF_EN           => BSP_RX_BIT_DESTUFF_EN,
          BSP_RX_STOP                     => BSP_RX_STOP,
          BSP_RX_CRC_CALC_O               => s_bsp_rx_crc_calc_tmr(i),
          BSP_RX_SEND_ACK                 => BSP_RX_SEND_ACK,
          BSP_RX_ACTIVE_ERROR_FLAG        => s_bsp_rx_active_error_flag_tmr(i),
          BSP_RX_PASSIVE_ERROR_FLAG       => s_bsp_rx_passive_error_flag_tmr(i),
          BSP_SEND_ERROR_FLAG             => BSP_SEND_ERROR_FLAG,
          BSP_ERROR_FLAG_DONE             => s_bsp_error_flag_done_tmr(i),
          BSP_ACTIVE_ERROR_FLAG_BIT_ERROR => s_bsp_active_error_flag_bit_error_tmr(i),
          EML_RECV_11_RECESSIVE_BITS      => s_eml_recv_11_recessive_bits_tmr(i),
          EML_ERROR_STATE                 => EML_ERROR_STATE,
          BTL_TX_BIT_VALUE                => s_btl_tx_bit_value_tmr(i),
          BTL_TX_BIT_VALID                => s_btl_tx_bit_valid_tmr(i),
          BTL_TX_RDY                      => BTL_TX_RDY,
          BTL_TX_DONE                     => BTL_TX_DONE,
          BTL_RX_BIT_VALUE                => BTL_RX_BIT_VALUE,
          BTL_RX_BIT_VALID                => BTL_RX_BIT_VALID,
          BTL_RX_SYNCED                   => BTL_RX_SYNCED,
          BTL_RX_STOP                     => s_btl_rx_stop_tmr(i),
          RX_FSM_STATE_O                  => s_rx_fsm_state_out(i),
          RX_FSM_STATE_VOTED_I            => s_rx_fsm_state_voted(i),
          TX_FSM_STATE_O                  => s_tx_fsm_state_out(i),
          TX_FSM_STATE_VOTED_I            => s_tx_fsm_state_voted(i),
          BSP_TX_CRC_CALC_VOTED_I         => s_bsp_tx_crc_calc_voted,
          BSP_RX_CRC_CALC_VOTED_I         => s_bsp_rx_crc_calc_voted);
      end generate for_TMR_generate;

      -- -----------------------------------------------------------------------
      -- TMR voters
      -- -----------------------------------------------------------------------
      INST_rx_fsm_state_voter : entity work.tmr_voter_triplicated_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK         => CLK,
          INPUT_A     => s_rx_fsm_state_out(0),
          INPUT_B     => s_rx_fsm_state_out(1),
          INPUT_C     => s_rx_fsm_state_out(2),
          VOTER_OUT_A => s_rx_fsm_state_voted(0),
          VOTER_OUT_B => s_rx_fsm_state_voted(1),
          VOTER_OUT_C => s_rx_fsm_state_voted(2),
          MISMATCH    => s_mismatch_vector(C_mismatch_rx_fsm_state));

      INST_tx_fsm_state_voter : entity work.tmr_voter_triplicated_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK         => CLK,
          INPUT_A     => s_tx_fsm_state_out(0),
          INPUT_B     => s_tx_fsm_state_out(1),
          INPUT_C     => s_tx_fsm_state_out(2),
          VOTER_OUT_A => s_tx_fsm_state_voted(0),
          VOTER_OUT_B => s_tx_fsm_state_voted(1),
          VOTER_OUT_C => s_tx_fsm_state_voted(2),
          MISMATCH    => s_mismatch_vector(C_mismatch_tx_fsm_state));

      INST_bsp_tx_rx_mismatch_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_rx_mismatch_tmr(0),
          INPUT_B   => s_bsp_tx_rx_mismatch_tmr(1),
          INPUT_C   => s_bsp_tx_rx_mismatch_tmr(2),
          VOTER_OUT => BSP_TX_RX_MISMATCH,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_rx_mismatch));

      INST_bsp_tx_rx_stuff_mismatch_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_rx_stuff_mismatch_tmr(0),
          INPUT_B   => s_bsp_tx_rx_stuff_mismatch_tmr(1),
          INPUT_C   => s_bsp_tx_rx_stuff_mismatch_tmr(2),
          VOTER_OUT => BSP_TX_RX_STUFF_MISMATCH,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_rx_stuff_mismatch));

      INST_bsp_tx_done_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_done_tmr(0),
          INPUT_B   => s_bsp_tx_done_tmr(1),
          INPUT_C   => s_bsp_tx_done_tmr(2),
          VOTER_OUT => BSP_TX_DONE,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_done));

      INST_bsp_tx_crc_calc_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_tx_crc_calc_tmr(0),
          INPUT_B   => s_bsp_tx_crc_calc_tmr(1),
          INPUT_C   => s_bsp_tx_crc_calc_tmr(2),
          VOTER_OUT => s_bsp_tx_crc_calc_voted,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_tx_crc_calc));

      INST_bsp_rx_crc_calc_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_crc_calc_tmr(0),
          INPUT_B   => s_bsp_rx_crc_calc_tmr(1),
          INPUT_C   => s_bsp_rx_crc_calc_tmr(2),
          VOTER_OUT => s_bsp_rx_crc_calc_voted,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_crc_calc));

      INST_bsp_rx_active_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_active_tmr(0),
          INPUT_B   => s_bsp_rx_active_tmr(1),
          INPUT_C   => s_bsp_rx_active_tmr(2),
          VOTER_OUT => BSP_RX_ACTIVE,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_active));

      INST_bsp_rx_ifs_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_ifs_tmr(0),
          INPUT_B   => s_bsp_rx_ifs_tmr(1),
          INPUT_C   => s_bsp_rx_ifs_tmr(2),
          VOTER_OUT => BSP_RX_IFS,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_ifs));

      INST_bsp_rx_data_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_data_tmr(0),
          INPUT_B   => s_bsp_rx_data_tmr(1),
          INPUT_C   => s_bsp_rx_data_tmr(2),
          VOTER_OUT => BSP_RX_DATA,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_data));

      INST_bsp_rx_data_count_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_data_count_tmr(0),
          INPUT_B   => s_bsp_rx_data_count_tmr(1),
          INPUT_C   => s_bsp_rx_data_count_tmr(2),
          VOTER_OUT => BSP_RX_DATA_COUNT,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_data_count));

      INST_bsp_rx_data_overflow_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_data_overflow_tmr(0),
          INPUT_B   => s_bsp_rx_data_overflow_tmr(1),
          INPUT_C   => s_bsp_rx_data_overflow_tmr(2),
          VOTER_OUT => BSP_RX_DATA_OVERFLOW,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_data_overflow));

      INST_bsp_rx_active_error_flag_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_active_error_flag_tmr(0),
          INPUT_B   => s_bsp_rx_active_error_flag_tmr(1),
          INPUT_C   => s_bsp_rx_active_error_flag_tmr(2),
          VOTER_OUT => BSP_RX_ACTIVE_ERROR_FLAG,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_active_error_flag));

      INST_bsp_rx_passive_error_flag_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_rx_passive_error_flag_tmr(0),
          INPUT_B   => s_bsp_rx_passive_error_flag_tmr(1),
          INPUT_C   => s_bsp_rx_passive_error_flag_tmr(2),
          VOTER_OUT => BSP_RX_PASSIVE_ERROR_FLAG,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_rx_passive_error_flag));

      INST_bsp_error_flag_done_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_error_flag_done_tmr(0),
          INPUT_B   => s_bsp_error_flag_done_tmr(1),
          INPUT_C   => s_bsp_error_flag_done_tmr(2),
          VOTER_OUT => BSP_ERROR_FLAG_DONE,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_error_flag_done));

      INST_bsp_active_error_flag_bit_error_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_bsp_active_error_flag_bit_error_tmr(0),
          INPUT_B   => s_bsp_active_error_flag_bit_error_tmr(1),
          INPUT_C   => s_bsp_active_error_flag_bit_error_tmr(2),
          VOTER_OUT => BSP_ACTIVE_ERROR_FLAG_BIT_ERROR,
          MISMATCH  => s_mismatch_vector(C_mismatch_bsp_active_error_flag_bit_error));

      INST_eml_recv_11_recessive_bits_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_eml_recv_11_recessive_bits_tmr(0),
          INPUT_B   => s_eml_recv_11_recessive_bits_tmr(1),
          INPUT_C   => s_eml_recv_11_recessive_bits_tmr(2),
          VOTER_OUT => EML_RECV_11_RECESSIVE_BITS,
          MISMATCH  => s_mismatch_vector(C_mismatch_eml_recv_11_recessive_bits));

      INST_btl_tx_bit_value_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_tx_bit_value_tmr(0),
          INPUT_B   => s_btl_tx_bit_value_tmr(1),
          INPUT_C   => s_btl_tx_bit_value_tmr(2),
          VOTER_OUT => BTL_TX_BIT_VALUE,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_tx_bit_value));

      INST_btl_tx_bit_valid_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_tx_bit_valid_tmr(0),
          INPUT_B   => s_btl_tx_bit_valid_tmr(1),
          INPUT_C   => s_btl_tx_bit_valid_tmr(2),
          VOTER_OUT => BTL_TX_BIT_VALID,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_tx_bit_valid));

      INST_btl_rx_stop_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_rx_stop_tmr(0),
          INPUT_B   => s_btl_rx_stop_tmr(1),
          INPUT_C   => s_btl_rx_stop_tmr(2),
          VOTER_OUT => BTL_RX_STOP,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_rx_stop));

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
