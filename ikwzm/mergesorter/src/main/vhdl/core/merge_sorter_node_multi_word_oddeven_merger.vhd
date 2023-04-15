-----------------------------------------------------------------------------------
--!     @file    merge_sorter_node_multi_word_oddeven_merger.vhd
--!     @brief   Merge Sorter Node Multi Word OddEven Merger Module :
--!     @version 0.7.0
--!     @date    2020/11/2
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
entity  Merge_Sorter_Node_Multi_Word_OddEven_Merger is
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
        I_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(            INFO_BITS-1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic;
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(            INFO_BITS-1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end Merge_Sorter_Node_Multi_Word_OddEven_Merger;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
use     Merge_Sorter.Sorting_Network;
use     Merge_Sorter.Core_Components.Word_Queue;
use     Merge_Sorter.Core_Components.Sorting_Network_Core;
library PipeWork;
use     PipeWork.Components.REDUCER;
architecture RTL of Merge_Sorter_Node_Multi_Word_OddEven_Merger is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      PARAM_TYPE        is record
              INTAKE_QUEUE_SIZE :  integer;
              LOSER_MERGE       :  Sorting_Network.Param_Type;
              FINAL_MERGE       :  Sorting_Network.Param_Type;
    end record;
    function  GEN_PARAM return PARAM_TYPE is
        variable param          :  PARAM_TYPE;
    begin
        param.INTAKE_QUEUE_SIZE := 2;
        param.LOSER_MERGE       := Sorting_Network.New_OddEven_Merger_Network(
                                       LO     => 0         ,
                                       HI     => 2*WORDS-1 ,
                                       ORDER  => SORT_ORDER,
                                       QUEUE  => 1
                                   );
        param.FINAL_MERGE       := Sorting_Network.New_OddEven_Merger_Network(
                                       LO     => 0         ,
                                       HI     => 2*WORDS-1 ,
                                       ORDER  => SORT_ORDER,
                                       QUEUE  => 1
                                   );
        param.FINAL_MERGE.Stage_List(param.FINAL_MERGE.Stage_HI).Queue_Size := 0;
        return param;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
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
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_team       :  TEAM_TYPE;
    signal    intake_word       :  std_logic_vector(TEAM_BITS-1 downto 0);
    signal    intake_info       :  std_logic_vector(INFO_BITS-1 downto 0);
    signal    intake_start      :  std_logic;
    signal    intake_last       :  std_logic;
    signal    intake_valid      :  std_logic;
    signal    intake_ready      :  std_logic;
    signal    first_team        :  TEAM_TYPE;
    signal    first_info        :  std_logic_vector(INFO_BITS-1 downto 0);
    signal    second_team       :  TEAM_TYPE;
    signal    second_info       :  std_logic_vector(INFO_BITS-1 downto 0);
    signal    third_team        :  TEAM_TYPE;
    signal    third_info        :  std_logic_vector(INFO_BITS-1 downto 0);
    signal    third_last        :  std_logic;
    signal    third_valid       :  std_logic;
    signal    third_ready       :  std_logic;
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
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    INTAKE_QUEUE: Word_Queue                                    -- 
        generic map (                                           -- 
            WORD_PARAM  => WORD_PARAM                         , -- 
            WORDS       => WORDS                              , --
            INFO_BITS   => INFO_BITS                          , -- 
            QUEUE_SIZE  => PARAM.INTAKE_QUEUE_SIZE              -- 
        )                                                       -- 
        port map (                                              -- 
            CLK         => CLK                                , -- In  :
            RST         => RST                                , -- In  :
            CLR         => CLR                                , -- In  :
            I_WORD      => I_WORD                             , -- In  :
            I_INFO      => I_INFO                             , -- In  :
            I_LAST      => I_LAST                             , -- In  :
            I_VALID     => I_VALID                            , -- In  :
            I_READY     => I_READY                            , -- Out :
            O_WORD      => intake_word                        , -- Out :
            O_INFO      => intake_info                        , -- Out :
            O_LAST      => intake_last                        , -- Out :
            O_VALID     => intake_valid                       , -- Out :
            O_READY     => intake_ready                         -- In  :
        );                                                       --
    intake_team <= TO_TEAM(intake_word);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                intake_start <= '1';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                intake_start <= '1';
            elsif (intake_start = '1') then
                if (intake_valid = '1' and intake_ready = '1' and intake_last = '0') then
                    intake_start <= '0';
                end if;
            else
                if (intake_valid = '1' and intake_ready = '1' and intake_last = '1') then
                    intake_start <= '1';
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PREPARE_TERM : block
        function  GEN_PRIORITY_WORD return std_logic_vector is
            variable  word    :  std_logic_vector(WORD_PARAM.BITS-1 downto 0);
        begin
            word := (others => '0');
            word(WORD_PARAM.ATRB_NONE_POS    ) := '1';
            word(WORD_PARAM.ATRB_PRIORITY_POS) := '1';
            word(WORD_PARAM.ATRB_POSTPEND_POS) := '0';
            return word;
        end function;
        function  GEN_POSTPEND_WORD return std_logic_vector is
            variable  word    :  std_logic_vector(WORD_PARAM.BITS-1 downto 0);
        begin
            word := (others => '0');
            word(WORD_PARAM.ATRB_NONE_POS    ) := '1';
            word(WORD_PARAM.ATRB_PRIORITY_POS) := '0';
            word(WORD_PARAM.ATRB_POSTPEND_POS) := '1';
            return word;
        end function;
        constant  PRIORITY_WORD     :  WORD_TYPE := GEN_PRIORITY_WORD;
        constant  POSTPEND_WORD     :  WORD_TYPE := GEN_POSTPEND_WORD;
        constant  PRIORITY_TEAM     :  TEAM_TYPE := (others => PRIORITY_WORD);
        constant  POSTPEND_TEAM     :  TEAM_TYPE := (others => POSTPEND_WORD);
        constant  INTAKE_WIDTH      :  integer := 2;
        constant  OUTLET_WIDTH      :  integer := 3;
        constant  DATA_TEAM0_LO     :  integer := 0;
        constant  DATA_TEAM0_HI     :  integer := DATA_TEAM0_LO + TEAM_BITS - 1;
        constant  DATA_INFO0_LO     :  integer := DATA_TEAM0_HI + 1;
        constant  DATA_INFO0_HI     :  integer := DATA_INFO0_LO + INFO_BITS - 1;
        constant  DATA_TEAM1_LO     :  integer := DATA_INFO0_HI + 1;
        constant  DATA_TEAM1_HI     :  integer := DATA_TEAM1_LO + TEAM_BITS - 1;
        constant  DATA_INFO1_LO     :  integer := DATA_TEAM1_HI + 1;
        constant  DATA_INFO1_HI     :  integer := DATA_INFO1_LO + INFO_BITS - 1;
        constant  DATA_TEAM2_LO     :  integer := DATA_INFO1_HI + 1;
        constant  DATA_TEAM2_HI     :  integer := DATA_TEAM2_LO + TEAM_BITS - 1;
        constant  DATA_INFO2_LO     :  integer := DATA_TEAM2_HI + 1;
        constant  DATA_INFO2_HI     :  integer := DATA_INFO2_LO + INFO_BITS - 1;
        signal    intake_team_0     :  TEAM_TYPE;
        signal    intake_team_1     :  TEAM_TYPE;
        signal    intake_strb       :  std_logic_vector(INTAKE_WIDTH          -1 downto 0);
        signal    intake_data       :  std_logic_vector(INTAKE_WIDTH*(TEAM_BITS+INFO_BITS)-1 downto 0);
        signal    outlet_data       :  std_logic_vector(OUTLET_WIDTH*(TEAM_BITS+INFO_BITS)-1 downto 0);
        signal    queue_reset       :  std_logic;
    begin
        intake_team_0 <= PRIORITY_TEAM when (intake_start = '1') else intake_team;
        intake_team_1 <= POSTPEND_TEAM when (intake_last  = '1') else intake_team;
        intake_strb   <= "11" when (intake_start = '1' or intake_last = '1') else "01";
        queue_reset   <= '1' when (CLR = '1') or
                                  (third_valid = '1' and third_ready = '1' and third_last = '1') else '0';
        intake_data(DATA_TEAM0_HI downto DATA_TEAM0_LO) <= TO_STD_LOGIC_VECTOR(intake_team_0);
        intake_data(DATA_INFO0_HI downto DATA_INFO0_LO) <= intake_info  ;
        intake_data(DATA_TEAM1_HI downto DATA_TEAM1_LO) <= TO_STD_LOGIC_VECTOR(intake_team_1);
        intake_data(DATA_INFO1_HI downto DATA_INFO1_LO) <= intake_info  ;
        QUEUE: REDUCER                                   -- 
            generic map (                                -- 
                WORD_BITS       => TEAM_BITS + INFO_BITS,--
                STRB_BITS       => 1,                    -- 
                I_WIDTH         => INTAKE_WIDTH,         -- 
                O_WIDTH         => OUTLET_WIDTH,         -- 
                QUEUE_SIZE      => 5,                    -- 5word分のキューを用意
                VALID_MIN       => 0,                    -- 
                VALID_MAX       => 0,                    -- 
                O_VAL_SIZE      => OUTLET_WIDTH,         -- 3word分貯めてからO_VALIDをアサート
                O_SHIFT_MIN     => 1,                    -- 
                O_SHIFT_MAX     => 1,                    -- 
                I_JUSTIFIED     => 1,                    -- 
                FLUSH_ENABLE    => 0                     -- 
            )                                            -- 
            port map (                                   -- 
                CLK             => CLK                 , -- In  :
                RST             => RST                 , -- In  :
                CLR             => queue_reset         , -- In  :
                I_DATA          => intake_data         , -- In  :
                I_STRB          => intake_strb         , -- In  :
                I_DONE          => intake_last         , -- In  :
                I_VAL           => intake_valid        , -- In  :
                I_RDY           => intake_ready        , -- Out :
                O_DATA          => outlet_data         , -- Out :
                O_DONE          => third_last          , -- Out :
                O_VAL           => third_valid         , -- Out :
                O_RDY           => third_ready           -- In  :
            );
        first_team  <= TO_TEAM(outlet_data(DATA_TEAM0_HI downto DATA_TEAM0_LO));
        first_info  <=         outlet_data(DATA_INFO0_HI downto DATA_INFO0_LO) ;
        second_team <= TO_TEAM(outlet_data(DATA_TEAM1_HI downto DATA_TEAM1_LO));
        second_info <=         outlet_data(DATA_INFO1_HI downto DATA_INFO1_LO) ;
        third_team  <= TO_TEAM(outlet_data(DATA_TEAM2_HI downto DATA_TEAM2_LO));
        third_info  <=         outlet_data(DATA_INFO2_HI downto DATA_INFO2_LO) ;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
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
        ii_word(WORD_TEAM0_HI downto WORD_TEAM0_LO) <= TO_STD_LOGIC_VECTOR(first_team );
        ii_word(WORD_TEAM1_HI downto WORD_TEAM1_LO) <= TO_STD_LOGIC_VECTOR(second_team);
        ii_info(INFO_TEAM_HI  downto INFO_TEAM_LO ) <= TO_STD_LOGIC_VECTOR(third_team );
        ii_info(INFO_INFO_HI  downto INFO_INFO_LO ) <= third_info ;
        ii_info(INFO_LAST_POS                     ) <= third_last ;
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
                I_VALID             => third_valid       , -- In  :
                I_READY             => third_ready       , -- Out :
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
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
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
end RTL;
