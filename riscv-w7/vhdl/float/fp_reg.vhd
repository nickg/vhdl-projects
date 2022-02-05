-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_cons.all;
use work.fp_wire.all;

entity fp_reg is
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		fp_reg_ri : in  fp_reg_read_in_type;
		fp_reg_wi : in  fp_reg_write_in_type;
		fp_reg_o  : out fp_reg_out_type
	);
end fp_reg;

architecture behavior of fp_reg is

	type fp_regfile_type is array (0 to 31) of std_logic_vector(63 downto 0);

	signal fp_regfile : fp_regfile_type := (others => (others => '0'));

begin

	process(fp_reg_ri,fp_regfile)

	begin

		if fp_reg_ri.rden1 = '1' then
			fp_reg_o.data1 <= fp_regfile(to_integer(unsigned(fp_reg_ri.raddr1)));
		else
			fp_reg_o.data1 <= (others => '0');
		end if;
		if fp_reg_ri.rden2 = '1' then
			fp_reg_o.data2 <= fp_regfile(to_integer(unsigned(fp_reg_ri.raddr2)));
		else
			fp_reg_o.data2 <= (others => '0');
		end if;
		if fp_reg_ri.rden3 = '1' then
			fp_reg_o.data3 <= fp_regfile(to_integer(unsigned(fp_reg_ri.raddr3)));
		else
			fp_reg_o.data3 <= (others => '0');
		end if;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if fp_reg_wi.wren = '1' then
				fp_regfile(to_integer(unsigned(fp_reg_wi.waddr))) <= fp_reg_wi.wdata;
			end if;

		end if;

	end process;

end architecture;
