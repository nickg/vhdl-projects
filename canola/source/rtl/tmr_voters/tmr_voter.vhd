-------------------------------------------------------------------------------
-- Title      : Majority voter for TMR
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : tmr_voter.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-24
-- Last update: 2020-02-13
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Majority voter with 3x single inputs, and a single voted
--              output for Triple Modular Redundancy (TMR).
--              Inspired by code for majority voters written in SystemVerilog
--              for the ALICE ITS upgrade by Matteo Lupi
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-24  1.0      svn     Created
-- 2020-02-13  1.1      svn     Renamed tmr_voter
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity tmr_voter is
  generic (
    G_MISMATCH_OUTPUT_EN  : boolean := false;
    G_MISMATCH_OUTPUT_REG : boolean := false);
  port (
    CLK       : in  std_logic;
    INPUT_A   : in  std_logic;
    INPUT_B   : in  std_logic;
    INPUT_C   : in  std_logic;
    VOTER_OUT : out std_logic;
    MISMATCH  : out std_logic
    );

  attribute DONT_TOUCH            : string;
  attribute DONT_TOUCH of INPUT_A : signal is "TRUE";
  attribute DONT_TOUCH of INPUT_B : signal is "TRUE";
  attribute DONT_TOUCH of INPUT_C : signal is "TRUE";
end entity tmr_voter;

architecture rtl of tmr_voter is

begin  -- architecture rtl

  -- Majority vote of the inputs
  proc_voter : process (INPUT_A, INPUT_B, INPUT_C) is
  begin
    if INPUT_A = '1' and INPUT_B = '1' then
      VOTER_OUT <= '1';
    elsif INPUT_A = '1' and INPUT_C = '1' then
      VOTER_OUT <= '1';
    elsif INPUT_B = '1' and INPUT_C = '1' then
      VOTER_OUT <= '1';
    else
      VOTER_OUT <= '0';
    end if;
  end process proc_voter;


  GEN_unregistered_mismatch: if G_MISMATCH_OUTPUT_EN and not G_MISMATCH_OUTPUT_REG generate
    -- Mismatch output - unregistered
    proc_unreg_mismatch: process (INPUT_A, INPUT_B, INPUT_C) is
    begin
      if INPUT_A = '1' and INPUT_B = '1' and INPUT_C = '1' then
        MISMATCH <= '0';
      elsif INPUT_A = '0' and INPUT_B = '0' and INPUT_C = '0' then
        MISMATCH <= '0';
      else
        MISMATCH <= '1';
      end if;
    end process proc_unreg_mismatch;
  end generate GEN_unregistered_mismatch;


  GEN_registered_mismatch: if G_MISMATCH_OUTPUT_EN and G_MISMATCH_OUTPUT_REG generate
    -- Mismatch output - registered
    proc_reg_mismatch: process (CLK) is
    begin
      if rising_edge(clk) then
        if INPUT_A = '1' and INPUT_B = '1' and INPUT_C = '1' then
          MISMATCH <= '0';
        elsif INPUT_A = '0' and INPUT_B = '0' and INPUT_C = '0' then
          MISMATCH <= '0';
        else
          MISMATCH <= '1';
        end if;
      end if;
    end process proc_reg_mismatch;
  end generate GEN_registered_mismatch;

end architecture rtl;
