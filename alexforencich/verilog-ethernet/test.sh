#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS="--exit-severity=error --ieee-warnings=off"

analyse ../verilog-axis/rtl/arbiter.v \
        ../verilog-axis/rtl/priority_encoder.v \
        ../verilog-axis/rtl/axis_fifo.v

analyse rtl/arp.v \
        rtl/arp_cache.v \
        rtl/arp_eth_rx.v \
        rtl/arp_eth_tx.v \
        rtl/axis_gmii_rx.v \
        rtl/axis_gmii_tx.v \
        rtl/eth_arb_mux.v \
        rtl/eth_mac_1g.v \
        rtl/ip.v \
        rtl/ip_arb_mux.v \
        rtl/ip_complete.v \
        rtl/ip_eth_rx.v \
        rtl/ip_eth_tx.v \
        rtl/lfsr.v \
        rtl/udp.v \
        rtl/udp_checksum_gen.v \
        rtl/udp_complete.v \
        rtl/udp_ip_rx.v \
        rtl/udp_ip_tx.v

analyse tb/tb_eth_mac_1g.v \
        tb/tb_udp_complete.v

for TOP in tb_eth_mac_1g tb_udp_complete; do
  elaborate
  run
done
