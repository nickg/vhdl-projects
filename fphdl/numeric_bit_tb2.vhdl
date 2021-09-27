-- file numeric_bit_tb2.vhd is a simulation testbench for 
-- IEEE 1076.3 numeric_bit package.
-- This is the second file in the series, following
-- numeric_bit_tb1.vhd
--
library IEEE;

use IEEE.numeric_bit.all;

entity numeric_bit_tb2 is
  generic (
    quiet : boolean := false);  -- make the simulation quiet
end entity numeric_bit_tb2;

architecture t1 of numeric_bit_tb2 is 
  -- required by A.1, A.2 tests
  constant max_size_checked : integer := 200;
  constant temp1    : signed( max_size_checked-2 downto 0 ) :=
    (others => '1');

  constant temp0    : signed( max_size_checked-2 downto 0 ) :=
    (others => '0');
  
  constant posmax   : signed( max_size_checked-1 downto 0 ) := 
    '0' & temp1;

  constant neg1 : signed( max_size_checked-1 downto 0 ) := 
    (others => '1');

  constant negmin   : signed( max_size_checked-1 downto 0 ) :=
    ('1', others => '0');

  constant zero     :  signed( max_size_checked-1 downto 0 ) :=
    (others => '0');

  -- required by s1_8 tests
  signal s_unull : unsigned(0 downto 1);
  signal s_snull : signed(0 downto 1);

