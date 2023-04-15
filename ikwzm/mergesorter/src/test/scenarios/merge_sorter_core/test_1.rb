require_relative '../scripts/scenario_writer.rb'
require_relative './sort.rb'

def test_1(file, mrg_ways, mrg_words, mrg_enable, stm_enable, stm_feedback, sort_order)

  title    = sprintf("Merge_Sorter_Core(MRG_WAYS=%d,MRG_WORDS=%d,MRG_ENABLE=%s,STM_ENABLE=%s,STM_FEEDBACK=%d) TEST 1", mrg_ways, mrg_words, mrg_enable.to_s, stm_enable.to_s, stm_feedback)
  data_bits= 32
  atrb_bits=  4
  random   = Random.new
  merchal  = ScenarioWriter::Marchal.new("MARCHAL", file)
  intake   = ScenarioWriter::IntakeStream.new("STM_I", file, mrg_words*data_bits, mrg_words*atrb_bits, data_bits, atrb_bits)
  outlet   = ScenarioWriter::OutletStream.new("OUT"  , file, mrg_words*data_bits, mrg_words*atrb_bits, data_bits, atrb_bits)
  blk_size = mrg_words*(mrg_ways**(stm_feedback+1))
  
  merchal.sync
  merchal.init
  intake.init
  outlet.init
  merchal.say "#{title} Start."

  if stm_enable == true then
    (1..2*blk_size+8).each_with_index do |size, index|
      intake_data = (1..size).to_a.map{|x| random.rand(0..1024)}
      while ((intake_data.size % mrg_words) > 0) do
        intake_data.push({PostPend: 1, None: 1})
      end
      outlet_data = []
      temp_data   = intake_data.dup
      while(not temp_data.empty?) do
        outlet_data.concat(sort(temp_data.shift(blk_size), sort_order))
      end
  
      merchal.sync
      merchal.say "#{title}.#{index+1} SIZE=#{size} Start."
      outlet.send_stm_request
      intake.transfer(intake_data, true)
      outlet.transfer(outlet_data, true)
      outlet.wait_stm_response
    end
  end 

  merchal.sync
  merchal.say "#{title} Done."
  merchal.sync
  
end
