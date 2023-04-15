-----------------------------------------------------------------------------------
--!     @file    interface.vhd
--!     @brief   Merge Sorter Interface Package :
--!     @version 1.3.0
--!     @date    2021/7/14
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2021 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package Interface is
    -------------------------------------------------------------------------------
    -- Bit Slice Field Type
    -------------------------------------------------------------------------------
    type      Bit_Slice_Field_Type is record
                  BITS              :  integer;
                  LO                :  integer;
                  HI                :  integer;
                  POS               :  integer;
    end record;
    function  New_Bit_Slice_Field(BITS: integer; LO: integer := 0) return Bit_Slice_Field_Type;
    -------------------------------------------------------------------------------
    -- Interface Mode Register Field Type
    -------------------------------------------------------------------------------
    type      Mode_Regs_Field_Type  is record
                  BITS              :  integer;
                  LO                :  integer;
                  HI                :  integer;
                  SAFETY            :  Bit_Slice_Field_Type;
                  SPECUL            :  Bit_Slice_Field_Type;
                  AID               :  Bit_Slice_Field_Type;
                  AUSER             :  Bit_Slice_Field_Type;
                  APROT             :  Bit_Slice_Field_Type;
                  CACHE             :  Bit_Slice_Field_Type;
                  CLOSE             :  Bit_Slice_Field_Type;
                  ERROR             :  Bit_Slice_Field_Type;
                  DONE              :  Bit_Slice_Field_Type;
    end record;
    function  New_Mode_Regs_Field(LO : integer) return Mode_Regs_Field_Type;
    -------------------------------------------------------------------------------
    -- Interface Status Register Field Type
    -------------------------------------------------------------------------------
    type      Stat_Regs_Field_Type  is record
                  BITS              :  integer;
                  LO                :  integer;
                  HI                :  integer;
                  RESV              :  Bit_Slice_Field_Type;
                  CLOSE             :  Bit_Slice_Field_Type;
                  ERROR             :  Bit_Slice_Field_Type;
                  DONE              :  Bit_Slice_Field_Type;
    end record;
    function  New_Stat_Regs_Field(LO : integer) return Stat_Regs_Field_Type;
    -------------------------------------------------------------------------------
    -- Interface Control Register Field Type
    -------------------------------------------------------------------------------
    type      Ctrl_Regs_Field_Type  is record
                  BITS              :  integer;
                  LO                :  integer;
                  HI                :  integer;
                  RESET             :  Bit_Slice_Field_Type;
                  PAUSE             :  Bit_Slice_Field_Type;
                  STOP              :  Bit_Slice_Field_Type;
                  START             :  Bit_Slice_Field_Type;
                  EBLK              :  Bit_Slice_Field_Type;
                  DONE              :  Bit_Slice_Field_Type;
                  FIRST             :  Bit_Slice_Field_Type;
                  LAST              :  Bit_Slice_Field_Type;
    end record;
    function  New_Ctrl_Regs_Field(LO : integer) return Ctrl_Regs_Field_Type;
    -------------------------------------------------------------------------------
    -- Interface Register Field Type
    -------------------------------------------------------------------------------
    type      Regs_Field_Type  is record
                  BITS              :  integer;
                  BASE_ADDR         :  integer;
                  REGS_LO           :  integer;
                  REGS_HI           :  integer;
                  ADDR_BASE_ADDR    :  integer;
                  ADDR              :  Bit_Slice_Field_Type;
                  SIZE_BASE_ADDR    :  integer;
                  SIZE              :  Bit_Slice_Field_Type;
                  MODE_BASE_ADDR    :  integer;
                  MODE              :  Mode_Regs_Field_Type;
                  STAT_BASE_ADDR    :  integer;
                  STAT              :  Stat_Regs_Field_Type;
                  CTRL_BASE_ADDR    :  integer;
                  CTRL              :  Ctrl_Regs_Field_Type;
    end record;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Regs_Field_Type return Regs_Field_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  Default_Regs_Param : Regs_Field_Type := New_Regs_Field_Type;
    
