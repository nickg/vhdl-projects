require_relative './test_1.rb'

ways               = 2
sort_order         = 1
sign               = false
scenario_file_name = sprintf("test_x%02d_o%d_s0.snr", ways, sort_order)

File.open(scenario_file_name,'w') do |file|
  test_1(file, ways, sort_order, sign, 100)
end

