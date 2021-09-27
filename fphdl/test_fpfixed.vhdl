-- --------------------------------------------------------------------
-- Title      : Test vectors for testing conversion between fixed and floating
-- point types
-- This is a test of the routines which the user needs to call from the
-- base package.  Most of the testing of the base routines is done in the
-- test vector for the lower level packages.
--   modification history : Last Modified $Date: 2010/09/17 19:02:06 $
--   Version $Id: test_fpfixed.vhdl,v 2.0 2010/09/17 19:02:06 l435385 Exp $
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_fpfixed is
  generic (
    quiet : BOOLEAN := false);          -- run quietly  
end entity test_fpfixed;

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- IEEE 1076.3
use ieee.math_real.all;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;                 -- IEEE 1076 fixed point package
use ieee.float_pkg.all;            -- IEEE 1076 floating point package

architecture testbench of test_fpfixed is
  alias fp is float32;                     -- 32 bit fp

        -- purpose: to_float wrapper
  function to_fp (
    arg : ufixed)
    return float32 is
  begin
    return to_float (arg, float32'high, -float32'low);
  end function to_fp;

        -- purpose: to_float wrapper
  function to_fp (
    arg : sfixed)
    return float32 is
  begin
    return to_float (arg, float32'high, -float32'low);
  end function to_fp;

          -- purpose: to_float wrapper
  function to_fp (
    arg : std_logic_vector)
    return float32 is
  begin
    return to_float (arg, float32'high, -float32'low);
  end function to_fp;
  -- purpose: reports an error
  procedure report_error (
    constant errmes : string;           -- error message
    actual          : ufixed;           -- data from algorithm
    expected        : ufixed)  is       -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR
      & "Actual   " & to_string(actual)
      & " (" & real'image(to_real(actual)) & ") /= " & CR
      & "Expected " & to_string(expected)
      & " (" & real'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes : string;           -- error message
    actual          : sfixed;           -- data from algorithm
    expected        : sfixed)  is       -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR
      & "Actual   " & to_string(actual) & " /= "
      & " (" & real'image(to_real(actual)) & ") /= " & CR
      & "Expected " & to_string(expected)
      & " (" & real'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes : string;           -- error message
    actual          : fp;               -- data from algorithm
    expected        : fp)  is           -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR
      & "Actual   " & to_string(actual) & " (" & real'image (to_real(actual)) & ") /= " & CR
      & "Expected " & to_string(expected) & " (" & real'image (to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  subtype ufixed7 is ufixed (3 downto -3);   -- 7 bit
  subtype ufixed16 is ufixed (7 downto -8);  -- 16 bit
  subtype sfixed7 is sfixed (3 downto -3);   -- 7 bit
  subtype sfixed16 is sfixed (7 downto -8);  -- 16 BIT
  signal start_breaktest, breaktest_done : BOOLEAN := false;
  signal start_longtest, longtest_done : BOOLEAN := false;
