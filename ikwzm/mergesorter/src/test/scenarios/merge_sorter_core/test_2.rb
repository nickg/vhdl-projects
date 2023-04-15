require_relative '../scripts/scenario_writer.rb'

def test_2(file, mrg_ways, mrg_words, mrg_enable, stm_enable, stm_feedback, sort_order, count=100)

  title    = sprintf("Merge_Sorter_Core(MRG_WAYS=%d,MRG_WORDS=%d,MRG_ENABLE=%s,STM_ENABLE=%s,STM_FEEDBACK=%d) TEST 2", mrg_ways, mrg_words, mrg_enable.to_s, stm_enable.to_s, stm_feedback)
  data_bits= 32
  atrb_bits=  4
  random   = Random.new
  merchal  = ScenarioWriter::Marchal.new("MARCHAL", file)
  intake   = (0..mrg_ways-1).to_a.map{ |i|
               name = sprintf("MRG_I%02X", i)
               ScenarioWriter::IntakeStream.new(name, file, mrg_words*data_bits, mrg_words*atrb_bits, data_bits, atrb_bits)
             }
  outlet   = ScenarioWriter::OutletStream.new("OUT" , file, mrg_words*data_bits, mrg_words*atrb_bits, data_bits, atrb_bits)
  
  merchal.sync
  merchal.init
  outlet.init
  merchal.say "#{title} Start."

  if mrg_enable == true then
  
    count.times do |test_num|
      merchal.sync
      merchal.say "#{title}.#{test_num+1} Start."
      outlet.send_mrg_request

      block_count = random.rand(1..4)
      block_count.times do |block_num|

        outlet_data = []
        while (outlet_data.size == 0) do
          intake_data = intake.map{ |channel|
            size = random.rand(0..4*mrg_words)
            (size == 0)? [nil] : sort(Array.new(size){|x| random.rand(0..1024)}, sort_order)
          }
          outlet_data = sort(intake_data.flatten.reject{|x| x.nil?}, sort_order)
        end
        intake_last = true
        intake_done = (block_num == block_count-1)
        outlet_last = intake_done

        intake.each_with_index do |channel, index|
          while ((intake_data[index].size % mrg_words) > 0) do
            intake_data[index].push({PostPend: 1, None: 1})
          end
          channel.transfer(intake_data[index], intake_last, intake_done)
        end
        while ((outlet_data.size % mrg_words) > 0) do
          outlet_data.push({PostPend: 1, None: 1})
        end
        outlet.transfer(outlet_data, outlet_last)
      end
      outlet.wait_mrg_response
    end
  end 

  merchal.sync
  merchal.say "#{title} Done."
  merchal.sync
  
end
