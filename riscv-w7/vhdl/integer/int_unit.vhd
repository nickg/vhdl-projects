-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.lzc_lib.all;
use work.int_constants.all;
use work.int_wire.all;
use work.int_library.all;

entity int_unit is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		int_unit_i : in  int_unit_in_type;
		int_unit_o : out int_unit_out_type
	);
end int_unit;

architecture behavior of int_unit is

	signal lzc_64_mul_i : lzc_64_in_type;
	signal lzc_64_mul_o : lzc_64_out_type;
	signal lzc_64_div_i : lzc_64_in_type;
	signal lzc_64_div_o : lzc_64_out_type;

	signal int_alu_i : int_alu_in_type;
	signal int_alu_o : int_alu_out_type;
	signal int_bcu_i : int_bcu_in_type;
	signal int_bcu_o : int_bcu_out_type;
	signal int_agu_i : int_agu_in_type;
	signal int_agu_o : int_agu_out_type;
	signal int_mul_i : int_mul_in_type;
	signal int_mul_o : int_mul_out_type;
	signal int_div_i : int_div_in_type;
	signal int_div_o : int_div_out_type;

begin

	int_decode_comp : int_decode
		port map(
			int_decode_i => int_unit_i.int_decode_i,
			int_decode_o => int_unit_o.int_decode_o
		);

	int_reg_file_comp : int_reg_file
		port map(
			reset      => reset,
			clock      => clock,
			int_reg_ri => int_unit_i.int_reg_ri,
			int_reg_wi => int_unit_i.int_reg_wi,
			int_reg_o  => int_unit_o.int_reg_o
		);

	int_forward_comp : int_forward
		port map(
			int_for_i => int_unit_i.int_for_i,
			int_for_o => int_unit_o.int_for_o
		);

	int_alu_comp : int_alu
		port map(
			int_alu_i => int_alu_i,
			int_alu_o => int_alu_o
		);

	int_bcu_comp : int_bcu
		port map(
			int_bcu_i => int_bcu_i,
			int_bcu_o => int_bcu_o
		);

	int_agu_comp : int_agu
		port map(
			int_agu_i => int_agu_i,
			int_agu_o => int_agu_o
		);

	lzc_64_mul_comp : lzc_64
		port map(
			A => lzc_64_mul_i.a,
			Z => lzc_64_mul_o.c
		);

	int_mul_comp : int_mul
		port map(
			reset     => reset,
			clock     => clock,
			int_mul_i => int_mul_i,
			int_mul_o => int_mul_o,
			lzc_o     => lzc_64_mul_o,
			lzc_i     => lzc_64_mul_i
		);

	lzc_64_div_comp : lzc_64
		port map(
			A => lzc_64_div_i.a,
			Z => lzc_64_div_o.c
		);

	int_div_comp : int_div
		port map(
			reset     => reset,
			clock     => clock,
			int_div_i => int_div_i,
			int_div_o => int_div_o,
			lzc_o     => lzc_64_div_o,
			lzc_i     => lzc_64_div_i
		);

	int_pipeline_comp : int_pipeline
		port map(
			reset          => reset,
			clock          => clock,
			int_pipeline_i => int_unit_i.int_pipeline_i,
			int_pipeline_o => int_unit_o.int_pipeline_o,
			int_alu_i      => int_alu_i,
			int_alu_o      => int_alu_o,
			int_bcu_i      => int_bcu_i,
			int_bcu_o      => int_bcu_o,
			int_agu_i      => int_agu_i,
			int_agu_o      => int_agu_o,
			int_mul_i      => int_mul_i,
			int_mul_o      => int_mul_o,
			int_div_i      => int_div_i,
			int_div_o      => int_div_o
		);

end architecture;
