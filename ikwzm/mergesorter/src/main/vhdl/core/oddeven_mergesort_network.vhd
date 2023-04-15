-----------------------------------------------------------------------------------
--!     @file    oddeven_mergesort_network.vhd
--!     @brief   Batcher's Odd-Even MergeSort Network Package :
--!     @version 1.4.1
--!     @date    2022/10/29
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
package OddEven_MergeSort_Network is
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
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer
    )             return         Sorting_Network.Param_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type;
end OddEven_MergeSort_Network;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Sorting_Network;
package body OddEven_MergeSort_Network is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure oddeven_merge(
        variable  NETWORK     :  inout Sorting_Network.Param_Type;
                  START_STAGE :  in    integer;
                  LO          :  in    integer;
                  HI          :  in    integer;
                  R           :  in    integer
    ) is
        variable  step        :        integer;
        variable  index       :        integer;
    begin
        step := R * 2;
        if (HI - LO > step) then
            oddeven_merge(NETWORK, START_STAGE + 1, LO    , HI, step);
            oddeven_merge(NETWORK, START_STAGE + 1, LO + R, HI, step);
            index  := LO + R;
            while (index <= HI - R) loop
                Sorting_Network.Add_Comparator(NETWORK, START_STAGE, index, index + R, TRUE);
                index := index + step;
            end loop;
        else
            Sorting_Network.Add_Comparator(NETWORK, START_STAGE, LO, LO + R, TRUE);
        end if;
        if (START_STAGE > NETWORK.Stage_Hi) then
            NETWORK.Stage_Hi   := START_STAGE;
            NETWORK.Stage_Size := NETWORK.Stage_Hi - NETWORK.Stage_Lo + 1;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure oddeven_sort(
        variable  NETWORK     :  inout Sorting_Network.Param_Type;
                  START_STAGE :  in    integer;
                  LO          :  in    integer;
                  HI          :  in    integer
    ) is
        variable  mid         :        integer;
    begin
        if (HI - LO > 0) then
            mid := LO + ((HI - LO) / 2);
            oddeven_merge(NETWORK, START_STAGE         , LO   , HI , 1);
            oddeven_sort (NETWORK, NETWORK.Stage_HI + 1, LO   , mid   );
            oddeven_sort (NETWORK, NETWORK.Stage_HI + 1, mid+1, HI    );
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
        oddeven_sort(network, network.Stage_Lo, network.Lo, network.Hi);
        Sorting_Network.Reverse_Network_Stage(network);
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
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := Sorting_Network.New_Network(LO,HI,ORDER);
        oddeven_merge(network, network.Stage_Lo, network.Lo, network.Hi, 1);
        Sorting_Network.Reverse_Network_Stage(network);
        return network;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := New_Merge_Network(LO,HI,ORDER);
        Sorting_Network.Set_Queue_Param(network, QUEUE);
        return network;
    end function;
end OddEven_MergeSort_Network;
