-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_wire.all;

package atom_wire is

	type atom_operation_type is record
		atom_word    : std_logic;
		atom_rl      : std_logic;
		atom_aq      : std_logic;
		atom_lr      : std_logic;
		atom_sc      : std_logic;
		atom_amoswap : std_logic;
		atom_amoadd  : std_logic;
		atom_amoxor  : std_logic;
		atom_amoand  : std_logic;
		atom_amoor   : std_logic;
		atom_amomin  : std_logic;
		atom_amomax  : std_logic;
		atom_amominu : std_logic;
		atom_amomaxu : std_logic;
	end record;

	constant init_atom_operation : atom_operation_type := (
		atom_word    => '0',
		atom_rl      => '0',
		atom_aq      => '0',
		atom_lr      => '0',
		atom_sc      => '0',
		atom_amoswap => '0',
		atom_amoadd  => '0',
		atom_amoxor  => '0',
		atom_amoand  => '0',
		atom_amoor   => '0',
		atom_amomin  => '0',
		atom_amomax  => '0',
		atom_amominu => '0',
		atom_amomaxu => '0'
	);

	type atom_decode_in_type is record
		instr : std_logic_vector(31 downto 0);
	end record;

	type atom_decode_out_type is record
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		load      : std_logic;
		store     : std_logic;
		ldst      : std_logic;
		atom_op   : atom_operation_type;
		load_op   : load_operation_type;
		store_op  : store_operation_type;
		valid     : std_logic;
	end record;

	type atom_decode_reg_type is record
		instr     : std_logic_vector(31 downto 0);
		opcode    : std_logic_vector(6 downto 0);
		funct3    : std_logic_vector(2 downto 0);
		funct5    : std_logic_vector(4 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		load      : std_logic;
		store     : std_logic;
		ldst      : std_logic;
		atom_op   : atom_operation_type;
		load_op   : load_operation_type;
		store_op  : store_operation_type;
		valid     : std_logic;
	end record;

	type atom_alu_in_type is record
		lval    : std_logic_vector(63 downto 0);
		rs2     : std_logic_vector(63 downto 0);
		atom_op : atom_operation_type;
	end record;

	type atom_alu_out_type is record
		res : std_logic_vector(63 downto 0);
	end record;

	type atom_agu_in_type is record
		rs1     : std_logic_vector(63 downto 0);
		load    : std_logic;
		store   : std_logic;
		atom_op : atom_operation_type;
		atom    : std_logic;
	end record;

	type atom_agu_out_type is record
		mem_addr : std_logic_vector(63 downto 0);
		mem_byte : std_logic_vector(7 downto 0);
		exc      : std_logic;
		etval    : std_logic_vector(63 downto 0);
		ecause   : std_logic_vector(3 downto 0);
	end record;

end atom_wire;
