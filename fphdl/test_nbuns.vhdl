-----------------------------------------------------------------------------
-- Title      : Test routines for the new functions in numeric_bit_unsigned
--              for vhdl-200x-ft
-- check of basic translation functions
-- check of boolean overloads (bit_vector now treated as a number) 
-- check of all math functions
-- check of all numeric_std shift functions
-- Last Modified: $Date: 2007-09-12 08:57:33-04 $
-- RCS ID: $Id: test_nbuns.vhdl,v 1.2 2007-09-12 08:57:33-04 l435385 Exp $
--
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org)
-----------------------------------------------------------------------------

entity test_nbuns is
  generic (
    quiet : BOOLEAN := false);          -- run quietly

end entity test_nbuns;

use std.textio.all;
library IEEE;
use ieee.numeric_bit_unsigned.all;

architecture testbench of test_nbuns is

  -- purpose: reports an error
  procedure report_error (
    constant errmes : in STRING;         -- error message
    actual          : in BIT_VECTOR;     -- data from algorithm
    expected        : in BIT_VECTOR) is  -- reference data
  begin  -- procedure report_error
    assert (actual = expected)
      report "TEST_NBUNS: " & errmes & LF
      & "Actual   " & to_string (actual) & " \= " & LF
      & "Expected " & to_string (expected)
      severity error;
  end procedure report_error;
  signal start_comptest, comptest_done   : BOOLEAN := false;
  signal start_transtest, transtest_done : BOOLEAN := false;
  signal start_mathtest, mathtest_done   : BOOLEAN := false;
  signal start_misctest, misctest_done   : BOOLEAN := false;
  signal start_matchtest, matchtest_done : BOOLEAN := false;
--  signal start_readwritetest, readwritetest_done : boolean := false;
begin  -- architecture testbench

  -- purpose: Main test process
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  tester : process is

  begin  -- process tester

    start_comptest  <= true;
    wait until comptest_done;
    start_transtest <= true;
    wait until transtest_done;
    start_mathtest  <= true;
    wait until mathtest_done;
    start_misctest  <= true;
    wait until misctest_done;
    start_matchtest <= true;
    wait until matchtest_done;
