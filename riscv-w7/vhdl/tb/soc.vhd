-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;

entity soc is
end entity soc;

architecture behavior of soc is

	component cpu
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type;
			meip_i  : in  std_logic;
			msip_i  : in  std_logic;
			mtip_i  : in  std_logic;
			mtime_i : in  std_logic_vector(63 downto 0)
		);
	end component;

	component reservation
		generic(
			number_of_cores   : integer := number_of_cores;
			reservation_depth : integer := reservation_depth
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			soc_i : in  soc_in_type;
			soc_o : out soc_out_type;
			mem_o : in  mem_out_type;
			mem_i : out mem_in_type
		);
	end component;

	component bram
		generic(
			bram_depth   : integer := bram_depth;
			bram_latency : integer := bram_latency
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			mem_i : in  mem_in_type;
			mem_o : out mem_out_type
		);
	end component;

	component check
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			mem_i : in  mem_in_type;
			mem_o : out mem_out_type
		);
	end component;

	component print
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			mem_i : in  mem_in_type;
			mem_o : out mem_out_type
		);
	end component;

	component clint
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
	end component;

	component plic
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
	end component;

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';
	signal rtc   : std_logic := '0';

	signal count : unsigned(31 downto 0) := (others => '0');

	signal soc_i : soc_in_type := (others => init_mem_in);
	signal soc_o : soc_out_type := (others => init_mem_out);

	signal mem_i : mem_in_type := init_mem_in;
	signal mem_o : mem_out_type := init_mem_out;

	signal bram_mem_i : mem_in_type := init_mem_in;
	signal bram_mem_o : mem_out_type := init_mem_out;

	signal print_mem_i : mem_in_type := init_mem_in;
	signal print_mem_o : mem_out_type := init_mem_out;

	signal check_mem_i : mem_in_type := init_mem_in;
	signal check_mem_o : mem_out_type := init_mem_out;

	signal clint_mem_i : mem_in_type := init_mem_in;
	signal clint_mem_o : mem_out_type := init_mem_out;

	signal plic_mem_i : mem_in_type := init_mem_in;
	signal plic_mem_o : mem_out_type := init_mem_out;

	signal irq_src : std_logic_vector(2**plic_sources-1 downto 0) := (others => '0');

	signal meip : std_logic_vector(2**plic_contexts-1 downto 0) := (others => '0');
	signal msip : std_logic_vector(2**clint_contexts-1 downto 0) := (others => '0');
	signal mtip : std_logic_vector(2**clint_contexts-1 downto 0) := (others => '0');

	signal mtime : std_logic_vector(63 downto 0) := (others => '0');

