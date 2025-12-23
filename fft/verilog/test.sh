#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=2008
TOP=fftmain_tb

A_OPTS=
E_OPTS=
R_OPTS=

analyse bimpy.v \
        bitreverse.v \
        butterfly.v \
        convround.v \
        fftstage.v \
        hwbfly.v \
        laststage.v \
        longbimpy.v \
        qtrstage.v \
        windowfn.v \
        fftmain.v

analyse ../fftmain_tb.vhd

elaborate
run
