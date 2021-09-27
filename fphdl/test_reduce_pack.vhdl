-------------------------------------------------------------------------------
-- Test vector for the VHDL-200x-FT numeric_std package
-- This is a test of the reduce functions in numeric_std
-- Last Modified: $Date: 2006-06-08 10:59:32-04 $
-- RCS ID: $Id: test_reduce_pack.vhdl,v 1.1 2006-06-08 10:59:32-04 l435385 Exp $
--
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org)
-------------------------------------------------------------------------------
entity test_reduce_pack is
  generic (
    quiet : BOOLEAN := false);          -- run quietly 
end entity test_reduce_pack;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
architecture testbench of test_reduce_pack is

  -- purpose: Error Reporting routine
  procedure report_error  (
    constant message : in STRING;            -- message string
    actual           : in STD_LOGIC_VECTOR;  -- result from code
    expected         : in STD_LOGIC) is      -- compared against
  begin  -- report_error
    assert (false)
      report message & " (" & to_string(actual) & ") /= " & to_string(expected)
      severity error;
  end report_error;
  constant x : STRING(1 to 1) := (others => 'X');
  -- because X = X is false in std_ulogic
  
begin  -- architecture testbench

  -- purpose: main level test process
  tester : process is
    variable slv16  : STD_LOGIC_VECTOR (15 downto 0);   -- 16 bit slv
    variable sulv16 : STD_ULOGIC_VECTOR (15 downto 0);  -- 16 bit sulv
    variable uns16  : UNSIGNED (15 downto 0);           -- 16 bit unsigned
    variable sig16  : SIGNED (15 downto 0);             -- 16 bit signed
    variable s      : STD_ULOGIC;                       -- one bit
    -- Odd lenghths to test recursive algorithem
    variable slv13  : STD_LOGIC_VECTOR (12 downto 0);   -- 13 bit slv

    variable nullarray : STD_LOGIC_VECTOR (0 downto 12);  -- null array
    
  begin  -- process tester

    ---------------------------------------------------------------------------
    -- Start with an "or" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (or (slv16) /= '0') then
      report_error  ("or reduce", slv16, '0');
    end if;
    sulv16 := "0000000000000001";
    if (or (sulv16) /= '1') then
      report_error  ("or reduce", STD_LOGIC_VECTOR (sulv16), '1');
    end if;
    uns16 := "1111111111111111";
    if (or (uns16) /= '1') then
      report_error  ("or reduce", STD_LOGIC_VECTOR (uns16), '1');
    end if;
    sig16 := "1000000000000001";
    if (or (sig16) /= '1') then
      report_error  ("or reduce", STD_LOGIC_VECTOR (sig16), '1');
    end if;
    slv13 := "0000000000000";
    if (or (slv13) /= '0') then
      report_error  ("or reduce", slv13, '0');
    end if;
    slv13 := "0000000000001";
    if (or (slv13) /= '1') then
      report_error  ("or reduce", slv13, '1');
    end if;
    slv13 := "1111111111111";
    if (or (slv13) /= '1') then
      report_error  ("or reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (or (slv13) /= '1') then
      report_error  ("or reduce", slv13, '1');
    end if;
    if (or (nullarray) /= '0') then    -- Null array test
      report_error  ("or reduce NULL", slv13, '0');
    end if;
    -- x test
    slv16 := "00000000000ZX000";
    if (or (slv16) /= 'X') then
      report_error  ("or reduce", slv16, 'X');
    end if;
    slv16 := "00000000000ZXWU-";
    if (or (slv16) /= 'U') then
      report_error  ("or reduce", slv16, 'U');
    end if;
    slv16 := "10000000000ZXWU-";
    if (or (slv16) /= '1') then
      report_error  ("or reduce", slv16, '1');
    end if;
    ---------------------------------------------------------------------------
    -- "and" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (and (slv16) /= '0') then
      report_error  ("and reduce", slv16, '0');
    end if;
    sulv16 := "0000000000000001";
    if (and (sulv16) /= '0') then
      report_error  ("and reduce", STD_LOGIC_VECTOR (sulv16), '0');
    end if;
    uns16 := "1111111111111111";
    if (and (uns16) /= '1') then
      report_error  ("and reduce", STD_LOGIC_VECTOR (uns16), '1');
    end if;
    sig16 := "1000000000000001";
    if (and (sig16) /= '0') then
      report_error  ("and reduce", STD_LOGIC_VECTOR (sig16), '0');
    end if;
    slv13 := "0000000000000";
    if (and (slv13) /= '0') then
      report_error  ("and reduce", slv13, '0');
    end if;
    slv13 := "0000000000001";
    if (and (slv13) /= '0') then
      report_error  ("and reduce", slv13, '0');
    end if;
    slv13 := "1111111111111";
    if (and (slv13) /= '1') then
      report_error  ("and reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (and (slv13) /= '0') then
      report_error  ("and reduce", slv13, '0');
    end if;
    if (and (nullarray) /= '1') then   -- Null array test
      report_error  ("and reduce NULL", slv13, '0');
    end if;
    -- x test
    slv16 := "11111111111ZX111";
    if (and (slv16) /= 'X') then
      report_error  ("and reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (and (slv16) /= 'U') then
      report_error  ("and reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    if (and (slv16) /= '0') then
      report_error  ("and reduce", slv16, '0');
    end if;
    ---------------------------------------------------------------------------
    -- xor test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (xor (slv16) /= '0') then
      report_error  ("xor reduce", slv16, '0');
    end if;
    sulv16 := "0000000000000001";
    if (xor (sulv16) /= '1') then
      report_error  ("xor reduce", STD_LOGIC_VECTOR (sulv16), '1');
    end if;
    uns16 := "1111111111111111";
    if (xor (uns16) /= '0') then
      report_error  ("xor reduce", STD_LOGIC_VECTOR (uns16), '0');
    end if;
    sig16 := "1000000000000001";
    if (xor (sig16) /= '0') then
      report_error  ("xor reduce", STD_LOGIC_VECTOR (sig16), '0');
    end if;
    slv13 := "0000000000000";
    if (xor (slv13) /= '0') then
      report_error  ("xor reduce", slv13, '0');
    end if;
    slv13 := "0000000000001";
    if (xor (slv13) /= '1') then
      report_error  ("xor reduce", slv13, '1');
    end if;
    slv13 := "1111111111111";
    if (xor (slv13) /= '1') then
      report_error  ("xor reduce", slv13, '1');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (xor (slv13) /= '0') then
      report_error  ("xor reduce", slv13, '0');
    end if;
    if (xor (nullarray) /= '0') then   -- Null array test
      report_error  ("xor reduce NULL", slv13, '0');
    end if;
    slv16 := "11111111111ZX111";
    if (xor (slv16) /= 'X') then
      report_error  ("xor reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (xor (slv16) /= 'U') then
      report_error  ("xor reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    s     := xor (slv16);
    if (s /= 'U') then
      report_error  ("xor reduce", slv16, s);
    end if;
    ---------------------------------------------------------------------------
    -- "nor" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (nor (slv16) /= '1') then
      report_error  ("nor reduce", slv16, '1');
    end if;
    sulv16 := "0000000000000001";
    if (nor (sulv16) /= '0') then
      report_error  ("nor reduce", STD_LOGIC_VECTOR (sulv16), '0');
    end if;
    uns16 := "1111111111111111";
    if (nor (uns16) /= '0') then
      report_error  ("nor reduce", STD_LOGIC_VECTOR (uns16), '0');
    end if;
    sig16 := "1000000000000001";
    if (nor (sig16) /= '0') then
      report_error  ("nor reduce", STD_LOGIC_VECTOR (sig16), '0');
    end if;
    slv13 := "0000000000000";
    if (nor (slv13) /= '1') then
      report_error  ("nor reduce", slv13, '1');
    end if;
    slv13 := "0000000000001";
    if (nor (slv13) /= '0') then
      report_error  ("nor reduce", slv13, '0');
    end if;
    slv13 := "1111111111111";
    if (nor (slv13) /= '0') then
      report_error  ("nor reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (nor (slv13) /= '0') then
      report_error  ("nor reduce", slv13, '0');
    end if;
    if (nor (nullarray) /= '1') then   -- Null array test
      report_error  ("nor reduce NULL", slv13, '1');
    end if;
    -- x test
    slv16 := "00000000000ZX000";
    if (nor (slv16) /= 'X') then
      report_error  ("nor reduce", slv16, 'X');
    end if;
    slv16 := "00000000000ZXWU-";
    if (nor (slv16) /= 'U') then
      report_error  ("nor reduce", slv16, 'U');
    end if;
    slv16 := "10000000000ZXWU-";
    if (nor (slv16) /= '0') then
      report_error  ("nor reduce", slv16, '0');
    end if;
    ---------------------------------------------------------------------------
    -- "nand" test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (nand (slv16) /= '1') then
      report_error  ("nand reduce", slv16, '1');
    end if;
    sulv16 := "0000000000000001";
    if (nand (sulv16) /= '1') then
      report_error  ("nand reduce", STD_LOGIC_VECTOR (sulv16), '1');
    end if;
    uns16 := "1111111111111111";
    if (nand (uns16) /= '0') then
      report_error  ("nand reduce", STD_LOGIC_VECTOR (uns16), '0');
    end if;
    sig16 := "1000000000000001";
    if (nand (sig16) /= '1') then
      report_error  ("nand reduce", STD_LOGIC_VECTOR (sig16), '1');
    end if;
    slv13 := "0000000000000";
    if (nand (slv13) /= '1') then
      report_error  ("nand reduce", slv13, '1');
    end if;
    slv13 := "0000000000001";
    if (nand (slv13) /= '1') then
      report_error  ("nand reduce", slv13, '1');
    end if;
    slv13 := "1111111111111";
    if (nand (slv13) /= '0') then
      report_error  ("nand reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (nand (slv13) /= '1') then
      report_error  ("nand reduce", slv13, '1');
    end if;
    if (nand (nullarray) /= '0') then  -- Null array test
      report_error  ("nand reduce NULL", slv13, '1');
    end if;
    slv16 := "11111111111ZX111";
    if (nand (slv16) /= 'X') then
      report_error  ("nand reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (nand (slv16) /= 'U') then
      report_error  ("nand reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    if (nand (slv16) /= '1') then
      report_error  ("nand reduce", slv16, '1');
    end if;
    ---------------------------------------------------------------------------
    -- xnor test
    ---------------------------------------------------------------------------
    slv16 := "0000000000000000";
    if (xnor (slv16) /= '1') then
      report_error  ("xnor reduce", slv16, '1');
    end if;
    sulv16 := "0000000000000001";
    if (xnor (sulv16) /= '0') then
      report_error  ("xnor reduce", STD_LOGIC_VECTOR (sulv16), '0');
    end if;
    uns16 := "1111111111111111";
    if (xnor (uns16) /= '1') then
      report_error  ("xnor reduce", STD_LOGIC_VECTOR (uns16), '1');
    end if;
    sig16 := "1000000000000001";
    if (xnor (sig16) /= '1') then
      report_error  ("xnor reduce", STD_LOGIC_VECTOR (sig16), '1');
    end if;
    slv13 := "0000000000000";
    if (xnor (slv13) /= '1') then
      report_error  ("xnor reduce", slv13, '1');
    end if;
    slv13 := "0000000000001";
    if (xnor (slv13) /= '0') then
      report_error  ("xnor reduce", slv13, '0');
    end if;
    slv13 := "1111111111111";
    if (xnor (slv13) /= '0') then
      report_error  ("xnor reduce", slv13, '0');
    end if;
    slv13 := "HLLLLLLLLLLLH";
    if (xnor (slv13) /= '1') then
      report_error  ("xnor reduce", slv13, '1');
    end if;
    if (xnor (nullarray) /= '1') then  -- Null array test
      report_error  ("xnor reduce NULL", slv13, '1');
    end if;
    slv16 := "11111111111ZX111";
    if (xnor (slv16) /= 'X') then
      report_error  ("xnor reduce", slv16, 'X');
    end if;
    slv16 := "11111111111ZXWU-";
    if (xnor (slv16) /= 'U') then
      report_error  ("xnor reduce", slv16, 'U');
    end if;
    slv16 := "00000110000ZXWU-";
    s     := xnor (slv16);
    if (s /= 'U') then
      report_error  ("xnor reduce", slv16, s);
    end if;
    assert (false) report "Testing complete" severity note;
    wait;
  end process tester;

end architecture testbench;
