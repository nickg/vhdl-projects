SENARIOS = axi4_stream_to_master_test_bench_32_32_256.snr \
           axi4_stream_to_master_test_bench_32_64_256.snr \
           axi4_stream_to_master_test_bench_64_32_256.snr \
           axi4_stream_to_master_test_bench_64_64_256.snr \
           $(END_FILE)

scenarios: $(SENARIOS)

clean:
	-rm $(SENARIOS)

axi4_stream_to_master_test_bench_32_32_256.snr : make_scenario.rb
	ruby make_scenario.rb -v --o_width 32 --i_width 32 --max_size 256 --output $@


axi4_stream_to_master_test_bench_32_64_256.snr : make_scenario.rb
	ruby make_scenario.rb -v --o_width 32 --i_width 64 --max_size 256 --output $@


axi4_stream_to_master_test_bench_64_32_256.snr : make_scenario.rb
	ruby make_scenario.rb -v --o_width 64 --i_width 32 --max_size 256 --output $@


axi4_stream_to_master_test_bench_64_64_256.snr : make_scenario.rb
	ruby make_scenario.rb -v --o_width 64 --i_width 64 --max_size 256 --output $@


