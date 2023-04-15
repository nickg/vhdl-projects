-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   TEST BENCH for Priority Encoder Procedures :
--!              Priority Encoder Procedurs Packageを検証するためのテストベンチ.
--!     @version 1.7.0
--!     @date    2018/3/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2013-2018 Ichiro Kawazome
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
-- テストベンチのコンポーネント宣言を含んだパッケージ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
    component TEST_BENCH
        generic (
            MSB         : boolean := FALSE;
            L           : integer := 0;
            H           : integer := 31;
            VERBOSE     : boolean := FALSE
        );
        port (
            FINISH      : out std_logic
        );
    end component;
end package;
-----------------------------------------------------------------------------------
-- テストベンチのエンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  TEST_BENCH is
    generic (
        MSB         : boolean := FALSE;
        L           : integer := 0;
        H           : integer := 31;
        VERBOSE     : boolean := FALSE
    );
    port (
        FINISH      : out std_logic
    );
end     TEST_BENCH;
-----------------------------------------------------------------------------------
-- テストベンチの本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all; 
use     std.textio.all;
library PipeWork;
use     PipeWork.Priority_Encoder_Procedures.Priority_Encode_To_Binary_Intricately;
library DUMMY_PLUG;
use     DUMMY_PLUG.MT19937AR.all;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
architecture stimulus of TEST_BENCH is
    function    MESSAGE_TAG return STRING is
    begin
        if (MSB = TRUE) then
            return "(MSB" & 
                    ",H="  & INTEGER_TO_STRING(H  ) &
                    ",L="  & INTEGER_TO_STRING(L  ) &
                   ")";
        else
            return "(LSB" & 
                    ",H="  & INTEGER_TO_STRING(H  ) &
                    ",L="  & INTEGER_TO_STRING(L  ) &
                   ")";
        end if;
    end function;
begin
    -------------------------------------------------------------------------------
    -- テスト開始
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        function  CALC_O_WIDTH return integer is
            variable width : integer;
        begin
            width := 0;
            while 2**width <= H loop
                width := width + 1;
            end loop;
            return width;
        end function;
        constant  O_WIDTH : integer := CALC_O_WIDTH;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        variable  i_data   : std_logic_vector(H downto L);
        variable  rnd_data : std_logic_vector(i_data'length-1 downto 0);
        variable  rnd_gen  : PSEUDO_RANDOM_NUMBER_GENERATOR_TYPE := NEW_PSEUDO_RANDOM_NUMBER_GENERATOR(88);
        variable  mismatch : integer;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure ENCODE(
            I : in  std_logic_vector;
            O : out std_logic_vector;
            V : out std_logic
        ) is
        begin
            Priority_Encode_To_Binary_Intricately(
                High_to_Low => MSB,
                Binary_Len  => O'length,
                Reduce_Len  => 4,
                Min_Dec_Len => 4,
                Max_Dec_Len => 8,
                Data        => I,
                Output      => O,
                Valid       => V
            );
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK(I_DATA  : in  std_logic_vector) is
            variable  gen_data  : std_logic_vector(O_WIDTH-1 downto 0);
            variable  exp_data  : std_logic_vector(O_WIDTH-1 downto 0);
            variable  gen_valid : std_logic;
            variable  exp_valid : std_logic;
        begin
            ENCODE(I_DATA,gen_data,gen_valid);
            if VERBOSE then
                assert (FALSE)
                    report MESSAGE_TAG &
                           "Mismtch Input="  & HEX_TO_STRING(I_DATA   ) &
                                 ", Output=" & HEX_TO_STRING(gen_data ) &
                                 ", Valid="  & BIN_TO_STRING(gen_valid)
                    severity NOTE;
            end if;
            if MSB = TRUE then
                exp_data  := (others => '0');
                exp_valid := '0';
                for i in I_DATA'high downto I_DATA'low loop
                    if (I_DATA(i) = '1') then
                        exp_data  := std_logic_vector(to_unsigned(i,O_WIDTH));
                        exp_valid := '1';
                        exit;
                    end if;
                end loop;
            else
                exp_data  := (others => '0');
                exp_valid := '0';
                for i in I_DATA'low to I_DATA'high loop
                    if (I_DATA(i) = '1') then
                        exp_data  := std_logic_vector(to_unsigned(i,O_WIDTH));
                        exp_valid := '1';
                        exit;
                    end if;
                end loop;
            end if;
            if (gen_data /= exp_data) or (gen_valid /= exp_valid) then
                mismatch := mismatch + 1;
            end if;
            assert (gen_data = exp_data)
                report MESSAGE_TAG &
                       "Mismtch Input="  & HEX_TO_STRING(I_DATA  ) &
                             ", Output=" & HEX_TO_STRING(gen_data) &
                               ", Exp="  & HEX_TO_STRING(exp_data)
                severity ERROR;
            assert (gen_valid = exp_valid)
                report MESSAGE_TAG &
                       "Mismtch Input="  & HEX_TO_STRING(I_DATA   ) &
                             ", Valid="  & BIN_TO_STRING(gen_valid) &
                              ", Exp="   & BIN_TO_STRING(exp_valid)
                severity ERROR;
        end procedure;
    begin
        mismatch := 0;
        for pos in i_data'range loop
            i_data := (others => '0');
            i_data(pos) := '1';
            CHECK(i_data);
        end loop;
        for pos in i_data'range loop
            i_data := (others => '0');
            i_data(pos) := '1';
            if MSB then
                if (pos > i_data'low) then
                    i_data(pos-1 downto i_data'low ) := (pos-1 downto i_data'low => '1');
                end if;
            else
                if (pos < i_data'high) then
                    i_data(i_data'high downto pos+1) := (i_data'high downto pos+1 => '1');
                end if;
            end if;
            CHECK(i_data);
        end loop;
        for count in 0 to 100 loop
            GENERATE_RANDOM_STD_LOGIC_VECTOR(rnd_gen, rnd_data);
            i_data := rnd_data;
            CHECK(i_data);
        end loop;
        assert(mismatch=0) report MESSAGE_TAG & "Run error!!!!!!" severity FAILURE;
        assert(mismatch>0) report MESSAGE_TAG & "Run complete..." severity NOTE;
        FINISH <= 'Z';
        wait;
    end process;
end stimulus;
-----------------------------------------------------------------------------------
-- TEST_BENCH_ALL
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  TEST_BENCH_ALL is
end     TEST_BENCH_ALL;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.TEST_BENCH;
architecture MODEL of TEST_BENCH_ALL is
    signal FINISH : std_logic;
begin
    L_GEN: for L in 0 to 3  generate
    H_GEN: for W in 4 to 32 generate
        MSB_TB:TEST_BENCH
            generic map(
                MSB         => TRUE ,
                L           => L,
                H           => L+W-1,
                VERBOSE     => FALSE
            )
            port map (
                FINISH      => FINISH
            );
        LSB_TB:TEST_BENCH
            generic map(
                MSB         => FALSE,
                L           => L,
                H           => L+W-1,
                VERBOSE     => FALSE
            )
            port map (
                FINISH      => FINISH
            );
    end generate;
    end generate;
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity NOTE;
        end if;
    end process;
end MODEL;
