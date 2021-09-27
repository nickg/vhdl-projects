-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the "fphdl16_pkg" package.
-- This is a comprehensive test for all of the routines in this package
-- Last Modified: $Date: 2006-07-25 09:23:05-04 $
-- RCS ID: $Id: test_fphdl16.vhdl,v 1.2 2006-07-25 09:23:05-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

------------------------------------------------------------------------
-- 1514   9 8       0  Small practical floating point number
-- 0 000000 000000000
-- 6 543210 123456789
-- +/- exp.  fraction
------------------------------------------------------------------------

--%%% Uncomment the following code and REMOVE the file "float_noround_pkg.vhd"
--library ieee;
--use ieee.fixed_pkg.all;
--package float_noround_pkg is new ieee.float_generic_pkg
--  generic map (
--    float_round_style => round_zero,
--    float_denormalize => false,
--    float_check_error => false,
--    float_guard_bits => 0,
--    NO_WARNING => true);

entity test_fphdl16 is
  generic (
    quiet : BOOLEAN := false);          -- run quietly
end entity test_fphdl16;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;
use work.float_noround_pkg.all;
architecture testbench of test_fphdl16 is
  subtype fp16 is float (6 downto -9);  -- alias for 16 bit fp type

-- purpose: reports an error
  procedure report_error (
    constant errmes : in STRING;        -- error message
    actual          : in fp16;          -- data from algorithm
    expected        : in fp16)  is      -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & " miscompare" & CR &
      "Actual   " & to_string (actual) & " ("
      & REAL'image(to_real(actual))& ") /= " & CR &
      "Expected " & to_string (expected) & " ("
      & REAL'image(to_real(expected))& ")"
      severity error;
    return;
  end procedure report_error;

  constant expon_base              : INTEGER := 2**(fp16'high-1) -1;  -- highest exponent
  signal start_bigcon, bigcon_done : BOOLEAN := false;
begin  -- architecture testbench

  -- purpose: Checks the conversion functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Test_process : process is

    variable checknum    : fp16;                    -- Floating point output
    variable checknum1   : fp16;                    -- Floating point output
    variable checknum2   : fp16;                    -- Floating point output
    variable checknum3   : fp16;                    -- Floating point output
    variable checkint    : INTEGER;                 -- integer test
    variable checkreal   : REAL;                    -- real test
    variable checkreal2  : REAL;                    -- real test
    variable checkuns    : UNSIGNED (15 downto 0);  -- unsigned test
    variable checkuns2   : UNSIGNED (15 downto 0);  -- unsigned test
    variable checkuns32  : UNSIGNED (31 downto 0);
    variable checkuns32x : UNSIGNED (31 downto 0);
  begin  -- process Test_process
    checkint := 1;
    checknum := to_float (checkint);
    report_error ("to_float 1",
                   checknum,
                   "0011111000000000");
    checkint := 2;
    checknum := to_float (checkint);
    report_error ("to_float 2",
                   checknum,
                   "0100000000000000");             -- 2
    checkint := -2;
    checknum := to_float (checkint);
    report_error ("to_float -2",
                   checknum,
                   "1100000000000000");
    checkint := 42;
    checknum := to_float (checkint);
    report_error ("to_float 42",
                   checknum,
                   "0100100010100000");             -- 42
    checkreal := 1.0 / 3.0;
    checknum  := to_float (checkreal);              -- not rounded.
    report_error ("to_float 1/3",
                   checknum,
                   "0011101010101010");             -- 1/3
    checkreal := 3.75;
    checknum  := to_float (checkreal);
    report_error ("3.75 to fp",
                   checknum,
                   "0100000111000000");
    checkreal := 7.85;
    checknum  := to_float (checkreal);              -- not rounded
    report_error ("7.85 to fp",
                   checknum,
                   "0100001111101100");
    checkreal := to_real (checknum);
    assert (checkreal = 7.843750) report "7.85 to real error "
      & REAL'image (checkreal) & " /= " & REAL'image (7.843750)
      severity error;
    checknum3 := checknum + to_float(3.75);
    report_error ("3.75 + 7.85",
                  checknum3,
                  "0100010011100110");
    checkreal := to_real (checknum3);
    assert (checkreal = 11.59375) report "3.75 + 7.85 real error "
      & REAL'image (checkreal) & " /= " & REAL'image (11.59375)
      severity error;
    checknum  := "0100001111101101";
    checkreal := to_real (checknum);
    assert (checkreal = 7.8515625) report "7.85 rounded to real error "
      & REAL'image (checkreal) & " /= " & REAL'image (7.8515625)
      severity error;
    checknum  := "0100010011100110";
    checkreal := to_real (checknum);
    assert (checkreal = 11.59375) report "11.6 rounded to real error "
      & REAL'image (checkreal) & " /= " & REAL'image (11.59375)
      severity error;
    checknum  := "0011111000000000";                -- 1
    checkreal := to_real (checknum);
    assert (checkreal = 1.0) report "1.0 conversion error "
      & REAL'image (checkreal) severity error;
    checkint := to_integer (checknum);
    assert (checkint = 1) report "1 conversion error "
      & INTEGER'image (checkint) severity error;
    checknum  := "0100000000000000";                -- 2
    checkreal := to_real (checknum);
    assert (checkreal = 2.0) report "2.0 conversion error "
      & REAL'image (checkreal) severity error;
    checkint := to_integer (checknum);
    assert (checkint = 2) report "2 conversion error "
      & INTEGER'image (checkint) severity error;
    checknum := "0100100010100000";                 -- 42
    checkint := to_integer (checknum);
    assert (checkint = 42) report "42 conversion error "
      & INTEGER'image (checkint) severity error;
    -- commented out because it donesn't come out even in the 64 bit precision.
--    checknum := "0011101010101011";  -- 1/3
--    checkreal := to_real (checknum);
--    assert (checkreal = 0.33349609380) report "1/3 conversion error "
--      & real'image (checkreal) & " \= "
--      & real'image (0.33349609380) severity error;    

    -- A few "near zero" test, FP16 is "non denormal".
    checknum  := "0000000100000000";
    checkreal := to_real (checknum);
    assert (checkreal = 1.5*(2.0**(-31))) report "non denormal to real error "
      & REAL'image (checkreal) & " /= " & REAL'image (1.5*(2.0**(-31)))
      severity error;
    checknum  := "0000000111111111";
    checkreal := to_real (checknum);
    assert (checkreal = ((2.0 - 2.0**(-9))*(2.0**(-31))))
      report "non denormal to real error"
      & REAL'image (checkreal) & " /= "
      & REAL'image ((2.0 - 2.0**(-10))*(2.0**(-31))) severity error;
    checkreal := 1.5*(2.0**(-31));
    checknum  := to_float (checkreal);
    report_error ("to_float non denormal",
                  checknum,
                  "0000000100000000");  -- (1.5*(2.0**(-31)))
    checkreal := (2.0 - 2.0**(-9))*(2.0**(-31));
    checknum  := to_float (checkreal);
    report_error ("to_float non denormal",
                  checknum,
                  "0000000111111111");
    checknum  := "0000000100000000";    -- (1.5*(2.0**(-31)))
    checknum2 := checknum + checknum;
    report_error ("small + small",
                  checknum2,
                  "0000001100000000");  -- (1.5*(2.0**(-29)))
    checknum  := "0000000111111111";    -- (2.0 - 2.0**(-10))*(2.0**(-31))
    checknum1 := "0000000100000000";    -- (1.5*(2.0**(-31)))
    checknum2 := checknum - checknum1;
    report_error ("small - small underflow",
                  checknum2,
                  zerofp (checknum2));
    checknum  := "0000001100000000";    -- (1.5*(2.0**(-29)))
    checknum1 := "0000000100000000";    -- (1.5*(2.0**(-31)))
    checknum2 := checknum - checknum1;
    report_error ("small - small",
                  checknum2,
                  "0000000100000000");
    checknum  := to_float (2);
    checknum1 := "0000000100000000";    -- (1.5*(2.0**(-31)))
    checknum2 := checknum * checknum1;
    report_error ("small * small ",
                  checknum2,
                  "0000001100000000");  -- (1.5*(2.0**(-29)))
    checknum  := to_float (0.5);
    checknum1 := "0000001100000000";    -- (1.5*(2.0**(-30)))
    checknum2 := checknum * checknum1;
    report_error ("small * small zero exp",
                  checknum2,
                  "0000000100000000");  -- (1.5*(2.0**(-31)))
    checknum1 := "0000001100000000";    -- (1.5*(2.0**(-30)))
    checknum2 := "0100000000000000";    -- 2
    checknum  := checknum1 / checknum2;
    report_error ("small/2 zero exp",
                  checknum,
                  "0000000100000000");  -- (1.5*(2.0**(-31)))
    -- infinity test
    checkint := 2**30;
    checknum := to_float (checkint);
    report_error ("to_float 2**30",
                  checknum,
                  fp16'("0111101000000000"));
    checkreal := 2.0**32;
    checknum  := to_float (checkreal);
    report_error ("to_float 2.0**32",
                  checknum,
                  fp16'("0111111000000000"));  -- infinity
    checkreal := 2.0**31;
    checknum  := to_float (checkreal);
    report_error ("to_float 2.0**31",
                  checknum,
                  fp16'("0111110000000000"));
    checkint := -2**30;
    checknum := to_float (checkint);
    report_error ("to_float -2**30",
                  checknum,
                  fp16'("1111101000000000"));
    checkreal := -2.0**32;
    checknum  := to_float (checkreal);
    report_error ("to_float -2.0**32",
                  checknum,
                  fp16'("1111111000000000"));  -- neg infinity
    checkreal := -2.0**31;
    checknum  := to_float (checkreal);
    report_error ("to_float -2.0**31",
                  checknum,
                  fp16'("1111110000000000"));
    checknum  := "0111110111111111";    -- maximum integer in this system
    checkreal := to_real (checknum);
    assert (checkreal = 4290772992.0) report "to_real max conversion error "
      & REAL'image (checkreal) severity error;
--    checkint := to_integer (checknum);
--    assert (checkint = integer'high) report "to_integer max conversion error "
--      & integer'image (checkint) severity error;
    checknum  := "0111101111111111";    -- largest number that is a valid int.
    checkreal := to_real (checknum);
    assert (checkreal = 2145386496.0) report "to_real max- conversion error "
      & REAL'image (checkreal) severity error;
    checkint := to_integer (checknum);
    assert (checkint = 2145386496) report "to_integer max- conversion error "
      & INTEGER'image (checkint) severity error;
    checknum  := "0111100111111111";    -- largest valid int. / 2
    checkreal := to_real (checknum);
    assert (checkreal = 1072693248.0) report "to_real max-/2 conversion error "
      & REAL'image (checkreal) severity error;
    checkint := to_integer (checknum);
    assert (checkint = 1072693248) report "to_integer max-/2 conversion error "
      & INTEGER'image (checkint) severity error;
    
    checkint := 2147483647;
    checknum := to_float (checkint);
    report_error ("to_float max conversion",
                  checknum,
                  "0111101111111111");
    checkint := 36831232;
    checknum := to_float (checkint);
    report_error ("to_float max- conversion",
                  checknum,
                  "0111000000110010");
    checknum := "0111000000110010";     -- maximum integer in this system
    checkint := to_integer (checknum);
    assert (checkint = 36831232) report "to_integer max- conversion error "
      & INTEGER'image (checkint) severity error;
    checkreal := to_real (checknum);
    assert (checkreal = 36831232.0) report "to_real max- conversion error "
      & REAL'image (checkreal) severity error;

    -- zero test
    checknum1 := "0011111000000000";    -- 1.0
    checknum  := checknum1 - checknum1;
    report_error ("1.0 - 1.0",
                  checknum,
                  zerofp(fp16'high, -fp16'low));
    checknum1 := "0011111000000000";    -- 1.0
    checknum  := checknum1 * checknum1;
    report_error ("1.0 * 1.0",
                  checknum,
                  checknum1);
    checknum1 := "0011111000000000";    -- 1.0
    checknum  := checknum1 / checknum1;
    report_error ("1.0 / 1.0",
                  checknum,
                  checknum1);
    checknum1 := "0011111000000000";    -- 1.0
    checknum  := checknum + checknum;
    report_error ("1.0 + 1.0",
                  checknum,
                  to_float(2));
    checknum1 := "0011111000000000";    -- 1.0
    checknum  := checknum1 * zerofp(checknum1);
    report_error ("1.0 * 0",
                  checknum,
                  zerofp(checknum1));
    checknum1 := "0011111000000000";    -- 1.0
    checknum  := zerofp(6, 9) / checknum1;
    report_error ("0 / 1.0",
                  checknum,
                  zerofp(checknum1));
    start_bigcon <= true;
    wait until bigcon_done;
    report "fphdl16_pkg testing complete" severity note;
    wait;
  end process Test_process;

  -- purpose: test the large number to small FP conversions
  -- type   : combinational
  bigcon : process is
    variable checknum  : fp16;
    variable checknum1 : fp16;
    variable checknum2 : fp16;
    variable us1, us2  : UNSIGNED (16 downto 0);  -- UNSIGNED
    variable s1, s2    : SIGNED(16 downto 0);     -- SIGNED
    variable uf1, uf2  : ufixed (8 downto -8);    -- unsigned fixed
    variable sf1, sf2  : sfixed (8 downto -8);    -- signed fixed point
  begin
    wait until start_bigcon;
    us1         := "00000000000000001";
    checknum    := to_float(us1);
    checknum1   := to_float(1);
    report_error ("UNSIGNED 1", checknum, checknum1);
    us1         := "10000000000000000";
    checknum    := to_float(us1);
    checknum1   := to_float(2**16);
    report_error ("UNSIGNED 2**16", checknum, checknum1);
    --  123456789
    us1         := "10000000010000001";
    checknum    := to_float(us1);
    checknum1   := to_float((2**16) + 128);
    report_error ("UNSIGNED 2**16+", checknum, checknum1);
    -- signed
    s1          := "00000000000000001";
    checknum    := to_float(s1);
    checknum1   := to_float(1);
    report_error ("SIGNED 1", checknum, checknum1);
    s1          := "01000000000000000";
    checknum    := to_float(s1);
    checknum1   := to_float(2**15);
    report_error ("SIGNED 2**15", checknum, checknum1);
    --  S123456789
    s1          := "01000000001000001";
    checknum    := to_float(s1);
    checknum1   := to_float((2**15) + 64);
    report_error ("SIGNED 2**15+", checknum, checknum1);
    -- unsigned fixed
    uf1         := "00000000000000001";
    checknum    := to_float(uf1);
    checknum1   := to_float(2.0**(-8));
--    checknum1 := to_float(to_real(uf1));
    report_error ("ufixed 1", checknum, checknum1);
    uf1         := "10000000000000000";
    checknum    := to_float(uf1);
    checknum1   := to_float(2**8);
--    checknum1 := to_float(to_real(uf1));
    report_error ("ufixed 2**8", checknum, checknum1);
    --  123456789
    uf1         := "10000000010000001";
    checknum    := to_float(uf1);
    checknum1   := to_float((2.0**8) + 0.5);
--    checknum1 := to_float(to_real(uf1));
    report_error ("ufixed 2**8+", checknum, checknum1);
    -- signed fixed
    sf1         := "00000000000000001";
    checknum    := to_float(sf1);
    checknum1   := to_float(2.0**(-8));
--    checknum1 := to_float(to_real(uf1));
    report_error ("sfixed 1", checknum, checknum1);
    sf1         := "01000000000000000";
    checknum    := to_float(sf1);
    checknum1   := to_float(2**7);
--    checknum1 := to_float(to_real(uf1));
    report_error ("sfixed 2**7", checknum, checknum1);
    --  S123456789
    sf1         := "01000000010000001";
    checknum    := to_float(sf1);
    checknum1   := to_float((2.0**7) + 0.5);
--    checknum1 := to_float(to_real(sf1));
    report_error ("sfixed 2**7+", checknum, checknum1);
    bigcon_done <= true;
    wait;
  end process bigcon;

end architecture testbench;
