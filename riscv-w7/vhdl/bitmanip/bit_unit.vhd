-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bit_constants.all;
use work.bit_wire.all;
use work.bit_library.all;

entity bit_unit is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		bit_unit_i : in  bit_unit_in_type;
		bit_unit_o : out bit_unit_out_type
	);
end bit_unit;

architecture behavior of bit_unit is

	signal bit_alu_i   : bit_alu_in_type;
	signal bit_alu_o   : bit_alu_out_type;
	signal bit_clmul_i : bit_clmul_in_type;
	signal bit_clmul_o : bit_clmul_out_type;

begin

	bit_decode_comp : bit_decode
		port map(
			bit_decode_i => bit_unit_i.bit_decode_i,
			bit_decode_o => bit_unit_o.bit_decode_o
		);

	bit_alu_comp : bit_alu
		port map(
			bit_alu_i => bit_alu_i,
			bit_alu_o => bit_alu_o
		);

	bit_clmul_comp : bit_clmul
		port map(
			reset       => reset,
			clock       => clock,
			bit_clmul_i => bit_clmul_i,
			bit_clmul_o => bit_clmul_o
		);

	bit_pipeline_comp : bit_pipeline
		port map(
			reset          => reset,
			clock          => clock,
			bit_pipeline_i => bit_unit_i.bit_pipeline_i,
			bit_pipeline_o => bit_unit_o.bit_pipeline_o,
			bit_alu_i      => bit_alu_i,
			bit_alu_o      => bit_alu_o,
			bit_clmul_i    => bit_clmul_i,
			bit_clmul_o    => bit_clmul_o
		);

end architecture;
