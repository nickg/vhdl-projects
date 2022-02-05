-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.plic_wire.all;
use work.plic_lib.all;

entity plic is
	generic(
		plic_sources  : integer := plic_sources;
		plic_contexts : integer := plic_contexts
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		mem_i   : in  mem_in_type;
		mem_o   : out mem_out_type;
		irq_src : in  std_logic_vector(2**plic_sources-1 downto 0);
		irq_req : out std_logic_vector(2**plic_contexts-1 downto 0)
	);
end plic;

architecture behavior of plic is

	constant plic_sp_start : integer := 0;
	constant plic_sp_end   : integer := plic_sp_start + 2**plic_sources*4;
	constant plic_pb_start : integer := 4096;
	constant plic_pb_end   : integer := plic_pb_start + 2**plic_sources/8;
	constant plic_eb_start : integer := 8192;
	constant plic_eb_end   : integer := plic_eb_start + 2**(plic_contexts+plic_sources)/8;
	constant plic_pt_start : integer := 2097152;
	constant plic_pt_end   : integer := plic_pt_start + 2**plic_contexts*4096;

	signal irq_sp : irq_sp_type := (others => (others => '0'));             -- interrupt source priorities
	signal irq_pb : irq_pb_type := (others => (others => '0'));             -- interrupt pending bits
	signal irq_eb : irq_eb_type := (others => (others => (others => '0'))); -- interrupt enable bits
	signal irq_pt : irq_pt_type := (others => (others => '0'));             -- interrupt priority thresholds
	signal irq_cl : irq_cl_type := (others => (others => '0'));             -- interrupt claim
	signal irq_co : irq_co_type := (others => (others => '0'));             -- interrupt completion

	signal rdata_q : std_logic_vector(63 downto 0) := (others => '0');
	signal ready_q : std_logic := '0';

	signal irq_leveledge : std_logic_vector(2**plic_sources-1 downto 0) := (others => '0');
	signal irq_claim     : std_logic_vector(2**plic_sources-1 downto 0) := (others => '0');
	signal irq_complete  : std_logic_vector(2**plic_sources-1 downto 0) := (others => '0');
	signal irq_request   : std_logic_vector(2**plic_sources-1 downto 0) := (others => '0');

