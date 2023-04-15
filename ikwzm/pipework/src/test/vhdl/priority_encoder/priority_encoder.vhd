-----------------------------------------------------------------------------------
--!     @file    priority_encoder
--!     @brief   Sample for Priority Encoder Procedures Package.
--!     @version 1.5.1
--!     @date    2013/8/9
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
entity  PRIORITY_ENCODER is
    generic (
        MSB     : boolean := FALSE;
        D_LOW   : integer :=   0;
        D_HIGH  : integer := 255;
        Q_WIDTH : integer :=   8
    );
    port (
        CLK     : in  std_logic;
        RST     : in  std_logic;
        D       : in  std_logic_vector(D_HIGH downto D_LOW);
        Q       : out std_logic_vector(Q_WIDTH-1  downto 0);
        Z       : out std_logic
    );
end PRIORITY_ENCODER;
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.Priority_Encoder_Procedures.Priority_Encode_To_Binary_Intricately;
architecture RTL_for_ALTERA of PRIORITY_ENCODER is
    signal i_data : std_logic_vector(D'range);
begin
    process (CLK, RST)
        variable o_data  : std_logic_vector(Q_WIDTH-1  downto 0);
        variable o_valid : std_logic;
    begin
        if (RST = '1') then
            i_data <= (others => '0');
            Q      <= (others => '0');
            Z      <= '0';
        elsif (CLK'event and CLK = '1') then
            Priority_Encode_To_Binary_Intricately(
                High_to_Low => MSB,
                Binary_Len  => Q_WIDTH,
                Reduce_Len  => 16,
                Min_Dec_Len => 20,
                Max_Dec_Len => 64,
                Data        => i_data,
                Output      => o_data,
                Valid       => o_valid
            );
            i_data <= D;
            Q <= o_data;
            Z <= not o_valid;
        end if;
    end process;
end RTL_for_ALTERA;

