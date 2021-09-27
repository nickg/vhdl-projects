-- --------------------------------------------------------------------
-- Title      : Test vectors for testing additions to package "std.standard".
-- check bit and boolean boolean functions
-- check bit and bit_vector boolean operations
-- check minimum and maximum functions
-- Last Modified: $Date: 2010/07/19 17:38:45 $
-- RCS ID: $Id: test_standard_additions.vhdl,v 2.0 2010/07/19 17:38:45 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_standard_additions is
  generic (
    quiet : BOOLEAN := false);          -- run quietly

end entity test_standard_additions;

use std.textio.all;
use std.env.all;

architecture testbench of test_standard_additions is
  signal start_booleantest, booleantest_done       : BOOLEAN := false;  -- test new booleans
  signal start_booleanvectest, booleanvectest_done : BOOLEAN := false;  -- test new booleans
  signal start_minmaxtest, minmaxtest_done         : BOOLEAN := false;  -- minmax test
  signal start_boolvtest, boolvtest_done           : BOOLEAN := false;  -- boolean_vector test
  signal start_xreducetest, xreducetest_done       : BOOLEAN := false;  -- edge test
  signal start_edgetest, edgetest_done             : BOOLEAN := false;  -- edge test
  signal start_qestionequ, questionequ_done        : BOOLEAN := false;  -- test ?= operators
  signal clk                                       : BIT;  -- clock signal (for edge test)
begin
  -- purpose: main test loop
  tester : process is
    constant new_line                      : STRING := LF& "";  -- test of NL constant
    -- test of the sim_resolution constant
    constant simulator_resolution_constant : TIME   := RESOLUTION_LIMIT;
  begin  -- process testter
    assert (quiet)
      report "Simulator resolution is: "
      & TIME'image(simulator_resolution_constant)
      severity note;
    start_booleantest    <= true;
    wait until booleantest_done;
    start_booleanvectest <= true;
    wait until booleanvectest_done;
    start_minmaxtest     <= true;
    wait until minmaxtest_done;
    start_xreducetest    <= true;
    wait until xreducetest_done;
    start_edgetest       <= true;
    wait until edgetest_done;
    start_boolvtest      <= true;
    wait until boolvtest_done;
    start_qestionequ     <= true;
    wait until questionequ_done;

    -- test reduction operations
    report "Updated package std.standard Testing complete" severity note;
    finish (0);

  end process tester;

  -- purpose: test the new boolean/bit functions
  booleantest : process is
    variable b1, b2   : BIT;
    variable bo1, bo2 : BOOLEAN;
  begin  -- process booleantest
    ---------------------------------------------------------------------------
    -- Checking the boolean/bit operations against the tables
    ---------------------------------------------------------------------------
    wait until start_booleantest;
    -- Test the new "??" operator
    b1  := '0';
    bo1 := ?? b1;
    assert (not bo1)
      report "?? (" & to_string(b1) & ") returned " & to_string(bo1)
      severity error;
    b1  := '1';
    bo1 := ?? b1;
    assert (bo1)
      report "?? (" & to_string(b1) & ") returned " & to_string(bo1)
      severity error;
    assert (quiet) report "boolean test completed" severity note;
    booleantest_done <= true;
    wait;
  end process booleantest;