--    start_readwritetest <= true;
--    wait until readwritetest_done;
    report "Numeric_Bit_Unsigned Testing complete" severity note;
    wait;

  end process tester;

  -- purpose: translation test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  transtest : process is
    variable nslv                            : BIT_VECTOR (1 downto 2);  -- null array
    variable check7, check7t                 : BIT_VECTOR (6 downto 0);
    variable check6, check6t                 : BIT_VECTOR (5 downto 0);
    variable check5, check5t                 : BIT_VECTOR (4 downto 0);
    variable check7uf1, check7uf2, check7uf3 : BIT_VECTOR (6 downto 0);
    variable s, s1                           : BIT;      -- single bits
    variable checkint, checkintt             : INTEGER;  -- integer
  begin  -- process transtest
    wait until start_transtest;
    check7   := "0000001";              -- 1
    check6   := resize (check7, check6'length);
    check6t  := "000001";
    report_error ("Resize test", check6, check6t);
    check6   := "000010";               -- 2
    check7   := resize (check6, check7'length);
    check7t  := "0000010";
    report_error ("Resize larger test", check7, check7t);
    nslv     := resize (check7, 0);     -- line will error out if wrong
    check6   := resize (nslv, 6);
    check6t  := (others => '0');
    report_error ("resize null array", check6, check6t);
    check7   := "0000001";              -- 1
    check6   := resize (check7, check6);
    check6t  := "000001";
    report_error ("Resize size_res test", check6, check6t);
    check6   := "000010";               -- 2
    check7   := resize (check6, check7);
    check7t  := "0000010";
    report_error ("Resize size_res larger test", check7, check7t);
    nslv     := resize (check7, nslv);  -- line will error out if wrong
    check6   := resize (nslv, check6);
    check6t  := (others => '0');
    report_error ("resize size_res null array", check6, check6t);
    -- to_integer
    check7   := "0000011";              -- 3
    checkint := to_integer (check7);
    assert (checkint = 3) report "to_integer test error "
      & INTEGER'image(checkint) & " /= " & to_string (check7) severity error;
    check5   := "11111";
    checkint := to_integer (check5);
    assert (checkint = 31) report "to_integer test error "
      & INTEGER'image(checkint) & " /= " & to_string (check5) severity error;
    if (not quiet) then
      report "Expect a null string error here" severity note;
      checkint := to_integer (nslv);
      assert (checkint = 0) report "to_integer null string test returned "
        & INTEGER'image(checkint) severity error;
    end if;
    checkint := 0;
    check7   := To_BitVector(checkint, check7'length);
    check7t  := (others => '0');
    report_error ("To_BitVector test", check7, check7t);
    checkint := 5;
    check5   := To_BitVector(checkint, check5'length);
    check5t  := "00101";                -- 5
    report_error ("To_BitVector test", check5, check5t);
    check5   := to_bv (5, check5'length);                -- check alias
    report_error ("to_bv test", check5, check5t);
    check5   := to_bit_vector (5, check5'length);        -- check alias
    report_error ("to_bit_vector test", check5, check5t);
    checkint := 0;
    check7   := To_BitVector(checkint, check7);
    check7t  := (others => '0');
    report_error ("To_BitVector size_res test", check7, check7t);
    checkint := 5;
    check5   := To_BitVector(checkint, check5);
    check5t  := "00101";                -- 5
    report_error ("To_BitVector size_res test", check5, check5t);
    check5   := to_bv (5, check5);      -- check alias
    report_error ("to_bv size_res test", check5, check5t);
    check5   := to_bit_vector (5, check5);               -- check alias
    report_error ("to_bit_vector size_res test", check5, check5t);
    -- It should be noted that the behavior of the min and
    -- max routine will be different depending on the "numeric_bit_unsigned"
    -- package, which replaced the compare (<) operator.
    -- You will find the opposite logic in "test_standard_addtions.vhd".
    check5   := "00110";
    check6   := "000111";
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
    -- test new "add_carry" procedures
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

    check7uf1      := "0110100";        -- 6.5
    check7uf2      := check7uf1 ror 1;
    check7uf3      := "0011010";        -- 3.25
    report_error ("ror test", check7uf2, check7uf3);
    check7uf2      := check7uf1 ror -1;
    check7uf3      := "1101000";        -- 13
    report_error ("ror test -1", check7uf2, check7uf3);
    check7uf2      := check7uf1 ror 55;
    check7uf3      := "1101000";
    report_error ("ror test 55", check7uf2, check7uf3);
    check7uf2      := check7uf1 ror -55;
    check7uf3      := "0011010";
    report_error ("ror test -55", check7uf2, check7uf3);
    check7uf1      := "0110100";        -- 6.5
    check7uf2      := check7uf1 rol -1;
    check7uf3      := "0011010";        -- 3.25
    report_error ("rol test", check7uf2, check7uf3);
    check7uf2      := check7uf1 rol 1;
    check7uf3      := "1101000";        -- 13
    report_error ("rol test -1", check7uf2, check7uf3);
    check7uf2      := check7uf1 rol -53;
    check7uf3      := "0100011";
    report_error ("rol test 53", check7uf2, check7uf3);
    check7uf2      := check7uf1 rol 53;
    check7uf3      := "1000110";
    report_error ("rol test -53", check7uf2, check7uf3);
    check7uf1      := "0110100";        -- 6.5
    check7uf2      := check7uf1 sra 1;
    check7uf3      := "0011010";        -- 3.25
    report_error ("SRa test", check7uf2, check7uf3);
    check7uf2      := check7uf1 sra -1;
    check7uf3      := "1101000";        -- 13
    report_error ("SRa test -1", check7uf2, check7uf3);
    check7uf2      := check7uf1 sra 55;
    check7uf3      := "0000000";
    report_error ("SRa test 55", check7uf2, check7uf3);
    check7uf2      := check7uf1 sra -55;
    check7uf3      := "0000000";
    report_error ("SRa test -55", check7uf2, check7uf3);
    check7uf1      := "0110100";        -- 6.5
    check7uf2      := check7uf1 sla -1;
    check7uf3      := "0011010";        -- 3.25
    report_error ("SLa test", check7uf2, check7uf3);
    check7uf2      := check7uf1 sla 1;
    check7uf3      := "1101000";        -- 13
    report_error ("SLa test -1", check7uf2, check7uf3);
    check7uf2      := check7uf1 sla -55;
    check7uf3      := "0000000";
    report_error ("SLa test 55", check7uf2, check7uf3);
    check7uf2      := check7uf1 sla 55;
    check7uf3      := "0000000";
    report_error ("SLa test -55", check7uf2, check7uf3);
    check7uf1      := "1110100";        -- 14.5
    check7uf2      := check7uf1 sra 1;
    check7uf3      := "0111010";        -- 16.25
    report_error ("SRa test carry", check7uf2, check7uf3);
    check7uf1      := "1110100";        -- 14.5
    check7uf2      := check7uf1 sra -1;
    check7uf3      := "1101000";        -- 13
    report_error ("SRa test -carry", check7uf2, check7uf3);
    check7uf1      := "0110101";        -- 6.625
    check7uf2      := check7uf1 sra 1;
    check7uf3      := "0011010";
    report_error ("SRa test carry-", check7uf2, check7uf3);
    check7uf1      := "0110101";        -- 6.625
    check7uf2      := check7uf1 sra -1;
    check7uf3      := "1101010";
    report_error ("SRa test -carry-", check7uf2, check7uf3);
    check7uf1      := "1110100";        -- 14.5
    check7uf2      := check7uf1 sla -1;
    check7uf3      := "0111010";
    report_error ("Sla test -carry", check7uf2, check7uf3);
    check7uf1      := "1110100";        -- 14.5
    check7uf2      := check7uf1 sla 1;
    check7uf3      := "1101000";        -- 13
    report_error ("Sla test carry", check7uf2, check7uf3);
    check7uf1      := "0110101";        -- 6.625
    check7uf2      := check7uf1 sla -1;
    check7uf3      := "0011010";
    report_error ("Sla test -carry-", check7uf2, check7uf3);
    check7uf1      := "0110101";        -- 6.625
    check7uf2      := check7uf1 sla 1;
    check7uf3      := "1101010";
    report_error ("Sla test carry-", check7uf2, check7uf3);
    assert (quiet) report "Translation test done" severity note;
    transtest_done <= true;
    wait;
  end process transtest;

  -- purpose: Test routines for the numeric_bit_unsigned package
  test_proc : process is
    variable nslv       : BIT_VECTOR (1 downto 2);  -- null array
    variable w, x, y, z : BIT_VECTOR (5 downto 0);  -- slvs
    variable testbool   : BOOLEAN;                  -- boolean test
    variable testint    : INTEGER;                  -- integer to test with
  begin  -- process test_proc
    wait until start_comptest;
    x        := "000001";                           -- 1
    y        := "000010";                           -- 2
    testbool := (x = y);                            -- false
    assert (not testbool) report "x = y"
      & " " & to_string (x)
      & " = " & to_string (y)
      severity error;
    testbool := (x = x);                            -- true
    assert testbool report "x = x"
      & " " & to_string (x)
      & " /= " & to_string (x)
      severity error;
    testbool := (x = 1);                            -- true
    assert testbool report "x = 1"
      & " " & to_string (x)
      & " /= 1"
      severity error;
    testbool := (1 = x);                            -- true
    assert testbool report "1 = x"
      & " 1"
      & " /= " & to_string (x)
      severity error;
    testbool := (y = 1);                            -- false
    assert (not testbool) report "y = 1"
      & " " & to_string (y)
      & " /= 1"
      severity error;
    testbool := (1 = y);                            -- false
    assert (not testbool) report "1 = y"
      & " 1"
      & " /= " & to_string (y)
      severity error;
--    testbool := (-1 = y);        -- Should create a range compile error
    

    x        := "000001";               -- 1
    y        := "000010";               -- 2
    testbool := (x /= y);               -- true
    assert testbool report "x /= y"
      & " " & to_string (x)
      & " = " & to_string (y)
      severity error;
    testbool := (x /= x);               -- false
    assert (not testbool) report "x /= x"
      & " " & to_string (x)
      & " /= " & to_string (x)
      severity error;
    testbool := (x /= 1);               -- false
    assert (not testbool) report "x /= 1"
      & " " & to_string (x)
      & " /= 1"
      severity error;
    testbool := (1 /= x);               -- false
    assert (not testbool) report "1 /= x"
      & " 1"
      & " /= " & to_string (x)
      severity error;
    testbool := (y /= 1);               -- true
    assert testbool report "y /= 1"
      & " " & to_string (y)
      & " /= 1"
      severity error;
    testbool := (1 /= y);               -- true
    assert testbool report "1 /= y"
      & " 1"
      & " /= " & to_string (y)
      severity error;
    
    x        := "000001";               -- 1
    y        := "000010";               -- 2
    testbool := (x < y);                -- true
    assert testbool report "x < y"
      & " " & to_string (x)
      & " = " & to_string (y)
      severity error;
    testbool := (y < x);                -- false
    assert (not testbool) report "y < x"
      & " " & to_string (y)
      & " = " & to_string (x)
      severity error;
    testbool := (x < x);                -- false
    assert (not testbool) report "x < x"
      & " " & to_string (x)
      & " /= " & to_string (x)
      severity error;

    testbool := (x < 1);                -- false
    assert (not testbool) report "x < 1"
      & " " & to_string (x)
      & " /= 1"
      severity error;
    testbool := (1 < x);                -- false
    assert (not testbool) report "1 < x"
      & " 1"
      & " /= " & to_string (x)
      severity error;
    testbool := (y < 1);                -- false
    assert (not testbool) report "y < 1"
      & " " & to_string (y)
      & " /= 1"
      severity error;
    testbool := (1 < y);                -- true
    assert testbool report "1 < y"
      & " 1"
      & " /= " & to_string (y)
      severity error;
    
    x        := "000001";               -- 1
    y        := "000010";               -- 2
    testbool := (x <= y);               -- true
    assert testbool report "x <= y"
      & " " & to_string (x)
      & " = " & to_string (y)
      severity error;
    testbool := (y <= x);               -- false
    assert (not testbool) report "y <= x"
      & " " & to_string (y)
      & " = " & to_string (x)
      severity error;
    testbool := (x <= x);               -- true
    assert testbool report "x <= x"
      & " " & to_string (x)
      & " /= " & to_string (x)
      severity error;

    testbool := (x <= 1);               -- true
    assert testbool report "x <= 1"
      & " " & to_string (x)
      & " /= 1"
      severity error;
    testbool := (1 <= x);               -- true
    assert testbool report "1 <= x"
      & " 1"
      & " /= " & to_string (x)
      severity error;
    testbool := (y <= 1);               -- false
    assert (not testbool) report "y <= 1"
      & " " & to_string (y)
      & " /= 1"
      severity error;
    testbool := (1 <= y);               -- true
    assert testbool report "1 <= y"
      & " 1"
      & " /= " & to_string (y)
      severity error;
    
    x        := "000001";               -- 1
    y        := "000010";               -- 2
    testbool := (x > y);                -- false
    assert (not testbool) report "x > y"
      & " " & to_string (x)
      & " = " & to_string (y)
      severity error;
    testbool := (y > x);                -- true
    assert testbool report "y > x"
      & " " & to_string (y)
      & " = " & to_string (x)
      severity error;
    testbool := (x > x);                -- false
    assert (not testbool) report "x > x"
      & " " & to_string (x)
      & " /= " & to_string (x)
      severity error;
    testbool := (x > 1);                -- false
    assert (not testbool) report "x > 1"
      & " " & to_string (x)
      & " /= 1"
      severity error;
    testbool := (1 > x);                -- false
    assert (not testbool) report "1 > x"
      & " 1"
      & " /= " & to_string (x)
      severity error;
    testbool := (y > 1);                -- true
    assert testbool report "y > 1"
      & " " & to_string (y)
      & " /= 1"
      severity error;
    testbool := (1 > y);                -- false
    assert (not testbool) report "1 > y"
      & " 1"
      & " /= " & to_string (y)
      severity error;

    x        := "000001";               -- 1
    y        := "000010";               -- 2
    testbool := (x >= y);               -- false
    assert (not testbool) report "x >= y"
      & " " & to_string (x)
      & " = " & to_string (y)
      severity error;
    testbool := (y >= x);               -- true
    assert testbool report "y >= x"
      & " " & to_string (y)
      & " = " & to_string (x)
      severity error;
    testbool := (x >= x);               -- true
    assert testbool report "x >= x"
      & " " & to_string (x)
      & " /= " & to_string (x)
      severity error;
    testbool := (x >= 1);               -- true
    assert testbool report "x >= 1"
      & " " & to_string (x)
      & " /= 1"
      severity error;
    testbool := (1 >= x);               -- true
    assert testbool report "1 >= x"
      & " 1"
      & " /= " & to_string (x)
      severity error;
    testbool := (y >= 1);               -- true
    assert testbool report "y >= 1"
      & " " & to_string (y)
      & " /= 1"
      severity error;
    testbool := (1 >= y);               -- false
    assert (not testbool) report "1 >= y"
      & " 1"
      & " /= " & to_string (y)
      severity error;                   -- STD_C.13 tests:
    assert BIT_VECTOR'("0001") <= BIT_VECTOR'("0010")
                                  report "Test STD_C.13.1 failing."
                                  severity failure;
    assert BIT_VECTOR'("01") <= BIT_VECTOR'("1010")
                                report "Test STD_C.13.2 failing."
                                severity failure;
    assert BIT_VECTOR'("000001") <= BIT_VECTOR'("111")
                                    report "Test STD_C.13.3 failing."
                                    severity failure;

    assert BIT_VECTOR'("010") <= BIT_VECTOR'("010")
                                 report "Test STD_C.13.5 failing."
                                 severity failure;
    assert BIT_VECTOR'("00010010") <= BIT_VECTOR'("10010")
                                      report "Test STD_C.13.8 failing."
                                      severity failure;
    assert BIT_VECTOR'("10") <= BIT_VECTOR'("0010")
                                report "Test STD_C.13.9 failing."
                                severity failure;

    assert not (BIT_VECTOR'("110001") <= BIT_VECTOR'("100010"))
      report "Test STD_C.13.4 failing."
      severity failure;
    assert not(BIT_VECTOR'("1111") <= BIT_VECTOR'("0001010"))
      report "Test STD_C.13.6 test failing."
      severity failure;
    assert not(BIT_VECTOR'("10001000") <= BIT_VECTOR'("11"))
      report "Test STD_C.13.7 test failing."
      severity failure;

    assert not(BIT_VECTOR'("110") <= BIT_VECTOR'("011"))
      report "Test STD_C.13.10 failing."
      severity failure;
    assert not(BIT_VECTOR'("10010010") <= BIT_VECTOR'("10010"))
      report "Test STD_C.13.11 failing."
      severity failure;

    if (not quiet) then
      report "Expect two null bit_vector errors here" severity note;
      assert not (BIT_VECTOR'("110") <= nslv)
        report "Test STD_C.13.13 failing."
        severity failure;
      assert not (nslv <= nslv)
        report "Test STD_C.13.14 failing."
        severity failure;
    end if;

-- STD_C.17 tests

    assert BIT_VECTOR'("0001") <= 2
                                  report "Test STD_C.17.1 failing."
                                  severity failure;
    assert BIT_VECTOR'("01") <= 10
                                report "Test STD_C.17.2 failing."
                                severity failure;
    assert BIT_VECTOR'("000001") <= 7
                                    report "Test STD_C.17.3 failing."
                                    severity failure;

    assert BIT_VECTOR'("010") <= 2
                                 report "Test STD_C.17.5 failing."
                                 severity failure;
    assert BIT_VECTOR'("00010010") <= 18
                                      report "Test STD_C.17.8 failing."
                                      severity failure;
    assert BIT_VECTOR'("10") <= 2
                                report "Test STD_C.17.9 failing."
                                severity failure;

    assert not (BIT_VECTOR'("110001") <= 34)
      report "Test STD_C.17.4 failing."
      severity failure;
    assert not(BIT_VECTOR'("1111") <= 10)
      report "Test STD_C.17.6 test failing."
      severity failure;
    assert not(BIT_VECTOR'("10001000") <= 3)
      report "Test STD_C.17.7 test failing."
      severity failure;

    assert not(BIT_VECTOR'("110") <= 3)
      report "Test STD_C.17.10 failing."
      severity failure;
    assert not(BIT_VECTOR'("10010010") <= 18)
      report "Test STD_C.17.11 failing."
      severity failure;
    assert not(BIT_VECTOR'("110") <= 2)
      report "Test STD_C.17.12 failing."
      severity failure;
    if (not quiet) then
      report "Expect a null bit_vector error here" severity note;
      assert not (nslv <= 0)
        report "Test STD_C.17.14 failing."
        severity failure;
    end if;
    comptest_done <= true;
    wait;
  end process test_proc;

  -- purpose: math test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  mathtest : process is
    procedure A_3 (left, right, RESULT : in BIT_VECTOR) is
  begin
    assert (left+right) = (RESULT)
      severity failure;
  end A_3;

  procedure A_3 (left, right : in BIT_VECTOR) is
  begin
    assert "+"(left, right)'length = 0 severity failure;
  end A_3;
  procedure A_5 (left : in BIT_VECTOR; right : in NATURAL; RESULT : in BIT_VECTOR) is
  begin
    assert (left+right) = (RESULT)
      severity failure;
  end A_5;

  procedure A_5 (left : in BIT_VECTOR; right : in NATURAL) is
  begin
    assert "+"(left, right)'length = 0 severity failure;
  end A_5;

  procedure A_6 (left : in NATURAL; right : in BIT_VECTOR; RESULT : in BIT_VECTOR) is
  begin
    assert (left+right) = (RESULT)
      severity failure;
  end A_6;

  procedure A_6 (left : in NATURAL; right : in BIT_VECTOR) is
  begin
    assert "+"(left, right)'length = 0 severity failure;
  end A_6;

  procedure A_9 (left, right, RESULT : in BIT_VECTOR) is
  begin
    assert (left-right) = (RESULT)
      severity failure;
  end A_9;

  procedure A_9 (left, right : in BIT_VECTOR) is
  begin
    assert "-"(left, right)'length = 0 severity failure;
  end A_9;
  procedure A_11 (left : in BIT_VECTOR; right : in NATURAL; RESULT : in BIT_VECTOR) is
  begin
    assert (left-right) = (RESULT)
      severity failure;
  end A_11;

  procedure A_11 (left : in BIT_VECTOR; right : in NATURAL) is
  begin
    assert "-"(left, right)'length = 0 severity failure;
  end A_11;

  procedure A_12 (left : in NATURAL; right, RESULT : in BIT_VECTOR) is
  begin
    assert (left-right) = (RESULT)
      severity failure;
  end A_12;

  procedure A_12 (left : in NATURAL; right : in BIT_VECTOR) is
  begin
    assert "-"(left, right)'length = 0 severity failure;
  end A_12;

  variable au, bu, cu    : BIT_VECTOR (7 downto 0);  -- unsigned
  variable w, x, y, z    : BIT_VECTOR (5 downto 0);  -- slvs
  variable xb            : BIT;
  variable yb            : BIT;
  variable testint       : INTEGER;                  -- integer to test with
  variable ures4, uns4   : BIT_VECTOR(1 to 4);
  variable uns6          : BIT_VECTOR(2 to 7);
  variable uns8          : BIT_VECTOR(0 to 7);
  variable uns10, ures10 : BIT_VECTOR(1 to 10);
  begin  -- process mathtest

    wait until start_mathtest;
    -- basic math test
    x := "000001";                      -- 1
    y := "000010";                      -- 2
    z := x + y;
    w := to_bv(3, z'length);
    report_error ("1+2", z, w);
    -- copied from numeric_std_tb4.vhd
    A_3("0", "0", "0");
    A_3("0", "1", "1");
    A_3("1", "0", "1");
    A_3("1", "1", "0");

    A_3("0000", "0000", "0000");
    A_3("0001", "0000", "0001");
    A_3("0000", "0001", "0001");
    A_3("0001", "0001", "0010");
    A_3("0010", "0010", "0100");
    A_3("0110", "1011", "0001");
    A_3("0110", "0110", "1100");
    A_3("1110", "1111", "1101");
    A_3("0010", "0101", "0111");
    A_3("0000", "1110", "1110");
    A_3("0010", "1111", "0001");
    A_3("0011", "0110", "1001");
    A_3("1101", "1101", "1010");
    A_3("1110", "0001", "1111");
    A_3("1101", "0110", "0011");
    A_3("0001", "1110", "1111");

    A_3("0101", "10", "0111");
    A_3("10", "0101", "0111");
    A_3("0101", "10", "0111");
    A_3("1111", "1111", "1110");
    A_3("11111111", "0", "11111111");
    A_3("0", "11111111", "11111111");
    A_3("1", "01010101", "01010110");
    A_3("01010101", "1", "01010110");
    A_3("1111000011110000", "0000000011111111", "1111000111101111");

    A_3("1", "");
    A_3("", "11111111");
    A_3("", "");
    A_5("0", 0, "0");
    A_5("0", 1, "1");
    A_5("1", 0, "1");
    A_5("1", 1, "0");

    A_5("0000", 0, "0000");
    A_5("0001", 0, "0001");
    A_5("0000", 1, "0001");
    A_5("0001", 1, "0010");
    A_5("0010", 2, "0100");
    A_5("0110", 11, "0001");
    A_5("0110", 6, "1100");
    A_5("1110", 15, "1101");
    A_5("0010", 5, "0111");
    A_5("0000", 14, "1110");
    A_5("0010", 15, "0001");
    A_5("0011", 6, "1001");
    A_5("1101", 13, "1010");
    A_5("1110", 1, "1111");
    A_5("1101", 6, "0011");
    A_5("0001", 14, "1111");

    A_5("0101", 2, "0111");
    if (not quiet) then
      report "Expect a vector truncated error here" severity note;
      A_5("10", 5, "11");
    end if;
    A_5("1111", 15, "1110");
    A_5("11111111", 0, "11111111");
    if (not quiet) then
      report "Expect two vector truncated errors here" severity note;
      A_5("1", 75, "0");
      A_5("0", 8, "0");
    end if;
    A_5("1111000011110000", 255, "1111000111101111");

    A_5("", 14);
    A_5("", 90210);
    A_6(0, "0", "0");
    A_6(0, "1", "1");
    A_6(1, "0", "1");
    A_6(1, "1", "0");

    A_6(0, "0000", "0000");
    A_6(0, "0001", "0001");
    A_6(1, "0000", "0001");
    A_6(1, "0001", "0010");
    A_6(2, "0010", "0100");
    A_6(11, "0110", "0001");
    A_6(6, "0110", "1100");
    A_6(15, "1110", "1101");
    A_6(5, "0010", "0111");
    A_6(14, "0000", "1110");
    A_6(15, "0010", "0001");
    A_6(6, "0011", "1001");
    A_6(13, "1101", "1010");
    A_6(1, "1110", "1111");
    A_6(6, "1101", "0011");
    A_6(14, "0001", "1111");

    A_6(2, "0101", "0111");
    A_6(15, "1111", "1110");
    if (not quiet) then
      report "Expect a vector truncated error here 3" severity note;
      A_6(5, "10", "11");
    end if;
    A_6(0, "11111111", "11111111");

    A_6(0, "1000", "1000");

    A_6(255, "1111000011110000", "1111000111101111");

    A_6(14, "");
    A_6(25678, "");
    A_9("0", "0", "0");
    A_9("0", "1", "1");
    A_9("1", "0", "1");
    A_9("1", "1", "0");

    A_9("0000", "0000", "0000");
    A_9("0001", "0000", "0001");
    A_9("0000", "0001", "1111");
    A_9("0001", "0001", "0000");
    A_9("0010", "0010", "0000");
    A_9("0110", "1011", "1011");
    A_9("0110", "0110", "0000");
    A_9("1110", "1111", "1111");
    A_9("0010", "0101", "1101");
    A_9("0000", "1110", "0010");
    A_9("0010", "1111", "0011");
    A_9("0011", "0110", "1101");
    A_9("1101", "1101", "0000");
    A_9("1110", "0001", "1101");
    A_9("1101", "0110", "0111");
    A_9("0001", "1110", "0011");

    A_9("0101", "10", "0011");
    A_9("10", "0101", "1101");
    A_9("0101", "10", "0011");
    A_9("1111", "1111", "0000");
    A_9("11111111", "0", "11111111");
    A_9("0", "11111111", "00000001");
    A_9("1", "01010101", "10101100");
    A_9("01010101", "1", "01010100");
    A_9("0", "1000", "1000");
    A_9("1111000011110000", "0000000011111111", "1110111111110001");

    A_9("1", "");
    A_9("", "11111111");
    A_9("", "");
    A_11("0", 0, "0");
    A_11("0", 1, "1");
    A_11("1", 0, "1");
    A_11("1", 1, "0");

    A_11("0000", 0, "0000");
    A_11("0001", 0, "0001");
    A_11("0000", 1, "1111");
    A_11("0001", 1, "0000");
    A_11("0010", 2, "0000");
    A_11("0110", 11, "1011");
    A_11("0110", 6, "0000");
    A_11("1110", 15, "1111");
    A_11("0010", 5, "1101");
    A_11("0000", 14, "0010");
    A_11("0010", 15, "0011");
    A_11("0011", 6, "1101");
    A_11("1101", 13, "0000");
    A_11("1110", 1, "1101");
    A_11("1101", 6, "0111");
    A_11("0001", 14, "0011");

    A_11("0101", 2, "0011");
    if (not quiet) then
      report "Expect a vector truncated error here" severity note;
      A_11("10", 5, "01");
    end if;
    A_11("1111", 15, "0000");
    A_11("11111111", 0, "11111111");
    if (not quiet) then
      report "Expect two vector truncated errors here" severity note;
      A_11("1", 85, "0");
      A_11("0", 8, "0");
    end if;
    A_11("1111000011110000", 255, "1110111111110001");

    A_11("", 10);
    A_11("", 90210);
    A_12(0, "0", "0");
    A_12(0, "1", "1");
    A_12(1, "0", "1");
    A_12(1, "1", "0");

    A_12(0, "0000", "0000");
    A_12(1, "0000", "0001");
    A_12(0, "0001", "1111");
    A_12(1, "0001", "0000");
    A_12(2, "0010", "0000");
    A_12(6, "1011", "1011");
    A_12(6, "0110", "0000");
    A_12(14, "1111", "1111");
    A_12(2, "0101", "1101");
    A_12(0, "1110", "0010");
    A_12(2, "1111", "0011");
    A_12(3, "0110", "1101");
    A_12(13, "1101", "0000");
    A_12(14, "0001", "1101");
    A_12(1, "1110", "0011");
    A_12(13, "0110", "0111");
    if (not quiet) then
      report "Expect a vector truncated error here" severity note;
      A_12(5, "10", "11");
    end if;
    A_12(2, "0101", "1101");
    A_12(15, "1111", "0000");
    if (not quiet) then
      report "Expect a vector truncated error here" severity note;
      A_12(255, "0000", "1111");
    end if;
    A_12(1, "01010101", "10101100");
    A_12(0, "1000", "1000");
    A_12(19, "0000000011111111", "1111111100010100");

    A_12(5, "1010", "1011");


    A_12(10, "");
    A_12(90210, "");

    -- copied from numeric_std_tb1.vhd
    -- A.15 tests
    for i in 0 to 63 loop
      uns6 := to_bit_vector(i, 6);
      for j in 0 to 15 loop
        uns4  := to_bit_vector(j, 4);
        uns10 := uns6*uns4;             -- A.15
        report_error ("6*4", uns10, to_bv(i*j, uns10'length));
        uns10 := uns4*uns6;
        report_error ("4*6", uns10, to_bv(i*j, uns10'length));
      end loop;
    end loop;

    -- A.17 and A.18 tests
    for i in 0 to 15 loop
      uns4 := to_bit_vector(i, 4);
      assert (i /= 8 or uns4 = "1000") and (i /= 9 or uns4 = "1001")
        and (i /= 15 or uns4 = "1111") and (i /= 0 or uns4 = "0000")
        and (i /= 3 or uns4 = "0011") and (i /= 7 or uns4 = "0111")
        and (to_integer(uns4) = i);
      for j in 0 to 15 loop
        -- exaustively test 4x4 case
        uns8 := j*uns4;                 -- A.18
        assert to_integer(uns8) = (i*j) report "A.18 fails"
          severity failure;
        uns8 := uns4*j;                 -- A.17
        assert to_integer(uns8) = (i*j) report "A.17 fails"
          severity failure;
      end loop;
      -- uns8:=19*uns4;         -- A.18; may note overflow of conversion
      -- assert to_integer(uns8)=(3*i)  report "A.18 fails" severity FAILURE;
      -- uns8:=uns4*21;         -- A.17; may note overflow of conversion
      -- assert to_integer(uns8)=(5*i)  report "A.17 fails" severity FAILURE;
    end loop;
    -- Id: A.21, A.23, and A.24
    for i in 0 to 1023 loop
      uns10 := to_bv(i, 10);
      for j in 1 to 15 loop
        uns4   := to_bv(j, 4);
        ures10 := uns10/uns4;
        assert to_integer(ures10) = i/j report "A.21 fails"
          severity failure;
        ures10 := uns10/j;
        assert to_integer(ures10) = i/j report "A.23 fails"
          severity failure;
        ures10 := i/("000000"&uns4);
        assert to_integer(ures10) = i/j report "A.24 fails"
          severity failure;
      end loop;
    end loop;
    -- These examples test interesting parts of other division algorithms.
    -- They are not particularly targeted to the division algorithm in the
    -- numeric packages.
    -- (These are two examples of the pentium's FDIV bug.)
    assert (to_bv(5505001, 23)&"0000000000000000")/to_bv(294911, 19)
      = "100101010101010101001"         -- =(5505001*65536/294911)
      report "A.21 fails ex.1"
      severity failure;
    assert (to_bv(4195835, 23)&"0000000000000000")/to_bv(3145727, 22)
      = "10101010101110101"             -- =(4195835*65536/3145727);
      report "A.21 fails ex.2"
      severity failure;
    -- These examples exercise interesting parts of Knuth's Algorithm D, in
    -- Seminumerical Algorithms, section 4.3.2, when B is 256.
    assert (to_bv(112893473, 28)/to_bv(19607, 16)) = to_bv(5757, 16)
      report "A.21 fails ex.3"
      severity failure;
    assert (to_bv(96419675, 28)/to_bv(34257, 16)) = to_bv(2814, 12)
      report "A.21 fails ex.4"
      severity failure;
    assert (to_bv(244699666, 28)/to_bv(59746, 16)) = to_bv(4095, 13)
      report "A.21 fails ex.5"
      severity failure;
    -- Id: A.27, A.29 and A.30
    for i in 0 to 1023 loop
      uns10 := to_bv(i, 10);
      for j in 1 to 15 loop
        uns4   := to_bv(j, 4);
        ures4  := uns10 rem uns4;
        assert to_integer(ures4) = i rem j report "A.27 fails" severity failure;
        ures10 := uns10 rem j;
        assert to_integer(ures10) = i rem j report "A.29 fails" severity failure;
        ures10 := i rem ("000000"&uns4);
        assert to_integer(ures10) = i rem j report "A.30 fails" severity failure;
      end loop;
    end loop;

    -- Id: A.33, A.35 and A.36
    for i in 0 to 1023 loop
      uns10 := to_bv(i, 10);
      for j in 1 to 15 loop
        uns4   := to_bv(j, 4);
        ures10 := resize((uns10 mod uns4), ures10'length);
        assert to_integer(ures10) = i mod j report "A.33 fails" severity failure;
        ures10 := uns10 mod j;
        assert to_integer(ures10) = i mod j report "A.35 fails" severity failure;
        ures10 := i mod ("000000"&uns4);
        assert to_integer(ures10) = i mod j report "A.36 fails" severity failure;
      end loop;
    end loop;

    -- bit test
    w  := "000000";
    xb := '1';
    w  := w + xb;
    x  := "000001";
    report_error ("slv + 1", w, x);
    w  := "000000";
    xb := '0';
    w  := w + xb;
    x  := "000000";
    report_error ("slv + 0", w, x);
    w  := "000000";
    xb := '1';
    w  := xb + w;
    x  := "000001";
    report_error ("1 + slv", w, x);
    w  := "000000";
    xb := '0';
    w  := xb + w;
    x  := "000000";
    report_error ("0 + slv", w, x);
    w  := "000000";
    yb := '1';
    w  := w + yb;
    x  := "000001";
    report_error ("slv + 1", w, x);
    w  := "000000";
    yb := '0';
    w  := w + yb;
    x  := "000000";
    report_error ("slv + 0", w, x);
    w  := "000000";
    yb := '1';
    w  := yb + w;
    x  := "000001";
    report_error ("1 + slv", w, x);
    w  := "000000";
    yb := '0';
    w  := yb + w;
    x  := "000000";
    report_error ("0 + slv", w, x);
    -- copied from test_minmax
    au := "10000010";
    bu := "00000100";
    cu := maximum (au, bu);
    assert (cu = "10000010") report "Max miscompare 82x" severity error;
    cu := maximum (bu, cu);
    assert (cu = "10000010") report "Max miscompare 82xr" severity error;
    cu := minimum (au, bu);
    assert (cu = "00000100") report "Min miscompare 04x" severity error;
    cu := minimum (bu, au);
    assert (cu = "00000100") report "Min miscompare 04xr" severity error;

    au            := "00100001";
    testint       := find_rightmost (au, '1');
    assert (testint = 0) report "find_rightmost error 0" severity error;
    testint       := find_rightmost (au, '0');
    assert (testint = 1) report "find_rightmost error 1" severity error;
    testint       := find_leftmost (au, '1');
    assert (testint = 5) report "find_leftmost error 1" severity error;
    testint       := find_leftmost (au, '0');
    assert (testint = 7) report "find_leftmost error 7" severity error;
    mathtest_done <= true;
    wait;
  end process mathtest;


  -- purpose: shift and anything else I can think of
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  misctest : process is
    variable s_unull : BIT_VECTOR (2 downto 3);  -- null array
  begin  -- process misctest
    wait until start_misctest;
    -- shift test, copied from numeric_std_tb2.vhd

    -- S.1 tests
    assert shift_left(s_unull, 0)'length = 0
      report "Test S.1.1 failing."
      severity failure;
    assert shift_left(s_unull, 1)'length = 0
      report "Test S.1.2 failing."
      severity failure;
    assert shift_left(s_unull, 100)'length = 0
      report "Test S.1.3 failing."
      severity failure;

    assert shift_left(BIT_VECTOR'("0"), 0) = BIT_VECTOR'("0")
      report "Test S.1.4 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("0"), 1) = BIT_VECTOR'("0")
      report "Test S.1.5 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("0"), 50) = BIT_VECTOR'("0")
      report "Test S.1.6 failing."
      severity failure;

    assert shift_left(BIT_VECTOR'("1"), 0) = BIT_VECTOR'("1")
      report "Test S.1.7 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("1"), 1) = BIT_VECTOR'("0")
      report "Test S.1.8 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("1"), 39) = BIT_VECTOR'("0")
      report "Test S.1.9 failing."
      severity failure;

    assert shift_left(BIT_VECTOR'("000"), 0) = BIT_VECTOR'("000")
      report "Test S.1.10 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("000"), 1) = BIT_VECTOR'("000")
      report "Test S.1.11 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("000"), 2) = BIT_VECTOR'("000")
      report "Test S.1.12 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("000"), 3) = BIT_VECTOR'("000")
      report "Test S.1.13 failing."
      severity failure;

    assert shift_left(BIT_VECTOR'("111"), 0) = BIT_VECTOR'("111")
      report "Test S.1.14 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("111"), 1) = BIT_VECTOR'("110")
      report "Test S.1.15 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("111"), 2) = BIT_VECTOR'("100")
      report "Test S.1.16 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("111"), 3) = BIT_VECTOR'("000")
      report "Test S.1.17 failing."
      severity failure;

    assert shift_left(BIT_VECTOR'("001"), 0) = BIT_VECTOR'("001")
      report "Test S.1.18 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("001"), 1) = BIT_VECTOR'("010")
      report "Test S.1.19 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("001"), 2) = BIT_VECTOR'("100")
      report "Test S.1.20 failing."
      severity failure;
    assert shift_left(BIT_VECTOR'("001"), 3) = BIT_VECTOR'("000")
      report "Test S.1.21 failing."
      severity failure;
    assert shift_right(s_unull, 0)'length = 0
      report "Test S.2.1 failing."
      severity failure;
    assert shift_right(s_unull, 1)'length = 0
      report "Test S.2.2 failing."
      severity failure;
    assert shift_right(s_unull, 100)'length = 0
      report "Test S.2.3 failing."
      severity failure;

    assert shift_right(BIT_VECTOR'("0"), 0) = BIT_VECTOR'("0")
      report "Test S.2.4 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("0"), 1) = BIT_VECTOR'("0")
      report "Test S.2.5 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("0"), 50) = BIT_VECTOR'("0")
      report "Test S.2.6 failing."
      severity failure;

    assert shift_right(BIT_VECTOR'("1"), 0) = BIT_VECTOR'("1")
      report "Test S.2.7 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("1"), 1) = BIT_VECTOR'("0")
      report "Test S.2.8 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("1"), 39) = BIT_VECTOR'("0")
      report "Test S.2.9 failing."
      severity failure;

    assert shift_right(BIT_VECTOR'("000"), 0) = BIT_VECTOR'("000")
      report "Test S.2.10 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("000"), 1) = BIT_VECTOR'("000")
      report "Test S.2.11 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("000"), 2) = BIT_VECTOR'("000")
      report "Test S.2.12 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("000"), 3) = BIT_VECTOR'("000")
      report "Test S.2.13 failing."
      severity failure;

    assert shift_right(BIT_VECTOR'("111"), 0) = BIT_VECTOR'("111")
      report "Test S.2.14 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("111"), 1) = BIT_VECTOR'("011")
      report "Test S.2.15 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("111"), 2) = BIT_VECTOR'("001")
      report "Test S.2.16 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("111"), 3) = BIT_VECTOR'("000")
      report "Test S.2.17 failing."
      severity failure;

    assert shift_right(BIT_VECTOR'("100"), 0) = BIT_VECTOR'("100")
      report "Test S.2.18 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("100"), 1) = BIT_VECTOR'("010")
      report "Test S.2.19 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("100"), 2) = BIT_VECTOR'("001")
      report "Test S.2.20 failing."
      severity failure;
    assert shift_right(BIT_VECTOR'("100"), 3) = BIT_VECTOR'("000")
      report "Test S.2.21 failing."
      severity failure;
    -- S.5 tests
    assert rotate_left(s_unull, 0)'length = 0
      report "Test S.5.1 failing."
      severity failure;
    assert rotate_left(s_unull, 1)'length = 0
      report "Test S.5.2 failing."
      severity failure;
    assert rotate_left(s_unull, 100)'length = 0
      report "Test S.5.3 failing."
      severity failure;

    assert rotate_left(BIT_VECTOR'("0"), 0) = BIT_VECTOR'("0")
      report "Test S.5.4 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("0"), 1) = BIT_VECTOR'("0")
      report "Test S.5.5 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("0"), 50) = BIT_VECTOR'("0")
      report "Test S.5.6 failing."
      severity failure;

    assert rotate_left(BIT_VECTOR'("1"), 0) = BIT_VECTOR'("1")
      report "Test S.5.7 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("1"), 1) = BIT_VECTOR'("1")
      report "Test S.5.8 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("1"), 39) = BIT_VECTOR'("1")
      report "Test S.5.9 failing."
      severity failure;

    assert rotate_left(BIT_VECTOR'("000"), 0) = BIT_VECTOR'("000")
      report "Test S.5.10 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("000"), 1) = BIT_VECTOR'("000")
      report "Test S.5.11 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("000"), 2) = BIT_VECTOR'("000")
      report "Test S.5.12 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("000"), 3) = BIT_VECTOR'("000")
      report "Test S.5.13 failing."
      severity failure;

    assert rotate_left(BIT_VECTOR'("111"), 0) = BIT_VECTOR'("111")
      report "Test S.5.14 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("111"), 1) = BIT_VECTOR'("111")
      report "Test S.5.15 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("111"), 2) = BIT_VECTOR'("111")
      report "Test S.5.16 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("111"), 3) = BIT_VECTOR'("111")
      report "Test S.5.17 failing."
      severity failure;

    assert rotate_left(BIT_VECTOR'("011"), 0) = BIT_VECTOR'("011")
      report "Test S.5.18 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("011"), 1) = BIT_VECTOR'("110")
      report "Test S.5.19 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("011"), 2) = BIT_VECTOR'("101")
      report "Test S.5.20 failing."
      severity failure;
    assert rotate_left(BIT_VECTOR'("011"), 3) = BIT_VECTOR'("011")
      report "Test S.5.21 failing."
      severity failure;
    assert rotate_right(s_unull, 0)'length = 0
      report "Test S.6.1 failing."
      severity failure;
    assert rotate_right(s_unull, 1)'length = 0
      report "Test S.6.2 failing."
      severity failure;
    assert rotate_right(s_unull, 100)'length = 0
      report "Test S.6.3 failing."
      severity failure;

    assert rotate_right(BIT_VECTOR'("0"), 0) = BIT_VECTOR'("0")
      report "Test S.6.4 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("0"), 1) = BIT_VECTOR'("0")
      report "Test S.6.5 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("0"), 50) = BIT_VECTOR'("0")
      report "Test S.6.6 failing."
      severity failure;

    assert rotate_right(BIT_VECTOR'("1"), 0) = BIT_VECTOR'("1")
      report "Test S.6.7 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("1"), 1) = BIT_VECTOR'("1")
      report "Test S.6.8 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("1"), 39) = BIT_VECTOR'("1")
      report "Test S.6.9 failing."
      severity failure;

    assert rotate_right(BIT_VECTOR'("000"), 0) = BIT_VECTOR'("000")
      report "Test S.6.10 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("000"), 1) = BIT_VECTOR'("000")
      report "Test S.6.11 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("000"), 2) = BIT_VECTOR'("000")
      report "Test S.6.12 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("000"), 3) = BIT_VECTOR'("000")
      report "Test S.6.13 failing."
      severity failure;

    assert rotate_right(BIT_VECTOR'("111"), 0) = BIT_VECTOR'("111")
      report "Test S.6.14 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("111"), 1) = BIT_VECTOR'("111")
      report "Test S.6.15 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("111"), 2) = BIT_VECTOR'("111")
      report "Test S.6.16 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("111"), 3) = BIT_VECTOR'("111")
      report "Test S.6.17 failing."
      severity failure;

    assert rotate_right(BIT_VECTOR'("110"), 0) = BIT_VECTOR'("110")
      report "Test S.6.18 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("110"), 1) = BIT_VECTOR'("011")
      report "Test S.6.19 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("110"), 2) = BIT_VECTOR'("101")
      report "Test S.6.20 failing."
      severity failure;
    assert rotate_right(BIT_VECTOR'("110"), 3) = BIT_VECTOR'("110")
      report "Test S.6.21 failing."
      severity failure;

    misctest_done <= true;
    wait;
  end process misctest;

  -- purpose: test the match function
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  matchtest : process is
    variable s, s1, s2       : BIT;
    variable auns, buns      : BIT_VECTOR (7 downto 0);
    variable check6, check6t : BIT_VECTOR (6 downto 0);
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
    check6 := "1000010";
    buns   := "11000010";
    s      := check6 ?/= buns;
    assert s = '1'
      report "s " & to_string(check6) & " ?/= " & to_string(buns)
      & " = " & to_string (s)
      severity error;
    check6 := "0000010";
    buns   := "00000010";
    s      := check6 ?/= buns;
    assert s = '0'
      report "s " & to_string(check6) & " ?/= " & to_string(buns)
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
    assert (quiet) report "match test completed" severity note;
    matchtest_done <= true;
    wait;
  end process matchtest;

--  -- purpose: read and write test
--  -- type   : combinational
--  -- inputs : 
--  -- outputs: 
--  readwritetest: process is
--    variable checkint, checkint2 : integer;
--    variable l : line;                  -- line variable
--    variable slv32, slv32t : bit_vector (31 downto 0);  -- 32 bit SLV
--    variable good : boolean;
--    variable st3 : string (1 to 3);
--  begin  -- process readwritetest

--    wait until start_readwritetest;
--    -- hread
--    L := new string'("000000AB");
--    hread (L, checkint, good);
--    checkint2 := to_integer ("10101011");
--    assert (good) report "hread AB good = false" severity error;
--    assert (checkint = checkint2) report "hread AB mismatch "
--      & boolean'image(good)
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    L := new string'("00000AB");        -- not 32 bits
--    hread (L, checkint, good);
--    checkint2 := 0;
--    assert (not good) report "hread short AB good = true" severity error;
--    assert (checkint = checkint2) report "hread short AB mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    L := new string'("000000AB");
--    hread (L, checkint);
--    checkint2 := to_integer ("10101011");
--    assert (checkint = checkint2) report "hread ng AB mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    if (not quiet) then
--      report "Expect an HREAD and TO_INTEGER error here" severity note;
--      L := new string'("00000AB");        -- not 32 bits
--      hread (L, checkint);
--      checkint2 := 0;
--      assert (checkint = checkint2) report "hread ng short AB mismatch "
--        & boolean'image(good)
--        & integer'image(checkint) & " /= " & integer'image(checkint2)
--        severity error;
--      deallocate (L);
--    end if;
--    -- hwrite
--    L := null;
--    checkint := 171;
--    hwrite (L, checkint);
--    assert (L.all = "AB") report "hwrite failed "
--      & integer'image(checkint) & " /= " & L.all severity error;
--    deallocate (L);
--    -- oread
--    L := new string'("00000000707");
--    oread (L, checkint, good);
--    assert (good) report "oread 707 good = false" severity error;
--    checkint2 := to_integer ("111000111");
--    assert (checkint = checkint2) report "oread 707 mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    L := new string'("0000000707");     -- short
--    oread (L, checkint, good);
--    assert (not good) report "oread ng 707 good = false" severity error;
--    checkint2 := 0;
--    assert (checkint = checkint2) report "oread short 707 mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    L := new string'("00000000707");
--    oread (L, checkint);
--    checkint2 := to_integer ("111000111");
--    assert (checkint = checkint2) report "oread ng 707 mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    if (not quiet) then
--      report "Expect an OREAD and TO_INTEGER error here" severity note;
--      L := new string'("0000000707");     -- short
--      oread (L, checkint);
--      checkint2 := 0;
--      assert (checkint = checkint2) report "oread ng short 707 mismatch "
--        & integer'image(checkint) & " /= " & integer'image(checkint2)
--        severity error;
--      deallocate (L);
--    end if;
--    -- owrite
--    L := null;
--    checkint := 171;
--    owrite (L, checkint);
--    assert (L.all = "253") report "owrite failed "
--      & integer'image(checkint) & " /= " & L.all severity error;
--    deallocate (L);

--    -- bread
--    L := new string'("00000000000000000000000000000101");
--    bread (L, checkint, good);
--    assert (good) report "bread 3 good = false" severity error;
--    checkint2 := 5;
--    assert (checkint = checkint2) report "bread 3 mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    L := new string'("0000000000000000000000000000111");     -- short
--    bread (L, checkint, good);
--    assert (not good) report "bread ng 7 good = false" severity error;
--    checkint2 := 0;
--    assert (checkint = checkint2) report "bread short 7 mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    L := new string'("00000000000000000000000000001001");
--    bread (L, checkint);
--    checkint2 := 9;
--    assert (checkint = checkint2) report "bread ng 9 mismatch "
--      & integer'image(checkint) & " /= " & integer'image(checkint2)
--      severity error;
--    deallocate (L);
--    if (not quiet) then
--      report "Expect an BREAD and TO_INTEGER error here" severity note;
--      L := new string'("0000000000000000000000000000110");     -- short
--      bread (L, checkint);
--      checkint2 := 0;
--      assert (checkint = checkint2) report "bread ng short 6 mismatch "
--        & integer'image(checkint) & " /= " & integer'image(checkint2)
--        severity error;
--      deallocate (L);
--    end if;
--    -- bwrite
--    L := null;
--    checkint := 4;
--    bwrite (L, checkint);
--    assert (L.all = "00000000000000000000000000000100") report "bwrite failed "
--      & integer'image(checkint) & " /= " & L.all severity error;
--    deallocate (L);
--    -- dread
--     L := new string'("4");
--    dread (L, slv32, good);
--    slv32t := "00000000000000000000000000000100";
--    assert (good) report "dread 4 good = false" severity error;
--    assert (slv32 = slv32t) report "dread 4 mismatch " & LF
--      & to_string (slv32) & " /= " & LF & to_string(slv32t)
--      severity error;
--    deallocate (L);
--    L := new string'("-8");
--    dread (L, slv32, good);
--    slv32t := (others => '0');
--    assert (not good) report "dread -8 good = true" severity error;
--    assert (std.standard."=" (slv32, slv32t))
--      report "dread -8 mismatch " & LF
--      & to_string (slv32) & " /= " & LF & to_string(slv32t)
--      severity error;
--    deallocate (L);
--    L := new string'("16");
--    dread (L, slv32);
--    slv32t := "00000000000000000000000000010000";
--    assert (slv32 = slv32t) report "dread 16 mismatch " & LF
--      & to_string (slv32) & " /= " & LF & to_string(slv32t)
--      severity error;
--    deallocate (L);
--    if (not quiet) then
--      report "Expect an DREAD and TO_INTEGER error here" severity note;
--      L := new string'("-45");
--      dread (L, slv32);
--    slv32t := (others => '0');
--   assert (std.standard."=" (slv32, slv32t))
--     report "dread -45 mismatch " & LF
--      & to_string (slv32) & " /= " & LF & to_string(slv32t)
--      severity error;
--      deallocate (L);
--    end if;   
--    -- dwrite
--    L := null;
--    dwrite (L, "1010");
--    assert (L.all = "10") report "dwrite failed 10 "
--      & " /= " & L.all severity error;
--    deallocate (L);
--    -- to_dstring
--    st3 := to_dstring ("111111111");
--    assert (st3 = "511") report "to_dstring failed 511 /= " & st3
--      severity error;
--    assert (quiet) report "Read/Write test complete" severity note;
--    readwritetest_done <= true;
--    wait;
--  end process readwritetest;

end architecture testbench;
