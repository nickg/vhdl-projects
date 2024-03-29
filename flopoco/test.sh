#!/bin/bash

# Generated with flopoco FPLog we=16 wf=46 TestBench n=10000

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=TestBench_FPLog_16_46_0_F400_uid2_F400_uid220
STOP_TIME=100240ns

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--exit-severity=failure --ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"
GHDL_R_OPTS="--ieee-asserts=disable"

analyse flopoco.vhdl

elaborate
run
