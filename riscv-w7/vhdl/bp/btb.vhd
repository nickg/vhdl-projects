-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity btb is
	generic(
		btb_depth : integer := btb_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		btb_i : in  btb_in_type;
		btb_o : out btb_out_type
	);
end btb;

architecture behavior of btb is

	type target_type is array (0 to 2**btb_depth-1) of std_logic_vector(126 - btb_depth  downto 0);

	signal target : target_type := (others => (others => '0'));

begin

	btb_o.rdata <= target(btb_i.raddr);

	process(clock)

	begin

	if rising_edge(clock) then

		if btb_i.wen = '1' then
			target(btb_i.waddr) <= btb_i.wdata;
		end if;

	end if;

	end process;

end architecture;
