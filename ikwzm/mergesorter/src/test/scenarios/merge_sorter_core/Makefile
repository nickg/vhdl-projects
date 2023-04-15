
SCENARIOS = test_x04_w1_m0_s1_f0 \
            test_x04_w1_m0_s1_f1 \
            test_x04_w1_m0_s1_f2 \
            test_x04_w1_m1_s0_f0 \
            test_x04_w1_m1_s1_f2 \
            test_x04_w2_m1_s0_f0 \
            test_x04_w2_m0_s1_f0 \
            test_x04_w2_m0_s1_f1 \
            test_x04_w2_m0_s1_f2 \
            $(END_OF_LIST)

SCENARIO_FILES = $(addsuffix .snr,$(SCENARIOS))

all: $(SCENARIO_FILES)

clean:
	rm $(SCENARIO_FILES)

%.snr : %.rb test_1.rb test_2.rb sort.rb
	ruby $<

