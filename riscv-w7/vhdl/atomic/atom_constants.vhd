-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package atom_constants is

	constant funct3_32 : std_logic_vector(2 downto 0) := "010";
	constant funct3_64 : std_logic_vector(2 downto 0) := "011";

	constant funct5_lr      : std_logic_vector(4 downto 0) := "00010";
	constant funct5_sc      : std_logic_vector(4 downto 0) := "00011";
	constant funct5_amoswap : std_logic_vector(4 downto 0) := "00001";
	constant funct5_amoadd  : std_logic_vector(4 downto 0) := "00000";
	constant funct5_amoxor  : std_logic_vector(4 downto 0) := "00100";
	constant funct5_amoand  : std_logic_vector(4 downto 0) := "01100";
	constant funct5_amoor   : std_logic_vector(4 downto 0) := "01000";
	constant funct5_amomin  : std_logic_vector(4 downto 0) := "10000";
	constant funct5_amomax  : std_logic_vector(4 downto 0) := "10100";
	constant funct5_amominu : std_logic_vector(4 downto 0) := "11000";
	constant funct5_amomaxu : std_logic_vector(4 downto 0) := "11100";

	constant opcode_atomic : std_logic_vector(6 downto 0) := "0101111";

end atom_constants;
