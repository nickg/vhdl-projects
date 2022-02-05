-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bit_constants is

	constant funct3_add    : std_logic_vector(2 downto 0) := "000";
	constant funct3_andn   : std_logic_vector(2 downto 0) := "111";
	constant funct3_bclr   : std_logic_vector(2 downto 0) := "001";
	constant funct3_bext   : std_logic_vector(2 downto 0) := "101";
	constant funct3_binv   : std_logic_vector(2 downto 0) := "001";
	constant funct3_bset   : std_logic_vector(2 downto 0) := "001";
	constant funct3_cmul   : std_logic_vector(2 downto 0) := "001";
	constant funct3_cmulh  : std_logic_vector(2 downto 0) := "011";
	constant funct3_cmulr  : std_logic_vector(2 downto 0) := "010";
	constant funct3_clz    : std_logic_vector(2 downto 0) := "001";
	constant funct3_cpop   : std_logic_vector(2 downto 0) := "001";
	constant funct3_ctz    : std_logic_vector(2 downto 0) := "001";
	constant funct3_max    : std_logic_vector(2 downto 0) := "110";
	constant funct3_maxu   : std_logic_vector(2 downto 0) := "111";
	constant funct3_min    : std_logic_vector(2 downto 0) := "100";
	constant funct3_minu   : std_logic_vector(2 downto 0) := "101";
	constant funct3_orcb   : std_logic_vector(2 downto 0) := "101";
	constant funct3_orn    : std_logic_vector(2 downto 0) := "110";
	constant funct3_rev8   : std_logic_vector(2 downto 0) := "101";
	constant funct3_rol    : std_logic_vector(2 downto 0) := "001";
	constant funct3_ror    : std_logic_vector(2 downto 0) := "101";
	constant funct3_sextb  : std_logic_vector(2 downto 0) := "001";
	constant funct3_sexth  : std_logic_vector(2 downto 0) := "001";
	constant funct3_sh1add : std_logic_vector(2 downto 0) := "010";
	constant funct3_sh2add : std_logic_vector(2 downto 0) := "100";
	constant funct3_sh3add : std_logic_vector(2 downto 0) := "110";
	constant funct3_slli   : std_logic_vector(2 downto 0) := "001";
	constant funct3_xnor   : std_logic_vector(2 downto 0) := "100";
	constant funct3_zexth  : std_logic_vector(2 downto 0) := "100";

	constant funct12_orcb  : std_logic_vector(11 downto 0) := "001010000111";
	constant funct12_rev8  : std_logic_vector(11 downto 0) := "011010111000";

	constant funct7_add    : std_logic_vector(6 downto 0) := "0000100";
	constant funct7_andn   : std_logic_vector(6 downto 0) := "0100000";
	constant funct7_bclr   : std_logic_vector(6 downto 0) := "0100100";
	constant funct7_bext   : std_logic_vector(6 downto 0) := "0100100";
	constant funct7_binv   : std_logic_vector(6 downto 0) := "0110100";
	constant funct7_bset   : std_logic_vector(6 downto 0) := "0010100";
	constant funct7_cmul   : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_cmulh  : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_cmulr  : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_clz    : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_cpop   : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_ctz    : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_max    : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_maxu   : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_min    : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_minu   : std_logic_vector(6 downto 0) := "0000101";
	constant funct7_orn    : std_logic_vector(6 downto 0) := "0100000";
	constant funct7_rol    : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_ror    : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_sextb  : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_sexth  : std_logic_vector(6 downto 0) := "0110000";
	constant funct7_sh1add : std_logic_vector(6 downto 0) := "0010000";
	constant funct7_sh2add : std_logic_vector(6 downto 0) := "0010000";
	constant funct7_sh3add : std_logic_vector(6 downto 0) := "0010000";
	constant funct7_xnor   : std_logic_vector(6 downto 0) := "0100000";
	constant funct7_zexth  : std_logic_vector(6 downto 0) := "0000100";

	constant funct6_bclri  : std_logic_vector(5 downto 0) := "010010";
	constant funct6_bexti  : std_logic_vector(5 downto 0) := "010010";
	constant funct6_binvi  : std_logic_vector(5 downto 0) := "011010";
	constant funct6_bseti  : std_logic_vector(5 downto 0) := "001010";
	constant funct6_rori   : std_logic_vector(5 downto 0) := "011000";
	constant funct6_slli   : std_logic_vector(5 downto 0) := "000010";

	constant funct5_clz    : std_logic_vector(4 downto 0) := "00000";
	constant funct5_cpop   : std_logic_vector(4 downto 0) := "00010";
	constant funct5_ctz    : std_logic_vector(4 downto 0) := "00001";
	constant funct5_sextb  : std_logic_vector(4 downto 0) := "00100";
	constant funct5_sexth  : std_logic_vector(4 downto 0) := "00101";
	constant funct5_zexth  : std_logic_vector(4 downto 0) := "00000";

	constant opcode_imm    : std_logic_vector(6 downto 0) := "0010011";
	constant opcode_reg    : std_logic_vector(6 downto 0) := "0110011";
	constant opcode_imm_32 : std_logic_vector(6 downto 0) := "0011011";
	constant opcode_reg_32 : std_logic_vector(6 downto 0) := "0111011";

end bit_constants;
