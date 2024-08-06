#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=cbc_decryption_monte_carlo_testbench256
STOP_TIME=1ms

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--exit-severity=failure --ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"
GHDL_R_OPTS="--ieee-asserts=disable"

analyse vhdl/twofish.vhd \
        vhdl/twofish_testbenches_secondary_circuits.vhd \
        vhdl/twofish.vhd \
        vhdl/twofish_cbc_decryption_monte_carlo_testbench_256bits.vhd

#elaborate
run_jit
