#!/bin/bash

cd $(dirname $0)
. ../functions.sh

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
        ../dummyplug/src/main/vhdl/axi4/axi4_stream_slave_player.vhd

WORK=pipework

analyse src/components/chopper.vhd \
        src/components/components.vhd \
        src/components/count_down_register.vhd \
        src/components/count_up_register.vhd \
        src/components/delay_adjuster.vhd \
        src/components/delay_register.vhd \
        src/components/float_intake_manifold_valve.vhd \
        src/components/float_intake_valve.vhd \
        src/components/float_outlet_manifold_valve.vhd \
        src/components/float_outlet_valve.vhd \
        src/components/pipeline_register.vhd \
        src/components/pipeline_register_controller.vhd \
        src/components/pool_intake_port.vhd \
        src/components/pool_outlet_port.vhd \
        src/components/priority_encoder_procedures.vhd \
        src/components/queue_arbiter.vhd \
        src/components/queue_arbiter_integer_arch.vhd \
        src/components/queue_arbiter_one_hot_arch.vhd \
        src/components/queue_receiver.vhd \
        src/components/queue_register.vhd \
        src/components/reducer.vhd \
        src/components/register_access_adapter.vhd \
        src/components/register_access_decoder.vhd \
        src/components/register_access_syncronizer.vhd \
        src/components/sdpram.vhd \
        src/components/sdpram_model.vhd \
        src/components/syncronizer.vhd \
        src/components/syncronizer_input_pending_register.vhd \
        src/components/unrolled_loop_counter.vhd \
        src/image/image_types.vhd \
        src/image/image_components.vhd \
        src/image/image_stream_atrb_generator.vhd \
        src/image/image_stream_buffer_bank_memory_reader.vhd \
        src/image/image_stream_buffer_bank_memory_writer.vhd \
        src/image/image_stream_buffer_bank_memory.vhd \
        src/image/image_stream_buffer_intake_line_selector.vhd \
        src/image/image_stream_buffer_outlet_line_selector.vhd \
        src/image/image_stream_channel_reducer.vhd \
        src/image/image_stream_buffer.vhd \
        src/convolution/convolution_types.vhd \
        src/convolution/convolution_components.vhd \
        src/convolution/convolution_parameter_buffer.vhd \
        src/convolution/convolution_parameter_buffer_reader.vhd \
        src/convolution/convolution_parameter_buffer_writer.vhd \
        src/pump/pump_components.vhd \
        src/pump/pipe_controller.vhd \
        src/pump/pipe_requester_interface.vhd \
        src/pump/pipe_responder_interface.vhd \
        src/pump/pump_control_register.vhd \
        src/pump/pump_controller_intake_side.vhd \
        src/pump/pump_flow_syncronizer.vhd \
        src/pump/pump_request_controller.vhd \
        src/pump/pump_stream_intake_controller.vhd \
        src/axi4/axi4_types.vhd \
        src/axi4/axi4_components.vhd \
        src/axi4/axi4_data_port.vhd \
        src/axi4/axi4_master_address_channel_controller.vhd \
        src/axi4/axi4_master_read_interface.vhd \
        src/axi4/axi4_master_transfer_queue.vhd \
        src/axi4/axi4_master_write_interface.vhd \
        src/axi4/axi4_register_interface.vhd \
        src/axi4/axi4_register_read_interface.vhd \
        src/axi4/axi4_register_write_interface.vhd \
        src/axi4/axi4_slave_read_interface.vhd \
        src/axi4/axi4_slave_write_interface.vhd \
        src/axi4/axi4_data_outlet_port.vhd \

WORK=work

analyse src/test/vhdl/chopper/chopper_function_model.vhd \
        src/test/vhdl/chopper/chopper_test_bench.vhd

for TOP in chopper_test_bench; do
 elaborate
 run
done

analyse src/test/vhdl/axi4_adapter/axi4_read_adapter.vhd \
        src/test/vhdl/axi4_adapter/axi4_write_adapter.vhd \
        src/test/vhdl/axi4_adapter/axi4_adapter.vhd \
        src/test/vhdl/axi4_adapter/axi4_adapter_test_bench.vhd \
        src/test/vhdl/axi4_adapter/axi4_adapter_test_bench_4096_32_32.vhd

