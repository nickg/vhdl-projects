-- --------------------------------------------------------------------
-- Title      : Test_logic
-- test vectors for the bit and bit_vector logical operators.
--
-- Last Modified: $Date: 2010/09/17 19:04:25 $
-- RCS ID: $Id: test_logical.vhdl,v 2.0 2010/09/17 19:04:25 l435385 Exp $
--
--  Modified for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------
entity test_logical is
  generic (
    quiet : BOOLEAN := false);          -- run quietly
end entity test_logical;

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_bit.all;

architecture testbench of test_logical is
  SIGNAL start_logicaltest, logicaltest_done : BOOLEAN := false;
  signal start_qequtest, qequtest_done : BOOLEAN := false;
begin

  -- purpose: master process
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  master: process is
  begin
    start_logicaltest <= true;
    wait until logicaltest_done;
    start_qequtest <= true;
    wait until qequtest_done;
    report "std_logic_1164 additions test completed" severity note;
    wait;
  end process master;

  -- purpose: test of std_logic_1164 ?=, ?/=, ?>, etc functions (implicit)
  qequ: process is
    variable aslv, bslv : std_logic_vector (7 downto 0);  -- slvs
    variable asulv, bsulv : std_ulogic_vector (7 downto 0);  -- sulvs
    variable s, s1, s2 : std_ulogic;
    variable check6, check6t : std_logic_vector (6 downto 0);
    variable checks6, checks6t : std_ulogic_vector (6 downto 0);
  begin
    wait until start_qequtest;
    -- Test of ?= operator for std_ulogic
    for s in STD_ULOGIC loop
      for s1 in STD_ULOGIC loop
        s2 := s ?= s1;
        if (s = '-' or s1 = '-') then
          assert (s2 = '1')
            report to_string(s) & " ""?="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        elsif ((s = 'U' or s1 = 'U')) then
          assert (s2 = 'U')
            report to_string(s) & " ""?="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        elsif ((s = s1 and (to_x01(s) /= 'X'))
               or (s = '0' and s1 = 'L') or (s = 'L' and s1 = '0')
               or (s = '1' and s1 = 'H') or (s = 'H' and s1 = '1')) then
          assert (s2 = '1')
            report to_string(s) & " ""?="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        elsif (s /= s1) and (to_x01(s) /= 'X') and (to_x01(s1) /= 'X') then
          assert (s2 = '0')
            report to_string(s) & " ""?="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        else           -- There's an X in there
          assert (s2 = 'X')
            report to_string(s) & " ""?="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        end if;
      end loop;
    end loop;
    -- Test of ?/= operator for std_ulogic
    for s in STD_ULOGIC loop
      for s1 in STD_ULOGIC loop
        s2 := s ?/= s1;
        if (s = '-' or s1 = '-') then
          assert (s2 = '0')
            report to_string(s) & " ""?/="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        elsif ((s = 'U' or s1 = 'U')) then
          assert (s2 = 'U')
            report to_string(s) & " ""?/="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        elsif ((s = s1 and (to_x01(s) /= 'X'))
               or (s = '0' and s1 = 'L') or (s = 'L' and s1 = '0')
               or (s = '1' and s1 = 'H') or (s = 'H' and s1 = '1')) then
          assert (s2 = '0')
            report to_string(s) & " ""?/="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        elsif (s /= s1) and (to_x01(s) /= 'X') and (to_x01(s1) /= 'X') then
          assert (s2 = '1')
            report to_string(s) & " ""?/="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        else           -- There's an X in there
          assert (s2 = 'X')
            report to_string(s) & " ""?/="" " & to_string(s1)
            & " = " & to_string (s2) severity error;
        end if;
      end loop;
    end loop;
    -- ?<
    s1 := '0';
    s2 := '0';
    s := s1 ?< s2;
    assert s = '0' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := '0';
    s := s1 ?< s2;
    assert s = '0' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '0';
    s2 := '1';
    s := s1 ?< s2;
    assert s = '1' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'L';
    s2 := '1';
    s := s1 ?< s2;
    assert s = '1' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'X';
    s2 := '1';
    s := s1 ?< s2;
    assert s = 'X' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := 'U';
    s := s1 ?< s2;
    assert s = 'U' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'Z';
    s2 := 'Z';
    s := s1 ?< s2;
    assert s = 'X' report to_string(s1) & " ?< " & to_string(s2)
      & " = " & to_string(s) severity error;
    -- ?<=
    s1 := '0';
    s2 := '0';
    s := s1 ?<= s2;
    assert s = '1' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := '0';
    s := s1 ?<= s2;
    assert s = '0' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '0';
    s2 := '1';
    s := s1 ?<= s2;
    assert s = '1' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'L';
    s2 := '1';
    s := s1 ?<= s2;
    assert s = '1' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'H';
    s2 := '1';
    s := s1 ?<= s2;
    assert s = '1' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'X';
    s2 := '1';
    s := s1 ?<= s2;
    assert s = 'X' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := 'U';
    s := s1 ?<= s2;
    assert s = 'U' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'Z';
    s2 := 'Z';
    s := s1 ?<= s2;
    assert s = 'X' report to_string(s1) & " ?<= " & to_string(s2)
      & " = " & to_string(s) severity error;
    -- ?>
    s1 := '0';
    s2 := '0';
    s := s1 ?> s2;
    assert s = '0' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := '0';
    s := s1 ?> s2;
    assert s = '1' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '0';
    s2 := '1';
    s := s1 ?> s2;
    assert s = '0' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := 'L';
    s := s1 ?> s2;
    assert s = '1' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'X';
    s2 := '1';
    s := s1 ?> s2;
    assert s = 'X' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := 'U';
    s := s1 ?> s2;
    assert s = 'U' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'Z';
    s2 := 'Z';
    s := s1 ?> s2;
    assert s = 'X' report to_string(s1) & " ?> " & to_string(s2)
      & " = " & to_string(s) severity error;
    -- ?>=
    s1 := '0';
    s2 := '0';
    s := s1 ?>= s2;
    assert s = '1' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := '0';
    s := s1 ?>= s2;
    assert s = '1' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '0';
    s2 := '1';
    s := s1 ?>= s2;
    assert s = '0' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'L';
    s2 := '1';
    s := s1 ?>= s2;
    assert s = '0' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'H';
    s2 := '1';
    s := s1 ?>= s2;
    assert s = '1' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'X';
    s2 := '1';
    s := s1 ?>= s2;
    assert s = 'X' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := '1';
    s2 := 'U';
    s := s1 ?>= s2;
    assert s = 'U' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    s1 := 'Z';
    s2 := 'Z';
    s := s1 ?>= s2;
    assert s = 'X' report to_string(s1) & " ?>= " & to_string(s2)
      & " = " & to_string(s) severity error;
    -- std_logic_vector
    aslv := "00000010";
    bslv := "00000010";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "00000011";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000011";
    bslv := "00000011";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "11000011";
    bslv := "00000011";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "11000011";
    bslv := "11000000";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "0000001H";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "0000001L";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "0000001X";
    s := aslv ?= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "0000001X";
    bslv := "00000010";
    s := aslv ?= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000000";
    bslv := "LLLLLLLL";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "11111111";
    bslv := "HHHHHHHH";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "000-000L";
    bslv := "U001000H";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "L00-000U";
    bslv := "H0010000";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "XXXXXXXX";
    bslv := "XXXXXXXX";
    s := aslv ?= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "UZ-WHL01";
    bslv := "XXXXXXXX";
    s := aslv ?= bslv;
    assert s = 'U'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "--------";
    bslv := "XXXXXXXX";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-0";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-1";
    s := aslv ?= bslv;
    assert s = '0'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "Z0U0W0X0";
    bslv := "-0-0-0-0";
    s := aslv ?= bslv;
    assert s = '1'
      report to_string(aslv) & " ?= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect a ?= length mismatch warning here" severity note;
      check6 := "0000000";
      aslv   := "00000000";
      s := check6 ?= aslv;
      assert s = 'X'
        report "slv " & to_string(check6) & " ?= " & to_string(aslv)
        & " = " & to_string (s)
        severity error;
    end if;
    -- ?/=
    aslv := "00000010";
    bslv := "00000010";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "00000011";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000011";
    bslv := "00000011";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "11000011";
    bslv := "00000011";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "11000011";
    bslv := "11000000";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "0000001H";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "0000001L";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000010";
    bslv := "0000001X";
    s := aslv ?/= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "0000001X";
    bslv := "00000010";
    s := aslv ?/= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "00000000";
    bslv := "LLLLLLLL";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "11111111";
    bslv := "HHHHHHHH";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "000-000L";
    bslv := "U001000H";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "L00-000U";
    bslv := "H0010000";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "XXXXXXXX";
    bslv := "XXXXXXXX";
    s := aslv ?/= bslv;
    assert s = 'X'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "UZ-WHL01";
    bslv := "XXXXXXXX";
    s := aslv ?/= bslv;
    assert s = 'U'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "--------";
    bslv := "XXXXXXXX";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-0";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "10101010";
    bslv := "-0-0-0-1";
    s := aslv ?/= bslv;
    assert s = '1'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    aslv := "Z0U0W0X0";
    bslv := "-0-0-0-0";
    s := aslv ?/= bslv;
    assert s = '0'
      report to_string(aslv) & " ?/= " & to_string(bslv)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect a ?/= length mismatch warning here" severity note;
      check6 := "0000000";
      aslv   := "00000000";
      s := check6 ?/= aslv;
      assert s = 'X'
        report "slv " & to_string(check6) & " ?/= " & to_string(aslv)
        & " = " & to_string (s)
        severity error;
    end if;
    -- std_ulogic_vector
    asulv := "00000010";
    bsulv := "00000010";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "00000011";
    s := asulv ?= bsulv;
    assert s = '0'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "11000011";
    bsulv := "00000011";
    s := asulv ?= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "11000011";
    bsulv := "11000000";
    s := asulv ?= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "0000001H";
    s := asulv ?= bsulv;
    assert s = '0'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "0000001L";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "0000001X";
    s := asulv ?= bsulv;
    assert s = 'X'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "0000001X";
    bsulv := "00000010";
    s := asulv ?= bsulv;
    assert s = 'X'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000000";
    bsulv := "LLLLLLLL";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "11111111";
    bsulv := "HHHHHHHH";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "XXXXXXXX";
    bsulv := "XXXXXXXX";
    s := asulv ?= bsulv;
    assert s = 'X'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "UZ-WHL01";
    bsulv := "XXXXXXXX";
    s := asulv ?= bsulv;
    assert s = 'U'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "--------";
    bsulv := "XXXXXXXX";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "10101010";
    bsulv := "-0-0-0-0";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "10101010";
    bsulv := "-0-0-0-1";
    s := asulv ?= bsulv;
    assert s = '0'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "Z0U0W0X0";
    bsulv := "-0-0-0-0";
    s := asulv ?= bsulv;
    assert s = '1'
      report "sulv " & to_string(asulv) & " ?= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect a ?= length mismatch warning here" severity note;
      checks6 := "0000000";
      asulv   := "00000000";
      s := checks6 ?= asulv;
      assert s = 'X'
        report "sulv " & to_string(checks6) & " ?= " & to_string(asulv)
        & " = " & to_string (s)
        severity error;
    end if;
    -- ?/=
    asulv := "00000010";
    bsulv := "00000010";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "00000011";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000011";
    bsulv := "00000011";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "11000011";
    bsulv := "00000011";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "11000011";
    bsulv := "11000000";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "0000001H";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "0000001L";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000010";
    bsulv := "0000001X";
    s := asulv ?/= bsulv;
    assert s = 'X'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "0000001X";
    bsulv := "00000010";
    s := asulv ?/= bsulv;
    assert s = 'X'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "00000000";
    bsulv := "LLLLLLLL";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "11111111";
    bsulv := "HHHHHHHH";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "000-000L";
    bsulv := "U001000H";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "L00-000U";
    bsulv := "H0010000";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "XXXXXXXX";
    bsulv := "XXXXXXXX";
    s := asulv ?/= bsulv;
    assert s = 'X'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "UZ-WHL01";
    bsulv := "XXXXXXXX";
    s := asulv ?/= bsulv;
    assert s = 'U'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "--------";
    bsulv := "XXXXXXXX";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "10101010";
    bsulv := "-0-0-0-0";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "10101010";
    bsulv := "-0-0-0-1";
    s := asulv ?/= bsulv;
    assert s = '1'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    asulv := "Z0U0W0X0";
    bsulv := "-0-0-0-0";
    s := asulv ?/= bsulv;
    assert s = '0'
      report to_string(asulv) & " ?/= " & to_string(bsulv)
      & " = " & to_string (s)
      severity error;
    if not quiet then
      report "Expect a ?/= length mismatch warning here" severity note;
      checks6 := "0000000";
      asulv   := "00000000";
      s := checks6 ?/= asulv;
      assert s = 'X'
        report "sulv " & to_string(checks6) & " ?/= " & to_string(asulv)
        & " = " & to_string (s)
        severity error;
    end if;
    assert quiet
      report "?= testing completed" severity note;
    qequtest_done <= true;
    wait;
  end process qequ;

  -- test logical functions between std_logic_vector and std_ulogic_vector
  verify : process is
    subtype bv4 is bit_vector(0 to 3);
    variable a_bv : bv4;
    variable a_suv : std_ulogic_vector(0 to 3);
    variable a_slv : std_logic_vector(0 to 3);
    variable b_su : std_ulogic;
    variable b_bv : bv4;
  begin
    wait until start_logicaltest;
    for a_val in 0 to 15 loop
      a_bv := bit_vector( to_unsigned(a_val, 4) );
      a_suv := to_stdulogicvector(a_bv);
      a_slv := to_stdlogicvector(a_bv);
      for b in bit loop
        b_su := to_stdulogic(b);
        b_bv := bv4'(others => b);

        assert to_bitvector(a_suv and b_su) = bit_vector'(a_bv and b_bv)
	  report "error in a_suv and b_su";
        assert to_bitvector(a_slv and b_su) = bit_vector'(a_bv and b_bv)
	  report "error in a_slv and b_su";
        assert to_bitvector(b_su and a_suv) = bit_vector'(b_bv and a_bv)
	  report "error in b_su and a_suv";
        assert to_bitvector(b_su and a_slv) = bit_vector'(b_bv and a_bv)
	  report "error in b_su and a_slv";

        assert to_bitvector(a_suv nand b_su) = bit_vector'(a_bv nand b_bv)
	  report "error in a_suv nand b_su";
        assert to_bitvector(a_slv nand b_su) = bit_vector'(a_bv nand b_bv)
	  report "error in a_slv nand b_su";
        assert to_bitvector(b_su nand a_suv) = bit_vector'(b_bv nand a_bv)
	  report "error in b_su nand a_suv";
        assert to_bitvector(b_su nand a_slv) = bit_vector'(b_bv nand a_bv)
	  report "error in b_su nand a_slv";

        assert to_bitvector(a_suv or b_su) = bit_vector'(a_bv or b_bv)
	  report "error in a_suv or b_su";
        assert to_bitvector(a_slv or b_su) = bit_vector'(a_bv or b_bv)
	  report "error in a_slv or b_su";
        assert to_bitvector(b_su or a_suv) = bit_vector'(b_bv or a_bv)
	  report "error in b_su or a_suv";
        assert to_bitvector(b_su or a_slv) = bit_vector'(b_bv or a_bv)
	  report "error in b_su or a_slv";

        assert to_bitvector(a_suv nor b_su) = bit_vector'(a_bv nor b_bv)
	  report "error in a_suv nor b_su";
        assert to_bitvector(a_slv nor b_su) = bit_vector'(a_bv nor b_bv)
	  report "error in a_slv nor b_su";
        assert to_bitvector(b_su nor a_suv) = bit_vector'(b_bv nor a_bv)
	  report "error in b_su nor a_suv";
        assert to_bitvector(b_su nor a_slv) = bit_vector'(b_bv nor a_bv)
	  report "error in b_su nor a_slv";

        assert to_bitvector(a_suv xor b_su) = bit_vector'(a_bv xor b_bv)
	  report "error in a_suv xor b_su";
        assert to_bitvector(a_slv xor b_su) = bit_vector'(a_bv xor b_bv)
	  report "error in a_slv xor b_su";
        assert to_bitvector(b_su xor a_suv) = bit_vector'(b_bv xor a_bv)
	  report "error in b_su xor a_suv";
        assert to_bitvector(b_su xor a_slv) = bit_vector'(b_bv xor a_bv)
	  report "error in b_su xor a_slv";

        assert to_bitvector(a_suv xnor b_su) = bit_vector'(a_bv xnor b_bv)
	  report "error in a_suv xnor b_su";
        assert to_bitvector(a_slv xnor b_su) = bit_vector'(a_bv xnor b_bv)
	  report "error in a_slv xnor b_su";
        assert to_bitvector(b_su xnor a_suv) = bit_vector'(b_bv xnor a_bv)
	  report "error in b_su xnor a_suv";
        assert to_bitvector(b_su xnor a_slv) = bit_vector'(b_bv xnor a_bv)
	  report "error in b_su xnor a_slv";

	wait for 1 ns;
      end loop;
    end loop;
    assert quiet
      report "std_ulogic and vector logical operators test completed."
      severity note;
    logicaltest_done <= true;
    wait;
  end process verify;

end architecture testbench;
