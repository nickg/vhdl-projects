-- --------------------------------------------------------------------
-- Title      : Test_shift
-- test vectors for the shift funcitons in 1164.
--
-- Last Modified: $Date: 2006-06-08 11:01:00-04 $
-- RCS ID: $Id: test_shift.vhdl,v 1.1 2006-06-08 11:01:00-04 l435385 Exp $
--
--  Modified for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------
entity test_shift is
  generic (
    quiet : BOOLEAN := false);          -- run quietly
end entity test_shift;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

architecture test of test_shift is
  signal start_shifttest, shifttest_done : BOOLEAN := false;  -- start reading test
begin

  verify : process is
    variable bv  : BIT_VECTOR(0 to 3);
    variable suv : STD_ULOGIC_VECTOR(0 to 3);
    variable slv : STD_LOGIC_VECTOR(0 to 3);
  begin
    for bv_val in 0 to 15 loop
      bv  := BIT_VECTOR (to_unsigned (bv_val, bv'length));  -- call from numeric_bit
      suv := to_stdulogicvector(bv);
      slv := to_stdlogicvector(bv);
      for shamt in -4 to 4 loop
        assert to_bitvector(suv sll shamt) = bv sll shamt
          report "error in unsigned sll";
        assert to_bitvector(slv sll shamt) = bv sll shamt
          report "error in signed sll";

        assert to_bitvector(suv srl shamt) = bv srl shamt
          report "error in unsigned srl";
        assert to_bitvector(slv srl shamt) = bv srl shamt
          report "error in signed srl";

        -- SLA and SRA not defined for std_logic_vector
--      assert to_bitvector(suv sla shamt) = bv sla shamt
--        report "error in unsigned sla";
--      assert to_bitvector(slv sla shamt) = bv sla shamt
--        report "error in signed sla";

--      assert to_bitvector(suv sra shamt) = bv sra shamt
--        report "error in unsigned sra";
--      assert to_bitvector(slv sra shamt) = bv sra shamt
--        report "error in signed sra";

        assert to_bitvector(suv rol shamt) = bv rol shamt
          report "error in unsigned rol";
        assert to_bitvector(slv rol shamt) = bv rol shamt
          report "error in signed rol";

        assert to_bitvector(suv ror shamt) = bv ror shamt
          report "error in unsigned ror";
        assert to_bitvector(slv ror shamt) = bv ror shamt
          report "error in signed ror";
        wait for 1 ns;
      end loop;
    end loop;
    start_shifttest <= true;
    wait until shifttest_done;
    assert (false) report "1164 shift testing completed." severity note;
    wait;
  end process verify;

  -- purpose: test the arithmetic shifts
  shifttest : process is
    -- purpose: report an error
    procedure report_error (
      errmes   : in STRING;                 -- error message
      actual   : in STD_ULOGIC_VECTOR;      -- data from algorithm
      expected : in STD_ULOGIC_VECTOR)  is  -- reference data
    begin  -- function report_error
      if actual /= expected then
        report errmes & " " & to_string (actual) & " /= " & to_string (expected)
          severity error;
      end if;
      return;
    end procedure report_error;
    variable check7uf1, check7uf2, check7uf3 : STD_ULOGIC_VECTOR(6 downto 0);
    variable check7sf1, check7sf2, check7sf3 : STD_LOGIC_VECTOR(6 downto 0);
  begin  -- process shifttest
    wait until start_shifttest;
    check7uf1 := "0110100";                 -- 6.5
    check7uf2 := check7uf1 srl 1;
    check7uf3 := "0011010";                 -- 3.25
    report_error ("SRL test", check7uf2, check7uf3);
    check7uf2 := check7uf1 srl -1;
    check7uf3 := "1101000";                 -- 13
    report_error ("SRL test -1", check7uf2, check7uf3);
    check7uf2 := check7uf1 srl 55;
    check7uf3 := "0000000";
    report_error ("SRL test 55", check7uf2, check7uf3);
    check7uf2 := check7uf1 srl -55;
    check7uf3 := "0000000";
    report_error ("SRL test -55", check7uf2, check7uf3);
    check7uf1 := "0110100";                 -- 6.5
    check7uf2 := check7uf1 sll -1;
    check7uf3 := "0011010";                 -- 3.25
    report_error ("SLL test", check7uf2, check7uf3);
    check7uf2 := check7uf1 sll 1;
    check7uf3 := "1101000";                 -- 13
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
    -- std_logic_vector
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

    assert (quiet) report "Arithmetic shift test completed" severity note;
    shifttest_done <= true;
    wait;
  end process shifttest;

end architecture test;
