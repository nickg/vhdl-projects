-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the "fphdl64_pkg" package.
-- This is a comprehensive test for all of the routines in this package
-- Last Modified: $Date: 2007-09-12 08:58:36-04 $
-- RCS ID: $Id: test_fphdl64.vhdl,v 1.4 2007-09-12 08:58:36-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_fphdl64 is
  generic (
    quiet : BOOLEAN := false);          -- run quietly

end entity test_fphdl64;

use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.fixed_float_types.all;
use ieee.float_pkg.all;
architecture testbench of test_fphdl64 is
  constant iterations   : integer := 5000;      -- number of interations

  -- purpose: to_float wrapper
  function to_fp (
    arg : INTEGER)
    return float64 is
  begin
    return to_float (arg, float64'high, -float64'low);
  end function to_fp;

  -- purpose: to_float wrapper
  function to_fp (
    arg : real)
    return float64 is
  begin
    return to_float (arg, float64'high, -float64'low);
  end function to_fp;

  -- purpose: to_float wrapper
  function to_fp (
    arg : signed)
    return float64 is
  begin
    return to_float (arg, float64'high, -float64'low);
  end function to_fp;

  -- purpose: to_float wrapper
  function to_fp (
    arg : unsigned)
    return float64 is
  begin
    return to_float (arg, float64'high, -float64'low);
  end function to_fp;

  -- purpose: to_float wrapper
  function to_fp (
    arg : std_logic_vector)
    return float64 is
  begin
    return to_float (arg, float64'high, -float64'low);
  end function to_fp;

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
    constant errmes : in string;        -- error message
    actual          : in float;          -- data from algorithm
    expected        : in float)  is      -- reference data
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
  -- purpose: reports an error
  procedure report_error (
    constant errmes   :    string;      -- error message
    actual            : in unsigned;        -- data from algorithm
    constant expected :    unsigned)  is    -- reference data
    variable L : line;
  begin  -- function report_error
    if actual /= expected then
      assert (false) report errmes severity error;
      write (L, string'("Actual   "));
      write (L, std_ulogic_vector (actual));
      write (L, string'(" /= "));
      writeline (output, L);
      L := new string'("Expected ");
      write (L, std_ulogic_vector (expected));
      writeline (output, L);
    end if;
    return;
  end procedure report_error;
  procedure report_error (
    constant errmes   :    string;      -- error message
    actual            : in signed;        -- data from algorithm
    constant expected :    signed)  is    -- reference data
    variable L : line;
  begin  -- function report_error
    if actual /= expected then
      assert (false) report errmes severity error;
      write (L, string'("Actual   "));
      write (L, std_ulogic_vector (actual));
      write (L, string'(" /= "));
      writeline (output, L);
      L := new string'("Expected ");
      write (L, std_ulogic_vector (expected));
      writeline (output, L);
    end if;
    return;
  end procedure report_error;
  procedure report_error (
    constant errmes   :    string;      -- error message
    actual            : in std_logic_vector;        -- data from algorithm
    constant expected :    std_logic_vector)  is    -- reference data
    variable L : line;
  begin  -- function report_error
    if actual /= expected then
      assert (false) report errmes severity error;
      write (L, string'("Actual   "));
      write (L, actual);
      write (L, string'(" /= "));
      writeline (output, L);
      L := new string'("Expected ");
      write (L, expected);
      writeline (output, L);
    end if;
    return;
  end procedure report_error;
  procedure report_error_loop (
    constant errmes   : in string;      -- error message
    iteration : integer;
    actual            : in float;        -- data from algorithm
    constant expected : in float)  is    -- reference data
    variable L : line;
    variable fract1, fract2 : unsigned (-float64'low-1 downto 0); -- fract
  begin  -- function report_error
    if actual /= expected then
      -- these routines add or subtract 1 from the result
      -- if we are 1 (or less) off then the result is still correct.
      for i in -1 downto float64'low loop
        fract1(-float64'low+i) := actual(i);
        fract2(-float64'low+i) := expected(i);
      end loop;
      if ((fract1 = fract2+1) or (fract1 = fract2-1))
        and (std_logic_vector(actual(float64'high downto 0)) =
             std_logic_vector(expected(float64'high downto 0))) then
      else
        report errmes & " " & integer'image(iteration) & CR &
      "Actual   " & to_string (actual) & " /= " & CR &
      "Expected " & to_string (expected);
      end if;
    end if;
    return;
  end procedure report_error_loop;
  signal start_sbtest, sbtest_done : BOOLEAN := false;  -- subtract boundard test
  constant expon_base  : integer := 2**(float64'high-1) -1;  -- highest exponent
begin  -- architecture testbench

  -- purpose: Checks the conversion functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Test_process : process is
    variable checknum   : float64;         -- Floating point output
    variable checknum1  : float64;         -- Floating point output
    variable checknum2  : float64;         -- Floating point output
    variable checknum3  : float64;         -- Floating point output
    variable checknum32 : float32;  -- float32
    variable checkint   : integer;      -- integer test
    variable checkreal  : real;         -- real test
    variable checkreal2 : real;         -- real test
    variable checkuns   : unsigned ( 33 downto 0 );  -- unsigned test
    variable checksns   : signed ( 33 downto 0 );  -- signed test
    variable checksign  : signed ( float64'high - 1 downto 0 );  -- check of SIGNED
    variable fptype : valid_fpstate;
    variable seed1, seed2 : integer := 1000000;  -- Seed for random number
    variable L : line;
  begin  -- process Test_process
    checknum  := zerofp(checknum);
    checkint  := to_integer (checknum);
    assert (checkint = 0) report "+0 test miscompare" severity error;
    checknum  := neg_zerofp(checknum);
    checkint  := to_integer (checknum);
    assert (checkint = 0) report "-0 test miscompare" severity error;
    checknum  := "0100000000000000000000000000000000000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 2) report "2 test miscompare" severity error;    
    checknum  := "1100000000000000000000000000000000000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = -2) report "-2 test miscompare" severity error;
    checknum  := "0100000000000000000000000000000000000000000000000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = 2.0) report "2.0 test miscompare" severity error;
    checknum  := "0100000000011010000000000000000000000000000000000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = 6.5) report "6.5 test miscompare" severity error;
    checknum  := "1100000000011010000000000000000000000000000000000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = -6.5) report "-6.5 test miscompare" severity error;
    checknum  := "0011111111000000000000000000000000000000000000000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = 0.125) report "0.125 test miscompare" severity error;
    checknum  := "0100000001000101000000000000000000000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 42) report "42 test miscompare" severity error;
    checknum  := "0000000000001000000000000000000000000000000000000000000000000000";

    checkreal := to_real (checknum);
    assert (checkreal = 2.0**(-1023))
      report "2**-1023 test miscompare " & integer'image(checkint)
      severity error;
    checknum  := "0100000110000001100101111000100111011000000000000000000000000000";
    checkint  := to_integer (arg => checknum);
    assert (checkint = 36892987)
      report "64bit 36892987 test miscompare " & integer'image(checkint)
      severity error;
    checknum  := "0100000110000001100101111000100111110000000000000000000000000000";
    checkint  := to_integer (arg => checknum);
    assert (checkint = 36892990)
      report "64bit 36892990 test miscompare " & integer'image(checkint)
      severity error;
    checknum  := "0100000111011111111111111111111111111111010000000000000000000000";
    checkint  := to_integer (arg => checknum);
    assert (checkint = 2147483645)
      report "64bit maxint -2 miscompare "& integer'image(checkint)
      severity error;
    checknum  := "0100000111011111111111111111111111111111110000000000000000000000";
    checkint  := to_integer (arg => checknum);
    assert (checkint = +2147483647)
      report "64bit integer'high miscompare " & integer'image(checkint)
      severity error;
    checknum  := "1100000111011111111111111111111111111111110000000000000000000000";
    checkint  := to_integer (arg => checknum);
    assert (checkint = -2147483647)
      report "64bit integer'low miscompare " & integer'image(checkint)
      severity error;
    
    -- Check to integer to floating point conversion
    checkint := 0;
    checknum := to_fp (checkint);
    report_error( "FP +0 miscompare", checknum , zerofp);
    checkint := 2;
    checknum := to_fp (checkint);
    report_error ("FP +2 miscompare",
                  checknum,
                  float64'("0100000000000000000000000000000000000000000000000000000000000000"));
    checkint := -2;
    checknum := to_fp (checkint);
    report_error ( "FP -2 miscompare",
                   checknum,
                   float64'("1100000000000000000000000000000000000000000000000000000000000000"));
    checkreal := 6.5;
    checknum  := to_fp(checkreal);
    report_error ( "FP 6.5 test miscompare",
                   checknum,
                   float64'("0100000000011010000000000000000000000000000000000000000000000000"));
    checkreal := -6.5;
    checknum  := to_fp(checkreal);

    report_error ( "FP -6.5 test miscompare",
                   checknum,
                   float64'("1100000000011010000000000000000000000000000000000000000000000000"));
    checkreal := 0.125;
    checknum  := to_fp(checkreal);
    report_error ( "FP 0.125 test miscompare",
                   checknum,
                   float64'("0011111111000000000000000000000000000000000000000000000000000000"));
    checkint := 42;
    checknum := to_fp (checkint);
    report_error ( "FP 42 miscompare",
                   checknum,
                   float64'("0100000001000101000000000000000000000000000000000000000000000000"));
    checkreal := 2.0**(-1023);
    checknum  := to_fp(checkreal);
    report_error ( "FP 2**-1023 miscompare",
                   checknum,
                   float64'("0000000000001000000000000000000000000000000000000000000000000000"));
    -- Signed and unsigned
    checksign := to_signed (-42, checksign'high + 1);
    checknum  := to_fp(checksign);
    report_error ( "FP signed -42 test miscompare",
                   checknum,
                   float64'("1100000001000101000000000000000000000000000000000000000000000000"));
    checkuns := to_unsigned (42, checkuns'high + 1);
    checknum := to_fp(checkuns);
    report_error ( "FP unsigned 42 test miscompare" ,
                   checknum,
                   float64'("0100000001000101000000000000000000000000000000000000000000000000"));
    checkuns := "1100000000000000000000000000000001";
    checknum := to_fp (checkuns);
    report_error ( "Extended unsigned test miscompare (will fail with REAL pkg)" ,
                   checknum,
                   float64'("0100001000001000000000000000000000000000000010000000000000000000"));
    checkuns := to_unsigned (1, checkuns'length);
    checknum := to_fp (checkuns);
    report_error ( "to_unsigned of '01' miscompare",
                   checknum,
                   to_fp(1));
    checksns := "1100000000000000000000000000000001";
    checknum := to_fp (checksns);
    report_error ( "Extended -signed test miscompare (will fail with REAL pkg)" ,
                   checknum,
                   float64'("1100000111101111111111111111111111111111111000000000000000000000"));
    checksns := "0100000000000000000000000000000001";
    checknum := to_fp (checksns);
    report_error ( "Extended +signed test miscompare (will fail with REAL pkg)" ,
                   checknum,
                   float64'("0100000111110000000000000000000000000000000100000000000000000000"));
    checkuns := to_unsigned (42, checksns'length);
    checknum32 := to_float(checkuns, checknum32);
    report_error ( "32 bit FP unsigned 42 test miscompare" ,
                   checknum32,
                   reverse("00000000000000000001010001000010"));
    checksns := to_signed (42, checksns'length);
    checknum32 := to_float(checksns, float32'high, -float32'low);
    report_error ( "32 bit FP signed 42 test miscompare" ,
                   checknum32,
                   reverse("00000000000000000001010001000010"));
    checksns := to_signed (1, checksns'length);
    checknum := to_fp(checksns(1 downto 0));
    report_error ( "to_signed of '01' miscompare",
                   checknum,
                   to_fp(1));    
    -- Extended floating point test
    checkint := 36892987;
    checknum := to_fp (checkint);
    report_error ( "FP 36892987 miscompare",
                   checknum,
                   float64'("0100000110000001100101111000100111011000000000000000000000000000"));
    checkint := 36892990;
    checknum := to_fp (checkint);
    report_error ( "FP 36892990 miscompare",
                   checknum,
                   float64'("0100000110000001100101111000100111110000000000000000000000000000"));
    checkint := 2147483645;             -- max int -2
    checknum := to_fp ( checkint);
    report_error ( "FP maxint -2 miscompare",
                   checknum,
                   float64'("0100000111011111111111111111111111111111010000000000000000000000"));
    checkint := -2147483647;            -- Integer'low
    checknum := to_fp ( checkint);
    report_error ( "FP integer'low miscompare",
                   checknum,
                   float64'("1100000111011111111111111111111111111111110000000000000000000000"));    
    checkint := +2147483647;            -- Integer'high
    checknum := to_fp ( checkint);
    report_error ( "FP integer'high miscompare",
                   checknum,
                   float64'("0100000111011111111111111111111111111111110000000000000000000000"));
    checkreal := +2147483647.0;          -- Integer'high
    checknum := to_fp ( checkreal );
    report_error ( "FP real integer'high miscompare",
                   checknum,
                   float64'("0100000111011111111111111111111111111111110000000000000000000000"));
    checkreal := checkreal * 2.0**80;
    checknum := to_fp ( checkreal);
    report_error ( "FP 2**80 * real integer'high miscompare",
                   checknum,
                   float64'("0100011011011111111111111111111111111111110000000000000000000000"));
    checknum := to_fp(MATH_PI);
    report_error ( "FP PI miscompare",
                   checknum,
                   float64'("0100000000001001001000011111101101010100010001000010110100011000"));
    checknum := to_fp (1.0/3.0);
    report_error ( "FP 1/3 miscompare",
                   checknum,
                   float64'("0011111111010101010101010101010101010101010101010101010101010101"));

    checknum2 := "0100000111110110010110100000101111000000000100000000000000000000";
-- 6,000,000,000
    if (quiet and not fphdlsynth_or_real) then
      checkuns := to_unsigned (checknum2, checkuns'high+1);
    report_error ("Unsigned 6 billion miscompare (will fail with REAL pkg)",
                  checkuns, "0101100101101000001011110000000001");
    checksns := to_signed (checknum2, checksns'high +1);
    report_error ("signed 6 billion miscompare (will fail with REAL pkg)",
                  checksns, "0101100101101000001011110000000001");
    checknum2 := "0100001000000110010110100000101111000000000110000000000000000000";
-- 12,000,000,000
    checkuns := to_unsigned (checknum2, checkuns'high+1);
    report_error ("unsigned 12 billion miscompare (will fail with REAL pkg)",
                  checkuns,  "1011001011010000010111100000000011");
    checknum2 := "1100000111110110010110100000101111000000000000000000000000000000";
    checksns := to_signed (checknum2, checksns'high +1);
    report_error ("signed -6 billion miscompare (will fail with REAL pkg)",
                  checksns, "1010011010010111110100010000000000");
    end if;

-- Check some basic math functions
    checknum2 := "1100000000011010000000000000000000000000000000000000000000000000";  -- -6.5
    checknum  := abs (checknum2);
    report_error ( "abs -6.5 test miscompare",
                   checknum,
                   to_fp(6.5));
    -- Check some basic math functions
    checknum2 := "1100000000011010000000000000000000000000000000000000000000000000";  -- -6.5
    checknum  := - checknum2;
    report_error ( "neg -6.5 test miscompare",
                   checknum,
                   to_fp(6.5));
    checknum3 := "0100000001000101000000000000000000000000000000000000000000000000";  -- 42
    checknum  := - checknum3;
    report_error ( "neg 42 test miscompare",
                   checknum,
                   to_fp(-42));
    checknum  := "0100000000011010000000000000000000000000000000000000000000000000";  -- 6.5
    checknum2 := checknum3 + checknum;  -- 42 + 6.5
    assert (to_real(checknum2) = 48.5)
      report "Add 42 + 6.5 test miscompare" severity error;
    checknum2 := checknum3 - checknum;  -- 42 - 6.5
    assert (to_real(checknum2) = 35.5)
      report "subtract 42 - 6.5 test miscompare" severity error;
    checknum2 := checknum3 * checknum;  -- 42 * 6.5
    assert (to_integer(checknum2) = 273)
      report "mult 42 * 6.5 test miscompare" severity error;
    checknum := checknum2 / checknum3;  -- 273 / 42
    assert (to_real(checknum) = 6.5)
      report "div 273 / 42 test miscompare" severity error;
    checknum1 := "0000000000000000111000111000111000111000111000111000111000111000";
    --               0000E38E38E38E38
    checknum2 := "0000000000010000000000000000000000000000000000000000000000000000";
    --               0010000000000000
    checknum := checknum1 * checknum2;
    report_error ("mult denormal * smallest normal error",
                  checknum,
                  zerofp);
    checknum := to_fp(2.0**(-512));
    checknum2 := checknum * checknum;
    checknum3 := (others => '0');
    checknum3 (-2) := '1';               -- denormal number 2**-1024
    report_error ("2**-512 * 2**-512 denormal test", checknum2, checknum3);

    -- Check the compare operations
    checknum  := to_fp (1.0/3.0);
    checknum2 := to_fp ( 2 );
    assert (checknum = checknum)        -- true
      report "Error X = X miscompare" severity error;
    assert not(checknum = checknum2)    -- false
      report "Error X = Y miscompare" severity error;
    assert (zerofp = neg_zerofp)            -- true
      report "Error 0 = -0 miscompare" severity error;
    assert not(checknum = qnanfp)         -- false
      report "Error X = qnan miscompare" severity error;
    assert not(qnanfp = checknum2)        -- false
      report "Error qnan = Y miscompare" severity error;
    assert (checknum2 = 2.0)            -- true
      report "Error X = real(X) miscompare" severity error;
    assert not(checknum2 = 1.0)         -- false
      report "Error X = real(Y) miscompare" severity error;
    assert (2.0 = checknum2)            -- true
      report "Error real(X) = X miscompare" severity error;
    assert not(1.0 = checknum2)         -- false
      report "Error real(X) = Y miscompare" severity error;
    
    assert not(checknum /= checknum)    -- false
      report "Error X /= X miscompare" severity error;
    assert (checknum /= checknum2)      -- true
      report "Error X /= Y miscompare" severity error;
    assert not((zerofp /= neg_zerofp))      -- false
      report "Error 0 = -0 miscompare" severity error;
    assert (checknum /= qnanfp)           -- true
      report "Error X = qnan miscompare" severity error;
    assert (qnanfp /= checknum2)          -- true
      report "Error qnan = Y miscompare" severity error;
    assert not(checknum2 /= 2.0)        -- false
      report "Error X /= real(X) miscompare" severity error;
    assert(checknum2 /= 1.0)            -- true
      report "Error X /= real(Y) miscompare" severity error;
    assert not(2.0 /= checknum2)        -- false
      report "Error real(X) /= X miscompare" severity error;
    assert (1.0 /= checknum2)           -- true
      report "Error real(X) /= Y miscompare" severity error;
    
    assert (checknum >= checknum)       -- true
      report "Error X >= X miscompare" severity error;
    assert (checknum2 >= checknum)      -- true
      report "Error Y >= X miscompare" severity error;
    assert not(checknum >= checknum2)   -- false
      report "Error X >= Y miscompare" severity error;
    assert not(checknum >= qnanfp)        -- false
      report "Error X >= qnan miscompare" severity error;
    assert not(qnanfp >= checknum2)       -- false
      report "Error qnan >= Y miscompare" severity error;
    assert (checknum2 >= 2.0)           -- true
      report "Error X >= real(X) miscompare" severity error;
    assert not(checknum2 >= 3.0)        -- false
      report "Error X >= real(Y) miscompare" severity error;
    assert (2.0 >= checknum2)           -- true
      report "Error real(X) >= Y miscompare" severity error;
    assert not (1.0 >= checknum2)       -- false
      report "Error real(X) >= Y miscompare" severity error;

    assert (checknum <= checknum)       -- true
      report "Error X <= X miscompare" severity error;
    assert not(checknum2 <= checknum)   -- false
      report "Error Y <= X miscompare" severity error;
    assert (checknum <= checknum2)      -- true
      report "Error X <= Y miscompare" severity error;
    assert not(checknum <= qnanfp)        -- false
      report "Error X <= qnan miscompare" severity error;
    assert not(qnanfp <= checknum2)       -- false
      report "Error qnan <= Y miscompare" severity error;
    assert (checknum2 <= 2.0)           -- true
      report "Error X <= real(X) miscompare" severity error;
    assert not(checknum2 <= 1.0)        -- false
      report "Error X <= real(Y) miscompare" severity error;
    assert (2.0 <= checknum2)           -- true
      report "Error real(X) <= X miscompare" severity error;
    assert (1.0 <= checknum2)           -- false
      report "Error real(X) <= Y miscompare" severity error;
    
    assert not (checknum > checknum)    -- false
      report "Error X > X miscompare" severity error;
    assert (checknum2 > checknum)       -- true
      report "Error Y > X miscompare" severity error;
    assert not(checknum > checknum2)    -- false
      report "Error X > Y miscompare" severity error;
    assert not(checknum > qnanfp)         -- false
      report "Error X > qnan miscompare" severity error;
    assert not(qnanfp > checknum2)        -- false
      report "Error qnan > Y miscompare" severity error;
    assert (checknum2 > 1.0)            -- true
      report "Error X > real(X) miscompare" severity error;
    assert not(checknum2 > 3.0)         -- false
      report "Error X > real(Y) miscompare" severity error;
    assert (3.0 > checknum2)            -- true
      report "Error real(X) > X miscompare" severity error;
    assert not(1.0 > checknum2)         -- false
      report "Error real(X) > Y miscompare" severity error;

    assert not(checknum < checknum)     -- false
      report "Error X < X miscompare" severity error;
    assert not(checknum2 < checknum)    -- false
      report "Error Y < X miscompare" severity error;
    assert (checknum < checknum2)       -- true
      report "Error X < Y miscompare" severity error;
    assert not(checknum < qnanfp)         -- false
      report "Error X < qnan miscompare" severity error;
    assert not(qnanfp < checknum2)        -- false
      report "Error qnan < Y miscompare" severity error;
    assert (checknum2 < 3.0)            -- true
      report "Error X < real(X) miscompare" severity error;
    assert not(checknum2 < 1.0)         -- false
      report "Error X < real(Y) miscompare" severity error;
    assert not(3.0 < checknum2)         -- false
      report "Error real(X) < X miscompare" severity error;
    assert (1.0 < checknum2)            -- true
      report "Error real(X) < Y miscompare" severity error;

    -- Check the "Class" command
    assert (Classfp(zerofp(checknum)) = pos_zero)
      report "Error Class of Zero incorrect" severity error;
    assert (Classfp(neg_zerofp(checknum)) = neg_zero)
      report "Error Class of neg_zero incorrect" severity error;
    assert (Classfp(pos_inffp(checknum)) = pos_inf)
      report "Error Class of infinity incorrect" severity error;
    assert (Classfp(neg_inffp(checknum)) = neg_inf)
      report "Error Class of neg_inf incorrect" severity error;
    assert (Classfp(qnanfp(checknum)) = quiet_nan)
      report "Error Class of quiet_nan incorrect" severity error;
    assert (Classfp(nanfp(checknum)) = nan)
      report "Error Class of signaling nan incorrect" severity error;
    assert (Classfp(to_fp(2)) = pos_normal)
      report "Error Class of normal incorrect" severity error;
    assert (Classfp(to_fp(-2)) = neg_normal)
      report "Error Class of neg incorrect" severity error;
    checknum := to_fp(2.0**(-1025));
    report_error ("to_fp 2**-1025 error",
                  checknum,
                  float64'("0000000000000010000000000000000000000000000000000000000000000000"));
    assert (Classfp(checknum) = pos_denormal)
      report "Error Class of denormal incorrect" severity error;
    checknum := to_fp(-1.0*(2.0**(-1025)));
    checknum1 := "1000000000000010000000000000000000000000000000000000000000000000";
    report_error ("to_fp -2**-1025 error",
                  checknum, checknum1);
    assert (Classfp(checknum) = neg_denormal)
      report "Error Class of neg_denoral incorrect" severity error;
    -- check the copy sign command
    checknum := Copysign (pos_inffp(checknum), neg_zerofp(checknum));
    checknum1 := neg_inffp(checknum);
    report_error ("Error Copysign command incorrect", checknum, checknum1);
    -- test of the resize routines
    checknum32 := (others => '0');
    checknum := to_float64 ( checknum32);
    report_error ("64bit resize +0 miscompare",
                  checknum,
                  zerofp);
    checknum32 := "01000000000000000000000000000000";
    checknum := to_float64 ( checknum32);
    report_error ("64bit resize +2 miscompare",
                  checknum,
                  float64'("0100000000000000000000000000000000000000000000000000000000000000"));
    
    checknum32 := "11000000000000000000000000000000";
    checknum := to_float64 ( checknum32);
    report_error ("64bit resize -2 miscompare",
                  checknum,
                  float64'("1100000000000000000000000000000000000000000000000000000000000000"));
    checknum32 := reverse("00000000000000000001010001000010");
    checknum := to_float64 ( checknum32);
    report_error( "64bit resize 42 miscompare" ,
                  checknum,
                  float64'("0100000001000101000000000000000000000000000000000000000000000000"));
    checknum32 := reverse("00000000000000000000000001111100");
    checknum := to_float64 ( checknum32);
    report_error( "64bit resize .125 miscompare",
                  checknum,
                  float64'("0011111111000000000000000000000000000000000000000000000000000000"));
    checknum32 := reverse("00000000000000000000000100000000");
    checknum := to_float64 ( checknum32);
    report_error( "64bit resize 2**-126 miscompare" ,
                  checknum,
                  float64'("0011100000010000000000000000000000000000000000000000000000000000"));
    checknum32 := reverse("00000000000000000000001000000000");
    checknum := to_float64 ( checknum32);
    report_error( "64bit resize 2**-127 miscompare",
                  checknum,
                  float64'("0011100000000000000000000000000000000000000000000000000000000000"))
      ;
    checknum32 := reverse("10000000000000000000001000000000");
    checknum := to_float64 ( checknum32);
    report_error( "64bit resize 2**-127+ miscompare" ,
                  checknum,
                  float64'("0011100000000000000000000000000001000000000000000000000000000000"));
    checknum32 := reverse("10000000000000000000000000000000");
    checknum := to_float64 ( checknum32);
    report_error ( "64bit resize 2**-149 miscompare",
                   checknum,
                   float64'("0011011010100000000000000000000000000000000000000000000000000000"));
    checknum32 := "01001100000011001011110001001111";
    checknum := to_float64 ( checknum32);
    report_error (  "64bit resize 36892988 miscompare",
                    checknum,
                    float64'("0100000110000001100101111000100111100000000000000000000000000000"));
    checknum32 := "01001100000011001011110001010000";
    checknum := to_float64 ( checknum32);
    report_error ( "64bit resize 36892990 miscompare",
                   checknum,
                   float64'("0100000110000001100101111000101000000000000000000000000000000000"));
    -- Nans, inf, -0
    checknum32 := "10000000000000000000000000000000";  -- -0
    checknum := to_float64 ( checknum32);
    report_error ( "64bit resize -0 miscompare",
                   checknum, - zerofp);
    checknum32 := pos_inffp;  -- +inf
    checknum := to_float64 ( checknum32);
    report_error ( "64bit resize +int miscompare",
                   checknum, pos_inffp);
    checknum32 := neg_inffp;  -- -inf
    checknum := to_float64 ( checknum32);
    report_error ( "64bit resize -int miscompare",
                   checknum, neg_inffp);
    checknum32 := nanfp;  -- nan
    checknum := to_float64 (checknum32);
    fptype := classfp (checknum);
    assert fptype = nan
      report "64bit resize NAN returned " & to_string(checknum)
      severity error;
    checknum32 := qnanfp;  -- qnan
    checknum := to_float64 (checknum32);
    fptype := classfp (checknum);
    assert fptype = quiet_nan
      report "64bit resize NAN returned " & to_string(checknum)
      severity error;
-- Larger to smaller
    checknum32 := to_float32 (zerofp(checknum));
    report_error ( "32bit resize +0 miscompare",
                   checknum32,
                   float32'("00000000000000000000000000000000"));
    checknum := "0100000000000000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize +2 miscompare",
                   checknum32, float32'("01000000000000000000000000000000"));
    checknum := "1100000000000000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize -2 miscompare", checknum32,
                   float32'("11000000000000000000000000000000"));
    checknum := "0100000001000101000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error (  "32bit resize 42 miscompare",
                    checknum32, reverse("00000000000000000001010001000010"));
    checknum := "0011111111000000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize .125 miscompare",
                   checknum32, reverse("00000000000000000000000001111100"));
    checknum := "0011100000010000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error( "32bit resize 2**-126 miscompare",
                  checknum32, reverse("00000000000000000000000100000000"));
    checknum := "0011100000000000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize 2**-127 miscompare",
                   checknum32, reverse("00000000000000000000001000000000"));
    checknum := "0011100000000000000000000000000001000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize 2**-127+ miscompare",
                   checknum32, reverse("10000000000000000000001000000000"));
    checknum := "0011011010100000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize 2**-149 miscompare" ,
                   checknum32, reverse("10000000000000000000000000000000"));
    checknum := "0011011010000000000000000000000000000000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize 2**-150 miscompare" ,
                   checknum32,
                   float32'("00000000000000000000000000000000"));
    checknum := "0100000110000001100101111000100111100000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize 36892988 miscompare",
                   checknum32, float32'("01001100000011001011110001001111"));
    checknum := "0100000110000001100101111000100111110000000000000000000000000000";
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize 36892990 miscompare",
                   checknum32, float32'("01001100000011001011110001010000"));
    -- Nans, inf, -0
    checknum := - zerofp(checknum);  -- -0
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize -0 miscompare",
                   checknum32, float32'("10000000000000000000000000000000"));
    checknum := pos_inffp(checknum);  -- +inf
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize +inf miscompare",
                   checknum32, pos_inffp);
    checknum := neg_inffp(checknum);  -- +inf
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize -inf miscompare",
                   checknum32, neg_inffp);
    checknum := nanfp(checknum);  -- NAN
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize NAN miscompare",
                   to_slv(checknum32),
                   to_slv(qnanfp));
    checknum := qnanfp(checknum);  -- NAN
    checknum32 := to_float32 (checknum);
    report_error ( "32bit resize qNAN miscompare",
                   to_slv(checknum32),
                   to_slv(qnanfp));
    -- Pentium bug test
    checknum := to_fp (4195835.0);
    checknum1 := to_fp (3145727.0);
    checknum2 := checknum / checknum1;
--    checknum3 := to_fp (1.33382);       -- Pentium got 1.33374
    checknum3 := "0011111111110101010101110101010000011100011111000110101101000011";
    report_error ( "Pentium bug test", checknum2, checknum3);
    addloop: for i in 0 to iterations loop     -- Close loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**(expon_base-1);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(expon_base-1);
      checknum1 := to_fp(checkreal);
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_fp(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum := checknum1 + checknum2;
      checknum3 := to_fp( checkreal+checkreal2);
      report_error_loop ("Add loop error",
                         i,
                         checknum,
                         checknum3);
    end loop addloop;
    addloop2: for i in 0 to iterations loop     -- Close loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**(real(expon_base-1)*checkreal-(real(expon_base/2)));
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(real(expon_base-1)*checkreal2-(real(expon_base/2)));
      checknum1 := to_fp(checkreal);
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_fp(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum := checknum1 + checknum2;
      checknum3 := to_fp( checkreal+checkreal2);
      report_error_loop ("Add loop 2 error",
                         i,
                         checknum,
                         checknum3);
    end loop addloop2;
    subloop: for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**(expon_base-1);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(expon_base-1);
      checknum1 := to_fp(checkreal);
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_fp(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum := checknum1 - checknum2;
      checknum3 := to_fp( checkreal - checkreal2);
      report_error_loop ("sub loop error",
                         i,
                         checknum,
                         checknum3);
    end loop subloop;
    multloop: for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**((expon_base-1)/2);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**((expon_base-1)/2);
      checknum1 := to_fp(checkreal);
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_fp(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum := checknum1 * checknum2;
      checknum3 := to_fp( checkreal * checkreal2);
      report_error_loop ("mult loop error",
                         i,
                         checknum,
                         checknum3);
    end loop multloop;
    multloop2: for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**(real((expon_base-1)/2)*checkreal-(real(expon_base/4)));
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(real((expon_base-1)/2)*checkreal2-(real(expon_base/4)));
      checknum1 := to_fp(checkreal);
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_fp(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
--      L := new string'("checknum1 := """);
--      write (L, checknum1);
--      write (L, string'(""";  -- "));
--      write (L, checkreal);
--      writeline (output, L);
--      L := new string'("checknum2 := """);
--      write (L, checknum2);
--      write (L, string'(""";  -- "));
--      write (L, checkreal2);
--      writeline (output, L);
      checknum := checknum1 * checknum2;
      checknum3 := to_fp( checkreal * checkreal2);
      report_error_loop ("mult loop2 error",
                         i,
                         checknum,
                         checknum3);
    end loop multloop2;
    divloop: for i in 0 to iterations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**(expon_base-1);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**((expon_base-1)/2);
      checknum1 := to_fp(checkreal);
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_fp(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum := checknum1 / checknum2;
      checknum3 := to_fp( checkreal / checkreal2);
      report_error_loop ("div loop error",
                         i,
                         checknum,
                         checknum3);
    end loop divloop;

    checknum1 := "1101111111011011111100111010001111100101000010000010111000101011";  -- -5.855801E+153
    checknum2 := "0101111110011110000101010000100101010101110000011001010100111001";  -- 3.938828E+152
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 101", checknum, to_fp(checkreal));

    checknum1 := "1101111111001101001011011101001011010110010101111101101000101111";  -- -3.056456E+153
    checknum2 := "0101111111011010111010111001011011110000100011110110111011111000";  -- 5.639716E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 102", checknum, to_fp(checkreal));

    checknum1 := "1101111111011101110111011010110111010001101010000100010011000110";  -- -6.256823E+153
    checknum2 := "1101111111000111110111001001110010000111111010010110001101001001";  -- -2.499484E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 103", checknum, to_fp(checkreal));

    checknum1 := "0101111111011000111000101110001111101010111000010101001100010011";  -- 5.213603E+153
    checknum2 := "1101111110001011111011001001111011101100110001001111100001110000";  -- -1.828143E+152
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 104", checknum, to_fp(checkreal));

    checknum1 := "0101111111011000001011010000111010001101110011100010110010101010";  -- 5.064800E+153
    checknum2 := "0101111111010000000010110001001011110010000101100001110001101101";  -- 3.361014E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 105", checknum, to_fp(checkreal));
    checknum1 := "1101111101101001110110111111110001101011110100110011101110010011";  -- -4.232383E+151
    checknum2 := "1101111111001001100010001111001011100001101011010100001011001000";  -- -2.674748E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 106", checknum, to_fp(checkreal));
    checknum1 := "1101111111001111110001100011110011110000100001111010111000101000";  -- -3.328317E+153
    checknum2 := "1101111110100111010000010101001010011110101000100110000001011000";  -- -6.089860E+152
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 107", checknum, to_fp(checkreal));
    checknum1 := "1101111111010011101001111000011011011010011111001101100111100101";  -- -4.117538E+153
    checknum2 := "0101111111000010101001110110000000101101100001111011011101110101";  -- 1.953959E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 108", checknum, to_fp(checkreal));
    checknum1 := "0101111110101010110101100111110111111100010001011100100100101111";  -- 7.028064E+152
    checknum2 := "0101111111010100001110010011011110110011111111110111100101000001";  -- 4.236764E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 109", checknum, to_fp(checkreal));
    checknum1 := "0101111111000010000100110000010011001010110000111101111111111011";  -- 1.893255E+153
    checknum2 := "1101111111010001110111110110000111111001011011000100001100110001";  -- -3.744254E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 110", checknum, to_fp(checkreal));
    checknum1 := "0101111111000110010010110101111111100101101100011110100001010001";  -- 2.335308E+153
    checknum2 := "0101111111010000010100001000001101110010011101011101110101100011";  -- 3.417840E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 111", checknum, to_fp(checkreal));
    checknum1 := "1101111111000011111101001100111010110001001000000011000011001001";  -- -2.090390E+153
    checknum2 := "0101111111011000110111101111011010011001110111111000011101011100";  -- 5.210389E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 112", checknum, to_fp(checkreal));
    checknum1 := "0101111111011010011110001011100110001010110110101110100001000100";  -- 5.545717E+153
    checknum2 := "1101111111010111111011001111000010110010001100001101101011010010";  -- -5.012330E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 114", checknum, to_fp(checkreal));
    checknum1 := "1101111111011101100011001001001001111011010000110010110111111001";  -- -6.190450E+153
    checknum2 := "1101111110110101101001100011100110011000111001100110001100000010";  -- -1.133867E+153
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 115", checknum, to_fp(checkreal));
    checknum1 := "0011010000011100111110101111100110110101010011000100001101101011";  -- 1.154210E-57
    checknum2 := "0011101110001000110110101000000011111001010010010110100010001001";  -- 6.578675E-22
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 116", checknum, to_fp(checkreal));
    checknum1 := "0011110000010000111101110000100101000011100110000111100110010111";  -- 2.299184E-19
    checknum2 := "1011011110001101111111011001010010110100000011101010110111111001";  -- -4.303433E-41
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 117", checknum, to_fp(checkreal));
    checknum1 := "1011100110110001111010110110100011100100011001011011001001011110";  -- -8.835030E-31
    checknum2 := "0011111010101000111001111001000100001011010101001101010101010100";  -- 7.422136E-07
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 118", checknum, to_fp(checkreal));
    checknum1 := "0011001100000110110100111000011110100000101110111100010111011000";  -- 6.935954E-63
    checknum2 := "0011110010011100000010011011000111111101101101001111001100100110";  -- 9.727591E-17
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 119", checknum, to_fp(checkreal));
    checknum1 := "0100010101001110111010001100011011110101010001100010011010101110";  -- 7.473407E+25
    checknum2 := "0011110111100000011111111111000001110100100110001010011111001001";  -- 1.200516E-10
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 120", checknum, to_fp(checkreal));
    checknum1 := "0100101101110100000100010101011101110110110011001110001101100110";  -- 3.075372E+55
    checknum2 := "1100101000011001100110011100111110110100100011101111000010101000";  -- -9.353912E+48
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 121", checknum, to_fp(checkreal));
    checknum1 := "0011100000101000100010110110000101010100010010111000111001001011";  -- 3.606483E-38
    checknum2 := "0100100100111010101101011101111110000011111010100100000111111011";  -- 5.956628E+44
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 122", checknum, to_fp(checkreal));
    checknum1 := "0011110100001000100011010011100000011000000001101011101001011001";  -- 1.090312E-14
    checknum2 := "0011101100111110000011001011001011010111100100110110110100000101";  -- 2.485645E-23
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 123", checknum, to_fp(checkreal));
    checknum1 := "0011111011110000101110110011101111101101100100111111000011111010";  -- 1.595629E-05
    checknum2 := "0100100101101000101111110100110111111011100001000111111001000011";  -- 4.415063E+45
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 124", checknum, to_fp(checkreal));
    checknum1 := "0011010111011100101110101111010001110011000110010001001100011101";  -- 3.071572E-49
    checknum2 := "0011100000010010000011001111100111010111100000100111001011111100";  -- 1.326155E-38
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 125", checknum, to_fp(checkreal));
    checknum1 := "0011100010000000011111110011010111101001111101110001111110000100";  -- 1.551363E-36
    checknum2 := "0011101100001110111010101011100110001100011101011010111010011101";  -- 3.196732E-24
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 126", checknum, to_fp(checkreal));
    checknum1 := "1100011011110011011111010011100001011001110100100001001100111010";  -- -6.324588E+33
    checknum2 := "1011010101100111110101010000111110100001011010100001110011000011";  -- -1.990564E-51
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 127", checknum, to_fp(checkreal));
    checknum1 := "1100011010001001110101011000000111100001011000001011110100000110";  -- -6.549700E+31
    checknum2 := "0011110100100100010001100010000010000000001001000110111011100000";  -- 3.601374E-14
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 128", checknum, to_fp(checkreal));
    checknum1 := "1011101011011001011101011110110001010001100001000110110011100101";  -- -3.290710E-25
    checknum2 := "1011110001100101000010101101001011100101111111111001101011111100";  -- -9.125635E-18
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 129", checknum, to_fp(checkreal));
    checknum1 := "0011001101000010001010010001001111100000001000000011110000000100";  -- 8.829126E-62
    checknum2 := "0011110101100000101110001101101010001010010101000110111101010110";  -- 4.752702E-13
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 130", checknum, to_fp(checkreal));
    checknum1 := "0100000100010100111001001111010101000011011110001110101000000111";  -- 3.423333E+05
    checknum2 := "1011001001000001010001101010000011111100000011110101000001011111";  -- -1.281597E-66
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 131", checknum, to_fp(checkreal));
    checknum1 := "0100010010011000101100010010100001100110000011101110011100001100";  -- 2.915120E+22
    checknum2 := "0100100000011010001001110011010011111111111110101001001110111000";  -- 2.224864E+39
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 132", checknum, to_fp(checkreal));
    checknum1 := "1011100010111011111101010111011011010000001110011011101110111010";  -- -2.103390E-35
    checknum2 := "1011011000011011000001101101101110101010000101110010101001001101";  -- -4.623120E-48
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 133", checknum, to_fp(checkreal));
    checknum1 := "1100010100011011101000100101100010101000011101010011011010111100";  -- -8.351914E+24
    checknum2 := "0100001101110010110000000010001010011110011001101101010000110000";  -- 8.444487E+16
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 134", checknum, to_fp(checkreal));
    checknum1 := "0011110000011010100101111100000111101011110111101100001010001110";  -- 3.603997E-19
    checknum2 := "1100010101001011010101111101010110011001110011010011010111110110";  -- -6.611157E+25
    checknum := checknum1 * checknum2;
    checkreal := to_real(checknum1) * to_real(checknum2);
    report_error ("Mult loopcheck 135", checknum, to_fp(checkreal));
    -- Subtract boundary test
    start_sbtest <= true;
    wait until sbtest_done;
    
    assert (false) report "fphdl64_pkg testing complete" severity note;
    wait;
  end process Test_process;

  -- purpose: subtraction boundary test
  -- These test catch sticky bit errors.
  sbtest: process is
    variable ck1, ck2, ck3, ck4, ck5 : float64;
    variable ckr1, ckr2, ckr3 : REAL;
  begin
    wait until start_sbtest;
    ckr1 := 1.0/3.0;
    ck1 := to_float (ckr1, ck1'high, -ck1'low);
    for i in -45 downto -55 loop
      ck2 := scalb (ck1, i);
      ckr2 := to_real (ck2);
      ck3 := ck1 - ck2;
      ckr3 := ckr1 - ckr2;
      ck4 := to_float (ckr3, ck4'high, -ck4'low);
      report_error (integer'image(i) & " subtraction boundary real", ck3, ck4);
    end loop;
--d5120ba3 5fb8661a 0 5fb86616 5fb86615 zzzzzzzz 00100000
    ck1 := from_hstring ("000b8661a0b8661a", ck1'high, -ck1'low);
    ckr1 := to_real (ck1);
    ck5 := from_hstring ("100120ba30120ba3", ck5'high, -ck5'low);
    for i in -45 downto -60 loop
      ck2 := scalb (ck5, i);
      ckr2 := to_real (ck2);
      ck3 := ck1 + ck2;
      ckr3 := ckr1 + ckr2;
      ck4 := to_float (ckr3, ck4'high, -ck4'low);
      report_error (integer'image(i) & " A subtraction boundary real", ck3, ck4);
    end loop;
--3d1a52a4 38326219 0 3d1a7f3c 3d1a7f3d zzzzzzzz 00100000
    ck1 := from_hstring ("0F21a52a401a52a4", ck1'high, -ck1'low);
    ckr1 := to_real (ck1);
    ck5 := from_hstring ("0F23262190326219", ck5'high, -ck5'low);
    for i in -45 downto -60 loop
      ck2 := scalb (ck5, i);
      ckr2 := to_real (ck2);
      ck3 := ck1 + ck2;
      ckr3 := ckr1 + ckr2;
      ck4 := to_float (ckr3, ck4'high, -ck4'low);
      report_error (integer'image(i) & " B subtraction boundary real", ck3, ck4);
    end loop;
--82a388c2 8dcf6c9e 0 8dcf6ca0 8dcf6ca1 zzzzzzzz 00100000
    ck1 := from_hstring ("0d0cf6c9e0cf6c9e", ck1'high, -ck1'low);
    ckr1 := to_real (ck1);
    ck5 := from_hstring ("0d0a388c20a388c2", ck5'high, -ck5'low);
    for i in -45 downto -60 loop
      ck2 := scalb (ck5, i);
      ckr2 := to_real (ck2);
      ck3 := ck1 + ck2;
      ckr3 := ckr1 + ckr2;
      ck4 := to_float (ckr3, ck4'high, -ck4'low);
      report_error (integer'image(i) & " C subtraction boundary real", ck3, ck4);
    end loop;
--774710a0 ec24e7d8 0 7747109e 7747109d zzzzzzzz 00100000
    ck1 := from_hstring ("0d04710a004710a0", ck1'high, -ck1'low);
    ckr1 := to_real (ck1);
    ck5 := from_hstring ("0d024e7d8024e7d8", ck5'high, -ck5'low);
    for i in -45 downto -60 loop
      ck2 := scalb (ck5, i);
      ckr2 := to_real (ck2);
      ck3 := ck1 + ck2;
      ckr3 := ckr1 + ckr2;
      ck4 := to_float (ckr3, ck4'high, -ck4'low);
      report_error (integer'image(i) & " D subtraction boundary real", ck3, ck4);
    end loop;
    assert (quiet) report "Subtraction boundary test completed" severity note;
    sbtest_done <= true;
  end process sbtest;
end architecture testbench;
