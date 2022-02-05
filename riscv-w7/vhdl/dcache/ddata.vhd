-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.dwire.all;

entity ddata is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		data_i : in  ddata_in_type;
		data_o : out ddata_out_type
	);
end ddata;

architecture behavior of ddata is

	type data_type is array (0 to 2**cache_sets-1) of std_logic_vector((2**cache_words)*64-1 downto 0);

	signal data_array : data_type := (others => (others => '0'));

	signal rdata : std_logic_vector((2**cache_words)*64-1 downto 0) := (others => '0');

begin

	data_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if data_i.wen = '1' then
			data_array(data_i.waddr) <= data_i.wdata;
		end if;

		rdata <= data_array(data_i.raddr);

	end if;

	end process;

end architecture;
