#!/bin/bash

# Generated from MyHDL scripts/benchmarks
#   https://github.com/myhdl/myhdl/tree/master/scripts/benchmark

cd $(dirname $0)
. ../functions.sh

STD=2008

analyse pck_myhdl_011.vhd \
        test_lfsr24.vhd \
        test_randgen.vhd \
        test_findmax.vhd \
        test_longdiv.vhd \
        test_timer.vhd

for TOP in test_lfsr24 test_randgen test_findmax test_longdiv test_timer; do
  elaborate
  run >$TOP.out
done
