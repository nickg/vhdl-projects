require_relative '../scripts/scenario_writer.rb'

def test_1(file, words, sort_order, sign, count)

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

  title    = sprintf("Sorting Network(WORDS=%d,ORDER=%d,SIGN=%d) TEST 1", words, sort_order, (sign)?1:0)
  word_bits= 8
  atrb_bits= 4
  random   = Random.new
  merchal  = ScenarioWriter::Marchal.new("MARCHAL", file)
  intake   = ScenarioWriter::IntakeStream.new("I", file, words*word_bits, words*atrb_bits, word_bits, atrb_bits)
  outlet   = ScenarioWriter::OutletStream.new("O", file, words*word_bits, words*atrb_bits, word_bits, atrb_bits)
  n_min    = (sign)? -(2**(word_bits-1))   : 0;
  n_max    = (sign)?  (2**(word_bits-1))-1 : (2**(word_bits))-1;

  merchal.sync
  merchal.init
  merchal.say "#{title} Start."

  count.times do |test_num|
    merchal.sync
    merchal.say "#{title}.#{test_num+1} Start."
    random.rand(1..4).times do
    
      intake_data = Array.new(words){ |x|
        type=rand(0..99)
        data=random.rand(n_min..n_max)
        (type==0)? {PostPend: 1, None: 1, Data: 0} :
        (type==1)? {Priority: 1, None: 1, Data: 0} :
                   data
      }
      outlet_data = intake_data.sort{|a,b| sort_proc(a,b,sort_order)}

      intake.transfer(intake_data, true)
      outlet.transfer(outlet_data, true)
    end
  end

  merchal.sync
  merchal.say "#{title} Done."
  merchal.sync
  
end
