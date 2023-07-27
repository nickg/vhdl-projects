#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=
GHDL_R_OPTS=

WORK=poc

analyse @compile_list.txt

TESTS=(
  #arith_addw_tb
  arith_firstone_tb
  arith_div_tb
  io_debounce_tb
  fifo_ic_assembly_tb
  uart_rx_tb
  dstruct_stack_tb
  dstruct_deque_tb
  strings_tb
  physical_tb
)   

for TOP in ${TESTS[@]}; do
  run_jit
done

