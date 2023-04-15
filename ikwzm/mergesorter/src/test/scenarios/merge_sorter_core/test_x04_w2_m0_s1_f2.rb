require_relative './test_1.rb'
require_relative './test_2.rb'

mrg_ways           = 4
mrg_words          = 2
mrg_enable         = false
stm_enable         = true
stm_feedback       = 2
sort_order         = 0
scenario_file_name = File.basename(__FILE__, ".rb") + ".snr"

File.open(scenario_file_name,'w') do |file|
  test_1(file, mrg_ways, mrg_words, mrg_enable, stm_enable, stm_feedback, sort_order)
  test_2(file, mrg_ways, mrg_words, mrg_enable, stm_enable, stm_feedback, sort_order)
end

