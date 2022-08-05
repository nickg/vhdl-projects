#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=
NVC_OPTS="-H 64m"

mkdir -p results
mkdir -p reports

WORK=osvvm_tbuart

analyse UART/testbench/OsvvmTestCommonPkg.vhd \
        UART/testbench/TestCtrl_e.vhd \
        UART/testbench/TbUart.vhd \
        UART/testbench/TbUart_SendGet1.vhd \
        UART/testbench/TbUart_SendGet2.vhd \
        UART/testbench/TbUart_Checkers1.vhd \
        UART/testbench/TbUart_Checkers2.vhd \
        UART/testbench/TbUart_Options1.vhd \
        UART/testbench/TbUart_Options2.vhd \
        UART/testbench/TbUart_Overload1.vhd \
        UART/testbench/TbUart_Scoreboard1.vhd

for TOP in TbUart_{SendGet1,SendGet2,Checkers1,Checkers2} \
           TbUart_{Options1,Options2,Overload1,Scoreboard1}; do
  elaborate
  run
done

WORK=osvvm_tbaxi4

analyse AXI4/Axi4Lite/testbench/OsvvmTestCommonPkg.vhd \
        AXI4/Axi4Lite/testbench/TestCtrl_e.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_BasicReadWrite.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_MemoryReadWrite1.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_RandomReadWriteByte.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_RandomReadWrite.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_ReadWriteAsync1.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_ReadWriteAsync2.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_ReadWriteAsync3.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_TimeOut.vhd \
        AXI4/Axi4Lite/testbench/TbAxi4_WriteOptions.vhd

for TOP in TbAxi4_{BasicReadWrite,ReadWriteAsync1,ReadWriteAsync2} \
           TbAxi4_{ReadWriteAsync3,RandomReadWrite,RandomReadWriteByte} \
           TbAxi4_{TimeOut,WriteOptions,MemoryReadWrite1}; do
  elaborate
  run
done
