-- --------------------------------------------------------------------
-- Title      : Test vectors for testing additions to package "std.textio".
-- check new read and write functions
-- check the to_string functions
-- check the reduction operations
-- check the sread (string read) procedures
-- test the tee function
-- Last Modified: $Date: 2010/07/19 18:52:13 $
-- RCS ID: $Id: test_std_textio_add.vhdl,v 2.1 2010/07/19 18:52:13 l435385 Exp $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org)
-- ---------------------------------------------------------------------------

entity test_std_textio_add is
  generic (
    quiet : boolean := false);          -- run quietly

end entity test_std_textio_add;

use std.textio.all;

architecture testbench of test_std_textio_add is
  signal   start_readtest, readtest_done     : boolean   := false;  -- test read/write
  signal   start_stringtest, stringtest_done : boolean   := false;  -- test to_string
  signal   start_sreadtest, sreadtest_done   : boolean   := false;  -- sread test
  signal   start_teetest, teetest_done       : boolean   := false;  -- tee test
  signal   start_fileiotest, fileiotest_done       : boolean   := false;  -- tee test
--  signal start_vectest, vectest_done : BOOLEAN := false;  -- vector test
begin
  -- purpose: main test loop
  tester : process is

  begin  -- process testter
    start_stringtest <= true;
    wait until stringtest_done;

    start_readtest <= true;
    wait until readtest_done;
    start_sreadtest <= true;
    wait until sreadtest_done;

    start_fileiotest <= true;
    wait until fileiotest_done;
    start_teetest <= true;
    wait until teetest_done;
