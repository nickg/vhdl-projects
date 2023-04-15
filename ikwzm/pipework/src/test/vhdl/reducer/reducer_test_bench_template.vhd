-----------------------------------------------------------------------------------
--!     @file    test_bench_template.vhd
--!     @brief   TEST BENCH TEMPLATE for REDUCER :
--!     @version 1.8.4
--!     @date    2020/11/7
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2020 Ichiro Kawazome
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
library PIPEWORK;
use     PIPEWORK.COMPONENTS.REDUCER;
use     WORK.COMPONENTS.REDUCER_TEST_MODEL;
entity  REDUCER_TEST_BENCH_DWC_W%W_I%I_O%O_Q%Q_J%J_V%V is
    port(FINISH:out std_logic);
end     REDUCER_TEST_BENCH_DWC_W%W_I%I_O%O_Q%Q_J%J_V%V;
architecture MODEL of REDUCER_TEST_BENCH_DWC_W%W_I%I_O%O_Q%Q_J%J_V%V is
    constant   WORD_BITS      : integer := %W;
    constant   I_WIDTH        : integer := %I;
    constant   O_WIDTH        : integer := %O;
    constant   QUEUE_SIZE     : integer := %Q;
    constant   FLUSH_ENABLE   : integer :=  1;
    constant   I_JUSTIFIED    : integer := %J;
    constant   O_SHIFT_MAX    : integer := O_WIDTH;
    constant   O_SHIFT_MIN    : integer := 0;
    constant   O_VAL_SIZE     : integer := %V;
    constant   NO_VAL_SET     : integer := O_WIDTH;
    constant   NAME           : string(1 to 22) := "DWC_W%W_I%I_O%O_Q%Q_J%J_V%V";
    constant   PERIOD         : time    := 10 ns;
    constant   DELAY          : time    :=  1 ns;
    signal     CLK_ENA        : std_logic;
    signal     CLK            : std_logic;
    signal     RST            : std_logic;
    signal     CLR            : std_logic;
    signal     START          : std_logic;
    signal     OFFSET         : std_logic_vector(O_WIDTH-1 downto 0);
    signal     DONE           : std_logic;
    signal     FLUSH          : std_logic;
    signal     BUSY           : std_logic;
    signal     START_DATA     : std_logic_vector(WORD_BITS-1 downto 0);
    signal     FLUSH_DATA     : std_logic_vector(WORD_BITS-1 downto 0);
    signal     NO_VAL_DATA    : std_logic_vector(WORD_BITS-1 downto 0);
    signal     I_ENABLE       : std_logic;
    signal     I_DATA         : std_logic_vector(I_WIDTH*(WORD_BITS  )-1 downto 0);
    signal     I_STRB         : std_logic_vector(I_WIDTH*(WORD_BITS/8)-1 downto 0);
    signal     I_DONE         : std_logic;
    signal     I_FLUSH        : std_logic;
    signal     I_VAL          : std_logic;
    signal     I_RDY          : std_logic;
    signal     O_ENABLE       : std_logic;
    signal     O_DATA         : std_logic_vector(O_WIDTH*(WORD_BITS  )-1 downto 0);
    signal     O_STRB         : std_logic_vector(O_WIDTH*(WORD_BITS/8)-1 downto 0);
    signal     O_DONE         : std_logic;
    signal     O_FLUSH        : std_logic;
    signal     O_VAL          : std_logic;
    signal     O_RDY          : std_logic;
    signal     O_SHIFT        : std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN);
    constant   gnd            : std_logic_vector(O_WIDTH-1 downto 0) := (others => '0');
begin
    U:REDUCER
        generic map (
            WORD_BITS     => WORD_BITS,
            STRB_BITS     => WORD_BITS/8,
            I_WIDTH       => I_WIDTH,
            O_WIDTH       => O_WIDTH,
            QUEUE_SIZE    => QUEUE_SIZE,
            VALID_MIN     => 0,
            VALID_MAX     => 0,
            O_VAL_SIZE    => O_VAL_SIZE,
            O_SHIFT_MAX   => O_SHIFT_MAX,
            O_SHIFT_MIN   => O_SHIFT_MIN,
            NO_VAL_SET    => NO_VAL_SET ,
            I_JUSTIFIED   => I_JUSTIFIED,
            FLUSH_ENABLE  => FLUSH_ENABLE
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            START         => START,
            OFFSET        => OFFSET,
            DONE          => DONE,
            FLUSH         => FLUSH,
            START_DATA    => START_DATA ,
            FLUSH_DATA    => FLUSH_DATA ,
            NO_VAL_DATA   => NO_VAL_DATA,
            I_ENABLE      => I_ENABLE,
            I_DATA        => I_DATA,
            I_STRB        => I_STRB,
            I_FLUSH       => I_FLUSH,
            I_DONE        => I_DONE,
            I_VAL         => I_VAL,
            I_RDY         => I_RDY,
            O_ENABLE      => O_ENABLE,
            O_DATA        => O_DATA,
            O_STRB        => O_STRB,
            O_FLUSH       => O_FLUSH,
            O_DONE        => O_DONE,
            O_VAL         => O_VAL,
            O_RDY         => O_RDY,
            O_SHIFT       => O_SHIFT,
            BUSY          => BUSY ,
            VALID         => open
        );
    O:REDUCER_TEST_MODEL
        generic map (
            NAME          => NAME,
            DELAY         => DELAY,
            WORD_BITS     => WORD_BITS,
            I_WIDTH       => I_WIDTH,
            O_WIDTH       => O_WIDTH,
            O_VAL_SIZE    => O_VAL_SIZE,
            O_SHIFT_MAX   => O_SHIFT_MAX,
            O_SHIFT_MIN   => O_SHIFT_MIN,
            NO_VAL_SET    => NO_VAL_SET ,
            I_JUSTIFIED   => I_JUSTIFIED,
            FLUSH_ENABLE  => FLUSH_ENABLE
        )
        port map (
            CLK           => CLK       ,
            RST           => RST       ,
            CLR           => CLR       ,
            FINISH        => FINISH    ,
            CLK_ENA       => CLK_ENA   ,
            START         => START     ,
            OFFSET        => OFFSET    ,
            START_DATA    => START_DATA ,
            FLUSH_DATA    => FLUSH_DATA ,
            NO_VAL_DATA   => NO_VAL_DATA,
            DONE          => DONE      ,
            FLUSH         => FLUSH     ,
            BUSY          => BUSY      ,
            I_ENABLE      => I_ENABLE  ,
            I_DATA        => I_DATA    ,
            I_STRB        => I_STRB    ,
            I_DONE        => I_DONE    ,
            I_FLUSH       => I_FLUSH   ,
            I_VAL         => I_VAL     ,
            I_RDY         => I_RDY     ,
            O_ENABLE      => O_ENABLE  ,
            O_DATA        => O_DATA    ,
            O_STRB        => O_STRB    ,
            O_DONE        => O_DONE    ,
            O_FLUSH       => O_FLUSH   ,
            O_VAL         => O_VAL     ,
            O_RDY         => O_RDY     ,
            O_SHIFT       => O_SHIFT
        );
    process begin
        loop
            CLK <= '1'; wait for PERIOD/2;
            CLK <= '0'; wait for PERIOD/2;
            exit when(CLK_ENA = '0');
        end loop;
        CLK <= '0';
        wait;
    end process;
end MODEL;
