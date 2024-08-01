#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=demo188_tb
STOP_TIME=2300ms

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--exit-severity=failure --ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"
GHDL_R_OPTS="--ieee-asserts=disable"

WORK=i80186

analyse rtl/cpu86instr.vhd \
        rtl/cpu86pack.vhd \
        rtl/newbiufsm_fsm.vhd \
        rtl/a_table.vhd \
        rtl/d_table.vhd \
        rtl/n_table.vhd \
        rtl/r_table.vhd \
        rtl/m_table.vhd \
        rtl/formatter_rtl.vhd \
        rtl/newbiushift.vhd \
        rtl/rise_edge.vhd \
        rtl/biuirq_rtl.vhd \
        rtl/newbiu_rtl.vhd \
        rtl/dataregfile_rtl.vhd \
        rtl/segregfile_rtl.vhd \
        rtl/divider_rtl_ser.vhd \
        rtl/multiplier_rtl.vhd \
        rtl/alu_rtl.vhd \
        rtl/ipregister_rtl.vhd \
        rtl/datapath_rtl.vhd \
        rtl/proc_rtl.vhd \
        rtl/I80188/cpu188_rtl.vhd

analyse testbench/utils.vhd \
        testbench/sram_behavior.vhd \
        testbench/port_mon.vhd \
        bootstrap.vhd \
        demo188.vhd \
        demo188_tb.vhd

#elaborate
run_jit
