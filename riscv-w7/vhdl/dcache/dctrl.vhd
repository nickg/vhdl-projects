-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.dwire.all;

entity dctrl is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ctrl_i  : in  dctrl_in_type;
		ctrl_o  : out dctrl_out_type;
		cache_i : in  mem_in_type;
		cache_o : out mem_out_type;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type
	);
end dctrl;

architecture behavior of dctrl is

	type state_type is (HIT,MISS,UPDATE,INVALIDATE,WRITEBACK);

	type ctrl_type is record
		addr    : std_logic_vector(63 downto 0);
		data    : std_logic_vector(63 downto 0);
		strb    : std_logic_vector(7 downto 0);
		tag     : std_logic_vector(60-(cache_sets+cache_words) downto 0);
		sid     : integer range 0 to 2**cache_sets-1;
		lid     : integer range 0 to 2**cache_words-1;
		invalid : std_logic;
		rden    : std_logic;
		wren    : std_logic;
	end record;

	constant init_ctrl_type : ctrl_type := (
		addr    => (others => '0'),
		data    => (others => '0'),
		strb    => (others => '0'),
		tag     => (others => '0'),
		sid     => 0,
		lid     => 0,
		invalid => '0',
		rden    => '0',
		wren    => '0'
	);

	type data_type is record
		state   : state_type;
		addr    : std_logic_vector(63 downto 0);
		data    : std_logic_vector(63 downto 0);
		strb    : std_logic_vector(7 downto 0);
		rdata   : std_logic_vector(63 downto 0);
		wdata   : std_logic_vector(63 downto 0);
		tag     : std_logic_vector(60-(cache_sets+cache_words) downto 0);
		dtag    : std_logic_vector(60-(cache_sets+cache_words) downto 0);
		cline   : std_logic_vector((2**cache_words)*64-1 downto 0);
		dline   : std_logic_vector((2**cache_words)*64-1 downto 0);
		wen     : std_logic_vector(2**cache_ways-1 downto 0);
		wvec    : std_logic_vector(2**cache_ways-1 downto 0);
		dvec    : std_logic_vector(2**cache_ways-1 downto 0);
		sid     : integer range 0 to 2**cache_sets-1;
		lid     : integer range 0 to 2**cache_words-1;
		count   : integer range 0 to 2**cache_words-1;
		wid     : integer range 0 to 2**cache_ways-1;
		invalid : std_logic;
		flush   : std_logic;
		busy    : std_logic;
		valid   : std_logic;
		hit     : std_logic;
		miss    : std_logic;
		dirty   : std_logic;
		rden    : std_logic;
		wren    : std_logic;
		den     : std_logic;
		wr      : std_logic;
		store   : std_logic;
		ready   : std_logic;
	end record;

	constant init_data_type : data_type := (
		state   => INVALIDATE,
		addr    => (others => '0'),
		data    => (others => '0'),
		strb    => (others => '0'),
		rdata   => (others => '0'),
		wdata   => (others => '0'),
		tag     => (others => '0'),
		dtag    => (others => '0'),
		cline   => (others => '0'),
		dline   => (others => '0'),
		wen     => (others => '0'),
		wvec    => (others => '0'),
		dvec    => (others => '0'),
		sid     => 0,
		lid     => 0,
		wid     => 0,
		count   => 0,
		invalid => '0',
		flush   => '0',
		busy    => '0',
		valid   => '0',
		hit     => '0',
		miss    => '0',
		dirty   => '0',
		rden    => '0',
		wren    => '0',
		den     => '0',
		wr      => '0',
		store   => '0',
		ready   => '0'
	);

	signal r,rin : ctrl_type := init_ctrl_type;
	signal r_next,rin_next : data_type := init_data_type;

