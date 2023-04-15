-----------------------------------------------------------------------------------
--!     @file    word_compare.vhd
--!     @brief   Merge Sorter Word Compare Module :
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
entity  Word_Compare is
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        SORT_ORDER  :  integer :=  0
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        A_WORD      :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0);
        B_WORD      :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0);
        VALID       :  in  std_logic;
        READY       :  out std_logic;
        SEL_A       :  out std_logic;
        SEL_B       :  out std_logic
    );
end Word_Compare;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of Word_Compare is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function select_a_unsigned(A_WORD, B_WORD: std_logic_vector;ORDER: integer) return boolean is
        variable a_comp  :  unsigned(WORD_PARAM.DATA_COMPARE_HI - WORD_PARAM.DATA_COMPARE_LO downto 0);
        variable b_comp  :  unsigned(WORD_PARAM.DATA_COMPARE_HI - WORD_PARAM.DATA_COMPARE_LO downto 0);
    begin
        a_comp := to_01(unsigned(A_WORD(WORD_PARAM.DATA_COMPARE_HI downto WORD_PARAM.DATA_COMPARE_LO)));
        b_comp := to_01(unsigned(B_WORD(WORD_PARAM.DATA_COMPARE_HI downto WORD_PARAM.DATA_COMPARE_LO)));
        if (ORDER = 0) then
            return (a_comp <= b_comp);
        else
            return (a_comp >= b_comp);
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function select_a_signed(A_WORD, B_WORD: std_logic_vector;ORDER: integer) return boolean is
        variable a_comp  :    signed(WORD_PARAM.DATA_COMPARE_HI - WORD_PARAM.DATA_COMPARE_LO downto 0);
        variable b_comp  :    signed(WORD_PARAM.DATA_COMPARE_HI - WORD_PARAM.DATA_COMPARE_LO downto 0);
    begin
        a_comp := to_01(  signed(A_WORD(WORD_PARAM.DATA_COMPARE_HI downto WORD_PARAM.DATA_COMPARE_LO)));
        b_comp := to_01(  signed(B_WORD(WORD_PARAM.DATA_COMPARE_HI downto WORD_PARAM.DATA_COMPARE_LO)));
        if (ORDER = 0) then
            return (a_comp <= b_comp);
        else
            return (a_comp >= b_comp);
        end if;
    end function;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(VALID, A_WORD, B_WORD) 
        variable select_a :  boolean;
    begin
        if (VALID = '1') then
            if (WORD_PARAM.DATA_COMPARE_SIGN) then
                select_a := select_a_signed  (A_WORD, B_WORD, SORT_ORDER);
            else
                select_a := select_a_unsigned(A_WORD, B_WORD, SORT_ORDER);
            end if;
            if    (A_WORD(WORD_PARAM.ATRB_PRIORITY_POS) = '1') or
                  (B_WORD(WORD_PARAM.ATRB_POSTPEND_POS) = '1') then
                SEL_A <= '1';
                SEL_B <= '0';
            elsif (B_WORD(WORD_PARAM.ATRB_PRIORITY_POS) = '1') or
                  (A_WORD(WORD_PARAM.ATRB_POSTPEND_POS) = '1') then
                SEL_A <= '0';
                SEL_B <= '1';
            elsif (select_a = TRUE) then
                SEL_A <= '1';
                SEL_B <= '0';
            else
                SEL_A <= '0';
                SEL_B <= '1';
            end if;
                READY <= '1';
        else
                READY <= '0';
                SEL_A <= '0';
                SEL_B <= '0';
        end if;
    end process;
end RTL;

