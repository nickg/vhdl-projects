#!/bin/bash

#
# https://github.com/stnolting/neorv32
#

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS=
E_OPTS=
R_OPTS="--exit-severity=error --ieee-warnings=off"

GHDL_R_OPTS="--ieee-asserts=disable --assert-level=error"

WORK=neorv32
TOP=neorv32_tb_simple
STOP_TIME=10ms

analyse rtl/core/neorv32_package.vhd
analyse rtl/core/neorv32_application_image.vhd
analyse sim/simple/uart_rx.simple.vhd
analyse sim/simple/neorv32_tb.simple.vhd
analyse rtl/core/neorv32_top.vhd
analyse rtl/core/neorv32_cpu.vhd
analyse rtl/core/neorv32_icache.vhd
analyse rtl/core/neorv32_busswitch.vhd
analyse rtl/core/neorv32_bus_keeper.vhd
analyse rtl/core/neorv32_imem.entity.vhd
analyse rtl/core/neorv32_dmem.entity.vhd
analyse rtl/core/neorv32_bootloader_image.vhd
analyse rtl/core/neorv32_boot_rom.vhd
analyse rtl/core/neorv32_wishbone.vhd
analyse rtl/core/neorv32_xip.vhd
analyse rtl/core/neorv32_cfs.vhd
analyse rtl/core/neorv32_gpio.vhd
analyse rtl/core/neorv32_wdt.vhd
analyse rtl/core/neorv32_mtime.vhd
analyse rtl/core/neorv32_uart.vhd
analyse rtl/core/neorv32_spi.vhd
analyse rtl/core/neorv32_twi.vhd
analyse rtl/core/neorv32_pwm.vhd
analyse rtl/core/neorv32_trng.vhd
analyse rtl/core/neorv32_neoled.vhd
analyse rtl/core/neorv32_slink.vhd
analyse rtl/core/neorv32_xirq.vhd
analyse rtl/core/neorv32_gptmr.vhd
analyse rtl/core/neorv32_sysinfo.vhd
analyse rtl/core/neorv32_debug_dm.vhd
analyse rtl/core/neorv32_debug_dtm.vhd
analyse rtl/core/neorv32_cpu_control.vhd
analyse rtl/core/neorv32_cpu_regfile.vhd
analyse rtl/core/neorv32_cpu_alu.vhd
analyse rtl/core/neorv32_cpu_bus.vhd
analyse rtl/core/neorv32_fifo.vhd
analyse rtl/core/neorv32_cpu_decompressor.vhd
analyse rtl/core/neorv32_cpu_cp_shifter.vhd
analyse rtl/core/neorv32_cpu_cp_muldiv.vhd
analyse rtl/core/neorv32_cpu_cp_bitmanip.vhd
analyse rtl/core/neorv32_cpu_cp_fpu.vhd
analyse rtl/core/neorv32_cpu_cp_cfu.vhd
analyse rtl/core/mem/neorv32_imem.legacy.vhd
analyse rtl/core/mem/neorv32_dmem.legacy.vhd

elaborate
run
