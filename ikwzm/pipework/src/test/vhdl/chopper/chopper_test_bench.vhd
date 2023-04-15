-----------------------------------------------------------------------------------
--!     @file    chopper_test_bench.vhd
--!     @brief   CHOPPER TEST BENCH :
--!              CHOPPER MODULEを検証するためのテストベンチ.
--!     @version 1.7.0
--!     @date    2018/3/21
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
-- コンポーネント宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
component  CHOPPER_TEST_BENCH
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
        FINISH      : out std_logic
    );
end component;
component  CHOPPER_FUNCTION_MODEL 
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
end component;
end COMPONENTS;
-----------------------------------------------------------------------------------
-- エンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH is
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
        FINISH      : out std_logic
    );
end     CHOPPER_TEST_BENCH;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH のアーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     WORK.COMPONENTS.CHOPPER_FUNCTION_MODEL;
architecture MODEL of CHOPPER_TEST_BENCH is
    signal      CLK             : std_logic;
    signal      RST             : std_logic;
    signal      CLR             : std_logic;
    signal      LOAD            : std_logic;
    signal      CHOP            : std_logic;
    signal      ADDR            : std_logic_vector(ADDR_BITS-1 downto 0);
    signal      SIZE            : std_logic_vector(SIZE_BITS-1 downto 0);
    signal      SEL             : std_logic_vector(MAX_PIECE downto MIN_PIECE);
    signal      COUNT           : std_logic_vector(COUNT_BITS-1 downto 0);
    signal      NONE            : std_logic;
    signal      LAST            : std_logic;
    signal      NEXT_NONE       : std_logic;
    signal      NEXT_LAST       : std_logic;
    signal      PSIZE           : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      NEXT_PSIZE      : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      VALID           : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
    signal      NEXT_VALID      : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
begin
    U: CHOPPER
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => GEN_VALID
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID
        );

    M: CHOPPER_FUNCTION_MODEL
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => GEN_VALID,
            VERBOSE       => VERBOSE
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID,
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH_ALL
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH_ALL is
end     CHOPPER_TEST_BENCH_ALL;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.CHOPPER_TEST_BENCH;
architecture MODEL of CHOPPER_TEST_BENCH_ALL is
    signal FINISH : std_logic;
begin
    BURST_GEN    :for BURST     in 1         to 1        generate
    MAX_SIZE_GEN :for MAX_SIZE  in 5         to 9        generate
    MIN_PIECE_GEN:for MIN_PIECE in 0         to MAX_SIZE generate
    MAX_PIECE_GEN:for MAX_PIECE in MIN_PIECE to MAX_SIZE generate
        TB:CHOPPER_TEST_BENCH 
            generic map (
                BURST         => BURST,
                MIN_PIECE     => MIN_PIECE,
                MAX_PIECE     => MAX_PIECE,
                MAX_SIZE      => MAX_SIZE,
                ADDR_BITS     => MAX_SIZE,
                SIZE_BITS     => MAX_SIZE,
                COUNT_BITS    => MAX_SIZE,
                PSIZE_BITS    => MAX_SIZE,
                GEN_VALID     => 1,
                VERBOSE       => 0
            )
            port map (
                FINISH        => FINISH
            );
    end generate;
    end generate;
    end generate;
    end generate;
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity NOTE;
        end if;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH_3_6_6
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH_3_6_6 is
    port    (FINISH      : out std_logic  );
end     CHOPPER_TEST_BENCH_3_6_6;
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     WORK.COMPONENTS.CHOPPER_FUNCTION_MODEL;
use     WORK.COMPONENTS.CHOPPER_TEST_BENCH;
architecture MODEL of CHOPPER_TEST_BENCH_3_6_6 is
    constant    BURST           : integer := 1;
    constant    MIN_PIECE       : integer := 3;
    constant    MAX_PIECE       : integer := 6;
    constant    MAX_SIZE        : integer := 6;
    constant    ADDR_BITS       : integer := 12;
    constant    SIZE_BITS       : integer := 12;
    constant    COUNT_BITS      : integer := 12;
    constant    PSIZE_BITS      : integer := 12;
    signal      CLK             : std_logic;
    signal      RST             : std_logic;
    signal      CLR             : std_logic;
    signal      LOAD            : std_logic;
    signal      CHOP            : std_logic;
    signal      ADDR            : std_logic_vector(ADDR_BITS-1 downto 0);
    signal      SIZE            : std_logic_vector(SIZE_BITS-1 downto 0);
    signal      SEL             : std_logic_vector(MAX_PIECE downto MIN_PIECE);
    signal      COUNT           : std_logic_vector(COUNT_BITS-1 downto 0);
    signal      NONE            : std_logic;
    signal      LAST            : std_logic;
    signal      NEXT_NONE       : std_logic;
    signal      NEXT_LAST       : std_logic;
    signal      PSIZE           : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      NEXT_PSIZE      : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      VALID           : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
    signal      NEXT_VALID      : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
