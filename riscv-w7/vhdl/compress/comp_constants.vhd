-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package comp_constants is

	constant c0_addispn : std_logic_vector(2 downto 0) := "000";
	constant c0_fld     : std_logic_vector(2 downto 0) := "001";
	constant c0_lw      : std_logic_vector(2 downto 0) := "010";
	constant c0_ld      : std_logic_vector(2 downto 0) := "011";
	constant c0_fsd     : std_logic_vector(2 downto 0) := "101";
	constant c0_sw      : std_logic_vector(2 downto 0) := "110";
	constant c0_sd      : std_logic_vector(2 downto 0) := "111";

	constant c1_addi  : std_logic_vector(2 downto 0) := "000";
	constant c1_addiw : std_logic_vector(2 downto 0) := "001";
	constant c1_li    : std_logic_vector(2 downto 0) := "010";
	constant c1_lui   : std_logic_vector(2 downto 0) := "011";
	constant c1_alu   : std_logic_vector(2 downto 0) := "100";
	constant c1_jal   : std_logic_vector(2 downto 0) := "101";
	constant c1_beqz  : std_logic_vector(2 downto 0) := "110";
	constant c1_bnez  : std_logic_vector(2 downto 0) := "111";

	constant c2_slli  : std_logic_vector(2 downto 0) := "000";
	constant c2_fldsp : std_logic_vector(2 downto 0) := "001";
	constant c2_lwsp  : std_logic_vector(2 downto 0) := "010";
	constant c2_ldsp  : std_logic_vector(2 downto 0) := "011";
	constant c2_alu   : std_logic_vector(2 downto 0) := "100";
	constant c2_fsdsp : std_logic_vector(2 downto 0) := "101";
	constant c2_swsp  : std_logic_vector(2 downto 0) := "110";
	constant c2_sdsp  : std_logic_vector(2 downto 0) := "111";

	constant opcode_c0 : std_logic_vector(1 downto 0) := "00";
	constant opcode_c1 : std_logic_vector(1 downto 0) := "01";
	constant opcode_c2 : std_logic_vector(1 downto 0) := "10";

end comp_constants;
