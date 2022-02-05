-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.int_wire.all;

package functions is

	function to_std_logic(
		condition : in boolean
	)
	return std_logic;

	function multiplexer(
		data0 : in std_logic_vector(63 downto 0);
		data1 : in std_logic_vector(63 downto 0);
		sel   : in std_logic
	)
	return std_logic_vector;

	function store_data(
		data     : in std_logic_vector(63 downto 0);
		store_op : in store_operation_type
	)
	return std_logic_vector;

	function load_data(
		data       : in std_logic_vector(63 downto 0);
		byteenable : in std_logic_vector(7 downto 0);
		load_op    : in load_operation_type
	)
	return std_logic_vector;

	function to_hex(
		data : in std_logic_vector(63 downto 0)
	)
	return string;

	function is_branch(
		instr : in std_logic_vector(31 downto 0)
	)
	return std_logic;

	function is_return(
		instr : in std_logic_vector(31 downto 0)
	)
	return std_logic;

	function is_unconditional(
		instr : in std_logic_vector(31 downto 0)
	)
	return std_logic;

	function nan_boxing(
		data   : in std_logic_vector(63 downto 0);
		enable : in std_logic
	)
	return std_logic_vector;

	function and_reduce(arg: std_logic_vector) return ux01;
	function nand_reduce(arg: std_logic_vector) return ux01;
	function or_reduce(arg: std_logic_vector) return ux01;
	function nor_reduce(arg: std_logic_vector) return ux01;
	function xor_reduce(arg: std_logic_vector) return ux01;
	function xnor_reduce(arg: std_logic_vector) return ux01;

	function equal(
		data0 : in std_logic_vector;
		data1 : in std_logic_vector
	)
	return boolean;

end functions;

