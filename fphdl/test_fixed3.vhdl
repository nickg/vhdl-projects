-- Test vectors for the fixed point math package
-- This is a comprehensive test for the fixed point math packages.
-- Created for vhdl-200x by David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
--   modification history : Last Modified $Date: 2007-09-12 08:58:36-04 $
--   Version $Id: test_fixed3.vhdl,v 1.3 2007-09-12 08:58:36-04 l435385 Exp $
-- --------------------------------------------------------------------

entity test_fixed3 is
  generic (
    quiet : BOOLEAN := false);          -- make the simulation quiet
end entity test_fixed3;

use std.textio.all;
library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;          -- %%% For testing only, REMOVE
use ieee.numeric_std.all;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

architecture testbench of test_fixed3 is

  constant debug : BOOLEAN := false;    -- debug mode, prints out lots of data
  -- purpose: reports an error
  procedure report_error (
    constant errmes   : in STRING;      -- error message
    actual            : in ufixed;      -- data from algorithm
    constant expected : in ufixed) is   -- reference data
    variable L : LINE;
  begin  -- function report_error
    assert actual = expected
      report errmes & LF
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & LF
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
      report errmes & LF
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & LF
      & "     /= " & to_string(expected)
      & " (" & REAL'image(to_real(expected)) & ")"
      severity error;
    return;
  end procedure report_error;

  -- purpose: reports an error
  -- Needed to compare strings with meta values in them.
  procedure report_error (
    constant errmes : string;  -- error message
    actual : in std_logic_vector;  -- data from algorithm
    constant expected : std_logic_vector) is  -- reference data
    variable L : line;
  begin  -- function report_error
    if actual /= expected then
      report errmes severity error;
      -- This is what you had to go through before the "to_string"
      -- funcitons.
      write (L, string'("Actual: "));
      write (L, actual);
      writeline (output, L);
      write (L, string'("     /= "));
      write (L, expected);
      writeline (output, L);
    end if;
    return;
  end procedure report_error;
  subtype ufixed7_3 is ufixed (3 downto -3);                           -- 7 bit
  subtype ufixed16_8 is ufixed (7 downto -8);                          -- 16 bit
  subtype sfixed7_3 is sfixed (3 downto -3);                           -- 7 bit
  subtype sfixed16_8 is sfixed (7 downto -8);                          -- 16 BIT
  signal  start_resizetest, resizetest_done       : BOOLEAN := false;  -- resize test
  signal  start_sresizetest, sresizetest_done     : BOOLEAN := false;  -- resize test
  signal  start_newconvtest, newconvtest_done     : BOOLEAN := false;  -- new convert test
  signal  start_boundtest, boundtest_done         : BOOLEAN := false;  -- boundary test
  signal  start_shiftfindtest, shiftfindtest_done : BOOLEAN := false;  -- start reading test
  signal  start_newremmodtest, newremmodtest_done : BOOLEAN := false;  -- new rem/mod test
  signal  start_scalbtest, scalbtest_done         : BOOLEAN := false;  -- scalb test
  signal  start_quesequaltest, quesequtest_done   : BOOLEAN := false;  -- ?= test
  signal  start_fileiotest, fileiotest_done       : BOOLEAN := false;
begin  -- architecture testbench

  -- purpose: Main test process
  tester : process is

  begin  -- process tester

    --------------------------------------------------------------------------
    -- Boundary test, test the bounds of the numbers
    --------------------------------------------------------------------------
    start_boundtest <= true;
    wait until boundtest_done;

    ---------------------------------------------------------------------------
    -- Shift and find test
    ---------------------------------------------------------------------------
    start_shiftfindtest <= true;
    wait until shiftfindtest_done;

    --------------------------------------------------------------------------
    -- resize test, to check the bounds.
    --------------------------------------------------------------------------
    start_resizetest  <= true;
    wait until resizetest_done;
    start_sresizetest <= true;
    wait until sresizetest_done;

    --------------------------------------------------------------------------
    -- New conversion test
    --------------------------------------------------------------------------
    start_newconvtest   <= true;
    wait until newconvtest_done;
    start_newremmodtest <= true;
    wait until newremmodtest_done;

    --------------------------------------------------------------------------
    -- scalb test
    --------------------------------------------------------------------------
    start_scalbtest     <= true;
    wait until scalbtest_done;          -- scalb test
    --------------------------------------------------------------------------
    -- Start ?= ?/=, ?> ... and to_xu01 test
    --------------------------------------------------------------------------
    start_quesequaltest <= true;
    wait until quesequtest_done;        -- ?= test
    --------------------------------------------------------------------------
    -- File I/O test
    --------------------------------------------------------------------------
    start_fileiotest    <= true;
    wait until fileiotest_done;
    report "Fixed point package testing part 3 complete";
    wait;

  end process tester;

  -- purpose: Check the shift and find funcitons
  shiftfind : process is
    variable check7uf1, check7uf2, check7uf3 : ufixed7_3;
    variable check7sf1, check7sf2, check7sf3 : sfixed7_3;
    variable check7s1, check7s2, check7s3    : SIGNED (6 downto 0);
    variable checkint                        : INTEGER;
  begin  -- process shiftfind
    wait until start_shiftfindtest;
    -- A quick little experiment in signed shifts.
    check7s1 := "1000000";              -- -64
    check7s2 := shift_right (check7s1, 6);
    check7s3 := "1111111";              -- -1
    report_error ("signed shift_right 6 test",
                  to_sfixed(check7s2), to_sfixed(check7s3));
    check7s1 := "1000000";              -- -64
    check7s2 := shift_right (check7s1, 7);
    check7s3 := "1111111";              -- Answer would be -0.5
    report_error ("signed shift_right 7 test",
                  to_sfixed(check7s2), to_sfixed(check7s3));
    check7s1 := "1000000";              -- -64
    check7s2 := shift_right (check7s1, 8);
    check7s3 := "1111111";              -- Answer would be -0.25
    report_error ("signed shift_right 8 test",
                  to_sfixed(check7s2), to_sfixed(check7s3));
    -- ufixed shift test
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
    check7uf2 := check7uf1 srl 0;
    check7uf3 := "0110100";             -- 6.5
    report_error ("SRL test 0", check7uf2, check7uf3);
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
    check7uf2 := check7uf1 sll 0;
    check7uf3 := "0110100";             -- 6.5
    report_error ("Sll test 0", check7uf2, check7uf3);

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
    check7uf2 := check7uf1 ror 0;
    check7uf3 := "0110100";             -- 6.5
    report_error ("ror test 0", check7uf2, check7uf3);
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
    check7uf2 := check7uf1 rol 0;
    check7uf3 := "0110100";             -- 6.5
    report_error ("rol test 0", check7uf2, check7uf3);

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
    check7uf2 := check7uf1 sra 0;
    check7uf3 := "0110100";             -- 6.5
    report_error ("SRa test 0", check7uf2, check7uf3);

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
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := check7uf1 sla 0;
    check7uf3 := "0110100";             -- 6.5
    report_error ("sla test 0", check7uf2, check7uf3);
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
    -- Saturation test
    check7uf1 := "1110100";             -- 14.5
    check7uf2 := check7uf1 sra 52;
    check7uf3 := "0000000";
    report_error ("Sra saturation", check7uf2, check7uf3);
    check7uf1 := "0110101";             -- 6.625
    check7uf2 := check7uf1 sla 52;
    check7uf3 := "0000000";
    report_error ("Sla saturation", check7uf2, check7uf3);
    check7uf1 := "0110101";             -- 6.625
    check7uf2 := check7uf1 sra 52;
    check7uf3 := "0000000";
    report_error ("Sra 0 saturation", check7uf2, check7uf3);
    check7uf1 := "1110100";             -- 14.5
    check7uf2 := check7uf1 sla 52;
    check7uf3 := "0000000";
    report_error ("Sla 0 saturation", check7uf2, check7uf3);

    -- signed test.  This is a copy and paste of the unsigned
    -- test, so the commented numbers mean nothing if they are
    -- negative.
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 srl 1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("Signed SRL test", check7sf2, check7sf3);
    check7sf2 := check7sf1 srl -1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed SRL test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 srl 55;
    check7sf3 := "0000000";
    report_error ("Signed SRL test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 srl -55;
    check7sf3 := "0000000";
    report_error ("Signed SRL test -55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 srl 0;
    check7sf3 := "0110100";             -- 6.5
    report_error ("Signed srl test 0", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sll -1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("Signed SLL test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sll 1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed SLL test 1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sll -55;
    check7sf3 := "0000000";
    report_error ("Signed SLL test -55", check7sf2, check7sf3);
    check7sf2 := check7sf1 sll 55;
    check7sf3 := "0000000";
    report_error ("Signed SLL test 55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sll 0;
    check7sf3 := "0110100";             -- 6.5
    report_error ("Signed sll test 0", check7sf2, check7sf3);

    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 ror 1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("Signed ror test", check7sf2, check7sf3);
    check7sf2 := check7sf1 ror -1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed ror test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 ror 55;
    check7sf3 := "1101000";
    report_error ("Signed ror test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 ror -55;
    check7sf3 := "0011010";
    report_error ("Signed ror test -55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 ror 0;
    check7sf3 := "0110100";             -- 6.5
    report_error ("Signed ror test 0", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 rol -1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("Signed rol test", check7sf2, check7sf3);
    check7sf2 := check7sf1 rol 1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed rol test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 rol -53;
    check7sf3 := "0100011";
    report_error ("Signed rol test 53", check7sf2, check7sf3);
    check7sf2 := check7sf1 rol 53;
    check7sf3 := "1000110";
    report_error ("Signed rol test -53", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 rol 0;
    check7sf3 := "0110100";             -- 6.5
    report_error ("Signed rol test 0", check7sf2, check7sf3);

    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sra 1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("Signed SRa test", check7sf2, check7sf3);
    check7sf2 := check7sf1 sra -1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed SRa test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sra 55;
    check7sf3 := "0000000";
    report_error ("Signed SRa test 55", check7sf2, check7sf3);
    check7sf2 := check7sf1 sra -55;
    check7sf3 := "0000000";
    report_error ("Signed SRa test -55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sra 0;
    check7sf3 := "0110100";             -- 6.5
    report_error ("Signed sra test 0", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sla -1;
    check7sf3 := "0011010";             -- 3.25
    report_error ("Signed SLa test -1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sla 1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed SLa test 1", check7sf2, check7sf3);
    check7sf2 := check7sf1 sla -55;
    check7sf3 := "0000000";
    report_error ("Signed SLa test -55", check7sf2, check7sf3);
    check7sf2 := check7sf1 sla 55;
    check7sf3 := "0000000";
    report_error ("Signed SLa test 55", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := check7sf1 sla 0;
    check7sf3 := "0110100";             -- 6.5
    report_error ("Signed sla test 0", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sra 1;
    check7sf3 := "1111010";             -- 16.25
    report_error ("Signed SRa test carry", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sra -1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed SRa test -carry", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sra 1;
    check7sf3 := "0011010";
    report_error ("Signed SRa test carry-", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sra -1;
    check7sf3 := "1101010";
    report_error ("Signed SRa test -carry-", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sla -1;
    check7sf3 := "1111010";
    report_error ("Signed Sla test -carry", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sla 1;
    check7sf3 := "1101000";             -- 13
    report_error ("Signed Sla test carry", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sla -1;
    check7sf3 := "0011010";
    report_error ("Signed Sla test -carry-", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sla 1;
    check7sf3 := "1101010";
    report_error ("Signed Sla test carry-", check7sf2, check7sf3);
    -- Saturation test
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sra 52;
    check7sf3 := "1111111";
    report_error ("Signed Sra saturation", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sla 52;
    check7sf3 := "0000000";
    report_error ("Signed Sla saturation", check7sf2, check7sf3);
    check7sf1 := "0110101";             -- 6.625
    check7sf2 := check7sf1 sra 52;
    check7sf3 := "0000000";
    report_error ("Signed Sra 52 saturation", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sla 52;
    check7sf3 := "0000000";
    report_error ("-Signed Sla 52 saturation", check7sf2, check7sf3);
    check7sf1 := "1110100";             -- 14.5
    check7sf2 := check7sf1 sra 52;
    check7sf3 := "1111111";
    report_error ("-Signed Sra 52 saturation", check7sf2, check7sf3);


    -- shift_right and shift_left test
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := shift_left(check7uf1, 1);
    check7uf3 := "1101000";             -- 13
    report_error ("shift_left 1 test", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := shift_left(check7uf1, 0);
    report_error ("shift_left 0 test", check7uf2, check7uf1);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := shift_left(check7uf1, 4);
    check7uf3 := "1000000";             -- 8
    report_error ("shift_left 4 test", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := shift_left(check7uf1, 50);
    check7uf3 := "0000000";             -- 8
    report_error ("shift_left 50 test", check7uf2, check7uf3);
    -- signed shift_left
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_left(check7sf1, 1);
    check7sf3 := "1101000";             -- 13
    report_error ("shift_left signed 1 test", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_left(check7sf1, 0);
    report_error ("shift_left signed 0 test", check7sf2, check7sf1);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_left(check7sf1, 4);
    check7sf3 := "1000000";             -- 8
    report_error ("shift_left signed 4 test", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_left(check7sf1, 50);
    check7sf3 := "0000000";             -- 8
    report_error ("shift_left signed 50 test", check7sf2, check7sf3);
    -- shift_right test
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := shift_right (check7uf1, 1);
    check7uf3 := "0011010";             -- 3.25
    report_error ("shift_right 1 test", check7uf2, check7uf3);
    check7uf1 := "0110100";             -- 6.5
    check7uf2 := shift_right (check7uf1, 0);
    report_error ("shift_right 0 test", check7uf2, check7uf1);
    check7uf1 := "1000000";             -- 8
    check7uf2 := shift_right (check7uf1, 3);
    check7uf3 := "0001000";             -- 1
    report_error ("shift_right 3 test", check7uf2, check7uf3);
    check7uf1 := "1000000";             -- 8
    check7uf2 := shift_right (check7uf1, 50);
    check7uf3 := "0000000";             -- 1
    report_error ("shift_right 50 test", check7uf2, check7uf3);
    -- signed shift_right
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_right (check7sf1, 1);
    check7sf3 := "0011010";             -- 3.25
    report_error ("shift_right signed 1 test", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_right (check7sf1, 0);
    report_error ("shift_right signed 1 test", check7sf2, check7sf1);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_right (check7sf1, 3);
    check7sf3 := "0000110";             -- 0.75
    report_error ("shift_right signed 3 test", check7sf2, check7sf3);
    check7sf1 := "0110100";             -- 6.5
    check7sf2 := shift_right (check7sf1, 62);
    check7sf3 := "0000000";             -- 0.375
    report_error ("shift_right signed 62 test", check7sf2, check7sf3);
    check7sf1 := "1000000";             -- -8
    check7sf2 := shift_right (check7sf1, 1);
    check7sf3 := "1100000";
    report_error ("shift_right -signed 1 test", check7sf2, check7sf3);
    check7sf1 := "1000000";             -- -8
    check7sf2 := shift_right (check7sf1, 6);
    check7sf3 := "1111111";
    report_error ("shift_right -signed 6 test", check7sf2, check7sf3);
    check7sf1 := "1000000";             -- -8
    check7sf2 := shift_right (check7sf1, 7);
    check7sf3 := "1111111";
    report_error ("shift_right -signed 7 test", check7sf2, check7sf3);
    check7sf1 := "1000000";             -- -8
    check7sf2 := shift_right (check7sf1, 42);
    check7sf3 := "1111111";
    report_error ("shift_right -signed 42 test", check7sf2, check7sf3);

    -- find msb test
    check7uf1 := "0110100";             -- 6.5
    checkint  := find_leftmost (check7uf1, '1');
    assert (checkint = 2) report "find_leftmost, 2 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "0110100";             -- 6.5
    checkint  := find_rightmost (check7uf1, '1');
    assert (checkint = -1) report "find_rightmost, -1 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "0000000";
    checkint  := find_leftmost (check7uf1, '1');
    assert (checkint = -4) report "find_leftmost, -4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "0000000";
    checkint  := find_rightmost (check7uf1, '1');
    assert (checkint = 4) report "find_rightmost, 4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "0000001";
    checkint  := find_leftmost (check7uf1, '1');
    assert (checkint = -3) report "find_leftmost, -3 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "1000000";
    checkint  := find_rightmost (check7uf1, '1');
    assert (checkint = 3) report "find_rightmost, 3 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "1111101";
    checkint  := find_leftmost (check7uf1, '0');
    assert (checkint = -2) report "find_leftmost, -2 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "1000011";
    checkint  := find_rightmost (check7uf1, '0');
    assert (checkint = -1) report "find_rightmost, -1 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "1111111";
    checkint  := find_leftmost (check7uf1, '0');
    assert (checkint = -4) report "find_leftmost, -4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;
    check7uf1 := "1111111";
    checkint  := find_rightmost (check7uf1, '0');
    assert (checkint = 4) report "find_rightmost, 4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7uf1) severity error;

    -- signed test
    check7sf1 := "0110100";             -- 6.5
    checkint  := find_leftmost (check7sf1, '1');
    assert (checkint = 2) report "find_leftmost, 2 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "0110100";             -- 6.5
    checkint  := find_rightmost (check7sf1, '1');
    assert (checkint = -1) report "find_rightmost, -1 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "0000000";
    checkint  := find_leftmost (check7sf1, '1');
    assert (checkint = -4) report "find_leftmost, -4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "0000000";
    checkint  := find_rightmost (check7sf1, '1');
    assert (checkint = 4) report "find_rightmost, 4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "0000001";
    checkint  := find_leftmost (check7sf1, '1');
    assert (checkint = -3) report "find_leftmost, -3 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "1000000";
    checkint  := find_rightmost (check7sf1, '1');
    assert (checkint = 3) report "find_rightmost, 3 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "1111101";
    checkint  := find_leftmost (check7sf1, '0');
    assert (checkint = -2) report "find_leftmost, -2 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "1000011";
    checkint  := find_rightmost (check7sf1, '0');
    assert (checkint = -1) report "find_rightmost, -1 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "1111111";
    checkint  := find_leftmost (check7sf1, '0');
    assert (checkint = -4) report "find_leftmost, -4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    check7sf1 := "1111111";
    checkint  := find_rightmost (check7sf1, '0');
    assert (checkint = 4) report "find_rightmost, 4 /= " & INTEGER'image(checkint)
      & " from " & to_string (check7sf1) severity error;
    assert (quiet) report "Shift and find test completed" severity note;
    shiftfindtest_done <= true;
    wait;
  end process shiftfind;

  -- purpose: test new conversion functions, these pass the result to create
  -- the size of the result
  newconvtest : process is
    variable checkint                          : INTEGER;
    variable checkreal                         : REAL;
    variable checkuns                          : UNSIGNED (7 downto 0);
    variable checksns                          : SIGNED (7 downto 0);
    variable checkslv                          : STD_LOGIC_VECTOR (6 downto 0);
    variable check7uf1, check7uf2, check7uf3   : ufixed7_3;
    variable check7sf1, check7sf2, check7sf3   : sfixed7_3;
    variable check16uf, check16uf1, check16uf2 : ufixed16_8;
    variable check16sf, check16sf1, check16sf2 : sfixed16_8;
  begin
    wait until start_newconvtest;
    checkint         := 1;
    check7uf1        := to_ufixed (checkint, check7uf1);
    check7uf2        := "0001000";
    report_error ("to_ufixed (1, size_res)", check7uf1, check7uf2);
    checkreal        := 4.0;
    check7uf1        := to_ufixed (checkreal, check7uf1);
    check7uf2        := "0100000";
    report_error ("to_ufixed (4.0, size_res)", check7uf1, check7uf2);
    checkuns         := "00000001";
    check7uf1        := to_ufixed (checkuns, check7uf1);
    check7uf2        := "0001000";
    report_error ("to_ufixed (unsigned, size_res)", check7uf1, check7uf2);
    checkslv         := "0011000";
    check7uf1        := to_ufixed (checkslv, check7uf1);
    check7uf2        := "0011000";
    report_error ("to_ufixed (slv, size_res)", check7uf1, check7uf2);
    check7uf1        := "0111100";           -- 7.5
    check16uf1       := resize (check7uf1, check16uf1);
    check16uf2       := "0000011110000000";  -- 7.5
    report_error ("resize (uf7, uf16)", check16uf1, check16uf1);
    check16uf1       := "0000001101000000";  -- 3.25
    check7uf1        := resize (check16uf1, check7uf1);
    check7uf2        := "0011010";           -- 3.25
    report_error ("resize (uf16, uf7)", check7uf1, check7uf2);
    checkint         := 2;
    check7sf1        := to_sfixed (checkint, check7sf1);
    check7sf2        := "0010000";
    report_error ("to_sfixed (2, size_res)", check7sf1, check7sf2);
    checkreal        := 1.0;
    check7sf1        := to_sfixed (checkreal, check7sf1);
    check7sf2        := "0001000";
    report_error ("to_sfixed (1.0, size_res)", check7sf1, check7sf2);
    checksns         := "00000101";
    check7sf1        := to_sfixed (checksns, check7sf1);
    check7sf2        := "0101000";
    report_error ("to_sfixed (signed, size_res)", check7sf1, check7sf2);
    checkslv         := "0001000";
    check7sf1        := to_sfixed (checkslv, check7sf1);
    check7sf2        := "0001000";
    report_error ("to_sfixed (slv, size_res)", check7sf1, check7sf2);
    check7sf1        := "0111100";           -- 7.5
    check16sf1       := resize (check7sf1, check16sf1);
    check16sf2       := "0000011110000000";  -- 7.5
    report_error ("resize (sf7, sf16)", check16sf1, check16sf1);
    check16sf1       := "0000001101000000";  -- 3.25
    check7sf1        := resize (check16sf1, check7sf1);
    check7sf2        := "0011010";           -- 3.25
    report_error ("resize (sf16, sf7)", check7sf1, check7sf2);
    assert (quiet) report "New conversion test completed." severity note;
    newconvtest_done <= true;
    wait;
  end process newconvtest;

  -- purpose: test the resize function exahustively
  resizetest : process is
    -- purpose: wrapper around report_error
    procedure rewrap (
      constant errmes : in STRING;
      actual          : in ufixed;
      expected        : in ufixed) is
    alias ex : ufixed (actual'range) is expected;  -- sets size
  begin
    report_error (errmes   => errmes,
                  actual   => actual,
                  expected => ex);
  end procedure rewrap;
  variable uf   : ufixed7_3;                       -- 3 downto -3
  variable uf1  : ufixed (7 downto 4);
  variable uf2  : ufixed (7 downto 3);
  variable uf3  : ufixed (7 downto 2);
  variable uf4  : ufixed (7 downto -2);
  variable uf5  : ufixed (7 downto -3);
  variable uf6  : ufixed (7 downto -4);
  variable uf7  : ufixed (7 downto -8);
  variable uf8  : ufixed (4 downto 4);
  variable uf9  : ufixed (4 downto 3);
  variable ufa  : ufixed (4 downto 2);
  variable ufb  : ufixed (4 downto -2);
  variable ufc  : ufixed (4 downto -3);
  variable ufd  : ufixed (4 downto -4);
  variable ufe  : ufixed (4 downto -8);
  variable uff  : ufixed (3 downto 3);
  variable ufg  : ufixed (3 downto 2);
  variable ufh  : ufixed (3 downto -2);
  variable ufi  : ufixed (3 downto -3);
  variable ufj  : ufixed (3 downto -4);
  variable ufk  : ufixed (3 downto -8);
  variable ufl  : ufixed (2 downto 2);
  variable ufm  : ufixed (2 downto -2);
  variable ufn  : ufixed (2 downto -3);
  variable ufo  : ufixed (2 downto -4);
  variable ufp  : ufixed (0 downto 0);
  variable ufq  : ufixed (0 downto -2);
  variable ufr  : ufixed (0 downto -3);
  variable ufs  : ufixed (0 downto -4);
  variable uft  : ufixed (0 downto -8);
  variable ufu  : ufixed (-2 downto -2);
  variable ufv  : ufixed (-2 downto -3);
  variable ufw  : ufixed (-2 downto -4);
  variable ufx  : ufixed (-2 downto -8);
  variable ufy  : ufixed (-3 downto -3);
  variable ufz  : ufixed (-3 downto -4);
  variable ufaa : ufixed (-3 downto -8);
  variable ufab : ufixed (-5 downto -8);
  begin
    wait until start_resizetest;
    uf  := "1000001";                              -- 8.125, test pattern
    uf1 := resize (uf, uf1'high, uf1'low);
    rewrap ("resize uf1 test", uf1, "0001");
    uf2 := resize (uf, uf2'high, uf2'low);
    rewrap ("resize uf2 test", uf2, "00001");
    uf3 := resize (uf, uf3'high, uf3'low);
    rewrap ("resize uf3 test", uf3, "000010");
    uf4 := resize (uf, uf4'high, uf4'low);
    rewrap ("resize uf4 test", uf4, "0000100000");
    uf5 := resize (uf, uf5'high, uf5'low);
    rewrap ("resize uf5 test", uf5, "00001000001");
    uf6 := resize (uf, uf6'high, uf6'low);
    rewrap ("resize uf6 test", uf6, "000010000010");
    uf7 := resize (uf, uf7'high, uf7'low);
    rewrap ("resize uf7 test", uf7, "0000100000100000");
    uf8 := resize (uf, uf8'high, uf8'low);
    rewrap ("resize uf8 test", uf8, "1");
    uf9 := resize (uf, uf9'high, uf9'low);
    rewrap ("resize uf9 test", uf9, "01");
    ufa := resize (uf, ufa'high, ufa'low);
    rewrap ("resize ufa test", ufa, "010");
    ufb := resize (uf, ufb'high, ufb'low);
    rewrap ("resize ufb test", ufb, "0100000");
    ufc := resize (uf, ufc'high, ufc'low);
    rewrap ("resize ufc test", ufc, "01000001");
    ufd := resize (uf, ufd'high, ufd'low);
    rewrap ("resize ufd test", ufd, "010000010");
    ufe := resize (uf, ufe'high, ufe'low);
    rewrap ("resize ufe test", ufe, "0100000100000");
    uff := resize (uf, uff'high, uff'low);
    rewrap ("resize uff test", uff, "1");
    ufg := resize (uf, ufg'high, ufg'low);
    rewrap ("resize ufg test", ufg, "10");
    ufh := resize (uf, ufh'high, ufh'low);
    rewrap ("resize ufh test", ufh, "100000");
    ufi := resize (uf, ufi'high, ufi'low);
    rewrap ("resize ufi test", ufi, "1000001");
    ufj := resize (uf, ufj'high, ufj'low);
    rewrap ("resize ufj test", ufj, "10000010");
    ufk := resize (uf, ufk'high, ufk'low);
    rewrap ("resize ufk test", ufk, "100000100000");
    -- Check some rounding
    uf  := "1110111";                              -- test pattern
    uf1 := resize (uf, uf1'high, uf1'low);
    rewrap ("rounding resize uf1 test", uf1, "0001");
    uf2 := resize (uf, uf2'high, uf2'low);
    rewrap ("rounding resize uf2 test", uf2, "00010");
    uf3 := resize (uf, uf3'high, uf3'low);
    rewrap ("rounding resize uf3 test", uf3, "000100");
    uf4 := resize (uf, uf4'high, uf4'low);
    rewrap ("rounding resize uf4 test", uf4, "0000111100");
    uf5 := resize (uf, uf5'high, uf5'low);
    rewrap ("rounding resize uf5 test", uf5, "00001110111");
    uf6 := resize (uf, uf6'high, uf6'low);
    rewrap ("rounding resize uf6 test", uf6, "000011101110");
    uf7 := resize (uf, uf7'high, uf7'low);
    rewrap ("rounding resize uf7 test", uf7, "0000111011100000");
    uf8 := resize (uf, uf8'high, uf8'low);
    rewrap ("rounding resize uf8 test", uf8, "1");
    uf9 := resize (uf, uf9'high, uf9'low);
    rewrap ("rounding resize uf9 test", uf9, "10");
    ufa := resize (uf, ufa'high, ufa'low);
    rewrap ("rounding resize ufa test", ufa, "100");
    ufb := resize (uf, ufb'high, ufb'low);
    rewrap ("rounding resize ufb test", ufb, "0111100");
    ufc := resize (uf, ufc'high, ufc'low);
    rewrap ("rounding resize ufc test", ufc, "01110111");
    ufd := resize (uf, ufd'high, ufd'low);
    rewrap ("rounding resize ufd test", ufd, "011101110");
    ufe := resize (uf, ufe'high, ufe'low);
    rewrap ("rounding resize ufe test", ufe, "0111011100000");
    uff := resize (uf, uff'high, uff'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);       -- round and wrap
    rewrap ("rounding resize uff test", uff, "0");
    ufg := resize (uf, ufg'high, ufg'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);       -- round and wrap
    rewrap ("rounding resize ufg test", ufg, "00");
    ufh := resize (uf, ufh'high, ufh'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);       -- round and wrap
    rewrap ("rounding resize ufh test", ufh, "111100");
    ufi := resize (uf, ufi'high, ufi'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);       -- round and wrap
    rewrap ("rounding resize ufi test", ufi, "1110111");
    ufj := resize (uf, ufj'high, ufj'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);       -- round and wrap
    rewrap ("rounding resize ufj test", ufj, "11101110");
    ufk := resize (uf, ufk'high, ufk'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);       -- round and wrap
    rewrap ("rounding resize ufk test", ufk, "111011100000");

    uf   := "1000001";                  -- 8.125, test pattern
    -- saturate versions
    ufl  := resize (uf, ufl'high, ufl'low);
    rewrap ("resize ufl test", ufl, "1");
    ufm  := resize (uf, ufm'high, ufm'low);
    rewrap ("resize ufm test", ufm, "11111");
    ufn  := resize (uf, ufn'high, ufn'low);
    rewrap ("resize ufn test", ufn, "111111");
    ufo  := resize (uf, ufo'high, ufo'low);
    rewrap ("resize ufo test", ufo, "1111111");
    ufp  := resize (uf, ufp'high, ufp'low);
    rewrap ("resize ufp test", ufp, "1");
    ufq  := resize (uf, ufq'high, ufq'low);
    rewrap ("resize ufq test", ufq, "111");
    ufr  := resize (uf, ufr'high, ufr'low);
    rewrap ("resize ufr test", ufr, "1111");
    ufs  := resize (uf, ufs'high, ufs'low);
    rewrap ("resize ufs test", ufs, "11111");
    uft  := resize (uf, uft'high, uft'low);
    rewrap ("resize uft test", uft, "111111111");
    ufu  := resize (uf, ufu'high, ufu'low);
    rewrap ("resize ufu test", ufu, "1");
    ufv  := resize (uf, ufv'high, ufv'low);
    rewrap ("resize ufv test", ufv, "11");
    ufw  := resize (uf, ufw'high, ufw'low);
    rewrap ("resize ufw test", ufw, "111");
    ufx  := resize (uf, ufx'high, ufx'low);
    rewrap ("resize ufx test", ufx, "1111111");
    ufy  := resize (uf, ufy'high, ufy'low);
    rewrap ("resize ufy test", ufy, "1");
    ufz  := resize (uf, ufz'high, ufz'low);
    rewrap ("resize ufz test", ufz, "11");
    ufaa := resize (uf, ufaa'high, ufaa'low);
    rewrap ("resize ufaa test", ufaa, "111111");
    ufab := resize (uf, ufab'high, ufab'low);
    rewrap ("resize ufab test", ufab, "1111");
    -- wrap versions
    ufl := resize (uf, ufl'high, ufl'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufl test", ufl, "0");
    ufm := resize (uf, ufm'high, ufm'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufm test", ufm, "00000");
    ufn := resize (uf, ufn'high, ufn'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufn test", ufn, "000001");
    ufo := resize (uf, ufo'high, ufo'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufo test", ufo, "0000010");
    ufp := resize (uf, ufp'high, ufp'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufp test", ufp, "0");
    ufq := resize (uf, ufq'high, ufq'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufq test", ufq, "000");
    ufr := resize (uf, ufr'high, ufr'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufr test", ufr, "0001");
    ufs := resize (uf, ufs'high, ufs'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufs test", ufs, "00010");
    uft := resize (uf, uft'high, uft'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize uft test", uft, "000100000");
    ufu := resize (uf, ufu'high, ufu'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufu test", ufu, "0");
    ufv := resize (uf, ufv'high, ufv'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufv test", ufv, "01");
    ufw := resize (uf, ufw'high, ufw'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufw test", ufw, "010");
    ufx := resize (uf, ufx'high, ufx'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufx test", ufx, "0100000");
    ufy := resize (uf, ufy'high, ufy'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufy test", ufy, "1");
    ufz := resize (uf, ufz'high, ufz'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize ufz test", ufz, "10");
    ufaa := resize (uf, ufaa'high, ufaa'low,
                    overflow_style => fixed_wrap,
                    round_style    => fixed_round);
    rewrap ("wrap resize ufaa test", ufaa, "100000");
    ufab := resize (uf, ufab'high, ufab'low,
                    overflow_style => fixed_wrap,
                    round_style    => fixed_round);
    rewrap ("wrap resize ufab test", ufab, "0000");
    assert (quiet) report "resize test complete" severity note;
    resizetest_done <= true;
    wait;
  end process resizetest;

  -- purpose: test the resize function exahustively
  sresizetest : process is
    -- purpose: wrapper around report_error
    procedure rewrap (
      constant errmes : in STRING;
      actual          : in sfixed;
      expected        : in sfixed) is
    alias ex : sfixed (actual'range) is expected;      -- sets size
  begin
    report_error (errmes   => errmes,
                  actual   => actual,
                  expected => ex);
  end procedure rewrap;
  variable sf   : sfixed7_3;                           -- 3 downto -3
  variable sf1  : sfixed (7 downto 4);
  variable sf2  : sfixed (7 downto 3);
  variable sf3  : sfixed (7 downto 2);
  variable sf4  : sfixed (7 downto -2);
  variable sf5  : sfixed (7 downto -3);
  variable sf6  : sfixed (7 downto -4);
  variable sf7  : sfixed (7 downto -8);
  variable sf8  : sfixed (4 downto 4);
  variable sf9  : sfixed (4 downto 3);
  variable sfa  : sfixed (4 downto 2);
  variable sfb  : sfixed (4 downto -2);
  variable sfc  : sfixed (4 downto -3);
  variable sfd  : sfixed (4 downto -4);
  variable sfe  : sfixed (4 downto -8);
  variable sff  : sfixed (3 downto 3);
  variable sfg  : sfixed (3 downto 2);
  variable sfh  : sfixed (3 downto -2);
  variable sfi  : sfixed (3 downto -3);
  variable sfj  : sfixed (3 downto -4);
  variable sfk  : sfixed (3 downto -8);
  variable sfl  : sfixed (2 downto 2);
  variable sfm  : sfixed (2 downto -2);
  variable sfn  : sfixed (2 downto -3);
  variable sfo  : sfixed (2 downto -4);
  variable sfp  : sfixed (0 downto 0);
  variable sfq  : sfixed (0 downto -2);
  variable sfr  : sfixed (0 downto -3);
  variable sfs  : sfixed (0 downto -4);
  variable sft  : sfixed (0 downto -8);
  variable sfu  : sfixed (-2 downto -2);
  variable sfv  : sfixed (-2 downto -3);
  variable sfw  : sfixed (-2 downto -4);
  variable sfx  : sfixed (-2 downto -8);
  variable sfy  : sfixed (-3 downto -3);
  variable sfz  : sfixed (-3 downto -4);
  variable sfaa : sfixed (-3 downto -8);
  variable sfab : sfixed (-5 downto -8);
  begin
    wait until start_sresizetest;
    sf  := "1000001";                                  -- -7.875, test pattern
    sf1 := resize (sf, sf1'high, sf1'low);
    rewrap ("resize sf1 test", sf1, "0000");           -- 0 better than -16
    sf2 := resize (sf, sf2'high, sf2'low);
    rewrap ("resize sf2 test", sf2, "11111");          -- -8 better than 0
    sf3 := resize (sf, sf3'high, sf3'low);
    rewrap ("resize sf3 test", sf3, "111110");
    sf4 := resize (sf, sf4'high, sf4'low);
    rewrap ("resize sf4 test", sf4, "1111100000");
    sf5 := resize (sf, sf5'high, sf5'low);
    rewrap ("resize sf5 test", sf5, "11111000001");
    sf6 := resize (sf, sf6'high, sf6'low);
    rewrap ("resize sf6 test", sf6, "111110000010");
    sf7 := resize (sf, sf7'high, sf7'low);
    rewrap ("resize sf7 test", sf7, "1111100000100000");
    sf8 := resize (sf, sf8'high, sf8'low);
    rewrap ("resize sf8 test", sf8, "0");              -- 0 better than -16
    sf9 := resize (sf, sf9'high, sf9'low);
    rewrap ("resize sf9 test", sf9, "11");             -- -8
    sfa := resize (sf, sfa'high, sfa'low);
    rewrap ("resize sfa test", sfa, "110");
    sfb := resize (sf, sfb'high, sfb'low);
    rewrap ("resize sfb test", sfb, "1100000");
    sfc := resize (sf, sfc'high, sfc'low);
    rewrap ("resize sfc test", sfc, "11000001");
    sfd := resize (sf, sfd'high, sfd'low);
    rewrap ("resize sfd test", sfd, "110000010");
    sfe := resize (sf, sfe'high, sfe'low);
    rewrap ("resize sfe test", sfe, "1100000100000");
    sff := resize (sf, sff'high, sff'low);
    rewrap ("resize sff test", sff, "1");
    sfg := resize (sf, sfg'high, sfg'low);
    rewrap ("resize sfg test", sfg, "10");
    sfh := resize (sf, sfh'high, sfh'low);
    rewrap ("resize sfh test", sfh, "100000");
    sfi := resize (sf, sfi'high, sfi'low);
    rewrap ("resize sfi test", sfi, "1000001");
    sfj := resize (sf, sfj'high, sfj'low);
    rewrap ("resize sfj test", sfj, "10000010");
    sfk := resize (sf, sfk'high, sfk'low);
    rewrap ("resize sfk test", sfk, "100000100000");
    -- Check some rounding
    sf  := "1110111";                                  -- test pattern -1.125
    sf1 := resize (sf, sf1'high, sf1'low);
    rewrap ("rounding resize sf1 test", sf1, "0000");  -- 0, rounding.
    sf2 := resize (sf, sf2'high, sf2'low);
    rewrap ("rounding resize sf2 test", sf2, "00000");
    sf3 := resize (sf, sf3'high, sf3'low);
    rewrap ("rounding resize sf3 test", sf3, "000000");
    sf4 := resize (sf, sf4'high, sf4'low);
    rewrap ("rounding resize sf4 test", sf4, "1111111100");
    sf5 := resize (sf, sf5'high, sf5'low);
    rewrap ("rounding resize sf5 test", sf5, "11111110111");
    sf6 := resize (sf, sf6'high, sf6'low);
    rewrap ("rounding resize sf6 test", sf6, "111111101110");
    sf7 := resize (sf, sf7'high, sf7'low);
    rewrap ("rounding resize sf7 test", sf7, "1111111011100000");
    sf8 := resize (sf, sf8'high, sf8'low);
    rewrap ("rounding resize sf8 test", sf8, "0");
    sf9 := resize (sf, sf9'high, sf9'low);
    rewrap ("rounding resize sf9 test", sf9, "00");
    sfa := resize (sf, sfa'high, sfa'low);
    rewrap ("rounding resize sfa test", sfa, "000");
    sfb := resize (sf, sfb'high, sfb'low);
    rewrap ("rounding resize sfb test", sfb, "1111100");
    sfc := resize (sf, sfc'high, sfc'low);
    rewrap ("rounding resize sfc test", sfc, "11110111");
    sfd := resize (sf, sfd'high, sfd'low);
    rewrap ("rounding resize sfd test", sfd, "111101110");
    sfe := resize (sf, sfe'high, sfe'low);
    rewrap ("rounding resize sfe test", sfe, "1111011100000");
    sff := resize (sf, sff'high, sff'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);           -- round and wrap
    rewrap ("rounding resize sff test", sff, "0");
    sfg := resize (sf, sfg'high, sfg'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);           -- round and wrap
    rewrap ("rounding resize sfg test", sfg, "00");
    sfh := resize (sf, sfh'high, sfh'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);           -- round and wrap
    rewrap ("rounding resize sfh test", sfh, "111100");
    sfi := resize (sf, sfi'high, sfi'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);           -- round and wrap
    rewrap ("rounding resize sfi test", sfi, "1110111");
    sfj := resize (sf, sfj'high, sfj'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);           -- round and wrap
    rewrap ("rounding resize sfj test", sfj, "11101110");
    sfk := resize (sf, sfk'high, sfk'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);           -- round and wrap
    rewrap ("rounding resize sfk test", sfk, "111011100000");

    sf   := "1000001";                  -- -7.875, test pattern
    -- saturate versions
    sfl  := resize (sf, sfl'high, sfl'low);
    rewrap ("resize sfl test", sfl, "1");
    sfm  := resize (sf, sfm'high, sfm'low);
    rewrap ("resize sfm test", sfm, "10000");
    sfn  := resize (sf, sfn'high, sfn'low);
    rewrap ("resize sfn test", sfn, "100000");
    sfo  := resize (sf, sfo'high, sfo'low);
    rewrap ("resize sfo test", sfo, "1000000");
    sfp  := resize (sf, sfp'high, sfp'low);
    rewrap ("resize sfp test", sfp, "1");
    sfq  := resize (sf, sfq'high, sfq'low);
    rewrap ("resize sfq test", sfq, "100");
    sfr  := resize (sf, sfr'high, sfr'low);
    rewrap ("resize sfr test", sfr, "1000");
    sfs  := resize (sf, sfs'high, sfs'low);
    rewrap ("resize sfs test", sfs, "10000");
    sft  := resize (sf, sft'high, sft'low);
    rewrap ("resize sft test", sft, "100000000");
    sfu  := resize (sf, sfu'high, sfu'low);
    rewrap ("resize sfu test", sfu, "1");
    sfv  := resize (sf, sfv'high, sfv'low);
    rewrap ("resize sfv test", sfv, "10");
    sfw  := resize (sf, sfw'high, sfw'low);
    rewrap ("resize sfw test", sfw, "100");
    sfx  := resize (sf, sfx'high, sfx'low);
    rewrap ("resize sfx test", sfx, "1000000");
    sfy  := resize (sf, sfy'high, sfy'low);
    rewrap ("resize sfy test", sfy, "1");
    sfz  := resize (sf, sfz'high, sfz'low);
    rewrap ("resize sfz test", sfz, "10");
    sfaa := resize (sf, sfaa'high, sfaa'low);
    rewrap ("resize sfaa test", sfaa, "100000");
    sfab := resize (sf, sfab'high, sfab'low);
    rewrap ("resize sfab test", sfab, "1000");
    -- wrap versions
    sfl := resize (sf, sfl'high, sfl'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfl test", sfl, "0");
    sfm := resize (sf, sfm'high, sfm'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfm test", sfm, "00000");
    sfn := resize (sf, sfn'high, sfn'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfn test", sfn, "000001");
    sfo := resize (sf, sfo'high, sfo'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfo test", sfo, "0000010");
    sfp := resize (sf, sfp'high, sfp'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfp test", sfp, "0");
    sfq := resize (sf, sfq'high, sfq'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfq test", sfq, "000");
    sfr := resize (sf, sfr'high, sfr'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfr test", sfr, "0001");
    sfs := resize (sf, sfs'high, sfs'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfs test", sfs, "00010");
    sft := resize (sf, sft'high, sft'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sft test", sft, "000100000");
    sfu := resize (sf, sfu'high, sfu'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfu test", sfu, "0");
    sfv := resize (sf, sfv'high, sfv'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfv test", sfv, "01");
    sfw := resize (sf, sfw'high, sfw'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfw test", sfw, "010");
    sfx := resize (sf, sfx'high, sfx'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfx test", sfx, "0100000");
    sfy := resize (sf, sfy'high, sfy'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfy test", sfy, "1");
    sfz := resize (sf, sfz'high, sfz'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfz test", sfz, "10");
    sfaa := resize (sf, sfaa'high, sfaa'low,
                    overflow_style => fixed_wrap,
                    round_style    => fixed_round);
    rewrap ("wrap resize sfaa test", sfaa, "100000");
    sfab := resize (sf, sfab'high, sfab'low,
                    overflow_style => fixed_wrap,
                    round_style    => fixed_round);
    rewrap ("wrap resize sfab test", sfab, "0000");
    -- You know, we could actually try some POSITIVE numbers....
    sf  := "0100001";                   -- 4.125, test pattern
    sf1 := resize (sf, sf1'high, sf1'low);
    rewrap ("resize pos sf1 test", sf1, "0000");
    sf2 := resize (sf, sf2'high, sf2'low);
    rewrap ("resize pos sf2 test", sf2, "00001");        -- rounded
    sf3 := resize (sf, sf3'high, sf3'low);
    rewrap ("resize pos sf3 test", sf3, "000001");       -- not rounded
    sf4 := resize (sf, sf4'high, sf4'low);
    rewrap ("resize pos sf4 test", sf4, "0000010000");
    sf5 := resize (sf, sf5'high, sf5'low);
    rewrap ("resize pos sf5 test", sf5, "00000100001");
    sf6 := resize (sf, sf6'high, sf6'low);
    rewrap ("resize pos sf6 test", sf6, "000001000010");
    sf7 := resize (sf, sf7'high, sf7'low);
    rewrap ("resize pos sf7 test", sf7, "0000010000100000");
    sf8 := resize (sf, sf8'high, sf8'low);
    rewrap ("resize pos sf8 test", sf8, "0");
    sf9 := resize (sf, sf9'high, sf9'low);
    rewrap ("resize pos sf9 test", sf9, "01");           -- 8
    sfa := resize (sf, sfa'high, sfa'low);
    rewrap ("resize pos sfa test", sfa, "001");
    sfb := resize (sf, sfb'high, sfb'low);
    rewrap ("resize pos sfb test", sfb, "0010000");
    sfc := resize (sf, sfc'high, sfc'low);
    rewrap ("resize pos sfc test", sfc, "00100001");
    sfd := resize (sf, sfd'high, sfd'low);
    rewrap ("resize pos sfd test", sfd, "001000010");
    sfe := resize (sf, sfe'high, sfe'low);
    rewrap ("resize pos sfe test", sfe, "0010000100000");
    sff := resize (sf, sff'high, sff'low);
    rewrap ("resize pos sff test", sff, "0");
    sfg := resize (sf, sfg'high, sfg'low);
    rewrap ("resize pos sfg test", sfg, "01");
    sfh := resize (sf, sfh'high, sfh'low);
    rewrap ("resize pos sfh test", sfh, "010000");
    sfi := resize (sf, sfi'high, sfi'low);
    rewrap ("resize pos sfi test", sfi, "0100001");
    sfj := resize (sf, sfj'high, sfj'low);
    rewrap ("resize pos sfj test", sfj, "01000010");
    sfk := resize (sf, sfk'high, sfk'low);
    rewrap ("resize pos sfk test", sfk, "010000100000");
    sf  := "0110111";                   -- test pattern 6.875
    sf1 := resize (sf, sf1'high, sf1'low);
    rewrap ("rounding resize pos sf1 test", sf1, "0000");
    sf2 := resize (sf, sf2'high, sf2'low);
    rewrap ("rounding resize pos sf2 test", sf2, "00001");
    sf3 := resize (sf, sf3'high, sf3'low);
    rewrap ("rounding resize pos sf3 test", sf3, "000010");
    sf4 := resize (sf, sf4'high, sf4'low);
    rewrap ("rounding resize pos sf4 test", sf4, "0000011100");
    sf5 := resize (sf, sf5'high, sf5'low);
    rewrap ("rounding resize pos sf5 test", sf5, "00000110111");
    sf6 := resize (sf, sf6'high, sf6'low);
    rewrap ("rounding resize pos sf6 test", sf6, "000001101110");
    sf7 := resize (sf, sf7'high, sf7'low);
    rewrap ("rounding resize pos sf7 test", sf7, "0000011011100000");
    sf8 := resize (sf, sf8'high, sf8'low);
    rewrap ("rounding resize pos sf8 test", sf8, "0");
    sf9 := resize (sf, sf9'high, sf9'low);
    rewrap ("rounding resize pos sf9 test", sf9, "01");
    sfa := resize (sf, sfa'high, sfa'low);
    rewrap ("rounding resize pos sfa test", sfa, "010");
    sfb := resize (sf, sfb'high, sfb'low);
    rewrap ("rounding resize pos sfb test", sfb, "0011100");
    sfc := resize (sf, sfc'high, sfc'low);
    rewrap ("rounding resize pos sfc test", sfc, "00110111");
    sfd := resize (sf, sfd'high, sfd'low);
    rewrap ("rounding resize pos sfd test", sfd, "001101110");
    sfe := resize (sf, sfe'high, sfe'low);
    rewrap ("rounding resize pos sfe test", sfe, "0011011100000");
    sff := resize (sf, sff'high, sff'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);             -- round and wrap
    rewrap ("rounding resize pos sff test", sff, "1");   -- wraps to -8
    sfg := resize (sf, sfg'high, sfg'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);             -- round and wrap
    rewrap ("rounding resize pos sfg test", sfg, "10");  -- wraps to -8
    sfh := resize (sf, sfh'high, sfh'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);             -- round and wrap
    rewrap ("rounding resize pos sfh test", sfh, "011100");
    sfi := resize (sf, sfi'high, sfi'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);             -- round and wrap
    rewrap ("rounding resize pos sfi test", sfi, "0110111");
    sfj := resize (sf, sfj'high, sfj'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);             -- round and wrap
    rewrap ("rounding resize pos sfj test", sfj, "01101110");
    sfk := resize (sf, sfk'high, sfk'low,
                   round_style    => fixed_round,
                   overflow_style => fixed_wrap);             -- round and wrap
    rewrap ("rounding resize pos sfk test", sfk, "011011100000");
    sf   := "0100001";                  -- back to 4.125, test pattern
    -- saturate versions
    sfl  := resize (sf, sfl'high, sfl'low);
    rewrap ("resize sfl test", sfl, "0");
    sfm  := resize (sf, sfm'high, sfm'low);
    rewrap ("resize sfm test", sfm, "01111");
    sfn  := resize (sf, sfn'high, sfn'low);
    rewrap ("resize sfn test", sfn, "011111");
    sfo  := resize (sf, sfo'high, sfo'low);
    rewrap ("resize sfo test", sfo, "0111111");
    sfp  := resize (sf, sfp'high, sfp'low);
    rewrap ("resize sfp test", sfp, "0");
    sfq  := resize (sf, sfq'high, sfq'low);
    rewrap ("resize sfq test", sfq, "011");
    sfr  := resize (sf, sfr'high, sfr'low);
    rewrap ("resize sfr test", sfr, "0111");
    sfs  := resize (sf, sfs'high, sfs'low);
    rewrap ("resize sfs test", sfs, "01111");
    sft  := resize (sf, sft'high, sft'low);
    rewrap ("resize sft test", sft, "011111111");
    sfu  := resize (sf, sfu'high, sfu'low);
    rewrap ("resize sfu test", sfu, "0");
    sfv  := resize (sf, sfv'high, sfv'low);
    rewrap ("resize sfv test", sfv, "01");
    sfw  := resize (sf, sfw'high, sfw'low);
    rewrap ("resize sfw test", sfw, "011");
    sfx  := resize (sf, sfx'high, sfx'low);
    rewrap ("resize sfx test", sfx, "0111111");
    sfy  := resize (sf, sfy'high, sfy'low);
    rewrap ("resize sfy test", sfy, "0");
    sfz  := resize (sf, sfz'high, sfz'low);
    rewrap ("resize sfz test", sfz, "01");
    sfaa := resize (sf, sfaa'high, sfaa'low);
    rewrap ("resize sfaa test", sfaa, "011111");
    sfab := resize (sf, sfab'high, sfab'low);
    rewrap ("resize sfab test", sfab, "0111");
    -- wrap versions
    sfl := resize (sf, sfl'high, sfl'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfl test", sfl, "1");
    sfm := resize (sf, sfm'high, sfm'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfm test", sfm, "10000");
    sfn := resize (sf, sfn'high, sfn'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfn test", sfn, "100001");
    sfo := resize (sf, sfo'high, sfo'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfo test", sfo, "1000010");
    sfp := resize (sf, sfp'high, sfp'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfp test", sfp, "0");
    sfq := resize (sf, sfq'high, sfq'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfq test", sfq, "000");
    sfr := resize (sf, sfr'high, sfr'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfr test", sfr, "0001");
    sfs := resize (sf, sfs'high, sfs'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfs test", sfs, "00010");
    sft := resize (sf, sft'high, sft'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sft test", sft, "000100000");
    sfu := resize (sf, sfu'high, sfu'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfu test", sfu, "0");
    sfv := resize (sf, sfv'high, sfv'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfv test", sfv, "01");
    sfw := resize (sf, sfw'high, sfw'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfw test", sfw, "010");
    sfx := resize (sf, sfx'high, sfx'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfx test", sfx, "0100000");
    sfy := resize (sf, sfy'high, sfy'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfy test", sfy, "1");
    sfz := resize (sf, sfz'high, sfz'low,
                   overflow_style => fixed_wrap,
                   round_style    => fixed_round);
    rewrap ("wrap resize sfz test", sfz, "10");
    sfaa := resize (sf, sfaa'high, sfaa'low,
                    overflow_style => fixed_wrap,
                    round_style    => fixed_round);
    rewrap ("wrap resize sfaa test", sfaa, "100000");
    sfab := resize (sf, sfab'high, sfab'low,
                    overflow_style => fixed_wrap,
                    round_style    => fixed_round);
    rewrap ("wrap resize sfab test", sfab, "0000");
    assert (quiet) report "signed resize test complete" severity note;
    sresizetest_done <= true;
    wait;
  end process sresizetest;

  -- purpose: boundary test
  boundtest : process is
    variable check7uf1, check7uf2, check7uf3 : ufixed7_3;
    variable checkuf                         : ufixed (-1 downto -3);  -- something small
    variable checkuns, checkuns1             : UNSIGNED (2 downto 0);  -- short unsigned
    variable check7sf1, check7sf2, check7sf3 : sfixed7_3;
    variable checksf                         : sfixed (0 downto -3);  -- something small
    variable checks, checks1                 : SIGNED (2 downto 0);  -- short signed
  begin
    wait until start_boundtest;
    check7uf1 := "0000000";             -- 0
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    -- rounding test
    check7uf1 := "0000100";             -- 0.5
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0001100";             -- 1.5
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "010";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0000101";             -- 0.625
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "001";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0000101";             -- 0.625
    checkuns := to_unsigned (arg         => check7uf1,
                             size        => checkuns'length,
                             round_style => fixed_truncate);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(check7uf1) & " no round)",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0001100";             -- 1.5
    checkuns := to_unsigned (arg         => check7uf1,
                             size        => checkuns'length,
                             round_style => fixed_truncate);
    checkuns1 := "001";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    checkuf := "010";                   -- 0.25
    checkuns := to_unsigned (arg         => checkuf,
                             size        => checkuns'length,
                             round_style => fixed_round);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(checkuf) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    checkuf := "100";                   -- 0.5
    checkuns := to_unsigned (arg         => checkuf,
                             size        => checkuns'length,
                             round_style => fixed_round);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(checkuf) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    checkuf := "101";                   -- 0.625
    checkuns := to_unsigned (arg         => checkuf,
                             size        => checkuns'length,
                             round_style => fixed_round);
    checkuns1 := "001";
    report_error ("to_unsigned (" & to_string(checkuf) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    checkuf := "101";                   -- 0.625
    checkuns := to_unsigned (arg         => checkuf,
                             size        => checkuns'length,
                             round_style => fixed_truncate);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(checkuf) & ") no round",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    -- overflow test
    check7uf1 := "0110000";             -- 6
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "110";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0111000";             -- 7
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "111";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0111100";             -- 7.5
    checkuns := to_unsigned (arg            => check7uf1,
                             size           => checkuns'length,
                             round_style    => fixed_truncate,
                             overflow_style => fixed_saturate);
    checkuns1 := "111";
    report_error ("to_unsigned (" & to_string(check7uf1) & ") no round",
                  to_ufixed (checkuns), to_ufixed(checkuns1));

    check7uf1 := "0111100";             -- 7.5
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "111";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));

    check7uf1 := "1000000";             -- 8
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "111";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "1001000";             -- 9
    checkuns  := to_unsigned (check7uf1, checkuns'length);
    checkuns1 := "111";
    report_error ("to_unsigned (" & to_string(check7uf1) & ")",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "0111100";             -- 7.5
    checkuns := to_unsigned (arg             => check7uf1,
                              size           => checkuns'length,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(check7uf1) & "), round, wrap",
                  to_ufixed (checkuns), to_ufixed(checkuns1));

    check7uf1 := "1000000";             -- 8
    checkuns := to_unsigned (arg             => check7uf1,
                              size           => checkuns'length,
                              round_style    => fixed_truncate,
                              overflow_style => fixed_wrap);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(check7uf1) & "), round, wrap",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "1001000";             -- 9
    checkuns := to_unsigned (arg             => check7uf1,
                              size           => checkuns'length,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);
    checkuns1 := "001";
    report_error ("to_unsigned (" & to_string(check7uf1) & "), round, wrap",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "1110000";             -- 14
    checkuns := to_unsigned (arg             => check7uf1,
                              size           => checkuns'length,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);
    checkuns1 := "110";
    report_error ("to_unsigned (" & to_string(check7uf1) & "), round, wrap",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "1110101";             -- 14.625
    checkuns := to_unsigned (arg             => check7uf1,
                              size           => checkuns'length,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);
    checkuns1 := "111";
    report_error ("to_unsigned (" & to_string(check7uf1) & "), round, wrap",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    check7uf1 := "1111101";             -- 15.625
    checkuns := to_unsigned (arg             => check7uf1,
                              size           => checkuns'length,
                              round_style    => fixed_round,
                              overflow_style => fixed_wrap);
    checkuns1 := "000";
    report_error ("to_unsigned (" & to_string(check7uf1) & "), round, wrap",
                  to_ufixed (checkuns), to_ufixed(checkuns1));
    -- SIGNED
    check7sf1 := "0000000";             -- 0
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "000";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    -- rounding test
    check7sf1 := "0000100";             -- 0.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "000";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0001100";             -- 1.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "010";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0000101";             -- 0.625
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "001";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0000101";             -- 0.625
    checks := to_signed (arg         => check7sf1,
                         size        => checks'length,
                         round_style => fixed_truncate);
    checks1 := "000";
    report_error ("to_signed (" & to_string(check7sf1) & " no round)",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0001100";             -- 1.5
    checks := to_signed (arg         => check7sf1,
                         size        => checks'length,
                         round_style => fixed_truncate);
    checks1 := "001";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    -- Try some little numbers
    checksf := "0010";                  -- 0.25
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_round);
    checks1 := "000";
    report_error ("to_signed (" & to_string(checksf) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    checksf := "0100";                  -- 0.5
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_round);
    checks1 := "000";
    report_error ("to_signed (" & to_string(checksf) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    checksf := "0101";                  -- 0.625
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_round);
    checks1 := "001";
    report_error ("to_signed (" & to_string(checksf) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    checksf := "0101";                  -- 0.625
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_truncate);
    checks1 := "000";
    report_error ("to_signed (" & to_string(checksf) & ") no round",
                  to_sfixed (checks), to_sfixed(checks1));
    -- overflow test
    check7sf1 := "0010000";             -- 2
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "010";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0011000";             -- 3
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "011";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0011100";             -- 3.5
    checks := to_signed (arg            => check7sf1,
                         size           => checks'length,
                         round_style    => fixed_truncate,
                         overflow_style => fixed_saturate);
    checks1 := "011";
    report_error ("to_signed (" & to_string(check7sf1) & ") no round",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0011100";             -- 3.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "011";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));

    check7sf1 := "0100000";             -- 4
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "011";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0101000";             -- 5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "011";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0011100";             -- 3.5
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "100";
    report_error ("to_signed (" & to_string(check7sf1) & "), round, wrap",
                  to_sfixed (checks), to_sfixed(checks1));

    check7sf1 := "0100000";             -- 4
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_truncate,
                          overflow_style => fixed_wrap);
    checks1 := "100";
    report_error ("to_signed (" & to_string(check7sf1) & "), round, wrap",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0101000";             -- 5
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "101";
    report_error ("to_signed (" & to_string(check7sf1) & "), round, wrap",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0110000";             -- 6
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "110";
    report_error ("to_signed (" & to_string(check7sf1) & "), round, wrap",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0110101";             -- 6.625
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "111";
    report_error ("to_signed (" & to_string(check7sf1) & "), round, wrap",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "0111101";             -- 7.625
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "000";
    report_error ("to_signed (" & to_string(check7sf1) & "), round, wrap",
                  to_sfixed (checks), to_sfixed(checks1));
    -- negative SIGNED
    check7sf1 := "1111111";             -- -0.125
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "000";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1111100";             -- -0.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "000";
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1111010";             -- -0.75
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "111";                 -- -1
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1110100";             -- -1.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "110";                 -- -2
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1110101";             -- -1.365
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "111";                 -- -1
    report_error ("to_signed (" & to_string(check7sf1) & ")",
                  to_sfixed (checks), to_sfixed(checks1));
    checksf := "1110";                  -- -0.25
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_round);
    checks1 := "000";
    report_error ("to_signed (" & to_string(checksf) & ") "
                  & REAL'image(to_real(checksf)),
                  to_sfixed (checks), to_sfixed(checks1));
    checksf := "1100";                  -- -0.5
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_round);
    checks1 := "000";                   -- because of round overflow
    report_error ("to_signed (" & to_string(checksf) & ") "
                  & REAL'image(to_real(checksf)),
                  to_sfixed (checks), to_sfixed(checks1));
    checksf := "1011";                  -- -0.625
    checks := to_signed (arg         => checksf,
                         size        => checks'length,
                         round_style => fixed_round);
    checks1 := "111";                   -- -1
    report_error ("to_signed (" & to_string(checksf) & ") "
                  & REAL'image(to_real(checksf)),
                  to_sfixed (checks), to_sfixed(checks1));
    -- negative overflow test
    check7sf1 := "1100100";             -- -3.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -3
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1100000";             -- -4
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -4
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1011100";             -- -4.5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -4
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));

    check7sf1 := "1010011";             -- -4.625
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -4
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1011000";             -- -5
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -4
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1010000";             -- -6
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -4
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1010000";             -- -6
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "010";                   -- Wrapped to 2
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1000000";             -- -8
    checks    := to_signed (check7sf1, checks'length);
    checks1   := "100";                 -- -4
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    check7sf1 := "1000000";             -- -8
    checks := to_signed (arg             => check7sf1,
                          size           => checks'length,
                          round_style    => fixed_round,
                          overflow_style => fixed_wrap);
    checks1 := "000";                   -- wrapped to 0
    report_error ("to_signed (" & to_string(check7sf1) & ") "
                  & REAL'image(to_real(check7sf1)),
                  to_sfixed (checks), to_sfixed(checks1));
    assert (quiet) report "boundary test completed" severity note;
    boundtest_done <= true;
    wait;
  end process boundtest;

  -- purpose: Test new rem and mod functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  newremmodtest : process is
    --SIGNAL same_mod_sfixed_result : boolean;
    constant a_ufixed_high : INTEGER := 1;
    constant a_ufixed_low  : INTEGER := -2;
    constant b_ufixed_high : INTEGER := 5;
    constant b_ufixed_low  : INTEGER := 3;

    variable a_ufixed    : ufixed(a_ufixed_high downto a_ufixed_low)   := ('1', others => '0');
    variable b_ufixed    : ufixed(b_ufixed_high downto b_ufixed_low)   := ('1', others => '0');
    variable a_sfixed    : sfixed(a_ufixed_high downto a_ufixed_low)   := ('1', others => '0');
    variable b_sfixed    : sfixed(b_ufixed_high downto b_ufixed_low)   := ('1', others => '0');
    variable afix_signed : SIGNED(a_ufixed_high-a_ufixed_low downto 0) := ('1', others => '0');
    variable bfix_signed : SIGNED(b_ufixed_high-b_ufixed_low downto 0) := ('1', others => '0');
    variable mod_ufixed_result : ufixed(UFixed_high(a_ufixed'high, a_ufixed'low, 'm',
                                                    b_ufixed'high,
                                                    b_ufixed'low) downto 
                                        UFixed_low(a_ufixed'high, a_ufixed'low,
                                                   'm', b_ufixed'high,
                                                   b_ufixed'low));
    variable mod_sfixed_result : sfixed(SFixed_high(a_sfixed'high, a_sfixed'low, 'm', b_sfixed'high, b_sfixed'low) downto
                                        SFixed_low(a_sfixed'high, a_sfixed'low, 'm', b_sfixed'high, b_sfixed'low));
    variable rem_ufixed_result : ufixed(UFixed_high(a_ufixed'high, a_ufixed'low, 'r', b_ufixed'high, b_ufixed'low) downto
                                        UFixed_low(a_ufixed'high, a_ufixed'low, 'r', b_ufixed'high, b_ufixed'low));
    variable rem_sfixed_result : sfixed(SFixed_high(a_sfixed'high, a_sfixed'low, 'r', b_sfixed'high, b_sfixed'low) downto
                                        SFixed_low(a_sfixed'high, a_sfixed'low, 'r', b_sfixed'high, b_sfixed'low));

    variable a_ureal, b_ureal, a_sreal, b_sreal : REAL                                        := 1.0;
    variable mod_ureal_result                   : REAL                                        := 1.0;
    variable mod_sreal_result                   : REAL                                        := 1.0;
    variable rem_ureal_result, rem_sreal_result : REAL                                        := 1.0;
    constant max_bfix_signed_value              : SIGNED(b_ufixed_high-b_ufixed_low downto 0) := ('0', others => '1');
    variable ck7, ck7t                          : ufixed (3 downto -3);
    variable ck8                                : ufixed (3 downto -6);
    variable ck8h                               : ufixed (7 downto -3);
    variable ck9                                : ufixed (7 downto -6);
    variable sck2                               : sfixed (0 downto -1);
    variable sck4, sck4t                        : sfixed (2 downto -1);
    variable ckl                                : ufixed (-2 downto -4);  -- low
    variable ckh                                : ufixed (4 downto 2);  -- high
    variable ckhl : ufixed (ufixed_high (ckh'high, ckh'low, 'm',
                                         ckl'high, ckl'low) downto
                            ufixed_low (ckh'high, ckh'low, 'm',
                                        ckl'high, ckl'low));
    variable cklh : ufixed (ufixed_high (ckl'high, ckl'low, 'm',
                                         ckh'high, ckh'low) downto
                            ufixed_low (ckl'high, ckl'low, 'm',
                                        ckh'high, ckh'low));
  begin
    wait until start_newremmodtest;

    afix_signed := ('1', others => '0');
    bfix_signed := ('1', others => '0');
    while (bfix_signed /= max_bfix_signed_value) loop
      a_ufixed := ufixed(UNSIGNED(afix_signed));
      b_ufixed := ufixed(UNSIGNED(bfix_signed));
      a_sfixed := sfixed((afix_signed));
      b_sfixed := sfixed((bfix_signed));
      a_ureal  := to_real(a_ufixed);
      b_ureal  := to_real(b_ufixed);
      a_sreal  := to_real(a_sfixed);
      b_sreal  := to_real(b_sfixed);

      mod_ufixed_result := a_ufixed mod b_ufixed;
      mod_ureal_result  := a_ureal mod b_ureal;

      mod_sfixed_result := a_sfixed mod b_sfixed;
      mod_sreal_result  := a_sreal mod b_sreal;

      rem_ufixed_result := a_ufixed rem b_ufixed;
      rem_ureal_result  := a_ureal mod b_ureal;

      rem_sfixed_result := a_sfixed rem b_sfixed;
      rem_sreal_result  := sign(a_sreal)*(abs(a_sreal) mod abs(b_sreal));

      report_error ("mod ufixed", mod_ufixed_result,
                    to_ufixed (mod_ureal_result, 10, -10));
      report_error (to_string (a_sfixed) & " (" & REAL'image(a_sreal) & ") " &
                    " mod (s) " &
                    to_string (b_sfixed) & " (" & REAL'image(b_sreal) & ") = "
                    & REAL'image(mod_sreal_result),
                    mod_sfixed_result,
                    to_sfixed (mod_sreal_result, 10, -10));
      report_error ("rem ufixed", rem_ufixed_result,
                    to_ufixed (rem_ureal_result, 10, -10));
      report_error ("rem sfixed", rem_sfixed_result,
                    to_sfixed (rem_sreal_result, 10, -10));

      bfix_signed := bfix_signed+1;
      if bfix_signed = -1 then
        bfix_signed := to_signed(1, bfix_signed'length);  -- skip the 0 because a/0 gives an error
      end if;
    end loop;
    ck7 := "1111111";                   -- saturate
    ck9 := (others => '1');             -- saturate
    ck8 := ck9 mod ck7;
    report_error (to_string (ck9) & " mod " & to_string (ck7), ck8,
                  to_ufixed (to_real(ck9) mod to_real(ck7), 20, -20));
    ck8 := ck7 mod ck9;
    report_error (to_string (ck7) & " mod " & to_string (ck9), ck8,
                  to_ufixed (to_real(ck7) mod to_real(ck9), 20, -20));
    sck2  := "01";                      -- 0.5
    sck4  := "1000";                    -- -4
    sck4t := sck2 mod sck4;
    report_error (to_string(sck2) & " mod " & to_string(sck4),
                  sck4t, to_sfixed (-3.5, 5, -5));
    sck2  := "11";                      -- -0.5
    sck4  := "0111";                    -- 3.5
    sck4t := sck2 mod sck4;
    report_error (to_string(sck2) & " mod " & to_string(sck4),
                  sck4t, to_sfixed (3, 5, -5));
    -- some odd range testing
    ckl  := "010";
    ckh  := "010";
    ckhl := ckh mod ckl;
    report_error (to_string (ckh) & " mod " & to_string (ckl), ckhl,
                  to_ufixed (to_real(ckh) mod to_real(ckl), 20, -20));
    cklh := ckl mod ckh;
    report_error (to_string (ckl) & " mod " & to_string (ckh), cklh,
                  to_ufixed (to_real(ckl) mod to_real(ckh), 20, -20));
    -- A few corner case range test
    ck8 := "0000100000";                -- 0.5
    ck7 := "0001010";                   -- 1.25
    ck9 := resize (ck7 mod ck8, ck9);
    report_error (to_string (ck7) & " mod " & to_string (ck8), ck9,
                  to_ufixed (to_real(ck7) mod to_real(ck8), 20, -20));
    ck8 := "0000000100";                -- 0.0625
    ck7 := "0001010";                   -- 1.25
    ck9 := resize (ck7 mod ck8, ck9);
    report_error (to_string (ck7) & " mod " & to_string (ck8), ck9,
                  to_ufixed (to_real(ck7) mod to_real(ck8), 20, -20));    
    assert (quiet) report "New rem/mod test completed" severity note;
    newremmodtest_done <= true;
    wait;
  end process newremmodtest;

  -- purpose: test the scalb funcitons
  scalbtest : process is
    variable ck7us1 : ufixed (3 downto -3);  -- ufixed
    variable ck7sus1 : ufixed (4 downto -2);  -- scalb (ck7us1, 1)
    variable ck7sus2 : ufixed (2 downto -4);  -- scalb (ck7us1, -1)
    variable ck7s1 : sfixed (3 downto -3);  -- sfixed
    variable ck7ss1 : sfixed (4 downto -2);  -- scalb (ck7us1, 1)
    variable ck7ss2 : sfixed (2 downto -4);  -- scalb (ck7us1, -1)
    variable sind : SIGNED (4 downto 0);  -- signed index
    variable ckreal : REAL;
    variable ckint : INTEGER;
  begin
    wait until start_scalbtest;
    ck7us1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7us1, 1));
    assert ckint = 4
      report "scalb (" & to_string (ck7us1) & ", 1) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7us1, -1));
    assert ckint = 1
      report "scalb (" & to_string (ck7us1) & ", -1) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7us1, 5));
    assert ckint = 64
      report "scalb (" & to_string (ck7us1) & ", 5) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "0010000";                -- 2
    ckreal := to_real (scalb(ck7us1, -5));
    assert ckreal = 0.0625
      report "scalb (" & to_string (ck7us1) & ", -5) = " & real'image(ckreal)
      severity error;
    ck7us1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7us1, 0));
    assert ckint = 2
      report "scalb (" & to_string (ck7us1) & ", 0) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "0010000";                -- 2
    ck7sus1 := scalb(ck7us1, 1);        -- typed correctly
    assert ck7sus1 = 4
      report "scalb (" & to_string (ck7us1) & ", 1) = " & to_string (ck7sus1)
      severity error;
    ck7us1 := "0010000";                -- 2
    ck7sus2 := scalb(ck7us1, -1);        -- typed correctly
    assert ck7sus1 = 4
      report "scalb (" & to_string (ck7us1) & ", -1) = " & to_string (ck7sus2)
      severity error;
    ck7us1 := "0011000";                -- 3
    sind := "00001";
    ckint := to_integer (scalb(ck7us1, sind));
    assert ckint = 6
      report "scalb (" & to_string (ck7us1) & ", 1) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "0110000";                -- 6
    sind := "11111";
    ckint := to_integer (scalb(ck7us1, sind));
    assert ckint = 3
      report "scalb (" & to_string (ck7us1) & ", -1) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "1111111";                -- 15.875
    sind := "01111";
    ckint := to_integer (scalb(ck7us1, sind));
    assert ckint = 520192
      report "scalb (" & to_string (ck7us1) & ", 15) = " & INTEGER'image(ckint)
      severity error;
    ck7us1 := "1000000";                -- 8
    sind := "11000";
    ckreal := to_real (scalb(ck7us1, sind));
    assert ckreal = 0.03125
      report "scalb (" & to_string (ck7us1) & ", -8) = " & real'image(ckreal)
      severity error;
    -- signed
    ck7s1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7s1, 1));
    assert ckint = 4
      report "scalb (s" & to_string (ck7s1) & ", 1) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7s1, -1));
    assert ckint = 1
      report "scalb (s" & to_string (ck7s1) & ", -1) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7s1, 5));
    assert ckint = 64
      report "scalb (s" & to_string (ck7s1) & ", 5) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "0010000";                -- 2
    ckreal := to_real (scalb(ck7s1, -5));
    assert ckreal = 0.0625
      report "scalb (s" & to_string (ck7s1) & ", -5) = " & real'image(ckreal)
      severity error;
    ck7s1 := "0010000";                -- 2
    ckint := to_integer (scalb(ck7s1, 0));
    assert ckint = 2
      report "scalb (s" & to_string (ck7s1) & ", 0) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "0010000";                -- 2
    ck7ss1 := scalb(ck7s1, 1);        -- typed correctly
    assert ck7ss1 = 4
      report "scalb (s" & to_string (ck7s1) & ", 1) = " & to_string (ck7ss1)
      severity error;
    ck7s1 := "0010000";                -- 2
    ck7ss2 := scalb(ck7s1, -1);        -- typed correctly
    assert ck7ss1 = 4
      report "scalb (s" & to_string (ck7s1) & ", -1) = " & to_string (ck7ss2)
      severity error;
    ck7s1 := "0011000";                -- 3
    sind := "00001";
    ckint := to_integer (scalb(ck7s1, sind));
    assert ckint = 6
      report "scalb (s" & to_string (ck7s1) & ", 1) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "0110000";                -- 6
    sind := "11111";
    ckint := to_integer (scalb(ck7s1, sind));
    assert ckint = 3
      report "scalb (s" & to_string (ck7s1) & ", -1) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "1000000";                -- -8
    sind := "01111";
    ckint := to_integer (scalb(ck7s1, sind));
    assert ckint = -262144
      report "scalb (s" & to_string (ck7s1) & ", 15) = " & INTEGER'image(ckint)
      severity error;
    ck7s1 := "1000000";                -- -8
    sind := "11000";                    -- -8
    ckreal := to_real (scalb(ck7s1, sind));
    assert ckreal = -0.03125
      report "scalb (s" & to_string (ck7s1) & ", -8) = " & real'image(ckreal)
      severity error;
    -- is_negative
    ck7s1 := "1000000";                 -- -8
    assert Is_Negative (ck7s1)
      report "Is_Negative (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "1100000";                 -- -4
    assert Is_Negative (ck7s1)
      report "Is_Negative (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0100000";                 -- 4
    assert not Is_Negative (ck7s1)
      report "Is_Negative (" & to_string (ck7s1) & ") = true"
      severity error;
    ck7s1 := "0000000";                 -- 0
    assert not Is_Negative (ck7s1)
      report "Is_Negative (" & to_string (ck7s1) & ") = true"
      severity error;
    assert (quiet) report "Scalb test completed" severity note;
    scalbtest_done <= true;
    wait;
  end process scalbtest;

  -- purpose: test ?= ?/=, ?> ... and to_xu01 test
  quesequal : process is
    variable ck7us1, ck7us2, ck7us3 : ufixed (3 downto -3);  -- ufixed
    variable ck6us1 : ufixed (2 downto -3);
    variable ck7s1, ck7s2, ck7s3 : sfixed (3 downto -3);  -- sfixed
    variable ck6s1 : sfixed (2 downto -3);
    variable s1 : STD_ULOGIC;           -- result
  begin
    wait until start_quesequaltest;
    ck7us1 := "0000000";                -- 0.0
    ck7us2 := "0000000";                -- 0.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";                -- 0.0
    ck7us2 := "0001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000H00L";                -- 1.0
    ck7us2 := "0001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "0001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "000100H";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "000100X";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "U00100H";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'U'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "L00-00U";
    ck7us2 := "H001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'U'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "Z00100H";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "100100W";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-00H00L";
    ck7us2 := "X001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-00H00L";
    ck7us2 := "-001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "X00H00L";
    ck7us2 := "X001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "U00H00L";
    ck7us2 := "U001000";                -- 1.0
    s1 := ck7us1 ?= ck7us2;
    assert s1 = 'U'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-------";
    ck7us2 := "Z01XUWH";
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-------";
    ck7us2 := "-------";
    s1 := ck7us1 ?= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
   -- ?/=
    ck7us1 := "0000000";                -- 0.0
    ck7us2 := "0000000";                -- 0.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";                -- 0.0
    ck7us2 := "0001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000H00L";                -- 1.0
    ck7us2 := "0001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "0001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "000100H";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "000100X";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "U00100H";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = 'U'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "Z00100H";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "000-00L";
    ck7us2 := "100100W";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-00H00L";
    ck7us2 := "X001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-00H00L";
    ck7us2 := "-001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "X00H00L";
    ck7us2 := "X001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "U00H00L";
    ck7us2 := "U001000";                -- 1.0
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = 'U'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-------";
    ck7us2 := "Z01XUWH";
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "-------";
    ck7us2 := "-------";
    s1 := ck7us1 ?/= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?/= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    -- ?<
    ck7us1 := "0000000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000H000";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100L";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100U";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100X";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100X";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100W";
    s1 := ck7us1 ?< ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - error from ?< here" severity note;
      ck7us1 := "0000000";
      ck7us2 := "000100-";
      s1 := ck7us1 ?< ck7us2;
      assert s1 = 'X'
        report to_string(ck7us1) & " ?< " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- ?<=
    ck7us1 := "0000000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000H000";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100L";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100U";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100X";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100X";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100W";
    s1 := ck7us1 ?<= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?<= error here" severity note;
      ck7us1 := "0000000";
      ck7us2 := "000100-";
      s1 := ck7us1 ?<= ck7us2;
      assert s1 = 'X'
        report to_string(ck7us1) & " ?<= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- ?>
    ck7us1 := "0000000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000H000";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100L";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100U";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100X";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100X";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "000100W";
    s1 := ck7us1 ?> ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?> error here" severity note;
      ck7us1 := "0000000";
      ck7us2 := "000100-";
      s1 := ck7us1 ?> ck7us2;
      assert s1 = 'X'
        report to_string(ck7us1) & " ?> " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- ?>=
    ck7us1 := "0000000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0000000";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0000000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = '0'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "0001000";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck7us2 := "000H000";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us2 := "0000000";
    ck7us1 := "000100L";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = '1'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us2 := "0000000";
    ck7us1 := "000100U";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us2 := "0000000";
    ck7us1 := "000100X";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us2 := "0000000";
    ck7us1 := "000100X";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us2 := "0000000";
    ck7us1 := "000100W";
    s1 := ck7us1 ?>= ck7us2;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?>= error here" severity note;
      ck7us1 := "0000000";
      ck7us2 := "000100-";
      s1 := ck7us1 ?>= ck7us2;
      assert s1 = 'X'
        report to_string(ck7us1) & " ?>= " & to_string(ck7us2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- Now we do it all over again, this time for Signed fixed point numbers!
    ck7s1 := "0000000";                -- 0.0
    ck7s2 := "0000000";                -- 0.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";                -- 0.0
    ck7s2 := "0001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000H00L";                -- 1.0
    ck7s2 := "0001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "0001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "000100H";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "000100X";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "U00100H";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = 'U'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "Z00100H";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "100100W";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-00H00L";
    ck7s2 := "X001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-00H00L";
    ck7s2 := "-001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "X00H00L";
    ck7s2 := "X001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "U00H00L";
    ck7s2 := "U001000";                -- 1.0
    s1 := ck7s1 ?= ck7s2;
    assert s1 = 'U'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-------";
    ck7s2 := "Z01XUWH";
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-------";
    ck7s2 := "-------";
    s1 := ck7s1 ?= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
   -- ?/=
    ck7s1 := "0000000";                -- 0.0
    ck7s2 := "0000000";                -- 0.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";                -- 0.0
    ck7s2 := "0001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000H00L";                -- 1.0
    ck7s2 := "0001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "0001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "000100H";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "000100X";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "U00100H";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = 'U'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "Z00100H";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "000-00L";
    ck7s2 := "100100W";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-00H00L";
    ck7s2 := "X001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-00H00L";
    ck7s2 := "-001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "X00H00L";
    ck7s2 := "X001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "U00H00L";
    ck7s2 := "U001000";                -- 1.0
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = 'U'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-------";
    ck7s2 := "Z01XUWH";
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "-------";
    ck7s2 := "-------";
    s1 := ck7s1 ?/= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?/= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    -- ?<
    ck7s1 := "0000000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "1001000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "1001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000H000";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100L";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100U";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100X";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100X";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100W";
    s1 := ck7s1 ?< ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - error from ?< here" severity note;
      ck7s1 := "0000000";
      ck7s2 := "000100-";
      s1 := ck7s1 ?< ck7s2;
      assert s1 = 'X'
        report to_string(ck7s1) & " ?< s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- ?<=
    ck7s1 := "0000000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "1001000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "1001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000H000";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100L";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100U";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100X";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100X";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100W";
    s1 := ck7s1 ?<= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?<= error here" severity note;
      ck7s1 := "0000000";
      ck7s2 := "000100-";
      s1 := ck7s1 ?<= ck7s2;
      assert s1 = 'X'
        report to_string(ck7s1) & " ?<= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- ?>
    ck7s1 := "0000000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "1001000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "1001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000H000";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100L";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100U";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100X";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100X";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "000100W";
    s1 := ck7s1 ?> ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?> error here" severity note;
      ck7s1 := "0000000";
      ck7s2 := "000100-";
      s1 := ck7s1 ?> ck7s2;
      assert s1 = 'X'
        report to_string(ck7s1) & " ?> s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
        severity error;     
    end if;
    -- ?>=
    ck7s1 := "0000000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0000000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0000000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "1001000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "1001000";
    ck7s2 := "0001000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '0'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck7s2 := "000H000";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s2 := "0000000";
    ck7s1 := "000100L";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = '1'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s2 := "0000000";
    ck7s1 := "000100U";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s2 := "0000000";
    ck7s1 := "000100X";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s2 := "0000000";
    ck7s1 := "000100X";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s2 := "0000000";
    ck7s1 := "000100W";
    s1 := ck7s1 ?>= ck7s2;
    assert s1 = 'X'
      report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
      severity error;
    if not quiet then
      report "Expect a - from ?>= error here" severity note;
      ck7s1 := "0000000";
      ck7s2 := "000100-";
      s1 := ck7s1 ?>= ck7s2;
      assert s1 = 'X'
        report to_string(ck7s1) & " ?>= s" & to_string(ck7s2) & " = " & STD_ULOGIC'image(s1)
        severity error;
    end if;
    -- Do some test with different widths
    ck7us1 := "0001000";
    ck6us1 := "001000";
    s1 := ck7us1 ?= ck6us1;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck6us1) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "0001000";
    ck6us1 := "L01000";
    s1 := ck7us1 ?= ck6us1;
    assert s1 = '1'
      report to_string(ck7us1) & " ?= " & to_string(ck6us1) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7us1 := "X001000";
    ck6us1 := "-01000";
    s1 := ck7us1 ?= ck6us1;
    assert s1 = 'X'
      report to_string(ck7us1) & " ?= " & to_string(ck6us1) & " = " & STD_ULOGIC'image(s1)
      severity error;
    -- signed

    ck7s1 := "0001000";
    ck6s1 := "001000";
    s1 := ck7s1 ?= ck6s1;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck6s1) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "0001000";
    ck6s1 := "L01000";
    s1 := ck7s1 ?= ck6s1;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck6s1) & " = " & STD_ULOGIC'image(s1)
      severity error;
    ck7s1 := "1101000";
    ck6s1 := "H01000";
    s1 := ck7s1 ?= ck6s1;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck6s1) & " = " & STD_ULOGIC'image(s1)
      severity error;
    -- Because the "-" will be sign extended, it will cancel out the "X".
    ck7s1 := "X001000";
    ck6s1 := "-01000";
    s1 := ck7s1 ?= ck6s1;
    assert s1 = '1'
      report to_string(ck7s1) & " ?= s" & to_string(ck6s1) & " = " & STD_ULOGIC'image(s1)
      severity error;












    
    --------------------------------------------------------------------------
    -- test for to_UX01 and to_X01Z
    --------------------------------------------------------------------------
    -- to_UX01
    ck7us1 := "0101010";                -- 5.25
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0101010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert not Is_X (ck7us1)
      report "Is_X (" & to_string (ck7us1) & ") = true"
      severity error;
    ck7us1 := "01010HL";                -- 5.25
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0101010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert not Is_X (ck7us1)
      report "Is_X (" & to_string (ck7us1) & ") = true"
      severity error;
    ck7us1 := "0-010HL";
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0Z010HL";
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0W010HL";
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0X010HL";
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0U010HL";
    ck7us2 := to_UX01 (ck7us1);
    ck7us3 := "0U01010";
    report_error ("to_ux01 (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    -- to_X01Z
    ck7us1 := "0101010";                -- 5.25
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0101010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert not Is_X (ck7us1)
      report "Is_X (" & to_string (ck7us1) & ") = true"
      severity error;
    ck7us1 := "01010HL";                -- 5.25
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0101010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert not Is_X (ck7us1)
      report "Is_X (" & to_string (ck7us1) & ") = true"
      severity error;
    ck7us1 := "0-010HL";
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0Z010HL";
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0Z01010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0W010HL";
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0X010HL";
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    ck7us1 := "0U010HL";
    ck7us2 := to_X01Z (ck7us1);
    ck7us3 := "0X01010";
    report_error ("to_X01Z (" & to_string(ck7us1) & ")", to_slv(ck7us2), to_slv(ck7us3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7us1) & ") = false"
      severity error;
    -- signed to_UX01
    ck7s1 := "0101010";                -- 5.25
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0101010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert not Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = true"
      severity error;
    ck7s1 := "01010HL";                -- 5.25
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0101010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert not Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = true"
      severity error;
    ck7s1 := "0-010HL";
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0Z010HL";
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0W010HL";
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0X010HL";
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0U010HL";
    ck7s2 := to_UX01 (ck7s1);
    ck7s3 := "0U01010";
    report_error ("to_UX01 (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    -- to_X01Z
    ck7s1 := "0101010";                -- 5.25
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0101010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert not Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = true"
      severity error;
    ck7s1 := "01010HL";                -- 5.25
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0101010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert not Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = true"
      severity error;
    ck7s1 := "0-010HL";
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0Z010HL";
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0Z01010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0W010HL";
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0X010HL";
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;
    ck7s1 := "0U010HL";
    ck7s2 := to_X01Z (ck7s1);
    ck7s3 := "0X01010";
    report_error ("to_X01Z (s" & to_string(ck7s1) & ")", to_slv(ck7s2), to_slv(ck7s3));
    assert Is_X (ck7s1)
      report "Is_X (" & to_string (ck7s1) & ") = false"
      severity error;

    assert (quiet) report "?= test test completed" severity note;
    quesequtest_done <= true;
    wait;
  end process quesequal;

  fileio : process
    constant filename    : STRING := "textfile";
    file testfile        : TEXT;
    variable file_status : FILE_OPEN_STATUS;
    variable MyLine      : LINE;
    variable slv         : sfixed(1 downto -2);
    variable sulv        : ufixed(1 downto -2);
    variable hslv        : ufixed (7 downto -8);         -- hex
    variable oslv        : ufixed (2 downto -9);         -- octal
    variable hsslv       : sfixed (7 downto -8);         -- hex
    variable osslv       : sfixed (2 downto -9);         -- octal
    variable ok          : BOOLEAN;
  begin
    wait until start_fileiotest;
    -- Write the test file
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => write_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for write with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    Myline := new STRING'("0001");
    writeline (testfile, Myline);
    Myline := new STRING'(" 0010");
    writeline (testfile, Myline);
    Myline := new STRING'("        0011");
    writeline (testfile, Myline);
    Myline := new STRING'("0100");
    writeline (testfile, Myline);
    Myline := new STRING'("");                           -- blank LINE
    writeline (testfile, Myline);
    Myline := new STRING'("0101 ");
    writeline (testfile, Myline);
    Myline := new STRING'(" ");                          -- just a space
    writeline (testfile, Myline);
    Myline := new STRING'(HT & "0110 ");
    writeline (testfile, Myline);
    Myline := new STRING'(CHARACTER'val(160) & "0111");  -- nbsp
    writeline (testfile, Myline);
    Myline := new STRING'("%000");
    writeline (testfile, Myline);
    Myline := new STRING'("0%00");
    writeline (testfile, Myline);
    Myline := new STRING'("000%");
    writeline (testfile, Myline);
    Myline := new STRING'("111");                        -- short STRING
    writeline (testfile, Myline);
    Myline := new STRING'("00111");                      -- big STRING
    writeline (testfile, Myline);
    Myline := new STRING'("UXWZ");
    writeline (testfile, Myline);
    Myline := new STRING'("HL-Z");
    writeline (testfile, Myline);
    Myline := new STRING'("1010 0101");
    writeline (testfile, Myline);
    Myline := new STRING'("10111101");
    writeline (testfile, Myline);
    Myline := new STRING'("1111");
    writeline (testfile, Myline);
    file_close (testfile);
    -- close it, and open it for reading.
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0001")
      report "Read SLV 1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0010")
      report "Read SLV 2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0011")
      report "Read SLV 3 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0100")
      report "Read SLV 4 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, slv);
      assert (to_slv(slv) = "UUUU")
        report "Read SLV blank returned " & to_string(slv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0101")
      report "Read SLV 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, slv);
      assert (to_slv(slv) = "UUUU")
        report "Read SLV space returned " & to_string(slv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0110")
      report "Read SLV 6 HT returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0111")
      report "Read SLV 7 NBSP returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 read errors here" severity note;
      read(MyLine, slv);
      assert (to_slv(slv) = "UUUU")
        report "Read SLV %000 returned " & to_string(slv) severity error;
      readline(testfile, MyLine);
      read(MyLine, slv);
      assert (to_slv(slv) = "UUUU")
        report "Read SLV 0%00 returned " & to_string(slv) severity error;
      readline(testfile, MyLine);
      read(MyLine, slv);
      assert (to_slv(slv) = "UUUU")
        report "Read SLV 000% returned " & to_string(slv) severity error;
      readline(testfile, MyLine);
      read(MyLine, slv);
      assert (to_slv(slv) = "UUUU")
        report "Read SLV short returned " & to_string(slv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "0011")
      report "Read SLV 7 extra returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "UXWZ")
      report "Read SLV X1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "HL-Z")
      report "Read SLV X2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "1010")
      report "Read SLV A returned " & to_string(slv) severity error;
    read(MyLine, slv);
    assert (to_slv(slv) = "0101")
      report "Read SLV A 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "1011")
      report "Read SLV B returned " & to_string(slv) severity error;
    read(MyLine, slv);
    assert (to_slv(slv) = "1101")
      report "Read SLV B D returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (to_slv(slv) = "1111")
      report "Read SLV F returned " & to_string(slv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- std_ulogic_vector
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0001")
      report "Read SULV 1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0010")
      report "Read SULV 2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0011")
      report "Read SULV 3 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0100")
      report "Read SULV 4 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, sulv);
      assert (to_slv(sulv) = "UUUU")
        report "Read SULV blank returned " & to_string(sulv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0101")
      report "Read SULV 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, sulv);
      assert (to_slv(sulv) = "UUUU")
        report "Read SULV space returned " & to_string(sulv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0110")
      report "Read SULV 6 HT returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0111")
      report "Read SULV 7 NBSP returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 read errors here" severity note;
      read(MyLine, sulv);
      assert (to_slv(sulv) = "UUUU")
        report "Read SULV %000 returned " & to_string(sulv) severity error;
      readline(testfile, MyLine);
      read(MyLine, sulv);
      assert (to_slv(sulv) = "UUUU")
        report "Read SULV 0%00 returned " & to_string(sulv) severity error;
      readline(testfile, MyLine);
      read(MyLine, sulv);
      assert (to_slv(sulv) = "UUUU")
        report "Read SULV 000% returned " & to_string(sulv) severity error;
      readline(testfile, MyLine);
      read(MyLine, sulv);
      assert (to_slv(sulv) = "UUUU")
        report "Read SULV short returned " & to_string(sulv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0011")
      report "Read SULV 7 extra returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "UXWZ")
      report "Read SULV X1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "HL-Z")
      report "Read SULV X2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "1010")
      report "Read SULV A returned " & to_string(sulv) severity error;
    read(MyLine, sulv);
    assert (to_slv(sulv) = "0101")
      report "Read SULV A 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "1011")
      report "Read SULV B returned " & to_string(sulv) severity error;
    read(MyLine, sulv);
    assert (to_slv(sulv) = "1101")
      report "Read SULV B D returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (to_slv(sulv) = "1111")
      report "Read SULV F returned " & to_string(sulv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- std_logic_vector - read with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 1 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0001")
      report "Read SLV 1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0010")
      report "Read SLV 2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 3 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0011")
      report "Read SLV 3 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 4 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0100")
      report "Read SLV 4 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV blank returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UUUU")
      report "Read SLV blank returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0101")
      report "Read SLV 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UUUU")
      report "Read SLV space returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 6 HT returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0110")
      report "Read SLV 6 HT returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 7 NBSP returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0111")
      report "Read SLV 7 NBSP returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UUUU")
      report "Read SLV %000 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UUUU")
      report "Read SLV 0%00 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UUUU")
      report "Read SLV 000% returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UUUU")
      report "Read SLV short returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 7 extra returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0011")
      report "Read SLV 7 extra returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV X1 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "UXWZ")
      report "Read SLV X1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV X2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "HL-Z")
      report "Read SLV X2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV A returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "1010")
      report "Read SLV A returned " & to_string(slv) severity error;
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV A 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "0101")
      report "Read SLV A 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV B returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "1011")
      report "Read SLV B returned " & to_string(slv) severity error;
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV B D returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "1101")
      report "Read SLV B D returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV F returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(slv) = "1111")
      report "Read SLV F returned " & to_string(slv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- std_ulogic_vector read with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 1 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0001")
      report "Read SULV 1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0010")
      report "Read SULV 2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 3 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0011")
      report "Read SULV 3 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 4 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0100")
      report "Read SULV 4 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV blank returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UUUU")
      report "Read SULV blank returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0101")
      report "Read SULV 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UUUU")
      report "Read SULV space returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 6 HT returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0110")
      report "Read SULV 6 HT returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 7 NBSP returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0111")
      report "Read SULV 7 NBSP returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UUUU")
      report "Read SULV 000% returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UUUU")
      report "Read SULV 0%00 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UUUU")
      report "Read SULV 000% returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UUUU")
      report "Read SULV short returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 7 extra returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0011")
      report "Read SULV 7 extra returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV X1 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "UXWZ")
      report "Read SULV X1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV X2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "HL-Z")
      report "Read SULV X2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV A returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "1010")
      report "Read SULV A returned " & to_string(sulv) severity error;
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV A 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "0101")
      report "Read SULV A 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV B returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "1011")
      report "Read SULV B returned " & to_string(sulv) severity error;
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV B D returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "1101")
      report "Read SULV B D returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV F returned " & BOOLEAN'image(ok)
      severity error;
    assert (to_slv(sulv) = "1111")
      report "Read SULV F returned " & to_string(sulv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- hex read
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000000000001")
      report "hRead SLV 1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000000010000")
      report "hRead SLV 2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000000010001")
      report "hRead SLV 3 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000100000000")
      report "hRead SLV 4 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a hread error here" severity note;
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "hRead SLV blank returned " & to_string(hslv) severity error;
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000100000001")
      report "Hread SLV 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a hread error here" severity note;
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000100010000")
      report "Hread HSLV 6 HT returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000100010001")
      report "Hread HSLV 7 NBSP returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 hread errors here" severity note;
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV %000 returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV 0%000 returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV 000% returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV short returned " & to_string(hslv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000000010001")
      report "Hread HSLV 7 extra returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expecte 2 HREAD character errors here" severity note;
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV X1 returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV X2 returned " & to_string(hslv) severity error;
    else
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0001000000010000")
      report "Hread HSLV A returned " & to_string(hslv) severity error;
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0000000100000001")
      report "Hread HSLV A 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0001000000010001")
      report "Hread HSLV B returned " & to_string(hslv) severity error;
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0001000100000001")
      report "Hread HSLV B D returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (to_slv(hslv) = "0001000100010001")
      report "Hread HSLV F returned " & to_string(hslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- octal read
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000000000001")
      report "oread SLV 1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000000001000")
      report "oread SLV 2 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000000001001")
      report "oread SLV 3 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000001000000")
      report "oread SLV 4 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a oread error here" severity note;
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "oread SLV blank returned " & to_string(oslv) severity error;
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000001000001")
      report "Oread SLV 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a oread error here" severity note;
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000001001000")
      report "Oread OSLV 6 HT returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000001001001")
      report "Oread OSLV 7 NBSP returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 oread errors here" severity note;
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV %000 returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV 0%00 returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV 000% returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV short returned " & to_string(oslv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000000001001")
      report "Oread OSLV 7 extra returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expecte 2 OREAD character errors here" severity note;
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV X1 returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (to_slv(oslv) = "UUUUUUUUUUUU")
        report "Oread OSLV X2 returned " & to_string(oslv) severity error;
    else
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "001000001000")
      report "Oread OSLV A returned " & to_string(oslv) severity error;
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "000001000001")
      report "Oread OSLV A 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "001000001001")
      report "Oread OSLV B returned " & to_string(oslv) severity error;
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "001001000001")
      report "Oread OSLV B D returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (to_slv(oslv) = "001001001001")
      report "Oread OSLV F returned " & to_string(oslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
-- report "Got Here!" severity failure;
    -- hex read with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 1 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000000000001")
      report "hRead SLV 1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000000010000")
      report "hRead SLV 2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 3 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000000010001")
      report "hRead SLV 3 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000100000000")
      report "hRead SLV 4 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV blank returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "hRead SLV blank returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 5 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000100000001")
      report "Hread SLV 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV space returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV space returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 6 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000100010000")
      report "Hread HSLV 6 HT returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 7 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000100010001")
      report "Hread HSLV 7 NBSP returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread %000 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV %000 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread 0%00 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV 0%00 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread bad 000% returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "hread bad 000% returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread bad char 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "hread bad short returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 7 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000000010001")
      report "Hread HSLV 7 extra returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV X1 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV X1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV X2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV X2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV A returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0001000000010000")
      report "Hread HSLV A returned " & to_string(hslv) severity error;
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV A 5 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0000000100000001")
      report "Hread HSLV A 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV B returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0001000000010001")
      report "Hread HSLV B returned " & to_string(hslv) severity error;
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV B D returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0001000100000001")
      report "Hread HSLV B D returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV F returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hslv) = "0001000100010001")
      report "Hread HSLV F returned " & to_string(hslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- Octal read with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 1 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000000000001")
      report "oread SLV 1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000000001000")
      report "oread SLV 2 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 3 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000000001001")
      report "oread SLV 3 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 4 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000001000000")
      report "oread SLV 4 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV blank returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "oread SLV blank returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 5 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000001000001")
      report "Oread SLV 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV space returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV space returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 6 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000001001000")
      report "Oread OSLV 6 HT returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 6 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000001001001")
      report "Oread OSLV 7 NBSP returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 1 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV 1 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 2 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV 2 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 4 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV 4 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread short returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV short returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 7 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000000001001")
      report "Oread OSLV 7 extra returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV X1 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV X1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV X2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "UUUUUUUUUUUU")
      report "Oread OSLV X2 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV A returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "001000001000")
      report "Oread OSLV A returned " & to_string(oslv) severity error;
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV A 5 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "000001000001")
      report "Oread OSLV A 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV B returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "001000001001")
      report "Oread OSLV B returned " & to_string(oslv) severity error;
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV B D returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "001001000001")
      report "Oread OSLV B D returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV F returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(oslv) = "001001001001")
      report "Oread OSLV F returned " & to_string(oslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- signed hex and octal test
    -- hex read
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000000000001")
      report "hRead SLV 1 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000000010000")
      report "hRead SLV 2 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000000010001")
      report "hRead SLV 3 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000100000000")
      report "hRead SLV 4 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a hread error here" severity note;
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "hRead SLV blank returned " & to_string(hsslv) severity error;
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000100000001")
      report "Hread SLV 5 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a hread error here" severity note;
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV space returned " & to_string(hsslv) severity error;
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000100010000")
      report "Hread HSSLV 6 HT returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000100010001")
      report "Hread HSSLV 7 NBSP returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 hread errors here" severity note;
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV %000 returned " & to_string(hsslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV 0%000 returned " & to_string(hsslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV 000% returned " & to_string(hsslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV short returned " & to_string(hsslv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000000010001")
      report "Hread HSSLV 7 extra returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expecte 2 HREAD character errors here" severity note;
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV X1 returned " & to_string(hsslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hsslv);
      assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
        report "Hread HSSLV X2 returned " & to_string(hsslv) severity error;
    else
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0001000000010000")
      report "Hread HSSLV A returned " & to_string(hsslv) severity error;
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0000000100000001")
      report "Hread HSSLV A 5 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0001000000010001")
      report "Hread HSSLV B returned " & to_string(hsslv) severity error;
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0001000100000001")
      report "Hread HSSLV B D returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv);
    assert (to_slv(hsslv) = "0001000100010001")
      report "Hread HSSLV F returned " & to_string(hsslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- octal read
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000000000001")
      report "oread SLV 1 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000000001000")
      report "oread SLV 2 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000000001001")
      report "oread SLV 3 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000001000000")
      report "oread SLV 4 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a oread error here" severity note;
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "oread SLV blank returned " & to_string(osslv) severity error;
    end if;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000001000001")
      report "Oread SLV 5 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a oread error here" severity note;
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV space returned " & to_string(osslv) severity error;
    end if;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000001001000")
      report "Oread OSSLV 6 HT returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000001001001")
      report "Oread OSSLV 7 NBSP returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 oread errors here" severity note;
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV %000 returned " & to_string(osslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV 0%00 returned " & to_string(osslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV 000% returned " & to_string(osslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV short returned " & to_string(osslv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000000001001")
      report "Oread OSSLV 7 extra returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expecte 2 OREAD character errors here" severity note;
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV X1 returned " & to_string(osslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, osslv);
      assert (to_slv(osslv) = "UUUUUUUUUUUU")
        report "Oread OSSLV X2 returned " & to_string(osslv) severity error;
    else
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "001000001000")
      report "Oread OSSLV A returned " & to_string(osslv) severity error;
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "000001000001")
      report "Oread OSSLV A 5 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "001000001001")
      report "Oread OSSLV B returned " & to_string(osslv) severity error;
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "001001000001")
      report "Oread OSSLV B D returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv);
    assert (to_slv(osslv) = "001001001001")
      report "Oread OSSLV F returned " & to_string(osslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
-- report "Got Here!" severity failure;
    -- hex read with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 1 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000000000001")
      report "hRead SLV 1 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000000010000")
      report "hRead SLV 2 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 3 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000000010001")
      report "hRead SLV 3 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000100000000")
      report "hRead SLV 4 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread SLV blank returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "hRead SLV blank returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 5 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000100000001")
      report "Hread SLV 5 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread SLV space returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSSLV space returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 6 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000100010000")
      report "Hread HSSLV 6 HT returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 7 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000100010001")
      report "Hread HSSLV 7 NBSP returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread %000 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSSLV %000 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread 0%00 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSSLV 0%00 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread bad 000% returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "hread bad 000% returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread bad char 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "hread bad short returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV 7 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000000010001")
      report "Hread HSSLV 7 extra returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread SLV X1 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSSLV X1 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (not ok) report "hread SLV X2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "UUUUUUUUUUUUUUUU")
      report "Hread HSSLV X2 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV A returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0001000000010000")
      report "Hread HSSLV A returned " & to_string(hsslv) severity error;
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV A 5 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0000000100000001")
      report "Hread HSSLV A 5 returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV B returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0001000000010001")
      report "Hread HSSLV B returned " & to_string(hsslv) severity error;
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV B D returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0001000100000001")
      report "Hread HSSLV B D returned " & to_string(hsslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hsslv, ok);
    assert (ok) report "hread SLV F returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (to_slv(hsslv) = "0001000100010001")
      report "Hread HSSLV F returned " & to_string(hsslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- Octal read with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 1 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000000000001")
      report "oread SLV 1 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000000001000")
      report "oread SLV 2 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 3 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000000001001")
      report "oread SLV 3 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 4 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000001000000")
      report "oread SLV 4 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV blank returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "oread SLV blank returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 5 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000001000001")
      report "Oread SLV 5 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV space returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV space returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 6 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000001001000")
      report "Oread OSSLV 6 HT returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 6 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000001001001")
      report "Oread OSSLV 7 NBSP returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV 1 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV 1 % returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV 2 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV 2 % returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV 4 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV 4 % returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread short returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV short returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV 7 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000000001001")
      report "Oread OSSLV 7 extra returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV X1 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV X1 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (not Ok) report "oread OSSLV X2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "UUUUUUUUUUUU")
      report "Oread OSSLV X2 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV A returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "001000001000")
      report "Oread OSSLV A returned " & to_string(osslv) severity error;
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV A 5 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "000001000001")
      report "Oread OSSLV A 5 returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV B returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "001000001001")
      report "Oread OSSLV B returned " & to_string(osslv) severity error;
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV B D returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "001001000001")
      report "Oread OSSLV B D returned " & to_string(osslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, osslv, ok);
    assert (Ok) report "oread OSSLV F returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (to_slv(osslv) = "001001001001")
      report "Oread OSSLV F returned " & to_string(osslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    assert quiet report "File IO test completed" severity note;
    fileiotest_done <= true;
    wait;
  end process fileio;
end architecture testbench;
