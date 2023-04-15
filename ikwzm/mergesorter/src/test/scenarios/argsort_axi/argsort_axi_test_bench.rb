
class ArgSort_AXI_Test_Bench

  attr_reader   :name, :csr, :merchal
  attr_reader   :stm_mem, :stm_mem_addr, :stm_mem_size
  attr_reader   :mrg_mem, :mrg_mem_addr, :mrg_mem_size

  def initialize(file)
    @sort_order   = 0
    @stm_mem_addr = 0x81000000
    @stm_mem_size = 32*1024
    @rd_offset    = 0x0000
    @rd_size      = @stm_mem_size/2
    @wr_offset    = @stm_mem_size/2
    @wr_size      = @stm_mem_size/2
    @mrg_mem_addr = 0x81000000
    @mrg_mem_size = 32*1024
    @t0_offset    = 0x0000
    @t0_size      = @mrg_mem_size/2
    @t1_offset    = @mrg_mem_size/2
    @t1_size      = @mrg_mem_size/2
    @regs_addr    = 0x00000000
    @csr          = CSR.new("CSR", file, @regs_addr)
    @merchal      = ScenarioWriter::Marchal.new("MARCHAL", file)
    @stm_mem      = ScenarioWriter::AXI_Memory.new("STM" , file, @stm_mem_size, @stm_mem_addr, 15, 2)
    @mrg_mem      = ScenarioWriter::AXI_Memory.new("MRG" , file, @mrg_mem_size, @mrg_mem_addr,  0, 0)
    @tag          = "ArgSort_AXI_Test"
  end

  def start(title)
    @title = "#{@tag} #{title}"
    @merchal.sync
    @merchal.say "#{@title} Start."
    @merchal.init
    @stm_mem.init
    @mrg_mem.init
  end

  def done
    @merchal.sync
    @merchal.say "#{@title} Done."
    @merchal.sync
  end

  def run(data, args, title, params=nil)
    if ((data.length * 4) > @rd_size) then
      abort "#{title} data size overflow"
    end
    if ((args.length * 4) > @wr_size) then
      abort "#{title} args size overflow"
    end
    if ((data.length * 8) > @t0_size) then
      abort "#{title} data size overflow"
    end
    if ((data.length * 8) > @t1_size) then
      abort "#{title} data size overflow"
    end
    csr_params = (params.nil?)? Hash.new : params.dup
    csr_params[:rd_addr  ] = @stm_mem_addr + @rd_offset
    csr_params[:wr_addr  ] = @stm_mem_addr + @wr_offset
    csr_params[:t0_addr  ] = @mrg_mem_addr + @t0_offset
    csr_params[:t1_addr  ] = @mrg_mem_addr + @t1_offset
    csr_params[:rd_cache ] = @stm_mem.cache if not @stm_mem.cache.nil?
    csr_params[:rd_prot  ] = @stm_mem.prot  if not @stm_mem.prot.nil?
    csr_params[:wr_cache ] = @stm_mem.cache if not @stm_mem.cache.nil?
    csr_params[:wr_prot  ] = @stm_mem.prot  if not @stm_mem.prot.nil?
    csr_params[:t0_cache ] = @mrg_mem.cache if not @mrg_mem.cache.nil?
    csr_params[:t0_prot  ] = @mrg_mem.prot  if not @mrg_mem.prot.nil?
    csr_params[:t1_cache ] = @mrg_mem.cache if not @mrg_mem.cache.nil?
    csr_params[:t1_prot  ] = @mrg_mem.prot  if not @mrg_mem.prot.nil?
    csr_params[:size     ] = data.length
    csr_params[:interrupt] = true
    @merchal.sync
    @merchal.say "#{@tag} #{title} Start."
    @merchal.sync
    @csr.run(csr_params)
    @stm_mem.set_word_data(  data, @rd_offset)
    @stm_mem.run
    @stm_mem.check_word_data(args, @wr_offset)
    @mrg_mem.run
    @merchal.sync
    @merchal.say "#{@tag} #{title} Done."
  end

  def argsort(data)
    data_with_index = data.map.with_index{|n,i| [n,i]}
    if (@sort_order == 0)
      sorted_data = data_with_index.sort do |a,b|
        r = a[0] <=> b[0]
        (r == 0)? a[1] <=> b[1] : r
      end
    else
      sorted_data = data_with_index.sort do |a,b|
        r = b[0] <=> a[0]
        (r == 0)? a[1] <=> b[1] : r
      end
    end
    sorted_data.map{|a| a[1]}
  end

  class CSR < ScenarioWriter::Writer

    def initialize(name, file, regs_addr)
      super(name,file)
      @regs_addr         = regs_addr
      @rd_addr_regs_addr = regs_addr + 0x08;
      @wr_addr_regs_addr = regs_addr + 0x10;
      @t0_addr_regs_addr = regs_addr + 0x18;
      @t1_addr_regs_addr = regs_addr + 0x20;
      @rd_mode_regs_addr = regs_addr + 0x28;
      @wr_mode_regs_addr = regs_addr + 0x2C;
      @t0_mode_regs_addr = regs_addr + 0x30;
      @t1_mode_regs_addr = regs_addr + 0x34;
      @size_regs_addr    = regs_addr + 0x38;
      @ctrl_regs_addr    = regs_addr + 0x3C;
    end

    def init
    end

    def check_32bit(addr, data, name)
      @file.printf("  - READ : {ADDR: 0x%08X, DATA: \"32'h%08X\"} # #{name}[31:00]\n", addr+0, (data >> 0)& 0xFFFFFFFF)
    end

    def check_64bit(addr, data, name)
      @file.printf("  - READ : {ADDR: 0x%08X, DATA: \"32'h%08X\"} # #{name}[31:00]\n", addr+0, (data >> 0)& 0xFFFFFFFF)
      @file.printf("  - READ : {ADDR: 0x%08X, DATA: \"32'h%08X\"} # #{name}[63:32]\n", addr+4, (data >>32)& 0xFFFFFFFF)
    end

    def write_32bit(addr, data, name)
      @file.printf("  - WRITE: {ADDR: 0x%08X, DATA: \"32'h%08X\"} # #{name}[31:00]\n", addr+0, (data >> 0)& 0xFFFFFFFF)
    end

    def write_64bit(addr, data, name)
      @file.printf("  - WRITE: {ADDR: 0x%08X, DATA: \"32'h%08X\"} # #{name}[31:00]\n", addr+0, (data >> 0)& 0xFFFFFFFF)
      @file.printf("  - WRITE: {ADDR: 0x%08X, DATA: \"32'h%08X\"} # #{name}[63:32]\n", addr+4, (data >>32)& 0xFFFFFFFF)
    end

    def setup(params)
      if (params.key?(:rd_addr))
        write_64bit(@rd_addr_regs_addr, params[:rd_addr], "RD_ADDR")
      end
      if (params.key?(:wr_addr))
        write_64bit(@wr_addr_regs_addr, params[:wr_addr], "WR_ADDR")
      end
      if (params.key?(:t0_addr))
        write_64bit(@t0_addr_regs_addr, params[:t0_addr], "T0_ADDR")
      end
      if (params.key?(:t1_addr))
        write_64bit(@t1_addr_regs_addr, params[:t1_addr], "T1_ADDR")
      end

      rd_mode = params.fetch(:rd_mode, 0x00000000)
      rd_mode = rd_mode | ((params[:rd_cache] & 0xF) <<  4) if params.key?(:rd_cache)
      rd_mode = rd_mode | ((params[:rd_prot ] & 0x7) <<  8) if params.key?(:rd_prot )
      rd_mode = rd_mode | ((params[:rd_user ] & 0x1) << 11) if params.key?(:rd_user )
      rd_mode = rd_mode | (1                         << 14) if params.fetch(:rd_speculative, false)
      rd_mode = rd_mode | (1                         << 15) if params.fetch(:rd_safety, false)
      write_32bit(@rd_mode_regs_addr, rd_mode, "RD_MODE")
      
      wr_mode = params.fetch(:wr_mode, 0x00000000)
      wr_mode = wr_mode | ((params[:wr_cache] & 0xF) <<  4) if params.key?(:wr_cache)
      wr_mode = wr_mode | ((params[:wr_prot ] & 0x7) <<  8) if params.key?(:wr_prot )
      wr_mode = wr_mode | ((params[:wr_user ] & 0x1) << 11) if params.key?(:wr_user )
      wr_mode = wr_mode | (1                         << 14) if params.fetch(:wr_speculative, false)
      wr_mode = wr_mode | (1                         << 15) if params.fetch(:wr_safety, false)
      write_32bit(@wr_mode_regs_addr, wr_mode, "WR_MODE")
      
      t0_mode = params.fetch(:t0_mode, 0x00000000)
      t0_mode = t0_mode | ((params[:t0_cache] & 0xF) <<  4) if params.key?(:t0_cache)
      t0_mode = t0_mode | ((params[:t0_prot ] & 0x7) <<  8) if params.key?(:t0_prot )
      t0_mode = t0_mode | ((params[:t0_user ] & 0x1) << 11) if params.key?(:t0_user )
      t0_mode = t0_mode | (1                         << 14) if params.fetch(:t0_speculative, false)
      t0_mode = t0_mode | (1                         << 15) if params.fetch(:t0_safety, false)
      write_32bit(@t0_mode_regs_addr, t0_mode, "T0_MODE")
      
      t1_mode = params.fetch(:t1_mode, 0x00000000)
      t1_mode = t1_mode | ((params[:t1_cache] & 0xF) <<  4) if params.key?(:t1_cache)
      t1_mode = t1_mode | ((params[:t1_prot ] & 0x7) <<  8) if params.key?(:t1_prot )
      t1_mode = t1_mode | ((params[:t1_user ] & 0x1) << 11) if params.key?(:t1_user )
      t1_mode = t1_mode | (1                         << 14) if params.fetch(:t1_speculative, false)
      t1_mode = t1_mode | (1                         << 15) if params.fetch(:t1_safety, false)
      write_32bit(@t1_mode_regs_addr, t1_mode, "T1_MODE")
      
      if (params.key?(:size))
        write_32bit(@size_regs_addr   , params[:size   ], "SIZE   ")
      end

      ctrl_data = 0x00000000
      ctrl_data = ctrl_data | (1 <<  0) if params.fetch(:interrupt, false)
      ctrl_data = ctrl_data | (1 << 26) if params.fetch(:interrupt, false)
      ctrl_data = ctrl_data | (1 << 28) if params.fetch(:start    , false)
      ctrl_data = ctrl_data | (1 << 31) if params.fetch(:reset    , false)
      write_32bit(@ctrl_regs_addr, ctrl_data, "CSR    ")
    end

    def mem_start
      @file.puts "  - OUT  : {GPO(0): 1}"
    end 
    
    def mem_stop
      @file.puts "  - OUT  : {GPO(0): 0}"
    end

    def wait_interrupt(irq, timeout=1000000)
      @file.puts "  - WAIT : {GPI(0) : #{irq}, TIMEOUT: #{timeout}} # WAIT for IRQ=#{irq}"
    end

    def run(params)
      new_params = params.dup
      new_params[:start] = true
      my_name
      mem_start
      setup(new_params)
      if (new_params.fetch(:interrupt, false))
        wait_interrupt(1)
        check_32bit(@ctrl_regs_addr, 0x04010001, "CSR    ")
        write_32bit(@ctrl_regs_addr, 0x00000001, "CSR    ")
        wait_interrupt(0)
      end
      mem_stop
    end
    
  end  
  
end

