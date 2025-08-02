#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=cic_bench

A_OPTS=
E_OPTS="--no-collapse"
R_OPTS=
STOP_TIME=7300us

analyse cic_decim.v
analyse swap_pkg.vhd \
        gencores_pkg.vhd \
        genram_pkg.vhd \
        gc_shiftreg.vhd \
        wishbone_pkg.vhd \
        ce_synch.vhd \
        counters_gen_pkg.vhd \
        dsp_cores_pkg.vhd \
        decimation_strober.vhd \
        cic_dyn.vhd \
        swmode_sel.vhd \
        swap_freqgen.vhd \
        cic_bench.vhd

elaborate
run

sha1sum -c cic_out.samples.sha1 