begin

	process(cache_i,r,rin_next)

	variable v : ctrl_type;

	begin

		v := r;

		v.invalid := '0';
		v.rden := '0';
		v.wren := '0';

		if cache_i.mem_valid = '1' then
			if cache_i.mem_invalid = '1' then
				v.invalid := '1';
				v.sid := 0;
			else
				v.rden := not(cache_i.mem_write);
				v.wren := cache_i.mem_write;
				v.data := cache_i.mem_wdata;
				v.strb := cache_i.mem_strb;
				v.addr(63 downto cache_words+3) := cache_i.mem_addr(63 downto cache_words+3);
				v.addr(cache_words+2 downto 0) := (others => '0');
				v.tag := cache_i.mem_addr(63 downto cache_sets+cache_words+3);
				v.sid := to_integer(unsigned(cache_i.mem_addr(cache_sets+cache_words+2 downto 3+cache_words)));
				v.lid := to_integer(unsigned(cache_i.mem_addr(cache_words+2 downto 3)));
			end if;
		end if;

		if rin_next.invalid = '1' then
			v.sid := rin_next.sid;
		end if;

		rin <= v;

	end process;

	process(ctrl_i,cache_i,mem_o,r,r_next,rin)

	variable v : data_type;

	begin

		v := r_next;

		v.rden := '0';
		v.wren := '0';
		v.den := '0';
		v.hit := '0';
		v.miss := '0';
		v.invalid := '0';
		v.flush := '0';
		v.store := '0';

		if r_next.state = HIT then
			v.rden := r.rden;
			v.wren := r.wren;
			v.addr := r.addr;
			v.data := r.data;
			v.strb := r.strb;
			v.tag := r.tag;
			v.sid := r.sid;
			v.lid := r.lid;
			v.wr := r.wren;
		end if;

		ctrl_o.hit_i.tag <= v.tag;
		for i in 0 to 2**cache_ways-1 loop
			ctrl_o.hit_i.tag_a(i) <= ctrl_i.tag_o(i).rdata;
		end loop;
		ctrl_o.hit_i.valid <= ctrl_i.valid_o.rdata;

		case r_next.state is

			when HIT =>

				v.wvec := ctrl_i.valid_o.rdata;
				v.dvec := ctrl_i.dirty_o.rdata;
				v.wen := (others => '0');

				v.hit := ctrl_i.hit_o.hit and (v.rden or v.wren);
				v.miss := ctrl_i.hit_o.miss and (v.rden or v.wren);
				v.wid := ctrl_i.hit_o.wid;

				if v.miss = '1' then
					v.state := MISS;
					v.count := 0;
					v.valid := '1';
				elsif v.hit = '1' then
					v.wen(v.wid) := v.wren;
					v.wvec(v.wid) := v.wren;
					v.dvec(v.wid) := v.wren;
					v.den := v.wren;
					v.cline := ctrl_i.data_o(v.wid).rdata;
					v.valid := '0';
					if v.wren = '1' then
						v.state := UPDATE;
					end if;
				else
					v.valid := '0';
				end if;

				v.flush := '0';

			when MISS =>

				if r_next.miss = '1' then
					v.wid := ctrl_i.rand_o.wid;
					v.dirty := v.dvec(v.wid);
					v.dvec(v.wid) := r_next.wren;
					v.den := '1';
					v.dline := ctrl_i.data_o(v.wid).rdata;
					v.dtag := ctrl_i.tag_o(v.wid).rdata;
				end if;

				if mem_o.mem_ready = '1' then

					for i in 0 to 2**cache_words-1 loop
						if r_next.count = i then
							v.cline(64*(i+1)-1 downto 64*i) := mem_o.mem_rdata;
						end if;
					end loop;

					if v.count = 2**cache_words-1 then
						if v.dirty = '0' then
							v.wen(v.wid) := '1';
							v.wvec(v.wid) := '1';
							v.state := UPDATE;
						else
							v.addr(63 downto cache_words+3) := v.dtag & std_logic_vector(to_unsigned(v.sid,cache_sets));
							v.addr(cache_words+2 downto 0) := (others => '0');
							v.count := 0;
							v.state := WRITEBACK;
						end if;
						v.valid := '0';
					else
						v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
						v.count := v.count + 1;
					end if;

				end if;

				v.flush := '0';

			when UPDATE =>

				v.wen := (others => '0');
				v.wvec := (others => '0');
				v.dvec := (others => '0');
				v.valid := '0';
				v.state := HIT;

				v.flush := '0';

			when INVALIDATE =>

				v.dvec := ctrl_i.dirty_o.rdata;
				v.wvec := ctrl_i.valid_o.rdata;
				v.wen := (others => '0');

				v.dline := ctrl_i.data_o(v.wid).rdata;
				v.dtag := ctrl_i.tag_o(v.wid).rdata;

				if (v.dvec(v.wid) and v.wvec(v.wid)) = '1' then
					v.addr(63 downto cache_words+3) := v.dtag & std_logic_vector(to_unsigned(v.sid,cache_sets));
					v.addr(cache_words+2 downto 0) := (others => '0');
					v.state := WRITEBACK;
				else
					if v.wid = 2**cache_ways-1 then
						v.dvec := (others => '0');
						v.wvec := (others => '0');
						v.invalid := '1';
					end if;
				end if;

				v.count := 0;
				v.valid := '0';

				v.flush := '1';

			when WRITEBACK =>

				v.wen := (others => '0');

				if mem_o.mem_ready = '1' then
					if v.count /= 2**cache_words-1 then
						v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
						v.count := v.count + 1;
					else
						if v.dirty = '1' then
							v.wen(v.wid) := '1';
							v.wvec(v.wid) := '1';
							v.state := UPDATE;
						else
							if v.wid = 2**cache_ways-1 then
								v.dvec := (others => '0');
								v.wvec := (others => '0');
								v.invalid := '1';
							end if;
							v.state := INVALIDATE;
						end if;
						v.valid := '0';
					end if;
				end if;

				for i in 0 to 2**cache_words-1 loop
					if v.count = i then
						v.wdata := v.dline(64*(i+1)-1 downto 64*i);
						v.store := '1';
						v.valid := '1';
					end if;
				end loop;

			when others =>

				null;

		end case;

		for i in 0 to 2**cache_words-1 loop
			if v.lid = i and v.wr = '1' then
				for j in 0 to 7 loop
					if v.strb(j) = '1' then
						v.cline(i*64+(j+1)*8-1 downto i*64+j*8) := v.data((j+1)*8-1 downto j*8);
					end if;
				end loop;
			end if;
		end loop;

		for i in 0 to 2**cache_ways-1 loop
			ctrl_o.data_i(i).raddr <= rin.sid;
			ctrl_o.tag_i(i).raddr <= rin.sid;
		end loop;

		ctrl_o.valid_i.raddr <= rin.sid;

		ctrl_o.dirty_i.raddr <= rin.sid;

		for i in 0 to 2**cache_ways-1 loop
			ctrl_o.data_i(i).waddr <= v.sid;
			ctrl_o.data_i(i).wen <= v.wen(i);
			ctrl_o.data_i(i).wdata <= v.cline;
			ctrl_o.tag_i(i).waddr <= v.sid;
			ctrl_o.tag_i(i).wen <= v.wen(i);
			ctrl_o.tag_i(i).wdata <= v.tag;
		end loop;

		ctrl_o.rand_i.miss <= v.miss;

		ctrl_o.dirty_i.waddr <= v.sid;
		ctrl_o.dirty_i.wen <= v.den or v.invalid;
		ctrl_o.dirty_i.wdata <= v.dvec;

		ctrl_o.valid_i.waddr <= v.sid;
		ctrl_o.valid_i.wen <= or_reduce(v.wen) or v.invalid;
		ctrl_o.valid_i.wdata <= v.wvec;

		if v.state = INVALIDATE then
			if v.wid = 2**cache_ways-1 then
				v.wid := 0;
				if v.sid = 2**cache_sets-1 then
					v.state := HIT;
				else
					v.sid := v.sid+1;
				end if;
			else
				v.wid := v.wid + 1;
			end if;
		end if;

		if r.invalid = '1' then
			v.sid := 0;
			v.wid := 0;
			v.state := INVALIDATE;
		end if;

		for i in 0 to 2**cache_words-1 loop
			if v.lid = i then
				v.rdata := v.cline(64*(i+1)-1 downto 64*i);
			end if;
		end loop;

		if r_next.state = HIT then
			v.ready := v.rden and v.hit;
			v.busy := '0';
		elsif r_next.state = UPDATE then
			v.ready := '1';
			v.busy := '0';
		elsif r_next.state = INVALIDATE then
			if v.state = HIT then
				v.ready := '1';
				v.busy := '0';
			else
				v.ready := '0';
				v.busy := '1';
			end if;
		else
			v.ready := '0';
			v.busy := '1';
		end if;

		mem_i.mem_valid <= v.valid;
		mem_i.mem_instr <= '0';
		mem_i.mem_invalid <= '0';
		mem_i.mem_spec <= '0';
		mem_i.mem_atomic <= '0';
		mem_i.mem_lock <= '0';
		mem_i.mem_write <= v.store;
		mem_i.mem_strb <= X"FF";
		mem_i.mem_addr <= v.addr;
		mem_i.mem_wdata <= v.wdata;

		cache_o.mem_rdata <= v.rdata;
		cache_o.mem_ready <= v.ready;
		cache_o.mem_flush <= v.flush;
		cache_o.mem_error <= '0';
		cache_o.mem_busy <= v.busy;

		rin_next <= v;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_ctrl_type;
				r_next <= init_data_type;

			else

				r <= rin;
				r_next <= rin_next;

			end if;

		end if;

	end process;

end architecture;
