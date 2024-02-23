-------------------------------------------------------------------------------
-- Title      : Bit Timing Logic (BTL) for CAN bus - TMR Wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_btl_tmr_wrapper.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-27
-- Last update: 2020-08-26
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Wrapper for Triple Modular Redundancy (TMR) for
--              Bit Timing Logic (BTL) for the Canola CAN controller.
--              The wrapper creates three instances of the BTL entity,
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

entity canola_btl_tmr_wrapper is
  generic (
    G_SEE_MITIGATION_EN       : boolean := false;
    G_MISMATCH_OUTPUT_EN      : boolean := false;
    G_TIME_QUANTA_SCALE_WIDTH : natural := C_TIME_QUANTA_SCALE_WIDTH_DEFAULT);
  port (
    CLK                     : in  std_logic;
    RESET                   : in  std_logic;
    CAN_TX                  : out std_logic;
    CAN_RX                  : in  std_logic;

    BTL_TX_BIT_VALUE        : in  std_logic;  -- Value of bit to transmit
    BTL_TX_BIT_VALID        : in  std_logic;  -- BTL should transmit this bit
    BTL_TX_RDY              : out std_logic;  -- BTL is ready to transmit next bit
    BTL_TX_DONE             : out std_logic;  -- BTL has outputted the bit on the bus
    BTL_TX_ACTIVE           : in  std_logic;  -- We want to transmit on the
                                              -- bus, avoid Rx syncing

    BTL_RX_BIT_VALUE        : out std_logic;  -- Received bit value
    BTL_RX_BIT_VALID        : out std_logic;  -- Received bit value is valid
    BTL_RX_SYNCED           : out std_logic;  -- BTL has sync to a frame and is receiving
    BTL_RX_STOP             : in  std_logic;  -- Receiving frame is done, BTL
                                              -- can go out of sync

    TRIPLE_SAMPLING         : in  std_logic;  -- Enable triple sampling

    PROP_SEG                : in  std_logic_vector(C_PROP_SEG_WIDTH-1 downto 0);
    PHASE_SEG1              : in  std_logic_vector(C_PHASE_SEG1_WIDTH-1 downto 0);
    PHASE_SEG2              : in  std_logic_vector(C_PHASE_SEG2_WIDTH-1 downto 0);
    SYNC_JUMP_WIDTH         : in  unsigned(C_SYNC_JUMP_WIDTH_BITSIZE-1 downto 0);

    TIME_QUANTA_PULSE       : in  std_logic;
    TIME_QUANTA_RESTART     : out std_logic;

    -- Indicates mismatch in any of the TMR voters
    VOTER_MISMATCH          : out std_logic
    );
end entity canola_btl_tmr_wrapper;

architecture structural of canola_btl_tmr_wrapper is
  constant C_MISMATCH_OUTPUT_REG : boolean := true;

