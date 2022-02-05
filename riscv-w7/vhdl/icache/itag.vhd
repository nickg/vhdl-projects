-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.iwire.all;

entity itag is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		tag_i : in  itag_in_type;
		tag_o : out itag_out_type
	);
end itag;

architecture behavior of itag is

	type tag_type is array (0 to 2**cache_sets-1) of std_logic_vector(60-(cache_sets+cache_words) downto 0);

	signal tag_array : tag_type := (others => (others => '0'));

	signal rdata : std_logic_vector(60-(cache_sets+cache_words) downto 0) := (others => '0');

begin

	tag_o.rdata <= rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if tag_i.wen = '1' then
				tag_array(tag_i.waddr) <= tag_i.wdata;
			end if;

			rdata <= tag_array(tag_i.raddr);

		end if;

	end process;

end architecture;
