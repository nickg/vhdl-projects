-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;
use work.configure.all;
use work.comp_wire.all;
use work.atom_wire.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.bit_wire.all;
use work.fp_wire.all;

entity pipeline is
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		imem_o  : in  mem_out_type;
		imem_i  : out mem_in_type;
		dmem_o  : in  mem_out_type;
		dmem_i  : out mem_in_type;
		ipmp_o  : in  pmp_out_type;
		ipmp_i  : out pmp_in_type;
		dpmp_o  : in  pmp_out_type;
		dpmp_i  : out pmp_in_type;
		fpu_o   : in  fpu_out_type;
		fpu_i   : out fpu_in_type;
		meip_i  : in  std_logic;
		msip_i  : in  std_logic;
		mtip_i  : in  std_logic;
		mtime_i : in  std_logic_vector(63 downto 0)
	);
end pipeline;

architecture behavior of pipeline is

	component fetch_stage
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			csr_eo    : in  csr_exception_out_type;
			bp_o      : in  bp_out_type;
			bp_i      : out bp_in_type;
			fbuffer_o : in  fetchbuffer_out_type;
			fbuffer_i : out fetchbuffer_in_type;
			ipmp_o    : in  pmp_out_type;
			ipmp_i    : out pmp_in_type;
			a         : in  fetch_in_type;
			d         : in  fetch_in_type;
			y         : out fetch_out_type;
			q         : out fetch_out_type
		);
	end component;

	component decode_stage
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
	end component;

	component execute_stage
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
	end component;

	component memory_stage
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			csr_eo    : in  csr_exception_out_type;
			sbuffer_o : in  storebuffer_out_type;
			sbuffer_i : out storebuffer_in_type;
			a         : in  memory_in_type;
			d         : in  memory_in_type;
			y         : out memory_out_type;
			q         : out memory_out_type
		);
	end component;

	component writeback_stage
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
	end component;

	component comp_decode
		port(
			comp_decode_i : in  comp_decode_in_type;
			comp_decode_o : out comp_decode_out_type
		);
	end component;

	component atom_decode
		port(
			atom_decode_i : in  atom_decode_in_type;
			atom_decode_o : out atom_decode_out_type
		);
	end component;

	component csr_unit
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			csr_unit_i : in  csr_unit_in_type;
			csr_unit_o : out csr_unit_out_type
		);
	end component;

	component int_unit
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			int_unit_i : in  int_unit_in_type;
			int_unit_o : out int_unit_out_type
		);
	end component;

	component bit_unit
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			bit_unit_i : in  bit_unit_in_type;
			bit_unit_o : out bit_unit_out_type
		);
	end component;

	component atom_agu
		port(
			atom_agu_i : in  atom_agu_in_type;
			atom_agu_o : out atom_agu_out_type
		);
	end component;

	component atom_alu
		port(
			atom_alu_i : in  atom_alu_in_type;
			atom_alu_o : out atom_alu_out_type
		);
	end component;

	component bp
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			bp_i  : in  bp_in_type;
			bp_o  : out bp_out_type;
			bht_i : out bht_in_type;
			bht_o : in  bht_out_type;
			btb_i : out btb_in_type;
			btb_o : in  btb_out_type;
			ras_i : out ras_in_type;
			ras_o : in  ras_out_type
		);
	end component;

	component bht
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			bht_i : in  bht_in_type;
			bht_o : out bht_out_type
		);
	end component;

	component btb
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			btb_i : in  btb_in_type;
			btb_o : out btb_out_type
		);
	end component;

	component ras
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			ras_i : in  ras_in_type;
			ras_o : out ras_out_type
		);
	end component;

	component fetchbuffer
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			fbuffer_i : in  fetchbuffer_in_type;
			fbuffer_o : out fetchbuffer_out_type;
			imem_o    : in  mem_out_type;
			imem_i    : out mem_in_type
		);
	end component;

	component storebuffer
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			sbuffer_i : in  storebuffer_in_type;
			sbuffer_o : out storebuffer_out_type;
			dmem_o    : in  mem_out_type;
			dmem_i    : out mem_in_type
		);
	end component;

	signal fetch_y     : fetch_out_type;
	signal decode_y    : decode_out_type;
	signal execute_y   : execute_out_type;
	signal memory_y    : memory_out_type;
	signal writeback_y : writeback_out_type;

	signal fetch_q     : fetch_out_type;
	signal decode_q    : decode_out_type;
	signal execute_q   : execute_out_type;
	signal memory_q    : memory_out_type;
	signal writeback_q : writeback_out_type;

	signal comp_decode_i : comp_decode_in_type;
	signal comp_decode_o : comp_decode_out_type;

	signal atom_decode_i : atom_decode_in_type;
	signal atom_decode_o : atom_decode_out_type;

	signal csr_unit_i : csr_unit_in_type;
	signal csr_unit_o : csr_unit_out_type;

	signal int_unit_i : int_unit_in_type;
	signal int_unit_o : int_unit_out_type;

	signal bit_unit_i : bit_unit_in_type;
	signal bit_unit_o : bit_unit_out_type;

	signal atom_agu_i : atom_agu_in_type;
	signal atom_agu_o : atom_agu_out_type;

	signal atom_alu_i : atom_alu_in_type;
	signal atom_alu_o : atom_alu_out_type;

	signal bp_i : bp_in_type;
	signal bp_o : bp_out_type;

	signal bht_i : bht_in_type;
	signal bht_o : bht_out_type;

	signal btb_i : btb_in_type;
	signal btb_o : btb_out_type;

	signal ras_i : ras_in_type;
	signal ras_o : ras_out_type;

	signal fbuffer_i : fetchbuffer_in_type;
	signal fbuffer_o : fetchbuffer_out_type;

	signal sbuffer_i : storebuffer_in_type;
	signal sbuffer_o : storebuffer_out_type;