begin  -- architecture structural

  -- -----------------------------------------------------------------------
  -- Generate single instance of BTL when TMR is disabled
  -- -----------------------------------------------------------------------
  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    no_tmr_block : block is
      signal s_sync_fsm_state_no_tmr : std_logic_vector(C_BTL_SYNC_FSM_STATE_BITSIZE-1 downto 0);
    begin

      VOTER_MISMATCH <= '0';

      -- Create instance of BTL which connects directly to the wrapper's outputs
      -- The state register output from the BTL is routed directly back to its
      -- state register input without voting.
      INST_canola_btl : entity work.canola_btl
        generic map (
          G_TIME_QUANTA_SCALE_WIDTH => G_TIME_QUANTA_SCALE_WIDTH)
        port map (
          CLK                    => CLK,
          RESET                  => RESET,
          CAN_TX                 => CAN_TX,
          CAN_RX                 => CAN_RX,
          BTL_TX_BIT_VALUE       => BTL_TX_BIT_VALUE,
          BTL_TX_BIT_VALID       => BTL_TX_BIT_VALID,
          BTL_TX_RDY             => BTL_TX_RDY,
          BTL_TX_DONE            => BTL_TX_DONE,
          BTL_TX_ACTIVE          => BTL_TX_ACTIVE,
          BTL_RX_BIT_VALUE       => BTL_RX_BIT_VALUE,
          BTL_RX_BIT_VALID       => BTL_RX_BIT_VALID,
          BTL_RX_SYNCED          => BTL_RX_SYNCED,
          BTL_RX_STOP            => BTL_RX_STOP,
          TRIPLE_SAMPLING        => TRIPLE_SAMPLING,
          PROP_SEG               => PROP_SEG,
          PHASE_SEG1             => PHASE_SEG1,
          PHASE_SEG2             => PHASE_SEG2,
          SYNC_JUMP_WIDTH        => SYNC_JUMP_WIDTH,
          TIME_QUANTA_PULSE      => TIME_QUANTA_PULSE,
          TIME_QUANTA_RESTART    => TIME_QUANTA_RESTART,
          SYNC_FSM_STATE_O       => s_sync_fsm_state_no_tmr,
          SYNC_FSM_STATE_VOTED_I => s_sync_fsm_state_no_tmr);
    end block no_tmr_block;
  end generate if_NOMITIGATION_generate;


  -- -----------------------------------------------------------------------
  -- Generate three instances of BTL when TMR is enabled
  -- -----------------------------------------------------------------------
  if_TMR_generate : if G_SEE_MITIGATION_EN generate
    tmr_block : block is
      type t_sync_fsm_state_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_BTL_SYNC_FSM_STATE_BITSIZE-1 downto 0);
      signal s_sync_fsm_state_out, s_sync_fsm_state_voted : t_sync_fsm_state_tmr;

      signal s_can_tx_tmr              : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_tx_rdy_tmr          : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_tx_done_tmr         : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_rx_bit_value_tmr    : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_rx_bit_valid_tmr    : std_logic_vector(0 to C_K_TMR-1);
      signal s_btl_rx_synced_tmr       : std_logic_vector(0 to C_K_TMR-1);
      signal s_time_quanta_restart_tmr : std_logic_vector(0 to C_K_TMR-1);

      attribute DONT_TOUCH                              : string;
      attribute DONT_TOUCH of s_sync_fsm_state_out      : signal is "TRUE";
      attribute DONT_TOUCH of s_sync_fsm_state_voted    : signal is "TRUE";
      attribute DONT_TOUCH of s_can_tx_tmr              : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_tx_rdy_tmr          : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_tx_done_tmr         : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_rx_bit_value_tmr    : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_rx_bit_valid_tmr    : signal is "TRUE";
      attribute DONT_TOUCH of s_btl_rx_synced_tmr       : signal is "TRUE";
      attribute DONT_TOUCH of s_time_quanta_restart_tmr : signal is "TRUE";

      constant C_mismatch_sync_fsm_state      : integer := 0;
      constant C_mismatch_can_tx              : integer := 1;
      constant C_mismatch_btl_tx_rdy          : integer := 2;
      constant C_mismatch_btl_tx_done         : integer := 3;
      constant C_mismatch_btl_rx_bit_value    : integer := 4;
      constant C_mismatch_btl_rx_bit_valid    : integer := 5;
      constant C_mismatch_btl_rx_synced       : integer := 6;
      constant C_mismatch_time_quanta_restart : integer := 7;
      constant C_MISMATCH_WIDTH               : integer := 8;

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
        INST_canola_btl : entity work.canola_btl
          generic map (
            G_TIME_QUANTA_SCALE_WIDTH => G_TIME_QUANTA_SCALE_WIDTH)
          port map (
            CLK                    => CLK,
            RESET                  => RESET,
            CAN_TX                 => s_can_tx_tmr(i),
            CAN_RX                 => CAN_RX,
            BTL_TX_BIT_VALUE       => BTL_TX_BIT_VALUE,
            BTL_TX_BIT_VALID       => BTL_TX_BIT_VALID,
            BTL_TX_RDY             => s_btl_tx_rdy_tmr(i),
            BTL_TX_DONE            => s_btl_tx_done_tmr(i),
            BTL_TX_ACTIVE          => BTL_TX_ACTIVE,
            BTL_RX_BIT_VALUE       => s_btl_rx_bit_value_tmr(i),
            BTL_RX_BIT_VALID       => s_btl_rx_bit_valid_tmr(i),
            BTL_RX_SYNCED          => s_btl_rx_synced_tmr(i),
            BTL_RX_STOP            => BTL_RX_STOP,
            TRIPLE_SAMPLING        => TRIPLE_SAMPLING,
            PROP_SEG               => PROP_SEG,
            PHASE_SEG1             => PHASE_SEG1,
            PHASE_SEG2             => PHASE_SEG2,
            SYNC_JUMP_WIDTH        => SYNC_JUMP_WIDTH,
            TIME_QUANTA_PULSE      => TIME_QUANTA_PULSE,
            TIME_QUANTA_RESTART    => s_time_quanta_restart_tmr(i),
            SYNC_FSM_STATE_O       => s_sync_fsm_state_out(i),
            SYNC_FSM_STATE_VOTED_I => s_sync_fsm_state_voted(i)
            );
      end generate for_TMR_generate;

      -- -----------------------------------------------------------------------
      -- TMR voters
      -- -----------------------------------------------------------------------
      INST_sync_state_voter : entity work.tmr_voter_triplicated_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK         => CLK,
          INPUT_A     => s_sync_fsm_state_out(0),
          INPUT_B     => s_sync_fsm_state_out(1),
          INPUT_C     => s_sync_fsm_state_out(2),
          VOTER_OUT_A => s_sync_fsm_state_voted(0),
          VOTER_OUT_B => s_sync_fsm_state_voted(1),
          VOTER_OUT_C => s_sync_fsm_state_voted(2),
          MISMATCH    => s_mismatch_vector(C_mismatch_sync_fsm_state));

      INST_can_tx_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_can_tx_tmr(0),
          INPUT_B   => s_can_tx_tmr(1),
          INPUT_C   => s_can_tx_tmr(2),
          VOTER_OUT => CAN_TX,
          MISMATCH  => s_mismatch_vector(C_mismatch_can_tx));

      INST_btl_tx_rdy : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_tx_rdy_tmr(0),
          INPUT_B   => s_btl_tx_rdy_tmr(1),
          INPUT_C   => s_btl_tx_rdy_tmr(2),
          VOTER_OUT => BTL_TX_RDY,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_tx_rdy));

      INST_btl_tx_done : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_tx_done_tmr(0),
          INPUT_B   => s_btl_tx_done_tmr(1),
          INPUT_C   => s_btl_tx_done_tmr(2),
          VOTER_OUT => BTL_TX_DONE,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_tx_done));

      INST_btl_rx_bit_value : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_rx_bit_value_tmr(0),
          INPUT_B   => s_btl_rx_bit_value_tmr(1),
          INPUT_C   => s_btl_rx_bit_value_tmr(2),
          VOTER_OUT => BTL_RX_BIT_VALUE,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_rx_bit_value));

      INST_btl_rx_bit_valid : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_rx_bit_valid_tmr(0),
          INPUT_B   => s_btl_rx_bit_valid_tmr(1),
          INPUT_C   => s_btl_rx_bit_valid_tmr(2),
          VOTER_OUT => BTL_RX_BIT_VALID,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_rx_bit_valid));

      INST_btl_rx_synced : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_btl_rx_synced_tmr(0),
          INPUT_B   => s_btl_rx_synced_tmr(1),
          INPUT_C   => s_btl_rx_synced_tmr(2),
          VOTER_OUT => BTL_RX_SYNCED,
          MISMATCH  => s_mismatch_vector(C_mismatch_btl_rx_synced));

      INST_time_quanta_restart : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_time_quanta_restart_tmr(0),
          INPUT_B   => s_time_quanta_restart_tmr(1),
          INPUT_C   => s_time_quanta_restart_tmr(2),
          VOTER_OUT => TIME_QUANTA_RESTART,
          MISMATCH  => s_mismatch_vector(C_mismatch_time_quanta_restart));

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
