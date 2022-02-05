-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.lzc_lib.all;
use work.fp_cons.all;
use work.fp_typ.all;
use work.fp_wire.all;
use work.fp_lib.all;

entity fpu is
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		fpu_i     : in  fpu_in_type;
		fpu_o     : out fpu_out_type
	);
end fpu;

architecture behavior of fpu is

	signal lzc1_64_i : lzc_64_in_type;
	signal lzc1_64_o : lzc_64_out_type;
	signal lzc2_64_i : lzc_64_in_type;
	signal lzc2_64_o : lzc_64_out_type;
	signal lzc3_64_i : lzc_64_in_type;
	signal lzc3_64_o : lzc_64_out_type;
	signal lzc4_64_i : lzc_64_in_type;
	signal lzc4_64_o : lzc_64_out_type;

	signal lzc_256_i : lzc_256_in_type;
	signal lzc_256_o : lzc_256_out_type;

	signal fp_ext1_i : fp_ext_in_type;
	signal fp_ext1_o : fp_ext_out_type;
	signal fp_ext2_i : fp_ext_in_type;
	signal fp_ext2_o : fp_ext_out_type;
	signal fp_ext3_i : fp_ext_in_type;
	signal fp_ext3_o : fp_ext_out_type;

	signal fp_cmp_o  : fp_cmp_out_type;
	signal fp_cmp_i  : fp_cmp_in_type;
	signal fp_max_o  : fp_max_out_type;
	signal fp_max_i  : fp_max_in_type;
	signal fp_sgnj_o : fp_sgnj_out_type;
	signal fp_sgnj_i : fp_sgnj_in_type;
	signal fp_fma_i  : fp_fma_in_type;
	signal fp_fma_o  : fp_fma_out_type;

	signal fp_mac_i : fp_mac_in_type;
	signal fp_mac_o : fp_mac_out_type;

	signal fp_fdiv_i : fp_fdiv_in_type;
	signal fp_fdiv_o : fp_fdiv_out_type;

	signal fp_cvt_f2f_o : fp_cvt_f2f_out_type;
	signal fp_cvt_f2f_i : fp_cvt_f2f_in_type;
	signal fp_cvt_f2i_o : fp_cvt_f2i_out_type;
	signal fp_cvt_f2i_i : fp_cvt_f2i_in_type;
	signal fp_cvt_i2f_o : fp_cvt_i2f_out_type;
	signal fp_cvt_i2f_i : fp_cvt_i2f_in_type;

	signal fp_rnd_i : fp_rnd_in_type;
	signal fp_rnd_o : fp_rnd_out_type;

