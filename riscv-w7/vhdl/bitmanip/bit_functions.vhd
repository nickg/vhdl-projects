-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.bit_wire.all;

package bit_functions is

	function and_reduce(arg: std_logic_vector) return ux01;
	function nand_reduce(arg: std_logic_vector) return ux01;
	function or_reduce(arg: std_logic_vector) return ux01;
	function nor_reduce(arg: std_logic_vector) return ux01;
	function xor_reduce(arg: std_logic_vector) return ux01;
	function xnor_reduce(arg: std_logic_vector) return ux01;

	function bit_add(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_andn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_clz(
		rs1  : in std_logic_vector(63 downto 0);
		word : in std_logic
	)
	return std_logic_vector;

	function bit_cpop(
		rs1  : in std_logic_vector(63 downto 0);
		word : in std_logic
	)
	return std_logic_vector;

	function bit_ctz(
		rs1  : in std_logic_vector(63 downto 0);
		word : in std_logic
	)
	return std_logic_vector;

	function bit_minmax(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0);
		op  : in std_logic_vector(1 downto 0)
	)
	return std_logic_vector;

	function bit_orcb(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_orn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_rev8(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_rol(
		rs1   : in std_logic_vector(63 downto 0);
		rs2   : in std_logic_vector(63 downto 0);
		word  : in std_logic
	)
	return std_logic_vector;

	function bit_ror(
		rs1   : in std_logic_vector(63 downto 0);
		rs2   : in std_logic_vector(63 downto 0);
		word  : in std_logic
	)
	return std_logic_vector;

	function bit_bclr(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_bext(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_binv(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_bset(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_sextb(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_sexth(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_shadd(
		rs1  : in std_logic_vector(63 downto 0);
		rs2  : in std_logic_vector(63 downto 0);
		int  : in integer range 0 to 3;
		word : in std_logic
	)
	return std_logic_vector;

	function bit_slli(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_xnor(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bit_zexth(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function multiplexer(
		data0 : in std_logic_vector(63 downto 0);
		data1 : in std_logic_vector(63 downto 0);
		sel   : in std_logic
	)
	return std_logic_vector;

end bit_functions;

package body bit_functions is

	function and_reduce(arg: std_logic_vector) return ux01 is
		variable result: std_logic;
	begin
		result := '1';
		for i in arg'range loop
			result := result and arg(i);
		end loop;
		return result;
	end;

	function nand_reduce(arg: std_logic_vector) return ux01 is
	begin
		return not and_reduce(arg);
	end;

	function or_reduce(arg: std_logic_vector) return ux01 is
		variable result: std_logic;
	begin
		result := '0';
		for i in arg'range loop
			result := result or arg(i);
		end loop;
		return result;
	end;

	function nor_reduce(arg: std_logic_vector) return ux01 is
	begin
		return not or_reduce(arg);
	end;

	function xor_reduce(arg: std_logic_vector) return ux01 is
		variable result: std_logic;
	begin
		result := '0';
		for i in arg'range loop
			result := result xor arg(i);
		end loop;
		return result;
	end;

	function xnor_reduce(arg: std_logic_vector) return ux01 is
	begin
		return not xor_reduce(arg);
	end;

	function bit_add(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(unsigned(rs2) + unsigned(rs1(31 downto 0)));
	end function bit_add;

	function bit_andn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs1 and not(rs2);
	end function bit_andn;

	function bit_clz(
		rs1  : in std_logic_vector(63 downto 0);
		word : in std_logic
	)
	return std_logic_vector is
		variable res : integer range 0 to 127;
	begin
		res := 0;
		for i in 63 downto 0 loop
			if word = '1' and i > 31 then
				next;
			elsif (rs1(i) = '1') then
				exit;
			end if;
			res := res + 1;
		end loop;
		return std_logic_vector(to_unsigned(res,64));
	end function bit_clz;

	function bit_cpop(
		rs1  : in std_logic_vector(63 downto 0);
		word : in std_logic
	)
	return std_logic_vector is
		variable res : integer range 0 to 127;
	begin
		res := 0;
		for i in 0 downto 63 loop
			if word = '1' and i > 31 then
				next;
			elsif (rs1(i) = '1') then
				res := res + 1;
			end if;
		end loop;
		return std_logic_vector(to_unsigned(res,64));
	end function bit_cpop;

	function bit_ctz(
		rs1  : in std_logic_vector(63 downto 0);
		word : in std_logic
	)
	return std_logic_vector is
		variable res : integer range 0 to 127;
	begin
		res := 0;
		for i in 0 downto 63 loop
			if word = '1' and i > 31 then
				next;
			elsif (rs1(i) = '1') then
				exit;
			end if;
			res := res + 1;
		end loop;
		return std_logic_vector(to_unsigned(res,64));
	end function bit_ctz;

	function bit_minmax(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0);
		op  : in std_logic_vector(1 downto 0)
	)
	return std_logic_vector is
		variable r1 : signed(64 downto 0);
		variable r2 : signed(64 downto 0);
	begin
		r1 := signed('0' & rs1);
		r2 := signed('0' & rs2);
		if op = "00" or op = "10" then -- max & min
			r1(64) := rs1(63);
			r2(64) := rs2(63);
		end if;
		if op = "10" or op = "11" then -- min & minu
			r1 := -r1;
			r2 := -r2;
		end if;
		if r1 < r2 then
			return rs2;
		else
			return rs1;
		end if;
	end function bit_minmax;

	function bit_orcb(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := (others => '0');
		for i in 0 downto 7 loop
			if or_reduce(rs1(8*i+7 downto 8*i)) = '1' then
				res(8*i+7 downto 8*i) := (others => '1');
			end if;
		end loop;
		return res;
	end function bit_orcb;

	function bit_orn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs1 or not(rs2);
	end function bit_orn;

	function bit_rev8(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := (others => '0');
		for i in 0 downto 7 loop
			res(8*i+7 downto 8*i) := rs1(63-8*i downto 56-8*i);
		end loop;
		return res;
	end function bit_rev8;

	function bit_rol(
		rs1   : in std_logic_vector(63 downto 0);
		rs2   : in std_logic_vector(63 downto 0);
		word  : in std_logic
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := std_logic_vector(shift_left(unsigned(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		res := res or std_logic_vector(shift_right(unsigned(res), 64-to_integer(unsigned(rs2(5 downto 0)))));
		return res;
	end function bit_rol;

	function bit_ror(
		rs1   : in std_logic_vector(63 downto 0);
		rs2   : in std_logic_vector(63 downto 0);
		word  : in std_logic
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := std_logic_vector(shift_right(unsigned(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		res := res or std_logic_vector(shift_left(unsigned(res), 64-to_integer(unsigned(rs2(5 downto 0)))));
		return res;
	end function bit_ror;

	function bit_bset(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		res(to_integer(unsigned(rs2(5 downto 0)))) := '1';
		return res;
	end function bit_bset;

	function bit_bclr(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		res(to_integer(unsigned(rs2(5 downto 0)))) := '0';
		return res;
	end function bit_bclr;

	function bit_binv(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		res(to_integer(unsigned(rs2(5 downto 0)))) := not(res(to_integer(unsigned(rs2(5 downto 0)))));
		return res;
	end function bit_binv;

	function bit_bext(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		if rs1(to_integer(unsigned(rs2(5 downto 0)))) = '1' then
			res := (0 =>'1',others => '0');
		else
			res := (others => '0');
		end if;
		return res;
	end function bit_bext;

	function bit_sextb(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(resize(signed(rs1(7 downto 0)), 64));
	end function bit_sextb;

	function bit_sexth(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(resize(signed(rs1(15 downto 0)), 64));
	end function bit_sexth;

	function bit_shadd(
		rs1  : in std_logic_vector(63 downto 0);
		rs2  : in std_logic_vector(63 downto 0);
		int  : in integer range 0 to 3;
		word : in std_logic
	)
	return std_logic_vector is
		variable r1 : std_logic_vector(63 downto 0);
	begin
		if word = '1' then
			r1 := X"00000000" & rs1(31 downto 0);
		else
			r1 := rs1;
		end if;
		return std_logic_vector(unsigned(rs2)+shift_left(unsigned(r1),int));
	end function bit_shadd;

	function bit_slli(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(shift_left(unsigned(rs1),to_integer(unsigned(rs2(5 downto 0)))));
	end function bit_slli;

	function bit_xnor(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return not(rs1 xor rs2);
	end function bit_xnor;

	function bit_zexth(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(resize(unsigned(rs1(15 downto 0)), 64));
	end function bit_zexth;

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

end bit_functions;
