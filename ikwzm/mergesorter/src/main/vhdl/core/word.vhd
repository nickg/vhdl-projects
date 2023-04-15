-----------------------------------------------------------------------------------
--!     @file    word.vhd
--!     @brief   Merge Sorter Word Package :
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
use     ieee.numeric_std.all;
package Word is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  ATRB_NONE_POS         :  integer := 0;
    constant  ATRB_PRIORITY_POS     :  integer := 1;
    constant  ATRB_POSTPEND_POS     :  integer := 2;
    constant  ATRB_BITS             :  integer := 3;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      Param_Type       is record
                  BITS              :  integer;
                  DATA_BITS         :  integer;
                  DATA_LO           :  integer;
                  DATA_HI           :  integer;
                  DATA_COMPARE_LO   :  integer;
                  DATA_COMPARE_HI   :  integer;
                  DATA_COMPARE_SIGN :  boolean;
                  ATRB_BITS         :  integer;
                  ATRB_LO           :  integer;
                  ATRB_HI           :  integer;
                  ATRB_NONE_POS     :  integer;
                  ATRB_PRIORITY_POS :  integer;
                  ATRB_POSTPEND_POS :  integer;
    end record;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Param(
                  DATA_BITS         :  integer;
                  COMP_LO           :  integer;
                  COMP_HI           :  integer;
                  SIGN              :  boolean
              )   return               Param_Type;
    function  New_Param(
                  DATA_BITS         :  integer;
                  COMP_LO           :  integer;
                  COMP_HI           :  integer
              )   return               Param_Type;
    function  New_Param(
                  DATA_BITS         :  integer;
                  SIGN              :  boolean
              )   return               Param_Type;
    function  New_Param(
                  DATA_BITS         :  integer
              )   return               Param_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  Default_Param        :  Param_Type := New_Param(DATA_BITS => 8,SIGN => FALSE);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector;
                  PRIORITY         :  std_logic;
                  POSTPEND         :  std_logic;
                  NONE             :  std_logic
              )   return              std_logic_vector;
    function  New_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector
              )   return              std_logic_vector;
    function  New_Postpend_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector := "0";
                  NONE             :  std_logic        := '1'
              )   return              std_logic_vector;
    function  New_Priority_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector := "0";
                  NONE             :  std_logic        := '1'
              )   return              std_logic_vector;
end Word;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
package body Word is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Param(
                  DATA_BITS         :  integer;
                  COMP_LO           :  integer;
                  COMP_HI           :  integer;
                  SIGN              :  boolean
              )   return               Param_Type
    is
        variable  pos               :  integer;
        variable  param             :  Param_Type;
    begin
        pos := 0;

        param.DATA_BITS             := DATA_BITS;
        param.DATA_LO               := pos;
        param.DATA_HI               := pos + DATA_BITS-1;
        param.DATA_COMPARE_LO       := COMP_LO;
        param.DATA_COMPARE_HI       := COMP_HI;
        param.DATA_COMPARE_SIGN     := SIGN;
        pos := pos + DATA_BITS;
        
        param.ATRB_BITS             := ATRB_BITS;
        param.ATRB_LO               := pos;
        param.ATRB_HI               := pos + ATRB_BITS-1;
        param.ATRB_NONE_POS         := pos + ATRB_NONE_POS;
        param.ATRB_PRIORITY_POS     := pos + ATRB_PRIORITY_POS;
        param.ATRB_POSTPEND_POS     := pos + ATRB_POSTPEND_POS;
        pos := pos + ATRB_BITS;

        param.BITS := pos;

        return param;
    end New_Param;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Param(
                  DATA_BITS         :  integer;
                  COMP_LO           :  integer;
                  COMP_HI           :  integer
              )   return               Param_Type
    is
    begin
        return New_Param(
                  DATA_BITS         => DATA_BITS  ,
                  COMP_LO           => COMP_LO    ,
                  COMP_HI           => COMP_HI    ,
                  SIGN              => FALSE
               );
    end New_Param;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Param(
                  DATA_BITS         :  integer;
                  SIGN              :  boolean
              )   return               Param_Type
    is
    begin
        return New_Param(
                  DATA_BITS         => DATA_BITS  ,
                  COMP_LO           => 0          ,
                  COMP_HI           => DATA_BITS-1,
                  SIGN              => SIGN
               );
    end New_Param;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Param(
                  DATA_BITS         :  integer
              )   return               Param_Type
    is
    begin
        return New_Param(
                  DATA_BITS         => DATA_BITS  ,
                  COMP_LO           => 0          ,
                  COMP_HI           => DATA_BITS-1,
                  SIGN              => FALSE
               );
    end New_Param;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  resize(I: std_logic_vector;LEN: integer) return std_logic_vector
    is
    begin
        return std_logic_vector(resize(unsigned(I), LEN));
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector;
                  PRIORITY         :  std_logic;
                  POSTPEND         :  std_logic;
                  NONE             :  std_logic
              )   return              std_logic_vector
    is
        variable  a_word           :  std_logic_vector(PARAM.BITS-1 downto 0);
    begin
        a_word := (others => '0');
        a_word(PARAM.DATA_HI downto PARAM.DATA_LO) := DATA;
        a_word(PARAM.ATRB_NONE_POS    ) := NONE;
        a_word(PARAM.ATRB_PRIORITY_POS) := PRIORITY;
        a_word(PARAM.ATRB_POSTPEND_POS) := POSTPEND;
        return a_word;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector
              )   return              std_logic_vector
    is
    begin
        return New_Word(PARAM    => PARAM,
                        DATA     => DATA ,
                        PRIORITY => '0'  ,
                        POSTPEND => '0'  ,
                        NONE     => '0'
               );
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Postpend_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector := "0";
                  NONE             :  std_logic        := '1'
              )   return              std_logic_vector
    is
    begin
        return New_Word(PARAM    => PARAM                       ,
                        DATA     => resize(DATA,PARAM.DATA_BITS),
                        PRIORITY => '0'                         ,
                        POSTPEND => '1'                         ,
                        NONE     => NONE
               );
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  New_Priority_Word(
                  PARAM            :  Param_Type;
                  DATA             :  std_logic_vector := "0";
                  NONE             :  std_logic        := '1'
              )   return              std_logic_vector
    is
    begin
        return New_Word(PARAM    => PARAM                       ,
                        DATA     => resize(DATA,PARAM.DATA_BITS),
                        PRIORITY => '1'                         ,
                        POSTPEND => '0'                         ,
                        NONE     => NONE
               );
    end function;

end Word;
