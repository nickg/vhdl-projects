-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.dwire.all;

entity dirty is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		dirty_i : in  dirty_in_type;
		dirty_o : out dirty_out_type
	);
end dirty;

architecture behavior of dirty is

	type dirty_type is array (0 to 2**cache_sets-1) of std_logic_vector(2**cache_ways-1 downto 0);

	signal dirty_array : dirty_type := (others => (others => '0'));

	signal rdata : std_logic_vector(2**cache_ways-1 downto 0) := (others => '0');

begin

	dirty_o.rdata <= rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if dirty_i.wen = '1' then
				dirty_array(dirty_i.waddr) <= dirty_i.wdata;
			end if;

			rdata <= dirty_array(dirty_i.raddr);

		end if;

	end process;

end architecture;
