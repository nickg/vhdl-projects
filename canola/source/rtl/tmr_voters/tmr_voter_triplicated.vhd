-------------------------------------------------------------------------------
-- Title      : Triplicated majority voter for TMR
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : tmr_voter_triplicated.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-24
-- Last update: 2020-02-13
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Majority voter with 3x single inputs, and 3x voted outputs for
--              Triple Modular Redundancy (TMR).
--              Inspired by code for majority voters written in SystemVerilog
--              for the ALICE ITS upgrade by Matteo Lupi
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-24  1.0      svn     Created
-- 2020-02-13  1.1      svn     Renamed tmr_voter_triplicated
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;


entity tmr_voter_triplicated is
  generic (
    G_MISMATCH_OUTPUT_EN  : boolean := false;
    G_MISMATCH_OUTPUT_REG : boolean := false);
  port (
    CLK         : in  std_logic;
    INPUT_A     : in  std_logic;
    INPUT_B     : in  std_logic;
    INPUT_C     : in  std_logic;
    VOTER_OUT_A : out std_logic;
    VOTER_OUT_B : out std_logic;
    VOTER_OUT_C : out std_logic;
    MISMATCH    : out std_logic
    );

  attribute DONT_TOUCH                : string;
  attribute DONT_TOUCH of INPUT_A     : signal is "TRUE";
  attribute DONT_TOUCH of INPUT_B     : signal is "TRUE";
  attribute DONT_TOUCH of INPUT_C     : signal is "TRUE";
  attribute DONT_TOUCH of VOTER_OUT_A : signal is "TRUE";
  attribute DONT_TOUCH of VOTER_OUT_B : signal is "TRUE";
  attribute DONT_TOUCH of VOTER_OUT_C : signal is "TRUE";
end entity tmr_voter_triplicated;


architecture rtl of tmr_voter_triplicated is
  signal s_mismatch : std_logic_vector(2 downto 0);
begin  -- architecture rtl

  INST_tmr_voter_A : entity work.tmr_voter
    generic map (
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => false)   -- It will be registered below
    port map (
      CLK       => CLK,
      INPUT_A   => INPUT_A,
      INPUT_B   => INPUT_B,
      INPUT_C   => INPUT_C,
      VOTER_OUT => VOTER_OUT_A,
      MISMATCH  => s_mismatch(0));

  INST_tmr_voter_B : entity work.tmr_voter
    generic map (
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => false)   -- It will be registered below
    port map (
      CLK       => CLK,
      INPUT_A   => INPUT_A,
      INPUT_B   => INPUT_B,
      INPUT_C   => INPUT_C,
      VOTER_OUT => VOTER_OUT_B,
      MISMATCH  => s_mismatch(1));

  INST_tmr_voter_C : entity work.tmr_voter
    generic map (
      G_MISMATCH_OUTPUT_EN  => G_MISMATCH_OUTPUT_EN,
      G_MISMATCH_OUTPUT_REG => false)   -- It will be registered below
    port map (
      CLK       => CLK,
      INPUT_A   => INPUT_A,
      INPUT_B   => INPUT_B,
      INPUT_C   => INPUT_C,
      VOTER_OUT => VOTER_OUT_C,
      MISMATCH  => s_mismatch(2));


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
