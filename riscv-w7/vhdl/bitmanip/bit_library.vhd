-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.bit_constants.all;
use work.bit_wire.all;

package bit_library is

	component bit_decode
		port(
			bit_decode_i : in  bit_decode_in_type;
			bit_decode_o : out bit_decode_out_type
		);
	end component;

	component bit_alu
		port(
			bit_alu_i : in  bit_alu_in_type;
			bit_alu_o : out bit_alu_out_type
		);
	end component;

	component bit_clmul
		port(
			reset       : in  std_logic;
			clock       : in  std_logic;
			bit_clmul_i : in  bit_clmul_in_type;
			bit_clmul_o : out bit_clmul_out_type
		);
	end component;

	component bit_pipeline
		port(
			reset          : in  std_logic;
			clock          : in  std_logic;
			bit_pipeline_i : in  bit_pipeline_in_type;
			bit_pipeline_o : out bit_pipeline_out_type;
			bit_alu_i      : out bit_alu_in_type;
			bit_alu_o      : in  bit_alu_out_type;
			bit_clmul_i    : out bit_clmul_in_type;
			bit_clmul_o    : in  bit_clmul_out_type
		);
	end component;

end package;
