-----------------------------------------------------------------------------------
--!     @file    pump_control_register.vhd
--!     @brief   PUMP CONTROL REGISTER
--!     @version 1.8.3
--!     @date    2020/10/18
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2020 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief   PUMP CONTROL REGISTER :
-----------------------------------------------------------------------------------
entity  PUMP_CONTROL_REGISTER is
    generic (
        MODE_BITS       : --! @brief MODE REGISTER BITS :
                          --! ???????????????????????????????????????????????????.
                          integer := 32;
        STAT_BITS       : --! @brief STATUS REGISTER BITS :
                          --! ?????????????????????????????????????????????????????????.
                          integer := 32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock & Reset Signals.
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! ??????????????????
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! ???????????????????????????.?????????????????????.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! ????????????????????????.?????????????????????.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- RESET Bit        : ????????????????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * RESET_L='1' and RESET_D='1' ?????????????????????.
    -- * RESET_L='1' and RESET_D='0' ?????????????????????.
    -- * RESET_Q ???????????????????????????????????????.
    -- * RESET_Q='1' ????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
        RESET_L         : in  std_logic := '0';
        RESET_D         : in  std_logic := '0';
        RESET_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- START Bit        : ??????????????????????????????.
    -------------------------------------------------------------------------------
    -- * START_L='1' and START_D='1' ???????????????.
    -- * START_L='1' and START_D='0' ???????????????????????????.
    -- * START_Q ???????????????????????????.
    -- * START_Q='1' ????????????????????????????????????.
    -- * START_Q='0 '????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
        START_L         : in  std_logic := '0';
        START_D         : in  std_logic := '0';
        START_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- STOP Bit         : ???????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * STOP_L='1' and STOP_D='1' ???????????????????????????.
    -- * STOP_L='1' and STOP_D='0' ???????????????????????????.
    -- * STOP_Q ???????????????????????????.
    -- * STOP_Q='1' ????????????????????????????????????????????????.
    -- * STOP_Q='0' ?????????????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
        STOP_L          : in  std_logic := '0';
        STOP_D          : in  std_logic := '0';
        STOP_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- PAUSE Bit        : ??????????????????????????????.
    -------------------------------------------------------------------------------
    -- * PAUSE_L='1' and PAUSE_D='1' ???????????????.
    -- * PAUSE_L='1' and PAUSE_D='0' ???????????????.
    -- * PAUSE_Q ????????????????????????????????????.
    -- * PAUSE_Q='1' ??????????????????????????????????????????.
    -- * PAUSE_Q='0' ???????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
        PAUSE_L         : in  std_logic := '0';
        PAUSE_D         : in  std_logic := '0';
        PAUSE_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- FIRST Bit        : ????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * FIRST_L='1' and FIRST_D='1' ????????????????????????????????????????????????.
    -- * FIRST_L='1' and FIRST_D='0' ????????????????????????????????????????????????.
    -- * FIRST_Q ???????????????????????????.
    -------------------------------------------------------------------------------
        FIRST_L         : in  std_logic := '0';
        FIRST_D         : in  std_logic := '0';
        FIRST_Q         : out std_logic;
    -------------------------------------------------------------------------------
    -- LAST Bit         : ????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * LAST_L='1' and LAST_D='1' ????????????????????????????????????????????????.
    -- * LAST_L='1' and LAST_D='0' ????????????????????????????????????????????????.
    -- * LAST_Q ???????????????????????????.
    -------------------------------------------------------------------------------
        LAST_L          : in  std_logic := '0';
        LAST_D          : in  std_logic := '0';
        LAST_Q          : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE ENable Bit  : ?????????????????? DONE STatus Bit ??????????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * DONE_EN_L='1' and DONE_EN_D='1' ????????????????????? DONE STatus Bit ???????????????
    --   ????????????????????????.
    -- * DONE_EN_L='1' and DONE_EN_D='0' ????????????????????? DONE STatus Bit ???????????????
    --   ???????????????????????????.
    -- * DONE_EN_Q ???????????????????????????.
    -------------------------------------------------------------------------------
        DONE_EN_L       : in  std_logic := '0';
        DONE_EN_D       : in  std_logic := '0';
        DONE_EN_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- DONE STatus Bit  : DONE_EN_Q='1'?????????????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * DONE_ST_L='1' and DONE_ST_D='0' ????????????????????????????????????.
    -- * DONE_ST_L='1' and DONE_ST_D='1' ?????????????????????????????????????????????.
    -- * DONE_ST_Q='1' ??????DONE_EN_Q='1' ?????????????????????????????????????????????.
    -------------------------------------------------------------------------------
        DONE_ST_L       : in  std_logic := '0';
        DONE_ST_D       : in  std_logic := '0';
        DONE_ST_Q       : out std_logic;
    -------------------------------------------------------------------------------
    -- ERRor STatus Bit : ????????????????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * ERR_ST_L='1' and ERR_ST_D='0' ????????????????????????????????????.
    -- * ERR_ST_L='1' and ERR_ST_D='1' ?????????????????????????????????????????????.
    -- * ERR_ST_Q='1' ??????????????????????????????????????????????????????.
    -------------------------------------------------------------------------------
        ERR_ST_L        : in  std_logic := '0';
        ERR_ST_D        : in  std_logic := '0';
        ERR_ST_Q        : out std_logic;
    -------------------------------------------------------------------------------
    -- MODE Register    : ?????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * MODE_L(x)='1' and MODE_D(x)='1' ??? MODE_Q(x) ???'1'????????????.
    -- * MODE_L(x)='1' and MODE_D(x)='0' ??? MODE_Q(x) ???'0'????????????.
    -------------------------------------------------------------------------------
        MODE_L          : in  std_logic_vector(MODE_BITS-1 downto 0) := (others => '0');
        MODE_D          : in  std_logic_vector(MODE_BITS-1 downto 0) := (others => '0');
        MODE_Q          : out std_logic_vector(MODE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- STATus Register  : ???????????????????????????????????????.
    -------------------------------------------------------------------------------
    -- * STAT_L(x)='1' and STAT_D(x)='0' ??? STAT_Q(x)????????????.
    -- * STAT_L(x)='1' and STAT_D(x)='1' ????????????STAT_Q(x) ??????????????????.
    -- * STAT_I(x)='1' ??? STAT_Q(x) ???'1'????????????.
    -- * STAT_I(x)='0' ????????????STAT_Q(x) ??????????????????.
    -------------------------------------------------------------------------------
        STAT_L          : in  std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
        STAT_D          : in  std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
        STAT_Q          : out std_logic_vector(STAT_BITS-1 downto 0);
        STAT_I          : in  std_logic_vector(STAT_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       : --! @brief Request Valid Signal.
                          --! ?????????????????????????????????????????????????????????????????????.
                          --! * ??????????????????????????????????????????????????????????????????????????????.
                          --! * ?????????????????????????????????????????? Acknowledge ??????????????????
                          --!   ?????????????????????????????????????????????????????????.
                          out std_logic;
        REQ_FIRST       : --! @brief Request First Transaction.
                          --! ?????????????????????????????????????????????????????????.
                          out std_logic;
        REQ_LAST        : --! @brief Request Last Transaction.
                          --! ?????????????????????????????????????????????????????????.
                          out std_logic;
        REQ_READY       : --! @brief Request Ready Signal.
                          --! ??????????????????????????????????????????????????????????????????????????????.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       : --! @brief Acknowledge Valid Signal.
                          --! ????????? Command Request ???????????????.
                          --! ????????? ?????? Acknowledge ????????????????????????????????????.
                          --! * ??????????????????????????????????????????Command Request ?????????
                          --!   ??????????????????????????????. ??????????????????????????? Request ???
                          --!   ???????????????????????????????????????????????????????????????????????????
                          --!   ???????????????????????????????????????????????????.
                          --! * ??????????????? Request ????????????????????????????????????????????????
                          --!   ???.
                          --! * ???????????????????????????????????????????????????????????????????????????
                          --!   ????????? REQ_VAL ??????????????????????????? Request ????????????
                          --!   ????????????REQ_VAL???????????????????????????????????? Request ???
                          --!   ????????????????????????????????????????????????.
                          in  std_logic;
        ACK_ERROR       : --! @brief Acknowledge with Error.
                          --! ??????????????????????????????????????????????????????????????????????????????
                          --! ????????????????????????????????????.
                          in  std_logic;
        ACK_NEXT        : --! @brief Acknowledge with need Next transaction.
                          --! ??????????????????????????????????????????????????? REQ_LAST=0 ????????????
                          --! ????????????????????????????????????.
                          in  std_logic;
        ACK_LAST        : --! @brief Acknowledge with Last transaction.
                          --! ??????????????????????????????????????????????????? REQ_LAST=1 ????????????
                          --! ????????????????????????????????????.
                          in  std_logic;
        ACK_STOP        : --! @brief Acknowledge with Stop operation.
                          --! ??????????????????????????????????????????????????????????????????????????????
                          --! ?????????.
                          in  std_logic;
        ACK_NONE        : --! @brief Acknowledge with None Request transfer size.
                          --! REQ_SIZE=0 ??? Request ?????????????????????????????????????????????
                          --! ?????????.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_BUSY       : --! @brief Transfer Busy.
                          --! ???????????????????????????????????????????????????.
                          in  std_logic;
        XFER_ERROR      : --! @brief Transfer Error.
                          --! ????????????????????????????????????????????????????????????.
                          in  std_logic := '0';
        XFER_DONE       : --! @brief Transfer Done.
                          --! ???????????????????????????????????????????????? XFER_BUSY ???????????????
                          --! ??????????????????????????????.
                          --! * ????????????XFER_BUSY ????????????????????? ???????????????????????????
                          --!   ???????????????????????????????????????.
                          in std_logic;
    -------------------------------------------------------------------------------
    -- Status.
    -------------------------------------------------------------------------------
        VALVE_OPEN      : --! @brief Valve Open Flag.
                          --! ?????????(REQ_FIRST='1'??????)??????????????????????????????????????????
                          --! ????????????????????????(REQ_LAST='1'??????)???????????????????????????
                          --! ??????????????????????????????????????????????????????????????????????????????
                          --! ?????????????????????.
                          out std_logic;
        TRAN_START      : --! @brief Transaction Start Flag.
                          --! ???????????????????????????????????????????????????????????????.
                          --! ??????????????????????????????"?????????"????????????????????????????????????
                          --! ?????????.
                          out std_logic;
        TRAN_BUSY       : --! @brief Transaction Busy Flag.
                          --! ????????????????????????????????????????????????????????????.
                          out std_logic;
        TRAN_DONE       : --! @brief Transaction Done Flag.
                          --! ???????????????????????????????????????????????????????????????.
                          --! ??????????????????????????????????????????????????????????????????????????????.
                          out std_logic;
        TRAN_NONE       : --! @brief Transaction None Flag.
                          --! ????????????????????????????????????????????????????????????????????????????????????.
                          --! ??????????????????????????????????????????????????????????????????????????????.
                          out std_logic;
        TRAN_ERROR      : --! @brief Transaction Error Flag.
                          --! ??????????????????????????????????????????????????????????????????????????????.
                          --! ??????????????????????????????????????????????????????????????????????????????.
                          out std_logic
    );
end PUMP_CONTROL_REGISTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of PUMP_CONTROL_REGISTER is
    -------------------------------------------------------------------------------
    -- Register Bits.
    -------------------------------------------------------------------------------
    signal   reset_bit          : std_logic;
    signal   start_bit          : std_logic;
    signal   stop_bit           : std_logic;
    signal   pause_bit          : std_logic;
    signal   first_bit          : std_logic;
    signal   last_bit           : std_logic;
    signal   done_en_bit        : std_logic;
    signal   done_bit           : std_logic;
    signal   none_flag          : std_logic;
    signal   error_bit          : std_logic;
    signal   error_flag         : std_logic;
    signal   request_bit        : std_logic;
    signal   mode_regs          : std_logic_vector(MODE_BITS-1 downto 0);
    signal   stat_regs          : std_logic_vector(STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Control Signals.
    -------------------------------------------------------------------------------
    signal   transaction_start  : boolean;
    -------------------------------------------------------------------------------
    -- Main State Machine.
    -------------------------------------------------------------------------------
    type     STATE_TYPE     is  ( IDLE_STATE    ,
                                  REQ_STATE     ,
                                  ACK_STATE     ,
                                  CONTINUE_STATE,
                                  TAR_STATE     ,
                                  DONE_STATE    );
    signal   curr_state         : STATE_TYPE;
    -------------------------------------------------------------------------------
    -- Transaction State Machine.
    -------------------------------------------------------------------------------
    signal   tran_state         : std_logic_vector(2 downto 0);
    constant TRAN_IDLE_STATE    : std_logic_vector(2 downto 0) := "000";
    constant TRAN_FIRST_STATE   : std_logic_vector(2 downto 0) := "111";
    constant TRAN_OTHER_STATE   : std_logic_vector(2 downto 0) := "110";
    constant TRAN_TAR_STATE     : std_logic_vector(2 downto 0) := "100";
    signal   tran_once          : std_logic;
    signal   tran_err           : std_logic;
begin
    -------------------------------------------------------------------------------
    -- transaction_start : ????????????????????????????????????.
    -------------------------------------------------------------------------------
    transaction_start <= (curr_state = IDLE_STATE) and
                         (start_bit = '1' or (START_L = '1' and START_D = '1'));
    -------------------------------------------------------------------------------
    -- ?????????????????????????????????????????????????????????????????????
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
        variable xfer_run   : boolean;
        variable xfer_first : boolean;
        variable error_on   : boolean;
        variable none_on    : boolean;
    begin
        if    (RST = '1') then
                curr_state  <= IDLE_STATE;
                tran_state  <= (others => '0');
                tran_once   <= '0';
                tran_err    <= '0';
                reset_bit   <= '0';
                start_bit   <= '0';
                stop_bit    <= '0';
                pause_bit   <= '0';
                first_bit   <= '0';
                last_bit    <= '0';
                done_en_bit <= '0';
                done_bit    <= '0';
                error_bit   <= '0';
                error_flag  <= '0';
                mode_regs   <= (others => '0');
                stat_regs   <= (others => '0');
                request_bit <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR   = '1') then
                curr_state  <= IDLE_STATE;
                tran_state  <= (others => '0');
                tran_once   <= '0';
                tran_err    <= '0';
                reset_bit   <= '0';
                start_bit   <= '0';
                stop_bit    <= '0';
                pause_bit   <= '0';
                first_bit   <= '0';
                last_bit    <= '0';
                done_en_bit <= '0';
                done_bit    <= '0';
                error_bit   <= '0';
                error_flag  <= '0';
                mode_regs   <= (others => '0');
                stat_regs   <= (others => '0');
                request_bit <= '0';
            else
                -------------------------------------------------------------------
                --
                -------------------------------------------------------------------
                xfer_run := (XFER_BUSY = '1' and XFER_DONE = '0');
                -------------------------------------------------------------------
                -- ?????????????????????
                -------------------------------------------------------------------
                case curr_state is
                    when IDLE_STATE =>
                        if (transaction_start) then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE  =>
                        if    (REQ_READY = '0') then
                                next_state := REQ_STATE;
                        elsif (ACK_VALID = '1') then
                            if (ACK_NEXT = '1' or ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                                if (xfer_run = TRUE) then
                                    next_state := TAR_STATE;
                                else
                                    next_state := DONE_STATE;
                                end if;
                            else
                                    next_state := CONTINUE_STATE;
                            end if;
                        else
                                    next_state := ACK_STATE;
                        end if;
                    when ACK_STATE  =>
                        if (ACK_VALID = '1') then
                            if (ACK_NEXT = '1' or ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                                if (xfer_run = TRUE) then
                                    next_state := TAR_STATE;
                                else
                                    next_state := DONE_STATE;
                                end if;
                            else
                                    next_state := CONTINUE_STATE;
                            end if;
                        else
                                    next_state := ACK_STATE;
                        end if;
                    when CONTINUE_STATE =>
                            next_state := REQ_STATE;
                    when TAR_STATE  =>
                        if (xfer_run = TRUE) then
                            next_state := TAR_STATE;
                        else
                            next_state := DONE_STATE;
                        end if;
                    when DONE_STATE =>
                            next_state := IDLE_STATE;
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                if (reset_bit = '1') then
                    curr_state <= IDLE_STATE;
                else
                    curr_state <= next_state;
                end if;
                -------------------------------------------------------------------
                -- RESET BIT   :
                -------------------------------------------------------------------
                if    (RESET_L = '1') then
                    reset_bit <= RESET_D;
                end if;
                -------------------------------------------------------------------
                -- START BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    start_bit <= '0';
                elsif (START_L = '1' and START_D = '1') then
                    start_bit <= '1';
                elsif (next_state = DONE_STATE) then
                    start_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- STOP BIT    :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    stop_bit  <= '0';
                elsif (STOP_L  = '1' and STOP_D  = '1') then
                    stop_bit  <= '1';
                elsif (next_state = DONE_STATE) then
                    stop_bit  <= '0';
                end if;
                -------------------------------------------------------------------
                -- PAUSE BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    pause_bit <= '0';
                elsif (PAUSE_L = '1') then
                    pause_bit <= PAUSE_D;
                end if;
                -------------------------------------------------------------------
                -- FIRST BIT   :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    first_bit <= '0';
                elsif (FIRST_L = '1') then
                    first_bit <= FIRST_D;
                end if;
                xfer_first := (FIRST_L = '1' and FIRST_D = '1') or (first_bit = '1');
                -------------------------------------------------------------------
                -- LAST BIT    :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    last_bit  <= '0';
                elsif (LAST_L  = '1') then
                    last_bit  <= LAST_D;
                end if;
                -------------------------------------------------------------------
                -- DONE_EN BIT :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    done_en_bit  <= '0';
                elsif (DONE_EN_L  = '1') then
                    done_en_bit  <= DONE_EN_D;
                end if;
                -------------------------------------------------------------------
                -- DONE_ST BIT :
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    done_bit <= '0';
                elsif (done_en_bit = '1' and next_state = DONE_STATE) then
                    done_bit <= '1';
                elsif (DONE_ST_L  = '1' and DONE_ST_D = '0') then
                    done_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- MODE REGISTER
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    mode_regs <= (others => '0');
                else
                    for i in mode_regs'range loop
                        if (MODE_L(i) = '1') then
                            mode_regs(i) <= MODE_D(i);
                        end if;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- STATUS REGISTER
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    stat_regs <= (others => '0');
                else
                    for i in stat_regs'range loop
                        if    (STAT_L(i) = '1' and STAT_D(i) = '0') then
                            stat_regs(i) <= '0';
                        elsif (STAT_I(i) = '1') then
                            stat_regs(i) <= '1';
                        end if;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- REQ_VALID   : 
                -------------------------------------------------------------------
                if (next_state = REQ_STATE or next_state = ACK_STATE) then
                    request_bit <= '1';
                else
                    request_bit <= '0';
                end if;
                -------------------------------------------------------------------
                -- tran_state : REQ_FIRST(???????????????????????????)???????????????????????????????????????.
                -- tran_once  : ???????????????????????????????????????????????????????????????????????????????????????
                -- tran_err   : ??????????????????????????????????????????????????????????????????????????????
                -- none_on    : none_flag ????????????????????????????????????
                -- error_on   : error_flag ????????????????????????????????????
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    tran_state <= TRAN_IDLE_STATE;
                    tran_once <= '0';
                    tran_err  <= '0';
                    none_on   := FALSE;
                    error_on  := FALSE;
                elsif (tran_state = TRAN_IDLE_STATE) then
                    if (transaction_start and xfer_first) then
                        tran_state <= TRAN_FIRST_STATE;
                    else
                        tran_state <= TRAN_IDLE_STATE;
                    end if;
                    tran_once <= '0';
                    tran_err  <= '0';
                    none_on   := FALSE;
                    error_on  := FALSE;
                elsif (tran_state = TRAN_TAR_STATE) then
                    if (xfer_run = TRUE) then
                        tran_state <= TRAN_TAR_STATE;
                    else
                        tran_state <= TRAN_IDLE_STATE;
                    end if;
                    tran_err  <= XFER_ERROR;
                    none_on   := (tran_once = '0');
                    error_on  := (tran_err  = '1' or XFER_ERROR = '1');
                elsif (ACK_VALID = '1') then
                    if (ACK_LAST = '1' or ACK_ERROR = '1' or ACK_STOP = '1') then
                        if (xfer_run = TRUE) then
                            tran_state <= TRAN_TAR_STATE;
                        else
                            tran_state <= TRAN_IDLE_STATE;
                        end if;
                        none_on    := (tran_once = '0' and ACK_NONE  = '1');
                        error_on   := (tran_err  = '1' or XFER_ERROR = '1' or ACK_ERROR = '1');
                    else
                        tran_state <= TRAN_OTHER_STATE;
                        none_on    := FALSE;
                        error_on   := (tran_err  = '1' or XFER_ERROR = '1');
                    end if;
                    if (ACK_NONE = '0') then
                        tran_once  <= '1';
                    end if;
                    if (ACK_ERROR ='1' or XFER_ERROR = '1') then
                        tran_err   <= '1';
                    end if;
                else
                    if (XFER_ERROR = '1') then
                        tran_err   <= '1';
                    end if;
                    none_on  := FALSE;
                    error_on := FALSE;
                end if;
                -------------------------------------------------------------------
                -- NONE FLAG  : ????????????????????????????????????????????????????????????????????????????????????
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    none_flag <= '0';
                elsif (next_state = DONE_STATE and none_on) then
                    none_flag <= '1';
                else
                    none_flag <= '0';
                end if;
                -------------------------------------------------------------------
                -- ERROR FLAG : ??????????????????????????????????????????????????????????????????????????????.
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    error_flag <= '0';
                elsif (next_state = DONE_STATE and error_on) then
                    error_flag <= '1';
                end if;
                -------------------------------------------------------------------
                -- ERROR BIT  : ??????????????????????????????????????????????????????????????????????????????.
                -------------------------------------------------------------------
                if    (reset_bit = '1') then
                    error_bit <= '0';
                elsif (next_state = DONE_STATE and error_on) then
                    error_bit <= '1';
                elsif (ERR_ST_L = '1' and ERR_ST_D = '0') then
                    error_bit <= '0';
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- Register Output Signals.
    -------------------------------------------------------------------------------
    RESET_Q      <= reset_bit;
    START_Q      <= start_bit;
    STOP_Q       <= stop_bit;
    PAUSE_Q      <= pause_bit;
    FIRST_Q      <= first_bit;
    LAST_Q       <= last_bit;
    DONE_EN_Q    <= done_en_bit;
    DONE_ST_Q    <= done_bit;
    ERR_ST_Q     <= error_bit;
    MODE_Q       <= mode_regs;
    STAT_Q       <= stat_regs;
    -------------------------------------------------------------------------------
    -- Status
    -------------------------------------------------------------------------------
    VALVE_OPEN   <= tran_state(2);
    TRAN_START   <= '1' when (transaction_start = TRUE) else '0';
    TRAN_BUSY    <= start_bit;
    TRAN_DONE    <= '1' when (curr_state = DONE_STATE ) else '0';
    TRAN_NONE    <= none_flag;
    TRAN_ERROR   <= error_flag;
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
    REQ_VALID    <= request_bit;
    REQ_FIRST    <= tran_state(0);
    REQ_LAST     <= last_bit;
end RTL;
