-----------------------------------------------------------------------------------
--!     @file    core_intake_fifo.vhd
--!     @brief   Merge Sorter Core Intake Fifo Module :
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
entity  Core_Intake_Fifo is
    generic (
        WORD_PARAM      :  Word.Param_Type := Word.New_Param(DATA_BITS => 8);
        WORDS           :  integer :=    1;
        FBK_IN_ENABLE   :  boolean := TRUE;
        MRG_IN_ENABLE   :  boolean := TRUE;
        SIZE_BITS       :  integer :=    6;
        FIFO_SIZE       :  integer :=   64;
        LEVEL_SIZE      :  integer :=   32;
        INFO_BITS       :  integer :=    8;
        INFO_EBLK_POS   :  integer :=    0;
        INFO_FBK_POS    :  integer :=    1;
        INFO_FBK_NUM_LO :  integer :=    2;
        INFO_FBK_NUM_HI :  integer :=    7
    );
    port (
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
        FBK_REQ         :  in  std_logic := '0';
        FBK_ACK         :  out std_logic;
        FBK_DONE        :  out std_logic;
        FBK_OUT_START   :  in  std_logic := '0';
        FBK_OUT_SIZE    :  in  std_logic_vector(            SIZE_BITS-1 downto 0);
        FBK_OUT_LAST    :  in  std_logic := '0';
        FBK_IN_WORD     :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        FBK_IN_LAST     :  in  std_logic;
        FBK_IN_VALID    :  in  std_logic := '0';
        FBK_IN_READY    :  out std_logic;
        MRG_REQ         :  in  std_logic := '0';
        MRG_ACK         :  out std_logic;
        MRG_IN_WORD     :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        MRG_IN_EBLK     :  in  std_logic;
        MRG_IN_LAST     :  in  std_logic;
        MRG_IN_VALID    :  in  std_logic := '0';
        MRG_IN_READY    :  out std_logic;
        MRG_IN_LEVEL    :  out std_logic;
        OUTLET_WORD     :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        OUTLET_INFO     :  out std_logic_vector(            INFO_BITS-1 downto 0);
        OUTLET_LAST     :  out std_logic;
        OUTLET_VALID    :  out std_logic;
        OUTLET_READY    :  in  std_logic
    );
