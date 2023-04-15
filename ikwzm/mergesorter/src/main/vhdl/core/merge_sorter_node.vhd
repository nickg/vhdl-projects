-----------------------------------------------------------------------------------
--!     @file    merge_sorter_node.vhd
--!     @brief   Merge Sorter Node Module :
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
entity  Merge_Sorter_Node is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        INFO_BITS   :  integer :=  1;
        SORT_ORDER  :  integer :=  0
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        A_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        A_INFO      :  in  std_logic_vector(            INFO_BITS-1 downto 0) := (others => '0');
        A_LAST      :  in  std_logic;
        A_VALID     :  in  std_logic;
        A_READY     :  out std_logic;
        B_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        B_INFO      :  in  std_logic_vector(            INFO_BITS-1 downto 0) := (others => '0');
        B_LAST      :  in  std_logic;
        B_VALID     :  in  std_logic;
        B_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(            INFO_BITS-1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end Merge_Sorter_Node;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
use     Merge_Sorter.Sorting_Network;
use     Merge_Sorter.OddEven_MergeSort_Network;
use     Merge_Sorter.Core_Components.Word_Compare;
use     Merge_Sorter.Core_Components.Word_Queue;
use     Merge_Sorter.Core_Components.Sorting_Network_Core;
library PipeWork;
use     PipeWork.Components.REDUCER;
architecture RTL of Merge_Sorter_Node is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    i_word            :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
    signal    i_info            :  std_logic_vector(            INFO_BITS-1 downto 0);
    signal    i_sel_a           :  std_logic;
    signal    i_last            :  std_logic;
    signal    i_valid           :  std_logic;
    signal    i_ready           :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE        is (IDLE_STATE , COMP_STATE   ,
                                    A_SEL_STATE, A_FLUSH_STATE, 
                                    B_SEL_STATE, B_FLUSH_STATE
                                );
    signal    curr_state        :  STATE_TYPE;
    signal    next_state        :  STATE_TYPE;
    signal    temp_state        :  STATE_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    comp_valid        :  std_logic;
    signal    comp_ready        :  std_logic;
    signal    comp_sel_a        :  std_logic;
    signal    comp_sel_b        :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    COMP: Word_Compare                                         --
        generic map(                                           --
            WORD_PARAM  => WORD_PARAM                        , -- 
            SORT_ORDER  => SORT_ORDER                          -- 
        )                                                      -- 
        port map (                                             --
            CLK         => CLK                               , -- In  :
            RST         => RST                               , -- In  :
            CLR         => CLR                               , -- In  :
            A_WORD      => A_WORD(WORD_PARAM.BITS-1 downto 0), -- In  :
            B_WORD      => B_WORD(WORD_PARAM.BITS-1 downto 0), -- In  :
            VALID       => comp_valid                        , -- In  :
            READY       => comp_ready                        , -- Out :
            SEL_A       => comp_sel_a                        , -- Out :
            SEL_B       => comp_sel_b                          -- Out :
        );                                                     -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    comp_valid <= '1' when (curr_state = COMP_STATE and A_VALID = '1' and B_VALID = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (curr_state, comp_ready, comp_sel_b) begin
        case curr_state is
            when COMP_STATE =>
                if   (comp_ready = '1') then
                    if (comp_sel_b = '1') then
                        temp_state <= B_SEL_STATE;
                    else
                        temp_state <= A_SEL_STATE;
                    end if;
                else
                        temp_state <= COMP_STATE;
                end if;
            when others =>
                        temp_state <= curr_state;
        end case;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (temp_state, A_VALID, A_LAST, B_VALID, B_LAST, i_ready) begin
        case temp_state is
            when A_SEL_STATE =>
                if    (i_ready = '1' and A_VALID = '1' and A_LAST = '1') then
                    next_state <= B_FLUSH_STATE;
                elsif (i_ready = '1' and A_VALID = '1' and A_LAST = '0') then
                    next_state <= COMP_STATE;
                else
                    next_state <= A_SEL_STATE;
                end if;
            when B_SEL_STATE =>
                if    (i_ready = '1' and B_VALID = '1' and B_LAST = '1') then
                    next_state <= A_FLUSH_STATE;
                elsif (i_ready = '1' and B_VALID = '1' and B_LAST = '0') then
                    next_state <= COMP_STATE;
                else
                    next_state <= B_SEL_STATE;
                end if;
            when A_FLUSH_STATE =>
                if    (i_ready = '1' and A_VALID = '1' and A_LAST = '1') then
                    next_state <= COMP_STATE;
                else
                    next_state <= A_FLUSH_STATE;
                end if;
            when B_FLUSH_STATE =>
                if    (i_ready = '1' and B_VALID = '1' and B_LAST = '1') then
                    next_state <= COMP_STATE;
                else
                    next_state <= B_FLUSH_STATE;
                end if;
            when COMP_STATE  =>
                    next_state <= COMP_STATE;
            when others =>
                    next_state <= COMP_STATE;
        end case;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state <= IDLE_STATE;
            else
                curr_state <= next_state;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    A_READY <= '1' when (temp_state = A_SEL_STATE   and i_ready = '1') or
                        (temp_state = A_FLUSH_STATE and i_ready = '1') else '0';
    B_READY <= '1' when (temp_state = B_SEL_STATE   and i_ready = '1') or
                        (temp_state = B_FLUSH_STATE and i_ready = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_valid <= '1' when (temp_state = A_SEL_STATE   and A_VALID = '1') or
                        (temp_state = A_FLUSH_STATE and A_VALID = '1') or
                        (temp_state = B_SEL_STATE   and B_VALID = '1') or
                        (temp_state = B_FLUSH_STATE and B_VALID = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_last  <= '1' when (temp_state = A_FLUSH_STATE and A_LAST  = '1') or
                        (temp_state = B_FLUSH_STATE and B_LAST  = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_sel_a <= '1' when (temp_state = A_SEL_STATE  ) or
                        (temp_state = A_FLUSH_STATE) else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_word  <= B_WORD when (temp_state = B_SEL_STATE  ) or
                           (temp_state = B_FLUSH_STATE) else A_WORD;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    i_info  <= B_INFO when (temp_state = B_SEL_STATE  ) or
                           (temp_state = B_FLUSH_STATE) else A_INFO;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    SINGLE_WORD: if (WORDS = 1) generate
        O_WORD  <= i_word;
        O_INFO  <= i_info;
        O_LAST  <= i_last;
        O_VALID <= i_valid;
        i_ready <= O_READY;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MULTI_WORD: if (WORDS > 1) generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        type      PARAM_TYPE        is record
                  INTAKE_QUEUE_SIZE :  integer;
                  LOSER_MERGE       :  Sorting_Network.Param_Type;
                  FINAL_MERGE       :  Sorting_Network.Param_Type;
        end record;
        function  GEN_PARAM return PARAM_TYPE is
            variable param          :  PARAM_TYPE;
        begin
            param.INTAKE_QUEUE_SIZE := 2;
            param.LOSER_MERGE       := OddEven_MergeSort_Network.New_Merge_Network(
                                           LO     => 0         ,
                                           HI     => 2*WORDS-1 ,
                                           ORDER  => SORT_ORDER
                                       );
            param.FINAL_MERGE       := OddEven_MergeSort_Network.New_Merge_Network(
                                           LO     => 0         ,
                                           HI     => 2*WORDS-1 ,
                                           ORDER  => SORT_ORDER
                                       );
            Sorting_Network.Set_Queue_Param(param.LOSER_MERGE,
                                            Sorting_Network.Constant_Queue_Size(1,1,1));
            Sorting_Network.Set_Queue_Param(param.FINAL_MERGE,
                                            Sorting_Network.Constant_Queue_Size(1,1,0));
            return param;
        end function;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  PARAM             :  PARAM_TYPE := GEN_PARAM;
        constant  WORD_BITS         :  integer := WORD_PARAM.BITS;
        constant  TEAM_BITS         :  integer := WORDS*WORD_BITS;
        subtype   WORD_TYPE         is std_logic_vector(WORD_BITS-1 downto 0);
        type      TEAM_TYPE         is array(WORDS-1 downto 0) of WORD_TYPE;
        function  TO_STD_LOGIC_VECTOR(TEAM: TEAM_TYPE) return std_logic_vector is
            variable   value        :  std_logic_vector(TEAM_BITS-1 downto 0);
        begin
            for i in 0 to WORDS-1 loop
                value((i+1)*WORD_BITS-1 downto i*WORD_BITS) := TEAM(i);
            end loop;
            return value;
        end function;
        function  TO_TEAM(SV: std_logic_vector) return TEAM_TYPE is
            alias      value        :  std_logic_vector(SV'length-1 downto 0) is SV;
            variable   team         :  TEAM_TYPE;
        begin
            for i in 0 to WORDS-1 loop
                team(i) := value((i+1)*WORD_BITS-1 downto i*WORD_BITS);
            end loop;
            return team;
        end function;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  PRIORITY_WORD     :  WORD_TYPE := Word.New_Priority_Word(WORD_PARAM);
        constant  POSTPEND_WORD     :  WORD_TYPE := Word.New_Postpend_Word(WORD_PARAM);
        constant  PRIORITY_TEAM     :  TEAM_TYPE := (others => PRIORITY_WORD);
        constant  POSTPEND_TEAM     :  TEAM_TYPE := (others => POSTPEND_WORD);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    intake_team       :  TEAM_TYPE;
        signal    intake_info       :  std_logic_vector(INFO_BITS-1 downto 0);
        signal    intake_sel_a      :  std_logic;
        signal    intake_last       :  std_logic;
        signal    intake_valid      :  std_logic;
        signal    intake_ready      :  std_logic;
        signal    seeded_team       :  TEAM_TYPE;
        signal    last_a_team       :  TEAM_TYPE;
        signal    last_b_team       :  TEAM_TYPE;
        signal    merge_info        :  std_logic_vector(INFO_BITS-1 downto 0);
        signal    merge_last        :  std_logic;
        signal    merge_valid       :  std_logic;
        signal    merge_ready       :  std_logic;
        signal    last_winner_team  :  TEAM_TYPE;
        signal    last_loser_team   :  TEAM_TYPE;
        signal    challenger_team   :  TEAM_TYPE;
        signal    challenger_info   :  std_logic_vector(INFO_BITS-1 downto 0);
        signal    challenger_last   :  std_logic;
        signal    challenger_valid  :  std_logic;
        signal    challenger_ready  :  std_logic;
        signal    final_winner_team :  TEAM_TYPE;
        signal    final_loser_team  :  TEAM_TYPE;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        INTAKE: block
            constant  INFO_INFO_LO      :  integer := 0;
            constant  INFO_INFO_HI      :  integer := INFO_INFO_LO + INFO_BITS - 1;
            constant  INFO_SEL_POS      :  integer := INFO_INFO_HI + 1;
            constant  THIS_INFO_BITS    :  integer := INFO_SEL_POS - INFO_INFO_LO + 1;
            signal    ii_info           :  std_logic_vector(THIS_INFO_BITS-1 downto 0);
            signal    oo_info           :  std_logic_vector(THIS_INFO_BITS-1 downto 0);
            signal    oo_word           :  std_logic_vector(TEAM_BITS     -1 downto 0);
        begin
            ii_info(INFO_INFO_HI downto INFO_INFO_LO) <= i_info;
            ii_info(INFO_SEL_POS                    ) <= i_sel_a;
            QUEUE: Word_Queue                                           -- 
                generic map (                                           -- 
                    WORD_PARAM  => WORD_PARAM                         , -- 
                    WORDS       => WORDS                              , --
                    INFO_BITS   => THIS_INFO_BITS                     , -- 
                    QUEUE_SIZE  => PARAM.INTAKE_QUEUE_SIZE              -- 
                )                                                       -- 
                port map (                                              -- 
                    CLK         => CLK                                , -- In  :
                    RST         => RST                                , -- In  :
                    CLR         => CLR                                , -- In  :
                    I_WORD      => i_word                             , -- In  :
                    I_INFO      => ii_info                            , -- In  :
                    I_LAST      => i_last                             , -- In  :
                    I_VALID     => i_valid                            , -- In  :
                    I_READY     => i_ready                            , -- Out :
                    O_WORD      => oo_word                            , -- Out :
                    O_INFO      => oo_info                            , -- Out :
                    O_LAST      => intake_last                        , -- Out :
                    O_VALID     => intake_valid                       , -- Out :
                    O_READY     => intake_ready                         -- In  :
                );                                                       --
            intake_team  <= TO_TEAM(oo_word);
            intake_info  <= oo_info(INFO_INFO_HI downto INFO_INFO_LO);
            intake_sel_a <= oo_info(INFO_SEL_POS                    );
        end block;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PREPARE_TERM : block
            type      STATE_TYPE        is (IDLE_STATE, XFER_STATE, LAST_STATE);
            signal    curr_state        :  STATE_TYPE;
            signal    last_info         :  std_logic_vector(INFO_BITS-1 downto 0);
        begin
            process (CLK, RST) begin
                if (RST = '1') then
                        curr_state  <= IDLE_STATE;
                        last_a_team <= PRIORITY_TEAM;
                        last_b_team <= PRIORITY_TEAM;
                        last_info   <= (others => '0');
                elsif (CLK'event and CLK = '1') then
                    if (CLR = '1') then
                        curr_state  <= IDLE_STATE;
                        last_a_team <= PRIORITY_TEAM;
                        last_b_team <= PRIORITY_TEAM;
                        last_info   <= (others => '0');
                    else
                        case curr_state is
                            when IDLE_STATE =>
                                if (intake_valid = '1' and intake_ready = '1') then
                                    if (intake_last = '1') then
                                        curr_state <= LAST_STATE;
                                    else
                                        curr_state <= XFER_STATE;
                                    end if;
                                    if (intake_sel_a = '1') then
                                        last_a_team <= intake_team;
                                        last_b_team <= PRIORITY_TEAM;
                                    else
                                        last_a_team <= PRIORITY_TEAM;
                                        last_b_team <= intake_team;
                                    end if;
                                    last_info  <= intake_info;
                                else
                                    curr_state <= IDLE_STATE;
                                end if;
                            when XFER_STATE =>
                                if (intake_valid = '1' and intake_ready = '1') then
                                    if (intake_last = '1') then
                                        curr_state <= LAST_STATE;
                                    else
                                        curr_state <= XFER_STATE;
                                    end if;
                                    if (intake_sel_a = '1') then
                                        last_a_team <= intake_team;
                                    else
                                        last_b_team <= intake_team;
                                    end if;
                                    last_info  <= intake_info;
                                else
                                    curr_state <= XFER_STATE;
                                end if;
                            when LAST_STATE =>
                                if (merge_ready = '1') then
                                    curr_state <= IDLE_STATE;
                                else
                                    curr_state <= LAST_STATE;
                                end if;
                            when others =>
                                    curr_state <= IDLE_STATE;
                        end case;
                    end if;
                end if;
            end process;
            merge_info   <= last_info     when (curr_state = LAST_STATE) else intake_info;
            seeded_team  <= POSTPEND_TEAM when (curr_state = LAST_STATE) else intake_team;
            merge_valid  <= '1' when (curr_state = XFER_STATE and intake_valid = '1') or
                                     (curr_state = LAST_STATE                       ) else '0';
            merge_last   <= '1' when (curr_state = LAST_STATE                       ) else '0';
            intake_ready <= '1' when (curr_state = IDLE_STATE                       ) or
                                     (curr_state = XFER_STATE and merge_ready  = '1') else '0';
        end block;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        LOSER_MERGE: block
            constant  WORD_TEAM0_LO     :  integer := 0;
            constant  WORD_TEAM0_HI     :  integer := WORD_TEAM0_LO + TEAM_BITS - 1;
            constant  WORD_TEAM1_LO     :  integer := WORD_TEAM0_HI + 1;
            constant  WORD_TEAM1_HI     :  integer := WORD_TEAM1_LO + TEAM_BITS - 1;
            constant  THIS_WORD_BITS    :  integer := WORD_TEAM1_HI - WORD_TEAM0_LO + 1;
            constant  INFO_TEAM_LO      :  integer := 0;
            constant  INFO_TEAM_HI      :  integer := INFO_TEAM_LO  + TEAM_BITS - 1;
            constant  INFO_INFO_LO      :  integer := INFO_TEAM_HI  + 1;
            constant  INFO_INFO_HI      :  integer := INFO_INFO_LO  + INFO_BITS - 1;
            constant  INFO_LAST_POS     :  integer := INFO_INFO_HI  + 1;
            constant  THIS_INFO_BITS    :  integer := INFO_LAST_POS - INFO_TEAM_LO  + 1;
            signal    ii_word           :  std_logic_vector(THIS_WORD_BITS-1 downto 0);
            signal    ii_info           :  std_logic_vector(THIS_INFO_BITS-1 downto 0);
            signal    oo_word           :  std_logic_vector(THIS_WORD_BITS-1 downto 0);
            signal    oo_info           :  std_logic_vector(THIS_INFO_BITS-1 downto 0);
        begin
            ii_word(WORD_TEAM0_HI downto WORD_TEAM0_LO) <= TO_STD_LOGIC_VECTOR(last_a_team);
            ii_word(WORD_TEAM1_HI downto WORD_TEAM1_LO) <= TO_STD_LOGIC_VECTOR(last_b_team);
            ii_info(INFO_TEAM_HI  downto INFO_TEAM_LO ) <= TO_STD_LOGIC_VECTOR(seeded_team);
            ii_info(INFO_INFO_HI  downto INFO_INFO_LO ) <= merge_info;
            ii_info(INFO_LAST_POS                     ) <= merge_last;
            CORE: Sorting_Network_Core                         -- 
                generic map (                                  -- 
                    NETWORK_PARAM       => PARAM.LOSER_MERGE , --
                    WORD_PARAM          => WORD_PARAM        , -- 
                    INFO_BITS           => THIS_INFO_BITS      -- 
                )                                              -- 
                port map (                                     -- 
                    CLK                 => CLK               , -- In  :
                    RST                 => RST               , -- In  :
                    CLR                 => CLR               , -- In  :
                    I_WORD              => ii_word           , -- In  :
                    I_INFO              => ii_info           , -- In  :
                    I_VALID             => merge_valid       , -- In  :
                    I_READY             => merge_ready       , -- Out :
                    O_WORD              => oo_word           , -- Out :
                    O_INFO              => oo_info           , -- Out :
                    O_VALID             => challenger_valid  , -- Out :
                    O_READY             => challenger_ready  , -- In  :
                    BUSY                => open                -- Out :
                );
            last_winner_team <= TO_TEAM(oo_word(WORD_TEAM0_HI downto WORD_TEAM0_LO));
            last_loser_team  <= TO_TEAM(oo_word(WORD_TEAM1_HI downto WORD_TEAM1_LO));
            challenger_team  <= TO_TEAM(oo_info(INFO_TEAM_HI  downto INFO_TEAM_LO ));
            challenger_info  <=         oo_info(INFO_INFO_HI  downto INFO_INFO_LO ) ;
            challenger_last  <=         oo_info(INFO_LAST_POS                     ) ;
        end block;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FINAL_MERGE: block
            constant  WORD_TEAM0_LO     :  integer := 0;
            constant  WORD_TEAM0_HI     :  integer := WORD_TEAM0_LO + TEAM_BITS - 1;
            constant  WORD_TEAM1_LO     :  integer := WORD_TEAM0_HI + 1;
            constant  WORD_TEAM1_HI     :  integer := WORD_TEAM1_LO + TEAM_BITS - 1;
            constant  THIS_WORD_BITS    :  integer := WORD_TEAM1_HI - WORD_TEAM0_LO + 1;
            constant  INFO_INFO_LO      :  integer := 0;
            constant  INFO_INFO_HI      :  integer := INFO_INFO_LO  + INFO_BITS - 1;
            constant  INFO_LAST_POS     :  integer := INFO_INFO_HI  + 1;
            constant  THIS_INFO_BITS    :  integer := INFO_LAST_POS - INFO_INFO_LO + 1;
            signal    ii_word           :  std_logic_vector(THIS_WORD_BITS-1 downto 0);
            signal    ii_info           :  std_logic_vector(THIS_INFO_BITS-1 downto 0);
            signal    oo_word           :  std_logic_vector(THIS_WORD_BITS-1 downto 0);
            signal    oo_info           :  std_logic_vector(THIS_INFO_BITS-1 downto 0);
        begin
            ii_word(WORD_TEAM0_HI downto WORD_TEAM0_LO) <= TO_STD_LOGIC_VECTOR(challenger_team);
            ii_word(WORD_TEAM1_HI downto WORD_TEAM1_LO) <= TO_STD_LOGIC_VECTOR(last_loser_team);
            ii_info(INFO_INFO_HI  downto INFO_INFO_LO ) <= challenger_info;
            ii_info(INFO_LAST_POS                     ) <= challenger_last;
            CORE: Sorting_Network_Core                         -- 
                generic map (                                  -- 
                    NETWORK_PARAM       => PARAM.FINAL_MERGE , --
                    WORD_PARAM          => WORD_PARAM        , -- 
                    INFO_BITS           => THIS_INFO_BITS      -- 
                )                                              -- 
                port map (                                     -- 
                    CLK                 => CLK               , -- In  :
                    RST                 => RST               , -- In  :
                    CLR                 => CLR               , -- In  :
                    I_WORD              => ii_word           , -- In  :
                    I_INFO              => ii_info           , -- In  :
                    I_VALID             => challenger_valid  , -- In  :
                    I_READY             => challenger_ready  , -- Out :
                    O_WORD              => oo_word           , -- Out :
                    O_INFO              => oo_info           , -- Out :
                    O_VALID             => O_VALID           , -- Out :
                    O_READY             => O_READY           , -- In  :
                    BUSY                => open                -- Out :
                );
            final_winner_team <= TO_TEAM(oo_word(WORD_TEAM0_HI downto WORD_TEAM0_LO));
            final_loser_team  <= TO_TEAM(oo_word(WORD_TEAM1_HI downto WORD_TEAM1_LO));
            O_WORD <= oo_word(WORD_TEAM0_HI downto WORD_TEAM0_LO);
            O_INFO <= oo_info(INFO_INFO_HI  downto INFO_INFO_LO );
            O_LAST <= oo_info(INFO_LAST_POS);
        end block;
    end generate;
end RTL;