begin

	fetch_stage_comp : fetch_stage
		port map(
			reset     => reset,
			clock     => clock,
			csr_eo    => csr_unit_o.csr_eo,
			bp_o      => bp_o,
			bp_i      => bp_i,
			fbuffer_o => fbuffer_o,
			fbuffer_i => fbuffer_i,
			ipmp_o    => ipmp_o,
			ipmp_i    => ipmp_i,
			a.f       => fetch_y,
			a.d       => decode_y,
			a.e       => execute_y,
			a.m       => memory_y,
			a.w       => writeback_y,
			d.f       => fetch_q,
			d.d       => decode_q,
			d.e       => execute_q,
			d.m       => memory_q,
			d.w       => writeback_q,
			y         => fetch_y,
			q         => fetch_q
		);

	decode_stage_comp : decode_stage
		port map(
			reset         => reset,
			clock         => clock,
			int_decode_i  => int_unit_i.int_decode_i,
			int_decode_o  => int_unit_o.int_decode_o,
			bit_decode_i  => bit_unit_i.bit_decode_i,
			bit_decode_o  => bit_unit_o.bit_decode_o,
			comp_decode_i => comp_decode_i,
			comp_decode_o => comp_decode_o,
			atom_decode_i => atom_decode_i,
			atom_decode_o => atom_decode_o,
			fp_dec_i      => fpu_i.fp_dec_i,
			fp_dec_o      => fpu_o.fp_dec_o,
			csr_eo        => csr_unit_o.csr_eo,
			a.f           => fetch_y,
			a.d           => decode_y,
			a.e           => execute_y,
			a.m           => memory_y,
			a.w           => writeback_y,
			d.f           => fetch_q,
			d.d           => decode_q,
			d.e           => execute_q,
			d.m           => memory_q,
			d.w           => writeback_q,
			y             => decode_y,
			q             => decode_q
		);

	execute_stage_comp : execute_stage
		port map(
			reset          => reset,
			clock          => clock,
			int_reg_ri     => int_unit_i.int_reg_ri,
			int_for_i      => int_unit_i.int_for_i,
			int_for_o      => int_unit_o.int_for_o,
			int_reg_o      => int_unit_o.int_reg_o,
			csr_ri         => csr_unit_i.csr_ri,
			csr_ei         => csr_unit_i.csr_ei,
			csr_o          => csr_unit_o.csr_o,
			int_pipeline_i => int_unit_i.int_pipeline_i,
			int_pipeline_o => int_unit_o.int_pipeline_o,
			bit_pipeline_i => bit_unit_i.bit_pipeline_i,
			bit_pipeline_o => bit_unit_o.bit_pipeline_o,
			csr_alu_i      => csr_unit_i.csr_alu_i,
			csr_alu_o      => csr_unit_o.csr_alu_o,
			csr_eo         => csr_unit_o.csr_eo,
			atom_agu_o     => atom_agu_o,
			atom_agu_i     => atom_agu_i,
			atom_alu_o     => atom_alu_o,
			atom_alu_i     => atom_alu_i,
			fp_reg_o       => fpu_o.fp_reg_o,
			fp_reg_ri      => fpu_i.fp_reg_ri,
			fp_for_o       => fpu_o.fp_for_o,
			fp_for_i       => fpu_i.fp_for_i,
			fp_exe_o       => fpu_o.fp_exe_o,
			fp_exe_i       => fpu_i.fp_exe_i,
			dpmp_o         => dpmp_o,
			dpmp_i         => dpmp_i,
			meip_i         => meip_i,
			msip_i         => msip_i,
			mtip_i         => mtip_i,
			mtime_i        => mtime_i,
			a.f            => fetch_y,
			a.d            => decode_y,
			a.e            => execute_y,
			a.m            => memory_y,
			a.w            => writeback_y,
			d.f            => fetch_q,
			d.d            => decode_q,
			d.e            => execute_q,
			d.m            => memory_q,
			d.w            => writeback_q,
			y              => execute_y,
			q              => execute_q
		);

	memory_stage_comp : memory_stage
		port map(
			reset     => reset,
			clock     => clock,
			csr_eo    => csr_unit_o.csr_eo,
			sbuffer_o => sbuffer_o,
			sbuffer_i => sbuffer_i,
			a.f       => fetch_y,
			a.d       => decode_y,
			a.e       => execute_y,
			a.m       => memory_y,
			a.w       => writeback_y,
			d.f       => fetch_q,
			d.d       => decode_q,
			d.e       => execute_q,
			d.m       => memory_q,
			d.w       => writeback_q,
			y         => memory_y,
			q         => memory_q
		);

	writeback_stage_comp : writeback_stage
		port map(
			reset      => reset,
			clock      => clock,
			int_reg_wi => int_unit_i.int_reg_wi,
			fp_reg_wi  => fpu_i.fp_reg_wi,
			csr_wi     => csr_unit_i.csr_wi,
			csr_ci     => csr_unit_i.csr_ci,
			csr_eo     => csr_unit_o.csr_eo,
			a.f        => fetch_y,
			a.d        => decode_y,
			a.e        => execute_y,
			a.m        => memory_y,
			a.w        => writeback_y,
			d.f        => fetch_q,
			d.d        => decode_q,
			d.e        => execute_q,
			d.m        => memory_q,
			d.w        => writeback_q,
			y          => writeback_y,
			q          => writeback_q
		);

	comp_decode_comp : comp_decode
		port map(
			comp_decode_i => comp_decode_i,
			comp_decode_o => comp_decode_o
		);

	atom_decode_comp : atom_decode
		port map(
			atom_decode_i => atom_decode_i,
			atom_decode_o => atom_decode_o
		);

	csr_unit_comp : csr_unit
		port map(
			reset      => reset,
			clock      => clock,
			csr_unit_i => csr_unit_i,
			csr_unit_o => csr_unit_o
		);

	int_unit_comp : int_unit
		port map(
			reset      => reset,
			clock      => clock,
			int_unit_i => int_unit_i,
			int_unit_o => int_unit_o
		);

	bit_unit_comp : bit_unit
		port map(
			reset      => reset,
			clock      => clock,
			bit_unit_i => bit_unit_i,
			bit_unit_o => bit_unit_o
		);

	atom_agu_comp : atom_agu
		port map(
			atom_agu_i => atom_agu_i,
			atom_agu_o => atom_agu_o
		);

	atom_alu_comp : atom_alu
		port map(
			atom_alu_i => atom_alu_i,
			atom_alu_o => atom_alu_o
		);

	bp_comp : bp
		port map(
			reset => reset,
			clock => clock,
			bp_i  => bp_i,
			bp_o  => bp_o,
			bht_i => bht_i,
			bht_o => bht_o,
			btb_i => btb_i,
			btb_o => btb_o,
			ras_i => ras_i,
			ras_o => ras_o
		);

	bht_comp : bht
		port map(
			reset => reset,
			clock => clock,
			bht_i => bht_i,
			bht_o => bht_o
		);

	btb_comp : btb
		port map(
			reset => reset,
			clock => clock,
			btb_i => btb_i,
			btb_o => btb_o
		);

	ras_comp : ras
		port map(
			reset => reset,
			clock => clock,
			ras_i => ras_i,
			ras_o => ras_o
		);

	fetchbuffer_comp : fetchbuffer
		port map(
			reset     => reset,
			clock     => clock,
			fbuffer_i => fbuffer_i,
			fbuffer_o => fbuffer_o,
			imem_o    => imem_o,
			imem_i    => imem_i
		);

	storebuffer_comp : storebuffer
		port map(
			reset     => reset,
			clock     => clock,
			sbuffer_i => sbuffer_i,
			sbuffer_o => sbuffer_o,
			dmem_o    => dmem_o,
			dmem_i    => dmem_i
		);

end architecture;