begin

	process(clock)

	variable wdata : std_logic_vector(31 downto 0);
	variable rdata : std_logic_vector(31 downto 0);
	variable ready : std_logic;

	variable baddr : std_logic_vector(63 downto 0);
	variable raddr : std_logic_vector(63 downto 0);

	variable sp : std_logic;
	variable pb : std_logic;
	variable eb : std_logic;
	variable pt : std_logic;
	variable cc : std_logic;

	variable rd : std_logic;
	variable wr : std_logic;

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				wdata := (others => '0');
				rdata := (others => '0');
				ready := '0';
				baddr :=  (others => '0');
				raddr :=  (others => '0');
				sp := '0';
				pb := '0';
				eb := '0';
				pt := '0';
				cc := '0';
				rd := '0';
				wr := '0';
				irq_sp <= (others => (others => '0'));
				irq_pb <= (others => (others => '0'));
				irq_eb <= (others => (others => (others => '0')));
				irq_pt <= (others => (others => '0'));
				irq_co <= (others => (others => '0'));
			else
				wdata := (others => '0');
				rdata := (others => '0');
				ready := '0';
				baddr :=  (others => '0');
				raddr :=  (others => '0');
				sp := '0';
				pb := '0';
				eb := '0';
				pt := '0';
				cc := '0';
				rd := '0';
				wr := '0';
				if (mem_i.mem_valid = '1') then
					if mem_i.mem_addr(2) = '0' then
						wdata := mem_i.mem_wdata(31 downto 0);
					else
						wdata := mem_i.mem_wdata(63 downto 32);
					end if;
					if (mem_i.mem_write = '0') then
						rd := '1';
					else
						wr := '1';
					end if;
					if unsigned(mem_i.mem_addr) > plic_sp_start and unsigned(mem_i.mem_addr) < plic_sp_end then
						baddr := std_logic_vector(to_unsigned(plic_sp_start,baddr'length));
						sp := '1';
					elsif unsigned(mem_i.mem_addr) >= plic_pb_start and unsigned(mem_i.mem_addr) < plic_pb_end then
						baddr := std_logic_vector(to_unsigned(plic_pb_start,baddr'length));
						pb := '1';
					elsif unsigned(mem_i.mem_addr) >= plic_eb_start and unsigned(mem_i.mem_addr) < plic_eb_end then
						baddr := std_logic_vector(to_unsigned(plic_eb_start,baddr'length));
						eb := '1';
					elsif unsigned(mem_i.mem_addr) >= plic_pt_start and unsigned(mem_i.mem_addr) < plic_pt_end then
						baddr := std_logic_vector(to_unsigned(plic_pt_start,baddr'length));
						if mem_i.mem_addr(2) = '0' then
							pt := '1';
						else
							cc := '1';
						end if;
					end if;
					raddr := std_logic_vector(unsigned(mem_i.mem_addr)-unsigned(baddr));
					if sp = '1' then
						if rd = '1' then
							rdata := irq_sp(to_integer(unsigned(raddr(23 downto 2))));
						elsif wr = '1' then
							irq_sp(to_integer(unsigned(raddr(23 downto 2)))) <= wdata;
						end if;
						ready := '1';
					elsif pb = '1' then
						if rd = '1' then
							rdata := irq_pb(to_integer(unsigned(raddr(23 downto 2))));
						end if;
						ready := '1';
					elsif eb = '1' then
						if rd = '1' then
							rdata := irq_eb(to_integer(unsigned(raddr(23 downto 8))),to_integer(unsigned(raddr(7 downto 2))));
						elsif wr = '1' then
							irq_eb(to_integer(unsigned(raddr(23 downto 8))),to_integer(unsigned(raddr(7 downto 2)))) <= wdata;
						end if;
						ready := '1';
					elsif pt = '1' then
						if rd = '1' then
							rdata := irq_pt(to_integer(unsigned(raddr(23 downto 12))));
						elsif wr = '1' then
							irq_pt(to_integer(unsigned(raddr(23 downto 12)))) <= wdata;
						end if;
						ready := '1';
					elsif cc = '1' then
						if rd = '1' then
							rdata := irq_cl(to_integer(unsigned(raddr(23 downto 12))));
						elsif wr = '1' then
							irq_co(to_integer(unsigned(raddr(23 downto 12)))) <= wdata;
						end if;
						ready := '1';
					else
						ready := '1';
					end if;
				end if;
			end if;

			if mem_i.mem_addr(2) = '0' then
				rdata_q <= X"00000000" & rdata;
				ready_q <= ready;
			else
				rdata_q <= rdata & X"00000000";
				ready_q <= ready;
			end if;

		end if;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				irq_leveledge <= (others => '0');
				irq_claim <= (others => '0');
				irq_complete <= (others => '0');
			else
				for i in 0 to 2**plic_contexts-1 loop
					for j in 0 to 2**plic_sources-1 loop
						irq_claim(j) <= to_std_logic(unsigned(irq_cl(i)(plic_sources downto 0)) = j);
						irq_complete(j) <= to_std_logic(unsigned(irq_co(i)(plic_sources downto 0)) = j);
					end loop;
				end loop;
			end if;

		end if;

	end process;

	mem_o.mem_flush <= '0';
	mem_o.mem_error <= '0';
	mem_o.mem_busy <= '0';
	mem_o.mem_rdata <= rdata_q;
	mem_o.mem_ready <= ready_q;

	GEN_PLIC_GW : for i in 0 to 2**plic_sources-1 generate

		plic_gw_comp : plic_gw
		port map
		(
			reset                 => reset,
			clock                 => clock,
			plic_gw_irq_src       => irq_src(i),
			plic_gw_irq_leveledge => irq_leveledge(i),
			plic_gw_irq_claim     => irq_claim(i),
			plic_gw_irq_complete  => irq_complete(i),
			plic_gw_irq_request   => irq_request(i)
		);

	end generate GEN_PLIC_GW;

	plic_core_comp : plic_core
	port map
	(
		reset            => reset,
		clock            => clock,
		plic_core_irq_sp => irq_sp,
		plic_core_irq_pb => irq_pb,
		plic_core_irq_eb => irq_eb,
		plic_core_irq_pt => irq_pt,
		plic_core_irq_cl => irq_cl,
		plic_core_irq_ip => irq_req
	);

end architecture;
