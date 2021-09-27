-- --------------------------------------------------------------------
-- Title      : Test vector for numeric_std package.
--   Test of minimum and maximum functions
--   Test of find_leftmost and find_rightmost functions
--   Test of + and - with a single BIT
--   Test of to_x01, to_x01z, to_ux01, and Is_X functions
--   Test of new to_signed and to_unsigned functions
--   Test of overloaded shift functions
--   Test of single bit boolean operations
--
-- Last Modified: $Date: 2007-09-12 08:57:33-04 $
-- RCS ID: $Id: test_minmax.vhdl,v 1.2 2007-09-12 08:57:33-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- -----------------------------------------------------------------------------
entity test_minmax is
  generic (
    quiet : BOOLEAN := false);          -- run quietly

end entity test_minmax;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture testbench of test_minmax is
  procedure report_error (
    errmes   : in STRING;               -- error message
    actual   : in UNSIGNED;             -- data from algorithm
    expected : in UNSIGNED) is          -- reference data
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
    expected : in SIGNED) is            -- reference data
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
begin  -- architecture testbench

  -- purpose: Test routines for the minmax packages 
  testblock : process is
    variable x, y, z, a, b, c                : INTEGER;        -- integers
    variable as, bs, cs                      : SIGNED (7 downto 0);  -- signed
    variable asr, bsr, csr                   : SIGNED (0 to 7);  -- reverse signed
    variable au, bu, cu                      : UNSIGNED (7 downto 0);  -- unsigned
    variable aur, bur, cur                   : UNSIGNED (0 to 7);  -- reverse signed
    variable aslv, bslv                      : STD_LOGIC_VECTOR (7 downto 0);  -- slvs
    variable s, s1                           : STD_ULOGIC;
    variable check7uf1, check7uf2, check7uf3 : UNSIGNED (6 downto 0);
    variable check7sf1, check7sf2, check7sf3 : SIGNED (6 downto 0);
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
--    z := maximum (x,y);
--    assert (z = 2) report "Max miscompare, 2" severity error;
--    z := maximum (y,x);
--    assert (z = 2) report "Max miscompare, r2" severity error;
--    z := minimum (x, y);
--    assert (z = 1) report "Min miscompare, 1" severity error;
--    z := minimum (y, x);
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
    au   := "00100001";
    x    := find_rightmost (au, '1');
    assert (x = 0) report "find_rightmost error 0" severity error;
    x    := find_rightmost (au, '0');
    assert (x = 1) report "find_rightmost error 1" severity error;
    x    := find_rightmost (au, 'Z');
    assert (x = -1) report "find_rightmost error -1" severity error;
    x    := find_leftmost (au, '1');
    assert (x = 5) report "find_leftmost error 1" severity error;
    x    := find_leftmost (au, '0');
    assert (x = 7) report "find_leftmost error 7" severity error;
    x    := find_leftmost (au, 'Z');
    assert (x = -1) report "find_leftmost error -1" severity error;
    as   := "00100001";
    x    := find_rightmost (as, '1');
    assert (x = 0) report "find_rightmost error 0" severity error;
    x    := find_rightmost (as, '0');
    assert (x = 1) report "find_rightmost error 1" severity error;
    x    := find_rightmost (as, 'Z');
    assert (x = -1) report "find_rightmost error -1" severity error;
    x    := find_leftmost (as, '1');
    assert (x = 5) report "find_leftmost error 1" severity error;
    x    := find_leftmost (as, '0');
    assert (x = 7) report "find_leftmost error 7" severity error;
    x    := find_leftmost (as, 'Z');
    assert (x = -1) report "find_leftmost error -1" severity error;
    ---------------------------------------------------------------------------
    -- Additional test
    ---------------------------------------------------------------------------
    -- Test some meta values
    as   := "001XX100";
    bs   := - as;
    aslv := (others => 'X');
    assert (STD_LOGIC_VECTOR(bs) = aslv) report "- metavalue " & to_string (as)
      & " /= " & to_string (aslv) severity error;
    ---------------------------------------------------------------------------
    -- + '1' test
    ---------------------------------------------------------------------------
    s  := '1';
    au := "00000000";
    bu := au + s;
    cu := "00000001";
    assert (bu = cu) report to_string(au) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '0';
    au := "00000000";
    bu := au + s;
    cu := "00000000";
    assert (bu = cu) report to_string(au) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "11111111";
    bu := au + s;
    cu := "00000000";
    assert (bu = cu) report to_string(au) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "00000000";
    bu := s + au;
    cu := "00000001";
    assert (bu = cu) report STD_ULOGIC'image(s) & " + " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '0';
    au := "00000000";
    bu := s + au;
    cu := "00000000";
    assert (bu = cu) report STD_ULOGIC'image(s) & " + " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "11111111";
    bu := s + au;
    cu := "00000000";
    assert (bu = cu) report STD_ULOGIC'image(s) & " + " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "00000001";
    bu := au - s;
    cu := "00000000";
    assert (bu = cu) report to_string(au) & " - " & STD_ULOGIC'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "11111111";
    bu := au - s;
    cu := "11111110";
    assert (bu = cu) report to_string(au) & " - " & STD_ULOGIC'image(s) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '1';
    au := "00000001";
    bu := s - au;
    cu := "00000000";
    assert (bu = cu) report STD_ULOGIC'image(s) & " - " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    s  := '0';
    au := "00000001";
    bu := s - au;
    cu := "11111111";
    assert (bu = cu) report STD_ULOGIC'image(s) & " - " & to_string(au) & LF
      & to_string (bu) & " /= " & LF & to_string (cu)
      severity error;
    -- signed
    s  := '1';
    as := "00000000";
    bs := as + s;
    cs := "00000001";
    assert (bs = cs) report to_string(as) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '0';
    as := "00000000";
    bs := as + s;
    cs := "00000000";
    assert (bs = cs) report to_string(as) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "10000000";
    bs := as + s;
    cs := "10000001";
    assert (bs = cs) report to_string(as) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "11111111";
    bs := as + s;
    cs := "00000000";
    assert (bs = cs) report to_string(as) & " + " & STD_ULOGIC'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000000";
    bs := s + as;
    cs := "00000001";
    assert (bs = cs) report STD_ULOGIC'image(s) & " + " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000001";
    bs := s + as;
    cs := "00000010";
    assert (bs = cs) report STD_ULOGIC'image(s) & " + " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000000";
    bs := as - s;
    cs := "11111111";
    assert (bs = cs) report to_string(as) & " - " & STD_ULOGIC'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000001";
    bs := as - s;
    cs := "00000000";
    assert (bs = cs) report to_string(as) & " - " & STD_ULOGIC'image(s) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '1';
    as := "00000001";
    bs := s - as;
    cs := "00000000";
    assert (bs = cs) report STD_ULOGIC'image(s) & " - " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    s  := '0';
    as := "00000001";
    bs := s - as;
    cs := "11111111";
    assert (bs = cs) report STD_ULOGIC'image(s) & " - " & to_string(as) & LF
      & to_string (bs) & " /= " & LF & to_string (cs)
      severity error;
    -- to_x01 (unsigned)
    au := "1HLWXUZ-";
    bu := to_x01(au);
    cu := "110XXXXX";
    assert (to_string(bu) = to_string(cu)) report "to_x01 (" & to_string(au)
      & ") = " & to_string(bu) severity error;
    -- to_x01 (signed)
    as := "0HLWXUZ-";
    bs := to_x01(as);
    cs := "010XXXXX";
    assert (to_string(bs) = to_string(cs)) report "to_x01 (" & to_string(as)
      & ") = " & to_string(bs) severity error;
    -- to_x01z (unsigned)
    au := "1HLWXUZ-";
    bu := to_x01z(au);
    cu := "110XXXZX";
    assert (to_string(bu) = to_string(cu)) report "to_x01z (" & to_string(au)
      & ") = " & to_string(bu) severity error;
    -- to_x01z (signed)
    as := "0HLWXUZ-";
    bs := to_x01z(as);
    cs := "010XXXZX";
    assert (to_string(bs) = to_string(cs)) report "to_x01z (" & to_string(as)
      & ") = " & to_string(bs) severity error;
    -- to_ux01 (unsigned)
    au := "1HLWXUZ-";
    bu := to_ux01(au);
    cu := "110XXUXX";
    assert (to_string(bu) = to_string(cu)) report "to_ux01 (" & to_string(au)
      & ") = " & to_string(bu) severity error;
    -- to_ux01 (signed)
    as := "0HLWXUZ-";
    bs := to_ux01(as);
    cs := "010XXUXX";
    assert (to_string(bs) = to_string(cs)) report "to_ux01 (" & to_string(as)
      & ") = " & to_string(bs) severity error;
    -- Is_X (unsigned)
    au := "00001111";
    assert not (Is_X(au)) report "Is_X (" & to_string(au) & ") = true"
      severity error;
    au := "HHHHLLLL";
    assert not (Is_X(au)) report "Is_X (" & to_string(au) & ") = true"
      severity error;
    au := "HHHHLLLX";
    assert (Is_X(au)) report "Is_X (" & to_string(au) & ") = false"
      severity error;
    au := "HHHHLLLW";
    assert (Is_X(au)) report "Is_X (" & to_string(au) & ") = false"
      severity error;
    au := "HHHHLLLU";
    assert (Is_X(au)) report "Is_X (" & to_string(au) & ") = false"
      severity error;
    au := "HHHHLLLZ";
    assert (Is_X(au)) report "Is_X (" & to_string(au) & ") = false"
      severity error;
    au := "HHHHLLL-";
    assert (Is_X(au)) report "Is_X (" & to_string(au) & ") = false"
      severity error;
    -- Is_X (signed)
    as := "00001111";
    assert not (Is_X(as)) report "Is_X (" & to_string(as) & ") = true"
      severity error;
    as := "HHHHLLLL";
    assert not (Is_X(as)) report "Is_X (" & to_string(as) & ") = true"
      severity error;
    as := "HHHHLLLX";
    assert (Is_X(as)) report "Is_X (" & to_string(as) & ") = false"
      severity error;
    as := "HHHHLLLW";
    assert (Is_X(as)) report "Is_X (" & to_string(as) & ") = false"
      severity error;
    as := "HHHHLLLU";
    assert (Is_X(as)) report "Is_X (" & to_string(as) & ") = false"
      severity error;
    as := "HHHHLLLZ";
    assert (Is_X(as)) report "Is_X (" & to_string(as) & ") = false"
      severity error;
    as := "HHHHLLL-";
    assert (Is_X(as)) report "Is_X (" & to_string(as) & ") = false"
      severity error;
