SCENARIOS = test_x06_o0_s0 \
            test_x08_o0_s0 \
            test_x08_o1_s0 \
            test_x08_o0_s1 \
            test_x08_o1_s1 \
            test_x09_o1_s0 \
            test_x10_o0_s0 \
            $(END_OF_LIST)

SCENARIO_FILES = $(addsuffix .snr,$(SCENARIOS))

all: $(SCENARIO_FILES)

clean:
	rm $(SCENARIO_FILES)

%.snr : %.rb test_1.rb
	ruby $<

