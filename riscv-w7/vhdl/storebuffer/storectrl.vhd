-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;

entity storectrl is
	generic(
		storebuffer_depth : integer := storebuffer_depth
	);
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		storectrl_i : in  storebuffer_in_type;
		storectrl_o : out storebuffer_out_type;
		storeram_i  : out storeram_in_type;
		storeram_o  : in  storeram_out_type;
		dmem_o      : in  mem_out_type;
		dmem_i      : out mem_in_type
	);
end storectrl;

architecture behavior of storectrl is

	type reg_type is record
		saddr   : std_logic_vector(63 downto 0);
		sdata   : std_logic_vector(63 downto 0);
		sstrb   : std_logic_vector(7 downto 0);
		strb    : std_logic_vector(7 downto 0);
		addr    : std_logic_vector(63 downto 0);
		wdata   : std_logic_vector(63 downto 0);
		wid     : integer range 0 to 2**storebuffer_depth-1;
		rid     : integer range 0 to 2**storebuffer_depth-1;
		wren    : std_logic;
		rden    : std_logic;
		oflow   : std_logic;
		inv     : std_logic;
		amo     : std_logic;
		st      : std_logic;
		ld      : std_logic;
		atomic  : std_logic;
		slock   : std_logic;
		lock    : std_logic;
		swr     : std_logic;
		wr      : std_logic;
		store   : std_logic;
		load    : std_logic;
		full    : std_logic;
		invalid : std_logic;
	end record;

	constant init_reg : reg_type := (
		saddr   => (others => '0'),
		sdata   => (others => '0'),
		sstrb   => (others => '0'),
		strb    => (others => '0'),
		addr    => (others => '0'),
		wdata   => (others => '0'),
		wid     => 0,
		rid     => 0,
		wren    => '0',
		rden    => '0',
		oflow   => '0',
		inv     => '0',
		amo     => '0',
		st      => '0',
		ld      => '0',
		atomic  => '0',
		slock   => '0',
		lock    => '0',
		swr     => '0',
		wr      => '0',
		store   => '0',
		load    => '0',
		full    => '0',
		invalid => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(r,storectrl_i,storeram_o,dmem_o)

	variable v : reg_type;

	variable valid : std_logic;

	variable ready : std_logic;
	variable rdata : std_logic_vector(63 downto 0);

	begin

		v := r;

		if r.wren = '1' then
			ready := '1';
			rdata := (others => '0');
		elsif r.atomic = '1' then
			ready := dmem_o.mem_ready;
			rdata := dmem_o.mem_rdata;
		elsif r.load = '1' then
			ready := dmem_o.mem_ready;
			rdata := dmem_o.mem_rdata;
		else
			ready := '0';
			rdata := (others => '0');
		end if;

		if r.invalid = '1' then
			v.invalid := '0';
		elsif r.atomic = '1' then
			if ready = '1' then
				v.atomic := '0';
			end if;
		elsif r.load = '1' then
			if ready = '1' then
				v.load := '0';
			end if;
		end if;

		storectrl_o.mem_flush <= dmem_o.mem_flush;
		storectrl_o.mem_error <= dmem_o.mem_error;
		storectrl_o.mem_busy <= dmem_o.mem_busy;
		storectrl_o.mem_ready <= ready;
		storectrl_o.mem_rdata <= rdata;

		v.store := '0';

		if storectrl_i.mem_valid = '1' then
			v.inv := storectrl_i.mem_invalid;
			v.amo := storectrl_i.mem_atomic;
			v.st := storectrl_i.mem_write;
			v.ld := not(storectrl_i.mem_write);
			v.swr := storectrl_i.mem_write;
			v.slock := storectrl_i.mem_lock;
			v.sstrb := storectrl_i.mem_strb;
			v.saddr := storectrl_i.mem_addr;
			v.sdata := storectrl_i.mem_wdata;
			if v.amo = '1' then
				v.st := '0';
				v.ld := '0';
			end if;
			if v.st = '1' then
				v.store := '1';
			end if;
		end if;

		if r.full = '1' and r.store = '1' then
			v.store := '1';
		end if;

		v.wren := '0';
		v.full := '0';
		if v.store = '1' then
			if v.oflow = '1' and v.wid < v.rid then
				v.wren := '1';
			elsif v.oflow = '0' then
				v.wren := '1';
			else
				v.full := '1';
			end if;
		end if;

		if dmem_o.mem_ready = '1' then
			if v.rden = '1' then
				if v.rid = 2**storebuffer_depth-1 then
					v.oflow := '0';
					v.rid := 0;
				else
					v.rid := v.rid+1;
				end if;
			end if;
		end if;

		v.rden := '0';
		if v.oflow = '0' and v.rid < v.wid then
			v.rden := '1';
		elsif v.oflow = '1' then
			v.rden := '1';
		end if;

		storeram_i.wren <= v.wren;
		storeram_i.waddr <= v.wid;
		storeram_i.wdata <= v.swr & v.sstrb & v.saddr & v.sdata;

		storeram_i.raddr <= v.rid;

		if v.wren = '1' then
			if v.wid = 2**storebuffer_depth-1 then
				v.oflow := '1';
				v.wid := 0;
			else
				v.wid := v.wid+1;
			end if;
		end if;

		if (v.rden or v.wren) = '0' then
			if v.inv = '1' then
				v.invalid := '1';
			elsif v.amo = '1' then
				v.atomic := '1';
			elsif v.ld = '1' then
				v.load := '1';
			end if;
			v.inv := '0';
			v.amo := '0';
			v.ld := '0';
		end if;

		if v.rden = '1' then
			v.lock := '0';
			v.wr := storeram_o.rdata(136);
			v.strb := storeram_o.rdata(135 downto 128);
			v.addr := storeram_o.rdata(127 downto 64);
			v.wdata := storeram_o.rdata(63 downto 0);
		elsif v.atomic = '1' then
			v.lock := v.slock;
			v.wr := v.swr;
			v.strb := v.sstrb;
			v.addr := v.saddr;
			v.wdata := v.sdata;
		elsif v.load = '1' then
			v.lock := '0';
			v.wr := '0';
			v.strb := v.sstrb;
			v.addr := v.saddr;
			v.wdata := (others => '0');
		else
			v.lock := '0';
			v.wr := '0';
			v.strb := (others => '0');
			v.addr := (others => '0');
			v.wdata := (others => '0');
		end if;

		valid := v.rden or v.load or v.atomic or v.invalid;
		if (r.rden or r.load or r.atomic or r.invalid) = '1' then
			if dmem_o.mem_ready = '0' then
				valid := '0';
			end if;
		end if;

		dmem_i.mem_valid <= valid;
		dmem_i.mem_instr <= '0';
		dmem_i.mem_spec <= '0';
		dmem_i.mem_invalid <= v.invalid;
		dmem_i.mem_atomic <= v.atomic;
		dmem_i.mem_lock <= v.lock;
		dmem_i.mem_write <= v.wr;
		dmem_i.mem_strb <= v.strb;
		dmem_i.mem_addr <= v.addr;
		dmem_i.mem_wdata <= v.wdata;

		rin <= v;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
