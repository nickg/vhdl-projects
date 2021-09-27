-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the "fphdl_pkg" package.
-- This test uses the "fphdl_pkg_small" to test special lengths and
-- modes in the floating point package.
--   modification history : Last Modified $Date: 2007-09-12 08:58:36-04 $
--   Version $Id: test_fphdl.vhdl,v 1.3 2007-09-12 08:58:36-04 l435385 Exp $
-- --------------------------------------------------------------------

------------------------------------------------------------------------
-- 7 bit floating point number (Smallest fp number representable) definition:
-- 0 000 000
-- 3 210 123
-- S EEE FFF
------------------------------------------------------------------------

--%%% Uncomment the following code and REMOVE the file "float_roundneg_pkg.vhd"
--library ieee;
--use ieee.fixed_pkg.all;
--package float_roundneg_pkg is new ieee.float_generic_pkg
--  generic map (
--    float_round_style => round_neginf,
--    float_denormalize => false,
--    float_check_error => false,
--    float_guard_bits => 0,
--    NO_WARNING => false);

entity test_fphdl is
  generic (
    quiet : BOOLEAN := false);          -- run quietly 
end entity test_fphdl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
use work.float_roundneg_pkg.all;
architecture testbench of test_fphdl is
  alias fp32 is float32;                 -- 32 bit fp
  subtype fp16a is float (6 downto -9);                 -- 16 bit fp
  subtype fp7 is float(3 downto -3);                    -- 7 bit fp
  constant zero0fp7 : fp7 := zerofp(3, 3);  -- zero
  subtype  fp17a is float (6 downto -11);             -- 17a

  constant zero0   : fp32 := zerofp;      -- positive zero
  constant negzero : fp32 := neg_zerofp;  -- negative zero
  constant inf     : fp32 := pos_inffp;   -- infinity
  constant neginf  : fp32 := neg_inffp;   -- -infinity
  constant qnan    : fp32 := qnanfp;      -- quiet NAN
  constant snan    : fp32 := nanfp;       -- signal NAN

  -- purpose: converts an fp17a to an fp16a
  function resize (
    arg : float)                        -- input
    return fp16a is
    variable result : fp16a;            -- result
  begin  -- function resize
    result := resize (
      arg            => arg,
      exponent_width => result'high,
      fraction_width => -result'low,
      denormalize    => true,
      denormalize_in => true,
      round_style    => round_nearest);
    return result;
  end function resize;

  -- purpose: reports an error
  procedure report_error (
    constant errmes   : in string;      -- error message
    actual            : in float;       -- data from algorithm
    constant expected : in float)  is   -- reference data
  begin  -- function report_error
    assert (actual = expected) report errmes & " miscompare" & CR
      & "Actual   " & to_string(actual)
      & " (" & real'image(to_real(actual)) & ") /= " & CR
      & "Expected " & to_string(expected)
      & " (" & real'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  procedure report_error (
    constant errmes   : in string;                -- error message
    actual            : in std_logic_vector;      -- data from algorithm
    constant expected : in std_logic_vector)  is  -- reference data
    variable L : line;
  begin  -- function report_error
    write (L, errmes);
    write (L, " miscompare" & CR);
    write (L, string'("Actual   "));
    write (L, actual);
    write (L, CR);
    write (L, string'("Expected "));
    write (L, expected);
    assert (actual = expected) report L.all
      severity error;
    deallocate (L);
    return;
  end procedure report_error;

  function reverse (
    inpvec : std_logic_vector (0 to 31))
    return fp32 is
    variable result : fp32;
  begin
    for i in 0 to 31 loop
      result (i-23) := inpvec(i);
    end loop;  -- i
    return result;
  end function reverse;
  signal start_booltest, booltest_done       : BOOLEAN := false;
  signal start_logictest, logictest_done     : BOOLEAN := false;
  signal start_reduce_test, reduce_test_done : BOOLEAN := false;  -- reduce
  signal start_mixedmath, mixedmath_done : BOOLEAN := false;  -- mixed math test
begin  -- architecture testbench

  -- purpose: Main test process
  tester : process is
    variable checknum               : fp32;  -- Floating point output
    variable checknum2              : fp32;  -- Floating point output
    variable checknum3              : fp32;  -- Floating point output
    variable checkint               : integer;                  -- integer test
    variable checkreal              : real;  -- real test
    variable checkreal2             : real;  -- real test
    variable checkuns               : unsigned (15 downto 0);   -- unsigned test
    variable checksign              : signed (8 - 1 downto 0);  -- check of signed
    variable checkslv               : std_logic_vector (6 downto 0);
    variable ck7, ck72, ck73, ck7ck : fp7;   -- fp7 numbers
    variable X                      : line;  -- line of output
    variable fp16, fp16b            : fp16a;                    -- rounding type
    variable fp17                   : fp17a;                    -- check type
  begin  -- process tester
    -- 7 bit floating point test
    ck7      := (others => '0');
    checkint := to_integer(ck7);        -- 0
    assert (checkint = 0)
      report "fp7 0 miscompare " & integer'image (checkint) severity error;
    ck7      := "0101000";              -- 4
    checkint := to_integer (ck7);
    assert (checkint = 4)
      report "fp7 4 miscompare " & integer'image (checkint) severity error;
    ck7      := "0100000";              -- 2
    checkint := to_integer (ck7);
    assert (checkint = 2)
      report "fp7 4 miscompare " & integer'image (checkint) severity error;
    ck7       := "0101101";             -- 6.5
    checkreal := to_real (ck7);
    assert (checkreal = 6.5)
      report "fp7 6.5 miscompare " & real'image (checkreal) severity error;
    ck7       := "0000100";             -- 
    checkreal := to_real (ck7);
    assert (checkreal = 0.1875)
      report "fp7 0.1875 miscompare " & real'image (checkreal) severity error;
    ck7       := "0000001";             -- 
    checkreal := to_real (ck7);
    assert (checkreal = 0.140625)
      report "fp7 0.03125 miscompare " & real'image (checkreal) severity error;
    ck7       := "0110111";             -- 
    checkreal := to_real (ck7);
    assert (checkreal = 15.0)
      report "fp7 15 miscompare " & real'image (checkreal) severity error;
    checkint  := 0;
    ck7       := to_float(checkint, 3, 3);
    ck7ck     := (others => '0');       -- 0
    report_error ("to_fp7 0 miscompare", ck7, ck7ck);
    checkint  := 7;
    ck7       := to_float(checkint, ck7);
    ck7ck     := "0101110";             -- 7
    report_error ("to_fp7 7 miscompare", ck7, ck7ck);
    checkint  := -7;
    ck7       := to_float(checkint, zero0fp7);
    ck7ck     := "1101110";             -- -7
    report_error ("to_fp7 -7 miscompare", ck7, ck7ck);
    checkint  := 15;
    ck7       := to_float(checkint, ck7);
    ck7ck     := "0110111";             -- 15
    report_error ("to_fp7 15 miscompare", ck7, ck7ck);
    checkreal := 15.0;
    ck7       := to_float(checkreal, ck7);
    report_error ("to_fp7 15.0 miscompare", ck7, ck7ck);
    checkint  := 16;
    checkreal := 16.0;
    ck7       := to_float(checkreal, ck7);
    ck7ck     := "0111000";             -- infinity
    report_error ("to_fp7 real INF miscompare", ck7, ck7ck);
    ck7       := to_float(checkint, ck7);
    report_error ("to_fp7 int INF miscompare", ck7, ck7ck);
    checkreal := 15.5;
    ck7       := to_float(checkreal, ck7);
    ck7ck     := "0110111";             -- 15
    report_error ("to_fp7 15.5 = 15 miscompare", ck7, ck7ck);
    ck72      := "0100000";             -- 2
    ck73      := "0101000";             -- 4
    ck7       := ck72 + ck73;
    ck7ck     := "0101100";
    report_error ("FP7 2+4=6 miscompare",
                   ck7,
                   ck7ck);
    ck72 := "0100000";                  -- 2
    ck7  := ck72 + zero0fp7;
    report_error ("FP7 2+0=2 miscompare",
                   ck7,
                   ck72);
    ck72 := "0100000";                  -- 2
    ck7  := zero0fp7 + ck72;
    report_error ("FP7 0+0=2 miscompare",
                   ck7,
                   ck72);
    ck7 := zero0fp7 + zero0fp7;
    report_error ("FP7 0+0=0 miscompare",
                   ck7,
                   zero0fp7);
    ck7 := zero0fp7 - zero0fp7;
    report_error ("FP7 0-0=0 miscompare",
                   ck7,
                   zero0fp7);
    ck72 := "0100000";                  -- 2
    ck7  := ck72 * zero0fp7;
    report_error ("FP7 2*0=0 miscompare",
                   ck7,
                   zero0fp7);
    ck7 := zero0fp7 * ck72;
    report_error ("FP7 2*0=0 miscompare",
                   ck7,
                   zero0fp7);
    ck7 := zero0fp7 * zero0fp7;
    report_error ("FP7 0*0=0 miscompare",
                   ck7,
                   zero0fp7);
--    ck7 := "1111000";                   -- negative infinity
--    ck73 := "0111000";                  -- positive infinity
--    checkint := 0;
--    nextafterloop: while (ck7 /= ck73) loop
--      ck7 := nextafter (ck7, ck73);
--      checkreal := to_real (ck7);
--      write (X, string'(" Number "));
--      checkint := checkint + 1;
--      write (X, checkint);
--      write (X, string'(" "));
--      checkslv := to_slv (ck7);
--      write (X, checkslv);
--      write (X, string'(" = "));
--      write (X, real'image(checkreal));
--      writeline (output, X);
--    end loop nextafterloop;
    ck7 := "0110111";                   -- 15
    checksign := to_signed (15, checksign'length);
    intloop: while ck7 /= neg_inffp(ck7) loop
      checkint := to_integer (ck7);
      assert checkint = checksign
        report "to_integer (" & to_string(ck7) & ") returned "
        & INTEGER'image(to_integer(checksign)) severity error;
      ck7 := ck7 - 1;
      checksign := checksign - 1;
    end loop intloop;

    fp17  := "000000011111111111";      -- denormal
    fp16  := resize (fp17, fp16);
    fp16b := "0000000111111111";       -- If positive don't round
    report_error ("resize to non-denormal error",
                  fp16,
                  fp16b);
    fp17  := "100000011111111111";      -- negative denormal
    fp16  := resize (fp17, fp16);
    fp16b := "1000001000000000";        -- If negative, round.
    report_error ("resize to -non-denormal error",
                  fp16,
                  fp16b);

    checknum := "00000000000000000000000000000000";
    checkint := to_integer (checknum);
    assert (checkint = 0) report "+0 test miscompare "
      & integer'image (checkint) severity error;
    checknum := "10000000000000000000000000000000";
    checkint := to_integer (checknum);
    assert (checkint = 0) report "-0 test miscompare "
      & integer'image (checkint) severity error;
    checknum := "01000000000000000000000000000000";
    checkint := to_integer (checknum);
    assert (checkint = 2) report "2 test miscompare "
      & integer'image (checkint) severity error;
    checknum := "11000000000000000000000000000000";
    checkint := to_integer (checknum);
    assert (checkint = -2) report "-2 test miscompare "
      & integer'image (checkint) severity error;
    checknum  := "01000000000000000000000000000000";
    checkreal := to_real (checknum);
    assert (checkreal = 2.0) report "2.0 test miscompare "
      & real'image (checkreal) severity error;
    checknum  := reverse("00000000000000000000101100000010");
    checkreal := to_real (checknum);
    assert (checkreal = 6.5) report "6.5 test miscompare "
      & real'image (checkreal) severity error;
    checknum  := reverse("00000000000000000000101100000011");
    checkreal := to_real (checknum);
    assert (checkreal = -6.5) report "-6.5 test miscompare "
      & real'image (checkreal) severity error;
    checknum  := reverse("00000000000000000000000001111100");
    checkreal := to_real (checknum);
    assert (checkreal = 0.125) report "0.125 test miscompare "
      & real'image (checkreal) severity error;
    checknum := reverse("00000000000000000001010001000010");
    checkint := to_integer (checknum);
    assert (checkint = 42) report "42 test miscompare "
      & integer'image (checkint) severity error;
    checknum  := reverse("00000000000000000000000100000000");
    checkreal := to_real (checknum);
    assert (checkreal = 2.0**(-126)) report "2**-126 test miscompare "
      & real'image (checkreal) severity error;

    checknum  := reverse("00000000000000000000111011111110");
    checkreal := to_real (checknum);
    assert (checkreal = (1.875*(2.0**127))) report "3.19E38 test miscompare "
      & real'image (checkreal) severity error;
    -- Extended floating point test
    checknum  := reverse("00000000000000000000001000000000");
    checkreal := to_real (checknum);
    assert (checkreal = (2.0**(-127))+(2.0**(-128))) report "2**-127 non denormal test miscompare "
      & real'image (checkreal) & " \= "
      & real'image ((2.0**(-127))+(2.0**(-128))) severity error;
    checknum  := reverse("10000000000000000000000000000000");
    checkreal := to_real (checknum);
    assert (checkreal = (2.0**(-127))+(2.0**(-150))) report "2**-149 non denormal test miscompare "
      & real'image (checkreal) & " \= "
      & real'image ((2.0**(-127))+(2.0**(-150))) severity error;
    checknum := "01001100000011001011110001001111";
    checkint := to_integer (checknum);
    assert (checkint = 36892988)        -- nearest 36892987
      report "36892987 miscompare "
      & integer'image (checkint) severity error;
    checknum := "01001100000011001011110001010000";
    checkint := to_integer (checknum);
    assert (checkint = 36892992)        -- nearest 36892990
      report "36892990 miscompare "
      & integer'image (checkint) severity error;
--    checknum := "01001111000000000000000000000000";  -- Maximum integer
--    checkint := to_integer (arg => checknum);
--    assert (checkint = integer'high)    -- maximum integer in 32 bit FP mode
--      report "2**31 miscompare " & integer'image(checkint) severity error;

    -- Check to integer to floating point conversion
    checkint := 0;
    checknum := to_float (checkint);
    report_error ("FP +0",
                  checknum, zero0);
    checkint  := 2;
    checknum  := to_float (checkint);
    checknum2 := "01000000000000000000000000000000";
    report_error ("FP +2",
                  checknum, checknum2);
    checkint  := -2;
    checknum  := to_float (checkint);
    checknum2 := "11000000000000000000000000000000";
    report_error ("FP -2", checknum, checknum2);
    checkreal := 6.5;
    checknum  := to_float (checkreal);
    report_error ("FP 6.5 test", checknum,
                  reverse("00000000000000000000101100000010"));
    checkreal := -6.5;
    checknum  := to_float (checkreal);
    report_error ("FP -6.5 test",
                  checknum, reverse("00000000000000000000101100000011"));
    checkreal := 0.125;
    checknum  := to_float (checkreal);
    report_error ("FP 0.125 test",
                  checknum, reverse("00000000000000000000000001111100"));
    checkint := 42;
    checknum := to_float (checkint);
    report_error ("FP 42",
                  checknum, reverse("00000000000000000001010001000010"));
    checkreal := 2.0**(-126);
    checknum  := to_float (checkreal);
    report_error ("FP 2**-126",
                  checknum, reverse("00000000000000000000000100000000"));
    checkreal := (1.875*(2.0**127));
    checknum  := to_float (checkreal);
    report_error ("FP 1.875*(2**127)",
                  checknum, reverse("00000000000000000000111011111110"));
    checkreal := 2.0**128;
    checknum  := to_float (checkreal);
    report_error ("+infinity", checknum, inf);
    -- Signed and unsigned
    checksign := to_signed (-42, checksign'high + 1);
    checknum  := to_float (checksign);
    report_error ("FP signed -42 test",
                  checknum, reverse("00000000000000000001010001000011"));
    checkuns := to_unsigned (42, checkuns'high + 1);
    checknum := to_float (checkuns);
    report_error("FP unsigned 42 test",
                  checknum, reverse("00000000000000000001010001000010"));
    checkint := 36892987;               -- comes out uneven
    checknum := to_float (checkint);
    report_error ("FP unsigned 36892987 test ",
                   checknum, fp32'("01001100000011001011110001001110"));
    checkint  := 36892990;
    checknum  := to_float (checkint);
    checknum2 := "01001100000011001011110001001111";
    report_error ("FP unsigned 36892990 test miscompare",
                   checknum, checknum2);
    checkreal := 36892987.0;            -- comes out uneven
    checknum  := to_float (checkreal);
    checknum2 := "01001100000011001011110001001110";
    report_error ("FP unsigned 36892987.0 test miscompare",
                  checknum, checknum2);
    checkreal := 36892990.0;
    checknum  := to_float (checkreal);
    checknum2 := "01001100000011001011110001001111";
    report_error ("FP unsigned 36892990.0 test miscompare",
                   checknum, checknum2);
    checkint  := 2147483645;
    checknum  := to_float (checkint);
    checknum2 := "01001110111111111111111111111111";
    report_error ("FP unsigned maxint -2 test miscompare",
                   checknum, checknum2);
    checkreal := 2147483645.0;
    checknum  := to_float (checkreal, zero0);
    checknum2 := "01001110111111111111111111111111";
    report_error ("FP unsigned maxint -2.0 test miscompare",
                   checknum, checknum2);

    -- Extended floating point test
    checkreal := 2.0**(-127);
    checknum  := to_float (checkreal, checknum'high, -checknum'low);
    assert (checknum = zero0)
      report "FP 2**-127 miscompare" severity error;
    checkreal := 2.0**(-149);
    checknum  := to_float (checkreal);
    assert (checknum = zero0)
      report "FP 2**-149 miscompare" severity error;
    checkreal := 0.875;
    checknum  := to_float (checkreal);
    assert (checknum = reverse("00000000000000000000011011111100"))
      report "FP 0.875 miscompare" severity error;
    checkreal := -0.875;
    checknum  := to_float (checkreal);
    assert (checknum = reverse("00000000000000000000011011111101"))
      report "FP -0.875 miscompare" severity error;
    checknum := to_float(MATH_PI);
    report_error ("FP PI",
                  checknum, reverse("01011011111100001001001000000010"));
    checknum := to_float(MATH_E);
    report_error ("FP E",
                  checknum, reverse("00101010000111111011010000000010"));
    checknum  := to_float(MATH_RAD_TO_DEG);
    checknum2 := "01000010011001010010111011100000";
    report_error ("FP RAD_to_DEG",
                   checknum, checknum2);
    checknum  := to_float (1.0/3.0);
    checknum2 := "00111110101010101010101010101010";
    report_error("FP 1/3",
                  checknum, checknum2);
    checkint  := 36892987;              -- comes out uneven
    checknum  := to_float (checkint);
    checknum2 := "01001100000011001011110001001110";
    report_error("FP unsigned 36892987 test",
                  checknum, checknum2);
    checkint  := 36892990;
    checknum  := to_float (checkint);
    checknum2 := "01001100000011001011110001001111";
    report_error("FP unsigned 36892990 test",
                  checknum, checknum2);

    -- Check some basic math functions
    checknum2 := reverse("00000000000000000000101100000011");  -- -6.5
    checknum  := abs (checknum2);
    assert (to_real(checknum) = 6.5)
      report "abs -6.5 test miscompare" severity error;
    -- Check some basic math functions
    checknum2 := reverse("00000000000000000000101100000011");  -- -6.5
    checknum  := - checknum2;
    assert (to_real(checknum) = 6.5)
      report "neg -6.5 test miscompare" severity error;
    checknum3 := reverse("00000000000000000001010001000010");  -- 42
    checknum  := - checknum3;
    assert (to_signed(checknum, 10) = -42)
      report "neg 42 test miscompare" severity error;
    checknum  := reverse("00000000000000000000101100000010");  -- 6.5
    checknum2 := checknum3 + checknum;                         -- 42 + 6.5
    assert (to_real(checknum2) = 48.5)
      report "Add 42 + 6.5 test miscompare" severity error;
    checknum2 := checknum3 - checknum;                         -- 42 - 6.5
    assert (to_real(checknum2) = 35.5)
      report "subtract 42 - 6.5 test miscompare" severity error;
    checknum2 := checknum3 * checknum;                         -- 42 * 6.5
    assert (to_integer(checknum2) = 273)
      report "mult 42 * 6.5 test miscompare" severity error;
    checknum := checknum2 / checknum3;                         -- 273 / 42
    assert (to_real(checknum) = 6.5)
      report "div 273 / 42 test miscompare" severity error;

    -- Check the compare operations
    checknum  := to_float (1.0/3.0);
    checknum2 := to_float (2);
    assert (checknum = checknum)        -- true
      report "Error X = X miscompare" severity error;
    assert not(checknum = checknum2)    -- false
      report "Error X = Y miscompare" severity error;
    assert (zero0 = negzero)            -- true
      report "Error 0 = -0 miscompare" severity error;
    assert not(checknum = qnan)         -- false
      report "Error X = qnan miscompare" severity error;
    assert not(qnan = checknum2)        -- false
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
    assert not((zero0 /= negzero))      -- false
      report "Error 0 = -0 miscompare" severity error;
    assert (checknum /= qnan)           -- true
      report "Error X = qnan miscompare" severity error;
    assert (qnan /= checknum2)          -- true
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
    assert not(checknum >= qnan)        -- false
      report "Error X >= qnan miscompare" severity error;
    assert (qnan >= checknum2)          -- true because check_error is off
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
    assert (checknum <= qnan)           -- true because NAN checking is off
      report "Error X <= qnan miscompare" severity error;
    assert not (qnan <= checknum2)      -- false
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
    assert not(checknum > qnan)         -- false
      report "Error X > qnan miscompare" severity error;
    assert (qnan > checknum2)           -- true because nan checking off
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
    assert (checknum < qnan)            -- true because nan checking off
      report "Error X < qnan miscompare" severity error;
    assert not(qnan < checknum2)        -- false
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
    assert (ClassFP(zero0) = pos_zero)
      report "Error Class of Zero incorrect" severity error;
    assert (ClassFP(negzero) = neg_zero)
      report "Error Class of neg_zero incorrect" severity error;
    assert (ClassFP(inf) = pos_normal)        -- Checking truned off
      report "Error Class of infinity incorrect" severity error;
    assert (ClassFP(neginf) = neg_normal)        -- checking truned off
      report "Error Class of neg_inf incorrect" severity error;
    assert (ClassFP(qnan) = pos_normal)       -- checking truned off
      report "Error Class of quiet_nan incorrect" severity error;
    assert (ClassFP(snan) = pos_normal)       -- checking turned off
      report "Error Class of signaling nan incorrect" severity error;
    checknum := to_float(2);
    assert (ClassFP(checknum) = pos_normal)
      report "Error Class of normal incorrect" severity error;
    checknum := to_float(-2, checknum);
    assert (ClassFP(checknum) = neg_normal)
      report "Error Class of neg incorrect" severity error;
    checknum := to_float(2.0**(-149));
    assert (ClassFP(checknum) = pos_zero)
      report "Error Class of zero incorrect" severity error;
    checknum := to_float(-1.0*(2.0**(-149)));
    assert (ClassFP(checknum) = neg_zero)
      report "Error Class of zero incorrect" severity error; 
     -- check the copy sign command
    checknum := Copysign (inf, negzero);
    assert (checknum = neginf)
      report "Error Copysign command incorrect" severity error;
    -- Check the Scalb command
    checknum  := reverse("00000000000000000000101100000011");         -- -6.5
    checknum2 := Scalb (checknum, 1);
    assert (checknum2 = to_float(-13, checknum2))
      report "Scalb (-6.5, 1) incorrect" severity error;
    checksign := to_signed (-1, checksign'high + 1);
    checknum2 := Scalb (checknum, checksign);
    assert (checknum2 = to_float(-3.25))
      report "Scalb (-6.5, -1) incorrect" severity error;
    checkint  := Logb (reverse("00000000000000000000101100000011"));  -- -6.5
    assert (checkint = 2) report "Logb(-6.5) error" severity error;
    checksign := Logb (reverse("00000000000000000000101100000011"));  -- -6.5
    assert (checksign = 2) report "Logb(-6.5) error" severity error;
    -- NextAfter function tests
    checknum  := reverse("00000000000000000000101100000011");         -- -6.5
    checknum2 := Nextafter (checknum, checknum);
    assert (checknum2 = reverse("00000000000000000000101100000011"))
      report "Nextafter -6.5 test miscompare" severity error;
    checknum2 := Nextafter (checknum, neginf);
    assert (checknum2 = reverse("10000000000000000000101100000011"))
      report "Nextafter -6.5 - test miscompare" severity error;
    checknum  := "10111110101010101010101010101010";
    checknum2 := Nextafter (checknum, negzero);
    checknum3 := "10111110101010101010101010101001";
    report_error("Nextafter -1/3+ test",
                  checknum2 , checknum3);
    checknum2 := Nextafter (qnan, snan);   -- checkerror is truned off!
    assert (ClassFP(checknum2) = pos_normal)
      report "Nextafter signaling NAN (fails in REAL package) "
      & valid_fpstate'image (ClassFP(checknum2))
      severity error;
    checknum2 := Nextafter (zero0, qnan);  -- Check error is turned off!
    assert (ClassFP(checknum2) = pos_denormal)
      report "Nextafter quiet NAN (fails in REAL package) "
      & valid_fpstate'image (ClassFP(checknum2))
      severity error;
    checknum2 := Nextafter (neginf, inf);
    checknum3 := "11111111011111111111111111111111";
    report_error ("Nextafter neginf+",
                   checknum2, checknum3);  -- most neg #
    checknum2 := Nextafter (inf, neginf);
    checknum3 := "01111111011111111111111111111111";
    report_error ("Nextafter infinity- miscompare",
                  checknum2, checknum3);   -- most positive #
    checknum := "11111111011111111111111111111111";   -- most neg #
    -- The next two lines would cause a warning message, but we have
    -- NO_WARNING = TRUE set here.
      checknum2 := Nextafter (checknum, neginf);
      report_error ("Nextafter neginf miscompare",
                    checknum2, neginf);
      checknum  := "01111111011111111111111111111111";  -- most positive #
      checknum2 := Nextafter (checknum, inf);
      report_error ("Nextafter infinity miscompare",
                    checknum2, inf);
    checknum  := "01111111011111111111111111111111";  -- most positive #
    checknum2 := Nextafter (zero0, checknum);
    checknum3 := "00000000000000000000000000000001";
    report_error ("Nextafter smallest denormal miscompare",
                  checknum2, checknum3);
    checknum2 := Nextafter (checknum2, checknum);
    checknum3 := "00000000000000000000000000000010";
    report_error ("Nextafter smallest denormal+ miscompare",
                  checknum2, checknum3);   -- Smallest den +
    checknum  := "00000000011111111111111111111111";  -- Largest denormal number
    checknum2 := Nextafter (checknum, inf);
    checknum3 := "00000000100000000000000000000000";
    report_error ("Nextafter smallest normal miscompare",
                  checknum2, checknum3);   -- Smallest normal
    checknum2 := Nextafter (checknum2, inf);
    checknum3 := "00000000100000000000000000000001";
    report_error ("Nextafter smallest normal+ miscompare",
                  checknum2, checknum3);   -- Smallest norm +
    checknum  := "00000000111111111111111111111111";  -- Overflow fraction
    checknum2 := Nextafter (checknum, inf);
    checknum3 := "00000001000000000000000000000000";
    report_error ("Nextafter overflow fraction miscompare",
                  checknum2, checknum3);   -- Exp + 1
    checknum  := "10000000100000000000000000000000";  -- Smallest Neg normal
    checknum2 := Nextafter (checknum, inf);
    checknum3 := "10000000011111111111111111111111";  -- negitive denorm
    report_error("Nextafter largest neg den miscompare" ,
                  checknum2, checknum3);   -- largest
    checknum  := "10000000011111111111111111111111";  -- Largest denormal number
    checknum2 := Nextafter (checknum, neginf);
    checknum3 := "10000000100000000000000000000000";
    report_error("Nextafter negative smallest normal miscompare",
                  checknum2, checknum3);   -- Smallest normal
    -- mixed parameter test
    checknum  := reverse("00000000000000000001010001000010");         -- 42
    checknum3 := checknum + 6.5;
    checknum2 := "01000010010000100000000000000000";  -- 48.5
    report_error ("Add 42 + real(6.5)",
                  checknum3,
                  checknum2);
    checknum  := reverse("00000000000000000001010001000010");         -- 42
    checknum3 := 6.5 + checknum;
    checknum2 := "01000010010000100000000000000000";  -- 48.5
    report_error ("Add real (6.5) + 42",
                  checknum3,
                  checknum2);
    checknum  := reverse("00000000000000000000000001111100");         -- 0.125
    checknum3 := checknum + 42;
    checknum2 := "01000010001010001000000000000000";  -- 42.125
    report_error ("Add 0.125 + int(42)",
                  checknum3, checknum2);
    checknum  := reverse("00000000000000000000000001111100");         -- 0.125
    checknum3 := 42 + checknum;
    checknum2 := "01000010001010001000000000000000";  -- 42.125
    report_error ("Add int(42) + 0.125",
                  checknum3,
                  checknum2);
    checknum  := reverse("00000000000000000000000001111100");         -- 0.125
    checkuns  := to_unsigned (42, checkuns'high + 1);
    checknum3 := checknum + to_float (checkuns);
    checknum2 := "01000010001010001000000000000000";  -- 42.125
    report_error ("Add 0.125 + unsigned(42)",
                  checknum3,
                  checknum2);
    checkuns  := to_unsigned (42, checkuns'high + 1);
    checknum3 := to_float (checkuns, checknum) + checknum;
    checknum2 := "01000010001010001000000000000000";  -- 42.125
    report_error ("Add unsigned(42) + 0.125",
                  checknum3,
                  checknum2);
    checknum  := reverse("00000000000000000001010001000010");
    checksign := to_signed (-42, checksign'high + 1);
    checknum3 := checknum + to_float(checksign);
    report_error ("Add 42 + signed(-42)",
                  checknum3,
                  zero0);
    checknum  := reverse("00000000000000000001010001000010");
    checksign := to_signed (-42, checksign'high + 1);
    checknum3 := to_float (checksign, checknum) + checknum;
    report_error ("Add signed(-42) + 42",
                  checknum3,
                  zero0);
    start_mixedmath <= true;
    wait until mixedmath_done;
    start_booltest    <= true;
    wait until booltest_done;
    start_logictest   <= true;
    wait until logictest_done;
    start_reduce_test <= true;
    wait until reduce_test_done;
    assert (false) report "test_fphdl testing complete" severity note;
    wait;
  end process tester;

  -- purpose: main level test process
  -- Lifted from the "test_reduce_pack.vhd" tests
  test_reduce : process is
    procedure report_error (
      constant message : in string;        -- message string
      actual           : in float;         -- result from code
      expected         : in std_logic) is  -- compared against
  begin  -- report_error
    assert (false)
      report message & " (" & to_string(actual) & ") /= "
      & std_logic'image(expected)
      severity error;
  end report_error;
  variable slv16 : fp16a;                  -- 16 bit (even number of bits)
  variable uns16 : fp16a;                  -- 16 bit (even number of bits)
  variable s     : std_ulogic;             -- one bit
  -- Odd lenghths to test recursive algorithem
  variable slv13 : fp7;                    -- 7 bit (odd number of bits)
  begin  -- process tester
    wait until start_reduce_test;
    -- %%% replace these _reduce with "".
    ---------------------------------------------------------------------------
    -- Start with an "or" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (or_reduce (slv16) /= '0') then
      report_error ("or reduce", slv16, '0');
    end if;
    slv16 := "0000000000000001";
    if (or_reduce (slv16) /= '1') then
      report_error ("or reduce", slv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (or_reduce (uns16) /= '1') then
      report_error ("or reduce", uns16, '1');
    end if;
    uns16 := "1000000000000001";
    if (or_reduce (uns16) /= '1') then
      report_error ("or reduce", uns16, '1');
    end if;
    slv13 := "0000000";
    if (or_reduce (slv13) /= '0') then
      report_error ("or reduce", slv13, '0');
    end if;
    slv13 := "0000001";
    if (or_reduce (slv13) /= '1') then
      report_error ("or reduce", slv13, '1');
    end if;
    slv13 := "1111111";
    if (or_reduce (slv13) /= '1') then
      report_error ("or reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLH";
    if (or_reduce (slv13) /= '1') then
      report_error ("or reduce", slv13, '1');
    end if;
    -- x test
    slv16 := "00000000000ZX000";
    if (or_reduce (slv16) /= 'X') then
      report_error ("or reduce", slv16, 'X');
    end if;
    slv16 := "00000000000ZXWU-";
    if (or_reduce (slv16) /= 'U') then
      report_error ("or reduce", slv16, 'U');
    end if;
    slv16 := "10000000000ZXWU-";
    if (or_reduce (slv16) /= '1') then
      report_error ("or reduce", slv16, '1');
    end if;
    ---------------------------------------------------------------------------
    -- "and" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (and_reduce (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
    end if;
    slv16 := "0000000000000001";
    if (and_reduce (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (and_reduce (uns16) /= '1') then
      report_error ("and reduce", uns16, '1');
    end if;
    uns16 := "1000000000000001";
    if (and_reduce (uns16) /= '0') then
      report_error ("and reduce", uns16, '0');
    end if;
    slv13 := "0000000";
    if (and_reduce (slv13) /= '0') then
      report_error ("and reduce", slv13, '0');
    end if;
    slv13 := "0000001";
    if (and_reduce (slv13) /= '0') then
      report_error ("and reduce", slv13, '0');
    end if;
    slv13 := "1111111";
    if (and_reduce (slv13) /= '1') then
      report_error ("and reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLH";
    if (and_reduce (slv13) /= '0') then
      report_error ("and reduce", slv13, '0');
    end if;
    -- x test
    slv16 := "11111111111ZX111";
    if (and_reduce (slv16) /= 'X') then
      report_error ("and reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (and_reduce (slv16) /= 'U') then
      report_error ("and reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    if (and_reduce (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
    end if;
    ---------------------------------------------------------------------------
    -- xor test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (xor_reduce (slv16) /= '0') then
      report_error ("xor reduce", slv16, '0');
    end if;
    slv16 := "0000000000000001";
    if (xor_reduce (slv16) /= '1') then
      report_error ("xor reduce", slv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (xor_reduce (uns16) /= '0') then
      report_error ("xor reduce", uns16, '0');
    end if;
    uns16 := "1000000000000001";
    if (xor_reduce (uns16) /= '0') then
      report_error ("xor reduce", uns16, '0');
    end if;
    slv13 := "0000000";
    if (xor_reduce (slv13) /= '0') then
      report_error ("xor reduce", slv13, '0');
    end if;
    slv13 := "0000001";
    if (xor_reduce (slv13) /= '1') then
      report_error ("xor reduce", slv13, '1');
    end if;
    slv13 := "1111111";
    if (xor_reduce (slv13) /= '1') then
      report_error ("xor reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLH";
    if (xor_reduce (slv13) /= '0') then
      report_error ("xor reduce", slv13, '0');
    end if;
    slv16 := "11111111111ZX111";
    if (xor_reduce (slv16) /= 'X') then
      report_error ("xor reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (xor_reduce (slv16) /= 'U') then
      report_error ("xor reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    s     := xor_reduce (slv16);
    if (s /= 'U') then
      report_error ("xor reduce", slv16, s);
    end if;
    ---------------------------------------------------------------------------
    -- "nor" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (nor_reduce (slv16) /= '1') then
      report_error ("nor reduce", slv16, '1');
    end if;
    slv16 := "0000000000000001";
    if (nor_reduce (slv16) /= '0') then
      report_error ("nor reduce", slv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (nor_reduce (uns16) /= '0') then
      report_error ("nor reduce", uns16, '0');
    end if;
    uns16 := "1000000000000001";
    if (nor_reduce (uns16) /= '0') then
      report_error ("nor reduce", uns16, '0');
    end if;
    slv13 := "0000000";
    if (nor_reduce (slv13) /= '1') then
      report_error ("nor reduce", slv13, '1');
    end if;
    slv13 := "0000001";
    if (nor_reduce (slv13) /= '0') then
      report_error ("nor reduce", slv13, '0');
    end if;
    slv13 := "1111111";
    if (nor_reduce (slv13) /= '0') then
      report_error ("nor reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLH";
    if (nor_reduce (slv13) /= '0') then
      report_error ("nor reduce", slv13, '0');
    end if;
    -- x test
    slv16 := "00000000000ZX000";
    if (nor_reduce (slv16) /= 'X') then
      report_error ("nor reduce", slv16, 'X');
    end if;
    slv16 := "00000000000ZXWU-";
    if (nor_reduce (slv16) /= 'U') then
      report_error ("nor reduce", slv16, 'U');
    end if;
    slv16 := "10000000000ZXWU-";
    if (nor_reduce (slv16) /= '0') then
      report_error ("nor reduce", slv16, '0');
    end if;
    ---------------------------------------------------------------------------
    -- "nand" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (nand_reduce (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
    end if;
    slv16 := "0000000000000001";
    if (nand_reduce (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
    end if;
    uns16 := "1111111111111111";
    if (nand_reduce (uns16) /= '0') then
      report_error ("nand reduce", uns16, '0');
    end if;
    uns16 := "1000000000000001";
    if (nand_reduce (uns16) /= '1') then
      report_error ("nand reduce", uns16, '1');
    end if;
    slv13 := "0000000";
    if (nand_reduce (slv13) /= '1') then
      report_error ("nand reduce", slv13, '1');
    end if;
    slv13 := "0000001";
    if (nand_reduce (slv13) /= '1') then
      report_error ("nand reduce", slv13, '1');
    end if;
    slv13 := "1111111";
    if (nand_reduce (slv13) /= '0') then
      report_error ("nand reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLH";
    if (nand_reduce (slv13) /= '1') then
      report_error ("nand reduce", slv13, '1');
    end if;
    slv16 := "11111111111ZX111";
    if (nand_reduce (slv16) /= 'X') then
      report_error ("nand reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (nand_reduce (slv16) /= 'U') then
      report_error ("nand reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    if (nand_reduce (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
    end if;
    ---------------------------------------------------------------------------
    -- xnor test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (xnor_reduce (slv16) /= '1') then
      report_error ("xnor reduce", slv16, '1');
    end if;
    slv16 := "0000000000000001";
    if (xnor_reduce (slv16) /= '0') then
      report_error ("xnor reduce", slv16, '0');
    end if;
    uns16 := "1111111111111111";
    if (xnor_reduce (uns16) /= '1') then
      report_error ("xnor reduce", uns16, '1');
    end if;
    uns16 := "1000000000000001";
    if (xnor_reduce (uns16) /= '1') then
      report_error ("xnor reduce", uns16, '1');
    end if;
    slv13 := "0000000";
    if (xnor_reduce (slv13) /= '1') then
      report_error ("xnor reduce", slv13, '1');
    end if;
    slv13 := "0000001";
    if (xnor_reduce (slv13) /= '0') then
      report_error ("xnor reduce", slv13, '0');
    end if;
    slv13 := "1111111";
    if (xnor_reduce (slv13) /= '0') then
      report_error ("xnor reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLH";
    if (xnor_reduce (slv13) /= '1') then
      report_error ("xnor reduce", slv13, '1');
    end if;
    slv16 := "11111111111ZX111";
    if (xnor_reduce (slv16) /= 'X') then
      report_error ("xnor reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (xnor_reduce (slv16) /= 'U') then
      report_error ("xnor reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    s     := xnor_reduce (slv16);
    if (s /= 'U') then
      report_error ("xnor reduce", slv16, s);
    end if;
    assert (quiet)
      report "Floating point reduction testing complete" severity note;
    reduce_test_done <= true;
    wait;
  end process test_reduce;
  ----------------------------------------------------------------------------
  -- Copied from the "test_minmax.vhd".
  ----------------------------------------------------------------------------
  verify : process is
    subtype  bv4 is std_logic_vector(6 downto 0);
    variable a_bv  : bv4;
    variable a_suv : fp7;
    variable b_su  : std_ulogic;
    variable b_bv  : bv4;
  BEGIN
    WAIT UNTIL start_booltest;
    for a_val in 0 to 15 loop
      a_bv  := to_slv(to_float(a_val, a_suv));
      a_suv := to_float(a_bv, a_suv);
      for b in std_ulogic loop
        b_su := b;
        b_bv := bv4'(others => b);

        assert to_slv(a_suv and b_su) = std_logic_vector'(a_bv and b_bv)
          report "error in a_suv and b_su";
        assert to_slv(b_su and a_suv) = std_logic_vector'(b_bv and a_bv)
          report "error in b_su and a_suv";
        assert to_slv(a_suv nand b_su) = std_logic_vector'(a_bv nand b_bv)
          report "error in a_suv nand b_su";
        assert to_slv(b_su nand a_suv) = std_logic_vector'(b_bv nand a_bv)
          report "error in b_su nand a_suv";
        assert to_slv(a_suv or b_su) = std_logic_vector'(a_bv or b_bv)
          report "error in a_suv or b_su";
        assert to_slv(b_su or a_suv) = std_logic_vector'(b_bv or a_bv)
          report "error in b_su or a_suv";
        assert to_slv(a_suv nor b_su) = std_logic_vector'(a_bv nor b_bv)
          report "error in a_suv nor b_su";
        assert to_slv(b_su nor a_suv) = std_logic_vector'(b_bv nor a_bv)
          report "error in b_su nor a_suv";
        assert to_slv(a_suv xor b_su) = std_logic_vector'(a_bv xor b_bv)
          report "error in a_suv xor b_su";
        assert to_slv(b_su xor a_suv) = std_logic_vector'(b_bv xor a_bv)
          report "error in b_su xor a_suv";
        assert to_slv(a_suv xnor b_su) = std_logic_vector'(a_bv xnor b_bv)
          report "error in a_suv xnor b_su";
        assert to_slv(b_su xnor a_suv) = std_logic_vector'(b_bv xnor a_bv)
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
    variable uf, uf1, uf2, uf3 : fp7;
    -- Yes, this range is illegal, thus we have to use a "std_logic_vector"
    -- compate, and not the "=".
  begin
    wait until start_logictest;
    -- not
    uf1 := "1111100";
    uf  := not uf1;
    uf3 := "0000011";
    report_error ("not " & to_string (uf1), to_slv(uf), to_slv(uf3));
    uf1 := "-WHLXUZ";
    uf  := not uf1;
    uf3 := "XX01XUX";
    report_error ("not " & to_string (uf1), to_slv(uf), to_slv(uf3));
    -- or
    uf1 := "0000000";
    uf2 := "0000000";
    uf  := uf1 or uf2;
    uf3 := "0000000";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "0000001";
    uf2 := "0010000";
    uf  := uf1 or uf2;
    uf3 := "0010001";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "0010011";
    uf2 := "0010010";
    uf  := uf1 or uf2;
    uf3 := "0010011";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "00HHLLH";
    uf2 := "00HLLLL";
    uf  := uf1 or uf2;
    uf3 := "0011001";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "001100X";
    uf2 := "0010001";
    uf  := uf1 or uf2;
    uf3 := "0011001";
    report_error (to_string (uf1) & " or " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "00WXZUL";
    uf2 := "00HLUUW";
    uf  := uf1 or uf2;
    uf3 := "001XUUX";
    report_error (to_string (uf1) & " or " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- nor
    uf1 := "0000000";
    uf2 := "0000000";
    uf  := uf1 nor uf2;
    uf3 := "0000000";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0000001";
    uf2 := "0010000";
    uf  := uf1 nor uf2;
    uf3 := "0010001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0010011";
    uf2 := "0010010";
    uf  := uf1 nor uf2;
    uf3 := "0010011";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "00HHLLH";
    uf2 := "00HLLLL";
    uf  := uf1 nor uf2;
    uf3 := "0011001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0011001";
    uf2 := "001000W";
    uf  := uf1 nor uf2;
    uf3 := "0011001";
    report_error (to_string (uf1) & " nor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "LLWXZUL";
    uf2 := "00HLUZW";
    uf  := uf1 nor uf2;
    uf3 := "001XUUX";
    report_error (to_string (uf1) & " nor " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));

    -- and
    uf1 := "0000010";
    uf2 := "0001000";
    uf  := uf1 and uf2;
    uf3 := "0000000";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "1111010";
    uf2 := "1110110";
    uf  := uf1 and uf2;
    uf3 := "1110010";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "00LLLHH";
    uf2 := "00HLLHH";
    uf  := uf1 and uf2;
    uf3 := "0000011";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "001100Z";
    uf2 := "0010000";
    uf  := uf1 and uf2;
    uf3 := "0010000";
    report_error (to_string (uf1) & " and " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "LLWXZUL";
    uf2 := "00HLUZW";
    uf  := uf1 and uf2;
    uf3 := "00X0UU0";
    report_error (to_string (uf1) & " and " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- nand
    uf1 := "0000010";
    uf2 := "0001000";
    uf  := uf1 nand uf2;
    uf3 := "0000000";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0011010";
    uf2 := "0010110";
    uf  := uf1 nand uf2;
    uf3 := "0010010";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "LHLLLHH";
    uf2 := "0LHLLHH";
    uf  := uf1 nand uf2;
    uf3 := "0000011";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0011000";
    uf2 := "001000U";
    uf  := uf1 nand uf2;
    uf3 := "0010000";
    report_error (to_string (uf1) & " nand " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "H-WXZUL";
    uf2 := "10HLUZW";
    uf  := uf1 nand uf2;
    uf3 := "10X0UU0";
    report_error (to_string (uf1) & " nand " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));
    -- xor
    uf1 := "0000010";
    uf2 := "0001000";
    uf  := uf1 xor uf2;
    uf3 := "0001010";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "0000011";
    uf2 := "0001011";
    uf  := uf1 xor uf2;
    uf3 := "0001000";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "1100011";
    uf2 := "0001011";
    uf  := uf1 xor uf2;
    uf3 := "1101000";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "0001111";
    uf2 := "0000000";
    uf  := uf1 xor uf2;
    uf3 := "0001111";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "HH100H0";
    uf2 := "LL111H1";
    uf  := uf1 xor uf2;
    uf3 := "1101101";
    report_error (to_string (uf1) & " xor " & to_string (uf2), to_slv(uf), to_slv(uf3));
    uf1 := "U-WXZU0";
    uf2 := "0LHLUZ0";
    uf  := uf1 xor uf2;
    uf3 := "UXXXUU0";
    report_error (to_string (uf1) & " xor " & to_string (uf2),
                  to_slv(uf), to_slv(uf3));
    -- xnor
    uf1 := "0000010";
    uf2 := "0001000";
    uf  := uf1 xnor uf2;
    uf3 := "0001010";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0000011";
    uf2 := "0001011";
    uf  := uf1 xnor uf2;
    uf3 := "0001000";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0000011";
    uf2 := "0001011";
    uf  := uf1 xnor uf2;
    uf3 := "0001000";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "0001111";
    uf2 := "0000000";
    uf  := uf1 xnor uf2;
    uf3 := "0001111";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "LL100H0";
    uf2 := "H0111H1";
    uf  := uf1 xnor uf2;
    uf3 := "1001101";
    report_error (to_string (uf1) & " xnor " & to_string (uf2), to_slv(uf), to_slv(not uf3));
    uf1 := "H-WXZU0";
    uf2 := "H0HL-Z0";
    uf  := uf1 xnor uf2;
    uf3 := "0XXXXU0";
    report_error (to_string (uf1) & " xnor " & to_string (uf2),
                  to_slv(uf), to_slv(not uf3));
    assert (quiet) report "logical function test done" severity note;
    logictest_done <= true;
    wait;
  end process logictest;

  -- Mix the sizes of floating point numbers and check the results
  mixedmath: process is
    variable a1, a2, a3 : float32;
    variable b1, b2, b3 : fp16a;
    variable c1, c2, c3 : fp7;
  begin
    wait until start_mixedmath;
    a1 := (others => '0');
    b1 := (others => '0');
    a2 := a1 + b1;
    report_error ("Large 0 fp + small 0 fp", a2, a1);
    c1       := "0101101";             -- 6.5
    a1  := reverse("00000000000000000000000001111100");  -- 0.125
    a2 := c1 + a1;
    a3 := to_float (6.625, a3);
    report_error ("Small + large", a2, a3);
    a1 := reverse("00000000000000000001010001000010");  -- 42
    c1 := "1101110";             -- -7
    a2 := a1 - c1;
    a3 := to_float (49, a3'high, -a3'low);
    report_error ("Large - small", a2, a3);
    a2 := c1 - a1;
    a3 := to_float (-49);
    report_error ("Small - large", a2, a3);
    a1 := reverse("00000000000000000001010001000010");  -- 42
    c1     := "0110111";             -- 15
    a2 := a1 * c1;
    a3 := to_float (42*15, a3);
    report_error ("large * small", a2, a3);
    a2 := c1 * a1;
    report_error ("small * large", a2, a3);
    c1       := "0000100";             --  0.1875 (treated as non denormal)
    a2 := resize (c1, a2);
    a3 := to_float (0.1875, a3);
    report_error ("small denormal treated as normal resize", a2, a3);
    
    a1 := reverse("00000000000000000000000001111100");  -- 0.125
    a2 := c1 / a1;
    a3 := to_float (0.1875/ 0.125, a3);
    report_error ("small / large", a2, a3);
    a2 := a1 / c1;
    a3 := to_float (0.125 / 0.1875, a3);
    report_error ("large / small", a2, a3);
    a1 := "01000010001010000000000000000000";    -- 42
    c1 := to_float (5, c1);
    a2 := a1 rem c1;
    a3 := to_float (2, a3);
    report_error ("large rem small", a2, a3);
    a1 := to_float (5, a1);
    c1 := to_float (13, c1);
    a2 := c1 rem a1;
    a3 := to_float (3, a3);
    report_error ("small rem large", a2, a3);
    a1 := "01000010001010000000000000000000";    -- 42
    c1 := to_float (5, c1);
    a2 := a1 mod c1;
    a3 := to_float (2, a3);
    report_error ("large mod small", a2, a3);
    a1 := to_float (5, a1);
    c1 := to_float (13, c1);
    a2 := c1 mod a1;
    a3 := to_float (3, a3);
    report_error ("small mod large", a2, a3);
    a1 := "11000010001010000000000000000000";    -- -42
    c1 := to_float (5, c1);
    a2 := a1 mod c1;
    a3 := to_float ((-42) mod 5, a3);
    report_error ("-large mod small", a2, a3);
    a1 := "01000010001010000000000000000000";    -- 42
    c1 := to_float (-5, c1);
    a2 := a1 mod c1;
    a3 := to_float (42 mod (-5), a3);
    report_error ("large mod -small", a2, a3);
    
    assert (quiet) report "Mixed size math test completed" severity note;
    mixedmath_done <= true;
    wait;
  end process mixedmath;

end architecture testbench;
