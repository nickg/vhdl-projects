-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity ras is
	generic(
		ras_depth : integer := ras_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		ras_i : in  ras_in_type;
		ras_o : out ras_out_type
	);
end ras;

architecture behavior of ras is

	type stack_type is array (0 to 2**ras_depth-1) of std_logic_vector(63 downto 0);

	signal stack : stack_type := (others => (others => '0'));

begin

	ras_o.rdata <= stack(ras_i.raddr);

	process(clock)

	begin

	if rising_edge(clock) then

		if ras_i.wen = '1' then
			stack(ras_i.waddr) <= ras_i.wdata;
		end if;

	end if;

	end process;

end architecture;
