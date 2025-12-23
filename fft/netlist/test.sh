#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=2008
TOP=fftmain_tb

NVC_OPTS="-M 200M -H 256M"

A_OPTS=
E_OPTS=
R_OPTS="--ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed -Pxilinx-vivado/unisim/v08"
GHDL_R_OPTS="--ieee-asserts=disable"

analyse fftmain.vhdl ../fftmain_tb.vhd

elaborate
run
