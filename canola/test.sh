#!/bin/bash

#
#  A CAN controller for FPGAs written in VHDL 
#     https://github.com/svnesbo/canola
#

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS="--relaxed"
E_OPTS=
R_OPTS=

GHDL_OPTS=

analyse ./source/rtl/tmr_voters/tmr_pkg.vhd \
        ./source/rtl/canola_pkg.vhd \
        ./source/rtl/canola_crc.vhd \
        ./source/rtl/canola_frame_tx_fsm.vhd \
        ./source/rtl/canola_frame_rx_fsm.vhd \
        ./source/rtl/tmr_voters/tmr_voter.vhd \
        ./source/rtl/tmr_voters/tmr_voter_array.vhd \
        ./source/rtl/tmr_voters/tmr_voter_triplicated.vhd \
        ./source/rtl/tmr_voters/tmr_voter_triplicated_array.vhd \
        ./source/rtl/tmr_wrappers/canola_frame_tx_fsm_tmr_wrapper.vhd \
        ./source/rtl/tmr_wrappers/canola_frame_rx_fsm_tmr_wrapper.vhd \
        ./source/rtl/counters/up_counter.vhd \
        ./source/rtl/counters/counter_saturating.vhd \
        ./source/rtl/canola_eml.vhd \
        ./source/rtl/canola_bsp.vhd \
        ./source/rtl/canola_time_quanta_gen.vhd \
        ./source/rtl/tmr_wrappers/up_counter_tmr_wrapper.vhd \
        ./source/rtl/tmr_wrappers/canola_eml_tmr_wrapper.vhd \
        ./source/rtl/tmr_wrappers/canola_bsp_tmr_wrapper.vhd \
        ./source/rtl/tmr_wrappers/canola_time_quanta_gen_tmr_wrapper.vhd \
        ./source/rtl/tmr_wrappers/counter_saturating_tmr_wrapper_triplicated.vhd \
        ./source/rtl/canola_btl.vhd \
        ./source/rtl/tmr_wrappers/canola_btl_tmr_wrapper.vhd \
        ./source/rtl/canola_counters.vhd \
        ./source/rtl/canola_counters_tmr.vhd \
        ./source/rtl/canola_top.vhd \
        ./source/rtl/canola_top_tmr.vhd \
        ./source/rtl/axi_slave/axi_pkg.vhd \
        ./source/rtl/axi_slave/canola_axi_slave_pif_pkg.vhd \
        ./source/rtl/axi_slave/canola_axi_slave_axi_pif.vhd \
        ./source/rtl/axi_slave/canola_axi_slave.vhd \
        ./source/rtl/axi_slave/canola_axi_slave_tmr.vhd

analyse ./source/bench/canola_tb_pkg.vhd \
        ./source/bench/can_bfm/can_bfm_pkg.vhd \
        ./source/bench/can_bfm/can_uvvm_bfm_pkg.vhd \
        ./source/bench/canola_top_tb.vhd

TOP=canola_top_tb

mkdir -p log

elaborate
run
