#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS="--stop-delta=3000 --exit-severity=failure"

GHDL_OPTS=

analyse bitvis_uart/tb/uart_vvc_demo_th.vhd
analyse bitvis_uart/tb/uart_vvc_demo_tb.vhd

analyse bitvis_irqc/tb/irqc_demo_tb.vhd

analyse bitvis_vip_uart/tb/uvvm_demo_th.vhd
analyse bitvis_vip_uart/tb/uvvm_demo_tb.vhd

for TOP in uart_vvc_demo_tb uart_vvc_demo_tb uvvm_demo_tb; do
  elaborate
  run
done

