-- --------------------------------------------------------------------
-- Last Modified: $Date: 2006-07-06 15:50:04-04 $
-- RCS ID: $Id: test_fixed_nr.vhdl,v 1.1 2006-07-06 15:50:04-04 l435385 Exp $
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_noround_pkg.all;

entity test_fixed_nr is
  generic (
    quiet : BOOLEAN := false);
end entity test_fixed_nr;

use std.textio.all;
library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_noround_pkg.all;

architecture testbench of test_fixed_nr is
  constant debug : BOOLEAN := false;    -- debug mode, prints out lots of data
  -- purpose: reports an error
  procedure report_error (
    constant errmes   : in STRING;      -- error message
    actual            : in ufixed;      -- data from algorithm
    constant expected : in ufixed) is   -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & CR
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & CR
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
      report errmes & CR
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & CR
      & "     /= " & to_string(expected)
      & " (" & REAL'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;
  signal start_resizetest, resizetest_done : BOOLEAN;  -- resize test
  signal start_sunstest, sunstest_done     : BOOLEAN;  -- signed and unsigned test
  signal start_divtest, divtest_done       : BOOLEAN;  -- divide and reciprocal test
begin
  main : process is
  begin
    start_resizetest <= true;
    wait until resizetest_done;
    start_sunstest   <= true;
    wait until sunstest_done;
    start_divtest    <= true;
    wait until divtest_done;
    report "Fixed point noround test completed" severity note;
  end process main;

  -- purpose: test the resize functions
  resizetest : process is
    variable uf1, uf2, uf3    : ufixed (3 downto -3);
    variable ufx1, ufx2, ufx3 : ufixed (2 downto -1);
    variable sf1, sf2, sf3    : sfixed (3 downto -3);
    variable sfx1, sfx2, sfx3 : sfixed (2 downto -1);
  begin
    wait until start_resizetest;
    uf1  := "0000000";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "0000";
    report_error ("ufixed zero test", ufx1, ufx2);
    uf1  := "0000011";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "0000";
    report_error ("ufixed noround test", ufx1, ufx2);
    uf1  := "0000111";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "0001";
    report_error ("ufixed noround 0.5 test", ufx1, ufx2);
    uf1  := "0111110";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "1111";
    report_error ("ufixed noround 7.5 test", ufx1, ufx2);
    uf1  := "1000000";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "0000";
    report_error ("ufixed wrap test", ufx1, ufx2);
    uf1  := "1100000";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "1000";
    report_error ("ufixed wrap 4 test", ufx1, ufx2);
    uf1  := "1110111";
    ufx1 := resize (uf1, ufx1'high, ufx1'low);
    ufx2 := "1101";
    report_error ("ufixed wrap and noround 6.5 test", ufx1, ufx2);
    -- size_res
    uf1  := "0000000";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "0000";
    report_error ("ufixed zero test", ufx1, ufx2);
    uf1  := "0000011";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "0000";
    report_error ("ufixed noround test", ufx1, ufx2);
    uf1  := "0000111";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "0001";
    report_error ("ufixed noround 0.5 test", ufx1, ufx2);
    uf1  := "0111110";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "1111";
    report_error ("ufixed noround 7.5 test", ufx1, ufx2);
    uf1  := "1000000";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "0000";
    report_error ("ufixed wrap test", ufx1, ufx2);
    uf1  := "1100000";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "1000";
    report_error ("ufixed wrap 4 test", ufx1, ufx2);
    uf1  := "1110111";
    ufx1 := resize (uf1, ufx1);
    ufx2 := "1101";
    report_error ("ufixed wrap and noround 6.5 test", ufx1, ufx2);
    -- signed
    sf1  := "0000000";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "0000";
    report_error ("sfixed zero test", sfx1, sfx2);
    sf1  := "0000011";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "0000";
    report_error ("sfixed noround test", sfx1, sfx2);
    sf1  := "0000111";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "0001";
    report_error ("sfixed noround 0.5 test", sfx1, sfx2);
    sf1  := "0111110";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "1111";
    report_error ("sfixed noround 7.5 test", sfx1, sfx2);
    sf1  := "1000000";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "0000";
    report_error ("sfixed wrap test", sfx1, sfx2);
    sf1  := "1100000";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "1000";
    report_error ("sfixed wrap 4 test", sfx1, sfx2);
    sf1  := "1110111";
    sfx1 := resize (sf1, sfx1'high, sfx1'low);
    sfx2 := "1101";
    report_error ("sfixed wrap and noround 6.5 test", sfx1, sfx2);
    -- size_res
    sf1  := "0000000";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "0000";
    report_error ("sfixed zero test", sfx1, sfx2);
    sf1  := "0000011";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "0000";
    report_error ("sfixed noround test", sfx1, sfx2);
    sf1  := "0000111";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "0001";
    report_error ("sfixed noround 0.5 test", sfx1, sfx2);
    sf1  := "0111110";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "1111";
    report_error ("sfixed noround 7.5 test", sfx1, sfx2);
    sf1  := "1000000";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "0000";
    report_error ("sfixed wrap test", sfx1, sfx2);
    sf1  := "1100000";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "1000";
    report_error ("sfixed wrap 4 test", sfx1, sfx2);
    sf1  := "1110111";
    sfx1 := resize (sf1, sfx1);
    sfx2 := "1101";
    report_error ("sfixed wrap and noround 6.5 test", sfx1, sfx2);
    assert (quiet) report "Resize testing completed"
      severity note;
    resizetest_done <= true;
  end process resizetest;

  -- purpose: test the signed and unsigned functions
  sunstest : process is
    variable uf1        : ufixed (3 downto -3);
    variable ufx1, ufx2 : ufixed (3 downto 1);
    variable ufy1       : ufixed (5 downto 1);
    variable us1        : UNSIGNED (4 downto 0);
    variable sf1        : sfixed (3 downto -3);
    variable sfx1, sfx2 : sfixed (3 downto 1);
    variable sfy1       : sfixed (5 downto 1);
    variable s1         : SIGNED (4 downto 0);
    variable int        : INTEGER;
    variable rn         : REAL;
  begin
    wait until start_sunstest;
    us1  := "00000";
    ufx1 := to_ufixed (us1, ufx1'high, ufx1'low);
    ufx2 := "000";
    report_error ("to_ufixed(unsigned) zero test", ufx1, ufx2);
    us1  := "00001";
    ufx1 := to_ufixed (us1, ufx1'high, ufx1'low);
    ufx2 := "000";
    report_error ("to_ufixed(unsigned) 1-0 test", ufx1, ufx2);
    us1  := "00011";
    ufx1 := to_ufixed (us1, ufx1'high, ufx1'low);
    ufx2 := "001";
    report_error ("to_ufixed(unsigned) 3-2 test", ufx1, ufx2);
    us1  := "10011";
    ufx1 := to_ufixed (us1, ufx1'high, ufx1'low);
    ufx2 := "001";
    report_error ("to_ufixed(unsigned) 19-2 test", ufx1, ufx2);
    us1  := "11011";
    ufx1 := to_ufixed (us1, ufx1'high, ufx1'low);
    ufx2 := "101";
    report_error ("to_ufixed(unsigned) 27-10 test", ufx1, ufx2);
    -- integer
    int  := 0;
    ufx1 := to_ufixed (int, ufx1'high, ufx1'low);
    ufx2 := "000";
    report_error ("to_ufixed(integer) zero test", ufx1, ufx2);
    int  := 1;
    ufx1 := to_ufixed (int, ufx1'high, ufx1'low);
    ufx2 := "000";
    report_error ("to_ufixed(integer) 1-0 test", ufx1, ufx2);
    int  := 3;
    ufx1 := to_ufixed (int, ufx1'high, ufx1'low);
    ufx2 := "001";
    report_error ("to_ufixed(integer) 3-2 test", ufx1, ufx2);
    int  := 19;
    ufx1 := to_ufixed (int, ufx1'high, ufx1'low);
    ufx2 := "001";
    report_error ("to_ufixed(integer) 19-2 test", ufx1, ufx2);
    int  := 27;
    ufx1 := to_ufixed (int, ufx1'high, ufx1'low);
    ufx2 := "101";
    report_error ("to_ufixed(integer) 27-10 test", ufx1, ufx2);
    -- real
    rn   := 0.0;
    ufx1 := to_ufixed (rn, ufx1'high, ufx1'low);
    ufx2 := "000";
    report_error ("to_ufixed(real) zero test", ufx1, ufx2);
    rn   := 1.0;
    ufx1 := to_ufixed (rn, ufx1'high, ufx1'low);
    ufx2 := "000";
    report_error ("to_ufixed(real) 1-0 test", ufx1, ufx2);
    rn   := 3.0;
    ufx1 := to_ufixed (rn, ufx1'high, ufx1'low);
    ufx2 := "001";
    report_error ("to_ufixed(real) 3-2 test", ufx1, ufx2);
    rn   := 19.0;
    ufx1 := to_ufixed (rn, ufx1'high, ufx1'low);
    ufx2 := "001";
    report_error ("to_ufixed(real) 19-2 test", ufx1, ufx2);
    rn   := 27.0;
    ufx1 := to_ufixed (rn, ufx1'high, ufx1'low);
    ufx2 := "101";
    report_error ("to_ufixed(real) 27-10 test", ufx1, ufx2);
    -- size_res
    us1  := "00000";
    ufx1 := to_ufixed (us1, ufx1);
    ufx2 := "000";
    report_error ("to_ufixed(unsigned) zero test", ufx1, ufx2);
    us1  := "00001";
    ufx1 := to_ufixed (us1, ufx1);
    ufx2 := "000";
    report_error ("to_ufixed(unsigned) 1-0 test", ufx1, ufx2);
    us1  := "00011";
    ufx1 := to_ufixed (us1, ufx1);
    ufx2 := "001";
    report_error ("to_ufixed(unsigned) 3-2 test", ufx1, ufx2);
    us1  := "10011";
    ufx1 := to_ufixed (us1, ufx1);
    ufx2 := "001";
    report_error ("to_ufixed(unsigned) 19-2 test", ufx1, ufx2);
    us1  := "11011";
    ufx1 := to_ufixed (us1, ufx1);
    ufx2 := "101";
    report_error ("to_ufixed(unsigned) 27-10 test", ufx1, ufx2);
    -- integer
    int  := 0;
    ufx1 := to_ufixed (int, ufx1);
    ufx2 := "000";
    report_error ("to_ufixed(integer) zero test", ufx1, ufx2);
    int  := 1;
    ufx1 := to_ufixed (int, ufx1);
    ufx2 := "000";
    report_error ("to_ufixed(integer) 1-0 test", ufx1, ufx2);
    int  := 3;
    ufx1 := to_ufixed (int, ufx1);
    ufx2 := "001";
    report_error ("to_ufixed(integer) 3-2 test", ufx1, ufx2);
    int  := 19;
    ufx1 := to_ufixed (int, ufx1);
    ufx2 := "001";
    report_error ("to_ufixed(integer) 19-2 test", ufx1, ufx2);
    int  := 27;
    ufx1 := to_ufixed (int, ufx1);
    ufx2 := "101";
    report_error ("to_ufixed(integer) 27-10 test", ufx1, ufx2);
    -- real
    rn   := 0.0;
    ufx1 := to_ufixed (rn, ufx1);
    ufx2 := "000";
    report_error ("to_ufixed(real) zero test", ufx1, ufx2);
    rn   := 1.0;
    ufx1 := to_ufixed (rn, ufx1);
    ufx2 := "000";
    report_error ("to_ufixed(real) 1-0 test", ufx1, ufx2);
    rn   := 3.0;
    ufx1 := to_ufixed (rn, ufx1);
    ufx2 := "001";
    report_error ("to_ufixed(real) 3-2 test", ufx1, ufx2);
    rn   := 19.0;
    ufx1 := to_ufixed (rn, ufx1);
    ufx2 := "001";
    report_error ("to_ufixed(real) 19-2 test", ufx1, ufx2);
    rn   := 27.0;
    ufx1 := to_ufixed (rn, ufx1);
    ufx2 := "101";
    report_error ("to_ufixed(real) 27-10 test", ufx1, ufx2);
    -- to_unsigned
    uf1  := "0000000";
    us1  := to_unsigned(uf1, us1'length);
    assert (us1 = "00000") report "to_unsigned zero test" severity error;
    uf1  := "0000111";
    us1  := to_unsigned(uf1, us1'length);
    assert (us1 = "00000") report "to_unsigned noround test" severity error;
    uf1  := "0001111";
    us1  := to_unsigned(uf1, us1'length);
    assert (us1 = "00001") report "to_unsigned 1 noround test" severity error;
    ufy1 := "00111";                    -- 14
    us1  := to_unsigned (ufy1, us1'length);
    assert (us1 = "01110") report "to_unsigned 14-14 wrap test" severity error;
    ufy1 := "10111";                    -- 46
    us1  := to_unsigned (ufy1, us1'length);
    assert (us1 = "01110") report "to_unsigned 46-14 wrap test" severity error;
    -- to_unsigned size_res
    uf1  := "0000000";
    us1  := to_unsigned(uf1, us1);
    assert (us1 = "00000") report "to_unsigned zero test" severity error;
    uf1  := "0000111";
    us1  := to_unsigned(uf1, us1);
    assert (us1 = "00000") report "to_unsigned noround test" severity error;
    uf1  := "0001111";
    us1  := to_unsigned(uf1, us1);
    assert (us1 = "00001") report "to_unsigned 1 noround test" severity error;
    ufy1 := "00111";                    -- 14
    us1  := to_unsigned (ufy1, us1);
    assert (us1 = "01110") report "to_unsigned 14-14 wrap test" severity error;
    ufy1 := "10111";                    -- 46
    us1  := to_unsigned (ufy1, us1);
    assert (us1 = "01110") report "to_unsigned 46-14 wrap test" severity error;
    -- to_integer
    uf1  := "0000000";
    int  := to_integer(uf1);
    assert (int = 0) report "to_integer zero test" severity error;
    uf1  := "0000111";
    int  := to_integer(uf1);
    assert (int = 0) report "to_integer noround test" severity error;
    uf1  := "0001111";
    int  := to_integer(uf1);
    assert (int = 1) report "to_integer 1 noround test" severity error;
    ufy1 := "00111";                    -- 14
    int  := to_integer (ufy1);
    assert (int = 14) report "to_integer 14-14 wrap test" severity error;
    ufy1 := "10111";                    -- 46
    int  := to_integer (ufy1);
    assert (int = 46) report "to_integer 46-14 wrap test" severity error;
    -- signed
    s1   := "00000";
    sfx1 := to_sfixed (s1, sfx1'high, sfx1'low);
    sfx2 := "000";
    report_error ("to_sfixed(signed) zero test", sfx1, sfx2);
    s1   := "00001";
    sfx1 := to_sfixed (s1, sfx1'high, sfx1'low);
    sfx2 := "000";
    report_error ("to_sfixed(signed) 1-0 test", sfx1, sfx2);
    s1   := "00011";
    sfx1 := to_sfixed (s1, sfx1'high, sfx1'low);
    sfx2 := "001";
    report_error ("to_sfixed(signed) 3-2 test", sfx1, sfx2);
    s1   := "10011";
    sfx1 := to_sfixed (s1, sfx1'high, sfx1'low);
    sfx2 := "001";
    report_error ("to_sfixed(signed) 19-2 test", sfx1, sfx2);
    s1   := "11011";
    sfx1 := to_sfixed (s1, sfx1'high, sfx1'low);
    sfx2 := "101";
    report_error ("to_sfixed(signed) 27-10 test", sfx1, sfx2);
    -- integer
    int  := 0;
    sfx1 := to_sfixed (int, sfx1'high, sfx1'low);
    sfx2 := "000";
    report_error ("to_sfixed(integer) zero test", sfx1, sfx2);
    int  := 1;
    sfx1 := to_sfixed (int, sfx1'high, sfx1'low);
    sfx2 := "000";
    report_error ("to_sfixed(integer) 1-0 test", sfx1, sfx2);
    int  := 3;
    sfx1 := to_sfixed (int, sfx1'high, sfx1'low);
    sfx2 := "001";
    report_error ("to_sfixed(integer) 3-2 test", sfx1, sfx2);
    int  := 19;
    sfx1 := to_sfixed (int, sfx1'high, sfx1'low);
    sfx2 := "001";
    report_error ("to_sfixed(integer) 19-2 test", sfx1, sfx2);
    int  := 27;
    sfx1 := to_sfixed (int, sfx1'high, sfx1'low);
    sfx2 := "101";
    report_error ("to_sfixed(integer) 27-10 test", sfx1, sfx2);
    -- real
    rn   := 0.0;
    sfx1 := to_sfixed (rn, sfx1'high, sfx1'low);
    sfx2 := "000";
    report_error ("to_sfixed(real) zero test", sfx1, sfx2);
    rn   := 1.0;
    sfx1 := to_sfixed (rn, sfx1'high, sfx1'low);
    sfx2 := "000";
    report_error ("to_sfixed(real) 1-0 test", sfx1, sfx2);
    rn   := 3.0;
    sfx1 := to_sfixed (rn, sfx1'high, sfx1'low);
    sfx2 := "001";
    report_error ("to_sfixed(real) 3-2 test", sfx1, sfx2);
    rn   := 19.0;
    sfx1 := to_sfixed (rn, sfx1'high, sfx1'low);
    sfx2 := "001";
    report_error ("to_sfixed(real) 19-2 test", sfx1, sfx2);
    rn   := 27.0;
    sfx1 := to_sfixed (rn, sfx1'high, sfx1'low);
    sfx2 := "101";
    report_error ("to_sfixed(real) 27-10 test", sfx1, sfx2);
    -- size_res
    s1   := "00000";
    sfx1 := to_sfixed (s1, sfx1);
    sfx2 := "000";
    report_error ("to_sfixed(signed) zero test", sfx1, sfx2);
    s1   := "00001";
    sfx1 := to_sfixed (s1, sfx1);
    sfx2 := "000";
    report_error ("to_sfixed(signed) 1-0 test", sfx1, sfx2);
    s1   := "00011";
    sfx1 := to_sfixed (s1, sfx1);
    sfx2 := "001";
    report_error ("to_sfixed(signed) 3-2 test", sfx1, sfx2);
    s1   := "10011";
    sfx1 := to_sfixed (s1, sfx1);
    sfx2 := "001";
    report_error ("to_sfixed(signed) 19-2 test", sfx1, sfx2);
    s1   := "11011";
    sfx1 := to_sfixed (s1, sfx1);
    sfx2 := "101";
    report_error ("to_sfixed(signed) 27-10 test", sfx1, sfx2);
    -- integer
    int  := 0;
    sfx1 := to_sfixed (int, sfx1);
    sfx2 := "000";
    report_error ("to_sfixed(integer) zero test", sfx1, sfx2);
    int  := 1;
    sfx1 := to_sfixed (int, sfx1);
    sfx2 := "000";
    report_error ("to_sfixed(integer) 1-0 test", sfx1, sfx2);
    int  := 3;
    sfx1 := to_sfixed (int, sfx1);
    sfx2 := "001";
    report_error ("to_sfixed(integer) 3-2 test", sfx1, sfx2);
    int  := 19;
    sfx1 := to_sfixed (int, sfx1);
    sfx2 := "001";
    report_error ("to_sfixed(integer) 19-2 test", sfx1, sfx2);
    int  := 27;
    sfx1 := to_sfixed (int, sfx1);
    sfx2 := "101";
    report_error ("to_sfixed(integer) 27-10 test", sfx1, sfx2);
    -- real
    rn   := 0.0;
    sfx1 := to_sfixed (rn, sfx1);
    sfx2 := "000";
    report_error ("to_sfixed(real) zero test", sfx1, sfx2);
    rn   := 1.0;
    sfx1 := to_sfixed (rn, sfx1);
    sfx2 := "000";
    report_error ("to_sfixed(real) 1-0 test", sfx1, sfx2);
    rn   := 3.0;
    sfx1 := to_sfixed (rn, sfx1);
    sfx2 := "001";
    report_error ("to_sfixed(real) 3-2 test", sfx1, sfx2);
    rn   := 19.0;
    sfx1 := to_sfixed (rn, sfx1);
    sfx2 := "001";
    report_error ("to_sfixed(real) 19-2 test", sfx1, sfx2);
    rn   := 27.0;
    sfx1 := to_sfixed (rn, sfx1);
    sfx2 := "101";
    report_error ("to_sfixed(real) 27-10 test", sfx1, sfx2);
    -- to_signed
    sf1  := "0000000";
    s1   := to_signed(sf1, s1'length);
    assert (s1 = "00000") report "to_signed zero test" severity error;
    sf1  := "0000111";
    s1   := to_signed(sf1, s1'length);
    assert (s1 = "00000") report "to_signed noround test" severity error;
    sf1  := "0001111";
    s1   := to_signed(sf1, s1'length);
    assert (s1 = "00001") report "to_signed 1 noround test" severity error;
    sfy1 := "00111";                    -- 14
    s1   := to_signed (sfy1, s1'length);
    assert (s1 = "01110") report "to_signed 14-14 wrap test" severity error;
    sfy1 := "10111";                    -- 46
    s1   := to_signed (sfy1, s1'length);
    assert (s1 = "01110") report "to_signed 46-14 wrap test" severity error;
    -- to_signed size_res
    sf1  := "0000000";
    s1   := to_signed(sf1, s1);
    assert (s1 = "00000") report "to_signed zero test" severity error;
    sf1  := "0000111";
    s1   := to_signed(sf1, s1);
    assert (s1 = "00000") report "to_signed noround test" severity error;
    sf1  := "0001111";
    s1   := to_signed(sf1, s1);
    assert (s1 = "00001") report "to_signed 1 noround test" severity error;
    sfy1 := "00111";                    -- 14
    s1   := to_signed (sfy1, s1);
    assert (s1 = "01110") report "to_signed 14-14 wrap test" severity error;
    sfy1 := "10111";                    -- 46
    s1   := to_signed (sfy1, s1);
    assert (s1 = "01110") report "to_signed 46-14 wrap test" severity error;
    -- to_integer
    sf1  := "0000000";
    int  := to_integer(sf1);
    assert (int = 0) report "to_integer zero test" severity error;
    sf1  := "0000111";
    int  := to_integer(sf1);
    assert (int = 0) report "to_integer noround test" severity error;
    sf1  := "0001111";
    int  := to_integer(sf1);
    assert (int = 1) report "to_integer 1 noround test" severity error;
    sfy1 := "00111";                    -- 14
    int  := to_integer (sfy1);
    assert (int = 14) report "to_integer 14-14 wrap test" severity error;
    sfy1 := "10111";                    -- 46
    int  := to_integer (sfy1);
    assert (int = -18) report "to_integer 46-14 wrap test "
      & INTEGER'image (int) severity error;
    assert quiet report "SIGNED and UNSIGNED testing completed"
      severity note;
    sunstest_done <= true;
  end process sunstest;

  -- purpose: test the divide and reciprocal functions
  divtest : process is
    variable uf1, uf2 : ufixed (3 downto -3);
    variable ufd1, ufd2 : ufixed (ufixed_high (uf1, '/', uf2) downto
                                  ufixed_low (uf1, '/', uf2));
    variable ufm1, ufm2 : ufixed (ufixed_high (uf1, 'r', uf2) downto
                                  ufixed_low (uf1, 'r', uf2));
    variable ufr1, ufr2 : ufixed (ufixed_high (uf1, '1', uf2) downto
                                  ufixed_low (uf1, '1', uf2));
    variable sf1, sf2 : sfixed (3 downto -3);
    variable sfd1, sfd2 : sfixed (sfixed_high (sf1, '/', sf2) downto
                                  sfixed_low (sf1, '/', sf2));
    variable sfm1, sfm2 : sfixed (sfixed_high (sf1, 'r', sf2) downto
                                  sfixed_low (sf1, 'r', sf2));
    variable sfr1, sfr2 : sfixed (sfixed_high (sf1, '1', sf2) downto
                                  sfixed_low (sf1, '1', sf2));
  begin
    wait until start_divtest;
    uf1  := "0001000";                  -- 1
    uf2  := "0011000";                  -- 3
    ufd1 := uf1 / uf2;
    ufd2 := "00000000101010";
    report_error ("1/3 not rounded", ufd1, ufd2);
    uf1  := "0001000";                  -- 1
    uf2  := "0110000";                  -- 6
    ufd1 := uf1 / uf2;
    ufd2 := "00000000010101";
    report_error ("1/6 not rounded", ufd1, ufd2);
    uf1  := "0001000";                  -- 1
    uf2  := "0011000";                  -- 3
    ufd1 := divide (uf1, uf2);
    ufd2 := "00000000101010";
    report_error ("1/3 not rounded", ufd1, ufd2);
    uf1  := "0001000";                  -- 1
    uf2  := "0110000";                  -- 6
    ufd1 := divide (uf1, uf2);
    ufd2 := "00000000010101";
    report_error ("1/6 not rounded", ufd1, ufd2);
    uf2  := "0011000";                  -- 3
    ufr1 := reciprocal (uf2);
    ufr2 := "00000101";
    report_error ("recip 3 not rounded", ufr1, ufr2);
    uf2  := "0110000";                  -- 6
    ufr1 := reciprocal (uf2);
    ufr2 := "00000010";
    report_error ("recip 6 not rounded", ufr1, ufr2);
--    ufr1 := "00000000";
--    ufr2 := "00000001";
--    report_error ("an error", ufr1, ufr2);
    -- mod and remainder
    -- signed
    sf1  := "0001000";                  -- 1
    sf2  := "0011000";                  -- 3
    sfd1 := sf1 / sf2;
    sfd2 := "00000000010101";
    report_error ("s1/3 not rounded", sfd1, sfd2);
    sf1  := "0001000";                  -- 1
    sf2  := "0110000";                  -- 6
    sfd1 := sf1 / sf2;
    sfd2 := "00000000001010";
    report_error ("s1/6 not rounded", sfd1, sfd2);
    sf1  := "0001000";                  -- 1
    sf2  := "0011000";                  -- 3
    sfd1 := divide (sf1, sf2);
    sfd2 := "00000000010101";
    report_error ("s1/3 not rounded", sfd1, sfd2);
    sf1  := "0001000";                  -- 1
    sf2  := "0110000";                  -- 6
    sfd1 := divide (sf1, sf2);
    sfd2 := "00000000001010";
    report_error ("s1/6 not rounded", sfd1, sfd2);
    sf2  := "0011000";                  -- 3
    sfr1 := reciprocal (sf2);
    sfr2 := "00000010";
    report_error ("srecip 3 not rounded", sfr1, sfr2);
    sf2  := "0110000";                  -- 6
    sfr1 := reciprocal (sf2);
    sfr2 := "00000001";
    report_error ("srecip 6 not rounded", sfr1, sfr2);
--    sfr1 := "00000000";
--    sfr2 := "00000001";
--    report_error ("an error", sfr1, sfr2);
    assert quiet report "Divide and reciprocal testing completed"
      severity note;
    divtest_done <= true;
  end process divtest;
end architecture testbench;