begin

	fp_dec_comp : fp_dec
		port map(
			fp_dec_i => fpu_i.fp_dec_i,
			fp_dec_o => fpu_o.fp_dec_o
		);

	fp_exe_comp : fp_exe
		port map(
			fp_exe_i     => fpu_i.fp_exe_i,
			fp_exe_o     => fpu_o.fp_exe_o,
			fp_ext1_o    => fp_ext1_o,
			fp_ext1_i    => fp_ext1_i,
			fp_ext2_o    => fp_ext2_o,
			fp_ext2_i    => fp_ext2_i,
			fp_ext3_o    => fp_ext3_o,
			fp_ext3_i    => fp_ext3_i,
			fp_cmp_o     => fp_cmp_o,
			fp_cmp_i     => fp_cmp_i,
			fp_cvt_f2f_o => fp_cvt_f2f_o,
			fp_cvt_f2f_i => fp_cvt_f2f_i,
			fp_cvt_f2i_o => fp_cvt_f2i_o,
			fp_cvt_f2i_i => fp_cvt_f2i_i,
			fp_cvt_i2f_o => fp_cvt_i2f_o,
			fp_cvt_i2f_i => fp_cvt_i2f_i,
			fp_max_o     => fp_max_o,
			fp_max_i     => fp_max_i,
			fp_sgnj_o    => fp_sgnj_o,
			fp_sgnj_i    => fp_sgnj_i,
			fp_fma_o     => fp_fma_o,
			fp_fma_i     => fp_fma_i,
			fp_fdiv_o    => fp_fdiv_o,
			fp_fdiv_i    => fp_fdiv_i,
			fp_rnd_o     => fp_rnd_o,
			fp_rnd_i     => fp_rnd_i
		);

	fp_reg_comp : fp_reg
		port map(
			reset     => reset,
			clock     => clock,
			fp_reg_ri => fpu_i.fp_reg_ri,
			fp_reg_wi => fpu_i.fp_reg_wi,
			fp_reg_o  => fpu_o.fp_reg_o
		);

	fp_for_comp : fp_for
		port map(
			fp_for_i => fpu_i.fp_for_i,
			fp_for_o => fpu_o.fp_for_o
		);

	lzc1_64_comp : lzc_64
		port map(
			A => lzc1_64_i.a,
			Z => lzc1_64_o.c
		);

	lzc2_64_comp : lzc_64
		port map(
			A => lzc2_64_i.a,
			Z => lzc2_64_o.c
		);

	lzc3_64_comp : lzc_64
		port map(
			A => lzc3_64_i.a,
			Z => lzc3_64_o.c
		);

	lzc4_64_comp : lzc_64
		port map(
			A => lzc4_64_i.a,
			Z => lzc4_64_o.c
		);

	lzc_256_comp : lzc_256
		port map(
			A => lzc_256_i.a,
			Z => lzc_256_o.c
		);

	fp_ext1_comp : fp_ext
		port map(
			fp_ext_i => fp_ext1_i,
			fp_ext_o => fp_ext1_o,
			lzc_o    => lzc1_64_o,
			lzc_i    => lzc1_64_i
		);

	fp_ext2_comp : fp_ext
		port map(
			fp_ext_i => fp_ext2_i,
			fp_ext_o => fp_ext2_o,
			lzc_o    => lzc2_64_o,
			lzc_i    => lzc2_64_i
		);

	fp_ext3_comp : fp_ext
		port map(
			fp_ext_i => fp_ext3_i,
			fp_ext_o => fp_ext3_o,
			lzc_o    => lzc3_64_o,
			lzc_i    => lzc3_64_i
		);

	fp_cmp_comp : fp_cmp
		port map(
			fp_cmp_i => fp_cmp_i,
			fp_cmp_o => fp_cmp_o
		);

	fp_rnd_comp : fp_rnd
		port map(
			fp_rnd_i => fp_rnd_i,
			fp_rnd_o => fp_rnd_o
		);

	fp_cvt_comp : fp_cvt
		port map(
			fp_cvt_f2f_i => fp_cvt_f2f_i,
			fp_cvt_f2f_o => fp_cvt_f2f_o,
			fp_cvt_f2i_i => fp_cvt_f2i_i,
			fp_cvt_f2i_o => fp_cvt_f2i_o,
			fp_cvt_i2f_i => fp_cvt_i2f_i,
			fp_cvt_i2f_o => fp_cvt_i2f_o,
			lzc_i        => lzc4_64_i,
			lzc_o        => lzc4_64_o
		);

	fp_sgnj_comp : fp_sgnj
		port map(
			fp_sgnj_i => fp_sgnj_i,
			fp_sgnj_o => fp_sgnj_o
		);

	fp_max_comp : fp_max
		port map(
			fp_max_i => fp_max_i,
			fp_max_o => fp_max_o
		);

	fp_fma_comp : fp_fma
		port map(
			reset    => reset,
			clock    => clock,
			fp_fma_i => fp_fma_i,
			fp_fma_o => fp_fma_o,
			lzc_o    => lzc_256_o,
			lzc_i    => lzc_256_i
		);

	fp_mac_comp : fp_mac
		port map(
			fp_mac_i => fp_mac_i,
			fp_mac_o => fp_mac_o
		);

	fp_fdiv_comp : fp_fdiv
		port map(
			reset     => reset,
			clock     => clock,
			fp_fdiv_i => fp_fdiv_i,
			fp_fdiv_o => fp_fdiv_o,
			fp_mac_i  => fp_mac_i,
			fp_mac_o  => fp_mac_o
		);

end architecture;
