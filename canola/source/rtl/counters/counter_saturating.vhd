-------------------------------------------------------------------------------
-- Title      : Saturating counter
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : counter_saturating.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2020-01-30
-- Last update: 2020-01-31
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Simple up and down counter.
--              Saturates at the highest value when counting up, and saturates
--              at zero when counting down.
--              The code is based on counter_n written for the
--              ALICE ITS upgrade by Matteo Lupi and Matthias Bonora
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-30  1.0      svn     Created based on counter_n.vhd from
--                              ALICE ITS Upgrade project
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_saturating is
  generic (
    BIT_WIDTH  : natural := 16;
    INCR_WIDTH : natural := 16;
    VERBOSE    : boolean := false);
  port (
    CLK        : in std_logic; -- Clock
    RESET      : in std_logic; -- Global fpga reset
    CLEAR      : in std_logic; -- Counter clear
    SET        : in std_logic; -- Set counter to value
    SET_VALUE  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    COUNT_UP   : in std_logic;
    COUNT_DOWN : in std_logic;

    -- Value to count up/down by
    COUNT_INCR : in std_logic_vector(INCR_WIDTH-1 downto 0);

    -- Actual counter value output
    COUNT_OUT  : out std_logic_vector(BIT_WIDTH-1 downto 0);

    -- Voted counter value input, the count is always increased or decreased
    -- from this input. Connect to COUNT_OUT externally when not using TMR.
    COUNT_VOTED_IN : in std_logic_vector(BIT_WIDTH-1 downto 0));

end entity counter_saturating;


architecture arch of counter_saturating is

  signal i_counter : natural range 0 to (2**BIT_WIDTH)-1;

  -- purpose: Updates the counter.
  --          The counter saturates at 0 when counting
  --          down, and at (2**BIT_WIDTH)-1 when counting up.
  function f_update_counter (
    constant verbose         : boolean;
    constant count_up        : std_logic;
    constant count_down      : std_logic;
    constant i_count_current : natural;
    constant i_increment     : natural;
    constant C_bit_width     : natural)
    return natural is

    variable i_next_value : natural;
  begin  -- function f_update_counter
    if count_up = '1' then
      i_next_value := i_count_current + i_increment;

      if i_next_value >= (2**C_bit_width) then
        i_next_value := (2**C_bit_width - 1);
        -- synthesis translate_off
        if verbose then
          report "Counter high saturation" severity note;
        end if;
      -- synthesis translate_on
      end if;

    elsif count_down = '1' then
      if i_increment > i_count_current then
        i_next_value := 0;
        -- synthesis translate_off
        if verbose then
          report "Counter low saturation" severity note;
        end if;
      -- synthesis translate_on
      else
        i_next_value := i_count_current - i_increment;
      end if;

    else
      i_next_value := i_count_current;
    end if;


    return i_next_value;
  end function f_update_counter;

begin  -- architecture arch

  assert BIT_WIDTH >= INCR_WIDTH report "Increment width larger than counter width" severity failure;

  -- purpose: Updates the counter
  p_counter_update : process (CLK) is
    variable i_increment     : natural range 0 to (2**INCR_WIDTH) - 1;
    variable i_count_current : natural range 0 to (2**BIT_WIDTH) - 1;
  begin  -- process p_counter_update
    if rising_edge(CLK) then
      if RESET = '1' or CLEAR = '1' then
        i_counter <= 0;

        -- synthesis translate_off
        if VERBOSE then
          report "Counter reset" severity note;
        end if;
        -- synthesis translate_on

      elsif SET = '1' then
        i_counter <= to_integer(unsigned(SET_VALUE));

      else
        i_increment     := to_integer(unsigned(COUNT_INCR));
        i_count_current := to_integer(unsigned(COUNT_VOTED_IN));

        i_counter <= f_update_counter(VERBOSE, COUNT_UP, COUNT_DOWN,
                                   i_count_current, i_increment,
                                   BIT_WIDTH);
      end if;
    end if;
  end process p_counter_update;

  -----------------------------------------------------------------------------
  -- OUTPUT conversion
  -----------------------------------------------------------------------------
  COUNT_OUT <= std_logic_vector(to_unsigned(i_counter, BIT_WIDTH));

end architecture arch;
