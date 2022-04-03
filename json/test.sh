#!/bin/bash

#
# https://github.com/Paebbels/JSON-for-VHDL
#

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=Boards2
WORK=json

A_OPTS=
E_OPTS="-gC_PROJECT_DIR=."
R_OPTS=

analyse src/Encodings.pkg.vhdl \
        src/JSON.pkg.vhdl \
        src/JSON.ctx.vhdl

analyse examples/Boards2.vhdl

elaborate
run
