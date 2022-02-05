-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.comp_wire.all;
use work.atom_wire.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.bit_wire.all;
use work.fp_wire.all;

entity decode_stage is
	port(
		reset         : in  std_logic;
		clock         : in  std_logic;
		int_decode_i  : out int_decode_in_type;
		int_decode_o  : in  int_decode_out_type;
		bit_decode_i  : out bit_decode_in_type;
		bit_decode_o  : in  bit_decode_out_type;
		comp_decode_i : out comp_decode_in_type;
		comp_decode_o : in  comp_decode_out_type;
		atom_decode_i : out atom_decode_in_type;
		atom_decode_o : in  atom_decode_out_type;
		fp_dec_i      : out fp_dec_in_type;
		fp_dec_o      : in  fp_dec_out_type;
		csr_eo        : in  csr_exception_out_type;
		a             : in  decode_in_type;
		d             : in  decode_in_type;
		y             : out decode_out_type;
		q             : out decode_out_type
	);
end decode_stage;

architecture behavior of decode_stage is

	signal r   : decode_reg_type := init_decode_reg;
	signal rin : decode_reg_type := init_decode_reg;

begin

	combinational : process(a, d, r, int_decode_o, bit_decode_o, comp_decode_o, atom_decode_o, fp_dec_o, csr_eo)

		variable v : decode_reg_type;

	begin

		v := r;

		v.fpu := '0';
		v.fpu_op := init_fp_operation;

		v.pc := d.f.pc;
		v.instr := a.f.instr;
		v.taken := d.f.taken;
		v.exc := d.f.exc;
		v.etval := d.f.etval;
		v.ecause := d.f.ecause;

		-- if (d.d.stall or d.e.stall or d.m.stall or d.w.stall) = '1' then
		-- 	v := r;
		-- end if;

		if d.f.exc = '1' then
			v.instr := nop;
		end if;

		v.inc := "100";
		if and_reduce(v.instr(1 downto 0)) = '0' then
			v.inc := "010";
		end if;

		v.npc := std_logic_vector(unsigned(v.pc) + v.inc);

		v.stall := '0';

		v.clear := csr_eo.exc or csr_eo.mret or d.w.clear;

		if d.e.jump = '1' and d.f.taken = '0' then
			v.clear := '1';
		elsif d.e.jump = '0' and d.f.taken = '1' then
			v.clear := '1';
		elsif d.e.jump = '1' and d.f.taken = '1' and or_reduce(d.e.address xor d.f.pc) = '1' then
			v.clear := '1';
		end if;

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct7 := v.instr(31 downto 25);
		v.fmt := v.instr(26 downto 25);
		v.rm := v.instr(14 downto 12);

		v.raddr1 := v.instr(19 downto 15);
		v.raddr2 := v.instr(24 downto 20);
		v.raddr3 := v.instr(31 downto 27);
		v.waddr := v.instr(11 downto 7);
		v.caddr := v.instr(31 downto 20);

		v.csr_mode := v.instr(29 downto 28);

		v.imm := (others => '0');
		v.int_rden1 := '0';
		v.int_rden2 := '0';
		v.int_wren := '0';
		v.csr_rden := '0';
		v.csr_wren := '0';
		v.load := '0';
		v.store := '0';
		v.ldst := '0';
		v.int := '0';
		v.int_op := init_int_operation;
		v.load_op := init_load_operation;
		v.store_op := init_store_operation;
		v.atom_op := init_atom_operation;
		v.csr := '0';
		v.ecall := '0';
		v.ebreak := '0';
		v.mret := '0';
		v.wfi := '0';
		v.fence := '0';
		v.valid := '0';

		int_decode_i.instr <= v.instr;

		if int_decode_o.valid = '1' then
			v.imm := int_decode_o.imm;
			v.int_rden1 := int_decode_o.int_rden1;
			v.int_rden2 := int_decode_o.int_rden2;
			v.int_wren := int_decode_o.int_wren;
			v.csr_rden := int_decode_o.csr_rden;
			v.csr_wren := int_decode_o.csr_wren;
			v.load := int_decode_o.load;
			v.store := int_decode_o.store;
			v.int := int_decode_o.int;
			v.int_op := int_decode_o.int_op;
			v.load_op := int_decode_o.load_op;
			v.store_op := int_decode_o.store_op;
			v.csr := int_decode_o.csr;
			v.ecall := int_decode_o.ecall;
			v.ebreak := int_decode_o.ebreak;
			v.mret := int_decode_o.mret;
			v.wfi := int_decode_o.wfi;
			v.fence := int_decode_o.fence;
			v.valid := int_decode_o.valid;
		end if;

		v.fpu_rden1 := '0';
		v.fpu_rden2 := '0';
		v.fpu_rden3 := '0';
		v.fpu_wren := '0';
		v.fpu_load := '0';
		v.fpu_store := '0';
		v.fpu := '0';
		v.fpu_op := init_fp_operation;

		v.bitm := '0';

		v.bit_op := init_bit_operation;

		bit_decode_i.instr <= v.instr;

		if bit_decode_o.valid = '1' then
			v.imm := bit_decode_o.imm;
			v.int_rden1 := bit_decode_o.int_rden1;
			v.int_rden2 := bit_decode_o.int_rden2;
			v.int_wren := bit_decode_o.int_wren;
			v.bitm := bit_decode_o.bitm;
			v.bit_op := bit_decode_o.bit_op;
			v.valid := bit_decode_o.valid;
		end if;

		comp_decode_i.instr <= v.instr;

		if comp_decode_o.valid = '1' then
			v.imm := comp_decode_o.imm;
			v.raddr1 := comp_decode_o.raddr1;
			v.raddr2 := comp_decode_o.raddr2;
			v.waddr := comp_decode_o.waddr;
			v.int_rden1 := comp_decode_o.int_rden1;
			v.int_rden2 := comp_decode_o.int_rden2;
			v.int_wren := comp_decode_o.int_wren;
			v.fpu_rden2 := comp_decode_o.fpu_rden2;
			v.fpu_wren := comp_decode_o.fpu_wren;
			v.load := comp_decode_o.load;
			v.store := comp_decode_o.store;
			v.int := comp_decode_o.int;
			v.fpu := comp_decode_o.fpu;
			v.csr := comp_decode_o.csr;
			v.ebreak := comp_decode_o.ebreak;
			v.int_op := comp_decode_o.int_op;
			v.load_op := comp_decode_o.load_op;
			v.store_op := comp_decode_o.store_op;
			v.valid := comp_decode_o.valid;
		end if;

		v.comp := comp_decode_o.valid;

		atom_decode_i.instr <= v.instr;

		if atom_decode_o.valid = '1' then
			v.int_rden1 := atom_decode_o.int_rden1;
			v.int_rden2 := atom_decode_o.int_rden2;
			v.int_wren := atom_decode_o.int_wren;
			v.load := atom_decode_o.load;
			v.store := atom_decode_o.store;
			v.ldst := atom_decode_o.ldst;
			v.atom_op := atom_decode_o.atom_op;
			v.load_op := atom_decode_o.load_op;
			v.store_op := atom_decode_o.store_op;
			v.valid := atom_decode_o.valid;
		end if;

		v.atom :=  atom_decode_o.valid;

		fp_dec_i.instr <= v.instr;

		if fp_dec_o.valid = '1' then
			v.imm := fp_dec_o.imm;
			v.int_rden1 := fp_dec_o.int_rden1;
			v.int_wren := fp_dec_o.int_wren;
			v.fpu_rden1 := fp_dec_o.fpu_rden1;
			v.fpu_rden2 := fp_dec_o.fpu_rden2;
			v.fpu_rden3 := fp_dec_o.fpu_rden3;
			v.fpu_wren := fp_dec_o.fpu_wren;
			v.fpu_load := fp_dec_o.fpu_load;
			v.fpu_store := fp_dec_o.fpu_store;
			v.fpu := fp_dec_o.fpu;
			v.fpu_op := fp_dec_o.fpu_op;
			v.load_op := fp_dec_o.load_op;
			v.store_op := fp_dec_o.store_op;
			v.valid := fp_dec_o.valid;
			if and_reduce(v.rm) = '1' then
				v.rm := csr_eo.frm;
			end if;
		end if;

		if csr_eo.fs = "00" then
			v.fpu_wren := '0';
			v.fpu_load := '0';
			v.fpu_store := '0';
		end if;

		v.link_waddr := (v.waddr = "00001") or (v.waddr = "00101");
		v.link_raddr1 := (v.raddr1 = "00001") or (v.raddr1 = "00101");
		v.raddr1_eq_waddr := v.raddr1 = v.waddr;
		v.zero_waddr := (v.waddr = "00000");

		if v.waddr = "00000" then
			v.int_wren := '0';
		end if;

		v.return_pop := '0';
		v.return_push := '0';
		v.jump_uncond := '0';
		v.jump_rest := '0';

		if v.int_op.jal ='1' then
			if v.link_waddr then
				v.return_push := '1';
			elsif v.zero_waddr then
				v.jump_uncond := '1';
			else
				v.jump_rest := '1';
			end if;
		end if;

		if v.int_op.jalr ='1' then
			if not(v.link_waddr) and v.link_raddr1 then
				v.return_pop := '1';
			elsif v.link_waddr and not(v.link_raddr1) then
				v.return_push := '1';
			elsif v.link_waddr and v.link_raddr1 then
				if v.raddr1_eq_waddr then
					v.return_push := '1';
				elsif not(v.raddr1_eq_waddr) then
					v.return_pop := '1';
					v.return_push := '1';
				end if;
			else
				v.jump_rest := '1';
			end if;
		end if;

		if v.int_op.jal = '1' then
		end if;

		if v.exc = '0' then
			if v.valid = '0' then
				v.exc := '1';
				v.etval := X"00000000" & v.instr;
				v.ecause := except_illegal_instruction;
			elsif v.ecall = '1' then
				v.exc := '1';
				if csr_eo.mode = u_mode then
					v.ecause := except_env_call_user;
				elsif csr_eo.mode = m_mode then
					v.ecause := except_env_call_mach;
				end if;
			elsif v.ebreak = '1' then
				v.exc := '1';
				v.ecause := except_breakpoint;
			elsif v.csr = '1' then
				if unsigned(v.csr_mode) > unsigned(csr_eo.mode) then
					v.exc := '1';
					v.etval := X"00000000" & v.instr;
					v.ecause := except_illegal_instruction;
				end if;
			end if;
		end if;

		case v.funct3 is
			when "001" | "101" =>
				v.csr_rden := v.csr_rden and (or_reduce(v.waddr));
			when "010" | "110" =>
				v.csr_wren := v.csr_wren and (or_reduce(v.raddr1));
			when "011" | "111" =>
				v.csr_wren := v.csr_wren and (or_reduce(v.raddr1));
			when others => null;
		end case;

		if (a.e.csr_wren_n or a.m.csr_wren_n) = '1' then
			v.stall := '1';
		elsif (a.e.atom_n or a.m.atom_n) = '1' then
			v.stall := '1';
		elsif (a.e.load_n) = '1' then
			if (nor_reduce(a.e.waddr xor v.raddr1) and v.int_rden1) = '1' then
				v.stall := '1';
			end if;
			if (nor_reduce(a.e.waddr xor v.raddr2) and v.int_rden2) = '1' then
				v.stall := '1';
			end if;
		elsif (a.e.fpu_load_n) = '1' then
			if (nor_reduce(a.e.waddr xor v.raddr1) and v.fpu_rden1) = '1' then
				v.stall := '1';
			end if;
			if (nor_reduce(a.e.waddr xor v.raddr2) and v.fpu_rden2) = '1' then
				v.stall := '1';
			end if;
			if (nor_reduce(a.e.waddr xor v.raddr3) and v.fpu_rden3) = '1' then
				v.stall := '1';
			end if;
		elsif (v.csr_rden) = '1' then
			if (nor_reduce(v.caddr xor csr_fflags) and (a.e.fpu_n or a.m.fpu_n)) = '1' then
				v.stall := '1';
			end if;
		elsif (a.e.int_op.mcycle) = '1' then
			v.stall := '1';
		elsif (a.e.bit_op.bmcycle) = '1' then
			v.stall := '1';
		elsif (a.e.fpu_op.fmcycle) = '1' then
			v.stall := '1';
		end if;

		v.int_wren_n := v.int_wren;
		v.fpu_wren_n := v.fpu_wren;
		v.csr_wren_n := v.csr_wren;
		v.int_n := v.int;
		v.bitm_n := v.bitm;
		v.fpu_n := v.fpu;
		v.csr_n := v.csr;
		v.comp_n := v.comp;
		v.atom_n := v.atom;
		v.load_n := v.load;
		v.store_n := v.store;
		v.ldst_n := v.ldst;
		v.fpu_load_n := v.fpu_load;
		v.fpu_store_n := v.fpu_store;
		v.return_pop_n := v.return_pop;
		v.return_push_n := v.return_push;
		v.jump_uncond_n := v.jump_uncond;
		v.jump_rest_n := v.jump_rest;
		v.taken_n := v.taken;
		v.exc_n := v.exc;
		v.ecall_n := v.ecall;
		v.ebreak_n := v.ebreak;
		v.mret_n := v.mret;
		v.wfi_n := v.wfi;
		v.fence_n := v.fence;
		v.valid_n := v.valid;

		if (v.stall or a.e.stall or a.m.stall or a.w.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.fpu_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.bitm := '0';
			v.fpu := '0';
			v.csr := '0';
			v.comp := '0';
			v.atom := '0';
			v.int_op := init_int_operation;
			v.bit_op := init_bit_operation;
			v.fpu_op := init_fp_operation;
			v.load := '0';
			v.store := '0';
			v.fpu_load := '0';
			v.fpu_store := '0';
			v.return_pop := '0';
			v.return_push := '0';
			v.jump_uncond := '0';
			v.jump_rest := '0';
			v.taken := '0';
			v.exc := '0';
			v.ecall := '0';
			v.ebreak := '0';
			v.mret := '0';
			v.wfi := '0';
			v.fence := '0';
			v.valid := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		rin <= v;

		y.pc <= v.pc;
		y.npc <= v.npc;
		y.funct3 <= v.funct3;
		y.funct7 <= v.funct7;
		y.fmt <= v.fmt;
		y.rm <= v.rm;
		y.imm <= v.imm;
		y.int_rden1 <= v.int_rden1;
		y.int_rden2 <= v.int_rden2;
		y.fpu_rden1 <= v.fpu_rden1;
		y.fpu_rden2 <= v.fpu_rden2;
		y.fpu_rden3 <= v.fpu_rden3;
		y.csr_rden <= v.csr_rden;
		y.int_wren <= v.int_wren;
		y.fpu_wren <= v.fpu_wren;
		y.csr_wren <= v.csr_wren;
		y.raddr1 <= v.raddr1;
		y.raddr2 <= v.raddr2;
		y.raddr3 <= v.raddr3;
		y.waddr <= v.waddr;
		y.caddr <= v.caddr;
		y.load <= v.load;
		y.store <= v.store;
		y.ldst <= v.ldst;
		y.fpu_load <= v.fpu_load;
		y.fpu_store <= v.fpu_store;
		y.int <= v.int;
		y.bitm <= v.bitm;
		y.fpu <= v.fpu;
		y.csr <= v.csr;
		y.comp <= v.comp;
		y.atom <= v.atom;
		y.load_op <= v.load_op;
		y.store_op <= v.store_op;
		y.int_op <= v.int_op;
		y.bit_op <= v.bit_op;
		y.fpu_op <= v.fpu_op;
		y.atom_op <= v.atom_op;
		y.return_pop <= v.return_pop;
		y.return_push <= v.return_push;
		y.jump_uncond <= v.jump_uncond;
		y.jump_rest <= v.jump_rest;
		y.taken <= v.taken;
		y.etval <= v.etval;
		y.ecause <= v.ecause;
		y.exc <= v.exc;
		y.ecall <= v.ecall;
		y.ebreak <= v.ebreak;
		y.mret <= v.mret;
		y.wfi <= v.wfi;
		y.fence <= v.fence;
		y.valid <= v.valid;
		y.stall <= v.stall;
		y.clear <= v.clear;

		y.int_wren_n <= v.int_wren_n;
		y.fpu_wren_n <= v.fpu_wren_n;
		y.csr_wren_n <= v.csr_wren_n;
		y.int_n <= v.int_n;
		y.bitm_n <= v.bitm_n;
		y.fpu_n <= v.fpu_n;
		y.csr_n <= v.csr_n;
		y.comp_n <= v.comp_n;
		y.atom_n <= v.atom_n;
		y.load_n <= v.load_n;
		y.store_n <= v.store_n;
		y.ldst_n <= v.ldst_n;
		y.fpu_load_n <= v.fpu_load_n;
		y.fpu_store_n <= v.fpu_store_n;
		y.return_pop_n <= v.return_pop_n;
		y.return_push_n <= v.return_push_n;
		y.jump_uncond_n <= v.jump_uncond_n;
		y.jump_rest_n <= v.jump_rest_n;
		y.taken_n <= v.taken_n;
		y.exc_n <= v.exc_n;
		y.ecall_n <= v.ecall_n;
		y.ebreak_n <= v.ebreak_n;
		y.mret_n <= v.mret_n;
		y.wfi_n <= v.wfi_n;
		y.fence_n <= v.fence_n;
		y.valid_n <= v.valid_n;

		q.pc <= r.pc;
		q.npc <= r.npc;
		q.funct3 <= r.funct3;
		q.funct7 <= r.funct7;
		q.fmt <= r.fmt;
		q.rm <= r.rm;
		q.imm <= r.imm;
		q.int_rden1 <= r.int_rden1;
		q.int_rden2 <= r.int_rden2;
		q.fpu_rden1 <= r.fpu_rden1;
		q.fpu_rden2 <= r.fpu_rden2;
		q.fpu_rden3 <= r.fpu_rden3;
		q.csr_rden <= r.csr_rden;
		q.int_wren <= r.int_wren;
		q.fpu_wren <= r.fpu_wren;
		q.csr_wren <= r.csr_wren;
		q.raddr1 <= r.raddr1;
		q.raddr2 <= r.raddr2;
		q.raddr3 <= r.raddr3;
		q.waddr <= r.waddr;
		q.caddr <= r.caddr;
		q.load <= r.load;
		q.store <= r.store;
		q.ldst <= r.ldst;
		q.fpu_load <= r.fpu_load;
		q.fpu_store <= r.fpu_store;
		q.int <= r.int;
		q.bitm <= r.bitm;
		q.fpu <= r.fpu;
		q.csr <= r.csr;
		q.comp <= r.comp;
		q.atom <= r.atom;
		q.load_op <= r.load_op;
		q.store_op <= r.store_op;
		q.int_op <= r.int_op;
		q.bit_op <= r.bit_op;
		q.fpu_op <= r.fpu_op;
		q.atom_op <= r.atom_op;
		q.return_pop <= r.return_pop;
		q.return_push <= r.return_push;
		q.jump_uncond <= r.jump_uncond;
		q.jump_rest <= r.jump_rest;
		q.taken <= r.taken;
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.wfi <= r.wfi;
		q.fence <= r.fence;
		q.valid <= r.valid;
		q.stall <= r.stall;
		q.clear <= r.clear;

		q.int_wren_n <= r.int_wren_n;
		q.fpu_wren_n <= r.fpu_wren_n;
		q.csr_wren_n <= r.csr_wren_n;
		q.int_n <= r.int_n;
		q.bitm_n <= r.bitm_n;
		q.fpu_n <= r.fpu_n;
		q.csr_n <= r.csr_n;
		q.comp_n <= r.comp_n;
		q.atom_n <= r.atom_n;
		q.load_n <= r.load_n;
		q.store_n <= r.store_n;
		q.ldst_n <= r.ldst_n;
		q.fpu_load_n <= r.fpu_load_n;
		q.fpu_store_n <= r.fpu_store_n;
		q.return_pop_n <= r.return_pop_n;
		q.return_push_n <= r.return_push_n;
		q.jump_uncond_n <= r.jump_uncond_n;
		q.jump_rest_n <= r.jump_rest_n;
		q.taken_n <= r.taken_n;
		q.exc_n <= r.exc_n;
		q.ecall_n <= r.ecall_n;
		q.ebreak_n <= r.ebreak_n;
		q.mret_n <= r.mret_n;
		q.wfi_n <= r.wfi_n;
		q.fence_n <= r.fence_n;
		q.valid_n <= r.valid_n;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_decode_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
