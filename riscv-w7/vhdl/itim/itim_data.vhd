-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.itim_wire.all;

entity itim_data is
	generic(
		itim_sets  : integer;
		itim_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		idata_i : in  itim_data_in_type;
		idata_o : out itim_data_out_type
	);
end itim_data;

architecture behavior of itim_data is

	type data_type is array (0 to 2**itim_sets-1) of std_logic_vector((2**itim_words)*64-1 downto 0);

	signal data_array : data_type := (others => (others => '0'));

	signal rdata : std_logic_vector((2**itim_words)*64-1 downto 0) := (others => '0');

begin

	idata_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if idata_i.wen = '1' then
			data_array(idata_i.waddr) <= idata_i.wdata;
		end if;

		rdata <= data_array(idata_i.raddr);

	end if;

	end process;

end architecture;
