-------------------------------------------------------------------------------
-- Title      : Error Management Logic (EML) for CAN bus - TMR Wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_eml_tmr_wrapper.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-02-05
-- Last update: 2020-09-04
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Wrapper for Triple Modular Redundancy (TMR) for
--              Error Management Logic (BTL) for the Canola CAN controller.
--              The wrapper creates three instances of the EML entity,
--              and votes all the outputs. The EML does not have any internal
--              counters or FSMs that needs to be voted, and the counters
--              used by the EML are instantiated externally at the top level
--              using triplicated counter modules.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-02-05  1.0      svn     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;
use work.tmr_pkg.all;

entity canola_eml_tmr_wrapper is
  generic (
    G_SEE_MITIGATION_EN  : boolean := true;
    G_MISMATCH_OUTPUT_EN : boolean := true);
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    -- Error and success inputs should all be pulsed
    RX_STUFF_ERROR                   : in std_logic;
    RX_CRC_ERROR                     : in std_logic;
    RX_FORM_ERROR                    : in std_logic;
    RX_ACTIVE_ERROR_FLAG_BIT_ERROR   : in std_logic;
    RX_OVERLOAD_FLAG_BIT_ERROR       : in std_logic;
    RX_DOMINANT_BIT_AFTER_ERROR_FLAG : in std_logic;
    TX_BIT_ERROR                     : in std_logic;
    TX_ACK_ERROR                     : in std_logic;
    TX_ACTIVE_ERROR_FLAG_BIT_ERROR   : in std_logic;
    TRANSMIT_SUCCESS                 : in std_logic;
    RECEIVE_SUCCESS                  : in std_logic;
    RECV_11_RECESSIVE_BITS           : in std_logic;  -- Received/detected a sequence of
                                                      -- 11 recessive bits.

    -- Interface to saturating counter modules for
    -- Transmit Error Counter (TEC) and Receive Error Counter (REC)
    TEC_COUNT_VALUE           : in  t_eml_counter_tmr;
    TEC_COUNT_INCR            : out std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
    TEC_COUNT_UP              : out std_logic;
    TEC_COUNT_DOWN            : out std_logic;
    TEC_CLEAR                 : out std_logic;
    TEC_SET                   : out std_logic;
    TEC_SET_VALUE             : out std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
    REC_COUNT_VALUE           : in  t_eml_counter_tmr;
    REC_COUNT_INCR            : out std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
    REC_COUNT_UP              : out std_logic;
    REC_COUNT_DOWN            : out std_logic;
    REC_CLEAR                 : out std_logic;
    REC_SET                   : out std_logic;
    REC_SET_VALUE             : out std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);

    -- Interface to upcounter module for counter for
    -- received sequences of 11 consecutive recessive bits
    RECESSIVE_BIT_COUNT_VALUE : in  std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
    RECESSIVE_BIT_COUNT_UP    : out std_logic;
    RECESSIVE_BIT_COUNT_CLEAR : out std_logic;

    ERROR_STATE             : out std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

    -- Indicates mismatch in any of the TMR voters
    VOTER_MISMATCH          : out std_logic
    );
end entity canola_eml_tmr_wrapper;


architecture structural of canola_eml_tmr_wrapper is
  constant C_MISMATCH_OUTPUT_REG : boolean := true;
