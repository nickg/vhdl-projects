-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

entity plic_gw is
	generic(
		plic_sources     : integer := plic_sources;
		plic_contexts    : integer := plic_contexts;
		plic_max_pending : integer := plic_max_pending;
		plic_level       : std_logic := plic_level;
		plic_edge        : std_logic := plic_edge
	);
	port(
		reset                 : in  std_logic;
		clock                 : in  std_logic;
		plic_gw_irq_src       : in  std_logic;
		plic_gw_irq_leveledge : in  std_logic;
		plic_gw_irq_claim     : in  std_logic;
		plic_gw_irq_complete  : in  std_logic;
		plic_gw_irq_request   : out std_logic
	);
end plic_gw;

architecture behavior of plic_gw is

	signal plic_pend_count : integer range 0 to 2**plic_max_pending-1 := 0;
	signal plic_ip_state   : integer range 0 to 3 := 0;

	signal plic_src_delay : std_logic := '0';
	signal plic_src_edge  : std_logic := '0';

	signal plic_decr_pend : std_logic := '0';

begin

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then

				plic_src_delay <= '0';
				plic_src_edge <= '0';

			else

				plic_src_delay <= plic_gw_irq_src;
				plic_src_edge <= plic_gw_irq_src and not(plic_src_delay);

			end if;

		end if;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then

				plic_pend_count <= 0;

			else

					if plic_gw_irq_leveledge = plic_level then
						plic_pend_count <= 0;
					else
						if plic_decr_pend = '0' and plic_src_edge = '1' then
							if plic_pend_count < 2**plic_max_pending-1 then
								plic_pend_count <= plic_pend_count + 1;
							end if;
						elsif plic_decr_pend = '1' and plic_src_edge = '0' then
							if plic_pend_count > 0 then
								plic_pend_count <= plic_pend_count - 1;
							end if;
						end if;
					end if;

			end if;

		end if;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then

				plic_ip_state <= 0;
				plic_decr_pend <= '0';

			else

					plic_decr_pend <= '0';
					case plic_ip_state is
						when 0 =>
							if (plic_gw_irq_leveledge = plic_edge and plic_pend_count > 0) then
								plic_decr_pend <= '1';
								plic_ip_state <= 1;
							elsif (plic_gw_irq_leveledge = plic_level and plic_gw_irq_src = '1') then
								plic_ip_state <= 1;
							end if;
						when 1 =>
							if plic_gw_irq_claim = '1' then
								plic_ip_state <= 2;
							end if;
						when 2 =>
							if plic_gw_irq_complete = '1' then
								plic_ip_state <= 0;
							end if;
						when others =>
							plic_ip_state <= 0;
					end case;

			end if;

		end if;

	end process;

	plic_gw_irq_request <= '1' when plic_ip_state = 1 else '0';

end architecture;
