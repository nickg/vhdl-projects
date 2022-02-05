-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity storebuffer is
	generic(
		storebuffer_depth : integer := storebuffer_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		sbuffer_i : in  storebuffer_in_type;
		sbuffer_o : out storebuffer_out_type;
		dmem_o    : in  mem_out_type;
		dmem_i    : out mem_in_type
	);
end storebuffer;

architecture behavior of storebuffer is

	component storeram
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			storeram_i : in  storeram_in_type;
			storeram_o : out storeram_out_type
		);
	end component;

	component storectrl
		port(
			reset       : in  std_logic;
			clock       : in  std_logic;
			storectrl_i : in  storebuffer_in_type;
			storectrl_o : out storebuffer_out_type;
			storeram_i  : out storeram_in_type;
			storeram_o  : in  storeram_out_type;
			dmem_o      : in  mem_out_type;
			dmem_i      : out mem_in_type
		);
	end component;

	signal storeram_i : storeram_in_type;
	signal storeram_o : storeram_out_type;

begin

	storeram_comp : storeram
		port map(
			reset      => reset,
			clock      => clock,
			storeram_i => storeram_i,
			storeram_o => storeram_o
		);

	storectrl_comp : storectrl
		port map(
			reset       => reset,
			clock       => clock,
			storectrl_i => sbuffer_i,
			storectrl_o => sbuffer_o,
			storeram_i  => storeram_i,
			storeram_o  => storeram_o,
			dmem_o      => dmem_o,
			dmem_i      => dmem_i
		);

end architecture;
