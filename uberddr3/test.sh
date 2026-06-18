#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=uberddr3_sim

A_OPTS="-DNO_TEST_MODEL -DSIM_MODEL -Itestbench"
E_OPTS=
R_OPTS="--exit-severity=error --ieee-warnings=off"

IVERILOG_OPTS="-DNO_TEST_MODEL -DSIM_MODEL -Itestbench -g2012"

analyse testbench/ddr3_dimm_micron_sim.sv \
        testbench/ddr3.sv \
        testbench/models/IDELAYCTRL_model.v \
        testbench/models/IDELAYE2_model.v \
        testbench/models/IOBUF_DCIEN_model.v \
        testbench/models/IOBUF_model.v \
        testbench/models/IOBUFDS_DCIEN_model.v \
        testbench/models/IOBUFDS_model.v \
        testbench/models/ISERDESE2_model.v \
        testbench/models/OBUFDS_model.v \
        testbench/models/ODELAYE2_model.v \
        testbench/models/OSERDESE2_model.v \
        testbench/models/OBUF_model.v \
        rtl/ddr3_top.v \
        rtl/ddr3_controller.v \
        rtl/ddr3_phy.v \
        testbench/ddr3_module.sv

elaborate
run
