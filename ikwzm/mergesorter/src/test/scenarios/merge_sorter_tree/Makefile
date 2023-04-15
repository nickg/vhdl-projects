SCENARIOS = test_x02_w1_o1_s0 \
            test_x02_w1_o1_s1 \
            test_x04_w1_o0_s0 \
            test_x04_w1_o0_s1 \
            test_x02_w2_o0_s0 \
            test_x04_w2_o0_s0 \
            $(END_OF_LIST)

SCENARIO_FILES = $(addsuffix .snr,$(SCENARIOS))

all: $(SCENARIO_FILES)

clean:
	rm $(SCENARIO_FILES)

%.snr : %.rb test_1.rb
	ruby $<

