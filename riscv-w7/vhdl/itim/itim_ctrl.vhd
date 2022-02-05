-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.itim_wire.all;

entity itim_ctrl is
	generic(
		itim_sets  : integer;
		itim_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ictrl_i : in  itim_ctrl_in_type;
		ictrl_o : out itim_ctrl_out_type;
		itim_i  : in  mem_in_type;
		itim_o  : out mem_out_type;
		imem_o  : in  mem_out_type;
		imem_i  : out mem_in_type
	);
end itim_ctrl;

architecture behavior of itim_ctrl is

	type state_type is (HIT,MISS,LOAD,UPDATE,INVALIDATE);

	type ctrl_type is record
		addr : std_logic_vector(63 downto 0);
		tag  : std_logic_vector(60-(itim_sets+itim_words) downto 0);
		sid  : integer range 0 to 2**itim_sets-1;
		wid  : integer range 0 to 2**itim_words-1;
		inv  : std_logic;
		en   : std_logic;
	end record;

	constant init_ctrl_type : ctrl_type := (
		addr => (others => '0'),
		tag  => (others => '0'),
		sid  => 0,
		wid  => 0,
		inv  => '0',
		en   => '0'
	);

	type data_type is record
		state : state_type;
		addr  : std_logic_vector(63 downto 0);
		data  : std_logic_vector(63 downto 0);
		tag   : std_logic_vector(60-(itim_sets+itim_words) downto 0);
		words : std_logic_vector((2**itim_words)*64-1 downto 0);
		sid   : integer range 0 to 2**itim_sets-1;
		wid   : integer range 0 to 2**itim_words-1;
		count : integer range 0 to 2**itim_words-1;
		inv   : std_logic;
		busy  : std_logic;
		flush : std_logic;
		valid : std_logic;
		hit   : std_logic;
		load  : std_logic;
		miss  : std_logic;
		en    : std_logic;
		wen   : std_logic;
		lock  : std_logic;
		ready : std_logic;
	end record;

	constant init_data_type : data_type := (
		state => INVALIDATE,
		addr  => (others => '0'),
		data  => (others => '0'),
		tag   => (others => '0'),
		words => (others => '0'),
		sid   => 0,
		wid   => 0,
		count => 0,
		inv   => '0',
		busy  => '0',
		flush => '0',
		valid => '0',
		hit   => '0',
		load  => '0',
		miss  => '0',
		en    => '0',
		wen   => '0',
		lock  => '0',
		ready => '0'
	);

	signal r,rin : ctrl_type := init_ctrl_type;
	signal r_next,rin_next : data_type := init_data_type;

