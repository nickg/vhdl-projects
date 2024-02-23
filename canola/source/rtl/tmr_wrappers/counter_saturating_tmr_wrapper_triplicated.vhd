-------------------------------------------------------------------------------
-- Title      : Saturating counter TMR wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : counter_tmr_wrapper_triplicated.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-30
-- Last update: 2020-02-14
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: TMR wrapper for the saturating counter.
--              Creates three instances of the saturating counter,
--              and has three voted output of the counter value.
--              The code is based on counter_n written for the
--              ALICE ITS upgrade by Matteo Lupi and Matthias Bonora
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-30  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tmr_pkg.all;

entity counter_saturating_tmr_wrapper_triplicated is
  generic (
    BIT_WIDTH             : integer := 16;
    INCR_WIDTH            : natural := 16;
    VERBOSE               : boolean := false;
    G_SEE_MITIGATION_EN   : boolean := false;
    G_MISMATCH_OUTPUT_EN  : boolean := false;
    G_MISMATCH_OUTPUT_REG : boolean := false);
  port (
    CLK         : in  std_logic;        -- Clock
    RESET       : in  std_logic;        -- Global fpga reset
    CLEAR       : in  std_logic;        -- Counter clear
    SET         : in  std_logic;        -- Set counter to value
    SET_VALUE   : in  std_logic_vector(BIT_WIDTH-1 downto 0);
    COUNT_UP    : in  std_logic;
    COUNT_DOWN  : in  std_logic;
    COUNT_INCR  : in  std_logic_vector(INCR_WIDTH-1 downto 0);
    COUNT_OUT_A : out std_logic_vector(BIT_WIDTH-1 downto 0);
    COUNT_OUT_B : out std_logic_vector(BIT_WIDTH-1 downto 0);
    COUNT_OUT_C : out std_logic_vector(BIT_WIDTH-1 downto 0);
    MISMATCH    : out std_logic);
  attribute DONT_TOUCH                                               : string;
  attribute DONT_TOUCH of counter_saturating_tmr_wrapper_triplicated : entity is "true";
end entity counter_saturating_tmr_wrapper_triplicated;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture structural of counter_saturating_tmr_wrapper_triplicated is
begin

  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    no_tmr_block : block is
      signal s_counter_nonvoted  : std_logic_vector(BIT_WIDTH-1 downto 0);
    begin

      INST_counter_saturating: entity work.counter_saturating
        generic map (
          BIT_WIDTH  => BIT_WIDTH,
          INCR_WIDTH => INCR_WIDTH,
          VERBOSE    => VERBOSE)
        port map (
          CLK            => CLK,
          RESET          => RESET,
          CLEAR          => CLEAR,
          SET            => SET,
          SET_VALUE      => SET_VALUE,
          COUNT_UP       => COUNT_UP,
          COUNT_DOWN     => COUNT_DOWN,
          COUNT_INCR     => COUNT_INCR,
          COUNT_OUT      => s_counter_nonvoted,
          COUNT_VOTED_IN => s_counter_nonvoted);

      COUNT_OUT_A <= s_counter_nonvoted;
      COUNT_OUT_B <= s_counter_nonvoted;
      COUNT_OUT_C <= s_counter_nonvoted;
      MISMATCH    <= '0';

    end block no_tmr_block;
  end generate if_NOMITIGATION_generate;


  if_TMR_generate : if G_SEE_MITIGATION_EN generate
    tmr_block : block is
      type t_count_value_tmr is array (0 to C_K_TMR-1) of std_logic_vector(BIT_WIDTH-1 downto 0);

      signal s_counter_out   : t_count_value_tmr;
      signal s_counter_voted : t_count_value_tmr;

      attribute DONT_TOUCH                    : string;
      attribute DONT_TOUCH of s_counter_out   : signal is "TRUE";
      attribute DONT_TOUCH of s_counter_voted : signal is "TRUE";
    begin  -- block tmr_block

      -- for generate
      for_TMR_generate : for i in 0 to C_K_TMR-1 generate
        INST_counter_saturating: entity work.counter_saturating
          generic map (
            BIT_WIDTH  => BIT_WIDTH,
            INCR_WIDTH => INCR_WIDTH,
            VERBOSE    => VERBOSE)
          port map (
            CLK            => CLK,
            RESET          => RESET,
            CLEAR          => CLEAR,
            SET            => SET,
            SET_VALUE      => SET_VALUE,
            COUNT_UP       => COUNT_UP,
            COUNT_DOWN     => COUNT_DOWN,
            COUNT_INCR     => COUNT_INCR,
            COUNT_OUT      => s_counter_out(i),
            COUNT_VOTED_IN => s_counter_voted(i));
      end generate for_TMR_generate;

      INST_counter_voter : entity work.tmr_voter_triplicated_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => G_MISMATCH_OUTPUT_REG)
        port map (
          CLK         => CLK,
          INPUT_A     => s_counter_out(0),
          INPUT_B     => s_counter_out(1),
          INPUT_C     => s_counter_out(2),
          VOTER_OUT_A => s_counter_voted(0),
          VOTER_OUT_B => s_counter_voted(1),
          VOTER_OUT_C => s_counter_voted(2),
          MISMATCH    => MISMATCH);

      COUNT_OUT_A <= s_counter_voted(0);
      COUNT_OUT_B <= s_counter_voted(1);
      COUNT_OUT_C <= s_counter_voted(2);

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
