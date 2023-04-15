-----------------------------------------------------------------------------------
--!     @file    asymmetric_mergesort_network.vhd
--!     @brief   Asymmetric MergeSort Network Package :
--!     @version 1.4.1
--!     @date    2022/10/20
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
package Asymmetric_MergeSort_Network is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  GROUP_NETS  :  integer := 1
    )             return         Sorting_Network.Param_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  GROUP_NETS  :  integer := 1;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  L_LO        :  integer;
                  L_HI        :  integer;
                  H_LO        :  integer;
                  H_HI        :  integer;
                  ORDER       :  integer
    )             return         Sorting_Network.Param_Type;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  L_LO        :  integer;
                  L_HI        :  integer;
                  H_LO        :  integer;
                  H_HI        :  integer;
                  ORDER       :  integer;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type;
end Asymmetric_MergeSort_Network;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Sorting_Network;
use     Merge_Sorter.OddEven_MergeSort_Network;
package body Asymmetric_MergeSort_Network is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  align_by_power_of_2(I: integer) return integer is
        variable n : integer;
    begin
        n := 0;
        while (2**n < I) loop
            n := n + 1;
        end loop;
        return 2**n;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  max(L,R: integer) return integer is
    begin
        if (L < R) then return R;
        else            return L;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  min(L,R: integer) return integer is
    begin
        if (L > R) then return R;
        else            return L;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure asymmetric_merge(
        variable  NETWORK     :  inout Sorting_Network.Param_Type;
                  START_STAGE :  in    integer;
                  L_LO        :  in    integer;
                  L_HI        :  in    integer;
                  H_LO        :  in    integer;
                  H_HI        :  in    integer;
        constant  HALF_SIZE   :  in    integer
    ) is
        type      NET_VALID_VECTOR   is array(0 to 2*HALF_SIZE-1) of integer;
        variable  curr_net_list      :  NET_VALID_VECTOR;
        variable  next_net_list      :  NET_VALID_VECTOR;
        variable  merge_network      :  Sorting_Network.Param_Type;
        variable  operator           :  Sorting_Network.Operator_Type;
        variable  l_size             :  integer;
        variable  h_size             :  integer;
        variable  op_lo_net          :  integer;
        variable  op_hi_net          :  integer;
        variable  comp_lo_net        :  integer;
        variable  comp_hi_net        :  integer;
        variable  step               :  integer;
        variable  curr_stage         :  integer;
        variable  last_stage         :  integer;
    begin
        ---------------------------------------------------------------------------
        -- merge_network
        ---------------------------------------------------------------------------
        merge_network := OddEven_MergeSort_Network.New_Merge_Network(0, 2*HALF_SIZE-1, 0);
        ---------------------------------------------------------------------------
        -- curr_net_list initialize
        ---------------------------------------------------------------------------
        l_size := L_HI - L_LO + 1;
        h_size := H_HI - H_LO + 1;
        for i in 0 to HALF_SIZE-1 loop
            if (i < l_size) then
                curr_net_list(i) := i + L_LO;
            else
                curr_net_list(i) := -1;
            end if;
        end loop;
        for i in 0 to HALF_SIZE-1 loop
            if (i < h_size) then
                curr_net_list(i+HALF_SIZE) := i + H_LO;
            else
                curr_net_list(i+HALF_SIZE) := -1;
            end if;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        curr_stage := START_STAGE;
        last_stage := NETWORK.Stage_Hi;
        for stage in merge_network.Stage_Lo to merge_network.Stage_Hi loop
            for net in merge_network.Lo to merge_network.Hi loop
                operator  := merge_network.Stage_List(stage).Operator_List(net);
                step      := operator.STEP;
                op_lo_net := curr_net_list(net     );
                op_hi_net := curr_net_list(net+step);
                if (Sorting_Network.Operator_Is_Comp(operator)) then
                    if (step > 0) then
                        if    (op_lo_net >= 0 and op_hi_net >= 0) then
                            if (op_lo_net < op_hi_net) then
                                comp_lo_net := op_lo_net;
                                comp_hi_net := op_hi_net;
                            else
                                comp_lo_net := op_hi_net;
                                comp_hi_net := op_lo_net;
                            end if;
                            Sorting_Network.Add_Comparator(
                                NETWORK => NETWORK    ,
                                STAGE   => curr_stage ,
                                LO      => comp_lo_net,
                                HI      => comp_hi_net,
                                UP      => TRUE
                            );
                            next_net_list(net     ) := comp_lo_net;
                            next_net_list(net+step) := comp_hi_net;
                        elsif (op_lo_net >= 0 and op_hi_net <  0) then
                            next_net_list(net     ) := op_lo_net;
                            next_net_list(net+step) := -1;
                        elsif (op_hi_net >= 0 and op_lo_net <  0) then
                            next_net_list(net     ) := op_hi_net;
                            next_net_list(net+step) := -1;
                        else
                            next_net_list(net     ) := -1;
                            next_net_list(net+step) := -1;
                        end if;
                    elsif (step = 0) then
                        if (op_lo_net >= 0) then
                            next_net_list(net     ) := op_lo_net;
                        else
                            next_net_list(net     ) := -1;
                        end if;
                    end if;
                elsif (Sorting_Network.Operator_Is_Pass(operator)) then
                        if (op_lo_net >= 0 and op_hi_net >= 0) then
                            Sorting_Network.Add_Pass_Operator(
                                NETWORK => NETWORK   ,
                                STAGE   => curr_stage,
                                DST     => op_lo_net ,
                                SRC     => op_hi_net
                            );
                            next_net_list(net) := op_lo_net;
                        elsif (op_lo_net >= 0 and op_hi_net <  0) then
                            next_net_list(net) := op_lo_net;
                        else
                            next_net_list(net) := -1;
                        end if;
                else
                        if (op_lo_net >= 0) then
                            next_net_list(net) := op_lo_net;
                        else
                            next_net_list(net) := -1;
                        end if;
                end if;
            end loop;
            curr_net_list := next_net_list;
            last_stage    := curr_stage;
            curr_stage    := curr_stage + 1;
        end loop;
        if (last_stage > NETWORK.Stage_Hi) then
            NETWORK.Stage_Hi := last_stage;
        end if;
        NETWORK.Stage_Size := NETWORK.Stage_Hi - NETWORK.Stage_Lo + 1;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure asymmetric_merge(
        variable  NETWORK     :  inout Sorting_Network.Param_Type;
                  START_STAGE :  in    integer;
                  L_LO        :  in    integer;
                  L_HI        :  in    integer;
                  H_LO        :  in    integer;
                  H_HI        :  in    integer
    ) is
        variable  half_size   :        integer;
    begin
        half_size := max(align_by_power_of_2(L_HI-L_LO+1), 
                         align_by_power_of_2(H_HI-H_LO+1));
        asymmetric_merge(NETWORK, START_STAGE, L_LO, L_HI, H_LO, H_HI, half_size);
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure asymmetric_sort(
        variable  NETWORK     :  inout Sorting_Network.Param_Type;
                  START_STAGE :  in    integer;
                  LO          :  in    integer;
                  HI          :  in    integer;
                  GROUP_NETS  :  in    integer
    ) is
        variable  net_size    :        integer;
        variable  group_count :        integer;
        variable  l_network   :        Sorting_Network.Param_Type;
        variable  l_lo        :        integer;
        variable  l_hi        :        integer;
        variable  h_network   :        Sorting_Network.Param_Type;
        variable  h_lo        :        integer;
        variable  h_hi        :        integer;
        variable  next_stage  :        integer;
    begin
        net_size := HI - LO + 1;
        assert (net_size mod GROUP_NETS = 0)
            report "asymmetric_sort error" severity ERROR;
        group_count := net_size / GROUP_NETS;
        if (group_count > 1) then
            l_lo := LO;
            l_hi := LO + GROUP_NETS*(group_count/2) - 1;
            h_lo := l_hi + 1;
            h_hi := HI;
            l_network := Sorting_Network.New_Network(l_lo, l_hi, START_STAGE, NETWORK.Sort_Order);
            h_network := Sorting_Network.New_Network(h_lo, h_hi, START_STAGE, NETWORK.Sort_Order);
            asymmetric_sort(l_network, START_STAGE, l_lo, l_hi, GROUP_NETS);
            asymmetric_sort(h_network, START_STAGE, h_lo, h_hi, GROUP_NETS);
            Sorting_Network.Merge_Network(NETWORK, l_network);
            Sorting_Network.Merge_Network(NETWORK, h_network);
            next_stage := NETWORK.Stage_Hi + 1;
            asymmetric_merge(NETWORK, next_stage, l_lo, l_hi, h_lo, h_hi);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  GROUP_NETS  :  integer := 1
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := Sorting_Network.New_Network(LO, HI, ORDER);
        asymmetric_sort(network, network.Stage_Lo, LO, HI, GROUP_NETS);
        return network;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Network(
                  LO          :  integer;
                  HI          :  integer;
                  ORDER       :  integer;
                  GROUP_NETS  :  integer := 1;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := New_Network(LO, HI, ORDER, GROUP_NETS);
        Sorting_Network.Set_Queue_Param(network, QUEUE);
        return network;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  L_LO        :  integer;
                  L_HI        :  integer;
                  H_LO        :  integer;
                  H_HI        :  integer;
                  ORDER       :  integer
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
        variable  net_lo      :  integer;
        variable  net_hi      :  integer;
    begin
        net_lo  := min(L_LO, H_LO);
        net_hi  := max(L_HI, H_HI);
        network := Sorting_Network.New_Network(net_lo, net_hi, ORDER);
        asymmetric_merge(network, network.Stage_Lo, L_LO, L_HI, H_LO, H_HI);
        return network;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function   New_Merge_Network(
                  L_LO        :  integer;
                  L_HI        :  integer;
                  H_LO        :  integer;
                  H_HI        :  integer;
                  ORDER       :  integer;
                  QUEUE       :  Sorting_Network.Queue_Param_Type
    )             return         Sorting_Network.Param_Type
    is
        variable  network     :  Sorting_Network.Param_Type;
    begin
        network := New_Merge_Network(L_LO, L_HI, H_LO, H_HI, ORDER);
        Sorting_Network.Set_Queue_Param(network, QUEUE);
        return network;
    end function;
end Asymmetric_MergeSort_Network;
