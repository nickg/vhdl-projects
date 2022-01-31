-----------------------------------------------------------------------------------
--!     @file    chopper_function_model.vhd
--!     @brief   CHOPPER FUNCTION MODEL :
--!              CHOPPER MODULEを検証するための機能モデル.
--!     @version 1.7.0
--!     @date    2018/3/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2018 Ichiro Kawazome
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
-- エンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_FUNCTION_MODEL is
    generic (
        BURST       : integer := 1;
        MIN_PIECE   : integer := 6;
        MAX_PIECE   : integer := 6;
        MAX_SIZE    : integer := 9;
        ADDR_BITS   : integer := 9;
        SIZE_BITS   : integer := 9;
        COUNT_BITS  : integer := 9;
        PSIZE_BITS  : integer := 9;
        GEN_VALID   : integer := 1;
        VERBOSE     : integer := 0
    );
    port (
        CLK         : out std_logic;  
        RST         : out std_logic;
        CLR         : out std_logic;
        ADDR        : out std_logic_vector(ADDR_BITS-1 downto 0);
        SIZE        : out std_logic_vector(SIZE_BITS-1 downto 0);
        SEL         : out std_logic_vector(MAX_PIECE downto MIN_PIECE);
        LOAD        : out std_logic;
        CHOP        : out std_logic;
        COUNT       : in  std_logic_vector(COUNT_BITS-1 downto 0);
        NONE        : in  std_logic;
        LAST        : in  std_logic;
        NEXT_NONE   : in  std_logic;
        NEXT_LAST   : in  std_logic;
        PSIZE       : in  std_logic_vector(PSIZE_BITS-1 downto 0);
        NEXT_PSIZE  : in  std_logic_vector(PSIZE_BITS-1 downto 0);
        VALID       : in  std_logic_vector(2**(MAX_PIECE)-1 downto 0);
        NEXT_VALID  : in  std_logic_vector(2**(MAX_PIECE)-1 downto 0);
        FINISH      : out std_logic
    );
end     CHOPPER_FUNCTION_MODEL;
-----------------------------------------------------------------------------------
-- ★ アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
architecture MODEL of CHOPPER_FUNCTION_MODEL is
    constant    HEX             : STRING(1 to 16) := "0123456789ABCDEF";
    constant    PERIOD          : time    := 10 ns;
    constant    DELAY           : time    :=  2 ns;
    constant    TIMEOUT_CYCLE   : integer := 1000000;
    signal      SCENARIO        : STRING(1 to 5);
    signal      clock           : std_logic;
    signal      clk_ena         : std_logic;
    function    MESSAGE_TAG return STRING is
    begin
        return "(BURST="      & INTEGER_TO_STRING(BURST     ) &
               ",MIN_PIECE="  & INTEGER_TO_STRING(MIN_PIECE ) &
               ",MAX_PIECE="  & INTEGER_TO_STRING(MAX_PIECE ) &
               ",MAX_SIZE="   & INTEGER_TO_STRING(MAX_SIZE  ) &
               ",ADDR_BITS="  & INTEGER_TO_STRING(ADDR_BITS ) &
               ",SIZE_BITS="  & INTEGER_TO_STRING(SIZE_BITS ) &
               ",COUNT_BITS=" & INTEGER_TO_STRING(COUNT_BITS) &
               ",PSIZE_BITS=" & INTEGER_TO_STRING(PSIZE_BITS) &
               ",GEN_VALID="  & INTEGER_TO_STRING(GEN_VALID ) &
               "):";
    end function;
