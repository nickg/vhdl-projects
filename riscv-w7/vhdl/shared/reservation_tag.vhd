-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.reservation_wire.all;

entity reservation_tag is
	generic(
		reservation_depth : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		tag_i : in  tag_in_type;
		tag_o : out tag_out_type
	);
end reservation_tag;

architecture behavior of reservation_tag is

	type tag_type is array (0 to 2**reservation_depth-1) of std_logic_vector(60 downto 0);

	signal tag_array : tag_type := (others => (others => '0'));

begin

	tag_o.rdata <= tag_array(tag_i.raddr);

	process(clock)

	begin

	if rising_edge(clock) then

		if tag_i.wen = '1' then
			tag_array(tag_i.waddr) <= tag_i.wdata;
		end if;

	end if;

	end process;

end architecture;
