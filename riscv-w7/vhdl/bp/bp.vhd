-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;

entity bp is
	generic(
		bp_enable : boolean := bp_enable;
		btb_depth : integer := btb_depth;
		bht_depth : integer := bht_depth;
		ras_depth : integer := ras_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		bp_i  : in  bp_in_type;
		bp_o  : out bp_out_type;
		bht_i : out bht_in_type;
		bht_o : in  bht_out_type;
		btb_i : out btb_in_type;
		btb_o : in  btb_out_type;
		ras_i : out ras_in_type;
		ras_o : in  ras_out_type
	);
end bp;

architecture behavior of bp is

	type reg_btb_type is record
		wpc    : std_logic_vector(63 downto 0);
		rpc    : std_logic_vector(63 downto 0);
		wid    : integer range 0 to 2**btb_depth-1;
		rid    : integer range 0 to 2**btb_depth-1;
		waddr  : std_logic_vector(63 downto 0);
		update : std_logic;
	end record;

	constant init_reg_btb : reg_btb_type := (
		wpc    => (others => '0'),
		rpc    => (others => '0'),
		wid    => 0,
		rid    => 0,
		waddr  => (others => '0'),
		update => '0'
	);

	type reg_bht_type is record
		history : std_logic_vector(bht_depth-1 downto 0);
		get_ind : integer range 0 to 2**bht_depth-1;
		get_sat : unsigned(1 downto 0);
		upd_ind : integer range 0 to 2**bht_depth-1;
		upd_sat : unsigned(1 downto 0);
		update  : std_logic;
	end record;

	constant init_reg_bht : reg_bht_type := (
		history => (others => '0'),
		get_ind => 0,
		get_sat => (others => '0'),
		upd_ind => 0,
		upd_sat => (others => '0'),
		update  => '0'
	);

	type reg_ras_type is record
		count  : integer range 0 to 2**ras_depth;
		rid    : integer range 0 to 2**ras_depth-1;
		wid    : integer range 0 to 2**ras_depth-1;
		waddr  : std_logic_vector(63 downto 0);
		update : std_logic;
	end record;

	constant init_reg_ras : reg_ras_type := (
		count  => 0,
		rid    => 0,
		wid    => 0,
		waddr  => (others => '0'),
		update => '0'
	);

	signal r_btb, rin_btb : reg_btb_type := init_reg_btb;
	signal r_bht, rin_bht : reg_bht_type := init_reg_bht;
	signal r_ras, rin_ras : reg_ras_type := init_reg_ras;

