-----------------------------------------------------------------------------------
--!     @file    reducer_test_model.vhd
--!     @brief   TEST MODEL for REDUCER :
--!     @version 1.8.4
--!     @date    2020/11/7
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
package RANDOM_DATA_TABLE is
    procedure GET(
            WIDTH   : in  integer;
            OFFSET  : in  integer;
            ADDR    : in  integer;
            SIZE    : in  integer;
            LEN     : out integer;
            DATA    : out std_logic_vector;
            STRB    : out std_logic_vector;
            DONE    : out std_logic);
    constant  TABLE_SIZE : integer := 4096;
    constant  ERROR_CODE : std_logic_vector(7 downto 0) := std_logic_vector'("11001100");
end     RANDOM_DATA_TABLE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.uniform;
use     std.textio.all;
package body RANDOM_DATA_TABLE is

    type     DATA_TABLE_TYPE is array (INTEGER range <>) of std_logic_vector(7 downto 0);

    function DATA_TABLE_GEN(SIZE:integer) return DATA_TABLE_TYPE is
        variable table    : DATA_TABLE_TYPE(0 to SIZE-1);
        variable seed1    : integer := 1234;
        variable seed2    : integer := 5678;
        variable rnd_num  : real;
        variable pattern  : integer range 0 to 255;
    begin
        for i in table'range loop
            UNIFORM(seed1,seed2,rnd_num);
            pattern := integer(rnd_num*255.0);
            while (pattern = TO_INTEGER(unsigned(ERROR_CODE))) loop
                UNIFORM(seed1,seed2,rnd_num);
                pattern := integer(rnd_num*255.0);
            end loop;
            table(i) := std_logic_vector(TO_UNSIGNED(pattern,8));
        end loop;
        return table;
    end function;

    constant  DATA_TABLE  : DATA_TABLE_TYPE(0 to TABLE_SIZE-1) := DATA_TABLE_GEN(TABLE_SIZE);

    procedure GET(   WIDTH    : in    integer;
                     OFFSET   : in    integer;
                     ADDR     : in    integer;
                     SIZE     : in    integer;
                     LEN      : out   integer;
                     DATA     : out   std_logic_vector;
                     STRB     : out   std_logic_vector;
                     DONE     : out   std_logic) is
            variable o_data   :       std_logic_vector(8*WIDTH-1 downto 0);
            variable o_strb   :       std_logic_vector(  WIDTH-1 downto 0);
            variable f_strb   :       std_logic_vector(  WIDTH-1 downto 0);
            variable l_strb   :       std_logic_vector(  WIDTH-1 downto 0);
            variable length   :       integer;
            variable addr_end :       integer range 0 to TABLE_SIZE-1;
        begin
            addr_end := OFFSET + SIZE - 1;
            for i in f_strb'range loop
                if (i >= OFFSET) then
                    f_strb(i) := '1';
                else
                    f_strb(i) := '0';
                end if;
            end loop;
            for i in l_strb'range loop
                if (i <= addr_end) then
                    l_strb(i) := '1';
                else
                    l_strb(i) := '0';
                end if;
            end loop;
            if (addr_end < WIDTH) then
                DONE := '1';
            else
                DONE := '0';
            end if;
            o_strb := f_strb and l_strb;
            length := 0;
            for i in o_strb'range loop
                if (o_strb(i) = '1') then
                    length := length + 1;
                    o_data((i+1)*8-1 downto i*8) := DATA_TABLE(ADDR-OFFSET+i);
                else
                    o_data((i+1)*8-1 downto i*8) := ERROR_CODE;
                end if;
            end loop;
            DATA := o_data;
            STRB := o_strb;
            LEN  := length;
        end GET;
