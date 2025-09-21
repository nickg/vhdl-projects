#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=axis2mm_tb

A_OPTS=
E_OPTS=
R_OPTS="--exit-severity=error --ieee-warnings=off"

analyse sfifo.v skidbuffer.v axis2mm.v
analyse axi_pkg.vhdl axis2mm_tb.vhdl

elaborate
run
