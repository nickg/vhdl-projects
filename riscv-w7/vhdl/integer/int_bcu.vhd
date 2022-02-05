-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;
use work.int_constants.all;
use work.int_wire.all;

entity int_bcu is
	port(
		int_bcu_i : in  int_bcu_in_type;
		int_bcu_o : out int_bcu_out_type
	);
end int_bcu;

architecture behavior of int_bcu is

begin

	process(int_bcu_i)
		variable cond      : std_logic;
		variable rs1       : std_logic_vector(63 downto 0);
		variable rs2       : std_logic_vector(63 downto 0);
		variable branch_op : branch_operation_type;

	begin
		cond      := '0';
		rs1       := int_bcu_i.rs1;
		rs2       := int_bcu_i.rs2;
		branch_op := int_bcu_i.branch_op;

		if branch_op.beq = '1' then
			cond := to_std_logic(rs1 = rs2);
		elsif branch_op.bne = '1' then
			cond := to_std_logic(rs1 /= rs2);
		elsif branch_op.blt = '1' then
			cond := to_std_logic(signed(rs1) < signed(rs2));
		elsif branch_op.bge = '1' then
			cond := to_std_logic(signed(rs1) >= signed(rs2));
		elsif branch_op.bltu = '1' then
			cond := to_std_logic(unsigned(rs1) < unsigned(rs2));
		elsif branch_op.bgeu = '1' then
			cond := to_std_logic(unsigned(rs1) >= unsigned(rs2));
		end if;

		int_bcu_o.jump <= int_bcu_i.jal or int_bcu_i.jalr or (int_bcu_i.branch and cond);

	end process;

end architecture;
