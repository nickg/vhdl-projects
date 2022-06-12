#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS=

WORK=osvvm

mkdir -p results
mkdir -p reports

analyse osvvm/NamePkg.vhd \
        osvvm/OsvvmGlobalPkg.vhd \
        osvvm/TranscriptPkg.vhd \
        osvvm/TextUtilPkg.vhd \
        osvvm/AlertLogPkg.vhd \
        osvvm/SortListPkg_int.vhd \
        osvvm/RandomBasePkg.vhd \
        osvvm/RandomPkg.vhd \
        osvvm/RandomProcedurePkg.vhd \
        osvvm/MessagePkg.vhd \
        osvvm/ResolutionPkg.vhd \
        osvvm/NameStorePkg.vhd \
        osvvm/MessageListPkg.vhd \
        osvvm/VendorCovApiPkg.vhd \
        osvvm/CoveragePkg.vhd \
        osvvm/MemoryPkg.vhd \
        osvvm/ScoreboardGenericPkg.vhd \
        osvvm/ScoreboardPkg_int.vhd \
        osvvm/ScoreboardPkg_slv.vhd \
        osvvm/ReportPkg.vhd \
        osvvm/ResizePkg.vhd \
        osvvm/TbUtilPkg.vhd \
        osvvm/OsvvmTypesPkg.vhd \
        osvvm/OsvvmContext.vhd

WORK=osvvm_common

analyse Common/src/FifoFillPkg_slv.vhd \
        Common/src/FifoFillPtPkg_slv.vhd \
        Common/src/AddressBusTransactionPkg.vhd \
        Common/src/AddressBusResponderTransactionPkg.vhd \
        Common/src/AddressBusVersionCompatibilityPkg.vhd \
        Common/src/InterruptHandlerComponentPkg.vhd \
        Common/src/InterruptHandler.vhd \
        Common/src/ModelParametersPkg.vhd \
        Common/src/StreamTransactionPkg.vhd \
        Common/src/OsvvmCommonContext.vhd

WORK=osvvm_uart

analyse UART/src/UartTbPkg.vhd \
        UART/src/ScoreboardPkg_Uart.vhd \
        UART/src/UartRxComponentPkg.vhd \
        UART/src/UartRx.vhd \
        UART/src/UartTxComponentPkg.vhd \
        UART/src/UartTx.vhd \
        UART/src/UartContext.vhd

WORK=osvvm_tbuart

analyse UART/testbench/TestCtrl_e.vhd \
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

exit  # Not working yet

WORK=osvvm_axi4

analyse AXI4/common/src/Axi4CommonPkg.vhd \
        AXI4/common/src/Axi4InterfaceCommonPkg.vhd \
        AXI4/common/src/Axi4InterfacePkg.vhd \
        AXI4/common/src/Axi4LiteInterfacePkg.vhd \
        AXI4/common/src/Axi4ModelPkg.vhd \
        AXI4/common/src/Axi4OptionsPkg.vhd \
        AXI4/common/src/Axi4VersionCompatibilityPkg.vhd

analyse AXI4/Axi4Lite/src/Axi4LiteComponentPkg.vhd \
        AXI4/Axi4Lite/src/Axi4LiteMasterComponentPkg.vhd \
        AXI4/Axi4Lite/src/Axi4LiteMaster.vhd \
        AXI4/Axi4Lite/src/Axi4LiteMemoryComponentPkg.vhd \
        AXI4/Axi4Lite/src/Axi4LiteMemory.vhd \
        AXI4/Axi4Lite/src/Axi4LiteMonitorComponentPkg.vhd \
        AXI4/Axi4Lite/src/Axi4LiteMonitor_dummy.vhd \
        AXI4/Axi4Lite/src/Axi4LiteResponderComponentPkg.vhd \
        AXI4/Axi4Lite/src/Axi4LiteResponder_Transactor.vhd \
        AXI4/Axi4Lite/src/Axi4LiteContext.vhd

WORK=osvvm_tbaxi4

analyse AXI4/Axi4Lite/testbench/TestCtrl_e.vhd \
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
