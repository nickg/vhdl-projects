require 'optparse'
require_relative '../scripts/scenario_writer.rb'
require_relative './argsort_kernel_test_bench.rb'

class TestGenerator

  def initialize
    @program_name      = "test_gen"
    @program_version   = "1.0.0"
    @program_id        = @program_name + " " + @program_version
    @verbose           = false
    @debug             = false
    @test_scenarios    = []
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"){|val| @verbose = true}
    end
  end

  def parse_options(argv)
    @opt.order(argv) do |scenario|
      @test_scenarios << scenario
    end
  end

  def execute
    @test_scenarios.each do |scenario|
      m = /^test_x(?<ways>\d+)_w(?<words>\d+)_f(?<feedback>\d+)_(?<num>\d+)$/.match(scenario)
      ways     = m[:ways    ].to_i
      words    = m[:words   ].to_i
      feedback = m[:feedback].to_i
      num      = m[:num     ].to_i
      scenario_file_name = "#{scenario}.snr"
      if @verbose then
        puts "#{@program_id} : Generate #{scenario_file_name} ways=#{ways} words=#{words} feedback=#{feedback} test_num=#{num}"
      end
      File.open(scenario_file_name,'w') do |file|
        case num
        when 1 then
          test_1(file,ways,words,feedback)
        when 2 then
          test_2(file,ways,words,feedback)
        when 3
          test_3(file,ways,words,feedback)
        else
          abort "illegal test number #{num}"
        end
      end
    end
  end
  
  def test_1(file,ways,words,feedback)

    testbench = ArgSort_Kernel_Test_Bench.new(file,ways,words,feedback)

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

  def test_2(file,ways,words,feedback)

    testbench = ArgSort_Kernel_Test_Bench.new(file,ways,words,feedback)

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

  def test_3(file,ways,words,feedback)

    testbench = ArgSort_Kernel_Test_Bench.new(file,ways,words,feedback)

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
end

gen = TestGenerator.new
gen.parse_options(ARGV)
gen.execute


