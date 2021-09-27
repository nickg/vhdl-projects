#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=
WORK=ieee_proposed

A_OPTS=
E_OPTS=
R_OPTS=
GHDL_OPTS=-frelaxed

analyse standard_additions_c.vhdl \
        standard_textio_additions_c.vhdl \
        numeric_std_additions.vhdl \
        fixed_float_types_c.vhdl \
        std_logic_1164_additions.vhdl \
        numeric_std_unsigned_c.vhdl \
        fixed_pkg_c.vhdl \
        complex_tests.vhdl \
        env_c.vhdl \
        fixed_noresize.vhdl \
        float_pkg_c.vhdl \
        numeric_bit_tb1.vhdl \
        numeric_bit_tb2.vhdl \
        numeric_bit_tb3.vhdl \
        numeric_bit_tb4.vhdl \
        numeric_bit_tb5.vhdl \
        numeric_std_tb1.vhdl \
        numeric_std_tb2.vhdl \
        numeric_std_tb3.vhdl \
        numeric_std_tb4.vhdl \
        numeric_std_tb5.vhdl \
        real_tests.vhdl \
        complex_tests.vhdl

for TOP in numeric_bit_tb{1,2,3,4,5} numeric_std_tb{1,2,3,4,5} \
           real_tests complex_tests; do
  elaborate
  run
done

STD=2008
WORK=fphdl

analyse test_logical.vhdl \
        test_minmax.vhdl \
        test_nbuns.vhdl \
        test_nuns_su.vhdl \
        test_nuns.vhdl \
        test_realstring.vhdl \
        test_reduce_pack.vhdl \
        test_reduce.vhdl \
        test_shift.vhdl \
        test_std_textio_add.vhdl \
        test_string.vhdl

exit # Tests below here not working yet

for TOP in test_logical test_minmax; do
  elaborate
  run
done

# test_standard_additions.vhdl
# test_std_logic_textio.vhdl
# test_new1164.vhdl
# test_fpfixed.vhdl
# test_fphdl128.vhdl
# test_fphdl16.vhdl
# test_fphdl64.vhdl
# test_fphdlbase.vhdl
# test_fphdl.vhdl
#fixed_noround_pkg.vhdl
#fixed_synth.vhdl
# float_noround_pkg.vhdl
#float_roundneg_pkg.vhdl
#  test_bminmax.vhdl
#test_breduce_pack.vhdl
# test_bstring.vhdl
#test_fixed2.vhdl
# test_fixed3.vhdl
#test_fixed_nr.vhdl
# test_fixed_synth.vhdl
# test_fixed.vhdl
#test_float_synth.vhdl
#test_fp32.vhdl
  
