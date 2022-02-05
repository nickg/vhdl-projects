-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.functions.all;
use work.lzc_wire.all;
use work.fp_cons.all;
use work.fp_typ.all;
use work.fp_wire.all;

entity fp_exe is
	port(
		fp_exe_i     : in  fp_exe_in_type;
		fp_exe_o     : out fp_exe_out_type;
		fp_ext1_o    : in  fp_ext_out_type;
		fp_ext1_i    : out fp_ext_in_type;
		fp_ext2_o    : in  fp_ext_out_type;
		fp_ext2_i    : out fp_ext_in_type;
		fp_ext3_o    : in  fp_ext_out_type;
		fp_ext3_i    : out fp_ext_in_type;
		fp_cmp_o     : in  fp_cmp_out_type;
		fp_cmp_i     : out fp_cmp_in_type;
		fp_cvt_f2f_o : in  fp_cvt_f2f_out_type;
		fp_cvt_f2f_i : out fp_cvt_f2f_in_type;
		fp_cvt_f2i_o : in  fp_cvt_f2i_out_type;
		fp_cvt_f2i_i : out fp_cvt_f2i_in_type;
		fp_cvt_i2f_o : in  fp_cvt_i2f_out_type;
		fp_cvt_i2f_i : out fp_cvt_i2f_in_type;
		fp_max_o     : in  fp_max_out_type;
		fp_max_i     : out fp_max_in_type;
		fp_sgnj_o    : in  fp_sgnj_out_type;
		fp_sgnj_i    : out fp_sgnj_in_type;
		fp_fma_o     : in  fp_fma_out_type;
		fp_fma_i     : out fp_fma_in_type;
		fp_fdiv_o    : in  fp_fdiv_out_type;
		fp_fdiv_i    : out fp_fdiv_in_type;
		fp_rnd_o     : in  fp_rnd_out_type;
		fp_rnd_i     : out fp_rnd_in_type
	);
end fp_exe;

architecture behavior of fp_exe is

