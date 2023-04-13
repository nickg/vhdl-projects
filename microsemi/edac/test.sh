#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=edac_tb

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=

analyse edac_RAM.vhd edac.vhd edaci_18.vhd edac_tb.vhd

elaborate
run