begin
    U: CHOPPER
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID
        );

    M: CHOPPER_FUNCTION_MODEL
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1,
            VERBOSE       => 0
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID,
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH_7_12_24
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH_7_12_24 is
    port    (FINISH      : out std_logic  );
end     CHOPPER_TEST_BENCH_7_12_24;
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     WORK.COMPONENTS.CHOPPER_FUNCTION_MODEL;
use     WORK.COMPONENTS.CHOPPER_TEST_BENCH;
architecture MODEL of CHOPPER_TEST_BENCH_7_12_24 is
    constant    BURST           : integer :=  1;
    constant    MIN_PIECE       : integer :=  7;
    constant    MAX_PIECE       : integer := 12;
    constant    MAX_SIZE        : integer := 24;
    constant    ADDR_BITS       : integer := 24;
    constant    SIZE_BITS       : integer := 24;
    constant    COUNT_BITS      : integer := 24;
    constant    PSIZE_BITS      : integer := 24;
    signal      CLK             : std_logic;
    signal      RST             : std_logic;
    signal      CLR             : std_logic;
    signal      LOAD            : std_logic;
    signal      CHOP            : std_logic;
    signal      ADDR            : std_logic_vector(ADDR_BITS-1 downto 0);
    signal      SIZE            : std_logic_vector(SIZE_BITS-1 downto 0);
    signal      SEL             : std_logic_vector(MAX_PIECE downto MIN_PIECE);
    signal      COUNT           : std_logic_vector(COUNT_BITS-1 downto 0);
    signal      NONE            : std_logic;
    signal      LAST            : std_logic;
    signal      NEXT_NONE       : std_logic;
    signal      NEXT_LAST       : std_logic;
    signal      PSIZE           : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      NEXT_PSIZE      : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      VALID             : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
    signal      NEXT_VALID        : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
begin
    U: CHOPPER
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID
        );

    M: CHOPPER_FUNCTION_MODEL
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1,
            VERBOSE       => 1
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID,
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH_5_5_5
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH_5_5_5 is
    port    (FINISH      : out std_logic  );
end     CHOPPER_TEST_BENCH_5_5_5;
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     WORK.COMPONENTS.CHOPPER_FUNCTION_MODEL;
use     WORK.COMPONENTS.CHOPPER_TEST_BENCH;
architecture MODEL of CHOPPER_TEST_BENCH_5_5_5 is
    constant    BURST           : integer :=  1;
    constant    MIN_PIECE       : integer :=  5;
    constant    MAX_PIECE       : integer :=  5;
    constant    MAX_SIZE        : integer :=  5;
    constant    ADDR_BITS       : integer :=  5;
    constant    SIZE_BITS       : integer :=  5;
    constant    COUNT_BITS      : integer :=  5;
    constant    PSIZE_BITS      : integer :=  5;
    signal      CLK             : std_logic;
    signal      RST             : std_logic;
    signal      CLR             : std_logic;
    signal      LOAD            : std_logic;
    signal      CHOP            : std_logic;
    signal      ADDR            : std_logic_vector(ADDR_BITS-1 downto 0);
    signal      SIZE            : std_logic_vector(SIZE_BITS-1 downto 0);
    signal      SEL             : std_logic_vector(MAX_PIECE downto MIN_PIECE);
    signal      COUNT           : std_logic_vector(COUNT_BITS-1 downto 0);
    signal      NONE            : std_logic;
    signal      LAST            : std_logic;
    signal      NEXT_NONE       : std_logic;
    signal      NEXT_LAST       : std_logic;
    signal      PSIZE           : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      NEXT_PSIZE      : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      VALID           : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
    signal      NEXT_VALID      : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
begin
    U: CHOPPER
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID
        );

    M: CHOPPER_FUNCTION_MODEL
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1,
            VERBOSE       => 0
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID,
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH_6_9_9
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH_6_9_9 is
    port    (FINISH      : out std_logic  );