begin  -- architecture structural

  -- -----------------------------------------------------------------------
  -- Generate single instance of EML when TMR is disabled
  -- -----------------------------------------------------------------------
  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    VOTER_MISMATCH <= '0';

    -- Create instance of EML which connects directly to the wrapper's outputs
    INST_canola_eml : entity work.canola_eml
      port map (
        CLK                              => CLK,
        RESET                            => RESET,
        RX_STUFF_ERROR                   => RX_STUFF_ERROR,
        RX_CRC_ERROR                     => RX_CRC_ERROR,
        RX_FORM_ERROR                    => RX_FORM_ERROR,
        RX_ACTIVE_ERROR_FLAG_BIT_ERROR   => RX_ACTIVE_ERROR_FLAG_BIT_ERROR,
        RX_OVERLOAD_FLAG_BIT_ERROR       => RX_OVERLOAD_FLAG_BIT_ERROR,
        RX_DOMINANT_BIT_AFTER_ERROR_FLAG => RX_DOMINANT_BIT_AFTER_ERROR_FLAG,
        TX_BIT_ERROR                     => TX_BIT_ERROR,
        TX_ACK_ERROR                     => TX_ACK_ERROR,
        TX_ACTIVE_ERROR_FLAG_BIT_ERROR   => TX_ACTIVE_ERROR_FLAG_BIT_ERROR,
        TRANSMIT_SUCCESS                 => TRANSMIT_SUCCESS,
        RECEIVE_SUCCESS                  => RECEIVE_SUCCESS,
        RECV_11_RECESSIVE_BITS           => RECV_11_RECESSIVE_BITS,
        TEC_COUNT_VALUE                  => TEC_COUNT_VALUE(0),
        TEC_COUNT_INCR                   => TEC_COUNT_INCR,
        TEC_COUNT_UP                     => TEC_COUNT_UP,
        TEC_COUNT_DOWN                   => TEC_COUNT_DOWN,
        TEC_CLEAR                        => TEC_CLEAR,
        TEC_SET                          => TEC_SET,
        TEC_SET_VALUE                    => TEC_SET_VALUE,
        REC_COUNT_VALUE                  => REC_COUNT_VALUE(0),
        REC_COUNT_INCR                   => REC_COUNT_INCR,
        REC_COUNT_UP                     => REC_COUNT_UP,
        REC_COUNT_DOWN                   => REC_COUNT_DOWN,
        REC_CLEAR                        => REC_CLEAR,
        REC_SET                          => REC_SET,
        REC_SET_VALUE                    => REC_SET_VALUE,
        RECESSIVE_BIT_COUNT_VALUE        => RECESSIVE_BIT_COUNT_VALUE,
        RECESSIVE_BIT_COUNT_UP           => RECESSIVE_BIT_COUNT_UP,
        RECESSIVE_BIT_COUNT_CLEAR        => RECESSIVE_BIT_COUNT_CLEAR,
        ERROR_STATE                      => ERROR_STATE);
  end generate if_NOMITIGATION_generate;


  -- -----------------------------------------------------------------------
  -- Generate three instances of BTL when TMR is enabled
  -- -----------------------------------------------------------------------
  if_TMR_generate : if G_SEE_MITIGATION_EN generate
    tmr_block : block is
      type t_error_count_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
      type t_error_count_incr_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
      type t_error_state_tmr is array (0 to C_K_TMR-1) of std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

      -- Transmit Error Counter (TEC)
      signal s_tec_count_incr_tmr : t_error_count_incr_tmr;
      signal s_tec_count_up_tmr   : std_logic_vector(0 to C_K_TMR-1);
      signal s_tec_count_down_tmr : std_logic_vector(0 to C_K_TMR-1);
      signal s_tec_clear_tmr      : std_logic_vector(0 to C_K_TMR-1);

      -- Receive Error Counter (REC)
      signal s_rec_count_incr_tmr : t_error_count_incr_tmr;
      signal s_rec_count_up_tmr   : std_logic_vector(0 to C_K_TMR-1);
      signal s_rec_count_down_tmr : std_logic_vector(0 to C_K_TMR-1);
      signal s_rec_clear_tmr      : std_logic_vector(0 to C_K_TMR-1);
      signal s_rec_set_tmr        : std_logic_vector(0 to C_K_TMR-1);

      signal s_recessive_bit_count_up_tmr    : std_logic_vector(0 to C_K_TMR-1);
      signal s_recessive_bit_count_clear_tmr : std_logic_vector(0 to C_K_TMR-1);

      signal s_error_state_tmr : t_error_state_tmr;

      attribute DONT_TOUCH                                    : string;
      attribute DONT_TOUCH of s_tec_count_incr_tmr            : signal is "TRUE";
      attribute DONT_TOUCH of s_tec_count_up_tmr              : signal is "TRUE";
      attribute DONT_TOUCH of s_tec_count_down_tmr            : signal is "TRUE";
      attribute DONT_TOUCH of s_tec_clear_tmr                 : signal is "TRUE";
      attribute DONT_TOUCH of s_rec_count_incr_tmr            : signal is "TRUE";
      attribute DONT_TOUCH of s_rec_count_up_tmr              : signal is "TRUE";
      attribute DONT_TOUCH of s_rec_count_down_tmr            : signal is "TRUE";
      attribute DONT_TOUCH of s_rec_clear_tmr                 : signal is "TRUE";
      attribute DONT_TOUCH of s_rec_set_tmr                   : signal is "TRUE";
      attribute DONT_TOUCH of s_recessive_bit_count_up_tmr    : signal is "TRUE";
      attribute DONT_TOUCH of s_recessive_bit_count_clear_tmr : signal is "TRUE";
      attribute DONT_TOUCH of s_error_state_tmr               : signal is "TRUE";

      constant C_mismatch_tec_count_incr            : integer := 0;
      constant C_mismatch_tec_count_up              : integer := 1;
      constant C_mismatch_tec_count_down            : integer := 2;
      constant C_mismatch_tec_clear                 : integer := 3;
      constant C_mismatch_rec_count_incr            : integer := 4;
      constant C_mismatch_rec_count_up              : integer := 5;
      constant C_mismatch_rec_count_down            : integer := 6;
      constant C_mismatch_rec_clear                 : integer := 7;
      constant C_mismatch_rec_set                   : integer := 8;
      constant C_mismatch_recessive_bit_count_up    : integer := 9;
      constant C_mismatch_recessive_bit_count_clear : integer := 10;
      constant C_mismatch_error_state               : integer := 11;
      constant C_MISMATCH_WIDTH                     : integer := 12;

      constant C_MISMATCH_NONE : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0) := (others => '0');
      signal s_mismatch_vector : std_logic_vector(C_MISMATCH_WIDTH-1 downto 0);

    begin

      -- The only value the Receive Error Counter (REC) will be set directly to
      -- No point in voting this output
      REC_SET_VALUE <= std_logic_vector(to_unsigned(C_REC_SUCCES_ERROR_PASSIVE_JUMP_VALUE,
                                                    REC_SET_VALUE'length));

      -- Not used for the Transmit Error Counter (TEC)
      -- No point in voting this output
      TEC_SET_VALUE <= (others => '0');
      TEC_SET       <= '0';

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
        INST_canola_eml: entity work.canola_eml
          port map (
            CLK                              => CLK,
            RESET                            => RESET,
            RX_STUFF_ERROR                   => RX_STUFF_ERROR,
            RX_CRC_ERROR                     => RX_CRC_ERROR,
            RX_FORM_ERROR                    => RX_FORM_ERROR,
            RX_ACTIVE_ERROR_FLAG_BIT_ERROR   => RX_ACTIVE_ERROR_FLAG_BIT_ERROR,
            RX_OVERLOAD_FLAG_BIT_ERROR       => RX_OVERLOAD_FLAG_BIT_ERROR,
            RX_DOMINANT_BIT_AFTER_ERROR_FLAG => RX_DOMINANT_BIT_AFTER_ERROR_FLAG,
            TX_BIT_ERROR                     => TX_BIT_ERROR,
            TX_ACK_ERROR                     => TX_ACK_ERROR,
            TX_ACTIVE_ERROR_FLAG_BIT_ERROR   => TX_ACTIVE_ERROR_FLAG_BIT_ERROR,
            TRANSMIT_SUCCESS                 => TRANSMIT_SUCCESS,
            RECEIVE_SUCCESS                  => RECEIVE_SUCCESS,
            RECV_11_RECESSIVE_BITS           => RECV_11_RECESSIVE_BITS,
            TEC_COUNT_VALUE                  => TEC_COUNT_VALUE(i),
            TEC_COUNT_INCR                   => s_tec_count_incr_tmr(i),
            TEC_COUNT_UP                     => s_tec_count_up_tmr(i),
            TEC_COUNT_DOWN                   => s_tec_count_down_tmr(i),
            TEC_CLEAR                        => s_tec_clear_tmr(i),
            TEC_SET                          => open,
            TEC_SET_VALUE                    => open,
            REC_COUNT_VALUE                  => REC_COUNT_VALUE(i),
            REC_COUNT_INCR                   => s_rec_count_incr_tmr(i),
            REC_COUNT_UP                     => s_rec_count_up_tmr(i),
            REC_COUNT_DOWN                   => s_rec_count_down_tmr(i),
            REC_CLEAR                        => s_rec_clear_tmr(i),
            REC_SET                          => s_rec_set_tmr(i),
            REC_SET_VALUE                    => open,
            RECESSIVE_BIT_COUNT_VALUE        => RECESSIVE_BIT_COUNT_VALUE,
            RECESSIVE_BIT_COUNT_UP           => s_recessive_bit_count_up_tmr(i),
            RECESSIVE_BIT_COUNT_CLEAR        => s_recessive_bit_count_clear_tmr(i),
            ERROR_STATE                      => s_error_state_tmr(i));
      end generate for_TMR_generate;

      -- -----------------------------------------------------------------------
      -- TMR voters
      -- -----------------------------------------------------------------------
      INST_tec_count_incr_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tec_count_incr_tmr(0),
          INPUT_B   => s_tec_count_incr_tmr(1),
          INPUT_C   => s_tec_count_incr_tmr(2),
          VOTER_OUT => TEC_COUNT_INCR,
          MISMATCH  => s_mismatch_vector(C_mismatch_tec_count_incr));

      INST_tec_count_up_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tec_count_up_tmr(0),
          INPUT_B   => s_tec_count_up_tmr(1),
          INPUT_C   => s_tec_count_up_tmr(2),
          VOTER_OUT => TEC_COUNT_UP,
          MISMATCH  => s_mismatch_vector(C_mismatch_tec_count_up));

      INST_tec_count_down_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tec_count_down_tmr(0),
          INPUT_B   => s_tec_count_down_tmr(1),
          INPUT_C   => s_tec_count_down_tmr(2),
          VOTER_OUT => TEC_COUNT_DOWN,
          MISMATCH  => s_mismatch_vector(C_mismatch_tec_count_down));

      INST_tec_clear_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_tec_clear_tmr(0),
          INPUT_B   => s_tec_clear_tmr(1),
          INPUT_C   => s_tec_clear_tmr(2),
          VOTER_OUT => TEC_CLEAR,
          MISMATCH  => s_mismatch_vector(C_mismatch_tec_clear));

      INST_rec_count_incr_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rec_count_incr_tmr(0),
          INPUT_B   => s_rec_count_incr_tmr(1),
          INPUT_C   => s_rec_count_incr_tmr(2),
          VOTER_OUT => REC_COUNT_INCR,
          MISMATCH  => s_mismatch_vector(C_mismatch_rec_count_incr));

      INST_rec_count_up_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rec_count_up_tmr(0),
          INPUT_B   => s_rec_count_up_tmr(1),
          INPUT_C   => s_rec_count_up_tmr(2),
          VOTER_OUT => REC_COUNT_UP,
          MISMATCH  => s_mismatch_vector(C_mismatch_rec_count_up));

      INST_rec_count_down_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rec_count_down_tmr(0),
          INPUT_B   => s_rec_count_down_tmr(1),
          INPUT_C   => s_rec_count_down_tmr(2),
          VOTER_OUT => REC_COUNT_DOWN,
          MISMATCH  => s_mismatch_vector(C_mismatch_rec_count_down));

      INST_rec_clear_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rec_clear_tmr(0),
          INPUT_B   => s_rec_clear_tmr(1),
          INPUT_C   => s_rec_clear_tmr(2),
          VOTER_OUT => REC_CLEAR,
          MISMATCH  => s_mismatch_vector(C_mismatch_rec_clear));

      INST_rec_set_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_rec_set_tmr(0),
          INPUT_B   => s_rec_set_tmr(1),
          INPUT_C   => s_rec_set_tmr(2),
          VOTER_OUT => REC_SET,
          MISMATCH  => s_mismatch_vector(C_mismatch_rec_set));

      INST_recessive_bit_count_up_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_recessive_bit_count_up_tmr(0),
          INPUT_B   => s_recessive_bit_count_up_tmr(1),
          INPUT_C   => s_recessive_bit_count_up_tmr(2),
          VOTER_OUT => RECESSIVE_BIT_COUNT_UP,
          MISMATCH  => s_mismatch_vector(C_mismatch_recessive_bit_count_up));

      INST_recessive_bit_count_clear_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_recessive_bit_count_clear_tmr(0),
          INPUT_B   => s_recessive_bit_count_clear_tmr(1),
          INPUT_C   => s_recessive_bit_count_clear_tmr(2),
          VOTER_OUT => RECESSIVE_BIT_COUNT_CLEAR,
          MISMATCH  => s_mismatch_vector(C_mismatch_recessive_bit_count_clear));

      INST_error_state_voter : entity work.tmr_voter_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_error_state_tmr(0),
          INPUT_B   => s_error_state_tmr(1),
          INPUT_C   => s_error_state_tmr(2),
          VOTER_OUT => ERROR_STATE,
          MISMATCH  => s_mismatch_vector(C_mismatch_error_state));

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