begin
    process begin
        while (TRUE) loop
            CLK <= '1'; clock <= '1'; wait for PERIOD/2;
            CLK <= '0'; clock <= '0'; wait for PERIOD/2;
            exit when (clk_ena = '0');
        end loop;
        CLK <= '0'; clock <= '0';
        wait;
    end process;

    process
        variable test_count    : integer;
        variable test_total    : integer;
        variable test_interim  : integer;
        variable block_size    : integer;
        variable remain_size   : integer;
        variable none_piece    : boolean;
        variable last_piece    : boolean;
        variable piece_size    : integer;
        variable piece_count   : integer;
        variable addr_1st      : integer;
        variable piece_valid   : std_logic_vector(2**MAX_PIECE-1 downto 0);
        procedure WAIT_CLK(CNT:integer) is
        begin
            for i in 1 to CNT loop 
                wait until (clock'event and clock = '1'); 
            end loop;
            wait for DELAY;
        end WAIT_CLK;
        procedure CHECK_NEXT_SIGS is
            variable exp_none  : std_logic;
            variable exp_last  : std_logic;
            variable exp_psize : std_logic_vector(PSIZE_BITS-1 downto 0);
        begin
            if (none_piece) then
                exp_none := '1';
            else
                exp_none := '0';
            end if;
            if (last_piece) then
                exp_last := '1';
            else
                exp_last := '0';
            end if;
            exp_psize := std_logic_vector(TO_UNSIGNED(piece_size, PSIZE_BITS));
            assert (NEXT_NONE = exp_none)
                report MESSAGE_TAG &
                       "Mismtch NEXT_NONE="   & BIN_TO_STRING(NEXT_NONE  ) &
                                        "("   & BIN_TO_STRING(exp_none   ) & ")"
                severity ERROR;
            assert (NEXT_LAST = exp_last)
                report MESSAGE_TAG &
                       "Mismtch NEXT_LAST="   & BIN_TO_STRING(NEXT_LAST  ) &
                                        "("   & BIN_TO_STRING(exp_last   ) & ")"
                severity ERROR;
            assert (NEXT_PSIZE  = exp_psize) 
                report MESSAGE_TAG &
                       "Mismtch NEXT_PSIZE="  & HEX_TO_STRING(NEXT_PSIZE ) &
                                          "(" & HEX_TO_STRING(exp_psize  ) & ")"
                severity ERROR;
            assert (GEN_VALID = 0 or NEXT_VALID = piece_valid) 
                report MESSAGE_TAG &
                       "Mismtch NEXT_BEN="    & BIN_TO_STRING(NEXT_VALID ) &
                                          "(" & BIN_TO_STRING(piece_valid) & ")"
                severity ERROR;
        end procedure;
        procedure CHECK_CURR_SIGS is
            variable exp_none  : std_logic;
            variable exp_last  : std_logic;
            variable exp_psize : std_logic_vector(PSIZE_BITS-1 downto 0);
            variable exp_count : std_logic_vector(COUNT_BITS-1 downto 0);
        begin
            if (none_piece) then
                exp_none := '1';
            else
                exp_none := '0';
            end if;
            if (last_piece) then
                exp_last := '1';
            else
                exp_last := '0';
            end if;
            exp_psize := std_logic_vector(TO_UNSIGNED(piece_size , PSIZE_BITS));
            exp_count := std_logic_vector(TO_UNSIGNED(piece_count, COUNT_BITS));
            assert (NONE = exp_none)
                report MESSAGE_TAG &
                       "Mismtch NONE="   & BIN_TO_STRING(NONE       ) &
                                    "("  & BIN_TO_STRING(exp_none   ) & ")"
                severity ERROR;
            assert (LAST = exp_last)
                report MESSAGE_TAG &
                       "Mismtch LAST="   & BIN_TO_STRING(LAST       ) &
                                    "("  & BIN_TO_STRING(exp_last   ) & ")"
                severity ERROR;
            assert (PSIZE  = exp_psize)
                report MESSAGE_TAG &
                       "Mismtch PSIZE="  & HEX_TO_STRING(PSIZE      ) &
                                    "("  & HEX_TO_STRING(exp_psize  ) & ")"
                severity ERROR;
            assert (COUNT  = exp_count)
                report MESSAGE_TAG &
                       "Mismtch COUNT="  & HEX_TO_STRING(COUNT      ) &
                                    "("  & HEX_TO_STRING(exp_count  ) & ")"
                severity ERROR;
            assert (GEN_VALID = 0 or VALID = piece_valid) 
                report MESSAGE_TAG &
                       "Mismtch BEN="    & BIN_TO_STRING(VALID      ) &
                                  "("    & BIN_TO_STRING(piece_valid) & ")"
                severity ERROR;
        end procedure;
        procedure UPDATE is
        begin
            remain_size := remain_size - piece_size;
            if (remain_size = 0) then
                none_piece := TRUE;
                last_piece := FALSE;
            else
                none_piece := FALSE;
                last_piece := (addr_1st + remain_size <= block_size);
            end if;
            if    (none_piece) then
                piece_size := 0;
            elsif (last_piece) then
                piece_size := remain_size;
            else
                piece_size := block_size - addr_1st;
            end if;
            for i in piece_valid'low to piece_valid'high loop
                if (i >= addr_1st and i < addr_1st+piece_size) then
                    piece_valid(i) := '1';
                else
                    piece_valid(i) := '0';
                end if;
            end loop;
            piece_count := (addr_1st + remain_size - 1)/block_size;
            addr_1st   := 0;
        end procedure;
        procedure INIT(A,S,W:integer) is
        begin
            block_size  := 2**W;
            addr_1st    := A mod block_size;
            piece_size  := 0;
            if (BURST = 0 and S >= block_size-addr_1st) then
                remain_size := block_size-addr_1st;
            else
                remain_size := S;
            end if;
            UPDATE;
        end procedure;
        procedure TEST(A,S,W:integer) is
            variable count_enable  : boolean;
            variable timeout_count : integer;
        begin
            INIT(A,S,W);
            ADDR <= std_logic_vector(TO_UNSIGNED(A,ADDR_BITS));
            SIZE <= std_logic_vector(TO_UNSIGNED(S,SIZE_BITS));
            for i in SEL'range loop
                if (i = W) then
                    SEL(i) <= '1';
                else
                    SEL(i) <= '0';
                end if;
            end loop;
            LOAD <= '1';
            wait until (clock'event and clock = '1');
            CHECK_NEXT_SIGS;
            wait for DELAY;
            LOAD <= '0';
            wait for DELAY;
            if (none_piece = FALSE) then
                CHOP <= '1'; count_enable := TRUE;
                timeout_count := TIMEOUT_CYCLE;
                while (none_piece = FALSE) loop
                    wait until (clock'event and clock = '1');
                    assert (timeout_count > 0) 
                       report MESSAGE_TAG & "Time Out"
                       severity ERROR;
                    timeout_count := timeout_count - 1;
                    CHECK_CURR_SIGS;
                    if (count_enable) then
                        UPDATE;
                    end if;
                    CHECK_NEXT_SIGS;
                    wait for DELAY;
                end loop;
                CHOP <= '0'; count_enable := FALSE;
            end if;
            wait until (clock'event and clock = '1');
            wait for DELAY;
        end TEST;
    begin
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report  MESSAGE_TAG & "Starting Run..." severity NOTE;
                              clk_ena  <= '1';
                              SCENARIO <= "START";
                              CLR  <= '1';
                              RST  <= '1';
                              CHOP <= '0';
                              LOAD <= '0';
                              SEL  <= (others => '0');
                              ADDR <= (others => '0');
                              SIZE <= (others => '0');
        WAIT_CLK( 4);         RST  <= '0';
                              CLR  <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- シミュレーション開始
        ---------------------------------------------------------------------------
        SCENARIO <= "1.1.1";
        test_count := 0;
        test_total := 0;
        for W in MIN_PIECE to MAX_PIECE loop
            for A in 0 to 2**W-1 loop
                test_total := test_total + (2**MAX_SIZE)-A;
            end loop;
        end loop;
        test_interim := 5000;
        for W in MIN_PIECE to MAX_PIECE loop
            for A in 0 to 2**W-1 loop
                for S in 0 to (2**MAX_SIZE)-A-1 loop
                    assert(VERBOSE=0) report "W=" & INTEGER_TO_STRING(W) &
                                            ",A=" & INTEGER_TO_STRING(A) &
                                            ",S=" & INTEGER_TO_STRING(S) severity NOTE;
                    test_count := test_count+1;
                    assert ((test_count mod test_interim) /= 0)
                        report MESSAGE_TAG &
                               "(" & INTEGER_TO_STRING(test_count) & 
                               "/" & INTEGER_TO_STRING(test_total) & ")" severity NOTE;
                    TEST(A,S,W);
                end loop;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        SCENARIO <= "DONE.";
        WAIT_CLK(10); 
        assert(false) report MESSAGE_TAG & "Run complete..." severity NOTE;
        FINISH  <= 'Z';
        clk_ena <= '0';
        wait;
    end process;

end MODEL;