-- purpose: boolean vector test
-- type   : combinational
-- inputs : 
-- outputs: 
  booleanvectest : process is
    variable bv1, bv2, bv3 : BIT_VECTOR (2 downto 0);
    variable b1, b2        : BIT;
    variable bo1, bo2      : BOOLEAN;
  begin  -- process booleanvectest

    wait until start_booleanvectest;
    -- and
    bv1 := "010";
    b1  := '0';
    bv2 := bv1 and b1;
    bv3 := (others => '0');
    assert (bv2 = bv3) report "vector and bit error " & to_string (bv1) & " and "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '1';
    bv2 := bv1 and b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "vector and bit error " & to_string (bv1) & " and "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "101";
    b1  := '0';
    bv2 := b1 and bv1;
    bv3 := (others => '0');
    assert (bv2 = bv3) report "bit and vector error " & to_string (bv1) & " and "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "101";
    b1  := '1';
    bv2 := b1 and bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit and vector error " & to_string (bv1) & " and "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    -- or
    bv1 := "110";
    b1  := '0';
    bv2 := bv1 or b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "vector or bit error " & to_string (bv1) & " or "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "110";
    b1  := '1';
    bv2 := bv1 or b1;
    bv3 := (others => '1');
    assert (bv2 = bv3) report "vector or bit error " & to_string (bv1) & " or "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "011";
    b1  := '0';
    bv2 := b1 or bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit or vector error " & to_string (bv1) & " or "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "011";
    b1  := '1';
    bv2 := b1 or bv1;
    bv3 := (others => '1');
    assert (bv2 = bv3) report "bit or vector error " & to_string (bv1) & " or "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    -- xor
    bv1 := "010";
    b1  := '0';
    bv2 := bv1 xor b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "vector xor bit error " & to_string (bv1) & " xor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '1';
    bv2 := bv1 xor b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "vector xor bit error " & to_string (bv1) & " xor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "101";
    b1  := '0';
    bv2 := b1 xor bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit xor vector error " & to_string (bv1) & " xor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "101";
    b1  := '1';
    bv2 := b1 xor bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit xor vector error " & to_string (bv1) & " xor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    -- nand
    bv1 := "010";
    b1  := '0';
    bv2 := bv1 nand b1;
    bv3 := (others => '1');
    assert (bv2 = bv3) report "vector nand bit error " & to_string (bv1)
      & " nand " & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '1';
    bv2 := bv1 nand b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "vector nand bit error " & to_string (bv1)
      & " nand " & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '0';
    bv2 := b1 nand bv1;
    bv3 := (others => '1');
    assert (bv2 = bv3) report "bit nand vector error " & to_string (bv1)
      & " nand " & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '1';
    bv2 := b1 nand bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit nand vector error " & to_string (bv1)
      & " nand " & to_string(b1) & " /= " & to_string (bv2) severity error;
    -- nor
    bv1 := "110";
    b1  := '0';
    bv2 := bv1 nor b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "vector nor bit error " & to_string (bv1) & " nor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "110";
    b1  := '1';
    bv2 := bv1 nor b1;
    bv3 := (others => '0');
    assert (bv2 = bv3) report "vector nor bit error " & to_string (bv1) & " nor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "110";
    b1  := '0';
    bv2 := b1 nor bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit nor vector error " & to_string (bv1) & " nor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "110";
    b1  := '1';
    bv2 := b1 nor bv1;
    bv3 := (others => '0');
    assert (bv2 = bv3) report "bit nor vector error " & to_string (bv1) & " nor "
      & to_string(b1) & " /= " & to_string (bv2) severity error;
    -- xnor
    bv1 := "010";
    b1  := '0';
    bv2 := bv1 xnor b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "vector xnor bit error " & to_string (bv1)
      & " xnor " & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '1';
    bv2 := bv1 xnor b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "vector xnor bit error " & to_string (bv1)
      & " xnor " & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '0';
    bv2 := b1 xnor bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit xnor vector error " & to_string (bv1)
      & " xnor " & to_string(b1) & " /= " & to_string (bv2) severity error;
    bv1 := "010";
    b1  := '1';
    bv2 := b1 xnor bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit xnor vector error " & to_string (bv1)
      & " xnor " & to_string(b1) & " /= " & to_string (bv2) severity error;
    assert (quiet) report "boolean vector test complete" severity note;
    booleanvectest_done <= true;
    wait;
  end process booleanvectest;

  -- purpose: test the min and max functions
  minmaxtest : process is
    variable bv1, bv2, bv3    : BIT_VECTOR (3 downto 0);
    variable bv9, bv8, bv7    : BIT_VECTOR (4 downto 0);
    variable int1, int2, int3 : INTEGER;
    variable b1, b2, b3       : BIT;
    variable c1, c2, c3       : CHARACTER;
    variable sl1, sl2, sl3    : SEVERITY_LEVEL;
    variable r1, r2, r3       : REAL;
    variable t1, t2, t3       : TIME;
    variable st1, st2, st3    : STRING (1 to 4);
    variable fok1, fok2, fok3 : FILE_OPEN_KIND;
    variable fos1, fos2, fos3 : FILE_OPEN_STATUS;
    variable iv1, iv2, iv3    : integer_vector (3 downto 0);
    variable iv9, iv8         : integer_vector (0 to 4);
    variable st9              : STRING (5 downto 1);
    variable rv1, rv2, rv3    : real_vector (3 downto 0);
    variable rv9, rv8         : real_vector (0 to 4);
    variable tv1, tv2, tv3    : time_vector (3 downto 0);
    variable tv9, tv8         : time_vector (0 to 4);
  begin  -- process minmaxtest
    wait until start_minmaxtest;
    bv1 := "0001";
    bv2 := "0010";
    assert (bv2 > bv1) report to_string(bv2) & " > " & to_string(bv1)
      & " miscompare" severity error;
    assert not (bv2 < bv1) report to_string(bv2) & " < " & to_string(bv1)
      & " miscompare" severity error;
    assert (bv2 >= bv1) report to_string(bv2) & " >= " & to_string(bv1)
      & " miscompare" severity error;
    assert not (bv2 <= bv1) report to_string(bv2) & " <= " & to_string(bv1)
      & " miscompare" severity error;
    assert not (bv2 = bv1) report to_string(bv2) & " = " & to_string(bv1)
      & " miscompare" severity error;
    assert (bv2 /= bv1) report to_string(bv2) & " /= " & to_string(bv1)
      & " miscompare" severity error;
    bv3 := maximum (bv1, bv2);
    assert ((bv3 = bv2)) report "max (" & to_string(bv1) & ", "
      & to_string(bv2) & ") = " & to_string (bv3) severity error;
    bv3 := maximum (bv2, bv1);
    assert ((bv3 = bv2)) report "max (" & to_string(bv2) & ", "
      & to_string(bv1) & ") = " & to_string (bv3) severity error;
    
    bv3 := minimum (bv1, bv2);
    assert ((bv3 = bv1)) report "min (" & to_string(bv1) & ", "
      & to_string(bv2) & ") = " & to_string (bv3) severity error;
    bv3 := minimum (bv2, bv1);
    assert ((bv3 = bv1)) report "min (" & to_string(bv2) & ", "
      & to_string(bv1) & ") = " & to_string (bv3) severity error;
    -- It should be noted that the behavior of the min and
    -- max routine will be different depending on the "numeric_bit_unsigned"
    -- package, which replaced the compare (<) operator.
    -- You will find the opposite logic in "test_nbuns.vhd"
    bv9 := "00111";
    bv3 := "0110";
    assert (bv9 < bv3) report to_string(bv9) & " < " & to_string(bv3)
      & " miscompare" severity error;
    assert (bv3 > bv9) report to_string(bv3) & " > " & to_string(bv9)
      & " miscompare" severity error;
    bv1 := maximum (bv9, bv3);
    assert (bv1 = bv3) report "max (" & to_string(bv9) & ", "
      & to_string(bv3) & ") = " & to_string (bv1) severity error;
    bv1 := maximum (bv3, bv9);
    assert (bv1 = bv3) report "max (" & to_string(bv3) & ", "
      & to_string(bv9) & ") = " & to_string (bv1) severity error;
    bv8 := minimum (bv9, bv3);
    assert (bv8 = bv9) report "min (" & to_string(bv9) & ", "
      & to_string(bv3) & ") = " & to_string (bv8) severity error;
    bv8 := minimum (bv3, bv9);
    assert (bv8 = bv9) report "min (" & to_string(bv3) & ", "
      & to_string(bv9) & ") = " & to_string (bv8) severity error;

    int1 := 3;
    int2 := 4;
    int3 := maximum (int1, int2);
    assert (int3 = int2) report "max (" & to_string(int1) & ", "
      & to_string(int2) & ") = " & to_string(int3) severity error;
    int3 := maximum (int2, int1);
    assert (int3 = int2) report "max (" & to_string(int2) & ", "
      & to_string(int1) & ") = " & to_string(int3) severity error;
    int3 := minimum (int1, int2);
    assert (int3 = int1) report "min (" & to_string(int1) & ", "
      & to_string(int2) & ") = " & to_string(int3) severity error;
    int3 := minimum (int2, int1);
    assert (int3 = int1) report "min (" & to_string(int2) & ", "
      & to_string(int1) & ") = " & to_string(int3) severity error;
    b1 := '0';
    b2 := '1';
    b3 := maximum (b1, b2);
    assert (b3 = b2) report "max ( " & to_string(b1) & ", "
      & to_string(b2) & ") = " & to_string(b3) severity error;
    b3 := maximum (b2, b1);
    assert (b3 = b2) report "max ( " & to_string(b2) & ", "
      & to_string(b1) & ") = " & to_string(b3) severity error;
    b3 := minimum (b1, b2);
    assert (b3 = b1) report "min ( " & to_string(b1) & ", "
      & to_string(b2) & ") = " & to_string(b3) severity error;
    b3 := minimum (b2, b1);
    assert (b3 = b1) report "min ( " & to_string(b2) & ", "
      & to_string(b1) & ") = " & to_string(b3) severity error;
    c1 := 'A';
    c2 := 'Z';
    c3 := maximum (c1, c2);
    assert (c3 = c2) report "max (" & c1 & ", " & c2 & ") = " & c3
      severity error;
    c3 := maximum (c2, c1);
    assert (c3 = c2) report "max (" & c2 & ", " & c1 & ") = " & c3
      severity error;
    c3 := minimum (c1, c2);
    assert (c3 = c1) report "min (" & c1 & ", " & c2 & ") = " & c3
      severity error;
    c3 := minimum (c2, c1);
    assert (c3 = c1) report "min (" & c2 & ", " & c1 & ") = " & c3
      severity error;
    sl1 := note;
    sl2 := failure;
    sl3 := maximum (sl1, sl2);
    assert (sl3 = sl2) report "max (" & to_string(sl1) & ", "
      & to_string(sl2) & ") = " & to_string(sl3)
      severity error;
    sl3 := maximum (sl2, sl1);
    assert (sl3 = sl2) report "max (" & to_string(sl2) & ", "
      & to_string(sl1) & ") = " & to_string(sl3)
      severity error;
    sl3 := minimum (sl1, sl2);
    assert (sl3 = sl1) report "min (" & to_string(sl1) & ", "
      & to_string(sl2) & ") = " & to_string(sl3)
      severity error;
    sl3 := minimum (sl2, sl1);
    assert (sl3 = sl1) report "min (" & to_string(sl2) & ", "
      & to_string(sl1) & ") = " & to_string(sl3)
      severity error;
    r1 := 7.5;
    r2 := -16.3333333333;
    r3 := maximum (r1, r2);
    assert (r3 = r1) report "max (" & to_string(r1) & ", " & to_string(r2)
      & ") = " & to_string(r3) severity error;
    r3 := maximum (r2, r1);
    assert (r3 = r1) report "max (" & to_string(r2) & ", " & to_string(r1)
      & ") = " & to_string(r3) severity error;
    r3 := minimum (r1, r2);
    assert (r3 = r2) report "min (" & to_string(r1) & ", " & to_string(r2)
      & ") = " & to_string(r3) severity error;
    r3 := minimum (r2, r1);
    assert (r3 = r2) report "min (" & to_string(r2) & ", " & to_string(r1)
      & ") = " & to_string(r3) severity error;
    t1 := 5 ns;
    t2 := 1.4 min;
    t3 := maximum (t1, t2);
    assert (t3 = t2) report "max (" & to_string(t1) & ", " & to_string(t2)
      & ") = " & to_string(t3) severity error;
    t3 := maximum (t2, t1);
    assert (t3 = t2) report "max (" & to_string(t2) & ", " & to_string(t1)
      & ") = " & to_string(t3) severity error;
    t3 := minimum (t1, t2);
    assert (t3 = t1) report "min (" & to_string(t1) & ", " & to_string(t2)
      & ") = " & to_string(t3) severity error;
    t3 := minimum (t2, t1);
    assert (t3 = t1) report "min (" & to_string(t2) & ", " & to_string(t1)
      & ") = " & to_string(t3) severity error;
    st1 := "ABCD";
    st2 := "WXYZ";
    st3 := maximum (st1, st2);
    assert (st3 = st2) report "max (""" & st1 & """, """
      & st2 & """) = """ & st3 & '"'
      severity error;
    st3 := maximum (st2, st1);
    assert (st3 = st2) report "max (""" & st2 & """, """
      & st1 & """) = """ & st3 & '"'
      severity error;
    st3 := minimum (st1, st2);
    assert (st3 = st1) report "min (""" & st1 & """, """
      & st2 & """) = """ & st3 & '"'
      severity error;
    st3 := minimum (st2, st1);
    assert (st3 = st1) report "min (""" & st2 & """, """
      & st1 & """) = """ & st3 & '"'
      severity error;
    fok1 := read_mode;
    fok2 := write_mode;
    fok3 := maximum (fok1, fok2);
    assert (fok3 = fok2) report "max (" & to_string(fok1) & ", "
      & to_string(fok2) & ") = " & to_string(fok3)
      severity error;
    fok3 := maximum (fok2, fok1);
    assert (fok3 = fok2) report "max (" & to_string(fok2) & ", "
      & to_string(fok1) & ") = " & to_string(fok3)
      severity error;
    fok3 := minimum (fok1, fok2);
    assert (fok3 = fok1) report "min (" & to_string(fok1) & ", "
      & to_string(fok2) & ") = " & to_string(fok3)
      severity error;
    fok3 := minimum (fok2, fok1);
    assert (fok3 = fok1) report "min (" & to_string(fok2) & ", "
      & to_string(fok1) & ") = " & to_string(fok3)
      severity error;
    fos1 := open_ok;
    fos2 := name_error;
    fos3 := maximum (fos1, fos2);
    assert (fos3 = fos2) report "max (" & to_string(fos1) & ", "
      & to_string(fos2) & ") = "& to_string(fos3)
      severity error;
    fos3 := maximum (fos2, fos1);
    assert (fos3 = fos2) report "max (" & to_string(fos2) & ", "
      & to_string(fos1) & ") = "& to_string(fos3)
      severity error;
    fos3 := minimum (fos1, fos2);
    assert (fos3 = fos1) report "min (" & to_string(fos1) & ", "
      & to_string(fos2) & ") = "& to_string(fos3)
      severity error;
    fos3 := minimum (fos2, fos1);
    assert (fos3 = fos1) report "min (" & to_string(fos2) & ", "
      & to_string(fos1) & ") = "& to_string(fos3)
      severity error;

    -- Now do the vectorized ones.
    bv1 := "0100";
    b1  := maximum (bv1);
    b2  := '1';
    assert b1 = b2
      report "maximum (" & to_string(bv1) & ") /= " & to_string (b2)
      severity error;
    bv9 := "10111";
    b1  := maximum (bv9);
    b2  := '1';
    assert b1 = b2
      report "maximum (" & to_string(bv9) & ") /= " & to_string (b2)
      severity error;
    bv1 := "0100";
    b1  := minimum (bv1);
    b2  := '0';
    assert b1 = b2
      report "minimum (" & to_string(bv1) & ") /= " & to_string (b2)
      severity error;
    bv9 := "10111";
    b1  := minimum (bv9);
    b2  := '0';
    assert b1 = b2
      report "minimum (" & to_string(bv9) & ") /= " & to_string (b2)
      severity error;
    iv1  := (5, 4, 30, 2);
    int1 := maximum (iv1);
    int2 := 30;
    assert int1 = int2
      report "maximum (vector" & to_string(iv1(1)) & ") /= " & to_string (int2)
      severity error;
    iv9  := (6, 18, -12, 14, 0);
    int1 := maximum (iv9);
    int2 := 18;
    assert int1 = int2
      report "maximum (vector " & to_string(iv9(1)) & ") /= " & to_string (int2)
      severity error;
    iv1  := (5, 4, 30, 2);
    int1 := minimum (iv1);
    int2 := 2;
    assert int1 = int2
      report "minimum (vector " & to_string(iv1(1)) & ") /= " & to_string (int2)
      severity error;
    iv9  := (6, 18, -12, 14, 0);
    int1 := minimum (iv9);
    int2 := -12;
    assert int1 = int2
      report "minimum (vector " & to_string(iv9(1)) & ") /= " & to_string (int2)
      severity error;
    assert (iv1 = iv1) report "Integer vector = miscompare"
      severity error;
    assert not (iv1 = iv9) report "Integer vector not = miscompare"
      severity error;
    assert not (iv1 /= iv1) report "Integer vector /= miscompare"
      severity error;
    assert (iv1 /= iv9) report "Integer vector not /= miscompare"
      severity error;
    assert (iv1 < iv9) report "Integer vector < length miscompare"
      severity error;
    assert (iv9 > iv1) report "Integer vector > length miscompare"
      severity error;
    assert (iv1 <= iv9) report "Integer vector <= length miscompare"
      severity error;
    assert (iv9 >= iv1) report "Integer vector >= length miscompare"
      severity error;
    assert not (iv1 > iv9) report "Integer vector not > length miscompare"
      severity error;
    assert not (iv9 < iv1) report "Integer vector not < length miscompare"
      severity error;
    assert not (iv9 <= iv1) report "Integer vector not <= length miscompare"
      severity error;
    assert not (iv1 >= iv9) report "Integer vector not >= length miscompare"
      severity error;
    assert (iv1 <= iv1) report "Integer vector = <= miscompare"
      severity error;
    assert (iv1 >= iv1) report "Integer vector = >= miscompare"
      severity error;
    iv2  := (5, 5, 30, 2);
    assert (iv1 < iv2) report "Integer vector straight compare <"
      severity error;
    assert not (iv1 > iv2) report "Integer vector straight compare not >"
      severity error;
    assert (iv2 > iv1) report "Integer vector straight compare >"
      severity error;
    assert not (iv1 > iv2) report "Integer vector straight compare not <"
      severity error;
    st1 := "ABCD";
    c1  := maximum (st1);
    c2  := 'D';
    assert c1 = c2
      report "maximum (" & st1 & ") /= " & c2
      severity error;
    st9 := "zx&F ";
    c1  := maximum (st9);
    c2  := 'z';
    assert c1 = c2
      report "maximum (" & st9 & ") = " & c1
      severity error;
    st1 := "ABCD";
    c1  := minimum (st1);
    c2  := 'A';
    assert c1 = c2
      report "minimum (" & st1 & ") /= " & c2
      severity error;
    st9 := "zx&F ";
    c1  := minimum (st9);
    c2  := ' ';
    assert c1 = c2
      report "minimum (" & st9 & ") = " & c1
      severity error;
    rv1 := (7.9, 5.5, 3.33, -1000.0);
    r1  := maximum (rv1);
    r2  := 7.9;
    assert r1 = r2
      report "maximum (vector" & to_string(rv1(1)) & ") = " & to_string (r1)
      severity error;
    rv9 := (-0.5, 5.5, 80.4, 1000000.0, 0.0);
    r1  := maximum (rv9);
    r2  := 1000000.0;
    assert r1 = r2
      report "maximum (vector" & to_string(rv9(1)) & ") = " & to_string (r1)
      severity error;
    rv1 := (7.9, 5.5, 3.33, -1000.0);
    r1  := minimum (rv1);
    r2  := -1000.0;
    assert r1 = r2
      report "minimum (vector" & to_string(rv1(1)) & ") = " & to_string (r1)
      severity error;
    rv9 := (-0.5, 5.5, 80.4, 1000000.0, 0.0);
    r1  := minimum (rv9);
    r2  := -0.5;
    assert r1 = r2
      report "minimum (vector" & to_string(rv9(1)) & ") = " & to_string (r1)
      severity error;
    assert (rv1 = rv1) report "Real vector = miscompare"
      severity error;
    assert not (rv1 = rv9) report "Real vector not = miscompare"
      severity error;
    assert not (rv1 /= rv1) report "Real vector /= miscompare"
      severity error;
    assert (rv1 /= rv9) report "Real vector not /= miscompare"
      severity error;
