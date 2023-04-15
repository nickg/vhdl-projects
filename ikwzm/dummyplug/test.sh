#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
WORK=dummy_plug
TOP=

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

analyse src/main/vhdl/core/util.vhd \
        src/main/vhdl/core/reader.vhd \
        src/main/vhdl/core/vocal.vhd \
        src/main/vhdl/core/sync.vhd \
        src/main/vhdl/core/core.vhd \
        src/main/vhdl/core/marchal.vhd \
        src/main/vhdl/axi4/axi4_types.vhd \
        src/main/vhdl/axi4/axi4_core.vhd \
        src/main/vhdl/axi4/axi4_channel_player.vhd \
        src/main/vhdl/axi4/axi4_master_player.vhd \
        src/main/vhdl/axi4/axi4_models.vhd \
        src/main/vhdl/axi4/axi4_signal_printer.vhd \
        src/main/vhdl/axi4/axi4_slave_player.vhd \
        src/main/vhdl/axi4/axi4_stream_player.vhd \
        src/main/vhdl/axi4/axi4_stream_master_player.vhd \
        src/main/vhdl/axi4/axi4_stream_slave_player.vhd \
        src/main/vhdl/axi4/axi4_stream_signal_printer.vhd

WORK=work

analyse src/test/vhdl/core/reader_test_1.vhd \
        src/test/vhdl/axi4/axi4_test_1_1.vhd \
        src/test/vhdl/axi4/axi4_test_1.vhd \
        src/test/vhdl/axi4/axi4_test_1_2.vhd \
        src/test/vhdl/axi4/axi4_test_1_3.vhd \
        src/test/vhdl/axi4/axi4_test_1_4.vhd \
        src/test/vhdl/axi4/axi4_stream_test_1.vhd \
        src/test/vhdl/axi4/axi4_stream_test_1_1.vhd

for TOP in DUMMY_PLUG_AXI4_TEST_1_{1,2,3,4} DUMMY_PLUG_AXI4_STREAM_TEST_1_1; do
  run_jit
done
