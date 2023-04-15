-----------------------------------------------------------------------------------
--!     @file    word_drop_none.vhd
--!     @brief   Merge Sorter Word Drop None Module :
--!     @version 0.9.1
--!     @date    2020/11/19
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2020 Ichiro Kawazome
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
entity  Word_Drop_None is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        I_WORDS     :  integer :=  1;
        O_WORDS     :  integer :=  1;
        INFO_BITS   :  integer :=  1
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_WORD      :  in  std_logic_vector(I_WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(              INFO_BITS-1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic;
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(O_WORDS*WORD_PARAM.BITS-1 downto 0);
        O_STRB      :  out std_logic_vector(O_WORDS                -1 downto 0);
        O_INFO      :  out std_logic_vector(              INFO_BITS-1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end Word_Drop_None;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
use     Merge_Sorter.Core_Components.Word_Reducer;
architecture RTL of Word_Drop_None is
    signal    i_strb            :  std_logic_vector(I_WORDS-1 downto 0);
    constant  POSTPEND_WORD     :  std_logic_vector(WORD_PARAM.BITS-1 downto 0)
                                := Word.New_Postpend_Word(WORD_PARAM);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(I_WORD)
        variable  a_word :  std_logic_vector(WORD_PARAM.BITS-1 downto 0);
    begin
        for i in 0 to I_WORDS-1 loop
            a_word := I_WORD((i+1)*WORD_PARAM.BITS-1 downto i*WORD_PARAM.BITS);
            if (a_word(WORD_PARAM.ATRB_NONE_POS) = '0') then
                i_strb(i) <= '1';
            else
                i_strb(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Q: Word_Reducer                           -- 
        generic map (                         -- 
            WORD_PARAM      => WORD_PARAM   , --
            I_WORDS         => I_WORDS      , -- 入力側のワード数
            O_WORDS         => O_WORDS      , -- 出力側のワード数
            INFO_BITS       => INFO_BITS    , -- 
            QUEUE_SIZE      => O_WORDS+2*I_WORDS, -- 
            O_VAL_SIZE      => O_WORDS+1    , -- O_WORDS+1分貯めてからO_VALIDをアサート
            O_SHIFT_MIN     => O_WORDS      , -- キューから取り出す時は WORDS 単位
            O_SHIFT_MAX     => O_WORDS      , -- キューから取り出す時は WORDS 単位
            NO_VAL_SET      => O_WORDS      , --
            I_JUSTIFIED     => 1,             -- 
            FLUSH_ENABLE    => 0              -- 
        )                                     -- 
        port map (                            -- 
            CLK             => CLK          , -- In  :
            RST             => RST          , -- In  :
            CLR             => CLR          , -- In  :
            NO_VAL_WORD     => POSTPEND_WORD, -- In  :
            I_WORD          => I_WORD       , -- In  :
            I_INFO          => I_INFO       , -- In  :
            I_STRB          => i_strb       , -- In  :
            I_DONE          => I_LAST       , -- In  :
            I_VALID         => I_VALID      , -- In  :
            I_READY         => I_READY      , -- Out :
            O_WORD          => O_WORD       , -- Out :
            O_INFO          => O_INFO       , -- Out :
            O_STRB          => O_STRB       , -- Out :
            O_DONE          => O_LAST       , -- Out :
            O_VALID         => O_VALID      , -- Out :
            O_READY         => O_READY        -- In  :
        );
end RTL;
