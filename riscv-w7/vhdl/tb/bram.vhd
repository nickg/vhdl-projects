-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.configure.all;
use work.functions.all;
use work.wire.all;

library std;
use std.textio.all;
use std.env.all;

entity bram is
	generic(
		bram_depth   : integer := bram_depth;
		bram_latency : integer := bram_latency
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		mem_i : in  mem_in_type;
		mem_o : out mem_out_type
	);
end bram;

architecture behavior of bram is

	type memory_type is array (0 to 2**bram_depth-1) of std_logic_vector(63 downto 0);

	impure function init_memory(
		file_name : in string
	)
	return memory_type is
		file memory_file      : text open read_mode is file_name;
		variable memory_line  : line;
		variable memory_block : memory_type;
	begin
		for i in 0 to 2**bram_depth-1 loop
			readline(memory_file, memory_line);
			hread(memory_line, memory_block(i));
		end loop;
		return memory_block;
	end function;

	signal memory_block : memory_type := init_memory("bram.dat");

	attribute ram_style : string;
	attribute ram_style of memory_block : signal is "block";

	signal rdata : std_logic_vector(63 downto 0) := (others => '0');
	signal ready : std_logic := '0';

	signal latency : integer := 0;

begin

	mem_o.mem_flush <= '0';
	mem_o.mem_error <= '0';
	mem_o.mem_busy <= '0';
	mem_o.mem_rdata <= rdata;
	mem_o.mem_ready <= ready;

	process(clock)
		variable maddr : natural range 0 to 2**bram_depth-1;
	begin
		if rising_edge(clock) then

			if latency = bram_latency then

				latency <= 0;

				if mem_i.mem_valid = '1' then

					maddr := to_integer(unsigned(mem_i.mem_addr(27 downto 3)));

					if mem_i.mem_write = '1' then

						if mem_i.mem_strb(7) = '1' then
							memory_block(maddr)(63 downto 56) <= mem_i.mem_wdata(63 downto 56);
						end if;
						if mem_i.mem_strb(6) = '1' then
							memory_block(maddr)(55 downto 48) <= mem_i.mem_wdata(55 downto 48);
						end if;
						if mem_i.mem_strb(5) = '1' then
							memory_block(maddr)(47 downto 40) <= mem_i.mem_wdata(47 downto 40);
						end if;
						if mem_i.mem_strb(4) = '1' then
							memory_block(maddr)(39 downto 32) <= mem_i.mem_wdata(39 downto 32);
						end if;
						if mem_i.mem_strb(3) = '1' then
							memory_block(maddr)(31 downto 24) <= mem_i.mem_wdata(31 downto 24);
						end if;
						if mem_i.mem_strb(2) = '1' then
							memory_block(maddr)(23 downto 16) <= mem_i.mem_wdata(23 downto 16);
						end if;
						if mem_i.mem_strb(1) = '1' then
							memory_block(maddr)(15 downto 8) <= mem_i.mem_wdata(15 downto 8);
						end if;
						if mem_i.mem_strb(0) = '1' then
							memory_block(maddr)(7 downto 0) <= mem_i.mem_wdata(7 downto 0);
						end if;

					end if;

					rdata <= memory_block(maddr);
					ready <= '1';

				else

					ready <= '0';

				end if;

			else

				latency <= latency + 1;
				ready <= '0';

			end if;

		end if;

	end process;

end architecture;
