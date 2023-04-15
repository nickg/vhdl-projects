-----------------------------------------------------------------------------------
--!     @file    queue_receiver_test_bench.vhd
--!     @brief   QUEUE RECEIVER/ADJUSTER TEST BENCH :
--!              QUEUE RECEIVER/ADJUSTERを検証するためのテストベンチ.
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
-----------------------------------------------------------------------------------
-- テストベンチのベースモデルのコンポーネントの宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
    component QUEUE_RECEIVER_TEST_BENCH
        generic (
            QUEUE_SIZE       : integer := 4;
            DATA_BITS        : integer := 8
        );
        port (
            FINISH           : out std_logic
        );
     end component;
end     COMPONENTS;
-----------------------------------------------------------------------------------
-- テストベンチのベースモデル(エンティティ宣言)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.QUEUE_RECEIVER;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
use     DUMMY_PLUG.TINYMT32.all;
entity  QUEUE_RECEIVER_TEST_BENCH is
    generic (
        QUEUE_SIZE       : integer := 4;
        DATA_BITS        : integer := 8
    );
    port (
        FINISH           : out std_logic
    );
end    QUEUE_RECEIVER_TEST_BENCH;
-----------------------------------------------------------------------------------
-- テストベンチのベースモデル(アーキテクチャ本体)
-----------------------------------------------------------------------------------
architecture MODEL of QUEUE_RECEIVER_TEST_BENCH is
    constant PERIOD      : time    := 10 ns;
    constant DELAY       : time    :=  1 ns;
    signal   SCENARIO    : STRING(1 to 5);
    signal   CLK         : std_logic;
    signal   CLR         : std_logic;
    signal   RST         : std_logic;
    signal   I_DATA      : std_logic_vector(DATA_BITS-1 downto 0);
    signal   I_VAL       : std_logic;
    signal   I_ENABLE    : std_logic;
    signal   I_RDY       : std_logic;
    signal   O_RDY       : std_logic;
    signal   O_DATA      : std_logic_vector(DATA_BITS-1 downto 0);
    signal   O_VAL       : std_logic;
    signal   EXP_DATA    : std_logic_vector(DATA_BITS-1 downto 0);
    signal   MISMATCH    : boolean;
    signal   CLK_ENA     : boolean;
    function MESSAGE_TAG return STRING is
    begin
        return "(DATA_BITS="  & INTEGER_TO_STRING(DATA_BITS ) &
               ",QUEUE_SIZE=" & INTEGER_TO_STRING(QUEUE_SIZE) &
               "):";
    end function;
