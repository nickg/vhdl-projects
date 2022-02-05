-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.atom_constants.all;
use work.atom_wire.all;
use work.atom_functions.all;

entity atom_alu is
	port(
		atom_alu_i : in  atom_alu_in_type;
		atom_alu_o : out atom_alu_out_type
	);
end atom_alu;

architecture behavior of atom_alu is

begin

	process(atom_alu_i)

		variable res     : std_logic_vector(63 downto 0);
		variable lval    : std_logic_vector(63 downto 0);
		variable rs2     : std_logic_vector(63 downto 0);
		variable op      : std_logic_vector(1 downto 0);
		variable word    : std_logic;
		variable atom_op : atom_operation_type;

	begin

		res := (others => '0');
		lval := atom_alu_i.lval;
		rs2 := atom_alu_i.rs2;
		op := (others => '0');
		word := atom_alu_i.atom_op.atom_word;
		atom_op := atom_alu_i.atom_op;

		if atom_op.atom_amomin = '1' then
			op := "00";
		elsif atom_op.atom_amomax = '1' then
			op := "01";
		elsif atom_op.atom_amominu = '1' then
			op := "10";
		elsif atom_op.atom_amomaxu = '1' then
			op := "11";
		end if;

		if atom_op.atom_amoswap = '1' then
			res := rs2;
		elsif atom_op.atom_amoadd = '1' then
			res := std_logic_vector(unsigned(lval) + unsigned(rs2));
		elsif atom_op.atom_amoxor = '1' then
			res := lval xor rs2;
		elsif atom_op.atom_amoand = '1' then
			res := lval and rs2;
		elsif atom_op.atom_amoor = '1' then
			res := lval or rs2;
		elsif (atom_op.atom_amomin or atom_op.atom_amomax or atom_op.atom_amominu or atom_op.atom_amomaxu) = '1' then
			res := atom_minmax(lval,rs2,op,word);
		end if;

		atom_alu_o.res <= res;

	end process;

end architecture;
