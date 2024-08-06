#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=tb_fpu
#STOP_TIME=156500ns

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--exit-severity=failure --ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"
GHDL_R_OPTS="--ieee-asserts=disable"

analyse src/fpupack.vhd \
        src/pre_norm_addsub.vhd \
        src/addsub_28.vhd \
        src/post_norm_addsub.vhd \
        src/pre_norm_mul.vhd \
        src/mul_24.vhd \
        src/serial_mul.vhd \
        src/post_norm_mul.vhd \
        src/pre_norm_div.vhd \
        src/serial_div.vhd \
        src/post_norm_div.vhd \
        src/pre_norm_sqrt.vhd \
        src/sqrt.vhd \
        src/post_norm_sqrt.vhd \
        src/comppack.vhd \
        src/fpu.vhd \
        test_bench/txt_util.vhd \
        test_bench/tb_fpu.vhd

#elaborate
run_jit
