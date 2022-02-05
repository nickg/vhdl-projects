-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity bht is
	generic(
		bht_depth : integer := bht_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		bht_i : in  bht_in_type;
		bht_o : out bht_out_type
	);
end bht;

architecture behavior of bht is

	type pattern_type is array (0 to 2**bht_depth-1) of unsigned(1 downto 0);

	signal pattern : pattern_type := (others => (others => '0'));

begin

	bht_o.rdata1 <= pattern(bht_i.raddr1);
	bht_o.rdata2 <= pattern(bht_i.raddr2);

	process(clock)

	begin

	if rising_edge(clock) then

		if bht_i.wen = '1' then
			pattern(bht_i.waddr) <= bht_i.wdata;
		end if;

	end if;

	end process;

end architecture;
