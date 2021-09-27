-- --------------------------------------------------------------------
-- Title      : Test vectors for the textio routines.
--
--  Date: August 4, 2004. testcompile.
--
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org) 
-- -----------------------------------------------------------------------------
entity test_std_logic_textio is
  generic (
    quiet : BOOLEAN := false);          -- run quietly

end entity test_std_logic_textio;

library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;          -- Should be empty
architecture test of test_std_logic_textio is
  signal start_fileiotest, fileiotest_done : BOOLEAN := false;
begin
  process is
    variable L                          : LINE;
    variable value_std_ulogic           : STD_ULOGIC;
    variable value_std_ulogic_vector_12 : STD_ULOGIC_VECTOR(0 to 11);
    variable value_std_logic_vector_12  : STD_LOGIC_VECTOR(0 to 11);
    variable slv11                      : STD_LOGIC_VECTOR (0 to 10);
    variable sulv11                     : STD_ULOGIC_VECTOR (0 to 10);
    variable slv10                      : STD_LOGIC_VECTOR (0 to 9);
    variable sulv10                     : STD_ULOGIC_VECTOR (0 to 9);
    variable slvnull : STD_ULOGIC_VECTOR (1 to 0);  -- null
    variable good                       : BOOLEAN;
--    variable bv8 : bit_vector(7 downto 0) ;
--    variable bv5 : bit_vector(4 downto 0) ;
  begin
    -- Lets do a baseline with the behavior of bit_vectors
