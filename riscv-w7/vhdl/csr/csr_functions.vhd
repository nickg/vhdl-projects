-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.csr_constants.all;

package csr_functions is

	function multiplexer(
		data0 : in std_logic_vector(63 downto 0);
		data1 : in std_logic_vector(63 downto 0);
		sel   : in std_logic
	)
	return std_logic_vector;

	function to_std_logic(
		condition : in boolean
	)
	return std_logic;

end csr_functions;

package body csr_functions is

	function multiplexer(
		data0 : in std_logic_vector(63 downto 0);
		data1 : in std_logic_vector(63 downto 0);
		sel   : in std_logic
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		if sel = '0' then
			res := data0;
		else
			res := data1;
		end if;
		return res;
	end multiplexer;

	function to_std_logic(
		condition : in boolean
	)
	return std_logic is
	begin
		if condition then
			return '1';
		else
			return '0';
		end if;
	end function to_std_logic;

end csr_functions;
