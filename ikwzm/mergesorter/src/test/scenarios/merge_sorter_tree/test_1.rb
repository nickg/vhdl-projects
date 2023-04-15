require_relative '../scripts/scenario_writer.rb'

def test_1(file, ways, words, sort_order, sign, count)

  def sort_proc(a,b, sort_order)
    if a.nil? then
      a_priority = 0
      a_postpend = 1
      a_data     = 0
    elsif a.kind_of?(Hash)
      a_priority = a.fetch(:Priority, 0)
      a_postpend = a.fetch(:PostPend, 0)
      a_data     = a.fetch(:Data    , 0)
    else
      a_priority = 0
      a_postpend = 0
      a_data     = a
    end 
    if b.nil? then
      b_priority = 0
      b_postpend = 1
      b_data     = 0
    elsif b.kind_of?(Hash)
      b_priority = b.fetch(:Priority, 0)
      b_postpend = b.fetch(:PostPend, 0)
      b_data     = b.fetch(:Data    , 0)
    else
      b_priority = 0
      b_postpend = 0
      b_data     = b
    end
    if    a_priority != 0 then
      -1
    elsif b_priority != 0 then
       1
    elsif a_postpend != 0 then
       1
    elsif b_postpend != 0 then
      -1
    elsif (sort_order == 0) then
      a_data <=> b_data
    else
      b_data <=> a_data
    end
  end

  title    = sprintf("Merge_Sorter_Tree(WAYS=%d,WORDS=%d,SORT_ORDER=%d,SIGN=%d) TEST 1", ways, words, sort_order, (sign)?1:0)
  data_bits= 32
  atrb_bits=  4
  info_bits=  4
  random   = Random.new
  merchal  = ScenarioWriter::Marchal.new("MARCHAL", file)
  intake   = (0..ways-1).to_a.map{ |i|
               name = sprintf("I%02X", i)
               ScenarioWriter::IntakeStream.new(name, file, words*data_bits, words*atrb_bits, data_bits, atrb_bits)
             }
  outlet   = ScenarioWriter::OutletStream.new("O" , file, words*data_bits, words*atrb_bits, data_bits, atrb_bits)
  n_min    = (sign)? -512 : 0;
  n_max    = (sign)?  512 : 1024;

  merchal.sync
  merchal.init
  merchal.say "#{title} Start."

  count.times do |test_num|
    merchal.sync
    merchal.say "#{title}.#{test_num+1} Start."
    size_min = 0
    size_max = words*4 + 2

    random.rand(1..4).times do

      intake_data = intake.map{ |channel|
        size = random.rand(0..size_max)
        vec  = (size == size_min  )? [{PostPend: 1, None: 1}] : 
               (size == size_max-1)? Array.new(size-1){|x| random.rand(n_min..n_max)}.push({PostPend: 1, None: 1}) :
               (size == size_max  )? Array.new(size-2){|x| random.rand(n_min..n_max)}.push({PostPend: 1, None: 1}).push({Priority: 1, None: 1}) :
                                     Array.new(size  ){|x| random.rand(n_min..n_max)}
        while((vec.size % words) > 0) do
          vec.push({PostPend: 1, None: 1})
        end
        vec.sort{|a,b| sort_proc(a,b,sort_order)}
      }
      outlet_data = intake_data.flatten.sort{|a,b| sort_proc(a,b,sort_order)}

      intake.each_with_index do |channel, index|
        channel.transfer(intake_data[index], true)
      end 
      outlet.transfer(outlet_data, true)
    end
  end

  merchal.sync
  merchal.say "#{title} Done."
  merchal.sync
  
end
