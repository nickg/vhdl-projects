-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity fetchram is
	generic(
		fetchbuffer_depth : integer := fetchbuffer_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		fetchram_i : in  fetchram_in_type;
		fetchram_o : out fetchram_out_type
	);
end fetchram;

architecture behavior of fetchram is

	type ram_type is array (0 to 2**fetchbuffer_depth-1) of std_logic_vector(63 downto 0);

	signal fetch_ram : ram_type := (others => (others => '1'));

begin

	fetchram_o.rdata1 <= fetch_ram(fetchram_i.raddr1);
	fetchram_o.rdata2 <= fetch_ram(fetchram_i.raddr2);

	process(clock)

	begin

		if rising_edge(clock) then

			if fetchram_i.wren = '1' then
				fetch_ram(fetchram_i.waddr) <= fetchram_i.wdata;
			end if;

		end if;

	end process;


end architecture;
