#!/bin/bash
#
# https://github.com/kevinpt/vhdl-extras
#

cd $(dirname $0)
. ../functions.sh

STD=1993

A_OPTS="--relaxed"
E_OPTS=
R_OPTS="--ieee-warnings=off"

GHDL_OPTS="-frelaxed -fsynopsys"

core_files=(rtl/extras/pipelining.vhdl
            rtl/extras/strings.vhdl
            rtl/extras/characters_latin_1.vhdl
            rtl/extras/strings_maps.vhdl
            rtl/extras/strings_maps_constants.vhdl
            rtl/extras/strings_fixed.vhdl
            rtl/extras/strings_unbounded.vhdl
            rtl/extras/cordic.vhdl
            rtl/extras/crc_ops.vhdl
            rtl/extras/memory.vhdl
            rtl/extras/sizing.vhdl
            rtl/extras/synchronizing.vhdl
            rtl/extras/fifos.vhdl
            rtl/extras/muxing.vhdl
            rtl/extras/reg_file.vhdl
            rtl/extras/arithmetic.vhdl
            rtl/extras/ddfs.vhdl
            rtl/extras/parity_ops.vhdl
            rtl/extras/bit_ops.vhdl 
            rtl/extras/lfsr_ops.vhdl 
            rtl/extras/bcd_conversion.vhdl
            rtl/extras/glitch_filtering.vhdl
            rtl/extras/characters_handling.vhdl
            rtl/extras/hamming_edac.vhdl
            rtl/extras/gray_code.vhdl 
            rtl/extras/lcar_ops.vhdl
            rtl/extras/timing_ops.vhdl
            rtl/extras/oscillator.vhdl
            rtl/extras/random.vhdl
            rtl/extras/interrupt_ctl.vhdl
            rtl/extras/binaryio.vhdl
            rtl/extras/text_buffering.vhdl
            rtl/extras/secded_edac.vhdl
            rtl/extras/secded_codec.vhdl)

test_files=(rtl/test/test_muxing.vhdl
            rtl/test/test_secded_codec.vhdl
            rtl/test/test_strings_fixed.vhdl
            rtl/test/test_binaryio.vhdl
            rtl/test/test_crc_ops.vhdl
            rtl/test/test_rom.vhdl
            rtl/test/test_sizing.vhdl
            rtl/test/test_handshake_synchronizer.vhdl
            rtl/test/test_characters_handling.vhdl
            rtl/test/test_dual_port_ram.vhdl
            rtl/test/test_array_glitch_filter.vhdl
            rtl/test/test_glitch_filter.vhdl
            rtl/test/test_hamming_edac.vhdl
            rtl/test/test_lfsr_ops.vhdl
            rtl/test/test_secded_edac.vhdl
            rtl/test/test_text_buffering.vhdl
            rtl/test/test_strings_maps.vhdl
            rtl/test/test_lcar_ops.vhdl
            rtl/test/test_bcd_conversion.vhdl
            rtl/test/test_gray_code.vhdl
            rtl/test/test_ddfs.vhdl
            rtl/test/test_pipelined_adder.vhdl
            rtl/test/test_timing_ops.vhdl
            rtl/test/test_interrupt_ctl.vhdl
            rtl/test/test_reg_file.vhdl
            rtl/test/test_random.vhdl
            rtl/test/test_fifo.vhdl
            rtl/test/test_packet_fifo.vhdl
            rtl/test/test_parity_ops.vhdl
            rtl/test/test_strings_unbounded.vhdl
            rtl/test/test_simple_fifo.vhdl)

test_benches=(test_muxing
              test_secded_codec
              test_strings_fixed
              test_crc_ops
              test_sizing
              test_handshake_synchronizer
              test_characters_handling
              test_dual_port_ram
              test_array_glitch_filter
              test_glitch_filter
              test_hamming_edac
              test_strings_maps
              test_lcar_ops
              test_strings_maps
              test_lcar_ops
              test_bcd_conversion
              test_gray_code
              test_ddfs
              test_pipelined_adder
              test_interrupt_ctl
              test_reg_file
              test_random
              test_fifo
              test_packet_fifo
              test_parity_ops
              test_strings_unbounded
              test_simple_fifo
              test_binaryio
              test_text_buffering)

# Assertion Failure: Mismatch in to_real()
# test_timing_ops

WORK=extras
analyse ${core_files[*]}

WORK=test
analyse ${test_files[*]}

mkdir -p test/test-output/

for TOP in ${test_benches[*]}; do
  run_jit
done

exit
