-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.dtim_wire.all;

entity dtim_valid is
	generic(
		dtim_sets : integer
	);
	port(
		reset    : in  std_logic;
		clock    : in  std_logic;
		dvalid_i : in  dtim_valid_in_type;
		dvalid_o : out dtim_valid_out_type
	);
end dtim_valid;

architecture behavior of dtim_valid is

	type valid_type is array (0 to 2**dtim_sets-1) of std_logic;

	signal valid_array : valid_type := (others => '0');

	signal rdata : std_logic := '0';

begin

	dvalid_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if dvalid_i.wen = '1' then
			valid_array(dvalid_i.waddr) <= dvalid_i.wdata;
		end if;

		rdata <= valid_array(dvalid_i.raddr);

	end if;

	end process;

end architecture;
