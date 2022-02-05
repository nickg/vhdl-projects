-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;
use work.int_constants.all;
use work.int_wire.all;

entity int_alu is
	port(
		int_alu_i : in  int_alu_in_type;
		int_alu_o : out int_alu_out_type
	);
end int_alu;

architecture behavior of int_alu is

begin

	process(int_alu_i)
		variable res    : std_logic_vector(63 downto 0);
		variable rs1    : std_logic_vector(63 downto 0);
		variable rs2    : std_logic_vector(63 downto 0);
		variable alu_op : alu_operation_type;
		variable funct  : std_logic_vector(2 downto 0);
		variable word   : std_logic;
		variable op     : std_logic;

	begin
		res    := (others => '0');
		rs1    := int_alu_i.rs1;
		rs2    := multiplexer(int_alu_i.rs2, int_alu_i.imm, int_alu_i.sel);
		alu_op := int_alu_i.alu_op;
		word   := int_alu_i.word;

		if alu_op.alu_add = '1' then
			res := std_logic_vector(unsigned(rs1) + unsigned(rs2));
		elsif alu_op.alu_sub = '1' then
			res := std_logic_vector(unsigned(rs1) - unsigned(rs2));
		elsif alu_op.alu_sll = '1' then
			rs2(5) := rs2(5) and (not word);
			res := std_logic_vector(shift_left(unsigned(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		elsif alu_op.alu_slt = '1' then
			res(0) := to_std_logic(signed(rs1) < signed(rs2));
		elsif alu_op.alu_sltu = '1' then
			res(0) := to_std_logic(unsigned(rs1) < unsigned(rs2));
		elsif alu_op.alu_xor = '1' then
			res := rs1 xor rs2;
		elsif alu_op.alu_srl = '1' then
			rs2(5) := rs2(5) and (not word);
			if word = '1' then
				rs1(63 downto 32) := (others => '0');
			end if;
			res := std_logic_vector(shift_right(unsigned(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		elsif alu_op.alu_sra = '1' then
			rs2(5) := rs2(5) and (not word);
			if word = '1' then
				rs1(63 downto 32) := (others => rs1(31));
			end if;
			res := std_logic_vector(shift_right(signed(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		elsif alu_op.alu_or = '1' then
			res := rs1 or rs2;
		elsif alu_op.alu_and = '1' then
			res := rs1 and rs2;
		end if;

		if word = '1' then
			res(63 downto 31) := (others => res(31));
		end if;

		int_alu_o.res <= res;

	end process;

end architecture;
