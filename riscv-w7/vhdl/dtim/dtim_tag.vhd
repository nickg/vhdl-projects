-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.dtim_wire.all;

entity dtim_tag is
	generic(
		dtim_sets : integer;
		dtim_words : integer
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		dtag_i : in  dtim_tag_in_type;
		dtag_o : out dtim_tag_out_type
	);
end dtim_tag;

architecture behavior of dtim_tag is

	type tag_type is array (0 to 2**dtim_sets-1) of std_logic_vector(60-(dtim_sets+dtim_words) downto 0);

	signal tag_array : tag_type := (others => (others => '0'));

	signal rdata : std_logic_vector(60-(dtim_sets+dtim_words) downto 0) := (others => '0');

begin

	dtag_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if dtag_i.wen = '1' then
			tag_array(dtag_i.waddr) <= dtag_i.wdata;
		end if;

		rdata <= tag_array(dtag_i.raddr);

	end if;

	end process;

end architecture;
