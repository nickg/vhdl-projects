#!/usr/bin/env bash

cd $(dirname $0)
. ../functions.sh

STD=2008
LIBS=(osvvm)

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

WORK=vunit_lib

while IFS= read -u3 -r line; do
  analyse $line
done 3< vhdl/compile_order.txt

# Cannot run tests without Vunit harness
