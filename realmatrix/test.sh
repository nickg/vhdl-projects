#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=test_real_matrix
WORK=ieee_proposed

A_OPTS=
E_OPTS=-gQUIET=TRUE
R_OPTS=
GHDL_OPTS=-frelaxed

analyse real_matrix_pkg.vhdl \
        real_matrix_pkg_body.vhdl \
        test_real_matrix.vhdl

run_jit
