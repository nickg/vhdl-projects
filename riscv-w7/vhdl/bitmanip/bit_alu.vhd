-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bit_constants.all;
use work.bit_wire.all;
use work.bit_functions.all;

entity bit_alu is
	port(
		bit_alu_i : in  bit_alu_in_type;
		bit_alu_o : out bit_alu_out_type
	);
end bit_alu;

architecture behavior of bit_alu is

begin

	process(bit_alu_i)

		variable res  : std_logic_vector(63 downto 0);
		variable rs1  : std_logic_vector(63 downto 0);
		variable rs2  : std_logic_vector(63 downto 0);
		variable int  : integer range 0 to 3;
		variable op   : std_logic_vector(1 downto 0);
		variable word : std_logic;

		variable bit_zba : zba_operation_type;
		variable bit_zbb : zbb_operation_type;
		variable bit_zbs : zbs_operation_type;

	begin

		res := (others => '0');
		rs1 := bit_alu_i.rs1;
		rs2 := multiplexer(bit_alu_i.rs2, bit_alu_i.imm, bit_alu_i.sel);
		int := 0;
		op := (others => '0');
		word := bit_alu_i.word;

		bit_zba := bit_alu_i.bit_op.bit_zba;
		bit_zbb := bit_alu_i.bit_op.bit_zbb;
		bit_zbs := bit_alu_i.bit_op.bit_zbs;

		if bit_zba.bit_sh1add = '1' then
			int := 1;
		elsif bit_zba.bit_sh2add = '1' then
			int := 2;
		elsif bit_zba.bit_sh3add = '1' then
			int := 3;
		end if;

		if bit_zbb.bit_max = '1' then
			op := "00";
		elsif bit_zbb.bit_maxu = '1' then
			op := "01";
		elsif bit_zbb.bit_min = '1' then
			op := "10";
		elsif bit_zbb.bit_minu = '1' then
			op := "11";
		end if;

		if bit_zba.bit_add = '1' then
			res := bit_add(rs1,rs2);
		elsif (bit_zba.bit_sh1add or bit_zba.bit_sh2add or bit_zba.bit_sh3add) = '1' then
			res := bit_shadd(rs1,rs2,int,word);
		elsif bit_zba.bit_slli = '1' then
			res := bit_slli(rs1,rs2);
		elsif bit_zbb.bit_andn = '1' then
			res := bit_andn(rs1,rs2);
		elsif bit_zbb.bit_orn = '1' then
			res := bit_orn(rs1,rs2);
		elsif bit_zbb.bit_xnor = '1' then
			res := bit_xnor(rs1,rs2);
		elsif bit_zbb.bit_clz = '1' then
			res := bit_clz(rs1,word);
		elsif bit_zbb.bit_cpop = '1' then
			res := bit_cpop(rs1,word);
		elsif bit_zbb.bit_ctz = '1' then
			res := bit_ctz(rs1,word);
		elsif (bit_zbb.bit_max or bit_zbb.bit_maxu or bit_zbb.bit_min or bit_zbb.bit_minu) = '1' then
			res := bit_minmax(rs1,rs2,op);
		elsif  bit_zbb.bit_orcb = '1' then
			res := bit_orcb(rs1);
		elsif  bit_zbb.bit_rev8 = '1' then
			res := bit_rev8(rs1);
		elsif  bit_zbb.bit_rol = '1' then
			res := bit_rol(rs1,rs2,word);
		elsif  bit_zbb.bit_ror = '1' then
			res := bit_ror(rs1,rs2,word);
		elsif bit_zbb.bit_sextb = '1' then
			res := bit_sextb(rs1);
		elsif bit_zbb.bit_sexth = '1' then
			res := bit_sexth(rs1);
		elsif bit_zbb.bit_zexth = '1' then
			res := bit_zexth(rs1);
		elsif  bit_zbs.bit_bclr = '1' then
			res := bit_bclr(rs1,rs2);
		elsif  bit_zbs.bit_bext = '1' then
			res := bit_bext(rs1,rs2);
		elsif  bit_zbs.bit_binv = '1' then
			res := bit_binv(rs1,rs2);
		elsif  bit_zbs.bit_bset = '1' then
			res := bit_bset(rs1,rs2);
		end if;

		bit_alu_o.res <= res;

	end process;

end architecture;
