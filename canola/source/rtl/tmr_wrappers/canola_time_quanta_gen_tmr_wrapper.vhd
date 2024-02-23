-------------------------------------------------------------------------------
-- Title      : Time quanta generator for CAN bus - TMR Wrapper
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : can_time_quanta_gen.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-08-26
-- Last update: 2020-08-26
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Wrapper for Triple Modular Redundancy (TMR) for the
--              Time Quanta Generator (TQG) for the Canola CAN controller.
--              The wrapper creates three instances of the TQG entity,
--              and votes current counter value and outputs.
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-08-26  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;
use work.tmr_pkg.all;

entity canola_time_quanta_gen_tmr_wrapper is
  generic (
    G_SEE_MITIGATION_EN       : boolean := false;
    G_MISMATCH_OUTPUT_EN      : boolean := false;
    G_TIME_QUANTA_SCALE_WIDTH : natural := C_TIME_QUANTA_SCALE_WIDTH_DEFAULT);
  port (
    CLK               : in  std_logic;
    RESET             : in  std_logic;
    RESTART           : in  std_logic;
    CLK_SCALE         : in  unsigned(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);
    TIME_QUANTA_PULSE : out std_logic;

    -- Indicates mismatch in any of the TMR voters
    VOTER_MISMATCH    : out std_logic
    );
end entity canola_time_quanta_gen_tmr_wrapper;

architecture structural of canola_time_quanta_gen_tmr_wrapper is
  constant C_MISMATCH_OUTPUT_REG : boolean := true;

begin  -- architecture structural

  -- -----------------------------------------------------------------------
  -- Generate single instance of TQG when TMR is disabled
  -- -----------------------------------------------------------------------
  if_NOMITIGATION_generate : if not G_SEE_MITIGATION_EN generate
    no_tmr_block : block is
      signal s_count_no_tmr : std_logic_vector(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);
    begin

      VOTER_MISMATCH <= '0';

      -- Create instance of TQG which connects directly to the wrapper's outputs
      -- The counter value output from the TQG is routed directly back to its
      -- counter value input without voting.
      INST_canola_time_quanta_gen: entity work.canola_time_quanta_gen
        generic map (
          G_TIME_QUANTA_SCALE_WIDTH => G_TIME_QUANTA_SCALE_WIDTH)
        port map (
          CLK               => CLK,
          RESET             => RESET,
          RESTART           => RESTART,
          CLK_SCALE         => CLK_SCALE,
          TIME_QUANTA_PULSE => TIME_QUANTA_PULSE,
          COUNT_OUT         => s_count_no_tmr,
          COUNT_IN          => s_count_no_tmr);
    end block no_tmr_block;
  end generate if_NOMITIGATION_generate;


  -- -----------------------------------------------------------------------
  -- Generate three instances of TQG when TMR is enabled
  -- -----------------------------------------------------------------------
  if_TMR_generate : if G_SEE_MITIGATION_EN generate
    tmr_block : block is
      type t_count_tmr is array (0 to C_K_TMR-1) of std_logic_vector(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);
      signal s_count_out, s_count_voted : t_count_tmr;
      signal s_time_quanta_pulse_tmr    : std_logic_vector(0 to C_K_TMR-1);

      attribute DONT_TOUCH                            : string;
      attribute DONT_TOUCH of s_count_out             : signal is "TRUE";
      attribute DONT_TOUCH of s_count_voted           : signal is "TRUE";
      attribute DONT_TOUCH of s_time_quanta_pulse_tmr : signal is "TRUE";

      constant C_mismatch_count             : integer := 0;
      constant C_mismatch_time_quanta_pulse : integer := 1;
      constant C_MISMATCH_WIDTH             : integer := 2;

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
        INST_canola_time_quanta_gen: entity work.canola_time_quanta_gen
          generic map (
            G_TIME_QUANTA_SCALE_WIDTH => G_TIME_QUANTA_SCALE_WIDTH)
          port map (
            CLK               => CLK,
            RESET             => RESET,
            RESTART           => RESTART,
            CLK_SCALE         => CLK_SCALE,
            TIME_QUANTA_PULSE => s_time_quanta_pulse_tmr(i),
            COUNT_OUT         => s_count_out(i),
            COUNT_IN          => s_count_voted(i));
      end generate for_TMR_generate;

      -- -----------------------------------------------------------------------
      -- TMR voters
      -- -----------------------------------------------------------------------
      INST_count_voter : entity work.tmr_voter_triplicated_array
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK         => CLK,
          INPUT_A     => s_count_out(0),
          INPUT_B     => s_count_out(1),
          INPUT_C     => s_count_out(2),
          VOTER_OUT_A => s_count_voted(0),
          VOTER_OUT_B => s_count_voted(1),
          VOTER_OUT_C => s_count_voted(2),
          MISMATCH    => s_mismatch_vector(C_mismatch_count));

      INST_time_quanta_pulse_voter : entity work.tmr_voter
        generic map (
          G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
          G_MISMATCH_OUTPUT_REG => C_MISMATCH_OUTPUT_REG)
        port map (
          CLK       => CLK,
          INPUT_A   => s_time_quanta_pulse_tmr(0),
          INPUT_B   => s_time_quanta_pulse_tmr(1),
          INPUT_C   => s_time_quanta_pulse_tmr(2),
          VOTER_OUT => TIME_QUANTA_PULSE,
          MISMATCH  => s_mismatch_vector(C_mismatch_time_quanta_pulse));

    end block tmr_block;
  end generate if_TMR_generate;

end architecture structural;
