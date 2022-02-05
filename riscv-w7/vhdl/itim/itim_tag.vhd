-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.itim_wire.all;

entity itim_tag is
	generic(
		itim_sets  : integer;
		itim_words : integer
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		itag_i : in  itim_tag_in_type;
		itag_o : out itim_tag_out_type
	);
end itim_tag;

architecture behavior of itim_tag is

	type tag_type is array (0 to 2**itim_sets-1) of std_logic_vector(60-(itim_sets+itim_words) downto 0);

	signal tag_array : tag_type := (others => (others => '0'));

	signal rdata : std_logic_vector(60-(itim_sets+itim_words) downto 0) := (others => '0');

begin

	itag_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if itag_i.wen = '1' then
			tag_array(itag_i.waddr) <= itag_i.wdata;
		end if;

		rdata <= tag_array(itag_i.raddr);

	end if;

	end process;

end architecture;