begin
  process
    -- required by A.1, A.2 tests
    variable x : signed( max_size_checked-1 downto 0 ) := zero;
    -- required by s1_8 tests
    variable i : integer;
  begin

    assert quiet report "start of tests" severity note;
    
    -- S.1 tests
    assert shift_left(s_unull, 0)'length = 0
      report "Test S.1.1 failing."
      severity FAILURE;
    assert shift_left(s_unull, 1)'length = 0
      report "Test S.1.2 failing."
      severity FAILURE;
    assert shift_left(s_unull, 100)'length = 0
      report "Test S.1.3 failing."
      severity FAILURE;

    assert shift_left(unsigned'("0"), 0) = unsigned'("0")
      report "Test S.1.4 failing."
      severity FAILURE;
    assert shift_left(unsigned'("0"), 1) = unsigned'("0")
      report "Test S.1.5 failing."
      severity FAILURE;
    assert shift_left(unsigned'("0"), 50) = unsigned'("0")
      report "Test S.1.6 failing."
      severity FAILURE;

    assert shift_left(unsigned'("1"), 0) = unsigned'("1")
      report "Test S.1.7 failing."
      severity FAILURE;
    assert shift_left(unsigned'("1"), 1) = unsigned'("0")
      report "Test S.1.8 failing."
      severity FAILURE;
    assert shift_left(unsigned'("1"), 39) = unsigned'("0")
      report "Test S.1.9 failing."
      severity FAILURE;

    assert shift_left(unsigned'("000"), 0) = unsigned'("000")
      report "Test S.1.10 failing."
      severity FAILURE;
    assert shift_left(unsigned'("000"), 1) = unsigned'("000")
      report "Test S.1.11 failing."
      severity FAILURE;
    assert shift_left(unsigned'("000"), 2) = unsigned'("000")
      report "Test S.1.12 failing."
      severity FAILURE;
    assert shift_left(unsigned'("000"), 3) = unsigned'("000")
      report "Test S.1.13 failing."
      severity FAILURE;

    assert shift_left(unsigned'("111"), 0) = unsigned'("111")
      report "Test S.1.14 failing."
      severity FAILURE;
    assert shift_left(unsigned'("111"), 1) = unsigned'("110")
      report "Test S.1.15 failing."
      severity FAILURE;
    assert shift_left(unsigned'("111"), 2) = unsigned'("100")
      report "Test S.1.16 failing."
      severity FAILURE;
    assert shift_left(unsigned'("111"), 3) = unsigned'("000")
      report "Test S.1.17 failing."
      severity FAILURE;

    assert shift_left(unsigned'("001"), 0) = unsigned'("001")
      report "Test S.1.18 failing."
      severity FAILURE;
    assert shift_left(unsigned'("001"), 1) = unsigned'("010")
      report "Test S.1.19 failing."
      severity FAILURE;
    assert shift_left(unsigned'("001"), 2) = unsigned'("100")
      report "Test S.1.20 failing."
      severity FAILURE;
    assert shift_left(unsigned'("001"), 3) = unsigned'("000")
      report "Test S.1.21 failing."
      severity FAILURE;

    assert quiet report "S.1 tests done" severity note;

    -- S.2 tests
    assert shift_right(s_unull, 0)'length = 0
      report "Test S.2.1 failing."
      severity FAILURE;
    assert shift_right(s_unull, 1)'length = 0
      report "Test S.2.2 failing."
      severity FAILURE;
    assert shift_right(s_unull, 100)'length = 0
      report "Test S.2.3 failing."
      severity FAILURE;

    assert shift_right(unsigned'("0"), 0) = unsigned'("0")
      report "Test S.2.4 failing."
      severity FAILURE;
    assert shift_right(unsigned'("0"), 1) = unsigned'("0")
      report "Test S.2.5 failing."
      severity FAILURE;
    assert shift_right(unsigned'("0"), 50) = unsigned'("0")
      report "Test S.2.6 failing."
      severity FAILURE;

    assert shift_right(unsigned'("1"), 0) = unsigned'("1")
      report "Test S.2.7 failing."
      severity FAILURE;
    assert shift_right(unsigned'("1"), 1) = unsigned'("0")
      report "Test S.2.8 failing."
      severity FAILURE;
    assert shift_right(unsigned'("1"), 39) = unsigned'("0")
      report "Test S.2.9 failing."
      severity FAILURE;

    assert shift_right(unsigned'("000"), 0) = unsigned'("000")
      report "Test S.2.10 failing."
      severity FAILURE;
    assert shift_right(unsigned'("000"), 1) = unsigned'("000")
      report "Test S.2.11 failing."
      severity FAILURE;
    assert shift_right(unsigned'("000"), 2) = unsigned'("000")
      report "Test S.2.12 failing."
      severity FAILURE;
    assert shift_right(unsigned'("000"), 3) = unsigned'("000")
      report "Test S.2.13 failing."
      severity FAILURE;

    assert shift_right(unsigned'("111"), 0) = unsigned'("111")
      report "Test S.2.14 failing."
      severity FAILURE;
    assert shift_right(unsigned'("111"), 1) = unsigned'("011")
      report "Test S.2.15 failing."
      severity FAILURE;
    assert shift_right(unsigned'("111"), 2) = unsigned'("001")
      report "Test S.2.16 failing."
      severity FAILURE;
    assert shift_right(unsigned'("111"), 3) = unsigned'("000")
      report "Test S.2.17 failing."
      severity FAILURE;

    assert shift_right(unsigned'("100"), 0) = unsigned'("100")
      report "Test S.2.18 failing."
      severity FAILURE;
    assert shift_right(unsigned'("100"), 1) = unsigned'("010")
      report "Test S.2.19 failing."
      severity FAILURE;
    assert shift_right(unsigned'("100"), 2) = unsigned'("001")
      report "Test S.2.20 failing."
      severity FAILURE;
    assert shift_right(unsigned'("100"), 3) = unsigned'("000")
      report "Test S.2.21 failing."
      severity FAILURE;

    assert quiet report "S.2 tests done" severity note;

    -- S.3 tests
    assert shift_left(s_snull, 0)'length = 0
      report "Test S.3.1 failing."
      severity FAILURE;
    assert shift_left(s_snull, 1)'length = 0
      report "Test S.3.2 failing."
      severity FAILURE;
    assert shift_left(s_snull, 100)'length = 0
      report "Test S.3.3 failing."
      severity FAILURE;

    assert shift_left(signed'("0"), 0) = signed'("0")
      report "Test S.3.4 failing."
      severity FAILURE;
    assert shift_left(signed'("0"), 1) = signed'("0")
      report "Test S.3.5 failing."
      severity FAILURE;
    assert shift_left(signed'("0"), 50) = signed'("0")
      report "Test S.3.6 failing."
      severity FAILURE;

    assert shift_left(signed'("1"), 0) = signed'("1")
      report "Test S.3.7 failing."
      severity FAILURE;
    assert shift_left(signed'("1"), 1) = signed'("0")
      report "Test S.3.8 failing."
      severity FAILURE;
    assert shift_left(signed'("1"), 39) = signed'("0")
      report "Test S.3.9 failing."
      severity FAILURE;

    assert shift_left(signed'("000"), 0) = signed'("000")
      report "Test S.3.10 failing."
      severity FAILURE;
    assert shift_left(signed'("000"), 1) = signed'("000")
      report "Test S.3.11 failing."
      severity FAILURE;
    assert shift_left(signed'("000"), 2) = signed'("000")
      report "Test S.3.12 failing."
      severity FAILURE;
    assert shift_left(signed'("000"), 3) = signed'("000")
      report "Test S.3.13 failing."
      severity FAILURE;

    assert shift_left(signed'("111"), 0) = signed'("111")
      report "Test S.3.14 failing."
      severity FAILURE;
    assert shift_left(signed'("111"), 1) = signed'("110")
      report "Test S.3.15 failing."
      severity FAILURE;
    assert shift_left(signed'("111"), 2) = signed'("100")
      report "Test S.3.16 failing."
      severity FAILURE;
    assert shift_left(signed'("111"), 3) = signed'("000")
      report "Test S.3.17 failing."
      severity FAILURE;

    assert shift_left(signed'("001"), 0) = signed'("001")
      report "Test S.3.18 failing."
      severity FAILURE;
    assert shift_left(signed'("001"), 1) = signed'("010")
      report "Test S.3.19 failing."
      severity FAILURE;
    assert shift_left(signed'("001"), 2) = signed'("100")
      report "Test S.3.20 failing."
      severity FAILURE;
    assert shift_left(signed'("001"), 3) = signed'("000")
      report "Test S.3.21 failing."
      severity FAILURE;

    assert quiet report "S.3 tests done" severity note;

    -- S.4 tests
    assert shift_right(s_snull, 0)'length = 0
      report "Test S.4.1 failing."
      severity FAILURE;
    assert shift_right(s_snull, 1)'length = 0
      report "Test S.4.2 failing."
      severity FAILURE;
    assert shift_right(s_snull, 100)'length = 0
      report "Test S.4.3 failing."
      severity FAILURE;

    assert shift_right(signed'("0"), 0) = signed'("0")
      report "Test S.4.4 failing."
      severity FAILURE;
    assert shift_right(signed'("0"), 1) = signed'("0")
      report "Test S.4.5 failing."
      severity FAILURE;
    assert shift_right(signed'("0"), 50) = signed'("0")
      report "Test S.4.6 failing."
      severity FAILURE;

    assert shift_right(signed'("1"), 0) = signed'("1")
      report "Test S.4.7 failing."
      severity FAILURE;
    assert shift_right(signed'("1"), 1) = signed'("1")
      report "Test S.4.8 failing."
      severity FAILURE;
    assert shift_right(signed'("1"), 39) = signed'("1")
      report "Test S.4.9 failing."
      severity FAILURE;

    assert shift_right(signed'("000"), 0) = signed'("000")
      report "Test S.4.10 failing."
      severity FAILURE;
    assert shift_right(signed'("000"), 1) = signed'("000")
      report "Test S.4.11 failing."
      severity FAILURE;
    assert shift_right(signed'("000"), 2) = signed'("000")
      report "Test S.4.12 failing."
      severity FAILURE;
    assert shift_right(signed'("000"), 3) = signed'("000")
      report "Test S.4.13 failing."
      severity FAILURE;

    assert shift_right(signed'("111"), 0) = signed'("111")
      report "Test S.4.14 failing."
      severity FAILURE;
    assert shift_right(signed'("111"), 1) = signed'("111")
      report "Test S.4.15 failing."
      severity FAILURE;
    assert shift_right(signed'("111"), 2) = signed'("111")
      report "Test S.4.16 failing."
      severity FAILURE;
    assert shift_right(signed'("111"), 3) = signed'("111")
      report "Test S.4.17 failing."
      severity FAILURE;

    assert shift_right(signed'("100"), 0) = signed'("100")
      report "Test S.4.18 failing."
      severity FAILURE;
    assert shift_right(signed'("100"), 1) = signed'("110")
      report "Test S.4.19 failing."
      severity FAILURE;
    assert shift_right(signed'("100"), 2) = signed'("111")
      report "Test S.4.20 failing."
      severity FAILURE;
    assert shift_right(signed'("100"), 3) = signed'("111")
      report "Test S.4.21 failing."
      severity FAILURE;

    assert quiet report "S.4 tests done" severity note;

    -- S.5 tests
    assert rotate_left(s_unull, 0)'length = 0
      report "Test S.5.1 failing."
      severity FAILURE;
    assert rotate_left(s_unull, 1)'length = 0
      report "Test S.5.2 failing."
      severity FAILURE;
    assert rotate_left(s_unull, 100)'length = 0
      report "Test S.5.3 failing."
      severity FAILURE;

    assert rotate_left(unsigned'("0"), 0) = unsigned'("0")
      report "Test S.5.4 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("0"), 1) = unsigned'("0")
      report "Test S.5.5 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("0"), 50) = unsigned'("0")
      report "Test S.5.6 failing."
      severity FAILURE;

    assert rotate_left(unsigned'("1"), 0) = unsigned'("1")
      report "Test S.5.7 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("1"), 1) = unsigned'("1")
      report "Test S.5.8 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("1"), 39) = unsigned'("1")
      report "Test S.5.9 failing."
      severity FAILURE;

    assert rotate_left(unsigned'("000"), 0) = unsigned'("000")
      report "Test S.5.10 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("000"), 1) = unsigned'("000")
      report "Test S.5.11 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("000"), 2) = unsigned'("000")
      report "Test S.5.12 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("000"), 3) = unsigned'("000")
      report "Test S.5.13 failing."
      severity FAILURE;

    assert rotate_left(unsigned'("111"), 0) = unsigned'("111")
      report "Test S.5.14 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("111"), 1) = unsigned'("111")
      report "Test S.5.15 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("111"), 2) = unsigned'("111")
      report "Test S.5.16 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("111"), 3) = unsigned'("111")
      report "Test S.5.17 failing."
      severity FAILURE;

    assert rotate_left(unsigned'("011"), 0) = unsigned'("011")
      report "Test S.5.18 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("011"), 1) = unsigned'("110")
      report "Test S.5.19 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("011"), 2) = unsigned'("101")
      report "Test S.5.20 failing."
      severity FAILURE;
    assert rotate_left(unsigned'("011"), 3) = unsigned'("011")
      report "Test S.5.21 failing."
      severity FAILURE;

    assert quiet report "S.5 tests done" severity note;

    -- S.6 tests
    assert rotate_right(s_unull, 0)'length = 0
      report "Test S.6.1 failing."
      severity FAILURE;
    assert rotate_right(s_unull, 1)'length = 0
      report "Test S.6.2 failing."
      severity FAILURE;
    assert rotate_right(s_unull, 100)'length = 0
      report "Test S.6.3 failing."
      severity FAILURE;

    assert rotate_right(unsigned'("0"), 0) = unsigned'("0")
      report "Test S.6.4 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("0"), 1) = unsigned'("0")
      report "Test S.6.5 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("0"), 50) = unsigned'("0")
      report "Test S.6.6 failing."
      severity FAILURE;

    assert rotate_right(unsigned'("1"), 0) = unsigned'("1")
      report "Test S.6.7 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("1"), 1) = unsigned'("1")
      report "Test S.6.8 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("1"), 39) = unsigned'("1")
      report "Test S.6.9 failing."
      severity FAILURE;

    assert rotate_right(unsigned'("000"), 0) = unsigned'("000")
      report "Test S.6.10 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("000"), 1) = unsigned'("000")
      report "Test S.6.11 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("000"), 2) = unsigned'("000")
      report "Test S.6.12 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("000"), 3) = unsigned'("000")
      report "Test S.6.13 failing."
      severity FAILURE;

    assert rotate_right(unsigned'("111"), 0) = unsigned'("111")
      report "Test S.6.14 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("111"), 1) = unsigned'("111")
      report "Test S.6.15 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("111"), 2) = unsigned'("111")
      report "Test S.6.16 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("111"), 3) = unsigned'("111")
      report "Test S.6.17 failing."
      severity FAILURE;

    assert rotate_right(unsigned'("110"), 0) = unsigned'("110")
      report "Test S.6.18 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("110"), 1) = unsigned'("011")
      report "Test S.6.19 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("110"), 2) = unsigned'("101")
      report "Test S.6.20 failing."
      severity FAILURE;
    assert rotate_right(unsigned'("110"), 3) = unsigned'("110")
      report "Test S.6.21 failing."
      severity FAILURE;

    assert quiet report "S.6 tests done" severity note;

    -- S.7 tests
    assert rotate_left(s_snull, 0)'length = 0
      report "Test S.7.1 failing."
      severity FAILURE;
    assert rotate_left(s_snull, 1)'length = 0
      report "Test S.7.2 failing."
      severity FAILURE;
    assert rotate_left(s_snull, 100)'length = 0
      report "Test S.7.3 failing."
      severity FAILURE;

    assert rotate_left(signed'("0"), 0) = signed'("0")
      report "Test S.7.4 failing."
      severity FAILURE;
    assert rotate_left(signed'("0"), 1) = signed'("0")
      report "Test S.7.5 failing."
      severity FAILURE;
    assert rotate_left(signed'("0"), 50) = signed'("0")
      report "Test S.7.6 failing."
      severity FAILURE;

    assert rotate_left(signed'("1"), 0) = signed'("1")
      report "Test S.7.7 failing."
      severity FAILURE;
    assert rotate_left(signed'("1"), 1) = signed'("1")
      report "Test S.7.8 failing."
      severity FAILURE;
    assert rotate_left(signed'("1"), 39) = signed'("1")
      report "Test S.7.9 failing."
      severity FAILURE;

    assert rotate_left(signed'("000"), 0) = signed'("000")
      report "Test S.7.10 failing."
      severity FAILURE;
    assert rotate_left(signed'("000"), 1) = signed'("000")
      report "Test S.7.11 failing."
      severity FAILURE;
    assert rotate_left(signed'("000"), 2) = signed'("000")
      report "Test S.7.12 failing."
      severity FAILURE;
    assert rotate_left(signed'("000"), 3) = signed'("000")
      report "Test S.7.13 failing."
      severity FAILURE;

    assert rotate_left(signed'("111"), 0) = signed'("111")
      report "Test S.7.14 failing."
      severity FAILURE;
    assert rotate_left(signed'("111"), 1) = signed'("111")
      report "Test S.7.15 failing."
      severity FAILURE;
    assert rotate_left(signed'("111"), 2) = signed'("111")
      report "Test S.7.16 failing."
      severity FAILURE;
    assert rotate_left(signed'("111"), 3) = signed'("111")
      report "Test S.7.17 failing."
      severity FAILURE;

    assert rotate_left(signed'("011"), 0) = signed'("011")
      report "Test S.7.18 failing."
      severity FAILURE;
    assert rotate_left(signed'("011"), 1) = signed'("110")
      report "Test S.7.19 failing."
      severity FAILURE;
    assert rotate_left(signed'("011"), 2) = signed'("101")
      report "Test S.7.20 failing."
      severity FAILURE;
    assert rotate_left(signed'("011"), 3) = signed'("011")
      report "Test S.7.21 failing."
      severity FAILURE;

    assert quiet report "S.7 tests done" severity note;

    -- S.8 tests
    assert rotate_right(s_snull, 0)'length = 0
      report "Test S.8.1 failing."
      severity FAILURE;
    assert rotate_right(s_snull, 1)'length = 0
      report "Test S.8.2 failing."
      severity FAILURE;
    assert rotate_right(s_snull, 100)'length = 0
      report "Test S.8.3 failing."
      severity FAILURE;

    assert rotate_right(signed'("0"), 0) = signed'("0")
      report "Test S.8.4 failing."
      severity FAILURE;
    assert rotate_right(signed'("0"), 1) = signed'("0")
      report "Test S.8.5 failing."
      severity FAILURE;
    assert rotate_right(signed'("0"), 50) = signed'("0")
      report "Test S.8.6 failing."
      severity FAILURE;

    assert rotate_right(signed'("1"), 0) = signed'("1")
      report "Test S.8.7 failing."
      severity FAILURE;
    assert rotate_right(signed'("1"), 1) = signed'("1")
      report "Test S.8.8 failing."
      severity FAILURE;
    assert rotate_right(signed'("1"), 39) = signed'("1")
      report "Test S.8.9 failing."
      severity FAILURE;

    assert rotate_right(signed'("000"), 0) = signed'("000")
      report "Test S.8.10 failing."
      severity FAILURE;
    assert rotate_right(signed'("000"), 1) = signed'("000")
      report "Test S.8.11 failing."
      severity FAILURE;
    assert rotate_right(signed'("000"), 2) = signed'("000")
      report "Test S.8.12 failing."
      severity FAILURE;
    assert rotate_right(signed'("000"), 3) = signed'("000")
      report "Test S.8.13 failing."
      severity FAILURE;

    assert rotate_right(signed'("111"), 0) = signed'("111")
      report "Test S.8.14 failing."
      severity FAILURE;
    assert rotate_right(signed'("111"), 1) = signed'("111")
      report "Test S.8.15 failing."
      severity FAILURE;
    assert rotate_right(signed'("111"), 2) = signed'("111")
      report "Test S.8.16 failing."
      severity FAILURE;
    assert rotate_right(signed'("111"), 3) = signed'("111")
      report "Test S.8.17 failing."
      severity FAILURE;

    assert rotate_right(signed'("100"), 0) = signed'("100")
      report "Test S.8.18 failing."
      severity FAILURE;
    assert rotate_right(signed'("100"), 1) = signed'("010")
      report "Test S.8.19 failing."
      severity FAILURE;
    assert rotate_right(signed'("100"), 2) = signed'("001")
      report "Test S.8.20 failing."
      severity FAILURE;
    assert rotate_right(signed'("100"), 3) = signed'("100")
      report "Test S.8.21 failing."
      severity FAILURE;

    assert quiet report "S.8 tests done" severity note;

    -- alex Z. A.1, A.2 tests
    -- A.1 tests
    ------------
    --                             -01111...1111 = 11111...1111 + 1  
    assert -(posmax) = negmin + (-neg1) severity failure;


    --                                                   - (-3) = 3   
    assert -signed'('1', '0', '1') = signed'('0', '1', '1')
      severity failure;
    
    --                                                    -(3) = -3
    assert -signed'('0', '1', '1') = signed'('1', '0', '1')
      severity failure;


    --                                                     -(-2)= 2
    assert -signed'('1', '1', '0') = signed'('0', '1', '0')
      severity failure;

    --                                                     -(2)= -2
    assert -signed'('0', '1', '0') = signed'('1', '1', '0')
      severity failure;


    --                                                     -(-1)= 1
    assert -signed'('1', '1', '1') = signed'('0', '0', '1')
      severity failure;
    
    --                                                     -(1)= -1
    assert -signed'('0', '0', '1') = signed'('1', '1', '1')
      severity failure; 


    assert -zero = zero severity failure;

    

    -- check a few random numbers (not a powerful tests because the 
    -- to_integer function utilizes the "-" for signed 

--   assert to_integer(-to_signed(-12345, max_size_checked)) = 
    --  12345            severity failure;

--   assert to_integer(-to_signed(4568432, max_size_checked)) = 
    --                            - 4568432           severity failure;

--   assert to_integer(-to_signed(-1024, max_size_checked)) = 
    --                               1024             severity failure;


    -- specific test for numeric_bit

--      THIS TEST IS FAILING. ALEX Z. is to report on it.
--   x := x + 123456;
--   for sign_bit in std_logic loop
--       case sign_bit is 
--          when '0' | 'L' | '1' | 'H' => null;
--          when others => x(x'left) := sign_bit;
--                         assert -x =  to_01(x, 'X')
--               report "failed -x =  to_01(x, 'X')" severity failure;
--       end case; 
--   end loop;
    
    assert quiet report "A.1 tests done" severity note;

    -- A.2 tests


    assert posmax = abs(negmin + (-neg1)) severity failure;


    --                                                  abs(-3) = 3   
    assert abs(signed'('1', '0', '1')) = signed'('0', '1', '1')
      severity failure;
    

    --                                                  abs(-2) = 2
    assert abs(signed'('1', '1', '0')) = signed'('0', '1', '0')
      severity failure;


    --                                                 abs(-1) = 1
    assert abs(signed'('1', '1', '1')) = signed'('0', '0', '1')
      severity failure;

    assert abs(zero) = zero severity failure;


--   assert to_integer(abs(to_signed(-12345, max_size_checked))) = 
--                                    12345         severity failure;

--   assert to_integer(abs(to_signed(-4568432, max_size_checked))) = 
--                                    4568432       severity failure;
    
    assert quiet report "A.2 tests done" severity note;
    
    assert FALSE
      report "END OF test suite tb2"
      severity note;

    wait;
  end process;
end architecture t1;