end Interface;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
package body Interface is
    -------------------------------------------------------------------------------
    -- New Bit Slice Field
    -------------------------------------------------------------------------------
    function  New_Bit_Slice_Field(BITS: integer; LO: integer := 0) return Bit_Slice_Field_Type is
        variable  bit_field  :  Bit_Slice_Field_Type;
    begin
        bit_field.BITS := BITS;
        bit_field.POS  := LO;
        bit_field.LO   := LO;
        bit_field.HI   := LO + BITS - 1;
        return bit_field;
    end function;
    -------------------------------------------------------------------------------
    -- Interface Mode Register Field
    -------------------------------------------------------------------------------
    -- Mode[15]    = 1:AXI4 Master I/F をセイフティモードで動かす.
    -- Mode[14]    = 1:AXI4 Master I/F を投機モードで動かす.
    -- Mode[13]    = AXI4 Master I/F の AXID[0] の値を指定する.
    -- Mode[11]    = AXI4 Master I/F の ARUSER[0] の値を指定する.
    -- Mode[10:08] = AXI4 Master I/F の APORT[2:0] の値を指定する.
    -- Mode[07:04] = AXI4 Master I/F の ACHACHE[3:0]を指定する.
    -- Mode[03]    = 予約.
    -- Mode[02]    = 1:クローズ時(Status[2]='1')に割り込みを発生する.
    -- Mode[01]    = 1:エラー発生時(Status[1]='1')に割り込みを発生する.
    -- Mode[00]    = 1:転送終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    function  New_Mode_Regs_Field(LO: integer) return Mode_Regs_Field_Type is
        variable  mode_regs_field  :  Mode_Regs_Field_Type;
    begin
        mode_regs_field.BITS   := 16;
        mode_regs_field.LO     := LO;
        mode_regs_field.HI     := LO + mode_regs_field.BITS - 1;
        mode_regs_field.SAFETY := New_Bit_Slice_Field(1, LO + 15);
        mode_regs_field.SPECUL := New_Bit_Slice_Field(1, LO + 14);
        mode_regs_field.AID    := New_Bit_Slice_Field(1, LO + 13);
        mode_regs_field.AUSER  := New_Bit_Slice_Field(1, LO + 11);
        mode_regs_field.APROT  := New_Bit_Slice_Field(3, LO +  8);
        mode_regs_field.CACHE  := New_Bit_Slice_Field(4, LO +  4);
        mode_regs_field.CLOSE  := New_Bit_Slice_Field(1, LO +  2);
        mode_regs_field.ERROR  := New_Bit_Slice_Field(1, LO +  1);
        mode_regs_field.DONE   := New_Bit_Slice_Field(1, LO +  0);
        return mode_regs_field;
    end function;
    -------------------------------------------------------------------------------
    -- Interface Status Register Field Type
    -------------------------------------------------------------------------------
    -- Status[7:3] = 予約.
    -- Status[2]   = クローズ時にセットされる
    -- Status[1]   = エラー発生時にセットされる.
    -- Status[0]   = 転送終了時かつ Control[2]='1' にセットされる.
    -------------------------------------------------------------------------------
    function  New_Stat_Regs_Field(LO : integer) return Stat_Regs_Field_Type is
        variable  stat_regs_field  :  Stat_Regs_Field_Type;
    begin
        stat_regs_field.BITS   :=  8;
        stat_regs_field.LO     := LO;
        stat_regs_field.HI     := LO + stat_regs_field.BITS - 1;
        stat_regs_field.RESV   := New_Bit_Slice_Field(5, LO + 3);
        stat_regs_field.CLOSE  := New_Bit_Slice_Field(1, LO + 2);
        stat_regs_field.ERROR  := New_Bit_Slice_Field(1, LO + 1);
        stat_regs_field.DONE   := New_Bit_Slice_Field(1, LO + 0);
        return stat_regs_field;
    end function;
    -------------------------------------------------------------------------------
    -- Interface Control Register Field Type
    -------------------------------------------------------------------------------
    -- Control[7]  = 1:モジュールをリセットする. 0:リセットを解除する.
    -- Control[6]  = 1:転送を一時中断する.       0:転送を再開する.
    -- Control[5]  = 1:転送を中止する.           0:意味無し.
    -- Control[4]  = 1:転送を開始する.           0:意味無し.
    -- Control[3]  = 1:最後のブロックであることを指定する.
    -- Control[2]  = 1:転送終了時にStatus[0]がセットされる.
    -- Control[1]  = 1:連続したトランザクションの開始を指定する.
    -- Control[0]  = 1:連続したトランザクションの終了を指定する.
    -------------------------------------------------------------------------------
    function  New_Ctrl_Regs_Field(LO : integer) return Ctrl_Regs_Field_Type is
        variable  ctrl_regs_field  :  Ctrl_Regs_Field_Type;
    begin
        ctrl_regs_field.BITS   :=  8;
        ctrl_regs_field.LO     := LO;
        ctrl_regs_field.HI     := LO + ctrl_regs_field.BITS - 1;
        ctrl_regs_field.RESET  := New_Bit_Slice_Field(1, LO + 7);
        ctrl_regs_field.PAUSE  := New_Bit_Slice_Field(1, LO + 6);
        ctrl_regs_field.STOP   := New_Bit_Slice_Field(1, LO + 5);
        ctrl_regs_field.START  := New_Bit_Slice_Field(1, LO + 4);
        ctrl_regs_field.EBLK   := New_Bit_Slice_Field(1, LO + 3);
        ctrl_regs_field.DONE   := New_Bit_Slice_Field(1, LO + 2);
        ctrl_regs_field.FIRST  := New_Bit_Slice_Field(1, LO + 1);
        ctrl_regs_field.LAST   := New_Bit_Slice_Field(1, LO + 0);
        return ctrl_regs_field;
    end function;
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x00 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x04 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x08 |                          Size[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x0C | Control[7:0]  |  Status[7:0]  |          Mode[15:00]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------

    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Regs_Field_Type return Regs_Field_Type is
        variable  regs_field  :  Regs_Field_Type;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        regs_field.BASE_ADDR      := 16#00#;
        regs_field.REGS_LO        := 0;
        regs_field.REGS_HI        := 127;
        regs_field.BITS           := 128;
        ---------------------------------------------------------------------------
        -- Address Register
        ---------------------------------------------------------------------------
        regs_field.ADDR_BASE_ADDR := regs_field.BASE_ADDR + 16#00#;
        regs_field.ADDR           := New_Bit_Slice_Field(64, 8*regs_field.ADDR_BASE_ADDR);
        ---------------------------------------------------------------------------
        -- Size Register
        ---------------------------------------------------------------------------
        regs_field.SIZE_BASE_ADDR := regs_field.BASE_ADDR + 16#08#;
        regs_field.SIZE           := New_Bit_Slice_Field(32, 8*regs_field.SIZE_BASE_ADDR);
        ---------------------------------------------------------------------------
        -- Mode Register
        ---------------------------------------------------------------------------
        regs_field.MODE_BASE_ADDR := regs_field.BASE_ADDR + 16#0C#;
        regs_field.MODE           := New_Mode_Regs_Field(8*regs_field.MODE_BASE_ADDR);
        ---------------------------------------------------------------------------
        -- Status Register
        ---------------------------------------------------------------------------
        regs_field.STAT_BASE_ADDR := regs_field.BASE_ADDR + 16#0E#;
        regs_field.STAT           := New_Stat_Regs_Field(8*regs_field.STAT_BASE_ADDR);
        ---------------------------------------------------------------------------
        -- Control Register
        ---------------------------------------------------------------------------
        regs_field.CTRL_BASE_ADDR := regs_field.BASE_ADDR + 16#0F#;
        regs_field.CTRL           := New_Ctrl_Regs_Field(8*regs_field.CTRL_BASE_ADDR);

        return regs_field;
    end New_Regs_Field_Type;

end Interface;
