-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;

package plic_func is

	function and_logic(
		left  : std_logic_vector;
		right : std_logic
	)
	return std_logic_vector;

end plic_func;

package body plic_func is

	function and_logic(
		left  : std_logic_vector;
		right : std_logic
	)
	return std_logic_vector is
		variable res : std_logic_vector(left'length-1 downto 0);
	begin
		for i in 0 to left'length-1 loop
			res(i) := left(i) and right;
		end loop;
		return res;
	end function and_logic;

end plic_func;
