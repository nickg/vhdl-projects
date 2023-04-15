#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=1993
TOP=

A_OPTS=
E_OPTS=
R_OPTS=

NVC_OPTS="-M 32m"
GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

if [ ! -f src/test/scenarios/axi4_adapter/axi4_adapter_test_bench_4096_32_32.snr ]; then
  ./src/test/scenarios/axi4_adapter/make_scenario.rb \
    --name       AXI4_ADAPTER_TEST_4096_32_32 \
    --t_width    32 \
    --m_width    32 \
    --m_max_size 4096 \
    --output     src/test/scenarios/axi4_adapter/axi4_adapter_test_bench_4096_32_32.snr
fi

if [ ! -f src/test/scenarios/axi4_lite/axi4_lite_test_bench_32_32.snr ]; then
  (cd ./src/test/scenarios/axi4_lite && ./make_scenario.rb)
fi

WORK=dummy_plug

analyse ../dummyplug/src/main/vhdl/core/util.vhd \
        ../dummyplug/src/main/vhdl/core/reader.vhd \
        ../dummyplug/src/main/vhdl/core/vocal.vhd \
        ../dummyplug/src/main/vhdl/core/sync.vhd \
        ../dummyplug/src/main/vhdl/core/core.vhd \
        ../dummyplug/src/main/vhdl/core/marchal.vhd \
        ../dummyplug/src/main/vhdl/core/mt19937ar.vhd \
        ../dummyplug/src/main/vhdl/core/tinymt32.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_types.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_core.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_channel_player.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_master_player.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_models.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_signal_printer.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_slave_player.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_stream_master_player.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_stream_player.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_stream_slave_player.vhd \
        ../dummyplug/src/main/vhdl/axi4/axi4_memory_player.vhd

WORK=pipework

analyse ../pipework/src/components/components.vhd \
        ../pipework/src/components/float_intake_valve.vhd \
        ../pipework/src/components/float_outlet_valve.vhd \
        ../pipework/src/components/pipeline_register_controller.vhd \
        ../pipework/src/axi4/axi4_types.vhd \
        ../pipework/src/components/count_down_register.vhd \
        ../pipework/src/components/count_up_register.vhd \
        ../pipework/src/components/delay_adjuster.vhd \
        ../pipework/src/components/delay_register.vhd \
        ../pipework/src/components/float_intake_manifold_valve.vhd \
        ../pipework/src/components/float_outlet_manifold_valve.vhd \
        ../pipework/src/components/pipeline_register.vhd \
        ../pipework/src/components/queue_register.vhd \
        ../pipework/src/components/reducer.vhd \
        ../pipework/src/components/syncronizer.vhd \
        ../pipework/src/components/syncronizer_input_pending_register.vhd \
        ../pipework/src/pump/pump_components.vhd \
        ../pipework/src/pump/pump_control_register.vhd \
        ../pipework/src/axi4/axi4_components.vhd \
        ../pipework/src/axi4/axi4_data_port.vhd \
        ../pipework/src/components/chopper.vhd \
        ../pipework/src/components/pool_intake_port.vhd \
        ../pipework/src/components/pool_outlet_port.vhd \
        ../pipework/src/pump/pump_controller_intake_side.vhd \
        ../pipework/src/pump/pump_controller_outlet_side.vhd \
        ../pipework/src/pump/pump_flow_syncronizer.vhd \
        ../pipework/src/axi4/axi4_data_outlet_port.vhd \
        ../pipework/src/axi4/axi4_master_address_channel_controller.vhd \
        ../pipework/src/axi4/axi4_master_transfer_queue.vhd \
        ../pipework/src/components/queue_arbiter.vhd \
        ../pipework/src/components/queue_receiver.vhd \
        ../pipework/src/components/sdpram.vhd \
        ../pipework/src/pump/pump_stream_intake_controller.vhd \
        ../pipework/src/pump/pump_stream_outlet_controller.vhd \
        ../pipework/src/axi4/axi4_master_read_interface.vhd \
        ../pipework/src/axi4/axi4_master_write_interface.vhd \
        ../pipework/src/components/queue_tree_arbiter.vhd \
        ../pipework/src/axi4/axi4_register_read_interface.vhd \
        ../pipework/src/axi4/axi4_register_write_interface.vhd \
        ../pipework/src/components/register_access_decoder.vhd \
        ../pipework/src/components/register_access_syncronizer.vhd \
        ../pipework/src/axi4/axi4_register_interface.vhd \
        ../pipework/src/components/register_access_adapter.vhd \
        ../pipework/src/components/queue_arbiter_integer_arch.vhd \
        ../pipework/src/components/queue_arbiter_one_hot_arch.vhd \
        ../pipework/src/components/sdpram_model.vhd

WORK=merge_sorter

analyse src/main/vhdl/core/sorting_network.vhd \
        src/main/vhdl/core/word.vhd \
        src/main/vhdl/core/core_components.vhd \
        src/main/vhdl/core/word_compare.vhd \
        src/main/vhdl/core/word_pipeline_register.vhd \
        src/main/vhdl/core/oddeven_mergesort_network.vhd \
        src/main/vhdl/core/sorting_network_core.vhd \
        src/main/vhdl/core/word_queue.vhd \
        src/main/vhdl/interface/interface.vhd \
        src/main/vhdl/core/merge_sorter_node.vhd \
        src/main/vhdl/core/word_fifo.vhd \
        src/main/vhdl/core/word_reducer.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_axi_components.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_reader.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_writer.vhd \
        src/main/vhdl/interface/interface_components.vhd \
        src/main/vhdl/interface/merge_reader.vhd \
        src/main/vhdl/interface/merge_writer.vhd \
        src/main/vhdl/core/core_intake_fifo.vhd \
        src/main/vhdl/core/core_stream_intake.vhd \
        src/main/vhdl/core/merge_sorter_tree.vhd \
        src/main/vhdl/core/word_drop_none.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_axi_reader.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_axi_writer.vhd \
        src/main/vhdl/interface/interface_controller.vhd \
        src/main/vhdl/interface/merge_axi_reader.vhd \
        src/main/vhdl/interface/merge_axi_writer.vhd \
        src/main/vhdl/core/merge_sorter_core.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_axi_interface.vhd \
        src/main/vhdl/examples/argsort_axi/argsort_axi.vhd

WORK=work

analyse src/test/vhdl/argsort_axi_test_bench.vhd

for TOP in argsort_axi_test_bench_x04_w1_f0; do
  run_jit
done
