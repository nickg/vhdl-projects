-- Test vectors for the fixed point math package
-- This is a comprehensive test for the fixed point math packages.
-- Created for vhdl-200x by David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
--   modification history : Last Modified $Date: 2007/09/26 18:05:58 $
--   Version $Id: test_fixed.vhdl,v 1.10 2007/09/26 18:05:58 l435385 Exp $
-- --------------------------------------------------------------------

entity test_fixed is
  generic (
    quiet : BOOLEAN := false);          -- make the simulation quiet
end entity test_fixed;

use std.textio.all;
library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

architecture testbench of test_fixed is

  constant debug : BOOLEAN := false;    -- debug mode, prints out lots of data
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

  -- purpose: reports an error
  -- Needed to compare strings with meta values in them.
  procedure report_error (
    constant errmes   :    STRING;               -- error message
    actual            : in STD_LOGIC_VECTOR;     -- data from algorithm
    constant expected :    STD_LOGIC_VECTOR) is  -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(to_ufixed(unsigned(actual))) & LF
      & "     /= " & to_string(to_ufixed(unsigned(expected)))
      severity error;
    return;
  end procedure report_error;

--  -- purpose: converts an unsigned fixed point to a signed fixed point
--    function to_ufixed (
--      arg : sfixed)
--      return ufixed is
--      variable argabs : sfixed (arg'high + 1 downto arg'low);
--      variable result : ufixed (arg'range);
--    begin
--      argabs := abs (arg);
--      result := ufixed (argabs (arg'range));
--      return result;
--    end function to_ufixed;

  subtype ufixed7_3 is ufixed (3 downto -3);   -- 7 bit
  subtype ufixed16_8 is ufixed (7 downto -8);  -- 16 bit
  subtype sfixed7_3 is sfixed (3 downto -3);   -- 7 bit
  subtype sfixed8_3 is sfixed (4 downto -3);   -- 8 bit
  subtype sfixed16_8 is sfixed (7 downto -8);  -- 16 bit
  signal start_basetest, basetest_done             : BOOLEAN := false;  -- basic test
  signal start_readtest, readtest_done             : BOOLEAN := false;  -- start reading test
  signal start_comptest, comptest_done             : BOOLEAN := false;  -- start reading test
  signal start_endiantest, endiantest_done         : BOOLEAN := false;  -- start reading test
  signal start_smalltest, smalltest_done           : BOOLEAN := false;  -- start reading test
  signal start_oddrangetest, oddrangetest_done     : BOOLEAN := false;  -- start reading test
  signal start_mconvtest, mconvtest_done           : BOOLEAN := false;  -- .M convert test
  signal start_metanumbertest, metanumbertest_done : BOOLEAN := false;
  signal start_literaltest, literaltest_done       : BOOLEAN := false;  -- string literals


begin  -- architecture testbench

  -- purpose: Main test process
  tester : process is

  begin  -- process tester

    ---------------------------------------------------------------------------
    -- Basic test
    ---------------------------------------------------------------------------
    start_basetest <= true;
    wait until basetest_done;

    ---------------------------------------------------------------------------
    -- Perform the compare test
    ---------------------------------------------------------------------------
    start_comptest <= true;
    wait until comptest_done;
    ---------------------------------------------------------------------------
    -- Perform the read test
    ---------------------------------------------------------------------------
    start_readtest <= true;
    wait until readtest_done;

    ---------------------------------------------------------------------------
    -- Perform meta number test
    ---------------------------------------------------------------------------
    start_metanumbertest <= true;
    wait until metanumbertest_done;
    start_mconvtest      <= true;
    wait until mconvtest_done;

    ---------------------------------------------------------------------------
    -- Run the little endian test
    -- Per discussion on 7/12/2004 Little Endian numbers are made illegal.
    ---------------------------------------------------------------------------
    start_endiantest <= true;
    wait until endiantest_done;

    ---------------------------------------------------------------------------
    -- Small number test
    ---------------------------------------------------------------------------
    start_smalltest <= true;
    wait until smalltest_done;

    ---------------------------------------------------------------------------
    -- Odd range test, testing all positive and all negative ranges.
    ---------------------------------------------------------------------------
    start_oddrangetest <= true;
    wait until oddrangetest_done;

    ---------------------------------------------------------------------------
    -- Start the string literal test
    ---------------------------------------------------------------------------
    start_literaltest <= true;
    wait until literaltest_done;

    report "Fixed point package testing part 1 complete";
    wait;

  end process tester;

  -- purpose: Basic test for the fixed point package
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  basictest : process is
    variable checkint                          : INTEGER;
    variable checkreal                         : REAL;
    variable checkuns                          : UNSIGNED (7 downto 0);
    variable check7uf1, check7uf2              : ufixed7_3;
    variable check7uf, check7uft               : ufixed (4 downto -3);  -- ufixed7_3+ufixed7_3
    variable mulres, mulrest                   : ufixed (7 downto -6);  -- ufixed7_3*ufixed7_3
    variable divres, divrest                   : ufixed (6 downto -7);  -- ufixed7_3/ufixed7_3
    variable rdivres                           : ufixed(3 downto -4);  -- 1/ufixed7_3
    variable divres2                           : ufixed (10 downto -12);  -- ufixed16_8/ufixed7_3
    variable divres2x                          : ufixed (11 downto -11);  -- ufixed7_3/ufixed16_8
    variable divres3                           : ufixed (15 downto -16);  -- ufixed16_8/ufixed16_8
    variable rdivres3                          : ufixed (8 downto -8);  -- 1/ufixed16_8
    variable modres3                           : ufixed (3 downto -8);  -- ufixed7_3 mod fuixed16_8
    variable checksns                          : SIGNED (7 downto 0);
    variable check7sf1, check7sf2              : sfixed7_3;
    variable check7sf, check7sft               : sfixed (4 downto -3);  -- sfixed7_3+sfixed7_3
    variable smulres, smulrest                 : sfixed (7 downto -6);  -- sfixed7_3*sfixed7_3
    variable sdivres, sdivrest                 : sfixed (7 downto -6);  -- sfixed7_3/sfixed7_3
    variable rsdivres                          : sfixed (4 downto -3);  -- 1/sfixed7_3
    variable smodres3                          : sfixed (3 downto -8);  -- sfixed7_3 rem sfixed16_8
    variable sdivres2                          : sfixed (11 downto -11);  -- sfixed16_8/sfixed7_3
    variable sdivres2x                         : sfixed (12 downto -10);  -- sfixed7_3/sfixed16_8
    variable sdivres3                          : sfixed (16 downto -15);  -- sfixed16_8/sfixed16_8
    variable rsdivres3                         : sfixed (9 downto -7);  -- 1/sfixed16_8
    variable check16uf, check16uf1, check16uf2 : ufixed16_8;
    variable check16sf, check16sf1, check16sf2 : sfixed16_8;
    variable addcheck16                        : sfixed (8 downto -8);  -- sfixed16_8 + sfixed16_8
    variable checkx1, checkx2                  : ufixed (5 downto -13);
  begin  -- process basictest
    wait until start_basetest;
    -- conversion test
    checkint               := 0;
    check7uf1              := to_ufixed (checkint, ufixed7_3'high, ufixed7_3'low);
    check7uf2              := "0000000";               -- 0
    report_error ("0 miscompare", check7uf1, check7uf2);
    checkint               := 3;
    check7uf1              := to_ufixed (checkint, ufixed7_3'high, ufixed7_3'low);
    check7uf2              := "0011000";               -- 3
    report_error ("3 miscompare", check7uf1, check7uf2);
    checkuns               := "00000011";
    check7uf2              := "0011000";               -- 3
    check7uf1              := to_ufixed (checkuns, ufixed7_3'high, ufixed7_3'low);
    report_error ("3 unsigned miscompare", check7uf1, check7uf2);
    checkuns               := "00000101";
    check16uf              := (others => '0');
    check16uf (7 downto 0) := ufixed(checkuns);
    assert check16uf = to_ufixed(checkuns)
      report "unsigned casted to ufixed problem "
      & to_string (check16uf) & " /= 5" severity error;
    checkuns  := "00000100";
    check16uf := to_ufixed (checkuns, check16uf'high, check16uf'low);
    assert check16uf = to_ufixed(checkuns)
      report "unsigned conversion to ufixed problem "
      & to_string (check16uf) & " /= 4" severity error;
    checkreal := 0.0;
    check7uf1 := to_ufixed (checkreal, ufixed7_3'high, ufixed7_3'low);
    check7uf2 := "0000000";             -- 0
    report_error ("0.0 miscompare", check7uf1, check7uf2);
    checkreal := 6.5;
    check7uf1 := to_ufixed (checkreal, ufixed7_3'high, ufixed7_3'low);
    check7uf2 := "0110100";
    report_error ("6.5 miscompare", check7uf1, check7uf2);
    checkreal := to_real (check7uf2);   -- 6.5
    assert (checkreal = 6.5) report "to_real 6.5 miscompare";
    check7uf2 := "0011000";
    checkint  := to_integer (check7uf2);
    assert (checkint = 3) report "to_integer 3 miscompare";
    checkuns  := to_unsigned (check7uf2, checkuns'high+1);
    assert (checkuns = "00000011") report "to_unsigned 3 miscompare";
    -- Boundary test
    if (not quiet) then
      checkint  := 16;                  -- too big.
      report "Expect to_ufixed(integer) overflow error" severity note;
      check7uf1 := to_ufixed (checkint, check7uf1'high, check7uf1'low);
      check7uf2 := (others => '1');
      report_error ("16 to ufixed overflow", check7uf1, check7uf2);
    end if;
    checkint  := 15;
    check7uf1 := to_ufixed (checkint, check7uf1'high, check7uf1'low);
    check7uf2 := "1111000";
    report_error ("15 to ufixed overflow", check7uf1, check7uf2);
    if (not quiet) then
      checkreal := 16.0;                -- too big.
      report "Expect to_ufixed(real) overflow error" severity note;
      check7uf1 := to_ufixed (checkreal, check7uf1'high, check7uf1'low);
      check7uf2 := (others => '1');
      report_error ("16.0 to ufixed overflow", check7uf1, check7uf2);
    end if;
    checkreal := 15.875;                -- largest possible
    check7uf1 := to_ufixed (checkreal, check7uf1'high, check7uf1'low);
    check7uf2 := (others => '1');
    report_error ("15.875 to ufixed overflow", check7uf1, check7uf2);
    checkreal := 0.0625;                -- too small
    check7uf1 := to_ufixed (checkreal, check7uf1'high, check7uf1'low);
    check7uf2 := (others => '0');
    report_error (".0625 to ufixed underflow", check7uf1, check7uf2);
    checkreal := 0.125;                 -- smallest possible
    check7uf1 := to_ufixed (checkreal, check7uf1'high, check7uf1'low);
    check7uf2 := "0000001";
    report_error (".125 to ufixed underflow", check7uf1, check7uf2);
    -- Math test
    check7uf1 := "0011000";             -- 3
    check7uf2 := "0110100";             -- 6.5
    check7uf  := check7uf1 + check7uf2;
    check7uft := to_ufixed (3.0+6.5, check7uft'high, check7uft'low);
    report_error ("3 + 6.5 miscompare", check7uf, check7uft);
    -- Boundary test
    check7uf1 := "1111111";             -- 15.875
    check7uf  := check7uf1 + check7uf1;
    check7uft := "11111110";
    report_error ("15.875+15.875", check7uf, check7uft);
    check7uf2 := "0110100";             -- 6.5
    check7uf1 := "0011000";             -- 3
    check7uf  := check7uf2 - check7uf1;
    check7uf2 := to_ufixed (3.5, ufixed7_3'high, ufixed7_3'low);
    report_error ("6.5 - 3.0 miscompare", check7uf, check7uf2);
    check7uf2 := "0110100";             -- 6.5
    check7uf1 := "0011000";             -- 3
    -- What happens when we need a negative result in an unsigned subtract?
    check7uf  := check7uf1 - check7uf2;
    mulres    := "00011100100000";
    report_error ("3.0 - 6.5 miscompare", check7uf,
                  resize(mulres, check7uf'high, check7uf'low));  -- 28.5 (overflow);
    check7uf2 := "0110100";             -- 6.5
    check7uf1 := "0010000";             -- 2.0
    mulres    := check7uf1 * check7uf2;
    mulrest   := "00001101000000";
    report_error ("2 * 6.5 miscompare", mulres, mulrest);
    check7uf2 := "0110100";             -- 6.5
    mulres    := check7uf2 * check7uf2;
    mulrest   := "00101010010000";      -- 42.25
    report_error ("6.5 * 6.5 miscompare", mulres, mulrest);
    -- boundary multiply test
    check7uf2 := "1000000";             -- 8
    mulres    := check7uf2 * check7uf2;
    mulrest   := "01000000000000";      -- 64
    report_error ("8 * 8 miscompare", mulres, mulrest);
    check7uf2 := "1111111";             -- 15.875
    mulres    := check7uf2 * check7uf2;                -- 252.015625
    mulrest   := "11111100000001";
    report_error ("15.875 * 15.875 miscompare", mulres,
                  mulrest);
    check7uf2 := "0000001";             -- .125
    mulres    := check7uf2 * check7uf2;                -- 0.015625
    mulrest   := "00000000000001";
    report_error ("0.125 * 0.125 miscompare", mulres,
                  mulrest);
    -- division test
    check7uf2  := "0110100";            -- 6.5
    check7uf1  := "0010000";            -- 2.0
    divres     := check7uf2 / check7uf1;
    check7uf2  := "0011010";
    report_error ("6.5 / 2.0 miscompare", divres, check7uf2);
    check16uf1 := "0000110100000000";   -- 13
    check7uf1  := "0010000";            -- 2.0
    divres2    := check16uf1 / check7uf1;
    check16uf1 := "0000011010000000";   -- 6.5
    report_error ("long 13.0 / 2.0 miscompare", divres2, check16uf1);
    check7uf2  := "0110100";            -- 6.5
    divres     := check7uf2 / check7uf2;
    check7uf1  := "0001000";
    report_error ("6.5 / 6.5 miscompare", divres, check7uf1);
    check16uf1 := "0000000100000000";   -- 1
    check7uf2  := "0011000";            -- 3
    divres2    := check16uf1 / check7uf2;
    divres3    := "00000000000000000101010101010000";  -- 1/3 to divres2 precision
    report_error ("1/3 miscompare", divres2, divres3);
    check16uf1 := "0000001100000000";   -- 3
    assert (check16uf1 = 3) report "it's not 3" severity error;
    check7uf2  := "0001000";            -- 1
    assert (check7uf2 = 1) report "It's not 1" severity error;
    divres2x   := check7uf2 / check16uf1;
    divres3 := resize(to_ufixed(1.0/3.0, divres2x'high, divres2x'low),
                      divres3'high, divres3'low);
    report_error ("1/3+ miscompare", divres2x, divres3);
    check7uf2 := "1000000";             -- 8
    check7uf1 := "0000001";             -- 0.125
    divres    := check7uf2 / check7uf1;
    report_error ("8/0.125 miscompare", divres,
                  to_ufixed(8.0/0.125, divres2'high, divres2'low));
    check7uf2 := "1111111";             -- 15.875
    check7uf1 := "0000001";             -- 0.125
    divres    := check7uf2 / check7uf1;
    report_error ("15.875/0.125 miscompare", divres,
                  to_ufixed(15.875/0.125, divres2'high, divres2'low));
    check7uf2 := "1000000";             -- 8
    check7uf1 := "0000001";             -- 0.125
    divres    := check7uf1 / check7uf2;
    report_error ("0.125/8 miscompare", divres,
                  to_ufixed(0.125/8.0, divres2'high, divres2'low));
    -- Boundary test
    check7uf2 := "1111111";             -- 15.875
    check7uf1 := "0000001";             -- 0.125
    divres    := check7uf1 / check7uf2;
    divrest   := "00000000000001";      -- .0078125
    report_error ("0.125/15.875 miscompare", divres,
                  divrest);
    divrest := divide (check7uf1, check7uf2);
    report_error ("divide (0.125,15.875) miscompare", divres,
                  divrest);
    divres  := check7uf2 / check7uf1;
    divrest := "11111110000000";        -- 127
    report_error ("15.875/0.125 miscompare", divres,
                  divrest);
    divrest := divide (check7uf2, check7uf1);
    report_error ("divide (15.875,0.125) miscompare", divres,
                  divrest);
    -- 1 over X test cases
    check7uf1  := "0010000";            -- 2.0
    rdivres    := reciprocal (check7uf1);
    check7uf2  := "0000100";            -- 0.5
    report_error ("1/2 1/x miscompare", rdivres, check7uf2);
    check16uf1 := "0000001100000000";   -- 3
    rdivres3   := reciprocal (check16uf1);
    report_error ("1/3 1/x miscompare", rdivres3,
                  to_ufixed (1.0/3.0, rdivres3'high, rdivres3'low));
    check7uf1  := "0000100";            -- 0.5
    rdivres    := reciprocal (check7uf1);
    check7uf2  := "0010000";            -- 2.0
    report_error ("1/0.5 1/x miscompare", rdivres, check7uf2);
    -- boundary test
    check7uf1  := "0000001";            -- 0.125
    rdivres    := reciprocal (check7uf1);
    divrest    := "00010000000000";
    report_error ("1/0.125", rdivres, divrest);
    check7uf1  := "1111111";            -- 15.875
    rdivres    := reciprocal (check7uf1);
    divrest    := "00000000001000";     -- 0.0625
    report_error ("1/15.875", rdivres, divrest);
    check16uf1 := to_ufixed (6, check16uf1'high, check16uf1'low);
    rdivres3   := reciprocal (check16uf1);
    report_error ("1/6 1/x miscompare", rdivres3,
                  to_ufixed (1.0/6.0, rdivres3'high, rdivres3'low));
    check16uf1 := to_ufixed (20, check16uf1'high, check16uf1'low);
    rdivres3   := reciprocal (check16uf1);
    report_error ("1/20 1/x miscompare", rdivres3,
                  to_ufixed (1.0/20.0, rdivres3'high, rdivres3'low));
    check16uf1 := to_ufixed (42, check16uf1'high, check16uf1'low);
    rdivres3   := reciprocal (check16uf1);
    report_error ("1/42 1/x miscompare", rdivres3,
                  to_ufixed (1.0/42.0, rdivres3'high, rdivres3'low));
    checkx1 := to_ufixed (6*7, checkx1'high, checkx1'low);
    checkx1 := resize (reciprocal(checkx1),
                       checkx1'high, checkx1'low);
    checkx2 := resize (to_ufixed (1.0/42.0, -checkx1'low, -checkx1'high-1),
                       checkx2);
    report_error ("1/42 1/x mant miscompage", checkx1, checkx2);
    checkx1                         := to_ufixed (1.0/42.0, checkx1'high, checkx1'low);
    checkx1                         := resize (reciprocal(checkx1), checkx1'high, checkx1'low);
    checkx1 (-5 downto checkx1'low) := (others => '0');  -- toss the lower bits
    checkx2                         := to_ufixed (42, checkx2'high, checkx2'low);
    report_error ("42 1/x mant miscompare", checkx1, checkx2);
    check16uf1                      := "1000000000000000";      -- 128
    rdivres3                        := reciprocal (check16uf1);
    report_error ("1/128 1/x miscompare", rdivres3,
                  to_ufixed (1.0/128.0, divres3'high, divres3'low));
    check16uf1 := to_ufixed (1, check16uf1'high, check16uf1'low);
    check16uf2 := "1000000000000000";   -- 128
    divres3    := check16uf1 / check16uf2;
    check16uf2 := "0000000000000010";   -- 1/128
    report_error ("1/65 miscompage", divres3, check16uf2);
    check7uf1  := "0011000";            -- 3.0
    rdivres    := reciprocal (check7uf1);
    report_error ("reciprocal 3", rdivres,
                  to_ufixed (1.0/3.0, rdivres'high, rdivres'low));
    rdivres := reciprocal (arg         => check7uf1,
                           guard_bits  => fixed_guard_bits,     -- default
                           round_style => fixed_truncate);      -- do not round
    report_error ("reciprocal test, no round", rdivres,
                  to_ufixed (arg            => 1.0/3.0,
                             left_index     => rdivres'high,
                             right_index    => rdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    rdivres := reciprocal (arg         => check7uf1,
                           guard_bits  => 0,           -- no guard bits
                           round_style => fixed_round);
    report_error ("reciprocal test, no guard", rdivres,
                  to_ufixed (arg            => 1.0/3.0,
                             left_index     => rdivres'high,
                             right_index    => rdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    check7uf2 := "0001000";             -- 1.0
    check7uf1 := "0011000";             -- 3.0
    divres    := divide (check7uf2, check7uf1);
    report_error ("divide test", divres,
                  to_ufixed (1.0/3.0, divres'high, divres'low));
    divres := divide (l           => check7uf2,
                      r           => check7uf1,
                      guard_bits  => fixed_guard_bits,   -- default
                      round_style => fixed_truncate);  -- do not round
    report_error ("divide test, no round", divres,
                  to_ufixed (arg            => 1.0/3.0,
                             left_index     => divres'high,
                             right_index    => divres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    divres := divide (l           => check7uf2,
                      r           => check7uf1,
                      guard_bits  => 0,                -- no guard bits
                      round_style => fixed_round);
    report_error ("divide test, no guard", divres,
                  to_ufixed (arg            => 1.0/3.0,
                             left_index     => divres'high,
                             right_index    => divres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    -- scalb test
    check7uf2  := "0110100";
    check7uf1  := check7uf2 sla 0;
    check7uf2  := "0110100";
    report_error ("Scalb 0", check7uf1, check7uf2);
    check7uf2  := "0110100";
    check7uf1  := check7uf2 sla 1;
    check7uf2  := "1101000";
    report_error ("Scalb +1", check7uf1, check7uf2);
    check7uf2  := "0110100";
    check7uf1  := check7uf2 sla -1;
    check7uf2  := "0011010";
    report_error ("Scalb -1", check7uf1, check7uf2);
    check7uf2  := "0110100";
    check7uf1  := check7uf2 sla -2;
    check7uf2  := "0001101";
    report_error ("Scalb -2", check7uf1, check7uf2);
    check7uf2  := "0110100";
    checksns   := to_signed (0, checksns'length);
    check7uf1  := check7uf2 sla to_integer(checksns);
    check7uf2  := "0110100";
    report_error ("Scalb signed 0", check7uf1, check7uf2);
    check7uf2  := "0110100";
    checksns   := to_signed (1, checksns'length);
    check7uf1  := check7uf2 sla to_integer(checksns);
    check7uf2  := "1101000";
    report_error ("Scalb SIGNED +1", check7uf1, check7uf2);
    check7uf2  := "0110100";
    checksns   := to_signed (-1, checksns'length);
    check7uf1  := check7uf2 sla to_integer(checksns);
    check7uf2  := "0011010";
    report_error ("Scalb SIGNED -1", check7uf1, check7uf2);
    check7uf2  := "0110100";
    checksns   := to_signed (-2, checksns'length);
    check7uf1  := check7uf2 sla to_integer(checksns);
    check7uf2  := "0001101";
    report_error ("Scalb SIGNED -2", check7uf1, check7uf2);
    -- test remainder function
    check7uf2  := "0110100";            -- 6.5
    check7uf1  := "0010000";            -- 2.0
    check7uf1  := check7uf2 rem check7uf1;
    check7uf2  := "0000100";
    report_error ("6.5 rem 2.0 miscompare", check7uf1, check7uf2);
    check16uf1 := "0000011010000000";   -- 6.5
    check7uf1  := "0010000";            -- 2.0
    modres3    := check16uf1 rem check7uf1;
    check7uf2  := "0000100";
    report_error ("long 6.5 rem 2.0 miscompare", modres3, check7uf2);
    check7uf2  := "0110100";            -- 6.5
    check7uf2  := check7uf2 rem check7uf2;
    check7uf1  := "0000000";
    report_error ("6.5 rem 6.5 miscompare", check7uf1, check7uf2);
    check16uf1 := "0000000100000000";   -- 1
    check7uf2  := "0011000";            -- 3
    modres3    := check16uf1 rem check7uf2;
    check7uf2  := "0001000";            -- 1
    report_error ("1 rem 3 miscompare", modres3, check7uf2);
    -- test modulo function
    check7uf2  := "0110100";            -- 6.5
    check7uf1  := "0010000";            -- 2.0
    check7uf1  := check7uf2 mod check7uf1;
    check7uf2  := "0000100";            -- 0.5
    report_error ("6.5 mod 2.0 miscompare", check7uf1, check7uf2);
    check16uf1 := "0000011010000000";   -- 6.5
    check7uf1  := "0010000";            -- 2.0
    modres3    := check16uf1 mod check7uf1;
    check16uf2 := "0000000010000000";   -- 0.5
    report_error ("long 6.5 mod 2.0 miscompare", modres3, check16uf2);
    check7uf2  := "0110100";            -- 6.5
    check7uf2  := check7uf2 mod check7uf2;
    check7uf1  := "0000000";            -- 1
    report_error ("6.5 mod 6.5 miscompare", check7uf1, check7uf2);
    check16uf1 := "0000000100000000";   -- 1
    check7uf2  := "0011000";            -- 3
    modres3    := check16uf1 mod check7uf2;
    check16uf2 := "0000000100000000";   -- 1
    report_error ("1 mod 3 miscompare", modres3, check16uf2);

    -- conversion test, signed number
    checkint               := 3;
    check7sf1              := to_sfixed (checkint, sfixed7_3'high, sfixed7_3'low);
    check7sf2              := "0011000";
    report_error ("signed 3 miscompare", check7sf1, check7sf2);
    checkreal              := 6.5;
    check7sf1              := to_sfixed (checkreal, sfixed7_3'high, sfixed7_3'low);
    check7sf2              := "0110100";
    report_error ("signed 6.5 miscompare", check7sf1, check7sf2);
    checksns               := "00000011";
    check7sf1              := to_sfixed (checksns, sfixed7_3'high, sfixed7_3'low);
    check7sf2              := "0011000";
    report_error ("3 signed miscompare", check7sf1, check7sf2);
    checksns               := "00000101";
    check16sf              := (others => '0');
    check16sf (7 downto 0) := sfixed(checksns);
    assert check16sf = to_sfixed(checksns)
      report "signed casted to sfixed problem "
      & to_string (check16sf) & " /= 4" severity error;
    checksns  := "11111101";
    check16sf := to_sfixed (checksns, check16sf'high, check16sf'low);
    assert check16sf = to_sfixed(checksns)
      report "signed conversion to sfixed problem "
      & to_string (check16sf) & " /= -3" severity error;
    check7sf2 := "0110100";
    checkreal := to_real (check7sf2);   -- 6.5
    assert (checkreal = 6.5) report "to_real 6.5 miscompare "
      & REAL'image(checkreal);
    check7sf2 := "0011000";
    checkint  := to_integer (check7sf2);
    assert (checkint = 3) report "to_integer 3 miscompare "
      & INTEGER'image(checkint);
    checksns  := to_signed (check7sf2, checksns'high+1);
    assert (checksns = "00000011") report "to_signed 3 miscompare";
    check7uf1 := "1111111";
    check7sf  := to_sfixed (check7uf1);
    smulres   := "00001111111000";
    report_error ("ufixed to sfixed ", check7sf, smulres);
--    check7sf1 := "0111111";
--    check7uf1 := to_ufixed (check7sf1);
--    check7uf2 := "0111111";
--    report_error ("sfixed to ufixed ", check7uf1, check7uf2);
--    check7sf1 := "1111111";             -- -1
--    check7uf1 := to_ufixed (check7sf1);
--    check7uf2 := "0000001";
--    report_error ("-sfixed to ufixed", check7uf1, check7uf2);
--    check7sf1 := "1000000";             -- -8
--    check7uf1 := to_ufixed (check7sf1);
--    check7uf2 := "1000000";             -- 8
--    report_error ("max - sfixed to ufixed", check7uf1, check7uf2);
    -- Boundary test
    if (not quiet) then
      checkint  := 8;                   -- too big.
      report "Expect to_sfixed(integer) overflow error" severity note;
      check7sf1 := to_sfixed (checkint, check7sf1'high, check7sf1'low);
      check7sf2 := "0111111";           -- Maximum
      report_error ("8 to sfixed overflow", check7sf1, check7sf2);
    end if;
    checkint  := 7;                     -- max integer;
    check7sf1 := to_sfixed (checkint, check7sf1'high, check7sf1'low);
    check7sf2 := "0111000";             -- 7
    report_error ("7 to sfixed overflow", check7sf1, check7sf2);
    if (not quiet) then
      checkreal := 8.0;                 -- too big.
      report "Expect to_sfixed(real) overflow error" severity note;
      check7sf1 := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
      check7sf2 := "0111111";           -- Maximum
      report_error ("8.0 to sfixed overflow", check7sf1, check7sf2);
    end if;
    checkreal := 7.875;                 -- maximum.
    check7sf1 := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2 := "0111111";             -- Maximum
    report_error ("7.875 to sfixed ", check7sf1, check7sf2);
    checkreal := 0.0625;                -- too small
    check7sf1 := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2 := (others => '0');
    report_error (".0625 to sfixed underflow", check7sf1, check7sf2);
    check7sf1 := "1000000";
    checkint  := to_integer (check7sf1);
    assert (checkint = -8)
      report "conversion signed to_integer(" & to_string (check7sf1)
      & ") = " & INTEGER'image(checkint) & " should be -8"
      severity error;
    check7sf1 := "1111111";
    checkreal := to_real (check7sf1);
    assert (checkreal = -0.125)
      report "conversion signed to_real(" & to_string (check7sf1)
      & ") = " & REAL'image(checkreal) & " should be -0.125"
      severity error;
    check7sf1 := "1111110";
    checkreal := to_real (check7sf1);
    assert (checkreal = -0.25)
      report "conversion signed to_real(" & to_string (check7sf1)
      & ") = " & REAL'image(checkreal) & " should be -0.25"
      severity error;
    check7sf1 := "1000001";
    checkreal := to_real (check7sf1);
    assert (checkreal = -7.875)
      report "conversion signed to_real(" & to_string (check7sf1)
      & ") = " & REAL'image(checkreal) & " should be -7.875"
      severity error;
    check7sf1 := "1111101";
    checkreal := to_real (check7sf1);
    assert (checkreal = -0.375)
      report "conversion signed to_real(" & to_string (check7sf1)
      & ") = " & REAL'image(checkreal) & " should be -0.375"
      severity error;
    if (not quiet) then
      checkint  := -9;                  -- too big.
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (checkint, check7sf1'high, check7sf1'low);
      check7sf2 := "1000000";
      report_error ("-9 to sfixed overflow", check7sf1, check7sf2);
      checkreal := -9.0;                -- maximum.
      report "Expect to_sfixed(integer) -overflow error" severity note;
      check7sf1 := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
      check7sf2 := "1000000";
      report_error ("-9.0 to sfixed overflow", check7sf1, check7sf2);
    end if;
    checkint   := -8;                   -- maximum.
    check7sf1  := to_sfixed (checkint, check7sf1'high, check7sf1'low);
    check7sf2  := "1000000";
    report_error ("-8 to sfixed", check7sf1, check7sf2);
    checkint   := -7;                   -- maximum.
    check7sf1  := to_sfixed (checkint, check7sf1'high, check7sf1'low);
    check7sf2  := "1001000";
    report_error ("-7 to sfixed", check7sf1, check7sf2);
    checkreal  := -8.0;                 -- maximum.
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1000000";
    report_error ("-8.0 to sfixed", check7sf1, check7sf2);
    checkint   := -1;
    check7sf1  := to_sfixed (checkint, check7sf1'high, check7sf1'low);
    check7sf2  := "1111000";
    report_error ("-1 to sfixed", check7sf1, check7sf2);
    checkreal  := -1.0;
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111000";
    report_error ("-1.0 to sfixed", check7sf1, check7sf2);
    checkreal  := -7.875;               -- maximum -.001.
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1000001";
    report_error ("-7.875 to sfixed", check7sf1, check7sf2);
    checkreal  := -0.125;               -- -0000.00011 = 1111.11101 => 1111.111
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111111";
    report_error ("-0.125 to sfixed", check7sf1, check7sf2);
    checkreal  := -0.126;               -- -0000.00100 = 1111.11100 => 1111.111
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111111";
    report_error ("-0.126 to sfixed", check7sf1, check7sf2);
    checkreal  := -0.124;               -- -0000.00011 = 1111.11101 => 1111.111
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111111";
    report_error ("-0.124 to sfixed underflow", check7sf1, check7sf2);
    checkreal  := -0.0625;              -- -0000.00001 = 1111.11111 => 0000.000
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "0000000";
    report_error ("-.0625 to sfixed underflow", check7sf1, check7sf2);
    checkreal  := -0.09375;             -- -0000.00010 = 1111.11110 => 1111.111
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111111";
    report_error ("-.09375 to sfixed underflow", check7sf1, check7sf2);
    checkreal  := -0.03175;             -- -0000.00001 = 1111.11111 = 0000.000
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "0000000";
    report_error ("-.03175 to sfixed underflow", check7sf1, check7sf2);
    checkreal  := -0.15625;             -- -0000.00100 = 1111.11100 = 1111.111
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111111";
    report_error ("-0.15625 to sfixed", check7sf1, check7sf2);
    checkreal  := -0.1875;              -- -0000.00101 = 1111.11011 = 1111.111
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111110";
    report_error ("-0.1875 to sfixed", check7sf1, check7sf2);
    checkreal  := -0.21875;             -- -0000.00110 = 1111.11010 = 111.110
    check7sf1  := to_sfixed (checkreal, check7sf1'high, check7sf1'low);
    check7sf2  := "1111110";
    report_error ("-0.21875 to sfixed", check7sf1, check7sf2);
    -- Math test
    check7sf1  := "0011000";            -- 3
    check7sf2  := "0010100";            -- 2.5
    check7sf   := check7sf1 + check7sf2;
    check7sf2  := to_sfixed (3.0+2.5, sfixed7_3'high, sfixed7_3'low);
    report_error ("signed 3 + 2.5 miscompare", check7sf, check7sf2);
    -- Boundary test
    check7sf1  := "0111111";            -- 7.875
    check7sf   := check7sf1 + check7sf1;
    check7sft  := "01111110";           -- 15.75
    report_error ("7.875+7.875", check7sf, check7sft);
    check7sf2  := "0110100";            -- 6.5
    check7sf1  := "0011000";            -- 3
    check7sf   := check7sf2 - check7sf1;
    check7sf2  := to_sfixed (3.5, sfixed7_3'high, sfixed7_3'low);
    report_error ("signed 6.5 - 3.0 miscompare", check7sf, check7sf2);
    check7sf2  := "0110100";            -- 6.5
    check7sf1  := "0010000";            -- 2.0
    smulres    := check7sf1 * check7sf2;
    smulrest   := "00001101000000";     -- 13
    report_error ("signed 2 * 6.5 miscompare", smulres, smulrest);
    check7sf2  := "0110100";            -- 6.5
    smulres    := check7sf2 * check7sf2;
    smulrest   := "00101010010000";     -- 42.25
    report_error ("signed 6.5 * 6.5 miscompare", smulres, smulrest);
    check7sf2  := "0100000";            -- 4
    smulres    := check7sf2 * check7sf2;
    smulrest   := "00010000000000";     -- 16
    report_error ("4 * 4 miscompare", smulres, smulrest);
    -- boundary multiply test
    check7sf2  := "0111111";            -- 7.875
    smulres    := check7sf2 * check7sf2;
    smulrest   := "00111110000001";     -- 62.01562
    -- sdivres3 := to_sfixed (62.015625, sdivres3'high, sdivres3'low);
    report_error ("7.875 * 7.875 miscompare", smulres, smulrest);
    check7sf2  := "0000001";            -- .125
    smulres    := check7sf2 * check7sf2;
    smulrest   := "00000000000001";     -- 0.01562
    report_error ("0.125 * 0.125 miscompare", smulres, smulrest);
    -- signed divide
    check7sf2  := "0110100";            -- 6.5
    check7sf1  := "0010000";            -- 2.0
    sdivres    := check7sf2 / check7sf1;
    check7sf1  := "0011010";
    report_error ("signed 6.5 / 2.0 miscompare", sdivres, check7sf1);
    check16sf1 := "0000110100000000";   -- 13
    check7sf1  := "0010000";            -- 2.0
    sdivres2   := check16sf1 / check7sf1;
    check16sf1 := "0000011010000000";   -- 6.5
    report_error ("long signed 6.5 / 2.0 miscompare", sdivres2, check16sf1);
    check7sf2  := "0110100";            -- 6.5
    sdivres    := check7sf2 / check7sf2;
    check7sf1  := "0001000";
    report_error ("signed 6.5 / 6.5 miscompare", sdivres, check7sf1);
    sdivres2   := "00000000000001010101011";   -- ~1/3
    sdivres3   := resize (sdivres2, sdivres3'high, sdivres3'low);
    check16sf1 := "0000000100000000";   -- 1
    check7sf2  := "0011000";            -- 3
    sdivres2   := check16sf1 / check7sf2;
    report_error ("signed 1/3 miscompare", sdivres2, sdivres3);
    check16sf1 := "0000001100000000";   -- 3
    assert (check16sf1 = 3) report "it's not 3" severity error;
    check7sf2  := "0001000";            -- 1
    assert (check7sf2 = 1) report "It's not 1" severity error;
    sdivres2x  := check7sf2 / check16sf1;
    sdivres3 := resize(to_sfixed(1.0/3.0, sdivres2x'high, sdivres2x'low),
                       sdivres3'high, sdivres3'low);
    report_error ("1/3+ miscompare", sdivres2x, sdivres3);
    check7sf2 := "0100000";             -- 4
    check7sf1 := "0000001";             -- 0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("4/0.125 miscompare", sdivres,
                  to_sfixed(4.0/0.125, sdivres2'high, sdivres2'low));
    sdivres := divide (check7sf2, check7sf1);
    report_error ("divide (4,0.125) miscompare", sdivres,
                  to_sfixed(4.0/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "0111111";             -- 7.875
    check7sf1 := "0000001";             -- 0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("7.875/0.125 miscompare", sdivres,
                  to_sfixed(7.875/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "0100000";             -- 4
    check7sf1 := "0000001";             -- 0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("0.125/4 miscompare", sdivres,
                  to_sfixed(0.125/4.0, sdivres2'high, sdivres2'low));
    check7sf2 := "0111111";             -- 7.875
    check7sf1 := "0000001";             -- 0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("0.125/7.875 miscompare", sdivres,
                  to_sfixed(0.125/7.875, sdivres2'high, sdivres2'low));
    check7sf1  := "0010000";            -- 2.0
    rsdivres   := reciprocal (check7sf1);
    check7sf2  := "0000100";            -- 0.5
    report_error ("signed 1/2 signed 1/x miscompare", rsdivres, check7sf2);
    check16sf1 := "0000001100000000";   -- 3
    rsdivres3  := reciprocal (check16sf1);
    report_error ("signed 1/3 1/x miscompare", rsdivres3,
                  to_sfixed (1.0/3.0, rsdivres3'high, rsdivres3'low));
    check7sf1  := "0000100";            -- 0.5
    rsdivres   := reciprocal (check7sf1);
    check7sf2  := "0010000";            -- 2.0
    report_error ("signed 1/0.5 1/x miscompare", rsdivres, check7sf2);
    check16sf1 := "0100000100000000";   -- 65
    rsdivres3  := reciprocal (check16sf1);
    report_error ("signed 1/65 1/x miscompare", rsdivres3,
                  to_sfixed (1.0/65.0, rsdivres3'high, rsdivres3'low));
    check16sf1 := to_sfixed (1, check16sf1'high, check16sf1'low);
    check16sf2 := "0100000100000000";   -- 65
    sdivres3   := check16sf1 / check16sf2;
    report_error ("signed 1/65 miscompare", sdivres3,
                  to_sfixed (1.0/65.0, sdivres3'high, sdivres3'low));
    sdivres3 := divide (check16sf1, check16sf2);
    report_error ("signed divide (1,65) miscompare", sdivres3,
                  to_sfixed (1.0/65.0, sdivres3'high, sdivres3'low));
    -- boundary test, positive only
    check7sf1 := "0111111";             -- 7.875
    check7sf2 := "0000001";             -- 0.125
    sdivres   := check7sf1 / check7sf2;
    sdivrest  := "00111111000000";      -- 63
    report_error ("7.875/0.125", sdivres, sdivrest);
    sdivres   := divide (check7sf1, check7sf2);
    report_error ("divide(7.875,0.125)", sdivres, sdivrest);
    sdivres   := check7sf2 / check7sf1;
    sdivrest  := "00000000000001";      -- 0.015875
    report_error ("0.125/7.875", sdivres, sdivrest);
    sdivres   := divide (check7sf2, check7sf1, fixed_round, 0);
    report_error ("divide(0.125,7.875, true, 0)", sdivres, sdivrest);
    check7sf1 := "0011000";             -- 3.0
    rsdivres  := reciprocal (check7sf1);
    report_error ("reciprocal 3", rsdivres,
                  to_sfixed (1.0/3.0, rsdivres'high, rsdivres'low));
    rsdivres := reciprocal (arg         => check7sf1,
                            guard_bits  => fixed_guard_bits,    -- default
                            round_style => fixed_truncate);     -- do not round
    report_error ("reciprocal test, no round", rsdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => rsdivres'high,
                             right_index    => rsdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    rsdivres := reciprocal (arg         => check7sf1,
                            guard_bits  => 0,  -- no guard bits
                            round_style => fixed_round);
    report_error ("reciprocal test, no guard", rsdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => rsdivres'high,
                             right_index    => rsdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    check7sf1 := "0111111";             -- 7.785
    rsdivres  := reciprocal (check7sf1);
    report_error ("1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (STD_LOGIC_VECTOR'("00000001"), 4, -3));
    check7sf1 := "0000001";             -- 0.125
    rsdivres  := reciprocal (check7sf1);
    report_error ("1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (8, 5, -3));
    check7sf1 := "1000000";             -- -8
    rsdivres  := reciprocal (check7sf1);
    report_error ("1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (-(1.0/8.0), 5, -8));
    check7sf1 := "1111111";             -- -0.125
    rsdivres  := reciprocal (check7sf1);
    report_error ("1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (-8, 6, -3));
    check7sf2 := "0001000";             -- 1.0
    check7sf1 := "0011000";             -- 3.0
    sdivres   := divide (check7sf2, check7sf1);
    report_error ("signed divide test", sdivres,
                  to_sfixed (1.0/3.0, sdivres'high, sdivres'low));
    sdivres := divide (l           => check7sf2,
                       r           => check7sf1,
                       guard_bits  => fixed_guard_bits,         -- default
                       round_style => fixed_truncate);          -- do not round
    report_error ("signed divide test, no round", sdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => sdivres'high,
                             right_index    => sdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    sdivres := divide (l           => check7sf2,
                       r           => check7sf1,
                       guard_bits  => 0,       -- no guard bits
                       round_style => fixed_round);
    report_error ("signed divide test, no guard", sdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => sdivres'high,
                             right_index    => sdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    -- scalb test
    check7sf2  := "0110100";
    check7sf1  := check7sf2 sla 0;
    check7sf2  := "0110100";
    report_error ("signed Scalb 0", check7sf1, check7sf2);
    check7sf2  := "0010100";
    check7sf1  := check7sf2 sla 1;
    check7sf2  := "0101000";
    report_error ("signed Scalb +1", check7sf1, check7sf2);
    check7sf2  := "0110100";
    check7sf1  := check7sf2 sla -1;
    check7sf2  := "0011010";
    report_error ("signed Scalb -1", check7sf1, check7sf2);
    check7sf2  := "0110100";
    check7sf1  := check7sf2 sla -2;
    check7sf2  := "0001101";
    report_error ("signed Scalb -2", check7sf1, check7sf2);
    check16sf2 := "1111100110000000";   -- -6.5
    check16sf1 := check16sf2 sla -4;
    check16sf2 := "1111111110011000";
    report_error ("signed Scalb -6.5 -4", check16sf1, check16sf2);
    check16sf2 := "1111100110000000";   -- -6.5
    check16sf1 := check16sf2 sla 4;
    check16sf2 := "1001100000000000";
    report_error ("signed Scalb -6.5 4", check16sf1, check16sf2);
    check7sf2  := "0110100";
    checksns   := to_signed (0, checksns'length);
    check7sf1  := check7sf2 sla to_integer(checksns);
    check7sf2  := "0110100";
    report_error ("signed Scalb signed 0", check7sf1, check7sf2);
    check7sf2  := "0010100";
    checksns   := to_signed (1, checksns'length);
    check7sf1  := check7sf2 sla to_integer(checksns);
    check7sf2  := "0101000";
    report_error ("signed Scalb SIGNED +1", check7sf1, check7sf2);
    check7sf2  := "0110100";
    checksns   := to_signed (-1, checksns'length);
    check7sf1  := check7sf2 sla to_integer(checksns);
    check7sf2  := "0011010";
    report_error ("signed Scalb SIGNED -1", check7sf1, check7sf2);
    check7sf2  := "0110100";
    checksns   := to_signed (-2, checksns'length);
    check7sf1  := check7sf2 sla to_integer(checksns);
    check7sf2  := "0001101";
    report_error ("signed Scalb SIGNED -2", check7sf1, check7sf2);
    check16sf2 := "1111100110000000";   -- -6.5
    checksns   := to_signed (-4, checksns'length);
    check16sf1 := check16sf2 sla to_integer(checksns);
    check16sf2 := "1111111110011000";
    report_error ("signed Scalb -6.5 SIGNED -4", check16sf1, check16sf2);
    check16sf2 := "1111100110000000";   -- -6.5
    checksns   := to_signed (4, checksns'length);
    check16sf1 := check16sf2 sla to_integer(checksns);
    check16sf2 := "1001100000000000";
    report_error ("signed Scalb -6.5 signed 4", check16sf1, check16sf2);
    -- signed remainder test
    check7sf2  := "0110100";            -- 6.5
    check7sf1  := "0010000";            -- 2.0
    check7sf2  := check7sf2 rem check7sf1;
    check7sf1  := "0000100";            -- 0.5
    report_error ("signed 6.5 rem 2.0 miscompare", check7sf2, check7sf1);
    check16sf1 := "0000011010000000";   -- 6.5
    check7sf1  := "0010000";            -- 2.0
    smodres3   := check16sf1 rem check7sf1;
    check7sf1  := "0000100";            -- 0.5
    report_error ("long signed 6.5 rem 2.0 miscompare", smodres3, check7sf1);
    check7sf2  := "0110100";            -- 6.5
    check7sf2  := check7sf2 rem check7sf2;
    check7sf1  := "0000000";
    report_error ("6.5 rem 6.5 miscompare", check7sf2, check7sf1);
    check16sf1 := "0000000100000000";   -- 1
    check7sf2  := "0011000";            -- 3
    smodres3   := check16sf1 rem check7sf2;
    check7sf2  := "0001000";            -- 1
    report_error ("1 rem 3 miscompare", smodres3, check7sf2);
    check7sf2  := "0110100";            -- 6.5
    check7sf1  := "0010000";            -- 2.0
    check7sf2  := check7sf2 mod check7sf1;
    check7sf1  := "0000100";            -- 0.5
    report_error ("signed 6.5 mod 2.0 miscompare", check7sf2, check7sf1);
    check16sf1 := "0000011010000000";   -- 6.5
    check7sf1  := "0010000";            -- 2.0
    smodres3   := check16sf1 mod check7sf1;
    check16sf1 := "0000000010000000";   -- 0.5
    report_error ("long signed 6.5 mod 2.0 miscompare",
                  smodres3, check16sf1);
    check7sf2  := "0110100";            -- 6.5
    check7sf2  := check7sf2 mod check7sf2;
    check7sf1  := "0000000";
    report_error ("6.5 mod 6.5 miscompare", check7sf2, check7sf1);
    check16sf1 := "0000000100000000";   -- 1
    check7sf2  := "0011000";            -- 3
    smodres3   := check16sf1 mod check7sf2;
    check16sf2 := "0000000100000000";   -- 1
    report_error ("1 mod 3 miscompare", smodres3, check16sf2);

    -- Negative number test
    check16sf1 := "0000000010000000";                             -- 0.5
    check16sf2 := "1111111110000000";                             -- -0.5
    addcheck16 := - check16sf1;
    report_error ("-0.5 miscompare", addcheck16, check16sf2);
    checkint   := -3;
    check7sf1  := to_sfixed (checkint, sfixed7_3'high, sfixed7_3'low);
    check7sf2  := "1101000";                                      -- -3.0
    report_error ("-3 miscompare", check7sf1, check7sf2);
    check7sf1  := "0110100";                                      -- 6.5
    addcheck16 := - resize(check7sf1, check16sf1'high, check16sf1'low);
    check16sf2 := "1111100110000000";                             -- -6.5
    report_error ("-6.5 miscompare", addcheck16, check16sf2);
    checkreal  := -3.5;
    check7sf1  := to_sfixed (checkreal, sfixed7_3'high, sfixed7_3'low);
    check7sf2  := "1100100";
    report_error ("-3.5 miscompare", check7sf1, check7sf2);
    checksns   := "11111101";
    check7sf1  := to_sfixed (checksns, sfixed7_3'high, sfixed7_3'low);
    check7sf2  := "1101000";
    report_error ("signed -3 miscompare", check7sf1, check7sf2);
    check16sf1 := "0000000000000000";                             -- 0
    check16sf2 := "1111100110000000";                             -- -6.5
    check16sf2 := resize (check16sf1 - check16sf2,
                          check16sf2'high, check16sf2'low);
    check7sf1  := "0110100";                                      -- 6.5
    check16sf1 := resize(check7sf1, check16sf1'high, check16sf1'low);
    report_error ("0 - 6.5 miscompare", check16sf2, check16sf1);
    check16sf2 := "1111100110000000";                             -- -6.5
    checkreal  := to_real (check16sf2);                           -- -6.5
    assert (checkreal = -6.5) report "to_real -6.5 mismatch" severity error;
    check7sf2  := "1101000";                                      -- -3.0
    checkint   := to_integer (check7sf2);
    assert (checkint = -3) report "to_integer -3 miscompare "
      & INTEGER'image(checkint) severity error;
    -- boundary test
    check7sf1  := "0111111";                                      -- 7.875
    check7sf   := - check7sf1;
    check7sft  := "11000001";                                     -- -7.875
    report_error ("-7.875 check", check7sft, to_sfixed(-7.875, check7sft));
    report_error ("-7.875 bounds", check7sf, check7sft);
--    check7uf1  := to_ufixed (check7sf1);
--    check7uf2  := "0111111";                                      -- 7.875
--    report_error ("uns(abs(7.875))", check7uf1, check7uf2);
--    check7sf1  := "1000001";
--    check7uf1  := to_ufixed (check7sf1);
--    report_error ("uns(abs(-7.875))", check7uf1, check7uf2);
    check7sf1  := "1000000";                                      -- -8
    check7sf   := abs (check7sf1);
    check7sft  := "01000000";                                     -- 8
    report_error ("abs(-8)", check7sf, check7sft);
--    check7uf1  := to_ufixed (check7sf1);
--    check7uf2  := "1000000";                                      -- 8
--    report_error ("uns(abs(-8))", check7uf1, check7uf2);
    check7sf1  := "1000000";                                      -- -8
    check7sf   := check7sf1 + check7sf1;
    check7sft  := "10000000";                                     -- -16
    report_error ("-8+-8", check7sf, check7sft);
    check7sf1  := "1000000";                                      -- -8
    check7sf2  := "0111111";                                      -- 7.875
    check7sf   := check7sf1 - check7sf2;
    check7sft  := "10000001";                                     -- -15.875
    report_error ("+-8-7.875", check7sf, check7sft);
    check7sf1  := "1000000";                                      -- -8
    smulres    := check7sf1 * check7sf1;
    smulrest   := "01000000000000";                               -- 64
    report_error ("-8*-8", smulres, smulrest);
    check7sf1  := "1111111";                                      -- -0.125
    smulres    := check7sf1 * check7sf1;
    smulrest   := "00000000000001";                               -- 0.15625
    report_error ("-0.125*-0125", smulres, smulrest);
    check7sf1  := "1000000";                                      -- -8
    check7sf2  := "1111111";                                      -- -0.125
    sdivres    := check7sf1 / check7sf2;
    sdivrest   := "01000000000000";                               -- 64
    report_error ("-8/-0.125", sdivres, sdivrest);
    sdivres    := divide (check7sf1, check7sf2);
    report_error ("divide(-8,-0.125)", sdivres, sdivrest);
    sdivres    := check7sf2 / check7sf1;
    sdivrest   := "00000000000001";                               -- 0.015625
    report_error ("-0.125/-8", sdivres, sdivrest);
    sdivres    := divide (check7sf2, check7sf1, fixed_truncate, 0);
    report_error ("divied(-0.125,-8, false, 0)", sdivres, sdivrest);
    check7sf2  := "0000001";                                      -- 0.125
    sdivres    := check7sf1 / check7sf2;
    sdivrest   := "11000000000000";                               -- -64
    report_error ("-8/0.125", sdivres, sdivrest);
    sdivres    := divide (check7sf1, check7sf2, fixed_round, 1);
    report_error ("divide(-8,0.125, true, 1)", sdivres, sdivrest);
    sdivres    := check7sf2 / check7sf1;
    sdivrest   := "11111111111111";                               -- -0.015625
    report_error ("0.125/-8", sdivres, sdivrest);
    sdivres    := divide (check7sf2, check7sf1, fixed_truncate, 10);
    report_error ("divied(0.125,-8, true, 10)", sdivres, sdivrest);
    sdivres    := check7sf1 / check7sf1;
    report_error ("-8/-8", sdivres, to_sfixed (1, check7sf1));
    sdivres    := divide (check7sf1, check7sf1);
    report_error ("divide(-8,-8)", sdivres, to_sfixed (1, check7sf1));
    -- - reciprocal test
    check16sf1 := "1111110100000000";                             -- -3
    rsdivres3  := reciprocal (check16sf1);
    report_error ("-1/3 1/x miscompare", rsdivres3,
                  to_sfixed (-1.0/3.0, rsdivres3'high, rsdivres3'low));
    check7sf1 := "1111100";                                       -- -0.5
    rsdivres  := reciprocal (check7sf1);
    check7sf2 := "1110000";                                       -- -2.0
    report_error ("-1/0.5 1/x miscompare", rsdivres, check7sf2);
    check7sf2 := "0110100";                                       -- 6.5
    check7sf1 := to_sfixed(-2, check7sf1'high, check7sf1'low);    -- -2.0
    smulres   := check7sf1 * check7sf2;
    smulrest  := to_sfixed (-13, smulrest'high, smulrest'low);
    report_error ("signed -2 * 6.5 miscompare", smulres, smulrest);
    check7sf2 := to_sfixed(-6.5, check7sf1'high, check7sf1'low);  -- -6.5
    check7sf1 := "0010000";                                       -- 2.0
    smulres   := check7sf1 * check7sf2;
    smulrest  := to_sfixed (-13, smulrest'high, smulrest'low);
    report_error ("signed 2 * -6.5 miscompare", smulres, smulrest);
    check7sf1 := to_sfixed(-2, check7sf1'high, check7sf1'low);    -- -2.0
    check7sf2 := to_sfixed(-6.5, check7sf1'high, check7sf1'low);  -- -6.5
    smulres   := check7sf1 * check7sf2;
    smulrest  := "00001101000000";                                -- 13
    report_error ("signed -2 * -6.5 miscompare", smulres, smulrest);
    check7sf2 := "0100000";                                       -- 4
    check7sf1 := "1100000";                                       -- -4
    smulres   := check7sf2 * check7sf1;
    smulrest  := "11110000000000";                                -- 16
    report_error ("4 * -4 miscompare", smulres, smulrest);
    check7sf2 := "0111111";                                       -- 7.875
    check7sf1 := "1000001";                                       -- -7.875
    smulres   := check7sf2 * check7sf1;
    sdivres3  := to_sfixed (-62.015625, sdivres3'high, sdivres3'low);
    report_error ("7.875 * -7.875 miscompare", smulres, sdivres3);
    check7sf2 := "0000001";                                       -- .125
    check7sf1 := "1111111";                                       -- -0.125
    smulres   := check7sf2 * check7sf1;
    sdivres3  := to_sfixed (-0.015625, sdivres3'high, sdivres3'low);
    report_error ("0.125 * -0.125 miscompare", smulres, sdivres3);
    check7sf2 := "0100000";                                       -- 4
    check7sf1 := "1100000";                                       -- -4
    smulres   := check7sf1 * check7sf2;
    smulrest  := "11110000000000";                                -- -16
    report_error ("-4 * 4 miscompare", smulres, smulrest);
    check7sf2 := "0111111";                                       -- 7.875
    check7sf1 := "1000001";                                       -- -7.875
    smulres   := check7sf1 * check7sf2;
    sdivres3  := to_sfixed (-62.015625, sdivres3'high, sdivres3'low);
    report_error ("-7.875 * 7.875 miscompare", smulres, sdivres3);
    check7sf2 := "0000001";                                       -- .125
    check7sf1 := "1111111";                                       -- -0.125
    smulres   := check7sf1 * check7sf2;
    sdivres3  := to_sfixed (-0.015625, sdivres3'high, sdivres3'low);
    report_error ("-0.125 * 0.125 miscompare", smulres, sdivres3);
    check7sf2 := "1100000";                                       -- 4
    smulres   := check7sf2 * check7sf2;
    smulrest  := "00010000000000";                                -- 16
    report_error ("-4 * -4 miscompare", smulres, smulrest);
    check7sf2 := "1000001";                                       -- 7.875
    smulres   := check7sf2 * check7sf2;
    sdivres3  := to_sfixed (62.015625, sdivres3'high, sdivres3'low);
    report_error ("-7.875 * -7.875 miscompare", smulres, sdivres3);
    check7sf2 := "1111111";                                       -- .125
    smulres   := check7sf2 * check7sf2;
    sdivres3  := to_sfixed (0.015625, sdivres3'high, sdivres3'low);
    report_error ("-0.125 * -0.125 miscompare", smulres, sdivres3);

    check7sf2  := "0110100";                                       -- 6.5
    check7sf1  := to_sfixed(-2, check7sf1'high, check7sf1'low);    -- -2.0
    sdivres    := check7sf2 / check7sf1;
    check7sf1  := to_sfixed (6.5/(-2.0), check7sf1'high, check7sf1'low);
    report_error ("signed 6.5 / -2.0 miscompare", sdivres, check7sf1);
    check7sf2  := to_sfixed(-6.5, check7sf1'high, check7sf1'low);  -- -6.5
    check7sf1  := "0010000";                                       -- 2.0
    sdivres    := check7sf2 / check7sf1;
    check7sf1  := to_sfixed (-6.5/2.0, check7sf1'high, check7sf1'low);
    report_error ("signed -6.5 / 2.0 miscompare", sdivres, check7sf1);
    check7sf2  := to_sfixed(-6.5, check7sf1'high, check7sf1'low);  -- -6.5
    check7sf1  := to_sfixed(-2, check7sf1'high, check7sf1'low);    -- -2.0
    sdivres    := check7sf2 / check7sf1;
    check7sf1  := "0011010";
    report_error ("signed -6.5 / -2.0 miscompare", sdivres, check7sf1);
    check16sf1 := "1111110100000000";                              -- -3
    check7sf2  := "0001000";                                       -- 1
    sdivres2x  := check7sf2 / check16sf1;
    sdivres3 := resize(to_sfixed(1.0/(-3.0), sdivres2x'high, sdivres2x'low),
                       sdivres3'high, sdivres3'low);
    report_error ("1/-3+ miscompare", sdivres2x, sdivres3);
    check7sf2 := "0100000";                                        -- 4
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("4/-0.125 miscompare", sdivres,
                  to_sfixed(4.0/(-0.125), sdivres2'high, sdivres2'low));
    check7sf2 := "0111111";                                        -- 7.875
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("7.875/-0.125 miscompare", sdivres,
                  to_sfixed(7.875/(-0.125), sdivres2'high, sdivres2'low));
    check7sf2 := "1100000";                                        -- -4
    check7sf1 := "0000001";                                        -- -0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("0.125/-4 miscompare", sdivres,
                  to_sfixed(0.125/(-4.0), sdivres2'high, sdivres2'low));
    check7sf2 := "1000001";                                        -- -7.875
    check7sf1 := "0000001";                                        -- 0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("0.125/-7.875 miscompare", sdivres,
                  to_sfixed(0.125/(-7.875), sdivres2'high, sdivres2'low));
    check16sf1 := "0000001100000000";                              -- 3
    check7sf2  := "1111000";                                       -- -1
    sdivres2x  := check7sf2 / check16sf1;
    sdivres3 := resize(to_sfixed(-1.0/3.0, sdivres2x'high, sdivres2x'low),
                       sdivres3'high, sdivres3'low);
    report_error ("-1/3+ miscompare", sdivres2x, sdivres3);
    check7sf2 := "1100000";                                        -- 4
    check7sf1 := "0000001";                                        -- 0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("-4/0.125 miscompare", sdivres,
                  to_sfixed(-4.0/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "1000001";                                        -- 7.875
    check7sf1 := "0000001";                                        -- 0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("-7.875/0.125 miscompare", sdivres,
                  to_sfixed(-7.875/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "0100000";                                        -- 4
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("-0.125/4 miscompare", sdivres,
                  to_sfixed(-0.125/4.0, sdivres2'high, sdivres2'low));
    check7sf2 := "0111111";                                        -- 7.875
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("-0.125/7.875 miscompare", sdivres,
                  to_sfixed(-0.125/7.875, sdivres2'high, sdivres2'low));
    check16sf1 := "0000001100000000";                              -- 3
    check16sf1 := "1111110100000000";                              -- -3
    check7sf2  := "1111000";                                       -- -1
    sdivres2x  := check7sf2 / check16sf1;
    sdivres3 := resize(to_sfixed(1.0/3.0, sdivres2x'high, sdivres2x'low),
                       sdivres3'high, sdivres3'low);
    report_error ("-1/-3+ miscompare", sdivres2x, sdivres3);
    check7sf2 := "1100000";                                        -- -4
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("-4/-0.125 miscompare", sdivres,
                  to_sfixed(4.0/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "1000001";                                        -- -7.875
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf2 / check7sf1;
    report_error ("-7.875/-0.125 miscompare", sdivres,
                  to_sfixed(7.875/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "1100000";                                        -- -4
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("-0.125/-4 miscompare", sdivres,
                  to_sfixed(0.125/4.0, sdivres2'high, sdivres2'low));
    check7sf2 := "1000001";                                        -- -7.875
    check7sf1 := "1111111";                                        -- -0.125
    sdivres   := check7sf1 / check7sf2;
    report_error ("-0.125/-7.875 miscompare", sdivres,
                  to_sfixed(0.125/7.875, sdivres2'high, sdivres2'low));
    check7sf2 := "0000100";                                        -- 0.5
    check7sf1 := to_sfixed(-2, check7sf1'high, check7sf1'low);     -- -2.0
    rsdivres  := reciprocal (check7sf1);
    report_error ("-1/2 signed 1/x miscompare", rsdivres, -check7sf2);

    -- Check a few of the overloads
    check7uf1 := "0011010";             -- 3.25
    check7uf  := check7uf1 + 1.5;
    report_error ("3.25 + real 1.5",
                  check7uf, to_ufixed (4.75, check7uf'high, check7uf'low));
    check7uf := check7uf1 + to_ufixed (2, 3, 0);
    report_error ("3.25 + integer 2",
                  check7uf, to_ufixed (5.25, check7uf'high, check7uf'low));
    checkuns := "00000010";             -- 2
    check7uf2 := resize (check7uf1 + to_ufixed (checkuns, checkuns'high, 0),
                         check7uf2'high, check7uf2'low);
    report_error ("3.25 + unsigned 2",
                  check7uf2, to_ufixed (5.25, check7uf2'high, check7uf2'low));
    check7uf := 1.5 + check7uf1;
    report_error ("real 1.5 + 3.25",
                  check7uf, to_ufixed (4.75, check7uf'high, check7uf'low));
    check7uf := to_ufixed (2, 3, 0) + check7uf1;
    report_error ("integer 2 + 3.25",
                  check7uf, to_ufixed (5.25, check7uf2'high, check7uf2'low));
    checkuns := "00000010";             -- 2
    check7uf2 := resize (to_ufixed (checkuns, checkuns'high, 0) + check7uf1,
                         check7uf2'high, check7uf2'low);
    report_error ("unsigned 2 + 3.25",
                  check7uf2, to_ufixed (5.25, check7uf2'high, check7uf2'low));
    -- signed
    check7sf1 := "0011010";             -- 3.25
    check7sf  := check7sf1 + 1.5;
    report_error ("3.25 + real 1.5",
                  check7sf, to_sfixed (4.75, check7sf'high, check7sf'low));
    check7sf := check7sf1 + to_sfixed (2, 3, 0);
    report_error ("3.25 + integer 2",
                  check7sf, to_sfixed (5.25, check7sf'high, check7sf'low));
    checksns := "00000010";             -- 2
    check7sf2 := resize (check7sf1 + to_sfixed (checksns),
                         check7sf2'high, check7sf2'low);
    report_error ("3.25 + signed 2",
                  check7sf2, to_sfixed (5.25, check7sf2'high, check7sf2'low));
    check7sf := 1.5 + check7sf1;
    report_error ("real 1.5 + 3.25",
                  check7sf, to_sfixed (4.75, check7sf'high, check7sf'low));
    check7sf := to_sfixed (2, 3, 0) + check7sf1;
    report_error ("integer 2 + 3.25",
                  check7sf, to_sfixed (5.25, check7sf2'high, check7sf2'low));
    checksns := "00000010";             -- 2
    check7sf2 := resize (to_sfixed (checksns, checkuns'high, 0) + check7sf1,
                         check7sf2'high, check7sf2'low);
    report_error ("unsigned 2 + 3.25",
                  check7sf2, to_sfixed (5.25, check7sf2'high, check7sf2'low));
    assert (quiet) report "Basic conversion and math test completed"
      severity note;
    basetest_done <= true;
    wait;
  end process basictest;

  -- purpose: small number test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  smalltest : process is
    variable r1 : REAL;
    variable r2 : REAL;
    variable r3 : REAL;

    variable u1 : UFIXED(0 downto -1);
    variable u2 : UFIXED(0 downto -1);
  begin  -- process smalltest

    wait until start_smalltest;
    -- 1.5 + 1.5
    u1 := to_ufixed(1.5, 0, -1);
    u2 := to_ufixed(1.5, 0, -1);
    r3 := to_real(u1 + u2);
    assert r3 = 3.0 report "Unsigned-unsigned addition error" severity warning;

    -- 1.5 * 1.5
    u1 := to_ufixed(1.5, 0, -1);
    u2 := to_ufixed(1.5, 0, -1);
    r3 := to_real(u1 * u2);
    assert r3 = 2.25 report "Unsigned-unsigned multiply error"
      severity warning;
    assert (quiet) report "small number test completed" severity note;
    smalltest_done <= true;
    wait;
  end process smalltest;

  -- purpose: test little endian numbers
  endian_test : process is
    variable fr                              : ufixed (-3 to 3);  -- "to" direction range
    variable check7uf1, check7uf2, check7uf3 : ufixed7_3;
    variable check9uf                        : ufixed (5 downto -3);  -- ufixed7_3 + ufixed7_3 + ufixed7_3
    variable checkint                        : INTEGER;
    variable checkreal                       : REAL;
    variable A                               : ufixed(7 downto -3);
    variable Y                               : ufixed(6 downto -4);
    variable sfr                             : sfixed (-1 to 7);  -- (78.0d) into
    variable sft                             : sfixed (7 downto -1);  -- (78.0d)
    variable au, bu, cu                      : UNSIGNED (7 downto 0);  -- unsigned
    variable aur, bur, cur                   : UNSIGNED (0 to 7);  -- reverse SIGNED
    variable ufx                             : ufixed (20 downto -34);  -- big number
    variable sfx                             : sfixed (20 downto -34);  -- big number
  begin  -- process endian_test
    wait until start_endiantest;
    -- Confirm what signed and unsigned do
    aur := "01001110";                  -- 78 reverse range
    bu  := resize (aur, bu'length);     -- should be "01001110"
    au  := to_unsigned(78, au'length);
    assert (bu = au) report "downto + to 78 error "
      severity warning;
    aur := "00000001";                  -- 1, reversed range
    bu  := resize (aur, bu'length);
    au  := to_unsigned(1, au'length);
    assert (bu = au) report "downto + to error "
      severity warning;
    -- little endian test.
--    le16       := "0000000010000000";          -- 2.0 0000000.010000000
--    checkreal := to_real (le16);
--    assert (checkreal = 2.0) report "reverse range 2.0 real mismatch "
--      & real'image(checkreal) & " /= " & to_string (le16) severity error;
--    check16uf1 := resize (le16, check16uf1'high, check16uf1'low);
--        checkreal := to_real (check16uf1);
--    assert (checkreal = 2.0) report "reverse range 2.0 real mismatch "
--      & real'image(checkreal) & " /= " & to_string (check16uf1) severity error;
--    check16uf2 := "0000001000000000";
--    report_error ("LE resize", check16uf1, check16uf2);
--    le16       := "0000000010000000";          -- 2.0
--    check16uf1 := "0000000010000000";   -- 0.5
--    check16uf2 := check16uf1 + le16;    -- 2.5;
--    check16uf1 := to_ufixed (2.5, ufixed16_8'high, ufixed16_8'low);
--    report_error ("LE 2.0 + 0.5 miscompare", check16uf2, check16uf1);
--    le16       := "1000000010000000";
--    check16uf1 := "0000000010000001";
--    check16uf2 := check16uf1 + le16;    -- 1.0;
--    check16uf1 := "1000000100000001";
--    report_error ("LE high low miscompare", check16uf2, check16uf1);
    if (not quiet) then
      fr        := "0000010";           -- reversed range.
      report "Expect little Endian error here" severity note;
      check7uf1 := resize (fr, check7uf1'high, check7uf1'low);
      check7uf2 := "0000010";
      report_error ("LE UNSIGNED miscompare ", check7uf1, check7uf2);
      sfr       := "001110010";         -- (78.0d) into
      report "Expect little Endian error here" severity note;
      sft       := resize (sfr, sft'high, sft'low);
      report_error ("LE signed miscompare ", sft,
                    to_sfixed (57, sft'high, sft'low));
      -- It's 57 now, reading the bits in reverse order.
    end if;
    Y := "00000010100";                 -- 1.25
    A := Y;                             -- Multiply by 2
    check7uf1 := resize (to_ufixed (2, check7uf1'high) * Y,
                         check7uf1'high, check7uf1'low);
    report_error ("type conversion *2", A, check7uf1);
    check7uf1 := "1000000";             -- 8
    check7uf2 := "0001100";             -- 1.5
    check7uf3 := "0000001";             -- .125
    check9uf  := check7uf1 + check7uf2 + check7uf3;
    report_error ("+ + test", check9uf,
                  to_ufixed (9.625, check9uf'high, check9uf'low));
    check9uf := (check7uf1 + check7uf2) + check7uf3;
    report_error ("(+) + test", check9uf,
                  to_ufixed (9.625, check9uf'high, check9uf'low));
    check9uf := check7uf1 + (check7uf2 + check7uf3);
    report_error ("+ (+) test", check9uf,
                  to_ufixed (9.625, check9uf'high, check9uf'low));
    ufx       := "0000000001001000000000110101000010101111000010001010110";
    checkreal := to_real(ufx);
    assert (checkreal > 2304.41 and checkreal < 2304.42)
      report "Large to_real(ufixed) " & to_hstring (ufx) & " = "
      & REAL'image(checkreal)
      severity error;
    sfx       := "0000000001001000000000110101000010101111000010001010110";
    checkreal := to_real(sfx);
    assert (checkreal > 2304.41 and checkreal < 2304.42)
      report "Large to_real(sfixed) " & to_hstring (sfx) & " = "
      & REAL'image(checkreal)
      severity error;
    assert (quiet) report "Little Endian and Misc test completed"
      severity note;
    endiantest_done <= true;
    wait;
  end process endian_test;

  -- purpose: odd ranges test
  oddrange : process is
    variable checkreal             : REAL;
    variable checkint              : INTEGER;
    variable checkuf1, checkuf1x   : ufixed (-2 downto -5);  -- negative range only
    variable checkuf2, checkuf2x   : ufixed (4 downto 1);  -- positive range only, overlapping
    variable checkuf3, checkuf3x   : ufixed (5 downto -5);
    variable ckuf1recip            : ufixed (5 downto 1);  -- 1/ checkuf1
    variable ckuf2recip            : ufixed (-1 downto -5);  -- 1/checkuf2
    variable checksf1, checksf1x   : sfixed (-2 downto -6);  -- negative range only
    variable checksf1y             : sfixed (-1 downto -6);
    variable checksf2, checksf2x   : sfixed (5 downto 1);  -- positive range only, overlapping
    variable checksf2y             : sfixed (6 downto 1);
    variable checksf3, checksf3x   : sfixed (6 downto -6);
    variable cksf1recip            : sfixed (7 downto 2);  -- 1/checksf1
    variable cksf2recip            : sfixed (0 downto -5);   -- 1/checksf2
    variable checkstr, checkstr2   : STRING (1 to 7);
    variable checksstr, checksstr2 : STRING (1 to 8);
  begin  -- process oddrange
    wait until start_oddrangetest;
    checkuf1  := to_ufixed (0.25, checkuf1'high, checkuf1'low);
    checkuf1x := "1000";
    report_error ("0.25 odd range error", checkuf1, checkuf1x);
    checkreal := to_real (checkuf1x);
    assert (0.25 = checkreal) report "odd range 0.25 error "
      & REAL'image(checkreal) severity error;
    checkuf1  := resize (checkuf1x, checkuf1'high, checkuf1'low);
    report_error ("odd resize error", checkuf1, checkuf1x);
    checkuf2  := to_ufixed (4, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";
    report_error ("4 odd range error", checkuf2, checkuf2x);
    checkint  := to_integer (checkuf2x);
    assert (4 = checkint) report "odd range 4 error "
      & INTEGER'image(checkint) severity error;
    checkuf2 := resize (checkuf2x, checkuf2'high, checkuf2'low);
    report_error ("odd high resize error", checkuf2, checkuf2x);
    checkuf1 := "1111";
    checkint := to_integer(checkuf1);
    assert (checkint = 0) report "odd low to_integer"
      & INTEGER'image(checkint) severity error;
    checkuf2 := "1000";                 -- 16
    checkint := to_integer (checkuf2);
    assert (checkint = 16) report "odd high 16 to_integer"
      & INTEGER'image(checkint) severity error;
    checkuf2 := "0001";                 -- 2
    checkint := to_integer (checkuf2);
    assert (checkint = 2) report "odd high 2 to_integer"
      & INTEGER'image(checkint) severity error;
    checkuf3 := (others => '1');
    checkint := to_integer (checkuf3(-1 downto -5));
    assert (checkint = 1)
      report "to_integer(-1 dt -5) round to 1" severity error;
    checkuf3 := "00000001111";
    checkint := to_integer (checkuf3(-1 downto -5));
    assert (checkint = 0)
      report "to_integer(-1 dt -5) round to 0" severity error;
    checkuf1  := "1000";
    checkreal := to_real(checkuf1);
    assert (checkreal = 0.25) report "odd low to_real "
      & REAL'image(checkreal) severity error;
    checkuf2  := "1000";                -- 16
    checkreal := to_real (checkuf2);
    assert (checkreal = 16.0) report "odd high 16 to_real"
      & REAL'image(checkreal) severity error;
    checkuf2  := "0001";                -- 2
    checkreal := to_real (checkuf2);
    assert (checkreal = 2.0) report "odd high 2 to_real"
      & REAL'image(checkreal) severity error;
    -- zero test
    checkuf1  := to_ufixed (0, checkuf1'high, checkuf1'low);
    checkuf1x := "0000";
    report_error ("small to_ufixed(0)", checkuf1, checkuf1x);
    checkuf1  := to_ufixed (0.0, checkuf1'high, checkuf1'low);
    checkuf1x := "0000";
    report_error ("small to_ufixed(0.0)", checkuf1, checkuf1x);
    checkuf2  := to_ufixed (0, checkuf2'high, checkuf2'low);
    checkuf2x := "0000";
    report_error ("big to_ufixed(0)", checkuf1, checkuf1x);
    checkuf2  := to_ufixed (0.0, checkuf2'high, checkuf2'low);
    checkuf2x := "0000";
    report_error ("big to_ufixed(0.0)", checkuf1, checkuf1x);
    checkint  := 4;
    checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";
    report_error ("odd to_ufixed(integer) high ", checkuf2, checkuf2x);
    checkint  := 3;
    checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";                -- rounded
    report_error ("odd to_ufixed(integer) round high ", checkuf2, checkuf2x);
    checkint  := 5;
    checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";                -- not rounded
    report_error ("odd to_ufixed(integer) not round high ",
                  checkuf2, checkuf2x);
    checkint  := 30;
    checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
    checkuf2x := "1111";
    report_error ("odd to_ufixed(integer) max high ", checkuf2, checkuf2x);
    if (not quiet) then
      checkint  := 32;
      report "Expect to_ufixed(integer) error here" severity note;
      checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
      checkuf2x := "1111";
      report_error ("odd to_ufixed(integer) overflow high ",
                    checkuf2, checkuf2x);    
    end if;
    checkint  := 31;
    checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
    checkuf2x := "1111";
    report_error ("odd to_ufixed(integer) round overflow high ",
                  checkuf2, checkuf2x);
    checkreal := 4.0;
    checkuf2  := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";
    report_error ("odd to_ufixed(real) high ", checkuf2, checkuf2x);
    checkreal := 3.0;
    checkuf2  := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";                -- rounded
    report_error ("odd to_ufixed(real) round high ", checkuf2, checkuf2x);
    checkreal := 5.0;
    checkuf2  := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
    checkuf2x := "0010";                -- not rounded
    report_error ("odd to_ufixed(real) not round high ", checkuf2, checkuf2x);
    checkreal := 30.0;
    checkuf2  := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
    checkuf2x := "1111";
    report_error ("odd to_ufixed(real) max high ", checkuf2, checkuf2x);
    if (not quiet) then
      checkreal := 32.0;
      report "Expect to_ufixed(real) error here" severity note;
      checkuf2  := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
      checkuf2x := "1111";
      report_error ("odd to_ufixed(real) overflow high ",
                    checkuf2, checkuf2x);
    end if;
    checkreal := 31.0;
    checkuf2  := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
    checkuf2x := "1111";
    report_error ("odd to_ufixed(real) round overflow high ",
                  checkuf2, checkuf2x);
    checkreal := 0.25;
    checkuf1  := to_ufixed(checkreal, checkuf1'high, checkuf1'low);
    checkuf1x := "1000";
    report_error ("odd to_ufixed(real) low", checkuf1, checkuf1x);
    checkreal := 0.015625;              -- 2**-6
    checkuf1  := to_ufixed(checkreal, checkuf1'high, checkuf1'low);
    checkuf1x := "0000";                -- underflow
    report_error ("odd to_ufixed(real) underflow low", checkuf1, checkuf1x);
    checkreal := 0.03125;               -- 2**-5
    checkuf1  := to_ufixed(checkreal, checkuf1'high, checkuf1'low);
    checkuf1x := "0001";
    report_error ("odd to_ufixed(real) min low", checkuf1, checkuf1x);
    checkreal := 0.03125 + 0.015625;    -- 2**-5 + 2**-6
    checkuf1  := to_ufixed(checkreal, checkuf1'high, checkuf1'low);
    checkuf1x := "0010";                -- round
    report_error ("odd to_ufixed(real) min round low", checkuf1, checkuf1x);
    checkreal := 0.46875;               -- maximum
    checkuf1  := to_ufixed(checkreal, checkuf1'high, checkuf1'low);
    checkuf1x := "1111";
    report_error ("odd to_ufixed(real) max low", checkuf1, checkuf1x);
    checkreal := 0.46875 + 0.015625;    -- maximum + 2**-6
    checkuf1  := to_ufixed(checkreal, checkuf1'high, checkuf1'low);
    checkuf1x := "1111";
    report_error ("odd to_ufixed(real) max overflow low", checkuf1, checkuf1x);
    if (not quiet) then                 -- Some out of bounds test
      checkint  := 1;
      report "Expect to_ufixed(integer) overflow error here" severity note;
      checkuf1  := to_ufixed (checkint, checkuf1'high, checkuf1'low);
      checkuf1x := "1111";              -- saturate
      report_error ("odd to_ufixed(integer) low overflow",
                    checkuf1, checkuf1x);
      checkreal := 1.0;
      report "Expect to_ufixed(real) overflow error here" severity note;
      checkuf1  := to_ufixed (checkreal, checkuf1'high, checkuf1'low);
      checkuf1x := "1111";              -- saturate
      report_error ("odd to_ufixed(real) low overflow", checkuf1, checkuf1x);
      checkreal := 0.5;
      report "Expect to_ufixed(real) error here" severity note;
      checkuf1  := to_ufixed (checkreal, checkuf1'high, checkuf1'low);
      checkuf1x := "1111";              -- saturate
      report_error ("odd to_ufixed(0.5) low overflow", checkuf1, checkuf1x);
    end if;
    checkint  := 1;
    checkuf2  := to_ufixed (checkint, checkuf2'high, checkuf2'low);
    checkuf2x := "0000";
    report_error ("odd to_ufixed(integer) high underflow",
                  checkuf2, checkuf2x);
    checkreal  := 1.0;
    checkuf2   := to_ufixed (checkreal, checkuf2'high, checkuf2'low);
    checkuf2x  := "0000";
    report_error ("odd to_ufixed(real) high underflow", checkuf2, checkuf2x);
    checkuf1   := "1000";               -- 0.25
    ckuf1recip := reciprocal (checkuf1);
    report_error ("1 / "& to_string (checkuf1), ckuf1recip,
                  to_ufixed (4, 5, 0));
    checkuf1   := "0001";               -- 0.03125, minimum
    ckuf1recip := reciprocal (checkuf1);
    report_error ("1 / "& to_string (checkuf1), ckuf1recip,
                  to_ufixed (32, 9, 0));
    checkuf1   := "1111";               -- 0.46875 maximum
    ckuf1recip := reciprocal (checkuf1);
    report_error ("1 / "& to_string (checkuf1), ckuf1recip,
                  to_ufixed (2, 3, 1));
    checkuf2   := "0001";               -- 2
    ckuf2recip := reciprocal (checkuf2);
    report_error ("1 / "& to_string (checkuf2), ckuf2recip,
                  to_ufixed (0.5, 0, -5));
    checkuf2   := "1000";               -- 16
    ckuf2recip := reciprocal (checkuf2);
    report_error ("1 / "& to_string (checkuf2), ckuf2recip,
                  to_ufixed (0.0625, 0, -5));
    checkuf2   := "1001";               -- 18
    ckuf2recip := reciprocal (checkuf2);
    report_error ("1 / "& to_string (checkuf2), ckuf2recip,
                  to_ufixed (0.0555555, 0, -5));
    checkuf2   := "1111";               -- 30
    ckuf2recip := reciprocal (checkuf2);
    report_error ("1 / "& to_string (checkuf2), ckuf2recip,
                  to_ufixed (STD_LOGIC_VECTOR'("00001"), -1, -5)); 
    -- signed
    checksf1 := "11111";
    checkint := to_integer(checksf1);
    assert (checkint = 0) report "signed odd low to_integer"
      & INTEGER'image(checkint) severity error;
    checksf2 := "01000";                -- 16
    checkint := to_integer (checksf2);
    assert (checkint = 16) report "signed odd high 16 to_integer"
      & INTEGER'image(checkint) severity error;
    checksf2 := "00001";                -- 2
    checkint := to_integer (checksf2);
    assert (checkint = 2) report "signed odd high 2 to_integer"
      & INTEGER'image(checkint) severity error;
    checksf1  := "01000";
    checkreal := to_real(checksf1);
    assert (checkreal = 0.125) report "signed odd low to_real "
      & REAL'image(checkreal) severity error;
    checksf2  := "01000";               -- 16
    checkreal := to_real (checksf2);
    assert (checkreal = 16.0) report "signed odd high 16 to_real"
      & REAL'image(checkreal) severity error;
    checksf2  := "00001";               -- 2
    checkreal := to_real (checksf2);
    assert (checkreal = 2.0) report "signed odd high 2 to_real"
      & REAL'image(checkreal) severity error;
    checksf2  := "10001";               -- -30
    checkreal := to_real (checksf2);
    assert (checkreal = -30.0) report "signed odd high -30 to_real"
      & REAL'image(checkreal) severity error;
    checksf1  := to_sfixed (0, checksf1'high, checksf1'low);
    checksf1x := "00000";
    report_error ("small odd to_sfixed(0)", checksf1, checksf1x);
    checksf1  := to_sfixed (0.0, checksf1'high, checksf1'low);
    checksf1x := "00000";
    report_error ("small odd to_sfixed(0.0)", checksf1, checksf1x);
    checksf2  := to_sfixed (0, checksf2'high, checksf2'low);
    checksf2x := "00000";
    report_error ("big odd to_sfixed(0)", checksf2, checksf2x);
    checksf2  := to_sfixed (0.0, checksf2'high, checksf2'low);
    checksf2x := "00000";
    report_error ("big odd to_sfixed(0.0)", checksf2, checksf2x);
    checkint  := 4;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "00010";
    report_error ("odd to_sfixed(integer) high ", checksf2, checksf2x);
    checkint  := 3;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "00010";               -- rounded
    report_error ("odd to_sfixed(integer) round high ", checksf2, checksf2x);
    checkint  := 5;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "00010";               -- not rounded
    report_error ("odd to_sfixed(integer) not round high ",
                  checksf2, checksf2x);
    checkint  := 30;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "01111";
    report_error ("odd to_sfixed(integer) max high ", checksf2, checksf2x);
    if (not quiet) then
      checkint  := 32;
      report "Expect to_sfixed(integer) overflow error here" severity note;
      checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
      checksf2x := "01111";
      report_error ("odd to_sfixed(integer) overflow high ",
                    checksf2, checksf2x);    
    end if;
    checkint  := 31;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "01111";
    report_error ("odd to_sfixed(integer) round overflow high ",
                  checksf2, checksf2x);
    checkreal := 4.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "00010";
    report_error ("odd to_sfixed(real) high ", checksf2, checksf2x);
    checkreal := 3.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "00010";               -- rounded
    report_error ("odd to_sfixed(real) round high ", checksf2, checksf2x);
    checkreal := 5.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "00010";               -- not rounded
    report_error ("odd to_sfixed(real) not round high ", checksf2, checksf2x);
    checkreal := 30.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "01111";
    report_error ("odd to_sfixed(real) max high ", checksf2, checksf2x);
    if (not quiet) then
      checkreal := 32.0;
      report "Expect to_sfixed(real) error here" severity note;
      checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
      checksf2x := "01111";
      report_error ("odd to_sfixed(real) overflow high ", checksf2, checksf2x);
    end if;
    checkreal := 31.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "01111";
    report_error ("odd to_sfixed(real) round overflow high ",
                  checksf2, checksf2x);
    checkint  := -4;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "11110";
    report_error ("odd to_sfixed(integer) high ", checksf2, checksf2x);
    checkint  := -3;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "11110";               -- not rounded
    report_error ("odd to_sfixed(integer) not round high ",
                  checksf2, checksf2x);
    checkint  := -5;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "11110";               -- rounded
    report_error ("odd to_sfixed(integer) round high ", checksf2, checksf2x);
    checkint  := -30;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "10001";
    report_error ("odd to_sfixed(integer) almost max high ",
                  checksf2, checksf2x);
    checkint  := -32;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "10000";
    report_error ("odd to_sfixed(integer) max high ", checksf2, checksf2x);
    checkint  := -31;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "10000";
    report_error ("odd to_sfixed(integer) round overflow high ",
                  checksf2, checksf2x);
    if (not quiet) then
      checkint  := -33;
      report "Expect to_sfixed(integer) -overflow error here" severity note;
      checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
      checksf2x := "10000";
      report_error ("odd to_sfixed(-33) max high ", checksf2, checksf2x);
    end if;
    checkreal := -4.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "11110";
    report_error ("odd to_sfixed(real) high ", checksf2, checksf2x);
    checkreal := -3.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "11110";               -- not rounded
    report_error ("odd to_sfixed(real) not round high ", checksf2, checksf2x);
    checkreal := -5.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "11110";               -- rounded
    report_error ("odd to_sfixed(real) round high ", checksf2, checksf2x);
    checkreal := -30.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "10001";
    report_error ("odd to_sfixed(real) max high ", checksf2, checksf2x);
    checkreal := -32.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "10000";
    report_error ("odd to_sfixed(real) overflow high ", checksf2, checksf2x);
    checkreal := -31.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "10000";
    report_error ("odd to_sfixed(real) round overflow high ",
                  checksf2, checksf2x);
    if (not quiet) then
      checkreal := -33.0;
      report "Expect to_sfixed(integer) -overflow error here" severity note;
      checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
      checksf2x := "10000";
      report_error ("odd to_sfixed(-33.0) round overflow high ",
                    checksf2, checksf2x);
    end if;
    -- Some out of bounds test
    if (not quiet) then
      checkint  := 1;
      report "Expect to_sfixed(integer) overflow error here" severity note;
      checksf1  := to_sfixed (checkint, checksf1'high, checksf1'low);
      checksf1x := "01111";             -- saturate
      report_error ("odd to_sfixed(integer) low overflow",
                    checksf1, checksf1x);
      checkreal := 1.0;
      report "Expect to_sfixed(real) overflow error here" severity note;
      checksf1  := to_sfixed (checkreal, checksf1'high, checksf1'low);
      checksf1x := "01111";             -- saturate
      report_error ("odd to_sfixed(real) low overflow", checksf1, checksf1x);
      checkint  := -1;
      report "Expect to_ufixed(integer) -overflow error here" severity note;
      checksf1  := to_sfixed (checkint, checksf1'high, checksf1'low);
      checksf1x := "10000";             -- saturate
      report_error ("odd to_sfixed(-integer) low overflow",
                    checksf1, checksf1x);
      checkreal := -1.0;
      report "Expect to_ufixed(real) -overflow error here" severity note;
      checksf1  := to_sfixed (checkreal, checksf1'high, checksf1'low);
      checksf1x := "10000";             -- saturate
      report_error ("odd to_sfixed(-real) low overflow", checksf1, checksf1x);
    end if;
    checkint  := 1;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "00000";
    report_error ("odd to_sfixed(integer) high underflow",
                  checksf2, checksf2x);
    checkreal := 1.0;
    checksf2  := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x := "00000";
    report_error ("odd to_sfixed(real) high underflow", checksf2, checksf2x);
    checkint  := -1;
    checksf2  := to_sfixed (checkint, checksf2'high, checksf2'low);
    checksf2x := "00000";
    report_error ("odd to_sfixed(-integer) high underflow",
                  checksf2, checksf2x);
    checkreal  := -1.0;
    checksf2   := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x  := "00000";
    report_error ("odd to_sfixed(-real) high underflow", checksf2, checksf2x);
    checkreal  := -1.5;
    checksf2   := to_sfixed (checkreal, checksf2'high, checksf2'low);
    checksf2x  := "11111";
    report_error ("odd to_sfixed(-1.5) high underflow", checksf2, checksf2x);
    checksf1   := "00001";              -- 0.015625
    cksf1recip := reciprocal (checksf1);
    report_error ("1/"& to_string(checksf1), cksf1recip,
                  to_sfixed (64, 10, 0));
    checksf1   := "01000";              -- 0.125
    cksf1recip := reciprocal (checksf1);
    report_error ("1/"& to_string(checksf1), cksf1recip,
                  to_sfixed (8, 10, 0));
    checksf1   := "01111";              -- 0.234375 (max +)
    cksf1recip := reciprocal (checksf1);
    report_error ("1/"& to_string(checksf1), cksf1recip,
                  to_sfixed (4, 10, 0));
    checksf1   := "10000";              -- -0.25 (max -)
    cksf1recip := reciprocal (checksf1);
    report_error ("1/"& to_string(checksf1), cksf1recip,
                  to_sfixed (-4, 10, 0));
    checksf1   := "11111";              -- -0.015625
    cksf1recip := reciprocal (checksf1);
    report_error ("1/"& to_string(checksf1), cksf1recip,
                  to_sfixed (-64, 10, 0));
    -- Resize test
    checkuf1  := "1111";
    checkuf2  := resize (checkuf1, checkuf2'high, checkuf2'low);
    checkuf2x := "0000";
    report_error ("Odd low to high resize", checkuf2, checkuf2x);
    checkuf2  := "1111";
    checkuf1  := resize (checkuf2, checkuf1'high, checkuf1'low);  -- data lost
    checkuf1x := "1111";                -- saturate
    report_error ("Odd high to low resize", checkuf1, checkuf1x);
    checkuf2  := "0000";
    checkuf1  := resize (checkuf2, checkuf1'high, checkuf1'low);  -- data lost
    checkuf1x := "0000";                -- return zeros
    report_error ("0 Odd high to low resize", checkuf1, checkuf1x);
    checksf1  := "01111";
    checksf2  := resize (checksf1, checksf2'high, checksf2'low);
    checksf2x := "00000";
    report_error ("Odd low to high signed resize", checksf2, checksf2x);
    checksf2  := "01111";
    checksf1  := resize (checksf2, checksf1'high, checksf1'low);  -- data lost
    checksf1x := "01111";               -- saturated
    report_error ("Odd high to low signed resize", checksf1, checksf1x);
    checksf1  := "11111";
    checksf2  := resize (checksf1, checksf2'high, checksf2'low);
    checksf2x := "11111";
    report_error ("Odd low to high -signed resize", checksf2, checksf2x);
    checksf2  := "11111";
    checksf1  := resize (checksf2, checksf1'high, checksf1'low);  -- data lost
    checksf1x := "10000";               -- saturated
    report_error ("Odd high to low -signed resize", checksf1, checksf1x);

    checksf1  := to_sfixed (0.125, checksf1'high, checksf1'low);
    checksf1x := "01000";
    report_error ("+0.125 odd range error", checksf1, checksf1x);
    checkreal := to_real (checksf1x);
    assert (0.125 = checkreal) report "odd range +0.125 error "
      & REAL'image(checkreal) severity error;
    checksf2  := to_sfixed (4, checksf2'high, checksf2'low);
    checksf2x := "00010";
    report_error ("+4 odd range error", checksf2, checksf2x);
    checkint  := to_integer (checksf2x);
    assert (4 = checkint) report "odd range +4 error "
      & INTEGER'image(checkint) severity error;
    checksf1  := to_sfixed (-0.125, checksf1'high, checksf1'low);
    checksf1x := "11000";
    report_error ("-0.125 odd range error", checksf1, checksf1x);
    checkreal := to_real (checksf1x);
    assert (-0.125 = checkreal) report "odd range -0.125 error "
      & REAL'image(checkreal) severity error;
    checksf2  := to_sfixed (-4, checksf2'high, checksf2'low);
    checksf2x := "11110";
    report_error ("-4 odd range error", checksf2, checksf2x);
    checkint  := to_integer (checksf2x);
    assert (-4 = checkint) report "odd range -4 error "
      & INTEGER'image(checkint) severity error;
    checkuf1  := "1000";
    checkuf2  := "0010";
    checkuf3  := checkuf1 + checkuf2;
    checkuf3x := "00010001000";
    report_error ("Odd range add test", checkuf3, checkuf3x);
    checkuf1  := "1000";
    checkuf1x := "0010";
    checkuf1  := resize (checkuf1 + checkuf1x, checkuf1'high, checkuf1'low);
    checkuf1x := "1010";
    report_error ("Odd range low add test", checkuf1, checkuf1x);
    checkuf2  := "0010";
    checkuf2x := "0010";
    checkuf2  := resize (checkuf2 + checkuf2x, checkuf2'high, checkuf2'low);
    checkuf2x := "0100";
    report_error ("Odd range high add test", checkuf2, checkuf2x);
    -- Integer + negative binary point return a null array
--    if (not quiet) then
--      report "Expect 4 to_real(integer) overflow errors" severity note;
--      checkint  := 1;
--      checkuf1  := "1000";              -- .25
--      checkuf3  := resize (checkint + checkuf1, checkuf3);  -- "0.01111" + 0.01
--      checkuf3x := to_ufixed (0.71875, checkuf3x);
--      report_error ("odd range 1 + low", checkuf3, checkuf3x);
--      checkuf3  := resize (checkuf1 + checkint, checkuf3);
--      report_error ("odd range low + 1", checkuf3, checkuf3x);
--      checkuf3  := resize (checkint - checkuf1, checkuf3);
--      checkuf3x := to_ufixed (0.21875, checkuf3x);
--      report_error ("odd range 1 - low", checkuf3, checkuf3x);
--      checkuf3  := resize (checkuf1 - checkint, checkuf3);  -- overflow
--      checkuf3x := "00000011001";
--      report_error ("odd range low - 1 overflow", checkuf3, checkuf3x);
--      report "Expect 4 to_real(integer) overflow errors" severity note;
--      checkreal := 1.0;
--      checkuf1  := "1000";              -- .25
--      checkuf3  := resize (checkreal + checkuf1, checkuf3);
--      checkuf3x := "00000010111";       -- 0.01111 + 0.01000
--      report_error ("odd range 1.0 + low", checkuf3, checkuf3x);
--      checkuf3  := resize (checkuf1 + checkreal, checkuf3);
--      report_error ("odd range low + 1.0", checkuf3, checkuf3x);
--      checkuf3  := resize (checkreal - checkuf1, checkuf3);
--      checkuf3x := "00000000111";       -- 0.01111 - 0.01000
--      report_error ("odd range 1.0 - low", checkuf3, checkuf3x);
--      checkuf3  := resize (checkuf1 - checkreal, checkuf3);  -- overflow
--      checkuf3x := "00000011001";       -- 0.01000 - 0.01111
--      report_error ("odd range low - 1.0 overflow", checkuf3, checkuf3x);
--    end if;
    checkuf1 := "0100";                 -- 0.125
    checkuf2 := "1100";                 -- 24
    checkuf3 := resize (checkuf1 * checkuf2, checkuf3);
    report_error (to_string(checkuf1) & " * " & to_string(checkuf2),
                  checkuf3, to_ufixed (3, 5, 0));
    checkuf3 := resize (checkuf2 * checkuf1, checkuf3);
    report_error (to_string(checkuf2) & " * " & to_string(checkuf1),
                  checkuf3, to_ufixed (3, 5, 0));
    checkuf1 := "1000";                 -- 0.25
    checkuf2 := "0011";                 -- 6
    checkuf3 := resize (checkuf2 / checkuf1, checkuf3);
    report_error (to_string(checkuf2) & " / " & to_string(checkuf1),
                  checkuf3, to_ufixed (24, 10, 0));
    checkuf1 := "1100";                 -- 0.375
    checkuf2 := "0010";                 -- 4
    checkuf3 := resize (checkuf1 / checkuf2, checkuf3);
    report_error (to_string(checkuf1) & " / " & to_string(checkuf2),
                  checkuf3, to_ufixed (0.09375, 0, -10));
    -- signed
    checksf1  := "01000";
    checksf2  := "00010";
    checksf3  := checksf1 + checksf2;
    checksf3x := "0000100001000";
    report_error ("Odd signed range add test", checksf3, checksf3x);
    checksf1  := "01000";
    checksf1x := "00100";
    checksf1  := resize (checksf1 + checksf1x, checksf1'high, checksf1'low);
    checksf1x := "01100";
    report_error ("Odd signed low range add test", checksf1, checksf1x);
    checksf2  := "00010";
    checksf2x := "00110";
    checksf2  := resize (checksf2 + checksf2x, checksf2'high, checksf2'low);
    checksf2  := "01000";
    report_error ("Odd signed high range add test", checksf1, checksf1x);
    -- Integer + negative binary point return a null array
--    if (not quiet) then
--      report "Expect 4 to_real(integer) overflow errors" severity note;
--      checkint  := 1;
--      checksf1  := "01000";             -- .125
--      checksf3  := resize (checkint + checksf1, checksf3);
--      checksf3x := to_sfixed (0.359375, checksf3x);
--      report_error ("s odd range 1 + low", checksf3, checksf3x);
--      checksf3  := resize (checksf1 + checkint, checksf3);
--      report_error ("s odd range low + 1", checksf3, checksf3x);
--      checksf3  := resize (checkint - checksf1, checksf3);
--      checksf3x := to_sfixed (0.109375, checksf3x);
--      report_error ("s odd range 1 - low", checksf3, checksf3x);
--      checksf3  := resize (checksf1 - checkint, checksf3);  -- overflow
--      checksf3x := "1111111111001";
--      report_error ("odd range low - 1 overflow", checksf3, checksf3x);
--      report "Expect 4 to_real(integer) overflow errors" severity note;
--      checkreal := 1.0;
--      checksf1  := "01000";             -- .25
--      checksf3  := resize (checkreal + checksf1, checksf3);
--      checksf3x := "0000000010111";     -- 0.00111 + 0.00100
--      report_error ("s odd range 1.0 + low", checksf3, checksf3x);
--      checksf3  := resize (checksf1 + checkreal, checksf3);
--      report_error ("s odd range low + 1.0", checksf3, checksf3x);
--      checksf3  := resize (checkreal - checksf1, checksf3);
--      checksf3x := "0000000000111";     -- 0.00111 - 0.00100
--      report_error ("s odd range 1.0 - low", checksf3, checksf3x);
--      checksf3  := resize (checksf1 - checkreal, checksf3);  -- overflow
--      checksf3x := "1111111111001";     -- 0.001000 - 0.0011111
--      report_error ("s odd range low - 1.0 overflow", checksf3, checksf3x);
--    end if;

    checksf1x := "01000";
    checksf1y := - checksf1x;
    checksf1x := "11000";
    report_error ("Odd signed low negative test", checksf1y, checksf1x);
--    checksf1x := "01000";               -- 0.125
--    checkuf3  := resize (to_ufixed(checksf1x), checkuf3);
--    checkuf3x := "00000000100";         -- 0.125
--    report_error ("uns = abs(low)", checkuf3, checkuf3x);
    checksf1x := "01000";
    checksf1y := abs(checksf1x);
    report_error ("Odd signed low abs test", checksf1y, checksf1x);
    checksf2x := "10110";
    checksf2y := abs(checksf2x);
    checksf2x := "01010";
    report_error ("Odd signed low abs test 2", checksf2y, checksf2x);
    -- Multiply test
    checkuf1  := "1000";
    checkuf1x := resize (checkuf1 * checkuf1, checkuf1x'high, checkuf1x'low);
    checkuf1  := "0010";
    report_error ("Odd range low multiply", checkuf1x, checkuf1);
    checkuf2  := "0001";
    checkuf2x := resize (checkuf2 * checkuf2, checkuf2x'high, checkuf2x'low);
    checkuf2  := "0010";
    report_error ("Odd range high multiply", checkuf2x, checkuf2);
    checkuf1  := "1000";                -- 0.25
    checkuf2  := "0001";                -- 2
    checkuf3  := resize (checkuf1 * checkuf2, checkuf3'high, checkuf3'low);
    checkuf3x := to_ufixed (0.5, checkuf3x'high, checkuf3x'low);
    report_error ("Odd range mixed multiply", checkuf3, checkuf3x);
--    checkuf1 := "1000";                 -- 0.25
--    checkint := 1;
--    checkuf3 := resize (checkuf1 * checkint, checkuf3);
--    report_error ("odd range low * 1", checkuf3, checkuf1);
--    checkuf3 := resize (checkint * checkuf1, checkuf3);
--    report_error ("odd range 1 * low", checkuf3, checkuf1);
--    checkuf3 := resize (checkuf1 / checkint, checkuf3);
--    report_error ("odd range low / 1", checkuf3, checkuf1);
--    checkuf3 := resize (checkint / checkuf1, checkuf3);
--    checkuf3x := to_ufixed (4, checkuf3x);
--    report_error ("odd range 1 / low", checkuf3, checkuf3x);
    checkuf1  := "1000";                -- 0.25
    checkreal := 1.0;
    if (not quiet) then
      report "Expect 4 to_ufixed(integer) bounds errors" severity note;
      checkuf3  := resize (checkuf1 * checkreal, checkuf3);
      checkuf3x := "00000000100";       -- 0.01111 * 0.01000
      report_error ("odd range low * 1.0", checkuf3, checkuf3x);
      checkuf3  := resize (checkreal * checkuf1, checkuf3);
      report_error ("odd range 1.0 * low", checkuf3, checkuf3x);
      checkuf3  := resize (checkuf1 / checkreal, checkuf3);
      checkuf3x := "00000010000";       -- 0.01111 / 0.01000
      report_error ("odd range low / 1.0", checkuf3, checkuf3x);
      checkuf3  := resize (checkreal / checkuf1, checkuf3);
      checkuf3x := "00000111100";       -- 0.01000 / 0.01111
      report_error ("odd range 1.0 / low", checkuf3, checkuf3x);
    end if;
    -- signed
    checksf1  := "01000";               -- 0.125
    checksf1x := resize (checksf1 * checksf1, checksf1x'high, checksf1x'low);
    checksf1  := "00001";               -- 0.015625
    report_error ("Odd range signed low multiply", checksf1x, checksf1);
    checksf2  := "00010";               -- 4
    checksf2x := resize (checksf2 * checksf2, checksf2x'high, checksf2x'low);
    checksf2  := "01000";               -- 16
    report_error ("Odd range signed high multiply", checksf2x, checksf2);
    checksf1  := "01000";               -- 0.125
    checksf2  := "00010";               -- 4
    checksf3  := resize (checksf1 * checksf2, checksf3'high, checksf3'low);
    checksf3x := to_sfixed (0.5, checksf3x'high, checksf3x'low);
    report_error ("Odd range signed mixed multiply", checksf3, checksf3x);
    checksf1  := to_sfixed (-0.125, checksf1'high, checksf1'low);
    checksf1x := resize (checksf1 * checksf1, checksf1x'high, checksf1x'low);
    checksf1  := "00001";               -- 0.015625
    report_error ("Odd range -signed low multiply", checksf1x, checksf1);
    checksf2  := to_sfixed (-4, checksf2'high, checksf2'low);
    checksf2x := resize (checksf2 * checksf2, checksf2x'high, checksf2x'low);
    checksf2  := "01000";               -- 16
    report_error ("Odd range -signed high multiply", checksf2x, checksf2);
    checksf1  := to_sfixed (-0.125, checksf1'high, checksf1'low);
    checksf2  := to_sfixed (-4, checksf2'high, checksf2'low);
    checksf3  := resize (checksf1 * checksf2, checksf3'high, checksf3'low);
    checksf3x := to_sfixed (0.5, checksf3x'high, checksf3x'low);
    report_error ("Odd range -signed mixed multiply", checksf3, checksf3x);
    -- Division
    checkuf1  := "1000";                -- 0.25 again
    checkuf1x := "0100";                -- 0.125
    checkuf2  := resize (checkuf1 / checkuf1x, checkuf2'high, checkuf2'low);
    checkuf2x := to_ufixed (0.25/0.125, checkuf2x'high, checkuf2x'low);
    report_error ("Odd range low divide", checkuf2, checkuf2x);
    checkuf2  := "0001";                -- 2
    checkuf2x := "1000";                -- 16
    checkuf1  := resize (checkuf2 / checkuf2x, checkuf1'high, checkuf1'low);
    checkuf1x := "0100";                -- 0.125
    report_error ("Odd range high divide", checkuf1, checkuf1x);
    checkuf1  := "1000";                -- 0.25 again
    checkuf2  := "0001";                -- 2
    checkuf1  := resize (checkuf1 / checkuf2, checkuf1x'high, checkuf1x'low);
    checkuf1x := "0100";                -- 0.125
    report_error ("Odd range low / high divide", checkuf1, checkuf1x);
    checkuf1  := "1000";                -- 0.25 again
    checkuf2  := "0001";                -- 2
    checkuf2  := resize (checkuf2 / checkuf1, checkuf2'high, checkuf2'low);
    checkuf2x := "0100";                -- 8
    report_error ("Odd range high / low divide", checkuf2, checkuf2x);
    -- signed
    checksf1  := "01000";               -- 0.125 again
    checksf1x := "00100";               -- 0.0625
    checksf2  := resize (checksf1 / checksf1x, checksf2'high, checksf2'low);
    checksf2x := to_sfixed (2, checksf2x'high, checksf2x'low);
    report_error ("Odd range s low divide", checksf2, checksf2x);
    checksf2  := "00001";               -- 2
    checksf2x := "01000";               -- 16
    checksf1  := resize (checksf2 / checksf2x, checksf1'high, checksf1'low);
    checksf1x := "01000";               -- 0.125
    report_error ("Odd range s high divide", checksf1, checksf1x);
    checksf1  := "01000";               -- 0.125 again
    checksf2  := "00001";               -- 2
    checksf1  := resize (checksf1 / checksf2, checksf1'high, checksf1'low);
    checksf1x := "00100";               -- 0.0625
    report_error ("Odd range s low / high divide", checksf1, checksf1x);
    checksf1  := "01000";               -- 0.125 again
    checksf2  := "00001";               -- 2
    checksf2  := resize (checksf2 / checksf1, checksf2'high, checksf2'low);
    checksf2x := "01000";               -- 16
    report_error ("Odd range s high / low divide", checksf2, checksf2x);
    checksf2  := "11111";               -- -2
    checksf2x := "01000";               -- 16
    checksf1  := resize (checksf2 / checksf2x, checksf1'high, checksf1'low);
    checksf1x := to_sfixed (-0.125, checksf1x'high, checksf1x'low);
    report_error ("Odd range -s high divide", checksf1, checksf1x);
    checksf2  := "00001";               -- 2
    checksf2x := "11000";               -- -16
    checksf1  := resize (checksf2 / checksf2x, checksf1'high, checksf1'low);
    checksf1x := to_sfixed (-0.125, checksf1x'high, checksf1x'low);
    report_error ("Odd range s- high divide", checksf1, checksf1x);
    checksf2  := "11111";               -- -2
    checksf2x := "11000";               -- -16
    checksf1  := resize (checksf2 / checksf2x, checksf1'high, checksf1'low);
    checksf1x := "01000";               -- 0.125
    report_error ("Odd range -s- high divide", checksf1, checksf1x);
    checksf1  := "01000";               -- 0.125 again
    checkint  := 1;
--    checksf3 := resize (checksf1 * checkint, checksf3);
--    report_error ("s odd range low * 1", checksf3, checksf1);
--    checksf3 := resize (checkint * checksf1, checksf3);
--    report_error ("s odd range 1 * low", checksf3, checksf1);
--    checksf3 := resize (checksf1 / checkint, checksf3);
--    report_error ("s odd range low / 1", checksf3, checksf1);
--    checksf3 := resize (checkint / checksf1, checksf3);
--    checksf3x := to_sfixed (8, checksf3x);
--    report_error ("s odd range 1 / low", checksf3, checksf3x);
    checksf1  := "01000";               -- 0.25
    checkreal := 1.0;
    if (not quiet) then
      report "Expect 4 to_sfixed(integer) bounds errors" severity note;
      checksf3  := resize (checksf1 * checkreal, checksf3);
      checksf3x := "0000000000010";     -- 0.001111 * 0.001000
      report_error ("odd range low * 1.0", checksf3, checksf3x);
      checksf3  := resize (checkreal * checksf1, checksf3);
      report_error ("odd range 1.0 * low", checksf3, checksf3x);
      checksf3  := resize (checksf1 / checkreal, checksf3);
      checksf3x := "0000000100000";     -- 0.001111 / 0.001000
      report_error ("odd range low / 1.0", checksf3, checksf3x);
      checksf3  := resize (checkreal / checksf1, checksf3);
      checksf3x := "0000001111000";     -- 0.001000 / 0.001111
      report_error ("odd range 1.0 / low", checksf3, checksf3x);
    end if;

-- Compare function test
    checkuf1 := "0010";
    assert (checkuf1 = checkuf1)
      report "odd low = odd low miscompare" severity error;
    assert not (checkuf1 /= checkuf1)
      report "odd low /= odd low miscompare" severity error;
    assert not (checkuf1 < checkuf1)
      report "odd low < odd low miscompare" severity error;
    assert not (checkuf1 > checkuf1)
      report "odd low > odd low miscompare" severity error;
    assert (checkuf1 <= checkuf1)
      report "odd low <= odd low miscompare" severity error;
    assert (checkuf1 >= checkuf1)
      report "odd low >= odd low miscompare" severity error;
    checkuf2 := "0010";
    assert (checkuf2 = checkuf2)
      report "odd high = odd high miscompare" severity error;
    assert not (checkuf2 /= checkuf2)
      report "odd high /= odd high miscompare" severity error;
    assert not (checkuf2 < checkuf2)
      report "odd high < odd high miscompare" severity error;
    assert not (checkuf2 > checkuf2)
      report "odd high > odd high miscompare" severity error;
    assert (checkuf2 <= checkuf2)
      report "odd high <= odd high miscompare" severity error;
    assert (checkuf2 >= checkuf2)
      report "odd high >= odd high miscompare" severity error;
    assert (checkuf1 /= checkuf2)
      report "odd low /= odd high miscompare" severity error;
    assert (checkuf1 < checkuf2)
      report "odd low /= odd high miscompare" severity error;
    assert (checkuf1 <= checkuf2)
      report "odd low /= odd high miscompare" severity error;
    assert not (checkuf1 = checkuf2)
      report "odd low = odd high miscompare" severity error;
    assert not (checkuf1 > checkuf2)
      report "odd low = odd high miscompare" severity error;
    assert not (checkuf1 >= checkuf2)
      report "odd low = odd high miscompare" severity error;
    checksf1 := "01000";
    assert (checksf1 = checksf1)
      report "odd low = odd low signed miscompare" severity error;
    assert not (checksf1 /= checksf1)
      report "odd low /= odd low signed msicompare" severity error;
    assert not (checksf1 < checksf1)
      report "odd low < odd low signed msicompare" severity error;
    assert not (checksf1 > checksf1)
      report "odd low > odd low signed msicompare" severity error;
    assert (checksf1 <= checksf1)
      report "odd low <= odd low signed msicompare" severity error;
    assert (checksf1 >= checksf1)
      report "odd low >= odd low signed msicompare" severity error;
    checksf2 := "00010";
    assert (checksf2 = checksf2)
      report "odd high = odd high signed msicompare" severity error;
    assert not (checksf2 /= checksf2)
      report "odd high /= odd high signed msicompare" severity error;
    assert not (checksf2 < checksf2)
      report "odd high < odd high signed msicompare" severity error;
    assert not (checksf2 > checksf2)
      report "odd high > odd high signed msicompare" severity error;
    assert (checksf2 <= checksf2)
      report "odd high <= odd high signed msicompare" severity error;
    assert (checksf2 >= checksf2)
      report "odd high >= odd high signed msicompare" severity error;
    assert (checksf1 /= checksf2)
      report "odd low /= odd high signed msicompare" severity error;
    assert (checksf1 < checksf2)
      report "odd low /= odd high signed msicompare" severity error;
    assert (checksf1 <= checksf2)
      report "odd low /= odd high signed msicompare" severity error;
    assert not (checksf1 = checksf2)
      report "odd low = odd high signed msicompare" severity error;
    assert not (checksf1 > checksf2)
      report "odd low = odd high signed msicompare" severity error;
    assert not (checksf1 >= checksf2)
      report "odd low = odd high signed msicompare" severity error;
    if (not quiet) then
      report "Expect 12 vector truncated warning messages" severity note;
      checkint := 1;
      checksf1 := "01000";              -- 0.125
      assert not (checkint = checksf1)
        report INTEGER'image(checkint) & " = " & to_string (checksf1) &
        " small signed returned true"
        severity error;
      assert (checkint /= checksf1)
        report INTEGER'image(checkint) & " /= " & to_string (checksf1) &
        " small signed returned false"
        severity error;
      assert not (checkint <= checksf1)
        report INTEGER'image(checkint) & " <= " & to_string (checksf1) &
        " small signed returned true"
        severity error;
      assert (checkint >= checksf1)
        report INTEGER'image(checkint) & " >= " & to_string (checksf1) &
        " small signed returned false"
        severity error;
      assert not (checkint < checksf1)
        report INTEGER'image(checkint) & " < " & to_string (checksf1) &
        " small signed returned true"
        severity error;
      assert (checkint > checksf1)
        report INTEGER'image(checkint) & " > " & to_string (checksf1) &
        " small signed returned false"
        severity error;
      assert not (checksf1 = checkint)
        report to_string (checksf1) & " = " & INTEGER'image(checkint) &
        " small signed returned true"
        severity error;
      assert (checksf1 /= checkint)
        report to_string (checksf1) & " /= " & INTEGER'image(checkint) &
        " small signed returned false"
        severity error;
      assert (checksf1 <= checkint)
        report to_string (checksf1) & " <= " & INTEGER'image(checkint) &
        " small signed returned false"
        severity error;
      assert not (checksf1 >= checkint)
        report to_string (checksf1) & " >= " & INTEGER'image(checkint) &
        " small signed returned true"
        severity error;
      assert (checksf1 < checkint)
        report to_string (checksf1) & " < " & INTEGER'image(checkint) &
        " small signed returned false"
        severity error;
      assert not (checksf1 > checkint)
        report to_string (checksf1) & " > " & INTEGER'image(checkint) &
        " small signed returned true"
        severity error;
    end if;
--    checkint := -1;
--    checksf1 := "01000";                -- 0.125
--    assert not (checkint = checksf1)
--      report integer'image(checkint) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint /= checksf1)
--      report integer'image(checkint) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert (checkint <= checksf1)
--      report integer'image(checkint) & " <= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkint >= checksf1)
--      report integer'image(checkint) & " >= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint < checksf1)
--      report integer'image(checkint) & " < " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkint > checksf1)
--      report integer'image(checkint) & " > " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert not (checksf1 = checkint)
--      report  to_string (checksf1) & " = " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkint)
--      report  to_string (checksf1) & " /= " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 <= checkint)
--      report  to_string (checksf1) & " <= " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 >= checkint)
--      report  to_string (checksf1) & " >= " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 < checkint)
--      report  to_string (checksf1) & " < " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 > checkint)
--      report  to_string (checksf1) & " > " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    checkint := 1;
--    checksf1 := "10000";                -- -0.25
--    assert not (checkint = checksf1)
--      report integer'image(checkint) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint /= checksf1)
--      report integer'image(checkint) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkint <= checksf1)
--      report integer'image(checkint) & " <= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint >= checksf1)
--      report integer'image(checkint) & " >= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkint < checksf1)
--      report integer'image(checkint) & " < " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint > checksf1)
--      report integer'image(checkint) & " > " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 = checkint)
--      report  to_string (checksf1) & " = " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkint)
--      report  to_string (checksf1) & " /= " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert (checksf1 <= checkint)
--      report  to_string (checksf1) & " <= " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 >= checkint)
--      report  to_string (checksf1) & " >= " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 < checkint)
--      report  to_string (checksf1) & " < " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 > checkint)
--      report  to_string (checksf1) & " > " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    checkint := -1;
--    checksf1 := "10000";                -- -0.25
--    assert not (checkint = checksf1)
--      report integer'image(checkint) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint /= checksf1)
--      report integer'image(checkint) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert (checkint <= checksf1)
--      report integer'image(checkint) & " <= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkint >= checksf1)
--      report integer'image(checkint) & " >= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkint < checksf1)
--      report integer'image(checkint) & " < " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkint > checksf1)
--      report integer'image(checkint) & " > " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert not (checksf1 = checkint)
--      report  to_string (checksf1) & " = " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkint)
--      report  to_string (checksf1) & " /= " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 <= checkint)
--      report  to_string (checksf1) & " <= " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 >= checkint)
--      report  to_string (checksf1) & " >= " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 < checkint)
--      report  to_string (checksf1) & " < " & integer'image(checkint) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 > checkint)
--      report  to_string (checksf1) & " > " & integer'image(checkint) &
--      " small signed returned false"
--      severity error;
    -- zero test
    checkint := 0;
    checksf1 := "00000";
    assert (checkint = checksf1)
      report INTEGER'image(checkint) & " = " & to_string (checksf1) &
      " small signed returned false"
      severity error;
    assert not (checkint /= checksf1)
      report INTEGER'image(checkint) & " /= " & to_string (checksf1) &
      " small signed returned true"
      severity error;
    assert (checkint <= checksf1)
      report INTEGER'image(checkint) & " <= " & to_string (checksf1) &
      " small signed returned false"
      severity error;
    assert (checkint >= checksf1)
      report INTEGER'image(checkint) & " >= " & to_string (checksf1) &
      " small signed returned false"
      severity error;
    assert not (checkint < checksf1)
      report INTEGER'image(checkint) & " < " & to_string (checksf1) &
      " small signed returned true"
      severity error;
    assert not (checkint > checksf1)
      report INTEGER'image(checkint) & " > " & to_string (checksf1) &
      " small signed returned true"
      severity error;
    assert (checksf1 = checkint)
      report to_string (checksf1) & " = " & INTEGER'image(checkint) &
      " small signed returned false"
      severity error;
    assert not (checksf1 /= checkint)
      report to_string (checksf1) & " /= " & INTEGER'image(checkint) &
      " small signed returned true"
      severity error;
    assert (checksf1 <= checkint)
      report to_string (checksf1) & " <= " & INTEGER'image(checkint) &
      " small signed returned false"
      severity error;
    assert (checksf1 >= checkint)
      report to_string (checksf1) & " >= " & INTEGER'image(checkint) &
      " small signed returned false"
      severity error;
    assert not (checksf1 < checkint)
      report to_string (checksf1) & " < " & INTEGER'image(checkint) &
      " small signed returned true"
      severity error;
    assert not (checksf1 > checkint)
      report to_string (checksf1) & " > " & INTEGER'image(checkint) &
      " small signed returned true"
      severity error;
    -- with a real
--    checkreal := 0.25;                  -- too big, not overflow
--    checksf1 := "01000";                -- 0.125
--    assert not (checkreal = checksf1)
--      report real'image(checkreal) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal /= checksf1)
--      report real'image(checkreal) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal <= checksf1)
--      report real'image(checkreal) & " <= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal >= checksf1)
--      report real'image(checkreal) & " >= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal < checksf1)
--      report real'image(checkreal) & " < " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal > checksf1)
--      report real'image(checkreal) & " > " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 = checkreal)
--      report  to_string (checksf1) & " = " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkreal)
--      report  to_string (checksf1) & " /= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert (checksf1 <= checkreal)
--      report  to_string (checksf1) & " <= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 >= checkreal)
--      report  to_string (checksf1) & " >= " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 < checkreal)
--      report  to_string (checksf1) & " < " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 > checkreal)
--      report  to_string (checksf1) & " > " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    checkreal := -0.5;
--    checksf1 := "01000";                -- 0.125
--    assert not (checkreal = checksf1)
--      report real'image(checkreal) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal /= checksf1)
--      report real'image(checkreal) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert (checkreal <= checksf1)
--      report real'image(checkreal) & " <= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal >= checksf1)
--      report real'image(checkreal) & " >= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal < checksf1)
--      report real'image(checkreal) & " < " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal > checksf1)
--      report real'image(checkreal) & " > " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert not (checksf1 = checkreal)
--      report  to_string (checksf1) & " = " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkreal)
--      report  to_string (checksf1) & " /= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 <= checkreal)
--      report  to_string (checksf1) & " <= " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 >= checkreal)
--      report  to_string (checksf1) & " >= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 < checkreal)
--      report  to_string (checksf1) & " < " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 > checkreal)
--      report  to_string (checksf1) & " > " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    checkreal := 0.25;
--    checksf1 := "10000";                -- -0.25
--    assert not (checkreal = checksf1)
--      report real'image(checkreal) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal /= checksf1)
--      report real'image(checkreal) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal <= checksf1)
--      report real'image(checkreal) & " <= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal >= checksf1)
--      report real'image(checkreal) & " >= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal < checksf1)
--      report real'image(checkreal) & " < " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal > checksf1)
--      report real'image(checkreal) & " > " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 = checkreal)
--      report  to_string (checksf1) & " = " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkreal)
--      report  to_string (checksf1) & " /= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert (checksf1 <= checkreal)
--      report  to_string (checksf1) & " <= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 >= checkreal)
--      report  to_string (checksf1) & " >= " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 < checkreal)
--      report  to_string (checksf1) & " < " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 > checkreal)
--      report  to_string (checksf1) & " > " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    checkreal := -0.5;
--    checksf1 := "10000";                -- -0.25
--    assert not (checkreal = checksf1)
--      report real'image(checkreal) & " = " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal /= checksf1)
--      report real'image(checkreal) & " /= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert (checkreal <= checksf1)
--      report real'image(checkreal) & " <= " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal >= checksf1)
--      report real'image(checkreal) & " >= " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert (checkreal < checksf1)
--      report real'image(checkreal) & " < " & to_string (checksf1) &
--      " small signed returned false"
--      severity error;
--    assert not (checkreal > checksf1)
--      report real'image(checkreal) & " > " & to_string (checksf1) &
--      " small signed returned true"
--      severity error;
--    assert not (checksf1 = checkreal)
--      report  to_string (checksf1) & " = " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 /= checkreal)
--      report  to_string (checksf1) & " /= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 <= checkreal)
--      report  to_string (checksf1) & " <= " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 >= checkreal)
--      report  to_string (checksf1) & " >= " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
--    assert not (checksf1 < checkreal)
--      report  to_string (checksf1) & " < " & real'image(checkreal) &
--      " small signed returned true"
--      severity error;
--    assert (checksf1 > checkreal)
--      report  to_string (checksf1) & " > " & real'image(checkreal) &
--      " small signed returned false"
--      severity error;
    -- zero test
    checkreal := 0.0;
    checksf1  := "00000";
    assert (checkreal = checksf1)
      report REAL'image(checkreal) & " = " & to_string (checksf1) &
      " small signed returned false"
      severity error;
    assert not (checkreal /= checksf1)
      report REAL'image(checkreal) & " /= " & to_string (checksf1) &
      " small signed returned true"
      severity error;
    assert (checkreal <= checksf1)
      report REAL'image(checkreal) & " <= " & to_string (checksf1) &
      " small signed returned false"
      severity error;
    assert (checkreal >= checksf1)
      report REAL'image(checkreal) & " >= " & to_string (checksf1) &
      " small signed returned false"
      severity error;
    assert not (checkreal < checksf1)
      report REAL'image(checkreal) & " < " & to_string (checksf1) &
      " small signed returned true"
      severity error;
    assert not (checkreal > checksf1)
      report REAL'image(checkreal) & " > " & to_string (checksf1) &
      " small signed returned true"
      severity error;
    assert (checksf1 = checkreal)
      report to_string (checksf1) & " = " & REAL'image(checkreal) &
      " small signed returned false"
      severity error;
    assert not (checksf1 /= checkreal)
      report to_string (checksf1) & " /= " & REAL'image(checkreal) &
      " small signed returned true"
      severity error;
    assert (checksf1 <= checkreal)
      report to_string (checksf1) & " <= " & REAL'image(checkreal) &
      " small signed returned false"
      severity error;
    assert (checksf1 >= checkreal)
      report to_string (checksf1) & " >= " & REAL'image(checkreal) &
      " small signed returned false"
      severity error;
    assert not (checksf1 < checkreal)
      report to_string (checksf1) & " < " & REAL'image(checkreal) &
      " small signed returned true"
      severity error;
    assert not (checksf1 > checkreal)
      report to_string (checksf1) & " > " & REAL'image(checkreal) &
      " small signed returned true"
      severity error;
    
    checkuf1x := "1000";
    checkstr  := to_string(checkuf1x);
    checkstr2 := "0.01000";
    assert checkstr = checkstr2 report "odd low to_string "
      & checkstr & " /= " & checkstr2 severity error;
    assert to_ostring(checkuf1x) = "0.20" report "odd low to_ostring "
      & to_string(checkuf1x) & " /= " & to_ostring(checkuf1x) severity error;
    assert to_hstring(checkuf1x) = "0.40" report "odd low to_hstring "
      & to_string(checkuf1x) & " /= " & to_hstring(checkuf1x) severity error;
    checkuf1x := "ZZZZ";
    checkstr  := to_string(checkuf1x);
    checkstr2 := "Z.ZZZZZ";
    assert checkstr = checkstr2 report "odd low Z to_string "
      & checkstr & " /= " & checkstr2 severity error;
    assert to_ostring(checkuf1x) = "Z.ZZ" report "odd low Z to_ostring "
      & to_string(checkuf1x) & " /= " & to_ostring(checkuf1x) severity error;
    assert to_hstring(checkuf1x) = "Z.ZZ" report "odd low Z to_hstring "
      & to_string(checkuf1x) & " /= " & to_hstring(checkuf1x) severity error;
    
    checkuf2x := "1000";
    checkstr  := to_string(checkuf2x);
    checkstr2 := "10000.0";
    assert checkstr = checkstr2 report "odd high to_string "
      & checkstr & " /= " & checkstr2 severity error;
    assert to_ostring(checkuf2x) = "20.0" report "odd high to_ostring "
      & to_string(checkuf2x) & " /= " & to_ostring(checkuf2x) severity error;
    assert to_hstring(checkuf2x) = "10.0" report "odd high to_hstring "
      & to_string(checkuf2x) & " /= " & to_hstring(checkuf2x) severity error;
    -- to_string Z test, low
    checkuf2x := "ZZZZ";
    checkstr  := to_string(checkuf2x);
    checkstr2 := "ZZZZZ.Z";
    assert checkstr = checkstr2 report "odd high Z to_string "
      & checkstr & " /= " & checkstr2 severity error;
    assert to_ostring(checkuf2x) = "ZZ.Z" report "odd high Z to_ostring "
      & to_string(checkuf2x) & " /= " & to_ostring(checkuf2x) severity error;
    assert to_hstring(checkuf2x) = "ZZ.Z" report "odd high Z to_hstring "
      & to_string(checkuf2x) & " /= " & to_hstring(checkuf2x) severity error;
    -- to_string test, low number
    checksf1x  := "01000";
    checksstr  := to_string(checksf1x);
    checksstr2 := "0.001000";
    assert checksstr = checksstr2 report "odd low signed to_string "
      & checksstr & " /= " & checksstr2 severity error;
    assert to_ostring(checksf1x) = "0.10" report "odd low signed to_ostring "
      & to_string(checksf1x) & " /= " & to_ostring(checksf1x) severity error;
    assert to_hstring(checksf1x) = "0.20" report "odd low signed to_hstring "
      & to_string(checksf1x) & " /= " & to_hstring(checksf1x) severity error;
    -- to_string Z test, high
    checksf1x  := "ZZZZZ";
    checksstr  := to_string(checksf1x);
    checksstr2 := "Z.ZZZZZZ";
    assert checksstr = checksstr2 report "odd low signed Z to_string "
      & checksstr & " /= " & checksstr2 severity error;
    assert to_ostring(checksf1x) = "Z.ZZ" report "odd low signed Z to_ostring "
      & to_string(checksf1x) & " /= " & to_ostring(checksf1x) severity error;
    assert to_hstring(checksf1x) = "Z.ZZ" report "odd low signed Z to_hstring "
      & to_string(checksf1x) & " /= " & to_hstring(checksf1x) severity error;

    checksf2x := "01000";
    checksstr  := to_string(checksf2x);
    checksstr2 := "010000.0";
    assert checksstr = checksstr2 report "odd high signed to_string "
      & checksstr & " /= " & checksstr2 severity error;
    assert to_ostring(checksf2x) = "20.0" report "odd high signed to_ostring "
      & to_string(checksf2x) & " /= " & to_ostring(checksf2x) severity error;
    assert to_hstring(checksf2x) = "10.0" report "odd high signed to_hstring "
      & to_string(checksf2x) & " /= " & to_hstring(checksf2x) severity error;
    -- Z signed odd range (large) signed to_string test
    checksf2x := "ZZZZZ";
    checksstr  := to_string(checksf2x);
    checksstr2 := "ZZZZZZ.Z";
    assert checksstr = checksstr2 report "odd high signed Z to_string "
      & checksstr & " /= " & checksstr2 severity error;
    assert to_ostring(checksf2x) = "ZZ.Z" report "odd high signed Z to_ostring "
      & to_string(checksf2x) & " /= " & to_ostring(checksf2x) severity error;
    assert to_hstring(checksf2x) = "ZZ.Z" report "odd high signed Z to_hstring "
      & to_string(checksf2x) & " /= " & to_hstring(checksf2x) severity error;
    -- sign extend test, low
    checksf1x  := "11000";
    checksstr  := to_string(checksf1x);
    checksstr2 := "1.111000";
    assert checksstr = checksstr2 report "-odd low signed to_string "
      & checksstr & " /= " & checksstr2 severity error;
    assert to_ostring(checksf1x) = "7.70" report "-odd low signed to_ostring "
      & to_string(checksf1x) & " /= " & to_ostring(checksf1x) severity error;
    assert to_hstring(checksf1x) = "F.E0" report "-odd low signed to_hstring "
      & to_string(checksf1x) & " /= " & to_hstring(checksf1x) severity error;
    -- sign extend test, high
    checksf2x  := "10110";
    checksstr  := to_string(checksf2x);
    checksstr2 := "101100.0";
    assert checksstr = checksstr2 report "-odd high signed to_string "
      & checksstr & " /= " & checksstr2 severity error;
    assert to_ostring(checksf2x) = "54.0" report "-odd high signed to_ostring "
      & to_string(checksf2x) & " /= " & to_ostring(checksf2x) severity error;
    assert to_hstring(checksf2x) = "EC.0" report "-odd high signed to_hstring "
      & to_string(checksf2x) & " /= " & to_hstring(checksf2x) severity error;
    checkuf1  := "0100";
    checkuf1x := checkuf1 sll 1;
    checkuf1  := "1000";
    report_error ("odd range sll", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 srl 1;
    checkuf1  := "0010";
    report_error ("odd range srl", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 sll -1;
    checkuf1  := "0010";
    report_error ("odd range -sll", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 srl -1;
    checkuf1  := "1000";
    report_error ("odd range -srl", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 sla 1;
    checkuf1  := "1000";
    report_error ("odd range sla", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 sra 1;
    checkuf1  := "0010";
    report_error ("odd range sra", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 sla -1;
    checkuf1  := "0010";
    report_error ("odd range -sla", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 sra -1;
    checkuf1  := "1000";
    report_error ("odd range -sra", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 rol 1;
    checkuf1  := "1000";
    report_error ("odd range rol", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 ror 1;
    checkuf1  := "0010";
    report_error ("odd range ror", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 rol -1;
    checkuf1  := "0010";
    report_error ("odd range -rol", checkuf1x, checkuf1);
    checkuf1  := "0100";
    checkuf1x := checkuf1 ror -1;
    checkuf1  := "1000";
    report_error ("odd range -ror", checkuf1x, checkuf1);
    -- signed
    checksf1  := "01000";
    checksf1x := checksf1 sll 1;
    checksf1  := "10000";
    report_error ("Signed odd range sll", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 srl 1;
    checksf1  := "00100";
    report_error ("Signed odd range srl", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 sll -1;
    checksf1  := "00100";
    report_error ("Signed odd range -sll", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 srl -1;
    checksf1  := "10000";
    report_error ("Signed odd range -srl", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 sla 1;
    checksf1  := "10000";
    report_error ("Signed odd range sla", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 sra 1;
    checksf1  := "00100";
    report_error ("Signed odd range sra", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 sla -1;
    checksf1  := "00100";
    report_error ("Signed odd range -sla", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 sra -1;
    checksf1  := "10000";
    report_error ("Signed odd range -sra", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 rol 1;
    checksf1  := "10000";
    report_error ("Signed odd range rol", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 ror 1;
    checksf1  := "00100";
    report_error ("Signed odd range ror", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 rol -1;
    checksf1  := "00100";
    report_error ("Signed odd range -rol", checksf1x, checksf1);
    checksf1  := "01000";
    checksf1x := checksf1 ror -1;
    checksf1  := "10000";
    report_error ("Signed odd range -ror", checksf1x, checksf1);
    -- positive range
    checkuf2  := "0100";
    checkuf2x := checkuf2 sll 1;
    checkuf2  := "1000";
    report_error ("odd range sll", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 srl 1;
    checkuf2  := "0010";
    report_error ("odd range srl", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 sll -1;
    checkuf2  := "0010";
    report_error ("odd range -sll", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 srl -1;
    checkuf2  := "1000";
    report_error ("odd range -srl", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 sla 1;
    checkuf2  := "1000";
    report_error ("odd range sla", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 sra 1;
    checkuf2  := "0010";
    report_error ("odd range sra", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 sla -1;
    checkuf2  := "0010";
    report_error ("odd range -sla", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 sra -1;
    checkuf2  := "1000";
    report_error ("odd range -sra", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 rol 1;
    checkuf2  := "1000";
    report_error ("odd range rol", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 ror 1;
    checkuf2  := "0010";
    report_error ("odd range ror", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 rol -1;
    checkuf2  := "0010";
    report_error ("odd range -rol", checkuf2x, checkuf2);
    checkuf2  := "0100";
    checkuf2x := checkuf2 ror -1;
    checkuf2  := "1000";
    report_error ("odd range -ror", checkuf2x, checkuf2);
    -- signed
    checksf2  := "01000";
    checksf2x := checksf2 sll 1;
    checksf2  := "10000";
    report_error ("Signed odd range sll", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 srl 1;
    checksf2  := "00100";
    report_error ("Signed odd range srl", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 sll -1;
    checksf2  := "00100";
    report_error ("Signed odd range -sll", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 srl -1;
    checksf2  := "10000";
    report_error ("Signed odd range -srl", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 sla 1;
    checksf2  := "10000";
    report_error ("Signed odd range sla", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 sra 1;
    checksf2  := "00100";
    report_error ("Signed odd range sra", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 sla -1;
    checksf2  := "00100";
    report_error ("Signed odd range -sla", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 sra -1;
    checksf2  := "10000";
    report_error ("Signed odd range -sra", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 rol 1;
    checksf2  := "10000";
    report_error ("Signed odd range rol", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 ror 1;
    checksf2  := "00100";
    report_error ("Signed odd range ror", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 rol -1;
    checksf2  := "00100";
    report_error ("Signed odd range -rol", checksf2x, checksf2);
    checksf2  := "01000";
    checksf2x := checksf2 ror -1;
    checksf2  := "10000";
    report_error ("Signed odd range -ror", checksf2x, checksf2);
    -- find msb test
    checkuf1  := "0100";
    checkint  := find_leftmost (checkuf1, '1');
    assert (checkint = -3) report "find_leftmost, -3 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf1) severity error;
    checkuf1 := "0100";
    checkint := find_rightmost (checkuf1, '1');
    assert (checkint = -3) report "find_rightmost, -3 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf1) severity error;
    checkuf1 := "0000";
    checkint := find_leftmost (checkuf1, '1');
    assert (checkint = -6) report "find_leftmost, -6 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf1) severity error;
    checkuf1 := "0000";
    checkint := find_rightmost (checkuf1, '1');
    assert (checkint = -1) report "find_rightmost, -1 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf1) severity error;
    -- signed
    checksf1 := "01000";
    checkint := find_leftmost (checksf1, '1');
    assert (checkint = -3)
      report "signed find_leftmost, -3 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf1) severity error;
    checksf1 := "01000";
    checkint := find_rightmost (checksf1, '1');
    assert (checkint = -3)
      report "signed find_rightmost, -3 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf1) severity error;
    checksf1 := "00000";
    checkint := find_leftmost (checksf1, '1');
    assert (checkint = -7)
      report "signed find_leftmost, -7 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf1) severity error;
    checksf1 := "00000";
    checkint := find_rightmost (checksf1, '1');
    assert (checkint = -1)
      report "signed find_rightmost, -1 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf1) severity error;
    -- High only test
    checkuf2 := "0100";
    checkint := find_leftmost (checkuf2, '1');
    assert (checkint = 3) report "find_leftmost, 3 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf2) severity error;
    checkuf2 := "0100";
    checkint := find_rightmost (checkuf2, '1');
    assert (checkint = 3) report "find_rightmost, 3 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf2) severity error;
    checkuf2 := "0000";
    checkint := find_leftmost (checkuf2, '1');
    assert (checkint = 0) report "find_leftmost, 0 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf2) severity error;
    checkuf2 := "0000";
    checkint := find_rightmost (checkuf2, '1');
    assert (checkint = 5) report "find_rightmost, 5 /= " & INTEGER'image(checkint)
      & " from " & to_string (checkuf2) severity error;
    -- signed
    checksf2 := "01000";
    checkint := find_leftmost (checksf2, '1');
    assert (checkint = 4)
      report "signed find_leftmost, 4 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf2) severity error;
    checksf2 := "01000";
    checkint := find_rightmost (checksf2, '1');
    assert (checkint = 4)
      report "signed find_rightmost, 4 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf2) severity error;
    checksf2 := "00000";
    checkint := find_leftmost (checksf2, '1');
    assert (checkint = 0)
      report "signed find_leftmost, 0 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf2) severity error;
    checksf2 := "00000";
    checkint := find_rightmost (checksf2, '1');
    assert (checkint = 6)
      report "signed find_rightmost, 6 /= " & INTEGER'image(checkint)
      & " from " & to_string (checksf2) severity error;
    assert (quiet) report "Odd range test completed" severity note;
    oddrangetest_done <= true;
    wait;
  end process oddrange;


  -- purpose: Check to make sure meta numbers (X, H, W, etc) are done right
  metanumbertest : process is
    variable checkint                        : INTEGER;
    variable checkreal                       : REAL;
    variable checkuns                        : UNSIGNED (6 downto 0);
    variable checksns                        : SIGNED (6 downto 0);
    variable check7uf1, check7uf2, check7uf3 : ufixed7_3;
    variable check8uf                        : ufixed (4 downto -3);  -- ufixed7_3 + ufixed7_3
    variable check7sf1, check7sf2, check7sf3 : sfixed7_3;
    variable check8sf                        : sfixed (4 downto -3);  -- sfixed7_3 + sfixed7_3
    variable check7slv1, check7slv2 :
      STD_LOGIC_VECTOR (check7uf1'length-1 downto 0);   -- slv
    variable check8slv1, check8slv2 :
      STD_LOGIC_VECTOR (check8uf'length-1 downto 0);    -- slv
    variable soutslv : STD_LOGIC_VECTOR (13 downto 0);  -- long slv
    variable ZOutRef : STD_ULOGIC_VECTOR (13 downto 0);
    variable unull   : ufixed (-1 downto 1);            -- Null range
    variable snull   : sfixed (-1 downto 1);            -- Null range
  begin  -- process metanumbertest
    wait until start_metanumbertest;
    check7uf1  := "LLHHHLL";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7uf3  := "0011100";
    report_error ("HandL add", check8uf, check7uf3);
    check7uf1  := "001X100";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7slv2 := to_slv (check8uf (check7uf1'range));
    check7slv1 := (others => 'X');
    assert (check7slv2 = check7slv1)
      report "Meta add X " & to_string (check7uf1)
      & " + 0 /= " & to_string (check8uf) severity error;
    check7uf1  := "001U100";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7slv2 := to_slv (check8uf (check7uf1'range));
    check7slv1 := (others => 'X');
    assert (check7slv2 = check7slv1)
      report "Meta add U " & to_string (check7uf1)
      & " + 0 /= " & to_string (check8uf) severity error;
    check7uf1  := "001W100";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7slv2 := to_slv (check8uf (check7uf1'range));
    check7slv1 := (others => 'X');
    assert (check7slv2 = check7slv1)
      report "Meta add W " & to_string (check7uf1)
      & " + 0 /= " & to_string (check8uf) severity error;
    check7uf1  := "001Z100";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7slv2 := to_slv (check8uf (check7uf1'range));
    check7slv1 := (others => 'X');
    assert (check7slv2 = check7slv1)
      report "Meta add Z " & to_string (check7uf1)
      & " + 0 /= " & to_string (check8uf) severity error;
    check7uf1  := "001-100";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7slv2 := to_slv (check8uf (check7uf1'range));
    check7slv1 := (others => 'X');
    assert (check7slv2 = check7slv1)
      report "Meta add - " & to_string (check7uf1)
      & " + 0 /= " & to_string (check8uf) severity error;
    check7uf1  := "001X100";
    check7uf2  := "0000000";
    check8uf   := check7uf1 + check7uf2;
    check7slv2 := to_slv (check8uf (check7uf1'range));
    check7slv1 := (others => 'X');
    assert (check7slv2 = check7slv1)
      report "Meta add X " & to_string (check7uf1)
      & " + 0 /= " & to_string (check8uf) severity error;
    if (not quiet) then
      check7uf1 := "001X100";
      report "Expect to_integer meta value error here" severity note;
      checkint  := to_integer (check7uf1);
      assert (checkint = 0)
        report "to_integer meta value " & to_string (check7uf1)
        & " /= " & INTEGER'image(checkint) severity error;
      report "Expect to_real meta value error here" severity note;
      checkreal := to_real (check7uf1);
      assert (checkreal = 0.0)
        report "to_real meta value " & to_string (check7uf1)
        & " /= " & REAL'image(checkreal) severity error;
      check7sf1 := "001X100";
      report "Expect to_integer meta value error here" severity note;
      checkint  := to_integer (check7sf1);
      assert (checkint = 0)
        report "s to_integer meta value " & to_string (check7sf1)
        & " /= " & INTEGER'image(checkint) severity error;
      report "Expect to_real meta value error here" severity note;
      checkreal := to_real (check7sf1);
      assert (checkreal = 0.0)
        report "s to_real meta value " & to_string (check7sf1)
        & " /= " & REAL'image(checkreal) severity error;
    end if;

    check7sf1  := "001X100";
    check8sf   := - check7sf1;
    check8slv1 := to_slv (check8sf);
    check8slv2 := (others => 'X');
    assert (check8slv1 = check8slv2)
      report "Meta value - " & to_string (check7sf1)
      & " /= " & to_string (check8sf) severity error;
    check7sf1  := "001X100";
    check8sf   := abs(check7sf1);
    check8slv2 := to_slv (check8sf);
    check8slv1 := (others => 'X');
    assert (check8slv2 = check8slv1)
      report "Meta value abs " & to_string (check7sf1)
      & " /= " & to_string (check8sf) severity error;

    -- SLV conversion test
    ZOutRef := to_stdULogicVector(to_slv(to_sfixed(0.0, 1, -12)));
    assert (ZOutRef = "00000000000000")
      report "to_sulv(to_slv(to_sfixed(0))) problem "
      severity error;
    soutslv := "00010000000000";        -- 13 bit slv
    check7uf1 := to_ufixed (
      soutslv(soutslv'high downto soutslv'high - (check7uf1'length-1)),
      check7uf1'high, check7uf1'low);
    check7uf2 := "0001000";
    report_error ("long slv to ufixed text", check7uf1, check7uf2);
    check7sf1 := to_sfixed (
      soutslv(soutslv'high downto soutslv'high - (check7uf1'length-1)),
      check7sf1'high, check7sf1'low);
    check7sf2 := "0001000";
    report_error ("long slv to sfixed text", check7sf1, check7sf2);
    -- check the error processing in the to_ufixed(slv) function
    if (not quiet) then
      report "Expect 2 length errors from the to_ufixed(slv) function"
        severity note;
      unull := to_ufixed (soutslv, 4, -3);
      unull := to_ufixed (soutslv, 13, -13);
      report "Expect 2 length errors from the to_sfixed(slv) function"
        severity note;
      snull := to_sfixed (soutslv, 4, -3);
      snull := to_sfixed (soutslv, 13, -13);
    end if;

    assert (quiet) report "Meta number test completed" severity note;
    metanumbertest_done <= true;
    wait;
  end process metanumbertest;

  -- purpose: .M file converstion test, to test the section which allows
  -- formats similiar to the conventions used in Simulink
  -- type   : combinational
  mconvtest : process is
    variable checkuns : STD_LOGIC_VECTOR (6 downto 0);
    variable checksns : STD_LOGIC_VECTOR (6 downto 0);
    variable check7uf1, check7uf2, check7uf3 : ufixed (
      UFix_high (ufixed7_3'length, -ufixed7_3'low) downto
      UFix_low (ufixed7_3'length, -ufixed7_3'low));
    variable check7ufp7 : ufixed (
      UFix_high (check7uf1'length, -check7uf1'low, '+',
                 check7uf1'length, -check7uf1'low) downto
      UFix_low (check7uf1'length, -check7uf1'low, '+',
                check7uf1'length, -check7uf1'low));  -- ufixed7_3 + ufixed7_3
    variable check7ufm7 : ufixed (
      UFix_high (check7uf1'length, -check7uf1'low, '*',
                 check7uf1'length, -check7uf1'low) downto
      UFix_low (check7uf1'length, -check7uf1'low, '*',
                check7uf1'length, -check7uf1'low));  -- ufixed7_3 * ufixed7_3
    variable check7ufmi7 : ufixed (
      UFix_high (check7uf1'length, -check7uf1'low, '-',
                 check7uf1'length, -check7uf1'low) downto
      UFix_low (check7uf1'length, -check7uf1'low, '-',
                check7uf1'length, -check7uf1'low));  -- ufixed7_3 - ufixed7_3
    variable check7ufd7 : ufixed (
      UFix_high (check7uf1'length, -check7uf1'low, '/',
                 check7uf1'length, -check7uf1'low) downto
      UFix_low (check7uf1'length, -check7uf1'low, '/',
                check7uf1'length, -check7uf1'low));  -- ufixed7_3 / ufixed7_3
    variable check7ufmod7 : ufixed (
      UFix_high (check7uf1'length, -check7uf1'low, 'm',
                 check7uf1'length, -check7uf1'low) downto
      UFix_low (check7uf1'length, -check7uf1'low, 'm',
                check7uf1'length, -check7uf1'low));  -- ufixed7_3 mod ufixed7_3
    variable check7ufrem7 : ufixed (
      UFix_high (check7uf1'length, -check7uf1'low, 'r',
                 check7uf1'length, -check7uf1'low) downto
      UFix_low (check7uf1'length, -check7uf1'low, 'r',
                check7uf1'length, -check7uf1'low));  -- ufixed7_3 rem ufixed7_3
    variable check7sf1, check7sf2, check7sf3 : sfixed (
      SFix_high (sfixed7_3'length-1, -sfixed7_3'low) downto
      SFix_low (sfixed7_3'length-1, -sfixed7_3'low));
    variable check7sfp7 : sfixed (
      SFix_high (check7sf1'length-1, -check7sf1'low, '+',
                 check7sf1'length-1, -check7sf1'low) downto
      SFix_low (check7sf1'length-1, -check7sf1'low, '+',
                check7sf1'length-1, -check7sf1'low));  -- sfixed7_3 + sfixed7_3
    variable check7sfmi7 : sfixed (
      SFix_high (check7sf1'length-1, -check7sf1'low, '-',
                 check7sf1'length-1, -check7sf1'low) downto
      SFix_low (check7sf1'length-1, -check7sf1'low, '-',
                check7sf1'length-1, -check7sf1'low));  -- sfixed7_3 - sfixed7_3
    variable check7sfm7 : sfixed (
      SFix_high (check7sf1'length-1, -check7sf1'low, '*',
                 check7sf1'length-1, -check7sf1'low) downto
      SFix_low (check7sf1'length-1, -check7sf1'low, '*',
                check7sf1'length-1, -check7sf1'low));  -- sfixed7_3 * sfixed7_3
    variable check7sfd7 : sfixed (
      SFix_high (check7sf1'length-1, -check7sf1'low, '/',
                 check7sf1'length-1, -check7sf1'low) downto
      SFix_low (check7sf1'length-1, -check7sf1'low, '/',
                check7sf1'length-1, -check7sf1'low));  -- sfixed7_3 / sfixed7_3
    variable check7sfmod7 : sfixed (
      SFix_high (check7sf1'length-1, -check7sf1'low, 'm',
                 check7sf1'length-1, -check7sf1'low) downto
      SFix_low (check7sf1'length-1, -check7sf1'low, 'M',
                check7sf1'length-1, -check7sf1'low));  -- sfixed7_3 mod sfixed7_3
    variable check7sfrem7 : sfixed (
      SFix_high (check7sf1'length-1, -check7sf1'low, 'r',
                 check7sf1'length-1, -check7sf1'low) downto
      SFix_low (check7sf1'length-1, -check7sf1'low, 'R',
                check7sf1'length-1, -check7sf1'low));  -- sfixed7_3 rem sfixed7_3
    variable x_slv  : STD_LOGIC_VECTOR(15 downto 0);   -- 16-bits
    variable x_sfix : sfixed(1 downto -14);  -- 16-bits, = [1]si.ffffffffffffff[-14]
    variable check7slv1, check7slv2 :
      STD_LOGIC_VECTOR (check7uf1'length-1 downto 0);  -- slv
    variable soutslv : STD_LOGIC_VECTOR (13 downto 0);  -- long slv
    variable unull   : ufixed (-1 downto 1);         -- Null range
    variable snull   : sfixed (-1 downto 1);         -- Null range
  begin
    wait until start_mconvtest;
    check7slv1 := "0001000";
    check7uf1  := to_UFix (check7slv1, 7, 3);
    report_error ("to_UFix test", check7uf1,
                  to_ufixed (1, check7uf1'high, check7uf1'low));
    checkuns  := "0001000";
    check7uf1 := to_UFix (checkuns, 7, 3);
    report_error ("to_UFix test", check7uf1,
                  to_ufixed (1, check7uf1'high, check7uf1'low));
    check7slv1 := "0001000";
    check7sf1  := to_SFix (check7slv1, 7, 3);
    report_error ("to_Fix test", check7sf1,
                  to_sfixed (1, check7sf1'high, check7sf1'low));
    checksns  := "0001000";
    check7sf1 := to_SFix (checksns, 7, 3);
    report_error ("to_Fix test", check7sf1,
                  to_sfixed (1, check7sf1'high, check7sf1'low));
    if (not quiet) then
      report "Expect 2 errors from to_UFix and to_SFix here"
        severity note;
      soutslv := (others => '0');
      unull := to_UFix (
        soutslv (soutslv'high downto soutslv'high - (check7uf1'length)),
        7, 3);
      snull := to_SFix (
        soutslv (soutslv'high downto soutslv'high - (check7sf1'length)),
        7, 3);
    end if;
    checkuns  := "0110100";
    check7uf1 := to_UFix (checkuns, 7, 3);   -- 6.5
    report_error ("to_UFix(0110100, 7, 3)", check7uf1,
                  to_ufixed (6.5, check7uf1));
    checkuns  := "0000010";
    check7uf2 := to_UFix (checkuns, 7, 3);   -- 0.25
    report_error ("to_UFix(0000010, 7, 3)", check7uf2,
                  to_ufixed (0.25, check7uf2));
    check7ufp7 := check7uf1 + check7uf2;
    report_error ("to_ufix 6.5 + 0.25",
                  check7ufp7, to_ufixed (6.5+0.25, check7ufp7));
    check7ufmi7 := check7uf1 - check7uf2;
    report_error ("to_ufix 6.5 - 0.25",
                  check7ufmi7, to_ufixed (6.5-0.25, check7ufmi7));
    check7ufm7 := check7uf1 * check7uf2;
    report_error ("to_ufix 6.5 * 0.25",
                  check7ufm7, to_ufixed (6.5*0.25, check7ufm7));
    check7ufd7 := check7uf1 / check7uf2;
    report_error ("to_ufix 6.5 / 0.25",
                  check7ufd7, to_ufixed (6.5/0.25, check7ufd7));
    check7ufmod7 := check7uf1 mod check7uf2;
    report_error ("to_ufix 6.5 mod 0.25",
                  check7ufmod7, to_ufixed (6.5 mod 0.25, check7ufmod7));
    check7ufrem7 := check7uf1 mod check7uf2;
    report_error ("to_ufix 6.5 rem 0.25",
                  check7ufrem7, to_ufixed (6.5 mod 0.25, check7ufrem7));
    -- SIGNED
    checksns  := "0110100";
    check7sf1 := to_SFix (checksns, 7, 3);   -- 6.5
    report_error ("to_Fix(0110100, 6, 3)", check7sf1,
                  to_sfixed (6.5, check7sf1));
    checksns  := "0000010";
    check7sf2 := to_SFix (checksns, 7, 3);   -- 0.25
    report_error ("to_UFix(0000010, 6, 3)", check7sf2,
                  to_sfixed (0.25, check7sf2));    
    check7sfp7 := check7sf1 + check7sf2;
    report_error ("to_fix 6.5 + 0.25",
                  check7sfp7, to_sfixed (6.5+0.25, check7sfp7));
    check7sfmi7 := check7sf1 - check7sf2;
    report_error ("to_fix 6.5 - 0.25",
                  check7sfmi7, to_sfixed (6.5-0.25, check7sfmi7));
    check7sfm7 := check7sf1 * check7sf2;
    report_error ("to_fix 6.5 * 0.25",
                  check7sfm7, to_sfixed (6.5*0.25, check7sfm7));
    check7sfd7 := check7sf1 / check7sf2;
    report_error ("to_fix 6.5 / 0.25",
                  check7sfd7, to_sfixed (6.5/0.25, check7sfd7));
    check7sfmod7 := check7sf1 mod check7sf2;
    report_error ("to_fix 6.5 mod 0.25",
                  check7sfmod7, to_sfixed (6.5 mod 0.25, check7sfmod7));
    check7sfrem7 := check7sf1 rem check7sf2;
    report_error ("to_fix 6.5 rem 0.25",
                  check7sfrem7, to_sfixed (6.5 mod 0.25, check7sfrem7));
    x_slv  := "0001001000110100";       -- 16 bits
    x_sfix := to_SFix(x_slv, 16, 14);
    report_error ("to_sfix, 16 BIT 1", x_sfix, to_sfixed(x_slv, 1, -14));
    x_sfix := to_SFix(x_slv, x_sfix'length, abs(x_sfix'low));
    report_error ("to_sfix, 16 BIT 2", x_sfix, to_sfixed(x_slv, 1, -14));

    assert (quiet) report ".M file conversion function test complete"
      severity note;
    mconvtest_done <= true;
    wait;
  end process mconvtest;

  -- compare test.
  comp_test : process is
    variable checkint                          : INTEGER;
    variable checkreal                         : REAL;
    variable checkuns                          : UNSIGNED (7 downto 0);
    variable checksns                          : SIGNED (7 downto 0);
    variable check7uf1, check7uf2, check7uf3   : ufixed7_3;
    variable check7sf1, check7sf2, check7sf3   : sfixed7_3;
    variable check16uf, check16uf1, check16uf2 : ufixed16_8;
    variable check16sf, check16sf1, check16sf2 : sfixed16_8;
  begin  -- process comp_test
    wait until start_comptest;
    -- compare test
    check16uf2 := to_ufixed (6.5, ufixed16_8'high, ufixed16_8'low);
    check7uf1  := "0110100";            -- 6.5
    assert (check16uf2 = check7uf1)
      report "6.5 = 6.5 miscompare" severity error;
    assert (check16uf2 <= check7uf1)
      report "6.5 <= 6.5 miscompare" severity error;
    assert (check16uf2 >= check7uf1)
      report "6.5 >= 6.5 miscompare" severity error;
    assert (not (check16uf2 /= check7uf1))
      report "6.5 /= 6.5 miscompare" severity error;
    assert (not (check16uf2 < check7uf1))
      report "6.5 < 6.5 miscompare" severity error;
    assert (not (check16uf2 > check7uf1))
      report "6.5 > 6.5 miscompare" severity error;
    checkuns  := to_unsigned (check7uf1, checkuns'high + 1);  -- 6
    check7uf1 := to_ufixed (checkuns, ufixed7_3'high, ufixed7_3'low);
    assert (check7uf1 /= check16uf2)
      report "6 /= 6.5 miscompare" severity error;
    assert (check7uf1 <= check16uf2)
      report "6 <= 6.5 miscompare" severity error;
    assert (check16uf2 >= check7uf1)
      report "6.5 >= 6 miscompare" severity error;
    assert (not (check16uf2 = check7uf1))
      report "6.5 = 6 miscompare" severity error;
    assert (check7uf1 < check16uf2)
      report "6 < 6.5 miscompare" severity error;
    assert (check16uf2 > check7uf1)
      report "6.5 > 6 miscompare" severity error;
    -- signed test
    check16sf2 := to_sfixed (6.5, sfixed16_8'high, sfixed16_8'low);
    check7sf1  := "0110100";            -- 6.5
    assert (check16sf2 = check7sf1) report "signed 6.5 = 6.5 miscompare"
      severity error;
    assert (check16sf2 <= check7sf1) report "signed 6.5 <= 6.5 miscompare"
      severity error;
    assert (check16sf2 >= check7sf1) report "signed 6.5 >= 6.5 miscompare"
      severity error;
    assert (not (check16sf2 /= check7sf1))
      report "signed 6.5 /= 6.5 miscompare"
      severity error;
    assert (not (check16sf2 < check7sf1)) report "signed 6.5 < 6.5 miscompare"
      severity error;
    assert (not (check16sf2 > check7sf1)) report "signed 6.5 > 6.5 miscompare"
      severity error;
    checksns  := to_signed (check7sf1, checksns'high + 1);    -- 6
    check7sf1 := to_sfixed (checksns, sfixed7_3'high, sfixed7_3'low);
    assert (check7sf1 /= check16sf2) report "signed 6 /= 6.5 miscompare"
      severity error;
    assert (check7sf1 <= check16sf2) report "signed 6 <= 6.5 miscompare"
      severity error;
    assert (check16sf2 >= check7sf1) report "signed 6.5 >= 6 miscompare"
      severity error;
    assert (not (check16sf2 = check7sf1)) report "signed 6.5 = 6 miscompare"
      severity error;
    assert (check7sf1 < check16sf2) report "signed 6 < 6.5 miscompare"
      severity error;
    assert (check16sf2 > check7sf1) report "signed 6.5 > 6 miscompare"
      severity error;
    -- negative number test
    check16sf  := to_sfixed (6.5, sfixed16_8'high, sfixed16_8'low);
    check16sf2 := to_sfixed (-6.5, sfixed16_8'high, sfixed16_8'low);
    check7sf1  := "0110100";            -- 6.5
    assert (check16sf2 = check16sf2) report "signed -6.5 = -6.5 miscompare"
      severity error;
    assert (check16sf2 = -check7sf1) report "signed -6.5 = -6.5 7 miscompare"
      severity error;
    assert (-check16sf = -check7sf1) report "signed -6.5 = -6.5 - miscompare"
      severity error;
    assert (check16sf /= check16sf2) report "signed 6.5 /= -6.5 miscompare"
      severity error;
    assert not (check16sf2 /= check16sf2)
      report "signed -6.5 /= -6.5 miscompare"
      severity error;
    assert (check16sf /= -check7sf1) report "signed 6.5 /= -6.5 7 miscompare"
      severity error;
    assert (check7sf1 /= -check7sf1) report "signed 6.5 /= -6.5 7x miscompare"
      severity error;
    assert (check16sf /= -check7sf1) report "signed 6.5 /= -6.5 7 miscompare"
      severity error;
    assert (check16sf > check16sf2) report "signed 6.5 > -6.5 miscompare"
      severity error;
    assert not (check16sf < check16sf2) report "signed 6.5 < -6.5 miscompare"
      severity error;
    assert (check16sf >= check16sf2) report "signed 6.5 >= -6.5 miscompare"
      severity error;
    assert (check16sf2 < check16sf) report "signed -6.5 < 6.5 miscompare"
      severity error;
    assert not (check16sf2 > check16sf) report "signed -6.5 < 6.5 miscompare"
      severity error;
    assert (check16sf2 <= -check16sf) report "signed -6.5 <= 6.5 miscompare"
      severity error;
    assert (check16sf2 <= -check7sf1) report "signed -6.5 <= -6.5 size"
      severity error;
    assert (check16sf2 >= -check7sf1) report "signed -6.5 >= -6.5 size"
      severity error;
    -- Try some X checking
    check7uf1 := "000000Z";
    check7uf2 := "000000X";
    if not quiet then
      report "Expect 6 meta value compare warnings here" severity note;
      assert not (check7uf1 = check7uf1) report "X = X error" severity error;
      assert (check7uf2 /= check7uf2) report "not X /= X error" severity error;
      assert not (check7uf1 < check7uf1) report "X < X error" severity error;
      assert not (check7uf2 <= check7uf2) report "X <= X error" severity error;
      assert not (check7uf1 > check7uf1) report "X > X error" severity error;
      assert not (check7uf2 >= check7uf2) report "X >= X error" severity error;
    end if;
    check7sf1 := "X000000";
    check7sf2 := "000000Z";
    if not quiet then
      report "Expect 6 meta value compare warnings here" severity note;
      assert not (check7sf1 = check7sf1)
        report "signed X = X error" severity error;
      assert (check7sf2 /= check7sf2)
        report "signed not X /= X error" severity error;
      assert not (check7sf1 < check7sf1)
        report "signed X < X error" severity error;
      assert not (check7sf2 <= check7sf2)
        report "signed X <= X error" severity error;
      assert not (check7sf1 > check7sf1)
        report "signed X > X error" severity error;
      assert not (check7sf2 >= check7sf2)
        report "signed X >= X error" severity error;
    end if;
    -- check the overload cases
    check7uf1         := "0011000";     -- 3
    checkint          := 3;
    assert (check7uf1 = checkint) report "ufixed = 3" severity error;
    assert (checkint = check7uf1) report "3 = ufixed" severity error;
    check7uf1         := "0011000";     -- 3
    checkint          := 3;
    assert not (check7uf1 /= checkint) report "ufixed /= 3" severity error;
    assert not (checkint /= check7uf1) report "3 = ufixed" severity error;
    check7uf1         := "0011000";     -- 3
    checkint          := 3;
    assert not (check7uf1 < checkint) report "ufixed < 3" severity error;
    assert not (checkint < check7uf1) report "3 < ufixed" severity error;
    check7uf1         := "0011000";     -- 3
    checkint          := 3;
    assert not (check7uf1 > checkint) report "ufixed = 3" severity error;
    assert not (checkint > check7uf1) report "3 > ufixed" severity error;
    check7uf1         := "0011000";     -- 3
    checkint          := 3;
    assert (check7uf1 >= checkint) report "ufixed = 3" severity error;
    assert (checkint >= check7uf1) report "3 >= ufixed" severity error;
    check7uf1         := "0011000";     -- 3
    checkint          := 3;
    assert (check7uf1 <= checkint) report "ufixed = 3" severity error;
    assert (checkint  <= check7uf1) report "3 <= ufixed" severity error;
    check7uf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert (check7uf1 = checkreal) report "ufixed = 3.0" severity error;
    assert (checkreal = check7uf1) report "3.0 = ufixed" severity error;
    check7uf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert not (check7uf1 /= checkreal) report "ufixed /= 3.0" severity error;
    assert (checkreal = check7uf1) report "3.0 = ufixed" severity error;
    check7uf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert not (check7uf1 < checkreal) report "ufixed < 3.0" severity error;
    assert not (checkreal < check7uf1) report "3.0 < ufixed" severity error;
    check7uf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert not (check7uf1 > checkreal) report "ufixed = 3.0" severity error;
    assert not (checkreal > check7uf1) report "3.0 > ufixed" severity error;
    check7uf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert (check7uf1 >= checkreal) report "ufixed = 3.0" severity error;
    assert (checkreal >= check7uf1) report "3.0 >= ufixed" severity error;
    check7uf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert (check7uf1 <= checkreal) report "ufixed = 3.0" severity error;
    assert (checkreal <= check7uf1) report "3.0 <= ufixed" severity error;
    -- signed
    check7sf1         := "0011000";     -- 3
    checkint          := 3;
    assert (check7sf1 = checkint) report "sfixed = 3" severity error;
    assert (checkint = check7sf1) report "3 = sfixed" severity error;
    check7sf1         := "0011000";     -- 3
    checkint          := 3;
    assert not (check7sf1 /= checkint) report "sfixed /= 3" severity error;
    assert not (checkint /= check7sf1) report "3 /= sfixed" severity error;
    check7sf1         := "0011000";     -- 3
    checkint          := 3;
    assert not (check7sf1 < checkint) report "sfixed < 3" severity error;
    assert not (checkint < check7sf1) report "3 < sfixed" severity error;
    check7sf1         := "0011000";     -- 3
    checkint          := 3;
    assert not (check7sf1 > checkint) report "sfixed > 3" severity error;
    assert not (checkint > check7sf1) report "3 > sfixed" severity error;
    check7sf1         := "0011000";     -- 3
    checkint          := 3;
    assert (check7sf1 >= checkint) report "sfixed >= 3" severity error;
    assert (checkint >= check7sf1) report "3 >= sfixed" severity error;
    check7sf1         := "0011000";     -- 3
    checkint          := 3;
    assert (check7sf1 <= checkint) report "sfixed <= 3" severity error;
    assert (checkint  <= check7sf1) report "3 <= sfixed" severity error;
    check7sf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert (check7sf1 = checkreal) report "sfixed = 3.0" severity error;
    assert (checkreal = check7sf1) report "3.0 = sfixed" severity error;
    check7sf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert not (check7sf1 /= checkreal) report "sfixed /= 3.0" severity error;
    assert not (checkreal /= check7sf1) report "3.0 = sfixed" severity error;
    check7sf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert not (check7sf1 < checkreal) report "sfixed < 3.0" severity error;
    assert not (checkreal < check7sf1) report "3.0 < sfixed" severity error;
    check7sf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert not (check7sf1 > checkreal) report "sfixed > 3.0" severity error;
    assert not (checkreal > check7sf1) report "3.0 > sfixed" severity error;
    check7sf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert (check7sf1 >= checkreal) report "sfixed >= 3.0" severity error;
    assert (checkreal >= check7sf1) report "3.0 >= sfixed" severity error;
    check7sf1         := "0011000";     -- 3.0
    checkreal         := 3.0;
    assert (check7sf1 <= checkreal) report "sfixed <= 3.0" severity error;
    assert (checkreal <= check7sf1) report "3.0 <= sfixed" severity error;
    -- Check some boundaries
    if (not quiet) then
      check7uf1 := "0011000";           -- 3.0
      checkreal := -1.0;
      report "Expect two to_ufixed(-real) errors here" severity note;
      assert not (check7uf1 = checkreal)
        report "unsigned = -1.0" severity error;
      assert not (checkreal = check7uf1)
        report "unsigned = -1.0" severity error;
    end if;
    -- The old 1/3 test, make sure that real numbers round to match.
    check7uf1  := "0000011";            -- .375  odd bits <> 1/3
    check16uf1 := "0000000001010101";   -- ~.3332 even bits <> 1/3
    checkreal  := 1.0/3.0;
    assert (check16uf1 = checkreal)
      report to_string(check16uf1) & " = 1/3" severity error;
    assert (check7uf1 = checkreal)
      report to_string(check7uf1) & " = 1/3" severity error;
    assert (checkreal = check16uf1)
      report "1/3 = " & to_string(check16uf1) severity error;
    assert (checkreal = check7uf1)
      report "1/3 = " & to_string(check7uf1) severity error;
    assert not (check16uf1 /= checkreal)
      report to_string(check16uf1) & " /= 1/3" severity error;
    assert not (check7uf1 /= checkreal)
      report to_string(check7uf1) & " /= 1/3" severity error;
    assert not (checkreal /= check16uf1)
      report "1/3 /= " & to_string(check16uf1) severity error;
    assert not (checkreal /= check7uf1)
      report "1/3 /= " & to_string(check7uf1) severity error;
    assert (check16uf1 >= checkreal)
      report to_string(check16uf1) & " >= 1/3" severity error;
    assert (check7uf1 >= checkreal)
      report to_string(check7uf1) & " >= 1/3" severity error;
    assert (checkreal >= check16uf1)
      report "1/3 >= " & to_string(check16uf1) severity error;
    assert (checkreal >= check7uf1)
      report "1/3 >= " & to_string(check7uf1) severity error;
    assert (check16uf1 <= checkreal)
      report to_string(check16uf1) & " <= 1/3" severity error;
    assert (check7uf1 <= checkreal)
      report to_string(check7uf1) & " <= 1/3" severity error;
    assert (checkreal <= check16uf1)
      report "1/3 <= " & to_string(check16uf1) severity error;
    assert (checkreal <= check7uf1)
      report "1/3 <= " & to_string(check7uf1) severity error;
    assert not (check16uf1 > checkreal)
      report to_string(check16uf1) & " > 1/3" severity error;
    assert not (check7uf1 > checkreal)
      report to_string(check7uf1) & " > 1/3" severity error;
    assert not (checkreal > check16uf1)
      report "1/3 > " & to_string(check16uf1) severity error;
    assert not (checkreal > check7uf1)
      report "1/3 > " & to_string(check7uf1) severity error;
    assert not (check16uf1 < checkreal)
      report to_string(check16uf1) & " < 1/3" severity error;
    assert not (check7uf1 < checkreal)
      report to_string(check7uf1) & " < 1/3" severity error;
    assert not (checkreal < check16uf1)
      report "1/3 < " & to_string(check16uf1) severity error;
    assert not (checkreal < check7uf1)
      report "1/3 < " & to_string(check7uf1) severity error;
    -- Would (and should) cause a fatal runtime error
--    checkint := -1;
--    assert not (check7uf1 = checkint) report "unsigned = -1" severity error;
--    assert not (checkint = check7uf1) report "unsigned = -1" severity error;
    -- ufixed and sfixed test
    check7uf1 := "0011000";             -- 3.0
    check7sf1 := "0011000";             -- 3.0
    assert (to_sfixed(check7uf1) = check7sf1)
      report "ufixed = sfixed" severity error;
    assert (check7sf1 = to_sfixed(check7uf1))
      report "sfixed = ufixed" severity error;
    assert not (to_sfixed(check7uf1) /= check7sf1)
      report "ufixed /= sfixed" severity error;
    assert not (check7sf1 /= to_sfixed(check7uf1))
      report "sfixed /= ufixed" severity error;
    assert not (to_sfixed(check7uf1) < check7sf1)
      report "ufixed < sfixed" severity error;
    assert not (check7sf1 < to_sfixed(check7uf1))
      report "sfixed < ufixed" severity error;
    assert not (to_sfixed(check7uf1) > check7sf1)
      report "ufixed > sfixed" severity error;
    assert not (check7sf1 > to_sfixed(check7uf1))
      report "sfixed > ufixed" severity error;
    assert (to_sfixed(check7uf1) >= check7sf1)
      report "ufixed >= sfixed" severity error;
    assert (check7sf1 >= to_sfixed(check7uf1))
      report "sfixed >= ufixed" severity error;
    assert (to_sfixed(check7uf1) <= check7sf1)
      report "ufixed <= sfixed" severity error;
    assert (check7sf1 <= to_sfixed(check7uf1))
      report "sfixed <= ufixed" severity error;
    check7uf1 := "0011000";             -- 3.0
    check7sf1 := "1100000";             -- -3.0
    assert not (to_sfixed(check7uf1) = check7sf1)
      report "ufixed = sfixed" severity error;
    assert not (check7sf1 = to_sfixed(check7uf1))
      report "sfixed = ufixed" severity error;
    assert (to_sfixed(check7uf1) /= check7sf1)
      report "ufixed /= sfixed" severity error;
    assert (check7sf1 /= to_sfixed(check7uf1))
      report "sfixed /= ufixed" severity error;
    assert not (to_sfixed(check7uf1) < check7sf1)
      report "ufixed < sfixed" severity error;
    assert (check7sf1 < to_sfixed(check7uf1))
      report "sfixed < ufixed" severity error;
    assert (to_sfixed(check7uf1) > check7sf1)
      report "ufixed > sfixed" severity error;
    assert not (check7sf1 > to_sfixed(check7uf1))
      report "sfixed > ufixed" severity error;
    assert (to_sfixed(check7uf1) >= check7sf1)
      report "ufixed >= sfixed" severity error;
    assert not (check7sf1 >= to_sfixed(check7uf1))
      report "sfixed >= ufixed" severity error;
    assert not (to_sfixed(check7uf1) <= check7sf1)
      report "ufixed <= sfixed" severity error;
    assert (check7sf1 <= to_sfixed(check7uf1))
      report "sfixed <= ufixed" severity error;

    -- Test min and max functions
    check7uf1     := "0011000";         -- 3
    check7uf2     := "0110100";         -- 6.5
    check7uf3     := maximum (check7uf1, check7uf2);
    report_error ("Maximum ", check7uf3, check7uf2);
    check7uf3     := maximum (check7uf2, check7uf1);
    report_error ("Maximum rev ", check7uf3, check7uf2);
    check7uf3     := minimum (check7uf1, check7uf2);
    report_error ("Mimimum ", check7uf3, check7uf1);
    check7uf3     := minimum (check7uf2, check7uf1);
    report_error ("Mimimum rev", check7uf3, check7uf1);
    check7uf3     := maximum (check7uf1, check7uf1);
    report_error ("Maximum =", check7uf3, check7uf1);
    check7uf3     := maximum (check7uf2, check7uf2);
    report_error ("Mimimum =", check7uf3, check7uf2);
    check7sf1     := "0011000";         -- 3
    check7sf2     := "0110100";         -- 6.5
    check7sf3     := maximum (check7sf1, check7sf2);
    report_error ("Maximum ", check7sf3, check7sf2);
    check7sf3     := maximum (check7sf2, check7sf1);
    report_error ("Maximum rev ", check7sf3, check7sf2);
    check7sf3     := minimum (check7sf1, check7sf2);
    report_error ("Mimimum ", check7sf3, check7sf1);
    check7sf3     := minimum (check7sf2, check7sf1);
    report_error ("Mimimum rev", check7sf3, check7sf1);
    check7sf3     := maximum (check7sf1, check7sf1);
    report_error ("Maximum =", check7sf3, check7sf1);
    check7sf3     := maximum (check7sf2, check7sf2);
    report_error ("Mimimum =", check7sf3, check7sf2);
    check7sf1     := "1101000";         -- -3
    check7sf2     := "0110100";         -- 6.5
    check7sf3     := maximum (check7sf1, check7sf2);
    report_error ("Maximum -", check7sf3, check7sf2);
    check7sf3     := maximum (check7sf2, check7sf1);
    report_error ("Maximum rev -", check7sf3, check7sf2);
    check7sf3     := minimum (check7sf1, check7sf2);
    report_error ("Mimimum -", check7sf3, check7sf1);
    check7sf3     := minimum (check7sf2, check7sf1);
    report_error ("Mimimum rev -", check7sf3, check7sf1);
    check7sf3     := maximum (check7sf1, check7sf1);
    report_error ("Maximum = -", check7sf3, check7sf1);
    check7sf3     := maximum (check7sf2, check7sf2);
    report_error ("Mimimum = -", check7sf3, check7sf2);
    assert (quiet) report "Compare test completed" severity note;
    comptest_done <= true;
    wait;
  end process comp_test;

  -- purpose: test the read routines
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  read_test : process is
    variable checknum                : ufixed7_3;  -- Floating point output
    variable checknum1               : ufixed7_3;  -- Floating point output
    variable l                       : LINE;       -- line variable
    variable checkbool               : BOOLEAN;    -- check boolean
    variable checkslv                : STD_LOGIC_VECTOR (6 downto 0);
    variable checkstr, checkstr2     : STRING (1 to 8);        -- check string
    variable checkstrsf, checkstrsf2 : STRING (1 to 9);        -- check string
    variable checksf, checksf2       : sfixed8_3;  -- fixed signed
    variable good                    : BOOLEAN;
  begin  -- process read_test
    wait until start_readtest;
    -- test the READ routines
    L := new STRING'(" 0011000 ");
    read (L, checknum);
    report_error ("Error in Read",
                  checknum,
                  to_ufixed(3, ufixed7_3'high, ufixed7_3'low));
    deallocate (L);
    L := new STRING'(" 0011.000 ");
    read (L, checknum);
    report_error ("Error in Read2",
                  checknum,
                  to_ufixed(3, ufixed7_3'high, ufixed7_3'low));
    deallocate (L);
    L := new STRING'(" 0011000 ");
    read (L, checknum, checkbool);
    assert (checkbool) report "Read bool reported error condition"
      severity error;
    report_error ("Error in Read bool",
                  checknum,
                  to_ufixed(3, ufixed7_3'high, ufixed7_3'low));
    deallocate (L);
    L := new STRING'(" 0011.000 ");
    read (L, checknum, checkbool);
    assert (checkbool) report "Read2 bool reporting error condition"
      severity error;
    report_error ("Error in Read2",
                  checknum,
                  to_ufixed(3, ufixed7_3'high, ufixed7_3'low));
    deallocate (L);
    L := new STRING'(" 0011.0 00 ");
    read (L, checknum, checkbool);
    assert (not checkbool) report "Readb bool not reporting error condition"
      severity error;
    checkslv := to_slv(checknum);
    report_error ("Error in Readb",
                  checkslv,
                  "UUUUUUU");
    deallocate (L);
    L := new STRING'(" 0011.A00 ");
    read (L, checknum, checkbool);
    assert (not checkbool) report "Readb1 bool not reporting error condition"
      severity error;
    checkslv := to_slv(checknum);
    report_error ("Error in Readb1",
                  checkslv,
                  "UUUUUUU");
    deallocate (L);
    L := new STRING'(" 0011.00 ");
    read (L, checknum, checkbool);
    assert (not checkbool) report "Readb2 bool not reported error condition"
      severity error;
    deallocate (L);
    checkslv := to_slv (checknum);
    report_error ("Error in Readb2",
                  checkslv,
                  "UUUUUUU");
    deallocate (L);
    -- do some string test
    checknum  := "0011110";
    checkstr  := to_string (checknum);
    checkstr2 := "0011.110";
    assert (checkstr = checkstr2) report "to_string error "
      & checkstr & " /= " & checkstr2 severity error;
    L := new string'(to_string (checknum(3 downto 0)));
    assert (L.all = "0011.0")
      report "to_string (checknum (3 downto 0)) = '" & L.all & "'"
      severity error;
    deallocate (L);
    checknum := "0011110";
    checknum := "0011110";
    assert (to_ostring (checknum) = "03.6") report "to_ostring error "
      & to_ostring (checknum) & " /= 03.6" severity error;
    L := new string'(to_ostring (checknum(3 downto 0)));
    assert (L.all = "03.0")
      report "to_ostring (0011) = '" & L.all & "'"
      severity error;
    deallocate (L);
    checknum := "0011110";
    assert (to_hstring (checknum) = "3.C") report "to_hstring error "
      & to_hstring (checknum) & " /= 3.C" severity error;
    L := new string'(to_hstring (checknum(3 downto 0)));
    assert (L.all = "3.0")
      report "to_hstring (0011) = '" & L.all & "'"
      severity error;
    deallocate (L);
    checksf     := "11110110";
    checkstrsf  := to_string (checksf);
    checkstrsf2 := "11110.110";
    assert (checkstrsf = checkstrsf2) report "to_string (signed) error "
      & checkstrsf & " /= " &checkstrsf2 severity error;
    L := new string'(to_string (checksf(4 downto 0)));
    assert (L.all = "11110.0")
      report "to_string (s11110) = '" & L.all & "'"
      severity error;
    deallocate (L);
    checksf := "11110110";
    assert (to_ostring (checksf) = "76.6") report "to_ostring (signed) error "
      & to_ostring (checksf) & " /= 76.6" severity error;
    L := new string'(to_ostring (checksf(4 downto 0)));
    assert (L.all = "76.0")
      report "to_ostring (s11110) = '" & L.all & "'"
      severity error;
    deallocate (L);
    checksf := "11110110";
    assert (to_hstring (checksf) = "FE.C") report "to_hstring (signed) error "
      & to_hstring (checksf) & " /= FE.C" severity error;
    L := new string'(to_hstring (checksf(4 downto 0)));
    assert (L.all = "FE.0")
      report "to_hstring (s11110) = '" & L.all & "'"
      severity error;
    deallocate (L);
    L         := new STRING'("0101.010");
    read (L, checknum, good);
    checknum1 := "0101010";
    assert good report "unsigned read test, good false" severity error;
    report_error ("unsigned read test", checknum, checknum1);
    deallocate (L);
    L         := new STRING'("0101.001");
    read (L, checknum);
    checknum1 := "0101001";
    report_error ("unsigned readx test", checknum, checknum1);
    deallocate (L);
    L         := new STRING'("06.2");
    oread (L, checknum, good);
    checknum1 := "0110010";
    assert good report "unsigned oread test, good false" severity error;
    report_error ("unsigned oread test", checknum, checknum1);
    deallocate (L);
    L         := new STRING'("04.2");
    oread (L, checknum);
    checknum1 := "0100010";
    report_error ("unsigned oreadx test", checknum, checknum1);
    deallocate (L);
    L := new string'("1_7.600_.0");
    oread (L, checknum, good);
    checknum1 := "1111110";
    report_error ("unsigned oread 1_7.6 test1", checknum, checknum1);
    oread (L, checknum, good);
    checknum1 := "0000000";
    report_error ("unsigned oread 00_.0 test2", checknum, checknum1);    
    deallocate (L);
    L := new string'("0_2_._700._7");
    oread (L, checknum);
    checknum1 := "0010111";
    report_error ("unsigned oreadx _ test1", checknum, checknum1);
    oread (L, checknum);
    checknum1 := "0000111";
    report_error ("unsigned oreadx _ test2", checknum, checknum1);    
    deallocate (L);
    -- signed oread
    L         := new STRING'("06.2");
    oread (L, checksf, good);
    checksf2  := "00110010";
    assert good report "signed oread test, good false" severity error;
    report_error ("signed oread test", checksf, checksf2);
    deallocate (L);
    L         := new STRING'("04.2");
    oread (L, checksf);
    checksf2  := "00100010";
    report_error ("signed oreadx test", checksf, checksf2);
    deallocate (L);
    L         := new STRING'("76.2");
    oread (L, checksf, good);
    checksf2  := "11110010";
    assert good report "-signed oread test, good false" severity error;
    report_error ("-signed oread test", checksf, checksf2);
    deallocate (L);
    L         := new STRING'("74.2");
    oread (L, checksf);
    checksf2  := "11100010";
    report_error ("-signed oreadx test", checksf, checksf2);
    deallocate (L);
    L := new string'("6_7.600_.0");
    oread (L, checksf, good);
    checksf2  := "10111110";
    assert good report "signed oread 6_7.6, good false" severity error;
    report_error ("signed oread 6_7.6 test", checksf, checksf2);
    oread (L, checksf, good);
    checksf2  := "00000000";
    assert good report "signed oread 00_.0, good false" severity error;
    report_error ("signed oread 00_.0 test", checksf, checksf2);
    L := new string'("0_2_._700._7");
    oread (L, checksf);
    checksf2  := "00010111";
    report_error ("signed oread 0_2_._7 test", checksf, checksf2);
    oread (L, checksf);
    checksf2  := "00000111";
    report_error ("signed oread 00._7 test", checksf, checksf2);
    -- hread
    L         := new STRING'("6.4");
    hread (L, checknum, good);
    checknum1 := "0110010";
    assert good report "unsigned hread test, good false" severity error;
    report_error ("unsigned hread 6.4 test", checknum, checknum1);
    deallocate (L);
    if (not quiet) then
      report "Expect a HREAD vector truncated warning here" severity note;
      L         := new STRING'("A.F");
      hread (L, checknum);
      checknum1 := "1010111";
      report_error ("unsigned hread A.F test", checknum, checknum1);
      deallocate (L);
    end if;
    -- signed hread test
    L        := new STRING'("06.4");
    hread (L, checksf, good);
    checksf2 := "00110010";
    assert good report "signed hread test, good false" severity error;
    report_error ("signed hread test", checksf, checksf2);
    deallocate (L);
    if (not quiet) then
      report "Expect a HREAD vector truncated warning here" severity note;
      L        := new STRING'("0A.F");
      hread (L, checksf);
      checksf2 := "01010111";
      report_error ("signed hreadx 0A.F test", checksf, checksf2);
      deallocate (L);
    end if;
    L        := new STRING'("F6.4");
    hread (L, checksf, good);
    checksf2 := "10110010";
    assert good report "-signed hread test, good false" severity error;
    report_error ("signed hread test", checksf, checksf2);
    deallocate (L);
    L        := new STRING'("FA.E");
    hread (L, checksf);
    checksf2 := "11010111";             -- Negative round
    report_error ("-signed hreadx test", checksf, checksf2);
    deallocate (L);
    -- write
    checknum := "0101001";
    L        := null;
    write (L, checknum);
    assert (L.all = "0101.001")
      report "Unsigned write test " & L.all & " /= " & "0101.001"
      severity error;
    deallocate (L);
    L       := null;
    checksf := "00110010";
    write (L, checksf);
    assert (L.all = "00110.010")
      report "signed write test " & L.all & " /= " & "00110.010"
      severity error;
    deallocate (L);
    checksf := "11110010";
    L       := null;
    write (L, checksf);
    assert (L.all = "11110.010")
      report "-signed write test " & L.all & " /= " & "1110.010"
      severity error;
    deallocate (L);
    -- owrite
    checknum := "0101001";
    L        := null;
    owrite (L, checknum);
    assert (L.all = "05.1")
      report "Unsigned owrite test " & L.all & " /= " & "05.1"
      severity error;
    deallocate (L);
    L       := null;
    checksf := "00110010";
    owrite (L, checksf);
    assert (L.all = "06.2")
      report "signed owrite test " & L.all & " /= " & "06.2"
      severity error;
    deallocate (L);
    L       := null;
    checksf := "11110010";
    owrite (L, checksf);
    assert (L.all = "76.2")
      report "-signed owrite test " & L.all & " /= " & "76.2"
      severity error;
    -- hwrite
    deallocate (L);
    checknum := "0101001";
    L        := null;
    hwrite (L, checknum);
    assert (L.all = "5.2")
      report "Unsigned hwrite test " & L.all & " /= " & "5.2"
      severity error;
    deallocate (L);
    L       := null;
    checksf := "00110010";
    hwrite (L, checksf);
    assert (L.all = "06.4")
      report "signed hwrite test " & L.all & " /= " & "06.4"
      severity error;
    deallocate (L);
    L       := null;
    checksf := "11110101";
    hwrite (L, checksf);
    assert (L.all = "FE.A")
      report "-signed hwrite test " & L.all & " /= " & "FE.A"
      severity error;
    deallocate (L);
    L         := new STRING'("          1010101         0101.010 ");  -- space and tab
    read (L, checknum);
    checknum1 := "1010101";
    report_error ("Read, 2 things on a line", checknum, checknum1);
    read (L, checknum);
    checknum1 := "0101010";
    report_error ("Read, 2 things on a line, 2nd", checknum, checknum1);
    deallocate (L);
    L         := new STRING'("          1010101         0101.010 ");  -- space and tab
    read (L, checknum, good);
    assert (good) report "read, 2 things from a line good=false"
      severity error;
    checknum1 := "1010101";
    report_error ("Read, 2 things on a LINE good", checknum, checknum1);
    read (L, checknum, good);
    assert (good) report "read, 2 things from a line 2nd good=false"
      severity error;
    checknum1 := "0101010";
    report_error ("Read, 2 things on a LINE good, 2nd", checknum, checknum1);
    deallocate (L);
    L         := new STRING'("          01010101         00101.010 ");  -- space and tab
    read (L, checksf);
    checksf2  := "01010101";
    report_error ("sRead, 2 things on a line", checksf, checksf2);
    read (L, checksf);
    checksf2  := "00101010";
    report_error ("sRead, 2 things on a line, 2nd", checksf, checksf2);
    deallocate (L);
    L         := new STRING'("          01010101         00101.010 ");  -- space and tab
    read (L, checksf, good);
    assert (good) report "sread, 2 things from a line good=false"
      severity error;
    checksf2 := "01010101";
    report_error ("sRead, 2 things on a line", checksf, checksf2);
    read (L, checksf, good);
    assert (good) report "sread, 2 things from a line 2nd good=false"
      severity error;
    checksf2      := "00101010";
    report_error ("sRead, 2 things on a line, 2nd", checksf, checksf2);
    deallocate (L);
    assert (quiet) report "Read and write test completed" severity note;
    readtest_done <= true;
    wait;
  end process read_test;

  -- purpose: test for literals
  literaltest : process is
    variable check7uf1, check7uf2, check7uf3 : ufixed7_3;  -- unsigned fixed
    variable check7uf                        : ufixed (4 downto -3);  -- ufixed7_3+ufixed7_3
    variable checkeuf                        : ufixed (4 downto 0);  -- error condition
    variable check7sf1, check7sf2, check7sf3 : sfixed7_3;  -- signed fixed
    variable checkesf                        : sfixed (4 downto 0);  -- error condition
    variable check7sf                        : sfixed (4 downto -3);  -- sfixed7_3+sfixed7_3
    variable usc                             : ufixed (1 downto 0);
    variable sc                              : sfixed (2 downto 0);
    variable checkint                        : INTEGER;
    variable checkreal                       : REAL;
    variable checkslv                        : STD_LOGIC_VECTOR (7 downto 0);  -- slv
    variable unull                           : ufixed (-1 downto 1);  -- Null range
    variable snull                           : sfixed (-1 downto 1);  -- Null range
    variable ubad                            : ufixed (INTEGER'low to INTEGER'low+3);  -- literal range
    variable sbad                            : sfixed (INTEGER'low to INTEGER'low+3);  -- literal range
  begin
    wait until start_literaltest;
    -- Passing a literal to a funtion expecting a "ufixed" or an "sfixed" will
    -- give you unexpected results.  However it should do something consistent
    -- and not crash the simulator.
    -- A literal will resolve to "ufixed (integer'low to integer'low+3)"
    -- Which will typically cause a memory error if I don't do something.
    if (not quiet) then
      report "Expect literal error from resize function" severity note;
      check7uf2 := resize ("1000", check7uf1'high, check7uf1'low);
      check7uf1 := "0011100";           -- 3.5
      report "Expect literal error from f+ function" severity note;
      checkeuf  := check7uf1 + "0001";
      report_error ("ufixed + literal", checkeuf,
                    to_ufixed(4, checkeuf'high, checkeuf'low));  -- 3.5 rounded
      report "Expect literal error from +f function" severity note;
      checkeuf := "0001" + check7uf1;
      report_error ("literal + ufixed", checkeuf,
                    to_ufixed(4, checkeuf'high, checkeuf'low));  -- 3.5 rounded
      report "Expect literal error from f- function" severity note;
      checkeuf := check7uf1 - "0001";
      report_error ("ufixed - literal", checkeuf,
                    to_ufixed(4, checkeuf'high, checkeuf'low));  -- 3.5 rounded
      report "Expect literal error from -f function" severity note;
      checkeuf := "0001" - check7uf1;
      report_error ("literal - ufixed", checkeuf,
                    to_ufixed(unsigned'("11100")));  -- overflow, negative number
      report "Expect literal error from f* function" severity note;
      unull     := check7uf1 * "0001";
      report "Expect literal error from *f function" severity note;
      unull     := "0001" * check7uf1;
      report "Expect literal error from f/ function" severity note;
      unull     := check7uf1 / "0001";
      report "Expect literal error from /f function" severity note;
      unull     := "0001" / check7uf1;
      report "Expect literal error from reciprocal function" severity note;
      unull     := reciprocal ("0001");
      checkreal := 1.0;
      report "Expect literal error from l+r function" severity note;
      unull     := "0001" + checkreal;
      report "Expect literal error from l-r function" severity note;
      unull     := "0001" - checkreal;
      report "Expect literal error from l*r function" severity note;
      unull     := "0001" * checkreal;
      report "Expect literal error from l/r function" severity note;
      unull     := "0001" / checkreal;
      report "Expect literal error from r+l function" severity note;
      unull     := checkreal + "0001";
      report "Expect literal error from r-l function" severity note;
      unull     := checkreal - "0001";
      report "Expect literal error from r*l function" severity note;
      unull     := checkreal * "0001";
      report "Expect literal error from r/l function" severity note;
      unull     := checkreal / "0001";
      checkint  := 1;
      report "Expect literal error from l+i function" severity note;
      unull     := "0001" + checkint;
      report "Expect literal error from l-i function" severity note;
      unull     := "0001" - checkint;
      report "Expect literal error from l*i function" severity note;
      unull     := "0001" * checkint;
      report "Expect literal error from l/i function" severity note;
      unull     := "0001" / checkint;
      report "Expect literal error from i+l function" severity note;
      unull     := checkint + "0001";
      report "Expect literal error from i-l function" severity note;
      unull     := checkint - "0001";
      report "Expect literal error from * function" severity note;
      unull     := checkint * "0001";
      report "Expect literal error from i/l function" severity note;
      unull     := checkint / "0001";
      report "Expect literal error from i mod l function" severity note;
      unull     := check7uf1 mod "0001";
      check7uf1 := "0011100";           -- 3.5
      report "Expect literal error from l mod i function" severity note;
      unull     := "0001" mod check7uf1;
      report "Expect literal error from f rem l function" severity note;
      unull     := check7uf1 rem "0001";
      check7uf1 := "0011100";           -- 3.5
      report "Expect literal error from l rem f function" severity note;
      unull     := "0001" rem check7uf1;
      report "Expect literal error from a resize lit function" severity note;
      check7uf1 := "0011100";           -- 3.5
      usc := "01";                      -- 1.0
      usc := resize (arg => usc & "000",
                     left_index => usc'high,
                     right_index => usc'low);
      check7uf1 := "0011100";           -- 3.5
      report "Expect literal error from f=l function" severity note;
      assert not (check7uf1 = "00001")
        report "ufixed = literal returned true" severity error;
      report "Expect literal error from f/=l function" severity note;
      assert (check7uf1 /= "00001")
        report "ufixed /= literal returned false" severity error;
      report "Expect literal error from f<l function" severity note;
      assert not (check7uf1 < "00001")
        report "ufixed = literal returned true" severity error;
      report "Expect literal error from f>l function" severity note;
      assert (check7uf1 > "00001")
        report "ufixed > literal returned false" severity error;
      report "Expect literal error from f<=l function" severity note;
      assert not (check7uf1 <= "00001")
        report "ufixed <= literal returned true" severity error;
      report "Expect literal error from f>=l function" severity note;
      assert (check7uf1 >= "00001")
        report "ufixed >= literal returned false" severity error;
      report "Expect literal error from l=f function" severity note;
      assert not ("00001" = check7uf1)
        report "literal = ufixed returned true" severity error;
      report "Expect literal error from l/=f function" severity note;
      assert ("00001" /= check7uf1)
        report "literal /= ufixed returned false" severity error;
      report "Expect literal error from l<f function" severity note;
      assert ("00001" < check7uf1)
        report "literal < ufixed returned false" severity error;
      report "Expect literal error from l>f function" severity note;
      assert not ("00001" > check7uf1)
        report "literal > ufixed returned true" severity error;
      report "Expect literal error from l<=f function" severity note;
      assert ("00001" <= check7uf1)
        report "literal <= ufixed returned true" severity error;
      report "Expect literal error from l>=f function" severity note;
      assert not ("00001" >= check7uf1)
        report "literal >= ufixed returned false" severity error;
      report "Expect literal error from maximum function" severity note;
      check7uf2 (3 downto 0) := maximum ("0001", check7uf1);
      report "Expect literal error from minimum function" severity note;
      check7uf2 (3 downto 0) := minimum ("0001", check7uf1);
      report "Signed literal test" severity note;
      report "Expect literal error from signed resize function" severity note;
      check7sf1 := resize ("0100", check7sf1'high, check7sf1'low);
      check7sf2 := "0000000";
      report_error ("resize s literal", check7sf1, check7sf2);
      check7sf1 := "0011100";           -- 3.5
      report "Expect literal error from signed + function" severity note;
      checkesf  := check7sf1 + "0001";
      report_error ("sfixed + literal", checkesf,
                    to_sfixed(4, checkesf'high, checkesf'low));  -- 3.5 rounded
      check7sf1 := "0011100";           -- 3.5
      report "Expect literal error from signed - function" severity note;
      checkesf  := check7sf1 - "0001";
      report_error ("sfixed - literal", checkesf,
                    to_sfixed(4, checkesf'high, checkesf'low));  -- 3.5 rounded
      report "Expect literal error from signed * function" severity note;
      snull := check7sf1 * "0001";
      report "Expect literal error from signed * function" severity note;
      snull := "0001" * check7sf1;
      report "Expect literal error from signed / function" severity note;
      snull := check7sf1 / "0001";
      report "Expect literal error from signed / function" severity note;
      snull := "0001" / check7sf1;
      report "Expect literal error from signed reciprocal function"
        severity note;
      snull     := reciprocal ("0001");
      report "Expect literal error from signed mod function" severity note;
      snull     := check7sf1 mod "0001";
      check7sf1 := "0011100";           -- 3.5
      report "Expect literal error from signed mod function" severity note;
      snull     := "0001" mod check7sf1;
      report "Expect literal error from signed rem function" severity note;
      snull     := check7sf1 rem "0001";
      check7sf1 := "0011100";           -- 3.5
      report "Expect literal error from signed rem function" severity note;
      snull     := "0001" rem check7sf1;
      check7sf1 := "0011100";           -- 3.5
      report "Expect literal error from signed = function" severity note;
      assert not (check7sf1 = "00001")
        report "sfixed = literal returned true" severity error;
      report "Expect literal error from signed /= function" severity note;
      assert (check7sf1 /= "00001")
        report "sfixed /= literal returned false" severity error;
      report "Expect literal error from signed < function" severity note;
      assert not (check7sf1 < "00001")
        report "sfixed = literal returned true" severity error;
      report "Expect literal error from signed > function" severity note;
      assert (check7sf1 > "00001")
        report "sfixed > literal returned false" severity error;
      report "Expect literal error from signed <= function" severity note;
      assert not (check7sf1 <= "00001")
        report "sfixed <= literal returned true" severity error;
      report "Expect literal error from signed >= function" severity note;
      assert (check7sf1 >= "00001")
        report "sfixed >= literal returned false" severity error;
      report "Expect literal error from signed = function" severity note;
      assert not ("00001" = check7sf1)
        report "literal = sfixed returned true" severity error;
      report "Expect literal error from signed /= function" severity note;
      assert ("00001" /= check7sf1)
        report "literal /= sfixed returned false" severity error;
      report "Expect literal error from signed < function" severity note;
      assert ("00001" < check7sf1)
        report "literal < sfixed returned false" severity error;
      report "Expect literal error from signed > function" severity note;
      assert not ("00001" > check7sf1)
        report "literal > sfixed returned true" severity error;
      report "Expect literal error from signed <= function" severity note;
      assert ("00001" <= check7sf1)
        report "literal <= sfixed returned true" severity error;
      report "Expect literal error from signed >= function" severity note;
      assert not ("00001" >= check7sf1)
        report "literal >= sfixed returned false" severity error;
      report "Expect literal error from signed maximum function" severity note;
      check7sf2 (3 downto 0) := maximum ("0001", check7sf1);
      report "Expect literal error from signed minimum function" severity note;
      check7sf2 (3 downto 0) := minimum ("0001", check7sf1);
      report "Expect literal error from signed abs function" severity note;
      snull     := abs("0001");
      report "Expect literal error from signed - function" severity note;
      snull     := -"0001";
      checkint  := 1;
      checkreal := 1.0;
      report "Expect literal error from signed l+r function" severity note;
      snull     := "0001" + checkreal;
      report "Expect literal error from signed l-r function" severity note;
      snull     := "0001" - checkreal;
      report "Expect literal error from signed l*r function" severity note;
      snull     := "0001" * checkreal;
      report "Expect literal error from signed l/r function" severity note;
      snull     := "0001" / checkreal;
      report "Expect literal error from signed r+l function" severity note;
      snull     := checkreal + "0001";
      report "Expect literal error from signed r-l function" severity note;
      snull     := checkreal - "0001";
      report "Expect literal error from signed r*l function" severity note;
      snull     := checkreal * "0001";
      report "Expect literal error from signed r/l function" severity note;
      snull     := checkreal / "0001";
      report "Expect literal error from signed l+i function" severity note;
      snull     := "0001" + checkint;
      report "Expect literal error from signed l-i function" severity note;
      snull     := "0001" - checkint;
      report "Expect literal error from signed l*i function" severity note;
      snull     := "0001" * checkint;
      report "Expect literal error from signed l/i function" severity note;
      snull     := "0001" / checkint;
      report "Expect literal error from signed l mod i function" severity note;
      snull     := "0001" mod checkint;
      report "Expect literal error from signed i+l function" severity note;
      snull     := checkint + "0001";
      report "Expect literal error from signed i-l function" severity note;
      snull     := checkint - "0001";
      report "Expect literal error from signed i*l function" severity note;
      snull     := checkint * "0001";
      report "Expect literal error from signed i/l function" severity note;
      snull     := checkint / "0001";
      report "Expect literal error from signed i mod l function" severity note;
      snull     := checkint mod "0001";
    end if;
    check7uf1 := "0010100";             -- 2.5
    check7uf  := check7uf1 + to_ufixed(unsigned'("0001"));
    report_error ("ufixed + to_ufixed(literal)", check7uf,
                  to_ufixed(3.5, check7uf'high, check7uf'low));
    check7uf := to_ufixed(unsigned'("0001")) + check7uf1;
    report_error ("to_ufixed(literal) + ufixed", check7uf,
                  to_ufixed(3.5, check7uf'high, check7uf'low));
    check7uf1 := "0011000";             -- 3
    check7uf  := check7uf1 + to_ufixed (unsigned'("1"));
    report_error ("ufixed+ to_ufixed(""1"")", check7uf,
                  to_ufixed(4, check7uf'high, check7uf'low));
    check7uf := to_ufixed (unsigned'("1")) + check7uf1;
    report_error ("to_ufixed(""1"") + ufixed", check7uf,
                  to_ufixed(4, check7uf'high, check7uf'low));
    assert (quiet) report "String literal test completed" severity note;
    literaltest_done <= true;
    wait;
  end process literaltest;


end architecture testbench;
