#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS="--stop-delta=3000 --exit-severity=failure"

GHDL_OPTS=

WORK=bitvis_uart

analyse bitvis_uart/src/uart_pkg.vhd \
        bitvis_uart/src/uart_pif_pkg.vhd \
        bitvis_uart/src/uart_pif.vhd \
        bitvis_uart/src/uart_core.vhd \
        bitvis_uart/src/uart.vhd

WORK=bitvis_irqc

analyse bitvis_irqc/src/irqc_pif_pkg.vhd \
        bitvis_irqc/src/irqc_pif.vhd \
        bitvis_irqc/src/irqc_core.vhd \
        bitvis_irqc/src/irqc.vhd

WORK=uvvm_test

analyse bitvis_uart/tb/uart_vvc_demo_th.vhd
analyse bitvis_uart/tb/uart_vvc_demo_tb.vhd

analyse bitvis_irqc/tb/irqc_demo_tb.vhd

analyse bitvis_vip_uart/tb/uvvm_demo_th.vhd
analyse bitvis_vip_uart/tb/uvvm_demo_tb.vhd

analyse bitvis_vip_ethernet/tb/ethernet_mac_pkg.vhd \
        bitvis_vip_ethernet/tb/ethernet_mac.vhd \
        bitvis_vip_ethernet/tb/ethernet_sbi_gmii_demo_th.vhd \
        bitvis_vip_ethernet/tb/ethernet_sbi_gmii_demo_tb.vhd \
        bitvis_vip_ethernet/tb/sbi_fifo.vhd \
        bitvis_vip_ethernet/tb/ethernet_nvc_test.vhd

for TOP in uart_vvc_demo_tb uart_vvc_demo_tb uvvm_demo_tb \
           ethernet_sbi_gmii_demo_tb ethernet_nvc_tb; do
   elaborate
   run
done
