require_relative '../scripts/scenario_writer.rb'
require_relative './argsort_axi_test_bench.rb'

def test_1(file)

  testbench = ArgSort_AXI_Test_Bench.new(file)

  testbench.start("TEST 1")
  test_num = 1
  (1..128).to_a.each do |size|
    title = "TEST 1.#{test_num}"
    # data = Array.new(size){rand(-2147483648..2147483647)}
    data = Array.new(size){|i| i-(size/2).ceil}.shuffle
    args = testbench.argsort(data)
    testbench.run(data, args, title)
    test_num = test_num + 1
  end

  testbench.done
  
end

scenario_file_name = "test_1.snr"
File.open(scenario_file_name,'w') do |file|
  test_1(file)
end
