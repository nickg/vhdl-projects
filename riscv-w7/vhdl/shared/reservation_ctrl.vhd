-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.reservation_wire.all;

entity reservation_ctrl is
	generic(
		number_of_cores   : integer;
		reservation_depth : integer
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		soc_i     : in  soc_in_type;
		soc_o     : out soc_out_type;
		mem_o     : in  mem_out_type;
		mem_i     : out mem_in_type;
		arbiter_o : in  arbiter_out_type;
		arbiter_i : out arbiter_in_type;
		set_o     : in  set_out_type;
		set_i     : out set_in_type;
		tag_o     : in  tag_out_type;
		tag_i     : out tag_in_type;
		pid_o     : in  pid_out_type;
		pid_i     : out pid_in_type
	);
end reservation_ctrl;

architecture behavior of reservation_ctrl is

	type register_i_type is record
		mem     : mem_in_type;
		index   : integer range 0 to 2**reservation_depth-1;
		request : std_logic_vector(2**number_of_cores-1 downto 0);
		strb    : std_logic_vector(7 downto 0);
		addr    : std_logic_vector(63 downto 0);
		tag     : std_logic_vector(63 downto reservation_depth+3);
		set     : std_logic_vector(7 downto 0);
		pid     : integer range 0 to 2**number_of_cores-1;
		b_tag   : std_logic;
		b_set   : std_logic;
		b_pid   : std_logic;
		wen     : std_logic;
		enable  : std_logic;
		atomic  : std_logic;
		lock    : std_logic;
		load    : std_logic;
		store   : std_logic;
		cont    : std_logic;
		err     : std_logic;
	end record;

	constant init_register_i : register_i_type := (
		mem     => init_mem_in,
		index   => 0,
		request => (others => '0'),
		strb    => (others => '0'),
		addr    => (others => '0'),
		tag     => (others => '0'),
		set     => (others => '0'),
		pid     => 0,
		b_tag   => '0',
		b_set   => '0',
		b_pid   => '0',
		wen     => '0',
		enable  => '0',
		atomic  => '0',
		lock    => '0',
		load    => '0',
		store   => '0',
		cont    => '0',
		err     => '0'
	);

	type register_a_type is record
		pid   : integer range 0 to 2**number_of_cores-1;
		err   : std_logic;
		ready : std_logic;
	end record;

	constant init_register_a : register_a_type := (
		pid   => 0,
		err   => '0',
		ready => '1'
	);

	signal r_i,rin_i : register_i_type := init_register_i;
	signal r_a,rin_a : register_a_type := init_register_a;

begin

	process(r_i,rin_a,soc_i,mem_o,arbiter_o,set_o,tag_o,pid_o)

	variable v : register_i_type;

	begin

		v := r_i;

		v.mem := init_mem_in;

		v.enable := '0';
		v.atomic := '0';
		v.lock := '0';
		v.load := '0';
		v.store := '0';
		v.err := '0';
		v.set := (others => '0');

		for i in 0 to 2**number_of_cores-1 loop
			v.request(i) := soc_i(i).mem_valid;
		end loop;

		if or_reduce(v.request) = '1' then
			v.enable := '1';
		end if;

		if rin_a.ready = '0' then
			v.enable := '0';
		end if;

		arbiter_i.requests <= v.request;
		arbiter_i.enable <= v.enable and not(v.cont);

		for i in 0 to 2**number_of_cores-1 loop
			if (arbiter_o.grants(i) and v.enable) = '1' then
				v.pid := i;
				v.mem := soc_i(v.pid);
				v.atomic := soc_i(v.pid).mem_atomic;
				v.lock := soc_i(v.pid).mem_lock;
				v.strb := soc_i(v.pid).mem_strb;
				v.addr := soc_i(v.pid).mem_addr;
				v.load := not(soc_i(v.pid).mem_write);
				v.store := soc_i(v.pid).mem_write;
				exit;
			end if;
		end loop;

		if (v.enable and v.atomic) = '1' then
			v.tag := v.addr(63 downto reservation_depth+3);
			if reservation_depth = 0 then
				v.index := 0;
			else
				v.index := to_integer(unsigned(v.addr(reservation_depth+2 downto 3)));
			end if;
		end if;

		tag_i.raddr <= v.index;
		set_i.raddr <= v.index;
		pid_i.raddr <= v.index;

		v.b_tag := to_std_logic(tag_o.rdata = v.tag);
		v.b_set := to_std_logic(set_o.rdata = v.strb);
		v.b_pid := to_std_logic(pid_o.rdata = v.pid);

		if v.atomic = '1' and v.lock = '0' then
			if v.load = '1' then
				if (v.b_tag and v.b_set and v.b_pid) = '1' then
					v.err := '1';
					v.set := (others => '0');
					v.wen := '1';
				else
					v.set := v.strb;
					v.wen := '1';
				end if;
			elsif v.store = '1' then
				if (v.b_tag and v.b_set and v.b_pid) = '1' then
					v.set := (others => '0');
					v.wen := '1';
				else
					v.err := '1';
					v.set := (others => '0');
					v.wen := '1';
				end if;
			end if;
		end if;

		if v.atomic = '1' and v.lock = '1' then
			if v.load = '1' then
				v.cont := '1';
			elsif v.store = '1' then
				v.cont := '0';
			end if;
		end if;

		if v.err = '1' then
			v.mem := init_mem_in;
		end if;

		mem_i <= v.mem;

		v.wen := v.atomic and (v.load or v.store) and not(v.lock);

		tag_i.waddr <= v.index;
		set_i.waddr <= v.index;
		pid_i.waddr <= v.index;
		tag_i.wdata <= v.tag;
		set_i.wdata <= v.set;
		pid_i.wdata <= v.pid;
		tag_i.wen <= v.wen;
		set_i.wen <= v.wen;
		pid_i.wen <= v.wen;

		rin_i <= v;

	end process;

	process(r_i,r_a,mem_o)

	variable v : register_a_type;

	begin

		v := r_a;

		v.pid := r_i.pid;
		v.err := r_i.err;

		if r_i.enable = '1' then
			v.ready := '0';
		end if;

		for i in 0 to 2**number_of_cores-1 loop
			if i = v.pid then
				if v.err = '1' then
					v.ready := '1';
					soc_o(i).mem_flush <= '0';
					soc_o(i).mem_error <= '1';
					soc_o(i).mem_busy  <= '0';
					soc_o(i).mem_ready <= '1';
					soc_o(i).mem_rdata <= (others => '0');
				else
					if  mem_o.mem_ready = '1' then
						v.ready := '1';
					end if;
					soc_o(i) <= mem_o;
				end if;
			else
				soc_o(i) <= init_mem_out;
			end if;
		end loop;

		rin_a <= v;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				r_i <= init_register_i;
				r_a <= init_register_a;
			else
				r_i <= rin_i;
				r_a <= rin_a;
			end if;

		end if;

	end process;

end architecture;
