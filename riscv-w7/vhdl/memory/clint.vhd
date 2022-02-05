-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

entity clint is
	generic(
		clint_contexts : integer := clint_contexts
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		rtc     : in  std_logic;
		mem_i   : in  mem_in_type;
		mem_o   : out mem_out_type;
		msip_o  : out std_logic_vector(2**clint_contexts-1 downto 0);
		mtip_o  : out std_logic_vector(2**clint_contexts-1 downto 0);
		mtime_o : out std_logic_vector(63 downto 0)
	);
end clint;

architecture behavior of clint is

	constant clint_msip_start  : integer := 0;
	constant clint_msip_end    : integer := clint_msip_start + 2**clint_contexts*4;
	constant clint_mtcmp_start : integer := 16384;
	constant clint_mtcmp_end   : integer := clint_mtcmp_start + 2**clint_contexts*8;
	constant clint_mtime_start : integer := 49144;
	constant clint_mtime_end   : integer := clint_mtime_start + 8;

	type mtcmp_type is array (0 to 2**clint_contexts-1) of std_logic_vector(63 downto 0);

	signal mtcmp : mtcmp_type := (others => (others => '0'));

	signal state : std_logic := '0';
	signal incr  : std_logic := '0';

	signal mtime : std_logic_vector(63 downto 0) := (others => '0');

	signal rdata_q : std_logic_vector(63 downto 0) := (others => '0');
	signal ready_q : std_logic := '0';

	signal msip : std_logic_vector(2**clint_contexts-1 downto 0) := (others => '0');
	signal mtip : std_logic_vector(2**clint_contexts-1 downto 0) := (others => '0');

begin

	process(clock)

	variable wdata : std_logic_vector(63 downto 0);
	variable rdata : std_logic_vector(63 downto 0);
	variable ready : std_logic;

	variable baddr : std_logic_vector(63 downto 0);
	variable raddr : std_logic_vector(63 downto 0);

	variable ms : std_logic;
	variable mc : std_logic;
	variable mt : std_logic;

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
				ms := '0';
				mc := '0';
				mt := '0';
				rd := '0';
				wr := '0';
				msip <= (others => '0');
				mtcmp <= (others => (others => '0'));
				mtime <= (others => '0');
			else
				wdata := (others => '0');
				rdata := (others => '0');
				ready := '0';
				baddr :=  (others => '0');
				raddr :=  (others => '0');
				ms := '0';
				mc := '0';
				mt := '0';
				rd := '0';
				wr := '0';
				if incr = '1' then
					mtime <= std_logic_vector(unsigned(mtime) + 1);
				end if;
				if (mem_i.mem_valid = '1') then
					wdata := mem_i.mem_wdata;
					if (mem_i.mem_write = '0') then
						rd := '1';
					else
						wr := '1';
					end if;
					if unsigned(mem_i.mem_addr) >= clint_msip_start and unsigned(mem_i.mem_addr) < clint_msip_end then
						baddr := std_logic_vector(to_unsigned(clint_msip_start,baddr'length));
						ms := '1';
					elsif unsigned(mem_i.mem_addr) >= clint_mtcmp_start and unsigned(mem_i.mem_addr) < clint_mtcmp_end then
						baddr := std_logic_vector(to_unsigned(clint_mtcmp_start,baddr'length));
						mc := '1';
					elsif unsigned(mem_i.mem_addr) >= clint_mtime_start and unsigned(mem_i.mem_addr) < clint_mtime_end then
						baddr := std_logic_vector(to_unsigned(clint_mtime_start,baddr'length));
						mt := '1';
					end if;
					raddr := std_logic_vector(unsigned(mem_i.mem_addr)-unsigned(baddr));
					if ms = '1' then
						if rd = '1' then
							rdata(0) := msip(to_integer(unsigned(raddr(14 downto 3) & '0')));
							rdata(32) := msip(to_integer(unsigned(raddr(14 downto 3) & '1')));
						elsif wr = '1' then
							msip(to_integer(unsigned(raddr(14 downto 3) & '0'))) <= wdata(0);
							msip(to_integer(unsigned(raddr(14 downto 3) & '1'))) <= wdata(32);
						end if;
						ready := '1';
					elsif mc = '1' then
						if rd = '1' then
							rdata := mtcmp(to_integer(unsigned(raddr(15 downto 3))));
						elsif wr = '1' then
							mtcmp(to_integer(unsigned(raddr(15 downto 3)))) <= wdata;
						end if;
						ready := '1';
					elsif mt = '1' then
						if rd = '1' then
							rdata := mtime;
						elsif wr = '1' then
							mtime <= wdata;
						end if;
						ready := '1';
					else
						ready := '1';
					end if;
				end if;
			end if;

			rdata_q <= rdata;
			ready_q <= ready;

		end if;

	end process;

	msip_o <= msip;
	mtip_o <= mtip;
	mtime_o <= mtime;

	mem_o.mem_flush <= '0';
	mem_o.mem_error <= '0';
	mem_o.mem_busy <= '0';
	mem_o.mem_rdata <= rdata_q;
	mem_o.mem_ready <= ready_q;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				mtip <= (others => '0');
			else
				mtcmp_i : for i in 0 to 2**clint_contexts-1 loop
					if (unsigned(mtime) >= unsigned(mtcmp(i))) then
						mtip(i) <= '1';
					else
						mtip(i) <= '0';
					end if;
				end loop mtcmp_i;
			end if;

		end if;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				state <= '0';
				incr <= '0';
			else
				if state = '0' and rtc = '1' then
					state <= '1';
					incr <= '1';
				elsif  state = '1' and rtc = '0' then
					state <= '0';
					incr <= '0';
				else
					incr <= '0';
				end if;
			end if;

		end if;

	end process;

end architecture;
