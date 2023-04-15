
def sort(data,order=0)
  def sort_proc(a,b, sort_order)
    if a[0].nil? then
      a_priority = 0
      a_postpend = 1
      a_data     = 0
    elsif a[0].kind_of?(Hash)
      a_priority = a[0].fetch(:Priority, 0)
      a_postpend = a[0].fetch(:PostPend, 0)
      a_data     = a[0].fetch(:Data    , 0)
    else
      a_priority = 0
      a_postpend = 0
      a_data     = a[0]
    end 
    if b[0].nil? then
      b_priority = 0
      b_postpend = 1
      b_data     = 0
    elsif b[0].kind_of?(Hash)
      b_priority = b[0].fetch(:Priority, 0)
      b_postpend = b[0].fetch(:PostPend, 0)
      b_data     = b[0].fetch(:Data    , 0)
    else
      b_priority = 0
      b_postpend = 0
      b_data     = b[0]
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
      r = a_data <=> b_data
      (r == 0)? a[1] <=> b[1] : r
    else
      r = b_data <=> a_data
      (r == 0)? a[1] <=> b[1] : r
    end
  end

  data_with_index = data.map.with_index{|n,i| [n,i]}
  sorted_data = data_with_index.sort{|a,b| sort_proc(a,b,order)}
  sorted_data.map{|a| a[0]}
end

