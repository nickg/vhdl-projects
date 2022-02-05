-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.csr_constants.all;
use work.csr_wire.all;
use work.csr_functions.all;

entity csr_alu is
	port(
		csr_alu_i : in  csr_alu_in_type;
		csr_alu_o : out csr_alu_out_type
	);
end csr_alu;

architecture behavior of csr_alu is

begin

	process(csr_alu_i)
		variable res   : std_logic_vector(63 downto 0);
		variable rs1   : std_logic_vector(63 downto 0);
		variable data  : std_logic_vector(63 downto 0);
		variable funct : std_logic_vector(2 downto 0);

	begin
		res   := (others => '0');
		rs1   := multiplexer(csr_alu_i.rs1, csr_alu_i.imm, csr_alu_i.funct(2));
		data  := csr_alu_i.data;
		funct := csr_alu_i.funct;

		case funct is
			when "001" | "101" => res := rs1;
			when "010" | "110" => res := data or rs1;
			when "011" | "111" => res := data and (not rs1);
			when others        => null;
		end case;

		csr_alu_o.result <= res;

	end process;

end architecture;
