-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.bit_wire.all;
use work.fp_wire.all;
use work.atom_wire.all;

entity execute_stage is
	port(
		reset          : in  std_logic;
		clock          : in  std_logic;
		int_reg_ri     : out int_register_read_in_type;
		int_for_i      : out int_forward_in_type;
		int_for_o      : in  int_forward_out_type;
		int_reg_o      : in  int_register_out_type;
		csr_ri         : out csr_read_in_type;
		csr_ei         : out csr_exception_in_type;
		csr_o          : in  csr_out_type;
		int_pipeline_i : out int_pipeline_in_type;
		int_pipeline_o : in  int_pipeline_out_type;
		bit_pipeline_i : out bit_pipeline_in_type;
		bit_pipeline_o : in  bit_pipeline_out_type;
		csr_alu_i      : out csr_alu_in_type;
		csr_alu_o      : in  csr_alu_out_type;
		csr_eo         : in  csr_exception_out_type;
		atom_agu_o     : in  atom_agu_out_type;
		atom_agu_i     : out atom_agu_in_type;
		atom_alu_o     : in  atom_alu_out_type;
		atom_alu_i     : out atom_alu_in_type;
		fp_reg_o       : in  fp_reg_out_type;
		fp_reg_ri      : out fp_reg_read_in_type;
		fp_for_o       : in  fp_for_out_type;
		fp_for_i       : out fp_for_in_type;
		fp_exe_o       : in  fp_exe_out_type;
		fp_exe_i       : out fp_exe_in_type;
		dpmp_o         : in  pmp_out_type;
		dpmp_i         : out pmp_in_type;
		meip_i         : in  std_logic;
		msip_i         : in  std_logic;
		mtip_i         : in  std_logic;
		mtime_i        : in  std_logic_vector(63 downto 0);
		a              : in  execute_in_type;
		d              : in  execute_in_type;
		y              : out execute_out_type;
		q              : out execute_out_type
	);
end execute_stage;

architecture behavior of execute_stage is

	signal r   : execute_reg_type := init_execute_reg;
	signal rin : execute_reg_type := init_execute_reg;

