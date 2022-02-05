-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;

use work.csr_wire.all;

entity pmp is
	generic(
		pmp_enable  : boolean := pmp_enable;
		pmp_regions : integer := pmp_regions
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		pmp_i  : in  pmp_in_type;
		pmp_o  : out pmp_out_type
	);
end pmp;

architecture behavior of pmp is

begin

	PMP_ON : if pmp_enable = true generate

		process(pmp_i)

		variable exc      : std_logic;
		variable etval    : std_logic_vector(63 downto 0);
		variable ecause   : std_logic_vector(3 downto 0);
		variable lowaddr  : std_logic_vector(63 downto 0);
		variable highaddr : std_logic_vector(63 downto 0);
		variable mask     : std_logic_vector(63 downto 0);
		variable mask_inc : integer range 0 to 63;


		begin

			exc := '0';
			etval := (others => '0');
			ecause := (others => '0');
			lowaddr := (others => '0');
			highaddr := (others => '0');
			mask := (others => '0');
			mask_inc := 0;

			if pmp_i.mem_valid = '1' then
				if or_reduce(pmp_i.mem_addr(63 downto 56)) = '1' then
					exc := '1';
				else
					for i in 0 to pmp_regions-1 loop
						if pmp_i.pmpcfg(i).A = "01" then
							if i = 0 then
								lowaddr := (others => '0');
							else
								lowaddr := pmp_i.pmpaddr(i-1);
							end if;
							highaddr := pmp_i.pmpaddr(i);
							if unsigned(pmp_i.mem_addr(55 downto 2)) < unsigned(highaddr(53 downto 0)) and
									unsigned(pmp_i.mem_addr(55 downto 2)) >= unsigned(lowaddr(53 downto 0)) then
								if pmp_i.pmpcfg(i).L = '1' or pmp_i.mode = u_mode then
									if pmp_i.pmpcfg(i).X = '0' and pmp_i.mem_instr = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_instr_access_fault;
									elsif pmp_i.pmpcfg(i).R = '0' and pmp_i.mem_write = '0' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_load_access_fault;
									elsif  pmp_i.pmpcfg(i).W = '0' and pmp_i.mem_write = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_store_access_fault;
									end if;
								end if;
								exit;
							end if;
						elsif pmp_i.pmpcfg(i).A = "10" then
							if nor_reduce(pmp_i.mem_addr(55 downto 2) xor pmp_i.pmpaddr(i)(53 downto 0)) = '1' then
								if pmp_i.pmpcfg(i).L = '1' or pmp_i.mode = u_mode then
									if pmp_i.pmpcfg(i).X = '0' and pmp_i.mem_instr = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_instr_access_fault;
									elsif pmp_i.pmpcfg(i).R = '0' and pmp_i.mem_write = '0' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_load_access_fault;
									elsif  pmp_i.pmpcfg(i).W = '0' and pmp_i.mem_write = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_store_access_fault;
									end if;
								end if;
								exit;
							end if;
						elsif pmp_i.pmpcfg(i).A = "11" then
							mask := X"FFFFFFFFFFFFFFFF";
							mask_inc := 1;
							for j in 0 to 53 loop
								if (pmp_i.pmpaddr(i)(j) = '0') then
									exit;
								elsif (pmp_i.pmpaddr(i)(j) = '1') then
									mask_inc := mask_inc + 1;
								end if;
							end loop;
							mask := std_logic_vector(shift_left(unsigned(mask),mask_inc));
							lowaddr := pmp_i.pmpaddr(i) and mask;
							if nor_reduce((pmp_i.mem_addr(55 downto 2) and mask(53 downto 0)) xor lowaddr(53 downto 0)) = '1' then
								if pmp_i.pmpcfg(i).L = '1' or pmp_i.mode = u_mode then
									if pmp_i.pmpcfg(i).X = '0' and pmp_i.mem_instr = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_instr_access_fault;
									elsif pmp_i.pmpcfg(i).R = '0' and pmp_i.mem_write = '0' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_load_access_fault;
									elsif  pmp_i.pmpcfg(i).W = '0' and pmp_i.mem_write = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_store_access_fault;
									end if;
								end if;
								exit;
							end if;
						end if;
					end loop;
				end if;
			end if;

			pmp_o.exc <= exc;
			pmp_o.etval <= etval;
			pmp_o.ecause <= ecause;

		end process;

	end generate PMP_ON;

	PMP_OFF : if pmp_enable = false generate

		pmp_o.exc <= '0';
		pmp_o.etval <= (others => '0');
		pmp_o.ecause <= (others => '0');

	end generate PMP_OFF;

end architecture;
