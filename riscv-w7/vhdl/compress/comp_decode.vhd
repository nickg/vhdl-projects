-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;
use work.comp_constants.all;
use work.comp_wire.all;
use work.int_wire.all;

entity comp_decode is
	port(
		comp_decode_i : in  comp_decode_in_type;
		comp_decode_o : out comp_decode_out_type
	);
end comp_decode;

architecture behavior of comp_decode is

begin

	process(comp_decode_i)

		variable v : comp_decode_reg_type;

	begin
		v.instr := comp_decode_i.instr;

		v.imm_lwsp := std_logic_vector(resize(unsigned(v.instr(3 downto 2) & v.instr(12) & v.instr(6 downto 4) & "00"),64));
		v.imm_ldsp := std_logic_vector(resize(unsigned(v.instr(4 downto 2) & v.instr(12) & v.instr(6 downto 5) & "000"),64));
		v.imm_swsp := std_logic_vector(resize(unsigned(v.instr(8 downto 7) & v.instr(12 downto 9) & "00"),64));
		v.imm_sdsp := std_logic_vector(resize(unsigned(v.instr(9 downto 7) & v.instr(12 downto 10) & "000"),64));
		v.imm_lswr := std_logic_vector(resize(unsigned(v.instr(5) & v.instr(12 downto 10) & v.instr(6) & "00"),64));
		v.imm_lsdr := std_logic_vector(resize(unsigned(v.instr(6 downto 5) & v.instr(12 downto 10) & "000"),64));

		v.imm_j := std_logic_vector(resize(signed(v.instr(12) & v.instr(8) & v.instr(10 downto 9) & v.instr(6) & v.instr(7) & v.instr(2) & v.instr(11) & v.instr(5 downto 3) & "0"),64));
		v.imm_b := std_logic_vector(resize(signed(v.instr(12) & v.instr(6 downto 5) & v.instr(2) & v.instr(11 downto 10) & v.instr(4 downto 3) & "0"),64));
		v.imm_w := std_logic_vector(resize(unsigned(v.instr(10 downto 7) & v.instr(12 downto 11) & v.instr(5) & v.instr(6) & "00"),64));
		v.imm_i := std_logic_vector(resize(signed(v.instr(12) & v.instr(6 downto 2)),64));
		v.imm_u := std_logic_vector(resize(signed(v.instr(12) & v.instr(6 downto 2) & "000000000000"),64));
		v.imm_p := std_logic_vector(resize(signed(v.instr(12) & v.instr(4 downto 3) & v.instr(5) & v.instr(2) & v.instr(6) & "0000"),64));

		v.shamt := or_reduce(v.instr(12) & v.instr(6 downto 2));

		v.opcode := v.instr(1 downto 0);
		v.funct3 := v.instr(15 downto 13);
		v.funct4 := v.instr(12);
		v.funct6 := v.instr(11 downto 10);
		v.funct8 := v.instr(6 downto 5);
		v.funct9 := v.instr(12) & v.instr(6 downto 5);

		v.raddr1 := v.instr(11 downto 7);
		v.raddr2 := v.instr(6 downto 2);
		v.waddr := v.instr(11 downto 7);

		v.imm := (others => '0');

		v.int_rden1 := '0';
		v.int_rden2 := '0';
		v.int_wren := '0';
		v.fpu_rden2 := '0';
		v.fpu_wren := '0';
		v.load := '0';
		v.store := '0';
		v.int := '0';
		v.fpu := '0';
		v.csr := '0';
		v.ebreak := '0';
		v.int_op := init_int_operation;
		v.load_op := init_load_operation;
		v.store_op := init_store_operation;

		v.valid := '0';

		case v.opcode is
			when opcode_c0 =>
				case v.funct3 is
					when c0_addispn =>
						v.imm := v.imm_w;
						v.raddr1 := "00010";
						v.waddr := "01" & v.instr(4 downto 2);
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.int := '1';
						v.int_op.alu := '1';
						v.int_op.alu_imm := '1';
						v.int_op.alu_op.alu_add := '1';
						v.valid := or_reduce(v.instr(15 downto 0));
					when c0_fld =>
						v.imm := v.imm_lsdr;
						v.raddr1(4 downto 3) := "01";
						v.waddr := "01" & v.instr(4 downto 2);
						v.load_op.mem_ld := '1';
						v.int_rden1 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.load := '1';
						v.valid := '1';
					when c0_lw =>
						v.imm := v.imm_lswr;
						v.raddr1(4 downto 3) := "01";
						v.waddr := "01" & v.instr(4 downto 2);
						v.load_op.mem_lw := '1';
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.int := '1';
						v.load := '1';
						v.valid := '1';
					when c0_ld =>
						v.imm := v.imm_lsdr;
						v.raddr1(4 downto 3) := "01";
						v.waddr := "01" & v.instr(4 downto 2);
						v.load_op.mem_ld := '1';
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.int := '1';
						v.load := '1';
						v.valid := '1';
					when c0_fsd =>
						v.imm := v.imm_lsdr;
						v.raddr1(4 downto 3) := "01";
						v.raddr2(4 downto 3) := "01";
						v.store_op.mem_sd := '1';
						v.int_rden1 := '1';
						v.fpu_rden2 := '1';
						v.fpu := '1';
						v.store := '1';
						v.valid := '1';
					when c0_sw =>
						v.imm := v.imm_lswr;
						v.raddr1(4 downto 3) := "01";
						v.raddr2(4 downto 3) := "01";
						v.store_op.mem_sw := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.int := '1';
						v.store := '1';
						v.valid := '1';
					when c0_sd =>
						v.imm := v.imm_lsdr;
						v.raddr1(4 downto 3) := "01";
						v.raddr2(4 downto 3) := "01";
						v.store_op.mem_sd := '1';
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.int := '1';
						v.store := '1';
						v.valid := '1';
					when others =>
						null;
				end case;
			when opcode_c1 =>
				case v.funct3 is
					when c1_addi =>
						v.imm := v.imm_i;
						v.int_rden1 := '1';
						v.int_wren := v.shamt;
						v.int_op.alu := v.shamt;
						v.int_op.alu_imm := v.shamt;
						v.int_op.alu_op.alu_add := v.shamt;
						v.int := v.shamt;
						v.valid := '1';
					when c1_addiw =>
						v.imm := v.imm_i;
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.int_op.alu := '1';
						v.int_op.alu_imm := '1';
						v.int_op.alu_op.alu_add := '1';
						v.int_op.word := '1';
						v.int := '1';
						v.valid := '1';
					when c1_li =>
						v.imm := v.imm_i;
						v.int_wren := '1';
						v.int := '1';
						v.int_op.alu := '1';
						v.int_op.alu_imm := '1';
						v.int_op.alu_op.alu_add := '1';
						v.valid := '1';
					when c1_lui =>
						v.int_wren := v.shamt;
						v.int := v.shamt;
						if v.raddr1 = "00010" then
							v.imm := v.imm_p;
							v.int_rden1 := '1';
							v.int_op.alu := v.shamt;
							v.int_op.alu_imm := v.shamt;
							v.int_op.alu_op.alu_add := v.shamt;
						else
							v.imm := v.imm_u;
							v.int_op.lui := v.shamt;
						end if;
						v.valid := '1';
					when c1_alu =>
						v.imm := v.imm_i;
						v.raddr1(4 downto 3) := "01";
						v.raddr2(4 downto 3) := "01";
						v.waddr(4 downto 3) := "01";
						case v.funct6 is
							when "00" =>
								v.int_rden1 := '1';
								v.int_wren := v.shamt;
								v.int_op.alu := v.shamt;
								v.int_op.alu_imm := v.shamt;
								v.int_op.alu_op.alu_srl := v.shamt;
								v.int := v.shamt;
								v.valid := '1';
							when "01" =>
								v.int_rden1 := '1';
								v.int_wren := v.shamt;
								v.int_op.alu := v.shamt;
								v.int_op.alu_imm := v.shamt;
								v.int_op.alu_op.alu_sra := v.shamt;
								v.int := v.shamt;
								v.valid := '1';
							when "10" =>
								v.int_rden1 := '1';
								v.int_wren := '1';
								v.int_op.alu := '1';
								v.int_op.alu_imm := '1';
								v.int_op.alu_op.alu_and := '1';
								v.int := '1';
								v.valid := '1';
							when "11" =>
								case v.funct9 is
									when "000" =>
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_sub := '1';
										v.int := '1';
										v.valid := '1';
									when "001" =>
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_xor := '1';
										v.int := '1';
										v.valid := '1';
									when "010" =>
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_or := '1';
										v.int := '1';
										v.valid := '1';
									when "011" =>
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_and := '1';
										v.int := '1';
										v.valid := '1';
									when "100" =>
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_sub := '1';
										v.int_op.word := '1';
										v.int := '1';
										v.valid := '1';
									when "101" =>
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_add := '1';
										v.int_op.word := '1';
										v.int := '1';
										v.valid := '1';
									when others =>
										null;
								end case;
							when others =>
								null;
						end case;
					when c1_jal =>
						v.imm := v.imm_j;
						v.waddr := "00000";
						v.int_op.jal := '1';
						v.int := '1';
						v.valid := '1';
					when c1_beqz =>
						v.imm := v.imm_b;
						v.raddr1(4 downto 3) := "01";
						v.raddr2 := "00000";
						v.int_rden1 := '1';
						v.int_op.branch := '1';
						v.int_op.branch_op.beq := '1';
						v.int := '1';
						v.valid := '1';
					when c1_bnez =>
						v.imm := v.imm_b;
						v.raddr1(4 downto 3) := "01";
						v.raddr2 := "00000";
						v.int_rden1 := '1';
						v.int_op.branch := '1';
						v.int_op.branch_op.bne := '1';
						v.int := '1';
						v.valid := '1';
					when others =>
						null;
				end case;
			when opcode_c2 =>
				case v.funct3 is
					when c2_slli =>
						v.imm := v.imm_i;
						v.int_rden1 := '1';
						v.int_wren := v.shamt;
						v.int_op.alu := v.shamt;
						v.int_op.alu_imm := v.shamt;
						v.int_op.alu_op.alu_sll := v.shamt;
						v.int := v.shamt;
						v.valid := '1';
					when c2_fldsp =>
						v.imm := v.imm_ldsp;
						v.load_op.mem_ld := '1';
						v.raddr1 := "00010";
						v.int_rden1 := '1';
						v.fpu_wren := '1';
						v.fpu := '1';
						v.load := '1';
						v.valid := '1';
					when c2_lwsp =>
						v.imm := v.imm_lwsp;
						v.load_op.mem_lw := '1';
						v.raddr1 := "00010";
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.int := '1';
						v.load := '1';
						v.valid := '1';
					when c2_ldsp =>
						v.imm := v.imm_ldsp;
						v.load_op.mem_ld := '1';
						v.raddr1 := "00010";
						v.int_rden1 := '1';
						v.int_wren := '1';
						v.int := '1';
						v.load := '1';
						v.valid := '1';
					when c2_alu =>
						case v.funct4 is
							when '0' =>
								if or_reduce(v.raddr1) = '1' then
									if or_reduce(v.raddr2) = '0' then
										v.waddr := "00000";
										v.int_rden1 := '1';
										v.int_op.jalr := '1';
										v.int := '1';
									elsif or_reduce(v.raddr2) = '1' then
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_add := '1';
										v.int := '1';
									end if;
								end if;
								v.valid := '1';
							when '1' =>
								if or_reduce(v.raddr1) = '0' then
									if or_reduce(v.raddr2) = '0' then
										v.ebreak := '1';
										v.csr := '1';
									end if;
								elsif or_reduce(v.raddr1) = '1' then
									if or_reduce(v.raddr2) = '0' then
										v.waddr := "00001";
										v.int_rden1 := '1';
										v.int_wren := '1';
										v.int_op.jalr := '1';
										v.int := '1';
									elsif or_reduce(v.raddr2) = '1' then
										v.int_rden1 := '1';
										v.int_rden2 := '1';
										v.int_wren := '1';
										v.int_op.alu := '1';
										v.int_op.alu_op.alu_add := '1';
										v.int := '1';
									end if;
								end if;
								v.valid := '1';
							when others =>
								null;
						end case;
					when c2_fsdsp =>
						v.imm := v.imm_sdsp;
						v.store_op.mem_sd := '1';
						v.raddr1 := "00010";
						v.int_rden1 := '1';
						v.fpu_rden2 := '1';
						v.fpu := '1';
						v.store := '1';
						v.valid := '1';
					when c2_swsp =>
						v.imm := v.imm_swsp;
						v.store_op.mem_sw := '1';
						v.raddr1 := "00010";
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.int := '1';
						v.store := '1';
						v.valid := '1';
					when c2_sdsp =>
						v.imm := v.imm_sdsp;
						v.store_op.mem_sd := '1';
						v.raddr1 := "00010";
						v.int_rden1 := '1';
						v.int_rden2 := '1';
						v.int := '1';
						v.store := '1';
						v.valid := '1';
					when others =>
						null;
				end case;
			when others =>
				null;
		end case;

		comp_decode_o.imm <= v.imm;
		comp_decode_o.raddr1 <= v.raddr1;
		comp_decode_o.raddr2 <= v.raddr2;
		comp_decode_o.waddr <= v.waddr;
		comp_decode_o.int_rden1 <= v.int_rden1;
		comp_decode_o.int_rden2 <= v.int_rden2;
		comp_decode_o.int_wren <= v.int_wren;
		comp_decode_o.fpu_rden2 <= v.fpu_rden2;
		comp_decode_o.fpu_wren <= v.fpu_wren;
		comp_decode_o.load <= v.load;
		comp_decode_o.store <= v.store;
		comp_decode_o.int <= v.int;
		comp_decode_o.fpu <= v.fpu;
		comp_decode_o.csr <= v.csr;
		comp_decode_o.ebreak <= v.ebreak;
		comp_decode_o.int_op <= v.int_op;
		comp_decode_o.load_op <= v.load_op;
		comp_decode_o.store_op <= v.store_op;
		comp_decode_o.valid <= v.valid;

	end process;

end architecture;
