-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;
use work.int_constants.all;
use work.int_wire.all;
use work.int_types.all;

entity int_pipeline is
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
end int_pipeline;

architecture behavior of int_pipeline is

begin

	process(int_pipeline_i, int_alu_o, int_bcu_o, int_agu_o, int_mul_o, int_div_o)
		variable pc        : std_logic_vector(63 downto 0);
		variable npc       : std_logic_vector(63 downto 0);
		variable rs1       : std_logic_vector(63 downto 0);
		variable rs2       : std_logic_vector(63 downto 0);
		variable imm       : std_logic_vector(63 downto 0);
		variable load      : std_logic;
		variable store     : std_logic;
		variable load_op   : load_operation_type;
		variable store_op  : store_operation_type;
		variable int_op    : int_operation_type;
		variable enable    : std_logic;
		variable clear     : std_logic;
		variable alu_data  : std_logic_vector(63 downto 0);
		variable mul_data  : std_logic_vector(63 downto 0);
		variable div_data  : std_logic_vector(63 downto 0);
		variable result    : std_logic_vector(63 downto 0);
		variable inc       : natural range 0 to 7;
		variable jump      : std_logic;
		variable mem_addr  : std_logic_vector(63 downto 0);
		variable mem_byte  : std_logic_vector(7 downto 0);
		variable exc       : std_logic;
		variable etval     : std_logic_vector(63 downto 0);
		variable ecause    : std_logic_vector(3 downto 0);
		variable mul_ready : std_logic;
		variable div_ready : std_logic;
		variable ready     : std_logic;

	begin
		result := (others => '0');
		ready  := '0';

		pc       := int_pipeline_i.pc;
		npc      := int_pipeline_i.npc;
		rs1      := int_pipeline_i.rs1;
		rs2      := int_pipeline_i.rs2;
		imm      := int_pipeline_i.imm;
		load     := int_pipeline_i.load;
		store    := int_pipeline_i.store;
		load_op  := int_pipeline_i.load_op;
		store_op := int_pipeline_i.store_op;
		int_op   := int_pipeline_i.int_op;
		enable   := int_pipeline_i.enable;
		clear    := int_pipeline_i.clear;

		int_alu_i.rs1 <= rs1;
		int_alu_i.rs2 <= rs2;
		int_alu_i.imm <= imm;
		int_alu_i.alu_op <= int_op.alu_op;
		int_alu_i.word <= int_op.word;
		int_alu_i.sel <= int_op.alu_imm;

		alu_data := int_alu_o.res;

		int_bcu_i.rs1 <= rs1;
		int_bcu_i.rs2 <= rs2;
		int_bcu_i.jal <= int_op.jal;
		int_bcu_i.jalr <= int_op.jalr;
		int_bcu_i.branch <= int_op.branch;
		int_bcu_i.branch_op <= int_op.branch_op;

		jump := int_bcu_o.jump;

		int_agu_i.pc <= pc;
		int_agu_i.rs1 <= rs1;
		int_agu_i.imm <= imm;
		int_agu_i.load <= load;
		int_agu_i.store <= store;
		int_agu_i.load_op <= load_op;
		int_agu_i.store_op <= store_op;
		int_agu_i.auipc <= int_op.auipc;
		int_agu_i.jal <= int_op.jal;
		int_agu_i.jalr <= int_op.jalr;
		int_agu_i.branch <= int_op.branch;

		mem_addr := int_agu_o.mem_addr;
		mem_byte := int_agu_o.mem_byte;
		exc := int_agu_o.exc;
		etval := int_agu_o.etval;
		ecause := int_agu_o.ecause;

		int_div_i.data1 <= rs1;
		int_div_i.data2 <= rs2;
		int_div_i.op <= int_op.div_op;
		int_div_i.word <= int_op.word;
		int_div_i.enable <= enable;
		int_div_i.clear <= clear;

		div_ready := int_div_o.ready;
		div_data  := int_div_o.result;

		int_mul_i.data1 <= rs1;
		int_mul_i.data2 <= rs2;
		int_mul_i.op <= int_op.mul_op;
		int_mul_i.word <= int_op.word;
		int_mul_i.enable <= enable;
		int_mul_i.clear <= clear;

		mul_ready := int_mul_o.ready;
		mul_data  := int_mul_o.result;

		if mul_ready = '1' then
			result := mul_data;
			ready  := '1';
		elsif div_ready = '1' then
			result := div_data;
			ready  := '1';
		elsif int_op.mul = '1' then
			ready := '0';
		elsif int_op.div = '1' then
			ready := '0';
		elsif jump = '1' then
			result := npc;
		elsif int_op.alu = '1' then
			result := alu_data;
		elsif int_op.lui = '1' then
			result := imm;
		elsif int_op.auipc = '1' then
			result := mem_addr;
		end if;

		int_pipeline_o.result <= result;
		int_pipeline_o.jump <= jump;
		int_pipeline_o.mem_addr <= mem_addr;
		int_pipeline_o.mem_byte <= mem_byte;
		int_pipeline_o.exc <= exc;
		int_pipeline_o.etval <= etval;
		int_pipeline_o.ecause <= ecause;
		int_pipeline_o.ready <= ready;

	end process;

end architecture;
