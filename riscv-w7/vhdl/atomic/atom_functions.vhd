-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.atom_wire.all;

package atom_functions is

	function atom_minmax(
		rs1  : in std_logic_vector(63 downto 0);
		rs2  : in std_logic_vector(63 downto 0);
		op   : in std_logic_vector(1 downto 0);
		word : std_logic
	)
	return std_logic_vector;

end atom_functions;

package body atom_functions is

	function atom_minmax(
		rs1  : in std_logic_vector(63 downto 0);
		rs2  : in std_logic_vector(63 downto 0);
		op   : in std_logic_vector(1 downto 0);
		word : std_logic
	)
	return std_logic_vector is
		variable r1 : signed(64 downto 0);
		variable r2 : signed(64 downto 0);
	begin
		r1 := signed('0' & rs1);
		r2 := signed('0' & rs2);
		if op = "00" or op = "01" then -- max & min
			if word = '0' then
				r1(64) := rs1(63);
				r2(64) := rs2(63);
			elsif word = '1' then
				r1(64 downto 32) := (others => rs1(31));
				r2(64 downto 32) := (others => rs2(31));
			end if;
		end if;
		if op = "00" or op = "10" then -- min & minu
			r1 := -r1;
			r2 := -r2;
		end if;
		if r1 < r2 then
			return rs2;
		else
			return rs1;
		end if;
	end function atom_minmax;

end atom_functions;
