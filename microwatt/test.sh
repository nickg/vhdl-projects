#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=core_tb

WORK=unisim analyse sim-unisim/unisim_vcomponents.vhdl \
            sim-unisim/BUFG.vhdl \
            sim-unisim/BSCANE2.vhdl

analyse decode_types.vhdl \
        utils.vhdl \
        common.vhdl \
        wishbone_types.vhdl \
        glibc_random_helpers.vhdl \
        glibc_random.vhdl \
        foreign_random.vhdl \
        fetch1.vhdl \
        plru.vhdl \
        cache_ram.vhdl \
        icache.vhdl \
        decode1.vhdl \
        helpers.vhdl \
        insn_helpers.vhdl \
        control.vhdl \
        decode2.vhdl \
        register_file.vhdl \
        cr_file.vhdl \
        crhelpers.vhdl \
        ppc_fx_insns.vhdl \
        rotator.vhdl \
        logical.vhdl \
        countzero.vhdl \
        multiply.vhdl \
        divider.vhdl \
        pmu.vhdl \
        execute1.vhdl \
        loadstore1.vhdl \
        mmu.vhdl \
        dcache.vhdl \
        writeback.vhdl \
        core_debug.vhdl \
        fpu.vhdl \
        core.vhdl \
        wishbone_arbiter.vhdl \
        sim_bram_helpers.vhdl \
        sim_bram.vhdl \
        wishbone_bram_wrapper.vhdl \
        sync_fifo.vhdl \
        wishbone_debug_master.vhdl \
        xics.vhdl \
        syscon.vhdl \
        gpio.vhdl \
        spi_rxtx.vhdl \
        spi_flash_ctrl.vhdl \
        dmi_dtm_xilinx.vhdl \
        soc.vhdl \
        sim_console.vhdl \
        sim_pp_uart.vhdl \
        sim_jtag_socket.vhdl \
        sim_jtag.vhdl \
        sim_16550_uart.vhdl \
        core_tb.vhdl

elaborate
run
