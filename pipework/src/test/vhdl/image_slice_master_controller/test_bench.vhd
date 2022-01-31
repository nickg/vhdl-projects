-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   IMAGE_SLICE_MASTER_CONTROLLER TEST BENCH :
--!              IMAGE_SLICE_MASTER_CONTROLLER を検証するためのテストベンチ.
--!     @version 1.8.0
--!     @date    2019/4/5
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
-- テストベンチのベースモデル(エンティティ宣言)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  TEST_BENCH is
    generic (
        SOURCE_SHAPE      :  IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE(
                                 ELEM_BITS => 8,
                                 C         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(8),
                                 X         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(10),
                                 Y         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(20)
                             );
        SLICE_SHAPE       :  IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE(
                                 ELEM_BITS => 8,
                                 C         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(8),
                                 X         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(10),
                                 Y         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(20)
                             );
        MAX_SLICE_C_POS   :  integer := 8;
        MAX_SLICE_X_POS   :  integer := 10;
        MAX_SLICE_Y_POS   :  integer := 12;
        FINISH_ABORT      :  boolean := FALSE
    );
    port (
        FINISH            : out std_logic
    );
end    TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_SLICE_MASTER_CONTROLLER;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.all;
architecture MODEL of TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    := 10 ns;
    constant  DELAY             :  time    :=  1 ns;
    constant  ADDR_BITS         :  integer := 32;
    constant  SIZE_BITS         :  integer := 32;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    CLK               :  std_logic;
    signal    RST               :  std_logic;
    signal    CLR               :  std_logic;
    signal    CLK_ENA           :  boolean;
    signal    MISMATCH          :  boolean;
    signal    SCENARIO          :  STRING(1 to 5);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    SOURCE_C_SIZE     :  integer range 1 to SOURCE_SHAPE.C.MAX_SIZE := SOURCE_SHAPE.C.SIZE;
    signal    SOURCE_X_SIZE     :  integer range 1 to SOURCE_SHAPE.X.MAX_SIZE := SOURCE_SHAPE.X.SIZE;
    signal    SOURCE_Y_SIZE     :  integer range 1 to SOURCE_SHAPE.Y.MAX_SIZE := SOURCE_SHAPE.Y.SIZE;
    signal    SLICE_C_POS       :  integer range 0 to MAX_SLICE_C_POS := 0;
    signal    SLICE_X_POS       :  integer range 0 to MAX_SLICE_X_POS := 0;
    signal    SLICE_Y_POS       :  integer range 0 to MAX_SLICE_Y_POS := 0;
    signal    SLICE_C_SIZE      :  integer range 1 to SLICE_SHAPE .C.MAX_SIZE := SLICE_SHAPE .C.SIZE;
    signal    SLICE_X_SIZE      :  integer range 1 to SLICE_SHAPE .X.MAX_SIZE := SLICE_SHAPE .X.SIZE;
    signal    SLICE_Y_SIZE      :  integer range 1 to SLICE_SHAPE .Y.MAX_SIZE := SLICE_SHAPE .Y.SIZE;
    signal    ELEM_BYTES        :  integer range 1 to SOURCE_SHAPE.ELEM_BITS/8;
    signal    REQ_ADDR          :  std_logic_vector(ADDR_BITS-1 downto 0);
    signal    REQ_VALID         :  std_logic;
    signal    REQ_READY         :  std_logic;
    signal    RES_NONE          :  std_logic;
    signal    RES_ERROR         :  std_logic;
    signal    RES_VALID         :  std_logic;
    signal    RES_READY         :  std_logic;
    signal    MST_ADDR          :  std_logic_vector(ADDR_BITS-1 downto 0);
    signal    MST_SIZE          :  std_logic_vector(SIZE_BITS-1 downto 0);
    signal    MST_FIRST         :  std_logic;
    signal    MST_LAST          :  std_logic;
    signal    MST_START         :  std_logic;
    signal    MST_BUSY          :  std_logic;
    signal    MST_DONE          :  std_logic;
    signal    MST_ERROR         :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: IMAGE_SLICE_MASTER_CONTROLLER
        generic map (
            SOURCE_SHAPE    => SOURCE_SHAPE    , -- 
            SLICE_SHAPE     => SLICE_SHAPE     , --   
            MAX_SLICE_C_POS => MAX_SLICE_C_POS , --   
            MAX_SLICE_X_POS => MAX_SLICE_X_POS , --   
            MAX_SLICE_Y_POS => MAX_SLICE_Y_POS , --   
            ADDR_BITS       => ADDR_BITS       , --   
            SIZE_BITS       => SIZE_BITS         --   
        )
        port map (
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            SOURCE_C_SIZE   => SOURCE_C_SIZE   , -- In  :
            SOURCE_X_SIZE   => SOURCE_X_SIZE   , -- In  :
            SOURCE_Y_SIZE   => SOURCE_Y_SIZE   , -- In  :
            SLICE_C_POS     => SLICE_C_POS     , -- In  :
            SLICE_X_POS     => SLICE_X_POS     , -- In  :
            SLICE_Y_POS     => SLICE_Y_POS     , -- In  :
            SLICE_C_SIZE    => SLICE_C_SIZE    , -- In  :
            SLICE_X_SIZE    => SLICE_X_SIZE    , -- In  :
            SLICE_Y_SIZE    => SLICE_Y_SIZE    , -- In  :
            ELEM_BYTES      => ELEM_BYTES      , -- In  :
            REQ_ADDR        => REQ_ADDR        , -- In  :
            REQ_VALID       => REQ_VALID       , -- In  :
            REQ_READY       => REQ_READY       , -- Out :
            RES_NONE        => RES_NONE        , -- Out :
            RES_ERROR       => RES_ERROR       , -- Out :
            RES_VALID       => RES_VALID       , -- Out :
            RES_READY       => RES_READY       , -- In  :
            MST_ADDR        => MST_ADDR        , -- Out :
            MST_SIZE        => MST_SIZE        , -- Out :
            MST_FIRST       => MST_FIRST       , -- Out :
            MST_LAST        => MST_LAST        , -- Out :
            MST_START       => MST_START       , -- Out :
            MST_BUSY        => MST_BUSY        , -- In  :
            MST_DONE        => MST_DONE        , -- In  :
            MST_ERROR       => MST_ERROR         -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        loop
            CLK <= '1'; wait for PERIOD/2;
            CLK <= '0'; wait for PERIOD/2;
            exit when(CLK_ENA = FALSE);
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        variable mismatch :  integer := 0;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure WAIT_CLK(CNT:integer) is
        begin
            if (CNT > 0) then
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1'); 
                end loop;
            end if;
            wait for DELAY;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure REQ_VALID_PHASE(CNT:integer) is
            variable timeout : boolean;
        begin
            REQ_VALID <= '1';
            if (CNT > 0) then
                timeout := TRUE;
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1');
                    if (REQ_READY = '1') then
                        timeout := FALSE;
                        exit;
                    end if;
                end loop;
                assert (timeout = FALSE) report string'("REQ_READY Time Out") severity FAILURE;
            end if;
            wait for DELAY;
            REQ_VALID <= '0';
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure RES_READY_PHASE(CNT:integer; ERR,NONE: std_logic) is
            variable timeout : boolean;
        begin
            RES_READY <= '1';
            if (CNT > 0) then
                timeout := TRUE;
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1');
                    if (RES_VALID = '1') then
                        timeout := FALSE;
                        exit;
                    end if;
                end loop;
                assert (timeout = FALSE) report string'("RES_VALID Time Out") severity FAILURE;
            end if;
            if (RES_ERROR /= ERR) then
                assert (FALSE)
                report string'("RES_ERROR Mismatch '")  & BIN_TO_STRING(RES_ERROR) & "' /= '" & BIN_TO_STRING(ERR ) & "'"
                severity ERROR;
                mismatch := mismatch + 1;
            end if;
            if (RES_NONE  /= NONE) then
                assert (FALSE)
                report string'("RES_NONE  Mismatch '")  & BIN_TO_STRING(RES_NONE ) & "' /= '" & BIN_TO_STRING(NONE) & "'"
                severity ERROR;
                mismatch := mismatch + 1;
            end if;
            wait for DELAY;
            RES_READY <= '0';
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure MST_START_PHASE(CNT,ADDR,SIZE:integer;FIRST,LAST:std_logic) is
            variable timeout : boolean;
        begin
            if (CNT > 0) then
                timeout := TRUE;
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1');
                    if (MST_START = '1') then
                        timeout := FALSE;
                        exit;
                    end if;
                end loop;
                assert (timeout = FALSE) report string'("MST_START Time Out") severity FAILURE;
            end if;
            if (to_integer(unsigned(MST_ADDR)) /= ADDR) then
                assert (FALSE)
                report string'("Mismatch  MST_ADDR 0x") & HEX_TO_STRING(MST_ADDR ) & " /= 0x" & HEX_TO_STRING(ADDR, 32)
                severity ERROR;
                mismatch := mismatch + 1;
            end if;
            if (to_integer(unsigned(MST_SIZE)) /= SIZE) then
                assert (FALSE)
                report string'("Mismatch  MST_SIZE 0x") & HEX_TO_STRING(MST_SIZE ) & " /= 0x" & HEX_TO_STRING(SIZE, 32)
                severity ERROR;
                mismatch := mismatch + 1;
            end if;
            if (MST_FIRST /= FIRST) then
                assert (FALSE)
                report string'("MST_START Mismatch '")  & BIN_TO_STRING(MST_FIRST) & "' /= '" & BIN_TO_STRING(FIRST) & "'"
                severity ERROR;
                mismatch := mismatch + 1;
            end if;
            if (MST_LAST  /= LAST ) then
                assert (FALSE)
                report string'("MST_LAST  Mismatch '")  & BIN_TO_STRING(MST_LAST ) & "' /= '" & BIN_TO_STRING(LAST ) & "'"
                severity ERROR;
                mismatch := mismatch + 1;
            end if;
            wait for DELAY;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure MST_BUSY_PHASE(CNT:integer;ERR:std_logic) is
        begin
            MST_BUSY  <= '1';
            MST_DONE  <= '0';
            MST_ERROR <= '0';
            if (CNT > 0) then
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1');
                end loop;
            end if;
            wait for DELAY;
            MST_BUSY  <= '1';
            MST_DONE  <= '1';
            MST_ERROR <= ERR;
            wait until (CLK'event and CLK = '1');
            wait for DELAY;
            MST_BUSY  <= '0';
            MST_DONE  <= '0';
            MST_ERROR <= '0';
        end procedure;
    begin 
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report string'("Starting Run...") severity NOTE;
                             mismatch      := 0;
                             SCENARIO      <= "START";
                             CLK_ENA       <= TRUE;
                             RST           <= '1';
                             CLR           <= '1';
                             SOURCE_C_SIZE <=  SOURCE_SHAPE.C.SIZE ;
                             SOURCE_X_SIZE <=  SOURCE_SHAPE.X.SIZE ;
                             SOURCE_Y_SIZE <=  SOURCE_SHAPE.Y.SIZE ;
                             SLICE_C_POS   <=  0 ;
                             SLICE_X_POS   <=  0 ;
                             SLICE_Y_POS   <=  0 ;
                             SLICE_C_SIZE  <=  SLICE_SHAPE.C.SIZE;
                             SLICE_X_SIZE  <=  SLICE_SHAPE.X.SIZE;
                             SLICE_Y_SIZE  <=  SLICE_SHAPE.Y.SIZE;
                             ELEM_BYTES    <=  SOURCE_SHAPE.ELEM_BITS/8;
                             REQ_ADDR      <= (others => '0');
                             REQ_VALID     <= '0';
                             RES_READY     <= '0';
                             MST_BUSY      <= '0';
                             MST_DONE      <= '0';
                             MST_ERROR     <= '0';
        WAIT_CLK( 4);        RST           <= '0';
                             CLR           <= '0';
        WAIT_CLK( 4); 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO      <= "1.1.1";
                             SOURCE_C_SIZE <=  8;
                             SOURCE_X_SIZE <=  10;
                             SOURCE_Y_SIZE <=  20;
                             SLICE_C_POS   <=  0 ;
                             SLICE_X_POS   <=  0 ;
                             SLICE_Y_POS   <=  0 ;
                             SLICE_C_SIZE  <=  8;
                             SLICE_X_SIZE  <=  10;
                             SLICE_Y_SIZE  <=  1;
                             ELEM_BYTES    <=  SOURCE_SHAPE.ELEM_BITS/8;
                             REQ_ADDR      <=  std_logic_vector(to_unsigned(16#04120000#, ADDR_BITS));
                             REQ_VALID     <= '1';
                             RES_READY     <= '0';
                             MST_BUSY      <= '0';
                             MST_DONE      <= '0';
                             MST_ERROR     <= '0';
        REQ_VALID_PHASE(100);
        MST_START_PHASE(100, 16#04120000#, 80, '1', '1');
        MST_BUSY_PHASE (  4, '0');
        RES_READY_PHASE(100, '0', '0');
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO      <= "1.1.2";
                             SOURCE_C_SIZE <=  8;
                             SOURCE_X_SIZE <=  10;
                             SOURCE_Y_SIZE <=  20;
                             SLICE_C_POS   <=  0 ;
                             SLICE_X_POS   <=  1 ;
                             SLICE_Y_POS   <=  0 ;
                             SLICE_C_SIZE  <=  8;
                             SLICE_X_SIZE  <=  8;
                             SLICE_Y_SIZE  <=  4;
                             ELEM_BYTES    <=  SOURCE_SHAPE.ELEM_BITS/8;
                             REQ_ADDR      <=  std_logic_vector(to_unsigned(16#04120000#, ADDR_BITS));
                             REQ_VALID     <= '1';
                             RES_READY     <= '0';
                             MST_BUSY      <= '0';
                             MST_DONE      <= '0';
                             MST_ERROR     <= '0';
        REQ_VALID_PHASE(100);
        MST_START_PHASE(100,  16#04120008#, 64, '1', '0');
        MST_BUSY_PHASE (  4, '0');
        MST_START_PHASE(100,  16#04120058#, 64, '0', '0');
        MST_BUSY_PHASE (  4, '0');
        MST_START_PHASE(100,  16#041200A8#, 64, '0', '0');
        MST_BUSY_PHASE (  4, '0');
        MST_START_PHASE(100,  16#041200F8#, 64, '0', '1');
        MST_BUSY_PHASE (  4, '0');
        RES_READY_PHASE(100, '0', '0');
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO      <= "1.2.0";
                             SOURCE_C_SIZE <=  8;
                             SOURCE_X_SIZE <=  10;
                             SOURCE_Y_SIZE <=  20;
                             SLICE_C_POS   <=  0 ;
                             SLICE_X_POS   <=  1 ;
                             SLICE_Y_POS   <=  0 ;
                             SLICE_C_SIZE  <=  2 ;
                             SLICE_X_SIZE  <=  4;
                             SLICE_Y_SIZE  <=  1;
                             ELEM_BYTES    <=  SOURCE_SHAPE.ELEM_BITS/8;
                             REQ_ADDR      <=  std_logic_vector(to_unsigned(16#04120000#, ADDR_BITS));
                             REQ_VALID     <= '1';
                             RES_READY     <= '0';
                             MST_BUSY      <= '0';
                             MST_DONE      <= '0';
                             MST_ERROR     <= '0';
        REQ_VALID_PHASE(100);
        MST_START_PHASE(100,  16#04120008#,  2, '1', '0');
        MST_BUSY_PHASE (  4, '0');
        MST_START_PHASE(100,  16#04120010#,  2, '0', '0');
        MST_BUSY_PHASE (  4, '0');
        MST_START_PHASE(100,  16#04120018#,  2, '0', '0');
        MST_BUSY_PHASE (  4, '0');
        MST_START_PHASE(100,  16#04120020#,  2, '0', '1');
        MST_BUSY_PHASE (  4, '0');
        RES_READY_PHASE(100, '0', '0');
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
                             SCENARIO      <= "1.2.1";
                             SOURCE_C_SIZE <=  8;
                             SOURCE_X_SIZE <=  10;
                             SOURCE_Y_SIZE <=  20;
                             SLICE_C_POS   <=  2 ;
                             SLICE_X_POS   <=  1 ;
                             SLICE_Y_POS   <=  0 ;
                             SLICE_C_SIZE  <=  3 ;
                             SLICE_X_SIZE  <=  4;
                             SLICE_Y_SIZE  <=  1;
                             ELEM_BYTES    <=  SOURCE_SHAPE.ELEM_BITS/8;
                             REQ_ADDR      <=  std_logic_vector(to_unsigned(16#04120000#, ADDR_BITS));
                             REQ_VALID     <= '1';
                             RES_READY     <= '0';
                             MST_BUSY      <= '0';
                             MST_DONE      <= '0';
                             MST_ERROR     <= '0';
        REQ_VALID_PHASE(100);
        MST_START_PHASE(100,  16#0412000A#,  3, '1', '0');
        MST_BUSY_PHASE (  0, '0');
        MST_START_PHASE(100,  16#04120012#,  3, '0', '0');
        MST_BUSY_PHASE (  0, '0');
        MST_START_PHASE(100,  16#0412001A#,  3, '0', '0');
        MST_BUSY_PHASE (  0, '0');
        MST_START_PHASE(100,  16#04120022#,  3, '0', '1');
        MST_BUSY_PHASE (  0, '0');
        RES_READY_PHASE(100, '0', '0');
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10); 
        if (FINISH_ABORT) then
            FINISH  <= 'Z';
            CLK_ENA <= FALSE;
            if (mismatch > 0) then
                assert FALSE report "Simulation complete(error)."    severity FAILURE;
            else
                assert FALSE report "Simulation complete(success)."  severity FAILURE;
            end if;
        else
            if (mismatch > 0) then
                assert FALSE report "Simulation complete(error)."    severity FAILURE;
            else
                assert FALSE report "Simulation complete(success)."  severity NOTE;
            end if;
            FINISH  <= 'Z';
            CLK_ENA <= FALSE;
        end if;
        wait;
    end process;
end MODEL;
