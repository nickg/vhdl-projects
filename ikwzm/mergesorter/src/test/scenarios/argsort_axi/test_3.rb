require_relative '../scripts/scenario_writer.rb'
require_relative './argsort_axi_test_bench.rb'

def test_3(file)

  testbench = ArgSort_AXI_Test_Bench.new(file)

  testbench.start("TEST 3")
  test_num = 1
  size_list= Array.new(20){rand(10..1024)}
  params   = {:rd_speculative => true,
              :wr_speculative => true,
              :t0_speculative => true,
              :t1_speculative => true}
  size_list.each do |size|
    title = "TEST 3.#{test_num} SIZE=#{size}"
    # data = Array.new(size){rand(-127..128)}
    data = Array.new(size){|i| i-(size/2).ceil}.shuffle
    args = testbench.argsort(data)
    testbench.run(data, args, title, params)
    test_num = test_num + 1
  end

  testbench.done
  
end

scenario_file_name = "test_3.snr"
File.open(scenario_file_name,'w') do |file|
  test_3(file)
end
