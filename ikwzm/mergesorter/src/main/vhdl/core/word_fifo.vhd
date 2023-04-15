-----------------------------------------------------------------------------------
--!     @file    word_fifo.vhd
--!     @brief   Merge Sorter Word FIFO Module :
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
entity  Word_Fifo is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=   1;
        INFO_BITS   :  integer :=   1;
        FIFO_SIZE   :  integer :=  16;
        LEVEL_SIZE  :  integer :=  15
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_ENABLE    :  in  std_logic := '1';
        I_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(INFO_BITS            -1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic := '0';
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        I_LEVEL     :  out std_logic;
        O_ENABLE    :  in  std_logic := '1';
        O_WORD      :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(INFO_BITS            -1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end Word_Fifo;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
architecture RTL of Word_Fifo is
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    function  NUM_TO_BITS(NUM:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**value <= NUM) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    constant  COUNT_BITS        :  integer := NUM_TO_BITS(FIFO_SIZE  );
    constant  PTR_BITS          :  integer := NUM_TO_BITS(FIFO_SIZE-1);
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    constant  DATA_WORD_BITS    :  integer := WORDS*WORD_PARAM.BITS;
    constant  DATA_WORD_LO_POS  :  integer := 0;
    constant  DATA_WORD_HI_POS  :  integer := DATA_WORD_LO_POS + DATA_WORD_BITS - 1;
    constant  DATA_INFO_LO_POS  :  integer := DATA_WORD_HI_POS + 1;
    constant  DATA_INFO_HI_POS  :  integer := DATA_INFO_LO_POS + INFO_BITS      - 1;
    constant  DATA_LAST_POS     :  integer := DATA_INFO_HI_POS + 1;
    constant  DATA_LO_POS       :  integer := DATA_WORD_LO_POS;
    constant  DATA_HI_POS       :  integer := DATA_LAST_POS;
    constant  DATA_BITS         :  integer := DATA_HI_POS - DATA_LO_POS + 1;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    type      MEM_TYPE          is array (integer range <>) of std_logic_vector(DATA_BITS-1 downto 0);
    signal    mem               :  MEM_TYPE(FIFO_SIZE -1 downto 0);
    signal    wr_ptr            :  unsigned(PTR_BITS  -1 downto 0);
    signal    rd_ptr            :  unsigned(PTR_BITS  -1 downto 0);
    signal    wr_addr           :  unsigned(PTR_BITS  -1 downto 0);
    signal    rd_addr           :  unsigned(PTR_BITS  -1 downto 0);
    signal    wr_ena_i          :  std_logic;
    signal    wr_ena_q          :  std_logic;
    signal    rd_ena_i          :  std_logic;
    signal    rd_ena_q          :  std_logic;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    signal    intake_counter    :  unsigned(COUNT_BITS-1 downto 0);
    signal    intake_data       :  std_logic_vector(DATA_HI_POS downto DATA_LO_POS);
    signal    intake_valid      :  std_logic;
    signal    intake_level      :  std_logic;
    signal    intake_ready      :  std_logic;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    signal    outlet_counter    :  unsigned(COUNT_BITS-1 downto 0);
    signal    outlet_data       :  std_logic_vector(DATA_HI_POS downto DATA_LO_POS);
    signal    outlet_valid      :  std_logic;
    signal    outlet_ready      :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    intake_data(DATA_WORD_HI_POS downto DATA_WORD_LO_POS) <= I_WORD;
    intake_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS) <= I_INFO;
    intake_data(DATA_LAST_POS                           ) <= I_LAST;
    intake_valid <= I_VALID;
    I_READY      <= intake_ready;
    I_LEVEL      <= intake_level;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    wr_ena_i <= '1' when (I_ENABLE = '1' and intake_valid = '1' and intake_ready = '1') else '0';
    rd_ena_i <= '1' when (O_ENABLE = '1' and outlet_valid = '1' and outlet_ready = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_counter : unsigned(COUNT_BITS downto 0);
    begin
        if (RST = '1') then
                intake_counter <= (others => '0');
                intake_ready   <= '0';
                intake_level   <= '0';
                wr_ena_q       <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                intake_counter <= (others => '0');
                intake_ready   <= '0';
                intake_level   <= '0';
                wr_ena_q       <= '0';
            else
                next_counter := "0" & intake_counter;
                if (wr_ena_i = '1') then
                    next_counter := next_counter + 1;
                end if;
                if (rd_ena_q = '1') then
                    next_counter := next_counter - 1;
                end if;
                if (next_counter < FIFO_SIZE) then
                    intake_ready <= '1';
                else
                    intake_ready <= '0';
                end if;
                if (next_counter >= LEVEL_SIZE) then
                    intake_level <= '1';
                else
                    intake_level <= '0';
                end if;
                intake_counter <= next_counter(intake_counter'range);
                wr_ena_q       <= wr_ena_i;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_counter : unsigned(COUNT_BITS downto 0);
    begin
        if (RST = '1') then
                outlet_counter <= (others => '0');
                outlet_valid   <= '0';
                rd_ena_q       <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                outlet_counter <= (others => '0');
                outlet_valid   <= '0';
                rd_ena_q       <= '0';
            else
                next_counter := "0" & outlet_counter;
                if (wr_ena_q = '1') then
                    next_counter := next_counter + 1;
                end if;
                if (rd_ena_i = '1') then
                    next_counter := next_counter - 1;
                end if;
                if (next_counter > 0) then
                    outlet_valid <= '1';
                else
                    outlet_valid <= '0';
                end if;
                outlet_counter <= next_counter(outlet_counter'range);
                rd_ena_q       <= rd_ena_i;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                wr_ptr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                wr_ptr <= (others => '0');
            elsif (wr_ena_i = '1') then
                wr_ptr <= wr_ptr + 1;
            end if;
        end if;
    end process;
    wr_addr <= wr_ptr;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                rd_ptr <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                rd_ptr <= (others => '0');
            else
                rd_ptr <= rd_addr;
            end if;
        end if;
    end process;
    rd_addr <= rd_ptr + 1 when (rd_ena_i = '1') else rd_ptr;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK) begin
        if (CLK'event and CLK = '1') then
            if (wr_ena_i = '1') then
                mem(to_integer(to_01(wr_addr))) <= intake_data;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK) begin
        if (CLK'event and CLK = '1') then
            outlet_data <= mem(to_integer(to_01(rd_addr)));
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_WORD  <= outlet_data(DATA_WORD_HI_POS downto DATA_WORD_LO_POS);
    O_INFO  <= outlet_data(DATA_INFO_HI_POS downto DATA_INFO_LO_POS);
    O_LAST  <= outlet_data(DATA_LAST_POS);
    O_VALID <= outlet_valid;
    outlet_ready <= O_READY;
end RTL;
