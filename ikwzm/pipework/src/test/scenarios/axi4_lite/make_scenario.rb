#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
require 'pp'

class ScenarioGenerater
  def initialize(name, axi4_data_width, regs_data_width)
    @name            = name
    @axi4_data_width = axi4_data_width
    @axi4_data_size  = (Math.log2(@axi4_data_width)).to_i
    @regs_data_width = regs_data_width
    @no              = 0
    @id              = 10
    @data            = (1..4096).collect{rand(256)}
  end

  def  gen_write(io, address, data, resp)
    io.print "  - WRITE : \n"
    io.print "      ADDR : ", sprintf("0x%08X", address), "\n"
    io.print "      ID   : ", @id, "\n"
    io.print "      DATA : [", (data.collect{ |d| sprintf("0x%02X",d)}).join(',') ,"]\n"
    io.print "      RESP : ", resp, "\n"
  end
  def  gen_read(io, address, data, resp)
    io.print "  - READ : \n"
    io.print "      ADDR : ", sprintf("0x%08X", address), "\n"
    io.print "      ID   : ", @id, "\n"
    io.print "      DATA : [", (data.collect{ |d| sprintf("0x%02X",d)}).join(',') ,"]\n"
    io.print "      RESP : ", resp, "\n"
  end

  def gen(io, address, data, resp)
    @no += 1
    io.print "---\n"
    io.print "- - [MARCHAL]\n"
    io.print "  - SAY : \"", @name, " " , @no, "\"\n"
    io.print "- - [MASTER] \n"
    gen_write(io, address, data, resp)
    io.print "---\n"
    io.print "- - [MASTER] \n"
    gen_read( io, address, data, resp)
  end

  def generate(file_name)
    io = open(file_name, "w")
    address = @data.length
    word_bytes = @axi4_data_width/8
    @no += 1
    io.print "---\n"
    io.print "- - [MARCHAL]\n"
    io.print "  - SAY : \"", @name, " " , @no, "\"\n"
    io.print "- - [MASTER] \n"
    while address > 0
        if (address % word_bytes > 0)
            data_len = rand(1..(address % word_bytes))
        else
            data_len = rand(1..word_bytes)
        end
        address  = address - data_len
        gen_write(io, address, @data[address..address+data_len-1], "OKAY")
    end
    io.print "---\n"
    io.print "- - [MASTER] \n"
    address = @data.length
    while address > 0 
        if (address % word_bytes > 0)
            data_len = rand(1..(address % word_bytes))
        else
            data_len = rand(1..word_bytes)
        end
        address  = address - data_len
        gen_read( io, address, @data[address..address+data_len-1], "OKAY")
    end
    io.print "---\n"
    io.close
  end
end

gen = ScenarioGenerater.new("AXI4 LITE TEST", 32,32)
gen.generate("axi4_lite_test_bench_32_32.snr")

gen = ScenarioGenerater.new("AXI4 LITE TEST", 32,64)
gen.generate("axi4_lite_test_bench_32_64.snr")

gen = ScenarioGenerater.new("AXI4 LITE TEST", 64,32)
gen.generate("axi4_lite_test_bench_64_32.snr")