--    assert (rv1 < rv9) report "Real vector < length miscompare"
--      severity error;
--    assert (rv9 > rv1) report "Real vector > length miscompare"
--      severity error;
--    assert (rv1 <= rv9) report "Real vector <= length miscompare"
--      severity error;
--    assert (rv9 >= rv1) report "Real vector >= length miscompare"
--      severity error;
--    assert not (rv1 > rv9) report "Real vector not > length miscompare"
--      severity error;
--    assert not (rv9 < rv1) report "Real vector not < length miscompare"
--      severity error;
--    assert not (rv9 <= rv1) report "Real vector not <= length miscompare"
--      severity error;
--    assert not (rv1 >= rv9) report "Real vector not >= length miscompare"
--      severity error;
--    assert (rv1 <= rv1) report "Real vector = <= miscompare"
--      severity error;
--    assert (rv1 >= rv1) report "Real vector = >= miscompare"
--      severity error;
--    rv2 := (7.9, 5.5, 3.34, -1000.0);
--    assert (rv1 < rv2) report "Real vector straight compare <"
--      severity error;
--    assert not (rv1 > rv2) report "Real vector straight compare not >"
--      severity error;
--    assert (rv2 > rv1) report "Real vector straight compare >"
--      severity error;
--    assert not (rv1 > rv2) report "Real vector straight compare not <"
--      severity error;
    tv1 := (7.9 ns, 5.5 ns, 3.33 ns, -1000.0 ns);
    t1  := maximum (tv1);
    t2  := 7.9 ns;
    assert t1 = t2
      report "maximum (vector" & to_string(tv1(1)) & ") = " & to_string (t1)
      severity error;
    tv9 := (-0.5 ns, 5.5 ns, 80.4 ns, 1000000.0 ns, 0.0 ns);
    t1  := maximum (tv9);
    t2  := 1000000.0 ns;
    assert t1 = t2
      report "maximum (vector" & to_string(tv9(1)) & ") = " & to_string (t1)
      severity error;
    tv1 := (7.9 ns, 5.5 ns, 3.33 ns, -1000.0 ns);
    t1  := minimum (tv1);
    t2  := -1000.0 ns;
    assert t1 = t2
      report "minimum (vector" & to_string(tv1(1)) & ") = " & to_string (t1)
      severity error;
    tv9 := (-0.5 ns, 5.5 ns, 80.4 ns, 1000000.0 ns, 0.0 ns);
    t1  := minimum (tv9);
    t2  := -0.5 ns;
    assert t1 = t2
      report "minimum (vector" & to_string(tv9(1)) & ") = " & to_string (t1)
      severity error;
    assert (tv1 = tv1) report "Time vector = miscompare"
      severity error;
    assert not (tv1 = tv9) report "Time vector not = miscompare"
      severity error;
    assert not (tv1 /= tv1) report "Time vector /= miscompare"
      severity error;
    assert (tv1 /= tv9) report "Time vector not /= miscompare"
      severity error;
