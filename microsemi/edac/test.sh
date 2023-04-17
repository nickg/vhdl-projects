#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=edac_tb

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS="-frelaxed -fsynopsys"

analyse edac_RAM.vhd edac.vhd edaci_36.vhd edac_tb.vhd

elaborate
run
