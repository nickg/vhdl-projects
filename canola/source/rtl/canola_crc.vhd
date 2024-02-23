-------------------------------------------------------------------------------
-- Title      : Cyclic Redundancy Check (CRC) for CAN bus
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_crc.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-07-05
-- Last update: 2020-09-04
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Cyclic Redundancy Check (CRC) calculator for the Canola
--              CAN controller. Implementes the CRC15 algorithm as
--              specified in CAN Specification 2.0.
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-07-05  1.0      svn     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;


entity canola_crc is
  port (
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    BIT_IN    : in  std_logic;
    BIT_VALID : in  std_logic;
    CRC_IN    : in  std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    CRC_OUT   : out std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0));
end entity canola_crc;

architecture rtl of canola_crc is
  constant c_polynomial : std_logic_vector(C_CAN_CRC_WIDTH downto 0) := x"4599";
begin
  -- purpose: Calculate CRC15, one bit at a time.
  --          Based on pseudo code for calculating CRC in
  --          BOSCH CAN Specification 2.0, Part A - page 13
  -- type   : sequential
  -- inputs : CLK, RESET, BIT_IN, BIT_VALID
  -- outputs: CRC_OUT
  proc_crc_calc: process (CLK) is
    variable v_crc      : std_logic_vector(14 downto 0);
    variable v_crc_next : std_logic;
  begin  -- process proc_crc_calc
    if rising_edge(CLK) then
      if RESET = '1' then
        v_crc := (others => '0');
      elsif BIT_VALID = '1' then
        v_crc      := CRC_IN;
        v_crc_next := BIT_IN xor v_crc(14);
        v_crc      := v_crc(13 downto 0) & '0';

        if v_crc_next = '1' then
          v_crc := v_crc xor c_polynomial(C_CAN_CRC_WIDTH-1 downto 0);
        end if;
      end if;
      CRC_OUT <= v_crc;
    end if;
  end process proc_crc_calc;
end architecture rtl;
