-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.int_constants.all;
use work.int_wire.all;

package int_library is

	component int_decode
		port(
			int_decode_i : in  int_decode_in_type;
			int_decode_o : out int_decode_out_type
		);
	end component;

	component int_reg_file
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			int_reg_ri : in  int_register_read_in_type;
			int_reg_wi : in  int_register_write_in_type;
			int_reg_o  : out int_register_out_type
		);
	end component;

	component int_forward
		port(
			int_for_i : in  int_forward_in_type;
			int_for_o : out int_forward_out_type
		);
	end component;

	component int_alu
		port(
			int_alu_i : in  int_alu_in_type;
			int_alu_o : out int_alu_out_type
		);
	end component;

	component int_bcu
		port(
			int_bcu_i : in  int_bcu_in_type;
			int_bcu_o : out int_bcu_out_type
		);
	end component;

	component int_agu
		port(
			int_agu_i : in  int_agu_in_type;
			int_agu_o : out int_agu_out_type
		);
	end component;

	component int_mul
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			int_mul_i : in  int_mul_in_type;
			int_mul_o : out int_mul_out_type;
			lzc_o     : in  lzc_64_out_type;
			lzc_i     : out lzc_64_in_type
		);
	end component;

	component int_div
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			int_div_i : in  int_div_in_type;
			int_div_o : out int_div_out_type;
			lzc_o     : in  lzc_64_out_type;
			lzc_i     : out lzc_64_in_type
		);
	end component;

	component int_pipeline
		port(
			reset          : in  std_logic;
			clock          : in  std_logic;
			int_pipeline_i : in  int_pipeline_in_type;
			int_pipeline_o : out int_pipeline_out_type;
			int_alu_i      : out int_alu_in_type;
			int_alu_o      : in  int_alu_out_type;
			int_bcu_i      : out int_bcu_in_type;
			int_bcu_o      : in  int_bcu_out_type;
			int_agu_i      : out int_agu_in_type;
			int_agu_o      : in  int_agu_out_type;
			int_mul_i      : out int_mul_in_type;
			int_mul_o      : in  int_mul_out_type;
			int_div_i      : out int_div_in_type;
			int_div_o      : in  int_div_out_type
		);
	end component;

end package;
