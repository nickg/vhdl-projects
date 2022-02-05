-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity storeram is
	generic(
		storebuffer_depth : integer := storebuffer_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		storeram_i : in  storeram_in_type;
		storeram_o : out storeram_out_type
	);
end storeram;

architecture behavior of storeram is

	type ram_type is array (0 to 2**storebuffer_depth-1) of std_logic_vector(136 downto 0);

	signal store_ram : ram_type := (others => (others => '0'));

begin

	storeram_o.rdata <= store_ram(storeram_i.raddr);

	process(clock)

	begin

		if rising_edge(clock) then

			if storeram_i.wren = '1' then
				store_ram(storeram_i.waddr) <= storeram_i.wdata;
			end if;

		end if;

	end process;


end architecture;
