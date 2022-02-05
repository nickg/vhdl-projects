-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.bit_constants.all;
use work.bit_wire.all;

entity bit_decode is
	port(
		bit_decode_i : in  bit_decode_in_type;
		bit_decode_o : out bit_decode_out_type
	);
end bit_decode;

architecture behavior of bit_decode is

begin

	process(bit_decode_i)

		variable v : bit_decode_reg_type;

	begin

		v.instr := bit_decode_i.instr;

		v.imm5 := std_logic_vector(resize(unsigned(v.instr(24 downto 20)), 64));
		v.imm6 := std_logic_vector(resize(unsigned(v.instr(25 downto 20)), 64));

		v.imm := (others => '0');

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct5 := v.instr(24 downto 20);
		v.funct6 := v.instr(31 downto 26);
		v.funct7 := v.instr(31 downto 25);
		v.funct12 := v.instr(31 downto 20);

		v.int_rden1 := '0';
		v.int_rden2 := '0';
		v.int_wren := '0';

		v.bit_op := init_bit_operation;

		v.bitm := '0';
		v.valid := '1';

		case v.opcode is

			when opcode_imm =>

				v.int_rden1 := '1';
				v.int_wren := '1';

				v.bit_op.bit_imm := '1';

				v.imm := v.imm6;
				if v.funct6 = funct6_bclri and v.funct3 = funct3_bclr then
					v.bit_op.bit_zbs.bit_bclr := '1';
					v.bit_op.bit_alu := '1';
				elsif v.funct6 = funct6_bexti and v.funct3 = funct3_bext then
					v.bit_op.bit_zbs.bit_bext := '1';
					v.bit_op.bit_alu := '1';
				elsif v.funct6 = funct6_bseti and v.funct3 = funct3_bset then
					v.bit_op.bit_zbs.bit_bset := '1';
					v.bit_op.bit_alu := '1';
				elsif v.funct6 = funct6_binvi and v.funct3 = funct3_binv then
					v.bit_op.bit_zbs.bit_binv := '1';
					v.bit_op.bit_alu := '1';
				elsif v.funct6 = funct6_rori and v.funct3 = funct3_ror then
					v.bit_op.bit_zbb.bit_ror := '1';
					v.bit_op.bit_alu := '1';
				else
					if v.funct7 = funct7_clz then
						if v.funct5 = funct5_clz and v.funct3 = funct3_clz then
							v.bit_op.bit_zbb.bit_clz := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct5 = funct5_cpop and v.funct3 = funct3_cpop then
							v.bit_op.bit_zbb.bit_cpop := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct5 = funct5_ctz and v.funct3 = funct3_ctz then
							v.bit_op.bit_zbb.bit_ctz := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct5 = funct5_sextb and v.funct3 = funct3_sextb then
							v.bit_op.bit_zbb.bit_sextb := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct5 = funct5_sexth and v.funct3 = funct3_sexth then
							v.bit_op.bit_zbb.bit_sexth := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					else
						if v.funct12 = funct12_orcb and v.funct3 = funct3_orcb then
							v.bit_op.bit_zbb.bit_orcb := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct12 = funct12_rev8 and v.funct3 = funct3_rev8 then
							v.bit_op.bit_zbb.bit_rev8 := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					end if;
				end if;

				v.bitm := '1';

			when opcode_reg =>

				v.int_rden1 := '1';
				v.int_rden2 := '1';
				v.int_wren := '1';

				case v.funct7 is
					when funct7_andn =>
						if v.funct3 = funct3_andn then
							v.bit_op.bit_zbb.bit_andn := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_orn then
							v.bit_op.bit_zbb.bit_orn := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_xnor then
							v.bit_op.bit_zbb.bit_andn := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_bclr =>
						if v.funct3 = funct3_bclr then
							v.bit_op.bit_zbs.bit_bclr := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_bext then
							v.bit_op.bit_zbs.bit_bext := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_binv =>
						if v.funct3 = funct3_binv then
							v.bit_op.bit_zbs.bit_binv := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_bset =>
						if v.funct3 = funct3_bset then
							v.bit_op.bit_zbs.bit_bset := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_cmul =>
						if v.funct3 = funct3_cmul then
							v.bit_op.bit_zbc.bit_clmul := '1';
							v.bit_op.bit_clmul := '1';
							v.bit_op.bmcycle := '1';
						elsif v.funct3 = funct3_cmulh then
							v.bit_op.bit_zbc.bit_clmulh := '1';
							v.bit_op.bit_clmul := '1';
							v.bit_op.bmcycle := '1';
						elsif v.funct3 = funct3_cmulr then
							v.bit_op.bit_zbc.bit_clmulr := '1';
							v.bit_op.bit_clmul := '1';
							v.bit_op.bmcycle := '1';
						elsif v.funct3 = funct3_max then
							v.bit_op.bit_zbb.bit_max := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_maxu then
							v.bit_op.bit_zbb.bit_maxu := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_min then
							v.bit_op.bit_zbb.bit_min := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_minu then
							v.bit_op.bit_zbb.bit_minu := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_clz =>
						if v.funct3 = funct3_rol then
							v.bit_op.bit_zbb.bit_rol := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_ror then
							v.bit_op.bit_zbb.bit_ror := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_sh1add =>
						if v.funct3 = funct3_sh1add then
							v.bit_op.bit_zba.bit_sh1add := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_sh2add then
							v.bit_op.bit_zba.bit_sh2add := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_sh3add then
							v.bit_op.bit_zba.bit_sh3add := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when others =>
						v.valid := '0';
				end case;

				v.bitm := '1';

			when opcode_imm_32 =>

				v.int_rden1 := '1';
				v.int_wren := '1';

				v.bit_op.bit_word := '1';
				v.bit_op.bit_imm := '1';

				v.imm := v.imm6;
				if v.funct6 = funct6_slli and v.funct3 = funct3_slli then
					v.bit_op.bit_zba.bit_slli := '1';
					v.bit_op.bit_alu := '1';
				else
					if v.funct7 = funct7_clz then
						v.imm := v.imm5;
						if v.funct5 = funct5_clz and v.funct3 = funct3_clz then
							v.bit_op.bit_zbb.bit_clz := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct5 = funct5_cpop and v.funct3 = funct3_cpop then
							v.bit_op.bit_zbb.bit_cpop := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct5 = funct5_ctz and v.funct3 = funct3_ctz then
							v.bit_op.bit_zbb.bit_ctz := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_ror then
							v.bit_op.bit_zbb.bit_ror := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					else
						v.valid := '0';
					end if;
				end if;

				v.bitm := '1';

			when opcode_reg_32 =>

				v.int_rden1 := '1';
				v.int_rden2 := '1';
				v.int_wren := '1';

				v.bit_op.bit_word := '1';

				case v.funct7 is
					when funct7_add =>
						if v.funct3 = funct3_add then
							v.bit_op.bit_zba.bit_add := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_zexth and v.funct5 = funct5_zexth then
							v.bit_op.bit_zbb.bit_zexth := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_clz =>
						if v.funct3 = funct3_rol then
							v.bit_op.bit_zbb.bit_rol := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_ror then
							v.bit_op.bit_zbb.bit_ror := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when funct7_sh1add =>
						if v.funct3 = funct3_sh1add then
							v.bit_op.bit_zba.bit_sh1add := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_sh2add then
							v.bit_op.bit_zba.bit_sh2add := '1';
							v.bit_op.bit_alu := '1';
						elsif v.funct3 = funct3_sh3add then
							v.bit_op.bit_zba.bit_sh3add := '1';
							v.bit_op.bit_alu := '1';
						else
							v.valid := '0';
						end if;
					when others =>
						v.valid := '0';
				end case;

				v.bitm := '1';

			when others =>

				v.valid := '0';

		end case;

		bit_decode_o.imm <= v.imm;
		bit_decode_o.int_rden1 <= v.int_rden1;
		bit_decode_o.int_rden2 <= v.int_rden2;
		bit_decode_o.int_wren <= v.int_wren;
		bit_decode_o.bitm <= v.bitm;
		bit_decode_o.bit_op <= v.bit_op;
		bit_decode_o.valid <= v.valid;

	end process;

end architecture;
