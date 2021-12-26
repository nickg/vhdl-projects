#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993

A_OPTS=
E_OPTS=
R_OPTS="--ieee-warnings=off"

GHDL_OPTS="-fexplicit -frelaxed -fsynopsys"  #--ieee-asserts=disable

analyse lib/reg_file_struct/bist_pkg.vhd \
        lib/reg_file_struct/rf_pkg.vhd \
        lib/reg_file_struct/rf.vhd \
        lib/reg_file_struct/bist_rf1.vhd \
        lib/reg_file_struct/bist_rf1_bw.vhd \
        lib/reg_file_struct/bist_rf2.vhd \
        lib/reg_file_struct/bist_rf4.vhd \
        lib/reg_file_struct/generic/rf1_generic.vhd \
        lib/reg_file_struct/generic/rf1_bw_generic.vhd \
        lib/reg_file_struct/generic/rf2_generic.vhd \
        lib/reg_file_struct/generic/rf4_generic.vhd \
        lib/reg_file_struct/generic/bist_config_generic.vhd

analyse lib/fixed_dsm_pkg/ieee/fixed_float_types_c.vhd \
        lib/fixed_dsm_pkg/ieee/fixed_pkg_c.vhd \
        lib/fixed_dsm_pkg/fixed_dsm_pkg.vhd

analyse lib/hwutils/util_pkg.vhd \
        lib/hwutils/attr_pkg.vhd \
        lib/hwutils/global_buffer.vhd \
        lib/hwutils/sync2ff.vhd \
        lib/hwutils/flancter.vhd \
        lib/hwutils/guardflancter.vhd \
        lib/hwutils/flagsync.vhd

analyse lib/memory_tech_lib/memory_pkg.vhd \
        lib/memory_tech_lib/ram_1rw.vhd \
        lib/memory_tech_lib/tech/inferred/ram_1rw_infer.vhd

analyse components/ring_bus/ring_bus_pkg.vhd \
        components/ring_bus/ring_bus_pkg_body.vhd

analyse tools/tests/tap/test_pkg.vhd

analyse components/gps_if2/rbus_pkg.vhd \
        components/gps_if2/rbus_adp.vhd \
        components/gps_if2/gpsif_sub_pkg.vhd \
        components/gps_if2/gpsif_pkg.vhd \
        components/gps_if2/gpsif_top.vhd \
        components/gps_if2/gpsif.vhd \
        components/gps_if2/gpsif_reg.vhd \
        components/gps_if2/gpsif_buf.vhd \
        components/gps_if2/gpsif_db.vhd \
        components/gps_if2/gpsif_time.vhd \
        components/gps_if2/gpsif_config_sim.vhd

analyse components/uartlite/uart_pkg.vhd \
        components/uartlite/uart.vhd
        
# Crashes
#analyse components/misc/gpio_pkg.vhd \
#        components/misc/gpio.vhd \
#        components/misc/bus_mux_pkg.vhd \
#        components/misc/spi2.vhd

# Crashes
# analyse components/cpu/core/components_pkg.vhd \
#         components/cpu/core/mult_pkg.vhd \
#         components/cpu/core/register_file.vhd \
#         components/cpu/core/register_file_flops.vhd \
#         components/cpu/core/register_file_two_bank.vhd \
#         components/cpu/decode/decode_pkg.vhd \
#         components/cpu/decode/decode_body.vhd \
#         components/cpu/decode/decode.vhd \
#         components/cpu/decode/decode_core.vhd \
#         components/cpu/decode/decode_table.vhd \
#         components/cpu/decode/decode_table_direct.vhd \
#         components/cpu/decode/decode_table_rom.vhd \
#         components/cpu/decode/decode_table_direct_config.vhd \
#         components/cpu/decode/decode_table_rom_config.vhd \
#         components/cpu/core/datapath_pkg.vhd \
#         components/cpu/core/datapath.vhd \
#         components/cpu/core/cpu.vhd \
#         components/cpu/core/cpu_config.vhd
        
################################################################################
# lib/hwutils/tests

analyse lib/hwutils/tests/flagsync_tb.vhd \
        lib/hwutils/tests/flancter_tb.vhd \
        lib/hwutils/tests/guardflancter_tb.vhd

for TOP in flagsync_tb flancter_tb guardflancter_tb; do
  elaborate
  run
done

################################################################################
# lib/fixed_dsm_pkg/tests

analyse lib/fixed_dsm_pkg/tests/add_carry_tb.vhd

for TOP in add_carry_tb; do
  elaborate
  run
done

################################################################################
# lib/reg_file_struct/tests

# Missing architecture "artisan"

# analyse lib/reg_file_struct/tests/bist_tb_pkg.vhd \
#         lib/reg_file_struct/tests/bist_rf_tb.vhd \
#         lib/reg_file_struct/tests/rf_tb.vhd \
        
# for TOP in bist_rf_tb rf_tb; do
#   elaborate
#   run
# done

################################################################################
# components/uartlite/tests

analyse components/uartlite/tests/uart_tb.vhd

for TOP in uart_tb; do
  elaborate
  run
done

################################################################################
# components/misc/tests

# Crash compiling sources

# analyse components/misc/tests/gpio_tap.vhd \
#         components/misc/tests/multi_master_bus_mux_tap.vhd \
#         components/misc/tests/spi_tb.vhd

# for TOP in gpio_tap multi_master_bus_mux_tap spi_tb; do
#   elaborate
#   run
# done

################################################################################
# components/cpu/tests

# Crash compiling sources

# analyse components/cpu/tests/arith_tap.vhd \
#         components/cpu/tests/manip_tap.vhd \
#         components/cpu/tests/bshift_tap.vhd \
#         components/cpu/tests/mult_tap.vhd \
#         components/cpu/tests/divider_tap.vhd \
#         components/cpu/tests/register_tap.vhd \
#         components/cpu/tests/logic_tap.vhd

# for TOP in arith_tap manip_tap bshift_tap mult_tap divider_tap \
#            register_tap logic_tap; do
#   elaborate
#   run
# done

################################################################################
# components/gps_if2/tests

analyse components/gps_if2/tests/gpsif_tb_pkg.vhd \
        components/gps_if2/tests/gpsif_tb.vhd

for TOP in gpsif_tb; do
  elaborate
  run
done

################################################################################
# components/cpu/sim

# analyse components/cpu/sim/monitor_pkg.vhd \
#         components/cpu/sim/data_bus_pkg.vhd \
#         components/cpu/sim/mem/asymmetric_ram.vhd \
#         components/cpu/sim/mem/cpu_sram.vhd \
#         components/cpu/sim/cpusim_miniaic2.vhd \
#         components/cpu/sim/cpu_pure_tb.vhd

# TODO: cpu_tb.vhd

# for TOP in cpu_pure_tb; do
#   elaborate
#   run
# done
