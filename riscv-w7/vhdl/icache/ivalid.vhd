-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.iwire.all;

entity ivalid is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		valid_i : in  ivalid_in_type;
		valid_o : out ivalid_out_type
	);
end ivalid;

architecture behavior of ivalid is

	type valid_type is array (0 to 2**cache_sets-1) of std_logic_vector(2**cache_ways-1 downto 0);

	signal valid_array : valid_type := (others => (others => '0'));

	signal rdata : std_logic_vector(2**cache_ways-1 downto 0) := (others => '0');

begin

	valid_o.rdata <= rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if valid_i.wen = '1' then
				valid_array(valid_i.waddr) <= valid_i.wdata;
			end if;

			rdata <= valid_array(valid_i.raddr);

		end if;

	end process;

end architecture;
