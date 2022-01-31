#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   1.8.2
#       Created     :   2020/10/7
#       File name   :   make_scneario.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   AXI4-Adapter用シナリオ生成スクリプト
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012,2020 Ichiro Kawazome
#       All rights reserved.
# 
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions
#       are met:
# 
#         1. Redistributions of source code must retain the above copyright
#            notice, this list of conditions and the following disclaimer.
# 
#         2. Redistributions in binary form must reproduce the above copyright
#            notice, this list of conditions and the following disclaimer in
#            the documentation and/or other materials provided with the
#            distribution.
# 
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#---------------------------------------------------------------------------------
require 'optparse'
require 'pp'
require_relative "../../../../../dummyplug/tools/Dummy_Plug/ScenarioWriter/axi4"
require_relative "../../../../../dummyplug/tools/Dummy_Plug/ScenarioWriter/number-generater"
class ScenarioGenerater
  #-------------------------------------------------------------------------------
  # インスタンス変数
  #-------------------------------------------------------------------------------
  attr_reader   :program_name, :program_version
  attr_accessor :name   , :file_name, :test_items
  attr_accessor :m_model, :m_axi4_data_width, :m_max_xfer_size
  attr_accessor :t_model, :t_axi4_data_width, :t_max_xfer_size

  #-------------------------------------------------------------------------------
  # initialize
  #-------------------------------------------------------------------------------
  def initialize
    @program_name      = "make_scenario"
    @program_version   = "0.0.3"
    @t_axi4_data_width = 32
    @m_axi4_data_width = 32
    @t_max_xfer_size   = 4096
    @m_max_xfer_size   = 4096
    @t_model           = nil
    @m_model           = nil
    @no                = 0
    @name              = "AXI4_ADAPTER_TEST"
    @file_name         = nil
    @test_items        = []
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"              ){|val| @verbose           = true     }
      opt.on("--name       STRING"    ){|val| @name              = val      }
      opt.on("--output     FILE_NAME" ){|val| @file_name         = val      }
      opt.on("--t_width    INTEGER"   ){|val| @t_axi4_data_width = val.to_i }
      opt.on("--m_width    INTEGER"   ){|val| @m_axi4_data_width = val.to_i }
      opt.on("--t_max_size INTEGER"   ){|val| @t_max_xfer_size   = val.to_i }
      opt.on("--m_max_size INTEGER"   ){|val| @m_max_xfer_size   = val.to_i }
      opt.on("--test_item  INTEGER"   ){|val| @test_items.push(val.to_i)    }
    end
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @opt.parse(argv)
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def data_size_array(width)
    return (0..12).to_a.select{|i| 8*(2**i) <= width}
  end
  #-------------------------------------------------------------------------------
  # スレーブ側とマスター側のライトトランザクションを生成するメソッド.
  #-------------------------------------------------------------------------------
  def gen_write(io, address, data, t_size, t_seq, m_seq)
    t_tran  = @t_model.write_transaction.clone({:Address => address, :Data => data, :DataSize => t_size})
    io.print @t_model.execute(t_tran, t_seq)
    m_addr          = address
    m_data          = data.dup
    m_max_xfer_size = @m_model.write_transaction.max_transaction_size
    while not m_data.empty? do
      x_size = m_max_xfer_size - m_addr % m_max_xfer_size
      x_size = m_data.length if (m_data.length < x_size)
      x_data = m_data.shift(x_size)
      m_tran = @m_model.write_transaction.clone({:Address => m_addr, :Data => x_data})
      io.print @m_model.execute(m_tran, m_seq)
      m_addr = m_addr + x_size
      m_seq  = m_seq.clone({:AddrStartEvent => :NO_WAIT, :DataStartEvent => :NO_WAIT})
    end
  end
  #-------------------------------------------------------------------------------
  # スレーブ側とマスター側のリードトランザクションを生成するメソッド.
  #-------------------------------------------------------------------------------
  def gen_read(io, address, data, t_size, t_seq, m_seq)
    t_tran  = @t_model.read_transaction.clone({:Address => address, :Data => data, :DataSize => t_size})
    io.print @t_model.execute(t_tran, t_seq)
    if (@t_axi4_data_width > @m_axi4_data_width) then
      t_req_size = t_tran.estimate_request_size
      m_dmy_size = t_req_size - data.size
      m_data = data + Array.new(m_dmy_size, 0xFF)
    else
      m_data = data.dup
    end
    m_addr          = address
    m_max_xfer_size = @m_model.read_transaction.max_transaction_size
    while not m_data.empty? do
      x_size = m_max_xfer_size - m_addr % m_max_xfer_size
      x_size = m_data.length if (m_data.length < x_size)
      x_data = m_data.shift(x_size)
      m_tran = @m_model.read_transaction.clone({:Address => m_addr, :Data => x_data})
      io.print @m_model.execute(m_tran, m_seq)
      m_addr = m_addr + x_size
      m_seq  = m_seq.clone({:AddrStartEvent => :NO_WAIT, :DataStartEvent => :NO_WAIT})
    end
  end
  #-------------------------------------------------------------------------------
  # タイミングをランダムに生成するメソッド.
  #-------------------------------------------------------------------------------
  def gen_randam_sequence(default_sequence)
  end
  #-------------------------------------------------------------------------------
  # テストシナリオ１
  # リードトランザクションテスト(ADDR=(0..8),SIZE=(1..20),DATA_SIZE=(8..))
  #-------------------------------------------------------------------------------
  def test_1(io)
    test_major_num    = 1
    test_minor_num    = 1
    address_pattern   = (0..8).to_a
    size_pattern      = (1..20).to_a
    data_size_pattern = data_size_array(@t_axi4_data_width)
    size_pattern.each { |size|
      address_pattern.each { |address|
        data_size_pattern.each { |t_size|
          title   = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
          test_minor_num = test_minor_num + 1
          if ((address % @t_max_xfer_size) + size) > @t_max_xfer_size then
            size = @t_max_xfer_size - (address % @t_max_xfer_size)
          end
          data    = (1..size).collect{rand(256)}
          t_seq   = @t_model.default_sequence.clone({})
          m_seq   = @m_model.default_sequence.clone({})
          io.print "---\n"
          io.print "- N : \n"
          io.print "  - SAY : ", title, sprintf(" READ  ADDR=0x%08X, SIZE=%-3d, DATA_SIZE=%d\n", address, size, 2**t_size)
          gen_read(io, address, data, t_size, t_seq, m_seq)
        }
      }
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # テストシナリオ２
  # ライトトランザクションテスト(ADDR=(0..8),SIZE=(1..20),DATA_SIZE=(8..))
  #-------------------------------------------------------------------------------
  def test_2(io)
    test_major_num    = 2
    test_minor_num    = 1
    address_pattern   = (0..8).to_a
    size_pattern      = (1..20).to_a
    data_size_pattern = data_size_array(@t_axi4_data_width)
    size_pattern.each { |size|
      address_pattern.each { |address|
        data_size_pattern.each { |t_size|
          title   = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
          test_minor_num = test_minor_num + 1
          if ((address % @t_max_xfer_size) + size) > @t_max_xfer_size then
            size = @t_max_xfer_size - (address % @t_max_xfer_size)
          end
          data    = (1..size).collect{rand(256)}
          t_seq   = @t_model.default_sequence.clone({})
          m_seq   = @m_model.default_sequence.clone({})
          io.print "---\n"
          io.print "- N : \n"
          io.print "  - SAY : ", title, sprintf(" WRITE ADDR=0x%08X, SIZE=%-3d, DATA_SIZE=%d\n", address, size, 2**t_size)
          gen_write(io, address, data, t_size, t_seq, m_seq)
        }
      }
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # テストシナリオ３
  # リードライトランダムテスト
  #-------------------------------------------------------------------------------
  def test_3(io)
    test_major_num           = 3
    read_write_select        = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,1])
    t_data_size_select       = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new(data_size_array(@t_axi4_data_width))
    addr_start_event_pattern = [:ADDR_VALID, :NO_WAIT  ]
    data_start_event_pattern = [:ADDR_VALID, :ADDR_XFER]
    resp_start_event_pattern = [:ADDR_VALID, :ADDR_XFER, :FIRST_DATA_XFER, :LAST_DATA_XFER]
    addr_delay_cycle_pattern = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    data_xfer_pattern        = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    resp_delay_cycle_pattern = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    (1..1000).each {|test_minor_num|  
      title   = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
      address = rand(@t_max_xfer_size)
      size    = rand(255)+1
      if ((address % @t_max_xfer_size) + size) > @t_max_xfer_size then
        size = @t_max_xfer_size - (address % @t_max_xfer_size)
      end
      data    = (1..size).collect{rand(256)}
      t_size  = t_data_size_select.next
      t_seq   = @t_model.default_sequence.clone({
        :AddrStartEvent     => addr_start_event_pattern[rand(addr_start_event_pattern.size)],
        :DataStartEvent     => data_start_event_pattern[rand(data_start_event_pattern.size)],
        :ResponseStartEvent => resp_start_event_pattern[rand(resp_start_event_pattern.size)],
        :AddrDelayCycle     => addr_delay_cycle_pattern.next,
        :DataXferPattern    => data_xfer_pattern.next,
        :ResponseDeleyCycle => resp_delay_cycle_pattern.next
      })
      m_seq   = @m_model.default_sequence.clone({
        :AddrStartEvent     => addr_start_event_pattern[rand(addr_start_event_pattern.size)],
        :DataStartEvent     => data_start_event_pattern[rand(data_start_event_pattern.size)],
        :ResponseStartEvent => resp_start_event_pattern[rand(resp_start_event_pattern.size)],
        :AddrDelayCycle     => addr_delay_cycle_pattern.next,
        :DataXferPattern    => data_xfer_pattern.next,
        :ResponseDeleyCycle => resp_delay_cycle_pattern.next
      })
      if read_write_select.next == 1 then
        io.print "---\n"
        io.print "- N : \n"
        io.print "  - SAY : ", title, sprintf(" WRITE ADDR=0x%08X, SIZE=%-3d, DATA_SIZE=%d\n", address, size, 2**t_size)
        gen_write(io, address, data, t_size, t_seq, m_seq)
      else
        io.print "---\n"
        io.print "- N : \n"
        io.print "  - SAY : ", title, sprintf(" READ  ADDR=0x%08X, SIZE=%-3d, DATA_SIZE=%d\n", address, size, 2**t_size)
        gen_read(io, address, data, t_size, t_seq, m_seq)
      end
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def generate
    if @file_name == nil then
        @file_name = sprintf("axi4_adapter_test_bench_%d_%d_%d.snr", @m_max_xfer_size, @t_axi4_data_width, @m_axi4_data_width)
    end
    if @test_items == []
      @test_items = [1,2,3,4,5,6]
    end
    if @t_model == nil
      @t_model = Dummy_Plug::ScenarioWriter::AXI4::Master.new("T", {
        :ID_WIDTH      =>  4,
        :ADDR_WIDTH    => 32,
        :DATA_WIDTH    => @t_axi4_data_width,
        :MAX_TRAN_SIZE => @t_max_xfer_size  
      })
    end
    if @m_model == nil
      m_max_xfer_size = 256*@m_axi4_data_width/8
      m_max_xfer_size = @m_max_xfer_size if (m_max_xfer_size >= @m_max_xfer_size)
      m_max_xfer_size = 4096             if (m_max_xfer_size >= 4096)
      @m_model = Dummy_Plug::ScenarioWriter::AXI4::Slave.new("M", {
        :ID_WIDTH      =>  4,
        :ADDR_WIDTH    => 32,
        :DATA_WIDTH    => @m_axi4_data_width,
        :MAX_TRAN_SIZE => m_max_xfer_size
      })
    end
    title = @name.to_s + 
            " T_DATA_WIDTH="    + @t_axi4_data_width.to_s + 
            " M_DATA_WIDTH="    + @m_axi4_data_width.to_s +
            " T_MAX_XFER_SIZE=" + @t_max_xfer_size.to_s   +
            " M_MAX_XFER_SIZE=" + @m_max_xfer_size.to_s
    io = open(@file_name, "w")
    io.print "---\n"
    io.print "- N : \n"
    io.print "  - SAY : ", title, "\n"
    @test_items.each {|item|
        test_1(io) if (item == 1)
        test_2(io) if (item == 2)
        test_3(io) if (item == 3)
     #  test_4(io) if (item == 4)
     #  test_5(io) if (item == 5)
     #  test_6(io) if (item == 6)
    }
  end
end


gen = ScenarioGenerater.new
gen.parse_options(ARGV)
gen.generate
