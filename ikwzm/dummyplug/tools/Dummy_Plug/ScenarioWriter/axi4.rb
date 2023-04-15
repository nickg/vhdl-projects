#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   1.7.3
#       Created     :   2019/9/27
#       File name   :   axi4.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   AXI4用シナリオ生成モジュール
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
require_relative "./number-generater"
module Dummy_Plug
  module ScenarioWriter
    module AXI4
      #---------------------------------------------------------------------------
      # AXI4::Sequence
      #---------------------------------------------------------------------------
      class Sequence
        attr_accessor :addr_start_event, :addr_delay_cycle
        attr_accessor :data_start_event, :data_xfer_pattern
        attr_accessor :resp_start_event, :resp_delay_cycle

        ADDR_START_EVENTS = [:NO_WAIT, :ADDR_VALID]
        DATA_START_EVENTS = [:NO_WAIT, :ADDR_VALID, :ADDR_XFER]
        RESP_START_EVENTS = [:NO_WAIT, :ADDR_VALID, :ADDR_XFER, :FIRST_DATA_XFER, :LAST_DATA_XFER]
        def set_start_event(evnet_types, event) 
          if evnet_types.include?(event) then
            return event
          else
            raise
          end
        end
        def set_addr_start_event(event)
          return set_start_event(ADDR_START_EVENTS,event)
        end
        def set_data_start_event(event)
          return set_start_event(DATA_START_EVENTS,event)
        end
        def set_resp_start_event(event)
          return set_start_event(RESP_START_EVENTS,event)
        end
        #-------------------------------------------------------------------------
        # initialize
        #-------------------------------------------------------------------------
        def initialize(args)
          @addr_start_event     = set_addr_start_event(:NO_WAIT   )
          @data_start_event     = set_data_start_event(:ADDR_VALID)
          @resp_start_event     = set_resp_start_event(:ADDR_XFER )
          @addr_delay_cycle     = 0
          @data_xfer_pattern    = Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0)
          @resp_delay_cycle     = 0
          setup(args)
        end
        #-------------------------------------------------------------------------
        # 指定された辞書に基づいて内部変数を設定するメソッド.
        #-------------------------------------------------------------------------
        def setup(args)
          if args.key?(:AddrStartEvent) then
            @addr_start_event  = set_addr_start_event(args[:AddrStartEvent])
          end
          if args.key?(:DataStartEvent) then
            @data_start_event  = set_data_start_event(args[:DataStartEvent])
          end
          if args.key?(:ResponseStartEvent) then
            @resp_start_event  = set_resp_start_event(args[:ResponseStartEvent])
          end
          if args.key?(:AddrDelayCycle) then
            @addr_delay_cycle  = args[:AddrDelayCycle]
          end
          if args.key?(:DataXferPattern) then
            @data_xfer_pattern = args[:DataXferPattern]
          end
          if args.key?(:ResponseDelayCycle) then
            @resp_delay_cycle  = args[:ResponseDelayCycle]
          end
        end
        #-------------------------------------------------------------------------
        # 自分自身のコピーを生成して返すメソッド.
        #-------------------------------------------------------------------------
        def clone(args = Hash.new())
          sequence = self.dup
          sequence.setup(args)
          return sequence
        end
        #-------------------------------------------------------------------------
        # データアクセスパターンをリセットして最初からパターンを生成しなおす.
        #-------------------------------------------------------------------------
        def reset
          @data_xfer_pattern.reset
        end
      end

      #---------------------------------------------------------------------------
      # AXI4::Transaction
      #---------------------------------------------------------------------------
      class Transaction
        attr_reader   :name, :write
        attr_reader   :max_transaction_size
        attr_reader   :address, :burst_length, :burst_type, :data_size
        attr_reader   :id, :lock, :cache, :qos, :region, :addr_user
        attr_reader   :data, :data_user, :byte_data, :data_pos
        attr_reader   :response, :resp_user
        #-------------------------------------------------------------------------
        # initialize
        #-------------------------------------------------------------------------
        def initialize(args)
          @max_transaction_size = 4096
          @write                = nil
          @id                   = nil
          @lock                 = nil
          @cache                = nil
          @qos                  = nil
          @region               = nil
          @address              = nil
          @data_size            = nil
          @burst_length         = nil
          @burst_type           = nil
          @addr_user            = nil
          @data                 = nil
          @data_user            = nil
          @response             = nil
          @resp_user            = nil
          @data_pos             = 0
          @data_offset          = 0
          setup(args)
        end
        #-------------------------------------------------------------------------
        # 指定された辞書に基づいて内部変数を設定するメソッド.
        #-------------------------------------------------------------------------
        def setup(args)
          @name                 = args[:Name              ] if args.key?(:Name              )
          @write                = (args[:Write] == true )   if args.key?(:Write             )
          @write                = (args[:Read ] == false)   if args.key?(:Read              )
          @max_transaction_size = args[:MaxTransactionSize] if args.key?(:MaxTransactionSize)
          @id                   = args[:ID                ] if args.key?(:ID                )
          @lock                 = args[:Lock              ] if args.key?(:Lock              )
          @cache                = args[:Cache             ] if args.key?(:Cache             )
          @qos                  = args[:QOS               ] if args.key?(:QOS               )
          @region               = args[:Region            ] if args.key?(:Region            )
          @address              = args[:Address           ] if args.key?(:Address           )
          @data_size            = args[:DataSize          ] if args.key?(:DataSize          )
          @burst_length         = args[:BurstLength       ] if args.key?(:BurstLength       )
          @burst_type           = args[:BurstType         ] if args.key?(:BurstType         )
          @addr_user            = args[:AddressUser       ] if args.key?(:AddressUser       )
          @data                 = args[:Data              ] if args.key?(:Data              )
          @data_user            = args[:DataUser          ] if args.key?(:DataUser          )
          @response             = args[:Response          ] if args.key?(:Response          )
          @resp_user            = args[:ResponseUser      ] if args.key?(:ResponseUser      )

          if @data then
            @byte_data    = generate_byte_data_array(@data)
            @burst_length = calc_burst_length(@byte_data) if (@burst_length == nil)
          end
        end
        #-------------------------------------------------------------------------
        # 自分自身のコピーを生成して返すメソッド.
        #-------------------------------------------------------------------------
        def clone(args = Hash.new())
          transaction = self.dup
          transaction.setup(args)
          return transaction
        end
        #-------------------------------------------------------------------------
        # バイトデータ配列からバースト長を計算するメソッド.
        # AXI4の仕様では ARLEN/AWLEN に指定する値はバースト長-1だが、
        # Dummy_PlugのAXI4モデルは バースト長(-1しない値)を指定する
        #-------------------------------------------------------------------------
        def calc_burst_length(byte_data_array)
          byte_size  = byte_data_array.size.to_f
          data_width = (2**@data_size).to_f
          address_lo = (@address % data_width).to_f
          return ((byte_size+address_lo)/data_width).ceil
        end
        #-------------------------------------------------------------------------
        # トランザクション時の推定転送バイト数を計算するメソッド.
        # AXI4 では バースト長(@burst_length)とアドレス(@address)の下位ビットで
        # 転送バイト数を推定するしかないため、正味の転送バイト数(byte_data.size)と
        # 食い違うことがある. このメソッドでは転送バイトの推定値を計算する.
        #-------------------------------------------------------------------------
        def estimate_request_size
          return (2**@data_size)*@burst_length - (@address % (2**@data_size))
        end
        #-------------------------------------------------------------------------
        # ワードデータを含む配列をバイトデータの配列に変換するメソッド.
        #-------------------------------------------------------------------------
        def generate_byte_data_array(data_array)
          byte_data = Array.new()
          data_array.each {|word_data|
            if    word_data.kind_of?(Integer) then
              byte_data.push((word_data & 0xFF))
            elsif word_data.kind_of?(String) then
              if word_data =~ /^0x([0-9a-fA-F]+)$/ then
                word_str  = $1
                byte_size = (word_str.length+1)/2
                byte_size.downto(1) {|i|
                  byte_data.push(word_str.slice(2*(i-1),2).hex)
                }
              end
            else # T.B.D
              raise "Invalid Array Element (element=#{word_data} element.class=#{word_data.class})"
            end
          }
          return byte_data
        end
        #-------------------------------------------------------------------------
        # アドレスチャネル信号の設定値を Dummy_Plug 形式で出力するメソッド.
        #-------------------------------------------------------------------------
        def generate_address_channel_signals(tag)
          tab = " " * tag.length
          str  = tag + "ADDR  : " + sprintf("0x%08X", @address      ) + "\n" +
                 tab + "SIZE  : " + sprintf("%d"    , 2**@data_size ) + "\n" +
                 tab + "LEN   : " + sprintf("%d"    , @burst_length ) + "\n"
          str += tab + "ID    : " + sprintf("%d"    , @id           ) + "\n" if (@id         != nil)
          str += tab + "BURST : " + sprintf("%s"    , @burst_type   ) + "\n" if (@burst_type != nil)
          str += tab + "LOCK  : " + sprintf("%d"    , @lock         ) + "\n" if (@lock       != nil)
          str += tab + "CACHE : " + sprintf("%d"    , @cache        ) + "\n" if (@cache      != nil)
          str += tab + "QOS   : " + sprintf("%d"    , @qos          ) + "\n" if (@qos        != nil)
          str += tab + "REGION: " + sprintf("%d"    , @region       ) + "\n" if (@region     != nil)
          str += tab + "USER  : " + sprintf("%d"    , @addr_user    ) + "\n" if (@addr_user  != nil)
          return str
        end
        #-------------------------------------------------------------------------
        # データチャネル信号の設定値を Dummy_Plug 形式で出力するメソッド.
        #-------------------------------------------------------------------------
        def generate_data_channel_signals(tag, width, nil_data)
          tab = " " * tag.length
          if @data_pos == 0 then
            @data_offset = @address     % width
          else
            @data_offset = @data_offset % width
          end
          last_word = false
          word_size = (2**@data_size) - (@data_offset % (2**@data_size))
          if @data_pos + word_size >= @byte_data.size then
              last_word = true
              word_size = @byte_data.size - @data_pos
          end
          word_data = Array.new(width, nil)
          word_data[@data_offset...@data_offset+word_size] = @byte_data[@data_pos...@data_pos+word_size]
          @data_pos    += word_size
          @data_offset += word_size
          str  = tag + sprintf("DATA  : %d'h", 8*width) + word_data.reverse.collect{ |d| 
                   if d == nil then 
                     nil_data
                   else
                     sprintf("%02X",d)
                   end
          }.join('') + "\n"
          if @write then
            str += tab + sprintf("STRB  : %d'b", width) + word_data.reverse.collect{ |d| 
                     if d == nil then 
                       "0"
                     else
                       "1"
                     end
            }.join('') + "\n"
          else
            str += tab + "RESP  : " + @response + "\n"
            str += tab + "ID    : " + @id.to_s + "\n" if (@id != nil)
          end
          str += tab + "LAST  : " + ((last_word) ? "1" : "0") + "\n"
          str += tab + "USER  : " + @data_user + "\n" if (@data_user != nil)
          return str
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::SignalWidth
      #---------------------------------------------------------------------------
      class SignalWidth
        attr_accessor :id, :addr, :data, :a_len , :a_cache,
                      :a_user, :r_user , :w_user, :b_user
        def initialize(params = Hash.new())
          @id      = params.key?(:ID_WIDTH     ) ? params[:ID_WIDTH     ] :  0
          @addr    = params.key?(:ADDR_WIDTH   ) ? params[:ADDR_WIDTH   ] : 32
          @data    = params.key?(:DATA_WIDTH   ) ? params[:DATA_WIDTH   ] : 32
          @a_len   = params.key?(:A_LEN_WIDTH  ) ? params[:A_LEN_WIDTH  ] :  8
          @a_cache = params.key?(:A_CACHE_WIDTH) ? params[:A_CACHE_WIDTH] :  1
          @a_user  = params.key?(:A_USER_WIDTH ) ? params[:A_USER_WIDTH ] :  0
          @r_user  = params.key?(:R_USER_WIDTH ) ? params[:R_USER_WIDTH ] :  0
          @w_user  = params.key?(:W_USER_WIDTH ) ? params[:W_USER_WIDTH ] :  0
          @b_user  = params.key?(:B_USER_WIDTH ) ? params[:B_USER_WIDTH ] :  0
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::Base
      #---------------------------------------------------------------------------
      class Base
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        attr_reader   :name, :width, :read_transaction, :write_transaction, :default_sequence
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        attr_accessor :default_sequence
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def initialize(name, params = Hash.new())
          @name                 = name
          @width                = SignalWidth.new(params)
          @default_transaction  = Transaction.new({
            :MaxTransactionSize => params.key?(:MAX_TRAN_SIZE) ? params[:MAX_TRAN_SIZE] : 4096,
            :ID                 => params.key?(:ID           ) ? params[:ID           ] : 0   ,
            :DataSize           => calc_data_size(@width.data)                                ,
            :BurstType          => "INCR"                                                     ,
            :Response           => "OKAY"                                                     
          })
          @read_transaction     = @default_transaction.clone({:Read  => true})
          @write_transaction    = @default_transaction.clone({:Write => true})
          @null_transaction     = @default_transaction.clone({:Address => 0, :BurstLength => 1})
          @default_sequence     = Sequence.new({
            :AddrStartEvent     => :NO_WAIT,
            :AddrDelayCycle     => 0,
            :ResponseStartEvent => :ADDR_VALID,
            :ResponseDelayCycle => 0,
            :DataStartEvent     => :ADDR_VALID,
            :DataXferPattern    => Dummy_Plug::ScenarioWriter::ConstantNumberGenerater.new(0)
          })
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def calc_data_size(data_width)
          case data_width
          when    8 then 0
          when   16 then 1
          when   32 then 2
          when   64 then 3
          when  128 then 4
          when  256 then 5
          when  512 then 6
          when 1024 then 7
          else           nil
          end
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def read(args)
          sequence    = @default_sequence.clone(args)
          transaction = @read_transaction.clone(args)
          sequence.reset
          return transaction_read(transaction, sequence)
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def write(args)
          sequence    = @default_sequence.clone(args)
          transaction = @write_transaction.clone(args)
          sequence.reset
          return transaction_write(transaction, sequence)
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def execute(transaction, sequence)
          if transaction.write then
            return transaction_write(transaction, sequence)
          else
            return transaction_read(transaction, sequence)
          end
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::Master
      #---------------------------------------------------------------------------
      class Master < Base
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def initialize(name, params = Hash.new())
          super(name, params)
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_address(tag, channel_name, transaction, addr_delay_cycle)
          str    = tag + channel_name + ":\n"
          tab    = " " * tag.length
          indent = tab + "- "
          if addr_delay_cycle > 0 then
            str += indent + "VALID : 0\n"
            str += @null_transaction.generate_address_channel_signals(indent)
            str += indent + "WAIT  : " + addr_delay_cycle.to_s + "\n"
          end
          str   += indent + "VALID : 1\n"
          str   += transaction.generate_address_channel_signals(indent)
          str   += indent + "WAIT  : {AVALID : 1, AREADY : 1}\n"
          str   += indent + "VALID : 0\n"
          str   += @null_transaction.generate_address_channel_signals(indent)
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_read(transaction, sequence)
          addr_delay_cycle  = sequence.addr_delay_cycle
          data_start_event  = sequence.data_start_event
          data_xfer_pattern = sequence.data_xfer_pattern
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AR", transaction, addr_delay_cycle
                   )
          str   += "  - R :\n"
          str   += "    - READY : 0\n"
          case data_start_event 
          when :ADDR_XFER  then
            str += "    - WAIT  : {AVALID : 1, AREADY : 1}\n"
          when :ADDR_VALID then
            str += "    - WAIT  : " + addr_delay_cycle.to_s + "\n"
          when :NO_WAIT then
          else
            raise
          end 
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait_cycle = data_xfer_pattern.next
            str += "    - WAIT  : " + data_wait_cycle.to_s + "\n"
            str += "    - READY : 1\n"
            str += "    - WAIT  : {RVALID : 1, RREADY : 1}\n"
            str += "    - CHECK :\n"
            str += transaction.generate_data_channel_signals("        ", @width.data/8, "--")
            str += "    - READY : 0\n"
          end
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_write(transaction, sequence)
          addr_delay_cycle  = sequence.addr_delay_cycle
          data_start_event  = sequence.data_start_event
          data_xfer_pattern = sequence.data_xfer_pattern
          resp_start_event  = sequence.resp_start_event
          resp_delay_cycle  = sequence.resp_delay_cycle
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AW", transaction, addr_delay_cycle
                   )
          str   += "  - W :\n"
          str   += "    - VALID : 0\n"
          str   += "      DATA  : 0\n"
          str   += "      STRB  : 0\n"
          str   += "      LAST  : 0\n"
          case data_start_event 
          when :ADDR_XFER  then
            str += "    - WAIT  : {AVALID : 1, AREADY : 1}\n"
          when :ADDR_VALID then
            str += "    - WAIT  : " + addr_delay_cycle.to_s + "\n"
          when :NO_WAIT then
          else
            raise
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait_cycle = data_xfer_pattern.next
            str += "    - WAIT  : " + data_wait_cycle.to_s + "\n"
            str += "    - VALID : 1\n"
            str += transaction.generate_data_channel_signals("      ", @width.data/8, "FF")
            str += "    - WAIT  : {WVALID : 1, WREADY : 1}\n"
            str += "    - VALID : 0\n"
          end
          str   += "    - DATA  : 0\n"
          str   += "      STRB  : 0\n"
          str   += "      LAST  : 0\n"
          str   += "  - B :\n"
          str   += "    - READY : 0\n"
          case resp_start_event
          when :LAST_DATA_XFER  then
            str += "    - WAIT  : {WVALID : 1, WREADY : 1, WLAST : 1, ON : on}\n"
          when :FIRST_DATA_XFER then
            str += "    - WAIT  : {WVALID : 1, WREADY : 1, ON : on}\n"
          when :ADDR_XFER  then
            str += "    - WAIT  : {AVALID : 1, AREADY : 1, ON : on}\n"
          when :ADDR_VALID then
            str += "    - WAIT  : " + addr_delay_cycle.to_s + "\n"
          when :NO_WAIT then
          else
            raise
          end
          str   += "    - WAIT  : " + resp_delay_cycle.to_s + "\n"
          str   += "    - READY : 1\n"
          str   += "    - WAIT  : {BVALID : 1, BREADY : 1}\n"
          str   += "    - CHECK : {RESP  : " + transaction.response + "}\n"
          str   += "    - READY : 0\n"
          return str
        end
      end
      #---------------------------------------------------------------------------
      # AXI4::Slave
      #---------------------------------------------------------------------------
      class Slave  < Base
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def initialize(name, params = Hash.new())
          super(name, params)
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_address(tag, channel_name, transaction, addr_start_event, addr_delay_cycle)
          str    = tag + channel_name + ":\n"
          tab    = " " * tag.length
          indent = tab + "- "
          case addr_start_event
          when :ADDR_VALID then
            str += indent + "READY : 0\n"
            str += indent + "WAIT  : {AVALID : 1, ON : on}\n"
          when :NO_WAIT then
            str += indent + "READY : 0\n"
          else 
            raise
          end
          if addr_delay_cycle > 0 then
            str += indent + "READY : 0\n"
            str += indent + "WAIT  : " + addr_delay_cycle.to_s + "\n"
          end
          str   += indent + "READY : 1\n"
          str   += indent + "WAIT  : {AVALID : 1, AREADY : 1}\n"
          str   += indent + "CHECK : \n"
          str   += transaction.generate_address_channel_signals(tab+"    ")
          str   += indent + "READY : 0\n"
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_read(transaction, sequence)
          addr_start_event  = sequence.addr_start_event
          addr_delay_cycle  = sequence.addr_delay_cycle
          data_start_event  = sequence.data_start_event
          data_xfer_pattern = sequence.data_xfer_pattern
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AR", transaction, addr_start_event, addr_delay_cycle
                   )
          str   += "  - R :\n"
          str   += "    - VALID : 0\n"
          str   += "      DATA  : 0\n"
          str   += "      LAST  : 0\n"
          case data_start_event
          when :ADDR_XFER  then
            str += "    - WAIT  : {AVALID : 1, AREADY : 1, ON : on}\n"
          when :ADDR_VALID then
            str += "    - WAIT  : {AVALID : 1, ON : on}\n"
          when :NO_WAIT then
          else
            raise
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait_cycle = data_xfer_pattern.next
            str += "    - WAIT  : " + data_wait_cycle.to_s + "\n"
            str += "    - VALID : 1\n"
            str += transaction.generate_data_channel_signals("      ", @width.data/8, "FF")
            str += "    - WAIT  : {RVALID : 1, RREADY : 1}\n"
            str += "    - VALID : 0\n"
          end
          str   += "    - DATA  : 0\n"
          str   += "      LAST  : 0\n"
          return str
        end
        #-------------------------------------------------------------------------
        # 
        #-------------------------------------------------------------------------
        def transaction_write(transaction, sequence)
          addr_start_event  = sequence.addr_start_event
          addr_delay_cycle  = sequence.addr_delay_cycle
          data_start_event  = sequence.data_start_event
          data_xfer_pattern = sequence.data_xfer_pattern
          resp_start_event  = sequence.resp_start_event
          resp_delay_cycle  = sequence.resp_delay_cycle
          str    = "- - " + @name.to_s + "\n"
          str   += transaction_address(
                   "  - ", "AW", transaction, addr_start_event, addr_delay_cycle
                   )
          str   += "  - W :\n"
          str   += "    - READY : 0\n"
          case data_start_event
          when :ADDR_XFER  then
            str += "    - WAIT  : {AVALID : 1, AREADY : 1, ON : on}\n"
          when :ADDR_VALID then
            str += "    - WAIT  : {AVALID : 1, ON : on}\n"
          when :NO_WAIT then
          else
            raise
          end  
          while (transaction.data_pos < transaction.byte_data.size) do
            data_wait_cycle = data_xfer_pattern.next
            str += "    - WAIT  : " + data_wait_cycle.to_s + "\n"
            str += "    - READY : 1\n"
            str += "    - WAIT  : {WVALID : 1, WREADY : 1}\n"
            str += "    - CHECK :\n"
            str += transaction.generate_data_channel_signals("        ", @width.data/8, "--")
            str += "    - READY : 0\n"
          end
          str   += "  - B :\n"
          str   += "    - VALID : 0\n"
          case resp_start_event
          when :LAST_DATA_XFER  then
            str += "    - WAIT  : {WVALID : 1, WREADY : 1, WLAST : 1, ON : on}\n"
          when :FIRST_DATA_XFER then
            str += "    - WAIT  : {WVALID : 1, WREADY : 1, ON : on}\n"
          when :ADDR_XFER       then
            str += "    - WAIT  : {AVALID : 1, AREADY : 1, ON : on}\n"
          when :ADDR_VALID      then
            str += "    - WAIT  : {AVALID : 1, ON : on}\n"
          when :NO_WAIT then
          else
            raise
          end  
          str   += "    - WAIT  : " + resp_delay_cycle.to_s + "\n"
          str   += "    - VALID : 1\n"
          str   += "      RESP  : " + transaction.response + "\n"
          str   += "    - WAIT  : {BVALID : 1, BREADY : 1}\n"
          str   += "    - VALID : 0\n"
          return str
        end
      end
    end
  end
end
