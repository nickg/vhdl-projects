-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.dtim_wire.all;

entity dtim_lock is
	generic(
		dtim_sets : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		dlock_i : in  dtim_lock_in_type;
		dlock_o : out dtim_lock_out_type
	);
end dtim_lock;

architecture behavior of dtim_lock is

	type lock_type is array (0 to 2**dtim_sets-1) of std_logic;

	signal lock_array : lock_type := (others => '0');

	signal rdata : std_logic := '0';

begin

	dlock_o.rdata <= rdata;

	process(clock)

	begin

	if rising_edge(clock) then

		if dlock_i.wen = '1' then
			lock_array(dlock_i.waddr) <= dlock_i.wdata;
		end if;

		rdata <= lock_array(dlock_i.raddr);

	end if;

	end process;

end architecture;