begin

	combinational : process(a, d, r, int_for_o, int_reg_o, csr_o, csr_eo, int_pipeline_o, bit_pipeline_o, atom_agu_o, atom_alu_o, fp_reg_o, fp_for_o, fp_exe_o, csr_alu_o, dpmp_o, meip_i, msip_i, mtip_i, mtime_i)

		variable v : execute_reg_type;

	begin

		v := r;

		v.pc := d.d.pc;
		v.npc := d.d.npc;
		v.funct3 := d.d.funct3;
		v.funct7 := d.d.funct7;
		v.fmt := d.d.fmt;
		v.rm := d.d.rm;
		v.imm := d.d.imm;
		v.int_rden1 := d.d.int_rden1;
		v.int_rden2 := d.d.int_rden2;
		v.fpu_rden1 := d.d.fpu_rden1;
		v.fpu_rden2 := d.d.fpu_rden2;
		v.fpu_rden3 := d.d.fpu_rden3;
		v.csr_rden := d.d.csr_rden;
		v.int_wren := d.d.int_wren;
		v.fpu_wren := d.d.fpu_wren;
		v.csr_wren := d.d.csr_wren;
		v.raddr1 := d.d.raddr1;
		v.raddr2 := d.d.raddr2;
		v.raddr3 := d.d.raddr3;
		v.waddr := d.d.waddr;
		v.caddr := d.d.caddr;
		v.load := d.d.load;
		v.store := d.d.store;
		v.ldst := d.d.ldst;
		v.fpu_load := d.d.fpu_load;
		v.fpu_store := d.d.fpu_store;
		v.int := d.d.int;
		v.bitm := d.d.bitm;
		v.fpu := d.d.fpu;
		v.csr := d.d.csr;
		v.comp := d.d.comp;
		v.atom := d.d.atom;
		v.load_op := d.d.load_op;
		v.store_op := d.d.store_op;
		v.int_op := d.d.int_op;
		v.bit_op := d.d.bit_op;
		v.fpu_op := d.d.fpu_op;
		v.atom_op := d.d.atom_op;
		v.return_pop := d.d.return_pop;
		v.return_push := d.d.return_push;
		v.jump_uncond := d.d.jump_uncond;
		v.jump_rest := d.d.jump_rest;
		v.taken := d.d.taken;
		v.exc := d.d.exc;
		v.etval := d.d.etval;
		v.ecause := d.d.ecause;
		v.ecall := d.d.ecall;
		v.ebreak := d.d.ebreak;
		v.mret := d.d.mret;
		v.fence := d.d.fence;
		v.valid := d.d.valid;

		if (d.e.stall or d.m.stall or d.w.stall) = '1' then
			v := r;
			v.int_wren := v.int_wren_n;
			v.fpu_wren := v.fpu_wren_n;
			v.csr_wren := v.csr_wren_n;
			v.int := v.int_n;
			v.bitm := v.bitm_n;
			v.fpu := v.fpu_n;
			v.csr := v.csr_n;
			v.comp := v.comp_n;
			v.atom := v.atom_n;
			v.load := v.load_n;
			v.store := v.store_n;
			v.ldst := v.ldst_n;
			v.fpu_load := v.fpu_load_n;
			v.fpu_store := v.fpu_store_n;
			v.return_pop := v.return_pop_n;
			v.return_push := v.return_push_n;
			v.jump_uncond := v.jump_uncond_n;
			v.jump_rest := v.jump_rest_n;
			v.taken := v.taken_n;
			v.exc := v.exc_n;
			v.ecall := v.ecall_n;
			v.ebreak := v.ebreak_n;
			v.mret := v.mret_n;
			v.fence := v.fence_n;
			v.valid := v.valid_n;
		end if;

		v.stall := '0';

		v.clear := csr_eo.exc or csr_eo.mret or d.e.jump or d.w.clear;

		v.enable := not(d.e.stall or a.m.stall or a.w.stall or d.w.clear);

		int_reg_ri.rden1 <= v.int_rden1;
		int_reg_ri.rden2 <= v.int_rden2;
		int_reg_ri.raddr1 <= v.raddr1;
		int_reg_ri.raddr2 <= v.raddr2;

		fp_reg_ri.rden1 <= v.fpu_rden1;
		fp_reg_ri.rden2 <= v.fpu_rden2;
		fp_reg_ri.rden3 <= v.fpu_rden3;
		fp_reg_ri.raddr1 <= v.raddr1;
		fp_reg_ri.raddr2 <= v.raddr2;
		fp_reg_ri.raddr3 <= v.raddr3;

		csr_ri.rden <= v.csr_rden;
		csr_ri.raddr <= v.caddr;

		int_for_i.reg_en1 <= v.int_rden1;
		int_for_i.reg_en2 <= v.int_rden2;
		int_for_i.reg_addr1 <= v.raddr1;
		int_for_i.reg_addr2 <= v.raddr2;
		int_for_i.reg_data1 <= int_reg_o.data1;
		int_for_i.reg_data2 <= int_reg_o.data2;
		int_for_i.exe_en <= d.e.int_wren;
		int_for_i.mem_en <= d.m.int_wren;
		int_for_i.exe_addr <= d.e.waddr;
		int_for_i.mem_addr <= d.m.waddr;
		int_for_i.exe_data <= d.e.wdata;
		int_for_i.mem_data <= d.m.wdata;

		fp_for_i.reg_en1 <= v.fpu_rden1;
		fp_for_i.reg_en2 <= v.fpu_rden2;
		fp_for_i.reg_en3 <= v.fpu_rden3;
		fp_for_i.reg_addr1 <= v.raddr1;
		fp_for_i.reg_addr2 <= v.raddr2;
		fp_for_i.reg_addr3 <= v.raddr3;
		fp_for_i.reg_data1 <= fp_reg_o.data1;
		fp_for_i.reg_data2 <= fp_reg_o.data2;
		fp_for_i.reg_data3 <= fp_reg_o.data3;
		fp_for_i.exe_en <= d.e.fpu_wren;
		fp_for_i.mem_en <= d.m.fpu_wren;
		fp_for_i.exe_addr <= d.e.waddr;
		fp_for_i.mem_addr <= d.m.waddr;
		fp_for_i.exe_data <= d.e.wdata;
		fp_for_i.mem_data <= d.m.wdata;

		v.cdata := csr_o.data;

		v.rdata1 := int_for_o.data1;
		v.rdata2 := int_for_o.data2;

		v.frdata1 := fp_for_o.data1;
		v.frdata2 := fp_for_o.data2;
		v.frdata3 := fp_for_o.data3;

		if v.fpu_store = '1' then
			v.sdata := v.frdata2;
		elsif v.store = '1' then
			v.sdata := v.rdata2;
		end if;

		int_pipeline_i.pc <= v.pc;
		int_pipeline_i.npc <= v.npc;
		int_pipeline_i.rs1 <= v.rdata1;
		int_pipeline_i.rs2 <= v.rdata2;
		int_pipeline_i.imm <= v.imm;
		int_pipeline_i.funct <= v.funct3;
		int_pipeline_i.load <= v.load or v.fpu_load;
		int_pipeline_i.store <= v.store or v.fpu_store;
		int_pipeline_i.load_op <= v.load_op;
		int_pipeline_i.store_op <= v.store_op;
		int_pipeline_i.int_op <= v.int_op;
		int_pipeline_i.enable <= v.enable;
		int_pipeline_i.clear <= v.clear;

		bit_pipeline_i.rs1 <= v.rdata1;
		bit_pipeline_i.rs2 <= v.rdata2;
		bit_pipeline_i.imm <= v.imm;
		bit_pipeline_i.bit_op <= v.bit_op;
		bit_pipeline_i.enable <= v.enable;
		bit_pipeline_i.clear <= v.clear;

		atom_alu_i.lval <= d.m.ldata;
		atom_alu_i.rs2 <= d.m.rdata2;
		atom_alu_i.atom_op <= d.m.atom_op;

		atom_agu_i.rs1 <= v.rdata1;
		atom_agu_i.load <= v.load;
		atom_agu_i.store <= v.store;
		atom_agu_i.atom_op <= v.atom_op;
		atom_agu_i.atom <= v.atom;

		fp_exe_i.idata <= v.rdata1;
		fp_exe_i.data1 <= v.frdata1;
		fp_exe_i.data2 <= v.frdata2;
		fp_exe_i.data3 <= v.frdata3;
		fp_exe_i.op <= v.fpu_op;
		fp_exe_i.fmt <= v.fmt;
		fp_exe_i.rm <= v.rm;
		fp_exe_i.enable <= v.enable;
		fp_exe_i.clear  <= v.clear;

		v.idata := int_pipeline_o.result;
		v.jump := int_pipeline_o.jump;
		v.address := int_pipeline_o.mem_addr;
		v.byteenable := int_pipeline_o.mem_byte;
		v.ready := int_pipeline_o.ready;

		if v.atom = '1' then
			v.address := atom_agu_o.mem_addr;
			v.byteenable := atom_agu_o.mem_byte;
		end if;

		v.bdata := bit_pipeline_o.result;
		v.bready := bit_pipeline_o.ready;

		v.fdata := fp_exe_o.result;
		v.flags := fp_exe_o.flags;
		v.fready := fp_exe_o.ready;

		if v.csr = '1' then
			v.wdata := v.cdata;
		elsif v.bitm = '1' then
			v.wdata := v.bdata;
		elsif v.fpu = '1' then
			v.wdata := v.fdata;
		elsif v.int = '1' then
			v.wdata := v.idata;
		end if;

		csr_alu_i.rs1 <= v.rdata1;
		csr_alu_i.imm <= v.imm;
		csr_alu_i.data <= v.cdata;
		csr_alu_i.funct <= v.funct3;

		v.cdata := csr_alu_o.result;

		if (d.m.ldst and d.m.load) = '1' then
			v.int_wren := '1';
			v.load := '0';
			v.store := '1';
			v.ldst := '1';
			v.waddr := d.m.waddr;
			v.wdata := d.m.wdata;
			v.sdata := atom_alu_o.res;
			v.store_op := d.m.store_op;
			v.atom := d.m.atom;
			v.address := d.m.address;
			v.byteenable := d.m.byteenable;
		end if;

		dpmp_i.mem_valid <= v.load or v.fpu_load or v.store or v.fpu_store;
		dpmp_i.mem_instr <= '0';
		dpmp_i.mem_write <= v.store or v.fpu_store;
		dpmp_i.mem_addr <= v.address;
		dpmp_i.mode <= csr_eo.mode;
		dpmp_i.pmpcfg <= csr_eo.pmpcfg;
		dpmp_i.pmpaddr <= csr_eo.pmpaddr;

		if v.exc = '0' then
			if int_pipeline_o.exc = '1' then
				if (v.jump or v.load or v.fpu_load or v.store or v.fpu_store) = '1' then
					v.exc := int_pipeline_o.exc;
					v.etval := int_pipeline_o.etval;
					v.ecause := int_pipeline_o.ecause;
					v.jump := '0';
					v.load := '0';
					v.store := '0';
					v.fpu_load := '0';
					v.fpu_store := '0';
					v.int := '0';
					if v.ecause /= x"1" then
						v.int_wren := '0';
					end if;
				end if;
			elsif atom_agu_o.exc = '1' then
				v.exc := atom_agu_o.exc;
				v.etval := atom_agu_o.etval;
				v.ecause := atom_agu_o.ecause;
				v.atom := '0';
				v.load := '0';
				v.store := '0';
				v.int_wren := '0';
			elsif dpmp_o.exc = '1' then
				v.exc := dpmp_o.exc;
				v.etval := dpmp_o.etval;
				v.ecause := dpmp_o.ecause;
			end if;
		end if;

		if v.int_op.mcycle = '1' then
			if v.ready = '0' then
				if (a.m.stall or a.w.stall) = '0' then
					v.stall := '1';
				end if;
			end if;
		end if;

		if v.bit_op.bmcycle = '1' then
			if v.bready = '0' then
				if (a.m.stall or a.w.stall) = '0' then
					v.stall := '1';
				end if;
			end if;
		end if;

		if v.fpu_op.fmcycle = '1' then
			if v.fready = '0' then
				if (a.m.stall or a.w.stall) = '0' then
					v.stall := '1';
				end if;
			end if;
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
		v.fence_n := v.fence;
		v.valid_n := v.valid;

		if (v.stall or a.m.stall or a.w.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.fpu_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.bitm := '0';
			v.fpu := '0';
			v.csr := '0';
			v.comp := '0';
			v.atom := '0';
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
			v.fence := '0';
			v.jump := '0';
			v.valid := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		csr_ei.d_epc <= v.pc;
		csr_ei.e_epc <= d.e.pc;
		csr_ei.m_epc <= d.m.pc;
		csr_ei.w_epc <= d.w.pc;
		csr_ei.d_valid <= v.valid;
		csr_ei.e_valid <= d.e.valid;
		csr_ei.m_valid <= d.m.valid;
		csr_ei.w_valid <= d.w.valid;
		csr_ei.exc <= v.exc;
		csr_ei.etval <= v.etval;
		csr_ei.ecause <= v.ecause;
		csr_ei.ecall <= v.ecall;
		csr_ei.ebreak <= v.ebreak;
		csr_ei.mret <= v.mret;

		csr_ei.meip <= meip_i;
		csr_ei.msip <= msip_i;
		csr_ei.mtip <= mtip_i;
		csr_ei.mtime <= mtime_i;

		rin <= v;

		y.pc <= v.pc;
		y.npc <= v.npc;
		y.funct3 <= v.funct3;
		y.int_wren <= v.int_wren;
		y.fpu_wren <= v.fpu_wren;
		y.csr_wren <= v.csr_wren;
		y.waddr <= v.waddr;
		y.caddr <= v.caddr;
		y.rdata2 <= v.rdata2;
		y.wdata <= v.wdata;
		y.cdata <= v.cdata;
		y.sdata <= v.sdata;
		y.flags <= v.flags;
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
		y.jump <= v.jump;
		y.address <= v.address;
		y.byteenable <= v.byteenable;
		y.etval <= v.etval;
		y.ecause <= v.ecause;
		y.exc <= v.exc;
		y.ecall <= v.ecall;
		y.ebreak <= v.ebreak;
		y.mret <= v.mret;
		y.fence <= v.fence;
		y.valid <= v.valid;
		y.jump <= v.jump;
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
		y.fence_n <= v.fence_n;
		y.valid_n <= v.valid_n;

		q.pc <= r.pc;
		q.npc <= r.npc;
		q.funct3 <= r.funct3;
		q.int_wren <= r.int_wren;
		q.fpu_wren <= r.fpu_wren;
		q.csr_wren <= r.csr_wren;
		q.waddr <= r.waddr;
		q.caddr <= r.caddr;
		q.rdata2 <= r.rdata2;
		q.wdata <= r.wdata;
		q.cdata <= r.cdata;
		q.sdata <= r.sdata;
		q.flags <= r.flags;
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
		q.jump <= r.jump;
		q.address <= r.address;
		q.byteenable <= r.byteenable;
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.fence <= r.fence;
		q.valid <= r.valid;
		q.jump <= r.jump;
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
		q.fence_n <= r.fence_n;
		q.valid_n <= r.valid_n;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_execute_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
