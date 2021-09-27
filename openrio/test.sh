#!/bin/bash

#
# OpenRIO imported from https://github.com/magro732/OpenRIO
#

cd $(dirname $0)
. ../functions.sh

STD=1993

A_OPTS="--relax=prefer-explicit"
E_OPTS=
R_OPTS=

GHDL_OPTS="-frelaxed -fsynopsys -fexplicit"

analyse RioCommon.vhd \
        RioPacketBuffer.vhd \
        RioPcsUart.vhd \
        RioSerial.vhd \
        RioSwitch.vhd \
        RioWbBridge.vhd \
        TestRioPacketBuffer.vhd \
        TestRioPcsUart.vhd \
        TestRioSerial.vhd \
        TestRioSwitch.vhd \
        TestUart.vhd \
        Uart.vhd

for TOP in TestRioPacketBuffer TestRioPcsUart TestRioSerial \
           TestRioSwitch TestUart; do
  elaborate
  run
done
