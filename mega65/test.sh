#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993

A_OPTS="--error-limit=1 --relaxed"
E_OPTS=
R_OPTS="--ieee-warnings=off"

# Huge RAMs
NVC_OPTS="-M 128m" analyse src/vhdl/shadowram-a100t.vhdl src/vhdl/shadowram-a200t.vhdl

analyse @files.txt

for TOP in test_sprite; do
  elaborate
  run
done
