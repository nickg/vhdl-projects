-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.functions.all;
use work.int_constants.all;
use work.int_wire.all;
use work.csr_constants.all;

entity int_decode is
	generic(
		mul_performance : boolean := mul_performance
	);
	port(
		int_decode_i : in  int_decode_in_type;
		int_decode_o : out int_decode_out_type
	);
end int_decode;

architecture behavior of int_decode is

begin

	process(int_decode_i)

		variable v : int_decode_reg_type;

	begin
		v.instr := int_decode_i.instr;

		v.imm_csr := std_logic_vector(resize(unsigned(v.instr(19 downto 15)), 64));

		v.imm_c := std_logic_vector(resize(signed(v.instr(19 downto 15)), 64));
		v.imm_i := std_logic_vector(resize(signed(v.instr(31 downto 20)), 64));
		v.imm_s := std_logic_vector(resize(signed(v.instr(31 downto 25) & v.instr(11 downto 7)), 64));
		v.imm_b := std_logic_vector(resize(signed(v.instr(31) & v.instr(7) & v.instr(30 downto 25) & v.instr(11 downto 8) & '0'), 64));
		v.imm_u := std_logic_vector(resize(signed(v.instr(31 downto 12) & x"000"), 64));
		v.imm_j := std_logic_vector(resize(signed(v.instr(31) & v.instr(19 downto 12) & v.instr(20) & v.instr(30 downto 25) & v.instr(24 downto 21) & '0'), 64));

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct7 := v.instr(31 downto 25);
		v.rm := v.instr(14 downto 12);

		v.csr_addr := v.instr(31 downto 20);

		v.imm := (others => '0');

		v.int_rden1 := '0';
		v.int_rden2 := '0';
		v.int_wren := '0';
		v.csr_rden := '0';
		v.csr_wren := '0';

		v.load := '0';
		v.store := '0';
		v.int := '0';
		v.int_op := init_int_operation;
		v.load_op := init_load_operation;
		v.store_op := init_store_operation;

		v.csr := '0';
		v.ecall := '0';
		v.ebreak := '0';
		v.mret := '0';
		v.wfi := '0';

		v.fence := '0';
		v.valid := '1';

		case v.opcode is

			when opcode_lui | opcode_auipc =>

				v.imm := v.imm_u;
				v.int_wren := '1';
				v.int := '1';
				v.int_op.lui := v.opcode(5);
				v.int_op.auipc := not v.opcode(5);

			when opcode_jal | opcode_jalr =>

				v.int_wren := '1';
				if v.opcode(3) = '1' then
					v.imm := v.imm_j;
					v.int_op.jal := '1';
				elsif v.opcode(3) = '0' then
					v.imm := v.imm_i;
					v.int_rden1 := '1';
					v.int_op.jalr := '1';
				end if;
				v.int_op.word := '1';
				v.int := '1';

			when opcode_branch =>

				v.imm := v.imm_b;
				v.int_rden1 := '1';
				v.int_rden2 := '1';
				v.int := '1';
				v.int_op.branch := '1';
				case v.funct3 is
					when funct_beq  => v.int_op.branch_op.beq := '1';
					when funct_bne  => v.int_op.branch_op.bne := '1';
					when funct_blt  => v.int_op.branch_op.blt := '1';
					when funct_bge  => v.int_op.branch_op.bge := '1';
					when funct_bltu => v.int_op.branch_op.bltu := '1';
					when funct_bgeu => v.int_op.branch_op.bgeu := '1';
					when others     => v.valid := '0';
				end case;

			when opcode_load | opcode_store =>

				v.int_rden1 := '1';
				if v.opcode(5) = '0' then
					v.imm := v.imm_i;
					v.int_wren := '1';
					v.int := '1';
					v.load := '1';
					case v.funct3 is
						when funct_lb  => v.load_op.mem_lb := '1';
						when funct_lh  => v.load_op.mem_lh := '1';
						when funct_lw  => v.load_op.mem_lw := '1';
						when funct_ld  => v.load_op.mem_ld := '1';
						when funct_lbu => v.load_op.mem_lbu := '1';
						when funct_lhu => v.load_op.mem_lhu := '1';
						when funct_lwu => v.load_op.mem_lwu := '1';
						when others    => v.valid := '0';
					end case;
				elsif v.opcode(5) = '1' then
					v.imm := v.imm_s;
					v.int_rden2 := '1';
					v.int := '1';
					v.store := '1';
					case v.funct3 is
						when funct_sb  => v.store_op.mem_sb := '1';
						when funct_sh  => v.store_op.mem_sh := '1';
						when funct_sw  => v.store_op.mem_sw := '1';
						when funct_sd  => v.store_op.mem_sd := '1';
						when others    => v.valid := '0';
					end case;
				end if;

			when opcode_imm | opcode_reg | opcode_imm_32 | opcode_reg_32 =>

				v.int_rden1 := '1';
				v.int_wren := '1';
				if v.opcode(5) = '0' then
					v.imm := v.imm_i;
					v.int_op.alu := '1';
					v.int_op.alu_imm := '1';
					case v.funct3 is
						when funct_add =>
							v.int_op.alu_op.alu_add := '1';
						when funct_sll =>
						 	if v.opcode(3) = '1' and v.funct7 = "0000000" then
								v.int_op.alu_op.alu_sll := '1';
						 	elsif v.opcode(3) = '0' and v.funct7(6 downto 1) = "000000" then
								v.int_op.alu_op.alu_sll := '1';
							else
								v.valid := '0';
							end if;
						when funct_slt =>
							v.int_op.alu_op.alu_slt := '1';
						when funct_sltu =>
							v.int_op.alu_op.alu_sltu := '1';
						when funct_xor =>
							v.int_op.alu_op.alu_xor := '1';
						when funct_srl =>
						 	if v.opcode(3) = '1' and v.funct7 = "0000000" then
								v.int_op.alu_op.alu_srl := '1';
						 	elsif v.opcode(3) = '0' and v.funct7(6 downto 1) = "000000" then
								v.int_op.alu_op.alu_srl := '1';
						 	elsif v.opcode(3) = '1' and v.funct7 = "0100000" then
								v.int_op.alu_op.alu_sra := '1';
						 	elsif v.opcode(3) = '0' and v.funct7(6 downto 1) = "010000" then
								v.int_op.alu_op.alu_sra := '1';
							else
								v.valid := '0';
							end if;
						when funct_or =>
							v.int_op.alu_op.alu_or := '1';
						when funct_and =>
							v.int_op.alu_op.alu_and := '1';
						when others =>
							v.valid := '0';
					end case;
				elsif v.opcode(5) = '1' then
					v.int_rden2 := '1';
					if v.funct7 = "0000000" then
						v.int_op.alu := '1';
						case v.funct3 is
							when funct_add  => v.int_op.alu_op.alu_add := '1';
							when funct_sll  => v.int_op.alu_op.alu_sll := '1';
							when funct_slt  => v.int_op.alu_op.alu_slt := '1';
							when funct_sltu => v.int_op.alu_op.alu_sltu := '1';
							when funct_xor  => v.int_op.alu_op.alu_xor := '1';
							when funct_srl  => v.int_op.alu_op.alu_srl := '1';
							when funct_or   => v.int_op.alu_op.alu_or := '1';
							when funct_and  => v.int_op.alu_op.alu_and := '1';
							when others     => v.valid := '0';
						end case;
					elsif v.funct7 = "0100000" then
						v.int_op.alu := '1';
						case v.funct3 is
							when funct_add  => v.int_op.alu_op.alu_sub := '1';
							when funct_srl  => v.int_op.alu_op.alu_sra := '1';
							when others     => v.valid := '0';
						end case;
					elsif v.funct7 = "0000001" then
						v.int_op.div := v.funct3(2);
						v.int_op.mul := not v.funct3(2);
						case v.funct3 is
							when funct_mul    => v.int_op.mul_op.alu_mul := '1';
							when funct_mulh   => v.int_op.mul_op.alu_mulh := '1';
							when funct_mulhsu => v.int_op.mul_op.alu_mulhsu := '1';
							when funct_mulhu  => v.int_op.mul_op.alu_mulhu := '1';
							when funct_div    => v.int_op.div_op.alu_div := '1';
							when funct_divu   => v.int_op.div_op.alu_divu := '1';
							when funct_rem    => v.int_op.div_op.alu_rem := '1';
							when funct_remu   => v.int_op.div_op.alu_remu := '1';
							when others       => v.valid := '0';
						end case;
						if v.int_op.mul = '1' then
							if mul_performance then
								v.int_op.mcycle := '0';
							else
								v.int_op.mcycle := '1';
							end if;
						else
							v.int_op.mcycle := '1';
						end if;
					end if;
				end if;
				v.int := '1';
				v.int_op.word := v.opcode(3);

			when opcode_fence =>

				v.int := '1';
				if v.funct3 = "001" then
					v.fence := '1';
				end if;

			when opcode_system =>

				v.imm := v.imm_csr;
				case v.funct3 is
					when "000" =>
						case v.csr_addr is
							when csr_ecall =>
								v.csr := '1';
								v.ecall := '1';
							when csr_ebreak =>
								v.csr := '1';
								v.ebreak := '1';
							when csr_mret =>
								v.csr_rden := '1';
								v.csr := '1';
								v.mret := '1';
							when csr_wfi =>
								v.csr := '1';
								v.wfi := '1';
							when others =>
								v.valid := '0';
						end case;
					when others =>
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.csr_rden := '1';
						v.csr_wren := '1';
						v.csr := '1';
				end case;

			when others =>

				v.valid := '0';

		end case;

		if nor_reduce(v.instr xor nop) = '1' then
			v.int := '0';
		end if;

		int_decode_o.imm <= v.imm;
		int_decode_o.int_rden1 <= v.int_rden1;
		int_decode_o.int_rden2 <= v.int_rden2;
		int_decode_o.csr_rden <= v.csr_rden;
		int_decode_o.csr_wren <= v.csr_wren;
		int_decode_o.int_wren <= v.int_wren;
		int_decode_o.load <= v.load;
		int_decode_o.store <= v.store;
		int_decode_o.int <= v.int;
		int_decode_o.int_op <= v.int_op;
		int_decode_o.load_op <= v.load_op;
		int_decode_o.store_op <= v.store_op;
		int_decode_o.csr <= v.csr;
		int_decode_o.ecall <= v.ecall;
		int_decode_o.ebreak <= v.ebreak;
		int_decode_o.mret <= v.mret;
		int_decode_o.wfi <= v.wfi;
		int_decode_o.fence <= v.fence;
		int_decode_o.valid <= v.valid;

	end process;

end architecture;
