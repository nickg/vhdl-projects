-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.reservation_wire.all;

entity reservation_set is
	generic(
		reservation_depth : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		set_i : in  set_in_type;
		set_o : out set_out_type
	);
end reservation_set;

architecture behavior of reservation_set is

	type set_type is array (0 to 2**reservation_depth-1) of std_logic_vector(7 downto 0);

	signal set_array : set_type := (others => (others => '0'));

begin

	set_o.rdata <= set_array(set_i.raddr);

	process(clock)

	begin

	if rising_edge(clock) then

		if set_i.wen = '1' then
			set_array(set_i.waddr) <= set_i.wdata;
		end if;

	end if;

	end process;

end architecture;