begin

    U: QUEUE_RECEIVER
        generic map (
            QUEUE_SIZE  => QUEUE_SIZE,
            DATA_BITS   => DATA_BITS
        )
        port map (
            CLK         => CLK       ,
            RST         => RST       ,
            CLR         => CLR       ,
            I_DATA      => I_DATA    ,
            I_VAL       => I_VAL     ,
            I_RDY       => I_RDY     ,
            I_ENABLE    => I_ENABLE  ,
            O_DATA      => O_DATA    ,
            O_VAL       => O_VAL     ,
            O_RDY       => O_RDY     
        );

    process begin
        loop
            CLK <= '1'; wait for PERIOD/2;
            CLK <= '0'; wait for PERIOD/2;
            exit when(CLK_ENA = FALSE);
        end loop;
        CLK <= '0';
        wait;
    end process;

    process (CLK, RST) begin
        if (RST = '1') then
                I_DATA <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (I_VAL = '1' and I_RDY = '1') then
                I_DATA <= std_logic_vector(unsigned(I_DATA) + 1);
            end if;
        end if;
    end process;

    process (CLK, RST) begin
        if (RST = '1') then
                EXP_DATA <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (O_VAL = '1' and O_RDY = '1') then
                EXP_DATA <= std_logic_vector(unsigned(EXP_DATA) + 1);
            end if;
        end if;
    end process;

    process (CLK, RST) begin
        if (RST = '1') then
            MISMATCH <= FALSE;
        elsif (CLK'event and CLK = '1' and O_VAL = '1' and O_RDY = '1') then
            MISMATCH <= (O_DATA /= EXP_DATA);
            assert(O_DATA = EXP_DATA) report MESSAGE_TAG & "Mismatch data..." severity FAILURE;
        end if;
    end process;

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
        constant  seed      : SEED_TYPE           := X"00000001";
        constant  mat1      : SEED_TYPE           := X"8f7011ee";
        constant  mat2      : SEED_TYPE           := X"fc78ff1f";
        constant  tmat      : RANDOM_NUMBER_TYPE  := X"3793fdff";
        constant  init_key  : SEED_VECTOR(0 to 0) := (0 => seed);
        variable  rand      : PSEUDO_RANDOM_NUMBER_GENERATOR_TYPE :=
                              NEW_PSEUDO_RANDOM_NUMBER_GENERATOR(mat1,mat2,tmat,seed);
        variable  pattern   : real;
    begin
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report MESSAGE_TAG & "Starting Run..." severity NOTE;
                             SCENARIO <= "START";
                             CLK_ENA  <= TRUE;
                             RST      <= '1';
                             CLR      <= '1';
                             I_VAL    <= '0';
                             I_ENABLE <= '1';
                             O_RDY    <= '0';
        WAIT_CLK( 4);        RST      <= '0';
                             CLR      <= '0';
        WAIT_CLK( 4); 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO <= "1.1.1";
        WAIT_CLK( 1);        I_VAL    <= '1';
        WAIT_CLK(QUEUE_SIZE);I_VAL    <= '0';
        WAIT_CLK( 1);        O_RDY    <= '1';
        WAIT_CLK(QUEUE_SIZE);O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO <= "1.1.2";
        WAIT_CLK( 1);        O_RDY    <= '1';
        WAIT_CLK( 3);        I_VAL    <= '1';
        WAIT_CLK(QUEUE_SIZE);I_VAL    <= '0';
        WAIT_CLK( 1);        O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "1.1.3";
        WAIT_CLK( 1);       I_VAL    <= '1';
        for i in 1 to 10*QUEUE_SIZE loop
            WAIT_CLK(1);    O_RDY    <= '1';
            WAIT_CLK(1);    O_RDY    <= '0';
        end loop;
        WAIT_CLK( 4);       I_VAL    <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "1.1.4";
        WAIT_CLK( 1);       O_RDY    <= '1';
        for i in 1 to 10*QUEUE_SIZE loop
            WAIT_CLK(1);    I_VAL    <= '1';
            WAIT_CLK(1);    I_VAL    <= '0';
        end loop;
        WAIT_CLK( 4);       I_VAL    <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "1.1.5";
        WAIT_CLK( 1);       I_VAL    <= '0';
                            O_RDY    <= '0';
        for i in 1 to 10 loop
            WAIT_CLK(1);    I_VAL    <= '1';
                            O_RDY    <= '0';
            WAIT_CLK(1);    I_VAL    <= '1';
                            O_RDY    <= '1';
            WAIT_CLK(1);    I_VAL    <= '0';
                            O_RDY    <= '1';
            WAIT_CLK(1);    I_VAL    <= '0';
                            O_RDY    <= '0';
            WAIT_CLK(1);    I_VAL    <= '1';
                            O_RDY    <= '0';
            WAIT_CLK(3);    I_VAL    <= '1';
                            O_RDY    <= '1';
            WAIT_CLK(2);    I_VAL    <= '0';
                            O_RDY    <= '1';
            WAIT_CLK(1);    I_VAL    <= '0';
                            O_RDY    <= '0';
        end loop;
        WAIT_CLK( 4);       I_VAL    <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "2.1.1";
        WAIT_CLK( 1);       I_VAL    <= '0';
                            O_RDY    <= '0';
        for i in 1 to 1000 loop
            WAIT_CLK( 1);
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 0.5) then
                I_VAL <= '1';
            else
                I_VAL <= '0';
            end if;
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 0.5) then
                O_RDY <= '1';
            else
                O_RDY <= '0';
            end if;
        end loop;
        WAIT_CLK( 4);       I_VAL    <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "2.1.2";
        WAIT_CLK( 1);       I_VAL    <= '0';
                            O_RDY    <= '0';
        for i in 1 to 1000 loop
            WAIT_CLK( 1);
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 0.5) then
                I_VAL <= '1';
            else
                I_VAL <= '0';
            end if;
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 2.0/3.0) then
                O_RDY <= '1';
            else
                O_RDY <= '0';
            end if;
        end loop;
        WAIT_CLK( 4);       I_VAL    <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "2.1.3";
        WAIT_CLK( 1);       I_VAL    <= '0';
                            O_RDY    <= '0';
        for i in 1 to 1000 loop
            WAIT_CLK( 1);
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 2.0/3.0) then
                I_VAL <= '1';
            else
                I_VAL <= '0';
            end if;
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 1.0/3.0) then
                O_RDY <= '1';
            else
                O_RDY <= '0';
            end if;
        end loop;
        WAIT_CLK( 4);       I_VAL    <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10); 
        assert(false) report MESSAGE_TAG & " Run complete..." severity NOTE;
        CLK_ENA <= FALSE;
        FINISH  <= 'Z';
        wait;
    end process;

