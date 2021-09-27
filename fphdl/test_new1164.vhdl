-----------------------------------------------------------------------------
-- Title      : Test routines for the new functions in std_logic_1164
--              for vhdl-200x-ft
-- check of to_slv and to_bv aliases
-- check of all to_string functions
-- check of all read and write functions
-- check of all std_ulogic and boolean functions
-- check of the implicit minimum and maximum functions
-- Last Modified: $Date: 2007-09-11 15:31:23-04 $
-- RCS ID: $Id: test_new1164.vhdl,v 1.2 2007-09-11 15:31:23-04 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org)
-----------------------------------------------------------------------------
entity test_new1164 is
  generic (
    quiet : BOOLEAN := false);          -- run quietly
end entity test_new1164;

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_textio.all;          -- Should be empty
use std.textio.all;
architecture testbench of test_new1164 is  -- purpose: reports an error

  procedure report_error (
    constant errmes   :    STRING;      -- error message
    actual            : in STRING;      -- data from algorithm
    constant expected :    STRING)  is  -- reference data
  begin  -- function report_error
    assert (actual = expected)
      report "TEST_NEW1164: " & errmes & LF
      & "Actual   " & actual & " /= " & LF
      & "Expected " & expected
      severity error;
    return;
  end procedure report_error;
  signal start_readtest, readtest_done : BOOLEAN := false;  -- start reading test
  signal start_stest, stest_done       : BOOLEAN := false;  -- start reading test

  signal start_testalias, testalias_done    : BOOLEAN := false;
  signal start_booltest, booltest_done      : BOOLEAN := false;
  signal start_minmaxtest, minmaxtest_done  : BOOLEAN := false;
  signal start_qestionequ, questionequ_done : BOOLEAN := false;  -- test ?= operators  