--    assert (tv1 < tv9) report "Time vector < length miscompare"
--      severity error;
--    assert (tv9 > tv1) report "Time vector > length miscompare"
--      severity error;
--    assert (tv1 <= tv9) report "Time vector <= length miscompare"
--      severity error;
--    assert (tv9 >= tv1) report "Time vector >= length miscompare"
--      severity error;
--    assert not (tv1 > tv9) report "Time vector not > length miscompare"
--      severity error;
--    assert not (tv9 < tv1) report "Time vector not < length miscompare"
--      severity error;
--    assert not (tv9 <= tv1) report "Time vector not <= length miscompare"
--      severity error;
--    assert not (tv1 >= tv9) report "Time vector not >= length miscompare"
--      severity error;
--    assert (tv1 <= tv1) report "Time vector = <= miscompare"
--      severity error;
--    assert (tv1 >= tv1) report "Time vector = >= miscompare"
--      severity error;
--    tv2 := (7.9 ns, 5.5 ns, 3.33 ns, -999.0 ns);
--    assert (tv1 < tv2) report "Time vector straight compare <"
--      severity error;
--    assert not (tv1 > tv2) report "Time vector straight compare not >"
--      severity error;
--    assert (tv2 > tv1) report "Time vector straight compare >"
--      severity error;
--    assert not (tv1 > tv2) report "Time vector straight compare not <"
--      severity error;
    assert (quiet) report "minmax test complete" severity note;
    minmaxtest_done <= true;
    wait;
  end process minmaxtest;

  reducetest : process is
    -- purpose: Error Reporting routine
    procedure report_error (
      constant message : in STRING;           -- message string
      actual           : in BIT_VECTOR;       -- result from code
      expected         : in BIT) is           -- compared against
    variable L : LINE;
  begin  -- report_error
    assert (false)
      report message & " (" & to_string(actual) & ") /= " & to_string(expected)
      severity error;
    return;
  end report_error;
  variable slv16 : BIT_VECTOR (15 downto 0);  -- 16 bit slv
  variable s     : BIT;                       -- one bit
  -- Odd lenghths to test recursive algorithem
  variable slv13 : BIT_VECTOR (12 downto 0);  -- 13 bit slv

  variable nullarray : BIT_VECTOR (0 downto 12);  -- null array

  begin
    wait until start_xreducetest;
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
    slv16 := "1111111111111111";
    if (or (slv16) /= '1') then
      report_error ("or reduce", slv16, '1');
    end if;
    slv16 := "1000000000000001";
    if (or (slv16) /= '1') then
      report_error ("or reduce", slv16, '1');
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
    if (or (nullarray) /= '0') then    -- Null array test
      report_error ("or reduce NULL", slv13, '0');
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
    slv16 := "1111111111111111";
    if (and (slv16) /= '1') then
      report_error ("and reduce", slv16, '1');
    end if;
    slv16 := "1000000000000001";
    if (and (slv16) /= '0') then
      report_error ("and reduce", slv16, '0');
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
    if (and (nullarray) /= '1') then   -- Null array test
      report_error ("and reduce NULL", slv13, '0');
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
    slv16 := "1111111111111111";
    if (xor (slv16) /= '0') then
      report_error ("xor reduce", slv16, '0');
    end if;
    slv16 := "1000000000000001";
    if (xor (slv16) /= '0') then
      report_error ("xor reduce", slv16, '0');
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
    if (xor (nullarray) /= '0') then   -- Null array test
      report_error ("xor reduce NULL", slv13, '0');
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
    slv16 := "1111111111111111";
    if (nor (slv16) /= '0') then
      report_error ("nor reduce", slv16, '0');
    end if;
    slv16 := "1000000000000001";
    if (nor (slv16) /= '0') then
      report_error ("nor reduce", slv16, '0');
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
    if (nor (nullarray) /= '1') then   -- Null array test
      report_error ("nor reduce NULL", slv13, '1');
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
    slv16 := "1111111111111111";
    if (nand (slv16) /= '0') then
      report_error ("nand reduce", slv16, '0');
    end if;
    slv16 := "1000000000000001";
    if (nand (slv16) /= '1') then
      report_error ("nand reduce", slv16, '1');
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
    if (nand (nullarray) /= '0') then  -- Null array test
      report_error ("nand reduce NULL", slv13, '1');
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
    slv16 := "1111111111111111";
    if (xnor (slv16) /= '1') then
      report_error ("xnor reduce", slv16, '1');
    end if;
    slv16 := "1000000000000001";
    if (xnor (slv16) /= '1') then
      report_error ("xnor reduce", slv16, '1');
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
    if (xnor (nullarray) /= '1') then  -- Null array test
      report_error ("xnor reduce NULL", slv13, '1');
    end if;
    assert (quiet) report "reduction operation test complete" severity note;
    xreducetest_done <= true;
  end process reducetest;

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

  -- purpose: Boolean_Vector test
  boolvtest : process is
    variable bv1, bv2, bv3, bv4 : boolean_vector (3 downto 0);
    variable bvx1, bvx2         : boolean_vector (0 to 1);
    variable b1, b2             : BOOLEAN;
  begin
    wait until start_boolvtest;
    bv1 := (true, false, false, true);
    bv2 := (true, false, true, false);
    bv3 := not bv1;
    bv4 := (false, true, true, false);
    assert (bv3 = bv4) report "NOT Boolean_Vector" severity error;
    bv3 := bv1 and bv2;
    bv4 := (true, false, false, false);
    assert (bv3 = bv4) report "AND Boolean_Vector" severity error;
    bv3 := bv1 nand bv2;
    bv4 := (false, true, true, true);
    assert (bv3 = bv4) report "NAND Boolean_Vector" severity error;
    bv3 := bv1 or bv2;
    bv4 := (true, false, true, true);
    assert (bv3 = bv4) report "OR Boolean_Vector" severity error;
    bv3 := bv1 nor bv2;
    bv4 := not (true, false, true, true);
    assert (bv3 = bv4) report "NOR Boolean_Vector" severity error;
    bv3 := bv1 xor bv2;
    bv4 := (false, false, true, true);
    assert (bv3 = bv4) report "XOR Boolean_Vector" severity error;
    bv3 := bv1 xnor bv2;
    bv4 := not (false, false, true, true);
    assert (bv3 = bv4) report "XNOR Boolean_Vector" severity error;
    -- vector and bit test
    -- and
    bv1 := (false, false, true, false);
    b1  := false;
    bv2 := bv1 and b1;
    bv3 := (others => false);
    assert (bv2 = bv3) report "bvector and bit error 1" severity error;
    bv1 := (false, false, true, false);
    b1  := true;
    bv2 := bv1 and b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bvector and bit error 2" severity error;
    bv1 := (true, false, false, true);
    b1  := false;
    bv2 := b1 and bv1;
    bv3 := (others => false);
    assert (bv2 = bv3) report "bit and bvector error 3" severity error;
    bv1 := (true, false, false, true);
    b1  := true;
    bv2 := b1 and bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit and bvector error 4" severity error;
    -- or
    bv1 := (false, true, true, false);
    b1  := false;
    bv2 := bv1 or b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bvector or bit error 1" severity error;
    bv1 := (false, true, true, false);
    b1  := true;
    bv2 := bv1 or b1;
    bv3 := (others => true);
    assert (bv2 = bv3) report "vector or bit error 2" severity error;
    bv1 := (false, false, true, true);
    b1  := false;
    bv2 := b1 or bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit or bvector error 3" severity error;
    bv1 := (false, false, true, true);
    b1  := true;
    bv2 := b1 or bv1;
    bv3 := (others => true);
    assert (bv2 = bv3) report "bit or bvector error 4" severity error;
    -- xor
    bv1 := (false, false, true, false);
    b1  := false;
    bv2 := bv1 xor b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bvector xor bit error 1" severity error;
    bv1 := (false, false, true, false);
    b1  := true;
    bv2 := bv1 xor b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bvector xor bit error 2" severity error;
    bv1 := (false, true, false, true);
    b1  := false;
    bv2 := b1 xor bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit xor bvector error 3" severity error;
    bv1 := (false, true, false, true);
    b1  := true;
    bv2 := b1 xor bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit xor bvector error 4" severity error;
    -- nand
    bv1 := (false, false, true, false);
    b1  := false;
    bv2 := bv1 nand b1;
    bv3 := (others => true);
    assert (bv2 = bv3) report "bvector nand bit error 1" severity error;
    bv1 := (false, false, true, false);
    b1  := true;
    bv2 := bv1 nand b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bvector nand bit error 2" severity error;
    bv1 := (false, false, true, false);
    b1  := false;
    bv2 := b1 nand bv1;
    bv3 := (others => true);
    assert (bv2 = bv3) report "bit nand bvector error 3" severity error;
    bv1 := (false, false, true, false);
    b1  := true;
    bv2 := b1 nand bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit nand bvector error 4" severity error;
    -- nor
    bv1 := (true, false, false, true);
    b1  := false;
    bv2 := bv1 nor b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bvector nor bit error 1" severity error;
    bv1 := (false, true, true, false);
    b1  := true;
    bv2 := bv1 nor b1;
    bv3 := (others => false);
    assert (bv2 = bv3) report "bvector nor bit error 2" severity error;
    bv1 := (false, true, false, true);
    b1  := false;
    bv2 := b1 nor bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit nor bvector error 3" severity error;
    bv1 := (true, true, true, true);
    b1  := true;
    bv2 := b1 nor bv1;
    bv3 := (others => false);
    assert (bv2 = bv3) report "bit nor bvector error 4" severity error;
    -- xnor
    bv1 := (false, false, true, false);
    b1  := false;
    bv2 := bv1 xnor b1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bvector xnor bit error 1" severity error;
    bv1 := (false, false, true, false);
    b1  := true;
    bv2 := bv1 xnor b1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bvector xnor bit error 2" severity error;
    bv1 := (false, false, true, false);
    b1  := false;
    bv2 := b1 xnor bv1;
    bv3 := not bv1;
    assert (bv2 = bv3) report "bit xnor bvector error 3" severity error;
    bv1 := (false, false, true, false);
    b1  := true;
    bv2 := b1 xnor bv1;
    bv3 := bv1;
    assert (bv2 = bv3) report "bit xnor bvector error 4" severity error;
    -- reduction operators test
    b1  := and (bv1);
    assert (b1 = false) report "and_reduce Boolean_vector test 1"
      severity error;
    bv1 := (true, true, true, true);
    b1  := and (bv1);
    assert (b1 = true) report "and_reduce Boolean_vector test 2"
      severity error;
    bv1 := (true, false, false, true);
    b1  := nand (bv1);
    assert (b1 = true) report "nand_reduce Boolean_vector test 1"
      severity error;
    bv1 := (true, true, true, true);
    b1  := nand (bv1);
    assert (b1 = false) report "nand_reduce Boolean_vector test 2"
      severity error;
    bv1 := (true, false, false, true);
    b1  := or (bv1);
    assert (b1 = true) report "or_reduce Boolean_vector test 1"
      severity error;
    bv1 := (false, false, false, false);
    b1  := or (bv1);
    assert (b1 = false) report "or_reduce Boolean_vector test 2"
      severity error;
    bv1 := (true, false, false, true);
    b1  := nor (bv1);
    assert (b1 = false) report "nor_reduce Boolean_vector test 1"
      severity error;
    bv1 := (false, false, false, false);
    b1  := nor (bv1);
    assert (b1 = true) report "nor_reduce Boolean_vector test 2"
      severity error;
    bv1 := (true, false, false, true);
    b1  := xor (bv1);
    assert (b1 = false) report "xor_reduce Boolean_vector test 1"
      severity error;
    bv1 := (false, true, false, false);
    b1  := xor (bv1);
    assert (b1 = true) report "xor_reduce Boolean_vector test 2"
      severity error;
    bv1 := (true, false, false, true);
    b1  := xnor (bv1);
    assert (b1 = true) report "xnor_reduce Boolean_vector test 1"
      severity error;
    bv1 := (false, true, false, false);
    b1  := xnor (bv1);
    assert (b1 = false) report "xnor_reduce Boolean_vector test 2"
      severity error;

    -- How about some implicit ones
    bv1 := (false, false, true, true);
    bv2 := (true, true, false, false);
    b1  := bv1 < bv2;
    assert (b1 = true) report "< boolean_vector compare" severity error;
    bv1 := (false, true, false, false);
    bv2 := bv1 sll 1;
    bv3 := (true, false, false, false);
    assert (bv2 = bv3) report "SLL boolean_vector test" severity error;
    assert (quiet) report "BOOLEAN_VECTOR test complete"
      severity note;
    boolvtest_done <= true;
  end process boolvtest;

  -- purpose: test the ?= operators
  questionequ : process is

    variable b1, b2, b3    : BIT;
    variable t1, t2, t3    : BOOLEAN;
    variable bv1, bv2, bv3 : BIT_VECTOR (3 downto 0);
  begin
    wait until start_qestionequ;
    -- bit ?= bit
    b1 := '1';
    b2 := '1';
    b3 := "?=" (b1, b2);
    assert b3 = '1'
      report BIT'image(b1) & " ?= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    b1 := '0';
    b2 := '1';
    b3 := "?=" (b1, b2);
    assert b3 = '0'
      report BIT'image(b1) & " ?= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    b1 := '1';
    b2 := '0';
    b3 := "?=" (b1, b2);
    assert b3 = '0'
      report BIT'image(b1) & " ?= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    b1 := '0';
    b2 := '0';
    b3 := "?=" (b1, b2);
    assert b3 = '1'
      report BIT'image(b1) & " ?= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    -- bit ?/= bit
    b1 := '1';
    b2 := '1';
    b3 := "?/=" (b1, b2);
    assert b3 = '0'
      report BIT'image(b1) & " ?/= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    b1 := '0';
    b2 := '1';
    b3 := "?/=" (b1, b2);
    assert b3 = '1'
      report BIT'image(b1) & " ?/= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    b1 := '1';
    b2 := '0';
    b3 := "?/=" (b1, b2);
    assert b3 = '1'
      report BIT'image(b1) & " ?/= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    b1 := '0';
    b2 := '0';
    b3 := "?/=" (b1, b2);
    assert b3 = '0'
      report BIT'image(b1) & " ?/= " & BIT'image(b2) & " returned " & BIT'image(b3)
      severity error;
    -- boolean ?= boolean