package body functions is

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

	function store_data(
		data     : in std_logic_vector(63 downto 0);
		store_op : in store_operation_type
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := (others => '0');
		if store_op.mem_sb = '1' then
			res := data(7 downto 0) & data(7 downto 0) & data(7 downto 0) & data(7 downto 0) & data(7 downto 0) & data(7 downto 0) & data(7 downto 0) & data(7 downto 0);
		elsif store_op.mem_sh = '1' then
			res := data(15 downto 0) & data(15 downto 0) & data(15 downto 0) & data(15 downto 0);
		elsif store_op.mem_sw = '1' then
			res := data(31 downto 0) & data(31 downto 0);
		elsif store_op.mem_sd = '1' then
			res := data;
		end if;
		return res;
	end store_data;

	function load_data(
		data       : in std_logic_vector(63 downto 0);
		byteenable : in std_logic_vector(7 downto 0);
		load_op    : in load_operation_type
	)
	return std_logic_vector is
		variable data_b : std_logic_vector(7 downto 0);
		variable data_h : std_logic_vector(15 downto 0);
		variable data_w : std_logic_vector(31 downto 0);
		variable data_d : std_logic_vector(63 downto 0);
		variable res    : std_logic_vector(63 downto 0);
	begin
		data_b := (others => '0');
		data_h := (others => '0');
		data_w := (others => '0');
		data_d := (others => '0');
		res    := (others => '0');
		if byteenable = "00000001" then
			data_b := data(7 downto 0);
		elsif byteenable = "00000010" then
			data_b := data(15 downto 8);
		elsif byteenable = "00000100" then
			data_b := data(23 downto 16);
		elsif byteenable = "00001000" then
			data_b := data(31 downto 24);
		elsif byteenable = "00010000" then
			data_b := data(39 downto 32);
		elsif byteenable = "00100000" then
			data_b := data(47 downto 40);
		elsif byteenable = "01000000" then
			data_b := data(55 downto 48);
		elsif byteenable = "10000000" then
			data_b := data(63 downto 56);
		elsif byteenable = "00000011" then
			data_h := data(15 downto 0);
		elsif byteenable = "00001100" then
			data_h := data(31 downto 16);
		elsif byteenable = "00110000" then
			data_h := data(47 downto 32);
		elsif byteenable = "11000000" then
			data_h := data(63 downto 48);
		elsif byteenable = "00001111" then
			data_w := data(31 downto 0);
		elsif byteenable = "11110000" then
			data_w := data(63 downto 32);
		elsif byteenable = "11111111" then
			data_d := data;
		end if;
		if load_op.mem_lb = '1' then
			res := std_logic_vector(resize(signed(data_b), 64));
		elsif load_op.mem_lh = '1' then
			res := std_logic_vector(resize(signed(data_h), 64));
		elsif load_op.mem_lw = '1' then
			res := std_logic_vector(resize(signed(data_w), 64));
		elsif load_op.mem_ld = '1' then
			res := std_logic_vector(resize(signed(data_d), 64));
		elsif load_op.mem_lbu = '1' then
			res := std_logic_vector(resize(unsigned(data_b), 64));
		elsif load_op.mem_lhu = '1' then
			res := std_logic_vector(resize(unsigned(data_h), 64));
		elsif load_op.mem_lwu = '1' then
			res := std_logic_vector(resize(unsigned(data_w), 64));
		end if;
		return res;
	end load_data;

	function to_hex(
		data : in std_logic_vector(63 downto 0)
	)
	return string is
		variable string_data  : string(1 to 16) := (others => 'x');
		variable partial_data : std_logic_vector(3 downto 0);
		variable index_j      : integer         := 0;
		variable index_k      : integer         := 3;
	begin
		for index_i in 1 to 16 loop
			partial_data := data(index_k downto index_j);
			case partial_data is
				when x"0"   => string_data(index_i) := '0';
				when x"1"   => string_data(index_i) := '1';
				when x"2"   => string_data(index_i) := '2';
				when x"3"   => string_data(index_i) := '3';
				when x"4"   => string_data(index_i) := '4';
				when x"5"   => string_data(index_i) := '5';
				when x"6"   => string_data(index_i) := '6';
				when x"7"   => string_data(index_i) := '7';
				when x"8"   => string_data(index_i) := '8';
				when x"9"   => string_data(index_i) := '9';
				when x"A"   => string_data(index_i) := 'A';
				when x"B"   => string_data(index_i) := 'B';
				when x"C"   => string_data(index_i) := 'C';
				when x"D"   => string_data(index_i) := 'D';
				when x"E"   => string_data(index_i) := 'E';
				when x"F"   => string_data(index_i) := 'F';
				when others => string_data(index_i) := 'X';
			end case;
			index_j      := index_k;
			index_k      := index_k + 4;
		end loop;
		return string_data;
	end function to_hex;

	function is_branch(
		instr : in std_logic_vector(31 downto 0)
	)
	return std_logic is
		variable branch : std_logic;
	begin
		branch := '0';
		if (instr(1 downto 0) = "01") then
			case instr(15 downto 13) is
				when "110" => branch := '1';
				when "111" => branch := '1';
				when others => null;
			end case;
		elsif (instr(1 downto 0) = "11") then
			case instr(6 downto 2) is
				when "11000" => branch := '1';
				when others => null;
			end case;
		end if;
		return branch;
	end function is_branch;

	function is_return(
		instr : in std_logic_vector(31 downto 0)
	)
	return std_logic is
		variable ret      : std_logic;
		variable rs1      : std_logic_vector(4 downto 0);
		variable rd       : std_logic_vector(4 downto 0);
		variable link_rs1 : boolean;
		variable link_rd  : boolean;
	begin
		ret := '0';
		rs1 := instr(19 downto 15);
		rd := instr(11 downto 7);
		link_rs1 := (rs1 = "00001") or (rs1 = "00101");
		link_rd := (rd = "00001") or (rd = "00101");
		if (instr(1 downto 0) = "10") then
			case instr(15 downto 12) is
				when "1000" => ret := to_std_logic(link_rs1);
				when "1001" => ret := to_std_logic(rs1 = "00101");
				when others => null;
			end case;
		elsif (instr(1 downto 0) = "11") then
			case instr(6 downto 2) is
				when "11001" => ret := to_std_logic((link_rs1 and not(link_rd)) or
										(link_rs1 and link_rd and (rs1 /= rd)));
				when others => null;
			end case;
		end if;
		return ret;
	end function is_return;

	function is_unconditional(
		instr : in std_logic_vector(31 downto 0)
	)
	return std_logic is
		variable ucond    : std_logic;
		variable rd       : std_logic_vector(4 downto 0);
	begin
		ucond := '0';
		rd := instr(11 downto 7);
		if (instr(1 downto 0) = "01") then
			case instr(15 downto 13) is
				when "101" => ucond := '1';
				when others => null;
			end case;
		elsif (instr(1 downto 0) = "11") then
			case instr(6 downto 2) is
				when "11011" => ucond := to_std_logic(rd = "00000");
				when others => null;
			end case;
		end if;
		return ucond;
	end function is_unconditional;

	function nan_boxing(
		data   : in std_logic_vector(63 downto 0);
		enable : in std_logic
	)
	return std_logic_vector is
	begin
		if enable = '1' then
			return X"FFFFFFFF" & data(31 downto 0);
		else
			return data;
		end if;
	end function nan_boxing;

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

	function equal(
		data0 : in std_logic_vector;
		data1 : in std_logic_vector
	)
	return boolean is
		variable result: boolean;
	begin
		result := false;
		if or_reduce(data0 xor data1) = '0' then
			result := true;
		end if;
		return result;
	end;

end functions;
