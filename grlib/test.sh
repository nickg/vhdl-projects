#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=leon3mp
STOP_TIME=

A_OPTS="--relaxed"
E_OPTS=
R_OPTS=

GHDL_OPTS="-P.ghdl -P.ghdl/grlib -fsynopsys -fexplicit"

libs=(grlib techmap eth spw opencores gaisler esa fmf gsi
      micron cypress work)

for l in ${libs[@]}; do
  WORK=$l analyse @$l.txt
done

# analyse designs/leon3-ahbfile/config.vhd \
#         designs/leon3-ahbfile/ahbfile.vhd \
#         designs/leon3-ahbfile/leon3mp.vhd \
#         designs/leon3-ahbfile/testbench.vhd

# elaborate
# run