end MODEL;
use    WORK.COMPONENTS.QUEUE_RECEIVER_TEST_BENCH;
entity QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE02_DATA_BITS08 is
end    QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE02_DATA_BITS08;
architecture MODEL of QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE02_DATA_BITS08 is
begin
    TB:QUEUE_RECEIVER_TEST_BENCH generic map(QUEUE_SIZE=>2,DATA_BITS=>8) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.QUEUE_RECEIVER_TEST_BENCH;
entity QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE03_DATA_BITS08 is
end    QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE03_DATA_BITS08;
architecture MODEL of QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE03_DATA_BITS08 is
begin
    TB:QUEUE_RECEIVER_TEST_BENCH generic map(QUEUE_SIZE=>3,DATA_BITS=>8) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.QUEUE_RECEIVER_TEST_BENCH;
entity QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE04_DATA_BITS08 is
end    QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE04_DATA_BITS08;
architecture MODEL of QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE04_DATA_BITS08 is
begin
    TB:QUEUE_RECEIVER_TEST_BENCH generic map(QUEUE_SIZE=>4,DATA_BITS=>8) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.QUEUE_RECEIVER_TEST_BENCH;
entity QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE01_DATA_BITS08 is
end    QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE01_DATA_BITS08;
architecture MODEL of QUEUE_RECEIVER_TEST_BENCH_QUEUE_SIZE01_DATA_BITS08 is
begin
    TB:QUEUE_RECEIVER_TEST_BENCH generic map(QUEUE_SIZE=>1,DATA_BITS=>8) port map(FINISH=>open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.QUEUE_RECEIVER_TEST_BENCH;
entity  QUEUE_RECEIVER_TEST_BENCH_ALL is
end     QUEUE_RECEIVER_TEST_BENCH_ALL;
architecture    MODEL of QUEUE_RECEIVER_TEST_BENCH_ALL is
    signal FINISH : std_logic;
begin
    QUEUE_SIZE_GEN: for QUEUE_SIZE in 2 to 4 generate
        TB:QUEUE_RECEIVER_TEST_BENCH generic map (
            QUEUE_SIZE  => QUEUE_SIZE,
            DATA_BITS   => 8
        )
        port map (
           FINISH       => FINISH
        );
    end generate;
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity NOTE;
        end if;
    end process;
end MODEL;
