#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=2008
TOP=test1259

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=
GHDL_R_OPTS=

analyse test1259.vhd

elaborate
run
