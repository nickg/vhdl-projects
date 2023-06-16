-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the base "fphdl_base_pkg" package.
-- This is a test of the routines which the user needs to call from the
-- base package.  Most of the testing of the base routines is done in the
-- test vector for the lower level packages.
-- Last Modified: $Date: 2010/09/17 19:03:27 $
-- RCS ID: $Id: test_fphdlbase.vhdl,v 2.0 2010/09/17 19:03:27 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_fphdlbase is
  generic (
    quiet : BOOLEAN := false);          -- run quietly 
end entity test_fphdlbase;

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.fixed_float_types.all;
use ieee.float_pkg.all;
use ieee.fixed_pkg.all;
architecture testbench of test_fphdlbase is
  -- purpose: reports an error
  procedure report_error (
    constant errmes   : in STRING;               -- error message
    actual            : in float;                -- data from algorithm
    constant expected : in float)  is            -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & LF
      & "Actual   " & to_string(actual) & " ("
      & REAL'image(to_real(actual)) & ") /= " & LF
      & "Expected " & to_string(expected) & " ("
      & REAL'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;
  procedure report_error (
    constant errmes   : in STRING;               -- error message
    actual            : in ufixed;               -- data from algorithm
    constant expected : in ufixed)  is           -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & LF
      & "Actual   " & to_string(actual) & " /= " & LF
      & "Expected " & to_string(expected)
      severity error;
    return;
  end procedure report_error;
  procedure report_error (
    constant errmes   : in STRING;               -- error message
    actual            : in sfixed;               -- data from algorithm
    constant expected : in sfixed)  is           -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & LF
      & "Actual   " & to_string(actual) & " /= " & LF
      & "Expected " & to_string(expected)
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
      & "Actual: " & to_string(actual) & LF
      & "     /= " & to_string(expected)
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes   :    STRING;       -- error message
    actual            : in UNSIGNED;     -- data from algorithm
    constant expected :    UNSIGNED) is  -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(actual)
      & " (" & NATURAL'image(to_integer(actual)) & ")" & LF
      & "     /= " & to_string(expected)
      & " (" & NATURAL'image(to_integer(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes   :    STRING;      -- error message
    actual            : in SIGNED;      -- data from algorithm
    constant expected :    SIGNED) is   -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(actual)
      & " (" & INTEGER'image(to_integer(actual)) & ")" & LF
      & "     /= " & to_string(expected)
      & " (" & INTEGER'image(to_integer(expected)) & ")"
      severity error;
    return;
  end procedure report_error;
  signal start_guardtest, guardtest_done       : BOOLEAN := false;
  signal start_breaktest, breaktest_done       : BOOLEAN := false;
  signal start_resizetest, resizetest_done     : BOOLEAN := false;
  signal start_operatortest, operatortest_done : BOOLEAN := false;
  signal start_roundtest, roundtest_done       : BOOLEAN := false;
  signal start_mixedtest, mixedtest_done       : BOOLEAN := false;
  signal start_booltest, booltest_done         : BOOLEAN := false;
  signal start_logictest, logictest_done       : BOOLEAN := false;
  signal start_matchtest, matchtest_done       : BOOLEAN := false;
  signal start_reduce_test, reduce_test_done   : BOOLEAN := false;  -- reduce
  signal start_fromstrtest, fromstrtest_done   : BOOLEAN := false;  -- from_string
  signal start_dentest, dentest_done           : BOOLEAN := false;  -- denormal
  signal start_mactest, mactest_done           : BOOLEAN := false;
  signal start_sqrttest, sqrttest_done         : BOOLEAN := false;  -- sqrt
  signal start_intrange, intrange_done         : BOOLEAN := false;  -- int range
