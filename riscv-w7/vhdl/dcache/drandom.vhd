-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.dwire.all;

entity drandom is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset    : in  std_logic;
		clock    : in  std_logic;
		random_i : in  drandom_in_type;
		random_o : out drandom_out_type
	);
end drandom;

architecture behavior of drandom is

	signal count : std_logic_vector(cache_ways downto 1) := (others => '0');

	signal feedback : std_logic := '0';

begin

	COUNT_2 : if cache_ways=1 generate
		feedback <= not(count(1));
	end generate COUNT_2;

	COUNT_4 : if cache_ways=2 generate
		feedback <= not(count(2) xor count(1));
	end generate COUNT_4;

	COUNT_8 : if cache_ways=3 generate
		feedback <= not(count(3) xor count(2));
	end generate COUNT_8;

	COUNT_16 : if cache_ways=4 generate
		feedback <= not(count(4) xor count(3));
	end generate COUNT_16;

	COUNT_32 : if cache_ways=5 generate
		feedback <= not(count(5) xor count(3));
	end generate COUNT_32;

	COUNT_64 : if cache_ways=6 generate
		feedback <= not(count(6) xor count(5));
	end generate COUNT_64;

	COUNT_128 : if cache_ways=7 generate
		feedback <= not(count(7) xor count(6));
	end generate COUNT_128;

	COUNT_256 : if cache_ways=8 generate
		feedback <= not(count(8) xor count(6) xor count(5) xor count(4));
	end generate COUNT_256;

	LOWER : if cache_ways=1 generate

		process(clock)

		begin

			if rising_edge(clock) then

				if reset = reset_active then

					count <= (others => '0');

				else

					if random_i.miss = '1' then
						count <= (others => feedback);
					end if;

				end if;

			end if;

		end process;

	end generate LOWER;

	HIGHER : if cache_ways>1 generate

		process(clock)

		begin

			if rising_edge(clock) then

				if reset = reset_active then

					count <= (others => '0');

				else

					if random_i.miss = '1' then
						count <= count(cache_ways-1 downto 1) & feedback;
					end if;

				end if;

			end if;

		end process;

	end generate HIGHER;

	random_o.wid <= to_integer(unsigned(count(cache_ways downto 1)));

end architecture;
