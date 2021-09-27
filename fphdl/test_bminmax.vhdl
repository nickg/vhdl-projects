-- --------------------------------------------------------------------
-- Title      : Test vector for numeric_bit package.
--   Test of minimum and maximum functions
--   Test of find_leftmost and find_leftmost functions
--   Test of + and - with a single BIT
--   Test of new to_signed and to_unsigned functions
--   Test of overloaded shift functions
--   Test of single bit boolean operations
--
-- Last Modified: $Date: 2007-09-12 08:57:33-04 $
-- RCS ID: $Id: test_bminmax.vhdl,v 1.2 2007-09-12 08:57:33-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- -----------------------------------------------------------------------------
entity test_bminmax is
  generic (
    quiet : BOOLEAN := false);          -- run quietly 
end entity test_bminmax;

use std.textio.all;
library ieee;
use ieee.numeric_bit.all;

architecture testbench of test_bminmax is

  procedure report_error (
    errmes   : in STRING;               -- error message
    actual   : in UNSIGNED;             -- data from algorithm
    expected : in UNSIGNED)  is         -- reference data
  begin  -- function report_error
    if actual /= expected then
      report errmes & " " & to_string (actual) & " /= " & to_string (expected)
        severity error;
    end if;
    return;
  end procedure report_error;
  procedure report_error (
    errmes   : in STRING;               -- error message
    actual   : in SIGNED;               -- data from algorithm
    expected : in SIGNED)  is           -- reference data
  begin  -- function report_error
    if actual /= expected then
      report errmes & " " & to_string (actual) & " /= " & to_string (expected)
        severity error;
    end if;
    return;
  end procedure report_error;
  signal start_booleantest, booleantest_done : BOOLEAN := false;
  signal start_sizerestest, sizerestest_done : BOOLEAN := false;
  signal start_matchtest, matchtest_done     : BOOLEAN := false;
  signal start_edgetest, edgetest_done       : BOOLEAN := false;  -- edge test
  signal clk                                 : BIT;  -- clock signal (for edge test)
begin  -- architecture testbench

  -- purpose: Test routines for the minmax packages 
  testblock : process is
    variable x, y, z, a, b, c                : INTEGER;        -- integers
    variable as, bs, cs                      : SIGNED (7 downto 0);  -- signed
    variable asr, bsr, csr                   : SIGNED (0 to 7);  -- reverse signed
    variable au, bu, cu                      : UNSIGNED (7 downto 0);  -- unsigned
    variable aur, bur, cur                   : UNSIGNED (0 to 7);  -- reverse signed
    variable aslv, bslv                      : BIT_VECTOR (7 downto 0);  -- slvs
    variable check7uf1, check7uf2, check7uf3 : UNSIGNED (6 downto 0);
    variable check7sf1, check7sf2, check7sf3 : SIGNED (6 downto 0);
    variable s, s1                           : BIT;
    variable check6, check6t                 : UNSIGNED (5 downto 0);
    variable check5, check5t                 : UNSIGNED (4 downto 0);
    variable checks6, checks6t               : SIGNED (5 downto 0);
    variable checks5, checks5t               : SIGNED (4 downto 0);
    ---------------------------------------------------------------------------
    -- Name space violation! if we use "min" for minimum
    constant delay                           : TIME := 1 min;  -- one minute delay
  begin  -- process
    -- Integer versions to be placed in "standard" package.
