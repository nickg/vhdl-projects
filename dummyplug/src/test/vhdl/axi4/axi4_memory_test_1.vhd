-----------------------------------------------------------------------------------
--!     @file    aix4_memory_test_1.vhd
--!     @brief   TEST BENCH No.1 for DUMMY_PLUG.AXI4_MEMORY_PLAYER
--!     @version 1.7.5
--!     @date    2020/10/6
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019-2020 Ichiro Kawazome
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
entity  DUMMY_PLUG_AXI4_MEMORY_TEST_1 is
    generic (
        NAME            : --! @brief テストベンチの識別名.
                          STRING    := "AXI4_MEMORY_TEST_1";
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING    := "../../../src/test/scenarios/axi4/axi4_memory_test_1.snr";
        DATA_WIDTH      : --! @brief データチャネルのビット幅.
                          integer   := 32;
        READ_ENABLE     : --! @brief リードモードを指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトモードを指定する.
                          boolean   := TRUE;
        MEMORY_SIZE     : --! @brief メモリの大きさをバイト数で指定する.
                          integer := 4096;
        READ_QUEUE_SIZE : --! @brief リードトランザクションのキューの数を指定する.
                          integer := 4;
        WRITE_QUEUE_SIZE: --! @brief ライトトランザクションのキューの数を指定する.
                          integer := 4;
        DOMAIN_SIZE     : --! @brief ドメインの数を指定する.
                          integer := 8;
        FINISH_ABORT    : boolean := FALSE
    );
end     DUMMY_PLUG_AXI4_MEMORY_TEST_1;
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
architecture MODEL of DUMMY_PLUG_AXI4_MEMORY_TEST_1 is
    constant EXP_REPORT  : REPORT_STATUS_TYPE := (
        valid            => TRUE,
        error_count      =>  0,
        mismatch_count   =>  0,
        warning_count    =>  0,
        failure_count    =>  0,
        read_error_count =>  0
    );
begin
    TB: entity WORK.DUMMY_PLUG_AXI4_MEMORY_TEST generic map (
        NAME             => NAME            ,
        SCENARIO_FILE    => SCENARIO_FILE   ,
        DATA_WIDTH       => DATA_WIDTH      ,
        READ_ENABLE      => READ_ENABLE     ,
        WRITE_ENABLE     => WRITE_ENABLE    ,
        MEMORY_SIZE      => MEMORY_SIZE     ,
        READ_QUEUE_SIZE  => READ_QUEUE_SIZE ,
        WRITE_QUEUE_SIZE => WRITE_QUEUE_SIZE,
        DOMAIN_SIZE      => DOMAIN_SIZE     ,
        EXP_REPORT       => EXP_REPORT      ,
        FINISH_ABORT     => FINISH_ABORT    
    );        
end MODEL;
