-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.dtim_wire.all;

entity dtim_ctrl is
	generic(
		dtim_sets : integer;
		dtim_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		dctrl_i : in  dtim_ctrl_in_type;
		dctrl_o : out dtim_ctrl_out_type;
		dtim_i  : in  mem_in_type;
		dtim_o  : out mem_out_type;
		dmem_o  : in  mem_out_type;
		dmem_i  : out mem_in_type
	);
end dtim_ctrl;

architecture behavior of dtim_ctrl is

	type state_type is (HIT,MISS,LDST,ATOM,UPDATE,INVALIDATE,WRITEBACK);

	type ctrl_type is record
		addr : std_logic_vector(63 downto 0);
		data : std_logic_vector(63 downto 0);
		strb : std_logic_vector(7 downto 0);
		tag  : std_logic_vector(60-(dtim_sets+dtim_words) downto 0);
		sid  : integer range 0 to 2**dtim_sets-1;
		wid  : integer range 0 to 2**dtim_words-1;
		inv  : std_logic;
		rden : std_logic;
		wren : std_logic;
		atom : std_logic;
		lock : std_logic;
	end record;

	constant init_ctrl_type : ctrl_type := (
		addr => (others => '0'),
		data => (others => '0'),
		strb => (others => '0'),
		tag  => (others => '0'),
		sid  => 0,
		wid  => 0,
		inv  => '0',
		rden => '0',
		wren => '0',
		atom => '0',
		lock => '0'
	);

	type data_type is record
		state : state_type;
		addr  : std_logic_vector(63 downto 0);
		data  : std_logic_vector(63 downto 0);
		strb  : std_logic_vector(7 downto 0);
		rdata : std_logic_vector(63 downto 0);
		wdata : std_logic_vector(63 downto 0);
		tag   : std_logic_vector(60-(dtim_sets+dtim_words) downto 0);
		words : std_logic_vector((2**dtim_words)*64-1 downto 0);
		sid   : integer range 0 to 2**dtim_sets-1;
		wid   : integer range 0 to 2**dtim_words-1;
		count : integer range 0 to 2**dtim_words-1;
		inv   : std_logic;
		flush : std_logic;
		busy  : std_logic;
		valid : std_logic;
		hit   : std_logic;
		load  : std_logic;
		store : std_logic;
		miss  : std_logic;
		dirty : std_logic;
		rden  : std_logic;
		wren  : std_logic;
		wen   : std_logic;
		wr    : std_logic;
		val   : std_logic;
		loc   : std_logic;
		equ   : std_logic;
		atm   : std_logic;
		atom  : std_logic;
		lock  : std_logic;
		error : std_logic;
		ready : std_logic;
	end record;

	constant init_data_type : data_type := (
		state => INVALIDATE,
		addr  => (others => '0'),
		data  => (others => '0'),
		strb  => (others => '0'),
		rdata => (others => '0'),
		wdata => (others => '0'),
		tag   => (others => '0'),
		words => (others => '0'),
		sid   => 0,
		wid   => 0,
		count => 0,
		inv   => '0',
		flush => '0',
		busy  => '0',
		valid => '0',
		hit   => '0',
		load  => '0',
		store => '0',
		miss  => '0',
		dirty => '0',
		rden  => '0',
		wren  => '0',
		wen   => '0',
		wr    => '0',
		val   => '0',
		loc   => '0',
		equ   => '0',
		atm   => '0',
		atom  => '0',
		lock  => '0',
		error => '0',
		ready => '0'
	);

	signal r,rin : ctrl_type := init_ctrl_type;
	signal r_next,rin_next : data_type := init_data_type;

