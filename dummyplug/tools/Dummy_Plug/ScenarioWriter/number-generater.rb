#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   1.7.3
#       Created     :   2019/9/27
#       File name   :   number-generater.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   番号(整数)を生成するクラスを定義しているモジュール.
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012,2013 Ichiro Kawazome
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
module Dummy_Plug
  module ScenarioWriter
    #-----------------------------------------------------------------------------
    # 値を生成するクラスの基底クラス
    #-----------------------------------------------------------------------------
    class NumberGenerater
      attr_reader :curr_life, :limit_life, :finite, :done
      def initialize(limit_life = 0)
        @limit_life = limit_life
        @finite     = (@limit_life > 0)
        @curr_life  = 0
        @done       = (@finite == true and @curr_life >= @limit_life)
      end
      def next
        @curr_life += 1 if @curr_life < @limit_life
        @done       = (@finite == true and @curr_life >= @limit_life)
      end
      def reset
        @curr_life  = 0
        @done       = (@finite == true and @curr_life >= @limit_life)
      end
    end
    #-----------------------------------------------------------------------------
    # 常に同じ値を生成するクラス
    #-----------------------------------------------------------------------------
    class ConstantNumberGenerater < NumberGenerater
      attr_reader :number
      def initialize(number, limit_life = 0)
        @number     = number
        super(limit_life)
      end
      def next
        return nil if @done == true
        num = @number
        super
        return @number
      end
    end
    #-----------------------------------------------------------------------------
    # 指定された配列から順番に値を生成するクラス
    #-----------------------------------------------------------------------------
    class SequentialNumberGenerater < NumberGenerater
      attr_reader :seq, :curr_index
      def initialize(seq, limit_life = 0)
        @seq        = Array.new(seq)
        @curr_index = 0
        super(limit_life)
      end
      def next
        return nil if @done == true
        num = @seq[@curr_index]
        @curr_index = (@curr_index < @seq.size-1) ? @curr_index+1 : 0
        super
        return num
      end
      def reset
        @curr_index = 0
        super
      end
    end
    #-----------------------------------------------------------------------------
    # 指定された配列からランダムに値を生成するクラス
    #-----------------------------------------------------------------------------
    class RandomNumberGenerater < NumberGenerater
      attr_reader :seq
      def initialize(seq, limit_life = 0)
        @seq = Array.new(seq)
        super(limit_life)
      end
      def next
        return nil if @done == true
        num = @seq[rand(@seq.size)]
        super
        return num
      end
    end
    #-----------------------------------------------------------------------------
    # 値を生成するクラスを複合したクラス
    #-----------------------------------------------------------------------------
    class GenericNumberGenerater < NumberGenerater
      attr_reader :seq, :curr_index
      def initialize(args, limit_life = 0)
        count = 1
        @seq = Array.new()
        if args.kind_of?(Range) then
          args = args.to_a
        end
        args.each {|arg|
        ## p arg.class
          if arg.kind_of?(Dummy_Plug::ScenarioWriter::ConstantNumberGenerater  ) or
             arg.kind_of?(Dummy_Plug::ScenarioWriter::SequentialNumberGenerater) or
             arg.kind_of?(Dummy_Plug::ScenarioWriter::RandomNumberGenerater    ) or
             arg.kind_of?(Dummy_Plug::ScenarioWriter::GenericNumberGenerater   ) then
            @seq.push(arg)
          elsif arg.kind_of?(Range) then
            vec = arg.to_a
            if count < args.size
              @seq.push(SequentialNumberGenerater.new(vec,vec.size))
            else
              @seq.push(SequentialNumberGenerater.new(vec,0))
            end
          elsif arg.kind_of?(Array) then
            if count < args.size
              @seq.push(SequentialNumberGenerater.new(arg,arg.size))
            else
              @seq.push(SequentialNumberGenerater.new(arg,0))
            end
          elsif arg.kind_of?(Integer) then
            if count < args.size
              @seq.push(ConstantNumberGenerater.new(arg, 1))
            else
              @seq.push(ConstantNumberGenerater.new(arg, 0))
            end
          else
            raise "Invalid Array Element (element=#{arg} element.class=#{arg.class})"
         end
          count = count + 1
        }
        @curr_index = 0
        super(limit_life)
      end
      def next
        return nil if @done == true
        num = @seq[@curr_index].next
        @curr_index += 1 if @seq[@curr_index].done
        super
        @done = (@done == true or @curr_index >= @seq.size)
        return num
      end
      def reset
        @seq.each {|gen| gen.reset}
        @curr_index = 0
        super
      end
    end
  end
end
