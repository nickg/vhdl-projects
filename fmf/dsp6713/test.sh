#!/bin/bash
#
# Source: https://freemodelfoundry.com/proc.php
#

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=tbdsp6713

NVC_OPTS="-H 128m"

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=
GHDL_R_OPTS=

analyse conpack.vhd \
        dsp6713.vhd \
        sram1k16.vhd \
        sram1k8.vhd \
        km416s4030.vhd \
        tbdsp6713.vhd

run_jit
