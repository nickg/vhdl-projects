require_relative '../scripts/scenario_writer.rb'
require_relative './argsort_axi_test_bench.rb'

def test_2(file)

  testbench = ArgSort_AXI_Test_Bench.new(file)

  testbench.start("TEST 2")
  test_num = 1
  size_list= [512,768,1024]
  size_list.each do |size|
    title = "TEST 2.#{test_num} SIZE=#{size}"
    # data = Array.new(size){rand(-127..128)}
    data = Array.new(size){|i| i-(size/2).ceil}.shuffle
    args = testbench.argsort(data)
    testbench.run(data, args, title)
    test_num = test_num + 1
  end

  testbench.done
  
end

scenario_file_name = "test_2.snr"
File.open(scenario_file_name,'w') do |file|
  test_2(file)
end
