-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity fetchctrl is
	generic(
		fetchbuffer_depth : integer := fetchbuffer_depth
	);
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		fetchctrl_i : in  fetchbuffer_in_type;
		fetchctrl_o : out fetchbuffer_out_type;
		fetchram_i  : out fetchram_in_type;
		fetchram_o  : in  fetchram_out_type;
		imem_o      : in  mem_out_type;
		imem_i      : out mem_in_type
	);
end fetchctrl;

architecture behavior of fetchctrl is

	type reg_type is record
		pc      : std_logic_vector(63 downto 0);
		npc     : std_logic_vector(63 downto 0);
		fpc     : std_logic_vector(63 downto 0);
		nfpc    : std_logic_vector(63 downto 0);
		instr   : std_logic_vector(31 downto 0);
		rdata   : std_logic_vector(63 downto 0);
		rdata1  : std_logic_vector(63 downto 0);
		rdata2  : std_logic_vector(63 downto 0);
		wdata   : std_logic_vector(63 downto 0);
		incr    : std_logic;
		oflow   : std_logic;
		wden1   : std_logic;
		wden2   : std_logic;
		rden1   : std_logic;
		rden2   : std_logic;
		ready   : std_logic;
		flush   : std_logic;
		busy    : std_logic;
		wren    : std_logic;
		valid   : std_logic;
		spec    : std_logic;
		fence   : std_logic;
		clear   : std_logic;
		nspec   : std_logic;
		nfence  : std_logic;
		waddr   : natural range 0 to 2**fetchbuffer_depth-1;
		raddr1  : natural range 0 to 2**fetchbuffer_depth-1;
		raddr2  : natural range 0 to 2**fetchbuffer_depth-1;
		stall   : std_logic;
	end record;

	constant init_reg : reg_type := (
		pc      => bram_base_addr,
		npc     => bram_base_addr,
		fpc     => bram_base_addr,
		nfpc    => bram_base_addr,
		instr   => nop,
		rdata   => (others => '0'),
		rdata1  => (others => '0'),
		rdata2  => (others => '0'),
		wdata   => (others => '0'),
		incr    => '0',
		oflow   => '0',
		wden1   => '0',
		wden2   => '0',
		rden1   => '0',
		rden2   => '0',
		ready   => '0',
		flush   => '0',
		busy    => '0',
		wren    => '0',
		valid   => '0',
		spec    => '0',
		fence   => '0',
		clear   => '0',
		nspec   => '0',
		nfence  => '0',
		waddr   => 0,
		raddr1  => 0,
		raddr2  => 1,
		stall   => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(r,fetchctrl_i,fetchram_o,imem_o)

	variable v : reg_type;

	begin

		v := r;

		v.instr := nop;
		v.stall := '0';
		v.incr := '0';
		v.wren := '0';
		v.wden1 := '0';
		v.wden2 := '0';
		v.rden1 := '0';
		v.rden2 := '0';

		v.valid := fetchctrl_i.valid;
		v.clear := fetchctrl_i.clear;
		v.spec := fetchctrl_i.spec;
		v.fence := fetchctrl_i.fence;
		v.pc := fetchctrl_i.pc;
		v.npc := fetchctrl_i.npc;

		v.rdata := imem_o.mem_rdata;
		v.ready := imem_o.mem_ready;
		v.flush := imem_o.mem_flush;
		v.busy := imem_o.mem_busy;

		if v.ready = '1' then
			if v.oflow = '1' and v.waddr < v.raddr1 then
				v.wren := '1';
			elsif v.oflow = '0' then
				v.wren := '1';
			end if;
			v.wdata := v.rdata;
		end if;

		if v.oflow = '0' and v.raddr1 < v.waddr then
			v.rden1 := '1';
		elsif v.oflow = '1' then
			v.rden1 := '1';
		end if;

		if v.oflow = '0' and v.raddr2 < v.waddr then
			v.rden2 := '1';
		elsif v.oflow = '1' and v.raddr2 /= v.waddr then
			v.rden2 := '1';
		end if;

		if v.wren = '1' and v.rden1 = '0' and v.waddr = v.raddr1 then
			v.wden1 := '1';
		end if;
		if v.wren = '1' and v.rden2 = '0' and v.waddr = v.raddr2 then
			v.wden2 := '1';
		end if;

		if (v.nfence or v.nspec or v.busy or v.flush) = '1' then
			v.wren := '0';
			v.wden1 := '0';
			v.wden2 := '0';
			v.rden1 := '0';
			v.rden2 := '0';
		end if;

		fetchram_i.wren <= v.wren;
		fetchram_i.waddr <= v.waddr;
		fetchram_i.wdata <= v.wdata;

		fetchram_i.raddr1 <= v.raddr1;
		fetchram_i.raddr2 <= v.raddr2;

		v.rdata1 := fetchram_o.rdata1;
		v.rdata2 := fetchram_o.rdata2;

		if v.wden1 = '1' then
			v.rden1 := v.wden1;
			v.rdata1 := v.wdata;
		end if;
		if v.wden2 = '1' then
			v.rden2 := v.wden2;
			v.rdata2 := v.wdata;
		end if;

		if v.pc(2 downto 1) = "00" then
			if v.rden1 = '1' then
				v.instr := v.rdata1(31 downto 0);
			else
				v.stall := '1';
			end if;
		elsif v.pc(2 downto 1) = "01" then
			if v.rden1 = '1' then
				v.instr := v.rdata1(47 downto 16);
			else
				v.stall := '1';
			end if;
		elsif v.pc(2 downto 1) = "10" then
			if v.rden1 = '1' then
				v.instr := v.rdata1(63 downto 32);
			else
				v.stall := '1';
			end if;
		elsif v.pc(2 downto 1) = "11" then
			if v.rden1 = '1' then
				if v.rdata1(49 downto 48) = "11" then
					if v.rden2 = '1' then
						v.instr := v.rdata2(15 downto 0) & v.rdata1(63 downto 48);
					else
						v.stall := '1';
					end if;
				else
					v.instr := X"0000" & v.rdata1(63 downto 48);
				end if;
			else
				v.stall := '1';
			end if;
		end if;

		if v.valid = '1' then
			if v.stall = '0' then
				if v.pc(2 downto 1) = "10" then
					if v.instr(1 downto 0) = "11" then
						v.incr := '1';
					end if;
				elsif v.pc(2 downto 1) = "11" then
					v.incr := '1';
				end if;
			end if;
		end if;

		if v.ready = '1' then
			if v.wren = '1' then
				if v.waddr = 2**fetchbuffer_depth-1 then
					v.oflow := '1';
					v.waddr := 0;
				else
					v.waddr := v.waddr + 1;
				end if;
				v.fpc := std_logic_vector(unsigned(v.fpc) + 8);
			end if;
		end if;

		if v.valid = '1' then
			if v.incr = '1' then
				if v.raddr1 = 2**fetchbuffer_depth-1 then
					v.oflow := '0';
					v.raddr1 := 0;
				else
					v.raddr1 := v.raddr1 + 1;
				end if;
				if v.raddr2 = 2**fetchbuffer_depth-1 then
					v.raddr2 := 0;
				else
					v.raddr2 := v.raddr2 + 1;
				end if;
			end if;
		end if;

		if v.valid = '1' then
			if v.spec = '1' then
				v.nfpc := v.npc(63 downto 3) & "000";
				v.nspec := '1';
				v.spec := '0';
				v.oflow := '0';
				v.waddr := 0;
				v.raddr1 := 0;
				v.raddr2 := 1;
			elsif v.fence = '1' then
				v.nfpc := v.npc(63 downto 3) & "000";
				v.nfence := '1';
				v.fence := '0';
				v.oflow := '0';
				v.waddr := 0;
				v.raddr1 := 0;
				v.raddr2 := 1;
			end if;
		end if;

		if v.ready = '1' then
			if v.valid = '1' then
				if v.nspec = '1' or v.nfence = '1' then
					v.fpc := v.nfpc;
					v.spec := v.nspec;
					v.fence := v.nfence;
					v.nspec := '0';
					v.nfence := '0';
				end if;
			end if;
		end if;

		fetchctrl_o.instr <= v.instr;
		fetchctrl_o.stall <= v.stall;
		fetchctrl_o.flush <= v.flush;

		imem_i.mem_valid <= not(v.clear);
		imem_i.mem_instr <= '1';
		imem_i.mem_spec <= v.spec;
		imem_i.mem_invalid <= v.fence;
		imem_i.mem_atomic <= '0';
		imem_i.mem_lock <= '0';
		imem_i.mem_write <= '0';
		imem_i.mem_strb <= (others => '0');
		imem_i.mem_addr <= v.fpc;
		imem_i.mem_wdata <= (others => '0');

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