end     CHOPPER_TEST_BENCH_6_9_9;
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     WORK.COMPONENTS.CHOPPER_FUNCTION_MODEL;
use     WORK.COMPONENTS.CHOPPER_TEST_BENCH;
architecture MODEL of CHOPPER_TEST_BENCH_6_9_9 is
    constant    BURST           : integer :=  1;
    constant    MIN_PIECE       : integer :=  6;
    constant    MAX_PIECE       : integer :=  9;
    constant    MAX_SIZE        : integer :=  9;
    constant    ADDR_BITS       : integer :=  9;
    constant    SIZE_BITS       : integer :=  9;
    constant    COUNT_BITS      : integer :=  9;
    constant    PSIZE_BITS      : integer :=  9;
    signal      CLK             : std_logic;
    signal      RST             : std_logic;
    signal      CLR             : std_logic;
    signal      LOAD            : std_logic;
    signal      CHOP            : std_logic;
    signal      ADDR            : std_logic_vector(ADDR_BITS-1 downto 0);
    signal      SIZE            : std_logic_vector(SIZE_BITS-1 downto 0);
    signal      SEL             : std_logic_vector(MAX_PIECE downto MIN_PIECE);
    signal      COUNT           : std_logic_vector(COUNT_BITS-1 downto 0);
    signal      NONE            : std_logic;
    signal      LAST            : std_logic;
    signal      NEXT_NONE       : std_logic;
    signal      NEXT_LAST       : std_logic;
    signal      PSIZE           : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      NEXT_PSIZE      : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      VALID           : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
    signal      NEXT_VALID      : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
begin
    U: CHOPPER
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID
        );

    M: CHOPPER_FUNCTION_MODEL
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1,
            VERBOSE       => 0
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID,
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- CHOPPER_TEST_BENCH_5_5_5_NO_BURST
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CHOPPER_TEST_BENCH_5_5_5_NO_BURST is
    port    (FINISH      : out std_logic  );
end     CHOPPER_TEST_BENCH_5_5_5_NO_BURST;
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.CHOPPER;
use     WORK.COMPONENTS.CHOPPER_FUNCTION_MODEL;
use     WORK.COMPONENTS.CHOPPER_TEST_BENCH;
architecture MODEL of CHOPPER_TEST_BENCH_5_5_5_NO_BURST is
    constant    BURST           : integer :=  0;
    constant    MIN_PIECE       : integer :=  5;
    constant    MAX_PIECE       : integer :=  5;
    constant    MAX_SIZE        : integer :=  5;
    constant    ADDR_BITS       : integer :=  5;
    constant    SIZE_BITS       : integer :=  5;
    constant    COUNT_BITS      : integer :=  5;
    constant    PSIZE_BITS      : integer :=  5;
    signal      CLK             : std_logic;
    signal      RST             : std_logic;
    signal      CLR             : std_logic;
    signal      LOAD            : std_logic;
    signal      CHOP            : std_logic;
    signal      ADDR            : std_logic_vector(ADDR_BITS-1 downto 0);
    signal      SIZE            : std_logic_vector(SIZE_BITS-1 downto 0);
    signal      SEL             : std_logic_vector(MAX_PIECE downto MIN_PIECE);
    signal      COUNT           : std_logic_vector(COUNT_BITS-1 downto 0);
    signal      NONE            : std_logic;
    signal      LAST            : std_logic;
    signal      NEXT_NONE       : std_logic;
    signal      NEXT_LAST       : std_logic;
    signal      PSIZE           : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      NEXT_PSIZE      : std_logic_vector(PSIZE_BITS-1 downto 0);
    signal      VALID           : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
    signal      NEXT_VALID      : std_logic_vector(2**(MAX_PIECE)-1 downto 0);
begin
    U: CHOPPER
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID
        );

    M: CHOPPER_FUNCTION_MODEL
        generic map (
            BURST         => BURST,
            MIN_PIECE     => MIN_PIECE,
            MAX_PIECE     => MAX_PIECE,
            MAX_SIZE      => MAX_SIZE,
            ADDR_BITS     => ADDR_BITS,
            SIZE_BITS     => SIZE_BITS,
            COUNT_BITS    => COUNT_BITS,
            PSIZE_BITS    => PSIZE_BITS,
            GEN_VALID     => 1,
            VERBOSE       => 0
        )
        port map (
            CLK           => CLK,
            RST           => RST,
            CLR           => CLR,
            ADDR          => ADDR,
            SIZE          => SIZE,
            SEL           => SEL,
            LOAD          => LOAD,
            CHOP          => CHOP,
            COUNT         => COUNT,
            NONE          => NONE,
            LAST          => LAST,
            NEXT_NONE     => NEXT_NONE,
            NEXT_LAST     => NEXT_LAST,
            PSIZE         => PSIZE,
            NEXT_PSIZE    => NEXT_PSIZE,
            VALID         => VALID,
            NEXT_VALID    => NEXT_VALID,
            FINISH        => FINISH
        );
end MODEL;