--    t1 := true;
--    t2 := true;
--    t3 := "?=" (t1, t2);
--    assert t3
--      report BOOLEAN'image(t1) & " ?= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    t1 := false;
--    t2 := false;
--    t3 := "?=" (t1, t2);
--    assert t3
--      report BOOLEAN'image(t1) & " ?= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    t1 := false;
--    t2 := true;
--    t3 := "?=" (t1, t2);
--    assert not t3
--      report BOOLEAN'image(t1) & " ?= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    t1 := true;
--    t2 := false;
--    t3 := "?=" (t1, t2);
--    assert not t3
--      report BOOLEAN'image(t1) & " ?= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    -- boolean ?/= boolean
--    t1 := true;
--    t2 := true;
--    t3 := "?/=" (t1, t2);
--    assert not t3
--      report BOOLEAN'image(t1) & " ?/= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    t1 := false;
--    t2 := false;
--    t3 := "?/=" (t1, t2);
--    assert not t3
--      report BOOLEAN'image(t1) & " ?/= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    t1 := false;
--    t2 := true;
--    t3 := "?/=" (t1, t2);
--    assert t3
--      report BOOLEAN'image(t1) & " ?/= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
--    t1 := true;
--    t2 := false;
--    t3 := "?/=" (t1, t2);
--    assert t3
--      report BOOLEAN'image(t1) & " ?/= " & BOOLEAN'image (t2) & " returned " & BOOLEAN'image(t3)
--      severity error;
    -- bit_vector ?= bit_vector
    bv1 := "0010";
    bv2 := "0010";
    b3  := "?=" (bv1, bv2);
    assert b3 = '1'
      report to_string(bv1) & " ?= " & to_string(bv2) & " returned " & BIT'image(b3)
      severity error;
    b3 := "?/=" (bv1, bv2);
    assert b3 = '0'
      report to_string(bv1) & " ?/= " & to_string(bv2) & " returned " & BIT'image(b3)
      severity error;
