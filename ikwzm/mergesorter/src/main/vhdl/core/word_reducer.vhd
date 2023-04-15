-----------------------------------------------------------------------------------
--!     @file    word_reducer.vhd
--!     @brief   Merge Sorter Word Reducer Module :
--!     @version 0.9.1
--!     @date    2020/11/19
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2020 Ichiro Kawazome
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
library Merge_Sorter;
use     Merge_Sorter.Word;
entity  Word_Reducer is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        I_WORDS     :  integer :=  1;
        O_WORDS     :  integer :=  1;
        INFO_BITS   :  integer :=  1;
        QUEUE_SIZE  :  integer :=  0;
        VALID_MIN   :  integer :=  0;
        VALID_MAX   :  integer :=  0;
        O_VAL_SIZE  :  integer :=  0;
        O_SHIFT_MIN :  integer :=  1;
        O_SHIFT_MAX :  integer :=  1;
        NO_VAL_SET  :  integer :=  1;
        I_JUSTIFIED :  integer range 0 to 1 := 0;
        FLUSH_ENABLE:  integer range 0 to 1 := 0
    );
    port (
        CLK         :  in  std_logic; 
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        START       :  in  std_logic := '0';
        OFFSET      :  in  std_logic_vector(O_WORDS        -1 downto 0) := (others => '0');
        DONE        :  in  std_logic := '0';
        FLUSH       :  in  std_logic := '0';
        START_WORD  :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0) := (others => '0');
        START_INFO  :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        FLUSH_WORD  :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0) := (others => '0');
        FLUSH_INFO  :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        NO_VAL_WORD :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0) := (others => '0');
        NO_VAL_INFO :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        BUSY        :  out std_logic;
        VALID       :  out std_logic_vector(VALID_MAX downto VALID_MIN);
        I_ENABLE    :  in  std_logic := '1';
        I_WORD      :  in  std_logic_vector(I_WORDS*WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        I_STRB      :  in  std_logic_vector(I_WORDS        -1 downto 0);
        I_DONE      :  in  std_logic := '0';
        I_FLUSH     :  in  std_logic := '0';
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_ENABLE    :  in  std_logic := '1';
        O_WORD      :  out std_logic_vector(O_WORDS*WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(INFO_BITS      -1 downto 0);
        O_STRB      :  out std_logic_vector(O_WORDS        -1 downto 0);
        O_DONE      :  out std_logic;
        O_FLUSH     :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic;
        O_SHIFT     :  in  std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN) := (others => '0')
    );
