require_relative '../scripts/scenario_writer.rb'

def test_1(file, ways, sort_order, sign, count)

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

  title    = sprintf("Merge_Sorter_Tree(WAYS=%d,SORT_ORDER=%d,SIGN=%d) TEST 1", ways, sort_order, (sign)?1:0)
  random   = Random.new
  merchal  = ScenarioWriter::Marchal.new("MARCHAL", file)
  intake   = (0..ways-1).to_a.map{ |i|
               name = sprintf("I%02X", i)
               ScenarioWriter::IntakeStream.new(name, file, 32, 8, 32, 4)
             }
  outlet   = ScenarioWriter::OutletStream.new("O" , file, 32, 8, 32, 4)
  n_min    = (sign)? -512 : 0;
  n_max    = (sign)?  512 : 1024;

  merchal.sync
  merchal.init
  merchal.say "#{title} Start."

  count.times do |test_num|
    merchal.sync
    merchal.say "#{title}.#{test_num+1} Start."
    random.rand(1..4).times do
    
      intake_data = intake.map{ |channel|
        size = random.rand(0..6)
        vec  = (size == 0)? [{PostPend: 1, None: 1}] : 
               (size == 5)? Array.new(4){|x| random.rand(n_min..n_max)}.push({PostPend: 1, None: 1}) :
               (size == 6)? Array.new(4){|x| random.rand(n_min..n_max)}.push({PostPend: 1, None: 1}).push({Priority: 1, None: 1}) :
                            Array.new(size){|x| random.rand(n_min..n_max)}
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
