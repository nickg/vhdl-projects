-- File: test_randgen.vhd
-- Generated by MyHDL 0.11
-- Date: Wed Sep  1 11:52:06 2021


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

use work.pck_myhdl_011.all;

entity test_randgen is
end entity test_randgen;


architecture MyHDL of test_randgen is



signal clock: std_logic;
signal enable: std_logic;
signal random_word: unsigned(30 downto 0);
signal reset: std_logic;

begin




TEST_RANDGEN_DUT_LOGIC: process (clock, reset) is
    variable lfsr: unsigned(63 downto 0);
    variable word: unsigned(30 downto 0);
    variable tmp0: integer;
begin
    if (reset = '1') then
        random_word <= to_unsigned(0, 31);
        lfsr := to_unsigned(1, 64);
    elsif rising_edge(clock) then
        if bool(enable) then
            for i in 0 to 31-1 loop
                word(i) := lfsr(63);
                tmp0 := to_integer((((lfsr(63) xor lfsr(62)) xor lfsr(60)) xor lfsr(59)));
                lfsr := shift_left(lfsr, 1);
                lfsr(0) := stdl(tmp0);
            end loop;
            random_word <= word;
        end if;
    end if;
end process TEST_RANDGEN_DUT_LOGIC;

TEST_RANDGEN_STIMULUS: process is
    variable L: line;
begin
    enable <= '0';
    clock <= '0';
    reset <= '0';
    wait for 10 * 1 ns;
    reset <= '1';
    wait for 10 * 1 ns;
    reset <= '0';
    enable <= '1';
    for i in 0 to (2 ** 20)-1 loop
        wait for 10 * 1 ns;
        clock <= '1';
        wait for 10 * 1 ns;
        clock <= '0';
        write(L, to_hstring(random_word));
        writeline(output, L);
    end loop;
    wait;
end process TEST_RANDGEN_STIMULUS;

end architecture MyHDL;
