-----------------------------------------------------------------------------------
--!     @file    bubble_sort_network.vhd
--!     @brief   Bubble Sort Network Package :
--!     @version 1.4.1
--!     @date    2022/11/1
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2020-2022 Ichiro Kawazome
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
library Merge_Sorter;
use     Merge_Sorter.Sorting_Network;
package Bubble_Sort_Network is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer
    )             return         Sorting_Network.Param_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type;
end Bubble_Sort_Network;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Sorting_Network;
package body Bubble_Sort_Network is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure bubble_sort(
        variable  NETWORK     :  inout Sorting_Network.Param_Type;
                  START_STAGE :  in    integer;
                  LO          :  in    integer;
                  HI          :  in    integer
    ) is
        variable  comp_stage  :        integer;
        variable  last_stage  :        integer;
    begin
        if (HI - LO > 0) then
            comp_stage := START_STAGE;
            for net in HI-1 downto LO loop
                Sorting_Network.Add_Comparator(NETWORK, comp_stage, net, net+1, TRUE);
                if (NETWORK.Stage_Hi <  comp_stage) then
                    NETWORK.Stage_Hi := comp_stage;
                end if;
                comp_stage := comp_stage + 1;
            end loop;
            NETWORK.Stage_Size := NETWORK.Stage_Hi - NETWORK.Stage_Lo + 1;
            bubble_sort(NETWORK, START_STAGE + 2, LO + 1, HI);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := Sorting_Network.New_Network(LO,HI,ORDER);
        bubble_sort(network, network.Stage_Lo, network.Lo, network.Hi);
        return network;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := New_Network(LO,HI,ORDER);
        Sorting_Network.Set_Queue_Param(network, QUEUE);
        return network;
    end function;
end Bubble_Sort_Network;
