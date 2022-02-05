-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package int_constants is

	constant nop           : std_logic_vector(31 downto 0) := x"00000013";

	constant overflow      : std_logic_vector(63 downto 0) := x"FFFFFFFFFFFFFFFF";
	constant overflow_sign : std_logic_vector(63 downto 0) := x"8000000000000000";
	constant zero          : std_logic_vector(63 downto 0) := x"0000000000000000";
	constant one           : std_logic_vector(63 downto 0) := x"0000000000000001";

	constant funct_add     : std_logic_vector(2 downto 0) := "000";
	constant funct_sll     : std_logic_vector(2 downto 0) := "001";
	constant funct_slt     : std_logic_vector(2 downto 0) := "010";
	constant funct_sltu    : std_logic_vector(2 downto 0) := "011";
	constant funct_xor     : std_logic_vector(2 downto 0) := "100";
	constant funct_srl     : std_logic_vector(2 downto 0) := "101";
	constant funct_or      : std_logic_vector(2 downto 0) := "110";
	constant funct_and     : std_logic_vector(2 downto 0) := "111";

	constant funct_mul     : std_logic_vector(2 downto 0) := "000";
	constant funct_mulh    : std_logic_vector(2 downto 0) := "001";
	constant funct_mulhsu  : std_logic_vector(2 downto 0) := "010";
	constant funct_mulhu   : std_logic_vector(2 downto 0) := "011";
	constant funct_div     : std_logic_vector(2 downto 0) := "100";
	constant funct_divu    : std_logic_vector(2 downto 0) := "101";
	constant funct_rem     : std_logic_vector(2 downto 0) := "110";
	constant funct_remu    : std_logic_vector(2 downto 0) := "111";

	constant funct_beq     : std_logic_vector(2 downto 0) := "000";
	constant funct_bne     : std_logic_vector(2 downto 0) := "001";
	constant funct_blt     : std_logic_vector(2 downto 0) := "100";
	constant funct_bge     : std_logic_vector(2 downto 0) := "101";
	constant funct_bltu    : std_logic_vector(2 downto 0) := "110";
	constant funct_bgeu    : std_logic_vector(2 downto 0) := "111";

	constant funct_lb      : std_logic_vector(2 downto 0) := "000";
	constant funct_lh      : std_logic_vector(2 downto 0) := "001";
	constant funct_lw      : std_logic_vector(2 downto 0) := "010";
	constant funct_ld      : std_logic_vector(2 downto 0) := "011";
	constant funct_lbu     : std_logic_vector(2 downto 0) := "100";
	constant funct_lhu     : std_logic_vector(2 downto 0) := "101";
	constant funct_lwu     : std_logic_vector(2 downto 0) := "110";

	constant funct_sb      : std_logic_vector(2 downto 0) := "000";
	constant funct_sh      : std_logic_vector(2 downto 0) := "001";
	constant funct_sw      : std_logic_vector(2 downto 0) := "010";
	constant funct_sd      : std_logic_vector(2 downto 0) := "011";

	constant opcode_lui    : std_logic_vector(6 downto 0) := "0110111";
	constant opcode_auipc  : std_logic_vector(6 downto 0) := "0010111";
	constant opcode_jal    : std_logic_vector(6 downto 0) := "1101111";
	constant opcode_jalr   : std_logic_vector(6 downto 0) := "1100111";
	constant opcode_branch : std_logic_vector(6 downto 0) := "1100011";
	constant opcode_load   : std_logic_vector(6 downto 0) := "0000011";
	constant opcode_store  : std_logic_vector(6 downto 0) := "0100011";
	constant opcode_imm    : std_logic_vector(6 downto 0) := "0010011";
	constant opcode_reg    : std_logic_vector(6 downto 0) := "0110011";
	constant opcode_imm_32 : std_logic_vector(6 downto 0) := "0011011";
	constant opcode_reg_32 : std_logic_vector(6 downto 0) := "0111011";
	constant opcode_fence  : std_logic_vector(6 downto 0) := "0001111";

end int_constants;
