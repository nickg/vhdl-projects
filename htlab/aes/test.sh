#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=AES_cpu_top_tb
STOP_TIME=4ms

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--exit-severity=failure --ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"
GHDL_R_OPTS="--ieee-asserts=disable"

WORK=AES_Web_lib

analyse hdl/dkeylogic_rtl.vhd \
        hdl/keymem_struct.vhd \
        hdl/ekeylogic_rtl.vhd \
        hdl/ekeyfsm_fsm.vhd \
        hdl/aes_keygen_struct.vhd \
        hdl/enclogic_rtl11.vhd \
        hdl/aes_fsm_fsm.vhd \
        hdl/aes_encdec_struct.vhd \
        hdl/FSb_table.vhd \
        hdl/Reverse_Table.vhd \
        hdl/RSb_table.vhd \
        hdl/Forward_Table.vhd \
        hdl/aes_lut_struct.vhd \
        hdl/AES_io_rtl.vhd \
        hdl/aes_cpu_top_struct.vhd \
        hdl/AES_pack_pkg.vhd \
        hdl/AES_pack_pkg_body.vhd \
        hdl/AES_cpu_top_tester_behaviour.vhd \
        hdl/aes_cpu_top_tb_struct.vhd

#elaborate
run_jit
