#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2008

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--ieee-warnings=off"

NVC_OPTS="-M 32m"
GHDL_OPTS="-frelaxed"

analyse src/common/tyto_types_pkg.vhd \
	src/common/tyto_utils_pkg.vhd \
	src/common/retro/saa5050/saa5050_rom_data.vhd \
	src/common/retro/saa5050/saa5050.vhd \
	src/common/retro/hd6845/hd6845.vhd \
	src/common/tyto_sim_pkg.vhd \
	src/common/retro/saa5050/test/tb_saa5050.vhd \
	src/common/basic/xilinx/ram_sdp_a_32.vhd \
	src/common/basic/xilinx/ldce_bus.vhd \
	src/common/basic/ram_tdp_s.vhd \
	gen/np6532_ram_init_128k_pkg.vhd \
	gen/np65_decoder.vhd \
	src/common/retro/np65/np6532_ram.vhd \
	src/common/retro/np65/np6532_cache.vhd \
	src/common/retro/np65/np6532_core.vhd \
	src/common/retro/np65/np6532.vhd \
	submodules/vhdl_prng/rtl/rng_xoshiro128plusplus.vhdl

analyse src/designs/np6532_functest/np6532_functest.vhd

E_OPTS="-gvector_init=64512 -gstart_address=1024 -gref_file=./6502_functional_test.txt -gprogress_interval=1000"

TOP=np6532_functest

elaborate
run