--    start_vectest <= true;
--    wait until vectest_done;
    report "New package standard.textio Testing complete" severity note;
    wait;

  end process tester;

  -- purpose: test the read functions
  readtest : process is
    variable L             : line;
    variable st1, st2, st3 : string (1 to 8);
    variable bv1, bv2, bv3 : bit_vector (11 downto 0);
    variable bv4, bv5, bv6 : BIT_VECTOR (12 downto 0);
    variable bv7, bv8, bv9 : BIT_VECTOR (10 downto 0);
    variable good          : boolean;
    variable length : INTEGER;
  begin  -- process readtest
    ---------------------------------------------------------------------------
    -- Checking the new read functions
    ---------------------------------------------------------------------------
    wait until start_readtest;
    L   := new string'("");
    sread ( L, st1, length );
    assert (length = 0) report "sread null string" severity error;
    deallocate (L);
    st2 := "10100101";
    L   := new string'(st2);
    sread (L, st1, length );
    assert (length = st2'length) report "sread number bad read" severity error;
    assert (st1 = st2) report "sread (""" & st2 & """) = """
      & st1 & '"' severity error;
    deallocate (L);
    bv2 := "101001010011";
    L   := new string'(to_string (bv2));
    bread (L, bv1, good);
    assert good report "bread number bad read" severity error;
    assert (bv1 = bv2) report "bread (" & to_string(bv2) & ") = " & L.all
      severity error;
    deallocate (L);
    st2 := "ABcdEFge";
    L   := new string'(st2);
    sread (L, st1, length );
    assert length = st2'length report "sread letter bad read" severity error;
    assert (st1 = st2) report "sread (""" & st2 & """) = """ & st1 & '"'
      severity error;
    deallocate (L);
    st2 := "    0101";
    L   := new string'(st2);
    sread (L, st1, length );
    st3 := "0101    ";
    assert (length = 4) report "sread number bad read length = "
      & integer'image(length)
      severity error;
    assert (st1(1 to 4) = st3(1 to 4)) report "sread (""" & st2 & """) = """
      & st1 & '"' severity error;
    deallocate (L);
    st2 := "    EFge";
    L   := new string'(st2);
    sread (L, st1, length );
    st3 := "EFge    ";
    assert (length = 4) report "sread number bad read length = "
      & integer'image(length)
      severity error;
    assert (st1(1 to 4) = st3(1 to 4)) report "sread (""" & st2 & """) = """ & st1 & '"'
      severity error;
    L := new string'("");
    sread (L, st1, length);
    assert (length = 0)
      report "sread(NULL) returned non zero length " & st1 severity error;
    deallocate (L);
    st2 := "10100101";
    L   := new string'(st2);
    sread (L, st1, length);
    assert (st1 = st2) report "sread (""" & st2 & """) = """
      & st1 & '"' severity error;
    deallocate (L);
    bv2 := "101001010000";
    L   := new string'(to_string(bv2));
    bread (L, bv1);
    assert (bv1 = bv2) report "bread (" & to_string(bv2) & ") = "
      & L.all severity error;
    deallocate (L);
    st2 := "ABcdEFge";
    L   := new string'(st2);
    sread (L, st1, length);
    assert (st1 = st2) report "sread (""" & st2 & """) = """
      & st1 & '"' severity error;
    deallocate (L);
    st2 := "    0101";
    L   := new string'(st2);
    sread (L, st1, length);
    st3 := "0101    ";
    assert (st1(1 to 4) = st3(1 to 4)) report "sread (""" & st2 & """) = """
      & st1 & '"' severity error;
    deallocate (L);
    st2 := "    EFge";
    L   := new string'(st2);
    sread (L, st1, length);
    st3 := "EFge    ";
    assert (st1(1 to 4) = st3(1 to 4)) report "sread (""" & st2 & """) = """ & st1 & '"'
      severity error;
    deallocate (L);
    -- hread
    if (not quiet) then
      L := new string'("");
      hread ( L, bv1, good );           -- This error should be silent, but it
                                        -- isn't in Modeltech.
      assert not good report "a) std.textio.hread "& to_string (bv1)
        severity error;
      deallocate (L);
    end if;
    L := new string'(" *");
    hread ( L, bv1, good );
    assert not good report "b) std.textio.hread "& to_string (bv1)
      severity error;
    deallocate (L);
    L := new string'(" 00*");
    hread ( L, bv1, good );
    assert not good report "c) std.textio.hread "& to_string (bv1)
      severity error;
    deallocate (L);
    L := new string'("00*");
    hread ( L, bv1, good );
    assert not good report "d) std.textio.hread "& to_string (bv1)
      severity error;
    deallocate (L);
    L := new string'(" 00");
    hread ( L, bv1, good );
    assert not good report "e) std.textio.hread "& to_string (bv1)
      severity error;
    deallocate (L);
    L := new string'("00");
    hread ( L, bv1, good );
    assert not good report "f) std.textio.hread "& to_string (bv1)
      severity error;
    deallocate (L);
    L := new string'("9FE");
    hread ( L, bv1, good );
    assert good and bv1 = "100111111110"
      report "g) std.textio.hread "& to_string (bv1) severity error;
    deallocate (L);
    L := new string'("0ABC");
    hread (L, bv4, good);
    assert (good and bv4 = "0101010111100")
      report "h) short std.textio.hread " & to_string (bv4) severity error;
    deallocate (L);
    L := new string'("87");
    hread (L, bv4, good);
    assert not good
      report "i) long std.textio.hread " & to_string (bv4) severity error;
    deallocate (L);
    L := new string'("0876");
    hread (L, bv4, good);
    assert (good) report "j) std.textio.hread reported bad read" severity error;
    assert (bv4 = "0100001110110" )
      report "j) std.textio.hread (876) = " & to_string(bv4)
      & " /= 0100001110110" severity error;
    deallocate (L);
    L := new STRING'("543");            -- top bit zero so it will fit
    hread (L, bv7, good);
    assert (good) report "k) std.textio.hread reported bad read" severity error;
    assert (bv7 = "10101000011" )
      report "j) std.textio.hread (543) = " & to_string(bv7)
      & " /= 10101000011" severity error;
    deallocate (L);
    L := new string'("821");            -- one bit too many
    hread (L, bv7, good);
    assert (not good)
      report "l) std.textio.hread reported good read" severity error;
    deallocate (L);
    if (not quiet) then
      assert (quiet) report "Expect 8 hread errors here" severity note;
      L := new string'("");
      hread ( L, bv1);                  -- null string
      deallocate (L);
      L := new string'(" *");
      hread ( L, bv1 );                   -- illegal character
      deallocate (L);
      L := new string'(" 00*");
      hread ( L, bv1 );                   -- illegal character
      deallocate (L);
      L := new string'("00*");
      hread ( L, bv1 );                   -- illegal character
      deallocate (L);
      L := new string'(" 00");
      hread ( L, bv1 );                   -- short with white space
      deallocate (L);
      L := new string'("00");             -- short without white space
      hread ( L, bv1);
      deallocate (L);
      L := new string'("87");             -- one bit too few.
      hread (L, bv4);
      deallocate (L);
      L := new string'("821");            -- one bit too many
      hread (L, bv7);
      deallocate (L);
    end if;
    ----------------------------------------------------------------------------
    -- hread without good.
    ----------------------------------------------------------------------------
    L := new string'(" 901");
    hread ( L, bv1 );
    assert bv1 = "100100000001"
      report "m) std.textio.hread " & to_string (bv1) severity error;
    deallocate (L);
    L := new string'("9FE");
    hread ( L, bv1);
    assert bv1 = "100111111110"
      report "n) std.textio.hread "& to_string (bv1) severity error;
    deallocate (L);
    L := new string'(" 901");
    hread ( L, bv1 );
    assert bv1 = "100100000001"
      report "o) std.textio.hread " & to_string (bv1) severity error;
    deallocate (L);
    L := new string'("0ABC");
    hread (L, bv4);
    assert (bv4 = "0101010111100")
      report "h) short std.textio.hread " & to_string (bv4) severity error;
    deallocate (L);
    L := new string'("0876");
    hread (L, bv4);
    assert (bv4 = "0100001110110" )
      report "p) std.textio.hread (876) = " & to_string(bv4)
      & " /= 0100001110110" severity error;
    deallocate (L);
    L := new STRING'("543");            -- top bit zero so it will fit
    hread (L, bv7);
    assert (bv7 = "10101000011" )
      report "q) std.textio.hread (543) = " & to_string(bv7)
      & " /= 10101000011" severity error;
    deallocate (L);

-- oread
    L := new string'("");
    oread ( L, bv1, good );
    assert not good report "a) std.textio.oread null" severity error;
    deallocate (L);
    L := new string'(" *");
    oread ( L, bv1, good );
    assert not good report "b) std.textio.oread *" severity error;
    deallocate (L);
    L := new string'(" 000*");
    oread ( L, bv1, good );
    assert not good report "c) std.textio.oread  0*" severity error;
    deallocate (L);
    L := new string'("000*");
    oread ( L, bv1, good );
    assert not good report "d) std.textio.oread 0*" severity error;
    deallocate (L);
    L := new string'(" 00");
    oread ( L, bv1, good );
    assert not good report "e) std.textio.oread  0" severity error;
    deallocate (L);
    L := new string'("00");
    oread ( L, bv1, good );
    assert not good report "f) std.textio.oread 00 short" severity error;
    deallocate (L);
    L := new string'("6307");
    oread ( L, bv1, good );
    assert good and bv1 = "110011000111"
      report "g) std.textio.oread " & to_string (bv1) severity error;
    deallocate (L);
    L := new string'("10707");
    oread (L, bv4, good);
    assert (good) report "h) textio.oread reported error reading long number"
      severity error;
    assert (bv4 = "1000111000111")
      report "h) textio.oread (10707) = " & to_string(bv4) severity error;
    deallocate (L);
    L := new string'("3070");
    oread (L, bv7, good);
    assert (good) report "i) textio.oread reported error reading short number"
      severity error;
    assert (bv7 = "11000111000")
      report "i) textio.oread (3070) = " & to_string(bv7) severity error;
    deallocate (L);
    L := new string'("7070");
    oread (L, bv7, good);
    assert (not good)
      report "j) textio.oread not reported error reading short number"
      severity error;
    deallocate (L);
    L := new string'(" 6370");
    oread ( L, bv1 );
    assert bv1 = "110011111000"
      report "k) std.textio.oread " & to_string (bv1) severity error;
    deallocate (L);
    L := new string'("6307");
    oread ( L, bv1 );
    assert bv1 = "110011000111"
      report "l) std.textio.oread " & to_string (bv1) severity error;
    deallocate (L);
    L := new string'("10707");
    oread (L, bv4);
    assert (bv4 = "1000111000111")
      report "m) textio.oread (10707) = " & to_string(bv4) severity error;
    deallocate (L);
    L := new string'("3070");
    oread (L, bv7);
    assert (bv7 = "11000111000")
      report "n) textio.oread (3070) = " & to_string(bv7) severity error;
    deallocate (L);
    L := new string'(" 6370");
    oread ( L, bv1 );
    assert bv1 = "110011111000"
      report "o) std.textio.oread " & to_string (bv1) severity error;
    deallocate (L);
    if (not quiet) then
      assert (quiet) report "Expect 5 oread errors here" severity note;
      L := new string'("");
      oread ( L, bv1 );                   -- null character error
      deallocate (L);
      L := new string'(" ");
      oread ( L, bv1 );                   -- white space
      deallocate (L);
      L := new string'(" 000*");          -- illegal character error
      oread ( L, bv1 );
      deallocate (L);
      L := new string'(" 0");          -- short string
      oread ( L, bv1 );
      deallocate (L);
      L := new string'("7070");
      oread (L, bv7);                     -- vector truncated
      deallocate (L);
    end if;
    -- hwrite
    L := null;
    hwrite ( L, bit_vector'("00001001111101011010") );
    assert L.all = "09F5A" report "std.textio.hwrite " & L.all
      severity error;
    L := null;
    hwrite ( L, bit_vector'("00001001000010111100"),
             field => 8 );
    assert L.all = "   090BC" report "std.textio.hwrite " & L.all
      severity error;
    L := null;
    hwrite ( L, bit_vector'("00001001110101000000"),
             justified => left, field => 8 );
    assert L.all = "09D40   " report "std.textio.hwrite " & L.all
      severity error;
    -- owrite
    L := null;
    owrite ( L, bit_vector'("000101111010011") );
    assert L.all = "05723" report "std.textio.owrite " & L.all
      severity error;
    L := null;
    owrite ( L, bit_vector'("000101100001110"),
             field => 8 );
    assert L.all = "   05416" report "std.textio.owrite " & L.all
      severity error;
    L := null;
    owrite ( L, bit_vector'("000101000000000"),
             justified => left, field => 8 );
    assert L.all = "05000   " report "std.textio.owrite " & L.all severity
      error;
    L := null;
    bwrite (L, bit_vector'("11001101"));
    assert (L.all = "11001101") report "bwrite error " & L.all severity error;
    L := null;
    bwrite (L, bit_vector'("11001101"), left, 12);
    assert (L.all = "11001101    ") report "bwrite justify error " & L.all
      severity error;


    assert (quiet) report "read test complete" severity note;
    readtest_done <= true;
    wait;
  end process readtest;

  -- purpose: test the sread command
  sreadtest: process is
    variable st1, st2, st3 : STRING (1 to 4);
    variable st4 : STRING (1 to 3);
    variable st5 : STRING (1 to 5);
    variable good : BOOLEAN;
    variable length : NATURAL;
    variable L : LINE;
  begin
    wait until start_sreadtest;
    st2 := "WXYZ";
    L := new string'(st2);
    sread (L, st1, length);
    assert (length = st2'length)
      report "false error reported sread (" & st2 & ")"
      severity error;
    assert (st1 = st2)
      report "sread (""" & st2 & """) = """ & st1 & '"'
      severity error;
    st4 := "abc";
    L := new string'(st4);
    sread (L, st1, length);
    assert length = st4'length
      report "false error reported sread (" & st4 & ")"
      severity error;
--    st2 := st4 & " ";
    assert (st1(1 to 3) = st4)
      report "sread (""" & st4 & """) = """ & st1 & '"'
      severity error;
    st5 := "LMNOP";
    L := new string'(st5);
    sread (L, st1, length);
    assert length = st1'length
      report "false error reported sread (" & st5 & ")"
      severity error;
    st2 := st5 (st2'range);
    assert (st1 = st2)
      report "sread (""" & st5 & """) = """ & st1 & '"'
      severity error;
    st2 := "WXYZ";
    L := new string'(st2);
    sread (L, st1, length);
    assert (st1 = st2)
      report "sread (""" & st2 & """) = """ & st1 & '"'
      severity error;
    st4 := "abc";
    L := new string'(st4);
    sread (L, st1, length);
--    st2 := st4 & " ";
    assert (st1(1 to 3) = st4)
      report "sread (""" & st4 & """) = """ & st1 & '"'
      severity error;
    st5 := "LMNOP";
    L := new string'(st5);
    sread (L, st1, length);
    st2 := st5 (st2'range);
    assert (st1 = st2)
      report "sread (""" & st5 & """) = """ & st1 & '"'
      severity error;
    L := null;
    st2 := "WXYZ";
    swrite (L, st2);
    assert (L.all = st2) report "swrite ( " & st2 & ") /= " & L.all
      severity error;
    L := null;
    swrite (L, "qwerty", left, 8);
    assert (L.all = "qwerty  ") report "swrite (qwerty, left, 8) /= " & L.all
      severity error;
    assert (quiet) report "sread test complete" severity note;
    sreadtest_done <= true;
    wait;
  end process sreadtest;

  fileio: process
    constant filename : STRING := "textfile";
    file testfile : TEXT;
    variable file_status : FILE_OPEN_STATUS;
    variable MyLine : line;
    variable str    : string(1 to 4);
    variable slv    : bit_vector(3 downto 0);
    variable hslv : bit_VECTOR (15 downto 0);  -- hex
    variable oslv : bit_VECTOR (11 downto 0);  -- octal
    variable sl     : bit;
    variable ok     : boolean;
    variable strl : NATURAL;
  begin
    wait until start_fileiotest;
    -- Write the test file
    file_open (status => file_status,
               f => testfile,
               external_name => filename,
               open_kind => write_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for write with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    Myline := new string'("0001");
    writeline (testfile, Myline);
    Myline := new string'(" 0010");
    writeline (testfile, Myline);
    Myline := new string'("        0011");
    writeline (testfile, Myline);
    Myline := new string'("0100");
    writeline (testfile, Myline);
    Myline := new string'("");  -- blank LINE
    writeline (testfile, Myline);
    Myline := new string'("0101 ");
    writeline (testfile, Myline);
    Myline := new string'(" ");  -- just a space
    writeline (testfile, Myline);
    Myline := new string'(HT & "0110 ");
    writeline (testfile, Myline);
    Myline := new string'(character'val(160) & "0111");  -- nbsp
    writeline (testfile, Myline);
    Myline := new string'("%000");
    writeline (testfile, Myline);
    Myline := new string'("0%00");
    writeline (testfile, Myline);
    Myline := new string'("000%");
    writeline (testfile, Myline);
    Myline := new string'("111");  -- short STRING
    writeline (testfile, Myline);
    Myline := new string'("00111");  -- big STRING
    writeline (testfile, Myline);
    Myline := new string'("UXWZ");
    writeline (testfile, Myline);
    Myline := new string'("HL-Z");
    writeline (testfile, Myline);
    Myline := new string'("1010 0101");
    writeline (testfile, Myline);
    Myline := new string'("10111101");
    writeline (testfile, Myline);
    Myline := new string'("1111");
    writeline (testfile, Myline);
    file_close (testfile);
    -- close it, and open it for reading.
    file_open (status => file_status,
               f => testfile,
               external_name => filename,
               open_kind => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 1 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0001")
      report "Read STR 1 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 2 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0010")
      report "Read STR 2 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 3 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0011")
      report "Read STR 3 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 4 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0100")
      report "Read STR 4 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 0)
      report "Sread STR blank length returned " & INTEGER'image(strl)
      severity error;
--    assert (str = "    ")
--      report "Read STR blank returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 5 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0101")
      report "Read STR 5 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 0)
      report "Sread STR space length returned " & INTEGER'image(strl)
      severity error;
--    assert (str = "    ")
--      report "Read STR space returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 6 HT length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0110")
      report "Read STR 6 HT returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 7 nbsp length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0111")
      report "Read STR 7 NBSP returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 5 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "%000")
      report "Read STR space returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 5 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "0%00")
      report "Read STR space returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 5 length returned " & INTEGER'image(strl)
      severity error;
    assert (str = "000%")
      report "Read STR space returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 3)
      report "Sread STR short length returned " & INTEGER'image(strl)
      severity error;
    assert (str(1 to 3) = "111")
      report "Read STR short returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR 7 extra length returned " & INTEGER'image(strl);
    assert (str = "0011")
      report "Read STR 7 extra returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR X1 length returned " & INTEGER'image(strl);
    assert (str = "UXWZ")
      report "Read STR X1 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR X2 length returned " & INTEGER'image(strl);
    assert (str = "HL-Z")
      report "Read STR X2 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR A length returned " & INTEGER'image(strl);
    assert (str = "1010")
      report "Read STR A returned " & str severity error;
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR A 5 length returned " & INTEGER'image(strl);
    assert (str = "0101")
      report "Read STR A 5 returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR B length returned " & INTEGER'image(strl);
    assert (str = "1011")
      report "Read STR B returned " & str severity error;
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR B D length returned " & INTEGER'image(strl);
    assert (str = "1101")
      report "Read STR B D returned " & str severity error;
    readline(testfile, MyLine);
    sread (MyLine, str, strl);
    assert (strl = 4)
      report "Sread STR F length returned " & INTEGER'image(strl);
    assert (str = "1111")
      report "Read STR F returned " & str severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);


    -- Commented out the "read(L, BV)" and "read(L, BV, good)" testcase.
    -- As these are built in, they do not work consistently.
--    -- close it, and open it for reading.
--    file_open (status => file_status,
--               f => testfile,
--               external_name => filename,
--               open_kind => read_mode);
--    assert (file_status = open_ok)
--      report "Failed to open file " & filename & " for read with status " &
--      FILE_OPEN_STATUS'image(file_status)
--      severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0001")
--      report "Read SLV 1 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0010")
--      report "Read SLV 2 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0011")
--      report "Read SLV 3 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0100")
--      report "Read SLV 4 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect a read error here" severity note;
--      read(MyLine, slv);
--      assert (slv = "0000")
--        report "Read SLV blank returned " & to_string(slv) severity error;
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0101")
--      report "Read SLV 5 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect a read error here" severity note;
--      read(MyLine, slv);
--      assert (slv = "0000")
--        report "Read SLV space returned " & to_string(slv) severity error;
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0110")
--      report "Read SLV 6 HT returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0111")
--      report "Read SLV 7 NBSP returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect 4 read errors here" severity note;
--      read(MyLine, slv);
--      assert (slv = "0000")
--        report "Read SLV space returned " & to_string(slv) severity error;
--      readline(testfile, MyLine);
--      read(MyLine, slv);
--      assert (slv = "0000")
--        report "Read SLV space returned " & to_string(slv) severity error;
--      readline(testfile, MyLine);
--      read(MyLine, slv);
--      assert (slv = "0000")
--        report "Read SLV space returned " & to_string(slv) severity error;
--      readline(testfile, MyLine);
--      read(MyLine, slv);
--      assert (slv = "0000")
--        report "Read SLV space returned " & to_string(slv) severity error;
--    else
--      readline(testfile, MyLine);
--      readline(testfile, MyLine);
--      readline(testfile, MyLine);
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0011")
--      report "Read SLV 7 extra returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect two read bad character errors here" severity note;
--      read(MyLine, slv);
--    assert (slv = "0000")
--      report "Read SLV X1 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "0000")
--      report "Read SLV X2 returned " & to_string(slv) severity error;
--    else
--    readline(testfile, MyLine);
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "1010")
--      report "Read SLV A returned " & to_string(slv) severity error;
--    read(MyLine, slv);
--    assert (slv = "0101")
--      report "Read SLV A 5 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "1011")
--      report "Read SLV B returned " & to_string(slv) severity error;
--    read(MyLine, slv);
--    assert (slv = "1101")
--      report "Read SLV B D returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv);
--    assert (slv = "1111")
--      report "Read SLV F returned " & to_string(slv) severity error;
--    assert (EndFile(testfile))
--      report "End of file not reached!" severity error;
--    file_close (testfile);
--    -- std_logic_vector - read with good
--    file_open (status => file_status,
--               f => testfile,
--               external_name => filename,
--               open_kind => read_mode);
--    assert (file_status = open_ok)
--      report "Failed to open file " & filename & " for read with status " &
--      FILE_OPEN_STATUS'image(file_status)
--      severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 1 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0001")
--      report "Read SLV 1 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 2 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0010")
--      report "Read SLV 2 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 3 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0011")
--      report "Read SLV 3 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 4 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0100")
--      report "Read SLV 4 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV blank returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV blank returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 5 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0101")
--      report "Read SLV 5 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV space returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 6 HT returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0110")
--      report "Read SLV 6 HT returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 7 NBSP returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0111")
--      report "Read SLV 7 NBSP returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV space returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV space returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV space returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV space returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV 7 extra returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0011")
--      report "Read SLV 7 extra returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV X1 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV X1 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (not ok) report "Read SLV X2 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0000")
--      report "Read SLV X2 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV A returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "1010")
--      report "Read SLV A returned " & to_string(slv) severity error;
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV A 5 returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "0101")
--      report "Read SLV A 5 returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV B returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "1011")
--      report "Read SLV B returned " & to_string(slv) severity error;
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV B D returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "1101")
--      report "Read SLV B D returned " & to_string(slv) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, slv, ok);
--    assert (ok) report "Read SLV F returned " & BOOLEAN'image(ok)
--      severity error;
--    assert (slv = "1111")
--      report "Read SLV F returned " & to_string(slv) severity error;
--    assert (EndFile(testfile))
--      report "End of file not reached!" severity error;
--    file_close (testfile);
    -- hex read
    file_open (status => file_status,
               f => testfile,
               external_name => filename,
               open_kind => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000000000001")
      report "hRead SLV 1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000000010000")
      report "hRead SLV 2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000000010001")
      report "hRead SLV 3 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000100000000")
      report "hRead SLV 4 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a hread error here" severity note;
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "hRead SLV blank returned " & to_string(hslv) severity error;
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000100000001")
      report "Hread SLV 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a hread error here" severity note;
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000100010000")
      report "Hread HSLV 6 HT returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000100010001")
      report "Hread HSLV 7 NBSP returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 hread errors here" severity note;
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0000000000010001")
      report "Hread HSLV 7 extra returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expecte 2 HREAD character errors here" severity note;
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV X1 returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "0000000000000000")
        report "Hread HSLV X2 returned " & to_string(hslv) severity error;
    else
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0001000000010000")
      report "Hread HSLV A returned " & to_string(hslv) severity error;
    hread(MyLine, hslv);
    assert (hslv = "0000000100000001")
      report "Hread HSLV A 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0001000000010001")
      report "Hread HSLV B returned " & to_string(hslv) severity error;
    hread(MyLine, hslv);
    assert (hslv = "0001000100000001")
      report "Hread HSLV B D returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv);
    assert (hslv = "0001000100010001")
      report "Hread HSLV F returned " & to_string(hslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- octal read
    file_open (status => file_status,
               f => testfile,
               external_name => filename,
               open_kind => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000000000001")
      report "oread SLV 1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000000001000")
      report "oread SLV 2 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000000001001")
      report "oread SLV 3 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000001000000")
      report "oread SLV 4 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a oread error here" severity note;
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "oread SLV blank returned " & to_string(oslv) severity error;
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000001000001")
      report "Oread SLV 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a oread error here" severity note;
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000001001000")
      report "Oread OSLV 6 HT returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000001001001")
      report "Oread OSLV 7 NBSP returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 oread errors here" severity note;
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "000000001001")
      report "Oread OSLV 7 extra returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expecte 2 OREAD character errors here" severity note;
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV X1 returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "000000000000")
        report "Oread OSLV X2 returned " & to_string(oslv) severity error;
    else
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "001000001000")
      report "Oread OSLV A returned " & to_string(oslv) severity error;
    oread(MyLine, oslv);
    assert (oslv = "000001000001")
      report "Oread OSLV A 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "001000001001")
      report "Oread OSLV B returned " & to_string(oslv) severity error;
    oread(MyLine, oslv);
    assert (oslv = "001001000001")
      report "Oread OSLV B D returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv);
    assert (oslv = "001001001001")
      report "Oread OSLV F returned " & to_string(oslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- hex read with good
    file_open (status => file_status,
               f => testfile,
               external_name => filename,
               open_kind => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 1 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000001")
      report "hRead SLV 1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000010000")
      report "hRead SLV 2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 3 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000010001")
      report "hRead SLV 3 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000100000000")
      report "hRead SLV 4 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV blank returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "hRead SLV blank returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 5 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000100000001")
      report "Hread SLV 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV space returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "Hread HSLV space returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 6 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000100010000")
      report "Hread HSLV 6 HT returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 7 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000100010001")
      report "Hread HSLV 7 NBSP returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread space returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "Hread HSLV space returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread space returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "Hread HSLV space returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread bad char 2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "hread bad char 2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread bad char 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "hread bad char 4 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV 7 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000010001")
      report "Hread HSLV 7 extra returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV X1 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "Hread HSLV X1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV X2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000000000000")
      report "Hread HSLV X2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV A returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0001000000010000")
      report "Hread HSLV A returned " & to_string(hslv) severity error;
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV A 5 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0000000100000001")
      report "Hread HSLV A 5 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV B returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0001000000010001")
      report "Hread HSLV B returned " & to_string(hslv) severity error;
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV B D returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0001000100000001")
      report "Hread HSLV B D returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (ok) report "hread SLV F returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "0001000100010001")
      report "Hread HSLV F returned " & to_string(hslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- Octal read with good
    file_open (status => file_status,
               f => testfile,
               external_name => filename,
               open_kind => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 1 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000001")
      report "oread SLV 1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000001000")
      report "oread SLV 2 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 3 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000001001")
      report "oread SLV 3 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 4 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000001000000")
      report "oread SLV 4 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV blank returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "oread SLV blank returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 5 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000001000001")
      report "Oread SLV 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV space returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV space returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 6 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000001001000")
      report "Oread OSLV 6 HT returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 6 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000001001001")
      report "Oread OSLV 7 NBSP returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 1 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV 1 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 2 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV 2 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 4 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV 4 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread short returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV short returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV 7 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000001001")
      report "Oread OSLV 7 extra returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV X1 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV X1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV X2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000000000000")
      report "Oread OSLV X2 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV A returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "001000001000")
      report "Oread OSLV A returned " & to_string(oslv) severity error;
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV A 5 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "000001000001")
      report "Oread OSLV A 5 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV B returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "001000001001")
      report "Oread OSLV B returned " & to_string(oslv) severity error;
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV B D returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "001001000001")
      report "Oread OSLV B D returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (Ok) report "oread OSLV F returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "001001001001")
      report "Oread OSLV F returned " & to_string(oslv) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- STD_LOGIC
    -- commented out the "read(L, bit)" and "read(L, bit, good)" test.
    -- These are built in and also not consistent.