begin
  main : process
  begin
    start_testalias  <= true;
    wait until testalias_done;
    start_stest      <= true;
    wait until stest_done;
    start_readtest   <= true;
    wait until readtest_done;
    -- boolean test
    start_booltest   <= true;
    wait until booltest_done;
    start_minmaxtest <= true;
    wait until minmaxtest_done;
    start_qestionequ <= true;
    wait until questionequ_done;
    report "test_new1164 complete" severity note;
    wait;
  end process main;

  testalias : process
    variable su1, su2   : STD_ULOGIC;
    variable s1, s2     : STD_LOGIC;
    variable b1, b2     : BIT;
    variable bv1, bv2   : BIT_VECTOR (5 downto 0);
    variable sv1, sv2   : STD_LOGIC_VECTOR (5 downto 0);
    variable sulv1, sulv2 : STD_ULOGIC_VECTOR (5 downto 0);
  begin
    wait until start_testalias;
    -- test the new aliases
    bv1 := "101010";
    sv1 := to_slv (bv1);
    sv2 := "101010";
    assert (sv1 = sv2) report "to_slv(bv) not working " &
      to_string (bv1) & " /= " & to_string (sv1) severity error;
    sulv1 := "101101";
    sv1  := to_slv (sulv1);
    sv2  := "101101";
    assert (sv1 = sv2) report "to_slv(sulv) not working " &
      to_string (sulv1) & " /= " & to_string (sv1) severity error;
    bv1  := "010101";
    sulv1 := to_sulv (bv1);
    sulv2 := "010101";
    assert (sulv1 = sulv2) report "to_sulv(bv) not working " &
      to_string (bv1) & " /= " & to_string (sulv1) severity error;
    sv1  := "110011";
    sulv1 := to_sulv (sv1);
    sulv2 := "110011";
    assert (sulv1 = sulv2) report "to_sulv(slv) not working " &
      to_string (sv1) & " /= " & to_string (sulv1) severity error;
    sv1 := "111000";
    bv1 := to_bv (sv1);
    bv2 := "111000";
    assert (bv1 = bv2) report "to_bv(slv) not working " &
      to_string (sv1) & " /= " & to_string (bv1) severity error;
    sulv1 := "000111";
    bv1  := to_bv (sulv1);
    bv2  := "000111";
    assert (bv1 = bv2) report "to_bv(sulv) not working " &
      to_string (sulv1) & " /= " & to_string (bv1) severity error;
    assert (quiet) report "std_logic_1164 alias test done" severity note;
    testalias_done <= true;
    wait;
  end process testalias;

  -- purpose: Checks basic string functions
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  Test_process : process is
    variable checknum              : STD_ULOGIC_VECTOR (23 downto 0);  -- checknum
    variable checknum1             : STD_ULOGIC_VECTOR (24 downto 0);  -- checknum
    variable checknum2             : STD_ULOGIC_VECTOR (25 downto 0);  -- checknum
    variable checknum3             : STD_ULOGIC_VECTOR (26 downto 0);  -- checknum
    variable checksl               : STD_LOGIC;             -- STD_LOGIC
    variable checksu               : STD_ULOGIC;            -- std_ulogic
    variable checkstr, checkstrx   : STRING (1 to 24);
    variable checkstrb             : STRING (24 downto 1);  -- downto string
    variable checkstr1, checkstrx1 : STRING (1 to 25);
    variable checkstr2, checkstrx2 : STRING (1 to 26);
    variable checkstr3, checkstrx3 : STRING (1 to 27);
    variable checknums             : STD_LOGIC_VECTOR (23 downto 0);  -- std_logic_vector number
    variable checkst1              : STRING (1 to 1);       -- 1 char
    variable checkst2              : STRING (1 to 2);       -- 2 char
    variable checkst3              : STRING (1 to 3);       -- 3 char
    variable checkstr4             : STRING (1 to 4);       -- 4 char
    variable checkstr5             : STRING (1 to 5);       -- 5 char
    variable checkstr6             : STRING (1 to 6);       -- 6 char
    variable checkstr7             : STRING (1 to 7);       -- 7 char
    variable checkstr8             : STRING (1 to 8);       -- 7 char
    variable checkstr9             : STRING (1 to 9);       -- 7 char
  begin
    wait until start_stest;
    for checksl in STD_ULOGIC loop
      checkst1 := to_string(checksl);
      assert ("'" & checkst1 & "'" = STD_ULOGIC'image(checksl))
        report "std_logic to_string (" & STD_ULOGIC'image(checksl)
        & ") /= " & checkst1
        severity error;
    end loop;
    for checksu in STD_ULOGIC loop
      checkst1 := to_string(checksu);
      assert ("'" & checkst1 & "'" = STRING(STD_ULOGIC'image(checksu)))
        report "std_ulogic to_string (" & STD_ULOGIC'image(checksu)
        & ") /= " & checkst1
        severity error;
    end loop;
    checknum := "000000000000000000000000";
    checkstr := to_string (checknum);
    report_error ("First string test", checkstr,
                  "000000000000000000000000");
    checknum := "000000000000000000000011";
    checkstr := to_string (checknum);
    report_error ("right string test", checkstr,
                  "000000000000000000000011");
    checknum := "011000000000000000000000";
    checkstr := to_string (checknum);
    report_error ("left string test", checkstr,
                  "011000000000000000000000");
    checknum := "000000000000UX01ZWLH-000";
    checkstr := to_string (checknum);
    report_error ("MVL string test", checkstr,
                  "000000000000UX01ZWLH-000");
    checknum := "000000000000000000000011";
    checkstr := justify (to_string (checknum), left, 0);
    report_error ("string left justify 0", checkstr,
                  "000000000000000000000011");
    checknum  := "000000000000000000000011";
    checkstr1 := justify (to_string (checknum), left, 25);
    report_error ("string left justify 25", checkstr1,
                  "000000000000000000000011 ");
    checknum  := "000000000000000000000011";
    checkstr1 := justify (to_string (checknum), right, 25);
    report_error ("string right justify 25", checkstr1,
                  " 000000000000000000000011");
    checknum := "000000000000000000000011";
    checkstr := justify (to_string (checknum), right, 0);
    report_error ("string right justify 0", checkstr,
                  "000000000000000000000011");
    checknum := "000000000000000000000000";
    checkstr := to_bstring (checknum);
    report_error ("to_bstring test", checkstr,
                  "000000000000000000000000");
    checknums := "000000000000000000000000";
    checkstr  := to_string (checknums);
    report_error ("First string test", checkstr,
                  "000000000000000000000000");
    checknums := "000000000000000000000011";
    checkstr  := to_string (checknums);
    report_error ("right string test", checkstr,
                  "000000000000000000000011");
    checknums := "011000000000000000000000";
    checkstr  := to_string (checknums);
    report_error ("left string test", checkstr,
                  "011000000000000000000000");
    checknums := "000000000000UX01ZWLH-000";
    checkstr  := to_string (checknums);
    report_error ("MVL string test", checkstr,
                  "000000000000UX01ZWLH-000");
    checknums := "000000000000000000000011";
    checkstr  := to_string (checknums);
    report_error ("string left justify 0", checkstr,
                  "000000000000000000000011");
    checknums := "000000000000000000000011";
    checkstr1 := justify (to_string (checknums), left, 25);
    report_error ("string left justify 25", checkstr1,
                  "000000000000000000000011 ");
    checknums := "000000000000000000000011";
    checkstr1 := justify (to_string (checknums), right, 25);
    report_error ("string right justify 25", checkstr1,
                  " 000000000000000000000011");
    checknums := "000000000000000000000011";
    checkstr  := justify (to_string (checknums), right, 0);
    report_error ("string right justify 0", checkstr,
                  "000000000000000000000011");
    checknums := "000000000000000000000000";
    checkstr  := to_bstring (checknums);
    report_error ("to_bstring test", checkstr,
                  "000000000000000000000000");
    -- Check the Octal version
    checknum  := "000000000000000000000011";
    checkstr8 := to_ostring (checknum);
    report_error ("First octal test", checkstr8,
                  "00000003");
    checknum  := "111110101100011010001000";
    checkstr8 := to_ostring (checknum);
    report_error ("First octal test", checkstr8,
                  "76543210");
    checknum  := "001010011100101110000111";
    checkstr8 := to_ostring (checknum);
    report_error ("First octal test", checkstr8,
                  "12345607");
    checknum  := "00U00X00-X0000Z00W00L00H";
    checkstr8 := to_ostring (checknum);
    report_error ("unknown hole octal test", checkstr8,
                  "XXXXXX01");
    checknum  := "UUUXXX---ZZZWWWLLLHHHZZZ";
    checkstr8 := to_ostring (checknum);
    report_error ("unknown octal test", checkstr8,
                  "XXXZX07Z");
    -- to_ostring padding test
    checknum1 := "0000000000000000000000011";
    checkstr9 := to_ostring (checknum1);
    report_error ("Octal padding test 1", checkstr9,
                  "000000003");
    checknum2 := "11111110101100011010001000";
    checkstr9 := to_ostring (checknum2);
    report_error ("Octal padding test 2", checkstr9,
                  "376543210");
    checknum1 := "1001010011100101110000111";
    checkstr9 := to_ostring (checknum1);
    report_error ("Octal padding test 3", checkstr9,
                  "112345607");
    checknum1 := "Z001010011100101110000111";
    checkstr9 := to_ostring (checknum1);
    report_error ("Octal Z padding test 1", checkstr9,
                  "Z12345607");
    checknum2 := "ZZ001010011100101110000111";
    checkstr9 := to_ostring (checknum2);
    report_error ("Octal Z padding test 2", checkstr9,
                  "Z12345607");
    checknums := "100000000000000000000011";
    checkstr8 := to_ostring (checknums);
    report_error ("Octal std_logic_vector test", checkstr8,
                  "40000003");

    -- to_hstring test
    checknum  := "000000000000000000000011";
    checkstr6 := to_hstring (checknum);
    report_error ("First hex test", checkstr6,
                  "000003");
    checknum  := "010101000011001000010000";
    checkstr6 := to_hstring (checknum);
    report_error ("First hex number test", checkstr6,
                  "543210");
    checknum  := "101110101001100001110110";
    checkstr6 := to_hstring (checknum);
    report_error ("second hex number test", checkstr6,
                  "BA9876");
    checknum  := "111111101101110010111010";
    checkstr6 := to_hstring (checknum);
    report_error ("3 hex letter test", checkstr6,
                  "FEDCBA");
    checknum  := "001010011100101110000111";
    checkstr6 := to_hstring (checknum);
    report_error ("hex octal test", checkstr6,
                  "29CB87");
    checknum  := "U000X000-000Z000W000LHHH";
    checkstr6 := to_hstring (checknum);
    report_error ("unknown hole hex test", checkstr6,
                  "XXXXX7");
    checknum  := "ZZZZHHHHLLLL00LLHH11ZZZZ";
    checkstr6 := to_hstring (checknum);
    report_error ("ZH hex test", checkstr6,
                  "ZF00FZ");
    checknum1 := "0000000000000000000000011";
    checkstr7 := to_hstring (checknum1);
    report_error ("Hex padding test 1", checkstr7,
                  "0000003");
    checknum2 := "01000000000000000000000011";
    checkstr7 := to_hstring (checknum2);
    report_error ("Hex padding test 2", checkstr7,
                  "1000003");
    checknum3 := "101000000000000000000000011";
    checkstr7 := to_hstring (checknum3);
    report_error ("Hex padding test 3", checkstr7,
                  "5000003");
    checknum3 := "UX-000000000000000000000011";
    checkstr7 := to_hstring (checknum3);
    report_error ("Hex padding test 4", checkstr7,
                  "X000003");
    checknum3 := "ZZZ000000000000000000000011";
    checkstr7 := to_hstring (checknum3);
    report_error ("Hex padding Z test 1", checkstr7,
                  "Z000003");
    checknums := "100000000000000000000011";
    checkstr6 := to_hstring (checknums);
    report_error ("std_logic_vector hex test", checkstr6,
                  "800003");

    assert (quiet) report "std_logic_1164 to_string test done" severity note;
    stest_done <= true;                 -- start reading test

    wait;

  end process Test_process;

  -- purpose: test the read routines
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  read_test : process is
    constant rstring    : STRING := "110010101011";  -- constant string
    constant rstringh   : STRING := "CAB";           -- constant string
    constant rstringo   : STRING := "6253";          -- constant string
    constant rstringd   : STRING := "3243";          -- constant string
    constant rstringn   : STRING := "-853";          -- constant string
    constant bstring1   : STRING := "";              -- empty string
    constant bstring2   : STRING := "11*111*1111*";  -- illegal characters
    constant bstring3   : STRING := "11 111 1111";   -- space characters
    constant bstring4   : STRING := " 11 ";          -- space padding
    variable checknum   : STD_ULOGIC_VECTOR (11 downto 0);  -- std_ulogic_vector
    variable checknums  : STD_LOGIC_VECTOR (11 downto 0);   -- std_logic_vector
    variable checknums2 : STD_LOGIC_VECTOR (12 downto 0);   -- std_logic_vector
    variable l          : LINE;         -- line variable
    variable checkbool  : BOOLEAN;      -- check boolean
  begin  -- process read_test
    wait until start_readtest;
    -- test the READ routines
    L := new STRING'(rstring);
    read (L, checknum);
    report_error ("Error in binary Read",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    -- bread aliases
    L := new STRING'(rstring);
    bread (L, checknum);
    report_error ("Error in binary bRead",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    checknum := (others => '-');
    L        := new STRING'(rstringh);
    hread (L, checknum);
    report_error ("Error in hex read",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    checknum := (others => '-');
    L        := new STRING'(rstringo);
    oread (L, checknum);
    report_error ("Error in octal read",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    L := new STRING'(rstring);
    read (L, checknums);
    report_error ("Error in binary Read",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    L := new STRING'(rstring);
    bread (L, checknums);
    report_error ("Error in binary bRead",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    checknums := (others => '-');
    L         := new STRING'(rstringh);
    hread (L, checknums);
    report_error ("Error in hex read",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    checknums := (others => '-');
    L         := new STRING'(rstringo);
    oread (L, checknums);
    report_error ("Error in octal read",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    -- read with boolean checks
    L        := new STRING'(rstring);
    checknum := (others => '-');
    read (L, checknum, checkbool);
    assert (checkbool) report "TEST_STRING: Read reported error condition"
      severity error;
    report_error ("Error in binary Read",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    L        := new STRING'(rstring);
    checknum := (others => '-');
    bread (L, checknum, checkbool);
    assert (checkbool) report "TEST_STRING: bRead reported error condition"
      severity error;
    report_error ("Error in binary bRead",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    checknum := (others => '-');
    L        := new STRING'(rstringh);
    hread (L, checknum, checkbool);
    assert (checkbool) report "TEST_STRING: hRead reported error condition"
      severity error;
    report_error ("Error in hex read",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    checknum := (others => '-');
    L        := new STRING'(rstringo);
    oread (L, checknum, checkbool);
    assert (checkbool) report "TEST_STRING: oRead reported error condition"
      severity error;
    report_error ("Error in std_ulogic_vector octal read",
                  to_string(checknum),
                  "110010101011");
    deallocate (L);
    checknums := (others => '-');
    L         := new STRING'(rstring);
    read (L, checknums, checkbool);
    assert (checkbool) report "TEST_STRING: Read reported error condition"
      severity error;
    report_error ("Error in binary Read",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    checknums := (others => '-');
    L         := new STRING'(rstring);
    bread (L, checknums, checkbool);
    assert (checkbool) report "TEST_STRING: bRead reported error condition"
      severity error;
    report_error ("Error in binary bRead",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    checknums := (others => '-');
    L         := new STRING'(rstringh);
    hread (L, checknums, checkbool);
    assert (checkbool) report "TEST_STRING: hRead reported error condition"
      severity error;
    report_error ("Error in hex read",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    checknums := (others => '-');
    L         := new STRING'(rstringo);
    oread (L, checknums, checkbool);
    assert (checkbool) report "TEST_STRING: oRead reported error condition"
      severity error;
    report_error ("Error in std_logic_vector octal read",
                  to_string(checknums),
                  "110010101011");
    deallocate (L);
    L        := null;
    checknum := "110010101011";
    write (L, checknum);
    report_error ("Error in std_ulogic_vector write",
                  L.all,
                  "110010101011");
    deallocate (L);
    L        := null;
    checknum := "110010101011";
    bwrite (L, checknum);
    report_error ("Error in std_ulogic_vector bwrite",
                  L.all,
                  "110010101011");
    deallocate (L);
    L        := null;
    checknum := "110010101011";
    hwrite (L, checknum);
    report_error ("Error in std_ulogic_vector hwrite",
                  L.all,
                  rstringh);
    deallocate (L);
    L        := null;
    checknum := "110010101011";
    owrite (L, checknum);
    report_error ("Error in std_ulogic_vector owrite",
                  L.all,
                  rstringo);
    deallocate (L);
    L         := null;
    checknums := "110010101011";
    write (L, checknums);
    report_error ("Error in std_logic_vector write",
                  L.all,
                  "110010101011");
    deallocate (L);
    L         := null;
    checknums := "110010101011";
    bwrite (L, checknums);
    report_error ("Error in std_logic_vector bwrite",
                  L.all,
                  "110010101011");
    deallocate (L);
    L         := null;
    checknums := "110010101011";
    hwrite (L, checknums);
    report_error ("Error in std_logic_vector hwrite",
                  L.all,
                  rstringh);
    deallocate (L);
    L         := null;
    checknums := "110010101011";
    owrite (L, checknums);
    report_error ("Error in std_logic_vector owrite",
                  L.all,
                  rstringo);
    deallocate (L);

    -- Verify read error conditions
    -- read with boolean checks
    L        := new STRING'(bstring1);
    checknum := (others => '-');
    read (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: Read unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring1);
    checknum := (others => '-');
    hread (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: hRead unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring1);
    checknum := (others => '-');
    oread (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: oRead unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring1);
    checknums := (others => '-');
    read (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: Read unreported error condition"
      severity error;
    
    deallocate (L);
    L         := new STRING'(bstring1);
    checknums := (others => '-');
    hread (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: hRead unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring1);
    checknums := (others => '-');
    oread (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: oRead unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring2);
    checknum := (others => '-');
    read (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: Read2 unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring2);
    checknum := (others => '-');
    hread (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: hRead2 unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring2);
    checknum := (others => '-');
    oread (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: oRead2 unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring2);
    checknums := (others => '-');
    read (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: Read2 unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring2);
    checknums := (others => '-');
    hread (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: hRead2 unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring2);
    checknums := (others => '-');
    oread (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: oRead2 unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring3);
    checknum := (others => '-');
    read (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: Read3 unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring3);
    checknum := (others => '-');
    hread (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: hRead3 unreported error condition"
      severity error;
    deallocate (L);
    L        := new STRING'(bstring3);
    checknum := (others => '-');
    oread (L, checknum, checkbool);
    assert (not checkbool)
      report "TEST_STRING: oRead3 unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring3);
    checknums := (others => '-');
    read (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: Read3 unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring3);
    checknums := (others => '-');
    hread (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: hRead3 unreported error condition"
      severity error;
    deallocate (L);
    L         := new STRING'(bstring3);
    checknums := (others => '-');
    oread (L, checknums, checkbool);
    assert (not checkbool)
      report "TEST_STRING: oRead3 unreported error condition"
      severity error;
    deallocate (L);

    assert (quiet) report "std_logic_1164 read/write test done" severity note;
    readtest_done <= true;
    wait;
  end process read_test;

  -- purpose: boolean and std_ulogic test
  booltest : process is
    variable b1, b2   : STD_ULOGIC;
    variable bl1, bl2 : STD_LOGIC;
    variable bo1, bo2 : BOOLEAN;
  begin  -- process booltest
    wait until start_booltest;
    -- and
--    b1  := '0';
--    bo1 := false;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '0'))
--      report "std_ulogic and boolean " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '1'))
--      report "std_ulogic and boolean " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '0'))
--      report "std_ulogic and boolean " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '1'))
--      report "std_ulogic and boolean " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := false;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '0'))
--      report "boolean and std_ulogic " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '1'))
--      report "boolean and std_ulogic " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '0'))
--      report "boolean and std_ulogic " & STD_ULOGIC'image(b1) &
--      " and " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '1')) report "boolean and std_ulogic "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := false;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '0')) report "boolean and std_ulogic "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := false;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '0')) report "std_ulogic and boolean "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := true;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '1')) report "boolean and std_ulogic "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := true;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '1')) report "std_ulogic and boolean "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    bl1 := 'X';
--    bo1 := false;
--    b2  := bo1 and bl1;
--    assert (b2 = (bl1 and '0')) report "boolean and std_logic "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    bl1 := 'X';
--    bo1 := false;
--    b2  := bl1 and bo1;
--    assert (b2 = (bl1 and '0')) report "std_logic and boolean "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'L';
--    bo1 := true;
--    b2  := bo1 and b1;
--    assert (b2 = (b1 and '1')) report "boolean and std_ulogic "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'L';
--    bo1 := true;
--    b2  := b1 and bo1;
--    assert (b2 = (b1 and '1')) report "std_ulogic and boolean "
--      & STD_ULOGIC'image(b1) & " and " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
---- or
--    b1  := '0';
--    bo1 := false;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '0'))
--      report "std_ulogic or boolean " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '0'))
--      report "std_ulogic or boolean " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '1'))
--      report "std_ulogic or boolean " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '1'))
--      report "std_ulogic or boolean " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := false;
--    b2  := bo1 or b1;
--    assert (b2 = (b1 or '0'))
--      report "boolean or std_ulogic " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := bo1 or b1;
--    assert (b2 = (b1 or '0'))
--      report "boolean or std_ulogic " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := bo1 or b1;
--    assert (b2 = (b1 or '1'))
--      report "boolean or std_ulogic " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := bo1 or b1;
--    assert (b2 = (b1 or '1'))
--      report "boolean or std_ulogic " & STD_ULOGIC'image(b1) &
--      " or " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := 'U';
--    bo1 := false;
--    b2  := bo1 or b1;
--    assert (b2 = (to_x01(b1) or '0')) report "boolean or std_ulogic "
--      & STD_ULOGIC'image(b1) & " or " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'W';
--    bo1 := false;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '0')) report "std_ulogic or boolean "
--      & STD_ULOGIC'image(b1) & " or " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'Z';
--    bo1 := true;
--    b2  := bo1 or b1;
--    assert (b2 = (b1 or '1')) report "boolean or std_ulogic "
--      & STD_ULOGIC'image(b1) & " or " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := true;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '1')) report "std_ulogic or boolean "
--      & STD_ULOGIC'image(b1) & " or " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'H';
--    bo1 := false;
--    b2  := bo1 or b1;
--    assert (b2 = (b1 or '0')) report "boolean or std_ulogic "
--      & STD_ULOGIC'image(b1) & " or " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'H';
--    bo1 := false;
--    b2  := b1 or bo1;
--    assert (b2 = (b1 or '0')) report "std_ulogic or boolean "
--      & STD_ULOGIC'image(b1) & " or " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
---- xor
--    b1  := '0';
--    bo1 := false;
--    b2  := b1 xor bo1;
--    assert (b2 = (b1 xor '0'))
--      report "std_ulogic xor boolean " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := b1 xor bo1;
--    assert (b2 = (b1 xor '0'))
--      report "std_ulogic xor boolean " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := b1 xor bo1;
--    assert (b2 = (b1 xor '1'))
--      report "std_ulogic xor boolean " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := b1 xor bo1;
--    assert (b2 = (b1 xor '1'))
--      report "std_ulogic xor boolean " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := false;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '0'))
--      report "boolean xor std_ulogic " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '0'))
--      report "boolean xor std_ulogic " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '1'))
--      report "boolean xor std_ulogic " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '1'))
--      report "boolean xor std_ulogic " & STD_ULOGIC'image(b1) &
--      " xor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := 'X';
--    bo1 := false;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '0')) report "boolean xor std_ulogic "
--      & STD_ULOGIC'image(b1) & " xor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'U';
--    bo1 := false;
--    b2  := b1 xor bo1;
--    assert (b2 = (to_x01(b1) xor '0')) report "std_ulogic xor boolean "
--      & STD_ULOGIC'image(b1) & " xor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := '-';
--    bo1 := true;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '1')) report "boolean xor std_ulogic "
--      & STD_ULOGIC'image(b1) & " xor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'W';
--    bo1 := true;
--    b2  := b1 xor bo1;
--    assert (b2 = (b1 xor '1')) report "std_ulogic xor boolean "
--      & STD_ULOGIC'image(b1) & " xor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'H';
--    bo1 := true;
--    b2  := bo1 xor b1;
--    assert (b2 = (b1 xor '1')) report "boolean xor std_ulogic "
--      & STD_ULOGIC'image(b1) & " xor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'L';
--    bo1 := true;
--    b2  := b1 xor bo1;
--    assert (b2 = (b1 xor '1')) report "std_ulogic xor boolean "
--      & STD_ULOGIC'image(b1) & " xor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    -- nand
--    b1  := '0';
--    bo1 := false;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '0'))
--      report "std_ulogic nand boolean " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '0'))
--      report "std_ulogic nand boolean " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '1'))
--      report "std_ulogic nand boolean " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '1'))
--      report "std_ulogic nand boolean " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := false;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '0'))
--      report "boolean nand std_ulogic " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '0'))
--      report "boolean nand std_ulogic " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '1'))
--      report "boolean nand std_ulogic " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '1'))
--      report "boolean nand std_ulogic " & STD_ULOGIC'image(b1) &
--      " nand " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := 'X';
--    bo1 := false;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '0')) report "boolean nand std_ulogic "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := false;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '0')) report "std_ulogic nand boolean "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := true;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '1')) report "boolean nand std_ulogic "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := true;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '1')) report "std_ulogic nand boolean "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    bl1 := 'X';
--    bo1 := false;
--    b2  := bo1 nand bl1;
--    assert (b2 = (bl1 nand '0')) report "boolean nand std_logic "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    bl1 := 'X';
--    bo1 := false;
--    b2  := bl1 nand bo1;
--    assert (b2 = (bl1 nand '0')) report "std_logic nand boolean "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'L';
--    bo1 := true;
--    b2  := bo1 nand b1;
--    assert (b2 = (b1 nand '1')) report "boolean nand std_ulogic "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'L';
--    bo1 := true;
--    b2  := b1 nand bo1;
--    assert (b2 = (b1 nand '1')) report "std_ulogic nand boolean "
--      & STD_ULOGIC'image(b1) & " nand " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    -- nor
--    b1  := '0';
--    bo1 := false;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '0'))
--      report "std_ulogic nor boolean " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '0'))
--      report "std_ulogic nor boolean " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '1'))
--      report "std_ulogic nor boolean " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '1'))
--      report "std_ulogic nor boolean " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := false;
--    b2  := bo1 nor b1;
--    assert (b2 = (b1 nor '0'))
--      report "boolean nor std_ulogic " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := bo1 nor b1;
--    assert (b2 = (b1 nor '0'))
--      report "boolean nor std_ulogic " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := bo1 nor b1;
--    assert (b2 = (b1 nor '1'))
--      report "boolean nor std_ulogic " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := bo1 nor b1;
--    assert (b2 = (b1 nor '1'))
--      report "boolean nor std_ulogic " & STD_ULOGIC'image(b1) &
--      " nor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := 'U';
--    bo1 := false;
--    b2  := bo1 nor b1;
--    assert (b2 = (to_x01(b1) nor '0')) report "boolean nor std_ulogic "
--      & STD_ULOGIC'image(b1) & " nor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'W';
--    bo1 := false;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '0')) report "std_ulogic nor boolean "
--      & STD_ULOGIC'image(b1) & " nor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'Z';
--    bo1 := true;
--    b2  := bo1 nor b1;
--    assert (b2 = (b1 nor '1')) report "boolean nor std_ulogic "
--      & STD_ULOGIC'image(b1) & " nor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'X';
--    bo1 := true;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '1')) report "std_ulogic nor boolean "
--      & STD_ULOGIC'image(b1) & " nor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'H';
--    bo1 := false;
--    b2  := bo1 nor b1;
--    assert (b2 = (b1 nor '0')) report "boolean nor std_ulogic "
--      & STD_ULOGIC'image(b1) & " nor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'H';
--    bo1 := false;
--    b2  := b1 nor bo1;
--    assert (b2 = (b1 nor '0')) report "std_ulogic nor boolean "
--      & STD_ULOGIC'image(b1) & " nor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    -- xnor
--    b1  := '0';
--    bo1 := false;
--    b2  := b1 xnor bo1;
--    assert (b2 = (b1 xnor '0'))
--      report "std_ulogic xnor boolean " & STD_ULOGIC'image(b1) &
--      " xnor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := false;
--    b2  := b1 xnor bo1;
--    assert (b2 = (b1 xnor '0'))
--      report "std_ulogic xnor boolean " & STD_ULOGIC'image(b1) &
--      " xnor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '0';
--    bo1 := true;
--    b2  := b1 xnor bo1;
--    assert (b2 = (b1 xnor '1'))
--      report "std_ulogic xnor boolean " & STD_ULOGIC'image(b1) &
--      " xnor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := '1';
--    bo1 := true;
--    b2  := b1 xnor bo1;
--    assert (b2 = (b1 xnor '1'))
--      report "std_ulogic xnor boolean " & STD_ULOGIC'image(b1) &
--      " xnor " & BOOLEAN'image(bo1) & " /= " & STD_ULOGIC'image(b2)
--      severity error;
--    b1  := 'X';
--    bo1 := false;
--    b2  := bo1 xnor b1;
--    assert (b2 = (b1 xnor '0')) report "boolean xnor std_ulogic "
--      & STD_ULOGIC'image(b1) & " xnor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'U';
--    bo1 := false;
--    b2  := b1 xnor bo1;
--    assert (b2 = (to_x01(b1) xnor '0')) report "std_ulogic xnor boolean "
--      & STD_ULOGIC'image(b1) & " xnor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := '-';
--    bo1 := true;
--    b2  := bo1 xnor b1;
--    assert (b2 = (b1 xnor '1')) report "boolean xnor std_ulogic "
--      & STD_ULOGIC'image(b1) & " xnor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'W';
--    bo1 := true;
--    b2  := b1 xnor bo1;
--    assert (b2 = (b1 xnor '1')) report "std_ulogic xnor boolean "
--      & STD_ULOGIC'image(b1) & " xnor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'H';
--    bo1 := true;
--    b2  := bo1 xnor b1;
--    assert (b2 = (b1 xnor '1')) report "boolean xnor std_ulogic "
--      & STD_ULOGIC'image(b1) & " xnor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
--    b1  := 'L';
--    bo1 := true;
--    b2  := b1 xnor bo1;
--    assert (b2 = (b1 xnor '1')) report "std_ulogic xnor boolean "
--      & STD_ULOGIC'image(b1) & " xnor " & BOOLEAN'image(bo1) & " /= "
--      & STD_ULOGIC'image(b2) severity error;
    -- Test the "??" boolean function
    for b1 in STD_ULOGIC loop
      bo1 := ?? (b1);
      assert (bo1 = (b1 = '1' or b1 = 'H'))
        report "??(" & to_string(b1) & ") = " & to_string(bo1) severity error;
    end loop;
    for bl1 in STD_LOGIC loop
      bo1 := ?? (bl1);
      assert (bo1 = (bl1 = '1' or bl1 = 'H'))
        report "??(" & to_string(bl1) & ") = " & to_string(bo1) severity error;
    end loop;
    assert (quiet) report "std_logic_1164 boolean test done" severity note;
    booltest_done <= true;
    wait;
  end process booltest;

  -- purpose: test of the implicit minimum and maximum functions for
  -- std_logic_1164
  minmaxtest : process is
    variable slv1, slv2, slv3 : STD_LOGIC_VECTOR (3 downto 0);
    variable sulv1, sulv2, sulv3 : STD_ULOGIC_VECTOR (3 downto 0);
    variable slv9, slv8, slv7 : STD_LOGIC_VECTOR (4 downto 0);
    variable sulv9, sulv8, sulv7 : STD_ULOGIC_VECTOR (4 downto 0);
    variable b1, b2, b3       : STD_ULOGIC;
  begin
    wait until start_minmaxtest;
    slv1 := "0001";
    slv2 := "0010";
    assert (slv2 > slv1) report to_string(slv2) & " > " & to_string(slv1)
      & " miscompare" severity error;
    assert not (slv2 < slv1) report to_string(slv2) & " < " & to_string(slv1)
      & " miscompare" severity error;
    assert (slv2 >= slv1) report to_string(slv2) & " >= " & to_string(slv1)
      & " miscompare" severity error;
    assert not (slv2 <= slv1) report to_string(slv2) & " <= " & to_string(slv1)
      & " miscompare" severity error;
    assert not (slv2 = slv1) report to_string(slv2) & " = " & to_string(slv1)
      & " miscompare" severity error;
    assert (slv2 /= slv1) report to_string(slv2) & " /= " & to_string(slv1)
      & " miscompare" severity error;
    slv3 := maximum (slv1, slv2);
    assert ((slv3 = slv2)) report "max (" & to_string(slv1) & ", "
      & to_string(slv2) & ") = " & to_string (slv3) severity error;
    slv3 := maximum (slv2, slv1);
    assert ((slv3 = slv2)) report "max (" & to_string(slv2) & ", "
      & to_string(slv1) & ") = " & to_string (slv3) severity error;
    
    slv3 := minimum (slv1, slv2);
    assert ((slv3 = slv1)) report "min (" & to_string(slv1) & ", "
      & to_string(slv2) & ") = " & to_string (slv3) severity error;
    slv3 := minimum (slv2, slv1);
    assert ((slv3 = slv1)) report "min (" & to_string(slv2) & ", "
      & to_string(slv1) & ") = " & to_string (slv3) severity error;
    -- It should be noted that the behavior of the min and
    -- max routine will be different depending on the "numeric_std_unsigned"
    -- package, which replaced the compare (<) operator.
    -- You will find the opposite logic in "test_nuns.vhd"
    slv9 := "00111";
    slv3 := "0110";
    assert (slv9 < slv3) report to_string(slv9) & " < " & to_string(slv3)
      & " miscompare" severity error;
    assert (slv3 > slv9) report to_string(slv3) & " > " & to_string(slv9)
      & " miscompare" severity error;
    slv1 := maximum (slv9, slv3);
    assert (slv1 = slv3) report "max (" & to_string(slv9) & ", "
      & to_string(slv3) & ") = " & to_string (slv1) severity error;
    slv1 := maximum (slv3, slv9);
    assert (slv1 = slv3) report "max (" & to_string(slv3) & ", "
      & to_string(slv9) & ") = " & to_string (slv1) severity error;
    slv8 := minimum (slv9, slv3);
    assert (slv8 = slv9) report "min (" & to_string(slv9) & ", "
      & to_string(slv3) & ") = " & to_string (slv8) severity error;
    slv8 := minimum (slv3, slv9);
    assert (slv8 = slv9) report "min (" & to_string(slv3) & ", "
      & to_string(slv9) & ") = " & to_string (slv8) severity error;

    sulv1 := "0001";
    sulv2 := "0010";
    assert (sulv2 > sulv1) report to_string(sulv2) & " > " & to_string(sulv1)
      & " miscompare" severity error;
    assert not (sulv2 < sulv1) report to_string(sulv2) & " < " & to_string(sulv1)
      & " miscompare" severity error;
    assert (sulv2 >= sulv1) report to_string(sulv2) & " >= " & to_string(sulv1)
      & " miscompare" severity error;
    assert not (sulv2 <= sulv1) report to_string(sulv2) & " <= " & to_string(sulv1)
      & " miscompare" severity error;
    assert not (sulv2 = sulv1) report to_string(sulv2) & " = " & to_string(sulv1)
      & " miscompare" severity error;
    assert (sulv2 /= sulv1) report to_string(sulv2) & " /= " & to_string(sulv1)
      & " miscompare" severity error;
    sulv3 := maximum (sulv1, sulv2);
    assert ((sulv3 = sulv2)) report "max (" & to_string(sulv1) & ", "
      & to_string(sulv2) & ") = " & to_string (sulv3) severity error;
    sulv3 := maximum (sulv2, sulv1);
    assert ((sulv3 = sulv2)) report "max (" & to_string(sulv2) & ", "
      & to_string(sulv1) & ") = " & to_string (sulv3) severity error;
    
    sulv3 := minimum (sulv1, sulv2);
    assert ((sulv3 = sulv1)) report "min (" & to_string(sulv1) & ", "
      & to_string(sulv2) & ") = " & to_string (sulv3) severity error;
    sulv3 := minimum (sulv2, sulv1);
    assert ((sulv3 = sulv1)) report "min (" & to_string(sulv2) & ", "
      & to_string(sulv1) & ") = " & to_string (sulv3) severity error;
    -- since there are no numeric overloads for std_ulogic_vector,
    -- this should always be the default behavior.
    sulv9 := "00111";
    sulv3 := "0110";
    assert (sulv9 < sulv3) report to_string(sulv9) & " < " & to_string(sulv3)
      & " miscompare" severity error;
    assert (sulv3 > sulv9) report to_string(sulv3) & " > " & to_string(sulv9)
      & " miscompare" severity error;
    sulv1 := maximum (sulv9, sulv3);
    assert (sulv1 = sulv3) report "max (" & to_string(sulv9) & ", "
      & to_string(sulv3) & ") = " & to_string (sulv1) severity error;
    sulv1 := maximum (sulv3, sulv9);
    assert (sulv1 = sulv3) report "max (" & to_string(sulv3) & ", "
      & to_string(sulv9) & ") = " & to_string (sulv1) severity error;
    sulv8 := minimum (sulv9, sulv3);
    assert (sulv8 = sulv9) report "min (" & to_string(sulv9) & ", "
      & to_string(sulv3) & ") = " & to_string (sulv8) severity error;
    sulv8 := minimum (sulv3, sulv9);
    assert (sulv8 = sulv9) report "min (" & to_string(sulv3) & ", "
      & to_string(sulv9) & ") = " & to_string (sulv8) severity error;
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
    for b1 in STD_ULOGIC loop
      b2 := STD_ULOGIC'left;
      b3 := maximum (b1, b2);
      assert (b3 = b1) report "max (" & to_string(b1) & ", " & to_string(b2)
        & ") /= " & to_string (b3) severity error;
      b3 := maximum (b2, b1);
      assert (b3 = b1) report "max (" & to_string(b2) & ", " & to_string(b1)
        & ") /= " & to_string (b3) severity error;
      b3 := minimum (b1, b2);
      assert (b3 = 'U') report "min (" & to_string(b1) & ", " & to_string(b2)
        & ") /= " & to_string (b3) severity error;
      b3 := minimum (b2, b1);
      assert (b3 = 'U') report "min (" & to_string(b2) & ", " & to_string(b1)
        & ") /= " & to_string (b3) severity error;
    end loop;

    assert (quiet) report "std_logic_1164 minmax test done" severity note;
    minmaxtest_done <= true;
    wait;
  end process minmaxtest;

  -- purpose: test the ?= operators
  questionequ : process is
    variable b1, b2, b3    : STD_ULOGIC;
    variable t1, t2, t3    : BOOLEAN;
    variable sv1, sv2, sv3 : STD_LOGIC_VECTOR (3 downto 0);
    variable su1, su2, su3 : STD_ULOGIC_VECTOR (3 downto 0);
  begin
    wait until start_qestionequ;
    -- bit ?= bit
    b1 := '1';
    b2 := '1';
    b3 := b1 ?= b2;
    assert b3 = '1'
      report STD_ULOGIC'image(b1) & " ?= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b1 := '0';
    b2 := '1';
    b3 := b1 ?= b2;
    assert b3 = '0'
      report STD_ULOGIC'image(b1) & " ?= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b1 := '1';
    b2 := '0';
    b3 := b1 ?= b2;
    assert b3 = '0'
      report STD_ULOGIC'image(b1) & " ?= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b1 := '0';
    b2 := '0';
    b3 := b1 ?= b2;
    assert b3 = '1'
      report STD_ULOGIC'image(b1) & " ?= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    -- bit ?/= bit
    b1 := '1';
    b2 := '1';
    b3 := b1 ?/= b2;
    assert b3 = '0'
      report STD_ULOGIC'image(b1) & " ?/= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b1 := '0';
    b2 := '1';
    b3 := b1 ?/= b2;
    assert b3 = '1'
      report STD_ULOGIC'image(b1) & " ?/= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b1 := '1';
    b2 := '0';
    b3 := b1 ?/= b2;
    assert b3 = '1'
      report STD_ULOGIC'image(b1) & " ?/= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b1 := '0';
    b2 := '0';
    b3 := b1 ?/= b2;
    assert b3 = '0'
      report STD_ULOGIC'image(b1) & " ?/= " & STD_ULOGIC'image(b2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    -- std_logic_vector ?= std_logic_vector
    sv1 := "0010";
    sv2 := "0010";
    b3  := sv1 ?= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    sv1 := "0001";
    sv2 := "0010";
    b3  := sv1 ?= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    sv2 := "0001";
    sv1 := "0010";
    b3  := sv1 ?= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    -- std_ulogic_vector ?= STD_ULOGIC_VECTOR
    su1 := "0010";
    su2 := "0010";
    b3  := su1 ?= su2;
    assert b3 = '1'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '0'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    su1 := "0001";
    su2 := "0010";
    b3  := su1 ?= su2;
    assert b3 = '0'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '1'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    su2 := "0001";
    su1 := "0010";
    b3  := su1 ?= su2;
    assert b3 = '0'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '1'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    -- Test some metavalues
    sv1 := "0010";
    sv2 := "00H0";
    b3  := sv1 ?= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    sv1 := "0010";
    sv2 := "0L10";
    b3  := sv1 ?= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    sv1 := "0010";
    sv2 := "0-10";
    b3  := sv1 ?= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    sv1 := "0010";
    sv2 := "----";
    b3  := sv1 ?= sv2;
    assert b3 = '1'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = '0'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    sv1 := "0010";
    sv2 := "00W0";
    b3  := sv1 ?= sv2;
    assert b3 = 'X'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = 'X'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    sv1 := "0010";
    sv2 := "00U0";
    b3  := sv1 ?= sv2;
    assert b3 = 'U'
      report to_string(sv1) & " ?= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := sv1 ?/= sv2;
    assert b3 = 'U'
      report to_string(sv1) & " ?/= " & to_string(sv2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    -- std_ulogic_vector meta values
    -- Test some metavalues
    su1 := "0010";
    su2 := "00H0";
    b3  := su1 ?= su2;
    assert b3 = '1'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '0'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    su1 := "0010";
    su2 := "0L10";
    b3  := su1 ?= su2;
    assert b3 = '1'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '0'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    su1 := "0010";
    su2 := "0-10";
    b3  := su1 ?= su2;
    assert b3 = '1'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '0'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    su1 := "0010";
    su2 := "----";
    b3  := su1 ?= su2;
    assert b3 = '1'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = '0'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    su1 := "0010";
    su2 := "00W0";
    b3  := su1 ?= su2;
    assert b3 = 'X'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = 'X'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    su1 := "0010";
    su2 := "00U0";
    b3  := su1 ?= su2;
    assert b3 = 'U'
      report to_string(su1) & " ?= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;
    b3 := su1 ?/= su2;
    assert b3 = 'U'
      report to_string(su1) & " ?/= " & to_string(su2) & " returned " & STD_ULOGIC'image(b3)
      severity error;

    assert (quiet) report "?= test complete"
      severity note;
    questionequ_done <= true;
  end process questionequ;
end architecture testbench;
