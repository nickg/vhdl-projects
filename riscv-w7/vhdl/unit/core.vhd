-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.fp_wire.all;
use work.wire.all;

entity core is
	generic(
		fpu_enable      : boolean := fpu_enable;
		fpu_performance : boolean := fpu_performance
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ibus_o  : in  mem_out_type;
		ibus_i  : out mem_in_type;
		dbus_o  : in  mem_out_type;
		dbus_i  : out mem_in_type;
		meip_i  : in  std_logic;
		msip_i  : in  std_logic;
		mtip_i  : in  std_logic;
		mtime_i : in  std_logic_vector(63 downto 0)
	);
end entity core;

architecture behavior of core is

	component pipeline
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			imem_o  : in  mem_out_type;
			imem_i  : out mem_in_type;
			dmem_o  : in  mem_out_type;
			dmem_i  : out mem_in_type;
			ipmp_o  : in  pmp_out_type;
			ipmp_i  : out pmp_in_type;
			dpmp_o  : in  pmp_out_type;
			dpmp_i  : out pmp_in_type;
			fpu_o   : in  fpu_out_type;
			fpu_i   : out fpu_in_type;
			meip_i  : in  std_logic;
			msip_i  : in  std_logic;
			mtip_i  : in  std_logic;
			mtime_i : in  std_logic_vector(63 downto 0)
		);
	end component;

	component itim
		generic(
			itim_enable : boolean;
			itim_sets   : integer;
			itim_words  : integer
		);
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			itim_i : in  mem_in_type;
			itim_o : out mem_out_type;
			imem_o : in  mem_out_type;
			imem_i : out mem_in_type
		);
	end component;

	component dtim
		generic(
			dtim_enable : boolean;
			dtim_sets   : integer;
			dtim_words  : integer
		);
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			dtim_i : in  mem_in_type;
			dtim_o : out mem_out_type;
			dmem_o : in  mem_out_type;
			dmem_i : out mem_in_type
		);
	end component;

	component icache
		generic(
			cache_enable : boolean;
			cache_sets   : integer;
			cache_ways   : integer;
			cache_words  : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			cache_i : in  mem_in_type;
			cache_o : out mem_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	component dcache
		generic(
			cache_enable : boolean;
			cache_sets   : integer;
			cache_ways   : integer;
			cache_words  : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			cache_i : in  mem_in_type;
			cache_o : out mem_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	component pmp
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			pmp_i  : in  pmp_in_type;
			pmp_o  : out pmp_out_type
		);
	end component;

	component fpu
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			fpu_i : in  fpu_in_type;
			fpu_o : out fpu_out_type
		);
	end component;

	type access_type is (TIM_ACCESS,CACHE_ACCESS, IO_MEM_ACCESS, NO_ACCESS);
	type mode_type is (FREE,BUSY);

	type reg_type is record
		acc_t : access_type;
		mod_t : mode_type;
	end record;

	constant init_reg : reg_type := (
		acc_t => CACHE_ACCESS,
		mod_t => BUSY
	);

	signal itim_i : mem_in_type;
	signal itim_o : mem_out_type;
	signal dtim_i : mem_in_type;
	signal dtim_o : mem_out_type;

	signal icache_i : mem_in_type;
	signal icache_o : mem_out_type;
	signal dcache_i : mem_in_type;
	signal dcache_o : mem_out_type;

	signal imem_i : mem_in_type;
	signal imem_o : mem_out_type;
	signal dmem_i : mem_in_type;
	signal dmem_o : mem_out_type;

	signal it_mem_i : mem_in_type;
	signal it_mem_o : mem_out_type;
	signal dt_mem_i : mem_in_type;
	signal dt_mem_o : mem_out_type;

	signal io_mem_i : mem_in_type;
	signal io_mem_o : mem_out_type;
	signal do_mem_i : mem_in_type;
	signal do_mem_o : mem_out_type;

	signal ipmp_i : pmp_in_type;
	signal ipmp_o : pmp_out_type;
	signal dpmp_i : pmp_in_type;
	signal dpmp_o : pmp_out_type;

	signal fpu_o : fpu_out_type;
	signal fpu_i : fpu_in_type;

	signal ir, irin : reg_type := init_reg;
	signal dr, drin : reg_type := init_reg;

