-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;
use work.lzc_wire.all;
use work.int_wire.all;
use work.fp_cons.all;
use work.fp_typ.all;
use work.fp_wire.all;

entity fp_dec is
	port(
		fp_dec_i : in  fp_dec_in_type;
		fp_dec_o : out fp_dec_out_type
	);
end fp_dec;

architecture behavior of fp_dec is

begin

	process(fp_dec_i)
		variable v : fp_dec_reg_type;

	begin
		v.instr := fp_dec_i.instr;

		v.imm_i := std_logic_vector(resize(signed(v.instr(31 downto 20)), 64));
		v.imm_s := std_logic_vector(resize(signed(v.instr(31 downto 25) & v.instr(11 downto 7)), 64));

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct7 := v.instr(31 downto 25);
		v.rm := v.instr(14 downto 12);

		v.imm := (others => '0');

		v.int_rden1 := '0';
		v.int_wren := '0';

		v.fpu_rden1 := '0';
		v.fpu_rden2 := '0';
		v.fpu_rden3 := '0';
		v.fpu_wren := '0';

		v.fpu_load := '0';
		v.fpu_store := '0';

		v.fpu := '0';

		v.fpu_op := init_fp_operation;
		v.load_op := init_load_operation;
		v.store_op := init_store_operation;
		v.fpu_op.fcvt_op := v.instr(21 downto 20);

		v.valid := '0';

		case v.opcode is

			when opcode_fload | opcode_fstore =>

				v.int_rden1 := '1';
				if v.opcode(5) = '1' then
					v.imm := v.imm_s;
					v.fpu_rden2 := '1';
					v.fpu := '1';
					v.fpu_store := '1';
					case v.funct3 is
						when funct_sw  => v.store_op.mem_sw := '1';
						when funct_sd  => v.store_op.mem_sd := '1';
						when others     => null;
					end case;
				elsif v.opcode(5) = '0' then
					v.imm := v.imm_i;
					v.fpu_wren := '1';
					v.fpu := '1';
					v.fpu_load := '1';
					case v.funct3 is
						when funct_lw  => v.load_op.mem_lw := '1';
						when funct_ld  => v.load_op.mem_ld := '1';
						when others     => null;
					end case;
				end if;
				v.valid := '1';

			when opcode_fp =>

				case v.funct7(6 downto 2) is

					when funct_fadd | funct_fsub | funct_fmul | funct_fdiv =>

						v.fpu_rden1 := '1';
						v.fpu_rden2 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.fpu_op.fadd := to_std_logic(v.funct7(3 downto 2) = "00");
						v.fpu_op.fsub := to_std_logic(v.funct7(3 downto 2) = "01");
						v.fpu_op.fmul := to_std_logic(v.funct7(3 downto 2) = "10");
						v.fpu_op.fdiv := to_std_logic(v.funct7(3 downto 2) = "11");
						v.fpu_op.fnan := '1';
						v.fpu_op.fmcycle := '1';
						v.fpu_op.fflag := '1';
						v.valid := '1';

					when funct_fsqrt =>

						v.fpu_rden1 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.fpu_op.fsqrt := '1';
						v.fpu_op.fnan := '1';
						v.fpu_op.fmcycle := '1';
						v.fpu_op.fflag := '1';
						v.valid := '1';

					when funct_fsgnj =>

						v.fpu_rden1 := '1';
						v.fpu_rden2 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.fpu_op.fsgnj := '1';
						v.fpu_op.fnan := '1';
						v.valid := '1';

					when funct_fmax =>

						v.fpu_rden1 := '1';
						v.fpu_rden2 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.fpu_op.fmax := '1';
						v.fpu_op.fflag := '1';
						v.valid := '1';

					when funct_fcmp =>

						v.int_wren := '1';
						v.fpu_rden1 := '1';
						v.fpu_rden2 := '1';
						v.fpu := '1';
						v.fpu_op.fcmp := '1';
						v.fpu_op.fnan := '1';
						v.fpu_op.fflag := '1';
						v.valid := '1';

					when funct_fmv_f2i | funct_fmv_i2f =>

						if v.funct7(3) = '1' then

							v.int_rden1 := '1';
							v.fpu_wren := '1';
							v.fpu := '1';
							v.fpu_op.fmv_i2f := '1';
							v.valid := '1';

						elsif v.funct7(3) = '0' then

							v.int_wren := '1';
							v.fpu_rden1 := '1';
							v.fpu := '1';
							v.fpu_op.fmv_f2i := to_std_logic(v.rm = "000");
							v.fpu_op.fclass := to_std_logic(v.rm = "001");
							v.valid := '1';

						end if;

					when funct_fcvt_f2f =>

						v.fpu_rden1 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.fpu_op.fcvt_f2f := '1';
						v.fpu_op.fflag := '1';
						v.valid := '1';

					when funct_fcvt_f2i | funct_fcvt_i2f =>

						if v.funct7(3) = '1' then
							v.int_rden1 := '1';
							v.fpu_wren := '1';
							v.fpu_op.fcvt_i2f := '1';
						elsif v.funct7(3) = '0' then
							v.int_wren := '1';
							v.fpu_rden1 := '1';
							v.fpu_op.fcvt_f2i := '1';
							v.fpu_op.fnan := '1';
						end if;
						v.fpu := '1';
						v.fpu_op.fflag := '1';
						v.valid := '1';

					when others =>

						null;

				end case;

			when opcode_fmadd | opcode_fmsub | opcode_fnmsub | opcode_fnmadd =>

				v.fpu_rden1 := '1';
				v.fpu_rden2 := '1';
				v.fpu_rden3 := '1';
				v.fpu_wren := '1';
				v.fpu := '1';
				v.fpu_op.fmadd := to_std_logic(v.opcode(3 downto 2) = "00");
				v.fpu_op.fmsub := to_std_logic(v.opcode(3 downto 2) = "01");
				v.fpu_op.fnmsub := to_std_logic(v.opcode(3 downto 2) = "10");
				v.fpu_op.fnmadd := to_std_logic(v.opcode(3 downto 2) = "11");
				v.fpu_op.fmcycle := '1';
				v.fpu_op.fflag := '1';
				v.valid := '1';

			when others =>

				null;

		end case;

		fp_dec_o.imm <= v.imm;
		fp_dec_o.int_rden1 <= v.int_rden1;
		fp_dec_o.int_wren <= v.int_wren;
		fp_dec_o.fpu_rden1 <= v.fpu_rden1;
		fp_dec_o.fpu_rden2 <= v.fpu_rden2;
		fp_dec_o.fpu_rden3 <= v.fpu_rden3;
		fp_dec_o.fpu_wren <= v.fpu_wren;
		fp_dec_o.fpu_load <= v.fpu_load;
		fp_dec_o.fpu_store <= v.fpu_store;
		fp_dec_o.fpu <= v.fpu;
		fp_dec_o.fpu_op <= v.fpu_op;
		fp_dec_o.load_op <= v.load_op;
		fp_dec_o.store_op <= v.store_op;
		fp_dec_o.valid <= v.valid;

	end process;

end architecture;
