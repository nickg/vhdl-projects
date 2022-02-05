-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

library std;
use std.textio.all;
use std.env.all;

entity print is
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		mem_i : in  mem_in_type;
		mem_o : out mem_out_type
	);
end print;

architecture behavior of print is

	signal complete : std_logic := '0';
	signal massage  : string(1 to 511) := (others => character'val(0));
	signal index    : natural range 1 to 511 := 1;

	procedure print_out(
		signal info        : inout string(1 to 511);
		signal counter     : inout natural range 1 to 511;
		signal data        : in std_logic_vector(7 downto 0)) is
		variable buf       : line;
	begin
		if data = X"0A" then
			write(buf, info);
			writeline(output, buf);
			write(buf,integer'image(now/ 1 ns) & " ns");
			writeline(output, buf);
			info <= (others => character'val(0));
			counter <= 1;
		else
			info(counter) <= character'val(to_integer(unsigned(data)));
			counter <= counter + 1;
		end if;
	end procedure print_out;

begin

	mem_o.mem_flush <= '0';
	mem_o.mem_error <= '0';
	mem_o.mem_busy <= '0';
	mem_o.mem_ready <= complete;
	mem_o.mem_rdata <= (others => '0');

	process (clock)

	begin

		if rising_edge(clock) then
			if complete = '0' and mem_i.mem_valid = '1' and or_reduce(mem_i.mem_addr) = '0' and mem_i.mem_write = '1' then
				print_out(massage,index,mem_i.mem_wdata(7 downto 0));
				complete <= '1';
			elsif complete = '1' then
				complete <= '0';
			end if;
		end if;

	end process;

end architecture;
