-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_constants.all;
use work.int_wire.all;

entity int_reg_file is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		int_reg_ri : in  int_register_read_in_type;
		int_reg_wi : in  int_register_write_in_type;
		int_reg_o  : out int_register_out_type
	);
end int_reg_file;

architecture behavior of int_reg_file is

	type int_regfile_type is array (0 to 31) of std_logic_vector(63 downto 0);
	signal int_regfile : int_regfile_type := (others => (others => '0'));

begin

	process(int_reg_ri,int_regfile)

	begin

		if int_reg_ri.rden1 = '1' then
			int_reg_o.data1 <= int_regfile(to_integer(unsigned(int_reg_ri.raddr1)));
		else
			int_reg_o.data1 <= (others => '0');
		end if;

		if int_reg_ri.rden2 = '1' then
			int_reg_o.data2 <= int_regfile(to_integer(unsigned(int_reg_ri.raddr2)));
		else
			int_reg_o.data2 <= (others => '0');
		end if;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if int_reg_wi.wren = '1' and int_reg_wi.waddr /= "00000" then
				int_regfile(to_integer(unsigned(int_reg_wi.waddr))) <= int_reg_wi.wdata;
			end if;

		end if;

	end process;

end architecture;
