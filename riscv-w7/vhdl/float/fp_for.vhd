-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_cons.all;
use work.fp_wire.all;

entity fp_for is
	port(
		fp_for_i : in  fp_for_in_type;
		fp_for_o : out fp_for_out_type
	);
end fp_for;

architecture behavior of fp_for is

begin

	process(fp_for_i)
		variable res1 : std_logic_vector(63 downto 0);
		variable res2 : std_logic_vector(63 downto 0);
		variable res3 : std_logic_vector(63 downto 0);

	begin
		res1 := (others => '0');
		res2 := (others => '0');
		res3 := (others => '0');

		if fp_for_i.reg_en1 = '1' then
			res1 := fp_for_i.reg_data1;
			if fp_for_i.mem_en = '1' and fp_for_i.reg_addr1 = fp_for_i.mem_addr then
				res1 := fp_for_i.mem_data;
			end if;
			if fp_for_i.exe_en = '1' and fp_for_i.reg_addr1 = fp_for_i.exe_addr then
				res1 := fp_for_i.exe_data;
			end if;
		end if;

		if fp_for_i.reg_en2 = '1' then
			res2 := fp_for_i.reg_data2;
			if fp_for_i.mem_en = '1' and fp_for_i.reg_addr2 = fp_for_i.mem_addr then
				res2 := fp_for_i.mem_data;
			end if;
			if fp_for_i.exe_en = '1' and fp_for_i.reg_addr2 = fp_for_i.exe_addr then
				res2 := fp_for_i.exe_data;
			end if;
		end if;

		if fp_for_i.reg_en3 = '1' then
			res3 := fp_for_i.reg_data3;
			if fp_for_i.mem_en = '1' and fp_for_i.reg_addr3 = fp_for_i.mem_addr then
				res3 := fp_for_i.mem_data;
			end if;
			if fp_for_i.exe_en = '1' and fp_for_i.reg_addr3 = fp_for_i.exe_addr then
				res3 := fp_for_i.exe_data;
			end if;
		end if;

		fp_for_o.data1 <= res1;
		fp_for_o.data2 <= res2;
		fp_for_o.data3 <= res3;

	end process;

end architecture;
