-- file numeric_std_tb4.vhd is a simulation testbench for 
-- IEEE 1076.3 numeric_std package.
-- This is the fourth file in the series, following
-- numeric_std_tb3.vhd
--
library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity numeric_std_tb4 is
  generic (
    quiet : boolean := false);  -- make the simulation quiet
end entity numeric_std_tb4;

architecture t1 of numeric_std_tb4 is 
begin
  process
    procedure A_3 (LEFT, RIGHT, RESULT: in UNSIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT+RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_3;

    procedure A_3 (LEFT, RIGHT: in UNSIGNED) is
    begin
      assert "+"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_3;

    procedure A_4 (LEFT, RIGHT, RESULT: in SIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT+RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_4;

    procedure A_4 (LEFT, RIGHT: in SIGNED) is
    begin
      assert "+"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_4;

    procedure A_5 (LEFT:in UNSIGNED; RIGHT:in NATURAL; RESULT:in UNSIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT+RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_5;

    procedure A_5 (LEFT:in UNSIGNED; RIGHT:in NATURAL) is
    begin
      assert "+"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_5;

    procedure A_6 (LEFT:in NATURAL; RIGHT:in UNSIGNED; RESULT:in UNSIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT+RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_6;

    procedure A_6 (LEFT:in NATURAL; RIGHT:in UNSIGNED) is
    begin
      assert "+"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_6;

    procedure A_7 (LEFT:in INTEGER; RIGHT:in SIGNED; RESULT:in SIGNED) is
    begin
      assert  STD_LOGIC_VECTOR (LEFT+RIGHT) = STD_LOGIC_VECTOR (RESULT)
        severity FAILURE;
    end A_7;

    procedure A_7 (LEFT:in INTEGER; RIGHT:in SIGNED) is
    begin
      assert "+"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_7;

    procedure A_8 (LEFT:in SIGNED; RIGHT:in INTEGER; RESULT:in SIGNED) is
    begin
      assert  STD_LOGIC_VECTOR (LEFT+RIGHT) = STD_LOGIC_VECTOR (RESULT)
        severity FAILURE;
    end A_8;

    procedure A_8 (LEFT:in SIGNED; RIGHT:in INTEGER) is
    begin
      assert "+"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_8;

    procedure A_9 (LEFT, RIGHT, RESULT: in UNSIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT-RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_9;

    procedure A_9 (LEFT, RIGHT: in UNSIGNED) is
    begin
      assert "-"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_9;

    procedure A_10 (LEFT, RIGHT, RESULT: in SIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT-RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_10;

    procedure A_10 (LEFT, RIGHT: in SIGNED) is
    begin
      assert "-"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_10;

    procedure A_11 (LEFT:in UNSIGNED; RIGHT:in NATURAL; RESULT: in UNSIGNED) is
    begin
      assert  STD_LOGIC_VECTOR (LEFT-RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_11;

    procedure A_11 (LEFT:in UNSIGNED;  RIGHT: in NATURAL) is
    begin
      assert "-"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_11;

    procedure A_12 (LEFT:in NATURAL; RIGHT, RESULT: in UNSIGNED) is
    begin
      assert  STD_LOGIC_VECTOR (LEFT-RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_12;

    procedure A_12 (LEFT: in NATURAL; RIGHT:in UNSIGNED) is
    begin
      assert "-"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_12;

    procedure A_13 (LEFT:in SIGNED; RIGHT:in INTEGER; RESULT: in SIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT-RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_13;

    procedure A_13 (LEFT:in SIGNED; RIGHT:in INTEGER) is
    begin
      assert "-"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_13;

    procedure A_14 (LEFT:in INTEGER;  RIGHT, RESULT: in SIGNED) is 
    begin
      assert  STD_LOGIC_VECTOR (LEFT-RIGHT) = STD_LOGIC_VECTOR (RESULT) 
        severity FAILURE;
    end A_14;

    procedure A_14 (LEFT:in INTEGER;  RIGHT: in SIGNED) is
    begin
      assert "-"(LEFT, RIGHT)'length = 0 severity FAILURE;
    end A_14;

  begin

    A_3("0", "0", "0");
    A_3("0", "1", "1");
    A_3("1", "0", "1");
    A_3("1", "1", "0");

    A_3("0000",     "0000",     "0000");
    A_3("0001",     "0000",     "0001");
    A_3("0000",     "0001",     "0001");
    A_3("0001",     "0001",     "0010");
    A_3("0010",     "0010",     "0100");
    A_3("0110",     "1011",     "0001");
    A_3("0110",     "0110",     "1100");
    A_3("1110",     "1111",     "1101");
    A_3("0010",     "0101",     "0111");
    A_3("0000",     "1110",     "1110");
    A_3("0010",     "1111",     "0001");
    A_3("0011",     "0110",     "1001");
    A_3("1101",     "1101",     "1010");
    A_3("1110",     "0001",     "1111");
    A_3("1101",     "0110",     "0011");
    A_3("0001",     "1110",     "1111");

    A_3("0101",     "10",       "0111");
    A_3("10",       "0101",     "0111");
    A_3("0101",     "10",       "0111");
    A_3("1111",     "1111",     "1110");
    A_3("11111111", "0",        "11111111");
    A_3("0",        "11111111", "11111111");
    A_3("1",        "01010101", "01010110");
    A_3("01010101", "1",        "01010110");
    A_3("1111000011110000", "0000000011111111", "1111000111101111");

    A_3("H00H",     "HH00",     "0101");
    A_3("LHHL",     "LLH0",     "1000");
    A_3("0HHH",     "000H",     "1000");
    A_3("0H0H",     "1010",     "1111");

    A_3("0010",     "001X",     "XXXX");
    A_3("0X10",     "HL10",     "XXXX");
    A_3("0010",     "001-",     "XXXX");
    A_3("0010",     "0Z10",     "XXXX");
    A_3("10",       "00W0U-",   "XXXXXX");

    A_3("1",    "");
    A_3("",     "11111111");
    A_3("",     "");
    A_3("0X10", "");  
    A_3("",     "01X");

    assert quiet report "A.3 tests done" severity note;
    
    A_4("0", "0", "0");
    A_4("0", "1", "1");
    A_4("1", "0", "1");
    A_4("1", "1", "0");

    A_4("0000",     "0000",     "0000");
    A_4("0001",     "0000",     "0001");
    A_4("0000",     "0001",     "0001");
    A_4("0001",     "0001",     "0010");
    A_4("0010",     "0010",     "0100");
    A_4("0110",     "1011",     "0001");
    A_4("0110",     "0110",     "1100");
    A_4("1110",     "1111",     "1101");
    A_4("0010",     "0101",     "0111");
    A_4("0000",     "1110",     "1110");
    A_4("0010",     "1111",     "0001");
    A_4("0011",     "0110",     "1001");
    A_4("1101",     "1101",     "1010");
    A_4("1110",     "0001",     "1111");
    A_4("1101",     "0110",     "0011");
    A_4("0001",     "1110",     "1111");

    A_4("0101",     "10",       "0011");
    A_4("10",       "0101",     "0011");
    A_4("0101",     "10",       "0011");
    A_4("1111",     "111",      "1110");
    A_4("11111111", "10",       "11111101");
    A_4("1",        "01010101", "01010100");
    A_4("01010101", "1",        "01010100");
    A_4("1",        "1",        "0");
    A_4("1",        "111",      "110");
    A_4("111",      "1",        "110");
    A_4("0",        "1000",     "1000");
    A_4("1000",     "0",        "1000");
    A_4("1000",     "1000",     "0000");
    A_4("11",       "01010101", "01010100");
    A_4("1111000011110000", "0000000011111111", "1111000111101111");

    A_4("H00H",     "HH00",     "0101");
    A_4("LHHL",     "LLH0",     "1000");
    A_4("0HHH",     "000H",     "1000");
    A_4("0H0H",     "1010",     "1111");

    A_4("0010",     "001X",     "XXXX");
    A_4("0X10",     "HL10",     "XXXX");
    A_4("0010",     "001-",     "XXXX");
    A_4("0010",     "0Z10",     "XXXX");
    A_4("10",       "00W0U-",   "XXXXXX");

    A_4("1",    "");
    A_4("",     "11111111");
    A_4("",     "");
    A_4("0X10", "");  
    A_4("",     "01X");

    assert quiet report "A.4 tests done" severity note;
    
    A_5("0", 0, "0");
    A_5("0", 1, "1");
    A_5("1", 0, "1");
    A_5("1", 1, "0");

    A_5("0000",     0,     "0000");
    A_5("0001",     0,     "0001");
    A_5("0000",     1,     "0001");
    A_5("0001",     1,     "0010");
    A_5("0010",     2,     "0100");
    A_5("0110",     11,    "0001");
    A_5("0110",     6,     "1100");
    A_5("1110",     15,    "1101");
    A_5("0010",     5,     "0111");
    A_5("0000",     14,    "1110");
    A_5("0010",     15,    "0001");
    A_5("0011",     6,     "1001");
    A_5("1101",     13,    "1010");
    A_5("1110",     1,     "1111");
    A_5("1101",     6,     "0011");
    A_5("0001",     14,    "1111");

    A_5("0101",       2,     "0111");
    if (not quiet) then
      A_5("10",         5,     "11");
    end if;
    A_5("1111",       15,    "1110");
    A_5("11111111",   0,     "11111111");
    if (not quiet) then
      A_5("1",          75,    "0");
      A_5("0",          8,     "0");
    end if;
    A_5("1111000011110000", 255, "1111000111101111");

    A_5("H00H",   12,   "0101");
    A_5("LHHL",   2,    "1000");
    A_5("0HHH",   1,    "1000");
    A_5("0H0H",   10,   "1111");

    A_5("0X10",   2,     "XXXX");
    if (not quiet) then
      A_5("0-",     10,    "XX");
    end if;
    A_5("0ZWU",   0,     "XXXX");
    A_5("X",     1,      "X");

    A_5("",    14);
    A_5("",    90210);


    assert quiet report "A.5 tests done" severity note;
    
    A_6(0, "0", "0");
    A_6(0, "1", "1");
    A_6(1, "0", "1");
    A_6(1, "1", "0");

    A_6(0,  "0000",  "0000");
    A_6(0,  "0001",  "0001");
    A_6(1,  "0000",  "0001");
    A_6(1,  "0001",  "0010");
    A_6(2,  "0010",  "0100");
    A_6(11, "0110",  "0001");
    A_6(6,  "0110",  "1100");
    A_6(15, "1110",  "1101");
    A_6(5,  "0010",  "0111");
    A_6(14, "0000",  "1110");
    A_6(15, "0010",  "0001");
    A_6(6,  "0011",  "1001");
    A_6(13, "1101",  "1010");
    A_6(1,  "1110",  "1111");
    A_6(6,  "1101",  "0011");
    A_6(14, "0001",  "1111");

    A_6(2,   "0101",       "0111");
    if (not quiet) then
      A_6(5,   "10",         "11");
    end if;
    A_6(15,  "1111",       "1110");
    A_6(0,   "11111111",   "11111111");
    if (not quiet) then
      A_6(75,  "1",          "0");
    end if;
    A_6(0,   "1000",     "1000");

    A_6(255, "1111000011110000", "1111000111101111");

    A_6(12,  "H00H",   "0101");
    A_6(2,   "LHHL",   "1000");
    A_6(1,   "0HHH",   "1000");
    A_6(10,  "0H0H",   "1111");

    A_6(2,   "0X10",   "XXXX");
    if (not quiet) then
      A_6(10,  "0-",     "XX");
    end if;
    A_6(0,   "0ZWU",   "XXXX");
    A_6(1,   "X",      "X");

    A_6(14, "");
    A_6(25678, "");


    assert quiet report "A.6 tests done" severity note;
    
    A_7(0, "0", "0");
    A_7(0, "1", "1");
    if (not quiet) then
      A_7(1, "0", "1");
      A_7(1, "1", "0");
    end if;

    A_7(0,  "0000",  "0000");
    A_7(0,  "0001",  "0001");
    A_7(1,  "0000",  "0001");
    A_7(1,  "0001",  "0010");
    A_7(2,  "0010",  "0100");
    A_7(-5, "0110",  "0001");
    A_7(6,  "0110",  "1100");
    A_7(-1, "1110",  "1101");
    A_7(5,  "0010",  "0111");
    A_7(-2, "0000",  "1110");
    A_7(-1, "0010",  "0001");
    A_7(6,  "0011",  "1001");
    A_7(-3, "1101",  "1010");
    A_7(1,  "1110",  "1111");
    A_7(6,  "1101",  "0011");
    A_7(-2, "0001",  "1111");

    A_7(-2,  "0101",      "0011");
    if (not quiet) then
      A_7(5,   "10",        "11");
    end if;
    A_7(-1,  "1111",      "1110");
    A_7(-2,  "11111111",  "11111101");
    if (not quiet) then
      A_7(75,  "1",         "0");
    end if;
    A_7(-1,  "1",         "0");
    A_7(0,   "1000",      "1000");

    if (not quiet) then
      A_7(85,  "1111",      "0100");
      A_7(-85,  "1111",      "1010");
    end if;
    A_7(255, "1111000011110000",  "1111000111101111");

    A_7(-4, "H00H",     "0101");
    A_7(2,  "LHHL",     "1000");
    A_7(1,   "0HHH",     "1000");
    A_7(-6,  "0H0H",     "1111");

    if (not quiet) then
      A_7(16,  "1X",      "XX");
    end if;
    A_7(-3,  "001-",    "XXXX");
    A_7(7,   "0Z10",    "XXXX");
    A_7(12,  "00W0U-",  "XXXXXX");

    A_7(-5,  "");
    A_7(0,   "");


    assert quiet report "A.7 tests done" severity note;
    
    A_8("0", 0, "0");
    if (not quiet) then
      A_8("0", 1, "1");
    end if;
    A_8("1", 0, "1");
    if (not quiet) then
      A_8("1", 1, "0");
    end if;

    A_8("0000",     0,    "0000");
    A_8("0001",     0,    "0001");
    A_8("0000",     1,    "0001");
    A_8("0001",     1,    "0010");
    A_8("0010",     2,    "0100");
    A_8("0110",    -5,    "0001");
    A_8("0110",     6,    "1100");
    A_8("1110",    -1,    "1101");
    A_8("0010",     5,    "0111");
    A_8("0000",    -2,    "1110");
    A_8("0010",    -1,    "0001");
    A_8("0011",     6,    "1001");
    A_8("1101",    -3,    "1010");
    A_8("1110",     1,    "1111");
    A_8("1101",     6,    "0011");
    A_8("0001",    -2,    "1111");

    A_8("0101",     -2,  "0011");
    if (not quiet) then
      A_8("10",        5,  "11");
    end if;
    A_8("1111",     -1,  "1110");
    A_8("11111111", -2,  "11111101");
    if (not quiet) then
      A_8("1",        75,  "0");
    end if;
    A_8("1",        -1,  "0");
    if (not quiet) then
      A_8("1111",     85,  "0100");
      A_8("1111",    -85,  "1010");
    end if;
    A_8("00000",    -8,  "11000");
    A_8("1111000011110000", 255, "1111000111101111");

    A_8("H00H",    -4,     "0101");
    A_8("LHHL",     2,     "1000");
    A_8("0HHH",     1,     "1000");
    A_8("0H0H",    -6,     "1111");

    if (not quiet) then
      A_8("1X",      16,  "XX");
    end if;
    A_8("001-",    -3,  "XXXX");
    A_8("0Z10",     7,  "XXXX");
    A_8("00W0U-",  12,  "XXXXXX");

    A_8("",  -5);
    A_8("",  0);


    assert quiet report "A.8 tests done" severity note;
    
    A_9("0", "0", "0");
    A_9("0", "1", "1");
    A_9("1", "0", "1");
    A_9("1", "1", "0");

    A_9("0000",     "0000",     "0000");
    A_9("0001",     "0000",     "0001");
    A_9("0000",     "0001",     "1111");
    A_9("0001",     "0001",     "0000");
    A_9("0010",     "0010",     "0000");
    A_9("0110",     "1011",     "1011");
    A_9("0110",     "0110",     "0000");
    A_9("1110",     "1111",     "1111");
    A_9("0010",     "0101",     "1101");
    A_9("0000",     "1110",     "0010");
    A_9("0010",     "1111",     "0011");
    A_9("0011",     "0110",     "1101");
    A_9("1101",     "1101",     "0000");
    A_9("1110",     "0001",     "1101");
    A_9("1101",     "0110",     "0111");
    A_9("0001",     "1110",     "0011");

    A_9("0101",     "10",       "0011");
    A_9("10",       "0101",     "1101");
    A_9("0101",     "10",       "0011");
    A_9("1111",     "1111",     "0000");
    A_9("11111111", "0",        "11111111");
    A_9("0",        "11111111", "00000001");
    A_9("1",        "01010101", "10101100");
    A_9("01010101", "1",        "01010100");
    A_9("0",        "1000",     "1000");
    A_9("1111000011110000", "0000000011111111", "1110111111110001");

    A_9("H00H",     "HH00",     "1101");
    A_9("LHHL",     "LLH0",     "0100");
    A_9("0HHH",     "000H",     "0110");
    A_9("0H0H",     "1010",     "1011");

    A_9("0010",     "001X",     "XXXX");
    A_9("0X10",     "HL10",     "XXXX");
    A_9("00",       "1-",       "XX");
    A_9("0010",     "0Z10",     "XXXX");
    A_9("10",       "00W0U-",   "XXXXXX");

    A_9("1",    "");
    A_9("",     "11111111");
    A_9("",     "");
    A_9("0X10", "");  
    A_9("",     "01X");


    assert quiet report "A.9 tests done" severity note;
    
    A_10("0", "0", "0");
    A_10("0", "1", "1");
    A_10("1", "0", "1");
    A_10("1", "1", "0");

    A_10("0000",     "0000",     "0000");
    A_10("0001",     "0000",     "0001");
    A_10("0000",     "0001",     "1111");
    A_10("0001",     "0001",     "0000");
    A_10("0010",     "0010",     "0000");
    A_10("0110",     "1011",     "1011");
    A_10("0110",     "0110",     "0000");
    A_10("1110",     "1111",     "1111");
    A_10("0010",     "0101",     "1101");
    A_10("0000",     "1110",     "0010");
    A_10("0010",     "1111",     "0011");
    A_10("0011",     "0110",     "1101");
    A_10("1101",     "1101",     "0000");
    A_10("1110",     "0001",     "1101");
    A_10("1101",     "0110",     "0111");
    A_10("0001",     "1110",     "0011");

    A_10("0101",     "10",       "0111");
    A_10("10",       "0101",     "1001");
    A_10("0101",     "10",       "0111");
    A_10("1111",     "111",      "0000");
    A_10("11111111", "10",       "00000001");
    A_10("10",       "11111111", "11111111");
    A_10("1",        "01010101", "10101010");
    A_10("01010101", "1",        "01010110");
    A_10("11",       "01010101", "10101010");
    A_10("01010101", "11",       "01010110");
    A_10("1",        "1",        "0");
    A_10("1",        "111",      "000");
    A_10("111",      "1",        "000");
    A_10("111",      "1",        "000");
    A_10("0",        "1000",     "1000");
    A_10("1111000011110000", "0000000011111111", "1110111111110001");

    A_10("H00H",     "HH00",     "1101");
    A_10("LHHL",     "LLH0",     "0100");
    A_10("0HHH",     "000H",     "0110");
    A_10("0H0H",     "1010",     "1011");

    A_10("0010",     "1X",     "XXXX");
    A_10("0X10",     "HL10",   "XXXX");
    A_10("0",        "-",      "X");
    A_10("0010",     "0Z10",   "XXXX");
    A_10("10",       "00W0U-", "XXXXXX");

    A_10("1",    "");
    A_10("",     "11111111");
    A_10("",     "");
    A_10("0X10", "");  
    A_10("",     "01X");


    assert quiet report "A.10 tests done" severity note;
    
    A_11("0", 0, "0");
    A_11("0", 1, "1");
    A_11("1", 0, "1");
    A_11("1", 1, "0");

    A_11("0000",     0,     "0000");
    A_11("0001",     0,     "0001");
    A_11("0000",     1,     "1111");
    A_11("0001",     1,     "0000");
    A_11("0010",     2,     "0000");
    A_11("0110",     11,    "1011");
    A_11("0110",     6,     "0000");
    A_11("1110",     15,    "1111");
    A_11("0010",     5,     "1101");
    A_11("0000",     14,    "0010");
    A_11("0010",     15,    "0011");
    A_11("0011",     6,     "1101");
    A_11("1101",     13,    "0000");
    A_11("1110",     1,     "1101");
    A_11("1101",     6,     "0111");
    A_11("0001",     14,    "0011");

    A_11("0101",     2,    "0011");
    if (not quiet) then
      A_11("10",       5,    "01");
    end if;
    A_11("1111",     15,   "0000");
    A_11("11111111", 0,    "11111111");
    if (not quiet) then
      A_11("1",        85,   "0");
      A_11("0",        8,    "0");
    end if;
    A_11("1111000011110000", 255, "1110111111110001");

    A_11("H00H",    12,   "1101");
    A_11("LHHL",    2,    "0100");
    A_11("0HHH",    1,    "0110");
    A_11("0H0H",    10,   "1011");

    A_11("0X10",   2,    "XXXX");
    if (not quiet) then
      A_11("0-",     10,   "XX");
    end if;
    A_11("0ZWU",   0,    "XXXX");
    A_11("X",      1,    "X");

    A_11("",    10);
    A_11("",    90210);


    assert quiet report "A.11 tests done" severity note;
    
    A_12(0, "0", "0");
    A_12(0, "1", "1");
    A_12(1, "0", "1");
    A_12(1, "1", "0");

    A_12(0,    "0000",     "0000");
    A_12(1,    "0000",     "0001");
    A_12(0,    "0001",     "1111");
    A_12(1,    "0001",     "0000");
    A_12(2,    "0010",     "0000");
    A_12(6,    "1011",     "1011");
    A_12(6,    "0110",     "0000");
    A_12(14,   "1111",     "1111");
    A_12(2,    "0101",     "1101");
    A_12(0,    "1110",     "0010");
    A_12(2,    "1111",     "0011");
    A_12(3,    "0110",     "1101");
    A_12(13,   "1101",     "0000");
    A_12(14,   "0001",     "1101");
    A_12(13,   "0110",     "0111");
    A_12(1,    "1110",     "0011");

    if (not quiet) then
      A_12(5,     "10",      "11");
    end if;
    A_12(2,     "0101",    "1101");
    A_12(15,    "1111",    "0000");
    if (not quiet) then
      A_12(255,   "0000",    "1111");
    end if;
    A_12(1,     "01010101","10101100");
    A_12(0,     "1000",     "1000");
    A_12(19,    "0000000011111111", "1111111100010100");

    A_12(9,     "HH00",     "1101");
    A_12(6,     "LLH0",     "0100");
    A_12(7,     "000H",     "0110");
    A_12(5,     "1010",     "1011");


    A_12(2,  "0X10",     "XXXX");
    if (not quiet) then
      A_12(10, "0-",       "XX");
    end if;
    A_12(0,  "0ZWU",     "XXXX");
    A_12(1,  "X",        "X");

    A_12(10,    "");
    A_12(90210, "");


    assert quiet report "A.12 tests done" severity note;
    
    A_13("0", 0, "0");
    if (not quiet) then
      A_13("0", 1, "1");
    end if;
    A_13("1", 0, "1");
    if (not quiet) then
      A_13("1", 1, "0");
    end if;

    A_13("0000",     0,     "0000");
    A_13("0001",     0,     "0001");
    A_13("0000",     1,     "1111");
    A_13("0001",     1,     "0000");
    A_13("0010",     2,     "0000");
    A_13("0110",     -5,    "1011");
    A_13("0110",     6,     "0000");
    A_13("1110",     -1,    "1111");
    A_13("0010",     5,     "1101");
    A_13("0000",     -2,    "0010");
    A_13("0010",     -1,    "0011");
    A_13("0011",     6,     "1101");
    A_13("1101",     -3,    "0000");
    A_13("1110",     1,     "1101");
    A_13("1101",     6,     "0111");
    A_13("0001",     -2,    "0011");

    A_13("0101",     -2,    "0111");
    if (not quiet) then
      A_13("10",       5,     "01");
    end if;
    A_13("1111",     -1,    "0000");
    A_13("11111111", -2,    "00000001");
    if (not quiet) then
      A_13("1",        85,    "0");
      A_13("11",       85,    "10");
      A_13("1",        -1,    "0");
      A_13("0000",     -8,    "1000");
      A_13("0",        -7,    "1");
    end if;
    A_13("1111000011110000", 255, "1110111111110001");

    A_13("H00H",     -4,    "1101");
    A_13("LHHL",     2,     "0100");
    A_13("0HHH",     1,     "0110");
    A_13("0H0H",     -6,    "1011");

    if (not quiet) then
      A_13("1X",      16,  "XX");
    end if;
    A_13("001-",    -3,  "XXXX");
    A_13("0Z10",     7,  "XXXX");
    A_13("00W0U-",  12,  "XXXXXX");

    A_13("",     90210);
    A_13("",     -369);


    assert quiet report "A.13 tests done" severity note;
    
    A_14(0, "0", "0");
    A_14(0, "1", "1");
    if (not quiet) then
      A_14(1, "0", "1");
      A_14(1, "1", "0");
    end if;

    A_14(0,     "0000",     "0000");
    A_14(1,     "0000",     "0001");
    A_14(0,     "0001",     "1111");
    A_14(1,     "0001",     "0000");
    A_14(2,     "0010",     "0000");
    A_14(6,     "1011",     "1011");
    A_14(6,     "0110",     "0000");
    A_14(-2,    "1111",     "1111");
    A_14(2,     "0101",     "1101");
    A_14(0,     "1110",     "0010");
    A_14(2,     "1111",     "0011");
    A_14(3,     "0110",     "1101");
    A_14(-3,    "1101",     "0000");
    A_14(-2,    "0001",     "1101");
    A_14(-3,    "0110",     "0111");
    A_14(1,     "1110",     "0011");

    if (not quiet) then
      A_14(5,     "10",       "11");
    end if;
    A_14(-2,    "0101",     "1001");
    A_14(-1,    "111",      "000");
    A_14(-1,    "10",       "01");
    A_14(-1,    "01010101", "10101010");
    A_14(-1,    "1",        "0");
    A_14(-1,    "111",      "000");
    A_14(0,     "1000",     "1000");
    A_14(0,     "01000",    "11000");
    A_14(-3856, "0000000011111111", "1110111111110001");

    A_14(-7,    "HH00",     "1101");
    A_14(6,     "LLH0",     "0100");
    A_14(7,     "000H",     "0110");
    A_14(5,     "1010",     "1011");

    A_14(1,     "1X",       "XX");
    if (not quiet) then
      A_14(7,     "-",      "X");
    end if;
    A_14(6,    "0Z10",   "XXXX");
    A_14(10,    "00W0U-", "XXXXXX");

    A_14(0,    "");
    A_14(-90210, "");  
    A_14(90210, "");  


    assert quiet report "A.14 tests done" severity note;
    
    assert FALSE
      report "END OF test suite tb4"
      severity note;

    wait;
  end process;
end architecture t1;
