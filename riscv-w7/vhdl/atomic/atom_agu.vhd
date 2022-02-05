-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.functions.all;
use work.atom_constants.all;
use work.atom_wire.all;
use work.atom_functions.all;

entity atom_agu is
	port(
		atom_agu_i : in  atom_agu_in_type;
		atom_agu_o : out atom_agu_out_type
	);
end atom_agu;

architecture behavior of atom_agu is

begin

	process(atom_agu_i)

		variable exc      : std_logic;
		variable etval    : std_logic_vector(63 downto 0);
		variable ecause   : std_logic_vector(3 downto 0);

		variable mem_addr : std_logic_vector(63 downto 0);
		variable mem_byte : std_logic_vector(7 downto 0);

		variable misalign : std_logic;

	begin

		exc         := '0';
		etval       := X"0000000000000000";
		ecause      := X"0";

		mem_addr    := atom_agu_i.rs1;
		mem_byte    := X"00";

		misalign    := '0';

		if atom_agu_i.atom = '1' then

			if atom_agu_i.atom_op.atom_word = '0' then

				case mem_addr(2 downto 0) is
					when "000"  => mem_byte := "11111111";
					when others => misalign := '1';
				end case;

			elsif atom_agu_i.atom_op.atom_word = '1' then

				case mem_addr(2 downto 0) is
					when "000"  => mem_byte := "00001111";
					when "100"  => mem_byte := "11110000";
					when others => misalign := '1';
				end case;

			end if;

			if misalign = '1' then
				exc := '1';
				etval := mem_addr;
				if atom_agu_i.load = '1' then
					ecause := except_load_addr_misalign;
				elsif atom_agu_i.store = '1' then
					ecause := except_store_addr_misalign;
				end if;
			elsif or_reduce(mem_addr(63 downto 56)) = '1' then
				exc := '1';
				etval := mem_addr;
				if atom_agu_i.load = '1' then
					ecause := except_load_access_fault;
				elsif atom_agu_i.store = '1' then
					ecause := except_store_access_fault;
				end if;
			end if;

		end if;

		atom_agu_o.mem_addr <= mem_addr;
		atom_agu_o.mem_byte <= mem_byte;

		atom_agu_o.exc <= exc;
		atom_agu_o.etval <= etval;
		atom_agu_o.ecause <= ecause;

	end process;

end architecture;
