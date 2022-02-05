-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.reservation_wire.all;

entity reservation_pid is
	generic(
		number_of_cores   : integer;
		reservation_depth : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		pid_i : in  pid_in_type;
		pid_o : out pid_out_type
	);
end reservation_pid;

architecture behavior of reservation_pid is

	type pid_type is array (0 to 2**reservation_depth-1) of integer range 0 to 2**number_of_cores-1;

	signal pid_array : pid_type := (others => 0);

begin

	pid_o.rdata <= pid_array(pid_i.raddr);

	process(clock)

	begin

	if rising_edge(clock) then

		if pid_i.wen = '1' then
			pid_array(pid_i.waddr) <= pid_i.wdata;
		end if;

	end if;

	end process;

end architecture;
