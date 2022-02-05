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
use work.fp_wire.all;

entity writeback_stage is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		int_reg_wi : out int_register_write_in_type;
		fp_reg_wi  : out fp_reg_write_in_type;
		csr_wi     : out csr_write_in_type;
		csr_ci     : out csr_counter_in_type;
		csr_eo     : in  csr_exception_out_type;
		a          : in  writeback_in_type;
		d          : in  writeback_in_type;
		y          : out writeback_out_type;
		q          : out writeback_out_type
	);
end writeback_stage;

architecture behavior of writeback_stage is

	signal r   : writeback_reg_type := init_writeback_reg;
	signal rin : writeback_reg_type := init_writeback_reg;

begin

	combinational : process(a, d, r, csr_eo)

		variable v : writeback_reg_type;

	begin

		v := r;

		v.pc := d.m.pc;
		v.int_wren := d.m.int_wren;
		v.fpu_wren := d.m.fpu_wren;
		v.csr_wren := d.m.csr_wren;
		v.waddr := d.m.waddr;
		v.wdata := d.m.wdata;
		v.caddr := d.m.caddr;
		v.cdata := d.m.cdata;
		v.load := d.m.load;
		v.store := d.m.store;
		v.ldst := d.m.ldst;
		v.fpu_load := d.m.fpu_load;
		v.fpu_store := d.m.fpu_store;
		v.int := d.m.int;
		v.bitm := d.m.bitm;
		v.fpu := d.m.fpu;
		v.csr := d.m.csr;
		v.comp := d.m.comp;
		v.atom := d.m.atom;
		v.load_op := d.m.load_op;
		v.store_op := d.m.store_op;
		v.int_op := d.m.int_op;
		v.bit_op := d.m.bit_op;
		v.fpu_op := d.m.fpu_op;
		v.atom_op := d.m.atom_op;
		v.exc := d.m.exc;
		v.etval := d.m.etval;
		v.ecause := d.m.ecause;
		v.ecall := d.m.ecall;
		v.ebreak := d.m.ebreak;
		v.mret := d.m.mret;
		v.flags := d.m.flags;
		v.valid := d.m.valid;

		if d.w.stall = '1' then
			v := r;
		end if;

		v.stall := '0';

		v.clear := d.w.clear;

		if (v.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.fpu_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.bitm := '0';
			v.fpu := '0';
			v.csr := '0';
			v.comp := '0';
			v.atom := '0';
			v.fpu_load := '0';
			v.fpu_store := '0';
			v.load := '0';
			v.store := '0';
			v.ldst := '0';
			v.exc := '0';
			v.ecall := '0';
			v.ebreak := '0';
			v.mret := '0';
			v.valid := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		int_reg_wi.wren <= v.int_wren;
		int_reg_wi.waddr <= v.waddr;
		int_reg_wi.wdata <= v.wdata;

		fp_reg_wi.wren <= v.fpu_wren;
		fp_reg_wi.waddr <= v.waddr;
		fp_reg_wi.wdata <= v.wdata;

		csr_wi.wren <= v.csr_wren;
		csr_wi.waddr <= v.caddr;
		csr_wi.wdata <= v.cdata;

		csr_ci.load <= v.load;
		csr_ci.store <= v.store;
		csr_ci.int <= v.int;
		csr_ci.bitm <= v.bitm;
		csr_ci.fpu <= v.fpu;
		csr_ci.csr <= v.csr;
		csr_ci.comp <= v.comp;
		csr_ci.atom <= v.atom;
		csr_ci.int_op <= v.int_op;
		csr_ci.bit_op <= v.bit_op;
		csr_ci.fpu_op <= v.fpu_op;
		csr_ci.flags <= v.flags;

		rin <= v;

		y.pc <= v.pc;
		y.exc <= v.exc;
		y.ecall <= v.ecall;
		y.ebreak <= v.ebreak;
		y.mret <= v.mret;
		y.valid <= v.valid;
		y.stall <= v.stall;
		y.clear <= v.clear;

		q.pc <= r.pc;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.valid <= r.valid;
		q.stall <= r.stall;
		q.clear <= r.clear;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_writeback_reg;

			else

				r <= rin;
				r.clear <= '0';

			end if;

		end if;

	end process;

end architecture;
