-----------------------------------------------------------------------------------
--!     @file    aix4_register_interface_test_bench_64_32.vhd
--!     @brief   AXI4_REGISTER_INTERFACE TEST BENCH(AXI4_DATA_WIDTH=64,REGS_DATA_WIDTH=32)
--!     @version 1.7.0
--!     @date    2018/3/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
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
entity  AXI4_REGISTER_INTERFACE_TEST_BENCH_64_32 is
end     AXI4_REGISTER_INTERFACE_TEST_BENCH_64_32;
architecture MODEL of AXI4_REGISTER_INTERFACE_TEST_BENCH_64_32 is
    component  AXI4_REGISTER_INTERFACE_TEST_BENCH is
        generic (
            NAME            : STRING;
            SCENARIO_FILE   : STRING;
            AXI4_DATA_WIDTH : integer;
            REGS_DATA_WIDTH : integer
        );
    end component;
begin
    TB: AXI4_REGISTER_INTERFACE_TEST_BENCH generic map(
            NAME            => string'("AXI4_REGS_IF_64_32"),
            SCENARIO_FILE   => string'("src/test/scenarios/axi4_register_interface/axi4_register_interface_test_bench_64_32.snr"),
            AXI4_DATA_WIDTH => 64,
            REGS_DATA_WIDTH => 32
    );
end MODEL;
