require_relative './test_1.rb'

ways               = 2
words              = 2
sort_order         = 0
sign               = false
scenario_file_name = File.basename(__FILE__, ".rb") + ".snr"

File.open(scenario_file_name,'w') do |file|
  test_1(file, ways, words, sort_order, sign, 100)
end

