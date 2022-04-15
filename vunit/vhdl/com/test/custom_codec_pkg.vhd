library vunit_lib;
use vunit_lib.string_ops.all;
context vunit_lib.com_context;
use vunit_lib.queue_pkg.all;
use vunit_lib.queue_2008p_pkg.all;

use std.textio.all;

use work.custom_types_pkg.all;

library ieee;
library tb_com_lib;
use ieee.std_logic_1164.all;
use work.constants_pkg.all;
use tb_com_lib.more_constants_pkg.all;

package custom_codec_pkg is
  function encode (
    constant data : record1_t)
    return string;
  alias encode_record1_t is encode[record1_t return string];
  function decode (
    constant code : string)
    return record1_t;
  alias decode_record1_t is decode[string return record1_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record1_t);
  alias decode_record1_t is decode[string, positive, record1_t];
  procedure push(queue : queue_t; value : record1_t);
  impure function pop(queue : queue_t) return record1_t;
  alias push_record1_t is push[queue_t, record1_t];
  alias pop_record1_t is pop[queue_t return record1_t];
  procedure push(msg : msg_t; value : record1_t);
  impure function pop(msg : msg_t) return record1_t;
  alias push_record1_t is push[msg_t, record1_t];
  alias pop_record1_t is pop[msg_t return record1_t];

  function to_string (
    constant data : record1_t)
    return string;

  function encode (
    constant data : record2_t)
    return string;
  alias encode_record2_t is encode[record2_t return string];
  function decode (
    constant code : string)
    return record2_t;
  alias decode_record2_t is decode[string return record2_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record2_t);
  alias decode_record2_t is decode[string, positive, record2_t];
  procedure push(queue : queue_t; value : record2_t);
  impure function pop(queue : queue_t) return record2_t;
  alias push_record2_t is push[queue_t, record2_t];
  alias pop_record2_t is pop[queue_t return record2_t];
  procedure push(msg : msg_t; value : record2_t);
  impure function pop(msg : msg_t) return record2_t;
  alias push_record2_t is push[msg_t, record2_t];
  alias pop_record2_t is pop[msg_t return record2_t];

  function to_string (
    constant data : record2_t)
    return string;

  function encode (
    constant data : record3_t)
    return string;
  alias encode_record3_t is encode[record3_t return string];
  function decode (
    constant code : string)
    return record3_t;
  alias decode_record3_t is decode[string return record3_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record3_t);
  alias decode_record3_t is decode[string, positive, record3_t];
  procedure push(queue : queue_t; value : record3_t);
  impure function pop(queue : queue_t) return record3_t;
  alias push_record3_t is push[queue_t, record3_t];
  alias pop_record3_t is pop[queue_t return record3_t];
  procedure push(msg : msg_t; value : record3_t);
  impure function pop(msg : msg_t) return record3_t;
  alias push_record3_t is push[msg_t, record3_t];
  alias pop_record3_t is pop[msg_t return record3_t];

  function to_string (
    constant data : record3_t)
    return string;

  function encode (
    constant data : record4_t)
    return string;
  alias encode_record4_t is encode[record4_t return string];
  function decode (
    constant code : string)
    return record4_t;
  alias decode_record4_t is decode[string return record4_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record4_t);
  alias decode_record4_t is decode[string, positive, record4_t];
  procedure push(queue : queue_t; value : record4_t);
  impure function pop(queue : queue_t) return record4_t;
  alias push_record4_t is push[queue_t, record4_t];
  alias pop_record4_t is pop[queue_t return record4_t];
  procedure push(msg : msg_t; value : record4_t);
  impure function pop(msg : msg_t) return record4_t;
  alias push_record4_t is push[msg_t, record4_t];
  alias pop_record4_t is pop[msg_t return record4_t];

  function to_string (
    constant data : record4_t)
    return string;

  function encode (
    constant data : record5_t)
    return string;
  alias encode_record5_t is encode[record5_t return string];
  function decode (
    constant code : string)
    return record5_t;
  alias decode_record5_t is decode[string return record5_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record5_t);
  alias decode_record5_t is decode[string, positive, record5_t];
  procedure push(queue : queue_t; value : record5_t);
  impure function pop(queue : queue_t) return record5_t;
  alias push_record5_t is push[queue_t, record5_t];
  alias pop_record5_t is pop[queue_t return record5_t];
  procedure push(msg : msg_t; value : record5_t);
  impure function pop(msg : msg_t) return record5_t;
  alias push_record5_t is push[msg_t, record5_t];
  alias pop_record5_t is pop[msg_t return record5_t];

  function to_string (
    constant data : record5_t)
    return string;

  function encode (
    constant data : record6_t)
    return string;
  alias encode_record6_t is encode[record6_t return string];
  function decode (
    constant code : string)
    return record6_t;
  alias decode_record6_t is decode[string return record6_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record6_t);
  alias decode_record6_t is decode[string, positive, record6_t];
  procedure push(queue : queue_t; value : record6_t);
  impure function pop(queue : queue_t) return record6_t;
  alias push_record6_t is push[queue_t, record6_t];
  alias pop_record6_t is pop[queue_t return record6_t];
  procedure push(msg : msg_t; value : record6_t);
  impure function pop(msg : msg_t) return record6_t;
  alias push_record6_t is push[msg_t, record6_t];
  alias pop_record6_t is pop[msg_t return record6_t];

  function to_string (
    constant data : record6_t)
    return string;

  function encode (
    constant data : record7_t)
    return string;
  alias encode_record7_t is encode[record7_t return string];
  function decode (
    constant code : string)
    return record7_t;
  alias decode_record7_t is decode[string return record7_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record7_t);
  alias decode_record7_t is decode[string, positive, record7_t];
  procedure push(queue : queue_t; value : record7_t);
  impure function pop(queue : queue_t) return record7_t;
  alias push_record7_t is push[queue_t, record7_t];
  alias pop_record7_t is pop[queue_t return record7_t];
  procedure push(msg : msg_t; value : record7_t);
  impure function pop(msg : msg_t) return record7_t;
  alias push_record7_t is push[msg_t, record7_t];
  alias pop_record7_t is pop[msg_t return record7_t];

  function to_string (
    constant data : record7_t)
    return string;

  function encode (
    constant data : record8_t)
    return string;
  alias encode_record8_t is encode[record8_t return string];
  function decode (
    constant code : string)
    return record8_t;
  alias decode_record8_t is decode[string return record8_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record8_t);
  alias decode_record8_t is decode[string, positive, record8_t];
  procedure push(queue : queue_t; value : record8_t);
  impure function pop(queue : queue_t) return record8_t;
  alias push_record8_t is push[queue_t, record8_t];
  alias pop_record8_t is pop[queue_t return record8_t];
  procedure push(msg : msg_t; value : record8_t);
  impure function pop(msg : msg_t) return record8_t;
  alias push_record8_t is push[msg_t, record8_t];
  alias pop_record8_t is pop[msg_t return record8_t];

  function to_string (
    constant data : record8_t)
    return string;

  function encode (
    constant data : record9_t)
    return string;
  alias encode_record9_t is encode[record9_t return string];
  function decode (
    constant code : string)
    return record9_t;
  alias decode_record9_t is decode[string return record9_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record9_t);
  alias decode_record9_t is decode[string, positive, record9_t];
  procedure push(queue : queue_t; value : record9_t);
  impure function pop(queue : queue_t) return record9_t;
  alias push_record9_t is push[queue_t, record9_t];
  alias pop_record9_t is pop[queue_t return record9_t];
  procedure push(msg : msg_t; value : record9_t);
  impure function pop(msg : msg_t) return record9_t;
  alias push_record9_t is push[msg_t, record9_t];
  alias pop_record9_t is pop[msg_t return record9_t];

  function to_string (
    constant data : record9_t)
    return string;

  function command (
    constant a : natural;
    constant b : integer;
    constant c : integer;
    constant d : integer;
    constant e : std_logic)
    return string;
  alias command_msg is command[natural, integer, integer, integer, std_logic return string];

  function read (
    constant addr : natural;
    constant data : natural)
    return string;
  alias read_msg is read[natural, natural return string];

  function write (
    constant addr : natural;
    constant data : natural)
    return string;
  alias write_msg is write[natural, natural return string];

  function foo (
    constant slv : std_logic_vector(byte_msb downto byte_lsb);
    constant str : string(1 to 3);
    constant int_2d : int_2d_t(1 to 2, 4 downto -1))
    return string;
  alias foo_msg is foo[std_logic_vector, string, int_2d_t return string];

  function bar (
    constant slv : std_logic_vector(byte_msb downto byte_lsb);
    constant str : string(1 to 3);
    constant int_2d : int_2d_t(1 to 2, 4 downto -1))
    return string;
  alias bar_msg is bar[std_logic_vector, string, int_2d_t return string];

  function get_record2_msg_type_t (
    constant code : string)
    return record2_msg_type_t;

  function get_record8_msg_type_t (
    constant code : string)
    return record8_msg_type_t;

  function get_record9_msg_type_t (
    constant code : string)
    return record9_msg_type_t;

  type custom_types_pkg_msg_type_t is (command, read, write, foo, bar);
  function get_msg_type (
    constant code : string)
    return custom_types_pkg_msg_type_t;

  function encode (
    constant data : enum1_t)
    return string;
  alias encode_enum1_t is encode[enum1_t return string];
  function decode (
    constant code : string)
    return enum1_t;
  alias decode_enum1_t is decode[string return enum1_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out enum1_t);
  alias decode_enum1_t is decode[string, positive, enum1_t];
  procedure push(queue : queue_t; value : enum1_t);
  impure function pop(queue : queue_t) return enum1_t;
  alias push_enum1_t is push[queue_t, enum1_t];
  alias pop_enum1_t is pop[queue_t return enum1_t];
  procedure push(msg : msg_t; value : enum1_t);
  impure function pop(msg : msg_t) return enum1_t;
  alias push_enum1_t is push[msg_t, enum1_t];
  alias pop_enum1_t is pop[msg_t return enum1_t];

  function to_string (
    constant data : enum1_t)
    return string;

  function encode (
    constant data : record2_msg_type_t)
    return string;
  alias encode_record2_msg_type_t is encode[record2_msg_type_t return string];
  function decode (
    constant code : string)
    return record2_msg_type_t;
  alias decode_record2_msg_type_t is decode[string return record2_msg_type_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record2_msg_type_t);
  alias decode_record2_msg_type_t is decode[string, positive, record2_msg_type_t];
  procedure push(queue : queue_t; value : record2_msg_type_t);
  impure function pop(queue : queue_t) return record2_msg_type_t;
  alias push_record2_msg_type_t is push[queue_t, record2_msg_type_t];
  alias pop_record2_msg_type_t is pop[queue_t return record2_msg_type_t];
  procedure push(msg : msg_t; value : record2_msg_type_t);
  impure function pop(msg : msg_t) return record2_msg_type_t;
  alias push_record2_msg_type_t is push[msg_t, record2_msg_type_t];
  alias pop_record2_msg_type_t is pop[msg_t return record2_msg_type_t];

  function to_string (
    constant data : record2_msg_type_t)
    return string;

  function encode (
    constant data : record8_msg_type_t)
    return string;
  alias encode_record8_msg_type_t is encode[record8_msg_type_t return string];
  function decode (
    constant code : string)
    return record8_msg_type_t;
  alias decode_record8_msg_type_t is decode[string return record8_msg_type_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record8_msg_type_t);
  alias decode_record8_msg_type_t is decode[string, positive, record8_msg_type_t];
  procedure push(queue : queue_t; value : record8_msg_type_t);
  impure function pop(queue : queue_t) return record8_msg_type_t;
  alias push_record8_msg_type_t is push[queue_t, record8_msg_type_t];
  alias pop_record8_msg_type_t is pop[queue_t return record8_msg_type_t];
  procedure push(msg : msg_t; value : record8_msg_type_t);
  impure function pop(msg : msg_t) return record8_msg_type_t;
  alias push_record8_msg_type_t is push[msg_t, record8_msg_type_t];
  alias pop_record8_msg_type_t is pop[msg_t return record8_msg_type_t];

  function to_string (
    constant data : record8_msg_type_t)
    return string;

  function encode (
    constant data : record9_msg_type_t)
    return string;
  alias encode_record9_msg_type_t is encode[record9_msg_type_t return string];
  function decode (
    constant code : string)
    return record9_msg_type_t;
  alias decode_record9_msg_type_t is decode[string return record9_msg_type_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out record9_msg_type_t);
  alias decode_record9_msg_type_t is decode[string, positive, record9_msg_type_t];
  procedure push(queue : queue_t; value : record9_msg_type_t);
  impure function pop(queue : queue_t) return record9_msg_type_t;
  alias push_record9_msg_type_t is push[queue_t, record9_msg_type_t];
  alias pop_record9_msg_type_t is pop[queue_t return record9_msg_type_t];
  procedure push(msg : msg_t; value : record9_msg_type_t);
  impure function pop(msg : msg_t) return record9_msg_type_t;
  alias push_record9_msg_type_t is push[msg_t, record9_msg_type_t];
  alias pop_record9_msg_type_t is pop[msg_t return record9_msg_type_t];

  function to_string (
    constant data : record9_msg_type_t)
    return string;

  function encode (
    constant data : fruit_t)
    return string;
  alias encode_fruit_t is encode[fruit_t return string];
  function decode (
    constant code : string)
    return fruit_t;
  alias decode_fruit_t is decode[string return fruit_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out fruit_t);
  alias decode_fruit_t is decode[string, positive, fruit_t];
  procedure push(queue : queue_t; value : fruit_t);
  impure function pop(queue : queue_t) return fruit_t;
  alias push_fruit_t is push[queue_t, fruit_t];
  alias pop_fruit_t is pop[queue_t return fruit_t];
  procedure push(msg : msg_t; value : fruit_t);
  impure function pop(msg : msg_t) return fruit_t;
  alias push_fruit_t is push[msg_t, fruit_t];
  alias pop_fruit_t is pop[msg_t return fruit_t];

  function to_string (
    constant data : fruit_t)
    return string;

  function encode (
    constant data : custom_types_pkg_msg_type_t)
    return string;
  alias encode_custom_types_pkg_msg_type_t is encode[custom_types_pkg_msg_type_t return string];
  function decode (
    constant code : string)
    return custom_types_pkg_msg_type_t;
  alias decode_custom_types_pkg_msg_type_t is decode[string return custom_types_pkg_msg_type_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out custom_types_pkg_msg_type_t);
  alias decode_custom_types_pkg_msg_type_t is decode[string, positive, custom_types_pkg_msg_type_t];
  procedure push(queue : queue_t; value : custom_types_pkg_msg_type_t);
  impure function pop(queue : queue_t) return custom_types_pkg_msg_type_t;
  alias push_custom_types_pkg_msg_type_t is push[queue_t, custom_types_pkg_msg_type_t];
  alias pop_custom_types_pkg_msg_type_t is pop[queue_t return custom_types_pkg_msg_type_t];
  procedure push(msg : msg_t; value : custom_types_pkg_msg_type_t);
  impure function pop(msg : msg_t) return custom_types_pkg_msg_type_t;
  alias push_custom_types_pkg_msg_type_t is push[msg_t, custom_types_pkg_msg_type_t];
  alias pop_custom_types_pkg_msg_type_t is pop[msg_t return custom_types_pkg_msg_type_t];

  function to_string (
    constant data : custom_types_pkg_msg_type_t)
    return string;

  function encode (
    constant data : int_2d_t)
    return string;
  alias encode_int_2d_t is encode[int_2d_t return string];
  function decode (
    constant code : string)
    return int_2d_t;
  alias decode_int_2d_t is decode[string return int_2d_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out int_2d_t);
  alias decode_int_2d_t is decode[string, positive, int_2d_t];
  procedure push(queue : queue_t; value : int_2d_t);
  impure function pop(queue : queue_t) return int_2d_t;
  alias push_int_2d_t is push[queue_t, int_2d_t];
  alias pop_int_2d_t is pop[queue_t return int_2d_t];
  procedure push(msg : msg_t; value : int_2d_t);
  impure function pop(msg : msg_t) return int_2d_t;
  alias push_int_2d_t is push[msg_t, int_2d_t];
  alias pop_int_2d_t is pop[msg_t return int_2d_t];

  function to_string (
    constant data : int_2d_t)
    return string;

  function encode (
    constant data : array1_t)
    return string;
  alias encode_array1_t is encode[array1_t return string];
  function decode (
    constant code : string)
    return array1_t;
  alias decode_array1_t is decode[string return array1_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array1_t);
  alias decode_array1_t is decode[string, positive, array1_t];
  procedure push(queue : queue_t; value : array1_t);
  impure function pop(queue : queue_t) return array1_t;
  alias push_array1_t is push[queue_t, array1_t];
  alias pop_array1_t is pop[queue_t return array1_t];
  procedure push(msg : msg_t; value : array1_t);
  impure function pop(msg : msg_t) return array1_t;
  alias push_array1_t is push[msg_t, array1_t];
  alias pop_array1_t is pop[msg_t return array1_t];

  function to_string (
    constant data : array1_t)
    return string;

  function encode (
    constant data : array2_t)
    return string;
  alias encode_array2_t is encode[array2_t return string];
  function decode (
    constant code : string)
    return array2_t;
  alias decode_array2_t is decode[string return array2_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array2_t);
  alias decode_array2_t is decode[string, positive, array2_t];
  procedure push(queue : queue_t; value : array2_t);
  impure function pop(queue : queue_t) return array2_t;
  alias push_array2_t is push[queue_t, array2_t];
  alias pop_array2_t is pop[queue_t return array2_t];
  procedure push(msg : msg_t; value : array2_t);
  impure function pop(msg : msg_t) return array2_t;
  alias push_array2_t is push[msg_t, array2_t];
  alias pop_array2_t is pop[msg_t return array2_t];

  function to_string (
    constant data : array2_t)
    return string;

  function encode (
    constant data : array3_t)
    return string;
  alias encode_array3_t is encode[array3_t return string];
  function decode (
    constant code : string)
    return array3_t;
  alias decode_array3_t is decode[string return array3_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array3_t);
  alias decode_array3_t is decode[string, positive, array3_t];
  procedure push(queue : queue_t; value : array3_t);
  impure function pop(queue : queue_t) return array3_t;
  alias push_array3_t is push[queue_t, array3_t];
  alias pop_array3_t is pop[queue_t return array3_t];
  procedure push(msg : msg_t; value : array3_t);
  impure function pop(msg : msg_t) return array3_t;
  alias push_array3_t is push[msg_t, array3_t];
  alias pop_array3_t is pop[msg_t return array3_t];

  function to_string (
    constant data : array3_t)
    return string;

  function encode (
    constant data : array4_t)
    return string;
  alias encode_array4_t is encode[array4_t return string];
  function decode (
    constant code : string)
    return array4_t;
  alias decode_array4_t is decode[string return array4_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array4_t);
  alias decode_array4_t is decode[string, positive, array4_t];
  procedure push(queue : queue_t; value : array4_t);
  impure function pop(queue : queue_t) return array4_t;
  alias push_array4_t is push[queue_t, array4_t];
  alias pop_array4_t is pop[queue_t return array4_t];
  procedure push(msg : msg_t; value : array4_t);
  impure function pop(msg : msg_t) return array4_t;
  alias push_array4_t is push[msg_t, array4_t];
  alias pop_array4_t is pop[msg_t return array4_t];

  function to_string (
    constant data : array4_t)
    return string;

  function encode (
    constant data : array5_t)
    return string;
  alias encode_array5_t is encode[array5_t return string];
  function decode (
    constant code : string)
    return array5_t;
  alias decode_array5_t is decode[string return array5_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array5_t);
  alias decode_array5_t is decode[string, positive, array5_t];
  procedure push(queue : queue_t; value : array5_t);
  impure function pop(queue : queue_t) return array5_t;
  alias push_array5_t is push[queue_t, array5_t];
  alias pop_array5_t is pop[queue_t return array5_t];
  procedure push(msg : msg_t; value : array5_t);
  impure function pop(msg : msg_t) return array5_t;
  alias push_array5_t is push[msg_t, array5_t];
  alias pop_array5_t is pop[msg_t return array5_t];

  function to_string (
    constant data : array5_t)
    return string;

  function encode (
    constant data : array6_t)
    return string;
  alias encode_array6_t is encode[array6_t return string];
  function decode (
    constant code : string)
    return array6_t;
  alias decode_array6_t is decode[string return array6_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array6_t);
  alias decode_array6_t is decode[string, positive, array6_t];
  procedure push(queue : queue_t; value : array6_t);
  impure function pop(queue : queue_t) return array6_t;
  alias push_array6_t is push[queue_t, array6_t];
  alias pop_array6_t is pop[queue_t return array6_t];
  procedure push(msg : msg_t; value : array6_t);
  impure function pop(msg : msg_t) return array6_t;
  alias push_array6_t is push[msg_t, array6_t];
  alias pop_array6_t is pop[msg_t return array6_t];

  function to_string (
    constant data : array6_t)
    return string;

  function encode (
    constant data : array8_t)
    return string;
  alias encode_array8_t is encode[array8_t return string];
  function decode (
    constant code : string)
    return array8_t;
  alias decode_array8_t is decode[string return array8_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array8_t);
  alias decode_array8_t is decode[string, positive, array8_t];
  procedure push(queue : queue_t; value : array8_t);
  impure function pop(queue : queue_t) return array8_t;
  alias push_array8_t is push[queue_t, array8_t];
  alias pop_array8_t is pop[queue_t return array8_t];
  procedure push(msg : msg_t; value : array8_t);
  impure function pop(msg : msg_t) return array8_t;
  alias push_array8_t is push[msg_t, array8_t];
  alias pop_array8_t is pop[msg_t return array8_t];

  function to_string (
    constant data : array8_t)
    return string;

  function encode (
    constant data : array9_t)
    return string;
  alias encode_array9_t is encode[array9_t return string];
  function decode (
    constant code : string)
    return array9_t;
  alias decode_array9_t is decode[string return array9_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array9_t);
  alias decode_array9_t is decode[string, positive, array9_t];
  procedure push(queue : queue_t; value : array9_t);
  impure function pop(queue : queue_t) return array9_t;
  alias push_array9_t is push[queue_t, array9_t];
  alias pop_array9_t is pop[queue_t return array9_t];
  procedure push(msg : msg_t; value : array9_t);
  impure function pop(msg : msg_t) return array9_t;
  alias push_array9_t is push[msg_t, array9_t];
  alias pop_array9_t is pop[msg_t return array9_t];

  function to_string (
    constant data : array9_t)
    return string;

  function encode (
    constant data : array10_t)
    return string;
  alias encode_array10_t is encode[array10_t return string];
  function decode (
    constant code : string)
    return array10_t;
  alias decode_array10_t is decode[string return array10_t];
  procedure decode (
    constant code   : string;
    variable index : inout positive;
    variable result : out array10_t);
  alias decode_array10_t is decode[string, positive, array10_t];
  procedure push(queue : queue_t; value : array10_t);
  impure function pop(queue : queue_t) return array10_t;
  alias push_array10_t is push[queue_t, array10_t];
  alias pop_array10_t is pop[queue_t return array10_t];
  procedure push(msg : msg_t; value : array10_t);
  impure function pop(msg : msg_t) return array10_t;
  alias push_array10_t is push[msg_t, array10_t];
  alias pop_array10_t is pop[msg_t return array10_t];

  function to_string (
    constant data : array10_t)
    return string;