begin

	process(itim_i,r)

	variable v : ctrl_type;

	begin

		v := r;

		v.inv := '0';
		v.en := '0';

		if itim_i.mem_valid = '1' then
			if itim_i.mem_invalid = '1' then
				v.inv := itim_i.mem_invalid;
			else
				v.en := itim_i.mem_valid;
				v.addr := itim_i.mem_addr;
				v.tag := itim_i.mem_addr(63 downto itim_sets+itim_words+3);
				v.sid := to_integer(unsigned(itim_i.mem_addr(itim_sets+itim_words+2 downto 3+itim_words)));
				v.wid := to_integer(unsigned(itim_i.mem_addr(itim_words+2 downto 3)));
			end if;
		end if;

		rin <= v;

	end process;

	process(ictrl_i,imem_o,r,r_next,rin)

	variable v : data_type;

	begin

		v := r_next;

		v.en := '0';
		v.inv := '0';
		v.hit := '0';
		v.load := '0';
		v.miss := '0';
		v.flush := '0';

		if r_next.state = HIT then
			v.en := r.en;
			v.inv := r.inv;
			v.addr := r.addr;
			v.tag := r.tag;
			v.sid := r.sid;
			v.wid := r.wid;
		end if;

		case r_next.state is

			when HIT =>

				v.wen := '0';
				v.lock := ictrl_i.lock_o.rdata;

				if v.lock = '0' then
					v.miss := v.en;
				elsif (v.lock = '1' and or_reduce(ictrl_i.tag_o.rdata xor v.tag) = '1') then
					v.load := v.en;
				else
					v.hit := v.en;
				end if;

				if v.miss = '1' then
					v.state := MISS;
					v.addr(itim_words+2 downto 0) := (others => '0');
					v.count := 0;
					v.valid := '1';
				elsif v.load = '1' then
					v.state := LOAD;
					v.valid := '1';
				else
					v.words := ictrl_i.data_o.rdata;
					v.valid := '0';
				end if;

				v.flush := '0';

			when MISS =>

				if imem_o.mem_ready = '1' then

					for i in 0 to 2**itim_words-1 loop
						if r_next.count = i then
							v.words(64*(i+1)-1 downto 64*i) := imem_o.mem_rdata;
						end if;
					end loop;

					if r_next.count = 2**itim_words-1 then
						v.wen := '1';
						v.lock := '1';
						v.valid := '0';
						v.state := UPDATE;
					end if;

					v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
					if v.count /= 2**itim_words-1 then
						v.count := v.count + 1;
					end if;

				end if;

				v.flush := '0';

			when LOAD =>

				v.wen := '0';
				v.lock := '0';
				v.valid := '0';

				if imem_o.mem_ready = '1' then
					v.state := HIT;
				end if;

				v.flush := '0';

			when UPDATE =>

				v.wen := '0';
				v.lock := '0';
				v.valid := '0';
				v.state := HIT;

				v.flush := '0';

			when INVALIDATE =>

				v.wen := '0';
				v.lock := '0';
				v.valid := '0';
				v.inv := '1';

				v.flush := '1';

			when others =>

				null;

		end case;

		ictrl_o.tag_i.raddr <= rin.sid;
		ictrl_o.lock_i.raddr <= rin.sid;
		ictrl_o.data_i.raddr <= rin.sid;

		ictrl_o.tag_i.waddr <= v.sid;
		ictrl_o.tag_i.wen <= v.wen;
		ictrl_o.tag_i.wdata <= v.tag;

		ictrl_o.data_i.waddr <= v.sid;
		ictrl_o.data_i.wen <= v.wen;
		ictrl_o.data_i.wdata <= v.words;

		ictrl_o.lock_i.waddr <= v.sid;
		ictrl_o.lock_i.wen <= v.wen or v.inv;
		ictrl_o.lock_i.wdata <= v.lock;

		if r_next.state = INVALIDATE then
			if v.sid = 2**itim_sets-1 then
				v.state := HIT;
			else
				v.sid := v.sid+1;
			end if;
		end if;

		for i in 0 to 2**itim_words-1 loop
			if v.wid = i then
				v.data := v.words(64*(i+1)-1 downto 64*i);
			end if;
		end loop;

		if r_next.state = HIT then
			v.ready := v.en and v.hit;
			v.busy := '0';
		elsif r_next.state = LOAD then
			v.data := imem_o.mem_rdata;
			v.ready := imem_o.mem_ready;
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

		if r.inv = '1' then
			v.sid := 0;
			v.state := INVALIDATE;
		end if;

		imem_i.mem_valid <= v.valid;
		imem_i.mem_instr <= '1';
		imem_i.mem_invalid <= '0';
		imem_i.mem_spec <= '0';
		imem_i.mem_atomic <= '0';
		imem_i.mem_lock <= '0';
		imem_i.mem_write <= '0';
		imem_i.mem_strb <= X"FF";
		imem_i.mem_addr <= v.addr;
		imem_i.mem_wdata <= (others => '0');

		itim_o.mem_rdata <= v.data;
		itim_o.mem_ready <= v.ready;
		itim_o.mem_flush <= v.flush;
		itim_o.mem_error <= '0';
		itim_o.mem_busy <= v.busy;

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
