-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.iwire.all;

entity ihit is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		hit_i : in  ihit_in_type;
		hit_o : out ihit_out_type
	);
end ihit;

architecture behavior of ihit is

begin

	process(hit_i)

	variable valid : std_logic_vector(2**cache_ways-1 downto 0);
	variable wid   : integer range 0 to 2**cache_ways-1;

	begin

		valid := (others => '0');

		for i in 0 to 2**cache_ways-1 loop
			valid(i) := hit_i.valid(i) and and_reduce(hit_i.tag xnor hit_i.tag_a(i));
		end loop;

		hit_o.hit <= or_reduce(valid);
		hit_o.miss <= nor_reduce(valid);

		wid := 0;

		for i in 0 to 2**cache_ways-1 loop
			if valid(i) = '1' then
				wid := i;
				exit;
			end if;
		end loop;

		hit_o.wid <= wid;

	end process;

end architecture;
