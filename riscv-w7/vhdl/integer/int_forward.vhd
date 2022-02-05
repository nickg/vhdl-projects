-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_constants.all;
use work.int_wire.all;

entity int_forward is
	port(
		int_for_i : in  int_forward_in_type;
		int_for_o : out int_forward_out_type
	);
end int_forward;

architecture behavior of int_forward is

begin

	process(int_for_i)
		variable res1 : std_logic_vector(63 downto 0);
		variable res2 : std_logic_vector(63 downto 0);

	begin
		res1 := (others => '0');
		res2 := (others => '0');

		if int_for_i.reg_en1 = '1' then
			res1 := int_for_i.reg_data1;
			if int_for_i.mem_en = '1' and int_for_i.reg_addr1 = int_for_i.mem_addr then
				res1 := int_for_i.mem_data;
			end if;
			if int_for_i.exe_en = '1' and int_for_i.reg_addr1 = int_for_i.exe_addr then
				res1 := int_for_i.exe_data;
			end if;
		end if;

		if int_for_i.reg_en2 = '1' then
			res2 := int_for_i.reg_data2;
			if int_for_i.mem_en = '1' and int_for_i.reg_addr2 = int_for_i.mem_addr then
				res2 := int_for_i.mem_data;
			end if;
			if int_for_i.exe_en = '1' and int_for_i.reg_addr2 = int_for_i.exe_addr then
				res2 := int_for_i.exe_data;
			end if;
		end if;

		int_for_o.data1 <= res1;
		int_for_o.data2 <= res2;

	end process;

end architecture;
