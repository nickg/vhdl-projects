-------------------------------------------------------------------------------
-- Title      : Up counter
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : up_counter.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-30
-- Last update: 2020-02-14
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Simple parametric upounter with enable.
--              Modified version of upcounter_core written for the
--              ALICE ITS upgrade by Matteo Lupi
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-30  1.0      svn     Created based on upcounter_core.vhd from
--                              ALICE ITS Upgrade project
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity up_counter is
  generic(
    BIT_WIDTH     : integer := 16;
    IS_SATURATING : boolean := false;
    VERBOSE       : boolean := false);
  port(
    CLK            : in  std_logic;     -- Clock
    RESET          : in  std_logic;     -- global fpga reset
    CLEAR          : in  std_logic;     -- clear counter
    COUNT_UP       : in  std_logic;     -- count up
    COUNT_OUT      : out std_logic_vector(BIT_WIDTH - 1 downto 0);

    -- Voted counter value input, the count is always increased from this input.
    -- Connect to COUNT_OUT externally when not using TMR.
    COUNT_VOTED_IN : in  std_logic_vector(BIT_WIDTH - 1 downto 0));
end entity up_counter;

architecture arch of up_counter is

  subtype t_counter is unsigned(BIT_WIDTH - 1 downto 0);
  signal i_counter, i_counter_voted : t_counter;
  constant C_COUNTER_ZERO           : t_counter := (others => '0');
  constant C_COUNTER_MAX            : t_counter := (others => '1');

  -- purpose: updates the counter
  --          if is saturating is true the counter saturates,
  --          otherwise it overflows and wraps around to zero
  function f_update_counter(
    constant is_saturating  : boolean;
    constant verbose        : boolean;
    constant i_actual_value : t_counter)
  return t_counter is
    variable i_next_value : t_counter;
  begin  -- function f_update_counter
    if i_actual_value = C_COUNTER_MAX then
      if is_saturating then
        i_next_value := i_actual_value;
        -- synthesis translate_off
        if verbose then
          report "Counter saturation" severity NOTE;
        end if;
      -- synthesis translate_on
      else
        i_next_value := C_COUNTER_ZERO;
        -- synthesis translate_off
        if verbose then
          report "Counter overflow" severity NOTE;
        end if;
        -- synthesis translate_on
      end if;
    else
      i_next_value := i_actual_value + 1;
    end if;
    return i_next_value;
  end function f_update_counter;

begin  -- architecture arch

  --input/output mapping
  COUNT_OUT       <= std_logic_vector(i_counter);
  i_counter_voted <= unsigned(COUNT_VOTED_IN);

  -- purpose: updates the counter
  p_counter_update : process(CLK) is
  begin  -- process p_counter_update
    if rising_edge(CLK) then
      if RESET = '1' or CLEAR = '1' then
        i_counter <= C_COUNTER_ZERO;
      elsif COUNT_UP = '1' then
        i_counter <= f_update_counter(IS_SATURATING, VERBOSE, i_counter_voted);
      end if;
    end if;
  end process p_counter_update;

end architecture arch;
