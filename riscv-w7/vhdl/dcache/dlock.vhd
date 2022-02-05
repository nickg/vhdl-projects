-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.dwire.all;

entity dlock is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		dlock_i : in  dlock_in_type;
		dlock_o : out dlock_out_type
	);
end dlock;

architecture behavior of dlock is

	type dlock_type is array (0 to 2**cache_sets-1) of std_logic_vector(2**cache_ways-1 downto 0);

	signal dlock_array : dlock_type := (others => (others => '0'));

	signal rdata : std_logic_vector(2**cache_ways-1 downto 0) := (others => '0');

begin

	dlock_o.rdata <= rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if dlock_i.wen = '1' then
				dlock_array(dlock_i.waddr) <= dlock_i.wdata;
			end if;

			rdata <= dlock_array(dlock_i.raddr);

		end if;

	end process;

end architecture;