end package custom_codec_pkg;

package body custom_codec_pkg is
  function encode (
    constant data : record1_t)
    return string is
  begin
    return encode(data.a) & encode(data.b) & encode(data.c) & encode(data.d);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record1_t) is
  begin
    decode(code, index, result.a);
    decode(code, index, result.b);
    decode(code, index, result.c);
    decode(code, index, result.d);
  end procedure decode;

  function decode (
    constant code : string)
    return record1_t is
    variable ret_val : record1_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record1_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record1_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record1_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record1_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record1_t)
    return string is
  begin
    return create_group(4, encode(data.a), encode(data.b), encode(data.c), encode(data.d));
  end function to_string;
  function encode (
    constant data : record2_t)
    return string is
  begin
    return encode(data.msg_type) & encode(data.a) & encode(data.b) & encode(data.c) & encode(data.d) & encode(data.e);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record2_t) is
  begin
    decode(code, index, result.msg_type);
    decode(code, index, result.a);
    decode(code, index, result.b);
    decode(code, index, result.c);
    decode(code, index, result.d);
    decode(code, index, result.e);
  end procedure decode;

  function decode (
    constant code : string)
    return record2_t is
    variable ret_val : record2_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record2_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record2_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record2_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record2_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record2_t)
    return string is
  begin
    return create_group(6, encode(data.msg_type), encode(data.a), encode(data.b), encode(data.c), encode(data.d), encode(data.e));
  end function to_string;
  function encode (
    constant data : record3_t)
    return string is
  begin
    return encode(data.char);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record3_t) is
  begin
    decode(code, index, result.char);
  end procedure decode;

  function decode (
    constant code : string)
    return record3_t is
    variable ret_val : record3_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record3_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record3_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record3_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record3_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record3_t)
    return string is
  begin
    return create_group(1, encode(data.char));
  end function to_string;
  function encode (
    constant data : record4_t)
    return string is
  begin
    return encode(data.my_integer) & encode(data.my_real) & encode(data.my_time) & encode(data.my_boolean) & encode(data.my_bit) & encode(data.my_std_ulogic) & encode(data.my_severity_level) & encode(data.my_file_open_status) & encode(data.my_file_open_kind) & encode(data.my_integer2);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record4_t) is
  begin
    decode(code, index, result.my_integer);
    decode(code, index, result.my_real);
    decode(code, index, result.my_time);
    decode(code, index, result.my_boolean);
    decode(code, index, result.my_bit);
    decode(code, index, result.my_std_ulogic);
    decode(code, index, result.my_severity_level);
    decode(code, index, result.my_file_open_status);
    decode(code, index, result.my_file_open_kind);
    decode(code, index, result.my_integer2);
  end procedure decode;

  function decode (
    constant code : string)
    return record4_t is
    variable ret_val : record4_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record4_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record4_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record4_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record4_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record4_t)
    return string is
  begin
    return create_group(10, encode(data.my_integer), encode(data.my_real), encode(data.my_time), encode(data.my_boolean), encode(data.my_bit), encode(data.my_std_ulogic), encode(data.my_severity_level), encode(data.my_file_open_status), encode(data.my_file_open_kind), encode(data.my_integer2));
  end function to_string;
  function encode (
    constant data : record5_t)
    return string is
  begin
    return encode(data.my_character) & encode(data.my_string) & encode(data.my_boolean_vector) & encode(data.my_bit_vector) & encode(data.my_integer_vector) & encode(data.my_real_vector) & encode(data.my_time_vector) & encode(data.my_std_ulogic_vector) & encode(data.my_complex) & encode(data.my_character2);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record5_t) is
  begin
    decode(code, index, result.my_character);
    decode(code, index, result.my_string);
    decode(code, index, result.my_boolean_vector);
    decode(code, index, result.my_bit_vector);
    decode(code, index, result.my_integer_vector);
    decode(code, index, result.my_real_vector);
    decode(code, index, result.my_time_vector);
    decode(code, index, result.my_std_ulogic_vector);
    decode(code, index, result.my_complex);
    decode(code, index, result.my_character2);
  end procedure decode;

  function decode (
    constant code : string)
    return record5_t is
    variable ret_val : record5_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record5_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record5_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record5_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record5_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record5_t)
    return string is
  begin
    return create_group(10, encode(data.my_character), encode(data.my_string), encode(data.my_boolean_vector), encode(data.my_bit_vector), encode(data.my_integer_vector), encode(data.my_real_vector), encode(data.my_time_vector), encode(data.my_std_ulogic_vector), encode(data.my_complex), encode(data.my_character2));
  end function to_string;
  function encode (
    constant data : record6_t)
    return string is
  begin
    return encode(data.my_complex_polar) & encode(data.my_bit_unsigned) & encode(data.my_bit_signed) & encode(data.my_std_unsigned) & encode(data.my_std_signed) & encode(data.my_ufixed) & encode(data.my_sfixed) & encode(data.my_float) & encode(data.my_complex_polar2);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record6_t) is
  begin
    decode(code, index, result.my_complex_polar);
    decode(code, index, result.my_bit_unsigned);
    decode(code, index, result.my_bit_signed);
    decode(code, index, result.my_std_unsigned);
    decode(code, index, result.my_std_signed);
    decode(code, index, result.my_ufixed);
    decode(code, index, result.my_sfixed);
    decode(code, index, result.my_float);
    decode(code, index, result.my_complex_polar2);
  end procedure decode;

  function decode (
    constant code : string)
    return record6_t is
    variable ret_val : record6_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record6_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record6_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record6_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record6_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record6_t)
    return string is
  begin
    return create_group(9, encode(data.my_complex_polar), encode(data.my_bit_unsigned), encode(data.my_bit_signed), encode(data.my_std_unsigned), encode(data.my_std_signed), encode(data.my_ufixed), encode(data.my_sfixed), encode(data.my_float), encode(data.my_complex_polar2));
  end function to_string;
  function encode (
    constant data : record7_t)
    return string is
  begin
    return encode(data.r4) & encode(data.r5) & encode(data.r6);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record7_t) is
  begin
    decode(code, index, result.r4);
    decode(code, index, result.r5);
    decode(code, index, result.r6);
  end procedure decode;

  function decode (
    constant code : string)
    return record7_t is
    variable ret_val : record7_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record7_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record7_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record7_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record7_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record7_t)
    return string is
  begin
    return create_group(3, encode(data.r4), encode(data.r5), encode(data.r6));
  end function to_string;
  function encode (
    constant data : record8_t)
    return string is
  begin
    return encode(data.msg_type) & encode(data.addr) & encode(data.data);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record8_t) is
  begin
    decode(code, index, result.msg_type);
    decode(code, index, result.addr);
    decode(code, index, result.data);
  end procedure decode;

  function decode (
    constant code : string)
    return record8_t is
    variable ret_val : record8_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record8_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record8_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record8_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record8_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record8_t)
    return string is
  begin
    return create_group(3, encode(data.msg_type), encode(data.addr), encode(data.data));
  end function to_string;
  function encode (
    constant data : record9_t)
    return string is
  begin
    return encode(data.msg_type) & encode(data.slv) & encode(data.str) & encode(data.int_2d);
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record9_t) is
  begin
    decode(code, index, result.msg_type);
    decode(code, index, result.slv);
    decode(code, index, result.str);
    decode(code, index, result.int_2d);
  end procedure decode;

  function decode (
    constant code : string)
    return record9_t is
    variable ret_val : record9_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record9_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record9_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : record9_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record9_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record9_t)
    return string is
  begin
    return create_group(4, encode(data.msg_type), encode(data.slv), encode(data.str), encode(data.int_2d));
  end function to_string;
  function command (
    constant a : natural;
    constant b : integer;
    constant c : integer;
    constant d : integer;
    constant e : std_logic)
    return string is
  begin
    return encode(record2_msg_type_t'(command)) & encode(a) & encode(b) & encode(c) & encode(d) & encode(e);
  end function command;

  function read (
    constant addr : natural;
    constant data : natural)
    return string is
  begin
    return encode(record8_msg_type_t'(read)) & encode(addr) & encode(data);
  end function read;

  function write (
    constant addr : natural;
    constant data : natural)
    return string is
  begin
    return encode(record8_msg_type_t'(write)) & encode(addr) & encode(data);
  end function write;

  function foo (
    constant slv : std_logic_vector(byte_msb downto byte_lsb);
    constant str : string(1 to 3);
    constant int_2d : int_2d_t(1 to 2, 4 downto -1))
    return string is
  begin
    return encode(record9_msg_type_t'(foo)) & encode(slv) & encode(str) & encode(int_2d);
  end function foo;

  function bar (
    constant slv : std_logic_vector(byte_msb downto byte_lsb);
    constant str : string(1 to 3);
    constant int_2d : int_2d_t(1 to 2, 4 downto -1))
    return string is
  begin
    return encode(record9_msg_type_t'(bar)) & encode(slv) & encode(str) & encode(int_2d);
  end function bar;

  function get_record2_msg_type_t (
    constant code : string)
    return record2_msg_type_t is
  begin
    return decode(code);
  end;

  function get_record8_msg_type_t (
    constant code : string)
    return record8_msg_type_t is
  begin
    return decode(code);
  end;

  function get_record9_msg_type_t (
    constant code : string)
    return record9_msg_type_t is
  begin
    return decode(code);
  end;

  function get_msg_type (
    constant code : string)
    return custom_types_pkg_msg_type_t is
  begin
    return decode(code);
  end;

  function encode (
    constant data : enum1_t)
    return string is
    constant offset : natural := 0;
  begin
    return (1 => character'val(enum1_t'pos(data) + offset));
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out enum1_t) is
    constant offset : natural := 0;
  begin
    result := enum1_t'val(character'pos(code(index)) - offset);
    index := index + 1;
  end procedure decode;

  function decode (
    constant code : string)
    return enum1_t is
    variable ret_val : enum1_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : enum1_t) is
  begin
    push_fix_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return enum1_t is
  begin
    return decode(pop_fix_string(queue, 1));
  end;

  procedure push(msg : msg_t; value : enum1_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return enum1_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : enum1_t)
    return string is
  begin
    return enum1_t'image(data);
  end function to_string;

  function encode (
    constant data : record2_msg_type_t)
    return string is
    constant offset : natural := 0;
  begin
    return (1 => character'val(record2_msg_type_t'pos(data) + offset));
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record2_msg_type_t) is
    constant offset : natural := 0;
  begin
    result := record2_msg_type_t'val(character'pos(code(index)) - offset);
    index := index + 1;
  end procedure decode;

  function decode (
    constant code : string)
    return record2_msg_type_t is
    variable ret_val : record2_msg_type_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record2_msg_type_t) is
  begin
    push_fix_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record2_msg_type_t is
  begin
    return decode(pop_fix_string(queue, 1));
  end;

  procedure push(msg : msg_t; value : record2_msg_type_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record2_msg_type_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record2_msg_type_t)
    return string is
  begin
    return record2_msg_type_t'image(data);
  end function to_string;

  function encode (
    constant data : record8_msg_type_t)
    return string is
    constant offset : natural := 1;
  begin
    return (1 => character'val(record8_msg_type_t'pos(data) + offset));
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record8_msg_type_t) is
    constant offset : natural := 1;
  begin
    result := record8_msg_type_t'val(character'pos(code(index)) - offset);
    index := index + 1;
  end procedure decode;

  function decode (
    constant code : string)
    return record8_msg_type_t is
    variable ret_val : record8_msg_type_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record8_msg_type_t) is
  begin
    push_fix_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record8_msg_type_t is
  begin
    return decode(pop_fix_string(queue, 1));
  end;

  procedure push(msg : msg_t; value : record8_msg_type_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record8_msg_type_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record8_msg_type_t)
    return string is
  begin
    return record8_msg_type_t'image(data);
  end function to_string;

  function encode (
    constant data : record9_msg_type_t)
    return string is
    constant offset : natural := 3;
  begin
    return (1 => character'val(record9_msg_type_t'pos(data) + offset));
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out record9_msg_type_t) is
    constant offset : natural := 3;
  begin
    result := record9_msg_type_t'val(character'pos(code(index)) - offset);
    index := index + 1;
  end procedure decode;

  function decode (
    constant code : string)
    return record9_msg_type_t is
    variable ret_val : record9_msg_type_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : record9_msg_type_t) is
  begin
    push_fix_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return record9_msg_type_t is
  begin
    return decode(pop_fix_string(queue, 1));
  end;

  procedure push(msg : msg_t; value : record9_msg_type_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return record9_msg_type_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : record9_msg_type_t)
    return string is
  begin
    return record9_msg_type_t'image(data);
  end function to_string;

  function encode (
    constant data : fruit_t)
    return string is
    constant offset : natural := 0;
  begin
    return (1 => character'val(fruit_t'pos(data) + offset));
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out fruit_t) is
    constant offset : natural := 0;
  begin
    result := fruit_t'val(character'pos(code(index)) - offset);
    index := index + 1;
  end procedure decode;

  function decode (
    constant code : string)
    return fruit_t is
    variable ret_val : fruit_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : fruit_t) is
  begin
    push_fix_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return fruit_t is
  begin
    return decode(pop_fix_string(queue, 1));
  end;

  procedure push(msg : msg_t; value : fruit_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return fruit_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : fruit_t)
    return string is
  begin
    return fruit_t'image(data);
  end function to_string;

  function encode (
    constant data : custom_types_pkg_msg_type_t)
    return string is
    constant offset : natural := 0;
  begin
    return (1 => character'val(custom_types_pkg_msg_type_t'pos(data) + offset));
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out custom_types_pkg_msg_type_t) is
    constant offset : natural := 0;
  begin
    result := custom_types_pkg_msg_type_t'val(character'pos(code(index)) - offset);
    index := index + 1;
  end procedure decode;

  function decode (
    constant code : string)
    return custom_types_pkg_msg_type_t is
    variable ret_val : custom_types_pkg_msg_type_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : custom_types_pkg_msg_type_t) is
  begin
    push_fix_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return custom_types_pkg_msg_type_t is
  begin
    return decode(pop_fix_string(queue, 1));
  end;

  procedure push(msg : msg_t; value : custom_types_pkg_msg_type_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return custom_types_pkg_msg_type_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : custom_types_pkg_msg_type_t)
    return string is
  begin
    return custom_types_pkg_msg_type_t'image(data);
  end function to_string;


  -- Helper function to make tests pass GHDL v0.37
  function get_encoded_length ( constant vec: string ) return integer is
  begin return vec'length; end;

  function encode (
    constant data : int_2d_t)
    return string is
    function element_length (
      constant data : int_2d_t)
      return natural is
    begin
      if data'length(1) * data'length(2) = 0 then
        return 0;
      else
        return get_encoded_length(encode(data(data'left(1), data'left(2))));
      end if;
    end;
    constant length : natural := element_length(data);
    constant range1_length : positive := get_encoded_length(encode(data'left(1)));
    constant range2_length : positive := get_encoded_length(encode(data'left(2)));
    variable index : positive := 3 + 2 * range1_length + 2 * range2_length;
    variable ret_val : string(1 to 2 + 2 * range1_length + 2 * range2_length +
                                   data'length(1) * data'length(2) * length);
  begin
    ret_val(1 to 2 + 2 * range1_length + 2 * range2_length) :=
      encode_array_header(encode(data'left(1)), encode(data'right(1)), encode(data'ascending(1)),
                          encode(data'left(2)), encode(data'right(2)), encode(data'ascending(2)));
    for i in data'range(1) loop
      for j in data'range(2) loop
        ret_val(index to index + length - 1) := encode(data(i,j));
        index := index + length;
      end loop;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out int_2d_t) is
    constant range1_length : positive := get_encoded_length(encode(integer'left));
    constant range2_length : positive := get_encoded_length(encode(integer'left));
  begin
    index := index + 2 + 2 * range1_length + 2 * range2_length;
    for i in result'range(1) loop
      for j in result'range(2) loop
        decode(code, index, result(i,j));
      end loop;
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return int_2d_t is
    constant range1_length : positive := get_encoded_length(encode(integer'left));
    constant range2_length : positive := get_encoded_length(encode(integer'left));
    function ret_val_range (
      constant code : string)
      return int_2d_t is
      constant range_left1 : integer := decode(code(code'left to code'left + range1_length - 1));
      constant range_right1 : integer := decode(code(code'left + range1_length to
                                                          code'left + 2 * range1_length - 1));
      constant is_ascending1 : boolean := decode(code(code'left + 2 * range1_length to
                                                      code'left + 2 * range1_length));
      constant range_left2 : integer := decode(code(code'left + 2 * range1_length + 1 to
                                                         code'left + 2 * range1_length + range2_length));
      constant range_right2 : integer := decode(code(code'left + 2 * range1_length + range2_length + 1 to
                                                          code'left + 2 * range1_length + 2 * range2_length));
      constant is_ascending2 : boolean := decode(code(code'left + 2 * range1_length + 2 * range2_length + 1 to
                                                      code'left + 2 * range1_length + 2 * range2_length + 1));
      variable ret_val_ascending_ascending : int_2d_t(range_left1 to range_right1,
                                                         range_left2 to range_right2);
      variable ret_val_ascending_decending : int_2d_t(range_left1 to range_right1,
                                                         range_left2 downto range_right2);
      variable ret_val_decending_ascending : int_2d_t(range_left1 downto range_right1,
                                                         range_left2 to range_right2);
      variable ret_val_decending_decending : int_2d_t(range_left1 downto range_right1,
                                                         range_left2 downto range_right2);
    begin
      if is_ascending1 then
        if is_ascending2 then
          return ret_val_ascending_ascending;
        else
          return ret_val_ascending_decending;
        end if;
      else
        if is_ascending2 then
          return ret_val_decending_ascending;
        else
          return ret_val_decending_decending;
        end if;
      end if;
    end function ret_val_range;

    constant array_of_correct_range : int_2d_t := ret_val_range(code);
    variable ret_val : int_2d_t(array_of_correct_range'range(1), array_of_correct_range'range(2));
    variable index : positive := code'left + 2 + 2 * range1_length + 2 * range2_length;
  begin
    for i in ret_val'range(1) loop
      for j in ret_val'range(2) loop
        decode(code, index, ret_val(i,j));
      end loop;
    end loop;

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : int_2d_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return int_2d_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : int_2d_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return int_2d_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : int_2d_t)
    return string is
    variable element : string(1 to 2 + data'length(1) * data'length(2) * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range(1) loop
      for j in data'range(2) loop
        append_group(l, encode(data(i,j)));
      end loop;
    end loop;
    close_group(l, element, length);

    return create_array_group(element(1 to length), encode(data'left(1)), encode(data'right(1)), data'ascending(1),
                              encode(data'left(2)), encode(data'right(2)), data'ascending(2));
  end function to_string;

  function encode (
    constant data : array1_t)
    return string is
    constant length : positive := get_encoded_length(encode(data(data'left)));
    variable index : positive := 1;
    variable ret_val : string(1 to data'length * length);
  begin
    for i in data'range loop
      ret_val(index to index + length - 1) := encode(data(i));
      index := index + length;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array1_t) is
  begin
    for i in result'range loop
      decode(code, index, result(i));
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array1_t is
    variable ret_val : array1_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array1_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array1_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array1_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array1_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array1_t)
    return string is
    variable element : string(1 to 2 + data'length * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range loop
      append_group(l, encode(data(i)));
    end loop;
    close_group(l, element, length);

    return element(1 to length);
  end function to_string;

  function encode (
    constant data : array2_t)
    return string is
    constant length : positive := get_encoded_length(encode(data(data'left)));
    variable index : positive := 1;
    variable ret_val : string(1 to data'length * length);
  begin
    for i in data'range loop
      ret_val(index to index + length - 1) := encode(data(i));
      index := index + length;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array2_t) is
  begin
    for i in result'range loop
      decode(code, index, result(i));
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array2_t is
    variable ret_val : array2_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array2_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array2_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array2_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array2_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array2_t)
    return string is
    variable element : string(1 to 2 + data'length * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range loop
      append_group(l, encode(data(i)));
    end loop;
    close_group(l, element, length);

    return element(1 to length);
  end function to_string;

  function encode (
    constant data : array3_t)
    return string is
    constant length : positive := get_encoded_length(encode(data(data'left(1), data'left(2))));
    variable index : positive := 1;
    variable ret_val : string(1 to data'length(1) * data'length(2) * length);
  begin
    for i in data'range(1) loop
      for j in data'range(2) loop
        ret_val(index to index + length - 1) := encode(data(i,j));
        index := index + length;
      end loop;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array3_t) is
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        decode(code, index, result(i,j));
      end loop;
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array3_t is
    variable ret_val : array3_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array3_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array3_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array3_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array3_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array3_t)
    return string is
    variable element : string(1 to 2 + data'length(1) * data'length(2) * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range(1) loop
      for j in data'range(2) loop
        append_group(l, encode(data(i,j)));
      end loop;
    end loop;
    close_group(l, element, length);

    return element(1 to length);
  end function to_string;

  function encode (
    constant data : array4_t)
    return string is
    function element_length (
      constant data : array4_t)
      return natural is
    begin
      if data'length = 0 then
        return 0;
      else
        return get_encoded_length(encode(data(data'left)));
      end if;
    end;
    constant length : natural := element_length(data);
    constant range_length : positive := get_encoded_length(encode(data'left));
    variable index : positive := 2 + 2 * range_length;
    variable ret_val : string(1 to 1 + 2 * range_length + data'length * length);
  begin
    ret_val(1 to 1 + 2 * range_length) := encode_array_header(encode(data'left),
                                                              encode(data'right),
                                                              encode(data'ascending));
    for i in data'range loop
      ret_val(index to index + length - 1) := encode(data(i));
      index := index + length;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array4_t) is
    constant range_length : positive := get_encoded_length(encode(positive'left));
  begin
    index := index + 1 + 2 * range_length;
    for i in result'range loop
      decode(code, index, result(i));
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array4_t is
    constant range_length : positive := get_encoded_length(encode(positive'left));
    function ret_val_range (
      constant code : string)
      return array4_t is
      constant range_left : positive := decode(code(code'left to code'left + range_length - 1));
      constant range_right : positive := decode(code(code'left + range_length to code'left + 2 * range_length - 1));
      constant is_ascending : boolean := decode(code(code'left + 2 * range_length to code'left + 2 *range_length));
      variable ret_val_ascending : array4_t(range_left to range_right);
      variable ret_val_descending : array4_t(range_left downto range_right);
    begin
      if is_ascending then
        return ret_val_ascending;
      else
        return ret_val_descending;
      end if;
    end function ret_val_range;
    constant array_of_correct_range : array4_t := ret_val_range(code);
    variable ret_val : array4_t(array_of_correct_range'range);
    variable index : positive := code'left + 1 + 2 * range_length;
  begin
    for i in ret_val'range loop
      decode(code, index, ret_val(i));
    end loop;

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array4_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array4_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array4_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array4_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array4_t)
    return string is
    variable element : string(1 to 2 + data'length * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range loop
      append_group(l, encode(data(i)));
    end loop;
    close_group(l, element, length);

    return create_array_group(element(1 to length), encode(data'left), encode(data'right), data'ascending);
  end function to_string;

  function encode (
    constant data : array5_t)
    return string is
    function element_length (
      constant data : array5_t)
      return natural is
    begin
      if data'length(1) * data'length(2) = 0 then
        return 0;
      else
        return get_encoded_length(encode(data(data'left(1), data'left(2))));
      end if;
    end;
    constant length : natural := element_length(data);
    constant range1_length : positive := get_encoded_length(encode(data'left(1)));
    constant range2_length : positive := get_encoded_length(encode(data'left(2)));
    variable index : positive := 3 + 2 * range1_length + 2 * range2_length;
    variable ret_val : string(1 to 2 + 2 * range1_length + 2 * range2_length +
                                   data'length(1) * data'length(2) * length);
  begin
    ret_val(1 to 2 + 2 * range1_length + 2 * range2_length) :=
      encode_array_header(encode(data'left(1)), encode(data'right(1)), encode(data'ascending(1)),
                          encode(data'left(2)), encode(data'right(2)), encode(data'ascending(2)));
    for i in data'range(1) loop
      for j in data'range(2) loop
        ret_val(index to index + length - 1) := encode(data(i,j));
        index := index + length;
      end loop;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array5_t) is
    constant range1_length : positive := get_encoded_length(encode(integer'left));
    constant range2_length : positive := get_encoded_length(encode(integer'left));
  begin
    index := index + 2 + 2 * range1_length + 2 * range2_length;
    for i in result'range(1) loop
      for j in result'range(2) loop
        decode(code, index, result(i,j));
      end loop;
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array5_t is
    constant range1_length : positive := get_encoded_length(encode(integer'left));
    constant range2_length : positive := get_encoded_length(encode(integer'left));
    function ret_val_range (
      constant code : string)
      return array5_t is
      constant range_left1 : integer := decode(code(code'left to code'left + range1_length - 1));
      constant range_right1 : integer := decode(code(code'left + range1_length to
                                                          code'left + 2 * range1_length - 1));
      constant is_ascending1 : boolean := decode(code(code'left + 2 * range1_length to
                                                      code'left + 2 * range1_length));
      constant range_left2 : integer := decode(code(code'left + 2 * range1_length + 1 to
                                                         code'left + 2 * range1_length + range2_length));
      constant range_right2 : integer := decode(code(code'left + 2 * range1_length + range2_length + 1 to
                                                          code'left + 2 * range1_length + 2 * range2_length));
      constant is_ascending2 : boolean := decode(code(code'left + 2 * range1_length + 2 * range2_length + 1 to
                                                      code'left + 2 * range1_length + 2 * range2_length + 1));
      variable ret_val_ascending_ascending : array5_t(range_left1 to range_right1,
                                                         range_left2 to range_right2);
      variable ret_val_ascending_decending : array5_t(range_left1 to range_right1,
                                                         range_left2 downto range_right2);
      variable ret_val_decending_ascending : array5_t(range_left1 downto range_right1,
                                                         range_left2 to range_right2);
      variable ret_val_decending_decending : array5_t(range_left1 downto range_right1,
                                                         range_left2 downto range_right2);
    begin
      if is_ascending1 then
        if is_ascending2 then
          return ret_val_ascending_ascending;
        else
          return ret_val_ascending_decending;
        end if;
      else
        if is_ascending2 then
          return ret_val_decending_ascending;
        else
          return ret_val_decending_decending;
        end if;
      end if;
    end function ret_val_range;

    constant array_of_correct_range : array5_t := ret_val_range(code);
    variable ret_val : array5_t(array_of_correct_range'range(1), array_of_correct_range'range(2));
    variable index : positive := code'left + 2 + 2 * range1_length + 2 * range2_length;
  begin
    for i in ret_val'range(1) loop
      for j in ret_val'range(2) loop
        decode(code, index, ret_val(i,j));
      end loop;
    end loop;

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array5_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array5_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array5_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array5_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array5_t)
    return string is
    variable element : string(1 to 2 + data'length(1) * data'length(2) * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range(1) loop
      for j in data'range(2) loop
        append_group(l, encode(data(i,j)));
      end loop;
    end loop;
    close_group(l, element, length);

    return create_array_group(element(1 to length), encode(data'left(1)), encode(data'right(1)), data'ascending(1),
                              encode(data'left(2)), encode(data'right(2)), data'ascending(2));
  end function to_string;

  function encode (
    constant data : array6_t)
    return string is
    function element_length (
      constant data : array6_t)
      return natural is
    begin
      if data'length = 0 then
        return 0;
      else
        return get_encoded_length(encode(data(data'left)));
      end if;
    end;
    constant length : natural := element_length(data);
    constant range_length : positive := get_encoded_length(encode(data'left));
    variable index : positive := 2 + 2 * range_length;
    variable ret_val : string(1 to 1 + 2 * range_length + data'length * length);
  begin
    ret_val(1 to 1 + 2 * range_length) := encode_array_header(encode(data'left),
                                                              encode(data'right),
                                                              encode(data'ascending));
    for i in data'range loop
      ret_val(index to index + length - 1) := encode(data(i));
      index := index + length;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array6_t) is
    constant range_length : positive := get_encoded_length(encode(fruit_t'left));
  begin
    index := index + 1 + 2 * range_length;
    for i in result'range loop
      decode(code, index, result(i));
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array6_t is
    constant range_length : positive := get_encoded_length(encode(fruit_t'left));
    function ret_val_range (
      constant code : string)
      return array6_t is
      constant range_left : fruit_t := decode(code(code'left to code'left + range_length - 1));
      constant range_right : fruit_t := decode(code(code'left + range_length to code'left + 2 * range_length - 1));
      constant is_ascending : boolean := decode(code(code'left + 2 * range_length to code'left + 2 *range_length));
      variable ret_val_ascending : array6_t(range_left to range_right);
      variable ret_val_descending : array6_t(range_left downto range_right);
    begin
      if is_ascending then
        return ret_val_ascending;
      else
        return ret_val_descending;
      end if;
    end function ret_val_range;
    constant array_of_correct_range : array6_t := ret_val_range(code);
    variable ret_val : array6_t(array_of_correct_range'range);
    variable index : positive := code'left + 1 + 2 * range_length;
  begin
    for i in ret_val'range loop
      decode(code, index, ret_val(i));
    end loop;

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array6_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array6_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array6_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array6_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array6_t)
    return string is
    variable element : string(1 to 2 + data'length * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range loop
      append_group(l, encode(data(i)));
    end loop;
    close_group(l, element, length);

    return create_array_group(element(1 to length), encode(data'left), encode(data'right), data'ascending);
  end function to_string;

  function encode (
    constant data : array8_t)
    return string is
    constant length : positive := get_encoded_length(encode(data(data'left(1), data'left(2))));
    variable index : positive := 1;
    variable ret_val : string(1 to data'length(1) * data'length(2) * length);
  begin
    for i in data'range(1) loop
      for j in data'range(2) loop
        ret_val(index to index + length - 1) := encode(data(i,j));
        index := index + length;
      end loop;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array8_t) is
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        decode(code, index, result(i,j));
      end loop;
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array8_t is
    variable ret_val : array8_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array8_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array8_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array8_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array8_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array8_t)
    return string is
    variable element : string(1 to 2 + data'length(1) * data'length(2) * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range(1) loop
      for j in data'range(2) loop
        append_group(l, encode(data(i,j)));
      end loop;
    end loop;
    close_group(l, element, length);

    return element(1 to length);
  end function to_string;

  function encode (
    constant data : array9_t)
    return string is
    constant length : positive := get_encoded_length(encode(data(data'left)));
    variable index : positive := 1;
    variable ret_val : string(1 to data'length * length);
  begin
    for i in data'range loop
      ret_val(index to index + length - 1) := encode(data(i));
      index := index + length;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array9_t) is
  begin
    for i in result'range loop
      decode(code, index, result(i));
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array9_t is
    variable ret_val : array9_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array9_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array9_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array9_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array9_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array9_t)
    return string is
    variable element : string(1 to 2 + data'length * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range loop
      append_group(l, encode(data(i)));
    end loop;
    close_group(l, element, length);

    return element(1 to length);
  end function to_string;

  function encode (
    constant data : array10_t)
    return string is
    constant length : positive := get_encoded_length(encode(data(data'left(1), data'left(2))));
    variable index : positive := 1;
    variable ret_val : string(1 to data'length(1) * data'length(2) * length);
  begin
    for i in data'range(1) loop
      for j in data'range(2) loop
        ret_val(index to index + length - 1) := encode(data(i,j));
        index := index + length;
      end loop;
    end loop;

    return ret_val;
  end function encode;

  procedure decode (
    constant code   : string;
    variable index : inout   positive;
    variable result : out array10_t) is
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        decode(code, index, result(i,j));
      end loop;
    end loop;
  end procedure decode;

  function decode (
    constant code : string)
    return array10_t is
    variable ret_val : array10_t;
    variable index : positive := code'left;
  begin
    decode(code, index, ret_val);

    return ret_val;
  end function decode;

  procedure push(queue : queue_t; value : array10_t) is
  begin
    push_variable_string(queue, encode(value));
  end;

  impure function pop(queue : queue_t) return array10_t is
  begin
    return decode(pop_variable_string(queue));
  end;

  procedure push(msg : msg_t; value : array10_t) is
  begin
    push(msg.data, value);
  end;

  impure function pop(msg : msg_t) return array10_t is
  begin
    return pop(msg.data);
  end;

  function to_string (
    constant data : array10_t)
    return string is
    variable element : string(1 to 2 + data'length(1) * data'length(2) * 32);
    variable l : line;
    variable length : natural;
  begin
    open_group(l);
    for i in data'range(1) loop
      for j in data'range(2) loop
        append_group(l, encode(data(i,j)));
      end loop;
    end loop;
    close_group(l, element, length);

    return element(1 to length);
  end function to_string;


end package body custom_codec_pkg;