--    x := 1;
--    y := 2;
--    z := max (x,y);
--    assert (z = 2) report "Max miscompare, 2" severity error;
--    z := max (y,x);
--    assert (z = 2) report "Max miscompare, r2" severity error;
--    z := min (x, y);
--    assert (z = 1) report "Min miscompare, 1" severity error;
--    z := min (y, x);
--    assert (z = 1) report "Min miscompare, r1" severity error;
    as     := "10000001";
    bs     := "00000010";
    cs     := maximum (as, bs);
    assert (cs = "00000010") report "Max miscompare 02x" severity error;
    cs     := maximum (bs, cs);
    assert (cs = "00000010") report "Max miscompare 02xr" severity error;
    cs     := minimum (as, bs);
    assert (cs = "10000001") report "Min miscompare 81x" severity error;
    cs     := minimum (bs, as);
    assert (cs = "10000001") report "Min miscompare 81xr" severity error;
    au     := "10000010";
    bu     := "00000100";
    cu     := maximum (au, bu);
    assert (cu = "10000010") report "Max miscompare 82x" severity error;
    cu     := maximum (bu, cu);
    assert (cu = "10000010") report "Max miscompare 82xr" severity error;
    cu     := minimum (au, bu);
    assert (cu = "00000100") report "Min miscompare 04x" severity error;
    cu     := minimum (bu, au);
    assert (cu = "00000100") report "Min miscompare 04xr" severity error;
    -- checking the overloads for minimum and maximum
    check5 := "00110";
    check6 := "000111";
    assert (check6 > check5) report to_string(check6) & " > " & to_string(check5)
      & " miscompare" severity error;
    assert (check5 < check6) report to_string(check5) & " < " & to_string(check6)
      & " miscompare" severity error;
    check6t := maximum (check6, check5);
    assert (check6t = check6) report "max (" & to_string(check6) & ", "
      & to_string(check5) & ") = " & to_string (check6t) severity error;
    check6t := maximum (check5, check6);
    assert (check6t = check6) report "max (" & to_string(check5) & ", "
      & to_string(check6) & ") = " & to_string (check6t) severity error;
    check6t := minimum (check6, check5);
    assert (check6t = check5) report "min (" & to_string(check6) & ", "
      & to_string(check5) & ") = " & to_string (check6t) severity error;
    check6t := minimum (check5, check6);
    assert (check6t = check5) report "min (" & to_string(check5) & ", "
      & to_string(check6) & ") = " & to_string (check6t) severity error;
    checks5 := "01110";
    checks6 := "001111";
    assert (checks6 > checks5) report to_string(checks6) & " > " & to_string(checks5)
      & " miscompare" severity error;
    assert (checks5 < checks6) report to_string(checks5) & " < " & to_string(checks6)
      & " miscompare" severity error;
    checks6t := maximum (checks6, checks5);
    assert (checks6t = checks6) report "max (" & to_string(checks6) & ", "
      & to_string(checks5) & ") = " & to_string (checks6t) severity error;
    checks6t := maximum (checks5, checks6);
    assert (checks6t = checks6) report "max (" & to_string(checks5) & ", "
      & to_string(checks6) & ") = " & to_string (checks6t) severity error;
    checks6t := minimum (checks6, checks5);
    assert (checks6t = checks5) report "min (" & to_string(checks6) & ", "
      & to_string(checks5) & ") = " & to_string (checks6t) severity error;
    checks6t := minimum (checks5, checks6);
    assert (checks6t = checks5) report "min (" & to_string(checks5) & ", "
      & to_string(checks6) & ") = " & to_string (checks6t) severity error;

    -- find_rightmost find_leftmost test
    au := "00100001";
    x  := find_rightmost (au, '1');
    assert (x = 0) report "unsigned find_rightmost error 0" severity error;
    x  := find_rightmost (au, '0');
    assert (x = 1) report "find_rightmost error 1" severity error;
    x  := find_leftmost (au, '1');
    assert (x = 5) report "unsigned find_leftmost error 1" severity error;
    x  := find_leftmost (au, '0');
    assert (x = 7) report "unsigned find_leftmost error 7" severity error;
    au := "00000000";
    x  := find_rightmost (au, '1');
    assert (x = -1) report "unsigned0 find_rightmost error -1" severity error;
    x  := find_leftmost (au, '1');
    assert (x = -1) report "unsigned0 find_leftmost error -1" severity error;
    au := "11111111";
    x  := find_rightmost (au, '0');
    assert (x = -1) report "unsigned1 find_rightmost error -1" severity error;
    x  := find_leftmost (au, '0');
    assert (x = -1) report "unsigned1 find_leftmost error -1" severity error;
    as := "00100001";
    x  := find_rightmost (as, '1');
    assert (x = 0) report "signed find_rightmost error 0" severity error;
    x  := find_rightmost (as, '0');
    assert (x = 1) report "signed find_rightmost error 1" severity error;
    x  := find_leftmost (as, '1');
    assert (x = 5) report "signed find_leftmost error 1" severity error;
    x  := find_leftmost (as, '0');
    assert (x = 7) report "signed find_leftmost error 7" severity error;
    as := "00000000";
    x  := find_rightmost (as, '1');
    assert (x = -1) report "signed0 find_rightmost error -1" severity error;
    x  := find_leftmost (as, '1');
    assert (x = -1) report "signed0 find_leftmost error -1" severity error;
    as := "11111111";
    x  := find_rightmost (as, '0');
    assert (x = -1) report "signed1 find_rightmost error -1" severity error;
    x  := find_leftmost (as, '0');
    assert (x = -1) report "signed1 find_leftmost error -1" severity error;
    ---------------------------------------------------------------------------
    -- + '1' test
    ---------------------------------------------------------------------------
    s  := '1';
    au := "00000000";
    bu := au + s;
    cu := "00000001";
    assert (bu = cu) report to_string(au) & " + " & BIT'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '0';
    au := "00000000";
    bu := au + s;
    cu := "00000000";
    assert (bu = cu) report to_string(au) & " + " & BIT'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "11111111";
    bu := au + s;
    cu := "00000000";
    assert (bu = cu) report to_string(au) & " + " & BIT'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "00000000";
    bu := s + au;
    cu := "00000001";
    assert (bu = cu) report BIT'image(s) & " + " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '0';
    au := "00000000";
    bu := s + au;
    cu := "00000000";
    assert (bu = cu) report BIT'image(s) & " + " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "11111111";
    bu := s + au;
    cu := "00000000";
    assert (bu = cu) report BIT'image(s) & " + " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "00000001";
    bu := au - s;
    cu := "00000000";
    assert (bu = cu) report to_string(au) & " - " & BIT'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "11111111";
    bu := au - s;
    cu := "11111110";
    assert (bu = cu) report to_string(au) & " - " & BIT'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "00000001";
    bu := s - au;
    cu := "00000000";
    assert (bu = cu) report BIT'image(s) & " - " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '0';
    au := "00000001";
    bu := s - au;
    cu := "11111111";
    assert (bu = cu) report BIT'image(s) & " - " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    -- signed
    s  := '1';
    as := "00000000";
    bs := as + s;
    cs := "00000001";
    assert (bs = cs) report to_string(as) & " + " & BIT'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '0';
    as := "00000000";
    bs := as + s;
    cs := "00000000";
    assert (bs = cs) report to_string(as) & " + " & BIT'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "10000000";
    bs := as + s;
    cs := "10000001";
    assert (bs = cs) report to_string(as) & " + " & BIT'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "11111111";
    bs := as + s;
    cs := "00000000";
    assert (bs = cs) report to_string(as) & " + " & BIT'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000000";
    bs := s + as;
    cs := "00000001";
    assert (bs = cs) report BIT'image(s) & " + " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000001";
    bs := s + as;
    cs := "00000010";
    assert (bs = cs) report BIT'image(s) & " + " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000000";
    bs := as - s;
    cs := "11111111";
    assert (bs = cs) report to_string(as) & " - " & BIT'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000001";
    bs := as - s;
    cs := "00000000";
    assert (bs = cs) report to_string(as) & " - " & BIT'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000001";
    bs := s - as;
    cs := "00000000";
    assert (bs = cs) report BIT'image(s) & " - " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '0';
    as := "00000001";
    bs := s - as;
    cs := "11111111";
    assert (bs = cs) report BIT'image(s) & " - " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    -- test new "add_carry" procedures
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000001";             -- 1
--    s := '0';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "0000010";             -- 2
--    s := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000001";             -- 1
--    s := '1';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "0000011";             -- 3
--    s := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000110";             -- 6
--    s := '0';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "0000111";             -- 7
--    s := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000110";             -- 6
--    s := '1';                           -- 1
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "0001000";             -- 8
--    s := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111111";             -- 127
--    check7uf2 := "1111111";             -- 127
--    s := '0';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "1111110";             -- 126
--    s := '1';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111111";             -- 127
--    check7uf2 := "1111111";             -- 127
--    s := '1';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "1111111";             -- 127
--    s := '1';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111111";             -- 63
--    check7uf2 := "0000000";             -- 0
--    s := '1';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "0000000";             -- 0
--    s := '1';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111110";             -- 63
--    check7uf2 := "0000000";             -- 0
--    s := '1';
--    add_carry (L => check7uf1,
--               R => check7uf2,
--               c_in => s,
--               result => check7uf3,
--               c_out => s1);
--    check7uf1 := "1111111";             -- 0
--    s := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    -- SIGNED add_carry test
--    check7sf1 := "0000000";
--    check7sf2 := "0000000";
--    s := '0';
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    check7sf1 := "0000000";
--    s := '0';
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0000010";             -- 2
--    check7sf2 := "0000011";             -- 3
--    s := '0';                           -- 0
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '0';
--    check7sf1 := "0000101";             -- 5
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0000010";             -- 2
--    check7sf2 := "0000011";             -- 3
--    s := '1';                           -- 1
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '0';
--    check7sf1 := "0000110";             -- 6
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0111111";             -- 63
--    check7sf2 := "0000001";             -- 1
--    s := '0';                           -- 0
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '1';
--    check7sf1 := "1000000";             -- -128
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0111111";             -- 63
--    check7sf2 := "0000000";             -- 0
--    s := '1';                           -- 1
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '1';
--    check7sf1 := "1000000";             -- -128
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1111111";             -- -1
--    check7sf2 := "1111111";             -- -1
--    s := '0';
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    check7sf1 := "1111110";             -- -2
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1111111";             -- -1
--    check7sf2 := "0000001";             -- +1
--    s := '0';
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '0';
--    check7sf1 := "0000000";             -- 0
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1111111";             -- -1
--    check7sf2 := "0000001";             -- +1
--    s := '1';                           -- +1
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '0';
--    check7sf1 := "0000001";             -- 1
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1000000";             -- -128
--    check7sf2 := "1111111";             -- -1
--    s := '0';
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '1';
--    check7sf1 := "0111111";             -- 63
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1000000";             -- -128
--    check7sf2 := "1111111";             -- -1
--    s := '1';                           -- +1
--    add_carry (L => check7sf1,
--               R => check7sf2,
--               c_in => s,
--               result => check7sf3,
--               c_out => s1);
--    s := '0';
--    check7sf1 := "1000000";             -- -128
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
    -- sla (unsigned)
    -- sra (unsigned)
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 srl 1;
    check7uf3 := "0011010";             -- 3.25
    report_error ("SRL test", check7uf2, check7uf3);
    check7uf2 := check7uf1 srl -1;
    check7uf3 := "1101000";             -- 13
    report_error ("SRL test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 srl 55;
    check7uf3 := "0000000";
    report_error ("SRL test 55", check7uf2, check7uf3);
    check7uf2 := check7uf1 srl -55;
    check7uf3 := "0000000";
    report_error ("SRL test -55", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 sll -1;
    check7uf3 := "0011010";             -- 3.25
    report_error ("SLL test", check7uf2, check7uf3);
    check7uf2 := check7uf1 sll 1;
    check7uf3 := "1101000";             -- 13
    report_error ("SLL test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 sll -55;
    check7uf3 := "0000000";
    report_error ("SLL test 55", check7uf2, check7uf3);
    check7uf2 := check7uf1 sll 55;
    check7uf3 := "0000000";
    report_error ("SLL test -55", check7uf2, check7uf3);

    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 ror 1;
    check7uf3 := "0011010";             -- 3.25
    report_error ("ror test", check7uf2, check7uf3);
    check7uf2 := check7uf1 ror -1;
    check7uf3 := "1101000";             -- 13
    report_error ("ror test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 ror 55;
    check7uf3 := "1101000";
    report_error ("ror test 55", check7uf2, check7uf3);
    check7uf2 := check7uf1 ror -55;
    check7uf3 := "0011010";
    report_error ("ror test -55", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 rol -1;
    check7uf3 := "0011010";             -- 3.25
    report_error ("rol test", check7uf2, check7uf3);
    check7uf2 := check7uf1 rol 1;
    check7uf3 := "1101000";             -- 13
    report_error ("rol test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 rol -53;
    check7uf3 := "0100011";
    report_error ("rol test 53", check7uf2, check7uf3);
    check7uf2 := check7uf1 rol 53;
    check7uf3 := "1000110";
    report_error ("rol test -53", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 sra 1;
    check7uf3 := "0011010";             -- 3.25
    report_error ("SRa test", check7uf2, check7uf3);
    check7uf2 := check7uf1 sra -1;
    check7uf3 := "1101000";             -- 13
    report_error ("SRa test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 sra 55;
    check7uf3 := "0000000";
    report_error ("SRa test 55", check7uf2, check7uf3);
    check7uf2 := check7uf1 sra -55;
    check7uf3 := "0000000";
    report_error ("SRa test -55", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 sla -1;
    check7uf3 := "0011010";             -- 3.25
    report_error ("SLa test", check7uf2, check7uf3);
    check7uf2 := check7uf1 sla 1;
    check7uf3 := "1101000";             -- 13
    report_error ("SLa test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 sla -55;
    check7uf3 := "0000000";
    report_error ("SLa test 55", check7uf2, check7uf3);
    check7uf2 := check7uf1 sla 55;
    check7uf3 := "0000000";
    report_error ("SLa test -55", check7uf2, check7uf3);
    check7uf1 := "1110100";             -- 14.5
    check7uf2 := check7uf1 sra 1;
    check7uf3 := "0111010";             -- 16.25
    report_error ("SRa test carry", check7uf2, check7uf3);
    check7uf1 := "1110100";             -- 14.5
    check7uf2 := check7uf1 sra -1;
    check7uf3 := "1101000";             -- 13
    report_error ("SRa test -carry", check7uf2, check7uf3);
    check7uf1 := "0110101";             -- 6.625
    check7uf2 := check7uf1 sra 1;
    check7uf3 := "0011010";
    report_error ("SRa test carry-", check7uf2, check7uf3);
    check7uf1 := "0110101";             -- 6.625
    check7uf2 := check7uf1 sra -1;
    check7uf3 := "1101010";
    report_error ("SRa test -carry-", check7uf2, check7uf3);
    check7uf1 := "1110100";             -- 14.5
    check7uf2 := check7uf1 sla -1;
    check7uf3 := "0111010";
    report_error ("Sla test -carry", check7uf2, check7uf3);
    check7uf1 := "1110100";             -- 14.5
    check7uf2 := check7uf1 sla 1;
    check7uf3 := "1101000";             -- 13
    report_error ("Sla test carry", check7uf2, check7uf3);
    check7uf1 := "0110101";             -- 6.625
    check7uf2 := check7uf1 sla -1;
    check7uf3 := "0011010";
    report_error ("Sla test -carry-", check7uf2, check7uf3);
    check7uf1 := "0110101";             -- 6.625
    check7uf2 := check7uf1 sla 1;
    check7uf3 := "1101010";
    report_error ("Sla test carry-", check7uf2, check7uf3);
    -- sla (signed)
    -- sra (signed)
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 srl 1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("SRL test", check7sf2, check7sf3);
    check7sf2 := check7sf1 srl -1;
    check7sf3 := "1101000";             -- 13
    report_error ("SRL test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 srl 55;
    check7sf3 := "0000000";
    report_error ("SRL test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 srl -55;
    check7sf3 := "0000000";
    report_error ("SRL test -55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sll -1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("SLL test", check7sf2, check7sf3);
    check7sf2 := check7sf1 sll 1;
    check7sf3 := "1101000";             -- 13
    report_error ("SLL test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sll -55;
    check7sf3 := "0000000";
    report_error ("SLL test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 sll 55;
    check7sf3 := "0000000";
    report_error ("SLL test -55", check7sf2, check7sf3);

    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 ror 1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("ror test", check7sf2, check7sf3);
    check7sf2 := check7sf1 ror -1;
    check7sf3 := "1101000";             -- 13
    report_error ("ror test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 ror 55;
    check7sf3 := "1101000";
    report_error ("ror test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 ror -55;
    check7sf3 := "0011010";
    report_error ("ror test -55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 rol -1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("rol test", check7sf2, check7sf3);
    check7sf2 := check7sf1 rol 1;
    check7sf3 := "1101000";             -- 13
    report_error ("rol test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 rol -53;
    check7sf3 := "0100011";
    report_error ("rol test 53", check7sf2, check7sf3);
    check7sf2 := check7sf1 rol 53;
    check7sf3 := "1000110";
    report_error ("rol test -53", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sra 1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("SRa test", check7sf2, check7sf3);
    check7sf2 := check7sf1 sra -1;
    check7sf3 := "1101000";             -- 13
    report_error ("SRa test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sra 55;
    check7sf3 := "0000000";
    report_error ("SRa test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 sra -55;
    check7sf3 := "0000000";
    report_error ("SRa test -55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sla -1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("SLa test", check7sf2, check7sf3);
    check7sf2 := check7sf1 sla 1;
    check7sf3 := "1101000";             -- 13
    report_error ("SLa test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sla -55;
    check7sf3 := "0000000";
    report_error ("SLa test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 sla 55;
    check7sf3 := "0000000";
    report_error ("SLa test -55", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sra 1;
    check7sf3 := "1111010";             -- 16.25
    report_error ("SRa test carry", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sra -1;
    check7sf3 := "1101000";             -- 13
    report_error ("SRa test -carry", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sra 1;
    check7sf3 := "0011010";
    report_error ("SRa test carry-", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sra -1;
    check7sf3 := "1101010";
    report_error ("SRa test -carry-", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sla -1;
    check7sf3 := "1111010";
    report_error ("Sla test -carry", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sla 1;
    check7sf3 := "1101000";             -- 13
    report_error ("Sla test carry", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sla -1;
    check7sf3 := "0011010";
    report_error ("Sla test -carry-", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sla 1;
    check7sf3 := "1101010";
    report_error ("Sla test carry-", check7sf2, check7sf3);
    -- test of new conversion functions
--    check7sf1 := "0000001";
--    check7uf1 := remove_sign (check7sf1);
--    assert (check7uf1 = UNSIGNED(check7sf1))
--      report "remove_sign (""" & to_string(check7sf1) & """ /= """
--      & to_string(check7uf1) & """)"
--      severity error;
--    check7sf1 := "1111111";
--    check7uf1 := remove_sign (check7sf1);
--    assert (check7uf1 = 1)
--      report "remove_sign (""" & to_string(check7sf1) & """ /= """
--      & to_string(check7uf1) & """)"
--      severity error;
--    check7sf1 := "1000000";
--    check7uf1 := remove_sign (check7sf1);
--    assert (check7uf1 = 64)
--      report "remove_sign (""" & to_string(check7sf1) & """ /= """
--      & to_string(check7uf1) & """)"
--      severity error;
--    check7uf1 := "0000001";
--    as := add_sign (check7uf1);
--    assert (as = SIGNED ("0" & check7uf1))
--      report "add_sign (""" & to_string (check7uf1) & """ /= """
--      & to_string (as) & """)"
--      severity error;
--    check7uf1 := "1111111";
--    as := add_sign (check7uf1);
--    assert (as = SIGNED ("0" & check7uf1))
--      report "add_sign (""" & to_string (check7uf1) & """ /= """
--      & to_string (as) & """)"
--      severity error;
    -- boolean "std_ulogic and unsigned" (get from 1164 test)

    start_edgetest    <= true;
    wait until edgetest_done;
    start_booleantest <= true;
    wait until booleantest_done;
    start_sizerestest <= true;
    wait until sizerestest_done;
    start_matchtest   <= true;
    wait until matchtest_done;
    assert (false) report "numeric_bit test_minmax complete" severity note;
    wait;
  end process testblock;

  verify : process is
    subtype bv4 is BIT_VECTOR(0 to 3);
    variable a_bv  : bv4;
    variable a_suv : UNSIGNED(0 to 3);
    variable a_slv : SIGNED(0 to 3);
    variable b_su  : BIT;
    variable b_bv  : bv4;
  begin
    wait until start_booleantest;
    for a_val in 0 to 15 loop
      a_bv  := BIT_VECTOR(to_unsigned(a_val, 4));
      a_suv := UNSIGNED(a_bv);
      a_slv := SIGNED(a_bv);
      for b in BIT loop
        b_su := b;
        b_bv := bv4'(others => b);

        assert BIT_VECTOR(a_suv and b_su) = BIT_VECTOR'(a_bv and b_bv)
          report "error in a_suv and b_su";
        assert BIT_VECTOR(a_slv and b_su) = BIT_VECTOR'(a_bv and b_bv)
          report "error in a_slv and b_su";
        assert BIT_VECTOR(b_su and a_suv) = BIT_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_suv";
        assert BIT_VECTOR(b_su and a_slv) = BIT_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_slv";

        assert BIT_VECTOR(a_suv nand b_su) = BIT_VECTOR'(a_bv nand b_bv)
          report "error in a_suv nand b_su";
        assert BIT_VECTOR(a_slv nand b_su) = BIT_VECTOR'(a_bv nand b_bv)
          report "error in a_slv nand b_su";
        assert BIT_VECTOR(b_su nand a_suv) = BIT_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_suv";
        assert BIT_VECTOR(b_su nand a_slv) = BIT_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_slv";

        assert BIT_VECTOR(a_suv or b_su) = BIT_VECTOR'(a_bv or b_bv)
          report "error in a_suv or b_su";
        assert BIT_VECTOR(a_slv or b_su) = BIT_VECTOR'(a_bv or b_bv)
          report "error in a_slv or b_su";
        assert BIT_VECTOR(b_su or a_suv) = BIT_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_suv";
        assert BIT_VECTOR(b_su or a_slv) = BIT_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_slv";

        assert BIT_VECTOR(a_suv nor b_su) = BIT_VECTOR'(a_bv nor b_bv)
          report "error in a_suv nor b_su";
        assert BIT_VECTOR(a_slv nor b_su) = BIT_VECTOR'(a_bv nor b_bv)
          report "error in a_slv nor b_su";
        assert BIT_VECTOR(b_su nor a_suv) = BIT_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_suv";
        assert BIT_VECTOR(b_su nor a_slv) = BIT_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_slv";

        assert BIT_VECTOR(a_suv xor b_su) = BIT_VECTOR'(a_bv xor b_bv)
          report "error in a_suv xor b_su";
        assert BIT_VECTOR(a_slv xor b_su) = BIT_VECTOR'(a_bv xor b_bv)
          report "error in a_slv xor b_su";
        assert BIT_VECTOR(b_su xor a_suv) = BIT_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_suv";
        assert BIT_VECTOR(b_su xor a_slv) = BIT_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_slv";

        assert BIT_VECTOR(a_suv xnor b_su) = BIT_VECTOR'(a_bv xnor b_bv)
          report "error in a_suv xnor b_su";
        assert BIT_VECTOR(a_slv xnor b_su) = BIT_VECTOR'(a_bv xnor b_bv)
          report "error in a_slv xnor b_su";
        assert BIT_VECTOR(b_su xnor a_suv) = BIT_VECTOR'(b_bv xnor a_bv)
          report "error in b_su xnor a_suv";
        assert BIT_VECTOR(b_su xnor a_slv) = BIT_VECTOR'(b_bv xnor a_bv)
          report "error in b_su xnor a_slv";

        wait for 1 ns;
      end loop;
    end loop;
    assert (quiet) report "boolean test completed" severity note;
    booleantest_done <= true;
    wait;
  end process verify;

  -- purpose: test the match function
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  matchtest : process is
    variable aslv, bslv        : BIT_VECTOR (7 downto 0);  -- slvs
    variable asulv, bsulv      : BIT_VECTOR (7 downto 0);  -- sulvs
    variable s, s1, s2         : BIT;
    variable auns, buns        : UNSIGNED (7 downto 0);
    variable as, bs            : SIGNED (7 downto 0);
    variable check6, check6t   : UNSIGNED (6 downto 0);
    variable checks6, checks6t : SIGNED (6 downto 0);
    variable b                 : BOOLEAN;
  begin
    wait until start_matchtest;
    -- ?=
    -- unsigned
    auns := "00000010";
    buns := "00000010";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000010";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    -- signed
    as := "00000010";
    bs := "00000010";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000010";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;

    checks6 := "1000010";
    bs      := "11000010";
    s       := checks6 ?= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000011";
    bs      := "11000010";
    s       := checks6 ?= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;

    -- unsigned
    auns := "00000010";
    buns := "00000010";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?/= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?/= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000010";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    check6 := "1000010";
    buns   := "11000010";
    s      := check6 ?/= buns;
    assert s = '1'
      report "uns a " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "1000011";
    buns   := "11000010";
    s      := check6 ?/= buns;
    assert s = '1'
      report "uns b " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "1000010";
    buns   := "01000010";
    s      := check6 ?/= buns;
    assert s = '0'
      report "uns c " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "0000011";
    buns   := "00000011";
    s      := check6 ?/= buns;
    assert s = '0'
      report "uns d " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    -- ?<
    auns := "00000010";
    buns := "00000010";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?< buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?< buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000010";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10000010";
    buns := "00000010";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    -- ?<=
    auns := "00000010";
    buns := "00000010";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10000011";
    buns := "00000011";
    s    := auns ?<= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000010";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    -- ?>
    auns := "00000010";
    buns := "00000010";
    s    := auns ?> buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    buns := "00000010";
    auns := "00000011";
    s    := auns ?> buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    buns := "00000010";
    auns := "00000011";
    s    := auns ?> buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    buns := "10000010";
    auns := "00000011";
    s    := auns ?> buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000010";
    s    := auns ?> buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    -- ?>=
    auns := "00000010";
    buns := "00000010";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    buns := "00000010";
    auns := "00000011";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    buns := "00000010";
    auns := "00000011";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000011";
    s    := auns ?>= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10000010";
    buns := "00000011";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "00000010";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    check6 := "1000010";
    buns   := "01000010";
    s      := check6 ?= buns;
    assert s = '1'
      report "s " & to_string(check6) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "1000010";
    buns   := "11000010";
    s      := check6 ?= buns;
    assert s = '0'
      report "s " & to_string(check6) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "0000010";
    buns   := "00000010";
    s      := check6 ?= buns;
    assert s = '1'
      report "s " & to_string(check6) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;

    -- signed
    as := "00000010";
    bs := "00000010";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?/= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?/= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000010";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000010";
    bs      := "11000010";
    s       := checks6 ?/= bs;
    assert s = '0'
      report "s one " & to_string(checks6) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000011";
    bs      := "11000010";
    s       := checks6 ?/= bs;
    assert s = '1'
      report "s two " & to_string(checks6) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;

    -- ?<
    as := "00000010";
    bs := "00000010";
    s  := as ?< bs;
    assert s = '0'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?< bs;
    assert s = '1'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?< bs;
    assert s = '1'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000010";
    s  := as ?< bs;
    assert s = '0'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10000010";
    bs := "00000010";
    s  := as ?< bs;
    assert s = '1'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000010";
    bs      := "11000011";
    s       := checks6 ?< bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000011";
    bs      := "11000010";
    s       := checks6 ?< bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;

    -- ?<=
    as := "00000010";
    bs := "00000010";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10000011";
    bs := "00000011";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000010";
    bs      := "11000011";
    s       := checks6 ?<= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000011";
    bs      := "11000010";
    s       := checks6 ?<= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000011";
    bs      := "11000011";
    s       := checks6 ?<= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000010";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;

    -- ?>
    as := "00000010";
    bs := "00000010";
    s  := as ?> bs;
    assert s = '0'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    bs := "00000010";
    as := "00000011";
    s  := as ?> bs;
    assert s = '1'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    bs := "00000010";
    as := "00000011";
    s  := as ?> bs;
    assert s = '1'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    bs := "10000010";
    as := "00000011";
    s  := as ?> bs;
    assert s = '1'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000011";
    bs      := "11000010";
    s       := checks6 ?> bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000010";
    bs      := "11000011";
    s       := checks6 ?> bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000010";
    s  := as ?> bs;
    assert s = '0'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    -- ?>=
    as := "00000010";
    bs := "00000010";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    bs := "00000010";
    as := "00000011";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    bs := "00000010";
    as := "00000011";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000011";
    s  := as ?>= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10000010";
    bs := "00000011";
    s  := as ?>= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000010";
    bs      := "11000010";
    s       := checks6 ?>= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1111011";               -- -5
    bs      := "11111010";              -- -6
    s       := checks6 ?>= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "1000010";
    bs      := "11000011";
    s       := checks6 ?>= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "00000010";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;

    assert (quiet) report "match test completed" severity note;
    matchtest_done <= true;
    wait;
  end process matchtest;

  -- purpose: test the size_res functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  sizerestest : process is
    variable checkint          : INTEGER;
    variable check6, check6t   : UNSIGNED (5 downto 0);
    variable check5, check5t   : UNSIGNED (4 downto 0);
    variable checks6, checks6t : SIGNED (5 downto 0);
    variable checks5, checks5t : SIGNED (4 downto 0);
    variable nulls             : SIGNED (0 downto 1);
    variable nullu             : UNSIGNED (0 downto 1);  -- null arrays
  begin
    wait until start_sizerestest;
    check6           := "000111";                        -- 7
    check5           := resize (check6, check5);
    check5t          := "00111";                         -- 7
    report_error ("resize size_res", check5, check5t);
    check5           := "01000";                         -- 8
    check6           := resize (check5, check6);
    check6t          := "001000";                        -- 8
    report_error ("resize size_res", check6, check6t);
    nullu            := resize (check5, nullu);
    check5           := resize (nullu, check5);
    check5t          := (others => '0');
    report_error ("resize (null, check5)", check5, check5t);
    checkint         := 4;
    check5           := to_unsigned(checkint, check5);
    check5t          := "00100";                         -- 4
    report_error ("to_unsigned(4, size_res)", check5, check5t);
    nullu            := to_unsigned (checkint, nullu);
    -- signed
    checks6          := "000111";                        -- 7
    checks5          := resize (checks6, checks5);
    checks5t         := "00111";                         -- 7
    report_error ("resize s size_res", checks5, checks5t);
    checks5          := "01000";                         -- 8
    checks6          := resize (checks5, checks6);
    checks6t         := "001000";                        -- 8
    report_error ("resize s size_res", checks6, checks6t);
    nulls            := resize (checks5, nulls);
    checks5          := resize (nulls, checks5);
    checks5t         := (others => '0');
    report_error ("resize (null, checks5)", checks5, checks5t);
    checkint         := 4;
    checks5          := to_signed(checkint, checks5);
    checks5t         := "00100";                         -- 4
    report_error ("to_signed(4, size_res)", checks5, checks5t);
    nulls            := to_signed (checkint, nulls);
    assert (quiet) report "Size_RES testing completed" severity note;
    sizerestest_done <= true;
    wait;
  end process sizerestest;

  -- purpose: clock driver
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  clkprc : process is
    constant clock_period : TIME := 4 ns;
  begin  -- process clkprc
    if (not edgetest_done) then
      clk <= '0';
      wait for clock_period/2.0;
      clk <= '1';
      wait for clock_period/2.0;
    else
      wait;
    end if;
  end process clkprc;

  -- Copy of the test in "test_standard_additions". To test the edge
  -- functionality now that the "rising_edge" and "falling_edge" function have
  -- been moved into "standard".
  -- purpose: test the edge functions
  edgetest : process is
  begin
    wait until start_edgetest;
    wait for 1 ns;
    assert (not rising_edge(clk)) report "False rising_edge detection"
      severity error;
    wait until rising_edge (clk);
    assert (now = 2 ns) report "Rising edge of clock not in sync"
      severity error;
    wait for 1 ns;
    assert (not falling_edge(clk)) report "False falling_edge detection"
      severity error;
    wait until falling_edge (clk);
    assert (now = 4 ns) report "Falling edge of clock not in sync"
      severity error;
    wait for 1 ns;
    assert (not falling_edge(clk)) report "False falling_edge detection"
      severity error;
    wait until rising_edge (clk);
    assert (now = 6 ns) report "2 Rising edge of clock not in sync"
      severity error;
    wait for 1 ns;
    assert (not rising_edge(clk)) report "False rising_edge detection"
      severity error;
    wait until falling_edge (clk);
    assert (now = 8 ns) report "2 Falling edge of clock not in sync"
      severity error;
    wait until rising_edge (clk);
    assert (now = 10 ns) report "3 Rising edge of clock not in sync"
      severity error;
    wait until falling_edge (clk);
    assert (now = 12 ns) report "4 Falling edge of clock not in sync"
      severity error;
    assert (quiet) report "rising and falling edge test complete"
      severity note;
    edgetest_done <= true;
  end process edgetest;
end architecture testbench;
