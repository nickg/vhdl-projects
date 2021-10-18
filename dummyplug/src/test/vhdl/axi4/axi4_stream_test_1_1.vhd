-----------------------------------------------------------------------------------
--!     @file    aix4_stream_test_1_1.vhd
--!     @brief   TEST BENCH No.1.1 for DUMMY_PLUG.AXI4_MODELS
--!     @version 1.7.1
--!     @date    2018/3/20
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2018 Ichiro Kawazome
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
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
entity  DUMMY_PLUG_AXI4_STREAM_TEST_1_1 is
    generic (
        SCENARIO_FILE   : STRING  := "src/test/scenarios/axi4/axi4_stream_test_1_1.snr"
    );
end     DUMMY_PLUG_AXI4_STREAM_TEST_1_1;
architecture MODEL of DUMMY_PLUG_AXI4_STREAM_TEST_1_1 is
    constant NAME            : STRING  := "AXI4_STREAM_TEST_1_1";
    constant EXP_REPORT      : REPORT_STATUS_TYPE := (
        valid            => TRUE,
        error_count      =>  0,
        mismatch_count   =>  0,
        warning_count    =>  0,
        failure_count    =>  0,
        read_error_count =>  0
    );
    component DUMMY_PLUG_AXI4_STREAM_TEST_1
        generic (
            NAME            : STRING;
            SCENARIO_FILE   : STRING;
            DATA_WIDTH      : integer;
            EXP_REPORT      : REPORT_STATUS_TYPE
        );
    end component;
begin
    U: DUMMY_PLUG_AXI4_STREAM_TEST_1 generic map(NAME, SCENARIO_FILE, 32, EXP_REPORT);
end MODEL;