begin  -- architecture testbench

  -- purpose: Series of test of the conversion functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  test_process : process is
    variable checkint                       : integer;
    variable checkreal                      : real;
    variable checkuns                       : unsigned (7 downto 0);
    variable checksns                       : signed (7 downto 0);
    variable check7uf1, check7uf2, check7uf : ufixed7;
    variable check7sf1, check7sf2, check7sf : sfixed7;
    variable check16sf1, check16sf2         : sfixed16;
    variable checknum, checknum1            : float32;    -- Floating point output
    variable checknumf, checknumf1 : fp;
    variable checkst, checkst1 : SIGNED (3 downto 0);
  begin  -- process test_process
    checknum  := "00000000000000000000000000000000";   -- 0
    check7uf1 := to_ufixed (checknum, check7uf1'high, check7uf1'low);
    check7uf  := "0000000";
    report_error ("to_ufixed 0 miscompare",
                  check7uf1,
                  check7uf);
    checknum  := "01000000000000000000000000000000";   -- 2
    check7uf1 := to_ufixed (checknum, check7uf1'high, check7uf1'low);
    check7uf  := "0010000";
    report_error ("to_ufixed 2 miscompare",
                  check7uf1,
                  check7uf);
    checknum  := "01000000110100000000000000000000";   -- 6.5
    check7uf1 := to_ufixed (checknum, check7uf1'high, check7uf1'low);
    check7uf  := "0110100";
    report_error ("to_ufixed 6.5 miscompare",
                  check7uf1,
                  check7uf);    
    checknum  := "00000000000000000000000000000000";   -- 0
    check7sf1 := to_sfixed (checknum, check7sf1'high, check7sf1'low);
    check7sf  := "0000000";
    report_error ("to_sfixed 0 miscompare",
                  check7sf1,
                  check7sf);
    checknum  := "01000000000000000000000000000000";   -- 2
    check7sf1 := to_sfixed (checknum, check7sf1'high, check7sf1'low);
    check7sf  := "0010000";
    report_error ("to_sfixed 2 miscompare",
                  check7sf1,
                  check7sf);
    checknum  := "01000000110100000000000000000000";   -- 6.5
    check7sf1 := to_sfixed (checknum, check7sf1'high, check7sf1'low);
    check7sf  := "0110100";
    report_error ("to_sfixed 6.5 miscompare",
                  check7sf1,
                  check7sf);
    checknum   := "11000000110100000000000000000000";  -- -6.5
    check16sf1 := to_sfixed (checknum, check16sf1'high, check16sf1'low);
    check16sf2 := "1111100110000000";                  -- -6.5
    report_error ("to_sfixed -6.5 miscompare",
                  check16sf1,
                  check16sf2);

    check7uf  := "0000000";
    checknum  := to_fp (check7uf);
    checknum1 := "00000000000000000000000000000000";   -- 0
    report_error ("to_fp 0 miscompare",
                  checknum,
                  checknum1);
    check7uf  := "0010000";
    checknum  := to_fp (check7uf);
    checknum1 := "01000000000000000000000000000000";   -- 2
    report_error ("to_fp 2 miscompare",
                  checknum,
                  checknum1);
    check7uf  := "0110100";
    checknum  := to_fp (check7uf);
    checknum1 := "01000000110100000000000000000000";   -- 6.5
    report_error ("to_fp 6.5 miscompare",
                  checknum,
                  checknum1);    
    check7sf  := "0000000";
    checknum  := to_fp (check7sf);
    checknum1 := "00000000000000000000000000000000";   -- 0
    report_error ("to_fp signed 0 miscompare",
                  checknum,
                  checknum1);    
    check7sf  := "0010000";
    checknum  := to_fp (check7sf);
    checknum1 := "01000000000000000000000000000000";   -- 2
    report_error ("to_fp signed 2 miscompare",
                  checknum,
                  checknum1);
    check7sf  := "0110100";
    checknum  := to_fp (check7sf);
    checknum1 := "01000000110100000000000000000000";   -- 6.5
    report_error ("to_fp signed 6.5 miscompare",
                  checknum,
                  checknum1);
    check16sf2 := "1111100110000000";                  -- -6.5
    checknum   := to_fp (check16sf2);
    checknum1  := "11000000110100000000000000000000";  -- - 6.5
    report_error ("to_fp signed -6.5 miscompare",
                  checknum,
                  checknum1);
    -- check this in the "fphdl_pkg" now
    checknumf := "00000000000000000000000000000000";   -- 0
    check7uf1 := to_ufixed (checknumf, check7uf1'high, check7uf1'low);
    check7uf  := "0000000";
    report_error ("to_ufixed 0 miscompare",
                  check7uf1,
                  check7uf);
    checknumf := "01000000000000000000000000000000";   -- 2
    check7uf1 := to_ufixed (checknumf, check7uf1'high, check7uf1'low);
    check7uf  := "0010000";
    report_error ("to_ufixed 2 miscompare",
                  check7uf1,
                  check7uf);
    checknumf := "01000000110100000000000000000000";   -- 6.5
    check7uf1 := to_ufixed (checknumf, check7uf1'high, check7uf1'low);
    check7uf  := "0110100";
    report_error ("to_ufixed 6.5 miscompare",
                  check7uf1,
                  check7uf);    

    checknumf := "00000000000000000000000000000000";   -- 0
    check7sf1 := to_sfixed (checknumf, check7sf1'high, check7sf1'low);
    check7sf  := "0000000";
    report_error ("to_sfixed 0 miscompare",
                  check7sf1,
                  check7sf);
    checknumf := "01000000000000000000000000000000";   -- 2
    check7sf1 := to_sfixed (checknumf, check7sf1'high, check7sf1'low);
    check7sf  := "0010000";
    report_error ("to_sfixed 2 miscompare",
                  check7sf1,
                  check7sf);
    checknumf := "01000000110100000000000000000000";   -- 6.5
    check7sf1 := to_sfixed (checknumf, check7sf1'high, check7sf1'low);
    check7sf  := "0110100";
    report_error ("to_sfixed 6.5 miscompare",
                  check7sf1,
                  check7sf);
    checknumf  := "11000000110100000000000000000000";  -- -6.5
    check16sf1 := to_sfixed (checknumf, check16sf1'high, check16sf1'low);
    check16sf2 := "1111100110000000";                  -- -6.5
    report_error ("to_sfixed -6.5 miscompare",
                  check16sf1,
                  check16sf2);

    check7uf   := "0000000";
    checknumf  := to_fp (check7uf);
    checknumf1 := "00000000000000000000000000000000";  -- 0
    report_error ("to_fp 0 miscompare",
                  checknumf,
                  checknumf1);
    check7uf   := "0010000";
    checknumf  := to_fp (check7uf);
    checknumf1 := "01000000000000000000000000000000";  -- 2
    report_error ("to_fp 2 miscompare",
                  checknumf,
                  checknumf1);
    check7uf   := "0110100";
    checknumf  := to_fp (check7uf);
    checknumf1 := "01000000110100000000000000000000";  -- 6.5
    report_error ("to_fp 6.5 miscompare",
                  checknumf,
                  checknumf1);    
    check7sf   := "0000000";
    checknumf  := to_fp (check7sf);
    checknumf1 := "00000000000000000000000000000000";  -- 0
    report_error ("to_fp signed 0 miscompare",
                  checknumf,
                  checknumf1);    
    check7sf   := "0010000";
    checknumf  := to_fp (check7sf);
    checknumf1 := "01000000000000000000000000000000";  -- 2
    report_error ("to_fp signed 2 miscompare",
                  checknumf,
                  checknumf1);
    check7sf   := "0110100";
    checknumf  := to_fp (check7sf);
    checknumf1 := "01000000110100000000000000000000";  -- 6.5
    report_error ("to_fp signed 6.5 miscompare",
                  checknumf,
                  checknumf1);
    check16sf2 := "1111100110000000";                  -- -6.5
    checknumf  := to_fp (check16sf2);
    checknumf1 := "11000000110100000000000000000000";  -- -6.5
    report_error ("to_fp signed -6.5 miscompare",
                  checknumf,
                  checknumf1);
    check7sf1 := "1000000";            -- -8
    checknumf := to_fp (check7sf1);
    checknumf1 := to_float (-8, float32'high, -float32'low);
    report_error ("to_fp (sfixed-8) miscompare",
                  checknumf,
                  checknumf1);
    checkst := "1000";
    checknum := to_float (checkst, float32'high, -float32'low);
    checknum1 := to_float (-8, float32'high, -float32'low);
    report_error ("to_fp (signed-8) miscompare",
                  checknum,
                  checknum1);
    -- Do the break_number and normalize testing
    start_breaktest <= true;
    wait until breaktest_done;
    start_longtest <= true;
    wait until longtest_done;
    report "Fixed point and floating point translate test complete"
      severity note;
    wait;

  end process test_process;

  -- purpose: test break_number and normalize for fixed point
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  breaktest: process is
   -- raw floating point number
    variable checknum, checknum1, checknum2, checknum3 : float32;  -- floating point
    variable frc, frc1, frc2, frc3 : ufixed (0 downto float32'low);  -- fraction
    variable frcp : ufixed ( 1 downto float32'low);
    variable exp, exp1, exp2, exp3 : SIGNED (float32'high-1 downto 0);  -- exp
    variable sign : STD_ULOGIC;
    variable checkint : INTEGER;
  begin
    wait until start_breaktest;
    checknum  := "01000000110100000000000000000000";  -- 6.5
    checknum1 := "01000000100000000000000000000000";  -- 4
    break_number (arg => checknum,
                  denormalize => false,
                  fract => frc,
                  expon => exp,
                  sign => sign);
    frc3 := "110100000000000000000000";  -- 1.625 in fixed point
    report_error ("6.5 break number", frc, frc3);
    exp3 := "00000001";                 -- remember, biased by -1
    assert (exp = exp3) report "6.5 exp break number " severity error;
    break_number (arg => checknum1,
                  denormalize => false,
                  fract => frc1,
                  expon => exp1,
                  sign => sign);
    frc3 := "100000000000000000000000";  -- 1.0 in fixed point
    report_error ("2.0 break number", frc1, frc3);
    exp3 := "00000001";                 -- remember, biased by -1
    assert (exp1 = exp3) report "2.0 exp break number " severity error;
    frcp := frc + frc1;                 -- Add the fractions together
    checknum2 := normalize (fract => frcp,
                          expon => exp3,  -- all the same at this point
                          sign => '0',
                          fraction_width => -float32'low,
                          exponent_width => float32'high,
                          round_style => round_zero,  -- truncate
                          denormalize => false,
                          nguard => 1);
    -- 6.5 + 4.0
    checknum3 := add (checknum, checknum1);
    report_error ("normalize 6.5 + 4.0", checknum2, checknum3);
    breaktest_done <= true;
    wait;
  end process breaktest;

  -- purpose: Very long fixed point numbers

  longtest: process is
    variable ls1, ls2 : sfixed (128 downto -149);
    variable a, b, c : fp;
    variable r1, r2 : REAL;
  begin
    wait until start_longtest;
    ls1 := (others => '0');
    a := (others => '0');
    b := to_float(ls1);
    report_error ("to_float(large sfixed) 0", b, a);
    ls1 := (others => '0');
    ls1 (0) := '1';
    a := to_float(1.0);
    b := to_float(ls1);
    report_error ("to_float(large sfixed) 1", b, a);
    ls1 := resize (-ls1, ls1'high, ls1'low);
    a := to_float(-1.0);
    b := to_float(ls1);
    report_error ("to_float(large sfixed) -1", b, a);
    ls1 := (others => '0');
    ls1 (-1) := '1';                    -- 0.5
    a := to_float(0.5);
    b := to_float(ls1);
    report_error ("to_float(larg sfixed) 0.5", b, a);
    ls1 := (others => '0');
    ls1 (-126) := '1';                  -- min normal
    a := "00000000100000000000000000000000";
    b := to_float(ls1);
    report_error ("to_float(large sfixed) min normal", a, b);
    ls1 := (others => '0');
    ls1 (-127) := '1';                  -- max denomal
    ls1 (-128) := '1';                  -- for another value
    a := "00000000011000000000000000000000";
    b := to_float(ls1);
    report_error ("to_float(large sfixed) max denormal", a, b);
    
    a := "00000000000000000000000000000001";  -- 2**-149 (min denormal)
    ls1 := (others => '0');
    ls1 (ls1'low) := '1';               -- 2**-149
    b := to_float(ls1);
      report_error ("to_float(sfixed) min denormal", b, a);
    -- maximum number in Float32
    r1 := ( 1.0 - (2.0**(-24.0)) ) * (2.0**(+128.0));
    ls1 := to_sfixed (r1, ls1'high, ls1'low);
    ls2 := (others => '0');
    ls2 (ls2'high-1 downto ls2'high-24) := (others => '1');  -- Max of float32
    report_error ("to_sfixed(real) max value", ls1, ls2);
    b := to_float(r1);
    a := "01111111011111111111111111111111";  -- Just less than infinity
    report_error ("to_float(real) max value", b, a);
    b := to_float (ls2);
    report_error ("to_float(sfixed) max value", b,a);
    
    ls2 := resize (-ls2, ls2'high, ls2'low);
    a := to_float(ls2);
    b := "11111111011111111111111111111111";  -- Just less than -inf
    report_error ("to_float(large sfixed) min value", a, b);
    ls1 := (others => '1');
    ls1(ls1'high) := '0';
    a := to_float(ls1);                 -- should round to infinity
    b := "01111111100000000000000000000000";  -- + inf
    report_error ("to_float(larg xfixed) round to inf", a, b);
    ls1 := (others => '0');
    ls1(ls1'high) := '1';
    a := to_float(ls1);                 -- round to -inf
    b := "11111111100000000000000000000000";  -- - inf
    report_error ("to_float(larg xfixed) round to -inf", a, b);
    
    longtest_done <= true;
    wait;
  end process longtest;
  
end architecture testbench;
