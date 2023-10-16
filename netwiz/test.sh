#!/bin/bash

#
#  https://github.com/geddy11/netwiz
#

cd $(dirname $0)
. ../functions.sh

STD=2008

WORK=nw_adapt

analyse nw_adapt/src/nw_adaptations_pkg.vhd

WORK=nw_util

analyse nw_util/src/nw_types_pkg.vhd  \
        nw_util/src/nw_util_pkg.vhd \
        nw_util/src/nw_crc_pkg.vhd \
        nw_util/src/nw_prbs_pkg.vhd \
        nw_util/src/nw_nrs_pkg.vhd \
        nw_util/src/nw_util_context.vhd

WORK=nw_codec

analyse nw_codec/src/nw_base_pkg.vhd \
        nw_codec/src/nw_cobs_pkg.vhd \
        nw_codec/src/nw_hamming_pkg.vhd \
        nw_codec/src/nw_bitstuff_pkg.vhd \
        nw_codec/src/nw_sl_codec_pkg.vhd \
        nw_codec/src/nw_codec_context.vhd 

WORK=nw_ethernet

analyse nw_ethernet/src/nw_ethernet_pkg.vhd \
        nw_ethernet/src/nw_arp_pkg.vhd \
        nw_ethernet/src/nw_ethernet_context.vhd 

WORK=nw_ipv4

analyse nw_ipv4/src/ip_protocols_pkg.vhd \
        nw_ipv4/src/nw_ipv4_pkg.vhd \
        nw_ipv4/src/nw_tcpv4_pkg.vhd \
        nw_ipv4/src/nw_icmpv4_pkg.vhd \
        nw_ipv4/src/nw_udpv4_pkg.vhd \
        nw_ipv4/src/nw_ipv4_context.vhd

WORK=nw_ipv6

analyse nw_ipv6/src/nw_ipv6_pkg.vhd \
        nw_ipv6/src/nw_tcpv6_pkg.vhd \
        nw_ipv6/src/nw_icmpv6_pkg.vhd \
        nw_ipv6/src/nw_udpv6_pkg.vhd \
        nw_ipv6/src/nw_ipv6_context.vhd

WORK=nw_pcap

analyse nw_pcap/src/nw_pcap_pkg.vhd

WORK=nw_ptp

analyse nw_ptp/src/nw_ptpv2_pkg.vhd

WORK=nw_usb

analyse nw_usb/src/nw_usb_pkg.vhd \
        nw_usb/src/nw_usb_context.vhd

WORK=work

analyse nw_codec/tb/nw_codec_tb.vhd \
        nw_ethernet/tb/nw_ethernet_tb.vhd \
        nw_ipv4/tb/nw_ipv4_tb.vhd \
        nw_ipv6/tb/nw_ipv6_tb.vhd \
        nw_pcap/tb/nw_pcap_tb.vhd \
        nw_ptp/tb/nw_ptp_tb.vhd \
        nw_usb/tb/nw_usb_tb.vhd

tests=(
  nw_codec_tb nw_ethernet_tb nw_ipv4_tb nw_ipv6_tb nw_pcap_tb
  nw_ptp_tb nw_usb_tb
)

for TOP in ${tests[@]}; do
  run_jit
done

