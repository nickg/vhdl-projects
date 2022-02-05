-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.dtim_wire.all;

entity dtim_data is
	generic(
		dtim_sets : integer;
		dtim_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ddata_i : in  dtim_data_in_type;
		ddata_o : out dtim_data_out_type
	);
end dtim_data;

architecture behavior of dtim_data is

	type data_type is array (0 to 2**dtim_sets-1) of std_logic_vector((2**dtim_words)*64-1 downto 0);

	signal data_array : data_type := (others => (others => '0'));

	signal rdata : std_logic_vector((2**dtim_words)*64-1 downto 0) := (others => '0');

begin

	ddata_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if ddata_i.wen = '1' then
			data_array(ddata_i.waddr) <= ddata_i.wdata;
		end if;

		rdata <= data_array(ddata_i.raddr);

	end if;

	end process;

end architecture;
