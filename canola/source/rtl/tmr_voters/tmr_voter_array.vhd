-------------------------------------------------------------------------------
-- Title      : Majority voter array for TMR
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : tmr_voter_array.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-24
-- Last update: 2020-02-13
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Majority voter with 3x input arrays, and a voted output array
--              for Triple Modular Redundancy (TMR)
--              Inspired by code for majority voters written in SystemVerilog
--              for the ALICE ITS upgrade by Matteo Lupi
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-24  1.0      svn     Created
-- 2020-02-13  1.1      svn     Renamed tmr_voter_array
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;


entity tmr_voter_array is
  generic (
    G_MISMATCH_OUTPUT_EN  : boolean := false;
    G_MISMATCH_OUTPUT_REG : boolean := false);
  port (
    CLK       : in  std_logic;
    INPUT_A   : in  std_logic_vector;
    INPUT_B   : in  std_logic_vector;
    INPUT_C   : in  std_logic_vector;
    VOTER_OUT : out std_logic_vector;
    MISMATCH  : out std_logic
    );
end entity tmr_voter_array;


architecture rtl of tmr_voter_array is
  signal s_mismatch : std_logic_vector(INPUT_A'range);
begin  -- architecture rtl

  assert INPUT_A'length = INPUT_B'length
    report "Lengths of input vectors A and B do not match"
    severity failure;

  assert INPUT_A'length = INPUT_C'length
    report "Lengths of input vectors A and C do not match"
    severity failure;

  assert INPUT_A'length = VOTER_OUT'length
    report "Lengths of input vectors A and output vector VOTER_OUT do not match"
    severity failure;

  GEN_tmr_voters: for i in INPUT_A'range generate
    INST_tmr_voter: entity work.tmr_voter
      generic map (
        G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
        G_MISMATCH_OUTPUT_REG => false) -- It will be registered below
      port map (
        CLK       => CLK,
        INPUT_A   => INPUT_A(i),
        INPUT_B   => INPUT_B(i),
        INPUT_C   => INPUT_C(i),
        VOTER_OUT => VOTER_OUT(i),
        MISMATCH  => s_mismatch(i));
  end generate GEN_tmr_voters;


  GEN_no_mismatch: if not G_MISMATCH_OUTPUT_EN generate
    MISMATCH <= '0';
  end generate GEN_no_mismatch;

  GEN_unreg_mismatch: if G_MISMATCH_OUTPUT_EN and not G_MISMATCH_OUTPUT_REG generate
    -- Mismatch output - not registered
    MISMATCH <= or_reduce(s_mismatch);
  end generate GEN_unreg_mismatch;

  GEN_reg_mismatch: if G_MISMATCH_OUTPUT_EN and G_MISMATCH_OUTPUT_REG generate
    -- Mismatch output - registered
    proc_reg_mismatch: process (CLK) is
    begin
      if rising_edge(clk) then
        MISMATCH <= or_reduce(s_mismatch);
      end if;
    end process proc_reg_mismatch;
  end generate GEN_reg_mismatch;

end architecture rtl;
