-------------------------------------------------------------------------------
-- Title      : Time quanta generator for CAN bus
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : can_time_quanta_gen.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-07-03
-- Last update: 2020-08-26
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Time quanta generator for the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-07-03  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

library work;
use work.canola_pkg.all;

-- Generates a pulse (1 CLK cycle long) on the TIME_QUANTA_PULSE
-- output every CLK_SCALE+1 clock cycles.
-- Note: A pulse is outputted immediately following reset.
entity canola_time_quanta_gen is
  generic (
    G_TIME_QUANTA_SCALE_WIDTH : natural);
  port (
    CLK               : in  std_logic;
    RESET             : in  std_logic;
    RESTART           : in  std_logic;
    CLK_SCALE         : in  unsigned(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);
    TIME_QUANTA_PULSE : out std_logic;

    -- Used for voting/TMR
    COUNT_OUT         : out std_logic_vector(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);
    COUNT_IN          : in  std_logic_vector(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0)
    );
end entity canola_time_quanta_gen;

architecture rtl of canola_time_quanta_gen is
  signal s_counter : unsigned(G_TIME_QUANTA_SCALE_WIDTH-1 downto 0);
begin  -- architecture rtl

  COUNT_OUT <= std_logic_vector(s_counter);

  proc_time_quanta_gen : process(CLK) is
  begin  -- process proc_fsm
    if rising_edge(CLK) then
      TIME_QUANTA_PULSE <= '0';

      -- Synchronous reset
      if RESET = '1' or RESTART = '1' then
        TIME_QUANTA_PULSE <= '0';
        s_counter         <= (others => '0');
      else
        if s_counter = CLK_SCALE then
          TIME_QUANTA_PULSE <= '1';
          s_counter         <= (others => '0');
        else
          s_counter <= unsigned(COUNT_IN) + 1;
        end if;
      end if;
    end if;
  end process proc_time_quanta_gen;

end architecture rtl;
