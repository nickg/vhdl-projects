-----------------------------------------------------------------------------------
--!     @file    aix4_adapter_test_bench_4096_32_32_async.vhd
--!     @brief   AXI4_ADPATER TEST BENCH(MAX_XFER_SIZE=4096,T_DATA_WIDTH=32,M_DATA_WIDTH=32)
--!     @version 1.7.0
--!     @date    2018/3/22
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
use     ieee.numeric_std.all;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  AXI4_ADAPTER_TEST_BENCH_4096_32_32_ASYNC is
end     AXI4_ADAPTER_TEST_BENCH_4096_32_32_ASYNC;
use     WORK.AXI4_ADAPTER_TEST_BENCH_COMPONENTS.AXI4_ADAPTER_TEST_BENCH;
architecture MODEL of AXI4_ADAPTER_TEST_BENCH_4096_32_32_ASYNC is
begin
    TB: AXI4_ADAPTER_TEST_BENCH generic map (
        NAME            => string'("AXI4_ADAPTER_TEST_BENCH_4096_32_32_ASYNC"),
        SCENARIO_FILE   => string'("axi4_adapter_test_bench_4096_32_32.snr"),
        T_CLK_RATE      => 0,
        T_CLK_PERIOD    => 10 ns,
        M_CLK_RATE      => 0,
        M_CLK_PERIOD    => 10 ns,
        T_DATA_WIDTH    => 32,
        M_DATA_WIDTH    => 32,
        M_MAX_XFER_SIZE => 12
    );
end MODEL;

