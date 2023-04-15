-----------------------------------------------------------------------------------
--!     @file    merge_sorter_tree.vhd
--!     @brief   Merge Sorter Single Word Tree Module :
--!     @version 1.4.1
--!     @date    2022/11/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2022 Ichiro Kawazome
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
entity  Merge_Sorter_Tree is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        WAYS        :  integer :=  8;
        INFO_BITS   :  integer :=  3;
        SORT_ORDER  :  integer :=  0;
        QUEUE_SIZE  :  integer :=  2
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_WORD      :  in  std_logic_vector(WAYS*WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(WAYS*            INFO_BITS-1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic_vector(WAYS                      -1 downto 0);
        I_VALID     :  in  std_logic_vector(WAYS                      -1 downto 0);
        I_READY     :  out std_logic_vector(WAYS                      -1 downto 0);
        O_WORD      :  out std_logic_vector(     WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(                 INFO_BITS-1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end Merge_Sorter_Tree;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
use     Merge_Sorter.Core_Components.Word_Queue;
use     Merge_Sorter.Core_Components.Merge_Sorter_Node;
architecture RTL of Merge_Sorter_Tree is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component  Merge_Sorter_Tree 
        generic (
            WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
            WORDS       :  integer :=  1;
            WAYS        :  integer :=  8;
            INFO_BITS   :  integer :=  3;
            SORT_ORDER  :  integer :=  0;
            QUEUE_SIZE  :  integer :=  2
        );
        port (
            CLK         :  in  std_logic;
            RST         :  in  std_logic;
            CLR         :  in  std_logic;
            I_WORD      :  in  std_logic_vector(WAYS*WORDS*WORD_PARAM.BITS-1 downto 0);
            I_INFO      :  in  std_logic_vector(WAYS*            INFO_BITS-1 downto 0) := (others => '0');
            I_LAST      :  in  std_logic_vector(WAYS                      -1 downto 0);
            I_VALID     :  in  std_logic_vector(WAYS                      -1 downto 0);
            I_READY     :  out std_logic_vector(WAYS                      -1 downto 0);
            O_WORD      :  out std_logic_vector(     WORDS*WORD_PARAM.BITS-1 downto 0);
            O_INFO      :  out std_logic_vector(                 INFO_BITS-1 downto 0);
            O_LAST      :  out std_logic;
            O_VALID     :  out std_logic;
            O_READY     :  in  std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_word        :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
    signal    q_info        :  std_logic_vector(            INFO_BITS-1 downto 0);
    signal    q_last        :  std_logic;
    signal    q_valid       :  std_logic;
    signal    q_ready       :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    NONE: if (WAYS = 1) generate
        q_word     <= I_WORD;
        q_info     <= I_INFO;
        q_last     <= I_LAST (0);
        q_valid    <= I_VALID(0);
        I_READY(0) <= q_ready;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    TREE: if (WAYS > 1) generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  A_WAYS    :  integer := WAYS / 2;
        constant  A_FLAG_LO :  integer := 0;
        constant  A_FLAG_HI :  integer := A_WAYS - 1;
        constant  A_WORD_LO :  integer := 0;
        constant  A_WORD_HI :  integer := A_WAYS*WORDS*WORD_PARAM.BITS - 1;
        constant  A_INFO_LO :  integer := 0;
        constant  A_INFO_HI :  integer := A_WAYS*INFO_BITS             - 1;
        signal    a_word    :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        signal    a_info    :  std_logic_vector(            INFO_BITS-1 downto 0);
        signal    a_last    :  std_logic;
        signal    a_valid   :  std_logic;
        signal    a_ready   :  std_logic;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  B_WAYS    :  integer := WAYS - A_WAYS;
        constant  B_FLAG_LO :  integer := A_FLAG_HI + 1;
        constant  B_FLAG_HI :  integer := WAYS      - 1;
        constant  B_WORD_LO :  integer := A_WORD_HI + 1;
        constant  B_WORD_HI :  integer := WAYS*WORDS*WORD_PARAM.BITS - 1;
        constant  B_INFO_LO :  integer := A_INFO_HI + 1;
        constant  B_INFO_HI :  integer := WAYS*INFO_BITS             - 1;
        signal    b_word    :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        signal    b_info    :  std_logic_vector(            INFO_BITS-1 downto 0);
        signal    b_last    :  std_logic;
        signal    b_valid   :  std_logic;
        signal    b_ready   :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        A: Merge_Sorter_Tree                                        -- 
            generic map (                                           -- 
                WORD_PARAM  => WORD_PARAM                         , --
                WORDS       => WORDS                              , --
                WAYS        => A_WAYS                             , --
                INFO_BITS   => INFO_BITS                          , --
                SORT_ORDER  => SORT_ORDER                         , -- 
                QUEUE_SIZE  => QUEUE_SIZE                           --
            )                                                       -- 
            port map (                                              -- 
                CLK         => CLK                                , -- In  :
                RST         => RST                                , -- In  :
                CLR         => CLR                                , -- In  :
                I_WORD      => I_WORD (A_WORD_HI downto A_WORD_LO), -- In  :
                I_INFO      => I_INFO (A_INFO_HI downto A_INFO_LO), -- In  :
                I_LAST      => I_LAST (A_FLAG_HI downto A_FLAG_LO), -- In  :
                I_VALID     => I_VALID(A_FLAG_HI downto A_FLAG_LO), -- In  :
                I_READY     => I_READY(A_FLAG_HI downto A_FLAG_LO), -- Out :
                O_WORD      => a_word                             , -- Out :
                O_INFO      => a_info                             , -- Out :
                O_LAST      => a_last                             , -- Out :
                O_VALID     => a_valid                            , -- Out :
                O_READY     => a_ready                              -- In  :
            );                                                      -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        B: Merge_Sorter_Tree                                        -- 
            generic map (                                           -- 
                WORD_PARAM  => WORD_PARAM                         , --
                WORDS       => WORDS                              , --
                WAYS        => B_WAYS                             , --
                INFO_BITS   => INFO_BITS                          , --
                SORT_ORDER  => SORT_ORDER                         , -- 
                QUEUE_SIZE  => QUEUE_SIZE                           --
            )                                                       -- 
            port map (                                              -- 
                CLK         => CLK                                , -- In  :
                RST         => RST                                , -- In  :
                CLR         => CLR                                , -- In  :
                I_WORD      => I_WORD (B_WORD_HI downto B_WORD_LO), -- In  :
                I_INFO      => I_INFO (B_INFO_HI downto B_INFO_LO), -- In  :
                I_LAST      => I_LAST (B_FLAG_HI downto B_FLAG_LO), -- In  :
                I_VALID     => I_VALID(B_FLAG_HI downto B_FLAG_LO), -- In  :
                I_READY     => I_READY(B_FLAG_HI downto B_FLAG_LO), -- Out :
                O_WORD      => b_word                             , -- Out :
                O_INFO      => b_info                             , -- Out :
                O_LAST      => b_last                             , -- Out :
                O_VALID     => b_valid                            , -- Out :
                O_READY     => b_ready                              -- In  :
            );                                                      -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        NODE: Merge_Sorter_Node                                     -- 
           generic map(                                             -- 
                WORD_PARAM  => WORD_PARAM                         , --
                WORDS       => WORDS                              , --
                SORT_ORDER  => SORT_ORDER                         , -- 
                INFO_BITS   => INFO_BITS                            -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => CLK                                , -- In  :
                RST         => RST                                , -- In  :
                CLR         => CLR                                , -- In  :
                A_WORD      => a_word                             , -- In  :
                A_INFO      => a_info                             , -- In  :
                A_LAST      => a_last                             , -- In  :
                A_VALID     => a_valid                            , -- In  :
                A_READY     => a_ready                            , -- Out :
                B_WORD      => b_word                             , -- In  :
                B_INFO      => b_info                             , -- In  :
                B_LAST      => b_last                             , -- In  :
                B_VALID     => b_valid                            , -- In  :
                B_READY     => b_ready                            , -- Out :
                O_WORD      => q_word                             , -- Out :
                O_INFO      => q_info                             , -- Out :
                O_LAST      => q_last                             , -- Out :
                O_VALID     => q_valid                            , -- Out :
                O_READY     => q_ready                              -- In  :
            );                                                      -- 
    end generate;                                                   -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    OUTLET: block                                                   -- 
    begin                                                           -- 
        QUEUE: Word_Queue                                           -- 
            generic map (                                           -- 
                WORD_PARAM  => WORD_PARAM                         , -- 
                WORDS       => WORDS                              , --
                INFO_BITS   => INFO_BITS                          , -- 
                QUEUE_SIZE  => QUEUE_SIZE                           -- 
            )                                                       -- 
            port map (                                              -- 
                CLK         => CLK                                , -- In  :
                RST         => RST                                , -- In  :
                CLR         => CLR                                , -- In  :
                I_WORD      => q_word                             , -- In  :
                I_INFO      => q_info                             , -- In  :
                I_LAST      => q_last                             , -- In  :
                I_VALID     => q_valid                            , -- In  :
                I_READY     => q_ready                            , -- Out :
                O_WORD      => O_WORD                             , -- Out :
                O_INFO      => O_INFO                             , -- Out :
                O_LAST      => O_LAST                             , -- Out :
                O_VALID     => O_VALID                            , -- Out :
                O_READY     => O_READY                              -- In  :
           );                                                       --
    end block;                                                      -- 
end RTL;
