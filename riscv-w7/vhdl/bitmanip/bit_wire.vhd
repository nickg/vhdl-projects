-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bit_types.all;

package bit_wire is

	type zba_operation_type is record
		bit_add    : std_logic;
		bit_sh1add : std_logic;
		bit_sh2add : std_logic;
		bit_sh3add : std_logic;
		bit_slli   : std_logic;
	end record;

	constant init_zba_operation : zba_operation_type := (
		bit_add    => '0',
		bit_sh1add => '0',
		bit_sh2add => '0',
		bit_sh3add => '0',
		bit_slli   => '0'
	);

	type zbb_operation_type is record
		bit_andn  : std_logic;
		bit_orn   : std_logic;
		bit_xnor  : std_logic;
		bit_clz   : std_logic;
		bit_cpop  : std_logic;
		bit_ctz   : std_logic;
		bit_max   : std_logic;
		bit_maxu  : std_logic;
		bit_min   : std_logic;
		bit_minu  : std_logic;
		bit_orcb  : std_logic;
		bit_rev8  : std_logic;
		bit_rol   : std_logic;
		bit_ror   : std_logic;
		bit_sextb : std_logic;
		bit_sexth : std_logic;
		bit_zexth : std_logic;
	end record;

	constant init_zbb_operation : zbb_operation_type := (
		bit_andn  => '0',
		bit_orn   => '0',
		bit_xnor  => '0',
		bit_clz   => '0',
		bit_cpop  => '0',
		bit_ctz   => '0',
		bit_max   => '0',
		bit_maxu  => '0',
		bit_min   => '0',
		bit_minu  => '0',
		bit_orcb  => '0',
		bit_rev8  => '0',
		bit_rol   => '0',
		bit_ror   => '0',
		bit_sextb => '0',
		bit_sexth => '0',
		bit_zexth => '0'
	);

	type zbc_operation_type is record
		bit_clmul  : std_logic;
		bit_clmulh : std_logic;
		bit_clmulr : std_logic;
	end record;

	constant init_zbc_operation : zbc_operation_type := (
		bit_clmul  => '0',
		bit_clmulh => '0',
		bit_clmulr => '0'
	);

	type zbs_operation_type is record
		bit_bclr : std_logic;
		bit_bext : std_logic;
		bit_binv : std_logic;
		bit_bset : std_logic;
	end record;

	constant init_zbs_operation : zbs_operation_type := (
		bit_bclr => '0',
		bit_bext => '0',
		bit_binv => '0',
		bit_bset => '0'
	);

	type bit_operation_type is record
		bmcycle   : std_logic;
		bit_word  : std_logic;
		bit_imm   : std_logic;
		bit_alu   : std_logic;
		bit_clmul : std_logic;
		bit_zba   : zba_operation_type;
		bit_zbb   : zbb_operation_type;
		bit_zbc   : zbc_operation_type;
		bit_zbs   : zbs_operation_type;
	end record;

	constant init_bit_operation : bit_operation_type := (
		bmcycle   => '0',
		bit_word  => '0',
		bit_imm   => '0',
		bit_alu   => '0',
		bit_clmul => '0',
		bit_zba   => init_zba_operation,
		bit_zbb   => init_zbb_operation,
		bit_zbc   => init_zbc_operation,
		bit_zbs   => init_zbs_operation
	);

	type bit_decode_in_type is record
		instr : std_logic_vector(31 downto 0);
	end record;

	type bit_decode_out_type is record
		imm       : std_logic_vector(63 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		bitm      : std_logic;
		bit_op    : bit_operation_type;
		valid     : std_logic;
	end record;

	type bit_decode_reg_type is record
		instr     : std_logic_vector(31 downto 0);
		imm       : std_logic_vector(63 downto 0);
		imm5      : std_logic_vector(63 downto 0);
		imm6      : std_logic_vector(63 downto 0);
		opcode    : std_logic_vector(6 downto 0);
		funct3    : std_logic_vector(2 downto 0);
		funct5    : std_logic_vector(4 downto 0);
		funct6    : std_logic_vector(5 downto 0);
		funct7    : std_logic_vector(6 downto 0);
		funct12   : std_logic_vector(11 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		bitm      : std_logic;
		bit_op    : bit_operation_type;
		valid     : std_logic;
	end record;

	type bit_alu_in_type is record
		rs1    : std_logic_vector(63 downto 0);
		rs2    : std_logic_vector(63 downto 0);
		imm    : std_logic_vector(63 downto 0);
		bit_op : bit_operation_type;
		word   : std_logic;
		sel    : std_logic;
	end record;

	type bit_alu_out_type is record
		res : std_logic_vector(63 downto 0);
	end record;

	type bit_clmul_in_type is record
		data1  : std_logic_vector(63 downto 0);
		data2  : std_logic_vector(63 downto 0);
		op     : zbc_operation_type;
		word   : std_logic;
		enable : std_logic;
		clear  : std_logic;
	end record;

	type bit_clmul_out_type is record
		result : std_logic_vector(63 downto 0);
		ready  : std_logic;
	end record;

	type bit_clmul_reg_type is record
		state   : clmul_state_type;
		counter : natural range 0 to 63;
		index   : natural range 0 to 127;
		op      : zbc_operation_type;
		data1   : std_logic_vector(63 downto 0);
		data2   : std_logic_vector(63 downto 0);
		swap    : std_logic_vector(63 downto 0);
		result  : std_logic_vector(63 downto 0);
		ready   : std_logic;
	end record;

	constant init_bit_clmul_reg : bit_clmul_reg_type := (
		state   => CLMUL0,
		counter => 0,
		index   => 0,
		op      => init_zbc_operation,
		data1   => (others => '0'),
		data2   => (others => '0'),
		swap    => (others => '0'),
		result  => (others => '0'),
		ready   => '0'
	);

	type bit_pipeline_in_type is record
		rs1      : std_logic_vector(63 downto 0);
		rs2      : std_logic_vector(63 downto 0);
		imm      : std_logic_vector(63 downto 0);
		bit_op   : bit_operation_type;
		enable   : std_logic;
		clear    : std_logic;
	end record;

	type bit_pipeline_out_type is record
		result   : std_logic_vector(63 downto 0);
		ready    : std_logic;
	end record;

	type bit_unit_in_type is record
		bit_decode_i   : bit_decode_in_type;
		bit_pipeline_i : bit_pipeline_in_type;
	end record;

	type bit_unit_out_type is record
		bit_decode_o   : bit_decode_out_type;
		bit_pipeline_o : bit_pipeline_out_type;
	end record;

end bit_wire;
