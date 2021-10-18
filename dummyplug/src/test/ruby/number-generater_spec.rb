#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   1.5.1
#       Created     :   2013/7/31
#       File name   :   number-generater_spec.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   Dummy_Plug::ScenarioWriter::NumberGenerater の Rspec
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
require 'rspec'
require_relative '../../../tools/Dummy_Plug/ScenarioWriter/number-generater'

describe 'Dummy_Plug::ScenarioWriter::NumberGenerater' do

  describe 'ConstantNumberGenerater.new(1)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(1) }
    context '新規作成後' do
      it "@number==1" do 
        @gen.number.should == 1
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "常に1を返す" do
        10.times do
          @gen.next.should == 1
          @gen.done.should be_false
        end
      end
    end
    context '２回実行後にリセット' do
      before { 2.times{@gen.next};@gen.reset }
      it "@number==1" do 
        @gen.number.should == 1
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "常に1を返す" do
        10.times do
          @gen.next.should == 1
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'ConstantNumberGenerater.new(2,3)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(2,3) }
    context '新規作成後' do
      it "@number==2" do 
        @gen.number.should == 2
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "3回だけ2を返し4回目以降はnilを返す" do
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '5回実行後にリセット' do
      before { 5.times{@gen.next}; @gen.reset }
      it "@number==2" do 
        @gen.number.should == 2
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "3回だけ2を返し4回目以降はnilを返す" do
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'SequentialNumberGenerater.new([0,1,2,3])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::SequentialNumberGenerater.new([0,1,2,3]) }
    context '新規作成後' do
      it "@seq==[0,1,2,3]" do 
        @gen.seq.should == [0,1,2,3]
      end
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3を順番に返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
      end
    end
    context '5回実行後にリセット' do
      before { 5.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3を順番に返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
      end
    end
  end

  describe 'SequentialNumberGenerater.new([3,2,1,0],5)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::SequentialNumberGenerater.new([3,2,1,0],5) }
    context '新規作成後' do
      it "@seq==[3,2,1,0]" do 
        @gen.seq.should == [3,2,1,0]
      end
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "3,2,1,0,3を返しその後はnilを返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 0
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '5回実行後にリセット' do
      before { 5.times{@gen.next}; @gen.reset }
      it "@seq==[3,2,1,0]" do 
        @gen.seq.should == [3,2,1,0]
      end
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "3,2,1,0,3を返しその後はnilを返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 0
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'RandomNumberGenerater.new([4,4,4,4,4,5,5,6,7,8],100)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::SequentialNumberGenerater.new([4,4,4,4,4,5,5,6,7,8],100) }
    context '新規作成後' do
      it "@seq==[4,4,4,4,4,5,5,6,7,8]" do 
        @gen.seq.should == [4,4,4,4,4,5,5,6,7,8]
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "100回だけ4,5,6,7,8の中からランダムに返しその後はnilを返す" do
        100.times do
          @gen.done.should be_false
          @gen.next.should be_within(2).of(6)
        end
        10.times do
          @gen.done.should be_true
          @gen.next.should == nil
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new(0...4)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new(0...4) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3,3,3,3....を返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        100.times do
          @gen.curr_index.should == 3
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
    context '5回実行後にリセット' do
      before { 5.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3,3,3,3....を返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        100.times do
          @gen.curr_index.should == 3
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new(0...4,6)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new(0...4,6) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3を返しその後はnilを返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '5回実行後にリセット' do
      before { 5.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3を返しその後はnilを返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'GenericNumberGenerater.new([0,1,2,3])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([0,1,2,3]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3,3,3,3....を返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        100.times do
          @gen.curr_index.should == 3
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
    context '3回実行後にリセット' do
      before { 3.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3,3,3,3....を返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        100.times do
          @gen.curr_index.should == 3
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new([0,1,2,3],6)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([0,1,2,3],6) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3を返しその後はnilを返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '3回実行後にリセット' do
      before { 3.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3を返しその後はnilを返す" do
        @gen.curr_index.should == 0
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.curr_index.should == 1
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.curr_index.should == 2
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.curr_index.should == 3
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'GenericNumberGenerater.new([[0,1,2,3]])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2,3]]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1,2,3,0,1,2,3...を返す" do
        10.times do
          @gen.next.should == 0
          @gen.done.should be_false
          @gen.next.should == 1
          @gen.done.should be_false
          @gen.next.should == 2
          @gen.done.should be_false
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1,2,3,0,1,2,3...を返す" do
        10.times do
          @gen.next.should == 0
          @gen.done.should be_false
          @gen.next.should == 1
          @gen.done.should be_false
          @gen.next.should == 2
          @gen.done.should be_false
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new([[0,1,2,3]],6)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2,3]],6) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'GenericNumberGenerater.new([0,[1,2,3]])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([0,[1,2,3]]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,1,2,3,1,2,3...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        10.times do
          @gen.next.should == 1
          @gen.done.should be_false
          @gen.next.should == 2
          @gen.done.should be_false
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,1,2,3,1,2,3...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        10.times do
          @gen.next.should == 1
          @gen.done.should be_false
          @gen.next.should == 2
          @gen.done.should be_false
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new([0,[1,2,3]],6)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([0,[1,2,3]],6) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,1,2を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,1,2を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'GenericNumberGenerater.new([[0,1,2],3])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2],3]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3,3,3...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3,3,3...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 3
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new([[0,1,2],3],6)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2],3],6) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,3,3を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'GenericNumberGenerater.new([[0,1,2],[3,4]])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2],[3,4]]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,4,3,4,3,4,3,4...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 3
          @gen.done.should be_false
          @gen.next.should == 4
          @gen.done.should be_false
        end
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,4,3,4,3,4,3,4...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 3
          @gen.done.should be_false
          @gen.next.should == 4
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new([[0,1,2],[3,4]],8)' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2],[3,4]],8) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,4,3,4,3を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 4
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 4
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,4,3,4,3を返しその後はnilを返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 4
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 4
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
        @gen.next.should == nil
        @gen.done.should be_true
      end
    end
  end

  describe 'GenericNumberGenerater.new([SequentialNumberGenerater.new([0,1,2,3],7),[4,5,6]])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([Dummy_Plug::ScenarioWriter::SequentialNumberGenerater.new([0,1,2,3],7),[4,5,6]]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1,2,4,5,6,4,5,6,4,5,6...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 4
          @gen.done.should be_false
          @gen.next.should == 5
          @gen.done.should be_false
          @gen.next.should == 6
          @gen.done.should be_false
        end
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1,2,4,5,6,4,5,6,4,5,6...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 4
          @gen.done.should be_false
          @gen.next.should == 5
          @gen.done.should be_false
          @gen.next.should == 6
          @gen.done.should be_false
        end
      end
    end
  end

  describe 'GenericNumberGenerater.new([GenericNumberGenerater.new([[0,1,2,3]],7),[4,5,6]])' do
    before  { @gen = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([[0,1,2,3]],7),[4,5,6]]) }
    context '新規作成後' do
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1,2,4,5,6,4,5,6,4,5,6...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 4
          @gen.done.should be_false
          @gen.next.should == 5
          @gen.done.should be_false
          @gen.next.should == 6
          @gen.done.should be_false
        end
      end
    end
    context '9回実行後にリセット' do
      before { 9.times{@gen.next}; @gen.reset }
      it "@curr_index==0" do 
        @gen.curr_index.should == 0
      end
      it "@done==false" do 
        @gen.done.should be_false
      end
      it "0,1,2,3,0,1,2,4,5,6,4,5,6,4,5,6...を返す" do
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        @gen.next.should == 3
        @gen.done.should be_false
        @gen.next.should == 0
        @gen.done.should be_false
        @gen.next.should == 1
        @gen.done.should be_false
        @gen.next.should == 2
        @gen.done.should be_false
        10.times do
          @gen.next.should == 4
          @gen.done.should be_false
          @gen.next.should == 5
          @gen.done.should be_false
          @gen.next.should == 6
          @gen.done.should be_false
        end
      end
    end
  end
end