--    file_open (status => file_status,
--               f => testfile,
--               external_name => filename,
--               open_kind => read_mode);
--    assert (file_status = open_ok)
--      report "Failed to open file " & filename & " for read with status " &
--      FILE_OPEN_STATUS'image(file_status)
--      severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 1 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 2 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 3 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 4 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect a read error here" severity note;
--      read(MyLine, sl);
--      assert (sl = '0')
--        report "Read SL blank returned " & to_string(sl) severity error;
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 5 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect a read error here" severity note;
--      read(MyLine, sl);
--      assert (sl = '0')
--        report "Read SL space returned " & to_string(sl) severity error;
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 6 HT returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 7 NBSP returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect 1 read errors here" severity note;
--      read(MyLine, sl);
--      assert (sl = '0')
--        report "Read SL %000 returned " & to_string(sl) severity error;
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 0% returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 000% returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '1')
--      report "Read SL 111 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL 7 extra returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    if (not quiet) then
--      report "Expect 2 read(BIT) character errors here" severity note;
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL X1 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL X2 returned " & to_string(sl) severity error;
--    else
--    readline(testfile, MyLine);
--    end if;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '1')
--      report "Read SL A returned " & to_string(sl) severity error;
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL A 5 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '1')
--      report "Read SL B returned " & to_string(sl) severity error;
--    read(MyLine, sl);
--    assert (sl = '0')
--      report "Read SL B D returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl);
--    assert (sl = '1')
--      report "Read SL F returned " & to_string(sl) severity error;
--    assert (EndFile(testfile))
--      report "End of file not reached!" severity error;
--    file_close (testfile);
--    -- STD_LOGIC, with good
--    file_open (status => file_status,
--               f => testfile,
--               external_name => filename,
--               open_kind => read_mode);
--    assert (file_status = open_ok)
--      report "Failed to open file " & filename & " for read with status " &
--      FILE_OPEN_STATUS'image(file_status)
--      severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL1 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 1 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 2 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 2 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 3 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 3 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 4 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 4 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (not OK) report "Read SL blank returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL blank returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 5 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 5 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (not OK) report "Read SL blank returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL space returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 6 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 6 HT returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 7 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 7 NBSP returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (not OK) report "Read SL % returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL %000 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 0% returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 0% returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 000% returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 000% returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 111 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '1')
--      report "Read SL 111 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL 7 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL 7 extra returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--      read(MyLine, sl, Ok);
--    assert (not OK) report "Read SL x1 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL X1 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (not OK) report "Read x2 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL X2 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL A returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '1')
--      report "Read SL A returned " & to_string(sl) severity error;
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL A 5 returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL A 5 returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL B returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '1')
--      report "Read SL B returned " & to_string(sl) severity error;
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL B D returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '0')
--      report "Read SL B D returned " & to_string(sl) severity error;
--    readline(testfile, MyLine);
--    read(MyLine, sl, Ok);
--    assert (OK) report "Read SL F returned boolean "
--      & BOOLEAN'image(Ok) severity error;
--    assert (sl = '1')
--      report "Read SL F returned " & to_string(sl) severity error;
--    assert (EndFile(testfile))
--      report "End of file not reached!" severity error;
--    file_close (testfile);
    assert quiet report "File IO test completed" severity note;
    fileiotest_done <= true;
    wait;
  end process fileio;

  -- purpose: test string functions
  stringtest : process is
    variable st1, st2, st3 : string (1 to 12);  -- binary
    variable st4, st5, st6 : string (1 to 3);   -- hex
    variable st7, st8, st9 : string (1 to 4);   -- octal
    variable stx : STRING ( 1 to 1);    -- binary
    variable bv1           : bit_vector (11 downto 0);
    variable int           : integer;
    variable b       : BIT;
    variable boo : BOOLEAN;
    variable sl    : SEVERITY_LEVEL;
    variable r       : REAL;
    variable t       : TIME;
    variable fok : FILE_OPEN_KIND;
    variable fos : FILE_OPEN_STATUS;
    variable si    : SIDE;
    variable L : LINE;
  begin  -- process stringtest
    wait until start_stringtest;
    -- to_string
    bv1 := "000011110000";
    st2 := "000011110000";
    st1 := to_string (bv1);
    assert (st1 = st2) report "to_string error " & st1 & " /= " & st2
      severity error;
    bv1 := "111100001111";
    st2 := "111100001111";
    st1 := to_string (bv1);
    assert (st1 = st2) report "to_string error " & st1 & " /= " & st2
      severity error;
    -- to_hstring
    bv1 := "000011110000";
    st4 := "0F0";
    st5 := to_hstring (bv1);
    assert (st4 = st5) report "to_hstring(" & to_string (bv1) & ") /= " & st5
      severity error;
    bv1 := "001000110100";
    st4 := "234";
    st5 := to_hstring (bv1);
    assert (st4 = st5) report "to_hstring(" & to_string (bv1) & ") /= " & st5
      severity error;
    bv1 := "010101100111";
    st4 := "567";
    st5 := to_hstring (bv1);
    assert (st4 = st5) report "to_hstring(" & to_string (bv1) & ") /= " & st5
      severity error;
    bv1 := "100010011010";
    st4 := "89A";
    st5 := to_hstring (bv1);
    assert (st4 = st5) report "to_hstring(" & to_string (bv1) & ") /= " & st5
      severity error;
    bv1 := "101111001101";
    st4 := "BCD";
    st5 := to_hstring (bv1);
    assert (st4 = st5) report "to_hstring(" & to_string (bv1) & ") /= " & st5
      severity error;
    -- justify
    st7 := "LEFT";
    st1 := justify (st7, LEFT, st1'length);
    st2 := "LEFT        ";
    assert (st1 = st2) report "Left justify(""" & st7
      & """ /= """ & st1 & '"' severity error;
    st7 := "rite";
    st1 := justify (st7, RIGHT, st1'length);
    st2 := "        rite";
    assert (st1 = st2) report "Right justify(""" & st7
      & """ /= """ & st1 & '"' severity error;
    st7 := "none";
    st1 := justify (value => st7,
                    FIELD => st1'length);
    st2 := "        none";
    assert (st1 = st2) report "no justify(""" & st7
      & """ /= """ & st1 & '"' severity error;
    bv1 := "101110101101";
    st2 := "BAD         ";
    st1 := justify (to_hstring (bv1), LEFT, st1'length);
    assert (st1 = st2) report "to_hstring(" & to_string (bv1) & ", LEFT,"
      & ") /= """ & st2 & '"'
      severity error;
    bv1 := "111100001101";
    st2 := "         F0D";
    st1 := justify (to_hstring (bv1), right, st1'length);
    assert (st1 = st2) report "to_hstring(" & to_string (bv1) & ", right,"
      & ") /= """ & st2 & '"'
      severity error;
    -- to_ostring
    bv1 := "000001010011";
    st7 := "0123";
    st8 := to_ostring (bv1);
    assert (st8 = st7) report "to_ostring( " & to_string(bv1) & ") /= " & st8
      severity error;
    bv1 := "100101110111";
    st7 := "4567";
    st8 := to_ostring (bv1);
    assert (st8 = st7) report "to_ostring( " & to_string(bv1) & ") /= " & st8
      severity error;
    bv1 := "000001010011";
    st2 := "0123        ";
    st1 := justify (to_ostring (bv1), LEFT, st1'length);
    assert (st1 = st2) report "to_ostring( " & to_string(bv1) & ",LEFT) /= "
      & st8 severity error;
    bv1 := "000001010011";
    st2 := "        0123";
    st1 := justify (to_ostring (bv1), right, st1'length);
    assert (st1 = st2) report "to_ostring( " & to_string(bv1) & ",right) /= "
      & st8 severity error;
    -- to_string(integer)
    int := 123;
    st5 := "123";
    st4 := to_string(int);
    assert (st4 = st5) report "to_string("& integer'image(int)
      & ") /= " & st4 severity error;
    int := -45;
    st5 := "-45";
    st4 := to_string(int);
    assert (st4 = st5) report "to_string("& integer'image(int)
      & ") /= " & st4 severity error;
    int := 678;
    st5 := "678";
    st4 := to_string(int);
    assert (st4 = st5) report "to_string("& integer'image(int)
      & ") /= " & st4 severity error;
    int := -90;
    st5 := "-90";
    st4 := to_string(int);
    assert (st4 = st5) report "to_string("& integer'image(int)
      & ") /= " & st4 severity error;
    int := 678;
    st7 := " 678";
    st8 := justify (to_string(int), right, st8'length);
    assert (st8 = st7) report "to_string("& integer'image(int)
      & ") /= """ & st8 & '"' severity error;
    int := -90;
    st7 := "-90 ";
    st8 := justify (to_string(int), left, st8'length);
    assert (st8 = st7) report "to_string("& integer'image(int)
      & ") /= """ & st8 & '"' severity error;
    -- Now test the overloaded to_string funcitons
    for b in BIT loop
      stx := to_string (b);
      assert ("'" & stx & "'" = bit'image(b))
        report "bit to_string (""" & BIT'image(b) & """) /= " & stx
        severity error;
    end loop;
    for boo in BOOLEAN loop
      st1 := justify (to_string (boo), left, st1'length);
      L := null;
      swrite (L, BOOLEAN'image(boo), left, st1'length);
      assert (st1  = L.all)
        report "BOOLEAN to_string (""" &  BOOLEAN'image(boo)
        & """) /= " & st1
        severity error;
      deallocate (L);
    end loop;
    for sl in SEVERITY_LEVEL loop
      st1 := justify (to_string (sl), left, st1'length);
      L := null;
      swrite (L, SEVERITY_LEVEL'image(sl), left, st1'length);
      assert (st1  = L.all)
        report "SEVERITY_LEVEL to_string (""" &  SEVERITY_LEVEL'image(sl)
        & """) /= " & st1
        severity error;
      deallocate (L);
    end loop;
    for fok in FILE_OPEN_KIND loop
      st1 := justify (to_string (fok), left, st1'length);
      L := null;
      swrite (L, FILE_OPEN_KIND'image(fok), left, st1'length);
      assert (st1  = L.all)
        report "FILE_OPEN_KIND to_string (""" & FILE_OPEN_KIND'image(fok)
        & """) /= " & st1
        severity error;
      deallocate (L);
    end loop;
    for fos in FILE_OPEN_STATUS loop
      st1 := justify (to_string (fos), left, st1'length);
      L := null;
      swrite (L, FILE_OPEN_STATUS'image(fos), left, st1'length);
      assert (st1  = L.all)
        report "FILE_OPEN_KIND to_string (""" & FILE_OPEN_STATUS'image(fos)
        & """) /= " & st1
        severity error;
      deallocate (L);
    end loop;
    for si in SIDE loop
      st1 := justify (to_string (si), right, st1'length);
      L := null;
      swrite (L, SIDE'image(si), right, st1'length);
      assert (st1  = L.all)
        report "SIDE to_string (""" & SIDE'image(si)
        & """) /= " & st1
        severity error;
      deallocate (L);
    end loop;
    int := 4;
    stx := to_string (int);
    assert (stx = INTEGER'image(int))
      report "integer to_string (" & INTEGER'image(int) & ") /= " & stx
      severity error;
    int := 1234;
    st1 := justify (to_string (int), right, st1'length);
    assert (st1 = "        " & INTEGER'image(int))
      report "integer to_string (" & INTEGER'image(int) & ") /= " & st1
      severity error;
    int := 9876;
    st7 := justify (to_string (int), left, st7'length);
    assert (st7 = INTEGER'image(int))
      report "integer to_string (" & INTEGER'image(int) & ") /= " & st7
      severity error;
    r := 3.0;
    L := null;

    -- XXX Nick: these tests seem wrong
    -- SWRITE (L, justify (to_string (r), left, st1'length));
    -- assert L.all = REAL'image(r)
    --   report "real to_string(" & REAL'image(r) & ") /= " & st1
    --   severity error;
    -- deallocate (L);
    -- L := null;
    -- r := 3.1415926585;
    -- SWRITE (L, to_string (r));
    -- assert L.all = REAL'image(r)
    --   report "real to_string(" & REAL'image(r) & ") /= " & st1
    --   severity error;
    -- deallocate (L);
    -- L := null;
    -- r := 5000000.0;
    -- SWRITE (L, justify (to_string (r), left, st1'length));
    -- assert L.all = REAL'image(r)
    --   report "real to_string(" & REAL'image(r) & ") /= " & st1
    --   severity error;
    -- t := 1 ns;
    -- st7 := to_string (t);
    -- assert (st7 = TIME'image(t))
    --   report "time to_string(" & TIME'image(t) & ") /= " & st7
    --   severity error;
    -- t := 1.1 us;                        -- %%% possible precision problem here.
    -- st1 := justify (to_string (t), left, st1'length);
    -- st2 := "1100 ns" & "     ";
    -- assert (st1 = st2)
    --   report "time to_string(" & TIME'image(t) & ") /= " & st1
    --   severity error;

    assert (quiet) report "string test complete" severity note;
    stringtest_done <= true;
    wait;
  end process stringtest;


-- purpose: test the TEE procedure
  teetest: process is
    constant file_name : string := "textfile";
    file ofile : text;
    constant food : string := "TEE function test Echoed to both Screen and file";
    variable open_status : file_open_status;
    variable L : line;
  begin
    wait until start_teetest;
    file_open (open_status, ofile, file_name, write_mode);
    assert (open_status = open_ok) report "File failed to open, "
      & file_open_status'image(open_status) severity error;
    L := null;
    write (L, food);
    tee (ofile, L);
--    assert (L.all = food) report "TEE command removed the string "
--      & L.all severity error;
--    L := null;
    swrite (L, "Second line, echoed to both screen and file");
    tee (ofile, L);
--    assert (L.all = "Second line, echoed to both screen and file")
--      report "TEE command removed the string "
--      & L.all severity error;
    file_close (ofile);
    file_open (open_status, ofile, file_name, read_mode);
    assert (open_status = open_ok) report "File failed to open, "
      & file_open_status'image(open_status) severity error;
    readline (ofile, L);
    assert (L.all = food) report "TEE readback of string, wrong data "
      & L.all severity error;
    readline (ofile, L);
    assert (L.all = "Second line, echoed to both screen and file")
      report "TEE readback command removed the string "
      & L.all severity error;
    file_close (ofile);
    assert (quiet)
      report "tee test complete" severity note;
    teetest_done <= true;
    wait;
  end process teetest;

--  vectest: process is
--    variable bv1, bv2 : boolean_vector (3 downto 0);
--    variable iv1, iv2 : integer_vector (3 downto 0);
--    variable rv1, rv2 : real_vector (3 downto 0);
--    variable tv1, tv2 : time_vector ( 3 downto 0);
--    variable L : LINE;
--    variable good : BOOLEAN;
--    variable t1, t2 : TIME;
--    variable si1, si2, si3    : SIDE;
--  begin
--    wait until start_vectest;
--    bv1 := (true, false, true, false);
--    write (L, bv1);
--    assert (L.all = "TRUE, FALSE, TRUE, FALSE")
--      report "Write (boolean_vector) returned " & L.all severity error;
--    read (L, bv2);
--    assert (bv1 = bv2)
--      report "Read (boolean_vector) returned" & to_string(bv2) severity error;
--    deallocate (L);
--    swrite (L, "false, true, false, true");
--    read (L, bv1, good);
--    assert (good)
--      report "Error encounted reading boolean_vector" severity error;
--    assert (bv1 = (false, true, false, true))
--      report "read (boolean_vector, good) returned " & to_string (bv2)
--      severity error;
--    bv1 := (true, false, true, false);
--    write (L, to_string (bv1));
--    assert (L.all = "TRUE, FALSE, TRUE, FALSE")
--      report "to_string (boolean_vector) returned " & L.all severity error;
--    deallocate (L);
--    -- integer vector
--    iv1 := (50, 61, 5000, -1);
--    write (L, iv1);
--    assert (L.all = "50, 61, 5000, -1")
--      report "Write (integer_vector) returned " & L.all severity error;
--    read (L, iv2);
--    assert (iv1 = iv2)
--      report "Read (integer_vector) returned" & to_string(iv2) severity error;
--    deallocate (L);
--    swrite (L, "17, 1245, 5000000, -100");
--    read (L, iv1, good);
--    assert (good)
--      report "Error encounted reading integer_vector" severity error;
--    assert (iv1 = (17, 1245, 5000000, -100))
--      report "read (integer_vector, good) returned " & to_string (iv2)
--      severity error;
--    iv1 := (50, 61, 5000, -1);
--    write (L, to_string (iv1));
--    assert (L.all = "50, 61, 5000, -1")
--      report "to_string (integer_vector) returned " & L.all severity error;
--    deallocate (L);
--    -- real vector
--    rv1 := (50.0, 61.2, 5000.0, -1.5);
--    write (L => L,
--           VALUE => rv1,
--           DIGITS => 1);
--    assert (L.all = "50.0, 61.2, 5000.0, -1.5")
--      report "Write (real_vector) returned " & L.all severity error;
--    read (L, rv2);
--    assert (rv1 = rv2)
--      report "Read (real_vector) returned" & to_string(rv2) severity error;
--    deallocate (L);
--    swrite (L, "17.0, 1245.25, 5000000.111, -100.5");
--    read (L, rv1, good);
--    assert (good)
--      report "Error encounted reading real_vector" severity error;
--    assert (rv1 = (17.0, 1245.25, 5000000.111, -100.5))
--      report "read (real_vector, good) returned " & to_string (rv1)
--      severity error;
--    deallocate (L);
--    rv1 := (50.0, 61.2, 5000.0, -1.5);
--    write (L, to_string (VALUE => rv1,
--                         DIGITS => 1));
--    assert (L.all = "50.0, 61.2, 5000.0, -1.5")
--      report "to_string (real_vector) returned " & L.all severity error;
--    deallocate (L);
--    rv1 := (50.0, 61.2, 5000.0, -1.5);
--    write (L, to_string (VALUE => rv1,
--                         format => "%g"));
--    assert (L.all = "50, 61.2, 5000, -1.5")
--      report "to_string (real_vector, format) returned " & L.all
--      severity error;
--    deallocate (L);
--    -- time vector
--    tv1 := (50 ns, 61 ns, 5000 ns, -1 ns);
--    write (L => L,
--           VALUE => tv1);
--    assert (L.all = "50 ns, 61 ns, 5000 ns, -1 ns")
--      report "Write (time_vector) returned " & L.all severity error;
--    read (L, tv2);
--    assert (tv1 = tv2)
--      report "Read (time_vector) returned " & to_string(tv2) severity error;
--    deallocate (L);
--    swrite (L, "50 ns, 61 ns, 5000 ns, -1 ns");
--    read (L, tv2, good);
--    assert (good)
--      report "Error encounted reading time_vector" severity error;
--    assert (tv1 = tv2)
--      report "Read (time_vector) returned " & to_string(tv2) severity error;
--    deallocate (L);

--    -- Ok, try some testcases.
--    swrite (L, "50 ns,");
--    read (L, t1);
--    assert (t1 = 50 ns) report "read(50 ns) returned " & TIME'image(t1) severity error;

--        si1 := right;
--    si2 := left;
--    si3 := maximum (si1, si2);
--    assert (si3 = si2) report "max (" & to_string(si1) & ", "
--      & to_string(si2) & ") = "& to_string(si3)
--      severity error;
--    si3 := maximum (si2, si1);
--    assert (si3 = si2) report "max (" & to_string(si2) & ", "
--      & to_string(si1) & ") = "& to_string(si3)
--      severity error;
--    si3 := minimum (si1, si2);
--    assert (si3 = si1) report "min (" & to_string(si1) & ", "
--      & to_string(si2) & ") = "& to_string(si3)
--      severity error;
--    si3 := minimum (si1, si2);
--    assert (si3 = si1) report "min (" & to_string(si2) & ", "
--      & to_string(si1) & ") = "& to_string(si3)
--      severity error;

--    assert (quiet)
--      report "Vector read and write test completed" severity note;
--    vectest_done <= true;
--    wait;
--  end process vectest;
end architecture testbench;
