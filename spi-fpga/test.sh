#!/bin/bash

# https://github.com/jakubcabal/spi-fpga


cd $(dirname $0)
. ../functions.sh

STD=1993

A_OPTS=
E_OPTS=
R_OPTS="--exit-severity=failure --ieee-warnings=off"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

analyse rtl/spi_master.vhd \
        rtl/spi_slave.vhd \
        sim/spi_master_tb.vhd \
        sim/spi_slave_tb.vhd

for TOP in spi_master_tb spi_slave_tb; do
  elaborate
  run
done

