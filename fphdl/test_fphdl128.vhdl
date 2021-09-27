-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the "fphdl128_pkg" package.
-- This is a comprehensive test for all of the routines in this package
-- Last Modified: $Date: 2006-07-07 15:35:52-04 $
-- RCS ID: $Id: test_fphdl128.vhdl,v 1.1 2006-07-07 15:35:52-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_fphdl128 is
  generic (
    quiet : BOOLEAN := false);          -- run quietly 
end entity test_fphdl128;

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;
architecture testbench of test_fphdl128 is

-- For the conversion function test
  function reverse (
    inpvec : std_logic_vector (0 to 31))
    return float32 is
    variable result : float32;
  begin
    for i in 0 to 31 loop
      result (i-23) := inpvec(i);
    end loop;  -- i
    return result;
  end function reverse;

  -- purpose: reports an error
  procedure report_error (
    constant errmes   : in string;      -- error message
    actual            : in float;        -- data from algorithm
    constant expected : in float128)  is    -- reference data
    variable L : line;
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR &
          "Actual   " & to_string (actual) & " ("
          & real'image(to_real(actual))& ") /= " & CR &
          "Expected " & to_string (expected) & " ("
          & real'image(to_real(expected))& ")"
      severity error;
    return;
  end procedure report_error;
begin  -- architecture testbench

  -- purpose: testing process
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  test_process: process is
    variable checknum   : float128;         -- Floating point output
    variable checknum2  : float128;         -- Floating point output
    variable checknum3  : float128;         -- Floating point output
    variable checkint   : integer;      -- integer test
    variable checkreal  : real;         -- real test
    variable checkreal2 : real;         -- real test
  begin  -- process test_process
    checkint := 0;
    checknum := to_float (checkint, checknum);
    report_error ( "FP 0 miscompare",
                   checknum,
                   zerofp(float128'high, -float128'low));
    checkint := 2;
    checknum := to_float (checkint, checknum);
    report_error ( "FP 2 miscompare",
                   checknum,
                   to_float128(float32'("01000000000000000000000000000000")));  -- 2
    checkint := -2;
    checknum := to_float (checkint, float128'high, -float128'low);
    report_error ( "FP -2 miscompare",
                   checknum,
                   to_float128(float32'("11000000000000000000000000000000")));  -- -2
    checkint := 7;
    checknum := to_float (checkint, checknum);
    report_error ( "FP 7 miscompare",
                   checknum,
                   to_float128(float32'("01000000111000000000000000000000")));  -- 7
    checkreal := 6.5;
    checknum := to_float (checkreal, float128'high, -float128'low);
    report_error ("FP 6.5 miscompare",
                  checknum,
                  to_float128(reverse("00000000000000000000101100000010")));
    checkreal := -6.5;
    checknum := to_float (checkreal, checknum);
    report_error ("FP -6.5 miscompare",
                  checknum,
                  to_float128(reverse("00000000000000000000101100000011")));
    checkint := 36892987;
    checknum := to_float (checkint, checknum);
    report_error ("FP 36892987 miscompare",
                  checknum,
                  "01000000000110000001100101111000100111011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
--                  "01000000000000000000000000001100000011001011110001001110110000000000000000000000000000000000000000000000000000000000000000000000");
    checkreal := 1.0/3.0;
    checknum := to_float (checkreal, checknum);
    report_error ("FP 1/3 miscompare",
                  checknum,
                  "00111111111111010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000");
--                  "00111111111111111111111111111110101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000");
    checkreal := 0.000007;
    checknum := to_float (checkreal, checknum);
    report_error ("FP 0.000007 miscompare (fails in some simulators)",
                  checknum,
--                  "00111111111111111111111111110110111010101110000110001010110010011111001011111101110000000000000000000000000000000000000000000000"
                  "00111111111011011101010111000011000101011001001111100101111110110111000000000000000000000000000000000000000000000000000000000000");
--                  "00111111111111111111111111110110111010101110000110001010110010011111001011111101101110000000000000000000000000000000000000000000");

    checknum3 := to_float128(reverse("00000000000000000000101100000010")); -- 6.5
    checknum := to_float128(reverse("00000000000000000001010001000010")); -- 42
    checknum2 := checknum + checknum3;
    report_error ("6.5 + 42 miscompare",
                  checknum2,
                  to_float (48.5, checknum));
    checknum2 := checknum * checknum3;
    report_error ("6.5 * 42 miscompare",
                  checknum2,
                  to_float (273, checknum));
    checknum := checknum2 / checknum3;
    report_error ("273/42 miscompare",
                  checknum,
                  to_float128(reverse("00000000000000000001010001000010")));
    checknum := to_float (1, checknum) / to_float(3, checknum);
    report_error ("1/3 miscompare  (precision failure in REAL package)",
                  checknum,
--                   5432109876543210
                  "00111111111111010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101");
--                   210987654321098765432109876543210
--                  "00111111111111111111111111111110101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101011");
    report "Testing complete" severity note;
    wait;
  end process test_process;


end architecture testbench;
