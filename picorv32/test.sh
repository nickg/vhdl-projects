#!/bin/bash

cd $(dirname $0)
. ../functions.sh

TOP=testbench

A_OPTS=
E_OPTS=
R_OPTS=

analyse testbench_ez.v picorv32.v

elaborate
run

diff -u expect out
