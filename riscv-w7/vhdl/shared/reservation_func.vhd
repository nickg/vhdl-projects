-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.functions.all;
use work.reservation_wire.all;

package reservation_func is

	function thermometer(
		req : in std_logic_vector(2**number_of_cores-1 downto 0);
		pri : in std_logic_vector(2**number_of_cores-1 downto 0)
	)
	return thermometer_type;

	function reduction(
		ther : in thermometer_type
	)
	return std_logic_vector;

	function fixed_priority(
		red : in std_logic_vector(2**number_of_cores-1 downto 0)
	)
	return std_logic_vector;

end package;

package body reservation_func is

	function thermometer(
		req : in std_logic_vector(2**number_of_cores-1 downto 0);
		pri : in std_logic_vector(2**number_of_cores-1 downto 0)
	)
	return thermometer_type is
		variable ther : thermometer_type;
	begin
		for i in 0 to 2**number_of_cores-1 loop
			ther(0)(i) := req(i);
			ther(1)(i) := pri(i) and req(i);
		end loop;
		return ther;
	end function thermometer;

	function reduction(
		ther : in thermometer_type
	)
	return std_logic_vector is
		variable red : std_logic_vector(2**number_of_cores-1 downto 0);
		variable th0 : std_logic;
		variable th1 : std_logic;
	begin
		th0 := or_reduce(ther(0));
		th1 := or_reduce(ther(1));
		for i in 0 to 2**number_of_cores-1 loop
			red(i) := not((ther(0)(i) xor ther(1)(i)) or (th0 xor th1));
		end loop;
		return red;
	end function reduction;

	function fixed_priority(
		red : in std_logic_vector(2**number_of_cores-1 downto 0)
	)
	return std_logic_vector is
		variable gnt : std_logic_vector(2**number_of_cores-1 downto 0);
	begin
		gnt := (others => '0');
		for i in 0 to 2**number_of_cores-1 loop
			if red(i) = '1' then
				gnt(i) := '1';
				exit;
			end if;
		end loop;
		return gnt;
	end function fixed_priority;

end reservation_func;