begin

	BP_ON : if bp_enable = true generate

		branch_target_buffer : process(r_btb,bp_i,btb_o)

		variable v : reg_btb_type;

		begin

			v := r_btb;

			if bp_i.clear = '0' then
				v.rpc := bp_i.get_pc;
				v.rid := to_integer(unsigned(v.rpc(btb_depth downto 1)));
			end if;

			if bp_i.clear = '0' then
				v.wpc := bp_i.upd_pc;
				v.waddr := bp_i.upd_addr;
				v.wid := to_integer(unsigned(v.wpc(btb_depth downto 1)));
			end if;

			btb_i.raddr <= v.rid;

			if bp_i.upd_jump = '0' and bp_i.stall = '0' and bp_i.clear = '0' and
					nor_reduce(btb_o.rdata(126-btb_depth downto 64) xor v.rpc(63 downto btb_depth+1)) = '1' then
				bp_o.pred_baddr <= btb_o.rdata(63 downto 0);
				bp_o.pred_branch <= bp_i.get_branch;
				bp_o.pred_uncond <= bp_i.get_uncond;
			else
				bp_o.pred_baddr <= (others => '0');
				bp_o.pred_branch <= '0';
				bp_o.pred_uncond <= '0';
			end if;

			v.update := (bp_i.upd_branch and bp_i.upd_jump) or bp_i.upd_uncond;

			btb_i.wen <= v.update;
			btb_i.waddr <= v.wid;
			btb_i.wdata <= v.wpc(63 downto btb_depth+1) & v.waddr;

			rin_btb <= v;

		end process;

		branch_history_table : process(r_bht,bp_i,bht_o)

		variable v : reg_bht_type;

		begin

			v := r_bht;

			if bp_i.clear = '0' then
				v.upd_ind := to_integer(unsigned(v.history xor bp_i.upd_pc(bht_depth downto 1)));
			end if;

			bht_i.raddr1 <= v.upd_ind;
			v.upd_sat := bht_o.rdata1;

			if bp_i.clear = '0' then
				v.get_ind := to_integer(unsigned(v.history xor bp_i.get_pc(bht_depth downto 1)));
			end if;

			bht_i.raddr2 <= v.get_ind;
			v.get_sat := bht_o.rdata2;

			if bp_i.upd_branch = '1' then
				v.history := v.history(bht_depth-2 downto 0) & '0';
				if bp_i.upd_jump = '1' then
					v.history(0) := '1';
					if v.upd_sat < 3 then
						v.upd_sat := v.upd_sat + 1;
					end if;
				elsif bp_i.upd_jump = '0' then
					if v.upd_sat > 0 then
						v.upd_sat := v.upd_sat - 1;
					end if;
				end if;
			end if;

			if bp_i.get_branch = '1' and bp_i.upd_jump = '0' and bp_i.stall = '0' and
					bp_i.clear = '0' then
				bp_o.pred_jump <= v.get_sat(1);
			else
				bp_o.pred_jump <= '0';
			end if;

			v.update := bp_i.upd_branch;

			bht_i.wen <= v.update;
			bht_i.waddr <= v.upd_ind;
			bht_i.wdata <= v.upd_sat;

			rin_bht <= v;

		end process;

		return_address_stack : process(r_ras,bp_i,ras_o)

		variable v : reg_ras_type;

		begin

			v := r_ras;

			v.waddr := bp_i.upd_npc;

			if bp_i.upd_return = '1' then
				if v.count < 2**ras_depth then
					v.count := v.count + 1;
				end if;
				v.rid := v.wid;
				if v.wid < 2**ras_depth-1 then
					v.wid := v.wid + 1;
				else
					v.wid := 0;
				end if;
			end if;

			ras_i.raddr <= v.rid;

			if bp_i.get_return = '1' and bp_i.upd_jump = '0' and bp_i.stall = '0' and
					bp_i.clear = '0' and v.count > 0 then
				bp_o.pred_raddr <= ras_o.rdata;
				bp_o.pred_return <= '1';
				v.count := v.count - 1;
				v.wid := v.rid;
				if v.rid > 0 then
					v.rid := v.rid - 1;
				else
					v.rid := 2**ras_depth-1;
				end if;
			else
				bp_o.pred_raddr <= (others => '0');
				bp_o.pred_return <= '0';
			end if;

			v.update := bp_i.upd_return;

			ras_i.wen <= v.update;
			ras_i.waddr <= r_ras.wid;
			ras_i.wdata <= v.waddr;

			rin_ras <= v;

		end process;

		process(clock)

		begin

			if rising_edge(clock) then

				if reset = reset_active then

					r_btb <= init_reg_btb;
					r_bht <= init_reg_bht;
					r_ras <= init_reg_ras;

				else

					r_btb <= rin_btb;
					r_bht <= rin_bht;
					r_ras <= rin_ras;

				end if;

			end if;

		end process;

	end generate BP_ON;

	BP_OFF : if bp_enable = false generate

		bp_o.pred_baddr <= (others => '0');
		bp_o.pred_branch <= '0';
		bp_o.pred_jump <= '0';
		bp_o.pred_raddr <= (others => '0');
		bp_o.pred_return <= '0';
		bp_o.pred_uncond <= '0';

		btb_i.raddr <= 0;
		btb_i.wen <= '0';
		btb_i.waddr <= 0;
		btb_i.wdata <= (others => '0');

		bht_i.raddr1 <= 0;
		bht_i.raddr2 <= 0;
		bht_i.wen <= '0';
		bht_i.waddr <= 0;
		bht_i.wdata <= (others => '0');

		ras_i.raddr <= 0;
		ras_i.wen <= '0';
		ras_i.waddr <= 0;
		ras_i.wdata <= (others => '0');

	end generate BP_OFF;

end architecture;
