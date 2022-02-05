-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.functions.all;
use work.lzc_wire.all;
use work.fp_cons.all;
use work.fp_typ.all;
use work.fp_wire.all;

entity fp_fma is
	port(
		reset    : in  std_logic;
		clock    : in  std_logic;
		fp_fma_i : in  fp_fma_in_type;
		fp_fma_o : out fp_fma_out_type;
		lzc_o    : in  lzc_256_out_type;
		lzc_i    : out lzc_256_in_type
	);
end fp_fma;

architecture behavior of fp_fma is

	signal r_1 : fp_fma_reg_type_1 := init_fp_fma_reg_1;
	signal r_2 : fp_fma_reg_type_2 := init_fp_fma_reg_2;
	signal r_3 : fp_fma_reg_type_3 := init_fp_fma_reg_3;
	signal r_4 : fp_fma_reg_type_4 := init_fp_fma_reg_4;

	signal rin_1 : fp_fma_reg_type_1 := init_fp_fma_reg_1;
	signal rin_2 : fp_fma_reg_type_2 := init_fp_fma_reg_2;
	signal rin_3 : fp_fma_reg_type_3 := init_fp_fma_reg_3;
	signal rin_4 : fp_fma_reg_type_4 := init_fp_fma_reg_4;

begin

	process(fp_fma_i)
		variable a          : std_logic_vector(64 downto 0);
		variable b          : std_logic_vector(64 downto 0);
		variable c          : std_logic_vector(64 downto 0);
		variable class_a    : std_logic_vector(9 downto 0);
		variable class_b    : std_logic_vector(9 downto 0);
		variable class_c    : std_logic_vector(9 downto 0);
		variable fmt        : std_logic_vector(1 downto 0);
		variable rm         : std_logic_vector(2 downto 0);
		variable snan       : std_logic;
		variable qnan       : std_logic;
		variable dbz        : std_logic;
		variable inf        : std_logic;
		variable zero       : std_logic;
		variable neg        : std_logic;
		variable sign_a     : std_logic;
		variable exponent_a : std_logic_vector(11 downto 0);
		variable mantissa_a : std_logic_vector(52 downto 0);
		variable sign_b     : std_logic;
		variable exponent_b : std_logic_vector(11 downto 0);
		variable mantissa_b : std_logic_vector(52 downto 0);
		variable sign_c     : std_logic;
		variable exponent_c : std_logic_vector(11 downto 0);
		variable mantissa_c : std_logic_vector(52 downto 0);
		variable ready      : std_logic;

	begin
		a       := fp_fma_i.data1;
		b       := fp_fma_i.data2;
		c       := fp_fma_i.data3;
		class_a := fp_fma_i.class1;
		class_b := fp_fma_i.class2;
		class_c := fp_fma_i.class3;
		fmt     := fp_fma_i.fmt;
		rm      := fp_fma_i.rm;
		snan    := '0';
		qnan    := '0';
		dbz     := '0';
		inf     := '0';
		zero    := '0';
		neg     := fp_fma_i.op.fnmsub or fp_fma_i.op.fnmadd;
		ready   := fp_fma_i.enable and (fp_fma_i.op.fmadd or fp_fma_i.op.fmsub or
										fp_fma_i.op.fnmsub or fp_fma_i.op.fnmadd or
										fp_fma_i.op.fadd or fp_fma_i.op.fsub or
										fp_fma_i.op.fmul);

		if (fp_fma_i.op.fadd or fp_fma_i.op.fsub) = '1' then
			c       := b;
			class_c := class_b;
			b       := (62 downto 52 => '1', others => '0'); -- +1.0
			class_b := (6 => '1', others => '0');
		end if;

		if (fp_fma_i.op.fmsub or fp_fma_i.op.fnmsub or fp_fma_i.op.fsub) = '1' then
			c(64) := not c(64);
		end if;

		if fp_fma_i.op.fmul = '1' then
			c       := (64 => a(64) xor b(64), others => '0');
			class_c := (others => '0');
		end if;

		sign_a     := a(64);
		exponent_a := a(63 downto 52);
		mantissa_a := or_reduce(exponent_a) & a(51 downto 0);

		sign_b     := b(64);
		exponent_b := b(63 downto 52);
		mantissa_b := or_reduce(exponent_b) & b(51 downto 0);

		sign_c     := c(64);
		exponent_c := c(63 downto 52);
		mantissa_c := or_reduce(exponent_c) & c(51 downto 0);

		if (class_a(8) or class_b(8) or class_c(8)) = '1' then
			snan := '1';
		elsif (((class_a(3) or class_a(4)) and (class_b(0) or class_b(7))) or ((class_b(3) or class_b(4)) and (class_a(0) or class_a(7)))) = '1' then
			snan := '1';
		elsif (class_a(9) or class_b(9) or class_c(9)) = '1' then
			qnan := '1';
		elsif (((class_a(0) or class_a(7)) or (class_b(0) or class_b(7))) and ((class_c(0) or class_c(7)) and to_std_logic((a(64) xor b(64)) /= c(64)))) = '1' then
			snan := '1';
		elsif ((class_a(0) or class_a(7)) or (class_b(0) or class_b(7)) or (class_c(0) or class_c(7))) = '1' then
			inf := '1';
		end if;

		rin_1.fmt <= fmt;
		rin_1.rm <= rm;
		rin_1.snan <= snan;
		rin_1.qnan <= qnan;
		rin_1.dbz <= dbz;
		rin_1.inf <= inf;
		rin_1.zero <= zero;
		rin_1.neg <= neg;
		rin_1.sign_a <= sign_a;
		rin_1.exponent_a <= exponent_a;
		rin_1.mantissa_a <= mantissa_a;
		rin_1.sign_b <= sign_b;
		rin_1.exponent_b <= exponent_b;
		rin_1.mantissa_b <= mantissa_b;
		rin_1.sign_c <= sign_c;
		rin_1.exponent_c <= exponent_c;
		rin_1.mantissa_c <= mantissa_c;
		if fp_fma_i.clear = '1' then
			rin_1.ready <= '0';
		else
			rin_1.ready <= ready;
		end if;

	end process;

	process(r_1, fp_fma_i)
		variable fmt        : std_logic_vector(1 downto 0);
		variable rm         : std_logic_vector(2 downto 0);
		variable snan       : std_logic;
		variable qnan       : std_logic;
		variable dbz        : std_logic;
		variable inf        : std_logic;
		variable zero       : std_logic;
		variable neg        : std_logic;
		variable sign_a     : std_logic;
		variable exponent_a : std_logic_vector(11 downto 0);
		variable mantissa_a : std_logic_vector(52 downto 0);
		variable sign_b     : std_logic;
		variable exponent_b : std_logic_vector(11 downto 0);
		variable mantissa_b : std_logic_vector(52 downto 0);
		variable sign_c     : std_logic;
		variable exponent_c : std_logic_vector(11 downto 0);
		variable mantissa_c : std_logic_vector(52 downto 0);
		variable ready      : std_logic;

		variable sign_mul     : std_logic;
		variable exponent_mul : signed(13 downto 0);
		variable mantissa_mul : std_logic_vector(163 downto 0);

		variable sign_add     : std_logic;
		variable exponent_add : signed(13 downto 0);
		variable mantissa_add : std_logic_vector(163 downto 0);

		variable mantissa_l : std_logic_vector(163 downto 0);
		variable mantissa_r : std_logic_vector(163 downto 0);

		variable exponent_dif : signed(13 downto 0);
		variable counter_dif  : integer range 0 to 127;

		variable exponent_neg : std_logic;

	begin
		fmt        := r_1.fmt;
		rm         := r_1.rm;
		snan       := r_1.snan;
		qnan       := r_1.qnan;
		dbz        := r_1.dbz;
		inf        := r_1.inf;
		zero       := r_1.zero;
		neg        := r_1.neg;
		sign_a     := r_1.sign_a;
		exponent_a := r_1.exponent_a;
		mantissa_a := r_1.mantissa_a;
		sign_b     := r_1.sign_b;
		exponent_b := r_1.exponent_b;
		mantissa_b := r_1.mantissa_b;
		sign_c     := r_1.sign_c;
		exponent_c := r_1.exponent_c;
		mantissa_c := r_1.mantissa_c;
		ready      := r_1.ready;

		sign_add := sign_c;
		sign_mul := sign_a xor sign_b;

		exponent_add := signed("00" & exponent_c);
		exponent_mul := signed("00" & exponent_a) + signed("00" & exponent_b) - 2047;

		if and_reduce(exponent_c) = '1' then
			exponent_add := "00" & X"FFF";
		end if;
		if (and_reduce(exponent_a) or and_reduce(exponent_b)) = '1' then
			exponent_mul := "00" & X"FFF";
		end if;

		mantissa_add := "000" & mantissa_c & X"000000000000000000000000000";
		mantissa_mul := "00" & std_logic_vector(unsigned(mantissa_a) * unsigned(mantissa_b)) & X"00000000000000";

		exponent_dif := exponent_mul - exponent_add;
		counter_dif  := 0;

		exponent_neg := exponent_dif(13);

		if exponent_neg = '1' then
			counter_dif := 56;
			if exponent_dif > -56 then
				counter_dif := -to_integer(exponent_dif);
			end if;
			mantissa_l  := mantissa_add;
			mantissa_r  := mantissa_mul;
		else
			counter_dif := 108;
			if exponent_dif < 108 then
				counter_dif := to_integer(exponent_dif);
			end if;
			mantissa_l  := mantissa_mul;
			mantissa_r  := mantissa_add;
		end if;

		mantissa_r := std_logic_vector(shift_right(unsigned(mantissa_r),counter_dif));

		if exponent_neg = '1' then
			mantissa_add := mantissa_l;
			mantissa_mul := mantissa_r;
		else
			mantissa_add := mantissa_r;
			mantissa_mul := mantissa_l;
		end if;

		rin_2.fmt <= fmt;
		rin_2.rm <= rm;
		rin_2.snan <= snan;
		rin_2.qnan <= qnan;
		rin_2.dbz <= dbz;
		rin_2.inf <= inf;
		rin_2.zero <= zero;
		rin_2.neg <= neg;
		rin_2.sign_mul <= sign_mul;
		rin_2.exponent_mul <= exponent_mul;
		rin_2.mantissa_mul <= mantissa_mul;
		rin_2.sign_add <= sign_add;
		rin_2.exponent_add <= exponent_add;
		rin_2.mantissa_add <= mantissa_add;
		rin_2.exponent_neg <= exponent_neg;
		if fp_fma_i.clear = '1' then
			rin_2.ready <= '0';
		else
			rin_2.ready <= ready;
		end if;

	end process;

	process(r_2, fp_fma_i)
		variable fmt          : std_logic_vector(1 downto 0);
		variable rm           : std_logic_vector(2 downto 0);
		variable snan         : std_logic;
		variable qnan         : std_logic;
		variable dbz          : std_logic;
		variable inf          : std_logic;
		variable zero         : std_logic;
		variable neg          : std_logic;
		variable sign_mul     : std_logic;
		variable not_mul      : integer range 0 to 1;
		variable exponent_mul : signed(13 downto 0);
		variable mantissa_mul : std_logic_vector(163 downto 0);
		variable sign_add     : std_logic;
		variable not_add      : integer range 0 to 1;
		variable exponent_add : signed(13 downto 0);
		variable mantissa_add : std_logic_vector(163 downto 0);
		variable exponent_neg : std_logic;
		variable ready        : std_logic;

		variable sign_mac     : std_logic;
		variable exponent_mac : signed(13 downto 0);
		variable mantissa_mac : std_logic_vector(163 downto 0);

		variable sign_acc : std_logic;

	begin
		fmt          := r_2.fmt;
		rm           := r_2.rm;
		snan         := r_2.snan;
		qnan         := r_2.qnan;
		dbz          := r_2.dbz;
		inf          := r_2.inf;
		zero         := r_2.zero;
		neg          := r_2.neg;
		sign_mul     := r_2.sign_mul;
		exponent_mul := r_2.exponent_mul;
		mantissa_mul := r_2.mantissa_mul;
		sign_add     := r_2.sign_add;
		exponent_add := r_2.exponent_add;
		mantissa_add := r_2.mantissa_add;
		exponent_neg := r_2.exponent_neg;
		ready        := r_2.ready;

		if exponent_neg = '1' then
			exponent_mac := exponent_add;
		else
			exponent_mac := exponent_mul;
		end if;

		if sign_add = '1' then
			mantissa_add := not mantissa_add;
			not_add := 1;
		else
			not_add := 0;
		end if;
		if sign_mul = '1' then
			mantissa_mul := not mantissa_mul;
			not_mul := 1;
		else
			not_mul := 0;
		end if;

		mantissa_mac := std_logic_vector(signed(mantissa_add) + signed(mantissa_mul) + not_add + not_mul);
		sign_mac     := mantissa_mac(163);

		zero := nor_reduce(mantissa_mac);

		if zero = '1' then
			sign_mac := sign_add and sign_mul;
		elsif sign_mac = '1' then
			mantissa_mac := std_logic_vector(-signed(mantissa_mac));
		end if;

		rin_3.fmt <= fmt;
		rin_3.rm <= rm;
		rin_3.snan <= snan;
		rin_3.qnan <= qnan;
		rin_3.dbz <= dbz;
		rin_3.inf <= inf;
		rin_3.zero <= zero;
		rin_3.neg <= neg;
		rin_3.sign_mac <= sign_mac;
		rin_3.exponent_mac <= exponent_mac;
		rin_3.mantissa_mac <= mantissa_mac;
		if fp_fma_i.clear = '1' then
			rin_3.ready <= '0';
		else
			rin_3.ready <= ready;
		end if;

	end process;

	process(r_3, lzc_o, fp_fma_i)
		variable fmt          : std_logic_vector(1 downto 0);
		variable rm           : std_logic_vector(2 downto 0);
		variable snan         : std_logic;
		variable qnan         : std_logic;
		variable dbz          : std_logic;
		variable inf          : std_logic;
		variable zero         : std_logic;
		variable neg          : std_logic;
		variable sign_mac     : std_logic;
		variable exponent_mac : signed(13 downto 0);
		variable mantissa_mac : std_logic_vector(163 downto 0);
		variable ready        : std_logic;

		variable mantissa_lzc : std_logic_vector(255 downto 0);

		variable counter_mac : integer range 0 to 255;
		variable counter_sub : integer range 0 to 63;

		variable bias : integer range 0 to 2047;

		variable sign_rnd     : std_logic;
		variable exponent_rnd : integer range -8191 to 8191;
		variable mantissa_rnd : std_logic_vector(53 downto 0);
		variable grs          : std_logic_vector(2 downto 0);

	begin
		fmt          := r_3.fmt;
		rm           := r_3.rm;
		snan         := r_3.snan;
		qnan         := r_3.qnan;
		dbz          := r_3.dbz;
		inf          := r_3.inf;
		zero         := r_3.zero;
		neg          := r_3.neg;
		sign_mac     := r_3.sign_mac;
		exponent_mac := r_3.exponent_mac;
		mantissa_mac := r_3.mantissa_mac;
		ready        := r_3.ready;

		bias := 1918;
		if fmt = "01" then
			bias := 1022;
		end if;

		mantissa_lzc := mantissa_mac(162 downto 0) & "1" & X"FFFFFFFFFFFFFFFFFFFFFFF";

		lzc_i.a      <= mantissa_lzc;
		if ready = '1' then
			counter_mac := to_integer(unsigned(not (lzc_o.c)));
		else
			counter_mac := 0;
		end if;
		mantissa_mac := std_logic_vector(shift_left(unsigned(mantissa_mac),counter_mac));

		sign_rnd     := sign_mac xor neg;
		exponent_rnd := to_integer(exponent_mac) - bias - counter_mac;

		counter_sub := 0;
		if exponent_rnd <= 0 then
			counter_sub  := 63;
			if exponent_rnd > -63 then
				counter_sub := 1 - exponent_rnd;
			end if;
			exponent_rnd := 0;
		end if;

		mantissa_mac := std_logic_vector(shift_right(unsigned(mantissa_mac),counter_sub));

		mantissa_rnd := "00" & X"0000000" & mantissa_mac(162 downto 139);
		grs          := mantissa_mac(138 downto 137) & or_reduce(mantissa_mac(136 downto 0));
		if fmt = "01" then
			mantissa_rnd := "0" & mantissa_mac(162 downto 110);
			grs          := mantissa_mac(109 downto 108) & or_reduce(mantissa_mac(107 downto 0));
		end if;

		rin_4.sign_rnd <= sign_rnd;
		rin_4.exponent_rnd <= exponent_rnd;
		rin_4.mantissa_rnd <= mantissa_rnd;
		rin_4.fmt <= fmt;
		rin_4.rm <= rm;
		rin_4.grs <= grs;
		rin_4.snan <= snan;
		rin_4.qnan <= qnan;
		rin_4.dbz <= dbz;
		rin_4.inf <= inf;
		rin_4.zero <= zero;
		if fp_fma_i.clear = '1' then
			rin_4.ready <= '0';
		else
			rin_4.ready <= ready;
		end if;

	end process;

	process(r_4, fp_fma_i)
	begin
		fp_fma_o.fp_rnd.sig <= r_4.sign_rnd;
		fp_fma_o.fp_rnd.expo <= r_4.exponent_rnd;
		fp_fma_o.fp_rnd.mant <= r_4.mantissa_rnd;
		fp_fma_o.fp_rnd.rema <= "00";
		fp_fma_o.fp_rnd.fmt <= r_4.fmt;
		fp_fma_o.fp_rnd.rm <= r_4.rm;
		fp_fma_o.fp_rnd.grs <= r_4.grs;
		fp_fma_o.fp_rnd.snan <= r_4.snan;
		fp_fma_o.fp_rnd.qnan <= r_4.qnan;
		fp_fma_o.fp_rnd.dbz <= r_4.dbz;
		fp_fma_o.fp_rnd.inf <= r_4.inf;
		fp_fma_o.fp_rnd.zero <= r_4.zero;
		fp_fma_o.ready <= r_4.ready;
		if fp_fma_i.clear = '1' then
			fp_fma_o.ready <= '0';
		else
			fp_fma_o.ready <= r_4.ready;
		end if;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = reset_active then

				r_1 <= init_fp_fma_reg_1;
				r_2 <= init_fp_fma_reg_2;
				r_3 <= init_fp_fma_reg_3;
				r_4 <= init_fp_fma_reg_4;

			else

				r_1 <= rin_1;
				r_2 <= rin_2;
				r_3 <= rin_3;
				r_4 <= rin_4;

			end if;

		end if;

	end process;

end behavior;