begin

	process(fp_exe_i,fp_ext1_o, fp_ext2_o, fp_ext3_o,
					fp_cmp_o, fp_max_o, fp_sgnj_o, fp_cvt_f2f_o,
					fp_cvt_f2i_o, fp_cvt_i2f_o, fp_fma_o, fp_fdiv_o,
					fp_rnd_o)

		variable v : fp_exe_reg_type;

	begin

		v.idata  := fp_exe_i.idata;
		v.data1  := fp_exe_i.data1;
		v.data2  := fp_exe_i.data2;
		v.data3  := fp_exe_i.data3;
		v.op     := fp_exe_i.op;
		v.fmt    := fp_exe_i.fmt;
		v.rm     := fp_exe_i.rm;
		v.enable := fp_exe_i.enable;
		v.clear  := fp_exe_i.clear;

		v.result := (others => '0');
		v.flags  := (others => '0');
		v.ready  := '0';

		v.fp_rnd := init_fp_rnd_in;

		-- NAN Boxing
		-------------------------------------------------
		if v.fmt = "00" then
			if v.op.fnan = '1' then
				if and_reduce(v.data1(63 downto 32)) = '0' then
					v.data1 := X"000000007FC00000";
				end if;
				if and_reduce(v.data2(63 downto 32)) = '0' then
					v.data2 := X"000000007FC00000";
				end if;
				if and_reduce(v.data3(63 downto 32)) = '0' then
					v.data3 := X"000000007FC00000";
				end if;
			end if;
		end if;
		-------------------------------------------------

		if v.op.fcvt_f2f = '1' then
			v.fmt_ext := fp_exe_i.op.fcvt_op;
		else
			v.fmt_ext := fp_exe_i.fmt;
		end if;

		fp_ext1_i.data <= v.data1;
		fp_ext1_i.fmt <= v.fmt_ext;
		fp_ext1_i.enable <= v.enable;
		fp_ext2_i.data <= v.data2;
		fp_ext2_i.fmt <= v.fmt_ext;
		fp_ext2_i.enable <= v.enable;
		fp_ext3_i.data <= v.data3;
		fp_ext3_i.fmt <= v.fmt_ext;
		fp_ext3_i.enable <= v.enable;

		v.ext1 := fp_ext1_o.result;
		v.ext2 := fp_ext2_o.result;
		v.ext3 := fp_ext3_o.result;

		v.class1 := fp_ext1_o.class;
		v.class2 := fp_ext2_o.class;
		v.class3 := fp_ext3_o.class;

		fp_cmp_i.data1 <= v.ext1;
		fp_cmp_i.data2 <= v.ext2;
		fp_cmp_i.rm <= v.rm;
		fp_cmp_i.class1 <= v.class1;
		fp_cmp_i.class2 <= v.class2;
		fp_cmp_i.enable <= v.enable;

		fp_max_i.data1 <= v.data1;
		fp_max_i.data2 <= v.data2;
		fp_max_i.ext1 <= v.ext1;
		fp_max_i.ext2 <= v.ext2;
		fp_max_i.fmt <= v.fmt;
		fp_max_i.rm <= v.rm;
		fp_max_i.class1 <= v.class1;
		fp_max_i.class2 <= v.class2;
		fp_max_i.enable <= v.enable;

		fp_sgnj_i.data1 <= v.data1;
		fp_sgnj_i.data2 <= v.data2;
		fp_sgnj_i.fmt <= v.fmt;
		fp_sgnj_i.rm <= v.rm;

		fp_cvt_i2f_i.data <= v.idata;
		fp_cvt_i2f_i.op <= v.op;
		fp_cvt_i2f_i.fmt <= v.fmt;
		fp_cvt_i2f_i.rm <= v.rm;
		fp_cvt_i2f_i.enable <= v.enable;

		fp_cvt_f2f_i.data <= v.ext1;
		fp_cvt_f2f_i.fmt <= v.fmt;
		fp_cvt_f2f_i.rm <= v.rm;
		fp_cvt_f2f_i.class <= v.class1;
		fp_cvt_f2f_i.enable <= v.enable;

		fp_cvt_f2i_i.data <= v.ext1;
		fp_cvt_f2i_i.op <= v.op;
		fp_cvt_f2i_i.rm <= v.rm;
		fp_cvt_f2i_i.class <= v.class1;
		fp_cvt_f2i_i.enable <= v.enable;

		fp_fma_i.data1 <= v.ext1;
		fp_fma_i.data2 <= v.ext2;
		fp_fma_i.data3 <= v.ext3;
		fp_fma_i.class1 <= v.class1;
		fp_fma_i.class2 <= v.class2;
		fp_fma_i.class3 <= v.class3;
		fp_fma_i.op <= v.op;
		fp_fma_i.fmt <= v.fmt;
		fp_fma_i.rm <= v.rm;
		fp_fma_i.enable <= v.enable;
		fp_fma_i.clear <= v.clear;

		fp_fdiv_i.data1 <= v.ext1;
		fp_fdiv_i.data2 <= v.ext2;
		fp_fdiv_i.class1 <= v.class1;
		fp_fdiv_i.class2 <= v.class2;
		fp_fdiv_i.op <= v.op;
		fp_fdiv_i.fmt <= v.fmt;
		fp_fdiv_i.rm <= v.rm;
		fp_fdiv_i.enable <= v.enable;
		fp_fdiv_i.clear <= v.clear;

		if fp_fma_o.ready = '1' then
			v.fp_rnd := fp_fma_o.fp_rnd;
		elsif fp_fdiv_o.ready = '1' then
			v.fp_rnd := fp_fdiv_o.fp_rnd;
		elsif v.op.fcvt_f2f = '1' then
			v.fp_rnd := fp_cvt_f2f_o.fp_rnd;
		elsif v.op.fcvt_i2f = '1' then
			v.fp_rnd := fp_cvt_i2f_o.fp_rnd;
		end if;

		fp_rnd_i <= v.fp_rnd;

		if fp_fma_o.ready = '1' then
			v.result := fp_rnd_o.result;
			v.flags  := fp_rnd_o.flags;
			v.ready  := '1';
		elsif fp_fdiv_o.ready = '1' then
			v.result := fp_rnd_o.result;
			v.flags  := fp_rnd_o.flags;
			v.ready  := '1';
		elsif v.op.fmadd = '1' then
			v.ready := '0';
		elsif v.op.fmsub = '1' then
			v.ready := '0';
		elsif v.op.fnmsub = '1' then
			v.ready := '0';
		elsif v.op.fnmadd = '1' then
			v.ready := '0';
		elsif v.op.fadd = '1' then
			v.ready := '0';
		elsif v.op.fsub = '1' then
			v.ready := '0';
		elsif v.op.fmul = '1' then
			v.ready := '0';
		elsif v.op.fdiv = '1' then
			v.ready := '0';
		elsif v.op.fsqrt = '1' then
			v.ready := '0';
		elsif v.op.fsgnj = '1' then
			v.result := fp_sgnj_o.result;
			v.flags  := "00000";
		elsif v.op.fmax = '1' then
			v.result := fp_max_o.result;
			v.flags  := fp_max_o.flags;
		elsif v.op.fcmp = '1' then
			v.result := fp_cmp_o.result;
			v.flags  := fp_cmp_o.flags;
		elsif v.op.fclass = '1' then
			v.result := "00" & X"0000000000000" & v.class1;
			v.flags  := "00000";
		elsif v.op.fmv_f2i = '1' then
			v.result := v.data1;
			if nor_reduce(v.fmt) = '1' then
				v.result(63 downto 32) := (others => v.data1(31));
			end if;
			v.flags  := "00000";
		elsif v.op.fmv_i2f = '1' then
			v.result := v.idata;
			if nor_reduce(v.fmt) = '1' then
				v.result(63 downto 32) := (others => '1');
			end if;
			v.flags  := "00000";
		elsif v.op.fcvt_f2f = '1' then
			v.result := fp_rnd_o.result;
			v.flags  := fp_rnd_o.flags;
		elsif v.op.fcvt_i2f = '1' then
			v.result := fp_rnd_o.result;
			v.flags  := fp_rnd_o.flags;
		elsif v.op.fcvt_f2i = '1' then
			v.result := fp_cvt_f2i_o.result;
			v.flags  := fp_cvt_f2i_o.flags;
		end if;

		fp_exe_o.result <= v.result;
		fp_exe_o.flags <= v.flags;
		fp_exe_o.ready <= v.ready;

	end process;

end behavior;
