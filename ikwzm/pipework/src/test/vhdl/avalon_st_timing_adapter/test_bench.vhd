-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   Avalon-ST Timing Adapter Test Bench :
--!              Avalon-ST Timing Adapterを検証するためのテストベンチ.
--!     @version 0.2.0
--!     @date    2012/8/28
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
-----------------------------------------------------------------------------------
-- テストベンチのベースモデルのコンポーネントの宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
    component Avalon_ST_Timing_Adapter_Test_Bench
        generic (
            I_READY_LATENCY  : integer := 4;
            O_READY_LATENCY  : integer := 0;
            DATA_BITS        : integer := 8;
            AUTO_FINISH      : integer := 0
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
use     PIPEWORK.COMPONENTS.QUEUE_REGISTER;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
use     DUMMY_PLUG.TINYMT32.all;
entity  Avalon_ST_Timing_Adapter_Test_Bench is
    generic (
        I_READY_LATENCY  : integer := 4;
        O_READY_LATENCY  : integer := 0;
        DATA_BITS        : integer := 8;
        AUTO_FINISH      : integer := 0
    );
    port (
        FINISH           : out std_logic
    );
end    Avalon_ST_Timing_Adapter_Test_Bench;
-----------------------------------------------------------------------------------
-- テストベンチのベースモデル(アーキテクチャ本体)
-----------------------------------------------------------------------------------
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench is
    constant PERIOD      : time    := 10 ns;
    constant DELAY       : time    :=  1 ns;
    signal   SCENARIO    : STRING(1 to 5);
    signal   CLK         : std_logic;
    signal   CLR         : std_logic;
    signal   RST         : std_logic;
    signal   i_valid     : std_logic;
    signal   i_ready     : std_logic;
    signal   I_DATA      : std_logic_vector(DATA_BITS-1 downto 0);
    signal   I_VAL       : std_logic;
    signal   I_RDY       : std_logic;
    signal   O_RDY       : std_logic;
    signal   O_DATA      : std_logic_vector(DATA_BITS-1 downto 0);
    signal   O_VAL       : std_logic;
    signal   EXP_DATA    : std_logic_vector(DATA_BITS-1 downto 0);
    signal   MISMATCH    : boolean;
    function MESSAGE_TAG return STRING is
    begin
        return "(DATA_BITS="       & INTEGER_TO_STRING(DATA_BITS      ) &
               ",I_READY_LATENCY=" & INTEGER_TO_STRING(I_READY_LATENCY) &
               ",O_READY_LATENCY=" & INTEGER_TO_STRING(O_READY_LATENCY) &
               "):";
    end function;
    component  Avalon_ST_Timing_Adapter
        generic (
            DATA_BITS   : integer := 8;
            I_LATENCY   : integer := 0;
            O_LATENCY   : integer := 0
        );
        port (
            CLK         : in  std_logic; 
            RST         : in  std_logic;
            CLR         : in  std_logic;
            I_DATA      : in  std_logic_vector(DATA_BITS-1 downto 0);
            I_VAL       : in  std_logic;
         -- I_SOP       : in  std_logic;
         -- I_EOP       : in  std_logic;
            I_RDY       : out std_logic;
            O_DATA      : out std_logic_vector(DATA_BITS-1 downto 0);
         -- O_SOP       : in  std_logic;
         -- O_EOP       : in  std_logic;
            O_VAL       : out std_logic;
            O_RDY       : in  std_logic
        );
    end component;
begin

    U: Avalon_ST_Timing_Adapter
        generic map (
            DATA_BITS   => DATA_BITS ,
            I_LATENCY   => I_READY_LATENCY ,
            O_LATENCY   => O_READY_LATENCY
        )
        port map (
            CLK         => CLK   ,
            RST         => RST   ,
            CLR         => CLR   ,
            I_DATA      => I_DATA,
            I_VAL       => I_VAL ,
            I_RDY       => I_RDY ,
            O_DATA      => O_DATA,
            O_VAL       => O_VAL ,
            O_RDY       => O_RDY
        );
    I_READY_LATENCY_EQ_0: if (I_READY_LATENCY = 0) generate
        i_ready <= I_RDY;
        I_VAL   <= i_valid;
    end generate;
    I_READY_LATENCY_GT_0: if (I_READY_LATENCY > 0) generate
        signal   T_RDY       : std_logic_vector(I_READY_LATENCY downto 1);
    begin
        i_ready <= T_RDY(I_READY_LATENCY);
        I_VAL   <= i_valid and i_ready;
        process (CLK, RST) begin
            if (RST = '1') then
                T_RDY <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                for i in T_RDY'range loop
                    if (i = T_RDY'low) then
                        T_RDY(i) <= I_RDY;
                    else
                        T_RDY(i) <= T_RDY(i-1);
                    end if;
                end loop;
            end if;
        end process;
    end generate;
    
    process begin
        CLK <= '1'; wait for PERIOD/2;
        CLK <= '0'; wait for PERIOD/2;
    end process;

    process (CLK, RST) begin
        if (RST = '1') then
                I_DATA <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (I_READY_LATENCY = 0 and I_VAL = '1' and I_RDY = '1') or
               (I_READY_LATENCY > 0 and I_VAL = '1') then
                I_DATA <= std_logic_vector(unsigned(I_DATA) + 1);
            end if;
        end if;
    end process;

    O_READY_LATENCY_EQ_0: if (O_READY_LATENCY = 0) generate
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
    end generate;
    
    O_READY_LATENCY_GT_0: if (O_READY_LATENCY > 0) generate
        process (CLK, RST) begin
            if (RST = '1') then
                    EXP_DATA <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (O_VAL = '1') then
                    EXP_DATA <= std_logic_vector(unsigned(EXP_DATA) + 1);
                end if;
            end if;
        end process;
        process (CLK, RST) begin
            if (RST = '1') then
                MISMATCH <= FALSE;
            elsif (CLK'event and CLK = '1' and O_VAL = '1') then
                MISMATCH <= (O_DATA /= EXP_DATA);
                assert(O_DATA = EXP_DATA) report MESSAGE_TAG & "Mismatch data..." severity FAILURE;
            end if;
        end process;
    end generate;
    
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
        constant  WAIT_CYCLE: integer := I_READY_LATENCY+1;
    begin
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report MESSAGE_TAG & "Starting Run..." severity NOTE;
                             SCENARIO <= "START";
                             RST      <= '1';
                             CLR      <= '1';
                             i_valid  <= '0';
                             O_RDY    <= '0';
        WAIT_CLK( 4);        RST      <= '0';
                             CLR      <= '0';
        WAIT_CLK( 4); 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO <= "1.1.1";
        WAIT_CLK( 1);        i_valid  <= '1';
        WAIT_CLK(WAIT_CYCLE);i_valid  <= '0';
        WAIT_CLK( 1);        O_RDY    <= '1';
        WAIT_CLK(WAIT_CYCLE);O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO <= "1.1.2";
        WAIT_CLK( 1);        O_RDY    <= '1';
        WAIT_CLK( 3);        i_valid  <= '1';
        WAIT_CLK(WAIT_CYCLE);i_valid  <= '0';
        WAIT_CLK( 1);        O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "1.1.3";
        WAIT_CLK( 1);       i_valid  <= '1';
        for i in 1 to 10*WAIT_CYCLE loop
            WAIT_CLK(1);    O_RDY    <= '1';
            WAIT_CLK(1);    O_RDY    <= '0';
        end loop;
        WAIT_CLK( 4);       i_valid  <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "1.1.4";
        WAIT_CLK( 1);       O_RDY    <= '1';
        for i in 1 to 10*WAIT_CYCLE loop
            WAIT_CLK(1);    i_valid  <= '1';
            WAIT_CLK(1);    i_valid  <= '0';
        end loop;
        WAIT_CLK( 4);       i_valid  <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "1.1.5";
        WAIT_CLK( 1);       i_valid  <= '0';
                            O_RDY    <= '0';
        for i in 1 to 10 loop
            WAIT_CLK(1);    i_valid  <= '1';
                            O_RDY    <= '0';
            WAIT_CLK(1);    i_valid  <= '1';
                            O_RDY    <= '1';
            WAIT_CLK(1);    i_valid  <= '0';
                            O_RDY    <= '1';
            WAIT_CLK(1);    i_valid  <= '0';
                            O_RDY    <= '0';
            WAIT_CLK(1);    i_valid  <= '1';
                            O_RDY    <= '0';
            WAIT_CLK(3);    i_valid  <= '1';
                            O_RDY    <= '1';
            WAIT_CLK(2);    i_valid  <= '0';
                            O_RDY    <= '1';
            WAIT_CLK(1);    i_valid  <= '0';
                            O_RDY    <= '0';
        end loop;
        WAIT_CLK( 4);       i_valid  <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "2.1.1";
        WAIT_CLK( 1);       i_valid  <= '0';
                            O_RDY    <= '0';
        for i in 1 to 1000 loop
            WAIT_CLK( 1);
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 0.5) then
                i_valid <= '1';
            else
                i_valid <= '0';
            end if;
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 0.5) then
                O_RDY <= '1';
            else
                O_RDY <= '0';
            end if;
        end loop;
        WAIT_CLK( 4);       i_valid  <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "2.1.2";
        WAIT_CLK( 1);       i_valid  <= '0';
                            O_RDY    <= '0';
        for i in 1 to 1000 loop
            WAIT_CLK( 1);
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 0.5) then
                i_valid <= '1';
            else
                i_valid <= '0';
            end if;
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 2.0/3.0) then
                O_RDY <= '1';
            else
                O_RDY <= '0';
            end if;
        end loop;
        WAIT_CLK( 4);       i_valid  <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                            SCENARIO <= "2.1.3";
        WAIT_CLK( 1);       i_valid  <= '0';
                            O_RDY    <= '0';
        for i in 1 to 1000 loop
            WAIT_CLK( 1);
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 2.0/3.0) then
                i_valid <= '1';
            else
                i_valid <= '0';
            end if;
            GENERATE_RANDOM_REAL1(rand,pattern);
            if (pattern >= 1.0/3.0) then
                O_RDY <= '1';
            else
                O_RDY <= '0';
            end if;
        end loop;
        WAIT_CLK( 4);       i_valid  <= '0';
                            O_RDY    <= '1';
        wait until (CLK'event and CLK = '1' and O_VAL = '0');
        wait for DELAY;     O_RDY    <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10); 
        if (AUTO_FINISH = 0) then
            assert(false) report MESSAGE_TAG & " Run complete..." severity NOTE;
            FINISH <= 'Z';
        else
            FINISH <= 'Z';
            assert(false) report MESSAGE_TAG & " Run complete..." severity FAILURE;
        end if;
        wait;
    end process;

