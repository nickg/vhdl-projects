#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=toplevel

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

analyse Murax.vhd toplevel.vhd

elaborate
run