begin

	process(dtim_i,r,rin_next)

	variable v : ctrl_type;

	begin

		v := r;

		v.inv := '0';
		v.atom := '0';
		v.lock := '0';
		v.rden := '0';
		v.wren := '0';

		if dtim_i.mem_valid = '1' then
			if dtim_i.mem_invalid = '1' then
				v.inv := '1';
				v.sid := 0;
			else
				v.atom := dtim_i.mem_atomic;
				v.lock := dtim_i.mem_lock;
				v.rden := not(dtim_i.mem_write);
				v.wren := dtim_i.mem_write;
				v.data := dtim_i.mem_wdata;
				v.strb := dtim_i.mem_strb;
				v.addr := dtim_i.mem_addr;
				v.tag := dtim_i.mem_addr(63 downto dtim_sets+dtim_words+3);
				v.sid := to_integer(unsigned(dtim_i.mem_addr(dtim_sets+dtim_words+2 downto 3+dtim_words)));
				v.wid := to_integer(unsigned(dtim_i.mem_addr(dtim_words+2 downto 3)));
			end if;
		end if;

		if rin_next.inv = '1' then
			v.sid := rin_next.sid;
		end if;

		rin <= v;

	end process;

	process(dctrl_i,dmem_o,r,r_next,rin)

	variable v : data_type;

	begin

		v := r_next;

		v.atom := '0';
		v.lock := '0';
		v.rden := '0';
		v.wren := '0';
		v.inv := '0';
		v.hit := '0';
		v.atm := '0';
		v.load := '0';
		v.store := '0';
		v.miss := '0';
		v.flush := '0';
		v.error := '0';

		if r_next.state = HIT then
			v.atom := r.atom;
			v.lock := r.lock;
			v.rden := r.rden;
			v.wren := r.wren;
			v.addr := r.addr;
			v.data := r.data;
			v.strb := r.strb;
			v.tag := r.tag;
			v.sid := r.sid;
			v.wid := r.wid;
			v.wr := r.wren;
		end if;

		case r_next.state is

			when HIT =>

				v.wen := '0';
				v.loc := dctrl_i.lock_o.rdata;
				v.val := dctrl_i.valid_o.rdata;
				v.equ := nor_reduce(dctrl_i.tag_o.rdata xor v.tag);

				if v.val = '0' then
					if v.atom = '1' then
						v.atm := v.rden or v.wren;
					else
						v.miss := v.rden or v.wren;
					end if;
				else
					if v.equ = '0' then
						if v.atom = '1' then
							v.atm := v.rden or v.wren;
						else
							v.load := v.rden;
							v.store := v.wren;
						end if;
					else
						if v.loc = '1' then
							if v.atom = '1' then
								v.atm := v.rden or v.wren;
							else
								v.load := v.rden;
								v.store := v.wren;
							end if;
						else
							v.hit := v.rden or v.wren;
						end if;
					end if;
				end if;

				if v.atm = '1' then
					v.state := ATOM;
					v.store := v.wren;
					v.wdata := v.data;
					v.valid := '1';
				elsif v.miss = '1' then
					v.state := MISS;
					v.addr(dtim_words+2 downto 0) := (others => '0');
					v.count := 0;
					v.valid := '1';
				elsif (v.load or v.store) = '1' then
					v.state := LDST;
					v.store := v.wren;
					v.wdata := v.data;
					v.valid := '1';
				elsif v.hit = '1' then
					v.wen := '1';
					v.wr := v.wren;
					if v.wren = '1' then
						v.state := UPDATE;
					end if;
					v.words := dctrl_i.data_o.rdata;
					v.valid := '0';
				else
					v.valid := '0';
				end if;

				v.flush := '0';

			when MISS =>

				if dmem_o.mem_ready = '1' then

					for i in 0 to 2**dtim_words-1 loop
						if r_next.count = i then
							v.words(64*(i+1)-1 downto 64*i) := dmem_o.mem_rdata;
						end if;
					end loop;

					if v.count = 2**dtim_words-1 then
						v.wen := '1';
						v.val := '1';
						v.valid := '0';
						v.state := UPDATE;
					else
						v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
						v.count := v.count + 1;
					end if;

				end if;

				v.flush := '0';

			when LDST =>

				v.wen := '0';
				v.loc := '0';
				v.val := '0';
				v.equ := '0';
				v.valid := '0';

				if dmem_o.mem_ready = '1' then
					v.state := HIT;
				end if;

				v.flush := '0';

			when ATOM =>

				v.wen := '0';
				v.loc := '0';
				v.val := '0';
				v.equ := '0';
				v.valid := '0';

				if dmem_o.mem_ready = '1' then
					v.state := HIT;
					v.wen := '1';
					v.atm := '1';
					v.val := '1';
				end if;

				v.flush := '0';

			when UPDATE =>

				v.wen := '0';
				v.loc := '0';
				v.val := '0';
				v.equ := '0';
				v.valid := '0';
				v.state := HIT;

				v.flush := '0';

			when INVALIDATE =>

				v.wen := '0';
				v.equ := '0';

				v.tag := dctrl_i.tag_o.rdata;
				v.loc := dctrl_i.lock_o.rdata;
				v.val := dctrl_i.valid_o.rdata;
				v.words := dctrl_i.data_o.rdata;

				if v.val = '1' then
					v.addr(63 downto dtim_words+3) := v.tag & std_logic_vector(to_unsigned(v.sid,dtim_sets));
					v.addr(dtim_words+2 downto 0) := (others => '0');
					v.state := WRITEBACK;
				end if;

				v.count := 0;
				v.valid := '0';

				v.flush := '1';

			when WRITEBACK =>

				v.wen := '0';

				if dmem_o.mem_ready = '1' then
					if v.count /= 2**dtim_words-1 then
						v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
						v.count := v.count + 1;
					else
						v.valid := '0';
					end if;
				end if;

				for i in 0 to 2**dtim_words-1 loop
					if v.count = i then
						v.wdata := v.words(64*(i+1)-1 downto 64*i);
						v.store := '1';
						v.valid := '1';
					end if;
				end loop;

			when others =>

				null;

		end case;

		for i in 0 to 2**dtim_words-1 loop
			if v.wid = i and v.wr = '1' then
				for j in 0 to 7 loop
					if v.strb(j) = '1' then
						v.words(i*64+(j+1)*8-1 downto i*64+j*8) := v.data((j+1)*8-1 downto j*8);
					end if;
				end loop;
			end if;
		end loop;

		dctrl_o.tag_i.raddr <= rin.sid;
		dctrl_o.lock_i.raddr <= rin.sid;
		dctrl_o.data_i.raddr <= rin.sid;
		dctrl_o.valid_i.raddr <= rin.sid;

		dctrl_o.tag_i.waddr <= v.sid;
		dctrl_o.tag_i.wen <= v.wen;
		dctrl_o.tag_i.wdata <= v.tag;

		dctrl_o.data_i.waddr <= v.sid;
		dctrl_o.data_i.wen <= v.wen;
		dctrl_o.data_i.wdata <= v.words;

		dctrl_o.lock_i.waddr <= v.sid;
		dctrl_o.lock_i.wen <= v.wen or v.inv;
		dctrl_o.lock_i.wdata <= v.atm;

		dctrl_o.valid_i.waddr <= v.sid;
		dctrl_o.valid_i.wen <= v.wen or v.inv;
		dctrl_o.valid_i.wdata <= v.val;

		if v.state = INVALIDATE then
			if v.sid = 2**dtim_sets-1 then
				v.state := HIT;
			else
				v.sid := v.sid+1;
			end if;
		end if;

		if r.inv = '1' then
			v.sid := 0;
			v.state := INVALIDATE;
		end if;

		for i in 0 to 2**dtim_words-1 loop
			if v.wid = i then
				v.rdata := v.words(64*(i+1)-1 downto 64*i);
			end if;
		end loop;

		if r_next.state = HIT then
			v.ready := v.rden and v.hit;
			v.error := '0';
			v.busy := '0';
		elsif r_next.state = LDST then
			v.rdata := dmem_o.mem_rdata;
			v.ready := dmem_o.mem_ready;
			v.error := '0';
			v.busy := '0';
		elsif r_next.state = ATOM then
			v.rdata := dmem_o.mem_rdata;
			v.ready := dmem_o.mem_ready;
			v.error := dmem_o.mem_error;
			v.busy := '0';
		elsif r_next.state = UPDATE then
			v.ready := '1';
			v.error := '0';
			v.busy := '0';
		elsif r_next.state = INVALIDATE then
			if v.state = HIT then
				v.ready := '1';
				v.error := '0';
				v.busy := '0';
			else
				v.ready := '0';
				v.error := '0';
				v.busy := '1';
			end if;
		else
			v.ready := '0';
			v.error := '0';
			v.busy := '1';
		end if;

		dmem_i.mem_valid <= v.valid;
		dmem_i.mem_instr <= '0';
		dmem_i.mem_invalid <= '0';
		dmem_i.mem_spec <= '0';
		dmem_i.mem_atomic <= v.atom;
		dmem_i.mem_lock <= v.lock;
		dmem_i.mem_write <= v.store;
		dmem_i.mem_strb <= v.strb;
		dmem_i.mem_addr <= v.addr;
		dmem_i.mem_wdata <= v.wdata;

		dtim_o.mem_rdata <= v.rdata;
		dtim_o.mem_ready <= v.ready;
		dtim_o.mem_flush <= v.flush;
		dtim_o.mem_error <= v.error;
		dtim_o.mem_busy <= v.busy;

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