end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I0_O0_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I0_O0_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I0_O0_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>0,O_READY_LATENCY=>0,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I1_O0_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I1_O0_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I1_O0_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>1,O_READY_LATENCY=>0,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I2_O0_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I2_O0_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I2_O0_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>2,O_READY_LATENCY=>0,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I3_O0_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I3_O0_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I3_O0_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>3,O_READY_LATENCY=>0,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I4_O0_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I4_O0_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I4_O0_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>4,O_READY_LATENCY=>0,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I0_O1_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I0_O1_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I0_O1_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>0,O_READY_LATENCY=>1,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I0_O2_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I0_O2_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I0_O2_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>0,O_READY_LATENCY=>2,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I0_O3_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I0_O3_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I0_O3_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>0,O_READY_LATENCY=>3,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
use    WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity Avalon_ST_Timing_Adapter_Test_Bench_I0_O4_D8 is
end    Avalon_ST_Timing_Adapter_Test_Bench_I0_O4_D8;
architecture MODEL of Avalon_ST_Timing_Adapter_Test_Bench_I0_O4_D8 is
begin
    TB:Avalon_ST_Timing_Adapter_Test_Bench generic map(I_READY_LATENCY=>0,O_READY_LATENCY=>4,DATA_BITS=>8,AUTO_FINISH=>1) port map(FINISH=>open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.Avalon_ST_Timing_Adapter_Test_Bench;
entity  Avalon_ST_Timing_Adapter_Test_Bench_ALL is
end     Avalon_ST_Timing_Adapter_Test_Bench_ALL;
architecture    MODEL of Avalon_ST_Timing_Adapter_Test_Bench_ALL is
    signal FINISH : std_logic;
begin
    I_READY_LATENCY_GEN: for I_READY_LATENCY in 0 to 3 generate
    O_READY_LATENCY_GEN: for O_READY_LATENCY in 0 to 3 generate
        TB:Avalon_ST_Timing_Adapter_Test_Bench generic map (
            I_READY_LATENCY  => I_READY_LATENCY,
            O_READY_LATENCY  => O_READY_LATENCY,
            DATA_BITS        => 8,
            AUTO_FINISH      => 0
        )
        port map (
           FINISH            => FINISH
        );
    end generate;
    end generate;
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity FAILURE;
        end if;
    end process;
end MODEL;
