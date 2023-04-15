SCENARIOS = test_x02_o1_s0 \
            test_x02_o1_s1 \
            test_x04_o0_s0 \
            test_x04_o0_s1 \
            $(END_OF_LIST)

SCENARIO_FILES = $(addsuffix .snr,$(SCENARIOS))

all: $(SCENARIO_FILES)

clean:
	rm $(SCENARIO_FILES)

%.snr : %.rb test_1.rb
	ruby $<

