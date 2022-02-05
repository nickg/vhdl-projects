-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.itim_wire.all;

entity itim_lock is
	generic(
		itim_sets : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ilock_i : in  itim_lock_in_type;
		ilock_o : out itim_lock_out_type
	);
end itim_lock;

architecture behavior of itim_lock is

	type lock_type is array (0 to 2**itim_sets-1) of std_logic;

	signal lock_array : lock_type := (others => '0');

	signal rdata : std_logic := '0';

begin

	ilock_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if ilock_i.wen = '1' then
			lock_array(ilock_i.waddr) <= ilock_i.wdata;
		end if;

		rdata <= lock_array(ilock_i.raddr);

	end if;

	end process;

end architecture;
