#!/bin/bash
#
# https://github.com/bpadalino/vhdl-format
#

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=

analyse fmt.vhd fmt_test.vhd fmt_examples.vhd

for TOP in fmt_test; do
  elaborate
  run
done