--    L := new string'("00000 11111");
--    read (L, bv8, good);
--    write(Output, "Good = " & boolean'image(good) & LF) ;
--    write(Output, "bv8  = " & to_string(to_stdlogicvector(bv8)) & LF) ;
--    read (L, bv5, good) ;
--    write(Output, "bv5  = " & to_string(to_stdlogicvector(bv5)) & LF) ;

--    L := new string'("11111 00000");
--    read (L, bv8, good);
--    write(Output, "Good = " & boolean'image(good) & LF) ;
--    write(Output, "bv8  = " & to_string(to_stdlogicvector(bv8)) & LF) ;
--    read (L, bv5, good) ;
--    write(Output, "bv5  = " & to_string(to_stdlogicvector(bv5)) & LF) ; 
    ---------------------------------------------------------------------------
    -- Test read-with-good for std_ulogic
    ---------------------------------------------------------------------------
    assert (quiet) report "Test read-with-good for std_ulogic" severity note;

    L := NULL;
    read (L, value_std_ulogic, good);
    assert not good report "null STRING read test" severity error;
    deallocate (L);

    L := new STRING'("");
    read (L, value_std_ulogic, good);
    assert not good report "Empty STRING read test" severity error;
    deallocate (L);

    L := new STRING'("  *");
    read (L, value_std_ulogic, good);
    assert not good report " * read test" severity error;
    deallocate (L);

    L := new STRING'("*");
    read (L, value_std_ulogic, good);
    assert not good report "* read test" severity error;
    deallocate (L);

    L := new STRING'("0");
    read (L, value_std_ulogic, good);
    assert good and value_std_ulogic = '0'
      report "0 read test" severity error;
    deallocate (L);

    L := new STRING'("  0");
    read (L, value_std_ulogic, good);
    assert good and value_std_ulogic = '0'
      report "  0 read test" severity error;
    deallocate (L);

    L := new STRING'("1");
    read (L, value_std_ulogic, good);
    assert good and value_std_ulogic = '1'
      report "1 read test" severity error;
    deallocate (L);

    L := new STRING'("X");
    read (L, value_std_ulogic, good);
    assert good and value_std_ulogic = 'X'
      report "X read test" severity error;
    deallocate (L);

    ---------------------------------------------------------------------------
    -- Test read-without-good for std_ulogic
    ---------------------------------------------------------------------------

    assert (quiet) report "Test read-without-good for std_ulogic"
      severity note;
    if (not quiet) then
      report "expect 4 assertion violation..." severity note;
      L := NULL;
      read (L, value_std_ulogic);
      L := new STRING'("");
      read (L, value_std_ulogic);
      deallocate (L);
      L := new STRING'("  *");
      read (L, value_std_ulogic);
      deallocate (L);
      L := new STRING'("*");
      read (L, value_std_ulogic);
      deallocate (L);
    end if;
    L := new STRING'("0");
    read (L, value_std_ulogic);
    assert value_std_ulogic = '0' report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  0");
    read (L, value_std_ulogic);
    assert value_std_ulogic = '0' report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("1");
    read (L, value_std_ulogic);
    assert value_std_ulogic = '1' report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("X");
    read (L, value_std_ulogic);
    assert value_std_ulogic = 'X' report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("X");
    read (L, value_std_ulogic);
    assert value_std_ulogic = 'X' report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    ---------------------------------------------------------------------------
    -- Test read-with-good for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test read-with-good for std_ulogic_vector"
      severity note;
    
    L := NULL;
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) null string" severity error;
    deallocate (L);

    L := new STRING'("");
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) empty string" severity error;
    deallocate (L);

    L := new STRING'("  *");
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) leading space with illegal character" severity error;
    deallocate (L);

    L := new STRING'("  *");
    read (L, slvnull, good);
    assert good report "read(STD_ULOGIC_VECTOR) slvnull" severity error;
    assert L.all(1) = '*' report "read(std_ulogic_vector) failed whitespace test" severity error;
    deallocate (L);

    
    L := new STRING'("  01HL*01");
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) leading space read with illegal character"
      severity error;
    deallocate (L);

    L := new STRING'("01HL*01");
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) read with illegal character"
      severity error;
    deallocate (L);

    L := new STRING'("  01HL01");
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) short read with leading space"
      severity error;
    deallocate (L);

    L := new STRING'("01HL01");
    read (L, value_std_ulogic_vector_12, good);
    assert not good report "read(STD_ULOGIC_VECTOR) short read" severity error;
    deallocate (L);

    L := new STRING'("00001111XXXX");
    read (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "00001111XXXX"
      report "read(STD_ULOGIC_VECTOR) read with X" severity error;
    deallocate (L);

    L := new STRING'("  00001111XXXX");
    read (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "00001111XXXX"
      report "read(STD_ULOGIC_VECTOR) leading space" severity error;
    deallocate (L);

    L := new STRING'("0000_1111_XXXX");
    read (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "00001111XXXX"
      report "read(STD_ULOGIC_VECTOR) _ test" severity error;
    deallocate (L);

    L := new STRING'("  0000_1111_X_XXX");
    read (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "00001111XXXX"
      report "read(STD_ULOGIC_VECTOR) leading space and _ test" severity error;
    deallocate (L);

    L := new STRING'("_0000_1111_XXXX");
    read (L, value_std_ulogic_vector_12, good);
    assert not good
      report "read(STD_ULOGIC_VECTOR) leading _ not detected" severity error;
    deallocate (L);

    L := new STRING'("  0000_1111_X__XXX");
    read (L, value_std_ulogic_vector_12, good);
    assert not good
      report "read(STD_ULOGIC_VECTOR) double _ not detected" severity error;
    deallocate (L);

    L := new string'("0001_0010_0011 0100_0101_1000");
    read (L, value_std_ulogic_vector_12, good);
    assert good report "Read(std_ulogic_vector) long vector error"
      severity error;
    assert value_std_ulogic_vector_12 = "000100100011"
      report "read(std_ulogic_vector) long vector returned "
      & to_string(value_std_ulogic_vector_12) severity error;

    read (L, value_std_ulogic_vector_12, good);
    assert good report "Read(std_ulogic_vector) 2ns long vector error"
      severity error;
    assert value_std_ulogic_vector_12 = "010001011000"
      report "read(std_ulogic_vector) 2nd long vector returned "
      & to_string(value_std_ulogic_vector_12) severity error;
    
    ---------------------------------------------------------------------------
    -- Test read-without-good for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test read-without-good for std_ulogic_vector"
      severity note;
    
    if (not quiet) then
      report "expect 7 assertion violation..." severity note;
      L := NULL;
      read (L, value_std_ulogic_vector_12);
      L := new STRING'("");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  *");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  01HL*01");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("01HL*01");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  01HL01");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("01HL01");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
    end if;

    L := NULL;
    read (L, slvnull);
    -- Should not report an error.

    L := new STRING'("   *");
    read (L, slvnull);
    assert L.all(1) = '*' report "read w/o good Null string failed whitespace" severity error;
    
    L := new STRING'("00001111XXXX");
    read (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  00001111XXXX");
    read (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("0000_1111_XXXX");
    read (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  0000_1111_X_XXX");
    read (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    if (not quiet) then
      report "expect 2 assertion violation..." severity note;
      L := new STRING'("_0000_1111_XXXX");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  0000_1111_X__XXX");
      read (L, value_std_ulogic_vector_12);
      deallocate (L);
    end if;
    ---------------------------------------------------------------------------
    -- Test write for std_ulogic
    ---------------------------------------------------------------------------

    assert (quiet) report "Test write for std_ulogic" severity note;

    L := null;
    write (L, STD_ULOGIC'('U'));
    assert L.all = "U" report "write(std_ulogic) U = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('0'));
    assert L.all = "0" report "write(std_ulogic) 0 = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('1'));
    assert L.all = "1" report "write(std_ulogic) 1 = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('X'));
    assert L.all = "X" report "write(std_ulogic) X = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('Z'));
    assert L.all = "Z" report "write(std_ulogic) Z = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('L'));
    assert L.all = "L" report "write(std_ulogic) L = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('H'));
    assert L.all = "H" report "write(std_ulogic) H = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('W'));
    assert L.all = "W" report "write(std_ulogic) W = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('-'));
    assert L.all = "-" report "write(std_ulogic) - = " & L.all severity error;

    L := null;
    write (L, STD_ULOGIC'('U'),
            field => 4);
    assert L.all = "   U" report "write(std_ulogic) U field 4 = """ & L.all & '"' severity error;

    L := null;
    write (L, STD_ULOGIC'('U'),
            justified => left, field => 4);
    assert L.all = "U   " report "write(std_ulogic) U justify left, field 4 = """ & L.all & '"' severity error;

    ---------------------------------------------------------------------------
    -- Test write for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test write for std_ulogic_vector"
      severity note;
    
    L := null;
    write (L, STD_ULOGIC_VECTOR'("U01XZLHW-"));
    assert L.all = "U01XZLHW-" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    write (L, STD_ULOGIC_VECTOR'("U01XZLHW-"),
            field => 12);
    assert L.all = "   U01XZLHW-" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    write (L, STD_ULOGIC_VECTOR'("U01XZLHW-"),
            justified => left, field => 12);
    assert L.all = "U01XZLHW-   " report "TEST_STD_LOGIC_TEXTIO" severity error;

    ---------------------------------------------------------------------------
    -- Test read-with-good for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test read-with-good for std_logic_vector"
      severity note;
    
    L := new STRING'("");
    read (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  *");
    read (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  01HL*01");
    read (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("01HL*01");
    read (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  01HL01");
    read (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("01HL01");
    read (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("00001111XXXX");
    read (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  00001111XXXX");
    read (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("0000_1111_XXXX");
    read (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  0000_1111_X_XXX");
    read (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    ---------------------------------------------------------------------------
    -- Test read-without-good for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test read-without-good for std_logic_vector"
      severity note;
    if (not quiet) then
      report "expect 6 assertion violation..." severity note;
      L := new STRING'("");
      read (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  *");
      read (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  01HL*01");
      read (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("01HL*01");
      read (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  01HL01");
      read (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("01HL01");
      read (L, value_std_logic_vector_12);
      deallocate (L);
    end if;

    L := new STRING'("00001111XXXX");
    read (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  00001111XXXX");
    read (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("0000_1111_XXXX");
    read (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  0000_1111_XXXX");
    read (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "00001111XXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    L := new string'("0001_0010_0011 0100_0101_1000");
    read (L, value_std_logic_vector_12, good);
    assert good report "Read(std_logic_vector) long vector error"
      severity error;
    assert value_std_logic_vector_12 = "000100100011"
      report "read(std_logic_vector) long vector returned "
      & to_string(value_std_logic_vector_12) severity error;

    read (L, value_std_logic_vector_12, good);
    assert good report "Read(std_logic_vector) 2ns long vector error"
      severity error;
    assert value_std_logic_vector_12 = "010001011000"
      report "read(std_logic_vector) 2nd long vector returned "
      & to_string(value_std_logic_vector_12) severity error;

---------------------------------------------------------------------------
    -- Test write for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test write for std_logic_vector" severity note;

    L := null;
    write (L, STD_LOGIC_VECTOR'("U01XZLHW-"));
    assert L.all = "U01XZLHW-" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    write (L, STD_LOGIC_VECTOR'("U01XZLHW-"),
            field => 12);
    assert L.all = "   U01XZLHW-" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    write (L, STD_LOGIC_VECTOR'("U01XZLHW-"),
            justified => left, field => 12);
    assert L.all = "U01XZLHW-   " report "TEST_STD_LOGIC_TEXTIO" severity error;

    ---------------------------------------------------------------------------
    -- Test hex read-with-good for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test hex read-with-good for std_ulogic_vector"
      severity note;
    
    L := new STRING'("");
    hread (L, value_std_ulogic_vector_12, good);
    assert not good report "Null STRING hread std_ulogic_vector" severity error;
    deallocate (L);

    L := new STRING'("  *");
    hread (L, value_std_ulogic_vector_12, good);
    assert not good report "  * hread std_ulogic_vector" severity error;
    deallocate (L);

    L := new STRING'("  00*");
    hread (L, value_std_ulogic_vector_12, good);
    assert not good report "  00* hread std_ulogic_vector" severity error;
    deallocate (L);

    L := new STRING'("00*");
    hread (L, value_std_ulogic_vector_12, good);
    assert not good report "00* hread std_ulogic_vector" severity error;
    deallocate (L);

    L := new STRING'("  00");
    hread (L, value_std_ulogic_vector_12, good);
    assert not good report "  00 hread std_ulogic_vector" severity error;
    deallocate (L);

    L := new STRING'("00");
    hread (L, value_std_ulogic_vector_12, good);
    assert not good report "00 hread std_ulogic_vector" severity error;
    deallocate (L);

    L := new STRING'("9ZX");
    hread (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "1001ZZZZXXXX"
      report "hread(9ZX) SUV = " & to_string (value_std_ulogic_vector_12)
      severity error;
    deallocate (L);

    L := new STRING'("  9ZX");
    hread (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "1001ZZZZXXXX"
      report "hread (  9ZX) SUV = " & to_string (value_std_ulogic_vector_12)
      severity error;
    deallocate (L);

    L := new STRING'("7fe");
    hread (L, sulv11, good);
    assert (good) report "Read of short vector" severity error;
    assert (sulv11 = "11111111110")
      report "hread (7fe) = " & to_string (sulv11) severity error;
    deallocate (L);
    L := new STRING'("dcb");
    hread (L, sulv11, good);
    assert (not good) report "Read of short vector good" severity error;
    deallocate (L);
    L := new STRING'("0bc");
    hread (L, sulv10, good);
    assert (good) report "Read of short vector good" severity error;
    assert (sulv10 = "0010111100")
      report "hread (0bc) = " & to_string (sulv11) severity error;
    deallocate (L);
    L := new STRING'("abc");
    hread (L, sulv10, good);
    assert (not good) report "Read of short vector good" severity error;
    deallocate (L);
    L := new STRING'("XZX");
    hread (L, value_std_ulogic_vector_12, good);
    assert (good) report "Read of XZX" severity error;
    assert (value_std_ulogic_vector_12 = "XXXXZZZZXXXX")
      report "hread (XZX) = " & to_string (value_std_ulogic_vector_12)
      severity error;
    -- test the "_" stuff
    L := new string'("1_19");
    hread (L, value_std_ulogic_vector_12, good);
    assert (good) report "Read of 1_19" severity error;
    assert (value_std_ulogic_vector_12 = "000100011001")
      report "hread (1_19) = " & to_string (value_std_ulogic_vector_12)
      severity error;
    L := new string'(" 1_19");
    hread (L, value_std_ulogic_vector_12, good);
    assert (good) report "Read of 1_19" severity error;
    assert (value_std_ulogic_vector_12 = "000100011001")
      report "hread ( 1_19) = " & to_string (value_std_ulogic_vector_12)
      severity error;
    L := new string'("_1_19");
    hread (L, value_std_ulogic_vector_12, good);
    assert (not good) report "Read of _1_19" severity error;
    L := new string'(" 1__19");
    hread (L, value_std_ulogic_vector_12, good);
    assert (not good) report "Read of 1__19" severity error;
    ---------------------------------------------------------------------------
    -- Test hex read-without-good for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet)
      report "Test hex read-without-good for std_ulogic_vector"
      severity note;
    
    if (not quiet) then
      report "expect 8 assertion violation..." severity note;
      L := new STRING'("");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  *");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  00*");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("00*");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  00");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("00");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("dcb");
      hread (L, sulv11);
      deallocate (L);
      L := new STRING'("abc");
      hread (L, sulv10);
      deallocate (L);
    end if;

    L := new STRING'("9ZX");
    hread (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "1001ZZZZXXXX"
      report "hread (9ZX) = "
      & to_string (value_std_ulogic_vector_12)
      severity error;
    deallocate (L);

    L := new STRING'("  Z9X");
    hread (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "ZZZZ1001XXXX"
      report "hread (   Z9X) = "
      & to_string (value_std_ulogic_vector_12)
      severity error;
    deallocate (L);
    L := new STRING'("7fe");
    hread (L, sulv11);
    assert (sulv11 = "11111111110")
      report "hread (7fe) = " & to_string (sulv11) severity error;
    deallocate (L);
    L := new STRING'("0bc");
    hread (L, sulv10);
    assert (sulv10 = "0010111100")
      report "hread (0bc) = " & to_string (sulv11) severity error;
    deallocate (L);
    L := new string'("1_19");
    hread (L, value_std_ulogic_vector_12);
    assert (value_std_ulogic_vector_12 = "000100011001")
      report "hread (1_19) = " & to_string (value_std_ulogic_vector_12)
      severity error;
    deallocate (L);
    L := new string'(" 1_19");
    hread (L, value_std_ulogic_vector_12);
    assert (value_std_ulogic_vector_12 = "000100011001")
      report "hread ( 1_19) = " & to_string (value_std_ulogic_vector_12)
      severity error;
    deallocate (L);
    if (not quiet) then
      report "expect 2 assertion violation..." severity note;
      L := new string'("_1_19");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new string'(" 1__19");
      hread (L, value_std_ulogic_vector_12);
      deallocate (L);
    end if;
    L := new string'("2_3445_7");
    hread (L, value_std_ulogic_vector_12);
    assert (value_std_ulogic_vector_12 = "001000110100")
      report "HREAD(2_34) LONG returned "
      & to_string (value_std_ulogic_vector_12) severity error;
    hread (L, value_std_ulogic_vector_12);
    assert (value_std_ulogic_vector_12 = "010001010111")
      report "HREAD(45_7) LONG returned "
      & to_string (value_std_ulogic_vector_12) severity error;
    
    ---------------------------------------------------------------------------
    -- Test hex write for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test hex write for std_ulogic_vector"
      severity note;
    
    L := null;
    hwrite (L, STD_ULOGIC_VECTOR'("00001001ZZZZXXXX10UU"));
    assert L.all = "09ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    hwrite (L, STD_ULOGIC_VECTOR'("00001001ZZZZXXXX10UU"),
             field => 8);
    assert L.all = "   09ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    hwrite (L, STD_ULOGIC_VECTOR'("00001001ZZZZXXXX10UU"),
             justified => left, field => 8);
    assert L.all = "09ZXX   " report "TEST_STD_LOGIC_TEXTIO" severity error;

    ---------------------------------------------------------------------------
    -- Test hex read-with-good for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test hex read-with-good for std_logic_vector"
      severity note;
    
    L := new STRING'("");
    hread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  *");
    hread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  00*");
    hread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("00*");
    hread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  00");
    hread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := new STRING'("00");
    hread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("9ZX");
    hread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  9ZX");
    hread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    L := new STRING'("9Z_X");
    hread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  9_ZX");
    hread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    
    L := new STRING'("7fe");
    hread (L, slv11, good);
    assert (good) report "Read of short vector" severity error;
    assert (slv11 = "11111111110")
      report "hread (7fe) = " & to_string (slv11) severity error;
    deallocate (L);
    L := new STRING'("dcb");
    hread (L, slv11, good);
    assert (not good) report "Read of short vector good" severity error;
    deallocate (L);
    L := new STRING'("0bc");
    hread (L, slv10, good);
    assert (good) report "Read of short vector good" severity error;
    assert (slv10 = "0010111100")
      report "hread (0bc) = " & to_string (slv11) severity error;
    deallocate (L);
    L := new STRING'("abc");
    hread (L, slv10, good);
    assert (not good) report "Read of short vector good" severity error;
    deallocate (L);
    ---------------------------------------------------------------------------
    -- Test hex read-without-good for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test hex read-without-good for std_logic_vector"
      severity note;
    
    if (not quiet) then
      report "expect 8 assertion violation..." severity note;
      L := new STRING'("");
      hread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  *");
      hread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  00*");
      hread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("00*");
      hread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  00");
      hread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("00");
      hread (L, value_std_logic_vector_12);
      deallocate (L);
      hread (L, slv11);
      deallocate (L);
      L := new STRING'("abc");
      hread (L, slv10);
      deallocate (L);
    end if;

    L := new STRING'("9ZX");
    hread (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  9ZX");
    hread (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    L := new STRING'("9_ZX");
    hread (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  9Z_X");
    hread (L, value_std_logic_vector_12);
    assert value_std_logic_vector_12 = "1001ZZZZXXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    L := new STRING'("7fe");
    hread (L, slv11);
    assert (slv11 = "11111111110")
      report "hread (7fe) = " & to_string (slv11) severity error;
    deallocate (L);
    L := new STRING'("0bc");
    hread (L, slv10);
    assert (slv10 = "0010111100")
      report "hread (0bc) = " & to_string (slv11) severity error;
    deallocate (L);
    L := new STRING'("dcb");
    ---------------------------------------------------------------------------
    -- Test hex write for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test hex write for std_logic_vector"
      severity note;
    
    L := null;
    hwrite (L, STD_LOGIC_VECTOR'("00001001ZZZZXXXX10UU"));
    assert L.all = "09ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    hwrite (L, STD_LOGIC_VECTOR'("00001001ZZZZXXXX10UU"),
             field => 8);
    assert L.all = "   09ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    hwrite (L, STD_LOGIC_VECTOR'("00001001ZZZZXXXX10UU"),
             justified => left, field => 8);
    assert L.all = "09ZXX   " report "TEST_STD_LOGIC_TEXTIO" severity error;

    ---------------------------------------------------------------------------
    -- Test octal read-with-good for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test octal read-with-good for std_ulogic_vector"
      severity note;
    
    L := new STRING'("");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good report "oread(std_ulogic_vector) NULL string" severity error;
    deallocate (L);

    L := new STRING'("  *");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good report "oread(std_ulogic_vector) bad character" severity error;
    deallocate (L);

    L := new STRING'("  000*");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good report "oread(std_ulogic_vector) bad CHARACTER in STRING with leading spaces" severity error;
    deallocate (L);

    L := new STRING'("000*");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good report "oread(std_ulogic_vector) bad CHARACTER in STRING" severity error;
    deallocate (L);

    L := new STRING'("  00");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good report "oread(std_ulogic_vector) short read with leading spaces" severity error;
    deallocate (L);

    L := new STRING'("00");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good report "oread(std_ulogic_vector) short read" severity error;
    deallocate (L);

    L := new STRING'("63ZX");
    oread (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "110011ZZZXXX"
      report "oread(std_ulogic_vector) read of 63ZX = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("  63ZX");
    oread (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "110011ZZZXXX"
      report "oread(std_ulogic_vector) leading space read of 63ZX = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("63_ZX");
    oread (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "110011ZZZXXX"
      report "oread(std_ulogic_vector) read of 63_ZX = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("  6_3_Z_X");
    oread (L, value_std_ulogic_vector_12, good);
    assert good and value_std_ulogic_vector_12 = "110011ZZZXXX"
      report "oread(std_ulogic_vector) leading space read of 6_3_Z_X = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("_63_ZX");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good
      report "OREAD (STD_ULOGIC_VECTOR) leading _ test" severity error;
    deallocate (L);

    L := new STRING'("  6_3__Z_X");
    oread (L, value_std_ulogic_vector_12, good);
    assert not good
      report "OREAD (STD_ULOGIC_VECTOR) double _ test" severity error;
    deallocate (L);

    L := new string'("01234567");
    oread (L, value_std_ulogic_vector_12, good);
    assert good
      report "OREAD(0123) returned not good" severity error;
    assert value_std_ulogic_vector_12 = "000001010011"
      report "oread(0123) returned " & to_string(value_std_ulogic_vector_12)
      severity error;
    oread (L, value_std_ulogic_vector_12, good);
    assert good
      report "OREAD(4567) returned not good" severity error;
    assert value_std_ulogic_vector_12 = "100101110111"
      report "oread(4567) returned " & to_string(value_std_ulogic_vector_12)
      severity error;
    deallocate (L);

    L := new string'("             7654    3210");
    oread (L, value_std_ulogic_vector_12, good);
    assert good
      report "OREAD(7654) returned not good" severity error;
    assert value_std_ulogic_vector_12 = "111110101100"
      report "oread(7654) returned " & to_string(value_std_ulogic_vector_12)
      severity error;
    oread (L, value_std_ulogic_vector_12, good);
    assert good
      report "OREAD(3210) returned not good" severity error;
    assert value_std_ulogic_vector_12 = "011010001000"
      report "oread(3210) returned " & to_string(value_std_ulogic_vector_12)
      severity error;
    deallocate (L);
    ---------------------------------------------------------------------------
    -- Test octal read-without-good for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet)
      report "Test octal read-without-good for std_ulogic_vector"
      severity note;
    
    if (not quiet) then
      report "expect 6 assertion violation..." severity note;
      L := new STRING'("");
      oread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  *");
      oread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  000*");
      oread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("000*");
      oread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("  00");
      oread (L, value_std_ulogic_vector_12);
      deallocate (L);
      L := new STRING'("00");
      oread (L, value_std_ulogic_vector_12);
      deallocate (L);
    end if;

    L := new STRING'("63ZX");
    oread (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "110011ZZZXXX"
      report "oread(std_ulogic_vector) w/o good read of 63ZX = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("  63ZX");
    oread (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "110011ZZZXXX"
     report "oread(std_ulogic_vector) leading space w/o good read of 63ZX = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("63_ZX");
    oread (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "110011ZZZXXX"
     report "oread(std_ulogic_vector) w/o good read of 63_ZX = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    L := new STRING'("  6_3_Z_X");
    oread (L, value_std_ulogic_vector_12);
    assert value_std_ulogic_vector_12 = "110011ZZZXXX"
     report "oread(std_ulogic_vector) w/o good read of 6_3_Z_X = " &
      to_string (value_std_ulogic_vector_12) severity error;
    deallocate (L);

    if (not quiet) then
      report "expect 2 assertion violation..." severity note;
      L := new STRING'("_63_ZX");
      oread (L, value_std_ulogic_vector_12);
--      assert not good
--        report "oread(std_ulogic_vector) leading underscore" severity error;
      deallocate (L);

      L := new STRING'("  6_3__Z_X");
      oread (L, value_std_ulogic_vector_12);
--      assert not good
--        report "oread(std_ulogic_vector) double underscore" severity error;
      deallocate (L);
    end if;

    ---------------------------------------------------------------------------
    -- Test octal write for std_ulogic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test octal write for std_ulogic_vector"
      severity note;
    
    L := null;
    owrite (L, STD_ULOGIC_VECTOR'("000101ZZZXXX10U"));
    assert L.all = "05ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    owrite (L, STD_ULOGIC_VECTOR'("000101ZZZXXX10U"),
             field => 8);
    assert L.all = "   05ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    owrite (L, STD_ULOGIC_VECTOR'("000101ZZZXXX10U"),
             justified => left, field => 8);
    assert L.all = "05ZXX   " report "TEST_STD_LOGIC_TEXTIO" severity error;

    ---------------------------------------------------------------------------
    -- Test octal read-with-good for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test octal read-with-good for std_logic_vector"
      severity note;
    
    L := new STRING'("");
    oread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  *");
    oread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  00*");
    oread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("00*");
    oread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  000");
    oread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("000");
    oread (L, value_std_logic_vector_12, good);
    assert not good report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("63ZX");
    oread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  63ZX");
    oread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("63_ZX");
    oread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  6_3_Z_X");
    oread (L, value_std_logic_vector_12, good);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    ---------------------------------------------------------------------------
    -- Test octal read-without-good for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test octal read-without-good for std_logic_vector"
      severity note;
    
    if (not quiet) then
      report "expect 6 assertion violation..." severity note;
      L := new STRING'("");
      oread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  *");
      oread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  00*");
      oread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("00*");
      oread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("  000");
      oread (L, value_std_logic_vector_12);
      deallocate (L);
      L := new STRING'("000");
      oread (L, value_std_logic_vector_12);
      deallocate (L);
    end if;

    L := new STRING'("63ZX");
    oread (L, value_std_logic_vector_12);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  63ZX");
    oread (L, value_std_logic_vector_12);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("63_ZX");
    oread (L, value_std_logic_vector_12);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);

    L := new STRING'("  6_3_Z_X");
    oread (L, value_std_logic_vector_12);
    assert good and value_std_logic_vector_12 = "110011ZZZXXX"
      report "TEST_STD_LOGIC_TEXTIO" severity error;
    deallocate (L);
    ---------------------------------------------------------------------------
    -- Test octal write for std_logic_vector
    ---------------------------------------------------------------------------

    assert (quiet) report "Test octal write for std_logic_vector"
      severity note;
    
    L := null;
    owrite (L, STD_LOGIC_VECTOR'("000101ZZZXXX10U"));
    assert L.all = "05ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    owrite (L, STD_LOGIC_VECTOR'("000101ZZZXXX10U"),
             field => 8);
    assert L.all = "   05ZXX" report "TEST_STD_LOGIC_TEXTIO" severity error;

    L := null;
    owrite (L, STD_LOGIC_VECTOR'("000101ZZZXXX10U"),
             justified => left, field => 8);
    assert L.all = "05ZXX   " report "TEST_STD_LOGIC_TEXTIO" severity error;

    start_fileiotest <= true;
    wait until fileiotest_done;
    ---------------------------------------------------------------------------
    report "std_logic_textio test complete";
    ---------------------------------------------------------------------------
    wait;
  end process;

  fileio : process
    constant filename    : STRING := "textfile";
    file testfile        : TEXT;
    variable file_status : FILE_OPEN_STATUS;
    variable MyLine      : LINE;
    variable slv         : STD_LOGIC_VECTOR(3 downto 0);
    variable sulv        : STD_ULOGIC_VECTOR(3 downto 0);
    variable hslv        : STD_LOGIC_VECTOR (15 downto 0);  -- hex
    variable oslv        : STD_LOGIC_VECTOR (11 downto 0);  -- octal
    variable sl          : STD_LOGIC;
    variable sul         : STD_ULOGIC;
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
    Myline := new STRING'("");                              -- blank LINE
    writeline (testfile, Myline);
    Myline := new STRING'("0101 ");
    writeline (testfile, Myline);
    Myline := new STRING'(" ");                             -- just a space
    writeline (testfile, Myline);
    Myline := new STRING'(HT & "0110 ");
    writeline (testfile, Myline);
    Myline := new STRING'(CHARACTER'val(160) & "0111");     -- nbsp
    writeline (testfile, Myline);
    Myline := new STRING'("%000");
    writeline (testfile, Myline);
    Myline := new STRING'("0%00");
    writeline (testfile, Myline);
    Myline := new STRING'("000%");
    writeline (testfile, Myline);
    Myline := new STRING'("111");                           -- short STRING
    writeline (testfile, Myline);
    Myline := new STRING'("00111");                         -- big STRING
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
    flush (testfile);
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
    assert (slv = "0001")
      report "Read SLV 1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0010")
      report "Read SLV 2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0011")
      report "Read SLV 3 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0100")
      report "Read SLV 4 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, slv);
      assert (slv = "UUUU")
        report "Read SLV blank returned " & to_string(slv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0101")
      report "Read SLV 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, slv);
      assert (slv = "UUUU")
        report "Read SLV space returned " & to_string(slv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0110")
      report "Read SLV 6 HT returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0111")
      report "Read SLV 7 NBSP returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 read errors here" severity note;
      read(MyLine, slv);
      assert (slv = "UUUU")
        report "Read SLV space returned " & to_string(slv) severity error;
      readline(testfile, MyLine);
      read(MyLine, slv);
      assert (slv = "UUUU")
        report "Read SLV space returned " & to_string(slv) severity error;
      readline(testfile, MyLine);
      read(MyLine, slv);
      assert (slv = "UUUU")
        report "Read SLV space returned " & to_string(slv) severity error;
      readline(testfile, MyLine);
      read(MyLine, slv);
      assert (slv = "UUUU")
        report "Read SLV space returned " & to_string(slv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "0011")
      report "Read SLV 7 extra returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "UXWZ")
      report "Read SLV X1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "HL-Z")
      report "Read SLV X2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "1010")
      report "Read SLV A returned " & to_string(slv) severity error;
    read(MyLine, slv);
    assert (slv = "0101")
      report "Read SLV A 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "1011")
      report "Read SLV B returned " & to_string(slv) severity error;
    read(MyLine, slv);
    assert (slv = "1101")
      report "Read SLV B D returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv);
    assert (slv = "1111")
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
    assert (sulv = "0001")
      report "Read SULV 1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0010")
      report "Read SULV 2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0011")
      report "Read SULV 3 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0100")
      report "Read SULV 4 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, sulv);
      assert (sulv = "UUUU")
        report "Read SULV blank returned " & to_string(sulv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0101")
      report "Read SULV 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, sulv);
      assert (sulv = "UUUU")
        report "Read SULV space returned " & to_string(sulv) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0110")
      report "Read SULV 6 HT returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0111")
      report "Read SULV 7 NBSP returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 4 read errors here" severity note;
      read(MyLine, sulv);
      assert (sulv = "UUUU")
        report "Read SULV space returned " & to_string(sulv) severity error;
      readline(testfile, MyLine);
      read(MyLine, sulv);
      assert (sulv = "UUUU")
        report "Read SULV space returned " & to_string(sulv) severity error;
      readline(testfile, MyLine);
      read(MyLine, sulv);
      assert (sulv = "UUUU")
        report "Read SULV space returned " & to_string(sulv) severity error;
      readline(testfile, MyLine);
      read(MyLine, sulv);
      assert (sulv = "UUUU")
        report "Read SULV space returned " & to_string(sulv) severity error;
    else
      readline(testfile, MyLine);
      readline(testfile, MyLine);
      readline(testfile, MyLine);
    end if;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "0011")
      report "Read SULV 7 extra returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "UXWZ")
      report "Read SULV X1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "HL-Z")
      report "Read SULV X2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "1010")
      report "Read SULV A returned " & to_string(sulv) severity error;
    read(MyLine, sulv);
    assert (sulv = "0101")
      report "Read SULV A 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "1011")
      report "Read SULV B returned " & to_string(sulv) severity error;
    read(MyLine, sulv);
    assert (sulv = "1101")
      report "Read SULV B D returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv);
    assert (sulv = "1111")
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
    assert (slv = "0001")
      report "Read SLV 1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0010")
      report "Read SLV 2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 3 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0011")
      report "Read SLV 3 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 4 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0100")
      report "Read SLV 4 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV blank returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UUUU")
      report "Read SLV blank returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0101")
      report "Read SLV 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UUUU")
      report "Read SLV space returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 6 HT returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0110")
      report "Read SLV 6 HT returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 7 NBSP returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0111")
      report "Read SLV 7 NBSP returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UUUU")
      report "Read SLV space returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UUUU")
      report "Read SLV space returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UUUU")
      report "Read SLV space returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (not ok) report "Read SLV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UUUU")
      report "Read SLV space returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV 7 extra returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0011")
      report "Read SLV 7 extra returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV X1 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "UXWZ")
      report "Read SLV X1 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV X2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "HL-Z")
      report "Read SLV X2 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV A returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "1010")
      report "Read SLV A returned " & to_string(slv) severity error;
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV A 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "0101")
      report "Read SLV A 5 returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV B returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "1011")
      report "Read SLV B returned " & to_string(slv) severity error;
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV B D returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "1101")
      report "Read SLV B D returned " & to_string(slv) severity error;
    readline(testfile, MyLine);
    read(MyLine, slv, ok);
    assert (ok) report "Read SLV F returned " & BOOLEAN'image(ok)
      severity error;
    assert (slv = "1111")
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
    assert (sulv = "0001")
      report "Read SULV 1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0010")
      report "Read SULV 2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 3 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0011")
      report "Read SULV 3 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 4 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0100")
      report "Read SULV 4 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV blank returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UUUU")
      report "Read SULV blank returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0101")
      report "Read SULV 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UUUU")
      report "Read SULV space returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 6 HT returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0110")
      report "Read SULV 6 HT returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 7 NBSP returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0111")
      report "Read SULV 7 NBSP returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UUUU")
      report "Read SULV space returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UUUU")
      report "Read SULV space returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UUUU")
      report "Read SULV space returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (not ok) report "Read SULV space returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UUUU")
      report "Read SULV space returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV 7 extra returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0011")
      report "Read SULV 7 extra returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV X1 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "UXWZ")
      report "Read SULV X1 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV X2 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "HL-Z")
      report "Read SULV X2 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV A returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "1010")
      report "Read SULV A returned " & to_string(sulv) severity error;
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV A 5 returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "0101")
      report "Read SULV A 5 returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV B returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "1011")
      report "Read SULV B returned " & to_string(sulv) severity error;
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV B D returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "1101")
      report "Read SULV B D returned " & to_string(sulv) severity error;
    readline(testfile, MyLine);
    read(MyLine, sulv, ok);
    assert (ok) report "Read SULV F returned " & BOOLEAN'image(ok)
      severity error;
    assert (sulv = "1111")
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
      assert (hslv = "UUUUUUUUUUUUUUUU")
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
      assert (hslv = "UUUUUUUUUUUUUUUU")
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
      assert (hslv = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV space returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "UUUUUUUUUUUUUUUU")
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
      assert (hslv = "UUUUUUUUUUUUUUUU")
        report "Hread HSLV X1 returned " & to_string(hslv) severity error;
      readline(testfile, MyLine);
      hread(MyLine, hslv);
      assert (hslv = "UUUUUUUUUUUUUUUU")
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
      assert (oslv = "UUUUUUUUUUUU")
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
      assert (oslv = "UUUUUUUUUUUU")
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
      assert (oslv = "UUUUUUUUUUUU")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "UUUUUUUUUUUU")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "UUUUUUUUUUUU")
        report "Oread OSLV space returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "UUUUUUUUUUUU")
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
      assert (oslv = "UUUUUUUUUUUU")
        report "Oread OSLV X1 returned " & to_string(oslv) severity error;
      readline(testfile, MyLine);
      oread(MyLine, oslv);
      assert (oslv = "UUUUUUUUUUUU")
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
    assert (hslv = "UUUUUUUUUUUUUUUU")
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
    assert (hslv = "UUUUUUUUUUUUUUUU")
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
    assert (hslv = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV space returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread space returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV space returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread bad char 2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "UUUUUUUUUUUUUUUU")
      report "hread bad char 2 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread bad char 4 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "UUUUUUUUUUUUUUUU")
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
    assert (hslv = "UUUUUUUUUUUUUUUU")
      report "Hread HSLV X1 returned " & to_string(hslv) severity error;
    readline(testfile, MyLine);
    hread(MyLine, hslv, ok);
    assert (not ok) report "hread SLV X2 returned boolean "
      & BOOLEAN'image(ok) severity error;
    assert (hslv = "UUUUUUUUUUUUUUUU")
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
    assert (oslv = "UUUUUUUUUUUU")
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
    assert (oslv = "UUUUUUUUUUUU")
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
    assert (oslv = "UUUUUUUUUUUU")
      report "Oread OSLV 1 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 2 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "UUUUUUUUUUUU")
      report "Oread OSLV 2 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV 4 % returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "UUUUUUUUUUUU")
      report "Oread OSLV 4 % returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread short returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "UUUUUUUUUUUU")
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
    assert (oslv = "UUUUUUUUUUUU")
      report "Oread OSLV X1 returned " & to_string(oslv) severity error;
    readline(testfile, MyLine);
    oread(MyLine, oslv, ok);
    assert (not Ok) report "oread OSLV X2 returned boolean "
      & BOOLEAN 'image(Ok) severity error;
    assert (oslv = "UUUUUUUUUUUU")
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
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 1 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 2 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 3 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 4 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, sl);
      assert (sl = 'U')
        report "Read SL blank returned " & to_string(sl) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 5 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect a read error here" severity note;
      read(MyLine, sl);
      assert (sl = 'U')
        report "Read SL space returned " & to_string(sl) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 6 HT returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 7 NBSP returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    if (not quiet) then
      report "Expect 1 read errors here" severity note;
      read(MyLine, sl);
      assert (sl = 'U')
        report "Read SL %000 returned " & to_string(sl) severity error;
    end if;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 0% returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 000% returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '1')
      report "Read SL 111 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL 7 extra returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = 'U')
      report "Read SL X1 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = 'H')
      report "Read SL X2 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '1')
      report "Read SL A returned " & to_string(sl) severity error;
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL A 5 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '1')
      report "Read SL B returned " & to_string(sl) severity error;
    read(MyLine, sl);
    assert (sl = '0')
      report "Read SL B D returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl);
    assert (sl = '1')
      report "Read SL F returned " & to_string(sl) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- STD_LOGIC, with good
    file_open (status        => file_status,
               f             => testfile,
               external_name => filename,
               open_kind     => read_mode);
    assert (file_status = open_ok)
      report "Failed to open file " & filename & " for read with status " &
      FILE_OPEN_STATUS'image(file_status)
      severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL1 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 1 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 2 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 2 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 3 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 3 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 4 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 4 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (not OK) report "Read SL blank returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = 'U')
      report "Read SL blank returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 5 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 5 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (not OK) report "Read SL blank returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = 'U')
      report "Read SL space returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 6 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 6 HT returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 7 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 7 NBSP returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (not OK) report "Read SL % returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = 'U')
      report "Read SL %000 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 0% returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 0% returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 000% returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 000% returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 111 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '1')
      report "Read SL 111 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL 7 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL 7 extra returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL x1 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = 'U')
      report "Read SL X1 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read x2 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = 'H')
      report "Read SL X2 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL A returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '1')
      report "Read SL A returned " & to_string(sl) severity error;
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL A 5 returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL A 5 returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL B returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '1')
      report "Read SL B returned " & to_string(sl) severity error;
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL B D returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '0')
      report "Read SL B D returned " & to_string(sl) severity error;
    readline(testfile, MyLine);
    read(MyLine, sl, Ok);
    assert (OK) report "Read SL F returned boolean "
      & BOOLEAN'image(Ok) severity error;
    assert (sl = '1')
      report "Read SL F returned " & to_string(sl) severity error;
    assert (EndFile(testfile))
      report "End of file not reached!" severity error;
    file_close (testfile);
    -- Note also run this test for SIGNED, UNSIGNED, UFIXED, SFIXED
    assert quiet report "File IO test completed" severity note;
    fileiotest_done <= true;
    wait;
  end process fileio;

end architecture test;
