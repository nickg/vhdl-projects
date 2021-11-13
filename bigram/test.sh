#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=bigram

A_OPTS=
E_OPTS=
R_OPTS="--ieee-warnings=off"

GHDL_OPTS="-frelaxed"

analyse bigram.vhd

elaborate
run
