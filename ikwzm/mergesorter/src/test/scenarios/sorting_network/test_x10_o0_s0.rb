require_relative './test_1.rb'

words              = 10
sort_order         = 0
sign               = false
scenario_file_name = sprintf("test_x%02d_o%d_s%d.snr", words, sort_order, (sign)? 1 : 0)

File.open(scenario_file_name,'w') do |file|
  test_1(file, words, sort_order, sign, 100)
end

