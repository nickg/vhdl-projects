-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the "fphdl_pkg" package.
-- This is a comprehensive test for all of the routines in this package
-- Last Modified: $Date: 2007-09-11 15:31:23-04 $
-- RCS ID: $Id: test_fp32.vhdl,v 1.8 2007-09-11 15:31:23-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_fp32 is
  generic (
    quiet : BOOLEAN := false);          -- run quietly
end entity test_fp32;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;
use ieee.float_pkg.all;
use std.textio.all;
use ieee.std_logic_textio.all;
architecture testbench of test_fp32 is
  constant fp_exponent_width : integer := float32'high;  -- compatibility
  constant fp_fraction_width : integer := -float32'low;  -- compatibility
  constant expon_base  : integer := 2**(fp_exponent_width-1) -1;  -- highest exponent
  signal f32 : float32;                    -- signal
  subtype  float32_slv is std_logic_vector
    (fp_exponent_width + fp_fraction_width downto 0);  -- SLV version of float32

    -- purpose: reports an error
  procedure report_error (
    constant errmes : in string;        -- error message
    actual          : in float;          -- data from algorithm
    expected        : in float32)  is      -- reference data
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
    constant errmes : in string;        -- error message
    actual          : in ufixed;        -- data from algorithm
    expected        : in ufixed)  is    -- reference data
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
  -- Needed to compare strings with meta values in them.
  procedure report_error (
    constant errmes : in string;                -- error message
    actual          : in std_logic_vector;      -- data from algorithm
    expected        : in std_logic_vector)  is  -- reference data
    variable L : line;
  begin  -- function report_error
    if actual /= expected then
      report errmes severity error;
      L := new string'("Actual   ");
      write (L, actual);
      write (L, string'(" /= "));
      writeline (output, L);
      L := new string'("Expected ");
      write (L, expected);
      writeline (output, L);
    end if;
    return;
  end procedure report_error;

  -- This version is more forgiving of rounding errors.
  procedure report_error_loop (
    constant errmes : in string;        -- error message
    iteration       : in integer;
    actual          : in float;          -- data from algorithm
    expected        : in float)  is      -- reference data
--    variable fract1, fract2 : float32;     -- fract
  begin  -- function report_error
    if actual /= expected then
--      fract1 := nextafter (expected, pos_inffp);
--      fract2 := nextafter (expected, neg_inffp);
--      if (actual /= fract1) and (actual /= fract2) then
        report errmes & " " & integer'image(iteration) & CR &
          "Actual   " & to_string (actual) & " ("
          & real'image(to_real(actual))& ") /= " & CR &
          "Expected " & to_string (expected) & " ("
          & real'image(to_real(expected))& ")"
          severity error;
--      end if;
    end if;
    return;
  end procedure report_error_loop;

  signal start_readtest, readtest_done     : boolean := false;  -- start reading test
  signal start_comptest, comptest_done     : boolean := false;  -- start reading test
  signal start_nexttest, nexttest_done     : boolean := false;  -- start reading test
  signal start_divmodtest, divmodtest_done : BOOLEAN := false;  -- divmod test
  signal start_looptest, looptest_done     : boolean := false;  -- loop test
  signal start_looptest2, looptest2_done   : boolean := false;  -- loop test
  signal start_fixedtest, fixedtest_done   : BOOLEAN := false;  -- fixed point test
  signal start_normtest, normtest_done     : BOOLEAN := false;  -- normalize test
  signal start_naninftest, naninftest_done : BOOLEAN := false;  -- nan and infinity test
  signal start_sbtest, sbtest_done : BOOLEAN := false;  -- subtract boundard test
begin  -- architecture testbench

  -- purpose: Checks the conversion functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Test_process : process is

    variable checknum    : float32;        -- Floating point output
    variable checknum1   : float32;        -- Floating point output
    variable checknum2   : float32;        -- Floating point output
    variable checknum3   : float32;        -- Floating point output
    variable checkint    : integer;     -- integer test
    variable checkreal   : real;        -- real test
    variable checkuns    : unsigned (15 downto 0);  -- unsigned test
    variable checkuns2   : unsigned (15 downto 0);  -- unsigned test
    variable checkuns32  : unsigned (31 downto 0);
    variable checkuns32x : unsigned (31 downto 0);
    variable checksign   : signed (fp_exponent_width - 1 downto 0);  -- check of signed
    variable checksignx  : signed (fp_exponent_width - 1 downto 0);  -- check of SIGNED
    variable checks : SIGNED (7 downto 0);
    variable checkunsx : UNSIGNED (6 downto 0);
  begin  -- process Test_process
    checknum  := "00000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 0) report "+0 test miscompare" severity error;
    checknum  := "10000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 0) report "-0 test miscompare" severity error;
    checknum  := "01000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 2) report "2 test miscompare" severity error;
    checknum  := "11000000000000000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = -2) report "-2 test miscompare" severity error;
    checknum  := "01000000000000000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = 2.0) report "2.0 test miscompare" severity error;
    checknum  := "01000000110100000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = 6.5) report "6.5 test miscompare" severity error;
    checknum  := "11000000110100000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = -6.5) report "-6.5 test miscompare" severity error;
    checknum  := "00111110000000000000000000000000";                 -- 0.125
    checkreal := to_real (checknum);
    assert (checkreal = 0.125) report "0.125 test miscompare" severity error;
    checknum  := "01000010001010000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 42) report "42 test miscompare" severity error;
    checknum  := "00000000100000000000000000000000";                 -- 2**-126
    checkreal := to_real (checknum);
    assert (checkreal = 2.0**(-126)) report "2**-126 test miscompare"
      severity error;

    checknum  := "01111111011100000000000000000000";  -- 1.875*(2**127)
    checkreal := to_real (checknum);
    assert (checkreal = (1.875*(2.0**127))) report "3.19E38 test miscompare"
      severity error;
    -- Extended floating point test
    checknum  := "00000000010000000000000000000000";  -- 2**-127
    checkreal := to_real (checknum);
    assert (checkreal = 2.0**(-127)) report "2**-127 test miscompare"
      severity error;
    checknum  := "00000000000000000000000000000001";  -- 2**-149, smallest
    checkreal := to_real (checknum);
    assert (checkreal = 2.0**(-149)) report "2**-149 test miscompare"
      severity error;
    checknum  := "01000000110100000000000000000000";
    checkint  := to_integer (checknum);
    assert (checkint = 6)
      report "Integer 6.5 = 7 miscompare " & integer'image(checkint)
      severity error;
    checknum := "11000000110100000000000000000000";
    checkint := to_integer (checknum);
    assert (checkint = -6)
      report "Integer -6.5 = -7 test miscompare " & integer'image(checkint)
      severity error;
    checknum := "10111111011000000000000000000000";   -- -0.875
    checkint := to_integer (checknum);
    assert (checkint = -1)
      report "Integer -0.875 = -1 test miscompare " & integer'image(checkint)
      severity error;
    checknum := "01000000010010010000111111011011";   -- PI
    checkint := to_integer (checknum);
    assert (checkint = 3)
      report "Integer PI = 3 test miscompare " & integer'image(checkint)
      severity error;
    checknum := "01000000001011011111100001010100";   -- E
    checkint := to_integer (checknum);
    assert (checkint = 3)
      report "Integer E = 3 test miscompare " & integer'image(checkint)
      severity error;

    checknum := "01001100000011001011110001001111";  -- 36892987
    checkint := to_integer (arg => checknum);
    assert (checkint = 36892988)        -- nearest 36892987
      report "36892987 miscompare " & integer'image(checkint) severity error;
    checknum := "01001100000011001011110001010000";
    checkint := to_integer (arg => checknum);
    assert (checkint = 36892992)        -- nearest 36892990
      report "36892990 miscompare " & integer'image(checkint) severity error;
--  checknum := "01001110100000000000000000000000";  -- Maximum integer
    checknum := "01001110111111111111111111111111";  -- Maximum integer
    checkint := to_integer(checknum);
    assert (checkint = 2147483520)    -- maximum integer in 32 bit FP mode
      report "2**31 miscompare " & integer'image(checkint) severity error;
    ---------------------------------------------------------------------------
    -- Perform the read test
    ---------------------------------------------------------------------------
    start_readtest <= true;
    wait until readtest_done;

    -- Check to integer to floating point conversion
    checkint := 0;
    checknum := to_float (checkint);
    report_error ("FP +0 miscompare",
                  checknum,
                  zerofp);
    checkint := 2;
    checknum := to_float (checkint);
    report_error ("FP +2 miscompare",
                  checknum,
                  "01000000000000000000000000000000");
    checkint := -2;
    checknum := to_float (checkint);
    report_error ("FP -2 miscompare",
                  checknum,
                  "11000000000000000000000000000000");
    checkreal := 6.5;
    checknum  := to_float(checkreal);
    report_error ("FP 6.5 miscompare",
                  checknum,
                  "01000000110100000000000000000000");
    checkreal := -6.5;
    checknum  := to_float(checkreal);
    report_error ("FP -6.5 miscompare",
                  checknum,
                  "11000000110100000000000000000000");
    checkreal := 0.125;
    checknum  := to_float(checkreal);
    report_error ("FP 0.125 miscompare",
                  checknum,
                  "00111110000000000000000000000000");
    checkint := 42;
    checknum := to_float (checkint);
    report_error ("FP 42 miscompare",
                  checknum,
                  "01000010001010000000000000000000");
    checkreal := 2.0**(-126);
    checknum  := to_float(checkreal);
    report_error ("FP 2**-126 miscompare",
                  checknum,
                  "00000000100000000000000000000000");  -- 2**-126
    checkreal := (1.875*(2.0**127));
    checknum  := to_float(checkreal);
    report_error ("FP 1.875*(2**127) miscompare",
                  checknum,
                  "01111111011100000000000000000000");  -- 1.875*(2**127)
    checkreal := 2.0**128;
    checknum  := to_float(checkreal);
    report_error ("+infinity miscompare",
                  checknum,
                  pos_inffp);
    -- Signed and unsigned
    checksign := to_signed (-42, checksign'high + 1);
    checknum  := to_float(checksign);
    report_error ("FP signed -42 miscompare",
                  checknum,
                  "11000010001010000000000000000000");
    checkuns := to_unsigned (42, checkuns'high + 1);
    checknum := to_float(checkuns);
    report_error ("FP unsigned 42 miscompare",
                  checknum,
                  "01000010001010000000000000000000");
    checkuns := to_unsigned (42, checkuns'length);
    checknum := to_float(checkuns);
    report_error ("FP unsigned size_res 42 miscompare",
                  checknum,
                  "01000010001010000000000000000000");
    checkuns := to_unsigned (pos_inffp, checkuns'high + 1);
    assert (checkuns = unsigned'("1111111111111111"))
      report "to_unsigned overflow" severity error;
    checkuns := "1000000000000001";
    checknum := to_float (checkuns);
    report_error ("FP 32769 miscompare",
                  checknum,
                  "01000111000000000000000100000000");
    checkuns := (others => '0');
    checkuns (3) := '1';                -- 8
    checknum := to_float (checkuns(checkuns'high downto 3));  -- a slice.
    report_error ("fp UNSIGNED slice", checknum,
                  to_float (1));
    checkunsx := "1111111";             -- 127
    checknum := to_float (checkunsx);
    report_error ("to_float (UNSIGNED 127)", checknum, to_float(127));
    checkunsx := "1111110";             -- 126
    checknum := to_float (checkunsx);
    report_error ("to_float (UNSIGNED 126)", checknum, to_float(126));    
    -- signed
    checksign := (others => '0');
    checksign (3) := '1';                -- 8
    checknum := to_float (checksign(checksign'high downto 3));  -- a slice.
    report_error ("fp SIGNED slice", checknum,
                  to_float (1));
    checksign := to_signed (pos_inffp, checksign'high + 1);
    assert (checksign = signed'("01111111"))
      report "to_signed overflow" severity error;
    checksign := to_signed (neg_inffp, checksign'high + 1);
    assert (checksign = signed'("10000000"))
      report "to_signed underflow" severity error;
    checksign := to_signed (pos_inffp, checksign);
    assert (checksign = signed'("01111111"))
      report "to_signed size_res overflow" severity error;
    checksign := to_signed (neg_inffp, checksign);
    assert (checksign = signed'("10000000"))
      report "to_signed size_res underflow" severity error;
    checks := "00000000";
    checknum := to_float (checks);
    report_error ("to_float (SIGNED 0)", checknum, to_float(0));
    checks := "00000001";
    checknum := to_float (checks);
    report_error ("to_float (SIGNED 1)", checknum, to_float(1));
    checks := "11111111";
    checknum := to_float (checks);
    report_error ("to_float (SIGNED -1)", checknum, to_float(-1));
    checks := "01111111";               -- 127
    checknum := to_float (checks);
    report_error ("to_float (SIGNED +max)", checknum, to_float(127));
    checks := "10000000";               -- -128
    checknum := to_float (checks);
    report_error ("to_float (SIGNED -max)", checknum, to_float(-128));
    checks := "10000001";               -- -127
    checknum := to_float (checks);
    report_error ("to_float (SIGNED -max+1)", checknum, to_float(-127));
    -- go the other way and check the bound
    checknum := to_float (127);
    checks := to_signed (checknum, checks'length);
    assert (checks = "01111111")        -- 127
      report "to_float(127) wrong result " & INTEGER'image(to_integer(checks))
      severity error;
    checknum := to_float (-127);
    checks := to_signed (checknum, checks'length);
    assert (checks = "10000001")        -- -127
      report "to_float(-127) wrong result " & INTEGER'image(to_integer(checks))
      severity error;
    checknum := to_float (-128);
    checks := to_signed (checknum, checks'length);
    assert (checks = "10000000")        -- -128
      report "to_float(-128) wrong result " & INTEGER'image(to_integer(checks))
      severity error;
    -- Integers greater than 32 bits.
--    checknum := "01001111101001011010010110100101";     -- Integer overflow
--    checkint := to_integer (checknum);
--    assert (checkint = 5558192640)
--      report "Integer overflow error " & integer'image(checkint)
--      severity error;
--    checknum := "01010000000000000000000000000000";     -- Integer overflow
--    checkint := to_integer (checknum);
--    assert (checkint = integer'high)
--      report "Integer overflow error " & integer'image(checkint)
--      severity error;
    checknum   := "01010000000000000000000000000000";   -- 50000000 exp= 33
    checkuns32 := to_unsigned (checknum, checkuns32'length);
    assert (checkuns32 = unsigned'("11111111111111111111111111111111"))
      report "to_unsigned 2*33 overflow not detected"
      severity error;
    checknum   := "01001111101001011010010110100101";   -- 4fa5a5a5, exp=32
    checkuns32 := to_unsigned (checknum, checkuns32'length);
    assert (checkuns32 = unsigned'("11111111111111111111111111111111"))
      report "to_unsigned 2*32 overflow not detected" severity error;
    
    checkint := 36892987;                               -- comes out uneven
    checknum := to_float (checkint);
    report_error ("FP 36892987 miscompare",
                  checknum,
                  "01001100000011001011110001001111");
    checkint := 36892990;
    checknum := to_float (checkint);
    report_error ("FP 36892990 miscompare",
                  checknum,
                  "01001100000011001011110001010000");
    checkreal := 36892987.0;                            -- comes out uneven
    checknum  := to_float (checkreal);
    report_error ("FP real 36892987.0 miscompare",
                  checknum,
                  "01001100000011001011110001001111");
    checkreal := 36892990.0;
    checknum  := to_float (checkreal);
    report_error ("FP real 36892990.0 miscompare",
                  checknum,
                  "01001100000011001011110001010000");
    checkint := 2147483645;
    checknum := to_float (checkint);
    report_error ("FP maxint -2 miscompare",
                  checknum,
                  "01001111000000000000000000000000");
    checkreal := 2147483645.0;
    checknum  := to_float (checkreal);
    report_error ("FP real maxint -2 miscompare",
                  checknum,
                  "01001111000000000000000000000000");
    -- Extended floating point test
    checkreal := 2.0**(-127);
    checknum  := to_float(checkreal);
    report_error ("FP 2**-127 miscompare",
                  checknum,
                  "00000000010000000000000000000000");
    checkreal := 2.0**(-149);
    checknum  := to_float(checkreal);
    report_error ("FP 2**-149 miscompare",
                  checknum,
                  "00000000000000000000000000000001");
    checkreal := 0.875;
    checknum  := to_float(checkreal);
    report_error ("FP 0.875 miscompare",
                  checknum,
                  "00111111011000000000000000000000");  -- 0.875
    checkreal := -0.875;
    checknum  := to_float(checkreal);
    report_error ("FP -0.875 miscompare",
                  checknum,
                  "10111111011000000000000000000000");  -- -0.875
    checknum := to_float(MATH_PI);
    report_error ("FP PI miscompare",
                  checknum,
                  "01000000010010010000111111011011");  -- PI
    checknum := to_float(MATH_E);
    report_error ("FP E miscompare",
                  checknum,
                  "01000000001011011111100001010100");  -- E
    checknum := to_float(MATH_RAD_TO_DEG);
    report_error ("FP RAD_to_DEG miscompare",
                  checknum,
                  "01000010011001010010111011100001");
    checknum := to_float (1.0/3.0);
    report_error ("FP 1/3 miscompare",
                  checknum,
                  "00111110101010101010101010101011");  -- 1/3
    checkint := 36892987;                               -- comes out uneven
    checknum := to_float (checkint);
    report_error ("FP 36892987 miscompare",
                  checknum,
                  "01001100000011001011110001001111");
    checkint := 36892990;
    checknum := to_float (checkint);
    report_error ("FP 36892990 miscompare",
                  checknum,
                  "01001100000011001011110001010000");

    -- Check some basic math functions
    checknum2 := "11000000110100000000000000000000";    -- -6.5
    checknum  := abs (checknum2);
    checknum1 := "01000000110100000000000000000000";    -- 6.5
    report_error ("abs -6.5 test miscompare", checknum, checknum1);
    -- Check some basic math functions
    checknum2 := "11000000110100000000000000000000";    -- -6.5
    checknum  := - checknum2;
    checknum1 := "01000000110100000000000000000000";    -- 6.5
    report_error ("neg -6.5 test miscompare", checknum, checknum1);
    checknum3 := "01000010001010000000000000000000";    -- 42
    checknum  := - checknum3;
    assert (to_signed(checknum, 10) = -42)
      report "neg 42 test miscompare" severity error;
    checknum  := "01000000110100000000000000000000";    -- 6.5
    checknum2 := checknum3 + checknum;                  -- 42 + 6.5
    assert (to_real(checknum2) = 48.5)
      report "Add 42 + 6.5 test miscompare" severity error;
    checknum2 := checknum + checknum3;                  -- 6.5 + 42
    assert (to_real(checknum2) = 48.5)
      report "Add 6.5 + 42 test miscompare" severity error;
    checknum2 := checknum3 - checknum;                  -- 42 - 6.5
    assert (to_real(checknum2) = 35.5)
      report "subtract 42 - 6.5 test miscompare" severity error;
    checknum2 := checknum3 * checknum;                  -- 42 * 6.5
    assert (to_integer(checknum2) = 273)
      report "mult 42 * 6.5 test miscompare" severity error;
    checknum2 := checknum * checknum3;                  -- 6.5 * 42
    assert (to_integer(checknum2) = 273)
      report "mult 6.5 * 42 test miscompare" severity error;
    checknum := checknum2 / checknum3;                  -- 273 / 42
    report_error ("div 273 / 42 test miscompare",
                  checknum,
                  "01000000110100000000000000000000");  -- 6.5
    ---------------------------------------------------------------------------
    -- Perform the compare test
    ---------------------------------------------------------------------------
    start_comptest  <= true;
    wait until comptest_done;
    start_fixedtest <= true;
    wait until fixedtest_done;

    -- Check the Scalb command
    checknum  := "11000000110100000000000000000000";       -- -6.5
    checknum2 := Scalb (checknum, 1);
    checknum3 := to_float(-13);
    report_error ("Scalb (-6.5, 1) incorrect",
                  checknum2,
                  checknum3);
    checksign := to_signed (-1, checksign'high + 1);
    checknum2 := Scalb (checknum, checksign);
    checknum3 := to_float(-3.25);
    report_error ("Scalb (-6.5, -1) incorrect",
                  checknum2,
                  checknum3);
    checknum  := "00000000000000000000000000000001";       -- Smallest
    checknum2 := Scalb (checknum, 1);
    checknum3 := "00000000000000000000000000000010";
    report_error ("Scalb (2*-149, 1) incorrect",
                  checknum2,
                  checknum3);
    checknum2 := Scalb (checknum, -1);
    report_error ("Scalb (2*-149, -1) incorrect",
                  checknum2,
                  zerofp);
    checknum  := "00000000100000000000000000000000";       -- 2**-126
    checknum2 := Scalb (checknum, -1);
    report_error ("Scalb (2*-126, -1) (normal to denormal) incorrect",
                  checknum2,
                  "00000000010000000000000000000000");     -- 2**-127
    checknum  := "00000000010000000000000000000000";       -- 2**-127
    checknum2 := Scalb (checknum, -1);
    report_error ("Scalb (2*-127, -1) (denormal to normal) incorrect",
                  checknum2,
                  "00000000001000000000000000000000");     -- 2**-128
    checknum  := "00000000001000000000000000000000";       -- 2**-128
    checknum2 := Scalb (checknum, -1);
    report_error ("Scalb (2*-128, -1) (denormal to denormal) incorrect",
                  checknum2,
                  "00000000000100000000000000000000");     -- 2**-129
    checknum       := "11000000110100000000000000000000";  -- -6.5
    checkint       := Logb (checknum);
    assert (checkint = 2) report "Logb(-6.5) error" severity error;
    checksign      := Logb (checknum);
    assert (checksign = 2) report "Logb(-6.5) error" severity error;
    checknum       := "00000000100000000000000000000000";  -- 2**-126
    checkint       := Logb (checknum);
    assert (checkint = -126) report "Logb (2**-126) error" severity error;
    checknum       := "00000000010000000000000000000000";  -- 2**-127
    checkint       := Logb (checknum);                     -- 2**-127
    assert (checkint = -127) report "Logb(2**-127) error" severity error;
    checknum       := "00000000000000000000000000000001";
    checkint       := Logb (checknum);                     -- 2**-149
    assert (checkint = -149) report "Logb(2**-149) error" severity error;
    ---------------------------------------------------------------------------
    -- Run the test on the "nextafter" routine
    ---------------------------------------------------------------------------
    start_nexttest <= true;
    wait until nexttest_done;

    ---------------------------------------------------------------------------
    -- Math test
    ---------------------------------------------------------------------------
    checknum  := "01000000110100000000000000000000";    -- 6.5
    checknum2 := "01000000110100000000000000000000";    -- 6.5
    checknum3 := checknum + checknum2;
    report_error ("Add 13 miscompare",
                  checknum3,
                  "01000001010100000000000000000000");  -- 13

    checknum  := "01000010001010000000000000000000";    -- 42
    checknum2 := "00111110000000000000000000000000";    -- 0.125
    checknum3 := checknum + checknum2;
    report_error ("Add 4.125 miscompare",
                  checknum3,
                  "01000010001010001000000000000000");  -- 42.125
    checknum3 := checknum2 + checknum;
    report_error ("Add 4.125 rev miscompare",
                  checknum3,
                  "01000010001010001000000000000000");  -- 4.125
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum  := "01000000110100000000000000000000";    -- 6.5
    checknum3 := checknum + checknum2;                  -- 42 + 6.5
    report_error ("Add 42 + 6.5 miscompare",
                  checknum3,
                  "01000010010000100000000000000000");  -- 48.5
    checknum3 := checknum2 + checknum;                  -- 42 + 6.5
    report_error ("Add 6.5 + 42 miscompare",
                  checknum3,
                  "01000010010000100000000000000000");  -- 48.5
    checknum  := "00000000111111111111111111111111";    -- 2**-126++
    checknum3 := checknum + checknum;
    report_error ("Add 2**-126++ miscompare",
                  checknum3,
                  "00000001011111111111111111111111");  -- 2**-123++
    checknum  := "01000000110100000000000000000000";    -- 6.5
    checknum2 := "11000000110100000000000000000000";    -- -6.5
    checknum3 := checknum + checknum2;
    report_error ("Add 6.5-6.5 miscompare",
                  checknum3,
                  zerofp);
    checknum  := zerofp;
    checknum2 := from_hstring ("3F800000");  --1
    checknum3 := checknum + checknum2;
    report_error (to_hstring (checknum) & " + " & to_hstring(checknum2),
                  checknum3, checknum2);
    checknum  := zerofp;
    checknum2 := from_hstring ("007FFFFF");  -- denormal
    checknum3 := checknum + checknum2;
    report_error (to_hstring (checknum) & " + " & to_hstring(checknum2),
                  checknum3, checknum2);
    checknum  := from_hstring ("BF800000");  -- -1
    checknum2 := from_hstring ("3F800000");  -- 1
    checknum3 := checknum + checknum2;
    report_error (to_hstring (checknum) & " + " & to_hstring(checknum2),
                  checknum3, zerofp);
    checknum  := from_hstring ("80000000");  -- -0
    checknum2 := from_hstring ("BF800000");  -- -1
    checknum3 := checknum + checknum2;
    report_error (to_hstring (checknum) & " + " & to_hstring(checknum2),
                  checknum3, checknum2);
 
    -- mixed parameter test
    checknum  := "01000010001010000000000000000000";    -- 42
    checknum3 := checknum + 6.5;
    report_error ("Add 42 + real(6.5) miscompare",
                  checknum3,
                  "01000010010000100000000000000000");  -- 48.5
    checknum  := "01000010001010000000000000000000";    -- 42
    checknum3 := 6.5 + checknum;
    report_error ("Add real (6.5) + 42 miscompare",
                  checknum3,
                  "01000010010000100000000000000000");  -- 48.5
    checknum  := "00111110000000000000000000000000";    -- 0.125
    checknum3 := checknum + 42;
    report_error ("Add 0.125 + int(42) miscompare",
                  checknum3,
                  "01000010001010001000000000000000");  -- 42.125
    checknum  := "00111110000000000000000000000000";    -- 0.125
    checknum3 := 42 + checknum;
    report_error ("Add int(42) + 0.125 miscompare",
                  checknum3,
                  "01000010001010001000000000000000");  -- 42.125
    checknum  := "00111110000000000000000000000000";    -- 0.125
    checkuns  := to_unsigned (42, checkuns'high + 1);
    checknum3 := checknum + to_float(checkuns);
    report_error ("Add 0.125 + unsigned(42) miscompare",
                  checknum3,
                  "01000010001010001000000000000000");  -- 42.125
    checkuns  := to_unsigned (42, checkuns'high + 1);
    checknum3 := to_float(checkuns) + checknum;
    report_error ("Add unsigned(42) + 0.125  miscompare",
                  checknum3,
                  "01000010001010001000000000000000");  -- 42.125
    checknum  := to_float(42);
    checksign := to_signed (-42, checksign'high + 1);
    checknum3 := checknum + to_float(checksign);
    report_error ("Add 42 + signed(-42) miscompare",
                  checknum3,
                  zerofp);
    checknum  := to_float(42);
    checksign := to_signed (-42, checksign'high + 1);
    checknum3 := to_float(checksign) + checknum;
    report_error ("Add signed(-42) + 42 miscompare",
                  checknum3,
                  zerofp);
    checknum  := from_hstring ("41AAAAAA");
    checknum1  := "01000001101010101010101010101010";  -- overflow patterns
    report_error ("from_hstring(41AAAAAA)", checknum, checknum1);
    checknum := from_hstring ("412AAAAB");
    checknum1 := "01000001001010101010101010101011";
    report_error ("from_hstring(412AAAAB)", checknum, checknum1);
    checknum  := "01000001101010101010101010101010";  -- overflow patterns
    checknum2 := "01000001001010101010101010101011";
    checknum3 := checknum + checknum2;
    checknum2 := "01000010000000000000000000000000";
    report_error ("add pattern overflow test", checknum3, checknum2);
                  
    -- denormal test
    checknum  := "00000000111111111111111111111111";    -- 2**-126++
    checknum3 := checknum - checknum;
    report_error ("Add 2**-126++ - 2**-126++ miscompare",
                  checknum3,
                  zerofp);
    checknum  := "00000000010000000000000000000001";    -- 2**-127+
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := checknum + checknum2;
    report_error ("Add 2**-126 miscompare (denormal to normal)",
                  checknum3,
                  "00000000100000000000000000000001");  -- 2**-126+
    checknum  := "00000000010000000000000000000000";    -- 2**-127
    checknum2 := "00000000000000000000000000000001";    -- 2**-149
    checknum3 := checknum + checknum2;
    report_error ("Add 2**-127+ miscompare",
                  checknum3,
                  "00000000010000000000000000000001");  -- 2**-127+
    checknum  := "00000000100000000000000000000000";    -- 2**-126
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := checknum - checknum2;
    report_error ("Add 2**-126 - 2**-127 (normal to denormal) miscompare",
                  checknum3,
                  "00000000010000000000000000000000");  -- 2**-127
    checknum  := "00000000011111111111111111111111";    -- largest denormal
    checknum2 := "00000000000000000000000000000001";    -- 2**-149
    checknum3 := checknum + checknum2;
    report_error ("largest denormal + smallest denormal miscompare",
                  checknum3,
                  "00000000100000000000000000000000");
    checknum  := "00000000000000000000000000000001";    -- 2**-149
    checknum2 := "00111111000000000000000000000000";    -- 0.5
    checknum3 := checknum * checknum2;
    report_error ("2**-149 * 0.5 miscompare",
                  checknum3,
                  zerofp);

    checknum  := pos_inffp;
    checknum2 := "00000000000000000000000000000001";  -- 2**-149
    checknum3 := checknum + checknum2;
    report_error ("infinity+ miscompare",
                  checknum3,
                  pos_inffp);
    checknum  := pos_inffp;
    checknum2 := "00000000000000000000000000000001";  -- 2**-149
    checknum3 := checknum2 + checknum;
    report_error ("+infinity miscompare",
                  checknum3,
                  pos_inffp);
    checknum  := neg_inffp;
    checknum2 := "00000000000000000000000000000001";  -- 2**-149
    checknum3 := checknum + checknum2;
    report_error ("neginfinity+ miscompare",
                  checknum3,
                  neg_inffp);
    checknum  := neg_inffp;
    checknum2 := "00000000000000000000000000000001";  -- 2**-149
    checknum3 := checknum2 + checknum;
    report_error ("+neginfinity miscompare",
                  checknum3,
                  neg_inffp);

    checknum  := "00111110101010101010101010101011";    -- 1/3
    checknum2 := "01000000000000000000000000000000";    -- 2
    checknum3 := checknum + checknum2;
    report_error ("Add 2.333 miscompare",
                  checknum3,
                  "01000000000101010101010101010101");  -- 2.333333
    checknum3 := checknum2 + checknum;
    report_error ("Add 2.333 rev miscompare",
                  checknum3,
                  "01000000000101010101010101010101");  -- 2.333333
    checknum  := "00111110101010101010101010101011";    -- 1/3
    checknum2 := "01000000100000000000000000000000";    -- 4
    checknum3 := checknum + checknum2;
    -- possible rounding problem here
    report_error ("Add 4.333 miscompare",
                  checknum3,
                  "01000000100010101010101010101011");  -- 4.333333
    checknum  := "00000000100000000000000000000001";    -- 2**-126
    checknum2 := "01000000100000000000000000000001";    -- 4
    checknum3 := checknum + checknum2;
    report_error ("Add 4 + miscompare",
                  checknum3,
                  "01000000100000000000000000000001");  -- 4
    checknum3 := zerofp + zerofp;       -- 0 + 0
    report_error ("Add 0 + 0 miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum3 := neg_zerofp + zerofp;   -- -0 + 0
    report_error ("Add -0 + 0 miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum3 := zerofp + neg_zerofp;   -- 0 + -0
    report_error ("Add 0 + -0 miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum3 := neg_zerofp + neg_zerofp;   -- -0 + -0
    report_error ("Add -0 + -0 miscompare",
                  to_slv(checknum3),
                  to_slv(neg_zerofp));              -- -0
    checknum3 := zerofp - zerofp;       -- 0 - 0
    report_error ("Sub 0 - 0 miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum3 := zerofp - neg_zerofp;               -- 0 - (-0)
    report_error ("Sub 0 - -0 miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum3 := neg_zerofp - zerofp;               -- -0 - 0
    report_error ("Sub -0 - 0 miscompare",
                  to_slv(checknum3),
                  to_slv(neg_zerofp));              -- -0
    checknum3 := neg_zerofp - neg_zerofp;               -- -0 - -0
    report_error ("Sub -0 - -0 miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum  := "01000000110100000000000000000000";    -- 6.5
    checknum2 := "01000000100000000000000000000000";    -- 4
    checknum3 := checknum - checknum2;
    report_error ("Subtract 6.5 - 4 miscompare",
                  checknum3,
                  "01000000001000000000000000000000");  -- 2.5
    checknum3 := checknum2 - checknum;
    report_error ("Subtract 4 - 6.5 miscompare",
                  checknum3,
                  "11000000001000000000000000000000");  -- -2.5
    checknum  := "01000000100010101010101010101011";    -- 4.333333
    checknum2 := "00111110101010101010101010101011";    -- 1/3
    checknum3 := checknum - checknum2;
    report_error ("subtract 4 miscompare",
                  checknum3,
                  "01000000100000000000000000000000");  -- 4
    checknum3 := checknum2 - checknum;
    report_error ("subtract 4 miscompare",
                  checknum3,
                  "11000000100000000000000000000000");  -- -4
    checknum  := "01001011111001110011000110011011";    -- 30303030
    checknum2 := "01001011111001110011000110011100";    -- 30303033
    checknum3 := checknum2 - checknum;
    report_error ("Subtract 30303030 - 30303033 miscompare",
                  checknum3,
                  "01000000000000000000000000000000");  -- 2 (not 3, rounding) 
    checknum  := "01000000110100000000000000000000";    -- 6.5
    checknum2 := "01000000110100000000000000000000";    -- 6.5
    checknum3 := checknum * checknum2;
    report_error ("Multiply 42.25 miscompare",
                  checknum3,
                  "01000010001010010000000000000000");  -- 42.25
    checknum  := "00111110101010101010101010101011";    -- 1/3
    checknum2 := "01000000000000000000000000000000";    -- 2
    checknum3 := checknum * checknum2;
    report_error ("Multiply 2/3 miscompare",
                  checknum3,
                  "00111111001010101010101010101011");  -- 2/3
    checknum  := "01000010001010000000000000000000";    -- 42
    checknum2 := "01000000000000000000000000000000";    -- 2
    checknum3 := checknum * checknum2;
    report_error ("Multiply 84 miscompare",
                  checknum3,
                  "01000010101010000000000000000000");  -- 84
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum  := "11000000110100000000000000000000";    -- -6.5
    checknum3 := checknum * checknum2;
    report_error ("Multiply -273 miscompare",
                  checknum3,
                  "11000011100010001000000000000000");  -- -273
    checknum2 := "00111111100000000000000000000000";    -- 1.0
    checknum3 := "01000000010000000000000000000000";    -- 3.0
    checknum  := checknum2 / checknum3;                 -- 1 / 3
    report_error ("div 1/3 test miscompare",
                  checknum,
                  "00111110101010101010101010101011");  -- 1/3
    -- Denormal number test
    checknum2 := "00000000000000000000000000000001";    -- 2**-149
    checknum3 := "11000000000000000000000000000000";    -- -2.0
    checknum  := checknum2 * checknum3;                 -- 0
    report_error ("mult 2**-148 test miscompare",
                  checknum,
                  "10000000000000000000000000000010");  -- -2*-148
    checknum2 := "00000000000000000000000000000001";    -- 2**-149
    checknum  := "11000000000000000000000000000000";    -- -2.0
    checknum3 := checknum * checknum2;
    report_error ("Multiply -2**-148 miscompare",
                  checknum3,
                  "10000000000000000000000000000010");  -- -2**148
    checknum  := "00000000010000000000000000000000";    -- 2**-127
    checknum2 := "00111110100000000000000000000000";    -- 0.25
    checknum3 := checknum * checknum2;
    report_error ("Multiply 2**-129 (denormal * small) miscompare",
                  checknum3,
                  "00000000000100000000000000000000");  -- 2**-129
    checknum  := "00000000010000000000000000000010";    -- 2**-127+
    checknum2 := "00111111000000000000000000000000";    -- 0.5
    checknum3 := checknum * checknum2;
    report_error ("Multiply 2**-128 (denormal to denormal) miscompare",
                  checknum3,
                  "00000000001000000000000000000001");  -- 2**-128+
    checknum  := "00000000010000000000000000000001";    -- 2**-127+
    checknum2 := "11000000000000000000000000000000";    -- -2.0
    checknum3 := checknum * checknum2;
    report_error ("Multiply -2**-126+ (denormal to normal) miscompare",
                  checknum3,
                  "10000000100000000000000000000010");  -- -2**-126+
    checknum  := "00000000100000000000000000000000";    -- 2**-126
    checknum2 := "00111111000000000000000000000000";    -- 0.5
    checknum3 := checknum * checknum2;
    report_error ("Multiply 2**-127 (normal to denormal) miscompare",
                  checknum3,
                  "00000000010000000000000000000000");  -- 2**-127
    checknum  := "00000000010000000000000000000000";    -- 2**-127
    checknum2 := "00110000100010010111000001011111";    -- 0.000000001
    checknum3 := checknum * checknum2;
    report_error ("Multiply 0 (very small normal * denormal) miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0
    checknum  := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := checknum * checknum;
    report_error ("Multiply 0 (denormal * denormal) miscompare",
                  to_slv(checknum3),
                  to_slv(zerofp));              -- 0    
    checknum3 := checknum * (-checknum);
    report_error ("Multiply 0 (denormal * -denormal) miscompare",
                  to_slv(checknum3),
                  to_slv(neg_zerofp));              -- 0
    checknum2 := "11000000000000000000000000000000";    -- -2.0
    checknum3 := checknum2 * zerofp;    -- multiply by zero
    report_error ("Multiply 0 (-2 * 0) miscompare",
                  to_slv(checknum3),
                  to_slv(neg_zerofp));              -- 0
    checknum3 := zerofp * checknum2;    -- multiply by zero
    report_error ("Multiply 0 (0 * -2) miscompare",
                  to_slv(checknum3),
                  to_slv(neg_zerofp));              -- 0
    checknum  := zerofp;
    checknum2 := pos_inffp;
    checknum3 := checknum * checknum2;
    report_error ("Multiply 0 * inf miscompare",
                  to_slv (checknum3),
                  to_slv (qnanfp));  -- qnan /= qnan returns "FALSE", so use SLV
    checknum2 := zerofp;
    checknum  := pos_inffp;
    checknum3 := checknum * checknum2;
    report_error ("Multiply inf * 0 miscompare",
                  to_slv (checknum3),
                  to_slv (qnanfp));  -- qnan /= qnan returns "FALSE", so use SLV
    checknum  := "00000000100000000000000000000000";    -- 2**-126
    checknum2 := pos_inffp;
    checknum3 := checknum * checknum2;
    report_error ("Multiply x * inf miscompare",
                  checknum3,
                  pos_inffp);
    checknum  := "00000000100000000000000000000000";    -- 2**-126
    checknum2 := neg_inffp;
    checknum3 := checknum * checknum2;
    report_error ("Multiply x * -inf miscompare",
                  checknum3,
                  neg_inffp);
    checknum  := from_hstring ("E81AB458", float32'high, -float32'low);
    checknum2 := from_hstring ("0005E800", float32'high, -float32'low);
    checknum1 := from_hstring ("A6E46E4A", float32'high, -float32'low);
    checknum3 := checknum * checknum2;
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum  := from_hstring ("D6CFC3BB", float32'high, -float32'low);
    checknum2 := from_hstring ("8000721F", float32'high, -float32'low);
    checknum1 := from_hstring ("13B93CA4", float32'high, -float32'low);
    checknum3 := checknum * checknum2;
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum2 := from_hstring ("E81AB458", float32'high, -float32'low);
    checknum  := from_hstring ("0005E800", float32'high, -float32'low);
    checknum1 := from_hstring ("A6E46E4A", float32'high, -float32'low);
    checknum3 := checknum * checknum2;
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum2 := from_hstring ("D6CFC3BB", float32'high, -float32'low);
    checknum  := from_hstring ("8000721F", float32'high, -float32'low);
    checknum1 := from_hstring ("13B93CA4", float32'high, -float32'low);
    checknum3 := checknum * checknum2;
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum  := "01111111010101010101010101010101";    -- pattern 7F555555
    checknum2 := "00000000000000000000000000000001";    -- 2**-149
    checknum1 := "00010011101110010011110010100100";  -- correct ans.
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum2 := from_hstring ("806B15D0", float32'high, -float32'low);
    checknum  := from_hstring ("80028733", float32'high, -float32'low);
    checknum1 := from_hstring ("00000000", float32'high, -float32'low);
    checknum3 := checknum * checknum2;
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum2 := from_hstring ("3850311A", float32'high, -float32'low);
    checknum  := from_hstring ("0045A3D9", float32'high, -float32'low);
    checknum1 := from_hstring ("000000E3", float32'high, -float32'low);
    checknum3 := checknum * checknum2;  -- Denormal round a sticky test
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    checknum2 := from_hstring ("3F000001", float32'high, -float32'low); -- 0.5+
    checknum  := "00000000000000000000000000000001";    -- 2**-149
    checknum3 := checknum * checknum2;  -- Denormal round a sticky test
    report_error (to_hstring(checknum) & " * " & to_hstring (checknum2),
                  checknum3,
                  checknum);
    checknum2 := from_hstring ("806B15D0", float32'high, -float32'low);
    checknum  := from_hstring ("80028733", float32'high, -float32'low);
    checknum1 := from_hstring ("00000000", float32'high, -float32'low);
    checknum3 := mac (checknum, checknum2, checknum1);
    report_error ("mac (" & to_hstring(checknum) & to_hstring (checknum2),
                  checknum3,
                  checknum1);
    
    checknum2 := "00111111100000000000000000000000";  -- 1.0
    checknum  := neg_zerofp / checknum2;  -- -0/1 = -0
    report_error (" -0 / 1 = ",
                  to_slv(checknum), to_slv(neg_zerofp));
    checknum2 := "10111111100000000000000000000000";  -- -1.0
    checknum  := zerofp / checknum2;  -- 0/-1 = -0
    report_error (" 0 / -1 = ",
                  to_slv(checknum), to_slv(neg_zerofp));
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := "00000000010000000000000000000000";    -- 2**-127
    checknum  := checknum2 / checknum3;                 -- 1
    report_error ("div 2**-126/2**-126 test miscompare",
                  checknum,
                  "00111111100000000000000000000000");  -- 1
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := "01001100000011001011110001001111";    -- 36892987
    checknum  := checknum2 / checknum3;                 -- 0
    report_error ("div 369297/2**-126 test miscompare",
                  checknum,
                  zerofp);                              -- 0
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := "11000000000000000000000000000000";    -- -2.0
    checknum  := checknum2 / checknum3;                 -- 0
    report_error ("div -2**-127 test miscompare",
                  checknum,
                  "10000000001000000000000000000000");  -- -2*-128
    checknum2 := "10000000001000000000000000000000";    -- -2*-128
    checknum3 := "11000000000000000000000000000000";    -- -2.0
    checknum  := checknum2 / checknum3;                 -- 0
    report_error ("div 2**-128 test miscompare",
                  checknum,
                  "00000000000100000000000000000000");  -- 2*-129
    checknum2 := "00000000000100000000000000000000";    -- 2*-129
    checknum3 := "11000001000000000000000000000000";    -- -8.0
    checknum  := checknum2 / checknum3;                 -- 0
    report_error ("div 2**-136 test miscompare",
                  checknum,
                  "10000000000000100000000000000000");  -- -2*-131
    checknum2 := "10000000000000000000000000000010";    -- -2*-148
    checknum3 := "10000000000000000000000000000010";    -- -2*-148
    checknum  := checknum2 / checknum3;
    report_error ("div -2**-148/-2**-148 test miscompare",
                  checknum,
                  to_float(1));                          -- 1
    -- normal / denormal test
    checknum2 := "10000000000000000000000000000010";    -- -2*-148
    checknum3 := "00110100100000000000000000000000";    -- 2**-22
    checknum  := checknum3 / checknum2;
    report_error ("div 2**-22/-2**-148 test",
                  checknum,
                  to_float(-(2.0**126)));                -- 2*126
    checknum2 := "10000000000000000000000000000001";    -- -2*-149
    checknum3 := "00110100000000000000000000000000";    -- 2**-23
    checknum  := checknum3 / checknum2;
    report_error ("div 2**-23/-2**-149 test",
                  checknum,
                  to_float(-(2.0**126)));                -- 2*126
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := "00111111000000000000000000000000";    -- 0.5
    checknum  := checknum3 / checknum2;
    report_error ("div 0.5/2**-127 test",
                  checknum,
                  to_float(2.0**126));                   -- 2*126
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum3 := "00111111000000000000000000000001";    -- 0.5+
    checknum  := checknum3 / checknum2;
    report_error ("div 0.5+/2**-127 test",
                  checknum,
                  "01111110100000000000000000000001");  -- 2*126+
    checknum2 := "00000000010000000000000000000001";    -- 2**-127+
    checknum3 := "00111111000000000000000000000000";    -- 0.5
    checknum  := checknum3 / checknum2;
    report_error ("div 0.5/2**-127+ test",
                  checknum,
                  "01111110011111111111111111111100");  -- 2*126-
    checknum2 := "00000000001000000000000000000000";    -- 2**-128
    checknum3 := "00111110100000000000000000000000";    -- 0.25
    checknum  := checknum3 / checknum2;
    report_error ("div 0.25/2**-128 test",
                  checknum,
                  to_float(2.0**126));                   -- 2*126
    checknum2 := "00000000000010000000000000000000";    -- 2**-130
    checknum3 := "00111101100000000000000000000000";    -- 0.0625
    checknum  := checknum3 / checknum2;
    report_error ("div 0.0625/2**-130 test",
                  checknum,
                  to_float(2.0**126));                   -- 2*126
    checknum2 := "00000000000000100000000000000000";    -- 2**-132
    checknum3 := "00111100000000000000000000000000";    -- 2**-7
    checknum  := checknum3 / checknum2;
    report_error ("div 2**-7/2**-132 test",
                  checknum,
                  to_float(2.0**125));                   -- 2*125
    checknum2 := "00000000000000000000001000000000";    -- 2**-140
    checknum3 := "00111000000000000000000000000000";    -- 2**-15
    checknum  := checknum3 / checknum2;
    report_error ("div 2**-15/2**-140 test",
                  checknum,
                  to_float(2.0**125));                   -- 2**125
    checknum2 := "00000000000000000000000100000000";    -- 2**-141
    checknum3 := "00101011100000000000000000000000";    -- 2**-40
    checknum  := checknum3 / checknum2;
    report_error ("div 2**-40/2**-141 test",
                  checknum,
                  to_float(2.0**101));                   -- 2**101
    checknum2 := "10000000000000000000000000000010";    -- -2*-148
    checknum3 := "00111111000000000000000000000000";    -- 0.5
    checknum  := checknum3 / checknum2;
    report_error ("div 0.5/-2**-148 test",
                  checknum,
                  neg_inffp);  -- -2**147 = -inf
    checknum2 := "00000000000000000000000100000000";    -- 2**-141
    checknum3 := "01010100100000000000000000000000";    -- 2**40
    checknum  := checknum2 / checknum3;
    report_error ("div 2**-40/2**-141 test",
                  to_slv(checknum),
                  to_slv(zerofp));                   -- zero
    checknum2 := "10000000000000000000000100000000";    -- -2**-141
    checknum3 := "01010100100000000000000000000000";    -- 2**40
    checknum  := checknum2 / checknum3;
    report_error ("div 2**-40/2**-141 test",
                  to_slv(checknum),
                  to_slv(neg_zerofp));                   -- -0
    checknum2 := "00000000000000000000000100000000";    -- 2**-141
    checknum3 := "11010100100000000000000000000000";    -- -2**40
    checknum  := checknum2 / checknum3;
    report_error ("div 2**-40/2**-141 test",
                  to_slv(checknum),
                  to_slv(neg_zerofp));                   -- -0
    checknum2 := "10000000000000000000000100000000";    -- -2**-141
    checknum3 := "11010100100000000000000000000000";    -- -2**40
    checknum  := checknum2 / checknum3;
    report_error ("div 2**-40/2**-141 test",
                  to_slv(checknum),
                  to_slv(zerofp));                   -- zero
    -- Check some specific number (test that failed at Boing)
    checknum2 := from_hstring ("0000F01B");
    checknum3 := from_hstring ("2E8C024F");
    checknum  := checknum2 / checknum3;
    checknum1 := from_hstring ("0DDB82C8");
    report_error (to_hstring (checknum2) & " / " & to_hstring (checknum3),
                  checknum, checknum1);
    checknum2 := from_hstring ("8001C9E5");
    checknum3 := from_hstring ("005E857E");
    checknum  := checknum2 / checknum3;
    checknum1 := from_hstring ("BC9B04E0");
    report_error (to_hstring (checknum2) & " / " & to_hstring (checknum3),
                  checknum, checknum1);
    checknum2 := from_hstring ("0000957C");
    checknum3 := from_hstring ("8067E8F6");
    checknum  := checknum2 / checknum3;
    checknum1 := from_hstring ("BBB823DF");
    report_error (to_hstring (checknum2) & " / " & to_hstring (checknum3),
                  checknum, checknum1);
    checknum2 := from_hstring ("8000D591");
    checknum3 := from_hstring ("000723CB");
    checknum  := checknum2 / checknum3;
    checknum1 := from_hstring ("BDEF4BD7");
    report_error (to_hstring (checknum2) & " / " & to_hstring (checknum3),
                  checknum, checknum1);
    checknum2 := from_hstring ("80800001");
    checknum3 := from_hstring ("C0000000");
    checknum  := checknum2 / checknum3;
    checknum1 := from_hstring ("00400001");  -- sticky bit in divide always 1
    report_error (to_hstring (checknum2) & " / " & to_hstring (checknum3),
                  checknum, checknum1);
    -- Pentium bug test
    checknum2 := to_float (4195835.0);
    checknum3 := to_float (3145727.0);
    checknum := checknum2 / checknum3;
    --    checknum1 := to_float (1.33382);       -- Pentium got 1.33374
    checknum1 := "00111111101010101011101010100001";  -- 1.33820
    report_error ( "Pentium bug test", checknum, checknum1);
    -- big number test
    checknum2 := "01001100000011001011110001001111";    -- 36892987
    checknum3 := pos_inffp;
    checknum  := checknum2 / checknum3;
    report_error ("X/inf test miscompare",
                  checknum,
                  zerofp);
    checknum2 := "01001100000011001011110001001111";    -- 36892987
    checknum3 := pos_inffp;
    checknum  := checknum3 / checknum2;
    report_error ("inf / X test miscompare",
                  checknum,
                  pos_inffp);    
    checknum2 := "01001100000011001011110001001111";    -- 36892987
    checknum3 := neg_inffp;
    checknum  := checknum3 / checknum2;
    report_error ("neginf / X test miscompare",
                  checknum,
                  neg_inffp);

    -- rem function
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum3 := "01000000101000000000000000000000";    -- 5
    checknum  := checknum2 rem checknum3;               -- 2
    checknum1 := to_float (42 rem 5);
    report_error ("42 rem 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum3 := "01000000101000000000000000000000";    -- 5
    checknum  := checknum2 rem 5;               -- 2
    report_error ("42 rem int 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum  := 42 rem checknum3;               -- 2
    report_error ("int 42 rem 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum  := checknum2 rem 5.0;               -- 2
    report_error ("42 rem 5.0 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum  := 42.0 rem checknum3;               -- 2
    report_error ("42.0 rem 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum3 := "01000000000000000000000000000000";
    checknum  := checknum2 rem checknum3;               -- 0
    report_error ("42 rem 2 miscompare",
                  checknum,
                  zerofp);                              -- 0.0
        checknum2 := "01000010001010000000000000000000";    -- 42
    checknum3 := "01000000101000000000000000000000";    -- 5
    checknum  := checknum2 mod checknum3;               -- 2
    checknum1 := to_float (42 mod 5);
    report_error ("42 mod 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum3 := "01000000101000000000000000000000";    -- 5
    checknum  := checknum2 mod 5;               -- 2
    report_error ("42 mod int 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum  := 42 mod checknum3;               -- 2
    report_error ("int 42 mod 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum  := checknum2 mod 5.0;               -- 2
    report_error ("42 mod 5.0 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum  := 42.0 mod checknum3;               -- 2
    report_error ("42.0 mod 5 miscompare",
                  checknum, checknum1);  -- 2.0
    checknum2 := "01000010001010000000000000000000";    -- 42
    checknum3 := "01000000000000000000000000000000";
    checknum  := checknum2 mod checknum3;               -- 0
    report_error ("42 mod 2 miscompare",
                  checknum,
                  zerofp);                              -- 0.0
    -- DO the divmod test here
    start_divmodtest <= true;
    wait until divmodtest_done;

    checknum2 := "01111111011111111111111111111111";    -- Most positive number
    checknum  := checknum2 + checknum2;
    report_error ("positive overflow test",
                  checknum,
                  pos_inffp);
    checknum := checknum2 * checknum2;
    report_error ("multiply positive overflow test",
                  checknum,
                  pos_inffp);
    checknum2 := "11111111011111111111111111111111";    -- Most negitive number
    checknum  := checknum2 + checknum2;
    report_error ("negative overflow test",
                  checknum,
                  neg_inffp);    
    checknum := checknum2 * (-checknum2);
    report_error ("multiply negative overflow test",
                  checknum,
                  neg_inffp);
    checknum2 := "01000000000000000000000000000000";    -- 2.0
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2",
                  checknum,
                  "00111111000000000000000000000000");  -- 0.5
    checknum := reciprocal (to_float(3));
    report_error ("reciprocal (3)",
                  checknum,
                  "00111110101010101010101010101011");  -- 1/3
    checknum2 := to_float(MATH_PI);
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/PI",
                  checknum,
                  to_float(1.0/MATH_PI));
    checknum2 := to_float(MATH_E);
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/PE",
                  checknum,
                  to_float(1.0/MATH_E));
    checknum2 := "00000000100000000000000000000000";    -- 2**-126
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-126",
                  checknum,
                  "01111110100000000000000000000000");  -- 2**126
    -- denormal numbers that you can 1/X
    checknum2 := "00000000010000000000000000000000";    -- 2**-127
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-127",
                  checknum,
                  "01111111000000000000000000000000");  -- 2**127
    checknum2 := "00000000010000000000000000000001";    -- 2**-127+
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-127+",
                  checknum,
                  "01111110111111111111111111111100");  -- 2**127-
    checknum2 := "00000000010000000000010000000001";    -- 2**-127++
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-127++",
                  checknum,
                  "01111110111111111110111111111101");             -- 2**127--
    checknum2 := "00000000001000000000000000000001";    -- 2**-128+
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-128+",
                  checknum,
                  "01111111011111111111111111111000");  -- 2**127+
    checknum2 := "00000000001000000000001000000001";    -- 2**-128++
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-128++",
                  checknum,
                  "01111111011111111110111111111001");  -- 2**127++
    -- denormal numbers that 1/x = inf
    checknum2 := "00000000001000000000000000000000";    -- 2**-128
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-128 = inf",
                  checknum,
                  pos_inffp);           -- 2**128 = inf in 32 bits
    checknum2 := "10000000001000000000000000000000";    -- -2**-128
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal -1/2**-128 = -inf",
                  checknum,
                  neg_inffp);           -- 2**128 = inf in 32 bits
    checknum2 := "00000000000100000000000000000000";    -- 2**-129
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal 1/2**-129 = inf",
                  checknum,
                  pos_inffp);           -- 2**129 = inf in 32 bits
    checknum2 := "10000000000100000000000000000000";    -- -2**-129
    checknum  := reciprocal (checknum2);
    report_error ("reciprocal -1/2**-129 = -inf",
                  checknum,
                  neg_inffp);           -- 2**129 = inf in 32 bits
    checknum1 := "01000000000000000000000000000000";    -- 2.0
    checknum2 := "01000000000000000000000000000000";    -- 2.0
    checknum  := dividebyp2 (checknum1, checknum2);
    report_error ("dividebyp2, 2/2",
                  checknum,
                  to_float(1));
    checknum2 := "00111111000000000000000000000000";
    checknum  := dividebyp2 (to_float(42), checknum2);
    report_error ("dividebyp2, 42 / 0.5",
                  checknum,
                  to_float(84));
    --------------------------------------------------------------------------
    -- Nan and infinity testing
    --------------------------------------------------------------------------
    start_naninftest <= true;
    wait until naninftest_done;

    ---------------------------------------------------------------------------
    -- Perform all of the math loop test
    ---------------------------------------------------------------------------
    start_looptest  <= true;
    wait until looptest_done;
    ---------------------------------------------------------------------------
    -- Perform all of the denormal math loop test
    ---------------------------------------------------------------------------
    start_looptest2 <= true;
    wait until looptest2_done;
    -- Subtract boundary test
    start_sbtest <= true;
    wait until sbtest_done;
    -- We're done.  End the simulation.
    report "32 BIT floating point Testing complete"
      severity note;
    wait;
  end process Test_process;

  -- purpose: test compare operations
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  comptest : process is
    -- purpose: report a class error
    procedure report_class_error (
      constant errmes     : in STRING;  -- error message
      class               : in valid_fpstate;  -- State of FP number
      constant checkclass : in valid_fpstate;  -- state of number
      arg                 : in float32) is        -- Floating point number
  begin
    assert (class = checkclass)
      report errmes & " " & CR &
      "Class(" & to_string(arg) & ") = " & valid_fpstate'image(class) & CR &
      "Should be : " & valid_fpstate'image(checkclass)
      severity error;
  end procedure report_class_error;
  variable checknum, checknum2, checknum3 : float32;           -- check numbers
  variable fpclass                        : valid_fpstate;  -- Class of the fp number (IEEE defined)
  begin  -- process comptest
    wait until start_comptest;
    -- Check the compare operations
    checknum  := to_float (1.0/3.0);
    checknum2 := to_float (2);
    assert (checknum = checknum)        -- true
      report "Error X = X miscompare" severity error;
    assert not(checknum = checknum2)    -- false
      report "Error X = Y miscompare" severity error;
    assert (zerofp = neg_zerofp)        -- true
      report "Error 0 = -0 miscompare" severity error;
    assert not(checknum = qnanfp)       -- false
      report "Error X = qnan miscompare" severity error;
    assert not(qnanfp = checknum2)      -- false
      report "Error qnan = Y miscompare" severity error;
    assert (checknum2 = 2.0)            -- true
      report "Error X = real(X) miscompare" severity error;
    assert not(checknum2 = 1.0)         -- false
      report "Error X = real(Y) miscompare" severity error;
    assert (2.0 = checknum2)            -- true
      report "Error real(X) = X miscompare" severity error;
    assert not(1.0 = checknum2)         -- false
      report "Error real(X) = Y miscompare" severity error;
    assert (checknum2 = 2)            -- true
      report "Error X = int(X) miscompare" severity error;
    assert not(checknum2 = 1)         -- false
      report "Error X = int(Y) miscompare" severity error;
    assert (2 = checknum2)            -- true
      report "Error int(X) = X miscompare" severity error;
    assert not(1 = checknum2)         -- false
      report "Error int(X) = Y miscompare" severity error;
    
    assert not(checknum /= checknum)    -- false
      report "Error X /= X miscompare" severity error;
    assert (checknum /= checknum2)      -- true
      report "Error X /= Y miscompare" severity error;
    assert not((zerofp /= neg_zerofp))  -- false
      report "Error 0 /= -0 miscompare" severity error;
    assert (checknum /= qnanfp)         -- true
      report "Error X /= qnan miscompare" severity error;
    assert (qnanfp /= checknum2)        -- true
      report "Error qnan /= Y miscompare" severity error;
    assert not (checknum2 /= 2.0)        -- false
      report "Error X /= real(X) miscompare" severity error;
    assert (checknum2 /= 1.0)            -- true
      report "Error X /= real(Y) miscompare" severity error;
    assert not (2.0 /= checknum2)        -- false
      report "Error real(X) /= X miscompare" severity error;
    assert (1.0 /= checknum2)           -- true
      report "Error real(X) /= Y miscompare" severity error;
    assert not (checknum2 /= 2)        -- false
      report "Error X /= int(X) miscompare" severity error;
    assert (checknum2 /= 1)            -- true
      report "Error X /= int(Y) miscompare" severity error;
    assert not (2 /= checknum2)        -- false
      report "Error int(X) /= X miscompare" severity error;
    assert (1 /= checknum2)           -- true
      report "Error int(X) /= Y miscompare" severity error;
    
    assert (checknum >= checknum)       -- true
      report "Error X >= X miscompare" severity error;
    assert (checknum2 >= checknum)      -- true
      report "Error Y >= X miscompare" severity error;
    assert not(checknum >= checknum2)   -- false
      report "Error X >= Y miscompare" severity error;
    assert not(checknum >= qnanfp)      -- false
      report "Error X >= qnan miscompare" severity error;
    assert not(qnanfp >= checknum2)     -- false
      report "Error qnan >= Y miscompare" severity error;
    assert (checknum2 >= 2.0)           -- true
      report "Error X >= real(X) miscompare" severity error;
    assert not(checknum2 >= 3.0)        -- false
      report "Error X >= real(Y) miscompare" severity error;
    assert (2.0 >= checknum2)           -- true
      report "Error real(X) >= Y miscompare" severity error;
    assert not (1.0 >= checknum2)       -- false
      report "Error real(X) >= Y miscompare" severity error;
    assert (checknum2 >= 2)           -- true
      report "Error X >= int(X) miscompare" severity error;
    assert not(checknum2 >= 3)        -- false
      report "Error X >= int(Y) miscompare" severity error;
    assert (2 >= checknum2)           -- true
      report "Error int(X) >= Y miscompare" severity error;
    assert not (1 >= checknum2)       -- false
      report "Error int(X) >= Y miscompare" severity error;
    assert (zerofp >= neg_zerofp)        -- true
      report "Error 0 >= -0 miscompare" severity error;
    assert (neg_zerofp >= zerofp)        -- true
      report "Error -0 >= 0 miscompare" severity error;
    
    assert (checknum <= checknum)       -- true
      report "Error X <= X miscompare" severity error;
    assert not(checknum2 <= checknum)   -- false
      report "Error Y <= X miscompare" severity error;
    assert (checknum <= checknum2)      -- true
      report "Error X <= Y miscompare" severity error;
    assert not(checknum <= qnanfp)      -- false
      report "Error X <= qnan miscompare" severity error;
    assert not(qnanfp <= checknum2)     -- false
      report "Error qnan <= Y miscompare" severity error;
    assert (checknum2 <= 2.0)           -- true
      report "Error X <= real(X) miscompare" severity error;
    assert not(checknum2 <= 1.0)        -- false
      report "Error X <= real(Y) miscompare" severity error;
    assert (2.0 <= checknum2)           -- true
      report "Error real(X) <= X miscompare" severity error;
    assert (1.0 <= checknum2)           -- false
      report "Error real(X) <= Y miscompare" severity error;
    assert (checknum2 <= 2)           -- true
      report "Error X <= int(X) miscompare" severity error;
    assert not(checknum2 <= 1)        -- false
      report "Error X <= int(Y) miscompare" severity error;
    assert (2 <= checknum2)           -- true
      report "Error int(X) <= X miscompare" severity error;
    assert (1 <= checknum2)           -- false
      report "Error int(X) <= Y miscompare" severity error;
    assert (zerofp <= neg_zerofp)        -- true
      report "Error 0 <= -0 miscompare" severity error;
    assert (neg_zerofp <= zerofp)        -- true
      report "Error -0 <= 0 miscompare" severity error;
 
    assert not (checknum > checknum)    -- false
      report "Error X > X miscompare" severity error;
    assert (checknum2 > checknum)       -- true
      report "Error Y > X miscompare" severity error;
    assert not(checknum > checknum2)    -- false
      report "Error X > Y miscompare" severity error;
    assert not(checknum > qnanfp)       -- false
      report "Error X > qnan miscompare" severity error;
    assert not(qnanfp > checknum2)      -- false
      report "Error qnan > Y miscompare" severity error;
    assert (checknum2 > 1.0)            -- true
      report "Error X > real(X) miscompare" severity error;
    assert not(checknum2 > 3.0)         -- false
      report "Error X > real(Y) miscompare" severity error;
    assert (3.0 > checknum2)            -- true
      report "Error real(X) > X miscompare" severity error;
    assert not(1.0 > checknum2)         -- false
      report "Error real(X) > Y miscompare" severity error;
    assert (checknum2 > 1)            -- true
      report "Error X > int(X) miscompare" severity error;
    assert not(checknum2 > 3)         -- false
      report "Error X > int(Y) miscompare" severity error;
    assert (3 > checknum2)            -- true
      report "Error int(X) > X miscompare" severity error;
    assert not (1 > checknum2)         -- false
      report "Error int(X) > Y miscompare" severity error;
    assert not (zerofp > neg_zerofp)        -- false
      report "Error 0 > -0 miscompare" severity error;
    assert not (neg_zerofp > zerofp)        -- false
      report "Error -0 > 0 miscompare" severity error;
    
    assert not(checknum < checknum)     -- false
      report "Error X < X miscompare" severity error;
    assert not(checknum2 < checknum)    -- false
      report "Error Y < X miscompare" severity error;
    assert (checknum < checknum2)       -- true
      report "Error X < Y miscompare" severity error;
    assert not(checknum < qnanfp)       -- false
      report "Error X < qnan miscompare" severity error;
    assert not(qnanfp < checknum2)      -- false
      report "Error qnan < Y miscompare" severity error;
    assert (checknum2 < 3.0)            -- true
      report "Error X < real(X) miscompare" severity error;
    assert not(checknum2 < 1.0)         -- false
      report "Error X < real(Y) miscompare" severity error;
    assert not(3.0 < checknum2)         -- false
      report "Error real(X) < X miscompare" severity error;
    assert (1.0 < checknum2)            -- true
      report "Error real(X) < Y miscompare" severity error;
    assert (checknum2 < 3)            -- true
      report "Error X < int(X) miscompare" severity error;
    assert not(checknum2 < 1)         -- false
      report "Error X < int(Y) miscompare" severity error;
    assert not(3 < checknum2)         -- false
      report "Error int(X) < X miscompare" severity error;
    assert (1.0 < checknum2)            -- true
      report "Error int(X) < Y miscompare" severity error;
    assert not (zerofp < neg_zerofp)        -- false
      report "Error 0 < -0 miscompare" severity error;
    assert not (neg_zerofp < zerofp)        -- false
      report "Error -0 < 0 miscompare" severity error;
  
    checknum3 := maximum (checknum, checknum2);
    report_error ("Maximum test 1", checknum3, checknum2);
    checknum3 := maximum (checknum2, checknum);
    report_error ("Maximum test 2", checknum3, checknum2);
    checknum3 := minimum (checknum, checknum2);
    report_error ("Minimum test 1", checknum3, checknum);
    checknum3 := minimum (checknum2, checknum);
    report_error ("Minimum test 2", checknum3, checknum);
    -- negative zero test
    assert (zerofp = neg_zerofp)        -- true
      report "Error 0 = -0 miscompare" severity error;
    assert (zerofp <= neg_zerofp)       -- true
      report "Error 0 <= -0 miscompare" severity error;
    assert (zerofp >= neg_zerofp)       -- true
      report "Error 0 => -0 miscompare" severity error;
    assert not(zerofp < neg_zerofp)     -- false
      report "Error 0 < -0 miscompare" severity error;
    assert not(zerofp > neg_zerofp)     -- false
      report "Error 0 > -0 miscompare" severity error;
    assert not(zerofp /= neg_zerofp)    -- false
      report "Error 0 /= -0 miscompare" severity error;
    assert (neg_zerofp = zerofp)        -- true
      report "Error -0 = 0 miscompare" severity error;
    assert (neg_zerofp <= zerofp)       -- true
      report "Error -0 <= 0 miscompare" severity error;
    assert (neg_zerofp >= zerofp)       -- true
      report "Error -0 => 0 miscompare" severity error;
    assert not(neg_zerofp < zerofp)     -- false
      report "Error -0 < 0 miscompare" severity error;
    assert not(neg_zerofp > zerofp)     -- false
      report "Error -0 > 0 miscompare" severity error;
    assert not(neg_zerofp /= zerofp)    -- false
      report "Error -0 /= 0 miscompare" severity error;

    -- Check the "Class" command
    checknum := zerofp;
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of Zero incorrect ",
                        fpclass, pos_zero, checknum);
    checknum := neg_zerofp;
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of neg_zero incorrect",
                        fpclass, neg_zero, checknum);
    checknum := pos_inffp;
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of infinity incorrect",
                        fpclass, pos_inf, checknum);
    checknum := neg_inffp;
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of neg_inf incorrect",
                        fpclass, neg_inf, checknum);
    checknum := qnanfp;
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of quiet_nan incorrect",
                         fpclass, quiet_nan, checknum);
    checknum := nanfp;
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of signaling nan incorrect",
                         fpclass, nan, checknum);
    checknum := to_float(2);
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of normal incorrect",
                         fpclass, pos_normal, checknum);
    checknum := to_float(-2);
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of neg incorrect",
                         fpclass, neg_normal, checknum);
    checknum := to_float(2.0**(-149));
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of denormal incorrect",
                         fpclass, pos_denormal, checknum);
    checknum := to_float(-1.0*(2.0**(-149)));
    fpclass  := Classfp(checknum);
    report_class_error ("Error Class of neg_denoral incorrect",
                         fpclass, neg_denormal, checknum);
    checknum := to_float (2.0**(-126));
    fpclass  := Classfp(checknum);
    report_class_error ("class, min normal number", fpclass,
                        pos_normal, checknum);
    checknum := nextafter (checknum, zerofp);
    fpclass  := Classfp(checknum);
    report_class_error ("class nextafter min normal number", fpclass,
                        pos_denormal, checknum);
    checknum := "00000000011111111111111111111111";  -- max denormal
    fpclass  := classfp (checknum);
    report_class_error ("class max denormal number",
                        fpclass, pos_denormal, checknum);
    checknum := nextafter (checknum, pos_inffp);
    fpclass  := classfp (checknum);
    report_class_error ("class nextafter max denormal number", fpclass,
                        pos_normal, checknum);
    checknum := -to_float (2.0**(-126));
    fpclass  := Classfp (checknum);
    report_class_error ("class, -min normal number", fpclass,
                        neg_normal, checknum);
    checknum := nextafter (checknum, zerofp);
    fpclass  := Classfp (checknum);
    report_class_error ("class nextafter -min normal number", fpclass,
                        neg_denormal, checknum);
    checknum := "10000000011111111111111111111111";  -- max -denormal
    fpclass  := classfp (checknum);
    report_class_error ("class max -denormal number",
                        fpclass, neg_denormal, checknum);
    checknum := nextafter (checknum, neg_inffp);
    fpclass  := classfp (checknum);
    report_class_error ("class nextafter max -denormal number", fpclass,
                        neg_normal, checknum);
    -- check the copy sign command
    checknum := Copysign (pos_inffp, neg_zerofp);
    report_error ("Error Copysign command incorrect",
                   checknum, neg_inffp);
    checknum      := Copysign (to_float(-2), to_float(2));
    report_error ("Copysign POSITIVE to negative", checknum, to_float(2));
    checknum      := Copysign (to_float(42), to_float(1234));
    report_error ("Copysign pos to pos", checknum, to_float(42));
    checknum      := Copysign (to_float(-5), neg_zerofp);
    report_error ("Copysign neg to neg", checknum, to_float(-5));
    assert (quiet) report "compare test completed" severity note;
    comptest_done <= true;
    wait;
  end process comptest;


  -- purpose: test nextafter routine
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  nexttest : process is
    variable checknum, checknum2 : float32;  -- Floating point output
    variable fptype : valid_fpstate;    -- state type
  begin  -- process nexttest

    wait until start_nexttest;
    -- NextAfter function tests
    checknum  := "11000000110100000000000000000000";    -- -6.5
    checknum2 := Nextafter (checknum, checknum);
    report_error ("Nextafter -6.5 miscompare",
                  checknum2,
                  "11000000110100000000000000000000");
    checknum2 := Nextafter (checknum, neg_inffp);
    report_error ("Nextafter -6.5 - miscompare",
                  checknum2,
                  "11000000110100000000000000000001");
    checknum2 := Nextafter (to_float (-1.0/3.0), neg_zerofp);
    report_error ("Nextafter -1/3+ miscompare",
                  checknum2,
                  "10111110101010101010101010101010");
    checknum2 := Nextafter (qnanfp, nanfp);
    fptype := Classfp (checknum2);
    assert (fptype = nan)
      report "Nextafter signaling NAN miscompare " &
      valid_fpstate'image(fptype) severity error;
    checknum2 := Nextafter (zerofp, qnanfp);
    fptype := Classfp (checknum2);
    assert (fptype = quiet_nan)
      report "Nextafter quiet NAN miscompare " &
      valid_fpstate'image(fptype) severity error;
    checknum2 := Nextafter (neg_inffp, pos_inffp);
    report_error ("Nextafter neginf+ miscompare",
                  checknum2,
                  "11111111011111111111111111111111");  -- most neg #
    checknum2 := Nextafter (pos_inffp, neg_inffp);
    report_error ("Nextafter infinity- miscompare",
                  checknum2,
                  "01111111011111111111111111111111");  -- most positive #

    assert (quiet) report "Expect NextAfter overflow here." severity note;
    if (not quiet) then
      checknum  := "11111111011111111111111111111111";  -- most neg #
      checknum2 := Nextafter (checknum, neg_inffp);
      report_error ("Nextafter neginf miscompare",
                    checknum2,
                    neg_inffp);
      checknum  := "01111111011111111111111111111111";  -- most positive #
      assert (quiet) report "Expect NextAfter overflow here." severity note;
      checknum2 := Nextafter (checknum, pos_inffp);
      report_error ("Nextafter inifint miscompare",
                    checknum2,
                    pos_inffp);
    end if;
    checknum  := "01111111011111111111111111111111";  -- most positive #
    checknum2 := Nextafter (zerofp, checknum);
    report_error ("Nextafter smallest denormal miscompare",
                  checknum2,
                  "00000000000000000000000000000001");  -- Smallest
    checknum2 := Nextafter (checknum2, checknum);
    report_error ("Nextafter smallest denormal+ miscompare",
                  checknum2,
                  "00000000000000000000000000000010");  -- Smallest den +
    checknum  := "00000000011111111111111111111111";  -- Largest denormal number
    checknum2 := Nextafter (checknum, pos_inffp);
    report_error ("Nextafter smallest normal miscompare",
                  checknum2,
                  "00000000100000000000000000000000");  -- Smallest normal
    checknum2 := Nextafter (checknum2, pos_inffp);
    report_error ("Nextafter smallest normal+ miscompare",
                  checknum2,
                  "00000000100000000000000000000001");  -- Smallest norm +
    checknum  := "00000000111111111111111111111111";  -- Overflow fraction
    checknum2 := Nextafter (checknum, pos_inffp);
    report_error ("Nextafter overflow fraction miscompare",
                  checknum2,
                  "00000001000000000000000000000000");  -- Exp + 1
    checknum  := "10000000100000000000000000000000";  -- Smallest Neg normal
    checknum2 := Nextafter (checknum, pos_inffp);
    report_error ("Nextafter largest neg den miscompare",
                  checknum2, "10000000011111111111111111111111");  -- largest
                                        -- negitive denorm
    checknum  := "10000000011111111111111111111111";  -- Largest denormal number
    checknum2 := Nextafter (checknum, neg_inffp);
    report_error ("Nextafter negative smallest normal miscompare",
                  checknum2,
                  "10000000100000000000000000000000");  -- Smallest normal
    assert (quiet) report "NextAfter test complete" severity note;
    nexttest_done <= true;
    wait;
  end process nexttest;

  -- purpose: test the read routines
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  read_test : process is
    -- purpose: report a string error
    procedure report_error (
      constant errmes : in STRING;
      variable L1     : inout LINE;
      variable L2     : inout LINE) is
    begin
    assert (L1.all = L2.all)
      report errmes & " /= " & CR
      & "checked value  " & L2.all & CR
      & "returned value " & L1.all
      severity error;
     deallocate (L1); deallocate (L2);      
    end procedure report_error;
    variable L, L1, L2 : LINE;             -- line pointers to strings
    variable checknum              : float32;     -- Floating point output
    variable checknum1             : float32;     -- Floating point output
    variable checkbool             : boolean;  -- check boolean
    variable checkslv              : float32_slv;
    variable checksulv             : STD_ULOGIC_VECTOR (float32_slv'range);
    variable long_slv : STD_LOGIC_VECTOR (63 downto 0);  -- long slv
  begin  -- process read_test
    wait until start_readtest;
    -- test "to_string" first, it is used in the error routines.
    checknum  := to_float(42);
    write (L1, to_string (checknum));
    L2 := new string'("0:10000100:01010000000000000000000");
    assert (L1.all = L2.all)
      report "to_string(" & to_string (checknum) & ") /= " & CR
      & "                    " & L2.all severity error;
    deallocate (L1); deallocate (L2);
    checknum  := "0100000000000000000000000-ZUXWHL";
    write (L1, to_string (checknum));
    L2 := new string'("0:10000000:0000000000000000-ZUXWHL");
    assert (L1.all = L2.all)
      report "to_string(" & to_string (checknum) & ") /= " & CR
      & "                    " & L2.all severity error;
    deallocate (L1); deallocate (L2);
    -- to_slv is used in some of the below routines.
    -- function (and aliases) are necessary for syntheis.
    checknum := "01000000000000000000000000000000";
    checkslv := to_slv (checknum);
    report_error ("to_slv test", checkslv,
                  "01000000000000000000000000000000");
    checknum := "01100000000000000000000000000000";
    checkslv := to_stdlogicvector (checknum);
    report_error ("to_stdlogicvector test", checkslv,
                  "01100000000000000000000000000000");
    checknum := "01010000000000000000000000000000";
    checkslv := to_std_logic_vector (checknum);
    report_error ("to_std_logic_vector test", checkslv,
                  "01010000000000000000000000000000");
    checkslv := "01100000000000000000000000000000";
    checknum := to_float(checkslv);
    checknum1 := "01100000000000000000000000000000";
    report_error ("to_float(slv)", checknum, checknum1);
    long_slv := (others => '0');
    long_slv(62 downto 61) := (others => '1');
    checknum := to_float(long_slv(63 downto 32));
    report_error ("to_float(long_slv)", checknum, checknum1);
    -- to_sulv
    checknum := "01000000000000000000000000000000";
    checksulv := to_sulv (checknum);
    report_error ("to_sulv test", to_stdlogicvector (checksulv),
                  "01000000000000000000000000000000");
    checknum := "01100000000000000000000000000000";
    checksulv := to_stdulogicvector (checknum);
    report_error ("to_stdulogicvector test", to_stdlogicvector (checksulv),
                  "01100000000000000000000000000000");
    checknum := "01010000000000000000000000000000";
    checksulv := to_std_ulogic_vector (checknum);
    report_error ("to_std_ulogic_vector test", to_stdlogicvector (checksulv),
                  "01010000000000000000000000000000");
    checksulv := "01100000000000000000000000000000";
    checknum := to_float(checksulv);
    checknum1 := "01100000000000000000000000000000";
    report_error ("to_float(slv)", checknum, checknum1);
    -- test the READ routines
    L := new string'(" 11000000000000000000000000000000 ");
    read (L, checknum);
    report_error ("Error in Read",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1:10000000:00000000000000000000000 ");
    read (L, checknum);
    report_error ("Error in Read2",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1:1000_0000:000_0000_0000_0000_0000_0000 ");
    read (L, checknum);
    report_error ("Error in Read2_",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1_1000_0000.000_0000_0000_0000_0000_0000 ");
    read (L, checknum);
    report_error ("Error in Read2._",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 11000000000000000000000000000000 ");
    read (L, checknum, checkbool);
    assert (checkbool) report "Read reported error condition" severity error;
    report_error ("Error in Read bool",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1:10000000:00000000000000000000000 ");
    read (L, checknum, checkbool);
    assert (checkbool) report "Read2 reported error condition" severity error;
    report_error ("Error in Read2 bool",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1:1000_0000:000_0000_0000_0000_0000_0000 ");
    read (L, checknum, checkbool);
    assert (checkbool) report "Read2_ reported error condition" severity error;
    report_error ("Error in Read2_ bool",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1_1000_0000.000_0000_0000_0000_0000_0000 ");
    read (L, checknum, checkbool);
    assert (checkbool) report "Read2._ reported error condition" severity error;
    report_error ("Error in Read2._ bool",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 1:10000000:00000000 000000000000000 ");
    read (L, checknum, checkbool);
    assert (not checkbool) report "Readb not reported error condition"
      severity error;
    checkslv := to_slv (checknum);
    report_error ("Error in Readb bool",
                  checkslv,
                  "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
    deallocate (L);
    L := new string'(" 1:10000000:0000A000000000000000000 ");
    read (L, checknum, checkbool);
    assert (not checkbool) report "Readb1 not reported error condition"
      severity error;
    checkslv := to_slv (checknum);
    report_error ("Error in Readb1",
                  checkslv,
                  "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
    deallocate (L);
    L := new string'(" 1:10000000:0000000000000000000000 ");
    read (L, checknum, checkbool);
    assert (not checkbool) report "Readb2 not reported error condition"
      severity error;
    checkslv := to_slv (checknum);
    report_error ("Error in Readb2",
                  checkslv,
                  "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
    deallocate (L);
    -- Test the aliases
    L := new string'(" 11000000000000000000000000000000 ");
    bread (L, checknum);
    report_error ("Error in bRead",
                  checknum,
                  to_float(-2));
    deallocate (L);
    L := new string'(" 11000000000000000000000000000000 ");
    bread (L, checknum, checkbool);
    assert (checkbool) report "bRead reported error condition" severity error;
    report_error ("Error in bRead bool",
                  checknum,
                  to_float(-2));
    deallocate (L);
    -- write test
    L         := null;
    checknum  := to_float(42);
    write (L, checknum);
    L2 := new string'("0:10000100:01010000000000000000000");
    report_error ("write(" & to_string (checknum) & ")", L, L2);
    checknum  := "0100000000000000000000000-ZUXWHL";
    write (L, checknum);
    L2 := new string'("0:10000000:0000000000000000-ZUXWHL");
    report_error ("to_string(" & to_string (checknum) & ")", L, L2);
    checknum  := to_float(42);
    bwrite (L, checknum);
    L2 := new string'("0:10000100:01010000000000000000000");
    report_error ("bwrite(" & to_string (checknum) & ")", L, L2);
    -- to_hstring test
    checknum   := to_float(42);
    write (L1, to_hstring (checknum));
    L2 := new string'("42280000");
    report_error ("to_hstring(" & to_string (checknum) & ")", L1, L2);
    checknum   := "0100ZZZZ----UUUUXXXXWWWWHHHHLLLL";
    write (L1, to_hstring (checknum));
    L2 := new string'("4ZXXXXF0");
    report_error ("to_hstring(" & to_string (checknum) & ")", L1, L2);
    -- hwrite test
    L          := null;
    checknum   := to_float(42);
    hwrite (L, checknum);
    L2 := new string'("42280000");
    report_error ("write (" & to_string (checknum) & ")", L, L2);

    checknum   := "0100ZZZZ----UUUUXXXXWWWWHHHHLLLL";
    hwrite (L, checknum);
    L2 := new string'("4ZXXXXF0");
    report_error ("write (" & to_string (checknum) & ")", L, L2);
    -- to_ostring test
    checknum   := to_float(42);
    write (L1, to_ostring (checknum));
    L2 := new string'("10212000000");
    report_error ("to_ostring(" & to_string (checknum) & ")", L1, L2);
    checknum   := "01000ZZZ---UUUWWWXXXHHHLLLZZZ111";
    write (L1, to_ostring (checknum));
    L2 := new string'("10ZXXXX70Z7");
    report_error ("to_ostring(" & to_string (checknum) & ")", L1, L2);
    -- owrite test
    checknum   := to_float(42);
    owrite (L1, checknum);
    L2 := new string'("10212000000");
    report_error ("owrite(" & to_string (checknum) & ")", L1, L2);
    checknum   := "01000ZZZ---UUUWWWXXXHHHLLLZZZ111";
    owrite (L1, checknum);
    L2 := new string'("10ZXXXX70Z7");
    report_error ("owrite(" & to_string (checknum) & ")", L1, L2);
    -- hread test
    L := new string'("42280000");
    hread (L, checknum, checkbool);
    assert (checkbool) report "hRead reported error condition" severity error;
    report_error ("Error in hRead bool",
                  checknum,
                  to_float(42));
    deallocate (L);
    L := new string'("00000000");
    hread (L, checknum, checkbool);
    assert (checkbool) report "hRead reported error condition" severity error;
    report_error ("Error in hRead bool",
                  checknum,
                  to_float(0));
    L := new string'("abcdef00");
    hread (L, checknum, checkbool);
    assert (checkbool) report "hRead reported error condition" severity error;
    report_error ("Error in hRead bool",
                  checknum,
                  "10101011110011011110111100000000");
    deallocate (L);
    L := new string'("abcd_ef00");
    hread (L, checknum, checkbool);
    assert (checkbool) report "hRead reported error condition" severity error;
    report_error ("Error in hRead_ bool",
                  checknum,
                  "10101011110011011110111100000000");
    deallocate (L);
    L := new string'("157.4de_f00");
    hread (L, checknum, checkbool);
    assert (checkbool) report "hRead. reported error condition" severity error;
    report_error ("Error in hRead. bool",
                  checknum,
                  "10101011101001101111011110000000");
    deallocate (L);
    L := new string'("1:57:4de_f00");
    hread (L, checknum, checkbool);
    assert (checkbool) report "hRead: reported error condition" severity error;
    report_error ("Error in hRead: bool",
                  checknum,
                  "10101011101001101111011110000000");
    deallocate (L);
    L := new string'("42280000");
    hread (L, checknum);
    report_error ("Error in hRead",
                  checknum,
                  to_float(42));
    deallocate (L);
    L := new string'("00000000");
    hread (L, checknum);
    report_error ("Error in hRead",
                  checknum,
                  to_float(0));
    L := new string'("abcdef00");
    hread (L, checknum);
    report_error ("Error in hRead bool",
                  checknum,
                  "10101011110011011110111100000000");
    deallocate (L);
    L := new string'("abcd_ef00");
    hread (L, checknum);
    report_error ("Error in hRead_",
                  checknum,
                  "10101011110011011110111100000000");
    deallocate (L);
    L := new string'("157.4de_f00");
    hread (L, checknum);
    report_error ("Error in hRead.",
                  checknum,
                  "10101011101001101111011110000000");
    deallocate (L);
    L := new string'("1:57:4de_f00");
    hread (L, checknum);
    report_error ("Error in hRead:",
                  checknum,
                  "10101011101001101111011110000000");
    deallocate (L);
    -- from_hstring test
    L := new string'("42280000");
    checknum := from_hstring (L.all);
    checknum1 := to_float(42);
    report_error ("from_hstring ("& L.all & ")", checknum, checknum1);
    deallocate (L);
    L := new string'("00000000");
    checknum := from_hstring (L.all);
    checknum1 := to_float(0);
    report_error ("from_hstring ("& L.all & ")", checknum, checknum1);
    deallocate (L);
    L := new string'("abcdef00");
    checknum := from_hstring (L.all);
    checknum1 := "10101011110011011110111100000000";
    report_error ("from_hstring ("& L.all & ")", checknum, checknum1);
    deallocate (L);
    -- oread test
    L := new string'("10212000000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead reported error condition" severity error;
    report_error ("Error in oRead bool",
                  checknum,
                  to_float(42));
    deallocate (L);
    L := new string'("102_120_0_0_000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead_ reported error condition" severity error;
    report_error ("Error in oRead_ bool",
                  checknum,
                  to_float(42));
    deallocate (L);
    L := new string'("00000000000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead reported error condition" severity error;
    report_error ("Error in oRead bool",
                  checknum,
                  to_float(0));
    deallocate (L);
    L := new string'("01234567000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead reported error condition" severity error;
    report_error ("Error in oRead bool",
                  checknum,
                  "00001010011100101110111000000000");
    deallocate (L);
    L := new string'("01_234_567_000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead reported error condition" severity error;
    report_error ("Error in oRead bool",
                  checknum,
                  "00001010011100101110111000000000");
    deallocate (L);
    L := new string'("0_24.34567_000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead. reported error condition" severity error;
    report_error ("Error in oRead. bool",
                  checknum,
                  "00001010001110010111011100000000");
    deallocate (L);
    L := new string'("4_24345.67_000");
    oread (L, checknum, checkbool);
    assert (not checkbool) report "oRead. in the wrong spot not reported" severity error;
    deallocate (L);
    L := new string'("0:024:34567_000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead: reported error condition" severity error;
    report_error ("Error in oRead: bool",
                  checknum,
                  "00001010001110010111011100000000");
    deallocate (L);
    L := new string'("1:024:34567_000");
    oread (L, checknum, checkbool);
    assert (checkbool) report "oRead-: reported error condition" severity error;
    report_error ("Error in oRead-: bool",
                  checknum,
                  "10001010001110010111011100000000");
    deallocate (L);
    L := new string'("00000000000");
    oread (L, checknum);
    report_error ("Error in oRead",
                  checknum,
                  to_float(0));
    deallocate (L);
    L := new string'("01234567000");
    oread (L, checknum);
    report_error ("Error in oRead",
                  checknum,
                  "00001010011100101110111000000000");
    deallocate (L);
    L := new string'("10212000000");
    checknum := from_ostring (L.all);
    checknum1 := to_float(42);
    report_error ("from_ostring ("& L.all & ")", checknum, checknum1);
    deallocate (L);    
    L := new string'("00000000000");
    checknum := from_ostring (L.all);
    checknum1 := to_float(0);
    report_error ("from_ostring ("& L.all & ")", checknum, checknum1);
    deallocate (L);
    L := new string'("01234567000");
    checknum := from_ostring (L.all);
    checknum1 := "00001010011100101110111000000000";
    report_error ("from_ostring ("& L.all & ")", checknum, checknum1);
    deallocate (L);
    L := new string'("102_120_0_0_000");
    oread (L, checknum);
    report_error ("Error in oRead w/ _ ",
                  checknum,
                  to_float(42));
    L := new string'("01_234_567_000");
    oread (L, checknum);
    report_error ("Error in oRead_ ",
                  checknum,
                  "00001010011100101110111000000000");
    deallocate (L);
    L := new string'("0_24.34567_000");
    oread (L, checknum);
    report_error ("Error in oRead.",
                  checknum,
                  "00001010001110010111011100000000");
    deallocate (L);
    if not quiet then
      report "Expect 4 oread errors here" severity note;
    L := new string'("0_24.34567_00");  -- short read
    oread (L, checknum);
    deallocate (L);
      L := new string'("4_24345.67_000");
       oread (L, checknum);
       deallocate (L);     
       L := new string'("4:_24345.67_000");
       oread (L, checknum);
       deallocate (L);
       L := new string'("1:24345:67_000");
       oread (L, checknum);
       deallocate (L);
    end if;

    L := new string'("0:024:34567_000");
    oread (L, checknum);
    report_error ("Error in oRead:",
                  checknum,
                  "00001010001110010111011100000000");
    deallocate (L);
    L := new string'("1:024:34567_000");
    oread (L, checknum);
    report_error ("Error in oRead-:",
                  checknum,
                  "10001010001110010111011100000000");
    deallocate (L);
    assert (quiet) report "I/O read test complete" severity note;
    L := new string'("00000000000");
    readtest_done <= true;
    wait;
  end process read_test;

  -- purpose: test the fixed point converstion
  fixedtest : process is
    -- purpose: reports an error
    procedure report_error (
      constant errmes   : in    string;      -- error message
      actual            : in ufixed;      -- data from algorithm
      expected : in    ufixed)  is  -- reference data
    variable L, X, Y : line;
  begin  -- function report_error
    assert actual = expected
      report errmes & CR
      & "Actual   " & to_string(actual) & " /= " & CR
      & "Expected " & to_string(expected)
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes   :  in   string;                    -- error message
    actual            : in sfixed;                    -- data from algorithm
    expected :  in   sfixed)  is                -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & CR
      & "Actual   " & to_string(actual) & " /= " & CR
      & "Expected " & to_string(expected)
      severity error;
    return;
  end procedure report_error;
  subtype  ufixed7 is ufixed (3 downto -3);           -- 7 bit
  subtype  ufixed16 is ufixed (7 downto -8);          -- 16 bit
  subtype  sfixed7 is sfixed (3 downto -3);           -- 7 bit
  subtype  sfixed16 is sfixed (7 downto -8);          -- 16 BIT
  variable check7uf1, check7uf2, check7uf : ufixed7;
  variable check16uf1, check16uf2         : ufixed16;
  variable check7sf1, check7sf2, check7sf : sfixed7;
  variable check16sf1, check16sf2         : sfixed16;
  variable checknum, checknum1            : float32;     -- Floating point output
  begin
    wait until start_fixedtest;
    checknum  := "00000000000000000000000000000000";  -- 0
    check7uf1 := to_ufixed (checknum, check7uf1'high, check7uf1'low);
    check7uf  := "0000000";
    report_error ("to_ufixed 0 miscompare",
                  check7uf1,
                  check7uf);
    checknum  := "01000000000000000000000000000000";  -- 2
    check7uf1 := to_ufixed (checknum, check7uf1'high, check7uf1'low);
    check7uf  := "0010000";
    report_error ("to_ufixed 2 miscompare",
                  check7uf1,
                  check7uf);
    checknum  := "01000000110100000000000000000000";  -- 6.5
    check7uf1 := to_ufixed (checknum, check7uf1'high, check7uf1'low);
    check7uf  := "0110100";
    report_error ("to_ufixed 6.5 miscompare",
                  check7uf1,
                  check7uf);
    checknum   := to_float (42);
    check16uf1 := to_ufixed (checknum, check16uf1'high, check16uf1'low);
    check16uf2 := to_ufixed (42, check16uf1'high, check16uf1'low);
    report_error ("to_ufixed 42 miscompare",
                  check16uf1,
                  check16uf2);
    checknum  := "00000000000000000000000000000000";  -- 0
    check7sf1 := to_sfixed (checknum, check7sf1'high, check7sf1'low);
    check7sf  := "0000000";
    report_error ("to_sfixed 0 miscompare",
                  check7sf1,
                  check7sf);
    checknum  := "01000000000000000000000000000000";  -- 2
    check7sf1 := to_sfixed (checknum, check7sf1'high, check7sf1'low);
    check7sf  := "0010000";
    report_error ("to_sfixed 2 miscompare",
                  check7sf1,
                  check7sf);
    checknum  := "01000000110100000000000000000000";  -- 6.5
    check7sf1 := to_sfixed (checknum, check7sf1'high, check7sf1'low);
    check7sf  := "0110100";
    report_error ("to_sfixed 6.5 miscompare",
                  check7sf1,
                  check7sf);
    checknum   := "11000000110100000000000000000000";
    check16sf1 := to_sfixed (checknum, check16sf1'high, check16sf1'low);
    check16sf2 := "1111100110000000";                 -- -6.5
    report_error ("to_sfixed -6.5 miscompare",
                  check16sf1,
                  check16sf2);
    -- size_res functions
    checknum  := "00000000000000000000000000000000";  -- 0
    check7uf1 := to_ufixed (checknum, check7uf1);
    check7uf  := "0000000";
    report_error ("to_ufixed 0 size_res miscompare",
                  check7uf1,
                  check7uf);
    checknum  := "01000000000000000000000000000000";  -- 2
    check7uf1 := to_ufixed (checknum, check7uf1);
    check7uf  := "0010000";
    report_error ("to_ufixed 2 size_res miscompare",
                  check7uf1,
                  check7uf);
    checknum  := "01000000110100000000000000000000";  -- 6.5
    check7uf1 := to_ufixed (checknum, check7uf1);
    check7uf  := "0110100";
    report_error ("to_ufixed 6.5 size_res miscompare",
                  check7uf1,
                  check7uf);
    checknum   := to_float (42);
    check16uf1 := to_ufixed (checknum, check16uf1);
    check16uf2 := to_ufixed (42, check16uf1);
    report_error ("to_ufixed 42 size_res miscompare",
                  check16uf1,
                  check16uf2);
    checknum  := "00000000000000000000000000000000";  -- 0
    check7sf1 := to_sfixed (checknum, check7sf1);
    check7sf  := "0000000";
    report_error ("to_sfixed 0 size_res miscompare",
                  check7sf1,
                  check7sf);
    checknum  := "01000000000000000000000000000000";  -- 2
    check7sf1 := to_sfixed (checknum, check7sf1);
    check7sf  := "0010000";
    report_error ("to_sfixed 2 size_res miscompare",
                  check7sf1,
                  check7sf);
    checknum  := "01000000110100000000000000000000";  -- 6.5
    check7sf1 := to_sfixed (checknum, check7sf1);
    check7sf  := "0110100";
    report_error ("to_sfixed 6.5 size_res miscompare",
                  check7sf1,
                  check7sf);
    checknum   := "11000000110100000000000000000000";
    check16sf1 := to_sfixed (checknum, check16sf1);
    check16sf2 := "1111100110000000";                 -- -6.5
    report_error ("to_sfixed -6.5 size_res miscompare",
                  check16sf1,
                  check16sf2);
    -- to_float(ufixed)
    check7uf  := "0000000";
    checknum  := to_float (check7uf);
    checknum1 := "00000000000000000000000000000000";   -- 0
    report_error ("to_float 0 miscompare",
                  checknum,
                  checknum1);
    check7uf  := "0010000";
    checknum  := to_float (check7uf);
    checknum1 := "01000000000000000000000000000000";   -- 2
    report_error ("to_float 2 miscompare",
                  checknum,
                  checknum1);
    check7uf  := "0110100";
    checknum  := to_float (check7uf);
    checknum1 := "01000000110100000000000000000000";   -- 6.5
    report_error ("to_float 6.5 miscompare",
                  checknum,
                  checknum1);
    check16uf1 := to_ufixed (42, check16uf1'high, check16uf1'low);
    checknum   := to_float(check16uf1);
    checknum1  := to_float(42);
    report_error ("to_float 42 miscompare",
                  checknum, checknum1);
    check7sf  := "0000000";
    checknum  := to_float (check7sf);
    checknum1 := "00000000000000000000000000000000";   -- 0
    report_error ("to_float signed 0 miscompare",
                  checknum,
                  checknum1);    
    check7sf  := "0010000";
    checknum  := to_float (check7sf);
    checknum1 := "01000000000000000000000000000000";   -- 2
    report_error ("to_float signed 2 miscompare",
                  checknum,
                  checknum1);
    check7sf  := "0110100";
    checknum  := to_float (check7sf);
    checknum1 := "01000000110100000000000000000000";   -- 6.5
    report_error ("to_float signed 6.5 miscompare",
                  checknum,
                  checknum1);
    check16sf2 := "1111100110000000";                  -- -6.5
    checknum   := to_float (check16sf2);
    checknum1  := "11000000110100000000000000000000";  -- -6.5
    report_error ("to_float signed -6.5 miscompare",
                  checknum,
                  checknum1);
    check16sf2 := to_sfixed (42, check16sf2'high, check16sf2'low);
    checknum   := to_float (check16sf2);
    checknum1  := to_float(42);
    report_error ("to_float signed 42 miscompare",
                  checknum,
                  checknum1);
    assert (quiet) report "Fixed point number testing complete" severity note;
    fixedtest_done <= true;
    wait;
  end process fixedtest;

  divmodtest : process is
    constant bound              : INTEGER := 512;  -- 512
    variable ckr1, ckr2 : REAL;         -- real numbers
    variable sgn10, sgn4, res10, res10t : float32;  -- 32 bit floating point
  begin
    wait until start_divmodtest;
    -- Some targeted test cases
    ckr1 := 1.5;
    ckr2 := 3.0;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn10 mod sgn4;
    report_error ("1.5 mod 3", res10, to_float (ckr1 mod ckr2));
    res10 := sgn4 mod sgn10;
    report_error ("3 mod 1.5", res10, to_float (ckr2 mod ckr1));
    ckr1 := 1.5;
    ckr2 := 3.125;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn4 mod sgn10;
    report_error ("3.125 mod 1.5", res10, to_float (ckr2 mod ckr1)); 
    ckr1 := 40.33333333;
    ckr2 := 4.0;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn10 mod sgn4;
    res10t := "00111110101010101010101010000000";  -- shifted .3333
    report_error ("40.333 mod 4.0", res10, res10t);
    res10 := sgn4 mod sgn10;
    res10t := to_float (4);
    report_error ("4.0 mod 40.333", res10, res10t);
    ckr1 := 4.33333333;
    ckr2 := 4.0;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn10 mod sgn4;
    -- res10t := to_float (ckr1 mod ckr2);
    res10t := "00111110101010101010101010110000";  -- shifted 0.3333
    report_error ("4.333 mod 4.0", res10, res10t);
    res10 := sgn4 mod sgn10;
    res10t := to_float (4);
    -- res10t := to_float (ckr2 mod ckr1);
    report_error ("4.0 mod 4.333", res10, res10t);
    ckr1 := -4.33333333;
    ckr2 := 4.0;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn10 mod sgn4;
    -- res10t := to_float (ckr1 mod ckr2);
    res10t := "01000000011010101010101010101010";  -- shifted 3.6666
    report_error ("-4.333 mod 4.0", res10, res10t);
    res10 := sgn4 mod sgn10;
    res10t := "10111110101010101010101010110000";  -- shifted -0.3333
    report_error ("4.0 mod -4.333", res10, res10t);
    ckr1 := 4.33333333;
    ckr2 := -4.0;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn10 mod sgn4;
    res10t := "11000000011010101010101010101010";  -- shifted -3.6666
    report_error ("4.333 mod -4.0", res10, res10t);
    res10 := sgn4 mod sgn10;
    res10t := "00111110101010101010101010110000";  -- shifted 0.3333
    report_error ("-4.0 mod 4.333", res10, res10t);
    ckr1 := -4.33333333;
    ckr2 := -4.0;
    sgn10 := to_float(ckr1);
    sgn4 := to_float(ckr2);
    res10 := sgn10 mod sgn4;
    res10t := "10111110101010101010101010110000";  -- shifted -0.3333
    report_error ("-4.333 mod -4.0", res10, res10t);
    res10 := sgn4 mod sgn10;
    res10t := to_float (-4);
    report_error ("-4.0 mod -4.333", res10, res10t);
    -- loop copied from "numeric_std_tb1.vhd" to check the rem and mod functions
    for i in -bound to bound-1 loop
      sgn10 := to_float(i);
      for j in -8 to 7 loop
        next when j = 0;
        sgn4  := to_float(j);
        res10 := sgn10 rem sgn4;
        assert to_integer(res10) = i rem j
          report INTEGER'image(i) & " rem " & INTEGER'image(j) & " = "
          & to_string(res10) & " (" & integer'image(to_integer(res10))
          & ") not " & integer'image(i rem j)
          severity error;
      end loop;
    end loop;
    for i in -bound to bound-1 loop
      sgn10 := to_float(i);
      for j in -8 to 7 loop
        next when j = 0;
        sgn4  := to_float(j);
        res10 := sgn10 mod sgn4;
        assert to_integer(res10) = i mod j
          report INTEGER'image(i) & " mod " & INTEGER'image(j) & " = "
          & to_string(res10) & " (" & integer'image(to_integer(res10))
          & ") not " & integer'image(i mod j)
          severity error;
      end loop;
    end loop;
    -- large vs small
    sgn10 := to_float (500000000);          -- gt 2**23
    sgn4  := to_float (3);
    res10 := sgn10 rem sgn4;
    res10t := to_float (0);                 -- 500,000,000 rem 3 = 2
    report_error ("(32 bit overflow) 500,000,000 rem 3 (fails in REAL)",
                  res10, res10t);
    res10 := sgn4 rem sgn10;
    res10t := sgn4;                     -- if r > l return l
    report_error ("3 rem 500,000,000", res10, res10t);
    sgn10 := "00000000011000000000000000000000";       -- 2**-127 + 2**-128
    sgn4  := "00000000010000000000000000000000";       -- 2**-127
    res10 := sgn10 rem sgn4;
    res10t := "00000000001000000000000000000000";       -- 2**-128
    report_error ("denormal rem denormal", res10, res10t);
    assert (quiet) report "Div and Mod test complete" severity note;
    divmodtest_done <= true;
  end process divmodtest;

  -- purpose: test the normalize and break number routines
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  normtest : process is
    variable checknum, checknum1 : float32;
    variable checknum2, checknum3 : float32;
    variable frc, frc1, frc2, frc3 : ufixed (0 downto -fp_fraction_width);  -- fraction
    variable exp, exp1, exp2, exp3                     : SIGNED (fp_exponent_width-1 downto 0);  -- exp
    variable s, s1, s2, s3                             : STD_ULOGIC;  -- sign
    variable frcp                                      : ufixed (1 downto -fp_fraction_width);
    variable frcm : ufixed (3 downto -2*fp_fraction_width);  -- mult result
  begin
    wait until start_normtest;
    checknum  := "01000000110100000000000000000000";                  -- 6.5
    checknum1 := "01000000100000000000000000000000";                  -- 4
    break_number (arg   => checknum,
                  fract => frc,
                  expon => exp,
                  sign  => s);
    frc3 := "110100000000000000000000";     -- 1.625 in fixed point
    report_error ("6.5 break number", frc, frc3);
    exp3 := "00000001";                 -- remember, biased by -1
    assert (exp = exp3) report "6.5 exp break number " severity error;
    break_number (arg   => checknum1,
                  fract => frc1,
                  expon => exp1,
                  sign  => s1);
    frc3 := "100000000000000000000000";     -- 1.0 in fixed point
    report_error ("2.0 break number", frc1, frc3);
    exp3 := "00000001";                 -- remember, biased by -1
    assert (exp1 = exp3) report "2.0 exp break number " severity error;
    frcp := frc + frc1;                 -- Add the fractions together
    checknum2 := normalize (fract => frcp,
                            expon => exp3,  -- all the same at this point
                            sign  => '0');
    -- 6.5 + 4.0
    checknum3     := checknum + checknum1;
    report_error ("normalize 6.5 + 4.0", checknum2, checknum3);

    checknum  := "11000000110100000000000000000000";                  -- -6.5
    checknum1 := "01000010001010000000000000000000";    -- 42
    break_number (arg   => checknum1,
                  fract => frc1,
                  expon => exp1,
                  sign  => s1);
    frc3 := "110100000000000000000000";     -- 1.625 in fixed point
    report_error ("-6.5 break number", frc1, frc3);
    exp3 := "00000001";                 -- remember, biased by -1
    assert (exp1 = exp3) report "6.5 exp break number " severity error;
    break_number (arg   => checknum,
                  fract => frc,
                  expon => exp,
                  sign  => s);
    frc3 := "101010000000000000000000";     -- 1.3125 in fixed point
    report_error ("2.0 break number", frc, frc3);
    exp3 := "00000100";                 -- remember, biased by -1
    assert (exp = exp3) report "42.0 exp break number " severity error;
    frcm := frc * frc1;
    exp3 := exp + exp1 + 1;             -- +1 to make up for bias.
    s3 := s1 xor s;                     -- new sign
    checknum2 := normalize (fract => frcm,
                            expon => exp3,
                            sign => s3);
    checknum3 := checknum1 * checknum;
    report_error ("normalize -6.5 * 42", checknum2, checknum3);
    
    normtest_done <= true;
    wait;
  end process normtest;

  -- purpose: loop math test
  looptest : process is
    constant expon_base   : integer := 2**(fp_exponent_width-1) -1;  -- highest exponent
    variable checknum     : float32;       -- Floating point output
    variable checknum1    : float32;       -- Floating point output
    variable checknum2    : float32;       -- Floating point output
    variable checknum3    : float32;       -- Floating point output
    variable checkreal    : real;       -- real test
    variable checkreal2   : real;       -- real test
    variable seed1, seed2 : integer := 12345678;  -- Seed for random number
    variable inerations   : integer := 1000;      -- number of interations
  begin  -- process looptest

    wait until start_looptest;
    -- loop test
    addloop : for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**expon_base;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**expon_base;
      checknum1  := to_float(checkreal);
      if (checknum1(-4) = '1') then      -- randomly make it negative
        checknum1 := - checknum1;
      end if;
      checkreal := to_real(checknum1);   -- convert back for rounding.
      checknum2 := to_float(checkreal2);
      if (checknum2(-4) = '1') then      -- randomly make it negative
        checknum2 := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3  := to_float(checkreal+checkreal2);
      checknum   := checknum1 + checknum2;
      report_error_loop ("Add loop error",
                         i,
                         checknum,
                         checknum3);
    end loop addloop;
    subloop : for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**expon_base;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**expon_base;
      checknum1  := to_float(checkreal);
      if (checknum1(-4) = '1') then      -- randomly make it negative
        checknum1 := - checknum1;
      end if;
      checkreal := to_real(checknum1);   -- convert back for rounding.
      checknum2 := to_float(checkreal2);
      if (checknum2(-4) = '1') then      -- randomly make it negative
        checknum2 := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3  := to_float(checkreal - checkreal2);
      checknum   := checknum1 - checknum2;
      report_error_loop ("sub loop error",
                         i,
                         checknum,
                         checknum3);
    end loop subloop;
    multloop : for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**(expon_base/2);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(expon_base/2);
      checknum1  := to_float(checkreal);
      if (checknum1(-4) = '1') then      -- randomly make it negative
        checknum1 := - checknum1;
      end if;
      checkreal := to_real(checknum1);   -- convert back for rounding.
      checknum2 := to_float(checkreal2);
      if (checknum2(-4) = '1') then      -- randomly make it negative
        checknum2 := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3  := to_float(checkreal * checkreal2);
      checknum   := checknum1 * checknum2;
      report_error_loop ("mult loop error",
                         i,
                         checknum,
                         checknum3);
    end loop multloop;
    divloop : for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal  := checkreal * 2.0**expon_base;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(expon_base/2);
      checknum1  := to_float(checkreal);
      if (checknum1(-4) = '1') then      -- randomly make it negative
        checknum1 := - checknum1;
      end if;
      checkreal := to_real(checknum1);   -- convert back for rounding.
      checknum2 := to_float(checkreal2);
      if (checknum2(-4) = '1') then      -- randomly make it negative
        checknum2 := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3  := to_float(checkreal / checkreal2);
      checknum   := checknum1 / checknum2;
      report_error_loop ("div loop error",
                         i,
                         checknum,
                         checknum3);
    end loop divloop;
    assert (quiet) report "Loop testing completed" severity note;
    looptest_done <= true;
    wait;
  end process looptest;


  -- purpose: loop math test, for denormal numbers
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  looptest2 : process is
    constant expon_base   : integer := 2**(fp_exponent_width-1) -1;  -- highest exponent
    variable checknum     : float32;       -- Floating point output
    variable checknum1    : float32;       -- Floating point output
    variable checknum2    : float32;       -- Floating point output
    variable checknum3    : float32;       -- Floating point output
    variable checkreal    : real;       -- real test
    variable checkreal2   : real;       -- real test
    variable seed1, seed2 : integer := 87654321;  -- Seed for random number
    variable inerations   : integer := 1000;      -- number of interations
  begin  -- process looptest

    wait until start_looptest2;
    -- loop test
    addloop : for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal                              := checkreal * 2.0**expon_base;
      uniform (seed1, seed2, checkreal2);
      checkreal2                             := checkreal2 * 2.0**expon_base;
      checknum1                              := to_float(checkreal);
      checknum1 (fp_exponent_width downto 0) := (others => '0');     -- denormal
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1 := - checknum1;
      end if;
      checkreal                              := to_real(checknum1);  -- convert back for rounding.
      checknum2                              := to_float(checkreal2);
      checknum2 (fp_exponent_width downto 0) := (others => '0');     -- denormal
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2 := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3  := to_float(checkreal+checkreal2);
      checknum   := checknum1 + checknum2;
      report_error_loop ("Add loop2 error",
                         i,
                         checknum,
                         checknum3);
    end loop addloop;
    subloop : for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal                              := checkreal * 2.0**expon_base;
      uniform (seed1, seed2, checkreal2);
      checkreal2                             := checkreal2 * 2.0**expon_base;
      checknum1                              := to_float(checkreal);
      checknum1 (fp_exponent_width downto 0) := (others => '0');     -- denormal
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1 := - checknum1;
      end if;
      checkreal                              := to_real(checknum1);  -- convert back for rounding.
      checknum2                              := to_float(checkreal2);
      checknum2 (fp_exponent_width downto 0) := (others => '0');     -- denormal
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2 := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3  := to_float(checkreal - checkreal2);
      checknum   := checknum1 - checknum2;
      report_error_loop ("sub loop2 error",
                         i,
                         checknum,
                         checknum3);
    end loop subloop;
    -- Commented out because of rounding errors.  I'm creating a 32
    -- bit result which I then compare to a 64 bit result.  When you through
    -- denormal into the mix you get lots of shifted zeros.
    multloop: for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**(expon_base/2);
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(expon_base/2);
      checknum1 := to_float(checkreal);
      checknum1 (fp_exponent_width downto 0) := (others => '0');  -- denormal
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_float(checkreal2);
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3 := to_float( checkreal * checkreal2);
      checknum := checknum1 * checknum2;
      report_error_loop ("mult loop2 error",
                         i,
                         checknum,
                         checknum3);
    end loop multloop;
    divloop: for i in 0 to inerations loop
      uniform (seed1, seed2, checkreal);
      checkreal := checkreal * 2.0**expon_base;
      uniform (seed1, seed2, checkreal2);
      checkreal2 := checkreal2 * 2.0**(expon_base/2);
      checknum1 := to_float(checkreal);
      checknum1 (fp_exponent_width downto 0) := (others => '0');  -- denormal
      if (checknum1(-4) = '1') then     -- randomly make it negative
        checknum1  := - checknum1;
      end if;
      checkreal := to_real(checknum1);  -- convert back for rounding.
      checknum2 := to_float(checkreal2);
      checknum2 (fp_exponent_width downto 0) := (others => '0');  -- denormal
      if (checknum2(-4) = '1') then     -- randomly make it negative
        checknum2  := - checknum2;
      end if;
      checkreal2 := to_real(checknum2);  -- convert back for rounding
      checknum3 := to_float( checkreal / checkreal2);
      checknum := checknum1 / checknum2;
      report_error_loop ("div loop2 error",
                         i,
                         checknum,
                         checknum3);
    end loop divloop;
    assert (quiet) report "Denormal loop testing completed" severity note;
    looptest2_done <= true;
    wait;
  end process looptest2;
  
  -- purpose: Nan and infinity test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  noninftest: process is
    variable checknum     : float32;       -- Floating point output
    variable checknum1    : float32;       -- Floating point output
    variable checknum2    : float32;       -- Floating point output
    variable checknum3    : float32;       -- Floating point output
    variable checkreal    : real;       -- real test
    variable checkint   : integer;       -- int test
  begin
    wait until start_naninftest;
    -- Start with "+"
    checknum1 := pos_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 + checknum2;
    report_error ("pos_inf + 42", checknum, pos_inffp);
    checknum := checknum2 + checknum1;
    report_error ("42 + pos_inf", checknum, pos_inffp);
    checknum := checknum1 + checknum1;
    report_error ("pos_inf + pos_inf", checknum, pos_inffp);
    checknum1 := neg_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 + checknum2;
    report_error ("neg_inf + 42", checknum, neg_inffp);
    checknum := checknum2 + checknum1;
    report_error ("42 + neg_inf", checknum, neg_inffp);
    checknum := checknum1 + checknum1;
    report_error ("neg_inf + neg_inf", checknum, neg_inffp);
    checknum1 := from_string ("0:11111110:11111111111111111111111");  -- almost inf.
    checknum := checknum1 + checknum1;
    report_error ("almost inf + almost inf", checknum, pos_inffp);
    checknum1 := "11111111011111111111111111111111";  -- almost inf.
    checknum := checknum1 + checknum1;
    report_error ("almost -inf + almost -inf", checknum, neg_inffp);
    -- inf + inf = nan
    checknum1 := pos_inffp;
    checknum2 := neg_inffp;
    checknum := checknum1 + checknum2;
    report_error ("pos_inf + neg_inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 + checknum1;
    report_error ("neg_inf + pos_inf", to_slv(checknum), to_slv(qnanfp));    
    checknum1 := nanfp;
    checknum2 := to_float (42);
    checknum := checknum1 + checknum2;
    report_error ("nan + 42", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 + checknum1;
    report_error ("42 + nan", to_slv(checknum), to_slv(qnanfp));
    checknum1 := qnanfp;
    checknum2 := to_float (42);
    checknum := checknum1 + checknum2;
    report_error ("qnan + 42", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 + checknum1;
    report_error ("42 + qnan", to_slv(checknum), to_slv(qnanfp));
    -- "-"
    checknum1 := pos_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 - checknum2;
    report_error ("pos_inf - 42", checknum, pos_inffp);
    checknum := checknum2 - checknum1;
    report_error ("42 - pos_inf", checknum, neg_inffp);
    checknum := checknum1 - neg_inffp;
    report_error ("pos_inf - neg_inf", checknum, pos_inffp);
    checknum1 := neg_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 - checknum2;
    report_error ("neg_inf - 42", checknum, neg_inffp);
    checknum := checknum2 - checknum1;
    report_error ("42 - neg_inf", checknum, pos_inffp);
    checknum := neg_inffp - pos_inffp;
    report_error ("net_inf - pos_inf", checknum, neg_inffp);
    checknum1 := "01111111011111111111111111111111";  -- almost inf.
    checknum2 := "11111111011111111111111111111111";  -- almost -inf.
    checknum := checknum1 - checknum2;
    report_error ("almost inf - almost -inf", checknum, pos_inffp);
    checknum := checknum2 - checknum1;
    report_error ("almost -inf - almost +inf", checknum, neg_inffp);
    -- inf - neginf = nan
    checknum1 := pos_inffp;
    checknum2 := neg_inffp;
    checknum := checknum1 - checknum1;
    report_error ("pos_inf - pos_inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 - checknum2;
    report_error ("neg_inf - neg_inf", to_slv(checknum), to_slv(qnanfp));    
    checknum1 := nanfp;
    checknum2 := to_float (42);
    checknum := checknum1 - checknum2;
    report_error ("nan - 42", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 - checknum1;
    report_error ("42 - nan", to_slv(checknum), to_slv(qnanfp));
    checknum1 := qnanfp;
    checknum2 := to_float (42);
    checknum := checknum1 - checknum2;
    report_error ("qnan - 42", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 - checknum1;
    report_error ("42 - qnan", to_slv(checknum), to_slv(qnanfp));
    -- Start with "*"
    checknum1 := pos_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 * checknum2;
    report_error ("pos_inf * 42", checknum, pos_inffp);
    checknum := checknum2 * checknum1;
    report_error ("42 * pos_inf", checknum, pos_inffp);
    checknum := checknum1 * checknum1;
    report_error ("pos_inf * pos_inf", checknum, pos_inffp);
    checknum1 := neg_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 * checknum2;
    report_error ("neg_inf * 42", checknum, neg_inffp);
    checknum := checknum2 * checknum1;
    report_error ("42 * neg_inf", checknum, neg_inffp);
    checknum := checknum1 * checknum1;
    report_error ("neg_inf * neg_inf", checknum, pos_inffp);
    checknum1 := pos_inffp;
    checknum2 := neg_inffp;
    checknum := checknum1 * checknum2;
    report_error ("pos_inf * neg_inf", checknum, neg_inffp);
    checknum := checknum2 * checknum1;
    report_error ("neg_inf * pos_inf", checknum, neg_inffp);
    checknum1 := zerofp;
    checknum2 := neg_zerofp;
    checknum := checknum1 * checknum1;
    report_error ("+0 * +0", checknum, zerofp);
    checknum := checknum1 * checknum2;
    report_error ("+0 * -0", checknum, zerofp);
    checknum := checknum2 * checknum1;
    report_error ("-0 * +0", checknum, zerofp);
    checknum := checknum2 * checknum2;
    report_error ("-0 * -0", checknum, zerofp);
    checknum1 := "01111111011111111111111111111111";  -- almost inf.
    checknum := checknum1 * checknum1;
    report_error ("almost inf * almost inf", checknum, pos_inffp);
    checknum2 := "11111111011111111111111111111111";  -- almost -inf.
    checknum := checknum2 * checknum2;
    report_error ("almost -inf * almost -inf", checknum, pos_inffp);
    checknum := checknum2 * checknum1;
    report_error ("almost -inf * almost inf", checknum, neg_inffp);
    checknum := checknum1 * checknum2;
    report_error ("almost inf * almost -inf", checknum, neg_inffp);
    checknum1 := "01011111111111111111111111111111";  -- half inf.
    checknum := checknum1 * checknum1;
    report_error ("half inf * half inf", checknum, pos_inffp);
    checknum1 := "11011111111111111111111111111111";  -- half -inf.
    checknum := checknum1 * checknum1;
    report_error ("-half inf * -half inf", checknum, pos_inffp);
    -- zero * inf special case
    checknum1 := pos_inffp;
    checknum2 := zerofp;
    checknum := checknum1 * checknum2;
    report_error ("pos_inf * +0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 * checknum1;
    report_error ("+0 * pos_inf", to_slv(checknum), to_slv(qnanfp));
    checknum1 := neg_inffp;
    checknum2 := zerofp;
    checknum := checknum1 * checknum2;
    report_error ("neg_inf * +0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 * checknum1;
    report_error ("+0 * neg_inf", to_slv(checknum), to_slv(qnanfp));
    checknum1 := pos_inffp;
    checknum2 := neg_zerofp;
    checknum := checknum1 * checknum2;
    report_error ("pos_inf * -0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 * checknum1;
    report_error ("-0 * pos_inf", to_slv(checknum), to_slv(qnanfp));
    checknum1 := neg_inffp;
    checknum2 := neg_zerofp;
    checknum := checknum1 * checknum2;
    report_error ("neg_inf * -0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 * checknum1;
    report_error ("-0 * neg_inf", to_slv(checknum), to_slv(qnanfp));    
    checknum1 := nanfp;
    checknum2 := pos_inffp;
    checknum := checknum1 * checknum2;
    report_error ("nan * pos_inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 * checknum1;
    report_error ("pos_inf * nan", to_slv(checknum), to_slv(qnanfp));
    checknum1 := qnanfp;
    checknum2 := neg_inffp;
    checknum := checknum1 * checknum2;
    report_error ("qnan * neg_inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 * checknum1;
    report_error ("neg_inf * qnan", to_slv(checknum), to_slv(qnanfp));
    -- Start with "/"
    checknum1 := pos_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 / checknum2;
    report_error ("pos_inf / 42", checknum, pos_inffp);
    checknum := checknum2 / checknum1;
    report_error ("42 / pos_inf", checknum, zerofp);
    checknum := checknum1 / checknum1;
    report_error ("pos_inf / pos_inf", to_slv(checknum), to_slv(qnanfp));
    checknum1 := neg_inffp;
    checknum2 := to_float (42);
    checknum := checknum1 / checknum2;
    report_error ("neg_inf / 42", checknum, neg_inffp);
    checknum := checknum2 / checknum1;
    report_error ("42 / neg_inf", checknum, zerofp);
    checknum := checknum1 / checknum1;
    report_error ("neg_inf / neg_inf", to_slv(checknum), to_slv(qnanfp));
    checknum1 := "01111111011111111111111111111111";  -- almost inf.
    checknum2 := to_float (0.5);
    checknum := checknum1 / checknum2;
    report_error ("almost inf / 1/2", checknum, pos_inffp);
    checknum1 := "01011111111111111111111111111111";  -- half inf.
    checknum2 := "00000000010000000000000000000000";  -- 2**-127
    checknum := checknum1 / checknum2;
    report_error ("half inf / denormal", checknum, pos_inffp);
    checknum2 := "00000000100000000000000000000000";  -- 2**-126
    checknum := checknum1 / checknum2;
    report_error ("half inf / 2**-126", checknum, pos_inffp);
    -- inf / inf = nan
    checknum1 := pos_inffp;
    checknum2 := neg_inffp;
    checknum := checknum1 / checknum2;
    report_error ("pos_inf / neg_inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("neg_inf / pos_inf", to_slv(checknum), to_slv(qnanfp));
    -- 0 / 0
    checknum1 := zerofp;
    checknum2 := neg_zerofp;
    checknum := checknum1 / checknum1;
    report_error ("0 / 0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("-0 / 0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum1 / checknum2;
    report_error ("0 / -0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum2;
    report_error ("-0 / -0", to_slv(checknum), to_slv(qnanfp));
    -- X / 0
    if (not quiet) then
      report "Expect 8 divide by zero errors here" severity note;
      checknum1 := to_float (42);
      checknum2 := zerofp;
      checknum := checknum1 / checknum2;
      report_error ("42 / 0", checknum, pos_inffp);
      checknum1 := - to_float (42);
      checknum := checknum1 / checknum2;
      report_error ("-42 / 0", checknum, neg_inffp);
      checknum1 := to_float (42);
      checknum2 := neg_zerofp;
      checknum := checknum1 / checknum2;
      report_error ("42 / -0", checknum, neg_inffp);
      checknum1 := - to_float (42);
      checknum := checknum1 / checknum2;
      report_error ("-42 / -0", checknum, pos_inffp);
      checknum1 := pos_inffp;
      checknum2 := zerofp;
      checknum := checknum1 / checknum2;
      report_error ("+inf / 0", checknum, pos_inffp);
      checknum1 := neg_inffp;
      checknum := checknum1 / checknum2;
      report_error ("-inf / 0", checknum, neg_inffp);
      checknum1 := pos_inffp;
      checknum2 := neg_zerofp;
      checknum := checknum1 / checknum2;
      report_error ("+inf / -0", checknum, neg_inffp);
      checknum1 := neg_inffp;
      checknum := checknum1 / checknum2;
      report_error ("-inf / -0", checknum, pos_inffp);
    end if;
    -- nan
    checknum1 := nanfp;
    checknum2 := to_float (42);
    checknum := checknum1 / checknum2;
    report_error ("nan / 42", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("42 / nan", to_slv(checknum), to_slv(qnanfp));
    checknum1 := qnanfp;
    checknum2 := to_float (42);
    checknum := checknum1 / checknum2;
    report_error ("qnan / 42", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("42 / qnan", to_slv(checknum), to_slv(qnanfp));
    -- nan / 0
    checknum1 := nanfp;
    checknum2 := zerofp;
    checknum := checknum1 / checknum2;
    report_error ("nan / 0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("0 / nan", to_slv(checknum), to_slv(qnanfp));
    checknum1 := qnanfp;
    checknum2 := zerofp;
    checknum := checknum1 / checknum2;
    report_error ("qnan / 0", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("0 / qnan", to_slv(checknum), to_slv(qnanfp));
    -- nan / inf
    checknum1 := nanfp;
    checknum2 := pos_inffp;
    checknum := checknum1 / checknum2;
    report_error ("nan / pos_inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("pos_inf / nan", to_slv(checknum), to_slv(qnanfp));
    checknum1 := qnanfp;
    checknum2 := neg_inffp;
    checknum := checknum1 / checknum2;
    report_error ("qnan / -inf", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 / checknum1;
    report_error ("-inf / qnan", to_slv(checknum), to_slv(qnanfp));
    -- "rem"
    checknum1 := to_float (7.825);
    checknum2 := zerofp;
    checknum := checknum1 rem checknum2;
    report_error ("7.825 rem 0", to_slv(checknum), to_slv(qnanfp));
    checknum2 := neg_zerofp;
    checknum := checknum1 rem checknum2;
    report_error ("7.825 rem -0", to_slv(checknum), to_slv(qnanfp));
    checknum2 := to_float (7.825);
    checknum1 := pos_inffp;
    checknum := checknum1 rem checknum2;
    report_error ("inf rem 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum2 := neg_inffp;
    checknum := checknum1 rem checknum2;
    report_error ("-inf rem 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum1 := to_float (7.825);
    checknum2 := pos_inffp;
    checknum := checknum1 rem checknum2;
    report_error ("7.825 rem inf", checknum, zerofp);
    checknum2 := neg_inffp;
    checknum := checknum1 rem checknum2;
    report_error ("7.825 rem -inf", checknum, zerofp);
    -- nan check
    checknum1 := to_float (7.825);
    checknum2 := nanfp;    
    checknum := checknum1 rem checknum2;
    report_error ("nan rem 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 rem checknum1;
    report_error ("7.825 rem nan", to_slv(checknum), to_slv(qnanfp));
    checknum2 := qnanfp;    
    checknum := checknum1 rem checknum2;
    report_error ("qnan rem 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 rem checknum1;
    report_error ("7.825 rem qnan", to_slv(checknum), to_slv(qnanfp));
    -- "mod"
    checknum1 := to_float (7.825);
    checknum2 := zerofp;
    checknum := checknum1 mod checknum2;
    report_error ("7.825 mod 0", to_slv(checknum), to_slv(qnanfp));
    checknum2 := neg_zerofp;
    checknum := checknum1 mod checknum2;
    report_error ("7.825 mod -0", to_slv(checknum), to_slv(qnanfp));
    checknum2 := to_float (7.825);
    checknum1 := pos_inffp;
    checknum := checknum1 mod checknum2;
    report_error ("inf mod 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum2 := neg_inffp;
    checknum := checknum1 mod checknum2;
    report_error ("-inf mod 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum1 := to_float (7.825);
    checknum2 := pos_inffp;
    checknum := checknum1 mod checknum2;
    report_error ("7.825 mod inf", checknum, zerofp);
    checknum2 := neg_inffp;
    checknum := checknum1 mod checknum2;
    report_error ("7.825 mod -inf", checknum, zerofp);
    -- nan check
    checknum1 := to_float (7.825);
    checknum2 := nanfp;    
    checknum := checknum1 mod checknum2;
    report_error ("nan mod 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 mod checknum1;
    report_error ("7.825 mod nan", to_slv(checknum), to_slv(qnanfp));
    checknum2 := qnanfp;    
    checknum := checknum1 mod checknum2;
    report_error ("qnan mod 7.825", to_slv(checknum), to_slv(qnanfp));
    checknum := checknum2 mod checknum1;
    report_error ("7.825 mod qnan", to_slv(checknum), to_slv(qnanfp));
    -- Compare operations
    checknum1 := zerofp;
    checknum2 := neg_zerofp;
    assert (checknum1 = checknum1)
      report "0 = 0 returned false" severity error;
    assert (checknum1 = checknum2)
      report "0 = -0 returned false" severity error;
    assert (checknum2 = checknum1)
      report "-0 = 0 returned false" severity error;
    assert (checknum2 = checknum2)
      report "-0 = -0 returned false" severity error;
    assert (checknum1 <= checknum1)
      report "0 <= 0 returned false" severity error;
    assert (checknum1 <= checknum2)
      report "0 <= -0 returned false" severity error;
    assert (checknum2 <= checknum1)
      report "-0 <= 0 returned false" severity error;
    assert (checknum2 <= checknum2)
      report "-0 <= -0 returned false" severity error;
    assert (checknum1 >= checknum1)
      report "0 >= 0 returned false" severity error;
    assert (checknum1 >= checknum2)
      report "0 >= -0 returned false" severity error;
    assert (checknum2 >= checknum1)
      report "-0 >= 0 returned false" severity error;
    assert (checknum2 >= checknum2)
      report "-0 >= -0 returned false" severity error;
    assert not (checknum1 /= checknum1)
      report "0 /= 0 returned false" severity error;
    assert not (checknum1 /= checknum2)
      report "0 /= -0 returned false" severity error;
    assert not (checknum2 /= checknum1)
      report "-0 /= 0 returned false" severity error;
    assert not (checknum2 /= checknum2)
      report "-0 /= -0 returned false" severity error;
    assert not (checknum1 > checknum1)
      report "0 > 0 returned false" severity error;
    assert not (checknum1 > checknum2)
      report "0 > -0 returned false" severity error;
    assert not (checknum2 > checknum1)
      report "-0 > 0 returned false" severity error;
    assert not (checknum2 > checknum2)
      report "-0 < -0 returned false" severity error;
    assert not (checknum1 < checknum1)
      report "0 < 0 returned false" severity error;
    assert not (checknum1 < checknum2)
      report "0 < -0 returned false" severity error;
    assert not (checknum2 < checknum1)
      report "-0 < 0 returned false" severity error;
    assert not (checknum2 < checknum2)
      report "-0 < -0 returned false" severity error;
    checknum1 := nanfp;
    checknum2 := neg_zerofp;
    assert not (checknum1 = checknum2)
      report "nan = -0 returned true" severity note;
    assert not (checknum2 = checknum1)
      report "-0 = nan returned true" severity note;
    assert not (checknum1 = checknum1)
      report "nan = nan returned true" severity note;
    assert not (checknum1 < checknum2)
      report "nan < -0 returned true" severity note;
    assert not (checknum2 < checknum1)
      report "-0 < nan returned true" severity note;
    assert not (checknum1 < checknum1)
      report "nan < nan returned true" severity note;
    assert not (checknum1 > checknum2)
      report "nan > -0 returned true" severity note;
    assert not (checknum2 > checknum1)
      report "-0 > nan returned true" severity note;
    assert not (checknum1 > checknum1)
      report "nan > nan returned true" severity note;
    assert not (checknum1 <= checknum2)
      report "nan <= -0 returned true" severity note;
    assert not (checknum2 <= checknum1)
      report "-0 <= nan returned true" severity note;
    assert not (checknum1 >= checknum2)
      report "nan >= -0 returned true" severity note;
    assert not (checknum2 >= checknum1)
      report "-0 >= nan returned true" severity note;
    assert not (checknum1 >= checknum1)
      report "nan >= nan returned true" severity note;
    assert (checknum1 /= checknum2)
      report "nan /= -0 returned false" severity note;
    assert (checknum2 /= checknum1)
      report "-0 /= nan returned false" severity note;
    assert (checknum1 /= checknum1)
      report "nan /= nan returned false" severity note;
        checknum1 := qnanfp;
    checknum2 := neg_zerofp;
    assert not (checknum1 = checknum2)
      report "qnan = -0 returned true" severity note;
    assert not (checknum2 = checknum1)
      report "-0 = qnan returned true" severity note;
    assert not (checknum1 = checknum1)
      report "qnan = qnan returned true" severity note;
    assert not (checknum1 < checknum2)
      report "qnan < -0 returned true" severity note;
    assert not (checknum2 < checknum1)
      report "-0 < qnan returned true" severity note;
    assert not (checknum1 < checknum1)
      report "qnan < qnan returned true" severity note;
    assert not (checknum1 > checknum2)
      report "qnan > -0 returned true" severity note;
    assert not (checknum2 > checknum1)
      report "-0 > qnan returned true" severity note;
    assert not (checknum1 > checknum1)
      report "qnan > qnan returned true" severity note;
    assert not (checknum1 <= checknum2)
      report "qnan <= -0 returned true" severity note;
    assert not (checknum2 <= checknum1)
      report "-0 <= qnan returned true" severity note;
    assert not (checknum1 >= checknum2)
      report "qnan >= -0 returned true" severity note;
    assert not (checknum2 >= checknum1)
      report "-0 >= qnan returned true" severity note;
    assert not (checknum1 >= checknum1)
      report "qnan >= qnan returned true" severity note;
    assert (checknum1 /= checknum2)
      report "qnan /= -0 returned false" severity note;
    assert (checknum2 /= checknum1)
      report "-0 /= qnan returned false" severity note;
    assert (checknum1 /= checknum1)
      report "qnan /= qnan returned false" severity note;
    checknum1 := qnanfp;
    checknum2 := nanfp;
    assert not (checknum1 = checknum2)
      report "qnan = nan returned true" severity note;
    assert not (checknum2 = checknum1)
      report "nan = qnan returned true" severity note;
    assert not (checknum1 < checknum2)
      report "qnan < nan returned true" severity note;
    assert not (checknum2 < checknum1)
      report "nan < qnan returned true" severity note;
    assert not (checknum1 > checknum2)
      report "qnan > nan returned true" severity note;
    assert not (checknum2 > checknum1)
      report "nan > qnan returned true" severity note;
    assert not (checknum1 >= checknum2)
      report "qnan >= nan returned true" severity note;
    assert not (checknum2 >= checknum1)
      report "nan >= qnan returned true" severity note;
    assert not (checknum1 <= checknum2)
      report "qnan <= nan returned true" severity note;
    assert not (checknum2 <= checknum1)
      report "nan <= qnan returned true" severity note;
    assert (checknum1 /= checknum2)
      report "qnan = nan returned false" severity note;
    assert (checknum2 /= checknum1)
      report "nan /= qnan returned false" severity note;
    assert (quiet) report "Nan and infinity testing completed" severity note;
    naninftest_done <= true;
    wait;
  end process noninftest;

  -- purpose: subtraction boundary test
  sbtest: process is
    variable ck1, ck2, ck3, ck4, ck5 : float32;
    variable ckr1, ckr2, ckr3 : REAL;
  begin
    wait until start_sbtest;
--d5120ba3 5fb8661a 0 5fb86616 5fb86615 zzzzzzzz 00100000
    ck1 := from_hstring ("d5120ba3");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("5fb8661a");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("1) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("5fb86615");
    report_error ("1) subtraciton boundary expected", ck3, ck5);
--    ck5 := from_hstring ("5fb86615");
--    report_error ("1) subtraciton boundary expected 1", ck3, ck5);
--3d1a52a4 38326219 0 3d1a7f3c 3d1a7f3d zzzzzzzz 00100000
    ck1 := from_hstring ("3d1a52a4");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("38326219");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("2) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("3d1a7f3d");
    report_error ("2) subtraciton boundary expected", ck3, ck5);
--    ck5 := from_hstring ("5fb86615");
--    report_error ("1) subtraciton boundary expected 1", ck3, ck5);
--82a388c2 8dcf6c9e 0 8dcf6ca0 8dcf6ca1 zzzzzzzz 00100000
    ck1 := from_hstring ("82a388c2");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("8dcf6c9e");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("3) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("8dcf6ca1");
    report_error ("3) subtraciton boundary expected", ck3, ck5);
--774710a0 ec24e7d8 0 7747109e 7747109d zzzzzzzz 00100000
    ck1 := from_hstring ("774710a0");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("ec24e7d8");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("4) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("7747109d");
    report_error ("4) subtraciton boundary expected", ck3, ck5);
--0c32085e 07b50d1e 0 0c3262e4 0c3262e5 zzzzzzzz 00100000
    ck1 := from_hstring ("0c32085e");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("07b50d1e");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("5) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("0c3262e5");
    report_error ("5) subtraciton boundary expected", ck3, ck5);
--95fa000a 1eb542f8 0 1eb542ba 1eb542b9 zzzzzzzz 00100000
    ck1 := from_hstring ("95fa000a");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("1eb542f8");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("6) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("1eb542b9");
    report_error ("6) subtraciton boundary expected", ck3, ck5);
--d13b80bf 4e70b664 0 d137bde6 d137bde5 zzzzzzzz 00100000
    ck1 := from_hstring ("d13b80bf");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("4e70b664");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("7) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("d137bde5");
    report_error ("7) subtraciton boundary expected", ck3, ck5);
--f3eb464a 6ebfd21d 0 f3eb1656 f3eb1655 zzzzzzzz 00100000
    ck1 := from_hstring ("f3eb464a");
--    ckr1 := to_real (ck1);
    ck2 := from_hstring ("6ebfd21d");
--    ckr2 := to_real (ck2);
    ck3 := ck1 + ck2;
--    ckr3 := ckr1 + ckr2;
--    ck4 := to_float (ckr3);
--    report_error ("8) subtraction boundary real", ck3, ck4);
    ck5 := from_hstring ("f3eb1655");
    report_error ("8) subtraciton boundary expected", ck3, ck5);
    assert (quiet) report "Subtraction boundary test completed" severity note;
    sbtest_done <= true;
  end process sbtest;


end architecture testbench;
