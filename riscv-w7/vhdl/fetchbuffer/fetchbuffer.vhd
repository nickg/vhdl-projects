-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity fetchbuffer is
	generic(
		fetchbuffer_depth : integer := fetchbuffer_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		fbuffer_i : in  fetchbuffer_in_type;
		fbuffer_o : out fetchbuffer_out_type;
		imem_o    : in  mem_out_type;
		imem_i    : out mem_in_type
	);
end fetchbuffer;

architecture behavior of fetchbuffer is

	component fetchram
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			fetchram_i : in  fetchram_in_type;
			fetchram_o : out fetchram_out_type
		);
	end component;

	component fetchctrl
		port(
			reset       : in  std_logic;
			clock       : in  std_logic;
			fetchctrl_i : in  fetchbuffer_in_type;
			fetchctrl_o : out fetchbuffer_out_type;
			fetchram_i  : out fetchram_in_type;
			fetchram_o  : in  fetchram_out_type;
			imem_o      : in  mem_out_type;
			imem_i      : out mem_in_type
		);
	end component;

	signal fetchram_i : fetchram_in_type;
	signal fetchram_o : fetchram_out_type;

begin

	fetchram_comp : fetchram
		port map(
			reset      => reset,
			clock      => clock,
			fetchram_i => fetchram_i,
			fetchram_o => fetchram_o
		);

	fetchctrl_comp : fetchctrl
		port map(
			reset       => reset,
			clock       => clock,
			fetchctrl_i => fbuffer_i,
			fetchctrl_o => fbuffer_o,
			fetchram_i  => fetchram_i,
			fetchram_o  => fetchram_o,
			imem_o      => imem_o,
			imem_i      => imem_i
		);

end architecture;
