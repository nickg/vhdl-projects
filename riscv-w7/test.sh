#!/bin/bash

# Generated with flopoco FPLog we=16 wf=46 TestBench n=10000

cd $(dirname $0)
. ../functions.sh

STD=2008
TOP=soc

A_OPTS=
E_OPTS=
R_OPTS=

NVC_OPTS="-M 64m"
GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

analyse vhdl/tb/configure.vhd

analyse vhdl/lzc/lzc_wire.vhd

analyse vhdl/lzc/lzc_lib.vhd \
        vhdl/lzc/lzc_4.vhd \
        vhdl/lzc/lzc_8.vhd \
        vhdl/lzc/lzc_16.vhd \
        vhdl/lzc/lzc_32.vhd \
        vhdl/lzc/lzc_64.vhd \
        vhdl/lzc/lzc_128.vhd \
        vhdl/lzc/lzc_256.vhd

analyse vhdl/integer/int_constants.vhd \
        vhdl/integer/int_types.vhd \
        vhdl/integer/int_wire.vhd

analyse vhdl/atomic/atom_constants.vhd \
        vhdl/atomic/atom_wire.vhd \
        vhdl/atomic/atom_functions.vhd

analyse vhdl/bitmanip/bit_constants.vhd \
        vhdl/bitmanip/bit_types.vhd \
        vhdl/bitmanip/bit_wire.vhd \
        vhdl/bitmanip/bit_functions.vhd

analyse vhdl/float/fp_cons.vhd \
        vhdl/float/fp_typ.vhd \
        vhdl/float/fp_wire.vhd

analyse vhdl/csr/csr_constants.vhd \
        vhdl/csr/csr_wire.vhd \
        vhdl/csr/csr_functions.vhd

analyse vhdl/compress/comp_constants.vhd \
        vhdl/compress/comp_wire.vhd

analyse vhdl/setting/constants.vhd \
        vhdl/setting/wire.vhd \
        vhdl/setting/functions.vhd

analyse vhdl/compress/comp_decode.vhd

analyse vhdl/memory/arbiter.vhd \
        vhdl/memory/pmp.vhd \
        vhdl/memory/clint.vhd \
        vhdl/memory/check.vhd \
        vhdl/memory/print.vhd

analyse vhdl/bus/axi.vhd \
        vhdl/bus/ahb.vhd \
        vhdl/bus/avalon.vhd

analyse vhdl/plic/plic_wire.vhd \
        vhdl/plic/plic_func.vhd \
        vhdl/plic/plic_lib.vhd \
        vhdl/plic/plic_gw.vhd \
        vhdl/plic/plic_core.vhd \
        vhdl/plic/plic.vhd

analyse vhdl/icache/iwire.vhd \
        vhdl/icache/idata.vhd \
        vhdl/icache/itag.vhd \
        vhdl/icache/ivalid.vhd \
        vhdl/icache/ihit.vhd \
        vhdl/icache/irandom.vhd \
        vhdl/icache/ictrl.vhd \
        vhdl/icache/icache.vhd

analyse vhdl/dcache/dwire.vhd \
        vhdl/dcache/ddata.vhd \
        vhdl/dcache/dtag.vhd \
        vhdl/dcache/dvalid.vhd \
        vhdl/dcache/dirty.vhd \
        vhdl/dcache/dlock.vhd \
        vhdl/dcache/dhit.vhd \
        vhdl/dcache/drandom.vhd \
        vhdl/dcache/dctrl.vhd \
        vhdl/dcache/dcache.vhd

analyse vhdl/itim/itim_wire.vhd \
        vhdl/itim/itim_tag.vhd \
        vhdl/itim/itim_data.vhd \
        vhdl/itim/itim_lock.vhd \
        vhdl/itim/itim_ctrl.vhd \
        vhdl/itim/itim.vhd

analyse vhdl/dtim/dtim_wire.vhd \
        vhdl/dtim/dtim_tag.vhd \
        vhdl/dtim/dtim_data.vhd \
        vhdl/dtim/dtim_lock.vhd \
        vhdl/dtim/dtim_valid.vhd \
        vhdl/dtim/dtim_ctrl.vhd \
        vhdl/dtim/dtim.vhd

analyse vhdl/fetchbuffer/fetchram.vhd \
        vhdl/fetchbuffer/fetchctrl.vhd \
        vhdl/fetchbuffer/fetchbuffer.vhd

analyse vhdl/storebuffer/storebuffer.vhd \
        vhdl/storebuffer/storectrl.vhd \
        vhdl/storebuffer/storeram.vhd

analyse vhdl/shared/reservation_wire.vhd \
        vhdl/shared/reservation_func.vhd \
        vhdl/shared/reservation_arbiter.vhd \
        vhdl/shared/reservation_ctrl.vhd \
        vhdl/shared/reservation_set.vhd \
        vhdl/shared/reservation_pid.vhd \
        vhdl/shared/reservation_tag.vhd \
        vhdl/shared/reservation.vhd

analyse vhdl/bp/bht.vhd \
        vhdl/bp/btb.vhd \
        vhdl/bp/ras.vhd \
        vhdl/bp/bp.vhd

analyse vhdl/tb/bram.vhd

analyse vhdl/integer/int_library.vhd \
        vhdl/integer/int_alu.vhd \
        vhdl/integer/int_bcu.vhd \
        vhdl/integer/int_agu.vhd \
        vhdl/integer/int_mul.vhd \
        vhdl/integer/int_div.vhd \
        vhdl/integer/int_reg_file.vhd \
        vhdl/integer/int_forward.vhd \
        vhdl/integer/int_decode.vhd \
        vhdl/integer/int_pipeline.vhd \
        vhdl/integer/int_unit.vhd

analyse vhdl/atomic/atom_library.vhd \
        vhdl/atomic/atom_alu.vhd \
        vhdl/atomic/atom_agu.vhd \
        vhdl/atomic/atom_decode.vhd

analyse vhdl/bitmanip/bit_library.vhd \
        vhdl/bitmanip/bit_alu.vhd \
        vhdl/bitmanip/bit_clmul.vhd \
        vhdl/bitmanip/bit_decode.vhd \
        vhdl/bitmanip/bit_pipeline.vhd \
        vhdl/bitmanip/bit_unit.vhd

analyse vhdl/float/fp_lib.vhd \
        vhdl/float/fp_ext.vhd \
        vhdl/float/fp_cmp.vhd \
        vhdl/float/fp_max.vhd \
        vhdl/float/fp_sgnj.vhd \
        vhdl/float/fp_cvt.vhd \
        vhdl/float/fp_rnd.vhd \
        vhdl/float/fp_fma.vhd \
        vhdl/float/fp_mac.vhd \
        vhdl/float/fp_fdiv.vhd \
        vhdl/float/fp_for.vhd \
        vhdl/float/fp_reg.vhd \
        vhdl/float/fp_dec.vhd \
        vhdl/float/fp_exe.vhd \
        vhdl/float/fpu.vhd

analyse vhdl/csr/csr_alu.vhd \
        vhdl/csr/csr_file.vhd \
        vhdl/csr/csr_unit.vhd

analyse vhdl/stage/fetch_stage.vhd \
        vhdl/stage/decode_stage.vhd \
        vhdl/stage/execute_stage.vhd \
        vhdl/stage/memory_stage.vhd \
        vhdl/stage/writeback_stage.vhd

analyse vhdl/unit/pipeline.vhd \
        vhdl/unit/core.vhd \
        vhdl/unit/cpu.vhd

analyse vhdl/tb/soc.vhd

elaborate
run
