-----------------------------------------------------------------------------------
--!     @file    word_queue.vhd
--!     @brief   Merge Sorter Word Queue Module :
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
entity  Word_Queue is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        INFO_BITS   :  integer :=  1;
        QUEUE_SIZE  :  integer :=  2
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(INFO_BITS            -1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic := '0';
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(INFO_BITS            -1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end Word_Queue;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.Components.QUEUE_REGISTER;
library Merge_Sorter;
use     Merge_Sorter.Word;
architecture RTL of Word_Queue is
    constant  DATA_WORD_BITS    :  integer := WORDS*WORD_PARAM.BITS;
    constant  DATA_WORD_LO_POS  :  integer := 0;
    constant  DATA_WORD_HI_POS  :  integer := DATA_WORD_LO_POS + DATA_WORD_BITS - 1;
    constant  DATA_INFO_LO_POS  :  integer := DATA_WORD_HI_POS + 1;
    constant  DATA_INFO_HI_POS  :  integer := DATA_INFO_LO_POS + INFO_BITS      - 1;
    constant  DATA_LAST_POS     :  integer := DATA_INFO_HI_POS + 1;
    constant  DATA_LO_POS       :  integer := DATA_WORD_LO_POS;
    constant  DATA_HI_POS       :  integer := DATA_LAST_POS;
    constant  DATA_BITS         :  integer := DATA_HI_POS - DATA_LO_POS + 1;
    signal    i_data            :  std_logic_vector(DATA_HI_POS downto DATA_LO_POS);
    signal    q_data            :  std_logic_vector(DATA_HI_POS downto DATA_LO_POS);
    signal    q_valid           :  std_logic_vector(QUEUE_SIZE  downto           0);
begin
    Q: QUEUE_REGISTER                    -- 
        generic map (                    -- 
            QUEUE_SIZE  => QUEUE_SIZE  , -- 
            DATA_BITS   => DATA_BITS     --
        )                                -- 
        port map (                       -- 
            CLK         => CLK         , -- In  :
            RST         => RST         , -- In  :
            CLR         => CLR         , -- In  :
            I_DATA      => i_data      , -- In  :
            I_VAL       => I_VALID     , -- In  :
            I_RDY       => I_READY     , -- Out :
            O_DATA      => open        , -- Out :
            O_VAL       => open        , -- Out :
            Q_DATA      => q_data      , -- Out :
            Q_VAL       => q_valid     , -- Out :
            Q_RDY       => O_READY       -- In  :
        );
    i_data(DATA_WORD_HI_POS downto DATA_WORD_LO_POS) <= I_WORD;
    i_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS) <= I_INFO;
    i_data(DATA_LAST_POS                           ) <= I_LAST;
    O_WORD <= q_data(DATA_WORD_HI_POS downto DATA_WORD_LO_POS);
    O_INFO <= q_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS);
    O_LAST <= q_data(DATA_LAST_POS);
    O_VALID<= q_valid(0);
end RTL;
