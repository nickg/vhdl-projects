#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=fpga_top
STOP_TIME=4910us

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS="-frelaxed"

analyse example_medium/zpu_config_trace.vhd \
	zpu4/core/zpupkg.vhd \
	zpu4/src/txt_util.vhd \
	example_medium/sim_fpga_top.vhd \
	zpu4/core/zpu_core.vhd \
	example_medium/dram_hello.vhd \
	zpu4/src/timer.vhd \
	zpu4/src/io.vhd \
	zpu4/src/trace.vhd

elaborate
run
