-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.functions.all;
use work.csr_constants.all;
use work.csr_wire.all;
use work.csr_functions.all;

entity csr_file is
	generic(
		pmp_enable  : boolean := pmp_enable;
		pmp_regions : integer := pmp_regions
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		csr_ri : in  csr_read_in_type;
		csr_wi : in  csr_write_in_type;
		csr_o  : out csr_out_type;
		csr_ei : in  csr_exception_in_type;
		csr_eo : out csr_exception_out_type;
		csr_ci : in  csr_counter_in_type
	);
end csr_file;

architecture behavior of csr_file is

	signal mcsr : csr_machine_register := init_csr_machine_reg;
	signal ucsr : csr_user_register := init_csr_user_reg;

	signal mode : std_logic_vector(1 downto 0);
	signal exc  : std_logic;
	signal mret : std_logic;

begin

	process(mcsr,ucsr,mode,exc,mret)

	begin

		csr_eo.fs <= mcsr.mstatus.fs;
		csr_eo.epc <= mcsr.mepc;
		csr_eo.frm <= ucsr.frm;
		csr_eo.pmpcfg <= mcsr.pmpcfg;
		csr_eo.pmpaddr <= mcsr.pmpaddr;
		csr_eo.mode <= mode;
		csr_eo.exc <= exc;
		csr_eo.mret <= mret;

		if mcsr.mtvec.mode = "01" then
			csr_eo.tvec <= std_logic_vector(unsigned(mcsr.mtvec.base) + unsigned(mcsr.mcause.code(61 downto 0))) & "00";
		else
			csr_eo.tvec <= mcsr.mtvec.base & "00";
		end if;

	end process;

	read_csr : process(csr_ri,mcsr,ucsr)

	variable csr_data : std_logic_vector(63 downto 0);

	begin

		csr_data := (others => '0');

		if csr_ri.rden = '1' then

			if csr_ri.raddr = csr_misa then
				csr_data := mcsr.misa.mxl & X"000000000" &
							mcsr.misa.z & mcsr.misa.y &
							mcsr.misa.x & mcsr.misa.w &
							mcsr.misa.v & mcsr.misa.u &
							mcsr.misa.t & mcsr.misa.s &
							mcsr.misa.r & mcsr.misa.q &
							mcsr.misa.p & mcsr.misa.o &
							mcsr.misa.n & mcsr.misa.m &
							mcsr.misa.l & mcsr.misa.k &
							mcsr.misa.j & mcsr.misa.i &
							mcsr.misa.h & mcsr.misa.g &
							mcsr.misa.f & mcsr.misa.e &
							mcsr.misa.d & mcsr.misa.c &
							mcsr.misa.b & mcsr.misa.a;
			elsif csr_ri.raddr = csr_mstatus then
				csr_data := mcsr.mstatus.sd & X"0000000" & "0" &
							mcsr.mstatus.uxl  & X"000" & "00" &
							mcsr.mstatus.mprv & "00"  &
							mcsr.mstatus.fs   &
							mcsr.mstatus.mpp  & "000"  &
							mcsr.mstatus.mpie & "00"  &
							mcsr.mstatus.upie &
							mcsr.mstatus.mie  & "00"  &
							mcsr.mstatus.uie;
			elsif csr_ri.raddr = csr_mip then
				csr_data := X"0000000000000" &
							mcsr.mip.meip & "00" &
							mcsr.mip.ueip &
							mcsr.mip.mtip & "00" &
							mcsr.mip.utip &
							mcsr.mip.msip & "00" &
							mcsr.mip.usip;
			elsif csr_ri.raddr = csr_mie then
				csr_data := X"0000000000000" &
							mcsr.mie.meie & "00" &
							mcsr.mie.ueie &
							mcsr.mie.mtie & "00" &
							mcsr.mie.utie &
							mcsr.mie.msie & "00" &
							mcsr.mie.usie;
			elsif csr_ri.raddr = csr_mcause then
				csr_data := mcsr.mcause.irpt & mcsr.mcause.code;
			elsif csr_ri.raddr = csr_mtvec then
				csr_data := mcsr.mtvec.base & mcsr.mtvec.mode;
			elsif csr_ri.raddr = csr_mtval then
				csr_data := mcsr.mtval;
			elsif csr_ri.raddr = csr_mepc then
				csr_data := mcsr.mepc;
			elsif csr_ri.raddr = csr_mscratch then
				csr_data := mcsr.mscratch;
			elsif csr_ri.raddr = csr_mideleg then
				csr_data := mcsr.mideleg;
			elsif csr_ri.raddr = csr_medeleg then
				csr_data := mcsr.medeleg;
			elsif csr_ri.raddr = csr_mcycle then
				csr_data := mcsr.mcycle;
			elsif csr_ri.raddr = csr_minstret then
				csr_data := mcsr.minstret;
			end if;

			if pmp_enable = true then

				if pmp_regions >= 8 then

					if csr_ri.raddr = csr_pmpcfg0 then
						csr_data := mcsr.pmpcfg(7).L & "00" & mcsr.pmpcfg(7).A & mcsr.pmpcfg(7).X & mcsr.pmpcfg(7).X & mcsr.pmpcfg(7).R &
									mcsr.pmpcfg(6).L & "00" & mcsr.pmpcfg(6).A & mcsr.pmpcfg(6).X & mcsr.pmpcfg(6).W & mcsr.pmpcfg(6).R &
									mcsr.pmpcfg(5).L & "00" & mcsr.pmpcfg(5).A & mcsr.pmpcfg(5).X & mcsr.pmpcfg(5).W & mcsr.pmpcfg(5).R &
									mcsr.pmpcfg(4).L & "00" & mcsr.pmpcfg(4).A & mcsr.pmpcfg(4).X & mcsr.pmpcfg(4).W & mcsr.pmpcfg(4).R &
									mcsr.pmpcfg(3).L & "00" & mcsr.pmpcfg(3).A & mcsr.pmpcfg(3).X & mcsr.pmpcfg(3).W & mcsr.pmpcfg(3).R &
									mcsr.pmpcfg(2).L & "00" & mcsr.pmpcfg(2).A & mcsr.pmpcfg(2).X & mcsr.pmpcfg(2).W & mcsr.pmpcfg(2).R &
									mcsr.pmpcfg(1).L & "00" & mcsr.pmpcfg(1).A & mcsr.pmpcfg(1).X & mcsr.pmpcfg(1).W & mcsr.pmpcfg(1).R &
									mcsr.pmpcfg(0).L & "00" & mcsr.pmpcfg(0).A & mcsr.pmpcfg(0).X & mcsr.pmpcfg(0).W & mcsr.pmpcfg(0).R;
					elsif csr_ri.raddr = csr_pmpaddr0 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(0)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr1 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(1)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr2 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(2)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr3 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(3)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr4 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(4)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr5 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(5)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr6 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(6)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr7 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(7)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr8 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(8)(53 downto 0);
					end if;

				elsif pmp_regions >= 16 then

					if csr_ri.raddr = csr_pmpcfg2 then
						csr_data := mcsr.pmpcfg(15).L & "00" & mcsr.pmpcfg(15).A & mcsr.pmpcfg(15).X & mcsr.pmpcfg(15).X & mcsr.pmpcfg(15).R &
									mcsr.pmpcfg(14).L & "00" & mcsr.pmpcfg(14).A & mcsr.pmpcfg(14).X & mcsr.pmpcfg(14).W & mcsr.pmpcfg(14).R &
									mcsr.pmpcfg(13).L & "00" & mcsr.pmpcfg(13).A & mcsr.pmpcfg(13).X & mcsr.pmpcfg(13).W & mcsr.pmpcfg(13).R &
									mcsr.pmpcfg(12).L & "00" & mcsr.pmpcfg(12).A & mcsr.pmpcfg(12).X & mcsr.pmpcfg(12).W & mcsr.pmpcfg(12).R &
									mcsr.pmpcfg(11).L & "00" & mcsr.pmpcfg(11).A & mcsr.pmpcfg(11).X & mcsr.pmpcfg(11).W & mcsr.pmpcfg(11).R &
									mcsr.pmpcfg(10).L & "00" & mcsr.pmpcfg(10).A & mcsr.pmpcfg(10).X & mcsr.pmpcfg(10).W & mcsr.pmpcfg(10).R &
									mcsr.pmpcfg(9).L & "00" & mcsr.pmpcfg(9).A & mcsr.pmpcfg(9).X & mcsr.pmpcfg(9).W & mcsr.pmpcfg(9).R &
									mcsr.pmpcfg(8).L & "00" & mcsr.pmpcfg(8).A & mcsr.pmpcfg(8).X & mcsr.pmpcfg(8).W & mcsr.pmpcfg(8).R;
					elsif csr_ri.raddr = csr_pmpaddr9 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(9)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr10 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(10)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr11 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(11)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr12 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(12)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr13 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(13)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr14 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(14)(53 downto 0);
					elsif csr_ri.raddr = csr_pmpaddr15 then
						csr_data := X"00" & "00" & mcsr.pmpaddr(15)(53 downto 0);
					end if;

				end if;

			end if;

			if csr_ri.raddr = csr_ucycle then
				csr_data := mcsr.mcycle;
			elsif csr_ri.raddr = csr_uinstret then
				csr_data := mcsr.minstret;
			end if;

			if csr_ri.raddr = csr_fcsr then
				csr_data := X"00000000000000" & ucsr.frm & ucsr.fflags;
			elsif csr_ri.raddr = csr_fflags then
				csr_data := X"00000000000000" & "000" & ucsr.fflags;
			elsif csr_ri.raddr = csr_frm then
				csr_data := X"000000000000000" & "0" & ucsr.frm;
			end if;

		end if;

		csr_o.data <= csr_data;

	end process;

	write_user_csr : process(clock)

	begin

		if rising_edge(clock) then

			if (csr_ci.fpu and (csr_ci.fpu_op.fflag)) = '1' then
				ucsr.fflags <= csr_ci.flags;
			end if;

			if csr_wi.wren = '1' then

				case csr_wi.waddr is
					when csr_fcsr =>
						ucsr.frm <= csr_wi.wdata(7 downto 5);
						ucsr.fflags <= csr_wi.wdata(4 downto 0);
					when csr_fflags =>
						ucsr.fflags <= csr_wi.wdata(4 downto 0);
					when csr_frm =>
						ucsr.frm <= csr_wi.wdata(2 downto 0);
					when others => null;
				end case;

			end if;

		end if;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = reset_active then

				mode <= m_mode;
				exc  <= '0';
				mret <= '0';

				mcsr.mstatus.mie <= '0';
				mcsr.mstatus.mprv <= '0';
				mcsr.misa <= init_csr_isa_reg;
				mcsr.mcause <= init_csr_cause_reg;

				if pmp_enable = true then
					if pmp_regions >= 8 then
						mcsr.pmpcfg(0).L <= '0';
						mcsr.pmpcfg(1).L <= '0';
						mcsr.pmpcfg(2).L <= '0';
						mcsr.pmpcfg(3).L <= '0';
						mcsr.pmpcfg(4).L <= '0';
						mcsr.pmpcfg(5).L <= '0';
						mcsr.pmpcfg(6).L <= '0';
						mcsr.pmpcfg(7).L <= '0';
						mcsr.pmpcfg(0).A <= (others => '0');
						mcsr.pmpcfg(1).A <= (others => '0');
						mcsr.pmpcfg(2).A <= (others => '0');
						mcsr.pmpcfg(3).A <= (others => '0');
						mcsr.pmpcfg(4).A <= (others => '0');
						mcsr.pmpcfg(5).A <= (others => '0');
						mcsr.pmpcfg(6).A <= (others => '0');
						mcsr.pmpcfg(7).A <= (others => '0');
					end if;
					if pmp_regions >= 16 then
						mcsr.pmpcfg(8).L <= '0';
						mcsr.pmpcfg(9).L <= '0';
						mcsr.pmpcfg(10).L <= '0';
						mcsr.pmpcfg(11).L <= '0';
						mcsr.pmpcfg(12).L <= '0';
						mcsr.pmpcfg(13).L <= '0';
						mcsr.pmpcfg(14).L <= '0';
						mcsr.pmpcfg(15).L <= '0';
						mcsr.pmpcfg(8).A <= (others => '0');
						mcsr.pmpcfg(9).A <= (others => '0');
						mcsr.pmpcfg(10).A <= (others => '0');
						mcsr.pmpcfg(11).A <= (others => '0');
						mcsr.pmpcfg(12).A <= (others => '0');
						mcsr.pmpcfg(13).A <= (others => '0');
						mcsr.pmpcfg(14).A <= (others => '0');
						mcsr.pmpcfg(15).A <= (others => '0');
					end if;
				end if;

			else

				mcsr.mcycle <= std_logic_vector(unsigned(mcsr.mcycle) + 1);

				if (csr_ci.int or csr_ci.fpu or csr_ci.csr) = '1' then
					mcsr.minstret <= std_logic_vector(unsigned(mcsr.minstret) + 1);
				end if;

				if csr_ei.meip = '1' then
					mcsr.mip.meip <= '1';
				else
					mcsr.mip.meip <= '0';
				end if;

				if csr_ei.msip = '1' then
					mcsr.mip.msip <= '1';
				else
					mcsr.mip.msip <= '0';
				end if;

				if csr_ei.mtip = '1' then
					mcsr.mip.mtip <= '1';
				else
					mcsr.mip.mtip <= '0';
				end if;

				if mcsr.mstatus.mie = '1' and mcsr.mie.mtie = '1' and mcsr.mip.mtip = '1' then
					mcsr.mstatus.mpie <= mcsr.mstatus.mie;
					mcsr.mstatus.mpp <= mode;
					mcsr.mstatus.mie <= '0';
					if csr_ei.d_valid = '1' then
						mcsr.mepc <= csr_ei.d_epc;
					elsif csr_ei.e_valid = '1' then
						mcsr.mepc <= csr_ei.e_epc;
					elsif csr_ei.m_valid = '1' then
						mcsr.mepc <= csr_ei.m_epc;
					elsif csr_ei.w_valid = '1' then
						mcsr.mepc <= csr_ei.w_epc;
					end if;
					mcsr.mtval <= X"0000000000000000";
					mcsr.mcause.irpt <= '1';
					mcsr.mcause.code <= X"00000000000000" & "000" & interrupt_mach_timer;
					mode <= m_mode;
					exc <= '1';
				elsif mcsr.mstatus.mie = '1' and mcsr.mie.meie = '1' and mcsr.mip.meip = '1' then
					mcsr.mstatus.mpie <= mcsr.mstatus.mie;
					mcsr.mstatus.mpp <= mode;
					mcsr.mstatus.mie <= '0';
					if csr_ei.d_valid = '1' then
						mcsr.mepc <= csr_ei.d_epc;
					elsif csr_ei.e_valid = '1' then
						mcsr.mepc <= csr_ei.e_epc;
					elsif csr_ei.m_valid = '1' then
						mcsr.mepc <= csr_ei.m_epc;
					elsif csr_ei.w_valid = '1' then
						mcsr.mepc <= csr_ei.w_epc;
					end if;
					mcsr.mtval <= X"0000000000000000";
					mcsr.mcause.irpt <= '1';
					mcsr.mcause.code <= X"00000000000000" & "000" & interrupt_mach_extern;
					mode <= m_mode;
					exc <= '1';
				elsif csr_ei.exc = '1' then
					mcsr.mstatus.mpie <= mcsr.mstatus.mie;
					mcsr.mstatus.mpp <= mode;
					mcsr.mstatus.mie <= '0';
					mcsr.mepc <= csr_ei.d_epc;
					mcsr.mtval <= csr_ei.etval;
					mcsr.mcause.irpt <= '0';
					mcsr.mcause.code <= X"00000000000000" & "000" & csr_ei.ecause;
					mode <= m_mode;
					exc <= '1';
				else
					exc <= '0';
				end if;

				if csr_ei.mret = '1' then
					mode <= mcsr.mstatus.mpp;
					mcsr.mstatus.mie <= mcsr.mstatus.mpie;
					mcsr.mstatus.mpie <= '0';
					mcsr.mstatus.mpp <= u_mode;
					mret <= '1';
				else
					mret <= '0';
				end if;

				if csr_wi.wren = '1' then

					if csr_wi.waddr = csr_mstatus then
						mcsr.mstatus.sd   <= csr_wi.wdata(63);
						mcsr.mstatus.mprv <= csr_wi.wdata(17);
						mcsr.mstatus.fs   <= csr_wi.wdata(14 downto 13);
						if xor_reduce(csr_wi.wdata(12 downto 11)) = '0' then
							mcsr.mstatus.mpp  <= csr_wi.wdata(12 downto 11);
						end if;
						mcsr.mstatus.mpie <= csr_wi.wdata(7);
						mcsr.mstatus.upie <= csr_wi.wdata(4);
						mcsr.mstatus.mie  <= csr_wi.wdata(3);
						mcsr.mstatus.uie  <= csr_wi.wdata(0);
					elsif csr_wi.waddr = csr_mie then
						mcsr.mie.meie <= csr_wi.wdata(11);
						mcsr.mie.ueie <= csr_wi.wdata(8);
						mcsr.mie.mtie <= csr_wi.wdata(7);
						mcsr.mie.utie <= csr_wi.wdata(4);
						mcsr.mie.msie <= csr_wi.wdata(3);
						mcsr.mie.usie <= csr_wi.wdata(0);
					elsif csr_wi.waddr = csr_mcause then
						mcsr.mcause.irpt <= csr_wi.wdata(63);
						mcsr.mcause.code <= csr_wi.wdata(62 downto 0);
					elsif csr_wi.waddr = csr_mtvec then
						mcsr.mtvec.base <= csr_wi.wdata(63 downto 2);
						mcsr.mtvec.mode <= csr_wi.wdata(1 downto 0);
					elsif csr_wi.waddr = csr_mtval then
						mcsr.mtval <= csr_wi.wdata;
					elsif csr_wi.waddr = csr_mepc then
						mcsr.mepc <= csr_wi.wdata;
					elsif csr_wi.waddr = csr_mscratch then
						mcsr.mscratch <= csr_wi.wdata;
					elsif csr_wi.waddr = csr_mideleg then
						mcsr.mideleg <= csr_wi.wdata;
					elsif csr_wi.waddr = csr_medeleg then
						mcsr.medeleg <= csr_wi.wdata;
					end if;

					if pmp_enable = true then

						if pmp_regions >= 8 then

							if csr_wi.waddr = csr_pmpcfg0 then
								if mcsr.pmpcfg(7).L = '0' then
									mcsr.pmpcfg(7).L <= csr_wi.wdata(63);
									mcsr.pmpcfg(7).A <= csr_wi.wdata(60 downto 59);
									mcsr.pmpcfg(7).X <= csr_wi.wdata(58);
									mcsr.pmpcfg(7).W <= csr_wi.wdata(57);
									mcsr.pmpcfg(7).R <= csr_wi.wdata(56);
								end if;
								if mcsr.pmpcfg(6).L = '0' then
									mcsr.pmpcfg(6).L <= csr_wi.wdata(55);
									mcsr.pmpcfg(6).A <= csr_wi.wdata(52 downto 51);
									mcsr.pmpcfg(6).X <= csr_wi.wdata(50);
									mcsr.pmpcfg(6).W <= csr_wi.wdata(49);
									mcsr.pmpcfg(6).R <= csr_wi.wdata(48);
								end if;
								if mcsr.pmpcfg(5).L = '0' then
									mcsr.pmpcfg(5).L <= csr_wi.wdata(47);
									mcsr.pmpcfg(5).A <= csr_wi.wdata(44 downto 43);
									mcsr.pmpcfg(5).X <= csr_wi.wdata(42);
									mcsr.pmpcfg(5).W <= csr_wi.wdata(41);
									mcsr.pmpcfg(5).R <= csr_wi.wdata(40);
								end if;
								if mcsr.pmpcfg(4).L = '0' then
									mcsr.pmpcfg(4).L <= csr_wi.wdata(39);
									mcsr.pmpcfg(4).A <= csr_wi.wdata(36 downto 35);
									mcsr.pmpcfg(4).X <= csr_wi.wdata(34);
									mcsr.pmpcfg(4).W <= csr_wi.wdata(33);
									mcsr.pmpcfg(4).R <= csr_wi.wdata(32);
								end if;
								if mcsr.pmpcfg(3).L = '0' then
									mcsr.pmpcfg(3).L <= csr_wi.wdata(31);
									mcsr.pmpcfg(3).A <= csr_wi.wdata(28 downto 27);
									mcsr.pmpcfg(3).X <= csr_wi.wdata(26);
									mcsr.pmpcfg(3).W <= csr_wi.wdata(25);
									mcsr.pmpcfg(3).R <= csr_wi.wdata(24);
								end if;
								if mcsr.pmpcfg(2).L = '0' then
									mcsr.pmpcfg(2).L <= csr_wi.wdata(23);
									mcsr.pmpcfg(2).A <= csr_wi.wdata(20 downto 19);
									mcsr.pmpcfg(2).X <= csr_wi.wdata(18);
									mcsr.pmpcfg(2).W <= csr_wi.wdata(17);
									mcsr.pmpcfg(2).R <= csr_wi.wdata(16);
								end if;
								if mcsr.pmpcfg(1).L = '0' then
									mcsr.pmpcfg(1).L <= csr_wi.wdata(15);
									mcsr.pmpcfg(1).A <= csr_wi.wdata(12 downto 11);
									mcsr.pmpcfg(1).X <= csr_wi.wdata(10);
									mcsr.pmpcfg(1).W <= csr_wi.wdata(9);
									mcsr.pmpcfg(1).R <= csr_wi.wdata(8);
								end if;
								if mcsr.pmpcfg(0).L = '0' then
									mcsr.pmpcfg(0).L <= csr_wi.wdata(7);
									mcsr.pmpcfg(0).A <= csr_wi.wdata(4 downto 3);
									mcsr.pmpcfg(0).X <= csr_wi.wdata(2);
									mcsr.pmpcfg(0).W <= csr_wi.wdata(1);
									mcsr.pmpcfg(0).R <= csr_wi.wdata(0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr0 then
								if mcsr.pmpcfg(0).L = '0' and mcsr.pmpcfg(1).A /= "01" then
									mcsr.pmpaddr(0)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr1 then
								if mcsr.pmpcfg(1).L = '0' and mcsr.pmpcfg(2).A /= "01" then
									mcsr.pmpaddr(1)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr2 then
								if mcsr.pmpcfg(2).L = '0' and mcsr.pmpcfg(3).A /= "01" then
									mcsr.pmpaddr(2)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr3 then
								if mcsr.pmpcfg(3).L = '0' and mcsr.pmpcfg(4).A /= "01" then
									mcsr.pmpaddr(3)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr4 then
								if mcsr.pmpcfg(4).L = '0' and mcsr.pmpcfg(5).A /= "01" then
									mcsr.pmpaddr(4)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr5 then
								if mcsr.pmpcfg(5).L = '0' and mcsr.pmpcfg(6).A /= "01" then
									mcsr.pmpaddr(5)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr6 then
								if mcsr.pmpcfg(6).L = '0' and mcsr.pmpcfg(7).A /= "01" then
									mcsr.pmpaddr(6)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr7 then
								if mcsr.pmpcfg(7).L = '0' and mcsr.pmpcfg(8).A /= "01" then
									mcsr.pmpaddr(7)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							end if;

						end if;

						if pmp_regions >= 16 then

							if csr_wi.waddr = csr_pmpcfg2 then
								if mcsr.pmpcfg(15).L = '0' then
									mcsr.pmpcfg(15).L <= csr_wi.wdata(63);
									mcsr.pmpcfg(15).A <= csr_wi.wdata(60 downto 59);
									mcsr.pmpcfg(15).X <= csr_wi.wdata(58);
									mcsr.pmpcfg(15).W <= csr_wi.wdata(57);
									mcsr.pmpcfg(15).R <= csr_wi.wdata(56);
								end if;
								if mcsr.pmpcfg(14).L = '0' then
									mcsr.pmpcfg(14).L <= csr_wi.wdata(55);
									mcsr.pmpcfg(14).A <= csr_wi.wdata(52 downto 51);
									mcsr.pmpcfg(14).X <= csr_wi.wdata(50);
									mcsr.pmpcfg(14).W <= csr_wi.wdata(49);
									mcsr.pmpcfg(14).R <= csr_wi.wdata(48);
								end if;
								if mcsr.pmpcfg(13).L = '0' then
									mcsr.pmpcfg(13).L <= csr_wi.wdata(47);
									mcsr.pmpcfg(13).A <= csr_wi.wdata(44 downto 43);
									mcsr.pmpcfg(13).X <= csr_wi.wdata(42);
									mcsr.pmpcfg(13).W <= csr_wi.wdata(41);
									mcsr.pmpcfg(13).R <= csr_wi.wdata(40);
								end if;
								if mcsr.pmpcfg(12).L = '0' then
									mcsr.pmpcfg(12).L <= csr_wi.wdata(39);
									mcsr.pmpcfg(12).A <= csr_wi.wdata(36 downto 35);
									mcsr.pmpcfg(12).X <= csr_wi.wdata(34);
									mcsr.pmpcfg(12).W <= csr_wi.wdata(33);
									mcsr.pmpcfg(12).R <= csr_wi.wdata(32);
								end if;
								if mcsr.pmpcfg(11).L = '0' then
									mcsr.pmpcfg(11).L <= csr_wi.wdata(31);
									mcsr.pmpcfg(11).A <= csr_wi.wdata(28 downto 27);
									mcsr.pmpcfg(11).X <= csr_wi.wdata(26);
									mcsr.pmpcfg(11).W <= csr_wi.wdata(25);
									mcsr.pmpcfg(11).R <= csr_wi.wdata(24);
								end if;
								if mcsr.pmpcfg(10).L = '0' then
									mcsr.pmpcfg(10).L <= csr_wi.wdata(23);
									mcsr.pmpcfg(10).A <= csr_wi.wdata(20 downto 19);
									mcsr.pmpcfg(10).X <= csr_wi.wdata(18);
									mcsr.pmpcfg(10).W <= csr_wi.wdata(17);
									mcsr.pmpcfg(10).R <= csr_wi.wdata(16);
								end if;
								if mcsr.pmpcfg(9).L = '0' then
									mcsr.pmpcfg(9).L <= csr_wi.wdata(15);
									mcsr.pmpcfg(9).A <= csr_wi.wdata(12 downto 11);
									mcsr.pmpcfg(9).X <= csr_wi.wdata(10);
									mcsr.pmpcfg(9).W <= csr_wi.wdata(9);
									mcsr.pmpcfg(9).R <= csr_wi.wdata(8);
								end if;
								if mcsr.pmpcfg(8).L = '0' then
									mcsr.pmpcfg(8).L <= csr_wi.wdata(7);
									mcsr.pmpcfg(8).A <= csr_wi.wdata(4 downto 3);
									mcsr.pmpcfg(8).X <= csr_wi.wdata(2);
									mcsr.pmpcfg(8).W <= csr_wi.wdata(1);
									mcsr.pmpcfg(8).R <= csr_wi.wdata(0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr8 then
								if mcsr.pmpcfg(8).L = '0' and mcsr.pmpcfg(9).A /= "01" then
									mcsr.pmpaddr(8)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr9 then
								if mcsr.pmpcfg(9).L = '0' and mcsr.pmpcfg(10).A /= "01" then
									mcsr.pmpaddr(9)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr10 then
								if mcsr.pmpcfg(10).L = '0' and mcsr.pmpcfg(11).A /= "01" then
									mcsr.pmpaddr(10)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr11 then
								if mcsr.pmpcfg(11).L = '0' and mcsr.pmpcfg(12).A /= "01" then
									mcsr.pmpaddr(11)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr12 then
								if mcsr.pmpcfg(12).L = '0' and mcsr.pmpcfg(13).A /= "01" then
									mcsr.pmpaddr(12)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr13 then
								if mcsr.pmpcfg(13).L = '0' and mcsr.pmpcfg(14).A /= "01" then
									mcsr.pmpaddr(13)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr14 then
								if mcsr.pmpcfg(14).L = '0' and mcsr.pmpcfg(15).A /= "01" then
									mcsr.pmpaddr(14)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							elsif csr_wi.waddr = csr_pmpaddr15 then
								if mcsr.pmpcfg(15).L = '0' then
									mcsr.pmpaddr(15)(53 downto 0) <= csr_wi.wdata(53 downto 0);
								end if;
							end if;

						end if;

					end if;

				end if;

			end if;

		end if;

	end process;

end architecture;
