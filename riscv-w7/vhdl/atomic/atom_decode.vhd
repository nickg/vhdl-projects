-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.atom_constants.all;
use work.atom_wire.all;
use work.int_wire.all;

entity atom_decode is
	port(
		atom_decode_i : in  atom_decode_in_type;
		atom_decode_o : out atom_decode_out_type
	);
end atom_decode;

architecture behavior of atom_decode is

begin

	process(atom_decode_i)

		variable v : atom_decode_reg_type;

	begin

		v.instr := atom_decode_i.instr;

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct5 := v.instr(31 downto 27);

		v.int_rden1 := '0';
		v.int_rden2 := '0';
		v.int_wren := '0';

		v.load := '0';
		v.store := '0';
		v.ldst := '0';

		v.atom_op := init_atom_operation;
		v.load_op := init_load_operation;
		v.store_op := init_store_operation;

		v.valid := '1';

		case v.opcode is
			when opcode_atomic =>
				v.atom_op.atom_rl := v.instr(25);
				v.atom_op.atom_aq := v.instr(26);
				case v.funct5 is
					when funct5_lr =>
						v.atom_op.atom_lr := '1';
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.load := '1';
					when funct5_sc =>
						v.atom_op.atom_sc := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.int_wren := '1';
						v.store := '1';
					when funct5_amoswap =>
						v.atom_op.atom_amoswap := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amoadd =>
						v.atom_op.atom_amoadd := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amoxor =>
						v.atom_op.atom_amoxor := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amoand =>
						v.atom_op.atom_amoand := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amoor =>
						v.atom_op.atom_amoor := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amomin =>
						v.atom_op.atom_amomin := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amomax =>
						v.atom_op.atom_amomax := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amominu =>
						v.atom_op.atom_amominu := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when funct5_amomaxu =>
						v.atom_op.atom_amomaxu := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.load := '1';
						v.ldst := '1';
					when others =>
						v.valid := '0';
				end case;
				case v.funct3 is
					when funct3_32 =>
						v.atom_op.atom_word := '1';
						if (v.load or v.ldst) = '1' then
							v.load_op.mem_lw := '1';
						end if;
						if (v.store or v.ldst) = '1' then
							v.store_op.mem_sw := '1';
						end if;
					when funct3_64 =>
						v.atom_op.atom_word := '0';
						if (v.load or v.ldst) = '1' then
							v.load_op.mem_ld := '1';
						end if;
						if (v.store or v.ldst) = '1' then
							v.store_op.mem_sd := '1';
						end if;
					when others =>
						v.valid := '0';
				end case;
			when others =>
				v.valid := '0';
		end case;

		atom_decode_o.int_rden1 <= v.int_rden1;
		atom_decode_o.int_rden2 <= v.int_rden2;
		atom_decode_o.int_wren <= v.int_wren;
		atom_decode_o.load <= v.load;
		atom_decode_o.store <= v.store;
		atom_decode_o.ldst <= v.ldst;
		atom_decode_o.atom_op <= v.atom_op;
		atom_decode_o.load_op <= v.load_op;
		atom_decode_o.store_op <= v.store_op;
		atom_decode_o.valid <= v.valid;

	end process;

end architecture;