end     RANDOM_DATA_TABLE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  REDUCER_TEST_MODEL is
    generic (
        NAME          : string;
        DELAY         : time;
        WORD_BITS     : integer := 32;
        I_WIDTH       : integer :=  1;
        O_WIDTH       : integer :=  4;
        O_VAL_SIZE    : integer :=  4;
        O_SHIFT_MIN   : integer :=  4;
        O_SHIFT_MAX   : integer :=  4;
        I_JUSTIFIED   : integer :=  0;
        NO_VAL_SET    : integer :=  0;
        FLUSH_ENABLE  : integer :=  0;
        DEBUG_PRINT   : boolean :=  FALSE
    );
    port(
        CLK           : in  std_logic;
        RST           : out std_logic;
        CLR           : out std_logic;
        START         : out std_logic;
        OFFSET        : out std_logic_vector(O_WIDTH-1 downto 0);
        DONE          : out std_logic;
        FLUSH         : out std_logic;
        START_DATA    : out std_logic_vector((WORD_BITS)-1 downto 0);
        FLUSH_DATA    : out std_logic_vector((WORD_BITS)-1 downto 0);
        NO_VAL_DATA   : out std_logic_vector((WORD_BITS)-1 downto 0);
        I_ENABLE      : out std_logic;
        I_DATA        : out std_logic_vector(I_WIDTH*(WORD_BITS  )-1 downto 0);
        I_STRB        : out std_logic_vector(I_WIDTH*(WORD_BITS/8)-1 downto 0);
        I_FLUSH       : out std_logic;
        I_DONE        : out std_logic;
        I_VAL         : out std_logic;
        I_RDY         : in  std_logic := '0';
        O_ENABLE      : out std_logic;
        O_DATA        : in  std_logic_vector(O_WIDTH*(WORD_BITS  )-1 downto 0) := (others => '0');
        O_STRB        : in  std_logic_vector(O_WIDTH*(WORD_BITS/8)-1 downto 0) := (others => '1');
        O_FLUSH       : in  std_logic := '0';
        O_DONE        : in  std_logic := '0';
        O_VAL         : in  std_logic := '0';
        O_RDY         : out std_logic;
        O_SHIFT       : out std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN);
        BUSY          : in  std_logic;
        CLK_ENA       : out std_logic;
        FINISH        : out std_logic
    );
