
TEST_SCENARIOS = test_4_8_1x1x1_1x1x1_1_1.snr   \
                 test_4_8_4x1x1_4x1x1_1_1.snr   \
                 test_1_8_1x4x1_1x5x5_1_1.snr   \
                 test_0_2_32x1x1_32x3x3_8_4.snr \
                 $(END_LIST)

all: $(TEST_SCENARIOS)

clean:
	rm $(TEST_SCENARIOS)

test_4_8_1x1x1_1x1x1_1_1.snr    : make_4_8_1x1x1_1x1x1_1_1.rb   image_stream_buffer.rb
	ruby $<

test_4_8_4x1x1_4x1x1_1_1.snr    : make_4_8_4x1x1_4x1x1_1_1.rb   image_stream_buffer.rb
	ruby $<

test_1_8_1x4x1_1x5x5_1_1.snr    : make_1_8_1x4x1_1x5x5_1_1.rb   image_stream_buffer.rb
	ruby $<

test_0_2_32x1x1_32x3x3_8_4.snr  : make_0_2_32x1x1_32x3x3_8_4.rb image_stream_buffer.rb
	ruby $<