end Word_Reducer;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.Components.REDUCER;
library Merge_Sorter;
use     Merge_Sorter.Word;
architecture RTL of Word_Reducer is
    constant  TEAM_BITS         :  integer := WORDS*WORD_PARAM.BITS;
    constant  DATA_TEAM_LO_POS  :  integer := 0;
    constant  DATA_TEAM_HI_POS  :  integer := DATA_TEAM_LO_POS + TEAM_BITS - 1;
    constant  DATA_INFO_LO_POS  :  integer := DATA_TEAM_HI_POS + 1;
    constant  DATA_INFO_HI_POS  :  integer := DATA_INFO_LO_POS + INFO_BITS - 1;
    constant  DATA_LO_POS       :  integer := DATA_TEAM_LO_POS;
    constant  DATA_HI_POS       :  integer := DATA_INFO_HI_POS;
    constant  DATA_BITS         :  integer := DATA_HI_POS - DATA_LO_POS + 1;
    signal    i_data            :  std_logic_vector(I_WORDS*DATA_BITS-1 downto 0);
    signal    o_data            :  std_logic_vector(O_WORDS*DATA_BITS-1 downto 0);
    signal    start_data        :  std_logic_vector(        DATA_BITS-1 downto 0);
    signal    flush_data        :  std_logic_vector(        DATA_BITS-1 downto 0);
    signal    no_val_data       :  std_logic_vector(        DATA_BITS-1 downto 0);
    function  GEN_DATA(WORD,INFO: std_logic_vector) return std_logic_vector is
        variable  a_team        :  std_logic_vector(TEAM_BITS-1 downto 0);
        variable  a_data        :  std_logic_vector(DATA_BITS-1 downto 0);
    begin
        for i in 0 to WORDS-1 loop
            a_team((i+1)*WORD_PARAM.BITS-1 downto i*WORD_PARAM.BITS) := WORD;
        end loop;
        a_data(DATA_TEAM_HI_POS downto DATA_TEAM_LO_POS) := a_team;
        a_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS) := INFO;
        return a_data;
    end function;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    start_data  <= GEN_DATA(START_WORD , START_INFO );
    flush_data  <= GEN_DATA(FLUSH_WORD , FLUSH_INFO );
    no_val_data <= GEN_DATA(NO_VAL_WORD, NO_VAL_INFO);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (I_WORD, I_INFO)
        variable  a_team  :  std_logic_vector(TEAM_BITS-1 downto 0);
        variable  a_data  :  std_logic_vector(DATA_BITS-1 downto 0);
    begin
        for i in 0 to I_WORDS-1 loop
            a_team := I_WORD((i+1)*TEAM_BITS-1 downto i*TEAM_BITS);
            a_data(DATA_TEAM_HI_POS downto DATA_TEAM_LO_POS) := a_team;
            a_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS) := I_INFO;
            i_data((i+1)*DATA_BITS-1 downto i*DATA_BITS)     <= a_data;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Q: REDUCER                                       -- 
        generic map (                                -- 
            WORD_BITS       => DATA_BITS           , --
            STRB_BITS       => 1                   , -- 
            I_WIDTH         => I_WORDS             , -- 
            O_WIDTH         => O_WORDS             , -- 
            QUEUE_SIZE      => QUEUE_SIZE          , --
            VALID_MIN       => VALID_MIN           , -- 
            VALID_MAX       => VALID_MAX           , --
            O_VAL_SIZE      => O_VAL_SIZE          , -- 
            O_SHIFT_MIN     => O_SHIFT_MIN         , -- 
            O_SHIFT_MAX     => O_SHIFT_MAX         , -- 
            NO_VAL_SET      => NO_VAL_SET          , -- 
            I_JUSTIFIED     => I_JUSTIFIED         , -- 
            FLUSH_ENABLE    => FLUSH_ENABLE          -- 
        )                                            -- 
        port map (                                   --
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            START           => START               , -- In  :
            OFFSET          => OFFSET              , -- In  :
            DONE            => DONE                , -- In  :
            FLUSH           => FLUSH               , -- In  :
            START_DATA      => start_data          , -- In  :
            FLUSH_DATA      => flush_data          , -- In  :
            NO_VAL_DATA     => no_val_data         , -- In  :
            BUSY            => BUSY                , -- Out :
            VALID           => VALID               , -- Out :
            I_ENABLE        => I_ENABLE            , -- In  :
            I_DATA          => i_data              , -- In  :
            I_STRB          => I_STRB              , -- In  :
            I_DONE          => I_DONE              , -- In  :
            I_FLUSH         => I_FLUSH             , -- In  :
            I_VAL           => I_VALID             , -- In  :
            I_RDY           => I_READY             , -- Out :
            O_ENABLE        => O_ENABLE            , -- In  :
            O_DATA          => o_data              , -- Out :
            O_STRB          => O_STRB              , -- Out :
            O_DONE          => O_DONE              , -- Out :
            O_FLUSH         => O_FLUSH             , -- Out :
            O_VAL           => O_VALID             , -- Out :
            O_RDY           => O_READY             , -- In  :
            O_SHIFT         => O_SHIFT               -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (o_data)
        variable  a_team  :  std_logic_vector(TEAM_BITS-1 downto 0);
        variable  a_data  :  std_logic_vector(DATA_BITS-1 downto 0);
    begin
        for i in 0 to O_WORDS-1 loop
            a_data := o_data((i+1)*DATA_BITS-1 downto i*DATA_BITS);
            a_team := a_data(DATA_TEAM_HI_POS downto DATA_TEAM_LO_POS);
            O_WORD((i+1)*TEAM_BITS-1 downto i*TEAM_BITS) <= a_team;
        end loop;
        O_INFO <= o_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS);
    end process;
end RTL;
