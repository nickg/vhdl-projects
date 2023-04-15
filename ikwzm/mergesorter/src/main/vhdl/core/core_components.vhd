-----------------------------------------------------------------------------------
--!     @file    core_components.vhd                                             --
--!     @brief   Merge Sorter Core Component Library Description Package         --
--!     @version 1.4.1                                                           --
--!     @date    2022/11/02                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2022 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
use     Merge_Sorter.Sorting_Network;
-----------------------------------------------------------------------------------
--! @brief Merge Sorter Core Component Library Description Package               --
-----------------------------------------------------------------------------------
package Core_Components is
-----------------------------------------------------------------------------------
--! @brief Merge_Sorter_Core                                                     --
-----------------------------------------------------------------------------------
component Merge_Sorter_Core
    generic (
        MRG_IN_ENABLE   :  boolean := TRUE;
        MRG_WAYS        :  integer :=    8;
        MRG_WORDS       :  integer :=    1;
        MRG_FIFO_SIZE   :  integer :=  128;
        MRG_LEVEL_SIZE  :  integer :=   64;
        STM_IN_ENABLE   :  boolean := TRUE;
        STM_IN_QUEUE    :  integer :=    0;
        STM_WORDS       :  integer :=    1;
        STM_FEEDBACK    :  integer :=    1;
        SORT_ORDER      :  integer :=    0;
        DATA_BITS       :  integer :=   64;
        COMP_HIGH       :  integer :=   63;
        COMP_LOW        :  integer :=    0;
        COMP_SIGN       :  boolean := FALSE
    );
    port (
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
        STM_REQ_VALID   :  in  std_logic;
        STM_REQ_READY   :  out std_logic;
        STM_RES_VALID   :  out std_logic;
        STM_RES_READY   :  in  std_logic;
        STM_IN_DATA     :  in  std_logic_vector(         STM_WORDS*DATA_BITS-1 downto 0);
        STM_IN_STRB     :  in  std_logic_vector(         STM_WORDS          -1 downto 0);
        STM_IN_LAST     :  in  std_logic;
        STM_IN_VALID    :  in  std_logic;
        STM_IN_READY    :  out std_logic;
        MRG_REQ_VALID   :  in  std_logic;
        MRG_REQ_READY   :  out std_logic;
        MRG_RES_VALID   :  out std_logic;
        MRG_RES_READY   :  in  std_logic;
        MRG_IN_DATA     :  in  std_logic_vector(MRG_WAYS*MRG_WORDS*DATA_BITS-1 downto 0);
        MRG_IN_NONE     :  in  std_logic_vector(MRG_WAYS*MRG_WORDS          -1 downto 0);
        MRG_IN_EBLK     :  in  std_logic_vector(MRG_WAYS                    -1 downto 0);
        MRG_IN_LAST     :  in  std_logic_vector(MRG_WAYS                    -1 downto 0);
        MRG_IN_VALID    :  in  std_logic_vector(MRG_WAYS                    -1 downto 0);
        MRG_IN_READY    :  out std_logic_vector(MRG_WAYS                    -1 downto 0);
        MRG_IN_LEVEL    :  out std_logic_vector(MRG_WAYS                    -1 downto 0);
        OUT_DATA        :  out std_logic_vector(         MRG_WORDS*DATA_BITS-1 downto 0);
        OUT_STRB        :  out std_logic_vector(         MRG_WORDS          -1 downto 0);
        OUT_LAST        :  out std_logic;
        OUT_VALID       :  out std_logic;
        OUT_READY       :  in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Merge_Sorter_Node                                                     --
-----------------------------------------------------------------------------------
component Merge_Sorter_Node
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
end component;
-----------------------------------------------------------------------------------
--! @brief Merge_Sorter_Tree                                                     --
-----------------------------------------------------------------------------------
component Merge_Sorter_Tree
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
-----------------------------------------------------------------------------------
--! @brief Core_Intake_Fifo                                                      --
-----------------------------------------------------------------------------------
component Core_Intake_Fifo
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
end component;
-----------------------------------------------------------------------------------
--! @brief Core_Stream_Intake                                                    --
-----------------------------------------------------------------------------------
component Core_Stream_Intake
    generic (
        WORD_PARAM      :  Word.Param_Type := Word.Default_Param;
        MRG_WAYS        :  integer :=  8;
        MRG_WORDS       :  integer :=  1;
        STM_WORDS       :  integer :=  1;
        FEEDBACK        :  integer :=  1;
        SORT_ORDER      :  integer :=  0;
        MRG_WAYS_BITS   :  integer :=  3;
        SIZE_BITS       :  integer :=  6;
        INFO_BITS       :  integer :=  8;
        INFO_EBLK_POS   :  integer :=  0;
        INFO_FBK_POS    :  integer :=  1;
        INFO_FBK_NUM_LO :  integer :=  2;
        INFO_FBK_NUM_HI :  integer :=  7;
        QUEUE_SIZE      :  integer :=  0
    );
    port (
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
        START           :  in  std_logic;
        BUSY            :  out std_logic;
        DONE            :  out std_logic;
        FBK_OUT_START   :  out std_logic;
        FBK_OUT_SIZE    :  out std_logic_vector(SIZE_BITS                         -1 downto 0);
        FBK_OUT_LAST    :  out std_logic;
        I_DATA          :  in  std_logic_vector(STM_WORDS*    WORD_PARAM.DATA_BITS-1 downto 0);
        I_STRB          :  in  std_logic_vector(STM_WORDS                         -1 downto 0);
        I_LAST          :  in  std_logic;
        I_VALID         :  in  std_logic;
        I_READY         :  out std_logic;
        O_WORD          :  out std_logic_vector(MRG_WAYS*MRG_WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO          :  out std_logic_vector(MRG_WAYS*                INFO_BITS-1 downto 0);
        O_LAST          :  out std_logic_vector(MRG_WAYS                          -1 downto 0);
        O_VALID         :  out std_logic_vector(MRG_WAYS                          -1 downto 0);
        O_READY         :  in  std_logic_vector(MRG_WAYS                          -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Sorting_Network_Core                                                  --
-----------------------------------------------------------------------------------
component Sorting_Network_Core
    generic (
        NETWORK_PARAM   :  Sorting_Network.Param_Type := Sorting_Network.Param_Null;
        WORD_PARAM      :  Word.Param_Type            := Word.Default_Param;
        INFO_BITS       :  integer :=  3
    );
    port (
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
        I_WORD          :  in  std_logic_vector(NETWORK_PARAM.Size*WORD_PARAM.BITS-1 downto 0);
        I_INFO          :  in  std_logic_vector(INFO_BITS-1 downto 0) := (others => '0');
        I_VALID         :  in  std_logic;
        I_READY         :  out std_logic;
        O_WORD          :  out std_logic_vector(NETWORK_PARAM.Size*WORD_PARAM.BITS-1 downto 0);
        O_INFO          :  out std_logic_vector(INFO_BITS-1 downto 0);
        O_VALID         :  out std_logic;
        O_READY         :  in  std_logic;
        BUSY            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Word_Compare                                                          --
-----------------------------------------------------------------------------------
component Word_Compare
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
end component;
-----------------------------------------------------------------------------------
--! @brief Word_Fifo                                                             --
-----------------------------------------------------------------------------------
component Word_Fifo
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
end component;
-----------------------------------------------------------------------------------
--! @brief Word_Queue                                                            --
-----------------------------------------------------------------------------------
component Word_Queue
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        INFO_BITS   :  integer :=  1;
        QUEUE_SIZE  :  integer :=  2
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(INFO_BITS            -1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic := '0';
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(INFO_BITS            -1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Word_Reducer                                                          --
-----------------------------------------------------------------------------------
component Word_Reducer
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        I_WORDS     :  integer :=  1;
        O_WORDS     :  integer :=  1;
        INFO_BITS   :  integer :=  1;
        QUEUE_SIZE  :  integer :=  0;
        VALID_MIN   :  integer :=  0;
        VALID_MAX   :  integer :=  0;
        O_VAL_SIZE  :  integer :=  0;
        O_SHIFT_MIN :  integer :=  1;
        O_SHIFT_MAX :  integer :=  1;
        NO_VAL_SET  :  integer :=  1;
        I_JUSTIFIED :  integer range 0 to 1 := 0;
        FLUSH_ENABLE:  integer range 0 to 1 := 0
    );
    port (
        CLK         :  in  std_logic; 
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        START       :  in  std_logic := '0';
        OFFSET      :  in  std_logic_vector(O_WORDS        -1 downto 0) := (others => '0');
        DONE        :  in  std_logic := '0';
        FLUSH       :  in  std_logic := '0';
        START_WORD  :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0) := (others => '0');
        START_INFO  :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        FLUSH_WORD  :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0) := (others => '0');
        FLUSH_INFO  :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        NO_VAL_WORD :  in  std_logic_vector(WORD_PARAM.BITS-1 downto 0) := (others => '0');
        NO_VAL_INFO :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        BUSY        :  out std_logic;
        VALID       :  out std_logic_vector(VALID_MAX downto VALID_MIN);
        I_ENABLE    :  in  std_logic := '1';
        I_WORD      :  in  std_logic_vector(I_WORDS*WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(INFO_BITS      -1 downto 0) := (others => '0');
        I_STRB      :  in  std_logic_vector(I_WORDS        -1 downto 0);
        I_DONE      :  in  std_logic := '0';
        I_FLUSH     :  in  std_logic := '0';
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_ENABLE    :  in  std_logic := '1';
        O_WORD      :  out std_logic_vector(O_WORDS*WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(INFO_BITS      -1 downto 0);
        O_STRB      :  out std_logic_vector(O_WORDS        -1 downto 0);
        O_DONE      :  out std_logic;
        O_FLUSH     :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic;
        O_SHIFT     :  in  std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN) := (others => '0')
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Word_Pipeline_Register                                                --
-----------------------------------------------------------------------------------
component Word_Pipeline_Register
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        WORDS       :  integer :=  1;
        INFO_BITS   :  integer :=  1;
        QUEUE_SIZE  :  integer :=  2
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_WORD      :  in  std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(INFO_BITS            -1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic := '0';
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(WORDS*WORD_PARAM.BITS-1 downto 0);
        O_INFO      :  out std_logic_vector(INFO_BITS            -1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic;
        VALID       :  out std_logic_vector(QUEUE_SIZE downto 0);
        BUSY        :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Word_Drop_None                                                        --
-----------------------------------------------------------------------------------
component Word_Drop_None
    generic (
        WORD_PARAM  :  Word.Param_Type := Word.Default_Param;
        I_WORDS     :  integer :=  1;
        O_WORDS     :  integer :=  1;
        INFO_BITS   :  integer :=  1
    );
    port (
        CLK         :  in  std_logic;
        RST         :  in  std_logic;
        CLR         :  in  std_logic;
        I_WORD      :  in  std_logic_vector(I_WORDS*WORD_PARAM.BITS-1 downto 0);
        I_INFO      :  in  std_logic_vector(              INFO_BITS-1 downto 0) := (others => '0');
        I_LAST      :  in  std_logic;
        I_VALID     :  in  std_logic;
        I_READY     :  out std_logic;
        O_WORD      :  out std_logic_vector(O_WORDS*WORD_PARAM.BITS-1 downto 0);
        O_STRB      :  out std_logic_vector(O_WORDS                -1 downto 0);
        O_INFO      :  out std_logic_vector(              INFO_BITS-1 downto 0);
        O_LAST      :  out std_logic;
        O_VALID     :  out std_logic;
        O_READY     :  in  std_logic
    );
end component;
end Core_Components;
