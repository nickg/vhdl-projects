-----------------------------------------------------------------------------------
--!     @file    least_recently_used_selector_test_bench.vhd
--!     @brief   Least-Recently-Used-Selector Test Bench :
--!              Least_Recently_Used_Selectorを検証するためのテストベンチ.
--!     @version 1.7.0
--!     @date    2017/3/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2015-2018 Ichiro Kawazome
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
-- テストベンチのベースモデル(エンティティ宣言)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PipeWork;
use     PipeWork.Components.Least_Recently_Used_Selector;
entity  Least_Recently_Used_Selector_Test_Bench is
end     Least_Recently_Used_Selector_Test_Bench;
-----------------------------------------------------------------------------------
-- テストベンチのベースモデル(アーキテクチャ本体)
-----------------------------------------------------------------------------------
architecture MODEL of Least_Recently_Used_Selector_Test_Bench is
    constant   MESSAGE_TAG:  string(1 to 8) := string'("LRU_TEST");
    constant   ENTRY_SIZE :  integer :=  4;
    constant   PERIOD     :  time    := 10 ns;
    constant   DELAY      :  time    :=  1 ns;
    signal     SCENARIO   :  STRING(1 to 5);
    signal     clk_ena    :  boolean;
    signal     CLK        :  std_logic;
    signal     CLR        :  std_logic;
    signal     RST        :  std_logic;
    signal     I_SEL      :  std_logic_vector(ENTRY_SIZE downto 1);
    signal     O_SEL      :  std_logic_vector(ENTRY_SIZE downto 1);
    signal     Q_SEL      :  std_logic_vector(ENTRY_SIZE downto 1);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    U: Least_Recently_Used_Selector
        generic map (
            ENTRY_SIZE  => ENTRY_SIZE
        )
        port map (
            CLK         => CLK         , -- In  :
            RST         => RST         , -- In  :
            CLR         => CLR         , -- In  :
            I_SEL       => I_SEL       , -- In  :
            Q_SEL       => Q_SEL       , -- Out :
            O_SEL       => O_SEL         -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        loop
            CLK <= '1'; wait for PERIOD/2;
            CLK <= '0'; wait for PERIOD/2;
            exit when (clk_ena = FALSE);
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process 
        procedure WAIT_CLK(CNT:integer) is
        begin
            if (CNT > 0) then
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1'); 
                end loop;
            end if;
            wait for DELAY;
        end WAIT_CLK;
        procedure CHECK(I_NUM, O_NUM:integer) is
            variable o_exp_sel : std_logic_vector(O_SEL'range);
        begin
            for i in I_SEL'range loop
                if (i = I_NUM) then
                    I_SEL(i) <= '1';
                else
                    I_SEL(i) <= '0';
                end if;
            end loop;
            for i in o_exp_sel'range loop
                if (i = O_NUM) then
                    o_exp_sel(i) := '1';
                else
                    o_exp_sel(i) := '0';
                end if;
            end loop;
            wait until (CLK'event and CLK = '1');
            if (O_SEL /= o_exp_sel) then
                assert (false) report MESSAGE_TAG & " Mismatch..." severity FAILURE;
            end if;
        end procedure;
    begin
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report MESSAGE_TAG & " Starting Run..." severity NOTE;
                             SCENARIO <= "START";
                             clk_ena  <= TRUE;
                             RST      <= '1';
                             CLR      <= '1';
                             I_SEL    <= (others => '0');
        WAIT_CLK( 4);        RST      <= '0';
                             CLR      <= '0';
        WAIT_CLK( 4); 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "1.1.1";
        CHECK(I_NUM=>0, O_NUM=>1); -- [1,2,3,4]
        CHECK(I_NUM=>1, O_NUM=>2); -- [1,2,3,4] => [2,3,4,1]
        CHECK(I_NUM=>2, O_NUM=>3); -- [2,3,4,1] => [3,4,1,2]
        CHECK(I_NUM=>3, O_NUM=>4); -- [3,4,1,2] => [4,1,2,3]
        CHECK(I_NUM=>4, O_NUM=>1); -- [4,1,2,3] => [1,2,3,4]
        CHECK(I_NUM=>3, O_NUM=>1); -- [1,2,3,4] => [1,2,4,3]
        CHECK(I_NUM=>1, O_NUM=>2); -- [1,2,4,3] => [2,4,3,1]
        CHECK(I_NUM=>2, O_NUM=>4); -- [2,4,3,1] => [4,3,1,2]
        CHECK(I_NUM=>4, O_NUM=>3); -- [4,3,1,2] => [3,1,2,4]
        CHECK(I_NUM=>3, O_NUM=>1); -- [3,1,2,4] => [1,2,4,3]
        CHECK(I_NUM=>2, O_NUM=>1); -- [1,2,4,3] => [1,4,3,2]
        CHECK(I_NUM=>1, O_NUM=>4); -- [1,4,3,2] => [4,3,2,1]
        CHECK(I_NUM=>4, O_NUM=>3); -- [4,3,2,1] => [3,2,1,4]
        CHECK(I_NUM=>3, O_NUM=>2); -- [3,2,1,4] => [2,1,4,3]
        CHECK(I_NUM=>2, O_NUM=>1); -- [2,1,4,3] => [1,4,3,2]
        CHECK(I_NUM=>3, O_NUM=>1); -- [1,4,3,2] => [1,4,2,3]
        CHECK(I_NUM=>4, O_NUM=>1); -- [1,4,2,3] => [1,2,3,4]
        CHECK(I_NUM=>1, O_NUM=>2); -- [1,2,3,4] => [2,3,4,1]
        CHECK(I_NUM=>2, O_NUM=>3); -- [2,3,4,1] => [3,4,1,2]
        CHECK(I_NUM=>3, O_NUM=>4); -- [3,4,1,2] => [4,1,2,3]
        CHECK(I_NUM=>4, O_NUM=>1); -- [4,1,2,3] => [1,2,3,4]
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10); 
        assert(false) report MESSAGE_TAG & " Run complete..." severity NOTE;
        clk_ena <= FALSE;
        wait;
    end process;

end MODEL;
