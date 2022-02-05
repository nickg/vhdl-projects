-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.plic_wire.all;
use work.plic_func.all;

entity plic_core is
	generic(
		plic_sources     : integer := plic_sources;
		plic_contexts    : integer := plic_contexts;
		plic_priorities  : integer := plic_priorities;
		plic_max_pending : integer := plic_max_pending
	);
	port(
		reset            : in  std_logic;
		clock            : in  std_logic;
		plic_core_irq_sp : in  irq_sp_type;
		plic_core_irq_pb : in  irq_pb_type;
		plic_core_irq_eb : in  irq_eb_type;
		plic_core_irq_pt : in  irq_pt_type;
		plic_core_irq_cl : out irq_cl_type;
		plic_core_irq_ip : out std_logic_vector(2**plic_contexts-1 downto 0)
	);
end plic_core;

architecture behavior of plic_core is

	signal max_p_d : irq_mp_type := (others => (others => (others => '0')));
	signal max_i_d : irq_mi_type := (others => (others => (others => '0')));

	signal max_p_q : irq_mp_type := (others => (others => (others => '0')));
	signal max_i_q : irq_mi_type := (others => (others => (others => '0')));

begin

	process(plic_core_irq_sp,plic_core_irq_pb,plic_core_irq_eb,plic_core_irq_pt,max_p_d,max_i_d,max_p_q,max_i_q)

	variable var_irq_sp : irq_sp_type;

	begin

		max_p_d <= max_p_q;
		max_i_d <= max_i_q;

		for i in 0 to 2**plic_contexts-1 loop

			plic_core_irq_ip(i) <= '0';
			plic_core_irq_cl(i) <= (others => '0');

			for j in 0 to 2**plic_sources-1 loop

				var_irq_sp(j) := and_logic(plic_core_irq_sp(j),plic_core_irq_pb(j/32)(j mod 32));

				if j = 2**plic_sources-1 then

					if unsigned(and_logic(var_irq_sp(j),plic_core_irq_eb(i,j/32)(j mod 32))) > unsigned(plic_core_irq_pt(i)) then
						plic_core_irq_ip(i) <= '1';
						plic_core_irq_cl(i) <= max_i_q(i,j);
					end if;

				else

					if unsigned(and_logic(var_irq_sp(j),plic_core_irq_eb(i,j/32)(j mod 32))) > unsigned(max_p_q(i,j)) then
						max_p_d(i,j+1) <= var_irq_sp(j);
						max_i_d(i,j+1) <= std_logic_vector(to_unsigned(j+1,32));
					end if;

				end if;

			end loop;

		end loop;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then

				max_p_q <= (others => (others => (others => '0')));
				max_i_q <= (others => (others => (others => '0')));

			else

				max_p_q <= max_p_d;
				max_i_q <= max_i_d;

			end if;

		end if;

	end process;

end architecture;
