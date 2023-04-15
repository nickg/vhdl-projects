TEST_SCENARIOS = test_x04_w1_f0_1 test_x04_w1_f0_2 test_x04_w1_f0_3 \
                 test_x04_w1_f1_1 test_x04_w1_f1_2 test_x04_w1_f1_3 \
                 test_x04_w1_f2_1 test_x04_w1_f2_2 test_x04_w1_f2_3 \
                 test_x04_w2_f2_1 test_x04_w2_f2_2 test_x04_w2_f2_3 \
                 test_x16_w1_f2_1 test_x16_w1_f2_2 test_x16_w1_f2_3 \
                 $(END_LIST)

all: $(foreach SCENARIO, $(TEST_SCENARIOS), $(addsuffix .snr,$(SCENARIO)))

clean:
	-rm $(foreach SCENARIO, $(TEST_SCENARIOS), $(addsuffix .snr,$(SCENARIO)))

define RUN
$(addsuffix .snr,$(1)): test_gen.rb argsort_kernel_test_bench.rb
	ruby test_gen.rb -v $(1)
endef

$(foreach SCENARIO, $(TEST_SCENARIOS), $(eval $(call RUN,$(SCENARIO))))