--    b3 := "?<" (bv1, bv2);
--    assert b3 = '0'
--      report to_string(bv1) & " ?< " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?<=" (bv1, bv2);
--    assert b3 = '1'
--      report to_string(bv1) & " ?<= " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?>" (bv1, bv2);
--    assert b3 = '0'
--      report to_string(bv1) & " ?> " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?>=" (bv1, bv2);
--    assert b3 = '1'
--      report to_string(bv1) & " ?>= " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
    bv1 := "0001";
    bv2 := "0010";
    b3  := "?=" (bv1, bv2);
    assert b3 = '0'
      report to_string(bv1) & " ?= " & to_string(bv2) & " returned " & BIT'image(b3)
      severity error;
    b3 := "?/=" (bv1, bv2);
    assert b3 = '1'
      report to_string(bv1) & " ?/= " & to_string(bv2) & " returned " & BIT'image(b3)
      severity error;
--    b3 := "?<" (bv1, bv2);
--    assert b3 = '1'
--      report to_string(bv1) & " ?< " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?<=" (bv1, bv2);
--    assert b3 = '1'
--      report to_string(bv1) & " ?<= " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?>" (bv1, bv2);
--    assert b3 = '0'
--      report to_string(bv1) & " ?> " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?>=" (bv1, bv2);
--    assert b3 = '0'
--      report to_string(bv1) & " ?>= " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
    bv2 := "0001";
    bv1 := "0010";
    b3  := "?=" (bv1, bv2);
    assert b3 = '0'
      report to_string(bv1) & " ?= " & to_string(bv2) & " returned " & BIT'image(b3)
      severity error;
    b3 := "?/=" (bv1, bv2);
    assert b3 = '1'
      report to_string(bv1) & " ?/= " & to_string(bv2) & " returned " & BIT'image(b3)
      severity error;
--    b3 := "?<" (bv1, bv2);
--    assert b3 = '0'
--      report to_string(bv1) & " ?< " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?<=" (bv1, bv2);
--    assert b3 = '0'
--      report to_string(bv1) & " ?<= " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?>" (bv1, bv2);
--    assert b3 = '1'
--      report to_string(bv1) & " ?> " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
--    b3 := "?>=" (bv1, bv2);
--    assert b3 = '1'
--      report to_string(bv1) & " ?>= " & to_string(bv2) & " returned " & BIT'image(b3)
--      severity error;
    assert (quiet) report "?= test complete"
      severity note;
    questionequ_done <= true;
  end process questionequ;
end architecture testbench;