end Core_Intake_Fifo;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Core_Components.Word_Fifo;
architecture RTL of Core_Intake_Fifo is
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    NONE: if (FIFO_SIZE = 0) generate
        FBK_ACK      <= '0';
        FBK_DONE     <= '0';
        FBK_IN_READY <= '0';
        MRG_ACK      <= '0';
        MRG_IN_READY <= '0';
        MRG_IN_LEVEL <= '0';
        OUTLET_WORD  <= (others => '0');
        OUTLET_INFO  <= (others => '0');
        OUTLET_LAST  <= '0';
        OUTLET_VALID <= '0';
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MAIN: if (FIFO_SIZE > 0) generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  FBK_NUM_BITS      :  integer := INFO_FBK_NUM_HI-INFO_FBK_NUM_LO+1;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        type      STATE_TYPE        is (IDLE_STATE,
                                        FBK_RUN_STATE,
                                        FBK_ACK_STATE,
                                        MRG_RUN_STATE,
                                        MRG_ACK_STATE
                                       );
        signal    curr_state        :  STATE_TYPE;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    fbk_intake_enable :  boolean;
        signal    fbk_intake_valid  :  std_logic;
        signal    fbk_intake_ready  :  std_logic;
        signal    fbk_intake_word   :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        signal    fbk_intake_eblk   :  std_logic;
        signal    fbk_intake_last   :  std_logic;
        signal    fbk_outlet_enable :  boolean;
        signal    fbk_outlet_eblk   :  std_logic;
        signal    fbk_outlet_next   :  std_logic;
        signal    fbk_outlet_last   :  std_logic;
        signal    fbk_outlet_num    :  std_logic_vector(FBK_NUM_BITS-1 downto 0);
        signal    fbk_state_done    :  boolean;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    mrg_intake_enable :  boolean;
        signal    mrg_intake_valid  :  std_logic;
        signal    mrg_intake_ready  :  std_logic;
        signal    mrg_intake_word   :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        signal    mrg_intake_eblk   :  std_logic;
        signal    mrg_intake_last   :  std_logic;
        signal    mrg_outlet_enable :  boolean;
        signal    mrg_outlet_eblk   :  std_logic;
        signal    mrg_state_done    :  boolean;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    fifo_intake_valid :  std_logic;
        signal    fifo_intake_ready :  std_logic;
        signal    fifo_intake_word  :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        signal    fifo_intake_last  :  std_logic;
        signal    fifo_intake_eblk  :  std_logic;
        signal    fifo_intake_enable:  std_logic;
        signal    fifo_intake_level :  std_logic;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        signal    fifo_outlet_valid :  std_logic;
        signal    fifo_outlet_ready :  std_logic;
        signal    fifo_outlet_word  :  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        signal    fifo_outlet_last  :  std_logic;
        signal    fifo_outlet_eblk  :  std_logic;
        signal    fifo_outlet_enable:  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FSM: process (CLK, RST) begin
            if (RST = '1') then
                    curr_state         <= IDLE_STATE;
                    fifo_outlet_enable <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_state         <= IDLE_STATE;
                    fifo_outlet_enable <= '0';
                else
                    case curr_state is
                        when IDLE_STATE =>
                            if    (FBK_IN_ENABLE = TRUE and FBK_REQ = '1') then
                                curr_state         <= FBK_RUN_STATE;
                                fifo_outlet_enable <= '0';
                            elsif (MRG_IN_ENABLE = TRUE and MRG_REQ = '1') then
                                curr_state         <= MRG_RUN_STATE;
                                fifo_outlet_enable <= '1';
                            else
                                curr_state         <= IDLE_STATE;
                                fifo_outlet_enable <= '0';
                            end if;
                        when FBK_RUN_STATE =>
                            if    (fbk_state_done = TRUE) or
                                  (FBK_OUT_START = '1' and unsigned(FBK_OUT_SIZE) = 0) then
                                curr_state         <= FBK_ACK_STATE;
                                fifo_outlet_enable <= '0';
                            elsif (FBK_OUT_START = '1') then
                                curr_state         <= FBK_RUN_STATE;
                                fifo_outlet_enable <= '1';
                            else
                                curr_state         <= FBK_RUN_STATE;
                                fifo_outlet_enable <= fifo_outlet_enable;
                            end if;
                        when FBK_ACK_STATE =>
                            if (FBK_REQ = '0') then
                                curr_state         <= IDLE_STATE;
                                fifo_outlet_enable <= '0';
                            else
                                curr_state         <= FBK_ACK_STATE;
                                fifo_outlet_enable <= '0';
                            end if;
                        when MRG_RUN_STATE =>
                            if (mrg_state_done = TRUE) then
                                curr_state         <= MRG_ACK_STATE;
                                fifo_outlet_enable <= '0';
                            else
                                curr_state         <= MRG_RUN_STATE;
                                fifo_outlet_enable <= '1';
                            end if;
                        when MRG_ACK_STATE =>
                            if (MRG_REQ = '0') then
                                curr_state         <= IDLE_STATE;
                                fifo_outlet_enable <= '0';
                            else
                                curr_state         <= MRG_ACK_STATE;
                                fifo_outlet_enable <= '0';
                            end if;
                        when others =>
                                curr_state         <= IDLE_STATE;
                                fifo_outlet_enable <= '0';
                    end case;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        fifo_intake_word   <= fbk_intake_word  or mrg_intake_word;
        fifo_intake_last   <= fbk_intake_last  or mrg_intake_last;
        fifo_intake_eblk   <= fbk_intake_eblk  or mrg_intake_eblk;
        fifo_intake_valid  <= fbk_intake_valid or mrg_intake_valid;
        fifo_intake_enable <= '1' when (fbk_intake_enable or mrg_intake_enable) else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FBK_CTRL: if (FBK_IN_ENABLE = TRUE) generate
            signal    intake_enable  :  boolean;
            signal    outlet_counter :  std_logic_vector(SIZE_BITS-1 downto 0);
            signal    outlet_next    :  boolean;
            signal    outlet_last    :  boolean;
            signal    outlet_done    :  std_logic;
            signal    outlet_size    :  std_logic_vector(SIZE_BITS-1 downto 0);
        begin 
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            process (CLK, RST)
                variable next_counter :  unsigned(SIZE_BITS   downto 0);
                variable next_size    :  unsigned(SIZE_BITS-1 downto 0);
                variable next_done    :  std_logic;
            begin
                if (RST = '1') then
                        outlet_counter <= (others => '0');
                        outlet_next    <= FALSE;
                        outlet_last    <= FALSE;
                        outlet_size    <= (others => '0');
                        outlet_done    <= '0';
                elsif (CLK'event and CLK = '1') then
                    if (CLR = '1') then
                        outlet_counter <= (others => '0');
                        outlet_next    <= FALSE;
                        outlet_last    <= FALSE;
                        outlet_size    <= (others => '0');
                        outlet_done    <= '0';
                    elsif (curr_state = FBK_RUN_STATE) then
                        if (FBK_OUT_START = '1') then
                            next_size  := unsigned(FBK_OUT_SIZE) - 1;
                            next_done  := FBK_OUT_LAST;
                        else
                            next_size  := unsigned(outlet_size);
                            next_done  := outlet_done;
                        end if;
                        next_counter := "0" & unsigned(outlet_counter);
                        if (fifo_outlet_enable = '1') and
                           (fifo_outlet_valid  = '1') and
                           (fifo_outlet_ready  = '1') and
                           (fifo_outlet_last   = '1') then
                            next_counter := next_counter + 1;
                        end if;
                        outlet_counter <= std_logic_vector(next_counter(outlet_counter'range));
                        outlet_next    <= (next_counter  < unsigned(next_size));
                        outlet_last    <= (next_counter >= unsigned(next_size));
                        outlet_size    <= std_logic_vector(next_size);
                        outlet_done    <= next_done;
                    elsif (curr_state = FBK_ACK_STATE) then
                        outlet_counter <= outlet_counter;
                        outlet_next    <= outlet_next;
                        outlet_last    <= outlet_last;
                        outlet_size    <= outlet_size;
                        outlet_done    <= outlet_done;
                    else
                        outlet_counter <= (others => '0');
                        outlet_next    <= FALSE;
                        outlet_last    <= FALSE;
                        outlet_size    <= (others => '0');
                        outlet_done    <= '0';
                    end if;
                end if;
            end process;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            fbk_outlet_enable <= (curr_state = FBK_RUN_STATE and fifo_outlet_enable = '1');
            fbk_state_done    <= ((fbk_outlet_enable = TRUE) and
                                  (fbk_outlet_last   = '1' ) and
                                  (fifo_outlet_valid = '1' ) and
                                  (fifo_outlet_ready = '1' ) and
                                  (fifo_outlet_last  = '1'));
            fbk_outlet_next   <= '1' when (outlet_next and fbk_outlet_enable) else '0';
            fbk_outlet_last   <= '1' when (outlet_last and fbk_outlet_enable) else '0';
            fbk_outlet_eblk   <= '1' when (fbk_outlet_last = '1' and outlet_done = '1') else '0';
            fbk_outlet_num    <= outlet_counter(fbk_outlet_num'range) when (fbk_outlet_enable) else (others => '0');
            FBK_ACK           <= '1' when (curr_state = FBK_ACK_STATE) else '0';
            FBK_DONE          <= '1' when (curr_state = FBK_ACK_STATE and outlet_done = '1') else '0';
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            fbk_intake_word   <= FBK_IN_WORD       when (fbk_intake_enable) else (others => '0');
            fbk_intake_last   <= FBK_IN_LAST       when (fbk_intake_enable) else '0';
            fbk_intake_eblk   <= '0';
            fbk_intake_enable <= (curr_state = FBK_RUN_STATE);
            fbk_intake_valid  <= FBK_IN_VALID      when (fbk_intake_enable) else '0';
            fbk_intake_ready  <= fifo_intake_ready when (fbk_intake_enable) else '0';
            FBK_IN_READY      <= fifo_intake_ready when (fbk_intake_enable) else '0';
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FBK_NONE: if (FBK_IN_ENABLE = FALSE) generate
            fbk_state_done    <= TRUE;
            fbk_outlet_enable <= FALSE;
            fbk_outlet_eblk   <= '0';
            fbk_outlet_next   <= '0';
            fbk_outlet_num    <= (others => '0');
            fbk_intake_enable <= FALSE;
            fbk_intake_valid  <= '0';
            fbk_intake_word   <= (others => '0');
            fbk_intake_last   <= '0';
            fbk_intake_eblk   <= '0';
            fbk_intake_ready  <= '0';
            FBK_IN_READY      <= '0';
            FBK_ACK           <= '0';
            FBK_DONE          <= '0';
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        MRG_CTRL: if (MRG_IN_ENABLE = TRUE) generate
            signal    fifo_flush    :  boolean;
        begin
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            process (CLK, RST) begin
                if (RST = '1') then
                        fifo_flush <= FALSE;
                elsif (CLK'event and CLK = '1') then
                    if (CLR = '1') then
                        fifo_flush <= FALSE;
                    elsif (curr_state = MRG_RUN_STATE) then
                        if (mrg_state_done = TRUE) then
                            fifo_flush <= FALSE;
                        elsif (mrg_intake_valid  = '1' and mrg_intake_ready = '1') and
                              (MRG_IN_LAST       = '1' and MRG_IN_EBLK      = '1') then
                            fifo_flush <= TRUE;
                        end if;
                    else
                        fifo_flush <= FALSE;
                    end if;
                end if;
            end process;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            mrg_outlet_enable <= (curr_state = MRG_RUN_STATE and fifo_outlet_enable = '1');
            mrg_outlet_eblk   <= fifo_outlet_eblk when (mrg_outlet_enable) else '0';
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            mrg_state_done    <= ((curr_state = MRG_RUN_STATE and fifo_flush = TRUE) and
                                  (fifo_outlet_enable = '1') and
                                  (fifo_outlet_valid  = '1') and
                                  (fifo_outlet_ready  = '1') and
                                  (fifo_outlet_last   = '1') and
                                  (fifo_outlet_eblk   = '1'));
            MRG_ACK           <= '1' when (curr_state = MRG_ACK_STATE) else '0';
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            mrg_intake_enable <= (curr_state = MRG_RUN_STATE and fifo_flush = FALSE);
            mrg_intake_word   <= MRG_IN_WORD       when (mrg_intake_enable) else (others => '0');
            mrg_intake_last   <= MRG_IN_LAST       when (mrg_intake_enable) else '0';
            mrg_intake_eblk   <= MRG_IN_EBLK       when (mrg_intake_enable) else '0';
            mrg_intake_valid  <= MRG_IN_VALID      when (mrg_intake_enable) else '0';
            mrg_intake_ready  <= fifo_intake_ready when (mrg_intake_enable) else '0';
            MRG_IN_READY      <= fifo_intake_ready when (mrg_intake_enable) else '0';
            MRG_IN_LEVEL      <= fifo_intake_level when (mrg_intake_enable) else '0';
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        MRG_NONE: if (MRG_IN_ENABLE = FALSE) generate
            mrg_state_done    <= TRUE;
            mrg_outlet_enable <= FALSE;
            mrg_outlet_eblk   <= '0';
            mrg_intake_enable <= FALSE;
            mrg_intake_valid  <= '0';
            mrg_intake_word   <= (others => '0');
            mrg_intake_last   <= '0';
            mrg_intake_eblk   <= '0';
            mrg_intake_ready  <= '0';
            MRG_IN_READY      <= '0';
            MRG_IN_LEVEL      <= '0';
            MRG_ACK           <= '0';
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        OUTLET_WORD <= fifo_outlet_word when (fifo_outlet_enable = '1') else (others => '0');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (fifo_outlet_enable, fbk_outlet_eblk, fbk_outlet_next, fbk_outlet_num, mrg_outlet_eblk) begin
            if (fifo_outlet_enable = '1') then
                OUTLET_INFO(INFO_EBLK_POS                         ) <= fbk_outlet_eblk or mrg_outlet_eblk;
                OUTLET_INFO(INFO_FBK_POS                          ) <= fbk_outlet_next;
                OUTLET_INFO(INFO_FBK_NUM_HI downto INFO_FBK_NUM_LO) <= fbk_outlet_num;
            else
                OUTLET_INFO <= (others => '0');
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        OUTLET_LAST  <= fifo_outlet_last   when (fifo_outlet_enable = '1') else '0';
        OUTLET_VALID <= fifo_outlet_valid  when (fifo_outlet_enable = '1') else '0';
        fifo_outlet_ready <= OUTLET_READY;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        FIFO: Word_Fifo                              -- 
            generic map (                            -- 
                WORD_PARAM  => WORD_PARAM          , -- 
                WORDS       => WORDS               , -- 
                INFO_BITS   => 1                   , -- 
                FIFO_SIZE   => FIFO_SIZE           , -- 
                LEVEL_SIZE  => LEVEL_SIZE            -- 
            )                                        -- 
            port map (                               --
                CLK         => CLK                 , -- In  :  
                RST         => RST                 , -- In  :  
                CLR         => CLR                 , -- In  :  
                I_ENABLE    => fifo_intake_enable  , -- In  :  
                I_WORD      => fifo_intake_word    , -- In  :  
                I_INFO(0)   => fifo_intake_eblk    , -- In  :  
                I_LAST      => fifo_intake_last    , -- In  :  
                I_VALID     => fifo_intake_valid   , -- In  :  
                I_READY     => fifo_intake_ready   , -- Out :
                I_LEVEL     => fifo_intake_level   , -- Out :
                O_ENABLE    => fifo_outlet_enable  , -- In  :  
                O_WORD      => fifo_outlet_word    , -- Out :
                O_INFO(0)   => fifo_outlet_eblk    , -- Out :
                O_LAST      => fifo_outlet_last    , -- Out :
                O_VALID     => fifo_outlet_valid   , -- Out :
                O_READY     => fifo_outlet_ready     -- In  :  
            );
    end generate;
end RTL;