begin

	process(ir,imem_i,it_mem_i,io_mem_i,itim_o,icache_o,ibus_o)

	variable v : reg_type;

	variable it_mem_out : mem_out_type;
	variable io_mem_out : mem_out_type;
	variable itim_in    : mem_in_type;
	variable icache_in  : mem_in_type;
	variable imem_out   : mem_out_type;
	variable ibus_in    : mem_in_type;

	begin

		v := ir;

		itim_in := init_mem_in;
		icache_in := init_mem_in;
		ibus_in := init_mem_in;
		imem_out := init_mem_out;
		it_mem_out := init_mem_out;
		io_mem_out := init_mem_out;

		if v.mod_t = BUSY then
			if v.acc_t = TIM_ACCESS then
				if itim_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				imem_out := itim_o;
				ibus_in := it_mem_i;
				it_mem_out := ibus_o;
			elsif v.acc_t = CACHE_ACCESS then
				if icache_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				imem_out := icache_o;
				ibus_in := io_mem_i;
				io_mem_out := ibus_o;
			elsif v.acc_t = IO_MEM_ACCESS then
				if ibus_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				imem_out := ibus_o;
				ibus_in := imem_i;
			end if;
		end if;

		if v.mod_t = FREE then
			if imem_i.mem_valid = '1' then
				if (unsigned(imem_i.mem_addr) >= unsigned(itim_base_addr) and
						unsigned(imem_i.mem_addr) < unsigned(itim_top_addr)) then
					v.acc_t := TIM_ACCESS;
					v.mod_t := BUSY;
					itim_in := imem_i;
				elsif (unsigned(imem_i.mem_addr) >= unsigned(icache_base_addr) and
						unsigned(imem_i.mem_addr) < unsigned(icache_top_addr)) then
					v.acc_t := CACHE_ACCESS;
					v.mod_t := BUSY;
					icache_in := imem_i;
				else
					v.acc_t := IO_MEM_ACCESS;
					v.mod_t := BUSY;
					ibus_in := imem_i;
				end if;
			else
				v.acc_t := NO_ACCESS;
				v.mod_t := FREE;
			end if;
		end if;

		if imem_i.mem_valid = '1' then
			if imem_i.mem_invalid = '1' then
				v.acc_t := CACHE_ACCESS;
				v.mod_t := BUSY;
				icache_in := imem_i;
			end if;
		end if;

		itim_i <= itim_in;
		icache_i <= icache_in;
		ibus_i <= ibus_in;
		imem_o <= imem_out;
		it_mem_o <= it_mem_out;
		io_mem_o <= io_mem_out;


		irin <= v;

	end process;

	process (clock)

	begin

		if rising_edge(clock) then
			if reset = reset_active then
				ir <= init_reg;
			else
				ir <= irin;
			end if;
		end if;

	end process;

	process(dr,dmem_i,dt_mem_i,do_mem_i,dtim_o,dcache_o,dbus_o)

	variable v : reg_type;

	variable dt_mem_out : mem_out_type;
	variable do_mem_out : mem_out_type;
	variable dtim_in    : mem_in_type;
	variable dcache_in  : mem_in_type;
	variable dmem_out   : mem_out_type;
	variable dbus_in    : mem_in_type;

	begin

		v := dr;

		dtim_in := init_mem_in;
		dcache_in := init_mem_in;
		dbus_in := init_mem_in;
		dmem_out := init_mem_out;
		dt_mem_out := init_mem_out;
		do_mem_out := init_mem_out;

		if v.mod_t = BUSY then
			if v.acc_t = TIM_ACCESS then
				if dtim_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				dmem_out := dtim_o;
				dbus_in := dt_mem_i;
				dt_mem_out := dbus_o;
			elsif v.acc_t = CACHE_ACCESS then
				if dcache_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				dmem_out := dcache_o;
				dbus_in := do_mem_i;
				do_mem_out := dbus_o;
			elsif v.acc_t = IO_MEM_ACCESS then
				if dbus_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				dmem_out := dbus_o;
				dbus_in := dmem_i;
			end if;
		end if;

		if v.mod_t = FREE then
			if dmem_i.mem_valid = '1' then
				if (unsigned(dmem_i.mem_addr) >= unsigned(dtim_base_addr) and
						unsigned(dmem_i.mem_addr) < unsigned(dtim_top_addr)) then
					v.acc_t := TIM_ACCESS;
					v.mod_t := BUSY;
					dtim_in := dmem_i;
				elsif (unsigned(dmem_i.mem_addr) >= unsigned(dcache_base_addr) and
						unsigned(dmem_i.mem_addr) < unsigned(dcache_top_addr)) then
					v.acc_t := CACHE_ACCESS;
					v.mod_t := BUSY;
					dcache_in := dmem_i;
				else
					v.acc_t := IO_MEM_ACCESS;
					v.mod_t := BUSY;
					dbus_in := dmem_i;
				end if;
			else
				v.acc_t := NO_ACCESS;
				v.mod_t := FREE;
			end if;
		end if;

		if dmem_i.mem_valid = '1' then
			if dmem_i.mem_invalid = '1' then
				v.acc_t := CACHE_ACCESS;
				v.mod_t := BUSY;
				dcache_in := dmem_i;
			end if;
		end if;

		dtim_i <= dtim_in;
		dcache_i <= dcache_in;
		dbus_i <= dbus_in;
		dmem_o <= dmem_out;
		dt_mem_o <= dt_mem_out;
		do_mem_o <= do_mem_out;

		drin <= v;

	end process;

	process (clock)

	begin

		if rising_edge(clock) then
			if reset = reset_active then
				dr <= init_reg;
			else
				dr <= drin;
			end if;
		end if;

	end process;

	pipeline_comp : pipeline
		port map(
			reset   => reset,
			clock   => clock,
			imem_o  => imem_o,
			imem_i  => imem_i,
			dmem_o  => dmem_o,
			dmem_i  => dmem_i,
			ipmp_o  => ipmp_o,
			ipmp_i  => ipmp_i,
			dpmp_o  => dpmp_o,
			dpmp_i  => dpmp_i,
			fpu_o   => fpu_o,
			fpu_i   => fpu_i,
			meip_i  => meip_i,
			msip_i  => msip_i,
			mtip_i  => mtip_i,
			mtime_i => mtime_i
		);

	itim_comp : itim
		generic map(
			itim_enable => itim_enable,
			itim_sets   => itim_sets,
			itim_words  => itim_words
		)
		port map(
			reset  => reset,
			clock  => clock,
			itim_i => itim_i,
			itim_o => itim_o,
			imem_o => it_mem_o,
			imem_i => it_mem_i
		);

	dtim_comp : dtim
		generic map(
			dtim_enable => dtim_enable,
			dtim_sets   => dtim_sets,
			dtim_words  => dtim_words
		)
		port map(
			reset  => reset,
			clock  => clock,
			dtim_i => dtim_i,
			dtim_o => dtim_o,
			dmem_o => dt_mem_o,
			dmem_i => dt_mem_i
		);

	icache_comp : icache
		generic map(
			cache_enable => icache_enable,
			cache_sets   => icache_sets,
			cache_ways   => icache_ways,
			cache_words  => icache_words
		)
		port map(
			reset   => reset,
			clock   => clock,
			cache_i => icache_i,
			cache_o => icache_o,
			mem_o   => io_mem_o,
			mem_i   => io_mem_i
		);

	dcache_comp : dcache
		generic map(
			cache_enable => dcache_enable,
			cache_sets   => dcache_sets,
			cache_ways   => dcache_ways,
			cache_words  => dcache_words
		)
		port map(
			reset   => reset,
			clock   => clock,
			cache_i => dcache_i,
			cache_o => dcache_o,
			mem_o   => do_mem_o,
			mem_i   => do_mem_i
		);

	ipmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			pmp_i  => ipmp_i,
			pmp_o  => ipmp_o
		);

	dpmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			pmp_i  => dpmp_i,
			pmp_o  => dpmp_o
		);

	FP_Unit : if fpu_enable = true generate

		fpu_comp : fpu
			port map(
				reset => reset,
				clock => clock,
				fpu_i => fpu_i,
				fpu_o => fpu_o
			);

	end generate FP_Unit;

end architecture;
