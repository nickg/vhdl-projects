-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_constants.all;
use work.int_types.all;

package int_wire is

	type load_operation_type is record
		mem_lb  : std_logic;
		mem_lbu : std_logic;
		mem_lh  : std_logic;
		mem_lhu : std_logic;
		mem_lw  : std_logic;
		mem_lwu : std_logic;
		mem_ld  : std_logic;
	end record;

	constant init_load_operation : load_operation_type := (
		mem_lb  => '0',
		mem_lbu => '0',
		mem_lh  => '0',
		mem_lhu => '0',
		mem_lw  => '0',
		mem_lwu => '0',
		mem_ld  => '0'
	);

	type store_operation_type is record
		mem_sb : std_logic;
		mem_sh : std_logic;
		mem_sw : std_logic;
		mem_sd : std_logic;
	end record;

	constant init_store_operation : store_operation_type := (
		mem_sb => '0',
		mem_sh => '0',
		mem_sw => '0',
		mem_sd => '0'
	);

	type alu_operation_type is record
		alu_add  : std_logic;
		alu_sub  : std_logic;
		alu_sll  : std_logic;
		alu_slt  : std_logic;
		alu_sltu : std_logic;
		alu_xor  : std_logic;
		alu_srl  : std_logic;
		alu_sra  : std_logic;
		alu_or   : std_logic;
		alu_and  : std_logic;
	end record;

	constant init_alu_operation : alu_operation_type := (
		alu_add  => '0',
		alu_sub  => '0',
		alu_sll  => '0',
		alu_slt  => '0',
		alu_sltu => '0',
		alu_xor  => '0',
		alu_srl  => '0',
		alu_sra  => '0',
		alu_or   => '0',
		alu_and  => '0'
	);

	type mul_operation_type is record
		alu_mul    : std_logic;
		alu_mulh   : std_logic;
		alu_mulhsu : std_logic;
		alu_mulhu  : std_logic;
	end record;

	constant init_mul_operation : mul_operation_type := (
		alu_mul    => '0',
		alu_mulh   => '0',
		alu_mulhsu => '0',
		alu_mulhu  => '0'
	);

	type div_operation_type is record
		alu_div  : std_logic;
		alu_divu : std_logic;
		alu_rem  : std_logic;
		alu_remu : std_logic;
	end record;

	constant init_div_operation : div_operation_type := (
		alu_div  => '0',
		alu_divu => '0',
		alu_rem  => '0',
		alu_remu => '0'
	);

	type branch_operation_type is record
		beq  : std_logic;
		bne  : std_logic;
		blt  : std_logic;
		bge  : std_logic;
		bltu : std_logic;
		bgeu : std_logic;
	end record;

	constant init_branch_operation : branch_operation_type := (
		beq  => '0',
		bne  => '0',
		blt  => '0',
		bge  => '0',
		bltu => '0',
		bgeu => '0'
	);

	type int_operation_type is record
		lui       : std_logic;
		auipc     : std_logic;
		jal       : std_logic;
		jalr      : std_logic;
		branch    : std_logic;
		word      : std_logic;
		alu       : std_logic;
		div       : std_logic;
		mul       : std_logic;
		mcycle    : std_logic;
		alu_imm   : std_logic;
		alu_op    : alu_operation_type;
		mul_op    : mul_operation_type;
		div_op    : div_operation_type;
		branch_op : branch_operation_type;
	end record;

	constant init_int_operation : int_operation_type := (
		lui       => '0',
		auipc     => '0',
		jal       => '0',
		jalr      => '0',
		branch    => '0',
		word      => '0',
		alu       => '0',
		div       => '0',
		mul       => '0',
		mcycle    => '0',
		alu_imm   => '0',
		alu_op    => init_alu_operation,
		mul_op    => init_mul_operation,
		div_op    => init_div_operation,
		branch_op => init_branch_operation
	);

	type int_decode_in_type is record
		instr : std_logic_vector(31 downto 0);
	end record;

	type int_decode_out_type is record
		imm       : std_logic_vector(63 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		csr_rden  : std_logic;
		csr_wren  : std_logic;
		load      : std_logic;
		store     : std_logic;
		int       : std_logic;
		int_op    : int_operation_type;
		load_op   : load_operation_type;
		store_op  : store_operation_type;
		csr       : std_logic;
		ecall     : std_logic;
		ebreak    : std_logic;
		mret      : std_logic;
		wfi       : std_logic;
		fence     : std_logic;
		valid     : std_logic;
	end record;

	type int_decode_reg_type is record
		instr     : std_logic_vector(31 downto 0);
		imm       : std_logic_vector(63 downto 0);
		imm_csr   : std_logic_vector(63 downto 0);
		imm_c     : std_logic_vector(63 downto 0);
		imm_i     : std_logic_vector(63 downto 0);
		imm_s     : std_logic_vector(63 downto 0);
		imm_b     : std_logic_vector(63 downto 0);
		imm_u     : std_logic_vector(63 downto 0);
		imm_j     : std_logic_vector(63 downto 0);
		opcode    : std_logic_vector(6 downto 0);
		funct3    : std_logic_vector(2 downto 0);
		funct7    : std_logic_vector(6 downto 0);
		rm        : std_logic_vector(2 downto 0);
		csr_addr  : std_logic_vector(11 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		csr_rden  : std_logic;
		csr_wren  : std_logic;
		load      : std_logic;
		store     : std_logic;
		int       : std_logic;
		int_op    : int_operation_type;
		load_op   : load_operation_type;
		store_op  : store_operation_type;
		csr       : std_logic;
		ecall     : std_logic;
		ebreak    : std_logic;
		mret      : std_logic;
		wfi       : std_logic;
		fence     : std_logic;
		valid     : std_logic;
	end record;

	type int_register_read_in_type is record
		rden1  : std_logic;
		raddr1 : std_logic_vector(4 downto 0);
		rden2  : std_logic;
		raddr2 : std_logic_vector(4 downto 0);
	end record;

	type int_register_write_in_type is record
		wren  : std_logic;
		waddr : std_logic_vector(4 downto 0);
		wdata : std_logic_vector(63 downto 0);
	end record;

	type int_register_out_type is record
		data1 : std_logic_vector(63 downto 0);
		data2 : std_logic_vector(63 downto 0);
	end record;

	type int_forward_in_type is record
		reg_en1   : std_logic;
		reg_addr1 : std_logic_vector(4 downto 0);
		reg_data1 : std_logic_vector(63 downto 0);
		reg_en2   : std_logic;
		reg_addr2 : std_logic_vector(4 downto 0);
		reg_data2 : std_logic_vector(63 downto 0);
		exe_en    : std_logic;
		exe_addr  : std_logic_vector(4 downto 0);
		exe_data  : std_logic_vector(63 downto 0);
		mem_en    : std_logic;
		mem_addr  : std_logic_vector(4 downto 0);
		mem_data  : std_logic_vector(63 downto 0);
	end record;

	type int_forward_out_type is record
		data1 : std_logic_vector(63 downto 0);
		data2 : std_logic_vector(63 downto 0);
	end record;

	type int_alu_in_type is record
		rs1    : std_logic_vector(63 downto 0);
		rs2    : std_logic_vector(63 downto 0);
		imm    : std_logic_vector(63 downto 0);
		alu_op : alu_operation_type;
		word   : std_logic;
		sel    : std_logic;
	end record;

	type int_alu_out_type is record
		res : std_logic_vector(63 downto 0);
	end record;

	type int_bcu_in_type is record
		rs1       : std_logic_vector(63 downto 0);
		rs2       : std_logic_vector(63 downto 0);
		jal       : std_logic;
		jalr      : std_logic;
		branch    : std_logic;
		branch_op : branch_operation_type;
	end record;

	type int_bcu_out_type is record
		jump : std_logic;
	end record;

	type int_agu_in_type is record
		pc       : std_logic_vector(63 downto 0);
		rs1      : std_logic_vector(63 downto 0);
		imm      : std_logic_vector(63 downto 0);
		load     : std_logic;
		store    : std_logic;
		load_op  : load_operation_type;
		store_op : store_operation_type;
		auipc    : std_logic;
		jal      : std_logic;
		jalr     : std_logic;
		branch   : std_logic;
	end record;

	type int_agu_out_type is record
		mem_addr : std_logic_vector(63 downto 0);
		mem_byte : std_logic_vector(7 downto 0);
		exc      : std_logic;
		etval    : std_logic_vector(63 downto 0);
		ecause   : std_logic_vector(3 downto 0);
	end record;

	type int_mul_in_type is record
		data1  : std_logic_vector(63 downto 0);
		data2  : std_logic_vector(63 downto 0);
		op     : mul_operation_type;
		word   : std_logic;
		enable : std_logic;
		clear  : std_logic;
	end record;

	type int_mul_out_type is record
		result : std_logic_vector(63 downto 0);
		ready  : std_logic;
	end record;

	type int_mul_reg_type_1 is record
		op    : mul_operation_type;
		word  : std_logic;
		neg   : std_logic;
		aa    : std_logic_vector(63 downto 0);
		bb    : std_logic_vector(63 downto 0);
		ready : std_logic;
	end record;

	constant init_int_mul_reg_1 : int_mul_reg_type_1 := (
		op    => init_mul_operation,
		word  => '0',
		neg   => '0',
		aa    => (others => '0'),
		bb    => (others => '0'),
		ready => '0'
	);

	type int_mul_reg_type_2 is record
		op    : mul_operation_type;
		word  : std_logic;
		neg   : std_logic;
		rr    : std_logic_vector(127 downto 0);
		ready : std_logic;
	end record;

	constant init_int_mul_reg_2 : int_mul_reg_type_2 := (
		op    => init_mul_operation,
		word  => '0',
		neg   => '0',
		rr    => (others => '0'),
		ready => '0'
	);

	type int_mul_reg_type is record
		state   : mul_state_type;
		counter : natural range 0 to 63;
		op      : mul_operation_type;
		word    : std_logic;
		neg     : std_logic;
		aa      : std_logic_vector(63 downto 0);
		bb      : std_logic_vector(63 downto 0);
		rr      : std_logic_vector(127 downto 0);
		result  : std_logic_vector(63 downto 0);
		ready   : std_logic;
	end record;

	constant init_int_mul_reg : int_mul_reg_type := (
		state   => MUL0,
		counter => 0,
		op      => init_mul_operation,
		word    => '0',
		neg     => '0',
		aa      => (others => '0'),
		bb      => (others => '0'),
		rr      => (others => '0'),
		result  => (others => '0'),
		ready   => '0'
	);

	type int_div_in_type is record
		data1  : std_logic_vector(63 downto 0);
		data2  : std_logic_vector(63 downto 0);
		op     : div_operation_type;
		word   : std_logic;
		enable : std_logic;
		clear  : std_logic;
	end record;

	type int_div_out_type is record
		result : std_logic_vector(63 downto 0);
		ready  : std_logic;
	end record;

	type int_div_reg_type is record
		state     : div_state_type;
		counter   : natural range 0 to 63;
		dividend  : std_logic_vector(63 downto 0);
		op        : div_operation_type;
		word      : std_logic;
		data1     : std_logic_vector(63 downto 0);
		data2     : std_logic_vector(63 downto 0);
		aq        : std_logic_vector(128 downto 0);
		a         : std_logic_vector(64 downto 0);
		m         : std_logic_vector(64 downto 0);
		divbyzero : std_logic;
		overflow  : std_logic;
		negdiv    : std_logic;
		negrem    : std_logic;
		update    : std_logic;
		result    : std_logic_vector(63 downto 0);
		ready     : std_logic;
	end record;

	constant init_int_div_reg : int_div_reg_type := (
		state     => DIV0,
		counter   => 0,
		dividend  => (others => '0'),
		op        => init_div_operation,
		word      => '0',
		data1     => (others => '0'),
		data2     => (others => '0'),
		aq        => (others => '0'),
		a         => (others => '0'),
		m         => (others => '0'),
		divbyzero => '0',
		overflow  => '0',
		negdiv    => '0',
		negrem    => '0',
		update    => '0',
		result    => (others => '0'),
		ready     => '0'
	);

	type int_pipeline_in_type is record
		pc       : std_logic_vector(63 downto 0);
		npc      : std_logic_vector(63 downto 0);
		rs1      : std_logic_vector(63 downto 0);
		rs2      : std_logic_vector(63 downto 0);
		imm      : std_logic_vector(63 downto 0);
		funct    : std_logic_vector(2 downto 0);
		load     : std_logic;
		store    : std_logic;
		load_op  : load_operation_type;
		store_op : store_operation_type;
		int_op   : int_operation_type;
		enable   : std_logic;
		clear    : std_logic;
	end record;

	type int_pipeline_out_type is record
		result   : std_logic_vector(63 downto 0);
		jump     : std_logic;
		mem_addr : std_logic_vector(63 downto 0);
		mem_byte : std_logic_vector(7 downto 0);
		exc      : std_logic;
		etval    : std_logic_vector(63 downto 0);
		ecause   : std_logic_vector(3 downto 0);
		ready    : std_logic;
	end record;

	type int_unit_in_type is record
		int_decode_i   : int_decode_in_type;
		int_reg_ri     : int_register_read_in_type;
		int_reg_wi     : int_register_write_in_type;
		int_for_i      : int_forward_in_type;
		int_pipeline_i : int_pipeline_in_type;
	end record;

	type int_unit_out_type is record
		int_decode_o   : int_decode_out_type;
		int_reg_o      : int_register_out_type;
		int_for_o      : int_forward_out_type;
		int_pipeline_o : int_pipeline_out_type;
	end record;

end package;