begin  -- architecture testbench

  -- purpose: master test process
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  master_test : process is
  begin
    start_guardtest    <= true;
    wait until guardtest_done;
    start_breaktest    <= true;
    wait until breaktest_done;
    start_resizetest   <= true;
    wait until resizetest_done;
    start_operatortest <= true;
    wait until operatortest_done;
    start_roundtest    <= true;
    wait until roundtest_done;
    start_mixedtest    <= true;
    wait until mixedtest_done;
    start_booltest     <= true;
    wait until booltest_done;
    start_logictest    <= true;
    wait until logictest_done;
    start_reduce_test  <= true;
    wait until reduce_test_done;
    start_mactest      <= true;
    wait until mactest_done;
    -- Check the match and ?= function
    start_matchtest    <= true;
    wait until matchtest_done;
    start_dentest      <= true;
    wait until dentest_done;
    start_sqrttest     <= true;
    wait until sqrttest_done;
    start_intrange     <= true;
    wait until intrange_done;
    ---------------------------------------------------------------------------
    -- From_string test
    ---------------------------------------------------------------------------
    start_fromstrtest  <= true;
    wait until fromstrtest_done;
    report "fphdlbase package testing complete" severity note;
  end process master_test;

  -- purpose: testing process
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  test_process : process is
    variable checknum   : float32;      -- Floating point output
    variable checknum2  : float32;      -- Floating point output
    variable checknum3  : float32;      -- Floating point output
    variable checkint   : INTEGER;      -- integer test
    variable checkreal  : REAL;         -- real test
    variable checkreal2 : REAL;         -- real test
    variable L          : LINE;         -- line
  begin  -- process test_process
    wait until start_guardtest;
    -- the primary test in this section is to test the guard
    -- bits.
    -- 1/2
    checknum2 := to_float (arg            => 1,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum3 := to_float (arg            => 0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 3);
    checknum3 := to_float (arg            => 1.0/0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/0.5 (guard 3)", checknum, checknum3);
    checknum3 := to_float (arg            => 0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 2);
    checknum3 := to_float (arg            => 1.0/0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/0.5 (guard 2)", checknum, checknum3);
    checknum3 := to_float (arg            => 0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 1);
    checknum3 := to_float (arg            => 1.0/0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/0.5 (guard 1)", checknum, checknum3);
    checknum3 := to_float (arg            => 0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 0);
    checknum3 := to_float (arg            => 1.0/0.5,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/0.5 (guard 0)", checknum, checknum3);
    -- 1/3
    checknum2 := to_float (arg            => 1,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum3 := to_float (arg            => 3,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 3);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/3 (guard 3)", checknum, checknum3);
    assert (quiet or fphdlsynth_or_real = true)
      report "Some of these test will fail when using the "
      & "REAL version of the fphdl_base_pkg body due to real rounding rules "
      & "in math_real" severity note;
    checknum2 := to_float (arg            => 1,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum3 := to_float (arg            => 3,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 2);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/3 (guard 2)", checknum, checknum3);
    checknum2 := to_float (arg            => 1,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum3 := to_float (arg            => 3,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 1);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("1/3 (guard 1)", checknum, checknum3);
    checknum2 := to_float (arg            => 1,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum3 := to_float (arg            => 3,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := divide (l     => checknum2,
                        r     => checknum3,
                        guard => 0);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low,
                           round_style    => round_zero);
    if not quiet or fphdlsynth_or_real = true then
      assert fphdlsynth_or_real
        report "Real package will cause a rounding error here" severity note;
      report_error ("1/3 (guard 0)", checknum, checknum3);
    end if;


    -- reciprocal
    checknum2 := to_float (arg            => 8,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := reciprocal (arg   => checknum2,
                            guard => 3);
    checknum3 := to_float (arg            => 1.0/8.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("reciprocal of 8 (guard 3)", checknum, checknum3);
    checknum := reciprocal (arg   => checknum2,
                            guard => 2);
    report_error ("reciprocal of 8 (guard 2)", checknum, checknum3);
    checknum := reciprocal (arg   => checknum2,
                            guard => 1);
    report_error ("reciprocal of 8 (guard 1)", checknum, checknum3);
    checknum := reciprocal (arg   => checknum2,
                            guard => 0);
    report_error ("reciprocal of 8 (guard 0)", checknum, checknum3);
    checknum2 := to_float (arg            => 3,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    checknum := reciprocal (arg   => checknum2,
                            guard => 3);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("reciprocal of 3 (guard 3)", checknum, checknum3);
    checknum := reciprocal (arg   => checknum2,
                            guard => 2);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low);
    report_error ("reciprocal of 3 (guard 2)", checknum, checknum3);
    checknum := reciprocal (arg   => checknum2,
                            guard => 1);
    report_error ("reciprocal of 3 (guard 1)", checknum, checknum3);
    checknum := reciprocal (arg   => checknum2,
                            guard => 0);
    checknum3 := to_float (arg            => 1.0/3.0,
                           exponent_width => float32'high,
                           fraction_width => -float32'low,
                           round_style    => round_zero);
    if not quiet or fphdlsynth_or_real = true then
      assert fphdlsynth_or_real
        report "Real package will cause a rounding error here" severity note;
      report_error ("reciprocal of 3 (guard 0)", checknum, checknum3);
    end if;
    assert (quiet) report "Guard and rounding test completed" severity note;
    guardtest_done <= true;
    wait;
  end process test_process;

  -- purpose: test the break and normalize functions
  breaktest : process is
    variable checknum          : float32;  -- Floating point output
    variable checknum2         : float32;  -- Floating point output
    variable fract, fract2     : UNSIGNED (-float32'low downto 0);  -- fraction
    variable exp, exp2         : SIGNED (float32'high-1 downto 0);  -- exponent
    variable lfract, lfract2   : UNSIGNED (-float32'low+3 downto 0);  -- fraction
    variable llfract, llfract2 : UNSIGNED (-float32'low+4 downto 0);  -- fraction
    variable lexp, lexp2       : SIGNED (float32'high downto 0);    -- exponent
    variable ulfract, ulfract2 : ufixed (0 downto float32'low-3);
    variable sign              : STD_ULOGIC;                        -- sign bit
  begin  -- process breaktest

    wait until start_breaktest;
    checknum := "11000000110100000000000000000000";  -- -6.5
    fract2   := "110100000000000000000000";
    exp2     := "00000001";
    break_number (arg          => checknum,
                   denormalize => true,
                   fract       => fract,
                   expon       => exp,
                   sign        => sign);
    report_error ("-6.5 fraction mismatch ", fract, fract2);
    report_error ("-6.5 exponent mismatch ", exp, exp2);
    checknum2 := normalize (fract          => fract2,
                            expon          => exp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 0);
    report_error ("normalize -6.5", checknum2, checknum);
    checknum := "10111110101010101010101010101010";  -- -1/3
    fract2   := "101010101010101010101010";
    exp2     := "11111101";
    break_number (arg          => checknum,
                   denormalize => true,
                   fract       => fract,
                   expon       => exp,
                   sign        => sign);
    report_error ("-1/3 fraction mismatch ", fract, fract2);
    report_error ("-1/3 exponent mismatch ", exp, exp2);
    checknum2 := normalize (fract          => fract2,
                            expon          => exp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 0);
    report_error ("normalize -1/3", checknum2, checknum);
    checknum := "00000000100000000000000000000000";  -- 2**-126
    fract2   := "100000000000000000000000";
    exp2     := "10000001";
    break_number (arg          => checknum,
                   denormalize => true,
                   fract       => fract,
                   expon       => exp,
                   sign        => sign);
    report_error ("2**-126 fraction mismatch ", fract, fract2);
    report_error ("2**-126 exponent mismatch ", exp, exp2);
    checknum2 := normalize (fract          => fract2,
                            expon          => exp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 0);
    report_error ("normalize 2**-126", checknum2, checknum);
    checknum := "00000000000000000000000000000010";  -- 2*-149
    fract2   := "000000000000000000000010";
    exp2     := "10000001";
    break_number (arg          => checknum,
                   denormalize => true,
                   fract       => fract,
                   expon       => exp,
                   sign        => sign);
    report_error ("2**-149 fraction mismatch ", fract, fract2);
    report_error ("2**-149 exponent mismatch ", exp, exp2);
    checknum2 := normalize (fract          => fract2,
                            expon          => exp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 0);
    report_error ("normalize 2**-149", checknum2, checknum);

    checknum := "00111110101010101010101010101011";  -- 1/3
    lfract2  := "101010101010101010101010101";
    lexp2    := "111111101";

    checknum2 := normalize (fract          => lfract2,
                            expon          => lexp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 3);
    report_error ("normalize 1/3", checknum2, checknum);

    checknum := "00111110101010101010101010101011";  -- 1/3
    llfract2 := "0101010101010101010101010101";
    lexp2    := "111111101";                         -- -3

    checknum2 := normalize (fract          => llfract2,
                            expon          => lexp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 3);
    report_error ("normalize long 1/3", checknum2, checknum);

    checknum := "00111110101010101010101010101011";  -- 1/3
    llfract2 := "1010101010101010101010101010";      -- shifted left
    lexp2    := "111111100";                         -- -4

    checknum2 := normalize (fract          => llfract2,
                            expon          => lexp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 3);
    report_error ("normalize shift 1/3", checknum2, checknum);

    checknum := "00111110101010101010101010101010";  -- 1/3
    llfract2 := "0010101010101010101010101010";      -- shifted right
    lexp2    := "111111110";                         -- -2

    checknum2 := normalize (fract          => llfract2,
                            expon          => lexp2,
                            sign           => checknum(checknum'high),
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 3);
    report_error ("normalize -shift 1/3", checknum2, checknum);


    checknum := "00111110101010101010101010101011";  -- 1/3
    ulfract2 := "101010101010101010101010101";
    lexp2    := "111111101";

    checknum2 := normalize (fract          => ulfract2,
                            expon          => lexp2,
                            sign           => '0',
                            fraction_width => -checknum'low,
                            exponent_width => checknum'high,
                            round_style    => round_nearest,
                            denormalize    => true,
                            nguard         => 3);
    report_error ("normalize ufixed 1/3", checknum2, checknum);
    checknum := "00111110101010101010101010101011";  -- 1/3
    ulfract2 := "101010101010101010101010101";
    lexp2    := "111111101";

    checknum2 := normalize (fract       => ulfract2,
                            expon       => lexp2,
                            sign        => checknum(checknum'high),
                            size_res    => checknum,
                            round_style => round_nearest,
                            denormalize => true,
                            nguard      => 3);
    report_error ("normalize ufixed size_res 1/3", checknum2, checknum);

    assert (quiet) report "Normalize and break_number testing completed"
      severity note;
    breaktest_done <= true;
    wait;
  end process breaktest;

  -- purpose: test resize functions
  resizetest : process is
    variable checknum, checknumt   : float32;
    variable check64, check64t     : float64;
    variable check128, check128t   : float128;
    variable check7, check7t       : float (3 downto -3);
    variable checkreal             : REAL;
    variable checkint              : INTEGER;
    variable checkuns              : UNSIGNED(7 downto 0);
    variable checksin              : SIGNED(7 downto 0);
    variable checkuf, checkuft     : ufixed (3 downto -3);
    variable checkufx              : ufixed (3 downto -4);
    variable checkufy              : ufixed (3 downto -6);
    variable checksf, checksft     : sfixed (4 downto -3);
    variable checkuf16, checkuf16t : ufixed (7 downto -8);
    variable checksf16, checksf16t : sfixed (7 downto -8);
  begin
    wait until start_resizetest;
    checkreal := 6.5;
    checknum  := to_float(checkreal, checknum);
    checknumt := "01000000110100000000000000000000";
    report_error ("to_float(6.5)", checknum, checknumt);
    checkint  := 2;
    check7    := to_float(checkint, check7);
    check7t   := "0100000";             -- 2
    report_error ("to_float(2)", check7, check7t);
    checkuns  := "00000100";            -- 4
    check7    := to_float (checkuns, check7);
    check7t   := "0101000";             -- 4
    report_error ("to_float(us4)", check7, check7t);
    checkuns  := "11111111";            -- 255
    check7    := to_float (checkuns, check7);         -- overflow
    check7t   := "0111000";             -- infinity in 7 bits
    report_error ("to_float (SIGNED 255 overflow)", check7, check7t);
    checkuns  := "11111111";            -- 255
    checknum  := to_float (checkuns, checknum);
    report_error ("to_float (SIGNED 255)", checknum, to_float(255, checknum));
    checkuns  := "11111110";            -- 254
    checknum  := to_float (checkuns, checknum);
    report_error ("to_float (SIGNED 254)", checknum, to_float(254, checknum));
    checkuns  := "01111111";            -- 127
    checknum  := to_float (checkuns, checknum);
    report_error ("to_float (SIGNED 255)", checknum, to_float(127, checknum));
    checknum  := to_float (254, checknum);
    checkuns  := to_unsigned (checknum, checkuns'length);
    assert (checkuns = "11111110")
      report "to_unsigned 254 = "
      & INTEGER'image(to_integer(checkuns))
      severity error;
    checknum := to_float (255, checknum);
    checkuns := to_unsigned (checknum, checkuns'length);
    assert (checkuns = "11111111")
      report "to_unsigned 255 = "
      & INTEGER'image(to_integer(checkuns))
      severity error;
    checknum := to_float (256, checknum);
    checkuns := to_unsigned (checknum, checkuns'length);
    assert (checkuns = "11111111")
      report "to_unsigned 256 overflow = "
      & INTEGER'image(to_integer(checkuns))
      severity error;
    checknum := to_float (512, checknum);
    checkuns := to_unsigned (checknum, checkuns'length);
    assert (checkuns = "11111111")
      report "to_unsigned 512 overflow = "
      & INTEGER'image(to_integer(checkuns))
      severity error;
    checksin  := "11111111";            -- -1
    check7    := to_float (checksin, check7);
    check7t   := "1011000";             -- -1
    report_error ("to_float(SIGNED -1)", check7, check7t);
    check7    := "0101101";             -- 6.5
    checkreal := to_real(check7);
    assert (checkreal = 6.5)
      report "to_real (" & to_string(check7) & ") = " & REAL'image(checkreal)
      & " not 6.5" severity error;
    checkuf   := "0110100";             -- 6.5
    check7    := to_float (checkuf, check7);
    check7t   := "0101101";             -- 6.5
    report_error ("to_float(ufixed 6.5)", check7, check7t);
    checksf   := "11001100";            -- -6.5
    checkreal := to_real(checksf);
    assert (checkreal = -6.5)
      report "to_real (" & to_string(checksf) & ") = " & REAL'image(checkreal)
      & " not -6.5" severity error;
    checksf  := "11001100";             -- -6.5
    check7   := to_float (checksf, check7);
    check7t  := "1101101";              -- -6.5
    report_error ("to_float(sfixed -6.5)", check7, check7t);
    checksin := "01111111";             -- 127
    checknum := to_float (checksin, checknum);
    report_error ("to_float(SIGNED 127)", checknum, to_float(127, checknum));
    checksin := "10000001";             -- -127
    checknum := to_float (checksin, checknum);
    report_error ("to_float(SIGNED -127)", checknum, to_float(-127, checknum));
    checksin := "10000000";             -- -128
    checknum := to_float (checksin, checknum);
    report_error ("to_float(SIGNED -128)", checknum, to_float(-128, checknum));
    checknum := to_float(127, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "01111111")
      report "to_signed (32 bit signed 127) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(-127, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "10000001")
      report "to_signed (32 bit signed -127) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(-128, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "10000000")
      report "to_signed (32 bit signed -128) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(-129, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "10000000")
      report "to_signed (32 bit signed -129 overflow) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(-257, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "10000000")
      report "to_signed (32 bit signed -257 overflow) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(-513, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "10000000")
      report "to_signed (32 bit signed -513 overflow) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(128, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "01111111")
      report "to_signed (32 bit signed 128 overflow) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(257, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "01111111")
      report "to_signed (32 bit signed 257 overflow) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum := to_float(513, checknum);
    checksin := to_signed (checknum, checksin'length);
    assert (checksin = "01111111")
      report "to_signed (32 bit signed 513 overflow) = "
      & INTEGER'image(to_integer(checksin))
      severity error;
    checknum  := "01000000110100000000000000000000";
    check7    := resize (checknum, check7t);
    check7t   := "0101101";             -- 6.5
    report_error ("resize 32bit 6.5 to 7 bits", check7, check7t);
    checknum  := "11000000110100000000000000000000";  -- -6.5
    check64   := resize (checknum, check64);
    check64t  := "1100000000011010000000000000000000000000000000000000000000000000";
    report_error ("-6.5, 32 to 64 resize", check64, check64t);
    check64   := "0100000000011010000000000000000000000000000000000000000000000000";
    check7    := resize (check64, check7);
    check7t   := "0101101";             -- 6.5
    report_error ("resize 64 to 7 6.5", check7, check7t);
    -- While we're here, do some denormal testing.
    check7    := "0000100";             -- 0.125 denormal
    checkreal := to_real(check7);
    assert (checkreal = 0.125)
      report "to_real (" & to_string(check7) & ") = "
      & REAL'image(checkreal) & " (not 0.125)" severity error;
    check7    := "0000100";             -- 0.1875 normal
    checkreal := to_real(arg => check7, denormalize => false);
    assert (checkreal = 0.1875)
      report "to_real (" & to_string(check7) & " no denormal) = "
      & REAL'image(checkreal) & " (not 0.1875)" severity error;
    check7    := "0000101";             -- 0.15625 denormal
    checkreal := to_real(check7);
    assert (checkreal = 0.15625)
      report "to_real (" & to_string(check7) & ") = "
      & REAL'image(checkreal) & " (not 0.15625)" severity error;
    check7    := "0000101";
    checkreal := to_real(arg => check7, denormalize => false);
    assert (checkreal = 0.203125)
      report "to_real (" & to_string(check7) & " no denormal) = "
      & REAL'image(checkreal) & " (not 0.203125)" severity error;
    check7    := "0000001";             -- 0.03125 denormal
    checkreal := to_real(check7);
    assert (checkreal = 0.03125)
      report "to_real (" & to_string(check7) & ") = "
      & REAL'image(checkreal) & " (not 0.03125)" severity error;
    check7    := "0000001";
    checkreal := to_real(arg => check7, denormalize => false);
    assert (checkreal = 0.140625)
      report "to_real (" & to_string(check7) & " no denormal) = "
      & REAL'image(checkreal) & " (not 0.140625)" severity error;
    check7    := "0001000";             -- normal 0.25
    checkreal := to_real(check7);
    assert (checkreal = 0.25)
      report "to_real (" & to_string(check7) & ") = "
      & REAL'image(checkreal) & " (not 0.25)" severity error;
    check7    := "0001000";             -- normal 0.25
    checkreal := to_real(arg => check7, denormalize => false);
    assert (checkreal = 0.25)
      report "to_real (" & to_string(check7) & " no denormal) = "
      & REAL'image(checkreal) & " (not 0.25)" severity error;
    -- real to fp
    checkreal := 0.125;
    check7    := to_float (checkreal, check7);
    check7t   := "0000100";             -- 0.125 denormal
    report_error ("to_float(0.125 denormal)", check7, check7t);
    checkreal := 0.125;
    check7 := to_float (arg         => checkreal, size_res => check7,
                        denormalize => false);
    check7t   := "0000000";             -- 0, underflow
    report_error ("to_float(0.125 non denormal underflow)", check7, check7t);
    checkreal := 0.1875;
    check7 := to_float (arg         => checkreal, size_res => check7,
                        denormalize => false);
    check7t   := "0000100";             -- 0.1875 normal
    report_error ("to_float(0.1875 non denormal)", check7, check7t);
    checkreal := 0.15625;
    check7    := to_float (checkreal, check7);
    check7t   := "0000101";             -- 0.15625 denormal
    report_error ("to_float(0.15625 denormal)", check7, check7t);
    checkreal := 0.203125;
    check7 := to_float (arg         => checkreal, size_res => check7,
                        denormalize => false);
    check7t   := "0000101";             -- 0.203125 non denormal
    report_error ("to_float(0.203125 non denormal)", check7, check7t);
    checkreal := 0.03125;               -- smallist 7 bit denormal number
    check7    := to_float (checkreal, check7);
    check7t   := "0000001";             -- 0.03125 denormal
    report_error ("to_float(0.03125 denormal)", check7, check7t);
    checkreal := 0.140625;
    check7 := to_float (arg         => checkreal, size_res => check7,
                        denormalize => false);
    check7t   := "0000001";             -- 0.03125 denormal
    report_error ("to_float(0.140625 non denormal)", check7, check7t);
    checkreal := 0.25;
    check7    := to_float (checkreal, check7);
    check7t   := "0001000";             -- normal 0.25
    report_error ("to_float(0.25 denormal)", check7, check7t);
    checkreal := 0.25;
    check7 := to_float (arg         => checkreal, size_res => check7,
                        denormalize => false);
    check7t  := "0001000";              -- normal 0.25
    report_error ("to_float(0.25 non denormal)", check7, check7t);
    -- to_ufixed
    check7   := "0000100";              -- 0.125 denormal
    checkuf  := to_ufixed (check7, checkuf);
    checkuft := "0000001";              -- 0.125 unsigned fixed
    report_error ("to_ufixed (" & to_string(check7) &")", checkuf, checkuft);
    check7   := "0000100";              -- 0.125 denormal
    checkuf16 := to_ufixed (arg         => check7, size_res => checkuf16,
                            denormalize => false);
    checkuf16t := "0000000000110000";   -- 0.1875 unsigned fixed
    report_error ("to_ufixed (" & to_string(check7) &" non denormal)",
                  checkuf16, checkuf16t);
    check7     := "0000101";            -- 0.15625 denormal
    checkuf16  := to_ufixed (check7, checkuf16);
    checkuf16t := to_ufixed (0.15625, checkuf16t);
    report_error ("to_ufixed (" & to_string(check7) &" non denormal)",
                  checkuf16, checkuf16t);
    -- to_sfixed
    check7   := "0000100";              -- 0.125 denormal
    checksf  := to_sfixed (check7, checksf);
    checksft := "00000001";             -- 0.125 unsigned fixed
    report_error ("to_sfixed (" & to_string(check7) &")", checksf, checksft);
    check7   := "0000100";              -- 0.125 denormal
    checksf16 := to_sfixed (arg         => check7, size_res => checksf16,
                            denormalize => false);
    checksf16t := "0000000000110000";   -- 0.1875 unsigned fixed
    report_error ("to_sfixed (" & to_string(check7) &" non denormal)",
                  checksf16, checksf16t);
    check7     := "0000101";            -- 0.15625 denormal
    checksf16  := to_sfixed (check7, checksf16);
    checksf16t := to_sfixed (0.15625, checksf16t);
    report_error ("to_sfixed (" & to_string(check7) &" non denormal)",
                  checksf16, checksf16t);
    -- to_float (ufixed)
    checkuf := "0000001";               -- 0.125 unsigned fixed
    check7  := to_float (checkuf, check7);
    check7t := "0000100";               -- 0.125 denormal
    report_error ("to_float(" & to_string(checkuf) & " denormal)",
                  check7, check7t);
    checkuf := "0000001";               -- 0.125 unsigned fixed
    check7 := to_float (arg         => checkuf, size_res => check7,
                        denormalize => false);
    check7t := "0000000";               -- underflow
    report_error ("to_float(" & to_string(checkuf) & " non denormal)",
                  check7, check7t);
    checkuf16 := "0000000000110000";    -- 0.1875 unsigned fixed
    check7 := to_float (arg         => checkuf16, size_res => check7,
                        denormalize => false);
    check7t := "0000100";               -- 0.1875 normal
    report_error ("to_float(" & to_string(checkuf16) & " nondenormal)",
                  check7, check7t);
    checkuf16 := to_ufixed (0.03125, checkuf16);
    check7    := to_float (checkuf16, check7);
    check7t   := "0000001";             -- 0.03125 denormal
    report_error ("to_float(" & to_string(checkuf16) & " denormal)",
                  check7, check7t);
    checkuf := "0000010";               -- 0.25
    check7  := to_float(checkuf, check7);
    check7t := "0001000";               -- normal 0.25
    report_error ("to_float(" & to_string(checkuf16) & " denormal)",
                  check7, check7t);
    checkufx := "00000010";             -- 0.125 unsigned fixed
    check7   := to_float (checkufx, check7);
    check7t  := "0000100";              -- 0.125 denormal
    report_error ("to_float(" & to_string(checkufx) & " denormal)",
                  check7, check7t);
    checkufx := "00000001";             -- 0.125/2 unsigned fixed
    check7   := to_float (checkufx, check7);
    check7t  := "0000010";              -- 0.125 denormal
    report_error ("to_float(" & to_string(checkufx) & " denormal)",
                  check7, check7t);
    checkufy := "0000001000";           -- 0.125 unsigned fixed
    check7   := to_float (checkufy, check7);
    check7t  := "0000100";              -- 0.125 denormal
    report_error ("to_float(" & to_string(checkufy) & " denormal)",
                  check7, check7t);
    checkufy := "0000001111";           -- 0.125+ unsigned fixed
    check7   := to_float (checkufy, check7);
    check7t  := "0001000";              -- min normal
    report_error ("to_float(" & to_string(checkufy) & " min normal)",
                  check7, check7t);
    checkuf := "1111111";
    check7  := to_float(checkuf, check7);
    check7t := "0111000";               -- infinity
    report_error ("to_float(" & to_string(checkuf) & " inf)",
                  check7, check7t);
    checkuf := "0000000";
    check7  := to_float(checkuf, check7);
    check7t := "0000000";               -- zero
    report_error ("to_float(" & to_string(checkuf) & " zero)",
                  check7, check7t);
    -- to_float (sfixed)
    checksf := "00000001";              -- 0.125 unsigned fixed
    check7  := to_float (checksf, check7);
    check7t := "0000100";               -- 0.125 denormal
    report_error ("to_float(signed " & to_string(checksf) & " denormal)",
                  check7, check7t);
    checksf := "00000001";              -- 0.125 unsigned fixed
    check7 := to_float (arg         => checksf, size_res => check7,
                        denormalize => false);
    check7t := "0000000";               -- underflow
    report_error ("to_float(signed " & to_string(checksf) & " non denormal)",
                  check7, check7t);
    checksf16 := "0000000000110000";    -- 0.1875 unsigned fixed
    check7 := to_float (arg         => checksf16, size_res => check7,
                        denormalize => false);
    check7t := "0000100";               -- 0.1875 normal
    report_error ("to_float(signed " & to_string(checksf16) & " nondenormal)",
                  check7, check7t);
    checksf16 := to_sfixed (0.03125, checksf16);
    check7    := to_float (checksf16, check7);
    check7t   := "0000001";             -- 0.03125 denormal
    report_error ("to_float(signed " & to_string(checksf16) & " denormal)",
                  check7, check7t);
    checksf := "00000010";              -- 0.25
    check7  := to_float(checksf, check7);
    check7t := "0001000";               -- normal 0.25
    report_error ("to_float(signed " & to_string(checksf16) & " denormal)",
                  check7, check7t);
    assert (quiet) report "Resize test completed" severity note;
    resizetest_done <= true;
    wait;
  end process resizetest;

  -- purpose: test operators
  operatortest : process is
    variable ck7, ck7t, ck7x : float (3 downto -3);
    variable checkreal       : REAL;
    variable checkint        : INTEGER;
  begin
    wait until start_operatortest;
    ck7x            := "1101000";       -- -4
    ck7             := abs (ck7x);
    ck7t            := "0101000";       -- 4
    report_error ("abs(-4)", ck7, ck7t);
    ck7x            := "0101000";       -- 4
    ck7             := - ck7x;
    ck7t            := "1101000";       -- -4
    report_error ("-4", ck7, ck7t);
    ck7             := "0101000";       -- 4
    ck7x            := "0100000";       -- 2
    ck7x            := ck7 + ck7x;
    ck7t            := "0101100";       -- 6
    report_error ("4+2=6", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    ck7x            := "0100000";       -- 2
    ck7x            := ck7 - ck7x;
    ck7t            := "0100000";       -- 2
    report_error ("4-2=2", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    ck7x            := "0100000";       -- 2
    ck7x            := ck7 * ck7x;
    ck7t            := "0110000";       -- 8
    report_error ("4*2=8", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    ck7x            := "0100000";       -- 2
    ck7x            := ck7 / ck7x;
    ck7t            := "0100000";       -- 2
    report_error ("4/2=2", ck7x, ck7t);
    ck7             := "0101101";       -- 6.5
    ck7x            := "0100000";       -- 2
    ck7             := ck7 mod ck7x;
    ck7t            := to_float (0.5, ck7t);
    report_error ("6.5 mod 2", ck7, ck7t);
    ck7             := "0101101";       -- 6.5
    ck7x            := "0100000";       -- 2
    ck7             := ck7 rem ck7x;
    ck7t            := to_float (0.5, ck7t);
    report_error ("6.5 rem 2", ck7, ck7t);
    -- check some compare functions
    ck7             := "0101000";       -- 4
    ck7x            := "1100000";       -- -2
    assert not (ck7 = ck7x) report "4=-2 returns true" severity error;
    assert (ck7 = ck7) report "4=4 returns false" severity error;
    assert (ck7 /= ck7x) report "4/=-2 returns false" severity error;
    assert not (ck7 /= ck7) report "4/=4 returns true" severity error;
    assert (ck7 > ck7x) report "4 > -2 returns false" severity error;
    assert not (ck7x > ck7) report "-2 > 4 returns true" severity error;
    assert not (ck7x > ck7x) report "-2 > -2 returns true" severity error;
    assert (ck7 >= ck7x) report "4 >= -2 returns false" severity error;
    assert not (ck7x >= ck7) report "-2 >= 4 returns true" severity error;
    assert (ck7x >= ck7x) report "-2 >= -2 returns false" severity error;
    assert not (ck7 < ck7x) report "4 < -2 returns true" severity error;
    assert (ck7x < ck7) report "-2 < 4 returns false" severity error;
    assert not (ck7x < ck7x) report "-2 < -2 returns true" severity error;
    assert not (ck7 <= ck7x) report "4 <= -2 returns true" severity error;
    assert (ck7x    <= ck7) report "-2 <= 4 returns false" severity error;
    assert (ck7x    <= ck7x) report "-2 <= -2 returns false" severity error;
    -- maximum and minimum
    ck7             := "0101000";       -- 4
    ck7x            := "1100000";       -- 2
    assert (ck7 = maximum (ck7, ck7x))
      report "max (4, -2) error" severity error;
    assert (ck7 = maximum (ck7x, ck7))
      report "max (-2, 4) error" severity error;
    assert (ck7x = minimum (ck7, ck7x))
      report "min (4, -2) error" severity error;
    assert (ck7x = minimum (ck7x, ck7))
      report "min (-2, 4) error" severity error;
    assert not (std_match (ck7, ck7x))
      report to_string(ck7) & " ?= " & to_string(ck7x) & " return true"
      severity error;
    assert not (std_match (ck7x, ck7))
      report to_string(ck7x) & " ?= " & to_string(ck7) & " return true"
      severity error;
    assert (std_match (ck7, ck7))
      report to_string(ck7) & " ?= " & to_string(ck7) & " return false"
      severity error;
    assert (std_match (ck7x, ck7x))
      report to_string(ck7x) & " ?= " & to_string(ck7x) & " return false"
      severity error;
    ck7  := "0101000";                  -- 4
    ck7x := "----000";                  -- zero fraction
    assert (std_match (ck7, ck7x))
      report to_string(ck7) & " ?= " & to_string(ck7x) & " return false"
      severity error;
    assert (std_match (ck7x, ck7))
      report to_string(ck7x) & " ?= " & to_string(ck7) & " return false"
      severity error;
    ck7 := "0101010";                   -- 5
    assert not (std_match (ck7, ck7x))
      report to_string(ck7) & " ?= " & to_string(ck7x) & " return true"
      severity error;
    assert not (std_match (ck7x, ck7))
      report to_string(ck7x) & " ?= " & to_string(ck7) & " return true"
      severity error;
    -- overloads for "real"
    ck7             := "0101000";       -- 4
    checkreal       := 2.0;
    ck7x            := ck7 + checkreal;
    ck7t            := "0101100";       -- 6
    report_error ("4+2.0=6", ck7x, ck7t);
    ck7x            := checkreal + ck7;
    report_error ("2.0+4=6", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    checkreal       := 2.0;
    ck7x            := ck7 - checkreal;
    ck7t            := "0100000";       -- 2
    report_error ("4-2.0=2", ck7x, ck7t);
    ck7x            := checkreal - ck7;
    ck7t            := "1100000";       -- 2
    report_error ("2.0-4=-2", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    checkreal       := 2.0;
    ck7x            := ck7 * checkreal;
    ck7t            := "0110000";       -- 8
    report_error ("4*2.0=8", ck7x, ck7t);
    ck7x            := checkreal * ck7;
    report_error ("2.0*4=8", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    checkreal       := 2.0;
    ck7x            := ck7 / checkreal;
    ck7t            := "0100000";       -- 2
    report_error ("4/2.0=2", ck7x, ck7t);
    ck7             := "0100000";       -- 2
    checkreal       := 4.0;
    ck7x            := checkreal / ck7;
    report_error ("4.0/2=2", ck7x, ck7t);
    ck7             := "0101101";       -- 6.5
    ck7             := ck7 mod 2.0;
    ck7t            := to_float (0.5, ck7t);
    report_error ("6.5 mod 2.0", ck7, ck7t);
    ck7             := "0101101";       -- 6.5
    ck7             := ck7 rem 2.0;
    ck7t            := to_float (0.5, ck7t);
    report_error ("6.5 rem 2.0", ck7, ck7t);
    ck7x            := "0100000";       -- 2
    ck7             := 6.5 mod ck7x;
    ck7t            := to_float (0.5, ck7t);
    report_error ("r6.5 mod 2", ck7, ck7t);
    ck7x            := "0100000";       -- 2
    ck7             := 6.5 rem ck7x;
    ck7t            := to_float (0.5, ck7t);
    report_error ("r6.5 rem 2", ck7, ck7t);
    ck7             := "0101000";       -- 4
    ck7x            := "1100000";       -- -2
    assert not (ck7 = -2.0) report "4=-2.0 returns true" severity error;
    assert (ck7 = 4.0) report "4=4.0 returns false" severity error;
    assert not (4.0 = ck7x) report "4.0=-2 returns true" severity error;
    assert (ck7 = 4.0) report "4=4.0 returns false" severity error;
    assert (ck7 /= -2.0) report "4/=-2.0 returns false" severity error;
    assert not (ck7 /= 4.0) report "4/=4.0 returns true" severity error;
    assert (4.0 /= ck7x) report "4.0/=-2 returns false" severity error;
    assert not (4.0 /= ck7) report "4.0/=4 returns true" severity error;
    assert (ck7 > -2.0) report "4 > -2.0 returns false" severity error;
    assert not (ck7x > 4.0) report "-2 > 4.0 returns true" severity error;
    assert not (ck7x > -2.0) report "-2 > -2.0 returns true" severity error;
    assert (4.0 > ck7x) report "4.0 > -2 returns false" severity error;
    assert not (-2.0 > ck7) report "-2.0 > 4 returns true" severity error;
    assert not (-2.0 > ck7x) report "-2.0 > -2 returns true" severity error;
    assert (ck7 >= -2.0) report "4 >= -2.0 returns false" severity error;
    assert not (ck7x >= 4.0) report "-2 >= 4.0 returns true" severity error;
    assert (ck7x >= -2.0) report "-2 >= -2.0 returns false" severity error;
    assert (4.0 >= ck7x) report "4.0 >= -2 returns false" severity error;
    assert not (-2.0 >= ck7) report "-2.0 >= 4 returns true" severity error;
    assert (-2.0 >= ck7x) report "-2.0 >= -2 returns false" severity error;
    assert not (ck7 < -2.0) report "4 < -2.0 returns true" severity error;
    assert (ck7x < 4.0) report "-2 < 4.0 returns false" severity error;
    assert not (ck7x < -2.0) report "-2 < -2.0 returns true" severity error;
    assert not (4.0 < ck7x) report "4.0 < -2 returns true" severity error;
    assert (-2.0 < ck7) report "-2.0 < 4 returns false" severity error;
    assert not (-2.0 < ck7x) report "-2.0 < -2 returns true" severity error;
    assert not (ck7 <= -2.0) report "4 <= -2.0 returns true" severity error;
    assert (ck7x    <= 4.0) report "-2 <= 4.0 returns false" severity error;
    assert (ck7x    <= -2.0) report "-2 <= -2.0 returns false" severity error;
    assert not (4.0 <= ck7x) report "4.0 <= -2 returns true" severity error;
    assert (-2.0    <= ck7) report "-2.0 <= 4 returns false" severity error;
    assert (-2.0    <= ck7x) report "-2.0 <= -2 returns false" severity error;
    -- overloads for "integer"
    ck7             := "0101000";       -- 4
    checkint        := 2;
    ck7x            := ck7 + checkint;
    ck7t            := "0101100";       -- 6
    report_error ("int 4+2=6", ck7x, ck7t);
    ck7x            := checkint + ck7;
    report_error ("int 2+4=6", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    checkint        := 2;
    ck7x            := ck7 - checkint;
    ck7t            := "0100000";       -- 2
    report_error ("int 4-2=2", ck7x, ck7t);
    ck7x            := checkint - ck7;
    ck7t            := "1100000";       -- 2
    report_error ("int 2-4=-2", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    checkint        := 2;
    ck7x            := ck7 * checkint;
    ck7t            := "0110000";       -- 8
    report_error ("int 4*2=8", ck7x, ck7t);
    ck7x            := checkint * ck7;
    report_error ("int 2*4=8", ck7x, ck7t);
    ck7             := "0101000";       -- 4
    checkint        := 2;
    ck7x            := ck7 / checkint;
    ck7t            := "0100000";       -- 2
    report_error ("int 4/2=2", ck7x, ck7t);
    ck7             := "0100000";       -- 2
    checkint        := 4;
    ck7x            := checkint / ck7;
    report_error ("int 4/2=2", ck7x, ck7t);
    ck7             := "0101101";       -- 6.5
    ck7             := ck7 mod 2;
    ck7t            := to_float (0.5, ck7t);
    report_error ("int 6.5 mod 2", ck7, ck7t);
    ck7             := "0101101";       -- 6.5
    ck7             := ck7 rem 2;
    ck7t            := to_float (0.5, ck7t);
    report_error ("int 6.5 rem 2", ck7, ck7t);
    ck7x            := "0100000";       -- 2
    ck7             := 7 mod ck7x;
    ck7t            := to_float (1, ck7t);
    report_error ("7 mod 2", ck7, ck7t);
    ck7x            := "0100000";       -- 2
    ck7             := 7 rem ck7x;
    ck7t            := to_float (1, ck7t);
    report_error ("7 rem 2", ck7, ck7t);
    ck7             := "0101000";       -- 4
    ck7x            := "1100000";       -- -2
    assert not (ck7 = -2) report "int 4=-2 returns true" severity error;
    assert (ck7 = 4) report "int 4=4 returns false" severity error;
    assert not (4 = ck7x) report "int 4=-2 returns true" severity error;
    assert (ck7 = 4) report "int 4=4 returns false" severity error;
    assert (ck7 /= -2) report "int 4/=-2 returns false" severity error;
    assert not (ck7 /= 4) report "int 4/=4 returns true" severity error;
    assert (4 /= ck7x) report "int 4/=-2 returns false" severity error;
    assert not (4 /= ck7) report "int 4/=4 returns true" severity error;
    assert (ck7 > -2) report "int 4 > -2 returns false" severity error;
    assert not (ck7x > 4) report "int -2 > 4 returns true" severity error;
    assert not (ck7x > -2) report "int -2 > -2 returns true" severity error;
    assert (4 > ck7x) report "int 4 > -2 returns false" severity error;
    assert not (-2 > ck7) report "int -2 > 4 returns true" severity error;
    assert not (-2 > ck7x) report "int -2 > -2 returns true" severity error;
    assert (ck7 >= -2) report "int 4 >= -2 returns false" severity error;
    assert not (ck7x >= 4) report "int -2 >= 4 returns true" severity error;
    assert (ck7x >= -2) report "int -2 >= -2 returns false" severity error;
    assert (4 >= ck7x) report "int 4 >= -2 returns false" severity error;
    assert not (-2 >= ck7) report "int -2 >= 4 returns true" severity error;
    assert (-2 >= ck7x) report "int -2 >= -2 returns false" severity error;
    assert not (ck7 < -2) report "int 4 < -2 returns true" severity error;
    assert (ck7x < 4) report "int -2 < 4 returns false" severity error;
    assert not (ck7x < -2) report "int -2 < -2 returns true" severity error;
    assert not (4 < ck7x) report "int 4 < -2 returns true" severity error;
    assert (-2 < ck7) report "int -2 < 4 returns false" severity error;
    assert not (-2 < ck7x) report "int -2 < -2 returns true" severity error;
    assert not (ck7 <= -2) report "int 4 <= -2 returns true" severity error;
    assert (ck7x    <= 4) report "int -2 <= 4 returns false" severity error;
    assert (ck7x    <= -2) report "int -2 <= -2 returns false" severity error;
    assert not (4   <= ck7x) report "int 4 <= -2 returns true" severity error;
    assert (-2      <= ck7) report "int -2 <= 4 returns false" severity error;
    assert (-2      <= ck7x) report "int -2 <= -2 returns false" severity error;

    assert (quiet) report "Operator test completed" severity note;
    operatortest_done <= true;
    wait;
  end process operatortest;

  -- purpose: rounding test
  roundtest : process is
    variable check7, check7t, check7y : float (3 downto -3);
    variable checkreal                : REAL;
    variable checkint                 : INTEGER;
    variable checkuf                  : ufixed (3 downto -3);  -- unsigned fixed point
    variable checksf                  : sfixed (3 downto -3);  -- signed fixed point
  begin
    wait until start_roundtest;
    -- Zero test
    check7   := "0000000";
    checkint := to_integer(check7);
    assert (checkint = 0)
      report "to_integer( 7 bit 0) = " & INTEGER'image(checkint)
      severity error;
    check7   := "1000000";
    checkint := to_integer(check7);
    assert (checkint = 0)
      report "to_integer( 32 bit -0) = " & INTEGER'image(checkint)
      severity error;
    check7    := "0000000";
    checkreal := to_real(check7);
    assert (checkreal = 0.0)
      report "to_integer( 7 bit 0) = " & INTEGER'image(checkint)
      severity error;
    check7    := "1000000";
    checkreal := to_real(check7);
    assert (checkreal = 0.0)
      report "to_integer( 7 bit -0) = " & INTEGER'image(checkint)
      severity error;
    check7  := "0000000";
    checkuf := to_ufixed (check7, checkuf);
    assert (checkuf = 0)
      report "to_ufixed (7 bit 0) = " & to_string(checkuf) severity error;
    check7  := "1000000";
    checkuf := to_ufixed (check7, checkuf);
    assert (checkuf = 0)
      report "to_ufixed (7 bit -0) = " & to_string(checkuf) severity error;
    check7  := "0000000";
    checksf := to_sfixed (check7, checksf);
    assert (checksf = 0)
      report "to_sfixed (7 bit 0) = " & to_string(checksf) severity error;
    check7  := "1000000";
    checksf := to_sfixed (check7, checksf);
    assert (checksf = 0)
      report "to_sfixed (7 bit -0) = " & to_string(checksf) severity error;
    -- Since round_nearest has been tested in other places, we'll
    -- test the other rounding modes here.
    check7  := "0101101";               -- 6.5
    check7t := "0011010";               -- 1.25
    check7 := add (l           => check7, r => check7t,
                   round_style => round_inf,
                   guard       => 1,
                   check_error => false,
                   denormalize => false);
    check7y := "0110000";               -- 8.0 (rounded up)
    report_error ("6.5 + 1.25 round_inf", check7, check7y);
    check7  := "0101101";               -- 6.5
    check7t := "0011010";               -- 1.25
    check7 := add (l           => check7, r => check7t,
                   round_style => round_neginf,
                   guard       => 1,
                   check_error => false,
                   denormalize => false);
    check7y := "0101111";               -- 7.5 (rounded down)
    report_error ("6.5 + 1.25 round_neginf", check7, check7y);
    check7  := "0101101";               -- 6.5
    check7t := "0011010";               -- 1.25
    check7 := add (l           => check7, r => check7t,
                   round_style => round_zero,
                   guard       => 1,
                   check_error => false,
                   denormalize => false);
    check7y := "0101111";               -- 7.5 (truncate)
    report_error ("6.5 + 1.25 round_zero", check7, check7y);
    check7  := "1101101";               -- -6.5
    check7t := "0011010";               -- -1.25
    check7 := subtract (l           => check7, r => check7t,
                        round_style => round_inf,
                        guard       => 1,
                        check_error => false,
                        denormalize => false);
    check7y := "1101111";               -- -7.5 (rounded down)
    report_error ("-6.5 - 1.25 round_inf", check7, check7y);
    check7  := "1101101";               -- -6.5
    check7t := "0011010";               -- 1.25
    check7 := subtract (l           => check7, r => check7t,
                        round_style => round_neginf,
                        guard       => 1,
                        check_error => false,
                        denormalize => false);
    check7y := "1110000";               -- -8.0 (rounded up)
    report_error ("-6.5 - 1.25 round_neginf", check7, check7y);
    check7  := "1101101";               -- -6.5
    check7t := "0011010";               -- 1.25
    check7 := subtract (l           => check7, r => check7t,
                        round_style => round_zero,
                        guard       => 1,
                        check_error => false,
                        denormalize => false);
    check7y := "1101111";               -- -7.5 (truncate)
    report_error ("-6.5 - 1.25 round_zero", check7, check7y);
    -- Real number
    if not quiet or fphdlsynth_or_real = true then
      assert fphdlsynth_or_real
        report "Real package will cause a round_neginf error here"
        severity note;
      checkreal := 7.75;
      check7 := to_float (arg          => checkreal, size_res => check7,
                           round_style => round_inf,
                           denormalize => false);
      check7t := "0110000";             -- 8.0 (rounded up)
      report_error ("to_float (" & REAL'image(checkreal) & ") round_inf",
                    check7, check7t);
    end if;
    checkreal := 7.75;
    check7 := to_float (arg          => checkreal, size_res => check7,
                         round_style => round_neginf,
                         denormalize => false);
    check7t := "0101111";               -- 7.5 (round down)
    report_error ("to_float (" & REAL'image(checkreal) & ") round_neginf",
                  check7, check7t);
    checkreal := 7.75;
    check7 := to_float (arg          => checkreal, size_res => check7,
                         round_style => round_zero,
                         denormalize => false);
    check7t := "0101111";               -- 7.5 (truncate)
    report_error ("to_float (" & REAL'image(checkreal) & ") round_zero",
                  check7, check7t);
    checkreal := -7.75;
    check7 := to_float (arg          => checkreal, size_res => check7,
                         round_style => round_inf,
                         denormalize => false);
    check7t := "1101111";               -- -7.5 (truncate)
    report_error ("to_float (" & REAL'image(checkreal) & ") round_inf",
                  check7, check7t);
    checkreal := -7.75;
    check7 := to_float (arg          => checkreal, size_res => check7,
                         round_style => round_neginf,
                         denormalize => false);
    if not quiet or fphdlsynth_or_real = true then
      assert fphdlsynth_or_real
        report "Real package will cause a round_neginf error here"
        severity note;
      check7t := "1110000";             -- -8.0 (rounded up)
      report_error ("to_float (" & REAL'image(checkreal) & ") round_neginf",
                    check7, check7t);
    end if;
    checkreal := -7.75;
    check7 := to_float (arg          => checkreal, size_res => check7,
                         round_style => round_zero,
                         denormalize => false);
    check7t := "1101111";               -- 7.5 (truncate)
    report_error ("to_float (" & REAL'image(checkreal) & ") round_zero",
                  check7, check7t);
    -- unsigned fixed point
    checkuf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => checkuf, size_res => check7,
                         round_style => round_inf,
                         denormalize => false);
    check7t := "0110000";               -- 8.0 (rounded up)
    report_error ("to_float (" & to_string(checkuf) & ") round_inf",
                  check7, check7t);
    checkuf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => checkuf, size_res => check7,
                         round_style => round_neginf,
                         denormalize => false);
    check7t := "0101111";               -- 7.5 (round down)
    report_error ("to_float (" & to_string(checkuf) & ") round_neginf",
                  check7, check7t);
    checkuf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => checkuf, size_res => check7,
                         round_style => round_zero,
                         denormalize => false);
    check7t := "0101111";               -- 7.5 (truncate)
    report_error ("to_float (" & to_string(checkuf) & ") round_zero",
                  check7, check7t);

    -- signed fixed point
    checksf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => checksf, size_res => check7,
                         round_style => round_inf,
                         denormalize => false);
    check7t := "0110000";               -- 8.0 (rounded up)
    report_error ("to_float (" & to_string(checksf) & ") round_inf",
                  check7, check7t);
    checksf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => checksf, size_res => check7,
                         round_style => round_neginf,
                         denormalize => false);
    check7t := "0101111";               -- 7.5 (round down)
    report_error ("to_float (" & to_string(checksf) & ") round_neginf",
                  check7, check7t);
    checksf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => checksf, size_res => check7,
                         round_style => round_zero,
                         denormalize => false);
    check7t := "0101111";               -- 7.5 (truncate)
    report_error ("to_float (" & to_string(checksf) & ") round_zero",
                  check7, check7t);

    checksf := "1000010";               -- - 7.75 in fixed point
    check7 := to_float (arg          => checksf, size_res => check7,
                         round_style => round_inf,
                         denormalize => false);
    check7t := "1101111";               -- FP -7.5 (round down)
    report_error ("to_float (" & to_string(checksf) & ") round_inf",
                  check7, check7t);
    checksf := "1000010";               -- - 7.75 in fixed point
    check7 := to_float (arg          => checksf, size_res => check7,
                         round_style => round_neginf,
                         denormalize => false);
    check7t := "1110000";               -- -8.0 (rounded up)
    report_error ("to_float (" & to_string(checksf) & ") round_neginf",
                  check7, check7t);
    checksf := "0111110";               -- 7.75 in fixed point
    check7 := to_float (arg          => -checksf, size_res => check7,
                         round_style => round_zero,
                         denormalize => false);
    check7t := "1101111";               -- - 7.5 (truncate)
    report_error ("to_float (" & to_string(checksf) & ") round_zero",
                  check7, check7t);
    assert (quiet) report "Rounding test completed" severity note;
    roundtest_done <= true;
    wait;
  end process roundtest;

  -- purpose: mixed width test.  This test also checks bad floating point
  -- ranges and NULL arrays.
  mixedtest : process is
    variable t32, ck32 : float32;
    variable t7, ck7   : float (3 downto -3);
    variable ckbad     : float (3 downto 0);        -- error condition.
    variable ckbad1    : float (3 downto 1);        -- error condition.
    variable ckbad2    : float (-1 downto -5);      -- error condition.
    variable ckbad3    : float (-3 to 3);           -- TO range.
    variable cknull    : float (0 downto 1);        -- null array
    variable checkint  : INTEGER;
    variable checkreal : REAL;
    variable checks    : SIGNED (3 downto 0);
    variable checkuns  : UNSIGNED (3 downto 0);
    variable checkuf   : ufixed (3 downto -3);
    variable checksf   : sfixed (3 downto -3);
  begin
    wait until start_mixedtest;
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t32 + t7;
    t32             := to_float (4.5, t32);
    report_error ("32 BIT 6.5 + 7 BIT -2", ck32, t32);
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t7 + t32;
    t32             := to_float (4.5, t32);
    report_error ("7 BIT -2 + 32 BIT 6.5", ck32, t32);
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t32 - t7;
    t32             := to_float (8.5, t32);
    report_error ("32 BIT 6.5 - 7 BIT -2", ck32, t32);
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t7 - t32;
    t32             := to_float (-8.5, t32);
    report_error ("7 BIT -2 - 32 BIT 6.5", ck32, t32);
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t32 * t7;
    t32             := to_float (-13, t32);
    report_error ("32 BIT 6.5 * 7 BIT -2", ck32, t32);
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t7 * t32;
    t32             := to_float (-13, t32);
    report_error ("7 BIT -2 * 32 BIT 6.5", ck32, t32);
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    ck32            := t32 / t7;
    t32             := to_float (-3.25, t32);
    report_error ("32 BIT 6.5 / 7 BIT -2", ck32, t32);
    t32             := "01000000000000000000000000000000";  -- 2.0
    t7              := "1100000";       -- -2
    ck32            := t7 / t32;
    t32             := to_float (-1, t32);
    report_error ("7 BIT -2 / 32 BIT 2.0", ck32, t32);
    t32             := "11000000000000000000000000000000";  -- 2.0
    t7              := "1100000";       -- -2
    ck32            := dividebyp2 (t32, t7);
    t32             := to_float (1, t32);
    report_error ("32 bit -2 /2 7 bit -2", ck32, t32);
    t32             := "11000000000000000000000000000000";  -- 2.0
    t7              := "1100000";       -- -2
    ck32            := dividebyp2 (t7, t32);
    t32             := to_float (1, t32);
    report_error ("7 bit -2 /2 32 bit -2", ck32, t32);
    t32             := to_float (1, t32);
    t7              := "0100000";       -- -2
    t32             := "01000000110100000000000000000000";  -- 6.5
    ck32            := t32 mod t7;
    t32             := to_float (0.5, t32);
    report_error ("32 bit 6.5 mod 7 bit 2", ck32, t32);
    t32             := "01000000000000000000000000000000";  -- 2
    t7              := "0101101";       -- 6.5
    ck32            := t7 mod t32;
    t32             := to_float (0.5, t32);
    report_error ("7 bit 6.5 mod 32 bit 2", ck32, t32);
    t7              := "0100000";       -- -2
    t32             := "01000000110100000000000000000000";  -- 6.5
    ck32            := t32 rem t7;
    t32             := to_float (0.5, t32);
    report_error ("32 bit 6.5 rem 7 bit 2", ck32, t32);
    t32             := "01000000000000000000000000000000";  -- 2
    t7              := "0101101";       -- 6.5
    ck32            := t7 rem t32;
    t32             := to_float (0.5, t32);
    report_error ("7 bit 6.5 rem 32 bit 2", ck32, t32);
    t32             := "11000000000000000000000000000000";  -- 2.0
    t7              := "1100000";       -- -2
    assert (t32 = t7) report "32 bit -2 = 7 bit -2" severity error;
    assert not (t32 /= t7) report "32 bit -2 /= 7 bit -2" severity error;
    assert (t7 = t32) report "7 bit -2 = 32 bit -2" severity error;
    assert not (t7 /= t32) report "7 bit -2 /= 32 bit -2" severity error;
    t32             := "01000000110100000000000000000000";  -- 6.5
    assert not (t32 = t7) report "32 bit 6.5 = 7 bit -2" severity error;
    assert (t32 /= t7) report "32 bit 6.5 /= 7 bit -2" severity error;
    assert not (t32 = t7) report "32 bit 6.5 = 7 bit -2" severity error;
    assert (t32 /= t7) report "32 bit 6.5 /= 7 bit -2" severity error;
    t32             := "01000000110100000000000000000000";  -- 6.5
    t7              := "1100000";       -- -2
    assert (t7 < t32) report "7 bit -2 < 32 bit 6.5" severity error;
    assert (t7      <= t32) report "7 bit -2 <= 32 bit 6.5" severity error;
    assert not (t7 > t32) report "7 bit -2 > 32 bit 6.5" severity error;
    assert not (t7 >= t32) report "7 bit -2 >= 32 bit 6.5" severity error;
    assert not (t32 < t7) report "32 bit 6.5 < 7 bit -2" severity error;
    assert not (t32 <= t7) report "32 bit 6.5 <= 7 bit -2" severity error;
    assert (t32 > t7) report "32 bit 6.5 > 7 bit -2" severity error;
    assert (t32 >= t7) report "32 bit 6.5 >= 7 bit -2" severity error;
    t32             := "11000000000000000000000000000000";  -- 2.0
    t7              := "1100000";       -- -2
    assert not (t7 < t32) report "7 bit -2 < 32 bit -2" severity error;
    assert (t7      <= t32) report "7 bit -2 <= 32 bit -2" severity error;
    assert not (t7 > t32) report "7 bit -2 > 32 bit -2" severity error;
    assert (t7 >= t32) report "7 bit -2 >= 32 bit -2" severity error;
    -- Check some literals
    if (not quiet) then
      t7                     := "1100000";          -- -2
      report "12 literal errors from math operations" severity note;
      ckbad                  := t7 + "00000000";    -- literal, causes an error
      ckbad                  := "00000000" + t7;
      ckbad                  := t7 - "00000000";    -- literal, causes an error
      ckbad                  := "00000000" - t7;
      ckbad                  := t7 * "00000000";    -- literal, causes an error
      ckbad                  := "00000000" * t7;
      ckbad                  := t7 / "00000000";    -- literal, causes an error
      ckbad                  := "0000000" / t7;
      ckbad                  := t7 rem "00000000";  -- literal, causes an error
      ckbad                  := "0000000" rem t7;
      ckbad                  := t7 mod "00000000";  -- literal, causes an error
      ckbad                  := "0000000" mod t7;
      report "6 literal errors from compare operations" severity note;
      assert not (t7 < "00000000") report "t7 < literal" severity error;
      assert not (t7 > "00000000") report "t7 > literal" severity error;
      assert not (t7         <= "00000000") report "t7 <= literal" severity error;
      assert not (t7 >= "00000000") report "t7 >= literal" severity error;
      assert not (t7 = "00000000") report "t7 = literal" severity error;
      assert (t7 /= "00000000") report "t7 /= literal" severity error;
      report "6 literal errors from compare operations" severity note;
      assert not ("00000000" < t7) report "literal < t7" severity error;
      assert not ("00000000" > t7) report "literal > t7" severity error;
      assert not ("00000000" <= t7) report "literal <= t7" severity error;
      assert not ("00000000" >= t7) report "literal >= t7" severity error;
      assert not ("00000000" = t7) report "literal = t7" severity error;
      assert ("00000000" /= t7) report "literal /= t7" severity error;
    end if;
    -- Null test, these will all return an "X".
    ck7    := t7 + cknull;
    ck7    := cknull + t7;
    ck7    := t7 - cknull;
    ck7    := cknull - t7;
    ck7    := t7 * cknull;
    ck7    := cknull * t7;
    ck7    := t7 / cknull;
    ck7    := cknull / t7;
    ck7    := t7 mod cknull;
    ck7    := cknull mod t7;
    ck7    := t7 rem cknull;
    ck7    := cknull rem t7;
    cknull := abs (cknull);
    cknull := - cknull;
    -- This one is silent
    if (not quiet) then
      checks    := to_signed (cknull, checks);
      checkreal := to_real (cknull);
      checkuns  := to_unsigned (cknull, checkuns);
      checkreal := to_real (cknull);
      checkuf   := to_ufixed (cknull, checkuf);
      checksf   := to_sfixed (cknull, checksf);
      -- bad ranges
      -- assert (quiet)
      report "6 bad range errors 3 dt 0" severity note;
      ckbad     := (others => '0');
      checkuns  := to_unsigned (ckbad, checkuns);
      checkreal := to_real (ckbad);
      checkuf   := to_ufixed (ckbad, checkuf);
      checksf   := to_sfixed (ckbad, checksf);
      checkint  := to_integer (ckbad);
      checks    := to_signed (ckbad, checks);
      -- assert (quiet)
      report "6 bad range errors 3 dt 1" severity note;
      ckbad1    := (others => '0');
      checkuns  := to_unsigned (ckbad1, checkuns);
      checkreal := to_real (ckbad1);
      checkuf   := to_ufixed (ckbad1, checkuf);
      checksf   := to_sfixed (ckbad1, checksf);
      checkint  := to_integer (ckbad1);
      checks    := to_signed (ckbad1, checks);
      -- assert (quiet)
      report "6 bad range errors -1 dt -5" severity note;
      ckbad2    := (others => '0');
      checkuns  := to_unsigned (ckbad2, checkuns);
      checkuf   := to_ufixed (ckbad2, checkuf);
      checksf   := to_sfixed (ckbad2, checksf);
      checks    := to_signed (ckbad2, checks);
      checkint  := to_integer (ckbad2);
      checkreal := to_real (ckbad2);
      -- assert (quiet)
      report "6 bad range errors -3 to 3" severity note;
      ckbad3    := "0011010";           -- 6 reverse ranged
      checkuns  := to_unsigned (ckbad3, checkuns);
      checks    := to_signed (ckbad3, checks);
      checkuf   := to_ufixed (ckbad3, checkuf);
      checksf   := to_sfixed (ckbad3, checksf);
      checkreal := to_real (ckbad3);
      assert (checkreal = 0.0)
        report "Bad range to_real returned " & REAL'image(checkreal)
        severity error;
      checkint := to_integer (ckbad3);
      assert (checkint = 0)
        report "Bad range to_real returned " & INTEGER'image(checkint)
        severity error;
    end if;

    ck7 := - ckbad3;
    ck7 := abs(ckbad3);

    assert (quiet) report "Mixed width test done" severity note;
    mixedtest_done <= true;
    wait;
  end process mixedtest;
  ----------------------------------------------------------------------------
  -- Copied from the "test_minmax.vhd".
  ----------------------------------------------------------------------------
  verify : process is
    subtype bv4 is STD_LOGIC_VECTOR(8 downto 0);
    variable a_bv  : bv4;
    variable a_suv : float(4 downto -4);
    variable b_su  : STD_ULOGIC;
    variable b_bv  : bv4;
  begin
    wait until start_booltest;
    for a_val in 0 to 15 loop
      a_bv  := to_slv(to_float(a_val, a_suv));
      a_suv := to_float(a_bv, a_suv);
      for b in STD_ULOGIC loop
        b_su := b;
        b_bv := bv4'(others => b);

        assert to_slv(a_suv and b_su) = STD_LOGIC_VECTOR'(a_bv and b_bv)
          report "error in a_suv and b_su";
        assert to_slv(b_su and a_suv) = STD_LOGIC_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_suv";
        assert to_slv(a_suv nand b_su) = STD_LOGIC_VECTOR'(a_bv nand b_bv)
          report "error in a_suv nand b_su";
        assert to_slv(b_su nand a_suv) = STD_LOGIC_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_suv";
        assert to_slv(a_suv or b_su) = STD_LOGIC_VECTOR'(a_bv or b_bv)
          report "error in a_suv or b_su";
        assert to_slv(b_su or a_suv) = STD_LOGIC_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_suv";
        assert to_slv(a_suv nor b_su) = STD_LOGIC_VECTOR'(a_bv nor b_bv)
          report "error in a_suv nor b_su";
        assert to_slv(b_su nor a_suv) = STD_LOGIC_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_suv";
        assert to_slv(a_suv xor b_su) = STD_LOGIC_VECTOR'(a_bv xor b_bv)
          report "error in a_suv xor b_su";
        assert to_slv(b_su xor a_suv) = STD_LOGIC_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_suv";
        assert to_slv(a_suv xnor b_su) = STD_LOGIC_VECTOR'(a_bv xnor b_bv)
          report "error in a_suv xnor b_su";
        assert to_slv(b_su xnor a_suv) = STD_LOGIC_VECTOR'(b_bv xnor a_bv)
          report "error in b_su xnor a_suv";
        wait for 1 ns;
      end loop;
    end loop;
    assert (quiet) report "boolean test completed" severity note;
    booltest_done <= true;
    wait;
  end process verify;

  -- purpose: test logical functions
  logictest : process is
    variable uf, uf1, uf2, uf3 : float (2 downto -2);
    -- Yes, this range is illegal, thus we have to use a "std_logic_vector"
    -- compate, and not the "=".
  begin
    wait until start_logictest;
    -- not
    uf1 := "11100";
    uf  := not uf1;
    uf3 := "00011";
    report_error ("not " & to_string (uf1), to_slv(uf), to_slv(uf3));
    uf1 := "HLXUZ";
    uf  := not uf1;
    uf3 := "01XUX";
    report_error ("not " & to_string (uf1), to_slv(uf), to_slv(uf3));
    -- or
    uf1 := "00000";
    uf2 := "00000";
    uf  := uf1 or uf2;
    uf3 := "00000";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "00001";
    uf2 := "10000";
    uf  := uf1 or uf2;
    uf3 := "10001";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "10011";
    uf2 := "10010";
    uf  := uf1 or uf2;
    uf3 := "10011";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "HHLLH";
    uf2 := "HLLLL";
    uf  := uf1 or uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "1100X";
    uf2 := "10001";
    uf  := uf1 or uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
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
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "00001";
    uf2 := "10000";
    uf  := uf1 nor uf2;
    uf3 := "10001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "10011";
    uf2 := "10010";
    uf  := uf1 nor uf2;
    uf3 := "10011";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "HHLLH";
    uf2 := "HLLLL";
    uf  := uf1 nor uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "11001";
    uf2 := "1000W";
    uf  := uf1 nor uf2;
    uf3 := "11001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
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
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "11010";
    uf2 := "10110";
    uf  := uf1 and uf2;
    uf3 := "10010";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "LLLHH";
    uf2 := "HLLHH";
    uf  := uf1 and uf2;
    uf3 := "00011";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "1100Z";
    uf2 := "10000";
    uf  := uf1 and uf2;
    uf3 := "10000";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
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
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "11010";
    uf2 := "10110";
    uf  := uf1 nand uf2;
    uf3 := "10010";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "LLLHH";
    uf2 := "HLLHH";
    uf  := uf1 nand uf2;
    uf3 := "00011";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "11000";
    uf2 := "1000U";
    uf  := uf1 nand uf2;
    uf3 := "10000";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "WXZUL";
    uf2 := "HLUZW";
    uf  := uf1 nand uf2;
    uf3 := "X0UU0";
    report_error (to_string (uf1) & " nand " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));
    -- xor
    uf1 := "00010";
    uf2 := "01000";
    uf  := uf1 xor uf2;
    uf3 := "01010";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "01111";
    uf2 := "00000";
    uf  := uf1 xor uf2;
    uf3 := "01111";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "100H0";
    uf2 := "111H1";
    uf  := uf1 xor uf2;
    uf3 := "01101";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "WXZU0";
    uf2 := "HLUZ0";
    uf  := uf1 xor uf2;
    uf3 := "XXUU0";
    report_error (to_string (uf1) & " xor " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- xnor
    uf1 := "00010";
    uf2 := "01000";
    uf  := uf1 xnor uf2;
    uf3 := "01010";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xnor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "00011";
    uf2 := "01011";
    uf  := uf1 xnor uf2;
    uf3 := "01000";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "01111";
    uf2 := "00000";
    uf  := uf1 xnor uf2;
    uf3 := "01111";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "100H0";
    uf2 := "111H1";
    uf  := uf1 xnor uf2;
    uf3 := "01101";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "WXZU0";
    uf2 := "HL-Z0";
    uf  := uf1 xnor uf2;
    uf3 := "XXXU0";
    report_error (to_string (uf1) & " xnor " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));
    assert (quiet) report "logical function test done" severity note;
    logictest_done <= true;
    wait;
  end process logictest;

  -- purpose: main level test process
  -- Lifted from the "test_reduce_pack.vhd" tests
  test_reduce : process is
    procedure report_error (
      constant message : in STRING;        -- message string
      actual           : in float;         -- result from code
      expected         : in STD_LOGIC) is  -- compared against
    begin  -- report_error
      assert (false)
        report message & " (" & to_string(actual) & ") /= "
        & STD_LOGIC'image(expected)
        severity error;
    end report_error;
  variable slv16 : float (10 downto -5);   -- 16 bit unsigned
  variable uns16 : float (10 downto -5);   -- 16 bit unsigned
  variable s     : STD_ULOGIC;             -- one bit
  -- Odd lenghths to test recursive algorithem
  variable slv13 : float (9 downto -3);    -- 13 bit slv
  variable nullarray : float (0 downto 12);  -- null array

  begin  -- process tester
    wait until start_reduce_test;
    ---------------------------------------------------------------------------
    -- Start with an "or" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (or (slv16) /= '0') then
      report_error ("or reduce", slv16, '0');
    end if;
    slv16 := "0000000000000001";
    if (or (slv16) /= '1') then
      report_error ("or reduce", slv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (or (uns16) /= '1') then
      report_error ("or reduce", uns16, '1');
    end if;
    uns16 := "1000000000000001";
    if (or (uns16) /= '1') then
      report_error ("or reduce", uns16, '1');
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
    if (or (nullarray) /= '0') then       -- Null array test
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
    slv16 := "0000000000000001";
    if (and (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (and (uns16) /= '1') then
      report_error ("and reduce", uns16, '1');
    end if;
    uns16 := "1000000000000001";
    if (and (uns16) /= '0') then
      report_error ("and reduce", uns16, '0');
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
    if (and (nullarray) /= '1') then      -- Null array test
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
    slv16 := "0000000000000001";
    if (xor (slv16) /= '1') then
      report_error ("xor reduce", slv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (xor (uns16) /= '0') then
      report_error ("xor reduce", uns16, '0');
    end if;
    uns16 := "1000000000000001";
    if (xor (uns16) /= '0') then
      report_error ("xor reduce", uns16, '0');
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
    if (xor (nullarray) /= '0') then      -- Null array test
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
    slv16 := "0000000000000001";
    if (nor (slv16) /= '0') then
      report_error ("nor reduce", slv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (nor (uns16) /= '0') then
      report_error ("nor reduce", uns16, '0');
    end if;
    uns16 := "1000000000000001";
    if (nor (uns16) /= '0') then
      report_error ("nor reduce", uns16, '0');
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
    if (nor (nullarray) /= '1') then      -- Null array test
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
    slv16 := "0000000000000001";
    if (nand (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (nand (uns16) /= '0') then
      report_error ("nand reduce", uns16, '0');
    end if;
    uns16 := "1000000000000001";
    if (nand (uns16) /= '1') then
      report_error ("nand reduce", uns16, '1');
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
    if (nand (nullarray) /= '0') then     -- Null array test
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
    slv16 := "0000000000000001";
    if (xnor (slv16) /= '0') then
      report_error ("xnor reduce", slv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (xnor (uns16) /= '1') then
      report_error ("xnor reduce", uns16, '1');
    end if;
    uns16 := "1000000000000001";
    if (xnor (uns16) /= '1') then
      report_error ("xnor reduce", uns16, '1');
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
    if (xnor (nullarray) /= '1') then     -- Null array test
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
      report "Floating point reduction testing complete" severity note;
    reduce_test_done <= true;
    wait;
  end process test_reduce;

  -- purpose: from_string test
  -- type   : sequential
  -- inputs : clock, reset
  -- outputs: 
  fromstr : process is
    variable L           : LINE;                 -- LINE
    variable ck7, ck7t   : float (3 downto -3);
    variable ckx7, ckx7t : float (6 downto -5);  -- an odd range
    variable ckh7, ckh7t : float (11 downto -4);
    variable cko7, cko7t : float (11 downto -6);
  begin
    wait until start_fromstrtest;
    L    := new STRING'("1001101");
    ck7  := from_string (L.all, ck7'high, -ck7'low);
    ck7t := "1001101";
    report_error ("from_string(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L    := new STRING'("1:010:011");
    ck7  := from_string (L.all, ck7'high, -ck7'low);
    ck7t := "1010011";
    report_error ("from_string(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L    := new STRING'("1001101");
    ck7  := from_bstring (L.all, ck7'high, -ck7'low);
    ck7t := "1001101";
    report_error ("from_bstring(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L    := new STRING'("1010.011");
    ck7  := from_bstring (L.all, ck7'high, -ck7'low);
    ck7t := "1010011";
    report_error ("from_bstring(" & L.all &", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    -- size_res versions of functions
    L    := new STRING'("1001001");
    ck7  := from_string (L.all, ck7);
    ck7t := "1001001";
    report_error ("from_string(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L    := new STRING'("1:010:011");
    ck7  := from_string (L.all, ck7);
    ck7t := "1010011";
    report_error ("from_string(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L    := new STRING'("1001101");
    ck7  := from_bstring (L.all, ck7);
    ck7t := "1001101";
    report_error ("from_bstring(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);
    L    := new STRING'("1011.011");
    ck7  := from_bstring (L.all, ck7);
    ck7t := "1011011";
    report_error ("from_bstring(" & L.all &", size_res)", ck7, ck7t);
    deallocate (L);

    -- Try it in HEX.
    L     := new STRING'("8FF.1");
    ckh7  := from_hstring (L.all, ckh7'high, -ckh7'low);
    ckh7t := from_string ("1:00011111111:0001", ckh7t);
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ckh7, ckh7t);
    deallocate (L);
    L     := new STRING'("AF09");
    ckh7  := from_hstring (L.all, ckh7'high, -ckh7'low);
    ckh7t := from_string ("1:01011110000:1001", ckh7t);
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ckh7, ckh7t);
    deallocate (L);
    L     := new STRING'("8FF.1");
    ckh7  := from_hstring (L.all, ckh7);
    ckh7t := from_string ("1:00011111111:0001", ckh7t);
    report_error ("from_hstring(" & L.all & ", size_res)", ckh7, ckh7t);
    deallocate (L);
    L     := new STRING'("AF09");
    ckh7  := from_hstring (L.all, ckh7);
    ckh7t := from_string ("1:01011110000:1001", ckh7t);
    report_error ("from_hstring(" & L.all & ", size_res)", ckh7, ckh7t);
    deallocate (L);
    L     := new STRING'("8FF.1");
    ckh7  := from_hstring (L.all, ckh7);
    ckh7t := from_string ("1:00011111111:0001", ckh7t);
    report_error ("from_hstring(" & L.all & ")", ckh7, ckh7t);
    deallocate (L);
    -- Try some odd ranges
    L     := new STRING'("41");
    ck7   := from_hstring (L.all, ck7'high, -ck7'low);
    ck7t  := from_string ("1000.001", ck7t);
    report_error ("from_hstring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("55");
    ck7   := from_hstring (L.all, ck7);
    ck7t  := from_string ("1010.101", ck7t);
    report_error ("from_hstring(" & L.all & ", size_res)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("e7D");
    ckx7  := from_hstring (L.all, ckx7);
    ckx7t := from_string ("1110011.11101", ckx7t);
    report_error ("from_hstring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    L     := new STRING'("7B9");
    ckx7  := from_hstring (L.all, ckx7);
    ckx7t := from_string ("0111101.11001", ckx7t);  -- rounded
    report_error ("from_hstring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    L     := new STRING'("E7D");                    -- no dot
    ckx7  := from_hstring (L.all, ckx7);
    ckx7t := from_string ("1110011.11101", ckx7t);
    report_error ("from_hstring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    -- Cause some errors
    if (not quiet) then
      report "Expect 2 from_hstring(float) errors" severity note;
      L    := new STRING'("FF.FF");                 -- overflow
      ckx7 := from_hstring (L.all, ckx7);
      L    := new STRING'("00");                    -- underflow
      ckx7 := from_hstring (L.all, ckx7);
    end if;

    -- Octal
    L     := new STRING'("4070.45");
    cko7  := from_ostring (L.all, cko7'high, -cko7'low);
    cko7t := from_string ("1:00000111000:100101", cko7t);
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", cko7, cko7t);
    deallocate (L);
    L     := new STRING'("707057");
    cko7  := from_ostring (L.all, cko7'high, -cko7'low);
    cko7t := from_string ("111000111000.101111", cko7t);
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", cko7, cko7t);
    deallocate (L);
    L     := new STRING'("4070.45");
    cko7  := from_ostring (L.all, cko7);
    cko7t := from_string ("100000111000.100101", cko7t);
    report_error ("from_ostring(" & L.all & ", size_res)", cko7, cko7t);
    deallocate (L);
    L     := new STRING'("707057");
    cko7  := from_ostring (L.all, cko7);
    cko7t := from_string ("111000111000.101111", cko7t);
    report_error ("from_ostring(" & L.all & ", size_res)", cko7, cko7t);
    deallocate (L);
    L     := new STRING'("4070.45");
    cko7  := from_ostring (L.all, cko7);
    cko7t := from_string ("100000111000.100101", cko7t);
    report_error ("from_ostring(" & L.all & ")", cko7, cko7t);
    deallocate (L);
    -- Try some odd ranges
    L     := new STRING'("1:5:7");
    ck7   := from_ostring (L.all, ck7'high, -ck7'low);
    ck7t  := from_string ("1:101:111", ck7t);
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("147");
    ck7   := from_ostring (L.all, ck7'high, -ck7'low);
    ck7t  := from_string ("1100.111", ck7t);
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("0:5.1");
    ck7   := from_ostring (L.all, ck7'high, -ck7'low);
    ck7t  := from_string ("0101.001", ck7t);
    report_error ("from_ostring(" & L.all & ", 'high, 'low)", ck7, ck7t);
    deallocate (L);
    L     := new STRING'("6675");
    ckx7  := from_ostring (L.all, ckx7);
    ckx7t := from_string ("1:101101:11101", ckx7t);
    report_error ("from_ostring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    L     := new STRING'("3200");
    ckx7  := from_ostring (L.all, ckx7);
    ckx7t := from_string ("0110100.00000", ckx7t);  -- rounded
    report_error ("from_ostring(" & L.all & ", size_res)", ckx7, ckx7t);
    deallocate (L);
    -- Cause some errors
    if (not quiet) then
      report "Expect 2 from_ostring(float) errors" severity note;
      L    := new STRING'("200.00");                -- overflow
      ckx7 := from_ostring (L.all, ckx7);
      L    := new STRING'("00");                    -- underflow
      ckx7 := from_ostring (L.all, ckx7);
    end if;
    assert (quiet) report "from_string(float) testing completed" severity note;
    fromstrtest_done <= true;
    wait;
  end process fromstr;

  -- purpose: denormal / non denormal number divide test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  dentest : process is
    variable a, b, c, d : float32;
  begin
    wait until start_dentest;
    a := "00000000010000000000000000000000";  -- 2**-127 denormal
    b := to_float (4, b);
    c := divide (l           => a,
                 r           => b,
                 denormalize => true);
    d := "00000000000100000000000000000000";  -- 2**-129 denormal
    report_error ("denormal / 4", c, d);
    a := "00000000010000000000000000000000";  -- 2**-127 denormal
    b := to_float (4, b);
    c := divide (l           => a,
                 r           => b,
                 denormalize => false);
    d := (others => '0');
    report_error ("non denormal / 4", c, d);
    a := "00000000100000000000000000000000";  -- 2**-126 non-denormal
    b := to_float (2, b'high, -b'low);
    c := divide (l           => a,
                 r           => b,
                 denormalize => false);
    d := (others => '0');
    report_error ("2**-126 / 2", c, d);
    a := to_float (0.25, a);
    b := "00000000010000000000000000000000";  -- 2**-127 denormal
    c := divide (l           => a,
                 r           => b,
                 denormalize => true);
    d := to_float (2.0**125, d);
    report_error ("0.25/denormal 2**-127", c, d);
    a := to_float (0.5, a);
    b := "00000000100000000000000000000000";  -- 2**-126 normal
    c := divide (l           => a,
                 r           => b,
                 denormalize => true);
    d := to_float (2.0**125, d);
    report_error ("0.5/normal 2**-126", c, d);
    a := to_float (0.25, a);
    b := "00000000010000000000000000000000";  -- 2**-127 denormal
    c := divide (l           => a,
                 r           => b,
                 denormalize => false);
    d := "01111101101010101010101010101011";  -- 2**-2 * 1/"1.1" * 2**127
    report_error ("0.25/non normal 2**-127", c, d);
    -- nextafter
    a := "00000000010000000000000000000000";  -- 2**-127 denormal
    b := to_float (2, b);
    c := nextafter (x           => a, y => b,
                    check_error => false,
                    denormalize => false);
    d := "00000000010000000000000000000001";
    report_error ("Nextafter(denormal, 2, false, false)", c, d);
    a := (others => '0');
    b := to_float (2, b);
    c := nextafter (x           => a, y => b,
                    check_error => false,
                    denormalize => false);
    d            := "00000000000000000000000000000001";
    report_error ("Nextafter(zero, 2, false, false)", c, d);
    assert (quiet) report "Denormal divide testing completed" severity note;
    dentest_done <= true;
    wait;
  end process dentest;

  -- purpose: test of the multiply accumulate
  mactest : process is
    variable a, b, c    : float32;
    variable x, y, z    : float32;
    variable r1, r2, r3 : REAL;
    variable i1, i2, i3 : INTEGER;
  begin
    wait until start_mactest;
    a            := to_float (1);
    b            := a;
    c            := a;
    x            := mac (a, b, c);
    y            := to_float (2);
    report_error ("1*1+1", x, y);
    a            := to_float (1);
    b            := a;
    c            := to_float (0);
    x            := mac (a, b, c);
    y            := to_float (1);
    report_error ("1*1+0", x, y);
    a            := to_float (1);
    b            := to_float (0);
    c            := to_float (1);
    x            := mac (a, b, c);
    y            := to_float (1);
    report_error ("1*0+1", x, y);
    a            := to_float (2);
    b            := to_float (3);
    c            := to_float (4);
    x            := mac (a, b, c);
    y            := to_float (10);
    report_error ("2*3+4", x, y);
    a            := to_float (0);
    b            := to_float (3);
    c            := to_float (4);
    x            := mac (a, b, c);
    y            := to_float (4);
    report_error ("0*3+4", x, y);
    a            := to_float (2);
    b            := to_float (3);
    c            := to_float (0);
    x            := mac (a, b, c);
    y            := to_float (6);
    report_error ("2*3+0", x, y);
    a            := to_float (2);
    b            := to_float (3);
    c            := to_float (100);
    x            := mac (a, b, c);
    y            := to_float (106);
    report_error ("2*3+100", x, y);
    a            := to_float (2);
    b            := to_float (30);
    c            := to_float (4);
    x            := mac (a, b, c);
    y            := to_float (64);
    report_error ("2*30+4", x, y);
    a            := to_float (2);
    b            := to_float (1.0/3.0);
    c            := to_float (1.0/6.0);
    x            := mac (a, b, c);
    y            := "00111111010101010101010101010110";  -- rounding
    report_error ("2*1/3+1/6", x, y);
    a            := to_float (0.5);
    b            := to_float (1.0/3.0);
    c            := to_float (2.0/3.0);
    x            := mac (a, b, c);
    y            := "00111111010101010101010101010110";  -- rounding
    report_error ("(1/2*1/3)+2/3", x, y);
    a            := to_float (1);
    b            := to_float (1.0/3.0);
    c            := to_float (8);
    x            := mac (a, b, c);
    y            := to_float (8.0+(1.0/3.0));
    report_error ("(1*1/3)+8", x, y);
    a            := to_float (4);
    b            := to_float (2);
    c            := to_float (1.0/3.0);
    x            := mac (a, b, c);
    y            := to_float (8.0+(1.0/3.0));
    report_error ("4*2+1/3", x, y);
    a            := to_float (1);
    b            := to_float (1.0/3.0);
    c            := b;
    x            := mac (a, b, c);
    y            := to_float (2.0/3.0);
    report_error ("1*1/3+1/3", x, y);
    a            := to_float (1.0/3.0);
    b            := a;
    c            := a;
    x            := mac (a, b, c);
    y            := to_float ((1.0/9.0)+(1.0/3.0));
    report_error ("1/3*1/3+1/3", x, y);
    a            := to_float (5000);
    b            := to_float (5000);
    c            := to_float (0.00005);
    x            := mac (a, b, c);
    y            := to_float (5000*5000);
    report_error ("5K*5k+.00005", x, y);
    a            := to_float (0.00005);
    b            := to_float (0.00005);
    c            := to_float (50000);
    x            := mac (a, b, c);
    y            := c;
    report_error (".00005**2+50k", x, y);
    a            := to_float (1);
    b            := -a;
    c            := to_float (0);
    x            := mac (a, b, c);
    y            := to_float (-1);
    report_error ("1*-1+0", x, y);
    a            := to_float (1);
    b            := -a;
    c            := to_float (3);
    x            := mac (a, b, c);
    y            := to_float (2);
    report_error ("1*-1+3", x, y);
    a            := to_float (-1);
    b            := a;
    c            := to_float (3);
    x            := mac (a, b, c);
    y            := to_float (4);
    report_error ("-1*-1+3", x, y);
    a            := to_float (-1);
    b            := a;
    c            := to_float (-3);
    x            := mac (a, b, c);
    y            := to_float (-2);
    report_error ("-1*-1-3", x, y);
    -- overflow testcase
    a            := "00111111011111111111111111111111";
    b            := to_float (1);
    c            := "00111111011111111111111111111111";
    x            := mac (a, b, c);
    y            := to_float (to_real(a)*2.0);
    report_error ("mac overflow test", x, y);
    assert quiet report "Multiply Accumulate testing completed" severity note;
    mactest_done <= true;
  end process mactest;

  -- purpose: test the match function, once again copied from test_minmax.
  matchtest : process is
    variable aslv, bslv : float (3 downto -4);  -- slvs
    variable cslv       : float32;
    variable s, s1      : STD_ULOGIC;
    variable i          : INTEGER;
  begin
    wait until start_matchtest;
    aslv := "00000010";
    bslv := "00000010";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    aslv := "00000010";
    bslv := "00000011";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "00000010";
    bslv := "0000001H";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "00000010";
    bslv := "0000001L";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    aslv := "00000010";
    bslv := "0000001X";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "0000001X";
    bslv := "00000010";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "00000000";
    bslv := "LLLLLLLL";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    aslv := "11111111";
    bslv := "HHHHHHHH";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    aslv := "XXXXXXXX";
    bslv := "XXXXXXXX";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "UZ-WHL01";
    bslv := "XXXXXXXX";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "--------";
    bslv := "XXXXXXXX";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-0";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-1";
    assert not (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned true"
      severity error;
    aslv := "Z0U0W0X0";
    bslv := "-0-0-0-0";
    assert (std_match (aslv, bslv))
      report "std_match (" & to_string(aslv) & " , " & to_string(bslv)
      & ") returned false"
      severity error;
    -- "?="
    aslv := "00000010";
    bslv := "00000010";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000010";
    bslv := "00000011";
    s    := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000010";
    bslv := "10000010";
    s    := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000010";
    bslv := "0000001H";
    s    := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000010";
    bslv := "0000001L";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000010";
    bslv := "0000001X";
    s    := aslv ?= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "0000001X";
    bslv := "00000010";
    s    := aslv ?= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000000";
    bslv := "LLLLLLLL";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "10000000";
    bslv := "LLLLLLLL";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "00000000";
    bslv := "HLLLLLLL";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "11111111";
    bslv := "HHHHHHHH";
    s    := aslv ?= bslv;
    assert s = '0'
      report "nan test" & to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "XXXXXXXX";
    bslv := "XXXXXXXX";
    s    := aslv ?= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "UZ-WHL01";
    bslv := "XXXXXXXX";
    s    := aslv ?= bslv;
    assert s = 'U'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "--------";
    bslv := "XXXXXXXX";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-0";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-1";
    s    := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    aslv := "Z0U0W0X0";
    bslv := "-0-0-0-0";
    s    := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & STD_ULOGIC'image(s)
      severity error;
    -- ?/=
    aslv := "00000000";                         -- 0.0
    bslv := "00000000";                         -- 0.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";                         -- 0.0
    bslv := "10000000";                         -- -0.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "10000000";                         -- -0.0
    bslv := "00000000";                         -- 0.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";                         -- 0.0
    bslv := "00001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000H00L";                         -- 1.0
    bslv := "00001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000-00L";
    bslv := "00001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000-00L";
    bslv := "0000100H";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000-00L";
    bslv := "0000100X";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000-00L";
    bslv := "0U00100H";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000-00L";
    bslv := "0Z00100H";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0000-00L";
    bslv := "0100100W";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0-00H00L";
    bslv := "0X001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0-00H00L";
    bslv := "0-001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0X00H00L";
    bslv := "0X001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0U00H00L";
    bslv := "0U001000";                         -- 1.0
    s1   := aslv ?/= bslv;
    assert s1 = 'U'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0-------";
    bslv := "0Z01XUWH";
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "0-------";
    bslv := "0-------";
    s1   := aslv ?/= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    -- ?<
    aslv := "00000000";
    bslv := "00000000";
    s1   := aslv ?< bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "10000000";
    s1   := aslv ?< bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "10000000";
    bslv := "00000000";
    s1   := aslv ?< bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00000000";
    s1   := aslv ?< bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "00001000";
    s1   := aslv ?< bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00001000";
    s1   := aslv ?< bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "01001000";
    s1   := aslv ?< bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "01001000";
    bslv := "00001000";
    s1   := aslv ?< bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000H000";
    s1   := aslv ?< bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100L";
    s1   := aslv ?< bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100U";
    s1   := aslv ?< bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100X";
    s1   := aslv ?< bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100X";
    s1   := aslv ?< bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100W";
    s1   := aslv ?< bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - error from ?< here" severity note;
      aslv := "00000000";
      bslv := "0000100-";
      s1   := aslv ?< bslv;
      assert s1 = 'X'
        report to_string(aslv) & " ?< " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
        severity error;
    end if;
    -- ?<=
    aslv := "00000000";
    bslv := "00000000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "10000000";
    bslv := "00000000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "10000000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00000000";
    s1   := aslv ?<= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "00001000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00001000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "01001000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "01001000";
    bslv := "00001000";
    s1   := aslv ?<= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000H000";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100L";
    s1   := aslv ?<= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100U";
    s1   := aslv ?<= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100X";
    s1   := aslv ?<= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100X";
    s1   := aslv ?<= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100W";
    s1   := aslv ?<= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?<= error here" severity note;
      aslv := "00000000";
      bslv := "0000100-";
      s1   := aslv ?<= bslv;
      assert s1 = 'X'
        report to_string(aslv) & " ?<= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
        severity error;
    end if;
    -- ?>
    aslv := "00000000";
    bslv := "00000000";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "10000000"; -- -0.0
    bslv := "00000000";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "10000000";                 -- -0.0
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00000000";
    s1   := aslv ?> bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "00001000";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00001000";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "01001000";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "01001000";
    bslv := "00001000";
    s1   := aslv ?> bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000H000";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100L";
    s1   := aslv ?> bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100U";
    s1   := aslv ?> bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100X";
    s1   := aslv ?> bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100X";
    s1   := aslv ?> bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "0000100W";
    s1   := aslv ?> bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?> error here" severity note;
      aslv := "00000000";
      bslv := "0000100-";
      s1   := aslv ?> bslv;
      assert s1 = 'X'
        report to_string(aslv) & " ?> " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
        severity error;
    end if;
    -- ?>=
    aslv := "00000000";
    bslv := "00000000";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "10000000";                 -- -0.0
    bslv := "00000000";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "10000000";                 -- -0.0
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00000000";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00000000";
    bslv := "00001000";
    s1   := aslv ?>= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "00001000";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00001000";
    bslv := "01001000";
    s1   := aslv ?>= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "01001000";
    bslv := "00001000";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "11001000";
    bslv := "00001000";
    s1   := aslv ?>= bslv;
    assert s1 = '0'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "00010000";
    bslv := "000H0000";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    bslv := "00000000";
    aslv := "0000100L";
    s1   := aslv ?>= bslv;
    assert s1 = '1'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    bslv := "00000000";
    aslv := "0000100U";
    s1   := aslv ?>= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    bslv := "00000000";
    aslv := "0000100X";
    s1   := aslv ?>= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    bslv := "00000000";
    aslv := "0000100X";
    s1   := aslv ?>= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    bslv := "00000000";
    aslv := "0000100W";
    s1   := aslv ?>= bslv;
    assert s1 = 'X'
      report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?>= error here" severity note;
      aslv := "00000000";
      bslv := "0000100-";
      s1   := aslv ?>= bslv;
      assert s1 = 'X'
        report to_string(aslv) & " ?>= " & to_string(bslv) & " = " & STD_ULOGIC'image(s1)
        severity error;
    end if;
    -- Do some test with different widths
    aslv := "01000000";
    cslv := "01000000000000000000000000000000";
    s1   := aslv ?= cslv;
    assert s1 = '1'
      report to_string(aslv) & " ?= " & to_string(cslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "LH001000";
    cslv := "01000000010000000000000000000000";
    s1   := aslv ?= cslv;
    assert s1 = '1'
      report to_string(aslv) & " ?= " & to_string(cslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "LH00H000";
    cslv := "00000000100000000000000000000000";
    s1   := aslv ?= cslv;
    assert s1 = '0'
      report to_string(aslv) & " ?= " & to_string(cslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "11001000";
    cslv := "-1000000010000000000000000000000";
    s1   := aslv ?= cslv;
    assert s1 = '1'
      report to_string(aslv) & " ?= " & to_string(cslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    aslv := "11001000";
    cslv := "110000000-0000000000000000000000";
    s1   := aslv ?= cslv;
    assert s1 = '1'
      report to_string(aslv) & " ?= " & to_string(cslv) & " = " & STD_ULOGIC'image(s1)
      severity error;
    -- is_negative
    aslv := "00000000";
    assert not is_negative(aslv)
      report "Is_Negative (" & to_string(aslv) & ") = true"
      severity error;
    aslv := "L0000000";
    assert not is_negative(aslv)
      report "Is_Negative (" & to_string(aslv) & ") = true"
      severity error;
    aslv := "10000000";
    assert is_negative(aslv)
      report "Is_Negative (" & to_string(aslv) & ") = false"
      severity error;
    aslv := "H0000000";
    assert is_negative(aslv)
      report "Is_Negative (" & to_string(aslv) & ") = false"
      severity error;
    aslv := "X0000000";
    assert not is_negative(aslv)
      report "Is_Negative (" & to_string(aslv) & ") = true"
      severity error;
    aslv := "10010000";
    assert is_negative(aslv)
      report "Is_Negative (" & to_string(aslv) & ") = false"
      severity error;
    -- to_ux01
    aslv := "UXZWLH01";
    bslv := to_ux01(aslv);
    report_error ("to_ux01(" & to_string(aslv) & ") error",
                  to_slv(bslv), "UXXX0101");
    aslv := "-UZWLH01";
    bslv := to_ux01(aslv);
    report_error ("to_ux01(" & to_string(aslv) & ") error",
                  to_slv(bslv), "XUXX0101");
    aslv := "HLHLHL10";
    bslv := to_ux01(aslv);
    report_error ("to_ux01(" & to_string(aslv) & ") error",
                  to_slv(bslv), "10101010");
    -- to_x01z
    aslv := "UXZWLH01";
    bslv := to_x01z(aslv);
    report_error ("to_x01z(" & to_string(aslv) & ") error",
                  to_slv(bslv), "XXZX0101");
    aslv := "--ZWLH01";
    bslv := to_x01z(aslv);
    report_error ("to_x01z(" & to_string(aslv) & ") error",
                  to_slv(bslv), "XXZX0101");
    aslv := "HLHLHL10";
    bslv := to_x01z(aslv);
    report_error ("to_x01z(" & to_string(aslv) & ") error",
                  to_slv(bslv), "10101010");
    -- find_leftmost
    s    := '0';
    aslv := "11100001";
    i    := find_leftmost (aslv, s);
    assert i = 0
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := '1';
    aslv := "11100001";
    i    := find_leftmost (aslv, s);
    assert i = aslv'high
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := 'X';
    aslv := "11100001";
    i    := find_leftmost (aslv, s);
    assert i = aslv'low-1
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := '1';
    aslv := "00000000";
    i    := find_leftmost (aslv, s);
    assert i = aslv'low-1
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := 'H';
    aslv := "11H00001";
    i    := find_leftmost (aslv, s);
    assert i = 3
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := '-';
    aslv := "11100-01";
    i    := find_leftmost (aslv, s);
    assert i = 3
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := 'U';
    aslv := "1110000U";
    i    := find_leftmost (aslv, s);
    assert i = aslv'low-1
      report "find_leftmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    -- find_rightmost
    s    := '0';
    aslv := "11100001";
    i    := find_rightmost (aslv, s);
    assert i = -3
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := '1';
    aslv := "11100001";
    i    := find_rightmost (aslv, s);
    assert i = aslv'low
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := 'X';
    aslv := "11100001";
    i    := find_rightmost (aslv, s);
    assert i = aslv'high+1
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := '1';
    aslv := "00000000";
    i    := find_rightmost (aslv, s);
    assert i = aslv'high+1
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := 'H';
    aslv := "11H00001";
    i    := find_rightmost (aslv, s);
    assert i = -4
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := '-';
    aslv := "11100-01";
    i    := find_rightmost (aslv, s);
    assert i = -4
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    s    := 'U';
    aslv := "1110000U";
    i    := find_rightmost (aslv, s);
    assert i = aslv'high+1
      report "find_rightmost (" & to_string(aslv) & ", " & STD_ULOGIC'image(s)
      & ") = "& INTEGER'image(i) severity error;
    assert (quiet) report "std_match test completed" severity note;
    matchtest_done <= true;
    wait;
  end process matchtest;

  -- purpose: test of the sqrt functions
  sqrttest: process is
    -- purpose: to float64
    function to_fp (
      arg : real)
      return float64 is
    begin
      return to_float (arg, float64'high, -float64'low);
    end function to_fp;
    function to_fp (
      arg : integer)
      return float64 is
    begin
      return to_float (arg, float64'high, -float64'low);
    end function to_fp;
    -- purpose: reports an error
    -- A little more forgiving, one bit off either way.
    procedure report_error63 (
      constant errmes   :    STRING;                  -- error message
      actual            : in float;                   -- data from algorithm
      constant expected :    float)  is               -- reference data
      variable L              : LINE;
      variable fract1, fract2 : float(actual'range);  -- fract
    begin  -- function report_error
      if actual /= expected then
        fract1 := nextafter (expected, pos_inffp);
        fract2 := nextafter (expected, neg_inffp);
        if (actual /= fract1) and (actual /= fract2) then
          report errmes & LF &
            "Actual   " & to_string (actual) & " ("
            & REAL'image(to_real(actual))& ") /= " & LF &
            "Expected " & to_string (expected) & " ("
            & REAL'image(to_real(expected))& ")"
            severity error;
        end if;
      end if;
      return;
    end procedure report_error63;
    variable checknum  : float64;          -- Floating point output
    variable checknum2 : float64;          -- Floating point output
    variable checknum3 : float64;          -- Floating point output
    variable checkreal  : REAL;         -- real test
    variable checkreal2 : REAL;         -- real test
  begin
    wait until start_sqrttest;
    -- sqrt
    checknum  := to_fp (2);
    checknum2 := sqrt (checknum);
    -- sqrt (2)
    checknum3 := "0011111111110110101000001001111001100110011111110011101111001101";
    checknum3 := to_fp (MATH_SQRT_2);
    report_error63 (" sqrt (2) error ",
                    checknum2,
                    checknum3);
    checkreal := 0.5;
    checknum  := to_fp (checkreal);
    checknum2 := sqrt (checknum);
    report_error63 (" sqrt (0.5) error ",
                    checknum2,
                    to_fp(sqrt(checkreal)));
    checkreal := MATH_PI;
    checknum  := to_fp (checkreal);
    checknum2 := sqrt (checknum);
    -- sqrt (pi)
    checknum3 := "0011111111111100010110111111100010010001101101001110111101101010";
    checknum3 := to_fp (MATH_SQRT_PI);
    report_error63 (" sqrt (PI) error ",
                  checknum2,
                  checknum3);
    checknum      := to_fp(25);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(5);          -- sqrt (25) = 5
    report_error ("Sqrt of 25 error", checknum2, checknum3);
    checknum      := to_fp(81);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(9);          -- sqrt (81) = 9
    report_error ("Sqrt of 81 error", checknum2, checknum3);
    checknum      := to_fp(36);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(6);          -- sqrt (36) = 6
    report_error ("Sqrt of 36 error", checknum2, checknum3);
    checknum      := to_fp(49);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(7);          -- sqrt (49) = 7
    report_error ("Sqrt of 49 error", checknum2, checknum3);
    checknum      := to_fp(0.04);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(0.2);        -- sqrt (1/25) = 1/5
    report_error ("Sqrt of 0.04 error", checknum2, checknum3);
    checknum      := to_fp(625);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(25);         -- sqrt (625) = 25
    report_error ("Sqrt of 625 error", checknum2, checknum3);
    checknum      := (others    => '0');
    checknum (-1) := '1';               -- denormal number 2**-1023
    checknum3     := to_fp(2.0**(-1023));
    report_error ("2**-1023 computation", checknum, checknum3);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(sqrt (2.0) * (2.0**(-512)));
    report_error63 ("Sqrt 2**-1023 denormal error", checknum2, checknum3);
    checknum      := (others    => '0');
    checknum (-2) := '1';               -- denormal number 2**-1024
    checknum3     := to_fp(2.0**(-1024));
    report_error ("2**-1024 computation", checknum, checknum3);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(2.0**(-512));
    report_error ("Sqrt 2**-1024 denormal error", checknum2, checknum3);
    checknum      := (others    => '0');
    checknum (-3) := '1';               -- denormal number 2**-1025
    checknum3     := to_fp(2.0**(-1025));
    report_error63 ("2**-1025 computation", checknum, checknum3);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(sqrt (2.0) * (2.0**(-513)));
    report_error63 ("Sqrt 2**-1025 denormal error", checknum2, checknum3);
    checknum      := (others    => '0');
    checknum (-4) := '1';               -- denormal number 2**-1026
    checknum3     := to_fp(2.0**(-1026));
    report_error ("2**-1026 computation", checknum, checknum3);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(2.0**(-513));
    report_error ("Sqrt 2**-1026 denormal error", checknum2, checknum3);
    checknum      := (others    => '0');
    checknum (-5) := '1';               -- denormal number 2**-1027
    checknum3     := to_fp(2.0**(-1027));
    report_error ("2**-1027 computation", checknum, checknum3);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(sqrt (2.0) * 2.0**(-514));
    report_error63 ("Sqrt 2**-1027 denormal error", checknum2, checknum3);
    checknum      := (others    => '0');
    checknum (-6) := '1';               -- denormal number 2**-1028
    checknum3     := to_fp(2.0**(-1028));
    report_error ("2**-1028 computation", checknum, checknum3);
    checknum2     := sqrt (checknum);
    checknum3     := to_fp(2.0**(-514));
    report_error ("Sqrt 2**-1028 denormal error", checknum2, checknum3);
    -- Test special cases
    checknum      := zerofp (float64'high, -float64'low);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (0)", checknum2, zerofp);
    checknum      := neg_zerofp (float64'high, -float64'low);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (-0)", checknum2, - zerofp);
    checknum      := pos_inffp (float64'high, -float64'low);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (+inf)", checknum2, pos_inffp);
    checknum      := neg_inffp (float64'high, -float64'low);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (-inf)", to_slv(checknum2), to_slv(qnanfp(float64'high, -float64'low)));
    checknum      := to_fp (-25);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (-25)", to_slv(checknum2), to_slv(qnanfp(float64'high, -float64'low)));
    -- denormal number -2**-1028
    checknum      := (float64'high => '1', -6 => '1', others => '0');
    checknum2     := sqrt (checknum);
    report_error ("sqrt (-denormal)", to_slv(checknum2), to_slv(qnanfp(float64'high, -float64'low)));
    checknum      := nanfp (float64'high, -float64'low);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (nan)", to_slv(checknum2), to_slv(qnanfp(float64'high, -float64'low)));
    checknum      := qnanfp (float64'high, -float64'low);
    checknum2     := sqrt (checknum);
    report_error ("sqrt (qnan)", to_slv(checknum2), to_slv(qnanfp(float64'high, -float64'low)));    
    assert quiet report "Sqrt test completed" severity note;
    sqrttest_done <= true;
    wait;
  end process sqrttest;

  -- purpose: Test the integer ranges to and from floating point
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  intrangetest: process is
    variable ck7, ck7t : float (3 downto -3);
    variable ck9, ck9t : float (4 downto -4);
    variable ck11, ck11t : float (5 downto -5);
    variable ck13, ck13t : float (6 downto -6);
    variable chkint, chkintt : INTEGER;
    variable chkreal, chkrealt : REAL;
  begin
    wait until start_intrange;
    chkint := 0;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := (others => '0');
    report_error ("7 bit to_float(0)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 2;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "0100000";                  -- 2.0
    report_error ("7 bit to_float(2)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -2;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "1100000";                  -- 2.0
    report_error ("7 bit to_float(-2)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 15;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "0110111";                  -- 15.0
    report_error ("7 bit to_float(15)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -15;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "1110111";                  -- 15.0
    report_error ("7 bit to_float(-15)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 16;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "0111000";                  -- infinity
    report_error ("7 bit to_float(16)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert integer'high = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -16;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "1111000";                  -- -infinity
    report_error ("7 bit to_float(-16)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert integer'low = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 16000;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "0111000";                  -- infinity
    report_error ("7 bit to_float(16000)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert integer'high = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -16000;
    ck7 := to_float (chkint, ck7'high, -ck7'low);
    ck7t := "1111000";                  -- -infinity
    report_error ("7 bit to_float(-16000)", ck7, ck7t);
    chkintt := to_integer (ck7t);
    assert integer'low = chkintt
      report "to_integer (" & to_string(ck7t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 0;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := (others => '0');
    report_error ("9 bit to_float(0)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 2;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "010000000";                  -- 2.0
    report_error ("9 bit to_float(2)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -2;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "110000000";                  -- 2.0
    report_error ("9 bit to_float(-2)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := 248;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "011101111";                  -- 248.0
    report_error ("9 bit to_float(248)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -248;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "111101111";                  -- -248.0
    report_error ("9 bit to_float(-248)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    -- Check out the rounding modes
    chkint := 240;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "011101110";                  -- 240.0
    report_error ("9 bit to_float(240)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -240;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "111101110";                  -- -240.0
    report_error ("9 bit to_float(-240)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    -- 244 should not trigger rounding
    chkint := 244;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "011101110";                  -- 240.0
    report_error ("9 bit to_float(244)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert 240 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -244;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "111101110";                  -- -240.0
    report_error ("9 bit to_float(-244)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert -240 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    -- 245 should trigger rounding
    chkint := 245;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "011101111";                  -- 240.0
    report_error ("9 bit to_float(245)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert 248 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -245;
    ck9 := to_float (chkint, ck9'high, -ck9'low);
    ck9t := "111101111";                  -- -240.0
    report_error ("9 bit to_float(-245)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert -248 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    -- round to infinity test
    chkint := 249;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- no rounding
    ck9t := "011101111";                  -- 248.0
    report_error ("9 bit to_float(249)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert 248 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -249;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- no rounding
    ck9t := "111101111";                  -- -248.0
    report_error ("9 bit to_float(-249)", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert -248 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    -- round to infinity
    chkint := 249;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_inf);  -- round up
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit to_float(249), round inf", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert integer'high = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -249;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_inf);
    ck9t := "111101111";                  -- -248.0
    report_error ("9 bit to_float(-249), round inf", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert -248 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    -- round to negative infinity
    chkint := 249;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_neginf);
    ck9t := "011101111";                  -- 248.0
    report_error ("9 bit to_float(249) round neginf", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert 248 = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;
    chkint := -249;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_neginf);
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit to_float(-249) round neginf", ck9, ck9t);
    chkintt := to_integer (ck9t);
    assert integer'low = chkintt
      report "to_integer (" & to_string(ck9t) & ") = " & INTEGER'image(chkintt)
      severity error;

    chkint := 252;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit to_float(252)", ck9, ck9t);
    chkint := -252;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit to_float(-252)", ck9, ck9t);
    chkint := 255;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit to_float(255)", ck9, ck9t);
    chkint := -255;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit to_float(-255)", ck9, ck9t);
    chkint := 256;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- rounding
    -- Trigger the infinity test
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit to_float(256)", ck9, ck9t);
    chkint := -256;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit to_float(-256)", ck9, ck9t);
    chkint := 1024;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- overflow
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit to_float(1024)", ck9, ck9t);
    chkint := -1024;
    ck9 := to_float (chkint, ck9'high, -ck9'low, round_nearest); -- overflow
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit to_float(-1024)", ck9, ck9t);
    -- 11 bit test
    chkint := 0;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := (others => '0');
    report_error ("11 bit to_float(0)", ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := 2;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "01000000000";                  -- 2.0
    report_error ("11 bit to_float(2)", ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := -2;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "11000000000";                  -- 2.0
    report_error ("11 bit to_float(-2)", ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := 32768;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "01111000000";                  -- 32768.0
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := 64512;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "01111011111";                  -- 64512.0
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := -64512;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "11111011111";                  -- 64512.0
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    -- Get as close as you can without triggering the round.
    chkint := 64512 + 511;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "01111011111";                  -- 64512.0
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert 64512 = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := -64512 - 511;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "11111011111";                  -- 64512.0
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert -64512 = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    -- Triggering the round.
    chkint := 64512 + 512;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "01111100000";                  -- + inf
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert integer'high = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := -64512 - 512;
    ck11 := to_float (chkint, ck11'high, -ck11'low);
    ck11t := "11111100000";                  -- - inf
    report_error ("11 bit to_float(" & integer'image(chkint) & ")",
                  ck11, ck11t);
    chkintt := to_integer (ck11t);
    assert integer'low = chkintt
      report "to_integer (" & to_string(ck11t) & ") = "
      & INTEGER'image(chkintt)
      severity error;

    -- 13 bit test (more range than 32 bit integer)
    chkint := 0;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := (others => '0');
    report_error ("13 bit to_float(0)", ck13, ck13t);
    chkintt := to_integer (ck13t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck13t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := 2;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "0100000000000";                  -- 2.0
    report_error ("13 bit to_float(2)", ck13, ck13t);
    chkintt := to_integer (ck13t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck13t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := -2;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "1100000000000";                  -- -2.0
    report_error ("13 bit to_float(-2)", ck13, ck13t);
    chkintt := to_integer (ck13t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck13t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := 32768;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "0101110000000";                  -- 32768.0
    report_error ("13 bit to_float(" & integer'image(chkint) & ")",
                  ck13, ck13t);
    chkintt := to_integer (ck13t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck13t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    -- Go as high as you can.
    chkint := 2130706432;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "0111101111111";                  -- 2,130,706,432
    report_error ("13 bit to_float(" & integer'image(chkint) & ")",
                  ck13, ck13t);
    chkintt := to_integer (ck13t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck13t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    chkint := -2130706432;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "1111101111111";                  -- -2,130,706,432
    report_error ("13 bit to_float(" & integer'image(chkint) & ")",
                  ck13, ck13t);
    chkintt := to_integer (ck13t);
    assert chkint = chkintt
      report "to_integer (" & to_string(ck13t) & ") = "
      & INTEGER'image(chkintt)
      severity error;
    -- Is rounded to a number which is larger than integer'high
    chkint := integer'high;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "0111110000000";                  -- 2.147484E09
    report_error ("13 bit to_float(" & integer'image(chkint) & ")",
                  ck13, ck13t);
    -- 32 bit -integer'low = 2,147,483,648, which is integer'high + 1.
    chkint := integer'low + 1;
    ck13 := to_float (chkint, ck13'high, -ck13'low);
    ck13t := "1111110000000";                  -- -2.147484E09
    report_error ("13 bit to_float(" & integer'image(chkint) & ")",
                  ck13, ck13t);
    -- Do it all again, but this time with real numbers
    chkreal := 0.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := (others => '0');
    report_error ("7 bit real to_float(0)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 2.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "0100000";                  -- 2.0
    report_error ("7 bit real to_float(2)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -2.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "1100000";                  -- 2.0
    report_error ("7 bit real to_float(-2)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 15.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "0110111";                  -- 15.0
    report_error ("7 bit real to_float(15)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -15.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "1110111";                  -- 15.0
    report_error ("7 bit real to_float(-15)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 16.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "0111000";                  -- infinity
    report_error ("7 bit real to_float(16)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert real'high = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -16.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "1111000";                  -- -infinity
    report_error ("7 bit real to_float(-16)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert real'low = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 16000.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "0111000";                  -- infinity
    report_error ("7 bit real to_float(16000)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert real'high = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -16000.0;
    ck7 := to_float (chkreal, ck7'high, -ck7'low);
    ck7t := "1111000";                  -- -infinity
    report_error ("7 bit real to_float(-16000)", ck7, ck7t);
    chkrealt := to_real (ck7t);
    assert real'low = chkrealt
      report "to_real (" & to_string(ck7t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 0.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := (others => '0');
    report_error ("9 bit real to_float(0)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 2.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "010000000";                  -- 2.0
    report_error ("9 bit real to_float(2)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -2.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "110000000";                  -- 2.0
    report_error ("9 bit real to_float(-2)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := 248.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "011101111";                  -- 248.0
    report_error ("9 bit real to_float(248)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -248.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "111101111";                  -- -248.0
    report_error ("9 bit real to_float(-248)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    -- Check out the rounding modes
    chkreal := 240.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "011101110";                  -- 240.0
    report_error ("9 bit real to_float(240)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -240.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "111101110";                  -- -240.0
    report_error ("9 bit real to_float(-240)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    -- 244 should not trigger rounding
    chkreal := 244.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "011101110";                  -- 240.0
    report_error ("9 bit real to_float(244)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert 240.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -244.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "111101110";                  -- -240.0
    report_error ("9 bit real to_float(-244)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert -240.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    -- 245 should trigger rounding
    chkreal := 245.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "011101111";                  -- 240.0
    report_error ("9 bit real to_float(245)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert 248.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -245.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low);
    ck9t := "111101111";                  -- -240.0
    report_error ("9 bit real to_float(-245)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert -248.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    -- round to infinity test
    chkreal := 249.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- no rounding
    ck9t := "011101111";                  -- 248.0
    report_error ("9 bit real to_float(249)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert 248.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -249.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- no rounding
    ck9t := "111101111";                  -- -248.0
    report_error ("9 bit real to_float(-249)", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert -248.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    -- round to infinity
    chkreal := 249.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_inf);  -- round up
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit real to_float(249), round inf", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert real'high = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -249.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_inf);
    ck9t := "111101111";                  -- -248.0
    report_error ("9 bit real to_float(-249), round inf", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert -248.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    -- round to negative infinity
    chkreal := 249.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_neginf);
    ck9t := "011101111";                  -- 248.0
    report_error ("9 bit real to_float(249) round neginf", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert 248.0 = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;
    chkreal := -249.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_neginf);
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit real to_float(-249) round neginf", ck9, ck9t);
    chkrealt := to_real (ck9t);
    assert real'low = chkrealt
      report "to_real (" & to_string(ck9t) & ") = " & REAL'image(chkrealt)
      severity error;

    chkreal := 252.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit real to_float(252)", ck9, ck9t);
    chkreal := -252.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit real to_float(-252)", ck9, ck9t);
    chkreal := 255.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit real to_float(255)", ck9, ck9t);
    chkreal := -255.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit real to_float(-255)", ck9, ck9t);
    chkreal := 256.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- rounding
    -- Trigger the infinity test
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit real to_float(256)", ck9, ck9t);
    chkreal := -256.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- rounding
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit real to_float(-256)", ck9, ck9t);
    chkreal := 1024.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- overflow
    ck9t := "011110000";                  -- + inf
    report_error ("9 bit real to_float(1024)", ck9, ck9t);
    chkreal := -1024.0;
    ck9 := to_float (chkreal, ck9'high, -ck9'low, round_nearest); -- overflow
    ck9t := "111110000";                  -- - infinity
    report_error ("9 bit real to_float(-1024)", ck9, ck9t);
    -- 11 bit test
    chkreal := 0.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := (others => '0');
    report_error ("11 bit real to_float(0)", ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := 2.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "01000000000";                  -- 2.0
    report_error ("11 bit real to_float(2)", ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := -2.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "11000000000";                  -- 2.0
    report_error ("11 bit real to_float(-2)", ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := 32768.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "01111000000";                  -- 32768.0
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := 64512.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "01111011111";                  -- 64512.0
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := -64512.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "11111011111";                  -- 64512.0
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    -- Get as close as you can without triggering the round.
    chkreal := 64512.0 + 511.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "01111011111";                  -- 64512.0
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert 64512.0 = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := -64512.0 - 511.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "11111011111";                  -- 64512.0
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert -64512.0 = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    -- Triggering the round.
    chkreal := 64512.0 + 512.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "01111100000";                  -- + inf
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert real'high = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := -64512.0 - 512.0;
    ck11 := to_float (chkreal, ck11'high, -ck11'low);
    ck11t := "11111100000";                  -- - inf
    report_error ("11 bit real to_float(" & real'image(chkreal) & ")",
                  ck11, ck11t);
    chkrealt := to_real (ck11t);
    assert real'low = chkrealt
      report "to_real (" & to_string(ck11t) & ") = "
      & REAL'image(chkrealt)
      severity error;

    -- 13 bit test (more range than 32 bit integer range)
    chkreal := 0.0;
    ck13 := to_float (chkreal, ck13'high, -ck13'low);
    ck13t := (others => '0');
    report_error ("13 bit real to_float(0)", ck13, ck13t);
    chkrealt := to_real (ck13t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck13t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := 2.0;
    ck13 := to_float (chkreal, ck13'high, -ck13'low);
    ck13t := "0100000000000";                  -- 2.0
    report_error ("13 bit real to_float(2)", ck13, ck13t);
    chkrealt := to_real (ck13t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck13t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := -2.0;
    ck13 := to_float (chkreal, ck13'high, -ck13'low);
    ck13t := "1100000000000";                  -- -2.0
    report_error ("13 bit real to_float(-2)", ck13, ck13t);
    chkrealt := to_real (ck13t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck13t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := 32768.0;
    ck13 := to_float (chkreal, ck13'high, -ck13'low);
    ck13t := "0101110000000";                  -- 32768.0
    report_error ("13 bit real to_float(" & real'image(chkreal) & ")",
                  ck13, ck13t);
    chkrealt := to_real (ck13t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck13t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    -- Go as high as you can.
    chkreal := 2130706432.0;
    ck13 := to_float (chkreal, ck13'high, -ck13'low);
    ck13t := "0111101111111";                  -- 2,130,706,432
    report_error ("13 bit real to_float(" & real'image(chkreal) & ")",
                  ck13, ck13t);
    chkrealt := to_real (ck13t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck13t) & ") = "
      & REAL'image(chkrealt)
      severity error;
    chkreal := -2130706432.0;
    ck13 := to_float (chkreal, ck13'high, -ck13'low);
    ck13t := "1111101111111";                  -- -2,130,706,432
    report_error ("13 bit real to_float(" & real'image(chkreal) & ")",
                  ck13, ck13t);
    chkrealt := to_real (ck13t);
    assert chkreal = chkrealt
      report "to_real (" & to_string(ck13t) & ") = "
      & REAL'image(chkrealt)
      severity error;
  
    assert quiet report "Range testing completed" severity note;
    intrange_done <= true;
    wait;
  end process intrangetest;

end architecture testbench;