for TOP in axi4_adapter_test_bench_4096_32_32; do
  elaborate
  run
done

analyse src/test/vhdl/axi4_lite/axi4_lite_test_bench.vhd \
        src/test/vhdl/axi4_lite/axi4_lite_test_bench_32_32.vhd

for TOP in axi4_lite_test_bench_32_32; do
  elaborate
  run
done

analyse src/test/vhdl/axi4_master_to_stream/axi4_master_to_stream.vhd \
        src/test/vhdl/axi4_master_to_stream/axi4_master_to_stream_test_bench.vhd

# Elaboration too slow
for top in axi4_m2s_tb_32_32_256_sync \
             axi4_m2s_tb_32_64_256_sync \
             axi4_m2s_tb_64_32_256_sync \
             axi4_m2s_tb_64_64_256_sync \
             axi4_m2s_tb_32_32_256_100mhz_250mhz \
             axi4_m2s_tb_32_32_256_250mhz_100mhz; do
  # elaborate
  # run
  true
done

analyse src/test/vhdl/axi4_register_interface/axi4_register_interface_test_bench.vhd \
        src/test/vhdl/axi4_register_interface/axi4_register_interface_test_bench_32_32.vhd \
        src/test/vhdl/axi4_register_interface/axi4_register_interface_test_bench_32_64.vhd \
        src/test/vhdl/axi4_register_interface/axi4_register_interface_test_bench_64_32.vhd

for TOP in axi4_register_interface_test_bench_32_32 \
             axi4_register_interface_test_bench_32_64 \
             axi4_register_interface_test_bench_64_32; do
  elaborate
  run
done

analyse src/test/vhdl/image_stream_models/image_stream_player.vhd \
        src/test/vhdl/image_stream_models/image_stream_master_player.vhd \
        src/test/vhdl/image_stream_models/image_stream_models.vhd \
        src/test/vhdl/image_stream_models/image_stream_player_test_bench.vhd \
        src/test/vhdl/image_stream_models/image_stream_slave_player.vhd \
        src/test/vhdl/convolution_parameter_buffer/convolution_parameter_buffer_test_bench.vhd \
        src/test/vhdl/image_stream_buffer/image_stream_buffer_test_bench.vhd

for TOP in convolution_parameter_buffer_test_bench_3x3x2x4 \
             image_stream_player_test_8x0x0x2x2 \
             image_stream_buffer_test_4_8_1x1x1_1x1x1x1; do
 elaborate
 run
done

analyse src/test/vhdl/delay_register/delay_register_test_bench.vhd

for TOP in delay_register_test_bench_all; do
  elaborate
  run
done

analyse src/test/vhdl/pipeline_register/pipeline_register_test_bench.vhd

for TOP in pipeline_register_test_bench_{0,1,2}; do
  elaborate
  run
done

analyse src/test/vhdl/priority_encoder/test_bench.vhd

for TOP in test_bench_all; do
  elaborate
  run
done

analyse src/test/vhdl/queue_arbiter/test_bench.vhd

for TOP in test_bench_one_hot_arch test_bench_integer_arch; do
  elaborate
  run
done

analyse src/test/vhdl/queue_receiver/queue_receiver_test_bench.vhd

for TOP in queue_receiver_test_bench_all; do
  elaborate
  run
done

analyse src/test/vhdl/sdpram/test_bench.vhd

for TOP in sdpram_test_bench_depth08_rd3_wd3_we0 \
             sdpram_test_bench_depth08_rd4_wd4_we0 \
             sdpram_test_bench_depth08_rd5_wd5_we0 \
             sdpram_test_bench_depth08_rd6_wd6_we3 \
             sdpram_test_bench_depth08_rd3_wd4_we0 \
             sdpram_test_bench_depth08_rd3_wd5_we0 \
             sdpram_test_bench_depth08_rd4_wd3_we0 \
             sdpram_test_bench_depth08_rd5_wd3_we0; do
  elaborate
  run
done
