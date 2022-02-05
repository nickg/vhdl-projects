-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bit_constants.all;
use work.bit_wire.all;
use work.bit_types.all;
use work.bit_functions.all;

entity bit_pipeline is
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
end bit_pipeline;

architecture behavior of bit_pipeline is

begin

	process(bit_pipeline_i, bit_alu_o, bit_clmul_o)

		variable rs1         : std_logic_vector(63 downto 0);
		variable rs2         : std_logic_vector(63 downto 0);
		variable imm         : std_logic_vector(63 downto 0);
		variable bit_op      : bit_operation_type;
		variable enable      : std_logic;
		variable clear       : std_logic;
		variable result      : std_logic_vector(63 downto 0);
		variable ready       : std_logic;

		variable alu_result   : std_logic_vector(63 downto 0);
		variable clmul_result : std_logic_vector(63 downto 0);
		variable clmul_ready  : std_logic;

	begin
		result := (others => '0');
		ready  := '0';

		rs1      := bit_pipeline_i.rs1;
		rs2      := bit_pipeline_i.rs2;
		imm      := bit_pipeline_i.imm;
		bit_op   := bit_pipeline_i.bit_op;
		enable   := bit_pipeline_i.enable;
		clear    := bit_pipeline_i.clear;

		bit_alu_i.rs1 <= rs1;
		bit_alu_i.rs2 <= rs2;
		bit_alu_i.imm <= imm;
		bit_alu_i.bit_op <= bit_op;
		bit_alu_i.word <= bit_op.bit_word;
		bit_alu_i.sel <= bit_op.bit_imm;

		alu_result := bit_alu_o.res;

		bit_clmul_i.data1 <= rs1;
		bit_clmul_i.data2 <= rs2;
		bit_clmul_i.op <= bit_op.bit_zbc;
		bit_clmul_i.word <= bit_op.bit_word;
		bit_clmul_i.enable <= enable;
		bit_clmul_i.clear <= clear;

		clmul_ready := bit_clmul_o.ready;
		clmul_result := bit_clmul_o.result;

		if clmul_ready = '1' then
			result := clmul_result;
			ready  := '1';
		elsif bit_op.bit_clmul = '1' then
			ready := '0';
		elsif bit_op.bit_alu = '1' then
			result := alu_result;
		end if;

		bit_pipeline_o.result <= result;
		bit_pipeline_o.ready <= ready;

	end process;

end architecture;
