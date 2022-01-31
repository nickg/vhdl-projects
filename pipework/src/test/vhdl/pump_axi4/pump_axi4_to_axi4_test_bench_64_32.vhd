-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4_test_bench_64_32.vhd
--!     @brief   Test Bench for Pump Sample Module (AXI4 to AXI4)
--!     @version 1.8.6
--!     @date    2021/5/25
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2021 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32 is
    generic (
        NAME            :  STRING  := string'("PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32");
        SCENARIO_FILE   :  STRING  := string'("pump_axi4_to_axi4_test_bench_64_32.snr");
        I_DATA_WIDTH    :  integer := 64;
        O_DATA_WIDTH    :  integer := 32;
        MAX_XFER_SIZE   :  integer := 6;
        FINISH_ABORT    :  boolean := FALSE
    );
end     PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32;
architecture MODEL of PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32 is
begin
    TB: entity WORK.PUMP_AXI4_TO_AXI4_TEST_BENCH generic map (
        NAME            => NAME         ,  
        SCENARIO_FILE   => SCENARIO_FILE,
        I_DATA_WIDTH    => I_DATA_WIDTH ,
        O_DATA_WIDTH    => O_DATA_WIDTH ,
        MAX_XFER_SIZE   => MAX_XFER_SIZE,
        FINISH_ABORT    => FINISH_ABORT
    );        
end MODEL;

