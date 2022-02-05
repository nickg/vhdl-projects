-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.comp_constants.all;
use work.int_wire.all;

package comp_wire is

	type comp_decode_in_type is record
		instr     : std_logic_vector(31 downto 0);
	end record;

	type comp_decode_out_type is record
		imm       : std_logic_vector(63 downto 0);
		raddr1    : std_logic_vector(4 downto 0);
		raddr2    : std_logic_vector(4 downto 0);
		waddr     : std_logic_vector(4 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		fpu_rden2 : std_logic;
		fpu_wren  : std_logic;
		load      : std_logic;
		store     : std_logic;
		int       : std_logic;
		fpu       : std_logic;
		csr       : std_logic;
		ebreak    : std_logic;
		int_op    : int_operation_type;
		load_op   : load_operation_type;
		store_op  : store_operation_type;
		valid     : std_logic;
	end record;

	type comp_decode_reg_type is record
		instr     : std_logic_vector(31 downto 0);
		imm       : std_logic_vector(63 downto 0);
		raddr1    : std_logic_vector(4 downto 0);
		raddr2    : std_logic_vector(4 downto 0);
		waddr     : std_logic_vector(4 downto 0);
		imm_lwsp  : std_logic_vector(63 downto 0);
		imm_ldsp  : std_logic_vector(63 downto 0);
		imm_swsp  : std_logic_vector(63 downto 0);
		imm_sdsp  : std_logic_vector(63 downto 0);
		imm_lswr  : std_logic_vector(63 downto 0);
		imm_lsdr  : std_logic_vector(63 downto 0);
		imm_j     : std_logic_vector(63 downto 0);
		imm_b     : std_logic_vector(63 downto 0);
		imm_i     : std_logic_vector(63 downto 0);
		imm_w     : std_logic_vector(63 downto 0);
		imm_u     : std_logic_vector(63 downto 0);
		imm_p     : std_logic_vector(63 downto 0);
		shamt     : std_logic;
		opcode    : std_logic_vector(1 downto 0);
		funct3    : std_logic_vector(2 downto 0);
		funct4    : std_logic;
		funct6    : std_logic_vector(1 downto 0);
		funct8    : std_logic_vector(1 downto 0);
		funct9    : std_logic_vector(2 downto 0);
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		fpu_rden2 : std_logic;
		fpu_wren  : std_logic;
		load      : std_logic;
		store     : std_logic;
		int       : std_logic;
		fpu       : std_logic;
		csr       : std_logic;
		ebreak    : std_logic;
		int_op    : int_operation_type;
		load_op   : load_operation_type;
		store_op  : store_operation_type;
		valid     : std_logic;
	end record;

end package;