end     REDUCER_TEST_MODEL;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
use     WORK.RANDOM_DATA_TABLE;
library Dummy_Plug;
use     Dummy_Plug.util.BIN_TO_STRING;
use     Dummy_Plug.util.HEX_TO_STRING;
use     Dummy_Plug.util.INTEGER_TO_STRING;
architecture MODEL of REDUCER_TEST_MODEL is
    constant   I_BYTES        : integer := I_WIDTH*WORD_BITS/8;
    constant   O_BYTES        : integer := O_WIDTH*WORD_BITS/8;
    constant   HEX            : STRING(1 to 16) := "0123456789ABCDEF";
    signal     SCENARIO       : STRING(1 to 5)  := "NONE.";
    signal     RECV_REQ       : boolean;
    signal     RECV_ACK       : boolean;
    signal     RECV_DONE      : boolean;
    signal     RECV_FLUSH     : boolean;
    signal     RECV_EOD       : boolean;
    signal     RECV_ADDR      : integer;
    signal     RECV_SIZE      : integer;
    signal     RECV_MODE      : integer;
    signal     RECV_SHIFT     : integer;
    signal     i_valid        : std_logic;
    signal     o_ready        : std_logic;
    constant   NO_VAL_BYTE    : std_logic_vector(7 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    function INT_TO_STRING(arg:integer;len:integer;space:character) return STRING is
        variable str   : STRING(1 to len);
        variable value : integer;
    begin
        value  := arg;
        for i in str'right downto str'left loop
            if (value > 0) then
                case (value mod 10) is
                    when 0      => str(i) := '0';
                    when 1      => str(i) := '1';
                    when 2      => str(i) := '2';
                    when 3      => str(i) := '3';
                    when 4      => str(i) := '4';
                    when 5      => str(i) := '5';
                    when 6      => str(i) := '6';
                    when 7      => str(i) := '7';
                    when 8      => str(i) := '8';
                    when 9      => str(i) := '9';
                    when others => str(i) := 'X';
                end case;
            else
                if (i = str'right) then
                    str(i) := '0';
                else
                    str(i) := space;
                end if;
            end if;
            value := value / 10;
        end loop;
        return str;
    end INT_TO_STRING;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process 
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
        end WAIT_CLK;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        procedure RECV_START (ADDR,SIZE,MODE,SHIFT:integer;FLUSH,EOD:boolean) is
        begin
            RECV_REQ  <= TRUE;
            RECV_ADDR <= ADDR;
            RECV_SIZE <= SIZE;
            RECV_MODE <= MODE;
            RECV_FLUSH<= FLUSH;
            RECV_EOD  <= EOD;
            RECV_SHIFT<= SHIFT;
            wait until (CLK'event and CLK = '1' and RECV_ACK = TRUE);
            wait for DELAY;
            RECV_REQ  <= FALSE;
        end RECV_START;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        procedure RECV_END is
        begin
            wait until (CLK'event and CLK = '1' and RECV_ACK = FALSE);
            wait for DELAY;
        end RECV_END;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        procedure OUTPUT(ADDR,SIZE:integer;INITIALIZE,LAST,FLUSH:boolean) is
            variable data         : std_logic_vector(I_DATA'range);
            variable strb         : std_logic_vector(I_STRB'range);
            variable valid        : std_logic;
            variable end_of_data  : std_logic;
            variable pos          : integer;
            variable bytes        : integer;
            variable len          : integer;
            variable lo_pos       : integer;
            variable num          : integer;
        begin
            if (INITIALIZE and O_WIDTH > 1) then
                for i in OFFSET'range loop
                    if (i < ((ADDR rem O_BYTES)/(WORD_BITS/8))) then
                        OFFSET(i) <= '1';
                    else
                        OFFSET(i) <= '0';
                    end if;
                end loop;
                START <= '1';
            end if;
            pos   := ADDR;
            bytes := SIZE;
            while (bytes > 0) loop
                lo_pos := pos rem I_BYTES;
                RANDOM_DATA_TABLE.GET(I_BYTES,lo_pos,pos,bytes,len,data,strb,end_of_data);
                pos    := pos   + len;
                bytes  := bytes - len;
                if (I_JUSTIFIED > 0 and strb(0) = '0') then
                    num := 1;
                    for i in 1 to strb'high loop
                        if (strb(i) = '1') then
                            num := i;
                            exit;
                        end if;
                    end loop;
                    for i in strb'low to strb'high loop
                        if (i+num > strb'high) then
                            I_DATA(8*(i+1)-1 downto 8*i) <= (others => '0');
                            I_STRB(                   i) <= '0';
                        else
                            I_DATA(8*(i+1)-1 downto 8*i) <= data(8*(i+1+num)-1 downto 8*(i+num));
                            I_STRB(                   i) <= strb(i+num);
                        end if;
                    end loop;
                else
                    I_DATA <= data;
                    I_STRB <= strb;
                end if;
                if (LAST) then
                    I_DONE  <= end_of_data;
                else
                    I_DONE  <= '0';
                end if;
                if (FLUSH) then
                    I_FLUSH <= end_of_data;
                else
                    I_FLUSH <= '0';
                end if;
                I_VAL   <= '1';
                i_valid <= '1';
                wait until (CLK'event and CLK = '1' and I_RDY = '1');
                wait for DELAY;
                START   <= '0';
                I_VAL   <= '0';
                i_valid <= '0';
                I_DONE  <= '0';
                I_FLUSH <= '0';
                I_DATA  <= (others => '1');
                I_STRB  <= (others => '1');
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        procedure OUTPUT(ADDR,SIZE:integer) is
        begin
            OUTPUT(ADDR,SIZE,TRUE,TRUE,FALSE);
        end procedure;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        variable max_addr    : integer;
        variable max_size    : integer;
        variable addr        : integer;
        variable remain_size : integer;
        variable block_size  : integer;
        variable initialize  : boolean;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        procedure DONE_REQ is
        begin
            DONE <= '1';
            wait until (CLK'event and CLK = '1');
            wait for DELAY;
            DONE <= '0';
        end procedure;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        procedure FLUSH_REQ is
        begin
            FLUSH <= '1';
            wait until (CLK'event and CLK = '1');
            wait for DELAY;
            FLUSH <= '0';
        end procedure;
    begin
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        if (I_BYTES > O_BYTES) then
            max_addr := I_BYTES;
            max_size := (I_BYTES/O_BYTES)*(I_BYTES*5);
        else
            max_addr := O_BYTES;
            max_size := (O_BYTES/I_BYTES)*(O_BYTES*5);
        end if;
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report "Starting Run..." severity NOTE;
                       SCENARIO <= "START";
                       CLK_ENA  <= '1';
                       RST      <= '1';
                       CLR      <= '1';
                       START    <= '0';
                       OFFSET   <= (others => '0');
                       DONE     <= '0';
                       FLUSH    <= '0';
                       I_DATA   <= (others => '0');
                       I_STRB   <= (others => '0');
                       I_FLUSH  <= '0';
                       I_DONE   <= '0';
                       I_VAL    <= '0';
                       i_valid  <= '0';
                       I_ENABLE <= '1';
                       O_ENABLE <= '1';
                       for i in 0 to WORD_BITS/8-1 loop
                           START_DATA ((i+1)*8-1 downto i*8) <= NO_VAL_BYTE;
                           FLUSH_DATA ((i+1)*8-1 downto i*8) <= NO_VAL_BYTE;
                           NO_VAL_DATA((i+1)*8-1 downto i*8) <= NO_VAL_BYTE;
                       end loop;
        WAIT_CLK( 4);  RST      <= '0';
                       CLR      <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "1.0.0";wait for 0 ns;
        for size in 1 to max_size loop
            for pos in 0 to max_addr loop
                addr := pos*max_addr+pos;
                RECV_START(addr,size,0,O_WIDTH,FALSE,TRUE);
                OUTPUT    (addr,size  );
                RECV_END;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "2.0.0";wait for 0 ns;
        for size in 1 to max_size loop
            for pos in 0 to max_addr loop
                addr := pos*max_addr+pos;
                RECV_START(addr,size,1,O_WIDTH,FALSE,TRUE);
                OUTPUT    (addr,size  );
                RECV_END;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "3.0.0";wait for 0 ns;
        for size in 1 to max_size loop
            for pos in 0 to max_addr loop
                addr := pos*max_addr+pos;
                RECV_START(addr,size,2,O_WIDTH,FALSE,TRUE);
                OUTPUT    (addr,size  );
                RECV_END;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "4.0.0";wait for 0 ns;
        if (WORD_BITS = 8 and I_WIDTH > 1) then
            for size in 8 to 33 loop
                for block_size in 1 to 11 loop
                    addr := 0;
                    remain_size := size;
                    RECV_START(addr,size,0,O_WIDTH,FALSE,TRUE);
                    initialize := TRUE;
                    while (remain_size > 0) loop
                        if (remain_size <= block_size) then
                            OUTPUT(addr,remain_size,initialize, TRUE ,FALSE);
                            addr := addr + remain_size;
                            remain_size := 0;
                        else
                            OUTPUT(addr,block_size ,initialize, FALSE,FALSE);
                            addr := addr + block_size;
                            remain_size := remain_size - block_size;
                        end if;
                        initialize := FALSE;
                    end loop;
                    RECV_END;
                end loop;
            end loop;
        end if;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "5.0.0";wait for 0 ns;
        if (WORD_BITS = 8 and I_WIDTH > 1) then
            for size in 8 to 15 loop
                for block_size in 1 to 11 loop
                    for wait_count in 0 to 3 loop
                        addr := 0;
                        remain_size := size;
                        RECV_START(addr,size,0,O_WIDTH,FALSE,FALSE);
                        initialize := TRUE;
                        while (remain_size > 0) loop
                            if (remain_size <= block_size) then
                                OUTPUT(addr,remain_size,initialize, FALSE,FALSE);
                                addr := addr + remain_size;
                                remain_size := 0;
                            else
                                OUTPUT(addr,block_size ,initialize, FALSE,FALSE);
                                addr := addr + block_size;
                                remain_size := remain_size - block_size;
                            end if;
                            initialize := FALSE;
                        end loop;
                        WAIT_CLK(wait_count);
                        DONE_REQ;
                        RECV_END;
                    end loop;
                end loop;
            end loop;
        end if;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "6.0.0";wait for 0 ns;
        if (FLUSH_ENABLE > 0 and WORD_BITS = 8 and I_WIDTH > 1) then
            for size in 8 to 33 loop
                for block_size in 1 to 11 loop
                    addr := 0;
                    remain_size := size;
                    initialize := TRUE;
                    while (remain_size > 0) loop
                        assert false report NAME & ":" & SCENARIO &
                            " addr="        & INTEGER_TO_STRING(addr       ) &
                            " size="        & INTEGER_TO_STRING(size       ) &
                            " remain_size=" & INTEGER_TO_STRING(remain_size) &
                            " block_size="  & INTEGER_TO_STRING(block_size ) severity note;
                        if (remain_size <= block_size) then
                            RECV_START(addr,remain_size,0,O_WIDTH,FALSE,TRUE);
                            OUTPUT(addr,remain_size,initialize, TRUE ,FALSE);
                            RECV_END;
                            addr := addr + remain_size;
                            remain_size := 0;
                        else
                            RECV_START(addr,block_size, 0,O_WIDTH,TRUE, TRUE);
                            OUTPUT(addr,block_size ,initialize, FALSE,TRUE );
                            RECV_END;
                            addr := addr + block_size;
                            remain_size := remain_size - block_size;
                        end if;
                        initialize := FALSE;
                    end loop;
                end loop;
            end loop;
        end if;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "7.0.0";wait for 0 ns;
        for mode in 0 to 2 loop
            for size in 1 to max_size loop
                for pos in 0 to max_addr loop
                 -- SCENARIO(3 to 3) <= INT_TO_STRING(pos,1,'0');
                    for sft in O_WIDTH downto 1 loop
                     -- SCENARIO(5 to 5) <= INT_TO_STRING(sft,1,'0');
                        addr := pos*max_addr+pos;
                     -- assert false report NAME & ":" & SCENARIO &
                     --     " addr=" & INTEGER_TO_STRING(addr) &
                     --     " size=" & INTEGER_TO_STRING(size) &
                     --     " pos="  & INTEGER_TO_STRING(pos ) &
                     --     " sft="  & INTEGER_TO_STRING(sft ) severity note;
                        RECV_START(addr,size,mode,sft,FALSE,TRUE);
                        OUTPUT    (addr,size  );
                        RECV_END;
                    end loop;
                end loop;
            end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10); 
        SCENARIO <= "DONE.";
        WAIT_CLK(10); 
        assert(false) report NAME & " Run complete..." severity NOTE;
        FINISH  <= 'Z';
        CLK_ENA <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RECV:process
        variable addr        : integer;
        variable size        : integer;
        variable len         : integer;
        variable lo_pos      : integer;
        variable data        : std_logic_vector(O_DATA'range);
        variable exp_data    : std_logic_vector(O_DATA'range);
        variable strb        : std_logic_vector(O_STRB'range);
        variable end_of_data : std_logic;
        variable data_ok     : boolean;
        variable first       : boolean;
        variable shift_words : integer;
        variable shift_bytes : integer;
        variable o_size      : integer;
        function gen_o_shift(n:integer) return std_logic_vector is
            variable result  : std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN);
        begin
            for i in result'range loop
                if (i < n) then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            end loop;
            return result;
        end function;
    begin
        RECV_ACK  <= FALSE;
        RECV_DONE <= FALSE;
        O_SHIFT   <= (others => '0');
        O_RDY     <= '0';
        o_ready   <= '0';
        RECV_LOOP: loop
            wait until (CLK'event and CLK = '1' and RECV_REQ = TRUE);
            wait for DELAY;
            first       := TRUE;
            addr        := RECV_ADDR;
            size        := RECV_SIZE;
            shift_words := RECV_SHIFT;
            shift_bytes := shift_words*(WORD_BITS/8);
            lo_pos      := addr rem O_BYTES;
            RECV_ACK <= TRUE;
            RECV_DONE<= FALSE;
            O_SHIFT  <= gen_o_shift(shift_words);
            if (RECV_MODE = 0) then
                O_RDY   <= '1';
                o_ready <= '1';
            else
                O_RDY   <= '0';
                o_ready <= '0';
            end if;
            CHK_LOOP: loop
                wait until (CLK'event and CLK = '1' and O_VAL = '1');
                if (RECV_MODE > 0) then
                    if (RECV_MODE > 1) then
                        for i in 2 to RECV_MODE loop
                            wait until (CLK'event and CLK = '1');
                        end loop;
                    end if;
                    wait for DELAY;
                    O_RDY   <= '1';
                    o_ready <= '1';
                    wait until (CLK'event and CLK = '1' and O_VAL = '1');
                end if;
                RANDOM_DATA_TABLE.GET(O_BYTES,lo_pos,addr,size,len,data,strb,end_of_data);
                if (lo_pos >= shift_bytes) then
                    o_size := 0;
                    lo_pos := lo_pos - shift_bytes;
                else
                    o_size := shift_bytes - lo_pos;
                    lo_pos := 0;
                end if;
                if (len < o_size) then
                    addr   := addr + len;
                    size   := size - len;
                else
                    addr   := addr + o_size;
                    size   := size - o_size;
                end if;
                assert (O_STRB = strb) report NAME & ":" & SCENARIO & " Mismatch O_STRB=" & BIN_TO_STRING(O_STRB) & " /= " & BIN_TO_STRING(strb) severity FAILURE;
                data_ok  := TRUE;
                exp_data := (others => '0');
                for i in O_STRB'range loop
                    if (O_STRB(i) = '1') then
                        if (O_DATA((i+1)*8-1 downto i*8) /= data((i+1)*8-1 downto i*8)) then
                            data_ok := FALSE;
                        end if;
                        exp_data((i+1)*8-1 downto i*8) := data((i+1)*8-1 downto i*8);
                    end if;
                    if (WORD_BITS = 8 and NO_VAL_SET > i and O_STRB(i) = '0') then
                        if (O_DATA((i+1)*8-1 downto i*8) /= NO_VAL_BYTE) then
                            data_ok := FALSE;
                        end if;
                        exp_data((i+1)*8-1 downto i*8) := NO_VAL_BYTE;
                    end if;
                end loop;
                assert (data_ok) report NAME & ":" & SCENARIO & " Mismatch O_DATA=" & HEX_TO_STRING(O_DATA) & " /= " & HEX_TO_STRING(exp_data) severity FAILURE;
                if (RECV_EOD = TRUE) then
                    if (FLUSH_ENABLE > 0 and RECV_FLUSH) then
                        assert (O_FLUSH = end_of_data)
                            report NAME & ":" & SCENARIO & " Mismatch O_FLUSH" severity FAILURE;
                    else
                        assert (O_DONE  = end_of_data)
                            report NAME & ":" & SCENARIO & " Mismatch O_DONE"  severity FAILURE;
                    end if;
                end if;
                exit CHK_LOOP when  (size <= 0);
                wait for DELAY;
                if (RECV_MODE > 0) then
                    O_RDY   <= '0';
                    o_ready <= '0';
                end if;
            end loop;
            RECV_DONE<= TRUE;
            if (RECV_EOD = FALSE) then
                if (FLUSH_ENABLE > 0 and RECV_FLUSH) then
                    if (O_FLUSH = '0') then
                        wait until (CLK'event and CLK = '1' and O_FLUSH = '1');
                    end if;
                else
                    if (O_DONE  = '0') then
                        wait until (CLK'event and CLK = '1' and O_DONE  = '1');
                    end if;
                end if;
            end if;
            wait for DELAY;
            RECV_ACK <= FALSE;
            RECV_DONE<= FALSE;
            O_RDY    <= '0';
            o_ready  <= '0';
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    CHECK_BUSY: process begin 
        RECV_LOOP: loop
            wait until (CLK'event and CLK = '1' and RECV_ACK = TRUE);
            CHK_LOOP_0: loop
                wait until (CLK'event and CLK = '1');
                assert (BUSY = '0') 
                    report NAME & ":" & SCENARIO & " Mismatch BUSY /= '0'" severity FAILURE;
                exit CHK_LOOP_0 when (i_valid = '1' and I_RDY = '1');
            end loop;
            CHK_LOOP_1: loop
                wait until (CLK'event and CLK = '1');
                assert (BUSY = '1') 
                    report NAME & ":" & SCENARIO & " Mismatch BUSY /= '1'" severity FAILURE;
                exit CHK_LOOP_1 when (O_VAL = '1' and o_ready = '1' and O_DONE  = '1') or
                                     (O_VAL = '1' and o_ready = '1' and O_FLUSH = '1');
            end loop;
            CHK_LOOP_2: loop
                wait until (CLK'event and CLK = '1');
                if (O_DONE = '1' or O_FLUSH = '1') then
                    assert (BUSY = '1') 
                        report NAME & ":" & SCENARIO & " Mismatch BUSY /= '1'" severity FAILURE;
                else
                    assert (BUSY = '0') 
                        report NAME & ":" & SCENARIO & " Mismatch(1->0) BUSY /= '0'" severity FAILURE;
                end if;
                exit CHK_LOOP_2 when (RECV_ACK = FALSE);
            end loop;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DEBUG_PRINT_BLOCK: if (DEBUG_PRINT = TRUE) generate
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process (SCENARIO) begin
            case SCENARIO is
                when "NONE." | "START" =>
                    null;
                when "DONE." =>
                    assert FALSE report NAME & " Scenario All Done..." severity NOTE;
                when others  =>
                    assert FALSE report NAME & ":" & SCENARIO & " Start..." severity NOTE;
            end case;
        end process;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process
            variable  text_line      : LINE;
            constant  TIME_WIDTH     : integer := 13;
            constant  TAG_WIDTH      : integer := 32;
            procedure p(M:in string) is
            begin
                if    (TAG_WIDTH > 0) then
                    WRITE(text_line, NAME, RIGHT, abs(TAG_WIDTH));
                elsif (TAG_WIDTH < 0) then
                    WRITE(text_line, NAME, LEFT , abs(TAG_WIDTH));
                end if;
                WRITE(text_line, M);
                WRITELINE(OUTPUT, text_line);
            end procedure;
            procedure p(T:in time;M:in string) is
            begin
                if    (TAG_WIDTH > 0) then
                    WRITE(text_line, NAME, RIGHT, abs(TAG_WIDTH));
                elsif (TAG_WIDTH < 0) then
                    WRITE(text_line, NAME, LEFT , abs(TAG_WIDTH));
                end if;
                if    (TIME_WIDTH > 0) then
                    WRITE(text_line, T, RIGHT, abs(TIME_WIDTH));
                elsif (TIME_WIDTH < 0) then
                    WRITE(text_line, T, LEFT , abs(TIME_WIDTH));
                end if;
                WRITE(text_line, M);
                WRITELINE(OUTPUT, text_line);
            end procedure;
        begin
            MAIN_LOOP:loop
                wait until (CLK'event and CLK = '1');
                p(Now, string'("|") & HEX_TO_STRING(O_DATA ) &
                       string'("|") & BIN_TO_STRING(O_STRB ) &
                       string'("|") & BIN_TO_STRING(O_DONE ) &
                       string'(" ") & BIN_TO_STRING(O_FLUSH) &
                       string'(" ") & BIN_TO_STRING(O_VAL  ) &
                       string'(" ") & BIN_TO_STRING(o_ready) &
                       string'("|"));
            end loop;
        end process;
    end generate;
end MODEL;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
    component REDUCER_TEST_MODEL is
        generic (
            NAME        : string;
            DELAY       : time;
            WORD_BITS   : integer;
            I_WIDTH     : integer;
            O_WIDTH     : integer;
            O_VAL_SIZE  : integer;
            O_SHIFT_MIN : integer;
            O_SHIFT_MAX : integer;
            NO_VAL_SET  : integer;
            I_JUSTIFIED : integer;
            FLUSH_ENABLE: integer
        );
        port(
            CLK         : in  std_logic;
            RST         : out std_logic;
            CLR         : out std_logic;
            START       : out std_logic;
            OFFSET      : out std_logic_vector(O_WIDTH-1 downto 0);
            DONE        : out std_logic;
            FLUSH       : out std_logic;
            START_DATA  : out std_logic_vector((WORD_BITS  )-1 downto 0);
            FLUSH_DATA  : out std_logic_vector((WORD_BITS  )-1 downto 0);
            NO_VAL_DATA : out std_logic_vector((WORD_BITS  )-1 downto 0);
            I_ENABLE    : out std_logic;
            I_DATA      : out std_logic_vector(I_WIDTH*(WORD_BITS  )-1 downto 0);
            I_STRB      : out std_logic_vector(I_WIDTH*(WORD_BITS/8)-1 downto 0);
            I_FLUSH     : out std_logic;
            I_DONE      : out std_logic;
            I_VAL       : out std_logic;
            I_RDY       : in  std_logic := '0';
            O_ENABLE    : out std_logic;
            O_DATA      : in  std_logic_vector(O_WIDTH*(WORD_BITS  )-1 downto 0) := (others => '0');
            O_STRB      : in  std_logic_vector(O_WIDTH*(WORD_BITS/8)-1 downto 0) := (others => '1');
            O_FLUSH     : in  std_logic := '0';
            O_DONE      : in  std_logic := '0';
            O_VAL       : in  std_logic := '0';
            O_RDY       : out std_logic;
            O_SHIFT     : out std_logic_vector(O_SHIFT_MAX downto O_SHIFT_MIN);
            BUSY        : in  std_logic;
            CLK_ENA     : out std_logic;
            FINISH      : out std_logic
        );
    end component;
end COMPONENTS;