--    -- test new "add_carry" procedures
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000001";             -- 1
--    s         := '0';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "0000010";             -- 2
--    s         := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000001";             -- 1
--    s         := '1';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "0000011";             -- 3
--    s         := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000110";             -- 6
--    s         := '0';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "0000111";             -- 7
--    s         := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000110";             -- 6
--    s         := '1';                   -- 1
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "0001000";             -- 8
--    s         := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111111";             -- 127
--    check7uf2 := "1111111";             -- 127
--    s         := '0';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "1111110";             -- 126
--    s         := '1';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111111";             -- 127
--    check7uf2 := "1111111";             -- 127
--    s         := '1';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "1111111";             -- 127
--    s         := '1';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111111";             -- 63
--    check7uf2 := "0000000";             -- 0
--    s         := '1';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "0000000";             -- 0
--    s         := '1';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    check7uf1 := "1111110";             -- 63
--    check7uf2 := "0000000";             -- 0
--    s         := '1';
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "1111111";             -- 0
--    s         := '0';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("add_carry", check7uf3, check7uf1);
--    -- X testing
--    check7uf1 := "0000000";             -- 0
--    check7uf2 := "0000000";             -- 0
--    s         := 'W';                   -- X
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7uf3) = STD_LOGIC_VECTOR (check7uf1))
--      report "add_carry, carry = X " & to_string(check7uf3)
--      severity error;
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "0000001";             -- 1
--    s         := 'X';                   -- X
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7uf3) = STD_LOGIC_VECTOR (check7uf1))
--      report "add_carry, carry = X " & to_string(check7uf3)
--      severity error;
--    check7uf1 := "000000-";             -- X
--    check7uf2 := "0000001";             -- 1
--    s         := '0';                   -- 0
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7uf3) = STD_LOGIC_VECTOR (check7uf1))
--      report "add_carry, carry = X " & to_string(check7uf3)
--      severity error;
--    check7uf1 := "0000001";             -- 1
--    check7uf2 := "000000U";             -- 1
--    s         := '0';                   -- X
--    add_carry (L      => check7uf1,
--               R      => check7uf2,
--               c_in   => s,
--               result => check7uf3,
--               c_out  => s1);
--    check7uf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7uf3) = STD_LOGIC_VECTOR (check7uf1))
--      report "add_carry, carry = X " & to_string(check7uf3)
--      severity error;
--    -- SIGNED add_carry test
--    check7sf1 := "0000000";
--    check7sf2 := "0000000";
--    s         := '0';
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    check7sf1 := "0000000";
--    s         := '0';
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0000010";             -- 2
--    check7sf2 := "0000011";             -- 3
--    s         := '0';                   -- 0
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '0';
--    check7sf1 := "0000101";             -- 5
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0000010";             -- 2
--    check7sf2 := "0000011";             -- 3
--    s         := '1';                   -- 1
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '0';
--    check7sf1 := "0000110";             -- 6
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0111111";             -- 63
--    check7sf2 := "0000001";             -- 1
--    s         := '0';                   -- 0
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '1';
--    check7sf1 := "1000000";             -- -128
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "0111111";             -- 63
--    check7sf2 := "0000000";             -- 0
--    s         := '1';                   -- 1
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '1';
--    check7sf1 := "1000000";             -- -128
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1111111";             -- -1
--    check7sf2 := "1111111";             -- -1
--    s         := '0';
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    check7sf1 := "1111110";             -- -2
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1111111";             -- -1
--    check7sf2 := "0000001";             -- +1
--    s         := '0';
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '0';
--    check7sf1 := "0000000";             -- 0
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1111111";             -- -1
--    check7sf2 := "0000001";             -- +1
--    s         := '1';                   -- +1
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '0';
--    check7sf1 := "0000001";             -- 1
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1000000";             -- -128
--    check7sf2 := "1111111";             -- -1
--    s         := '0';
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '1';
--    check7sf1 := "0111111";             -- 63
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    check7sf1 := "1000000";             -- -128
--    check7sf2 := "1111111";             -- -1
--    s         := '1';                   -- +1
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    s         := '0';
--    check7sf1 := "1000000";             -- -128
--    assert (s1 = s)
--      report "signed add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    report_error ("signed add_carry", check7sf3, check7sf1);
--    -- X testing
--    check7sf1 := "0000000";             -- 0
--    check7sf2 := "0000000";             -- 0
--    s         := 'W';                   -- X
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    check7sf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7sf3) = STD_LOGIC_VECTOR (check7sf1))
--      report "add_carry, carry = X " & to_string(check7sf3)
--      severity error;
--    check7sf1 := "0000001";             -- 1
--    check7sf2 := "0000001";             -- 1
--    s         := 'X';                   -- X
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    check7sf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7sf3) = STD_LOGIC_VECTOR (check7sf1))
--      report "add_carry, carry = X " & to_string(check7sf3)
--      severity error;
--    check7sf1 := "000000-";             -- X
--    check7sf2 := "0000001";             -- 1
--    s         := '0';                   -- 0
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    check7sf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7sf3) = STD_LOGIC_VECTOR (check7sf1))
--      report "add_carry, carry = X " & to_string(check7sf3)
--      severity error;
--    check7sf1 := "0000001";             -- 1
--    check7sf2 := "000000U";             -- 1
--    s         := '0';                   -- X
--    add_carry (L      => check7sf1,
--               R      => check7sf2,
--               c_in   => s,
--               result => check7sf3,
--               c_out  => s1);
--    check7sf1 := "XXXXXXX";             -- X
--    s         := 'X';
--    assert (s1 = s)
--      report "add_carry c_out reported was " & to_string (s1)
--      & " should be " & to_string (s) severity error;
--    assert (STD_LOGIC_VECTOR (check7sf3) = STD_LOGIC_VECTOR (check7sf1))
--      report "add_carry, carry = X " & to_string(check7sf3)
--      severity error;
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
    check7uf3 := "0111010";             -- 7.25
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
    -- boolean "std_ulogic and unsigned" (get from 1164 test)

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
--    check7sf1 := "1000000";             -- max negative #
--    check7uf1 := remove_sign (check7sf1);
--    assert (check7uf1 = 64)
--      report "remove_sign (""" & to_string(check7sf1) & """ /= """
--      & to_string(check7uf1) & """)"
--      severity error;
--    check7uf1 := "0000001";
--    as        := add_sign (check7uf1);
--    assert (as = SIGNED ("0" & check7uf1))
--      report "add_sign (""" & to_string (check7uf1) & """ /= """
--      & to_string (as) & """)"
--      severity error;
--    check7uf1 := "1111111";
--    as        := add_sign (check7uf1);
--    assert (as = SIGNED ("0" & check7uf1))
--      report "add_sign (""" & to_string (check7uf1) & """ /= """
--      & to_string (as) & """)"
--      severity error;
    check7uf1 := "0111110";
    check7uf2 := resize (check7uf1, check7uf2'length);
    report_error ("resize to same size", check7uf1, check7uf2);
    check7uf1 := "1011101";
    check7uf2 := resize (check7uf1, check7uf2'length);
    report_error ("resize to same size", check7uf1, check7uf2);
    check7uf1 := "1100011";
    check7uf2 := resize (check7uf1, check7uf2'length);
    report_error ("resize to same size", check7uf1, check7uf2);
    check7uf1 := "1111111";
    check7uf2 := resize (check7uf1, check7uf2'length);
    report_error ("resize to same size", check7uf1, check7uf2);

    start_booleantest <= true;
    wait until booleantest_done;
    start_matchtest   <= true;
    wait until matchtest_done;
    start_sizerestest <= true;
    wait until sizerestest_done;
    assert (false) report "numeric_std test_minmax complete" severity note;
    wait;
  end process testblock;

  verify : process is
    subtype bv4 is STD_LOGIC_VECTOR(0 to 3);
    variable a_bv  : bv4;
    variable a_suv : UNSIGNED(0 to 3);
    variable a_slv : SIGNED(0 to 3);
    variable b_su  : STD_ULOGIC;
    variable b_bv  : bv4;
  begin
    wait until start_booleantest;
    for a_val in 0 to 15 loop
      a_bv  := STD_LOGIC_VECTOR(to_unsigned(a_val, 4));
      a_suv := UNSIGNED(a_bv);
      a_slv := SIGNED(a_bv);
      for b in STD_ULOGIC loop
        b_su := b;
        b_bv := bv4'(others => b);

        assert STD_LOGIC_VECTOR(a_suv and b_su) = STD_LOGIC_VECTOR'(a_bv and b_bv)
          report "error in a_suv and b_su";
        assert STD_LOGIC_VECTOR(a_slv and b_su) = STD_LOGIC_VECTOR'(a_bv and b_bv)
          report "error in a_slv and b_su";
        assert STD_LOGIC_VECTOR(b_su and a_suv) = STD_LOGIC_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_suv";
        assert STD_LOGIC_VECTOR(b_su and a_slv) = STD_LOGIC_VECTOR'(b_bv and a_bv)
          report "error in b_su and a_slv";

        assert STD_LOGIC_VECTOR(a_suv nand b_su) = STD_LOGIC_VECTOR'(a_bv nand b_bv)
          report "error in a_suv nand b_su";
        assert STD_LOGIC_VECTOR(a_slv nand b_su) = STD_LOGIC_VECTOR'(a_bv nand b_bv)
          report "error in a_slv nand b_su";
        assert STD_LOGIC_VECTOR(b_su nand a_suv) = STD_LOGIC_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_suv";
        assert STD_LOGIC_VECTOR(b_su nand a_slv) = STD_LOGIC_VECTOR'(b_bv nand a_bv)
          report "error in b_su nand a_slv";

        assert STD_LOGIC_VECTOR(a_suv or b_su) = STD_LOGIC_VECTOR'(a_bv or b_bv)
          report "error in a_suv or b_su";
        assert STD_LOGIC_VECTOR(a_slv or b_su) = STD_LOGIC_VECTOR'(a_bv or b_bv)
          report "error in a_slv or b_su";
        assert STD_LOGIC_VECTOR(b_su or a_suv) = STD_LOGIC_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_suv";
        assert STD_LOGIC_VECTOR(b_su or a_slv) = STD_LOGIC_VECTOR'(b_bv or a_bv)
          report "error in b_su or a_slv";

        assert STD_LOGIC_VECTOR(a_suv nor b_su) = STD_LOGIC_VECTOR'(a_bv nor b_bv)
          report "error in a_suv nor b_su";
        assert STD_LOGIC_VECTOR(a_slv nor b_su) = STD_LOGIC_VECTOR'(a_bv nor b_bv)
          report "error in a_slv nor b_su";
        assert STD_LOGIC_VECTOR(b_su nor a_suv) = STD_LOGIC_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_suv";
        assert STD_LOGIC_VECTOR(b_su nor a_slv) = STD_LOGIC_VECTOR'(b_bv nor a_bv)
          report "error in b_su nor a_slv";

        assert STD_LOGIC_VECTOR(a_suv xor b_su) = STD_LOGIC_VECTOR'(a_bv xor b_bv)
          report "error in a_suv xor b_su";
        assert STD_LOGIC_VECTOR(a_slv xor b_su) = STD_LOGIC_VECTOR'(a_bv xor b_bv)
          report "error in a_slv xor b_su";
        assert STD_LOGIC_VECTOR(b_su xor a_suv) = STD_LOGIC_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_suv";
        assert STD_LOGIC_VECTOR(b_su xor a_slv) = STD_LOGIC_VECTOR'(b_bv xor a_bv)
          report "error in b_su xor a_slv";

        assert STD_LOGIC_VECTOR(a_suv xnor b_su) = STD_LOGIC_VECTOR'(a_bv xnor b_bv)
          report "error in a_suv xnor b_su";
        assert STD_LOGIC_VECTOR(a_slv xnor b_su) = STD_LOGIC_VECTOR'(a_bv xnor b_bv)
          report "error in a_slv xnor b_su";
        assert STD_LOGIC_VECTOR(b_su xnor a_suv) = STD_LOGIC_VECTOR'(b_bv xnor a_bv)
          report "error in b_su xnor a_suv";
        assert STD_LOGIC_VECTOR(b_su xnor a_slv) = STD_LOGIC_VECTOR'(b_bv xnor a_bv)
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
    variable aslv, bslv        : STD_LOGIC_VECTOR (7 downto 0);   -- slvs
    variable asulv, bsulv      : STD_ULOGIC_VECTOR (7 downto 0);  -- sulvs
    variable s, s1, s2         : STD_ULOGIC;
    variable auns, buns        : UNSIGNED (7 downto 0);
    variable as, bs            : SIGNED (7 downto 0);
    variable check6, check6t   : UNSIGNED (6 downto 0);
    variable checks6, checks6t : SIGNED (6 downto 0);
    variable b                 : BOOLEAN;
  begin
    wait until start_matchtest;
    -- First make sure that "std_match" still works
    -- Test std_match(std_ulogic) exhaustively
    for s in STD_ULOGIC loop
      for s1 in STD_ULOGIC loop
        b := std_match (s, s1);
        if ((s = s1 and (s /= 'U' and s /= 'X' and s /= 'W' and s /= 'Z'))
            or s = '-' or s1 = '-'
            or (s = '0' and s1 = 'L') or (s = 'L' and s1 = '0')
            or (s = '1' and s1 = 'H') or (s = 'H' and s1 = '1')) then
          assert (b)
            report "std_match (" & to_string(s) & ", " & to_string(s1)
            & ") returned false" severity error;
        else
          assert not (b)
            report "std_match (" & to_string(s) & ", " & to_string(s1)
            & ") returned true" severity error;
        end if;
      end loop;
    end loop;
    -- std_logic_vector
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
    -- std_ulogic_vector
    asulv := "00000010";
    bsulv := "00000010";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    asulv := "00000010";
    bsulv := "00000011";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "00000010";
    bsulv := "0000001H";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "00000010";
    bsulv := "0000001L";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    asulv := "00000010";
    bsulv := "0000001X";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "0000001X";
    bsulv := "00000010";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "00000000";
    bsulv := "LLLLLLLL";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    asulv := "11111111";
    bsulv := "HHHHHHHH";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    asulv := "XXXXXXXX";
    bsulv := "XXXXXXXX";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "UZ-WHL01";
    bsulv := "XXXXXXXX";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "--------";
    bsulv := "XXXXXXXX";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    asulv := "10101010";
    bsulv := "-0-0-0-0";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    asulv := "10101010";
    bsulv := "-0-0-0-1";
    assert not (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned true"
      severity error;
    asulv := "Z0U0W0X0";
    bsulv := "-0-0-0-0";
    assert (std_match (asulv, bsulv))
      report "std_match sulv (" & to_string(asulv) & " , " & to_string(bsulv)
      & ") returned false"
      severity error;
    -- unsigned
    auns := "00000010";
    buns := "00000010";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    auns := "00000010";
    buns := "00000011";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "00000010";
    buns := "0000001H";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "00000010";
    buns := "0000001L";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    auns := "00000010";
    buns := "0000001X";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "0000001X";
    buns := "00000010";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "00000000";
    buns := "LLLLLLLL";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "UZ-WHL01";
    buns := "XXXXXXXX";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "--------";
    buns := "XXXXXXXX";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    auns := "10101010";
    buns := "-0-0-0-0";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    auns := "10101010";
    buns := "-0-0-0-1";
    assert not (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned true"
      severity error;
    auns := "Z0U0W0X0";
    buns := "-0-0-0-0";
    assert (std_match (auns, buns))
      report "std_match uns (" & to_string(auns) & " , " & to_string(buns)
      & ") returned false"
      severity error;
    -- signed
    as := "00000010";
    bs := "00000010";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    as := "00000010";
    bs := "00000011";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "00000010";
    bs := "0000001H";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "00000010";
    bs := "0000001L";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    as := "00000010";
    bs := "0000001X";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "0000001X";
    bs := "00000010";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "00000000";
    bs := "LLLLLLLL";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "UZ-WHL01";
    bs := "XXXXXXXX";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "--------";
    bs := "XXXXXXXX";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    as := "10101010";
    bs := "-0-0-0-0";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    as := "10101010";
    bs := "-0-0-0-1";
    assert not (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned true"
      severity error;
    as := "Z0U0W0X0";
    bs := "-0-0-0-0";
    assert (std_match (as, bs))
      report "std_match s (" & to_string(as) & " , " & to_string(bs)
      & ") returned false"
      severity error;
    if (not quiet) then
      auns   := "00000111";
      check6 := "0000111";              -- length mismatch
      assert not (std_match(auns, check6))
        report "std_match (" & to_string(auns) & " , " & to_string(check6)
        & ") returned true"
        severity error;
      assert not (std_match(check6, auns))
        report "std_match (" & to_string(check6) & " , " & to_string(auns)
        & ") returned true"
        severity error;
      as      := "00000111";
      checks6 := "0000111";             -- length mismatch
      assert not (std_match(as, checks6))
        report "std_match s (" & to_string(as) & " , " & to_string(checks6)
        & ") returned true"
        severity error;
      assert not (std_match(checks6, as))
        report "std_match s (" & to_string(checks6) & " , " & to_string(as)
        & ") returned true"
        severity error;
    end if;
    -- Test std_match(std_ulogic) exhaustively
    for s in STD_ULOGIC loop
      for s1 in STD_ULOGIC loop
        b := std_match (s, s1);
        if ((s = s1 and (s /= 'U' and s /= 'X' and s /= 'W' and s /= 'Z'))
            or s = '-' or s1 = '-'
            or (s = '0' and s1 = 'L') or (s = 'L' and s1 = '0')
            or (s = '1' and s1 = 'H') or (s = 'H' and s1 = '1')) then
          assert (b)
            report "std_match (" & to_string(s) & ", " & to_string(s1)
            & ") returned false" severity error;
        else
          assert not (b)
            report "std_match (" & to_string(s) & ", " & to_string(s1)
            & ") returned true" severity error;
        end if;
      end loop;
    end loop;
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
    buns := "0000001H";
    s    := auns ?= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001L";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001X";
    s    := auns ?= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000001X";
    buns := "00000010";
    s    := auns ?= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000000";
    buns := "LLLLLLLL";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    s    := auns ?= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "UZ-WHL01";
    buns := "XXXXXXXX";
    s    := auns ?= buns;
    assert s = 'U'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "--------";
    buns := "XXXXXXXX";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10101010";
    buns := "-0-0-0-0";
    s    := auns ?= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10101010";
    buns := "-0-0-0-1";
    s    := auns ?= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "Z0U0W0X0";
    buns := "-0-0-0-0";
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
    bs := "0000001H";
    s  := as ?= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001L";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001X";
    s  := as ?= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000001X";
    bs := "00000010";
    s  := as ?= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000000";
    bs := "LLLLLLLL";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H000010";
    bs      := "HH00001L";
    s       := checks6 ?= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001H";
    bs      := "1100001L";
    s       := checks6 ?= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    s  := as ?= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "UZ-WHL01";
    bs := "XXXXXXXX";
    s  := as ?= bs;
    assert s = 'U'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "--------";
    bs := "XXXXXXXX";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10101010";
    bs := "-0-0-0-0";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10101010";
    bs := "-0-0-0-1";
    s  := as ?= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "Z0U0W0X0";
    bs := "-0-0-0-0";
    s  := as ?= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?= " & to_string(bs)
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
    buns := "0000001H";
    s    := auns ?/= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001L";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001X";
    s    := auns ?/= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000001X";
    buns := "00000010";
    s    := auns ?/= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000000";
    buns := "LLLLLLLL";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "H000010";
    buns   := "HH00001L";
    s      := check6 ?/= buns;
    assert s = '1'
      report "s " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "L000010";
    buns   := "LL00001L";
    s      := check6 ?/= buns;
    assert s = '0'
      report "s " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    s    := auns ?/= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "UZ-WHL01";
    buns := "XXXXXXXX";
    s    := auns ?/= buns;
    assert s = 'U'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "--------";
    buns := "XXXXXXXX";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10101010";
    buns := "-0-0-0-0";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "10101010";
    buns := "-0-0-0-1";
    s    := auns ?/= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "Z0U0W0X0";
    buns := "-0-0-0-0";
    s    := auns ?/= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?/= " & to_string(buns)
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
    buns := "0000001H";
    s    := auns ?< buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001L";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "H0000010";
    buns := "0000001L";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001X";
    s    := auns ?< buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000001X";
    buns := "00000010";
    s    := auns ?< buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000000H";
    buns := "LLLLLLLL";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    s    := auns ?< buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    s    := auns ?< buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?< " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      auns := "UZ-WHL01";
      buns := "XXXXXXXX";
      s    := auns ?< buns;
      assert s = 'X'
        report "uns " & to_string(auns) & " ?< " & to_string(buns)
        & " = " & to_string (s)
        severity error;
    end if;
    auns := "UZXWHL01";
    buns := "XXXXXXXX";
    s    := auns ?< buns;
    assert s = 'X'
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
    buns := "0000001H";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "H0000L1H";
    buns := "0000001H";
    s    := auns ?<= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001L";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001X";
    s    := auns ?<= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000001X";
    buns := "00000010";
    s    := auns ?<= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000000H";
    buns := "LLLLLLLL";
    s    := auns ?<= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    s    := auns ?<= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    s    := auns ?<= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?<= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      auns := "UZ-WHL01";
      buns := "XXXXXXXX";
      s    := auns ?<= buns;
      assert s = 'X'
        report "uns " & to_string(auns) & " ?<= " & to_string(buns)
        & " = " & to_string (s)
        severity error;
    end if;
    auns := "UZXWHL01";
    buns := "XXXXXXXX";
    s    := auns ?<= buns;
    assert s = 'X'
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
    auns := "0000001H";
    s    := auns ?> buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    buns := "H0000010";
    auns := "0000001H";
    s    := auns ?> buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001L";
    s    := auns ?> buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001X";
    s    := auns ?> buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000001Z";
    buns := "00000010";
    s    := auns ?> buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000000H";
    buns := "LLLLLLLL";
    s    := auns ?> buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    s    := auns ?> buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    s    := auns ?> buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?> " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      auns := "UZ-WHL01";
      buns := "XXXXXXXX";
      s    := auns ?> buns;
      assert s = 'X'
        report "uns " & to_string(auns) & " ?> " & to_string(buns)
        & " = " & to_string (s)
        severity error;
    end if;
    auns := "UZXWHL01";
    buns := "XXXXXXXX";
    s    := auns ?> buns;
    assert s = 'X'
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
    auns := "0000001H";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001H";
    s    := auns ?>= buns;
    assert s = '0'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "H0000010";
    buns := "0000001H";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001L";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "00000010";
    buns := "0000001X";
    s    := auns ?>= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000001Z";
    buns := "00000010";
    s    := auns ?>= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "0000000H";
    buns := "LLLLLLLL";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "11111111";
    buns := "HHHHHHHH";
    s    := auns ?>= buns;
    assert s = '1'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "H000010";
    buns   := "LH00001L";
    s      := check6 ?= buns;
    assert s = '1'
      report "s " & to_string(check6) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "H000010";
    buns   := "HH00001L";
    s      := check6 ?= buns;
    assert s = '0'
      report "s " & to_string(check6) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "L000010";
    buns   := "LL00001L";
    s      := check6 ?= buns;
    assert s = '1'
      report "s " & to_string(check6) & " ?= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    auns := "XXXXXXXX";
    buns := "XXXXXXXX";
    s    := auns ?>= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      auns := "UZ-WHL01";
      buns := "XXXXXXXX";
      s    := auns ?>= buns;
      assert s = 'X'
        report "uns " & to_string(auns) & " ?>= " & to_string(buns)
        & " = " & to_string (s)
        severity error;
    end if;
    auns := "UZXWHL01";
    buns := "XXXXXXXX";
    s    := auns ?>= buns;
    assert s = 'X'
      report "uns " & to_string(auns) & " ?>= " & to_string(buns)
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
    bs := "0000001H";
    s  := as ?/= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001L";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H000010";
    bs      := "HH00001L";
    s       := checks6 ?/= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001H";
    bs      := "HH00001L";
    s       := checks6 ?/= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001X";
    s  := as ?/= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000001X";
    bs := "00000010";
    s  := as ?/= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000000";
    bs := "LLLLLLLL";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    s  := as ?/= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "UZ-WHL01";
    bs := "XXXXXXXX";
    s  := as ?/= bs;
    assert s = 'U'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "--------";
    bs := "XXXXXXXX";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10101010";
    bs := "-0-0-0-0";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "10101010";
    bs := "-0-0-0-1";
    s  := as ?/= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "Z0U0W0X0";
    bs := "-0-0-0-0";
    s  := as ?/= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?/= " & to_string(bs)
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
    bs := "0000001H";
    s  := as ?< bs;
    assert s = '1'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001L";
    s  := as ?< bs;
    assert s = '0'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "H0000010";
    bs := "0000001L";
    s  := as ?< bs;
    assert s = '1'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001L";
    bs      := "HH00001H";
    s       := checks6 ?< bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001H";
    bs      := "HH00001L";
    s       := checks6 ?< bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001X";
    s  := as ?< bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000001X";
    bs := "00000010";
    s  := as ?< bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000000H";
    bs := "LLLLLLLL";
    s  := as ?< bs;
    assert s = '0'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    s  := as ?< bs;
    assert s = '0'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    s  := as ?< bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?< " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      as := "UZ-WHL01";
      bs := "XXXXXXXX";
      s  := as ?< bs;
      assert s = 'X'
        report "s " & to_string(as) & " ?< " & to_string(bs)
        & " = " & to_string (s)
        severity error;
    end if;
    as := "UZXWHL01";
    bs := "XXXXXXXX";
    s  := as ?< bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?< " & to_string(bs)
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
    bs := "0000001H";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "H0000L1H";
    bs := "0000001H";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001L";
    bs      := "HH00001H";
    s       := checks6 ?<= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001H";
    bs      := "HH00001L";
    s       := checks6 ?<= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001H";
    bs      := "HH00001H";
    s       := checks6 ?<= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001L";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001X";
    s  := as ?<= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000001X";
    bs := "00000010";
    s  := as ?<= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000000H";
    bs := "LLLLLLLL";
    s  := as ?<= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    s  := as ?<= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    s  := as ?<= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?<= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      as := "UZ-WHL01";
      bs := "XXXXXXXX";
      s  := as ?<= bs;
      assert s = 'X'
        report "s " & to_string(as) & " ?<= " & to_string(bs)
        & " = " & to_string (s)
        severity error;
    end if;
    as := "UZXWHL01";
    bs := "XXXXXXXX";
    s  := as ?<= bs;
    assert s = 'X'
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
    as := "0000001H";
    s  := as ?> bs;
    assert s = '1'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    bs := "H0000010";
    as := "0000001H";
    s  := as ?> bs;
    assert s = '1'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001H";
    bs      := "HH00001L";
    s       := checks6 ?> bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H00001L";
    bs      := "HH00001H";
    s       := checks6 ?> bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001L";
    s  := as ?> bs;
    assert s = '0'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001X";
    s  := as ?> bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000001Z";
    bs := "00000010";
    s  := as ?> bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000000H";
    bs := "LLLLLLLL";
    s  := as ?> bs;
    assert s = '1'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    s  := as ?> bs;
    assert s = '0'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    s  := as ?> bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?> " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      as := "UZ-WHL01";
      bs := "XXXXXXXX";
      s  := as ?> bs;
      assert s = 'X'
        report "s " & to_string(as) & " ?> " & to_string(bs)
        & " = " & to_string (s)
        severity error;
    end if;
    as := "UZXWHL01";
    bs := "XXXXXXXX";
    s  := as ?> bs;
    assert s = 'X'
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
    as := "0000001H";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001H";
    s  := as ?>= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "H0000010";
    bs := "0000001H";
    s  := as ?>= bs;
    assert s = '0'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H000010";
    bs      := "HH00001L";
    s       := checks6 ?>= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H11101H";               -- -5
    bs      := "HH11101L";              -- -6
    s       := checks6 ?>= bs;
    assert s = '1'
      report "s " & to_string(checks6) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    checks6 := "H000010";
    bs      := "HH00001H";
    s       := checks6 ?>= bs;
    assert s = '0'
      report "s " & to_string(checks6) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001L";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "00000010";
    bs := "0000001X";
    s  := as ?>= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000001Z";
    bs := "00000010";
    s  := as ?>= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "0000000H";
    bs := "LLLLLLLL";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "11111111";
    bs := "HHHHHHHH";
    s  := as ?>= bs;
    assert s = '1'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    as := "XXXXXXXX";
    bs := "XXXXXXXX";
    s  := as ?>= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect an error from a compare function here" severity note;
      as := "UZ-WHL01";
      bs := "XXXXXXXX";
      s  := as ?>= bs;
      assert s = 'X'
        report "s " & to_string(as) & " ?>= " & to_string(bs)
        & " = " & to_string (s)
        severity error;
    end if;
    as := "UZXWHL01";
    bs := "XXXXXXXX";
    s  := as ?>= bs;
    assert s = 'X'
      report "s " & to_string(as) & " ?>= " & to_string(bs)
      & " = " & to_string (s)
      severity error;


    
    assert (quiet) report "match test completed" severity note;
    matchtest_done <= true;
    wait;
  end process matchtest;

  -- purpose: test the size_res functions
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
end architecture testbench;
