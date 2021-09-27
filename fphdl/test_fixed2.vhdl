-- Test vectors for the fixed point math package, part 2
-- This is a test for the fixed point math packages.
-- Created for vhdl-200x by David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
--   modification history : Last Modified $Date: 2007-09-12 08:58:36-04 $
--   Version $Id: test_fixed2.vhdl,v 1.7 2007-09-12 08:58:36-04 l435385 Exp $
-- --------------------------------------------------------------------

entity test_fixed2 is
  generic (
    quiet : BOOLEAN := false);          -- make the simulation quiet
end entity test_fixed2;

use std.textio.all;
library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

architecture testbench of test_fixed2 is

  constant iterations : NATURAL := 10000;  -- used in random number test
  constant debug      : BOOLEAN := false;  -- debug mode, prints out lots of data
  -- purpose: reports an error
  procedure report_error (
    constant errmes   : in STRING;      -- error message
    actual            : in ufixed;      -- data from algorithm
    constant expected : in ufixed) is   -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & LF
      & "     /= " & to_string(expected)
      & " (" & REAL'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes   :    STRING;      -- error message
    actual            : in sfixed;      -- data from algorithm
    constant expected :    sfixed) is   -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & LF
      & "     /= " & to_string(expected)
      & " (" & REAL'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes   :    STRING;               -- error message
    actual            : in STD_LOGIC_VECTOR;     -- data from algorithm
    constant expected :    STD_LOGIC_VECTOR) is  -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(to_ufixed(actual, actual'length-1, 0)) & LF
      & "     /= " & to_string(to_sfixed(expected, expected'length-1, 0))
      severity error;
    return;
  end procedure report_error;

  subtype ufixed7_3 is ufixed (3 downto -3);                          -- 7 bit
  subtype ufixed16_8 is ufixed (7 downto -8);                         -- 16 bit
  subtype ufixed17_8 is ufixed (8 downto -8);                         -- 17 bit
  subtype sfixed7_3 is sfixed (3 downto -3);                          -- 7 bit
  subtype sfixed8_3 is sfixed (4 downto -3);                          -- 8 bit
  subtype sfixed16_8 is sfixed (7 downto -8);                         -- 16 bit
  signal start_nullrangetest, nullrangetest_done : BOOLEAN := false;  -- start reading test
  signal start_saturatetest, saturatetest_done   : BOOLEAN := false;
  signal start_ssaturatetest, ssaturatetest_done : BOOLEAN := false;  -- signed
  signal start_fromstrtest, fromstrtest_done     : BOOLEAN := false;  -- from_string
  signal start_randomtest, randomtest_done       : BOOLEAN := false;
  signal start_randomstest, randomstest_done     : BOOLEAN := false;
  signal start_accumtest, accumtest_done         : BOOLEAN := false;  -- accumulator test
  signal start_overloadtest, overloadtest_done   : BOOLEAN := false;  -- overload test
  signal start_divmodtest, divmodtest_done       : BOOLEAN := false;  -- div and mod
  signal start_reduce_test, reduce_test_done     : BOOLEAN := false;  -- reduce
  signal start_booltest, booltest_done           : BOOLEAN := false;  -- boolean
                                        -- functions
  signal start_vecbool, vecbool_done             : BOOLEAN := false;  -- vector booleans
  signal start_matchtest, matchtest_done         : BOOLEAN := false;  -- vector booleans
begin  -- architecture testbench

  -- purpose: Main test process
  tester : process is

  begin  -- process tester

    ---------------------------------------------------------------------------
    -- Saturation and rounding test
    ---------------------------------------------------------------------------
    start_saturatetest  <= true;        -- unsigned number test
    wait until saturatetest_done;
    start_ssaturatetest <= true;        -- signed number test
    wait until ssaturatetest_done;

    ---------------------------------------------------------------------------
    -- Overloaded function test
    ---------------------------------------------------------------------------
    start_overloadtest <= true;
    wait until overloadtest_done;
    start_reduce_test  <= true;
    wait until reduce_test_done;
    start_booltest     <= true;
    wait until booltest_done;
    start_vecbool      <= true;
    wait until vecbool_done;
    start_matchtest    <= true;
    wait until matchtest_done;
    ---------------------------------------------------------------------------
    -- From_string test
    ---------------------------------------------------------------------------
    start_fromstrtest  <= true;
    wait until fromstrtest_done;

    ---------------------------------------------------------------------------
    -- Div and mod test
    ---------------------------------------------------------------------------
    start_divmodtest <= true;
    wait until divmodtest_done;

    ---------------------------------------------------------------------------
    -- Accumulator test
    ---------------------------------------------------------------------------
    start_accumtest <= true;
    wait until accumtest_done;

    ---------------------------------------------------------------------------
    -- Null range test
    ---------------------------------------------------------------------------
    start_nullrangetest <= true;
    wait until nullrangetest_done;

    ---------------------------------------------------------------------------
    -- Random number test
    ---------------------------------------------------------------------------
    start_randomtest  <= true;
    wait until randomtest_done;
    start_randomstest <= true;
    wait until randomstest_done;

    report "Fixed point package testing part 2 complete";
    wait;

  end process tester;
  -- purpose: test the saturation and rounding
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  saturatetest : process is
    variable check7uf1, check7uf2, check7uf3 : ufixed7_3;
    variable check3uf1, check3uf2            : ufixed (4 downto 2);  -- odd range
    variable checkint                        : INTEGER;
    variable checkreal                       : REAL;
    variable checkuns                        : UNSIGNED (5 downto 0);
    variable check7sf1, check7sf2, check7sf3 : sfixed7_3;
  begin  -- process saturatetest
    wait until start_saturatetest;
    check3uf1 := "001";                 -- 4
    check7uf1 := resize (arg            => check3uf1,
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7uf2 := "0100000";             -- 4
    report_error ("resize 4 dt 2 to 3 dt -3 error", check7uf1, check7uf2);
    check3uf1 := "101";                 -- 20
    check7uf1 := resize (arg            => check3uf1,
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7uf2 := (others => '1');       -- saturation
    report_error ("resize 4 dt 2 to 3 dt -3 sat error", check7uf1, check7uf2);
    check3uf1 := "101";                 -- 20
    check7uf1 := resize (arg            => check3uf1,
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_wrap);           -- wrap
    check7uf2 := "0100000";             -- 4
    report_error ("resize 4 dt 2 to 3 dt -3 wrap error", check7uf1, check7uf2);
    check7uf1 := resize (arg            => to_ufixed (7.96875, 3, -5),  -- "0111.11111"
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7uf2 := "0111111";             -- 7.875
    report_error ("resize to 3 dt -3 no round error", check7uf1, check7uf2);
    check7uf1 := resize (arg            => to_ufixed (7.96875, 3, -5),  -- "0111.11111"
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_saturate);       -- saturate
    check7uf2 := "1000000";             -- 8
    report_error ("resize to 3 dt -3 wrap round error", check7uf1, check7uf2);
    check7uf1 := resize (arg            => to_ufixed (15.96875, 3, -5),  -- "1111.11111"
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_wrap);           -- wrap
    check7uf2 := (others => '0');       -- 0
    report_error ("resize to 3 dt -3 wrap round error", check7uf1, check7uf2);
    check7uf1 := resize (arg            => to_ufixed (15.96875, 3, -5),  -- "1111.11111"
                         left_index     => check7uf1'high,
                         right_index    => check7uf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_wrap);           -- wrap
    check7uf2 := "1111111";             -- 15.875
    report_error ("resize to 3 dt -3 wrap no round error", check7uf1, check7uf2);
    -- integer to ufixed
    if (not quiet) then
      checkint := 17;
      report "Expect to_ufixed(integer) overflow error" severity note;
      check7uf1 := to_ufixed (arg            => checkint,
                              left_index     => check7uf1'high,
                              right_index    => check7uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check7uf2 := (others => '1');
      report_error ("to_ufixed 17 failed to saturate", check7uf1, check7uf2);
      checkint  := 17;
      report "Expect to_ufixed(integer) overflow error" severity note;
      check7uf1 := to_ufixed (arg            => checkint,
                              left_index     => check7uf1'high,
                              right_index    => check7uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7uf2 := "0001000";           -- 1
      report_error ("to_ufixed 17 failed to wrap", check7uf1, check7uf2);
    end if;
    checkint := 5;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed 5 not round_test", check3uf1, check3uf2);
    checkint  := 5;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed 5 round_test", check3uf1, check3uf2);
    checkint  := 7;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed 7 not round_test", check3uf1, check3uf2);
    checkint  := 7;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "010";
    report_error ("to_ufixed 7 round_test", check3uf1, check3uf2);
    checkint  := 17;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed 17 not round_test", check3uf1, check3uf2);
    checkint  := 17;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed 17 round_test", check3uf1, check3uf2);
    checkint  := 19;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed 19 not round_test", check3uf1, check3uf2);
    checkint  := 19;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "101";
    report_error ("to_ufixed 19 round_test", check3uf1, check3uf2);
    checkint  := 24;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed 24 not round_test", check3uf1, check3uf2);
    checkint  := 24;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed 24 round_test", check3uf1, check3uf2);
    checkint  := 27;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed 27 not round_test", check3uf1, check3uf2);
    checkint  := 27;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 27 round_test", check3uf1, check3uf2);
    checkint  := 31;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 31 not round_test", check3uf1, check3uf2);
    checkint  := 31;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 31 round_test", check3uf1, check3uf2);
    checkint  := 31;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- wrap
    check3uf2 := "111";
    report_error ("to_ufixed 31 wrap not round_test", check3uf1, check3uf2);
    checkint  := 31;
    check3uf1 := to_ufixed (arg            => checkint,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "000";
    report_error ("to_ufixed 31 wrap round_test", check3uf1, check3uf2);
    if (not quiet) then
      checkint := 35;
      report "Expect to_ufixed(integer) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkint,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check3uf2 := "111";
      report_error ("to_ufixed 35 not round_test", check3uf1, check3uf2);
      checkint  := 35;
      report "Expect to_ufixed(integer) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkint,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_saturate);  -- saturate
      check3uf2 := "111";
      report_error ("to_ufixed 35 round_test", check3uf1, check3uf2);
      checkint  := 35;
      report "Expect to_ufixed(integer) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkint,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- saturate
      check3uf2 := "000";
      report_error ("to_ufixed 35 wrap not round_test", check3uf1, check3uf2);
      checkint  := 35;
      report "Expect to_ufixed(integer) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkint,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);      -- saturate
      check3uf2 := "001";
      report_error ("to_ufixed 35 wrap round_test", check3uf1, check3uf2);
    end if;
    -- real number unsigned fixed
    if (not quiet) then
      checkreal := 17.0;
      report "Expect to_ufixed(real) overflow error" severity note;
      check7uf1 := to_ufixed (arg            => checkreal,
                              left_index     => check7uf1'high,
                              right_index    => check7uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check7uf2 := (others => '1');
      report_error ("to_ufixed 17.0 failed to saturate", check7uf1, check7uf2);
      checkreal := 17.0;
      report "Expect to_ufixed(real) overflow error" severity note;
      check7uf1 := to_ufixed (arg            => checkreal,
                              left_index     => check7uf1'high,
                              right_index    => check7uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7uf2 := "0001000";           -- 1
      report_error ("to_ufixed 17.0 failed to wrap", check7uf1, check7uf2);
    end if;
    checkreal := 5.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed 5.0 not round_test", check3uf1, check3uf2);
    checkreal := 5.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed 5.0 round_test", check3uf1, check3uf2);
    checkreal := 7.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed 7.0 not round_test", check3uf1, check3uf2);
    checkreal := 7.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "010";
    report_error ("to_ufixed 7.0 round_test", check3uf1, check3uf2);
    checkreal := 17.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed 17.0 not round_test", check3uf1, check3uf2);
    checkreal := 17.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed 17.0 round_test", check3uf1, check3uf2);
    checkreal := 19.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed 19.0 not round_test", check3uf1, check3uf2);
    checkreal := 19.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "101";
    report_error ("to_ufixed 19.0 round_test", check3uf1, check3uf2);
    checkreal := 24.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed 24.0 not round_test", check3uf1, check3uf2);
    checkreal := 24.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed 24.0 round_test", check3uf1, check3uf2);
    checkreal := 27.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed 27.0 not round_test", check3uf1, check3uf2);
    checkreal := 27.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 27.0 round_test", check3uf1, check3uf2);
    checkreal := 31.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 31.0 not round_test", check3uf1, check3uf2);
    checkreal := 31.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 31.0 round_test", check3uf1, check3uf2);
    checkreal := 31.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed 31.0 wrap not round_test", check3uf1, check3uf2);
    checkreal := 31.0;
    check3uf1 := to_ufixed (arg            => checkreal,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "000";
    report_error ("to_ufixed 31.0 wrap round_test", check3uf1, check3uf2);
    if (not quiet) then
      checkreal := 35.0;
      report "Expect to_ufixed(real) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkreal,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check3uf2 := "111";
      report_error ("to_ufixed 35.0 not round_test", check3uf1, check3uf2);
      checkreal := 35.0;
      report "Expect to_ufixed(real) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkreal,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_saturate);  -- saturate
      check3uf2 := "111";
      report_error ("to_ufixed 35.0 round_test", check3uf1, check3uf2);
      checkreal := 35.0;
      report "Expect to_ufixed(real) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkreal,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- saturate
      check3uf2 := "000";
      report_error ("to_ufixed 35.0 wrap not round_test", check3uf1, check3uf2);
      checkreal := 35.0;
      report "Expect to_ufixed(real) overflow error" severity note;
      check3uf1 := to_ufixed (arg            => checkreal,
                              left_index     => check3uf1'high,
                              right_index    => check3uf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);      -- saturate
      check3uf2 := "001";
      report_error ("to_ufixed 35.0 wrap round_test", check3uf1, check3uf2);
    end if;
    -- unsigned
    checkuns := to_unsigned (17, checkuns'length);
    check7uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check7uf1'high,
                            right_index    => check7uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check7uf2 := (others => '1');
    report_error ("to_ufixed uns 17 failed to saturate", check7uf1, check7uf2);
    checkuns  := to_unsigned (17, checkuns'length);
    check7uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check7uf1'high,
                            right_index    => check7uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- wrap
    check7uf2 := "0001000";             -- 1
    report_error ("to_ufixed uns 17 failed to wrap", check7uf1, check7uf2);
    checkuns  := to_unsigned (5, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed uns 5 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (5, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed uns 5 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (7, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed uns 7 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (7, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "010";
    report_error ("to_ufixed uns 7 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (17, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed uns 17 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (17, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed uns 17 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (19, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "100";
    report_error ("to_ufixed uns 19 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (19, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "101";
    report_error ("to_ufixed uns 19 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (24, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed uns 24 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (24, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed uns 24 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (27, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "110";
    report_error ("to_ufixed uns 27 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (27, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed uns 27 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (31, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed uns 31 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (31, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed uns 31 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (31, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed uns 31 wrap not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (31, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "000";
    report_error ("to_ufixed uns 31 wrap round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (35, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed uns 35 not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (35, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3uf2 := "111";
    report_error ("to_ufixed uns 35 round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (35, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "000";
    report_error ("to_ufixed uns 35 wrap not round_test", check3uf1, check3uf2);
    checkuns  := to_unsigned (35, checkuns'length);
    check3uf1 := to_ufixed (arg            => checkuns,
                            left_index     => check3uf1'high,
                            right_index    => check3uf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3uf2 := "001";
    report_error ("to_ufixed uns 35 wrap round_test", check3uf1, check3uf2);
    -- signed
    assert (quiet) report "Rounding test completed"
      severity note;
    saturatetest_done <= true;
    wait;
  end process saturatetest;

  -- purpose: test the signed saturation and rounding
  ssaturatetest : process is
    variable check7sf1, check7sf2, check7sf3 : sfixed8_3;
    variable check3sf1, check3sf2            : sfixed (5 downto 2);  -- odd range
    variable check9sf, check9sf2             : sfixed (3 downto -5);
    variable check10sf                       : sfixed (4 downto -5);
    variable checkint                        : INTEGER;
    variable checkreal                       : REAL;
    variable checks                          : SIGNED (6 downto 0);
  begin  -- process saturatetest
    wait until start_ssaturatetest;
    check3sf1 := "0001";                -- 4
    check7sf1 := resize (arg            => check3sf1,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "00100000";            -- 4
    report_error ("resize signed 4 dt 2 to 3 dt -3 error",
                  check7sf1, check7sf2);
    check3sf1 := "0101";                -- 20
    check7sf1 := resize (arg            => check3sf1,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2                  := (others => '1');    -- saturation
    check7sf2 (check7sf2'high) := '0';
    report_error ("resize signed 4 dt 2 to 3 dt -3 sat error",
                  check7sf1, check7sf2);
    check3sf1 := "0101";                -- 20
    check7sf1 := resize (arg            => check3sf1,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_wrap);           -- wrap
    check7sf2 := "10100000";            -- -12
    report_error ("resize signed 4 dt 2 to 3 dt -3 wrap error",
                  check7sf1, check7sf2);
    check9sf := to_sfixed (7.96875, 3, -5);           -- "0111.11111"
    check7sf1 := resize (arg            => check9sf,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "00111111";            -- 7.875
    report_error ("resize signed to 3 dt -3 no round error",
                  check7sf1, check7sf2);
    check9sf := to_sfixed (7.96875, 3, -5);           -- "0111.11111"
    check7sf1 := resize (arg            => check9sf,  -- "0111.11111"
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "01000000";            -- 8
    report_error ("resize signed to 3 dt -3 round error",
                  check7sf1, check7sf2);
    check10sf := to_sfixed (15.96875, 4, -5);         -- "01111.11111"
    check7sf1 := resize (arg            => check10sf,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_wrap);           -- wrap
    check7sf2 := "10000000";            -- -16
    report_error ("resize signed to 3 dt -3 wrap round error",
                  check7sf1, check7sf2);
    check7sf1 := resize (arg            => to_sfixed (15.96875, 4, -5),  -- "01111.11111"
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_wrap);           -- wrap
    check7sf2 := "01111111";            -- 15.875
    report_error ("resize signed to 3 dt -3 wrap no round error",
                  check7sf1, check7sf2);
    -- integer to sfixed
    if (not quiet) then
      checkint := 17;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check7sf2                  := (others => '1');
      check7sf2 (check7sf2'high) := '0';
      report_error ("to_sfixed 17 failed to saturate", check7sf1, check7sf2);
      checkint                   := 17;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "10001000";          -- -15
      report_error ("to_sfixed 17 failed to wrap", check7sf1, check7sf2);
      checkint  := 49;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "10001000";          -- -15
      report_error ("to_sfixed 49 failed to wrap", check7sf1, check7sf2);
      checkint  := 113;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "10001000";          -- -15
      report_error ("to_sfixed 113 failed to wrap", check7sf1, check7sf2);
    end if;
    checkint := 5;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed 5 not round_test", check3sf1, check3sf2);
    checkint  := 5;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed 5 round_test", check3sf1, check3sf2);
    checkint  := 7;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed 7 not round_test", check3sf1, check3sf2);
    checkint  := 7;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0010";
    report_error ("to_sfixed 7 round_test", check3sf1, check3sf2);
    checkint  := 17;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed 17 not round_test", check3sf1, check3sf2);
    checkint  := 17;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed 17 round_test", check3sf1, check3sf2);
    checkint  := 19;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed 19 not round_test", check3sf1, check3sf2);
    checkint  := 19;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0101";
    report_error ("to_sfixed 19 round_test", check3sf1, check3sf2);
    checkint  := 24;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed 24 not round_test", check3sf1, check3sf2);
    checkint  := 24;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed 24 round_test", check3sf1, check3sf2);
    checkint  := 27;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed 27 not round_test", check3sf1, check3sf2);
    checkint  := 27;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 27 round_test", check3sf1, check3sf2);
    checkint  := 31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 31 not round_test", check3sf1, check3sf2);
    checkint  := 31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 31 round_test", check3sf1, check3sf2);
    checkint  := 31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 31 wrap not round_test", check3sf1, check3sf2);
    checkint  := 31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";
    report_error ("to_sfixed 31 wrap round_test", check3sf1, check3sf2);
    if (not quiet) then
      checkint := 35;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "0111";
      report_error ("to_sfixed 35 not round_test", check3sf1, check3sf2);
      checkint  := 35;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "0111";
      report_error ("to_sfixed 35 round_test", check3sf1, check3sf2);
      checkint  := 35;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "1000";
      report_error ("to_sfixed 35 wrap not round_test", check3sf1, check3sf2);
      checkint  := 35;
      report "Expect to_sfixed(integer) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "1001";
      report_error ("to_sfixed 35 wrap round_test", check3sf1, check3sf2);
    end if;
    -- real number signed fixed
    if (not quiet) then
      checkreal := 17.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check7sf2                  := (others => '1');
      check7sf2 (check7sf2'high) := '0';
      report_error ("to_sfixed 17.0 failed to saturate", check7sf1, check7sf2);
      checkreal                  := 17.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "10001000";          -- 1
      report_error ("to_sfixed 49.0 failed to wrap", check7sf1, check7sf2);
      checkreal := 49.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "10001000";          -- 1
      report_error ("to_sfixed 113.0 failed to wrap", check7sf1, check7sf2);
      checkreal := 113.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "10001000";          -- 1
      report_error ("to_sfixed 17.0 failed to wrap", check7sf1, check7sf2);
    end if;
    checkreal := 5.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed 5.0 not round_test", check3sf1, check3sf2);
    checkreal := 5.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed 5.0 round_test", check3sf1, check3sf2);
    checkreal := 7.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed 7.0 not round_test", check3sf1, check3sf2);
    checkreal := 7.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0010";
    report_error ("to_sfixed 7.0 round_test", check3sf1, check3sf2);
    checkreal := 17.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed 17.0 not round_test", check3sf1, check3sf2);
    checkreal := 17.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed 17.0 round_test", check3sf1, check3sf2);
    checkreal := 19.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed 19.0 not round_test", check3sf1, check3sf2);
    checkreal := 19.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0101";
    report_error ("to_sfixed 19.0 round_test", check3sf1, check3sf2);
    checkreal := 24.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed 24.0 not round_test", check3sf1, check3sf2);
    checkreal := 24.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed 24.0 round_test", check3sf1, check3sf2);
    checkreal := 27.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed 27.0 not round_test", check3sf1, check3sf2);
    checkreal := 27.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 27.0 round_test", check3sf1, check3sf2);
    checkreal := 31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 31.0 not round_test", check3sf1, check3sf2);
    checkreal := 31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 31.0 round_test", check3sf1, check3sf2);
    checkreal := 31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed 31.0 wrap not round_test", check3sf1, check3sf2);
    checkreal := 31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";                -- overflow into the sign bit and wrap
    report_error ("to_sfixed 31.0 wrap round_test", check3sf1, check3sf2);
    if (not quiet) then
      checkreal := 35.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "0111";
      report_error ("to_sfixed 35.0 not round_test", check3sf1, check3sf2);
      checkreal := 35.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "0111";
      report_error ("to_sfixed 35.0 round_test", check3sf1, check3sf2);
      checkreal := 35.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "1000";
      report_error ("to_sfixed 35.0 wrap not round_test", check3sf1, check3sf2);
      checkreal := 35.0;
      report "Expect to_sfixed(real) overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "1001";
      report_error ("to_sfixed 35.0 wrap round_test", check3sf1, check3sf2);
    end if;
    -- signed
    checks := to_signed (17, checks'length);
    check7sf1 := to_sfixed (arg            => checks,
                            left_index     => check7sf1'high,
                            right_index    => check7sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check7sf2                  := (others => '1');
    check7sf2 (check7sf2'high) := '0';
    report_error ("to_sfixed s 17 failed to saturate", check7sf1, check7sf2);
    checks                     := to_signed (17, checks'length);
    check7sf1 := to_sfixed (arg            => checks,
                            left_index     => check7sf1'high,
                            right_index    => check7sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- wrap
    check7sf2 := "10001000";            -- 1
    report_error ("to_sfixed s 17 failed to wrap", check7sf1, check7sf2);
    checks    := to_signed (5, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed s 5 not round_test", check3sf1, check3sf2);
    checks    := to_signed (5, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed s 5 round_test", check3sf1, check3sf2);
    checks    := to_signed (7, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0001";
    report_error ("to_sfixed s 7 not round_test", check3sf1, check3sf2);
    checks    := to_signed (7, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0010";
    report_error ("to_sfixed s 7 round_test", check3sf1, check3sf2);
    checks    := to_signed (17, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed s 17 not round_test", check3sf1, check3sf2);
    checks    := to_signed (17, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed s 17 round_test", check3sf1, check3sf2);
    checks    := to_signed (19, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0100";
    report_error ("to_sfixed s 19 not round_test", check3sf1, check3sf2);
    checks    := to_signed (19, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0101";
    report_error ("to_sfixed s 19 round_test", check3sf1, check3sf2);
    checks    := to_signed (24, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed s 24 not round_test", check3sf1, check3sf2);
    checks    := to_signed (24, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed s 24 round_test", check3sf1, check3sf2);
    checks    := to_signed (27, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0110";
    report_error ("to_sfixed s 27 not round_test", check3sf1, check3sf2);
    checks    := to_signed (27, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed s 27 round_test", check3sf1, check3sf2);
    checks    := to_signed (31, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed s 31 not round_test", check3sf1, check3sf2);
    checks    := to_signed (31, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed s 31 round_test", check3sf1, check3sf2);
    checks    := to_signed (31, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed s 31 wrap not round_test", check3sf1, check3sf2);
    checks    := to_signed (31, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";
    report_error ("to_sfixed s 31 wrap round_test", check3sf1, check3sf2);
    checks    := to_signed (35, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed s 35 not round_test", check3sf1, check3sf2);
    checks    := to_signed (35, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "0111";
    report_error ("to_sfixed s 35 round_test", check3sf1, check3sf2);
    checks    := to_signed (35, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";
    report_error ("to_sfixed s 35 wrap not round_test", check3sf1, check3sf2);
    checks    := to_signed (35, checks'length);
    check3sf1 := to_sfixed (arg            => checks,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1001";
    report_error ("to_sfixed s 35 wrap round_test", check3sf1, check3sf2);
    ---------------------------------------------------------------------------
    -- Negative number test
    ---------------------------------------------------------------------------
    check3sf1 := "1111";                -- -4
    check7sf1 := resize (arg            => check3sf1,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "11100000";            -- -4
    report_error ("resize -signed 4 dt 2 to 3 dt -3 error",
                  check7sf1, check7sf2);
    check3sf1 := "1011";                -- -20
    check7sf1 := resize (arg            => check3sf1,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2                  := (others => '0');    -- saturation
    check7sf2 (check7sf2'high) := '1';
    report_error ("resize -signed 4 dt 2 to 3 dt -3 sat error",
                  check7sf1, check7sf2);
    check3sf1 := "1011";                -- -20
    check7sf1 := resize (arg            => check3sf1,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_wrap);           -- wrap
    check7sf2 := "01100000";            -- 12
    report_error ("resize -signed 4 dt 2 to 3 dt -3 wrap error",
                  check7sf1, check7sf2);
    check9sf := "100000011";            -- -7.90625
    check7sf1 := resize (arg            => check9sf,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "11000000";            -- -8.0
    report_error ("resize -signed to 3 dt -3 no round error",
                  check7sf1, check7sf2);
    check9sf := "100000011";            -- -7.90625
    check7sf1 := resize (arg            => check9sf,  -- "0111.11111"
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "11000001";            -- -7.875
    report_error ("resize -signed to 3 dt -3 round error",
                  check7sf1, check7sf2);
    check9sf := "100000001";            -- -7.96875
    check7sf1 := resize (arg            => check9sf,  -- "0111.11111"
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_saturate);       -- saturate
    check7sf2 := "11000000";            -- -8
    report_error ("resize -signed to 3 dt -3 round error",
                  check7sf1, check7sf2);
    check10sf := "1111111111";          -- -1
    check7sf1 := resize (arg            => check10sf,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_wrap);           -- wrap
    check7sf2 := (others => '0');       -- -1
    report_error ("resize -signed to 3 dt -3 wrap round error",
                  check7sf1, check7sf2);
    check10sf := "1111111100";          -- -1
    check7sf1 := resize (arg            => check10sf,
                         left_index     => check7sf1'high,
                         right_index    => check7sf1'low,
                         round_style    => fixed_round,
                         overflow_style => fixed_wrap);           -- wrap
    check7sf2 := "11111111";            -- -1
    report_error ("resize -signed to 3 dt -3 wrap round error",
                  check7sf1, check7sf2);
    -- integer to sfixed
    if (not quiet) then
      checkint := -17;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check7sf2                  := (others => '0');
      check7sf2 (check7sf2'high) := '1';
      report_error ("to_sfixed -17 failed to saturate", check7sf1, check7sf2);
      checkint                   := -17;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "01111000";          -- 15
      report_error ("to_sfixed -17 failed to wrap", check7sf1, check7sf2);
      checkint  := -18;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "01110000";          -- 14
      report_error ("to_sfixed -18 failed to wrap", check7sf1, check7sf2);
      checkint  := -50;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "01110000";          -- 14
      report_error ("to_sfixed -50 failed to wrap", check7sf1, check7sf2);
      checkint  := -114;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkint,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "01110000";          -- 14
      report_error ("to_sfixed -114 failed to wrap", check7sf1, check7sf2);
    end if;
    checkint := -5;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1110";                -- -8
    report_error ("to_sfixed -5 not round_test", check3sf1, check3sf2);
    checkint  := -5;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1111";                -- -4
    report_error ("to_sfixed -5 round_test", check3sf1, check3sf2);
    checkint  := -7;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1110";                -- -8
    report_error ("to_sfixed -7 not round_test", check3sf1, check3sf2);
    checkint  := -7;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1110";
    report_error ("to_sfixed -7 round_test", check3sf1, check3sf2);
    checkint  := -17;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1011";                -- -20
    report_error ("to_sfixed -17 not round_test", check3sf1, check3sf2);
    checkint  := -17;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1100";                -- -16
    report_error ("to_sfixed -17 round_test", check3sf1, check3sf2);
    checkint  := -19;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1011";                -- -20
    report_error ("to_sfixed -19 not round_test", check3sf1, check3sf2);
    checkint  := -19;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1011";
    report_error ("to_sfixed -19 round_test", check3sf1, check3sf2);
    checkint  := -24;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1010";
    report_error ("to_sfixed -24 not round_test", check3sf1, check3sf2);
    checkint  := -24;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1010";
    report_error ("to_sfixed -24 round_test", check3sf1, check3sf2);
    checkint  := -27;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1001";
    report_error ("to_sfixed -27 not round_test", check3sf1, check3sf2);
    checkint  := -27;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1001";
    report_error ("to_sfixed -27 round_test", check3sf1, check3sf2);
    checkint  := -31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31 not round_test", check3sf1, check3sf2);
    checkint  := -31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31 round_test", check3sf1, check3sf2);
    checkint  := -31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31 wrap not round_test", check3sf1, check3sf2);
    checkint  := -31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31 wrap round_test", check3sf1, check3sf2);
    if (not quiet) then
      checkint := -35;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "1000";              -- -32
      report_error ("to_sfixed -35 not round_test", check3sf1, check3sf2);
      checkint  := -35;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "1000";              -- -32
      report_error ("to_sfixed -35 round_test", check3sf1, check3sf2);
      checkint  := -35;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "0111";              -- 28
      report_error ("to_sfixed -35 wrap not round_test", check3sf1, check3sf2);
      checkint  := -35;
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkint,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "0111";              -- 28
      report_error ("to_sfixed -35 wrap round_test", check3sf1, check3sf2);
    end if;
    checkint := -31;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);
    check3sf2 := "1000";
    report_error ("to_sfixed -31 wrap round_test", check3sf1, check3sf2);
    checkint  := -32;
    check3sf1 := to_sfixed (arg            => checkint,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);
    check3sf2 := "1000";
    report_error ("to_sfixed -32 wrap round_test", check3sf1, check3sf2);
    -- real number signed fixed
    if (not quiet) then
      checkreal := -17.0;
      report "Expect to_sfixed(real) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check7sf2                  := (others => '0');
      check7sf2 (check7sf2'high) := '1';
      report_error ("to_sfixed -17.0 failed to saturate", check7sf1, check7sf2);
      checkreal                  := -17.0;
      report "Expect to_sfixed(real) -overflow error" severity note;
      check7sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check7sf1'high,
                              right_index    => check7sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- wrap
      check7sf2 := "01111000";          --15
      report_error ("to_sfixed -17.0 failed to wrap", check7sf1, check7sf2);
    end if;
    checkreal := -5.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1110";                -- -8
    report_error ("to_sfixed -5.0 not round_test", check3sf1, check3sf2);
    checkreal := -5.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1111";                -- -4
    report_error ("to_sfixed -5.0 round_test", check3sf1, check3sf2);
    checkreal := -7.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1110";                -- -8
    report_error ("to_sfixed -7.0 not round_test", check3sf1, check3sf2);
    checkreal := -7.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1110";
    report_error ("to_sfixed -7.0 round_test", check3sf1, check3sf2);
    checkreal := -17.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1011";                -- -20
    report_error ("to_sfixed -17.0 not round_test", check3sf1, check3sf2);
    checkreal := -17.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1100";                -- -16
    report_error ("to_sfixed -17.0 round_test", check3sf1, check3sf2);
    checkreal := -19.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1011";                -- -20
    report_error ("to_sfixed -19.0 not round_test", check3sf1, check3sf2);
    checkreal := -19.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1011";
    report_error ("to_sfixed -19.0 round_test", check3sf1, check3sf2);
    checkreal := -24.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1010";
    report_error ("to_sfixed -24.0 not round_test", check3sf1, check3sf2);
    checkreal := -24.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1010";
    report_error ("to_sfixed -24.0 round_test", check3sf1, check3sf2);
    checkreal := -27.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1001";
    report_error ("to_sfixed -27.0 not round_test", check3sf1, check3sf2);
    checkreal := -27.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1001";
    report_error ("to_sfixed -27.0 round_test", check3sf1, check3sf2);
    checkreal := -31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31.0 not round_test", check3sf1, check3sf2);
    checkreal := -31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_saturate);    -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31.0 round_test", check3sf1, check3sf2);
    checkreal := -31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_truncate,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31.0 wrap not round_test", check3sf1, check3sf2);
    checkreal := -31.0;
    check3sf1 := to_sfixed (arg            => checkreal,
                            left_index     => check3sf1'high,
                            right_index    => check3sf1'low,
                            round_style    => fixed_round,
                            overflow_style => fixed_wrap);        -- saturate
    check3sf2 := "1000";                -- -32
    report_error ("to_sfixed -31.0 wrap round_test", check3sf1, check3sf2);
    if (not quiet) then
      checkreal := -35.0;
      report "Expect to_sfixed(real) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "1000";              -- -32
      report_error ("to_sfixed -35.0 not round_test", check3sf1, check3sf2);
      checkreal := -35.0;
      report "Expect to_sfixed(real) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_saturate);  -- saturate
      check3sf2 := "1000";              -- -32
      report_error ("to_sfixed -35.0 round_test", check3sf1, check3sf2);
      checkreal := -35.0;
      report "Expect to_sfixed(real) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "0111";              -- 28
      report_error ("to_sfixed -35.0 wrap not round_test", check3sf1, check3sf2);
      checkreal := -35.0;
      report "Expect to_sfixed(real) -overflow error" severity note;
      check3sf1 := to_sfixed (arg            => checkreal,
                              left_index     => check3sf1'high,
                              right_index    => check3sf1'low,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);      -- saturate
      check3sf2 := "0111";              -- 28
      report_error ("to_sfixed -35.0 wrap round_test", check3sf1, check3sf2);
    end if;
    check10sf := "1111111111";
    check9sf  := resize (check10sf, check9sf'high, check9sf'low);
    check9sf2 := "111111111";
    report_error ("Almost 0 resize", check9sf, check9sf2);
    -- -signed to sfixed

--    report to_string(check3sf1) & " = " & real'image(to_real(check3sf1)) severity note;

--    check9sf := "100000000";  -- -8
--    check9sf2 := "000100000";
--    for i  in 1 to 20 loop
--    report to_string(check9sf) & " = " & real'image(to_real(check9sf)) severity note;
--      check9sf := resize (check9sf + check9sf2, check9sf'high, check9sf'low);
--    end loop;  -- i 

    assert (quiet) report "Saturation test complete" severity note;
    ssaturatetest_done <= true;
    wait;
  end process ssaturatetest;

  -- purpose: check the overloaded functions
  overloadtest : process is
    -- purpose: Converts an sfixed to a ufixed
    function to_ufixed (
      arg : sfixed)
      return ufixed is
      variable argabs : sfixed (arg'high + 1 downto arg'low);
      variable result : ufixed (arg'range);
    begin
      argabs := abs (arg);
      result := ufixed (argabs (arg'range));
      return result;
    end function to_ufixed;
    variable check7uf1, check7uf2 : ufixed7_3;
    variable check7uf             : ufixed (4 downto -3);  -- ufixed7_3+ufixed7_3
    variable check7sf1, check7sf2 : sfixed7_3;
    variable check7sf             : sfixed (4 downto -3);  -- sfixed7_3+sfixed7_3
    variable check7sfx            : sfixed (5 downto -3);  -- ufixed7_3+sfixed7_3
    variable checkint             : INTEGER;
    variable checkreal            : REAL;
    variable mulres               : ufixed (7 downto -6);  -- ufixed7_3*ufixed7_3
    variable divres               : ufixed (6 downto -7);  -- ufixed7_3/ufixed7_3
    variable smulres              : sfixed (7 downto -6);  -- sfixed7_3*sfixed7_3
    variable smulresx             : sfixed (8 downto -6);  -- sfixed7_3 * ufixed7_3
    variable sdivres              : sfixed (7 downto -6);  -- sfixed7_3/sfixed7_3
    variable sdivresi2            : sfixed (7 downto -3);  -- int / sfixed7_3
    variable sdivresx             : sfixed (7 downto -7);  -- sfixed7_3/ufixed7_3
    variable sdivresx2            : sfixed (8 downto -6);  -- ufixed7_3/sfixed7_3
    variable smodresx             : sfixed(4 downto -3);  -- sfixed7_3 rem ufixed7_3
    variable bigs                 : sfixed (9 downto -9);  -- Big sfixed
    variable uf1                  : ufixed (0 downto 0);  -- one BIT
    variable uf2                  : ufixed (1 downto 0);  -- two bits
    variable uf3                  : ufixed (-1 downto -1);  -- one negative bit
    variable sf1                  : sfixed (0 downto 0);  -- one BIT
    variable sf2                  : sfixed (1 downto 0);  -- two bits
    variable sf3                  : sfixed (-1 downto -1);  -- one BIT
  begin
    wait until start_overloadtest;
    -- + and -
    check7uf1 := "0000100";             -- 0.5
    checkint  := 2;
    check7uf  := check7uf1 + checkint;
    report_error ("uf+int", check7uf,
                  to_ufixed (0.5+2.0, check7uf'high, check7uf'low));
    check7uf := checkint + check7uf1;
    report_error ("int+uf", check7uf,
                  to_ufixed (0.5+2.0, check7uf'high, check7uf'low));
    check7uf1 := "0011100";             -- 3.5
    checkint  := 2;
    check7uf  := check7uf1 - checkint;
    report_error ("uf-int", check7uf,
                  to_ufixed (3.5-2.0, check7uf'high, check7uf'low));
    checkint := 4;
    check7uf := checkint - check7uf1;
    report_error ("int-uf", check7uf,
                  to_ufixed (4.0-3.5, check7uf'high, check7uf'low));
    check7uf1 := "0001100";             -- 1.5
    uf1       := "0";                   -- 0
    check7uf  := check7uf1 + uf1;
    report_error (to_string(check7uf1) & " + " & to_string(uf1),
                  check7uf, check7uf1);
    check7uf1 := "0010100";             -- 2.5
    uf1       := "1";                   -- 1
    check7uf  := check7uf1 + uf1;
    report_error (to_string(check7uf1) & " + " & to_string(uf1),
                  check7uf, to_ufixed(3.5, check7uf));
    uf1      := "0";                    -- 0
    uf3      := "0";                    -- 0
    check7uf := resize (uf3 + uf1, check7uf);
    report_error (to_string(uf3) & " + " & to_string(uf1),
                  check7uf, to_ufixed(0, check7uf));
    uf1      := "0";                    -- 0
    uf3      := "1";                    -- 0
    check7uf := resize (uf1 + uf3, check7uf);
    report_error (to_string(uf1) & " + " & to_string(uf3),
                  check7uf, to_ufixed(0.5, check7uf));
    check7uf1 := "0010100";             -- 2.5
    uf3       := "1";                   -- 0.5
    check7uf  := check7uf1 + uf3;
    report_error (to_string(check7uf1) & " + " & to_string(uf3),
                  check7uf, to_ufixed(3, check7uf));
    check7uf1 := "0010110";             -- 2.75
    uf2       := "11";                  -- 3
    check7uf  := check7uf1 + uf2;
    report_error (to_string(check7uf1) & " + " & to_string(uf2),
                  check7uf, to_ufixed(5.75, check7uf));
    check7uf1 := "0010100";             -- 2.5
    uf3       := "1";                   -- 0.5
    check7uf  := check7uf1 - uf3;
    report_error (to_string(check7uf1) & " - " & to_string(uf3),
                  check7uf, to_ufixed(2, check7uf));
    check7uf1 := "0010100";             -- 2.5
    uf1       := "1";                   -- 1
    check7uf  := check7uf1 - uf1;
    report_error (to_string(check7uf1) & " - " & to_string(uf1),
                  check7uf, to_ufixed(1.5, check7uf));
    check7uf1 := "0000100";             -- 0.5
    uf1       := "1";                   -- 1
    check7uf  := check7uf1 - uf1;       -- underflow
    report_error (to_string(check7uf1) & " - " & to_string(uf1),
                  check7uf, to_ufixed(31.5, check7uf));
    -- real number
    check7uf1 := "0000100";             -- 0.5
    checkreal := 2.0;
    check7uf  := check7uf1 + checkreal;
    report_error ("uf+real", check7uf,
                  to_ufixed (0.5+2.0, check7uf'high, check7uf'low));
    check7uf := checkreal + check7uf1;
    report_error ("real+uf", check7uf,
                  to_ufixed (0.5+2.0, check7uf'high, check7uf'low));
    check7uf1 := "0011100";             -- 3.5
    checkreal := 2.0;
    check7uf  := check7uf1 - checkreal;
    report_error ("uf-real", check7uf,
                  to_ufixed (3.5-2.0, check7uf'high, check7uf'low));
    checkreal := 4.0;
    check7uf  := checkreal - check7uf1;
    report_error ("real+uf", check7uf,
                  to_ufixed (4.0-3.5, check7uf'high, check7uf'low));
    -- multiply
    check7uf1 := "0000100";             -- 0.5
    checkreal := 2.0;
    mulres    := check7uf1 * checkreal;
    report_error ("uf*real", mulres,
                  to_ufixed (2.0*0.5, mulres'high, mulres'low));
    mulres := checkreal * check7uf1;
    report_error ("real*uf", mulres,
                  to_ufixed (2.0*0.5, mulres'high, mulres'low));
    check7uf1 := "0000100";             -- 0.5
    checkint  := 2;
    mulres    := resize (check7uf1 * checkint, mulres'high, mulres'low);
    report_error ("uf*int", mulres,
                  to_ufixed (2.0*0.5, mulres'high, mulres'low));
    mulres := resize (checkint * check7uf1, mulres'high, mulres'low);
    report_error ("int*uf", mulres,
                  to_ufixed (2.0*0.5, mulres'high, mulres'low));
    -- divide
    check7uf1 := "0000100";             -- 0.5
    checkreal := 2.0;
    divres    := check7uf1 / checkreal;
    report_error ("uf/real", divres,
                  to_ufixed (0.5/2.0, divres'high, divres'low));
    divres := checkreal / check7uf1;
    report_error ("real/uf", divres,
                  to_ufixed (2.0/0.5, divres'high, divres'low));
    check7uf1 := "0000100";             -- 0.5
    checkint  := 2;
    divres    := resize (check7uf1 / checkint, divres'high, divres'low);
    report_error ("uf/real", divres,
                  to_ufixed (0.5/2.0, divres'high, divres'low));
    divres := resize (checkint / check7uf1, divres'high, divres'low);
    report_error ("real/uf", divres,
                  to_ufixed (2.0/0.5, divres'high, divres'low));
    -- rem and mod
    check7uf1 := "0010000";             -- 2.0
    checkreal := 5.0;
    check7uf1 := checkreal rem check7uf1;
    report_error ("REAL rem uf", check7uf1,
                  to_ufixed (5 rem 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0101000";             -- 5.0
    checkreal := 2.0;
    check7uf1 := check7uf1 rem checkreal;
    report_error ("REAL rem uf", check7uf1,
                  to_ufixed (5 rem 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0010000";             -- 2.0
    checkint  := 5;
    check7uf1 := checkint rem check7uf1;
    report_error ("int rem uf", check7uf1,
                  to_ufixed (5 rem 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0101000";             -- 5.0
    checkint  := 2;
    check7uf1 := check7uf1 rem checkint;
    report_error ("int rem uf", check7uf1,
                  to_ufixed (5 rem 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0010000";             -- 2.0
    checkreal := 5.0;
    check7uf1 := checkreal mod check7uf1;
    report_error ("REAL mod uf", check7uf1,
                  to_ufixed (5 mod 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0101000";             -- 5.0
    checkreal := 2.0;
    check7uf1 := check7uf1 mod checkreal;
    report_error ("REAL mod uf", check7uf1,
                  to_ufixed (5 mod 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0010000";             -- 2.0
    checkint  := 5;
    check7uf1 := checkint mod check7uf1;
    report_error ("int mod uf", check7uf1,
                  to_ufixed (5 mod 2, check7uf1'high, check7uf1'low));
    check7uf1 := "0101000";             -- 5.0
    checkint  := 2;
    check7uf1 := check7uf1 mod checkint;
    report_error ("int mod uf", check7uf1,
                  to_ufixed (5 mod 2, check7uf1'high, check7uf1'low));
    -- now with signed fixed point numbers
    -- + and -
    check7sf1 := "0000100";             -- 0.5
    checkint  := 2;
    check7sf  := check7sf1 + checkint;
    report_error ("sf+int", check7sf,
                  to_sfixed (0.5+2.0, check7sf'high, check7sf'low));
    check7sf := checkint + check7sf1;
    report_error ("int+sf", check7sf,
                  to_sfixed (0.5+2.0, check7sf'high, check7sf'low));
    check7sf1 := "0011100";             -- 3.5
    checkint  := 2;
    check7sf  := check7sf1 - checkint;
    report_error ("sf-int", check7sf,
                  to_sfixed (3.5-2.0, check7sf'high, check7sf'low));
    checkint := 4;
    check7sf := checkint - check7sf1;
    report_error ("int-sf", check7sf,
                  to_sfixed (4.0-3.5, check7sf'high, check7sf'low));
    check7sf1 := "0000100";             -- 0.5
    sf1       := "0";                   -- 0
    check7sf  := check7sf1 + sf1;
    report_error (to_string (check7sf1) & " + " & to_string (sf1),
                  check7sf, to_sfixed (0.5, check7sf));
    check7sf1 := "0000100";             -- 0.5
    sf1       := "1";                   -- -1
    check7sf  := check7sf1 + sf1;
    report_error (to_string (check7sf1) & " + " & to_string (sf1),
                  check7sf, to_sfixed (-0.5, check7sf));
    check7sf1 := "0001100";             -- 1.5
    sf1       := "1";                   -- -1
    check7sf  := check7sf1 * sf1;
    report_error (to_string (check7sf1) & " + " & to_string (sf1),
                  check7sf, to_sfixed (-1.5, check7sf));
    check7sf1 := "0010100";             -- 2.5
    sf2       := "01";                  -- 1
    check7sf  := check7sf1 + sf2;
    report_error (to_string (check7sf1) & " + " & to_string (sf2),
                  check7sf, to_sfixed (3.5, check7sf));
    check7sf1 := "0010100";             -- 2.5
    sf2       := "11";                  -- -1
    check7sf  := check7sf1 + sf2;
    report_error (to_string (check7sf1) & " + " & to_string (sf2),
                  check7sf, to_sfixed (1.5, check7sf));
    check7sf1 := "0010100";             -- 2.5
    sf2       := "10";                  -- -2
    check7sf  := check7sf1 + sf2;
    report_error (to_string (check7sf1) & " + " & to_string (sf2),
                  check7sf, to_sfixed (0.5, check7sf));
    check7sf1 := "0010100";             -- 2.5
    sf3       := "0";                   -- 0
    check7sf  := check7sf1 + sf3;
    report_error (to_string (check7sf1) & " + " & to_string (sf3),
                  check7sf, to_sfixed (2.5, check7sf));
    check7sf1 := "0010100";             -- 2.5
    sf3       := "1";                   -- -0.5
    check7sf  := check7sf1 + sf3;
    report_error (to_string (check7sf1) & " + " & to_string (sf3),
                  check7sf, to_sfixed (2, check7sf));
    -- real number
    check7sf1 := "0000100";             -- 0.5
    checkreal := 2.0;
    check7sf  := check7sf1 + checkreal;
    report_error ("sf+real", check7sf,
                  to_sfixed (0.5+2.0, check7sf'high, check7sf'low));
    check7sf := checkreal + check7sf1;
    report_error ("real+sf", check7sf,
                  to_sfixed (0.5+2.0, check7sf'high, check7sf'low));
    check7sf1 := "0011100";             -- 3.5
    checkreal := 2.0;
    check7sf  := check7sf1 - checkreal;
    report_error ("sf-real", check7sf,
                  to_sfixed (3.5-2.0, check7sf'high, check7sf'low));
    checkreal := 4.0;
    check7sf  := checkreal - check7sf1;
    report_error ("real+sf", check7sf,
                  to_sfixed (4.0-3.5, check7sf'high, check7sf'low));
    -- multiply
    check7sf1 := "0000100";             -- 0.5
    checkreal := 2.0;
    smulres   := check7sf1 * checkreal;
    report_error ("sf*real", smulres,
                  to_sfixed (2.0*0.5, smulres'high, smulres'low));
    smulres := checkreal * check7sf1;
    report_error ("real*sf", smulres,
                  to_sfixed (2.0*0.5, smulres'high, smulres'low));
    check7sf1 := "0000100";             -- 0.5
    checkint  := 2;
    smulres   := resize (check7sf1 * checkint, smulres'high, smulres'low);
    report_error ("sf*int", smulres,
                  to_sfixed (2.0*0.5, smulres'high, smulres'low));
    smulres := resize (checkint * check7sf1, smulres'high, smulres'low);
    report_error ("int*sf", smulres,
                  to_sfixed (2.0*0.5, smulres'high, smulres'low));
    -- divide
    check7sf1 := "0000100";             -- 0.5
    checkreal := 2.0;
    sdivres   := check7sf1 / checkreal;
    report_error ("sf/real", sdivres,
                  to_sfixed (0.5/2.0, sdivres'high, sdivres'low));
    sdivres := checkreal / check7sf1;
    report_error ("real/sf", sdivres,
                  to_sfixed (2.0/0.5, sdivres'high, sdivres'low));
    check7sf1 := "0000100";             -- 0.5
    checkint  := 2;
    sdivres   := resize (check7sf1 / checkint, sdivres'high, sdivres'low);
    report_error ("sf/real", sdivres,
                  to_sfixed (0.5/2.0, sdivres'high, sdivres'low));
    sdivres := resize (checkint / check7sf1, sdivres'high, sdivres'low);
    report_error ("real/sf", sdivres,
                  to_sfixed (2.0/0.5, sdivres'high, sdivres'low));
    -- rem and mod
    check7sf1 := "0010000";             -- 2.0
    checkreal := 5.0;
    check7sf1 := checkreal rem check7sf1;
    report_error ("REAL rem sf", check7sf1,
                  to_sfixed (5 rem 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0101000";             -- 5.0
    checkreal := 2.0;
    check7sf1 := check7sf1 rem checkreal;
    report_error ("REAL rem sf", check7sf1,
                  to_sfixed (5 rem 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0010000";             -- 2.0
    checkint  := 5;
    check7sf1 := checkint rem check7sf1;
    report_error ("int rem sf", check7sf1,
                  to_sfixed (5 rem 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0101000";             -- 5.0
    checkint  := 2;
    check7sf1 := resize (check7sf1 rem checkint, check7sf1'high, check7sf1'low);
    report_error ("int rem sf", check7sf1,
                  to_sfixed (5 rem 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0010000";             -- 2.0
    checkreal := 5.0;
    check7sf1 := checkreal mod check7sf1;
    report_error ("REAL mod sf", check7sf1,
                  to_sfixed (5 mod 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0101000";             -- 5.0
    checkreal := 2.0;
    check7sf1 := check7sf1 mod checkreal;
    report_error ("REAL mod sf", check7sf1,
                  to_sfixed (5 mod 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0010000";             -- 2.0
    checkint  := 5;
    check7sf1 := checkint mod check7sf1;
    report_error ("int mod sf", check7sf1,
                  to_sfixed (5 mod 2, check7sf1'high, check7sf1'low));
    check7sf1 := "0101000";             -- 5.0
    checkint  := 2;
    check7sf1 := check7sf1 mod checkint;
    report_error ("int mod sf", check7sf1,
                  to_sfixed (5 mod 2, check7sf1'high, check7sf1'low));

    -- Operations that mix ufixed and sfixed
    check7uf1 := "1111000";                        -- 15.0
    check7sf1 := "0111000";                        -- +7.0
    check7sfx := to_sfixed(check7uf1) + check7sf1;  -- size check
    bigs      := resize (check7sfx, bigs'high, bigs'low);
    report_error ("ufixed + sfixed", bigs,
                  to_sfixed (22, bigs'high, bigs'low));
    check7sfx := check7sf1 + to_sfixed(check7uf1);
    bigs      := resize (check7sfx, bigs'high, bigs'low);
    report_error ("sfixed + ufixed", bigs,
                  to_sfixed (22, bigs'high, bigs'low));
    -- Subtract
    check7uf1 := "1111000";                        -- 15.0
    check7sf1 := "1000000";                        -- -8.0
    check7sfx := to_sfixed(check7uf1) - check7sf1;  -- size check
    bigs      := resize (check7sfx, bigs'high, bigs'low);
    report_error ("ufixed - sfixed", bigs,
                  to_sfixed (23, bigs'high, bigs'low));
    check7sfx := check7sf1 - to_sfixed(check7uf1);  -- size check
    bigs      := resize (check7sfx, bigs'high, bigs'low);
    report_error ("ufixed - sfixed", bigs,
                  to_sfixed (-23, bigs'high, bigs'low));
    check7uf1 := "1111111";                        -- 15.875
    check7uf2 := "0000000";                        -- 0.0
    check7sfx := to_sfixed(check7uf2) - to_sfixed(check7uf1);
    bigs      := resize (check7sfx, bigs'high, bigs'low);
    report_error ("ufixed - ufixed return sfixed", bigs,
                  to_sfixed (-15.875, bigs'high, bigs'low));
    -- Multiply
    check7uf1 := "1111111";                        -- 15.875
    check7sf1 := "1000000";                        -- -8.0
    smulresx  := to_sfixed(check7uf1) * check7sf1;
    bigs      := resize (smulresx, bigs'high, bigs'low);
    report_error ("ufixed * sfixed", bigs,
                  to_sfixed (-127, bigs'high, bigs'low));
    smulresx := check7sf1 * to_sfixed(check7uf1);
    bigs     := resize (smulresx, bigs'high, bigs'low);
    report_error ("sfixed * ufixed", bigs,
                  to_sfixed (-127, bigs'high, bigs'low));
    check7uf1 := "1111111";                        -- 15.875
    check7sf1 := "0111111";                        --  7.875
    smulresx  := to_sfixed(check7uf1) * check7sf1;
    bigs      := resize (smulresx, bigs'high, bigs'low);
    report_error ("ufixed * sfixed pos", bigs,
                  to_sfixed ((15.875 * 7.875), bigs'high, bigs'low));
    smulresx := check7sf1 * to_sfixed(check7uf1);
    bigs     := resize (smulresx, bigs'high, bigs'low);
    report_error ("sfixed * ufixed pos", bigs,
                  to_sfixed ((15.875 * 7.875), bigs'high, bigs'low));
    -- divide
    check7uf1 := "0000001";                        -- 0.125
    check7sf1 := "0111111";                        -- 7.875
    sdivresx  := check7sf1 / to_sfixed(check7uf1);
    bigs      := resize (sdivresx, bigs'high, bigs'low);
    report_error ("sfixed / ufixed overflow", bigs,
                  to_sfixed ((7.875/0.125), bigs'high, bigs'low));
    check7uf1 := "0000001";                        -- 0.125
    check7sf1 := "1000000";                        -- -8
    sdivresx  := check7sf1 / to_sfixed(check7uf1);
    bigs      := resize (sdivresx, bigs'high, bigs'low);
    report_error ("sfixed / ufixed -overflow", bigs,
                  to_sfixed (((-8.0)/0.125), bigs'high, bigs'low));
    -- underflow
    check7uf1 := "1111111";                        -- 15.875
    check7sf1 := "0000001";                        -- 0.125
    sdivresx  := check7sf1 / to_sfixed(check7uf1);
    bigs      := resize (sdivresx, bigs'high, bigs'low);
    report_error ("sfixed / ufixed underflow", bigs,
                  to_sfixed ((0.125/15.875), bigs'high, bigs'low));
    -- -underflow
    bigs     := to_sfixed (((-0.125)/15.875), bigs'high, bigs'low);
    sdivresx := resize (bigs, sdivresx'high, sdivresx'low);
    assert (-0.0078125 = to_real(bigs))
      report "-underflow conversion error to_real(" & to_string(sdivresx)
      & ") = " & REAL'image(to_real(bigs)) & " not -0.0078125"
      severity error;
    check7sf  := "01111111";                       -- 15.875
    check7sf1 := "1111111";                        -- -0.125
    sdivresx  := check7sf1 / check7sf;
    bigs      := resize (sdivresx, bigs'high, bigs'low);
    report_error ("sfixed / sfixed -underflow", bigs,
                  to_sfixed (((-0.125)/15.875), bigs'high, bigs'low));
    check7uf1 := "1111111";                        -- 15.875
--    report to_string(check7uf1) & " = " & REAL'image(to_real(check7uf1))
--      severity note;
    check7sf1 := "1111111";                        -- -0.125
--    report to_string(check7sf1) & " = " & REAL'image(to_real(check7sf1))
--      severity note;
    sdivresx  := check7sf1 / to_sfixed(check7uf1);
    bigs      := resize (sdivresx, bigs'high, bigs'low);
    report_error ("sfixed / ufixed -underflow", bigs,
                  to_sfixed (((-0.125)/15.875), bigs'high, bigs'low));

    check7uf1 := "1111111";             -- 15.875
    check7sf1 := "0000001";             -- 0.125
    sdivresx2 := to_sfixed(check7uf1) / check7sf1;
    bigs      := resize (sdivresx2, bigs'high, bigs'low);
    report_error ("ufixed / sfixed overflow", bigs,
                  to_sfixed ((15.875/0.125), bigs'high, bigs'low));
    check7uf1 := "1111111";             -- 15.875
    check7sf1 := "1111111";             -- -0.125
    sdivresx2 := to_sfixed(check7uf1) / check7sf1;
    bigs      := resize (sdivresx2, bigs'high, bigs'low);
    report_error ("ufixed / sfixed -overflow", bigs,
                  to_sfixed ((15.875/(-0.125)), bigs'high, bigs'low));
    -- underflow
    check7uf1 := "0000001";             -- 0.125
    check7sf1 := "0111111";             -- 7.825
    sdivresx2 := to_sfixed(check7uf1) / check7sf1;
    bigs      := resize (sdivresx2, bigs'high, bigs'low);
    report_error ("ufixed / sfixed underflow", bigs,
                  to_sfixed ((0.125/7.825), bigs'high, bigs'low));
    sdivresx2 := divide (to_sfixed(check7uf1), check7sf1);
    report_error ("divide (ufixed, sfixed) underflow", sdivresx2,
                  to_sfixed ((0.125/7.825), bigs'high, bigs'low));
    check7uf1 := "0000001";             -- 0.125
    check7sf1 := "1000000";             -- -8
    sdivresx2 := to_sfixed(check7uf1) / check7sf1;
    bigs      := resize (sdivresx2, bigs'high, bigs'low);
    report_error ("ufixed / sfixed -underflow", bigs,
                  to_sfixed ((0.125/(-8.0)), bigs'high, bigs'low));
    sdivresx2 := divide (to_sfixed(check7uf1), check7sf1);
    report_error ("divide (ufixed, sfixed) -underflow", sdivresx2,
                  to_sfixed ((0.125/(-8.0)), bigs'high, bigs'low));
    -- remainder
    check7uf1 := "1111000";             -- 15
    check7sf1 := "0111000";             -- 7
    check7sf2 := to_sfixed(check7uf1) rem check7sf1;
    bigs      := resize (check7sf2, bigs'high, bigs'low);
    report_error ("ufixed rem sfixed", bigs,
                  to_sfixed ((15 rem 7), bigs'high, bigs'low));
    check7uf1 := "1111000";             -- 15
    check7sf1 := "1000000";             -- -8
    check7sf2 := to_sfixed(check7uf1) rem check7sf1;
    bigs      := resize (check7sf2, bigs'high, bigs'low);
    report_error ("ufixed rem -sfixed", bigs,
                  to_sfixed ((15 rem (-8)), bigs'high, bigs'low));    
    check7uf1 := "1111000";             -- 15
    check7sf1 := "0111000";             -- 7
    check7sf2 := check7sf1 rem to_sfixed(check7uf1);
    bigs      := resize (check7sf2, bigs'high, bigs'low);
    report_error ("sfixed rem ufixed", bigs,
                  to_sfixed ((7 rem 15), bigs'high, bigs'low));
    check7uf1 := "1111000";             -- 15
    check7sf1 := "1000000";             -- -8
    check7sf2 := check7sf1 rem to_sfixed(check7uf1);
    bigs      := resize (check7sf2, bigs'high, bigs'low);
    report_error ("-sfixed rem ufixed", bigs,
                  to_sfixed (((-8) rem 15), bigs'high, bigs'low));
    -- mod
    check7uf1 := "1111111";             -- 15.875
    check7sf1 := "0111111";             -- 7.875
    check7sf2 := to_sfixed(check7uf1) mod check7sf1;
    bigs      := resize (check7sf2, bigs'high, bigs'low);
    report_error ("ufixed mod sfixed", bigs,
                  to_sfixed ((15.875 mod 7.875), bigs'high, bigs'low));
    check7uf1 := "1111111";             -- 15.875
    check7sf1 := "1000000";             -- -8
    check7sf2 := to_sfixed(check7uf1) mod check7sf1;
    bigs      := resize (check7sf2, bigs'high, bigs'low);
    report_error ("ufixed mod -sfixed", bigs,
                  to_sfixed ((15.875 mod (-8.0)), bigs'high, bigs'low));    
    check7uf1 := "1111111";             -- 15.875
    check7sf1 := "0111111";             -- 7.875
    smodresx  := check7sf1 mod to_sfixed(check7uf1);
    bigs      := resize (smodresx, bigs'high, bigs'low);
    report_error ("sfixed rem ufixed", bigs,
                  to_sfixed ((7.875 mod 15.875), bigs'high, bigs'low));
    check7uf1 := "1111111";             -- 15.875
    check7sf1 := "1000000";             -- -8
    smodresx  := check7sf1 mod to_sfixed(check7uf1);
    bigs      := resize (smodresx, bigs'high, bigs'low);
    report_error ("-sfixed mod ufixed", bigs,
                  to_sfixed (((-8.0) mod 15.875), bigs'high, bigs'low));
    -- check the "ufixed_high" and "ufixed_low" functions
    checkint := ufixed_high (3, -3, '+', 3, -3);
    assert (checkint = 4)
      report "ufixed_high (3,-3, +, 3,-3) returned "
      & INTEGER'image(checkint) & " not 4"
      severity error;
    checkint := ufixed_high (check7uf1, '+', check7uf2);
    assert (checkint = check7uf'high)
      report "ufixed_high (check7uf1, +, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7uf'high)
      severity error;
    checkint := ufixed_low (3, -3, '+', 3, -3);
    assert (checkint = -3)
      report "ufixed_low (3,-3, +, 3,-3) returned "
      & INTEGER'image(checkint) & " not -3"
      severity error;
    checkint := ufixed_low (check7uf1, '+', check7uf2);
    assert (checkint = check7uf'low)
      report "ufixed_low (check7uf1, +, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7uf'low)
      severity error;
    checkint := ufixed_high (3, -3, '-', 3, -3);
    assert (checkint = 4)
      report "ufixed_high (3,-3, -, 3,-3) returned "
      & INTEGER'image(checkint) & " not 4"
      severity error;
    checkint := ufixed_high (check7uf1, '-', check7uf2);
    assert (checkint = check7uf'high)
      report "ufixed_high (check7uf1, -, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7uf'high)
      severity error;
    checkint := ufixed_low (3, -3, '-', 3, -3);
    assert (checkint = -3)
      report "ufixed_low (3,-3, -, 3,-3) returned "
      & INTEGER'image(checkint) & " not -3"
      severity error;
    checkint := ufixed_low (check7uf1, '-', check7uf2);
    assert (checkint = check7uf'low)
      report "ufixed_low (check7uf1, -, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7uf'low)
      severity error;

    checkint := ufixed_high (3, -3, '*', 3, -3);
    assert (checkint = 7)
      report "ufixed_high (3,-3, *, 3,-3) returned "
      & INTEGER'image(checkint) & " not 7"
      severity error;
    checkint := ufixed_high (check7uf1, '*', check7uf2);
    assert (checkint = mulres'high)
      report "ufixed_high (check7uf1, *, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(mulres'high)
      severity error;
    checkint := ufixed_low (3, -3, '*', 3, -3);
    assert (checkint = -6)
      report "ufixed_low (3,-3, *, 3,-3) returned "
      & INTEGER'image(checkint) & " not -6"
      severity error;
    checkint := ufixed_low (check7uf1, '*', check7uf2);
    assert (checkint = mulres'low)
      report "ufixed_low (check7uf1, *, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(mulres'low)
      severity error;

    checkint := ufixed_high (3, -3, '/', 3, -3);
    assert (checkint = 6)
      report "ufixed_high (3,-3, /, 3,-3) returned "
      & INTEGER'image(checkint) & " not 6"
      severity error;
    checkint := ufixed_high (check7uf1, '/', check7uf2);
    assert (checkint = divres'high)
      report "ufixed_high (check7uf1, /, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(divres'high)
      severity error;
    checkint := ufixed_low (3, -3, '/', 3, -3);
    assert (checkint = -7)
      report "ufixed_low (3,-3, /, 3,-3) returned "
      & INTEGER'image(checkint) & " not -7"
      severity error;
    checkint := ufixed_low (check7uf1, '/', check7uf2);
    assert (checkint = divres'low)
      report "ufixed_low (check7uf1, /, check7uf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(divres'low)
      severity error;
    checkint := ufixed_high(mulres, '*', divres);
    assert (checkint = mulres'high + divres'high+1)
      report "ufixed_high (mulres, *, divres) returned "
      & INTEGER'image(checkint) & " not 15"
      severity error;
    checkint := ufixed_high(mulres, '/', mulres);
    assert (checkint = mulres'high - mulres'low)
      report "ufixed_high (mulres, /, mulres) returned "
      & INTEGER'image(checkint) & " not 13"
      severity error;
    checkint := ufixed_high (2, -3, '1', 4, -5);
    assert (checkint = 3) report "ufixed_high (2, -3, '1', 4, -5) returned "
      & INTEGER'image(checkint) & " not 3"
      severity error;
    checkint := ufixed_low (2, -3, '1', 4, -5);
    assert (checkint = -3) report "ufixed_high (2, -3, '1', 4, -5) returned "
      & INTEGER'image(checkint) & " not -3"
      severity error;
    checkint := ufixed_high (mulres, '1', divres);
    assert (checkint = -mulres'low) report "ufixed_high (mulres, '1', divres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(-mulres'low)
      severity error;
    checkint := ufixed_low (divres, '1', mulres);
    assert (checkint = -divres'high-1) report "ufixed_low (divres, '1', mulres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(-divres'high-1)
      severity error;
    checkint := ufixed_high (2, -3, 'M', 4, -5);
    assert (checkint = 2) report "ufixed_high (2, -3, 'M', 4, -5) returned "
      & INTEGER'image(checkint) & " not 2"
      severity error;
    checkint := ufixed_low (2, -3, 'M', 4, -5);
    assert (checkint = -5) report "ufixed_high (2, -3, 'M', 4, -5) returned "
      & INTEGER'image(checkint) & " not -5"
      severity error;
    checkint := ufixed_high (mulres, 'm', divres);
    assert (checkint = divres'high) report "ufixed_high (mulres, 'm', divres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(divres'high)
      severity error;
    checkint := ufixed_low (divres, 'm', mulres);
    assert (checkint = divres'low) report "ufixed_low (divres, 'm', mulres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(divres'low)
      severity error;
    checkint := ufixed_high (2, -3, 'R', 4, -5);
    assert (checkint = 2) report "ufixed_high (2, -3, 'R', 4, -5) returned "
      & INTEGER'image(checkint) & " not 2"
      severity error;
    checkint := ufixed_low (2, -3, 'R', 4, -5);
    assert (checkint = -5) report "ufixed_high (2, -3, 'R', 4, -5) returned "
      & INTEGER'image(checkint) & " not -5"
      severity error;
    checkint := ufixed_high (mulres, 'r', divres);
    assert (checkint = divres'high) report "ufixed_high (mulres, 'm', divres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(divres'high)
      severity error;
    checkint := ufixed_low (divres, 'r', mulres);
    assert (checkint = divres'low) report "ufixed_low (divres, 'm', mulres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(divres'low)
      severity error;

    -- check the "sfixed_high" and "sfixed_low" functions
    checkint := sfixed_high (3, -3, '+', 3, -3);
    assert (checkint = 4)
      report "sfixed_high (3,-3, +, 3,-3) returned "
      & INTEGER'image(checkint) & " not 4"
      severity error;
    checkint := sfixed_high (check7sf1, '+', check7sf2);
    assert (checkint = check7sf'high)
      report "sfixed_high (check7sf1, +, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7sf'high)
      severity error;
    checkint := sfixed_low (3, -3, '+', 3, -3);
    assert (checkint = -3)
      report "sfixed_low (3,-3, +, 3,-3) returned "
      & INTEGER'image(checkint) & " not -3"
      severity error;
    checkint := sfixed_low (check7sf1, '+', check7sf2);
    assert (checkint = check7sf'low)
      report "sfixed_low (check7sf1, +, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7sf'low)
      severity error;
    checkint := sfixed_high (3, -3, '-', 3, -3);
    assert (checkint = 4)
      report "sfixed_high (3,-3, -, 3,-3) returned "
      & INTEGER'image(checkint) & " not 4"
      severity error;
    checkint := sfixed_high (check7sf1, '-', check7sf2);
    assert (checkint = check7sf'high)
      report "sfixed_high (check7sf1, -, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7sf'high)
      severity error;
    checkint := sfixed_low (3, -3, '-', 3, -3);
    assert (checkint = -3)
      report "sfixed_low (3,-3, -, 3,-3) returned "
      & INTEGER'image(checkint) & " not -3"
      severity error;
    checkint := sfixed_low (check7sf1, '-', check7sf2);
    assert (checkint = check7sf'low)
      report "sfixed_low (check7sf1, -, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(check7sf'low)
      severity error;

    checkint := sfixed_high (3, -3, '*', 3, -3);
    assert (checkint = 7)
      report "sfixed_high (3,-3, *, 3,-3) returned "
      & INTEGER'image(checkint) & " not 7"
      severity error;
    checkint := sfixed_high (check7sf1, '*', check7sf2);
    assert (checkint = smulres'high)
      report "sfixed_high (check7sf1, *, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(smulres'high)
      severity error;
    checkint := sfixed_low (3, -3, '*', 3, -3);
    assert (checkint = -6)
      report "sfixed_low (3,-3, *, 3,-3) returned "
      & INTEGER'image(checkint) & " not -6"
      severity error;
    checkint := sfixed_low (check7sf1, '*', check7sf2);
    assert (checkint = smulres'low)
      report "sfixed_low (check7sf1, *, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(smulres'low)
      severity error;

    checkint := sfixed_high (3, -3, '/', 3, -3);
    assert (checkint = 7)
      report "sfixed_high (3,-3, /, 3,-3) returned "
      & INTEGER'image(checkint) & " not 7"
      severity error;
    checkint := sfixed_high (check7sf1, '/', check7sf2);
    assert (checkint = sdivres'high)
      report "sfixed_high (check7sf1, /, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(sdivres'high)
      severity error;
    checkint := sfixed_low (3, -3, '/', 3, -3);
    assert (checkint = -6)
      report "sfixed_low (3,-3, /, 3,-3) returned "
      & INTEGER'image(checkint) & " not -6"
      severity error;
    checkint := sfixed_low (check7sf1, '/', check7sf2);
    assert (checkint = sdivres'low)
      report "sfixed_low (check7sf1, /, check7sf2) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(sdivres'low)
      severity error;
    checkint := sfixed_high(smulres, '*', sdivres);
    assert (checkint = 15)
      report "sfixed_high (smulres, *, sdivres) returned "
      & INTEGER'image(checkint) & " not 15"
      severity error;
    checkint := sfixed_high(smulres, '/', smulresx);
    assert (checkint = 14)
      report "sfixed_high (smulres, /, smulres) returned "
      & INTEGER'image(checkint) & " not 14"
      severity error;
    checkint := sfixed_high (2, -3, '1', 4, -5);
    assert (checkint = 4) report "sfixed_high (2, -3, '1', 4, -5) returned "
      & INTEGER'image(checkint) & " not 4"
      severity error;
    checkint := sfixed_low (2, -3, '1', 4, -5);
    assert (checkint = -2) report "sfixed_high (2, -3, '1', 4, -5) returned "
      & INTEGER'image(checkint) & " not -2"
      severity error;
    checkint := sfixed_high (smulres, '1', sdivres);
    assert (checkint = -smulres'low+1) report "sfixed_high (smulres, '1', sdivres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(-smulres'low+1)
      severity error;
    checkint := sfixed_low (sdivres, '1', smulres);
    assert (checkint = -sdivres'high) report "sfixed_high (sdivres, '1', smulres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(-sdivres'high)
      severity error;
    checkint := sfixed_high (2, -3, 'M', 4, -5);
    assert (checkint = 4) report "sfixed_high (2, -3, 'M', 4, -5) returned "
      & INTEGER'image(checkint) & " not 4"
      severity error;
    checkint := sfixed_low (2, -3, 'M', 4, -5);
    assert (checkint = -5) report "sfixed_high (2, -3, 'M', 4, -5) returned "
      & INTEGER'image(checkint) & " not -5"
      severity error;
    checkint := sfixed_high (smulres, 'm', sdivres);
    assert (checkint = sdivres'high) report "sfixed_high (smulres, 'm', sdivres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(sdivres'high)
      severity error;
    checkint := sfixed_low (sdivres, 'm', smulres);
    assert (checkint = sdivres'low) report "sfixed_low (sdivres, 'm', smulres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(sdivres'low)
      severity error;
    checkint := sfixed_high (2, -3, 'R', 4, -5);
    assert (checkint = 2) report "sfixed_high (2, -3, 'R', 4, -5) returned "
      & INTEGER'image(checkint) & " not 2"
      severity error;
    checkint := sfixed_low (2, -3, 'R', 4, -5);
    assert (checkint = -5) report "sfixed_high (2, -3, 'R', 4, -5) returned "
      & INTEGER'image(checkint) & " not -5"
      severity error;
    checkint := sfixed_high (smulres, 'r', sdivres);
    assert (checkint = sdivres'high) report "sfixed_high (smulres, 'm', sdivres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(sdivres'high)
      severity error;
    checkint := sfixed_low (sdivres, 'r', smulres);
    assert (checkint = sdivres'low) report "sfixed_low (sdivres, 'm', smulres) returned "
      & INTEGER'image(checkint) & " not " & INTEGER'image(sdivres'low)
      severity error;
    
    assert (quiet) report "Overload operations testing complete" severity note;
    overloadtest_done <= true;
    wait;
  end process overloadtest;

  divmodtest : process is
    constant bound         : INTEGER := 12;  -- 512
    variable sgn10, res10  : sfixed (10 downto -1);
    variable sgn4, res4    : sfixed (3 downto -1);
    variable ugn10, ures10 : ufixed (10 downto -1);
    variable ugn4, ures4   : ufixed (3 downto -1);
  begin
    wait until start_divmodtest;
    -- loop copied from "numeric_std_tb1.vhd" to check the div and mod functions
    -- unsigned
    for i in 0 to bound-1 loop
      ugn10 := to_ufixed(i, ugn10'high, ugn10'low);
      for j in 1 to 7 loop
        ugn4  := to_ufixed(j, ugn4'high, ugn4'low);
        ures4 := ugn10 rem ugn4;
        assert to_integer(ures4) = i rem j
          report INTEGER'image(i) & "u rem " & INTEGER'image(j) & " = "
          & to_string(ures4) & "(" & INTEGER'image(to_integer(ures4))
          & ") not " & INTEGER'image(i rem j)
          severity error;
      end loop;
    end loop;
    for i in 0 to bound-1 loop
      ugn10 := to_ufixed(i, ugn10'high, ugn10'low);
      for j in 1 to 7 loop
        ugn4  := to_ufixed(j, ugn4'high, ugn4'low);
        ures4 := ugn10 mod ugn4;
        assert to_integer(ures4) = i mod j
          report INTEGER'image(i) & " mod " & INTEGER'image(j) & " = "
          & to_string(ures4) & "(" & INTEGER'image(to_integer(ures4))
          & ") not " & INTEGER'image(i mod j)
          severity error;
      end loop;
    end loop;
    -- signed
    for i in -bound to bound-1 loop
      sgn10 := to_sfixed(i, sgn10'high, sgn10'low);
      for j in -8 to 7 loop
        next when j = 0;
        sgn4 := to_sfixed(j, sgn4'high, sgn4'low);
        res4 := sgn10 rem sgn4;
        assert to_integer(res4) = i rem j
          report INTEGER'image(i) & " rem " & INTEGER'image(j) & " = "
          & to_string(res4) & "(" & INTEGER'image(to_integer(res4))
          & ") not " & INTEGER'image(i rem j)
          severity error;
      end loop;
    end loop;
    for i in -bound to bound-1 loop
      sgn10 := to_sfixed(i, sgn10'high, sgn10'low);
      for j in -8 to 7 loop
        next when j = 0;
        sgn4 := to_sfixed(j, sgn4'high, sgn4'low);
        res4 := sgn10 mod sgn4;
        assert to_integer(res4) = i mod j
          report INTEGER'image(i) & " mod " & INTEGER'image(j) & " = "
          & to_string(res4) & "(" & INTEGER'image(to_integer(res4))
          & ") not " & INTEGER'image(i mod j)
          severity error;
      end loop;
    end loop;
    assert (quiet) report "Div and Mod test complete" severity note;
    divmodtest_done <= true;
  end process divmodtest;

  -- purpose: test the accumulate function
  accumtest : process is
    variable x, y, z : ufixed (3 downto 0);  -- accumulator
    variable a, b, c : sfixed (4 downto 0);  -- accumulator
    variable ci, co  : STD_ULOGIC;           -- carry in and out
  begin
    wait until start_accumtest;
    X := (others => '0');
    for i in 1 to 20 loop
      X := resize (arg            => (X + 1),
                   left_index     => X'high,
                   right_index    => X'low,
                   round_style    => fixed_truncate,
                   overflow_style => fixed_wrap);
    end loop;
    y := "0100";                             -- 4
    report_error ("UNSIGNED Accumulator test", X, Y);
    X := (others => '0');
    for i in 1 to 20 loop
      X := resize ((X + 1), X'high, X'low, fixed_wrap, fixed_truncate);
    end loop;
    y  := "0100";                            -- 4
    report_error ("NP UNSIGNED Accumulator test", X, Y);
    x  := "0001";
    y  := "0001";
    ci := '0';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(2, z));
    assert (co = '0')
      report "unsigned 1 + 1 + 0 carry out " & STD_ULOGIC'image(co)
      severity error;
    x  := "0001";
    y  := "0001";
    ci := '1';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(3, z));
    assert (co = '0')
      report "unsigned 1 + 1 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;
    x  := "1001";
    y  := "1001";
    ci := '0';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(2, z));
    assert (co = '1')
      report "unsigned 1001 + 1001 + 0 carry out " & STD_ULOGIC'image(co)
      severity error;
    x  := "0111";
    y  := "0111";
    ci := '0';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(14, z));
    assert (co = '0')
      report "unsigned 0111 + 0111 + 0 carry out " & STD_ULOGIC'image(co)
      severity error;
    x  := "0111";
    y  := "0111";
    ci := '1';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(15, z));
    assert (co = '0')
      report "unsigned 0111 + 0111 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;
    x  := "0111";
    y  := "1000";
    ci := '1';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(0, z));
    assert (co = '1')
      report "unsigned 0111 + 1000 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;
    x  := "1111";
    y  := "1111";
    ci := '1';
    add_carry (L       => X, R => Y, c_in => ci,
                result => z, c_out => co);
    report_error ("Add_carry " & to_string(x) & ", " & to_string(y) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  z, to_ufixed(15, z));
    assert (co = '1')
      report "unsigned 1111 + 1111 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;
    a := (others => '0');
    for i in 1 to 20 loop
      a := resize (arg            => (a + 1),
                   left_index     => a'high,
                   right_index    => a'low,
                   round_style    => fixed_truncate,
                   overflow_style => fixed_wrap);
    end loop;
    b := "10100";                            -- -12
    report_error ("SIGNED Accumulator test", a, b);
    a := (others => '0');
    for i in 1 to 20 loop
      a := resize ((a + 1), a'high, a'low, fixed_wrap, fixed_truncate);
    end loop;
    b  := "10100";                           -- -12
    report_error ("NP SIGNED Accumulator test", a, b);
    a  := "00001";
    b  := "00001";
    ci := '0';
    add_carry (L       => a, R => b, c_in => ci,
                result => c, c_out => co);
    report_error ("Add_carry " & to_string(a) & ", " & to_string(b) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  c, to_sfixed(2, c));
    assert (co = '0')
      report "signed 1 + 1 + 0 carry out " & STD_ULOGIC'image(co)
      severity error;
    a  := "00001";
    b  := "00001";
    ci := '1';
    add_carry (L       => a, R => b, c_in => ci,
                result => c, c_out => co);
    report_error ("Add_carry " & to_string(a) & ", " & to_string(b) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  c, to_sfixed(3, c));
    assert (co = '0')
      report "signed 1 + 1 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;
    a  := "01000";
    b  := "01000";
    ci := '0';
    add_carry (L       => a, R => b, c_in => ci,
                result => c, c_out => co);
    b := "10000";
    report_error ("Add_carry " & to_string(a) & ", " & to_string(b) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  c, b);
    assert (co = '0')
      report "signed 01000 + 01000 + 0 carry out " & STD_ULOGIC'image(co)
      severity error;
    a  := "10000";
    b  := "01110";
    ci := '1';
    add_carry (L       => a, R => b, c_in => ci,
                result => c, c_out => co);
    b := "11111";
    report_error ("Add_carry " & to_string(a) & ", " & to_string(b) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  c, b);
    assert (co = '1')
      report "signed 10000 + 01110 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;
    a  := "10000";
    b  := "01111";
    ci := '1';
    add_carry (L       => a, R => b, c_in => ci,
                result => c, c_out => co);
    b := "00000";
    report_error ("Add_carry " & to_string(a) & ", " & to_string(b) & ", "
                  & STD_ULOGIC'image(ci) & " returned " & STD_ULOGIC'image(co),
                  c, b);
    assert (co = '0')
      report "signed 10000 + 01111 + 1 carry out " & STD_ULOGIC'image(co)
      severity error;

    assert (quiet) report "Accumulator testing complete" severity note;
    accumtest_done <= true;
    wait;
  end process accumtest;

  -- purpose: Checks NULL ranges
  nullrangestest : process is
    variable unull                : ufixed (-1 downto 1);   -- Null range
    variable snull                : sfixed (-1 downto 1);   -- Null range
    variable unnull               : UNSIGNED (3 downto 4);  -- null range
    variable snnull               : SIGNED (3 downto 4);    -- null range
    variable stnull               : STRING (5 to 1);        -- null string
    variable slvnull              : STD_LOGIC_VECTOR (3 downto 4);  -- null range
    variable check7uf1, check7uf2 : ufixed7_3;
    variable check7sf1, check7sf2 : sfixed7_3;
    variable checkslv             : STD_LOGIC_VECTOR (7 downto 0);
    variable checkuns             : UNSIGNED (7 downto 0);
    variable checks               : SIGNED (7 downto 0);
    variable checkint             : INTEGER := 0;
    variable checkreal            : REAL    := 0.0;

  begin  -- process nullrangestest
    wait until start_nullrangetest;
    check7uf1 := "0011000";             -- 3
    -- These will produce a simulation error if they don't work right.
    unull     := check7uf1 + unull;
    unull     := unull + check7uf1;
    unull     := unull + 3.0;
    unull     := 3.0 + unull;
    unull     := unull + unull;
    unull     := check7uf1 - unull;
    unull     := unull - check7uf1;
    unull     := unull - 3.0;
    unull     := 3.0 - unull;
    unull     := unull - unull;
    unull     := check7uf1 * unull;
    unull     := unull * check7uf1;
    unull     := unull * 3.0;
    unull     := 3.0 * unull;
    unull     := unull * unull;
    unull     := check7uf1 / unull;
    unull     := unull / check7uf1;
    unull     := unull / 3.0;
    unull     := 3.0 / unull;
    unull     := unull / unull;
    unull     := check7uf1 rem unull;
    unull     := unull rem check7uf1;
    unull     := unull rem 3.0;
    unull     := 3.0 rem unull;
    unull     := unull rem unull;
    unull     := check7uf1 mod unull;
    unull     := unull mod check7uf1;
    unull     := unull mod 3.0;
    unull     := 3.0 mod unull;
    unull     := unull mod unull;
    slvnull   := to_slv (unull);
    unull     := to_ufixed (checkslv, unull'high, unull'low);
    unull     := to_ufixed (slvnull, check7uf1'high, check7uf1'low);
    unull     := to_ufixed (checkint, unull'high, unull'low);
    unull     := to_ufixed (checkreal, unull'high, unull'low);
    unull     := to_ufixed (checkuns, unull'high, unull'low);
    unull     := to_ufixed (unnull, check7uf1'high, check7uf1'low);
--    unull     := to_ufixed (snull);
    unnull    := to_unsigned (unull, checkuns'length);
    checkint  := to_integer (unull);
    assert (checkint = 0) report "Null range to_integer return a non zero "
      & INTEGER'image(checkint) severity error;
    checkreal := to_real (unull);
    assert (checkreal = 0.0) report "Null range to_real return a non zero "
      & REAL'image(checkreal) severity error;
    if not quiet then
      report "Expect a null array warning from to_01 routine" severity note;
      unull := to_01 (unull);
    end if;
    unull := resize (check7uf1, unull'left, unull'right);
    unull := resize (unull, check7uf1'high, check7uf1'low);
    if (not quiet) then
      report "Expect 6 null range compare warnings here" severity note;
      assert not (check7uf1 = unull)
        report "Null array = returned true" severity error;
      assert (check7uf1 /= unull)
        report "Null array /= returned false" severity error;
      assert not (unull < check7uf1)
        report "Null array < returned true" severity error;
      assert not (check7uf1 > unull)
        report "Null array > returned true" severity error;
      assert not (unull <= check7uf1)
        report "Null array <= returned true" severity error;
      assert not (check7uf1 >= unull)
        report "Null array >= returned true" severity error;
    end if;
    unull     := reciprocal (unull);
    unull     := to_ufixed (unnull);
    stnull    := to_string (unull);
--    stnull := to_dstring (unull);
    stnull    := to_ostring (unull);
    stnull    := to_hstring (unull);
--    unull     := to_ufixed (snull);
    -- signed test
    snull     := abs (snull);
    snull     := - snull;
    check7sf1 := "0011000";             -- 3
    -- These will produce a simulation error if they don't work right.
    snull     := check7sf1 + snull;
    snull     := snull + check7sf1;
    snull     := snull + 3.0;
    snull     := 3.0 + snull;
    snull     := snull + snull;
    snull     := check7sf1 - snull;
    snull     := snull - check7sf1;
    snull     := snull - 3.0;
    snull     := 3.0 - snull;
    snull     := snull - snull;
    snull     := check7sf1 * snull;
    snull     := snull * check7sf1;
    snull     := snull * 3.0;
    snull     := 3.0 * snull;
    snull     := snull * snull;
    snull     := check7sf1 / snull;
    snull     := snull / check7sf1;
    snull     := snull / 3.0;
    snull     := 3.0 / snull;
    snull     := snull / snull;
    snull     := check7sf1 rem snull;
    snull     := snull rem check7sf1;
    snull     := snull rem 3.0;
    snull     := 3.0 rem snull;
    snull     := snull rem snull;
    snull     := check7sf1 mod snull;
    snull     := snull mod check7sf1;
    snull     := snull mod 3.0;
    snull     := 3.0 mod snull;
    snull     := snull mod snull;
    slvnull   := to_slv (snull);
    snull     := to_sfixed (checkslv, snull'high, snull'low);
    snull     := to_sfixed (slvnull, check7sf1'high, check7sf1'low);
    snull     := to_sfixed (checkint, snull'high, snull'low);
    snull     := to_sfixed (checkreal, snull'high, snull'low);
    snull     := to_sfixed (checks, snull'high, snull'low);
    snull     := to_sfixed (snnull, check7sf1'high, check7sf1'low);
    snull     := to_sfixed (unull);
    snnull    := to_signed (snull, checkuns'length);
    checkint  := to_integer (snull);
    assert (checkint = 0) report "Null range to_integer return a non zero "
      & INTEGER'image(checkint) severity error;
    checkreal := to_real (snull);
    assert (checkreal = 0.0) report "Null range to_real return a non zero "
      & REAL'image(checkreal) severity error;
    if not quiet then
      report "Expect a null array warning from to_01 routine" severity note;
      snull := to_01 (snull);
    end if;
    snull := resize (snull, check7sf1'high, check7sf1'low);
    snull := resize (check7sf1, snull'left, snull'right);
    if (not quiet) then
      report "Expect 6 null range compare warnings here" severity note;
      assert not (check7sf1 = snull)
        report "Null array = returned true" severity error;
      assert (check7sf1 /= snull)
        report "Null array /= returned false" severity error;
      assert not (snull < check7sf1)
        report "Null array < returned true" severity error;
      assert not (check7sf1 > snull)
        report "Null array > returned true" severity error;
      assert not (snull <= check7sf1)
        report "Null array <= returned true" severity error;
      assert not (check7sf1 >= snull)
        report "Null array >= returned true" severity error;
    end if;
    snull              := reciprocal (snull);
    snull              := to_sfixed (snnull);
    stnull             := to_string (snull);
--    stnull := to_dstring (snull);
    stnull             := to_ostring (snull);
    stnull             := to_hstring (snull);
--    snull              := to_sfixed (unull);
    -- end of null range test
    assert (quiet) report "Null range testing complete" severity note;
    nullrangetest_done <= true;
    wait;
  end process nullrangestest;


  -- purpose: random number test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  randomnum : process is
    procedure report_error_loop (
      constant errmes :    STRING;      -- error message
      interation      : in INTEGER;
      actual          : in ufixed;      -- data from algorithm
      expected        : in ufixed) is   -- reference data
    variable min_num : ufixed (expected'range) := (others => '0');
  begin  -- function report_error
    min_num (min_num'low) := '1';       -- minimum number in range
    assert (actual = expected)
      or (actual = (expected + min_num))
      or (actual = ufixed'(expected - min_num))
      report errmes & " on iteration " & INTEGER'image(interation) & CR
      & "Actual: " & to_string (actual) & CR
      & "     /= " & to_string (expected)
      severity error;
    return;
  end procedure report_error_loop;
  variable checknum             : ufixed (8 downto -8);
  variable checknum1            : ufixed (8 downto -8);
  variable checknum2            : ufixed (8 downto -8);
  variable checksum1, checksum2 : ufixed (9 downto -8);
  variable checkmul1, checkmul2 : ufixed (17 downto -16);
  variable checkdiv1, checkdiv2 : ufixed (16 downto -17);
  variable rckdiv1, rckdiv2     : ufixed (8 downto -9);
  variable checkreal            : REAL;  -- real test
  variable checkreal1           : REAL;  -- real test
  variable checkreal2           : REAL;  -- real test
  variable seed1, seed2         : INTEGER := 12345678;  -- Seed for random number
  begin  -- process randomnum
    wait until start_randomtest;
    addloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      checknum1  := to_ufixed(checkreal, checknum1'high, checknum1'low);
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checknum2  := to_ufixed(checkreal2, checknum2'high, checknum2'low);
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checksum2 := to_ufixed(checkreal+checkreal2,
                             checksum2'high, checksum2'low);
      checksum1 := checknum1 + checknum2;
      report_error_loop ("Add loop error",
                         i,
                         checksum1,
                         checksum2);
    end loop addloop;
    subloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      if checkreal < checkreal2 then    -- make one smaller than the other
        checkreal1 := checkreal;
        checkreal  := checkreal2;
        checkreal2 := checkreal1;
      end if;
      checknum1  := to_ufixed(checkreal, checknum1'high, checknum1'low);
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checknum2  := to_ufixed(checkreal2, checknum2'high, checknum2'low);
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checksum2 := to_ufixed(checkreal - checkreal2,
                             checksum2'high, checksum2'low);
      checksum1 := checknum1 - checknum2;
      report_error_loop ("Sub loop error",
                         i,
                         checksum1,
                         checksum2);
    end loop subloop;
    mulloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      checknum1  := to_ufixed(checkreal, checknum1'high, checknum1'low);
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checknum2  := to_ufixed(checkreal2, checknum2'high, checknum2'low);
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checkmul2 := to_ufixed(checkreal*checkreal2,
                             checkmul2'high, checkmul2'low);
      checkmul1 := checknum1 * checknum2;
      report_error_loop ("Mult loop error",
                         i,
                         checkmul1,
                         checkmul2);
    end loop mulloop;
    divloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      checknum1  := to_ufixed(checkreal, checknum1'high, checknum1'low);
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checknum2  := to_ufixed(checkreal2, checknum2'high, checknum2'low);
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      if (checkreal2 = 0.0) then        -- check for X/0
        checkreal2 := 1.0;
        checknum2  := to_ufixed (1, checknum'high, checknum'low);
      end if;
      checkdiv2 := to_ufixed(checkreal/checkreal2,
                             checkdiv2'high, checkdiv2'low);
      checkdiv1 := checknum1 / checknum2;
      report_error_loop ("Div loop error " & to_string(checknum1) & " / "
                         & to_string(checknum2),
                         i,
                         checkdiv1,
                         checkdiv2);
    end loop divloop;
    reciploop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**checknum'high;
      checknum1 := to_ufixed(checkreal, checknum1'high, checknum1'low);
      checkreal := to_real(checknum1);  -- convert back for rounding.
      rckdiv2 := to_ufixed(1.0/checkreal,
                           rckdiv2'high, rckdiv2'low);
      rckdiv1 := reciprocal (checknum1);
      report_error_loop ("1/x loop error",
                         i,
                         rckdiv1,
                         rckdiv2);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 / 2.0**(checknum'high/2);
      checknum1  := to_ufixed(checkreal2, checknum1'high, checknum1'low);
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      if (checkreal = 0.0) then         -- check for X/0
        checkreal := 1.0;
        checknum1 := to_ufixed (1, checknum'high, checknum'low);
      end if;
      rckdiv2 := to_ufixed(1.0/checkreal,
                           rckdiv2'high, rckdiv2'low);
      rckdiv1 := reciprocal (checknum1);
      report_error_loop ("1/x max loop error",
                         i,
                         rckdiv1,
                         rckdiv2);
    end loop reciploop;
    assert (quiet) report "Unsiged random number loop completed" severity note;
    randomtest_done <= true;
    wait;
  end process randomnum;


  -- purpose: random signed number test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  randomsnum : process is
    procedure report_error_loop (
      constant errmes : in STRING;      -- error message
      interation      : in INTEGER;
      actual          : in sfixed;      -- data from algorithm
      expected        : in sfixed) is   -- reference data
    variable min_num : sfixed (expected'range) := (others => '0');
  begin  -- function report_error
    min_num (min_num'low) := '1';       -- minimum number in range
    assert (actual = expected)
      or (actual = (expected + min_num))
      or (actual = (expected - min_num))
      report errmes & " on iteration " & INTEGER'image(interation) & CR
      & "Actual: " & to_string (actual) & CR
      & "     /= " & to_string (expected)
      severity error;
    return;
  end procedure report_error_loop;
  variable checknum             : sfixed (8 downto -8);
  variable checknum1            : sfixed (8 downto -8);
  variable checknum2            : sfixed (8 downto -8);
  variable checksum1, checksum2 : sfixed (9 downto -8);
  variable checkmul1, checkmul2 : sfixed (17 downto -16);
  variable checkdiv1, checkdiv2 : sfixed (17 downto -16);
  variable rckdiv1, rckdiv2     : sfixed (9 downto -8);
  variable checkreal            : REAL;  -- real test
  variable checkreal1           : REAL;  -- real test
  variable checkreal2           : REAL;  -- real test
  variable seed1, seed2         : INTEGER := 13254678;  -- Seed for random number
  begin  -- process randomnum
    wait until start_randomstest;
    addloop : for i in 0 to iterations loop
      -- Create two random real numbers
      uniform (seed1, seed2, checkreal);
      uniform (seed1, seed2, checkreal2);
      -- Numbers from "uniform" are between 1.0 and 0, multiply them
      -- by 2**checknum'high to get a larger range.
      checkreal  := checkreal * 2.0**checknum'high;
      checkreal2 := checkreal2 * 2.0**checknum'high;
      -- Convert them to "sfixed"
      checknum1  := to_sfixed(checkreal, checknum1'high, checknum1'low);
      checknum2  := to_sfixed(checkreal2, checknum2'high, checknum2'low);
      -- Toss in a negative number occasionally
      if checknum1(0) = '1' then
        checknum1 := resize(-checknum1, checknum1);
      end if;
      if checknum2(0) = '1' then
        checknum2 := resize(-checknum2, checknum2);
      end if;
      -- Convert back to real (gets rid of any rounding issues)
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      -- Add the real versions together and convert to sfixed.
      checksum2 := to_sfixed(checkreal+checkreal2,
                             checksum2'high, checksum2'low);
      -- Add the two randomly generated numbers together
      checksum1 := checknum1 + checknum2;
      -- Compare.
      report_error_loop ("Signed Add loop error",
                         i,
                         checksum1,
                         checksum2);
    end loop addloop;
    subloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      checknum1  := to_sfixed(checkreal, checknum1'high, checknum1'low);
      checknum2  := to_sfixed(checkreal2, checknum2'high, checknum2'low);
      if checknum1(0) = '1' then
        checknum1 := resize(-checknum1, checknum1);
      end if;
      if checknum2(0) = '1' then
        checknum2 := resize(-checknum2, checknum2);
      end if;
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checksum2 := to_sfixed(checkreal - checkreal2,
                             checksum2'high, checksum2'low);
      checksum1 := checknum1 - checknum2;
      report_error_loop ("Signed Sub loop error",
                         i,
                         checksum1,
                         checksum2);
    end loop subloop;
    mulloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      checknum1  := to_sfixed(checkreal, checknum1'high, checknum1'low);
      checknum2  := to_sfixed(checkreal2, checknum2'high, checknum2'low);
      if checknum1(0) = '1' then
        checknum1 := resize(-checknum1, checknum1);
      end if;
      if checknum2(0) = '1' then
        checknum2 := resize(-checknum2, checknum2);
      end if;
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checkmul2 := to_sfixed(checkreal*checkreal2,
                             checkmul2'high, checkmul2'low);
      checkmul1 := checknum1 * checknum2;
      report_error_loop ("Signed Mult loop error",
                         i,
                         checkmul1,
                         checkmul2);
    end loop mulloop;
    divloop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**checknum'high;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**checknum'high;
      checknum1  := to_sfixed(checkreal, checknum1'high, checknum1'low);
      checknum2  := to_sfixed(checkreal2, checknum2'high, checknum2'low);
      if checknum1(0) = '1' then
        checknum1 := resize(-checknum1, checknum1);
      end if;
      if checknum2(0) = '1' then
        checknum2 := resize(-checknum2, checknum2);
      end if;
      checkreal  := to_real(checknum1);  -- convert back for rounding.
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checkdiv2 := to_sfixed(checkreal/checkreal2,
                             checkdiv2'high, checkdiv2'low);
      checkdiv1 := checknum1 / checknum2;
      assert (not debug)
        report to_string(checknum1) & "/" & to_string(checknum2)
        & "=" & to_string(checkdiv1)
        severity note;
      report_error_loop ("Signed Div loop error "
                         & to_string(checknum1) & " / " & to_string(checknum2),
                         i,
                         checkdiv1,
                         checkdiv2);
    end loop divloop;
    reciploop : for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**checknum'high;
      checknum1 := to_sfixed(checkreal, checknum1'high, checknum1'low);
      if checknum1(0) = '1' then
        checknum1 := resize(-checknum1, checknum1);
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      if (checkreal = 0.0) then         -- check for X/0
        checkreal := 1.0;
        checknum1 := to_sfixed (1, checknum'high, checknum'low);
      end if;
      rckdiv2 := to_sfixed(1.0/checkreal,
                           rckdiv2'high, rckdiv2'low);
      rckdiv1 := reciprocal (checknum1);
      report_error_loop ("signed 1/x loop error",
                         i,
                         rckdiv1,
                         rckdiv2);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 / 2.0**(checknum'high/2);
      checknum1  := to_sfixed(checkreal2, checknum1'high, checknum1'low);
      if checknum1(0) = '1' then
        checknum1 := resize(-checknum1, checknum1);
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.        
      if (checkreal = 0.0) then         -- check for X/0
        checkreal := 1.0;
        checknum1 := to_sfixed (1, checknum'high, checknum'low);
      end if;
      rckdiv2 := to_sfixed(1.0/checkreal,
                           rckdiv2'high, rckdiv2'low);
      rckdiv1 := reciprocal (checknum1);
      report_error_loop ("signed 1/x max loop error",
                         i,
                         rckdiv1,
                         rckdiv2);
    end loop reciploop;
    assert (quiet) report "Signed random number loop completed" severity note;
    randomstest_done <= true;
    wait;
  end process randomsnum;

  -- purpose: from_string test
  -- type   : sequential
  -- inputs : clock, reset
  -- outputs: 
  fromstr : process is
    variable L             : LINE;                  -- LINE
    variable ck7, ck7t     : ufixed (3 downto -3);
    variable cks7, cks7t   : sfixed (3 downto -3);
    variable ckx7, ckx7t   : ufixed (6 downto -5);  -- an odd range
    variable ckxs7, ckxs7t : sfixed (6 downto -5);  -- an odd range
    variable ckh7, ckh7t   : ufixed (11 downto -4);
    variable ckhs7, ckhs7t : sfixed (11 downto -4);
    variable cko7, cko7t   : ufixed (11 downto -6);
    variable ckso7, ckso7t : sfixed (11 downto -6);
    variable cknodot       : ufixed (11 downto 0);
    variable cksnodot      : sfixed (11 downto 0);
  begin
    wait until start_fromstrtest;
    L       := new STRING'("1001101");
    ck7     := from_string (L.all, ck7'high, ck7'low);
    ck7t    := to_ufixed (9.625, ck7t'high, ck7'low);
    report_error ("from_string(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1010.011");
    ck7     := from_string (L.all, ck7'high, ck7'low);
    ck7t    := to_ufixed (10.375, ck7t'high, ck7t'low);
    report_error ("from_string(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1001101");
    ck7     := from_bstring (L.all, ck7'high, ck7'low);
    ck7t    := to_ufixed (9.625, ck7t'high, ck7'low);
    report_error ("from_bstring(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1010.011");
    ck7     := from_bstring (L.all, ck7'high, ck7'low);
    ck7t    := to_ufixed (10.375, ck7t'high, ck7'low);
    report_error ("from_bstring(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("101010111100");
    cknodot := from_string (L.all, cknodot'high, 0);
    report_error ("from_string(" & L.all & ", 'high 0)", cknodot,
                  to_ufixed (UNSIGNED'("101010111100")));
    deallocate (L);
    -- size_res versions of functions
    L       := new STRING'("1001001");
    ck7     := from_string (L.all, ck7);
    ck7t    := to_ufixed (9.125, ck7t);
    report_error ("from_string(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1010.011");
    ck7     := from_string (L.all, ck7);
    ck7t    := to_ufixed (10.375, ck7t);
    report_error ("from_string(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1001101");
    ck7     := from_bstring (L.all, ck7);
    ck7t    := to_ufixed (9.625, ck7t);
    report_error ("from_bstring(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1011.011");
    ck7     := from_bstring (L.all, ck7);
    ck7t    := to_ufixed (11.375, ck7t);
    report_error ("from_bstring(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("101010111100");
    cknodot := from_string (L.all, cknodot);
    report_error ("from_string(" & L.all & ", size_res)", cknodot,
                  to_ufixed (UNSIGNED'("101010111100")));
    deallocate (L);
    -- Constant versions
    L       := new STRING'("1011.011");
    ck7     := from_string (L.all);
    ck7t    := to_ufixed (11.375, ck7t);
    report_error ("from_string(" & L.all &")", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("0000.000");
    ck7     := from_string (L.all);
    ck7t    := to_ufixed (0, ck7t);
    report_error ("from_string(" & L.all &")", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("1011.011");
    ck7     := from_bstring (L.all);
    ck7t    := to_ufixed (11.375, ck7t);
    report_error ("from_string(" & L.all &")", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("0000.000");
    ck7     := from_bstring (L.all);
    ck7t    := to_ufixed (0, ck7t);
    report_error ("from_string(" & L.all &")", ck7, ck7t);
    deallocate (L);
    L       := new STRING'("101010111100");
    cknodot := from_string (L.all);
    report_error ("from_string(" & L.all & ")", cknodot,
                  to_ufixed (UNSIGNED'("101010111100")));
    deallocate (L);
    -- signed version
    L        := new STRING'("1001101");
    cks7     := from_string (L.all, cks7'high, cks7'low);
    cks7t    := "1001101";
    report_error ("from_string( s " & L.all &", 'high, 'low)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1010.011");
    cks7     := from_string (L.all, cks7'high, cks7'low);
    cks7t    := "1010011";
    report_error ("from_string( s " & L.all &", 'high, 'low)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1001101");
    cks7     := from_bstring (L.all, cks7'high, cks7'low);
    cks7t    := "1001101";
    report_error ("from_bstring( s " & L.all &", 'high, 'low)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1010.011");
    cks7     := from_bstring (L.all, cks7'high, cks7'low);
    cks7t    := "1010011";
    report_error ("from_bstring( s " & L.all &", 'high, 'low)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("101010111100");
    cksnodot := from_string (L.all, cknodot'high, 0);
    report_error ("from_string( s " & L.all & ", 'high 0)", cksnodot,
                  to_sfixed (SIGNED'("101010111100")));
    deallocate (L);
    -- size_res versions of functions
    L        := new STRING'("1001001");
    cks7     := from_string (L.all, cks7);
    cks7t    := "1001001";
    report_error ("from_string( s " & L.all &", size_res)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1010.011");
    cks7     := from_string (L.all, cks7);
    cks7t    := "1010011";
    report_error ("from_string( s " & L.all &", size_res)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1001101");
    cks7     := from_bstring (L.all, cks7);
    cks7t    := "1001101";
    report_error ("from_bstring( s " & L.all &", size_res)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1011.011");
    cks7     := from_bstring (L.all, cks7);
    cks7t    := "1011011";
    report_error ("from_bstring( s " & L.all &", size_res)", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("101010111100");
    cksnodot := from_string (L.all, cksnodot);
    report_error ("from_string( s " & L.all & ", size_res)", cksnodot,
                  to_sfixed (SIGNED'("101010111100")));
    deallocate (L);
    -- Constant versions
    L        := new STRING'("1011.011");
    cks7     := from_string (L.all);
    cks7t    := "1011011";
    report_error ("from_string( s " & L.all &")", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("0000.000");
    cks7     := from_string (L.all);
    cks7t    := to_sfixed (0, cks7t);
    report_error ("from_string( s " & L.all &")", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("1011.011");
    cks7     := from_bstring (L.all);
    cks7t    := "1011011";
    report_error ("from_string( s " & L.all &")", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("0000.000");
    cks7     := from_bstring (L.all);
    cks7t    := to_sfixed (0, cks7t);
    report_error ("from_string( s " & L.all &")", cks7, cks7t);
    deallocate (L);
    L        := new STRING'("101010111100");
    cksnodot := from_string (L.all);
    report_error ("from_string( s " & L.all & ")", cksnodot,
                  to_sfixed (SIGNED'("101010111100")));
    deallocate (L);
    -- Try it in HEX.
    L       := new STRING'("8FF.1");
    ckh7    := from_hstring (L.all, ckh7'high, ckh7'low);
    ckh7t   := from_string ("100011111111.0001");
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ckh7, ckh7t);
    deallocate (L);
    L       := new STRING'("AF09");
    ckh7    := from_hstring (L.all, ckh7'high, ckh7'low);
    ckh7t   := from_string ("101011110000.1001");
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ckh7, ckh7t);
    deallocate (L);
    L       := new STRING'("8FF.1");
    ckh7    := from_hstring (L.all, ckh7);
    ckh7t   := from_string ("100011111111.0001");
    report_error ("from_hstring(" & L.all & ", size_res)", ckh7, ckh7t);
    deallocate (L);
    L       := new STRING'("AF09");
    ckh7    := from_hstring (L.all, ckh7);
    ckh7t   := from_string ("101011110000.1001");
    report_error ("from_hstring(" & L.all & ", size_res)", ckh7, ckh7t);
    deallocate (L);
    L       := new STRING'("8FF.1");
    ckh7    := from_hstring (L.all);
    ckh7t   := from_string ("100011111111.0001");
    report_error ("from_hstring(" & L.all & ")", ckh7, ckh7t);
    deallocate (L);
    L       := new STRING'("AF9");
    cknodot := from_hstring (L.all);
    report_error ("from_hstring(" & L.all & ")", cknodot,
                  to_ufixed(UNSIGNED'("101011111001")));
    deallocate (L);
    -- Try some odd ranges
    L     := new STRING'("8.2");
    ck7   := from_hstring (L.all, ck7'high, ck7'low);
    ck7t  := from_string ("1000.001");
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("A.A");
    ck7   := from_hstring (L.all, ck7);
    ck7t  := from_string ("1010.101");
    report_error ("from_hstring(" & L.all & ", size_res)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("7f.e8");
    ckx7  := from_hstring (L.all, ckx7);
    ckx7t := from_string ("1111111.11101");
    report_error ("from_hstring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    L     := new STRING'("3d.c7");
    ckx7  := from_hstring (L.all, ckx7);
    ckx7t := from_string ("0111101.11000");         -- rounded
    report_error ("from_hstring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    L     := new STRING'("7fe8");                   -- no dot
    ckx7  := from_hstring (L.all, ckx7);
    ckx7t := from_string ("1111111.11101");
    report_error ("from_hstring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    -- Cause some errors
    if (not quiet) then
      report "Expect 4 from_hstring(unsigned) errors" severity note;
      L    := new STRING'("3.dc7");                 -- dot in the wrong spot
      ckx7 := from_hstring (L.all, ckx7);
      L    := new STRING'("FF.FF");                 -- overflow
      ckx7 := from_hstring (L.all, ckx7);
      L    := new STRING'("00");                    -- underflow
      ckx7 := from_hstring (L.all, ckx7);
      L    := new STRING'("00.0.0");                -- two dots
      ckx7 := from_hstring (L.all, ckx7);
    end if;
    -- SIGNED
    L        := new STRING'("8FF.1");
    ckhs7    := from_hstring (L.all, ckhs7'high, ckhs7'low);
    ckhs7t   := from_string ("100011111111.0001");
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ckhs7, ckhs7t);
    deallocate (L);
    L        := new STRING'("AF09");
    ckhs7    := from_hstring (L.all, ckhs7'high, ckhs7'low);
    ckhs7t   := from_string ("101011110000.1001");
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ckhs7, ckhs7t);
    deallocate (L);
    L        := new STRING'("8FF.1");
    ckhs7    := from_hstring (L.all, ckhs7);
    ckhs7t   := from_string ("100011111111.0001");
    report_error ("from_hstring(" & L.all & ", size_res)", ckhs7, ckhs7t);
    deallocate (L);
    L        := new STRING'("AF09");
    ckhs7    := from_hstring (L.all, ckhs7);
    ckhs7t   := from_string ("101011110000.1001");
    report_error ("from_hstring(" & L.all & ", size_res)", ckhs7, ckhs7t);
    deallocate (L);
    L        := new STRING'("8FF.1");
    ckhs7    := from_hstring (L.all);
    ckhs7t   := from_string ("100011111111.0001");
    report_error ("from_hstring(" & L.all & ")", ckhs7, ckhs7t);
    deallocate (L);
    L        := new STRING'("AF9");
    cksnodot := from_hstring (L.all);
    report_error ("from_hstring(" & L.all & ")", cksnodot,
                  to_sfixed(SIGNED'("101011111001")));
    deallocate (L);
    -- Try some odd ranges
    L      := new STRING'("8.2");
    cks7   := from_hstring (L.all, cks7'high, cks7'low);
    cks7t  := from_string ("1000.001");
    report_error ("from_hstring(s" & L.all & ", 'high, 'low)", cks7, cks7t);
    deallocate (L);
    L      := new STRING'("A.A");
    cks7   := from_hstring (L.all, cks7);
    cks7t  := from_string ("1010.101");
    report_error ("from_hstring(s" & L.all & ", size_res)", cks7, cks7t);
    deallocate (L);
    L      := new STRING'("ff.e8");
    ckxs7  := from_hstring (L.all, ckxs7);
    ckxs7t := from_string ("1111111.11101");
    report_error ("from_hstring(s" & L.all & ", size_res)", ckxs7, ckxs7t);
    deallocate (L);
    L      := new STRING'("3d.c7");
    ckxs7  := from_hstring (L.all, ckxs7);
    ckxs7t := from_string ("0111101.11000");        -- rounded
    report_error ("from_hstring(s" & L.all & ", size_res)", ckxs7, ckxs7t);
    deallocate (L);
    L      := new STRING'("ffe8");                  -- no dot
    ckxs7  := from_hstring (L.all, ckxs7);
    ckxs7t := from_string ("1111111.11101");
    report_error ("from_hstring(s" & L.all & ", size_res)", ckxs7, ckxs7t);
    deallocate (L);
    -- Cause some errors
    if (not quiet) then
      report "Expect 5 from_hstring(signed) errors" severity note;
      L     := new STRING'("3.dc7");                -- dot in the wrong spot
      ckxs7 := from_hstring (L.all, ckxs7);
      L     := new STRING'("7F.FF");                -- overflow+
      ckxs7 := from_hstring (L.all, ckxs7);
      L     := new STRING'("8F.FF");                -- overflow-
      ckxs7 := from_hstring (L.all, ckxs7);
      L     := new STRING'("00");                   -- underflow
      ckxs7 := from_hstring (L.all, ckxs7);
      L     := new STRING'("00.0.0");               -- two dots
      ckxs7 := from_hstring (L.all, ckxs7);
    end if;
    -- Octal
    L       := new STRING'("4070.45");
    cko7    := from_ostring (L.all, cko7'high, cko7'low);
    cko7t   := from_string ("100000111000.100101");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", cko7, cko7t);
    deallocate (L);
    L       := new STRING'("707057");
    cko7    := from_ostring (L.all, cko7'high, cko7'low);
    cko7t   := from_string ("111000111000.101111");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", cko7, cko7t);
    deallocate (L);
    L       := new STRING'("4070.45");
    cko7    := from_ostring (L.all, cko7);
    cko7t   := from_string ("100000111000.100101");
    report_error ("from_ostring(" & L.all & ", size_res)", cko7, cko7t);
    deallocate (L);
    L       := new STRING'("707057");
    cko7    := from_ostring (L.all, cko7);
    cko7t   := from_string ("111000111000.101111");
    report_error ("from_ostring(" & L.all & ", size_res)", cko7, cko7t);
    deallocate (L);
    L       := new STRING'("4070.45");
    cko7    := from_ostring (L.all);
    cko7t   := from_string ("100000111000.100101");
    report_error ("from_ostring(" & L.all & ")", cko7, cko7t);
    deallocate (L);
    L       := new STRING'("4161");
    cknodot := from_ostring(L.all);
    report_error ("from_ostring(" & L.all & ")", cknodot,
                  to_ufixed(UNSIGNED'("100001110001")));
    deallocate (L);
    -- Try some odd ranges
    L     := new STRING'("17.7");
    ck7   := from_ostring (L.all, ck7'high, ck7'low);
    ck7t  := from_string ("1111.111");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("177");
    ck7   := from_ostring (L.all, ck7'high, ck7'low);
    ck7t  := from_string ("1111.111");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("05.1");
    ck7   := from_ostring (L.all, ck7'high, ck7'low);
    ck7t  := from_string ("0101.001");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("155.72");
    ckx7  := from_ostring (L.all, ckx7);
    ckx7t := from_string ("1101101.11101");
    report_error ("from_ostring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    L     := new STRING'("063.77");
    ckx7  := from_ostring (L.all, ckx7);
    ckx7t := from_string ("0110011.11111");         -- not rounded
    report_error ("from_ostring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    -- Cause some errors
    if (not quiet) then
      report "Expect 4 from_ostring(unsigned) errors" severity note;
      L    := new STRING'("0.0000");                -- dot in the wrong spot
      ckx7 := from_ostring (L.all, ckx7);
      L    := new STRING'("200.00");                -- overflow
      ckx7 := from_ostring (L.all, ckx7);
      L    := new STRING'("00");                    -- underflow
      ckx7 := from_ostring (L.all, ckx7);
      L    := new STRING'("00.0.0");                -- two dots
      ckx7 := from_ostring (L.all, ckx7);
    end if;

-- signed octal
    L        := new STRING'("4070.45");
    ckso7    := from_ostring (L.all, ckso7'high, ckso7'low);
    ckso7t   := from_string ("100000111000.100101");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ckso7, ckso7t);
    deallocate (L);
    L        := new STRING'("707057");
    ckso7    := from_ostring (L.all, ckso7'high, ckso7'low);
    ckso7t   := from_string ("111000111000.101111");
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ckso7, ckso7t);
    deallocate (L);
    L        := new STRING'("4070.45");
    ckso7    := from_ostring (L.all, ckso7);
    ckso7t   := from_string ("100000111000.100101");
    report_error ("from_ostring(" & L.all & ", size_res)", ckso7, ckso7t);
    deallocate (L);
    L        := new STRING'("707057");
    ckso7    := from_ostring (L.all, ckso7);
    ckso7t   := from_string ("111000111000.101111");
    report_error ("from_ostring(" & L.all & ", size_res)", ckso7, ckso7t);
    deallocate (L);
    L        := new STRING'("4070.45");
    ckso7    := from_ostring (L.all);
    ckso7t   := from_string ("100000111000.100101");
    report_error ("from_ostring(" & L.all & ")", ckso7, ckso7t);
    deallocate (L);
    L        := new STRING'("4161");
    cksnodot := from_ostring(L.all);
    report_error ("from_ostring(" & L.all & ")", cksnodot,
                  to_sfixed(SIGNED'("100001110001")));
    deallocate (L);
    -- Cause some errors
    if (not quiet) then
      report "Expect 5 from_ostring(signed) errors" severity note;
      L     := new STRING'("0.0000");   -- dot in the wrong spot
      ckxs7 := from_ostring (L.all, ckxs7);
      L     := new STRING'("200.00");   -- +overflow
      ckxs7 := from_ostring (L.all, ckxs7);
      L     := new STRING'("600.00");   -- -overflow
      ckxs7 := from_ostring (L.all, ckxs7);
      L     := new STRING'("00");       -- underflow
      ckxs7 := from_ostring (L.all, ckxs7);
      L     := new STRING'("00.0.0");   -- two dots
      ckxs7 := from_ostring (L.all, ckxs7);
    end if;
    assert (quiet) report "from_string testing completed" severity note;
    fromstrtest_done <= true;
    wait;
  end process fromstr;

  -- purpose: main level test process
  -- Lifted from the "test_reduce_pack.vhd" tests
  test_reduce : process is
    procedure report_error (
      constant message : in STRING;         -- message string
      actual           : in ufixed;         -- result from code
      expected         : in STD_LOGIC) is   -- compared against
    begin  -- report_error
      report message & " (" & to_string(actual) & ") /= "
      & STD_LOGIC'image(expected)
      severity error;
    end report_error;
    procedure report_error (
      constant message : in STRING;           -- message string
      actual           : in sfixed;           -- result from code
      expected         : in STD_LOGIC) is     -- compared against
    begin  -- report_error
      report message & " (" & to_string(actual) & ") /= "
      & STD_LOGIC'image(expected)
      severity error;
  end report_error;
  variable slv16  : ufixed (10 downto -5);  -- 16 bit unsigned
  variable sulv16 : sfixed (10 downto -5);  -- 16 bit signed
  variable uns16  : ufixed (10 downto -5);  -- 16 bit unsigned
  variable sig16  : sfixed (10 downto -5);  -- 16 bit signed
  variable s      : STD_ULOGIC;             -- one bit
  -- Odd lenghths to test recursive algorithem
  variable slv13  : ufixed (10 downto -2);  -- 13 bit slv

  variable nullarray : ufixed (0 downto 12);  -- null array

  begin  -- process tester
    wait until start_reduce_test;
    ---------------------------------------------------------------------------
    -- Start with an "or" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (or (slv16) /= '0') then
      report_error ("or reduce", slv16, '0');
    end if;
    sulv16 := "0000000000000001";
    if (or (sulv16) /= '1') then
      report_error ("or reduce", sulv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (or (uns16) /= '1') then
      report_error ("or reduce", uns16, '1');
    end if;
    sig16 := "1000000000000001";
    if (or (sig16) /= '1') then
      report_error ("or reduce", sig16, '1');
    end if;
    slv13 := "0000000000000";
    if (or (slv13) /= '0') then
      report_error ("or reduce", slv13, '0');
    end if;
    slv13 := "0000000000001";
    if (or (slv13) /= '1') then
      report_error ("or reduce", slv13, '1');
    end if;
    slv13 := "1111111111111";
    if (or (slv13) /= '1') then
      report_error ("or reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (or (slv13) /= '1') then
      report_error ("or reduce", slv13, '1');
    end if;
    if (or (nullarray) /= '0') then    -- Null array test
      report_error ("or reduce NULL", slv13, '0');
    end if;
    -- x test
    slv16 := "00000000000ZX000";
    if (or (slv16) /= 'X') then
      report_error ("or reduce", slv16, 'X');
    end if;
    slv16 := "00000000000ZXWU-";
    if (or (slv16) /= 'U') then
      report_error ("or reduce", slv16, 'U');
    end if;
    slv16 := "10000000000ZXWU-";
    if (or (slv16) /= '1') then
      report_error ("or reduce", slv16, '1');
    end if;
    ---------------------------------------------------------------------------
    -- "and" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (and (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
    end if;
    sulv16 := "0000000000000001";
    if (and (sulv16) /= '0') then
      report_error ("and reduce", sulv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (and (uns16) /= '1') then
      report_error ("and reduce", uns16, '1');
    end if;
    sig16 := "1000000000000001";
    if (and (sig16) /= '0') then
      report_error ("and reduce", sig16, '0');
    end if;
    slv13 := "0000000000000";
    if (and (slv13) /= '0') then
      report_error ("and reduce", slv13, '0');
    end if;
    slv13 := "0000000000001";
    if (and (slv13) /= '0') then
      report_error ("and reduce", slv13, '0');
    end if;
    slv13 := "1111111111111";
    if (and (slv13) /= '1') then
      report_error ("and reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (and (slv13) /= '0') then
      report_error ("and reduce", slv13, '0');
    end if;
    if (and (nullarray) /= '1') then   -- Null array test
      report_error ("and reduce NULL", slv13, '0');
    end if;
    -- x test
    slv16 := "11111111111ZX111";
    if (and (slv16) /= 'X') then
      report_error ("and reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (and (slv16) /= 'U') then
      report_error ("and reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    if (and (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
    end if;
    ---------------------------------------------------------------------------
    -- xor test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (xor (slv16) /= '0') then
      report_error ("xor reduce", slv16, '0');
    end if;
    sulv16 := "0000000000000001";
    if (xor (sulv16) /= '1') then
      report_error ("xor reduce", sulv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (xor (uns16) /= '0') then
      report_error ("xor reduce", uns16, '0');
    end if;
    sig16 := "1000000000000001";
    if (xor (sig16) /= '0') then
      report_error ("xor reduce", sig16, '0');
    end if;
    slv13 := "0000000000000";
    if (xor (slv13) /= '0') then
      report_error ("xor reduce", slv13, '0');
    end if;
    slv13 := "0000000000001";
    if (xor (slv13) /= '1') then
      report_error ("xor reduce", slv13, '1');
    end if;
    slv13 := "1111111111111";
    if (xor (slv13) /= '1') then
      report_error ("xor reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (xor (slv13) /= '0') then
      report_error ("xor reduce", slv13, '0');
    end if;
    if (xor (nullarray) /= '0') then   -- Null array test
      report_error ("xor reduce NULL", slv13, '0');
    end if;
    slv16 := "11111111111ZX111";
    if (xor (slv16) /= 'X') then
      report_error ("xor reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (xor (slv16) /= 'U') then
      report_error ("xor reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    s     := xor (slv16);
    if (s /= 'U') then
      report_error ("xor reduce", slv16, s);
    end if;
    ---------------------------------------------------------------------------
    -- "nor" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (nor (slv16) /= '1') then
      report_error ("nor reduce", slv16, '1');
    end if;
    sulv16 := "0000000000000001";
    if (nor (sulv16) /= '0') then
      report_error ("nor reduce", sulv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (nor (uns16) /= '0') then
      report_error ("nor reduce", uns16, '0');
    end if;
    sig16 := "1000000000000001";
    if (nor (sig16) /= '0') then
      report_error ("nor reduce", sig16, '0');
    end if;
    slv13 := "0000000000000";
    if (nor (slv13) /= '1') then
      report_error ("nor reduce", slv13, '1');
    end if;
    slv13 := "0000000000001";
    if (nor (slv13) /= '0') then
      report_error ("nor reduce", slv13, '0');
    end if;
    slv13 := "1111111111111";
    if (nor (slv13) /= '0') then
      report_error ("nor reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (nor (slv13) /= '0') then
      report_error ("nor reduce", slv13, '0');
    end if;
    if (nor (nullarray) /= '1') then   -- Null array test
      report_error ("nor reduce NULL", slv13, '1');
    end if;
    -- x test
    slv16 := "00000000000ZX000";
    if (nor (slv16) /= 'X') then
      report_error ("nor reduce", slv16, 'X');
    end if;
    slv16 := "00000000000ZXWU-";
    if (nor (slv16) /= 'U') then
      report_error ("nor reduce", slv16, 'U');
    end if;
    slv16 := "10000000000ZXWU-";
    if (nor (slv16) /= '0') then
      report_error ("nor reduce", slv16, '0');
    end if;
    ---------------------------------------------------------------------------
    -- "nand" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (nand (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
    end if;
    sulv16 := "0000000000000001";
    if (nand (sulv16) /= '1') then
      report_error ("nand reduce", sulv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (nand (uns16) /= '0') then
      report_error ("nand reduce", uns16, '0');
    end if;
    sig16 := "1000000000000001";
    if (nand (sig16) /= '1') then
      report_error ("nand reduce", sig16, '1');
    end if;
    slv13 := "0000000000000";
    if (nand (slv13) /= '1') then
      report_error ("nand reduce", slv13, '1');
    end if;
    slv13 := "0000000000001";
    if (nand (slv13) /= '1') then
      report_error ("nand reduce", slv13, '1');
    end if;
    slv13 := "1111111111111";
    if (nand (slv13) /= '0') then
      report_error ("nand reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (nand (slv13) /= '1') then
      report_error ("nand reduce", slv13, '1');
    end if;
    if (nand (nullarray) /= '0') then  -- Null array test
      report_error ("nand reduce NULL", slv13, '1');
    end if;
    slv16 := "11111111111ZX111";
    if (nand (slv16) /= 'X') then
      report_error ("nand reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (nand (slv16) /= 'U') then
      report_error ("nand reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    if (nand (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
    end if;
    ---------------------------------------------------------------------------
    -- xnor test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (xnor (slv16) /= '1') then
      report_error ("xnor reduce", slv16, '1');
    end if;
    sulv16 := "0000000000000001";
    if (xnor (sulv16) /= '0') then
      report_error ("xnor reduce", sulv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (xnor (uns16) /= '1') then
      report_error ("xnor reduce", uns16, '1');
    end if;
    sig16 := "1000000000000001";
    if (xnor (sig16) /= '1') then
      report_error ("xnor reduce", sig16, '1');
    end if;
    slv13 := "0000000000000";
    if (xnor (slv13) /= '1') then
      report_error ("xnor reduce", slv13, '1');
    end if;
    slv13 := "0000000000001";
    if (xnor (slv13) /= '0') then
      report_error ("xnor reduce", slv13, '0');
    end if;
    slv13 := "1111111111111";
    if (xnor (slv13) /= '0') then
      report_error ("xnor reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (xnor (slv13) /= '1') then
      report_error ("xnor reduce", slv13, '1');
    end if;
    if (xnor (nullarray) /= '1') then  -- Null array test
      report_error ("xnor reduce NULL", slv13, '1');
    end if;
    slv16 := "11111111111ZX111";
    if (xnor (slv16) /= 'X') then
      report_error ("xnor reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (xnor (slv16) /= 'U') then
      report_error ("xnor reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    s     := xnor (slv16);
    if (s /= 'U') then
      report_error ("xnor reduce", slv16, s);
    end if;
    assert (quiet)
      report "Fixed point reduction testing complete" severity note;
    reduce_test_done <= true;
    wait;
  end process test_reduce;

  ----------------------------------------------------------------------------
  -- Copied from the "test_minmax.vhd".
  ----------------------------------------------------------------------------
  verify : process is
    subtype bv4 is STD_LOGIC_VECTOR(3 downto 0);
    variable a_bv  : bv4;
    variable a_sulv : ufixed(3 downto 0);
    variable a_slv : sfixed(3 downto 0);
    variable b_su  : STD_ULOGIC;
    variable b_bv  : bv4;
  begin
    wait until start_booltest;
    for a_val in 0 to 15 loop
      a_bv  := to_slv(to_ufixed(a_val, a_sulv));
      a_sulv := to_ufixed(a_bv, a_sulv);
      a_slv := to_sfixed(a_bv, a_slv);
      for b in STD_ULOGIC loop
        b_su := b;
        b_bv := bv4'(others => b);

        assert STD_LOGIC_VECTOR(a_sulv and b_su) = STD_LOGIC_VECTOR'(a_bv and b_bv)
          report "error in a_sulv and b_su";
        assert STD_LOGIC_VECTOR(a_slv and b_su) = STD_LOGIC_VECTOR'(a_bv and b_bv)
          report "error in a_slv and b_su";
        assert STD_LOGIC_VECTOR(b_su and a_sulv) = STD_LOGIC_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_sulv";
        assert STD_LOGIC_VECTOR(b_su and a_slv) = STD_LOGIC_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_slv";

        assert STD_LOGIC_VECTOR(a_sulv nand b_su) = STD_LOGIC_VECTOR'(a_bv nand b_bv)
          report "error in a_sulv nand b_su";
        assert STD_LOGIC_VECTOR(a_slv nand b_su) = STD_LOGIC_VECTOR'(a_bv nand b_bv)
          report "error in a_slv nand b_su";
        assert STD_LOGIC_VECTOR(b_su nand a_sulv) = STD_LOGIC_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_sulv";
        assert STD_LOGIC_VECTOR(b_su nand a_slv) = STD_LOGIC_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_slv";

        assert STD_LOGIC_VECTOR(a_sulv or b_su) = STD_LOGIC_VECTOR'(a_bv or b_bv)
          report "error in a_sulv or b_su";
        assert STD_LOGIC_VECTOR(a_slv or b_su) = STD_LOGIC_VECTOR'(a_bv or b_bv)
          report "error in a_slv or b_su";
        assert STD_LOGIC_VECTOR(b_su or a_sulv) = STD_LOGIC_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_sulv";
        assert STD_LOGIC_VECTOR(b_su or a_slv) = STD_LOGIC_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_slv";

        assert STD_LOGIC_VECTOR(a_sulv nor b_su) = STD_LOGIC_VECTOR'(a_bv nor b_bv)
          report "error in a_sulv nor b_su";
        assert STD_LOGIC_VECTOR(a_slv nor b_su) = STD_LOGIC_VECTOR'(a_bv nor b_bv)
          report "error in a_slv nor b_su";
        assert STD_LOGIC_VECTOR(b_su nor a_sulv) = STD_LOGIC_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_sulv";
        assert STD_LOGIC_VECTOR(b_su nor a_slv) = STD_LOGIC_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_slv";

        assert STD_LOGIC_VECTOR(a_sulv xor b_su) = STD_LOGIC_VECTOR'(a_bv xor b_bv)
          report "error in a_sulv xor b_su";
        assert STD_LOGIC_VECTOR(a_slv xor b_su) = STD_LOGIC_VECTOR'(a_bv xor b_bv)
          report "error in a_slv xor b_su";
        assert STD_LOGIC_VECTOR(b_su xor a_sulv) = STD_LOGIC_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_sulv";
        assert STD_LOGIC_VECTOR(b_su xor a_slv) = STD_LOGIC_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_slv";

        assert STD_LOGIC_VECTOR(a_sulv xnor b_su) = STD_LOGIC_VECTOR'(a_bv xnor b_bv)
          report "error in a_sulv xnor b_su";
        assert STD_LOGIC_VECTOR(a_slv xnor b_su) = STD_LOGIC_VECTOR'(a_bv xnor b_bv)
          report "error in a_slv xnor b_su";
        assert STD_LOGIC_VECTOR(b_su xnor a_sulv) = STD_LOGIC_VECTOR'(b_bv xnor a_bv)
          report "error in b_su xnor a_sulv";
        assert STD_LOGIC_VECTOR(b_su xnor a_slv) = STD_LOGIC_VECTOR'(b_bv xnor a_bv)
          report "error in b_su xnor a_slv";

        wait for 1 ns;
      end loop;
    end loop;

    assert (quiet) report "boolean test completed" severity note;
    booltest_done <= true;
    wait;
  end process verify;

  --------------------------------------------------------------------------
  -- The basic Vector on vector test for 1164 were never found
  -- here are new ones.
  --------------------------------------------------------------------------
  vecbool : process is
    variable uf, uf1, uf2, uf3 : ufixed (2 downto -2);            -- ufixed
    variable sf, sf1, sf2, sf3 : sfixed (2 downto -2);            -- sfixed
    variable sulv1             : STD_ULOGIC_VECTOR (4 downto 0);  -- sulv for test
  begin
    wait until start_vecbool;
    -- not
    uf1 := "11100";
    uf  := not uf1;
    uf3 := "00011";
    report_error ("not " & to_string (uf1), uf, uf3);
    uf1 := "HLXUZ";
    uf  := not uf1;
    uf3 := "01XUX";
    report_error ("not " & to_string (uf1), to_slv(uf), to_slv(uf3));
    -- or
    uf1 := "00000";
    uf2 := "00000";
    uf  := uf1 or uf2;
    uf3 := "00000";
    report_error (to_string (uf1) & " or " & to_string (uf2), uf, uf3);
    uf1 := "00001";
    uf2 := "10000";
    uf  := uf1 or uf2;
    uf3 := "10001";
    report_error (to_string (uf1) & " or " & to_string (uf2), uf, uf3);
    uf1 := "10011";
    uf2 := "10010";
    uf  := uf1 or uf2;
    uf3 := "10011";
    report_error (to_string (uf1) & " or " & to_string (uf2), uf, uf3);
    uf1 := "HHLLH";
    uf2 := "HLLLL";
    uf  := uf1 or uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " or " & to_string (uf2), uf, uf3);
    uf1 := "1100X";
    uf2 := "10001";
    uf  := uf1 or uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " or " & to_string (uf2), uf, uf3);
    uf1 := "WXZUL";
    uf2 := "HLUUW";
    uf  := uf1 or uf2;
    uf3 := "1XUUX";
    report_error (to_string (uf1) & " or " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- nor
    uf1 := "00000";
    uf2 := "00000";
    uf  := uf1 nor uf2;
    uf3 := "00000";
    report_error (to_string (uf1) & " nor " & to_string (uf2), uf, not uf3);
    uf1 := "00001";
    uf2 := "10000";
    uf  := uf1 nor uf2;
    uf3 := "10001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), uf, not uf3);
    uf1 := "10011";
    uf2 := "10010";
    uf  := uf1 nor uf2;
    uf3 := "10011";
    report_error (to_string (uf1) & " nor " & to_string (uf2), uf, not uf3);
    uf1 := "HHLLH";
    uf2 := "HLLLL";
    uf  := uf1 nor uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), uf, not uf3);
    uf1 := "11001";
    uf2 := "1000W";
    uf  := uf1 nor uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), uf, not uf3);
    uf1 := "WXZUL";
    uf2 := "HLUZW";
    uf  := uf1 nor uf2;
    uf3 := "1XUUX";
    report_error (to_string (uf1) & " nor " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));

    -- and
    uf1 := "00010";
    uf2 := "01000";
    uf  := uf1 and uf2;
    uf3 := "00000";
    report_error (to_string (uf1) & " and " & to_string (uf2), uf, uf3);
    uf1 := "11010";
    uf2 := "10110";
    uf  := uf1 and uf2;
    uf3 := "10010";
    report_error (to_string (uf1) & " and " & to_string (uf2), uf, uf3);
    uf1 := "LLLHH";
    uf2 := "HLLHH";
    uf  := uf1 and uf2;
    uf3 := "00011";
    report_error (to_string (uf1) & " and " & to_string (uf2), uf, uf3);
    uf1 := "1100Z";
    uf2 := "10000";
    uf  := uf1 and uf2;
    uf3 := "10000";
    report_error (to_string (uf1) & " and " & to_string (uf2), uf, uf3);
    uf1 := "WXZUL";
    uf2 := "HLUZW";
    uf  := uf1 and uf2;
    uf3 := "X0UU0";
    report_error (to_string (uf1) & " and " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- nand
    uf1 := "00010";
    uf2 := "01000";
    uf  := uf1 nand uf2;
    uf3 := "00000";
    report_error (to_string (uf1) & " nand " & to_string (uf2), uf, not uf3);
    uf1 := "11010";
    uf2 := "10110";
    uf  := uf1 nand uf2;
    uf3 := "10010";
    report_error (to_string (uf1) & " nand " & to_string (uf2), uf, not uf3);
    uf1 := "LLLHH";
    uf2 := "HLLHH";
    uf  := uf1 nand uf2;
    uf3 := "00011";
    report_error (to_string (uf1) & " nand " & to_string (uf2), uf, not uf3);
    uf1 := "11000";
    uf2 := "1000U";
    uf  := uf1 nand uf2;
    uf3 := "10000";
    report_error (to_string (uf1) & " nand " & to_string (uf2), uf, not uf3);
    uf1 := "WXZUL";
    uf2 := "HLZUW";
    uf  := uf1 nand uf2;
    uf3 := "X0XU0";
    report_error (to_string (uf1) & " nand " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));
    -- xor
    uf1 := "00010";
    uf2 := "01000";
    uf  := uf1 xor uf2;
    uf3 := "01010";
    report_error (to_string (uf1) & " xor " & to_string (uf2), uf, uf3);
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xor " & to_string (uf2), uf, uf3);
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xor " & to_string (uf2), uf, uf3);
    uf1 := "01111";
    uf2 := "00000";
    uf  := uf1 xor uf2;
    uf3 := "01111";
    report_error (to_string (uf1) & " xor " & to_string (uf2), uf, uf3);
    uf1 := "100H0";
    uf2 := "111H1";
    uf  := uf1 xor uf2;
    uf3 := "01101";
    report_error (to_string (uf1) & " xor " & to_string (uf2), uf, uf3);
    uf1 := "WXUZ0";
    uf2 := "HLUZ0";
    uf  := uf1 xor uf2;
    uf3 := "XXUX0";
    report_error (to_string (uf1) & " xor " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- xnor
    uf1 := "00010";
    uf2 := "01000";
    uf  := uf1 xnor uf2;
    uf3 := "01010";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), uf, not uf3);
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xnor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), uf, not uf3);
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xnor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), uf, not uf3);
    uf1 := "01111";
    uf2 := "00000";
    uf  := uf1 xnor uf2;
    uf3 := "01111";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), uf, not uf3);
    uf1 := "100H0";
    uf2 := "111H1";
    uf  := uf1 xnor uf2;
    uf3 := "01101";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), uf, not uf3);
    uf1 := "WXZU0";
    uf2 := "HL-Z0";
    uf  := uf1 xnor uf2;
    uf3 := "XXXU0";
    report_error (to_string (uf1) & " xnor " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));
    -- signed
    -- not
    sf1 := "11100";
    sf  := not sf1;
    sf3 := "00011";
    report_error ("not " & to_string (sf1), sf, sf3);
    sf1 := "HLXUZ";
    sf  := not sf1;
    sf3 := "01XUX";
    report_error ("not " & to_string (sf1), to_slv(sf), to_slv(sf3));
    -- or
    sf1 := "00000";
    sf2 := "00000";
    sf  := sf1 or sf2;
    sf3 := "00000";
    report_error (to_string (sf1) & " or " & to_string (sf2), sf, sf3);
    sf1 := "00001";
    sf2 := "10000";
    sf  := sf1 or sf2;
    sf3 := "10001";
    report_error (to_string (sf1) & " or " & to_string (sf2), sf, sf3);
    sf1 := "10011";
    sf2 := "10010";
    sf  := sf1 or sf2;
    sf3 := "10011";
    report_error (to_string (sf1) & " or " & to_string (sf2), sf, sf3);
    sf1 := "HHLLH";
    sf2 := "HLLLL";
    sf  := sf1 or sf2;
    sf3 := "11001";
    report_error (to_string (sf1) & " or " & to_string (sf2), sf, sf3);
    sf1 := "1100X";
    sf2 := "10001";
    sf  := sf1 or sf2;
    sf3 := "11001";
    report_error (to_string (sf1) & " or " & to_string (sf2), sf, sf3);
    sf1 := "WXZUL";
    sf2 := "HLUUW";
    sf  := sf1 or sf2;
    sf3 := "1XUUX";
    report_error (to_string (sf1) & " or " & to_string (sf2),
                  to_slv(sf), to_slv(sf3));
    -- nor
    sf1 := "00000";
    sf2 := "00000";
    sf  := sf1 nor sf2;
    sf3 := "00000";
    report_error (to_string (sf1) & " nor " & to_string (sf2), sf, not sf3);
    sf1 := "00001";
    sf2 := "10000";
    sf  := sf1 nor sf2;
    sf3 := "10001";
    report_error (to_string (sf1) & " nor " & to_string (sf2), sf, not sf3);
    sf1 := "10011";
    sf2 := "10010";
    sf  := sf1 nor sf2;
    sf3 := "10011";
    report_error (to_string (sf1) & " nor " & to_string (sf2), sf, not sf3);
    sf1 := "HHLLH";
    sf2 := "HLLLL";
    sf  := sf1 nor sf2;
    sf3 := "11001";
    report_error (to_string (sf1) & " nor " & to_string (sf2), sf, not sf3);
    sf1 := "11001";
    sf2 := "1000W";
    sf  := sf1 nor sf2;
    sf3 := "11001";
    report_error (to_string (sf1) & " nor " & to_string (sf2), sf, not sf3);
    sf1 := "WXZUL";
    sf2 := "HLUZW";
    sf  := sf1 nor sf2;
    sf3 := "1XUUX";
    report_error (to_string (sf1) & " nor " & to_string (sf2),
                  to_slv(sf), to_slv(not sf3));

    -- and
    sf1 := "00010";
    sf2 := "01000";
    sf  := sf1 and sf2;
    sf3 := "00000";
    report_error (to_string (sf1) & " and " & to_string (sf2), sf, sf3);
    sf1 := "11010";
    sf2 := "10110";
    sf  := sf1 and sf2;
    sf3 := "10010";
    report_error (to_string (sf1) & " and " & to_string (sf2), sf, sf3);
    sf1 := "LLLHH";
    sf2 := "HLLHH";
    sf  := sf1 and sf2;
    sf3 := "00011";
    report_error (to_string (sf1) & " and " & to_string (sf2), sf, sf3);
    sf1 := "1100Z";
    sf2 := "10000";
    sf  := sf1 and sf2;
    sf3 := "10000";
    report_error (to_string (sf1) & " and " & to_string (sf2), sf, sf3);
    sf1 := "WXZUL";
    sf2 := "HLUZW";
    sf  := sf1 and sf2;
    sf3 := "X0UU0";
    report_error (to_string (sf1) & " and " & to_string (sf2),
                  to_slv(sf), to_slv(sf3));
    -- nand
    sf1 := "00010";
    sf2 := "01000";
    sf  := sf1 nand sf2;
    sf3 := "00000";
    report_error (to_string (sf1) & " nand " & to_string (sf2), sf, not sf3);
    sf1 := "11010";
    sf2 := "10110";
    sf  := sf1 nand sf2;
    sf3 := "10010";
    report_error (to_string (sf1) & " nand " & to_string (sf2), sf, not sf3);
    sf1 := "LLLHH";
    sf2 := "HLLHH";
    sf  := sf1 nand sf2;
    sf3 := "00011";
    report_error (to_string (sf1) & " nand " & to_string (sf2), sf, not sf3);
    sf1 := "11000";
    sf2 := "1000U";
    sf  := sf1 nand sf2;
    sf3 := "10000";
    report_error (to_string (sf1) & " nand " & to_string (sf2), sf, not sf3);
    sf1 := "WXZUL";
    sf2 := "HLUZW";
    sf  := sf1 nand sf2;
    sf3 := "X0UU0";
    report_error (to_string (sf1) & " nand " & to_string (sf2),
                  to_slv(sf), to_slv(not sf3));
    -- xor
    sf1 := "00010";
    sf2 := "01000";
    sf  := sf1 xor sf2;
    sf3 := "01010";
    report_error (to_string (sf1) & " xor " & to_string (sf2), sf, sf3);
    sf1 := "00011";
    sf2 := "01011";
    sf  := sf1 xor sf2;
    sf3 := "01000";
    report_error (to_string (sf1) & " xor " & to_string (sf2), sf, sf3);
    sf1 := "00011";
    sf2 := "01011";
    sf  := sf1 xor sf2;
    sf3 := "01000";
    report_error (to_string (sf1) & " xor " & to_string (sf2), sf, sf3);
    sf1 := "01111";
    sf2 := "00000";
    sf  := sf1 xor sf2;
    sf3 := "01111";
    report_error (to_string (sf1) & " xor " & to_string (sf2), sf, sf3);
    sf1 := "100H0";
    sf2 := "111H1";
    sf  := sf1 xor sf2;
    sf3 := "01101";
    report_error (to_string (sf1) & " xor " & to_string (sf2), sf, sf3);
    sf1 := "WXZU0";
    sf2 := "HLUZ0";
    sf  := sf1 xor sf2;
    sf3 := "XXUU0";
    report_error (to_string (sf1) & " xor " & to_string (sf2),
                  to_slv(sf), to_slv(sf3));
    -- xnor
    sf1 := "00010";
    sf2 := "01000";
    sf  := sf1 xnor sf2;
    sf3 := "01010";
    report_error (to_string (sf1) & " xnor " & to_string (sf2), sf, not sf3);
    sf1 := "00011";
    sf2 := "01011";
    sf  := sf1 xnor sf2;
    sf3 := "01000";
    report_error (to_string (sf1) & " xnor " & to_string (sf2), sf, not sf3);
    sf1 := "00011";
    sf2 := "01011";
    sf  := sf1 xnor sf2;
    sf3 := "01000";
    report_error (to_string (sf1) & " xnor " & to_string (sf2), sf, not sf3);
    sf1 := "01111";
    sf2 := "00000";
    sf  := sf1 xnor sf2;
    sf3 := "01111";
    report_error (to_string (sf1) & " xnor " & to_string (sf2), sf, not sf3);
    sf1 := "100H0";
    sf2 := "111H1";
    sf  := sf1 xnor sf2;
    sf3 := "01101";
    report_error (to_string (sf1) & " xnor " & to_string (sf2), sf, not sf3);
    sf1 := "WXZU0";
    sf2 := "HL-Z0";
    sf  := sf1 xnor sf2;
    sf3 := "XXXU0";
    report_error (to_string (sf1) & " xnor " & to_string (sf2),
                  to_slv(sf), to_slv(not sf3));
    -- test the std_ulogic_vector translation funcitons
    sulv1 := "00100";
    uf1   := to_ufixed (sulv1, uf1'high, uf1'low);
    uf2   := to_ufixed(1, uf2);
    report_error ("to_ufixed(sulv)", uf1, uf2);
    sulv1 := "00100";
    uf1   := to_ufixed (sulv1, uf1);
    uf2   := to_ufixed(1, uf2);
    report_error ("to_ufixed(sulv)", uf1, uf2);
    uf1   := "10100";
    sulv1 := to_sulv(uf1);
    assert sulv1 = "10100" report "to_sulv(ufixed) error" severity error;
    uf1   := "10010";
    sulv1 := to_stdulogicvector(uf1);
    assert sulv1 = "10010" report "to_stdulogicvector(ufixed) error"
      severity error;
    uf1   := "10001";
    sulv1 := to_std_ulogic_vector(uf1);
    assert sulv1 = "10001" report "to_std_ulogic_vector(ufixed) error"
      severity error;
    sulv1 := "00100";
    sf1   := to_sfixed (sulv1, sf1'high, sf1'low);
    sf2   := to_sfixed(1, sf2);
    report_error ("to_sfixed(sulv)", sf1, sf2);
    sulv1 := "00100";
    sf1   := to_sfixed (sulv1, sf1);
    sf2   := to_sfixed(1, sf2);
    report_error ("to_sfixed(sulv)", sf1, sf2);
    sf1   := "10100";
    sulv1 := to_sulv(sf1);
    assert sulv1 = "10100" report "to_sulv(sfixed) error" severity error;
    sf1   := "10010";
    sulv1 := to_stdulogicvector(sf1);
    assert sulv1 = "10010" report "to_stdulogicvector(sfixed) error"
      severity error;
    sf1   := "10001";
    sulv1 := to_std_ulogic_vector(sf1);
    assert sulv1 = "10001" report "to_std_ulogic_vector(sfixed) error"
      severity error;


    assert (quiet) report "Vector boolean test complete" severity note;
    vecbool_done <= true;
    wait;
  end process vecbool;

  -- purpose: test the "match" function
  matchtest : process is
    variable uf1, uf2  : ufixed (2 downto -2);  -- ufixed
    variable sf1, sf2  : sfixed (2 downto -2);  -- sfixed
    variable uf2x      : ufixed (0 downto -1);  -- odd range
    variable sf2x      : sfixed (0 downto -1);  -- odd range
    variable checkbool : BOOLEAN;
    variable checks    : STD_ULOGIC;
  begin
    wait until start_matchtest;
    uf1 := "00011";
    uf2 := "11100";
    assert (not std_match (uf1, uf2))
      report "std_match (" & to_string(uf1) & ", " & to_string(uf2) & ") returned true."
      severity error;
    uf1 := "00011";
    uf2 := "00011";
    assert (std_match (uf1, uf2))
      report "std_match (" & to_string(uf1) & ", " & to_string(uf2) & ") returned false."
      severity error;
    uf1 := "00011";
    uf2 := "X0011";
    assert not (std_match (uf1, uf2))
      report "std_match (" & to_string(uf1) & ", " & to_string(uf2) & ") returned true."
      severity error;
    uf1 := "-0011";
    uf2 := "X0011";
    assert (std_match (uf1, uf2))
      report "std_match (" & to_string(uf1) & ", " & to_string(uf2) & ") returned false."
      severity error;
    uf1 := "-----";
    uf2 := "XWZU-";
    assert (std_match (uf1, uf2))
      report "std_match (" & to_string(uf1) & ", " & to_string(uf2) & ") returned false."
      severity error;
    uf1 := "X----";
    uf2 := "XWZU-";
    assert not (std_match (uf1, uf2))
      report "std_match (" & to_string(uf1) & ", " & to_string(uf2) & ") returned true."
      severity error;
    if (not quiet) then
      -- Odd range, should always return false and a warning
      report "Expect 2 std_match length errors here" severity note;
      uf1  := "00000";
      uf2x := "00";
      assert not (std_match (uf1, uf2x))
        report "std_match (" & to_string (uf1) & ", " & to_string (uf2x) & ") returned true."
        severity error;
      uf1  := "-----";
      uf2x := "--";
      assert not (std_match (uf1, uf2x))
        report "std_match (" & to_string (uf1) & ", " & to_string (uf2x) & ") returned true."
        severity error;
    end if;
    sf1 := "00011";
    sf2 := "11100";
    assert (not std_match (sf1, sf2))
      report "std_match (" & to_string (sf1) & ", " & to_string (sf2) & ") returned true."
      severity error;
    sf1 := "00011";
    sf2 := "00011";
    assert (std_match (sf1, sf2))
      report "std_match (" & to_string (sf1) & ", " & to_string (sf2) & ") returned false."
      severity error;
    sf1 := "00011";
    sf2 := "X0011";
    assert not (std_match (sf1, sf2))
      report "std_match (" & to_string (sf1) & ", " & to_string (sf2) & ") returned true."
      severity error;
    sf1 := "-0011";
    sf2 := "X0011";
    assert (std_match (sf1, sf2))
      report "std_match (" & to_string (sf1) & ", " & to_string (sf2) & ") returned false."
      severity error;
    sf1 := "-----";
    sf2 := "XWZU-";
    assert (std_match (sf1, sf2))
      report "std_match (" & to_string (sf1) & ", " & to_string (sf2) & ") returned false."
      severity error;
    sf1 := "X----";
    sf2 := "XWZU-";
    assert not (std_match (sf1, sf2))
      report "std_match (" & to_string (sf1) & ", " & to_string (sf2) & ") returned true."
      severity error;
    if (not quiet) then
      -- Odd range, should always return false and a warning
      report "Expect 2 std_match length errors here" severity note;
      sf1  := "00000";
      sf2x := "00";
      assert not (std_match (sf1, sf2x))
        report "std_match (" & to_string (sf1) & ", " & to_string (sf2x) & ") returned true."
        severity error;
      sf1  := "-----";
      sf2x := "--";
      assert not (std_match (sf1, sf2x))
        report "std_match (" & to_string (sf1) & ", " & to_string (sf2x) & ") returned true."
        severity error;
    end if;
    uf1    := "00011";
    uf2    := "11100";
    checks := uf1 ?= uf2;
    assert (checks = '0')
      report to_string (uf1) & " ?= " & to_string (uf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    uf1    := "00011";
    uf2    := "00011";
    checks := uf1 ?= uf2;
    assert (checks = '1')
      report to_string (uf1) & " ?= " & to_string (uf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    uf1    := "00011";
    uf2    := "X0011";
    checks := uf1 ?= uf2;
    assert (checks = 'X')
      report to_string (uf1) & " ?= " & to_string (uf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    uf1    := "-0011";
    uf2    := "X0011";
    checks := uf1 ?= uf2;
    assert (checks = '1')
      report to_string (uf1) & " ?= " & to_string (uf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    uf1    := "-----";
    uf2    := "XWZU-";
    checks := uf1 ?= uf2;
    assert (checks = '1')
      report to_string (uf1) & " ?= " & to_string (uf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    uf1    := "X----";
    uf2    := "XWZU-";
    checks := uf1 ?= uf2;
    assert (checks = 'X')
      report to_string (uf1) & " ?= " & to_string (uf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;

    uf1    := "00000";
    uf2x   := "00";
    checks := uf1 ?= uf2x;
    assert (checks = '1')
      report to_string (uf1) & " ?= " & to_string (uf2x) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    uf1    := "-----";
    uf2x   := "--";
    checks := uf1 ?= uf2x;
    assert (checks = '1')
      report to_string (uf1) & " ?= " & to_string (uf2x) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "00011";
    sf2    := "11100";
    checks := sf1 ?= sf2;
    assert (checks = '0')
      report to_string (sf1) & " ?= " & to_string (sf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "00011";
    sf2    := "00011";
    checks := sf1 ?= sf2;
    assert (checks = '1')
      report to_string (sf1) & " ?= " & to_string (sf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "00011";
    sf2    := "X0011";
    checks := sf1 ?= sf2;
    assert (checks = 'X')
      report to_string (sf1) & " ?= " & to_string (sf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "-0011";
    sf2    := "X0011";
    checks := sf1 ?= sf2;
    assert (checks = '1')
      report to_string (sf1) & " ?= " & to_string (sf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "-----";
    sf2    := "XWZU-";
    checks := sf1 ?= sf2;
    assert (checks = '1')
      report to_string (sf1) & " ?= " & to_string (sf2) & " returned "
      severity error;
    sf1    := "X----";
    sf2    := "XWZU-";
    checks := sf1 ?= sf2;
    assert (checks = 'X')
      report to_string (sf1) & " ?= " & to_string (sf2) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "00000";
    sf2x   := "00";
    checks := sf1 ?= sf2x;
    assert (checks = '1')
      report to_string (sf1) & " ?= " & to_string (sf2x) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    sf1    := "-----";
    sf2x   := "--";
    checks := sf1 ?= sf2x;
    assert (checks = '1')
      report to_string (sf1) & " ?= " & to_string (sf2x) & " returned "
      & STD_ULOGIC'image(checks)
      severity error;
    assert (quiet) report "match ?= test done" severity note;
    matchtest_done <= true;
    wait;
  end process matchtest;
end architecture testbench;