begin

	reset <= '1' after 100 ns;
	clock <= not clock after 20 ns;

	process (clock)

	begin

		if rising_edge(clock) then

			if count = clk_divider_rtc then
				rtc <= not rtc;
				count <= (others => '0');
			else
				count <= count + 1;
			end if;

		end if;

	end process;

	process(mem_i,bram_mem_o,print_mem_o,check_mem_o,clint_mem_o,plic_mem_o)

	variable base_addr : std_logic_vector(63 downto 0);
	variable mem_addr  : std_logic_vector(63 downto 0);

	begin

		if mem_i.mem_valid = '1' then
			if (unsigned(mem_i.mem_addr) >= unsigned(plic_base_addr) and
					unsigned(mem_i.mem_addr) < unsigned(plic_top_addr)) then
				bram_mem_i.mem_valid <= '0';
				print_mem_i.mem_valid <= '0';
				clint_mem_i.mem_valid <= '0';
				plic_mem_i.mem_valid <= mem_i.mem_valid;
				base_addr := plic_base_addr;
			elsif (unsigned(mem_i.mem_addr) >= unsigned(clint_base_addr) and
					unsigned(mem_i.mem_addr) < unsigned(clint_top_addr)) then
				bram_mem_i.mem_valid <= '0';
				print_mem_i.mem_valid <= '0';
				clint_mem_i.mem_valid <= mem_i.mem_valid;
				plic_mem_i.mem_valid <= '0';
				base_addr := clint_base_addr;
			elsif (unsigned(mem_i.mem_addr) >= unsigned(print_base_addr) and
					unsigned(mem_i.mem_addr) < unsigned(print_top_addr)) then
				bram_mem_i.mem_valid <= '0';
				print_mem_i.mem_valid <= mem_i.mem_valid;
				clint_mem_i.mem_valid <= '0';
				plic_mem_i.mem_valid <= '0';
				base_addr := print_base_addr;
			elsif (unsigned(mem_i.mem_addr) >= unsigned(bram_base_addr) and
					unsigned(mem_i.mem_addr) < unsigned(bram_top_addr)) then
				bram_mem_i.mem_valid <= mem_i.mem_valid;
				print_mem_i.mem_valid <= '0';
				clint_mem_i.mem_valid <= '0';
				plic_mem_i.mem_valid <= '0';
				base_addr := bram_base_addr;
			else
				bram_mem_i.mem_valid <= '0';
				print_mem_i.mem_valid <= '0';
				clint_mem_i.mem_valid <= '0';
				plic_mem_i.mem_valid <= '0';
				base_addr := (others => '0');
			end if;
		else
			bram_mem_i.mem_valid <= '0';
			print_mem_i.mem_valid <= '0';
			clint_mem_i.mem_valid <= '0';
			plic_mem_i.mem_valid <= '0';
			base_addr := (others => '0');
		end if;

		mem_addr := std_logic_vector(unsigned(mem_i.mem_addr) - unsigned(base_addr));

		bram_mem_i.mem_instr <= mem_i.mem_instr;
		bram_mem_i.mem_spec <= mem_i.mem_spec;
		bram_mem_i.mem_invalid <= mem_i.mem_invalid;
		bram_mem_i.mem_atomic <= mem_i.mem_atomic;
		bram_mem_i.mem_lock <= mem_i.mem_lock;
		bram_mem_i.mem_write <= mem_i.mem_write;
		bram_mem_i.mem_strb <= mem_i.mem_strb;
		bram_mem_i.mem_addr <= mem_addr;
		bram_mem_i.mem_wdata <= mem_i.mem_wdata;

		print_mem_i.mem_instr <= mem_i.mem_instr;
		print_mem_i.mem_spec <= mem_i.mem_spec;
		print_mem_i.mem_invalid <= mem_i.mem_invalid;
		print_mem_i.mem_atomic <= mem_i.mem_atomic;
		print_mem_i.mem_lock <= mem_i.mem_lock;
		print_mem_i.mem_write <= mem_i.mem_write;
		print_mem_i.mem_strb <= mem_i.mem_strb;
		print_mem_i.mem_addr <= mem_addr;
		print_mem_i.mem_wdata <= mem_i.mem_wdata;

		clint_mem_i.mem_instr <= mem_i.mem_instr;
		clint_mem_i.mem_spec <= mem_i.mem_spec;
		clint_mem_i.mem_invalid <= mem_i.mem_invalid;
		clint_mem_i.mem_atomic <= mem_i.mem_atomic;
		clint_mem_i.mem_lock <= mem_i.mem_lock;
		clint_mem_i.mem_write <= mem_i.mem_write;
		clint_mem_i.mem_strb <= mem_i.mem_strb;
		clint_mem_i.mem_addr <= mem_addr;
		clint_mem_i.mem_wdata <= mem_i.mem_wdata;

		plic_mem_i.mem_instr <= mem_i.mem_instr;
		plic_mem_i.mem_spec <= mem_i.mem_spec;
		plic_mem_i.mem_invalid <= mem_i.mem_invalid;
		plic_mem_i.mem_atomic <= mem_i.mem_atomic;
		plic_mem_i.mem_lock <= mem_i.mem_lock;
		plic_mem_i.mem_write <= mem_i.mem_write;
		plic_mem_i.mem_strb <= mem_i.mem_strb;
		plic_mem_i.mem_addr <= mem_addr;
		plic_mem_i.mem_wdata <= mem_i.mem_wdata;

		check_mem_i <= mem_i;

		if (bram_mem_o.mem_ready = '1') then
			mem_o.mem_flush <= bram_mem_o.mem_flush;
			mem_o.mem_error <= bram_mem_o.mem_error;
			mem_o.mem_busy <= bram_mem_o.mem_busy;
			mem_o.mem_rdata <= bram_mem_o.mem_rdata;
			mem_o.mem_ready <= bram_mem_o.mem_ready;
		elsif (print_mem_o.mem_ready = '1') then
			mem_o.mem_flush <= print_mem_o.mem_flush;
			mem_o.mem_error <= print_mem_o.mem_error;
			mem_o.mem_busy <= print_mem_o.mem_busy;
			mem_o.mem_rdata <= print_mem_o.mem_rdata;
			mem_o.mem_ready <= print_mem_o.mem_ready;
		elsif (clint_mem_o.mem_ready = '1') then
			mem_o.mem_flush <= clint_mem_o.mem_flush;
			mem_o.mem_error <= clint_mem_o.mem_error;
			mem_o.mem_busy <= clint_mem_o.mem_busy;
			mem_o.mem_rdata <= clint_mem_o.mem_rdata;
			mem_o.mem_ready <= clint_mem_o.mem_ready;
		elsif (plic_mem_o.mem_ready = '1') then
			mem_o.mem_flush <= plic_mem_o.mem_flush;
			mem_o.mem_error <= plic_mem_o.mem_error;
			mem_o.mem_busy <= plic_mem_o.mem_busy;
			mem_o.mem_rdata <= plic_mem_o.mem_rdata;
			mem_o.mem_ready <= plic_mem_o.mem_ready;
		else
			mem_o.mem_flush <= '0';
			mem_o.mem_error <= '0';
			mem_o.mem_busy <= '0';
			mem_o.mem_rdata <= (others => '0');
			mem_o.mem_ready <= '0';
		end if;

	end process;

	GEN_CPU : for i in 0 to 2**number_of_cores-1 generate

		cpu_comp : cpu
			port map(
				reset   => reset,
				clock   => clock,
				mem_o   => soc_o(i),
				mem_i   => soc_i(i),
				meip_i  => meip(i),
				msip_i  => msip(i),
				mtip_i  => mtip(i),
				mtime_i => mtime
			);

	end generate GEN_CPU;

	reservation_comp : reservation
		port map(
			reset => reset,
			clock => clock,
			soc_i => soc_i,
			soc_o => soc_o,
			mem_o => mem_o,
			mem_i => mem_i
		);

	bram_comp : bram
		port map(
			reset => reset,
			clock => clock,
			mem_i => bram_mem_i,
			mem_o => bram_mem_o
		);

	check_comp : check
		port map(
			reset => reset,
			clock => clock,
			mem_i => check_mem_i,
			mem_o => check_mem_o
		);

	print_comp : print
		port map(
			reset => reset,
			clock => clock,
			mem_i => print_mem_i,
			mem_o => print_mem_o
		);

	clint_comp : clint
		port map(
			reset   => reset,
			clock   => clock,
			rtc     => rtc,
			mem_i   => clint_mem_i,
			mem_o   => clint_mem_o,
			msip_o  => msip,
			mtip_o  => mtip,
			mtime_o => mtime
		);

	plic_comp : plic
		port map(
			reset   => reset,
			clock   => clock,
			mem_i   => plic_mem_i,
			mem_o   => plic_mem_o,
			irq_src => irq_src,
			irq_req => meip
		);

end architecture;
