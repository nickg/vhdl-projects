-----------------------------------------------------------------------------------
--!     @file    reader_test_1.vhd
--!     @brief   TEST BENCH No.1 for DUMMY_PLUG.READER
--!     @version 1.7.1
--!     @date    2017/3/20
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
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.READER;
use     DUMMY_PLUG.READER.all;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.BOOLEAN_TO_STRING;
entity  DUMMY_PLUG_READER_TEST_1 is
    generic (
        TEST_FILE : STRING  := "../../../src/test/scenarios/core/reader_test_1.snr"
    );
end     DUMMY_PLUG_READER_TEST_1;
architecture MODEL of DUMMY_PLUG_READER_TEST_1 is
begin
    process
        constant  NAME      : STRING  := "DUMMY_PLUG_READER_TEST_1";
        variable  text_line : LINE;
        variable  debug     : boolean := FALSE;
        file      stream    : TEXT;
        variable  r         : READER.READER_TYPE := READER.NEW_READER(NAME,TEST_FILE);
        variable  get_event : READER.EVENT_TYPE;
        variable  good      : boolean;
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
        procedure event(
                      exp_event     : in  READER.EVENT_TYPE
        ) is
            variable  get_event     :     READER.EVENT_TYPE;
            variable  get_good      :     boolean;
        begin
            if (debug) then
                WRITE(text_line, NAME & "::event(" & READER.EVENT_TO_STRING(exp_event) & ") begin");
                WRITELINE(OUTPUT, text_line);
                READER.DEBUG_DUMP(r);
                r.debug_mode := 1;
            else
                r.debug_mode := 0;
            end if;
            READER.SEEK_EVENT(r, stream, get_event);
            assert(get_event = exp_event)
                report   NAME & " Mismatch SEEK_EVENT=>"  &
                         READER.EVENT_TO_STRING(get_event) & " /= "&
                         READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            READER.READ_EVENT(r, stream, get_event, get_good);
            if (debug) then
                READER.DEBUG_DUMP(r);
                WRITE(text_line, NAME & "::event end");
                WRITELINE(OUTPUT, text_line);
            end if;
            assert(get_good)
                report   NAME & " Error Get " &
                         READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
        end procedure;
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
        procedure event(
                      exp_event     : in  READER.EVENT_TYPE;
                      exp_value     : in  integer
        ) is
            variable  get_event     :     READER.EVENT_TYPE;
            variable  get_value     :     integer;
            variable  get_good      :     boolean;
        begin
            if (debug) then
                WRITE(text_line, NAME & "::event(" & READER.EVENT_TO_STRING(exp_event) & ") begin");
                WRITELINE(OUTPUT, text_line);
                READER.DEBUG_DUMP(r);
                r.debug_mode := 1;
            else
                r.debug_mode := 0;
            end if;
            READER.SEEK_EVENT(r, stream, get_event);
            assert(get_event = exp_event)
                report   NAME & " Mismatch SEEK_EVENT=>"  &
                         READER.EVENT_TO_STRING(get_event) & " /= " &
                         READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            READER.READ_INTEGER(r, stream, get_value, get_good);
            if (debug) then
                READER.DEBUG_DUMP(r);
                WRITE(text_line, NAME & "::event end");
                WRITELINE(OUTPUT, text_line);
            end if;
            assert(get_good)
                report   NAME & " Error Get " &
                         READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            assert(get_value = exp_value)
                report   NAME & " Mismatch READ_INTEGER=>" &
                         HEX_TO_STRING(get_value,32) & " /= " &
                         HEX_TO_STRING(exp_value,32) 
                severity FAILURE;
        end procedure;
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
        procedure event(
                      exp_event     : in  READER.EVENT_TYPE;
                      exp_value     : in  string
        ) is
            variable  get_event     :     READER.EVENT_TYPE;
            variable  get_value     :     string(1 to 128);
            variable  get_len       :     integer;
            variable  get_size      :     integer;
            variable  get_good      :     boolean;
        begin
            if (debug) then
                WRITE(text_line, NAME & "::event(" & READER.EVENT_TO_STRING(exp_event) & ") begin");
                WRITELINE(OUTPUT, text_line);
                READER.DEBUG_DUMP(r);
                r.debug_mode := 1;
            else
                r.debug_mode := 0;
            end if;
            READER.SEEK_EVENT(r, stream, get_event);
            assert(get_event = exp_event)
                report   NAME & " Mismatch SEEK_EVENT=>" &
                         READER.EVENT_TO_STRING(get_event) & " /= "&
                         READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            READER.READ_STRING (r, stream, get_value, get_len, get_size, get_good);
            if (debug) then
                READER.DEBUG_DUMP(r);
                WRITE(text_line, NAME & "::READ_STRING=>""" & get_value(1 to get_len) & """");
                WRITELINE(OUTPUT, text_line);
                WRITE(text_line, NAME & "::event end");
                WRITELINE(OUTPUT, text_line);
            end if;
            assert(get_good)
                report   NAME & " Error READ " & READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            assert(get_value(1 to get_len) = exp_value)
                report   NAME & " Mismatch READ_" & READER.EVENT_TO_STRING(exp_event) & """" &
                         get_value(1 to get_len) & """/=""" & exp_value & """"
                severity FAILURE;
        end procedure;
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
        procedure event(
                      exp_event     : in  READER.EVENT_TYPE;
                      exp_value     : in  boolean
        ) is
            variable  get_event     :     READER.EVENT_TYPE;
            variable  get_value     :     boolean;
            variable  get_good      :     boolean;
        begin
            if (debug) then
                WRITE(text_line, NAME & "::event(" & READER.EVENT_TO_STRING(exp_event) & ") begin");
                WRITELINE(OUTPUT, text_line);
                READER.DEBUG_DUMP(r);
                r.debug_mode := 1;
            else
                r.debug_mode := 0;
            end if;
            READER.SEEK_EVENT(r, stream, get_event);
            assert(get_event = exp_event)
                report   NAME & " Mismatch SEEK_EVENT=>" &
                         READER.EVENT_TO_STRING(get_event) & " /= "&
                         READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            READER.READ_BOOLEAN (r, stream, get_value, get_good);
            if (debug) then
                READER.DEBUG_DUMP(r);
                WRITE(text_line, NAME & "::READ_BOOLEAN=>""" & BOOLEAN_TO_STRING(get_value) & """");
                WRITELINE(OUTPUT, text_line);
                WRITE(text_line, NAME & "::event end");
                WRITELINE(OUTPUT, text_line);
            end if;
            assert(get_good)
                report   NAME & " Error READ " & READER.EVENT_TO_STRING(exp_event)
                severity FAILURE;
            assert(get_value = exp_value)
                report   NAME & " Mismatch READ_" & READER.EVENT_TO_STRING(exp_event) & """" &
                         BOOLEAN_TO_STRING(get_value) & """/=""" & BOOLEAN_TO_STRING(exp_value) & """"
                severity FAILURE;
        end procedure;
    begin
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
        file_open(stream, TEST_FILE, READ_MODE);
        --------------------------------------------------------------------------
        -- reader_test_1 1
        --------------------------------------------------------------------------
        event(READER.EVENT_DIRECTIVE                 );
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   , 1              );
        event(READER.EVENT_SCALAR   , 2              );
        event(READER.EVENT_SCALAR   , 3              );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "A"            );
        event(READER.EVENT_SCALAR   , "A"            );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SCALAR   , 4              );
        event(READER.EVENT_SCALAR   , 16#01234567#   );
        event(READER.EVENT_SCALAR   , 16#89AB#       );
        event(READER.EVENT_SCALAR   , 16#CDEF#       );
        event(READER.EVENT_SCALAR   ,  8#76543210#   );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SCALAR   , TRUE           );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SCALAR   , FALSE          );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 2
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "a"            );
        event(READER.EVENT_SCALAR   ,  1             );
        event(READER.EVENT_SCALAR   , "b"            );
        event(READER.EVENT_SCALAR   ,  2             );
        event(READER.EVENT_SCALAR   , "c"            );
        event(READER.EVENT_SCALAR   ,  3             );
        event(READER.EVENT_SCALAR   , "d"            );
        event(READER.EVENT_SCALAR   ,  4             );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 3
        --------------------------------------------------------------------------
        event(READER.EVENT_DIRECTIVE                 );
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   , "::vector"     );
        event(READER.EVENT_SCALAR   , ": - ()"       );
        event(READER.EVENT_SCALAR   , "Up, up, and away!");
        event(READER.EVENT_SCALAR   , "-123"         );
        event(READER.EVENT_SCALAR   , "http://example.com/foo#bar");
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   , "::vector"     );
        event(READER.EVENT_SCALAR   , ": - ()"       );
        event(READER.EVENT_SCALAR   , "Up, up, and away!");
        event(READER.EVENT_SCALAR   , "-123"         );
        event(READER.EVENT_SCALAR   , "http://example.com/foo#bar");
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 4
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "a"            );
        event(READER.EVENT_SCALAR   ,  1             );
        event(READER.EVENT_SCALAR   , "b"            );
        event(READER.EVENT_ANCHOR   , "anchor_b"     );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,  1             );
        event(READER.EVENT_SCALAR   ,  2             );
        event(READER.EVENT_SCALAR   ,  3             );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SCALAR   , "c"            );
        event(READER.EVENT_SCALAR   ,  3             );
        event(READER.EVENT_SCALAR   , "d"            );
        event(READER.EVENT_ALIAS    , "anchor_b"     );
        event(READER.EVENT_SCALAR   , "e"            );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,  4             );
        event(READER.EVENT_SCALAR   ,  5             );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 5
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "a"            );
        event(READER.EVENT_SCALAR   ,  1             );
        event(READER.EVENT_SCALAR   , "b"            );
        event(READER.EVENT_SCALAR   ,  2             );
        event(READER.EVENT_SCALAR   , "c"            );
        event(READER.EVENT_SCALAR   ,  3             );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,  4             );
        event(READER.EVENT_SCALAR   ,  5             );
        event(READER.EVENT_SCALAR   ,  6             );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,  7             );
        event(READER.EVENT_SCALAR   ,  8             );
        event(READER.EVENT_SCALAR   ,  9             );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,  10            );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SCALAR   ,  11            );
        event(READER.EVENT_SCALAR   ,"12  13   14"   );
        event(READER.EVENT_SCALAR   ,  15            );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 6
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "a"            );
        event(READER.EVENT_SCALAR   , "A"            );
        event(READER.EVENT_SCALAR   , "bb"           );
        event(READER.EVENT_SCALAR   , "BB"           );
        event(READER.EVENT_SCALAR   , "ccc"          );
        event(READER.EVENT_SCALAR   , "CCC"          );
        event(READER.EVENT_SCALAR   , "d"            );
        event(READER.EVENT_SCALAR   , "D"            );
        event(READER.EVENT_SCALAR   , "e"            );
        event(READER.EVENT_SCALAR   , "E"            );
        event(READER.EVENT_SCALAR   , "f"            );
        event(READER.EVENT_SCALAR   , "a b c"        );
        event(READER.EVENT_SCALAR   , "g"            );
        event(READER.EVENT_SCALAR   , "G"            );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 7
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "A"            );
        event(READER.EVENT_SCALAR   , "a"            );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "B"            );
        event(READER.EVENT_SCALAR   , "b"            );
        event(READER.EVENT_SCALAR   , "C"            );
        event(READER.EVENT_SCALAR   , "c"            );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   , 1              );
        event(READER.EVENT_SCALAR   , 2              );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   , "D"            );
        event(READER.EVENT_SCALAR   , "d"            );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SCALAR   , 3              );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 8
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"BUS"           );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"A"             );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"ADDR"          );
        event(READER.EVENT_SCALAR   ,"0x00000010"    );
        event(READER.EVENT_SCALAR   ,"WRITE"         );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,2               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"ADDR"          );
        event(READER.EVENT_SCALAR   ,"0x00000020"    );
        event(READER.EVENT_SCALAR   ,"WRITE"         );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SCALAR   ,"W"             );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,"0x00000000"    );
        event(READER.EVENT_SCALAR   ,"LAST"          );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"A.VAL"         );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"A.RDY"         );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,"0x00000000"    );
        event(READER.EVENT_SCALAR   ,"LAST"          );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,"0x00000001"    );
        event(READER.EVENT_SCALAR   ,"LAST"          );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,"0x00000002"    );
        event(READER.EVENT_SCALAR   ,"LAST"          );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,"0x00000003"    );
        event(READER.EVENT_SCALAR   ,"LAST"          );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SCALAR   ,"B"             );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RESP"          );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_SCALAR   ,"R"             );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,2               );
        event(READER.EVENT_SCALAR   ,"VAL"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"RDY"           );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,"0x00000004"    );
        event(READER.EVENT_SCALAR   ,"RESP"          );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_SCALAR   ,"LAST"          );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"T"             );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,3               );
        event(READER.EVENT_SCALAR   ,"ADDR"          );
        event(READER.EVENT_SCALAR   ,"0x00000020"    );
        event(READER.EVENT_SCALAR   ,"WRITE"         );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"0x00"          );
        event(READER.EVENT_SCALAR   ,"0x01"          );
        event(READER.EVENT_SCALAR   ,"0x02"          );
        event(READER.EVENT_SCALAR   ,"0x03"          );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"ID"            );
        event(READER.EVENT_SCALAR   ,4               );
        event(READER.EVENT_SCALAR   ,"ADDR"          );
        event(READER.EVENT_SCALAR   ,"0x00000020"    );
        event(READER.EVENT_SCALAR   ,"WRITE"         );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"0x00"          );
        event(READER.EVENT_SCALAR   ,"0x01"          );
        event(READER.EVENT_SCALAR   ,"0x02"          );
        event(READER.EVENT_SCALAR   ,"0x03"          );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 9
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"WAIT"          );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"VALID"         );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_SCALAR   ,"READY"         );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"WAIT"          );
        READER.SEEK_EVENT(r, stream, get_event);
        SKIP_EVENT(r, stream, get_event, good);
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- reader_test_1 10
        --------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_SEQ_BEGIN                 );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"JSON"          );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"VALID"         );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_SCALAR   ,"READY"         );
        event(READER.EVENT_SCALAR   ,0               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"JSON"          );
        event(READER.EVENT_MAP_BEGIN                 );
        event(READER.EVENT_SCALAR   ,"DATA"          );
        event(READER.EVENT_SCALAR   ,18              );
        event(READER.EVENT_SCALAR   ,"STRB"          );
        event(READER.EVENT_SCALAR   ,1               );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_MAP_END                   );
        event(READER.EVENT_SEQ_END                   );
        event(READER.EVENT_DOC_END                   );
        --------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        event(READER.EVENT_DOC_BEGIN                 );
        event(READER.EVENT_DOC_END                   );
        event(READER.EVENT_STREAM_END                );
        assert(false)
            report   NAME & " Run complete..."
            severity NOTE;
        wait;
    end process;
end MODEL;
