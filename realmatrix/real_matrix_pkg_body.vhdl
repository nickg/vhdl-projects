-------------------------------------------------------------------------------
-- Title      : Matrix Math package for type REAL
-- Project    : IEEE 1076.1-201x
-------------------------------------------------------------------------------
-- File       : real_matrix_pkg_body.vhdl
-- Author     : David Bishop  <dbishop@vhdl.org>
-- Company    :
-- Created    : 2010-04-15
-- Last update: 2023-10-30
-- Platform   :
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Matrix math package body for type REAL
-------------------------------------------------------------------------------
-- Copyright (c) 2011
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-04-15  1.0      dbishop@vhdl.org Created
-------------------------------------------------------------------------------

--

library ieee;
use ieee.math_real.all;
use std.textio.all;

package body real_matrix_pkg is

  -- %%% This is a built in function for VHDL-2008
--%VHDL2008%  -- purpose: minimum of l and r
--%VHDL2008%  function minimum (
--%VHDL2008%    l, r : INTEGER)
--%VHDL2008%    return INTEGER is
--%VHDL2008%  begin
--%VHDL2008%    if l < r then
--%VHDL2008%      return l;
--%VHDL2008%    else
--%VHDL2008%      return r;
--%VHDL2008%    end if;
--%VHDL2008%  end function minimum;

  -- %%% This is a built in function for VHDL-2008
  -- purpose: max of l and r
--%VHDL2008%  function maximum (
--%VHDL2008%    l, r : REAL)
--%VHDL2008%    return REAL is
--%VHDL2008%  begin
--%VHDL2008%    if l < r then
--%VHDL2008%      return r;
--%VHDL2008%    else
--%VHDL2008%      return l;
--%VHDL2008%    end if;
--%VHDL2008%  end function maximum;

  -----------------------------------------------------------------------------
  -- matrix multiply
  -----------------------------------------------------------------------------
  function "*" (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1,
                                   0 to r'length(2)-1);
  begin  -- multiply
    if l'length(2) /= r'length(1) then
      report real_matrix_pkg'instance_name & "Multiply "
        & "columns of left = " & INTEGER'image(l'length(2)) &
        " and rows or right = " & INTEGER'image (r'length(1))
        & " should be equal" severity error;
    elsif isempty (l) or isempty(r) then
      -- Silently return an empty matrix
      result := zeros(result'length(1), result'length(2));
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l(i+l'low(1), l'low(2)) * r(r'low(1), j+r'low(2));
          for k in 1 to l'length(2)-1 loop
            result (i, j) := result (i, j) +
                             (l(i+l'low(1), k+l'low(2)) *
                              r(k+r'low(1), j+r'low(2)));
          end loop;  -- k
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "*";

  -- purpose: matrix by vector
  function "*" (
    l : real_matrix;
    r : real_vector)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1,
                                   0 to r'length-1);
  begin  -- multiply
    if l'length(2) /= 1 then
      report real_matrix_pkg'instance_name & "Multiply "
        & " Matrix must have only one column to be multiplied by a vector, "
        & " l (" & INTEGER'image(l'length(1)) & ","
        & INTEGER'image(l'length(2)) & ") * r (" & INTEGER'image(r'length) &
        ") invalid" severity error;
    elsif l'length(1) /= r'length then
      report real_matrix_pkg'instance_name & "Multiply "
        & "columns of left matrix = " & INTEGER'image(l'length(2)) &
        " and size of right vector = " & INTEGER'image(r'length)
        & " should be equal" severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l(i+l'low(1), l'low(2)) * r(j+r'low);
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "*";

  -- purpose: multiply a vector by a matrix
  function "*" (
    l : real_vector;
    r : real_matrix)
    return real_vector is
    variable result : real_vector (0 to r'length(2)-1);
  begin  -- multiply
    if l'length /= r'length(1) then
      report real_matrix_pkg'instance_name & "Multiply "
        & "left vector length = " & INTEGER'image(l'length) &
        " and rows in right matrix = " & INTEGER'image(r'length(1))
        & " should be equal" severity error;
    elsif isempty(r) or isempty (l) then
      -- Silently return an empty matrix
      result := zeros (1, result'length);
    else
      for i in result'range loop
        result (i) := l(l'low) * r(r'low(1), i+r'low(2));
        for k in 1 to r'length(1)-1 loop
          result (i) := result (i) + (l(k+l'low) * r(k+r'low(1), i+r'low(2)));
        end loop;  -- k
      end loop;  -- i
    end if;
    return result;
  end function "*";

  -- purpose: multiply a scalar by a matrix
  function "*" (
    l : REAL;
    r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to r'length(1)-1,
                                   0 to r'length(2)-1);
  begin  -- multiply
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := l * r (i+r'low(1), j+r'low(2));
      end loop;  -- j
    end loop;  -- i
    return result;
  end function "*";

  -- purpose: multiply a scalar by a matrix
  function "*" (
    l : real_matrix;
    r : REAL)
    return real_matrix is
  begin  -- multiply
    return r * l;
  end function "*";

  -- purpose: multiply a scalar by a vector
  function "*" (
    l : REAL;
    r : real_vector)
    return real_vector is
    variable result : real_vector (0 to r'length-1);
  begin  -- multiply
    for i in result'range loop
      result (i) := l * r (i+r'low);
    end loop;  -- i
    return result;
  end function "*";

  function "*" (
    l : real_vector;
    r : REAL)
    return real_vector is
  begin
    return r * l;
  end function "*";

  -- purpose: divide matrix by a scalar
  function "/" (
    l : real_matrix;
    r : REAL)
    return real_matrix is
  begin
    return (1.0/r) * l;
  end function "/";

  -- purpose: divide vector by a scalar
  function "/" (
    l : real_vector;
    r : REAL)
    return real_vector is
  begin
    return (1.0/r) * l;
  end function "/";

  -- purpose: matrix addition
  function "+" (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1,
                                   0 to l'length(2)-1);
  begin  -- addition
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "Addition " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r("&
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) +
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "+";

  -- purpose: vector addition
  function "+" (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Addition " &
        "Vector lengths do not match l(" & INTEGER'image(l'length) &
        ") /= r(" & INTEGER'image(r'length) & ")" severity error;
      return result;
    else
      for i in result'range loop
        result(i) := l(l'low+i) + r(r'low+i);
      end loop;
      return result;
    end if;
  end function "+";

-- purpose: matrix subtraction
  function "-" (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1,
                                   0 to l'length(2)-1);
  begin  -- subtraction
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "Subtraction " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) -
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "-";

  -- purpose: vector addition
  function "-" (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Subtraction " &
        "Vector lengths do not match l(" & INTEGER'image(l'length) &
        ") /= r(" & INTEGER'image(r'length) & ")" severity error;
    else
      for i in result'range loop
        result(i) := l(l'low+i) - r(r'low+i);
      end loop;
    end if;
    return result;
  end function "-";

  -- unary minus
  function "-" (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (arg'range(1), arg'range(2));
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result(i, j) := - arg(i, j);
      end loop;
    end loop;
    return result;
  end function "-";

  function "-" (
    arg : real_vector)
    return real_vector is
    variable result : real_vector (arg'range);
  begin
    for i in result'range loop
      result(i) := - arg(i);
    end loop;
    return result;
  end function "-";

  -- Absolute value
  function "abs" (
    arg : real_vector)
    return real_vector is
    variable result : real_vector (arg'range);
  begin
    for i in result'range loop
      result(i) := abs (arg(i));
    end loop;
    return result;
  end function "abs";

  function "abs" (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (arg'range(1), arg'range(2));
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result(i, j) := abs (arg(i, j));
      end loop;
    end loop;
    return result;
  end function "abs";

  -- purpose: element by element multiply, Matlab .* operator
  function times (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1,
                                   0 to l'length(2)-1);
  begin  -- ".*"
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "times " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) *
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function times;

  -- purpose: vector multiplication ".*" operator
  function times (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "times " &
        "Vectors lengths do not match l(" & INTEGER'image(l'length)
        & ") /= r("& INTEGER'image(r'length) & ")"
        severity error;
    else
      for i in result'range loop
        result(i) := l(l'low+i) * r(r'low+i);
      end loop;
    end if;
    return result;
  end function times;

  -- purpose: element by element divide, Matlab "./" operator
  function rdivide (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1,
                                   0 to l'length(2)-1);
  begin  -- "./"
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "rdivide " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) /
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function rdivide;

  -- purpose: vector multiplication "./" operator
  function rdivide (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "rdivide " &
        "Vectors lengths do not match l(" & INTEGER'image(l'length)
        & ") /= r("& INTEGER'image(r'length) & ")"
        severity error;
    else
      for i in result'range loop
        result(i) := l(l'low+i) / r(r'low+i);
      end loop;
    end if;
    return result;
  end function rdivide;

  -- Matlab / operator
  function "/" (
    l, r : real_matrix)
    return real_matrix is
  begin
    return mrdivide (l, r);
  end function "/";

  -- Matlab / operator
  function mrdivide (
    l, r : real_matrix)
    return real_matrix is
  begin
    return l * inv(r);
  end function mrdivide;

  -- Matlab \ operator (= .\ function)
  function mldivide (
    l, r : real_matrix)
    return real_matrix is
  begin
    return inv(l) * r;
  end function mldivide;

  -- Raise a matrix to a power, "^" operator
  -- Recursive
  function "**" (
    arg : real_matrix;
    pow : INTEGER)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
    variable Half : INTEGER;
  begin
    if arg'length(1) /= arg'length(2) then
      report real_matrix_pkg'instance_name & "** " &
        "Matrix is not square (" & INTEGER'image(arg'length(1)) & "," &
        INTEGER'image(arg'length(2)) & ")" severity error;
      return arg;
    elsif pow < 0 then
      -- arg^(-1) = inv(arg)  arg^(-2) = inv(arg)^2
      return inv(arg)**(-pow);
    elsif pow = 0 then
      return ones (arg'length(1), arg'length(2));
    elsif pow = 1 then
      return arg;
    elsif pow = 2 then
      return arg * arg;
    else  -- Recursively call this function until complete
      Half   := pow / 2;
      result := (arg**Half) * (arg**(pow-Half));
      return result;
    end if;
  end function "**";

  -- same as the Matlab .^ function
  function pow (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to l'length(1)-1, 0 to l'length(2)-1);
  begin
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "pow " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image (r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (l'low(1)+i, l'low(2)+j) **
                           r (r'low(1)+i, r'low(2)+j);
        end loop;
      end loop;
    end if;
    return result;
  end function pow;

  -- same as the Matlab .^ function
  function pow (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "pow " &
        "Vectors are not of the same dimensions.  l(" &
        INTEGER'image (l'length) & ") /= r(" & INTEGER'image (r'length) & ")"
        severity error;
    else
      for i in result'range loop
        result (i) := l (l'low+i) ** r (r'low+i);
      end loop;
    end if;
    return result;
  end function pow;

  -- purpose: Performs an element by element square root
  function sqrt (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if arg ((arg'low(1)+i), (arg'low(2)+j)) < 0.0 then
          report real_matrix_pkg'instance_name & "sqrt " &
            "Negative value found at (" & INTEGER'image (arg'low(1)+i) &
            "," & INTEGER'image (arg'low(2)+j) & ")" severity error;
          result (i, j) := 0.0;
        else
          result (i, j) := sqrt (arg ((arg'low(1)+i), (arg'low(2)+j)));
        end if;
      end loop;
    end loop;
    return result;
  end function sqrt;

  -- purpose: Performs an element by element square root
  function sqrt (
    arg : real_vector)
    return real_vector is
    variable result : real_vector (0 to arg'length-1);
  begin
    for i in result'range loop
      if arg (arg'low(1)+i) < 0.0 then
        report real_matrix_pkg'instance_name & "sqrt " &
          "Negative value found at (" & INTEGER'image (arg'low+i) & ")"
          severity error;
        result (i) := 0.0;
      else
        result (i) := sqrt (arg (arg'low+i));
      end if;
    end loop;
    return result;
  end function sqrt;

  -- purpose: Performs an element by element e**arg
  function exp (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1, 0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := exp (arg ((arg'low(1)+i), (arg'low(2)+j)));
      end loop;
    end loop;
    return result;
  end function exp;

  -- purpose: Performs an element by element e**arg
  function exp (
    arg : real_vector)
    return real_vector is
    variable result : real_vector (0 to arg'length-1);
  begin
    for i in result'range loop
      result (i) := exp (arg (arg'low+i));
    end loop;
    return result;
  end function exp;

  -- purpose: Performs an element by element ln
  function log (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := log (arg ((arg'low(1)+i), (arg'low(2)+j)));
      end loop;
    end loop;
    return result;
  end function log;

  function log (
    arg : real_vector)
    return real_vector is
    variable result : real_vector (0 to arg'length-1);
  begin
    for i in result'range loop
      result (i) := log (arg (arg'low+i));
    end loop;
    return result;
  end function log;

  -- Compare functions (use the defaults when possible)
  function "=" (
    l : real_matrix;
    r : real_vector)
    return BOOLEAN is
    variable lv : real_vector (0 to r'length-1);
  begin
    if l'length(1) = 1 and l'length(2) = r'length then
      lv := SubMatrix (l, l'low(1), l'low(2), 1, r'length);
      return lv = r;
    else
      return false;
    end if;
  end function "=";

  function "=" (
    l : real_vector;
    r : real_matrix)
    return BOOLEAN is
  begin
    return r = l;
  end function "=";

  function "/=" (
    l : real_matrix;
    r : real_vector)
    return BOOLEAN is
  begin
    return not (l = r);
  end function "/=";

  function "/=" (
    l : real_vector;
    r : real_matrix)
    return BOOLEAN is
  begin
    return not (r = l);
  end function "/=";

  -----------------------------------------------------------------------------
  -- Integer matrix/vector versions
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- matrix multiply
  -----------------------------------------------------------------------------
  function "*" (
    l, r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to l'length(1)-1,
                                      0 to r'length(2)-1);
  begin  -- multiply
    if l'length(2) /= r'length(1) then
      report real_matrix_pkg'instance_name & "Multiply "
        & "columns of left = " & INTEGER'image(l'length(2)) &
        " and rows or right = " & INTEGER'image (r'length(1))
        & " should be equal" severity error;
    elsif isempty(result) then
      -- silently return the empty matrix as defined
      null;
    elsif isempty (l) or isempty(r) then
      -- return zeros
      result := zeros(result'length(1), result'length(2));
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l(i+l'low(1), l'low(2)) * r(r'low(1), j+r'low(2));
          for k in 1 to l'length(2)-1 loop
            result (i, j) := result (i, j) +
                             (l(i+l'low(1), k+l'low(2)) *
                              r(k+r'low(1), j+r'low(2)));
          end loop;  -- k
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "*";

  -- purpose: matrix by vector
  function "*" (
    l : integer_matrix;
    r : integer_vector)
    return integer_matrix is
    variable result : integer_matrix (0 to l'length(1)-1,
                                      0 to r'length-1);
  begin  -- multiply
    if l'length(2) /= 1 then
      report real_matrix_pkg'instance_name & "Multiply "
        & " Matrix must have only one column to be multiplied by a vector, "
        & " l (" & INTEGER'image(l'length(1)) & ","
        & INTEGER'image(l'length(2)) & ") * r (" & INTEGER'image(r'length) &
        ") invalid" severity error;
    elsif l'length(1) /= r'length then
      report real_matrix_pkg'instance_name & "Multiply "
        & "columns of left matrix = " & INTEGER'image(l'length(2)) &
        " and size of right vector = " & INTEGER'image(r'length)
        & " should be equal" severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l(i+l'low(1), l'low(2)) * r(j+r'low);
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "*";

  -- purpose: multiply a vector by a matrix
  function "*" (
    l : integer_vector;
    r : integer_matrix)
    return integer_vector is
    variable result : integer_vector (0 to r'length(2)-1);
  begin  -- multiply
    if l'length /= r'length(1) then
      report real_matrix_pkg'instance_name & "Multiply "
        & "left vector length = " & INTEGER'image(l'length) &
        " and rows in right matrix = " & INTEGER'image(r'length(1))
        & " should be equal" severity error;
    elsif isempty(r) or isempty (l) then
      -- Silently return an empty matrix
      result := zeros (1, result'length);
    else
      for i in result'range loop
        result (i) := l(l'low) * r(r'low(1), i+r'low(2));
        for k in 1 to r'length(1)-1 loop
          result (i) := result (i) + (l(k+l'low) * r(k+r'low(1), i+r'low(2)));
        end loop;  -- k
      end loop;  -- i
    end if;
    return result;
  end function "*";

  -- purpose: multiply a scalar by a matrix
  function "*" (
    l : INTEGER;
    r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to r'length(1)-1,
                                      0 to r'length(2)-1);
  begin  -- multiply
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := l * r (i+r'low(1), j+r'low(2));
      end loop;  -- j
    end loop;  -- i
    return result;
  end function "*";

  -- purpose: multiply a scalar by a matrix
  function "*" (
    l : integer_matrix;
    r : INTEGER)
    return integer_matrix is
  begin  -- multiply
    return r * l;
  end function "*";

  -- purpose: multiply a scalar by a vector
  function "*" (
    l : INTEGER;
    r : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to r'length-1);
  begin  -- multiply
    for i in result'range loop
      result (i) := l * r (i+r'low);
    end loop;  -- i
    return result;
  end function "*";

  function "*" (
    l : integer_vector;
    r : INTEGER)
    return integer_vector is
  begin
    return r * l;
  end function "*";

  -- purpose: matrix addition
  function "+" (
    l, r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to l'length(1)-1,
                                      0 to l'length(2)-1);
  begin  -- addition
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "Addition " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r("&
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) +
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "+";

  -- purpose: vector addition
  function "+" (
    l, r : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Addition " &
        "Vector lengths do not match l(" & INTEGER'image(l'length) &
        ") /= r(" & INTEGER'image(r'length) & ")" severity error;
    else
      for i in result'range loop
        result(i) := l(l'low+i) + r(r'low+i);
      end loop;
    end if;
    return result;
  end function "+";

-- purpose: matrix subtraction
  function "-" (
    l, r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to l'length(1)-1,
                                      0 to l'length(2)-1);
  begin  -- subtraction
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "Subtraction " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) -
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function "-";

  -- purpose: vector addition
  function "-" (
    l, r : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Subtraction " &
        "Vector lengths do not match l(" & INTEGER'image(l'length) &
        ") /= r(" & INTEGER'image(r'length) & ")" severity error;
    else
      for i in result'range loop
        result(i) := l(l'low+i) - r(r'low+i);
      end loop;
    end if;
    return result;
  end function "-";

  -- unary minus
  function "-" (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (arg'range(1), arg'range(2));
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result(i, j) := - arg(i, j);
      end loop;
    end loop;
    return result;
  end function "-";

  function "-" (
    arg : integer_vector)
    return integer_vector is
    variable result : integer_vector (arg'range);
  begin
    for i in result'range loop
      result(i) := - arg(i);
    end loop;
    return result;
  end function "-";

  -- Absolute value
  function "abs" (
    arg : integer_vector)
    return integer_vector is
    variable result : integer_vector (arg'range);
  begin
    for i in result'range loop
      result(i) := abs (arg(i));
    end loop;
    return result;
  end function "abs";

  function "abs" (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (arg'range(1), arg'range(2));
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result(i, j) := abs (arg(i, j));
      end loop;
    end loop;
    return result;
  end function "abs";

  -- purpose: element by element multiply, Matlab .* operator
  function times (
    l, r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to l'length(1)-1,
                                      0 to l'length(2)-1);
  begin  -- ".*"
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "times " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (i+l'low(1), j+l'low(2)) *
                           r (i+r'low(1), j+r'low(2));
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function times;

  -- purpose: vector multiplication ".*" operator
  function times (
    l, r : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "times " &
        "Vectors lengths do not match l(" & INTEGER'image(l'length)
        & ") /= r("& INTEGER'image(r'length) & ")"
        severity error;
      return result;
    else
      for i in result'range loop
        result(i) := l(l'low+i) * r(r'low+i);
      end loop;
      return result;
    end if;
  end function times;

  -- Raise a matrix to a power, "^" operator
  -- Recursive
  function "**" (
    arg : integer_matrix;
    pow : NATURAL)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(1)-1,
                                      0 to arg'length(2)-1);
    variable Half : INTEGER;
  begin
    if arg'length(1) /= arg'length(2) then
      report real_matrix_pkg'instance_name & "** " &
        "Matrix is not square (" & INTEGER'image(arg'length(1)) & "," &
        INTEGER'image(arg'length(2)) & ")" severity error;
      return arg;
    elsif pow = 0 then
      return ones (arg'length(1), arg'length(2));
    elsif pow = 1 then
      return arg;
    elsif pow = 2 then
      return arg * arg;
    else  -- Recursively call this function until complete
      Half   := pow / 2;
      result := (arg**Half) * (arg**(pow-Half));
      return result;
    end if;
  end function "**";

  -- same as the Matlab .^ function
  function pow (
    l, r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to l'length(1)-1, 0 to l'length(2)-1);
  begin
    if l'length(1) /= r'length(1) or l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "pow " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r(" &
        INTEGER'image (r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := l (l'low(1)+i, l'low(2)+j) **
                           r (r'low(1)+i, r'low(2)+j);
        end loop;
      end loop;
    end if;
    return result;
  end function pow;

  -- same as the Matlab .^ function
  function pow (
    l, r : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "pow " &
        "Vectors are not of the same dimensions.  l(" &
        INTEGER'image (l'length) & ") /= r(" & INTEGER'image (r'length) & ")"
        severity error;
    else
      for i in result'range loop
        result (i) := l (l'low+i) ** r (r'low+i);
      end loop;
    end if;
    return result;
  end function pow;

  -- Compare functions (use the defaults when possible)
  function "=" (
    l : integer_matrix;
    r : integer_vector)
    return BOOLEAN is
    variable lv : integer_vector (0 to r'length-1);
  begin
    if l'length(1) = 1 and l'length(2) = r'length then
      lv := SubMatrix (l, l'low(1), l'low(2), 1, r'length);
      return lv = r;
    else
      return false;
    end if;
  end function "=";

  function "=" (
    l : integer_vector;
    r : integer_matrix)
    return BOOLEAN is
  begin
    return r = l;
  end function "=";

  function "/=" (
    l : integer_matrix;
    r : integer_vector)
    return BOOLEAN is
  begin
    return not (l = r);
  end function "/=";

  function "/=" (
    l : integer_vector;
    r : integer_matrix)
    return BOOLEAN is
  begin
    return not (r = l);
  end function "/=";

  -----------------------------------------------------------------------------
  -- Algorithmic function
  -----------------------------------------------------------------------------

  function round (
    arg             : real_matrix;
    constant places : INTEGER := 0)
    return real_matrix is
    variable result : real_matrix (arg'range(1), arg'range(2));
    constant rto    : REAL := 10.0**places;  -- number to round around
  begin
    for i in arg'range(1) loop
      for j in arg'range(2) loop
        result(i, j) := round (arg(i, j) * rto)/ rto;
      end loop;
    end loop;
    return result;
  end function round;

  function round (
    arg             : real_vector;
    constant places : INTEGER := 0)
    return real_vector is
    variable result : real_vector (arg'range);
    constant rto    : REAL := 10.0**places;  -- number to round around
  begin
    for i in arg'range loop
      result(i) := round (arg(i) * rto)/ rto;
    end loop;
    return result;
  end function round;

  -- Sum the diagonal
  function trace (
    arg : real_matrix)
    return REAL is
  begin
    return sum (diag(arg));
  end function trace;

  -- Sum a vector
  function sum (
    arg : real_vector)
    return REAL is
    variable result : REAL;
  begin
    if isempty (arg) then
      return 0.0;
    else
      result := arg (arg'low);
      for i in arg'low+1 to arg'high loop
        result := result + arg(i);
      end loop;
      return result;
    end if;
  end function sum;

  -- Sum a matrix and returns a vector
  function sum (
    arg          : real_matrix;
    constant dim : POSITIVE := 1)                        -- 1 = y, 2 = x
    return real_vector is
    variable resx : real_vector (0 to arg'length(2)-1);  -- x vector
    variable resy : real_vector (0 to arg'length(1)-1);  -- y vector
  begin
    if dim = 1 then
      for i in resx'range loop
        -- Pull out a column
        for j in resy'range loop
          resy (j) := arg (arg'low(1)+j, arg'low(2)+i);
        end loop;
        resx (i) := sum (resy);
      end loop;
      return resx;
    elsif dim = 2 then
      for i in resy'range loop
        -- Pull out a row
        for j in resx'range loop
          resx (j) := arg (arg'low(1)+i, arg'low(2)+j);
        end loop;
--        resx := SubMatrix (arg, i+arg'low(1), arg'low(2),  -- i,0
--                           1, resx'length);
        resy (i) := sum (resx);
      end loop;
      return resy;
    else
      report real_matrix_pkg'instance_name & "sum " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return resx;
    end if;
  end function sum;

  -- Multiply every element in a vector
  function prod (
    arg : real_vector)
    return REAL is
    variable result : REAL;
  begin
    if isempty (arg) then
      return 1.0;
    else
      result := arg (arg'low);
      for i in arg'low+1 to arg'high loop
        result := result * arg(i);
      end loop;
      return result;
    end if;
  end function prod;

  -- Multiply elements in a matrix and returns a vector
  function prod (
    arg          : real_matrix;
    constant dim : POSITIVE := 1)                        -- 1 = y, 2 = x
    return real_vector is
    variable resx : real_vector (0 to arg'length(2)-1);  -- x vector
    variable resy : real_vector (0 to arg'length(1)-1);  -- y vector
  begin
    if dim = 1 then
      for i in resx'range loop
        -- Pull out a column
        for j in resy'range loop
          resy (j) := arg (arg'low(1)+j, arg'low(2)+i);
        end loop;
        resx (i) := prod (resy);
      end loop;
      return resx;
    elsif dim = 2 then
      for i in resy'range loop
        -- Pull out a row
        for j in resx'range loop
          resx (j) := arg (arg'low(1)+i, arg'low(2)+j);
        end loop;
        resy (i) := prod (resx);
      end loop;
      return resy;
    else
      report real_matrix_pkg'instance_name & "prod " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return resx;
    end if;
  end function prod;

  -- purpose: Dot product of two vectors
  function dot (
    l, r : real_vector)
    return REAL is
    variable result : REAL;
  begin
    result := 0.0;
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Dot " &
        "Vectors lengths do not match l(" & INTEGER'image(l'length)
        & ") /= r("& INTEGER'image(r'length) & ")"
        severity error;
    else
      for i in 0 to l'length-1 loop
        result := result + (l (l'low+i) * r (r'low+i));
      end loop;
    end if;
    return result;
  end function dot;

  -- purpose: cross product of two vectors
  function cross (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Cross " &
        "Vectors do not match l(" & INTEGER'image(l'length) & ") /= r("&
        INTEGER'image(r'length) & ")"
        severity error;
    elsif l'length /= 3 then
      report real_matrix_pkg'instance_name & "Cross " &
        "function only works on a vector length of 3, length given was "
        & INTEGER'image(l'length)
        severity error;
    else
      result(0) := l(l'low+1)*r(r'low+2) - l(l'low+2)*r(r'low+1);
      result(1) := l(l'low+2)*r(r'low+0) - l(l'low+0)*r(r'low+2);
      result(2) := l(l'low+0)*r(r'low+1) - l(l'low+1)*r(r'low+0);
    end if;
    return result;
  end function cross;

  -- purpose: cross product of two matrices
  function cross (
    l, r : real_matrix)
    return real_matrix is
    variable a, b, c : real_vector (0 to l'length(1)-1);  -- variables
    variable result  : real_matrix (0 to l'length(1)-1, 0 to l'length(2)-1);
  begin
    if l'length(1) /= r'length(1) and l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "Cross " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r("&
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    elsif l'length(2) /= 3 then
      report real_matrix_pkg'instance_name & "Cross " &
        "function only works on a matrix length of 3, length given was ("
        & INTEGER'image(l'length(1)) & "," & INTEGER'image(l'length(2)) & ")"
        severity error;
    else
      for i in result'range(2) loop
        for j in a'range loop
          a (j) := l (l'low(1)+j, l'low(2)+i);
          b (j) := r (r'low(1)+j, r'low(2)+i);
        end loop;
--        a := SubMatrix (l, l'low(1), i+l'low(2), a'length, 1);  -- return column i
--        b := SubMatrix (r, r'low(1), i+l'low(2), b'length, 1);
        c := cross (a, b);
        InsertColumn (c, result, 0, i);  -- Put result in column i
      end loop;
    end if;
    return result;
  end function cross;

  -- Kronecker product.
  function kron (
    l, r : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to (l'length(1)*r'length(1))-1,
                                   0 to (l'length(2)*r'length(2))-1);
  begin
    for i in 0 to l'length(1)-1 loop
      for j in 0 to l'length(2)-1 loop
        for m in 0 to r'length(1)-1 loop
          for n in 0 to r'length(2)-1 loop
            result ((i*r'length(1))+m, (j*r'length(2))+n) :=
              l(i, j) * r(m, n);
          end loop;  -- n
        end loop;  -- m
      end loop;  -- j
    end loop;  -- i
    return result;
  end function kron;

  -- purpose: Finds the determinant of a matrix
  -- Note that this one is recursive!
  -- http://people.richland.edu/james/lecture/m116/matrices/determinant.html
  function det (
    arg : real_matrix)
    return REAL is
    variable i, j : INTEGER;            -- temp variables
    variable plus : BOOLEAN;            -- Used on the last sum
    variable reduced : real_matrix (0 to arg'length(1)-2,
                                    0 to arg'length(2)-2);  -- reduced matrix
    variable result, prod : REAL;
  begin  -- determinant
    if isempty(arg) then
      result := 0.0;
    elsif arg'length(1) /= arg'length(2) then
      report real_matrix_pkg'instance_name & "determinant " &
        " Matrix is not square " & INTEGER'image(arg'length(1)) &
        " /= " & INTEGER'image(arg'length(2)) severity error;
      result := 0.0;
    elsif arg'length(1) = 1 then        -- 1x1 matrix.
      result := arg(arg'low(1), arg'low(2));
    elsif arg'length(1) = 2 then        -- 2x2 matrix
      -- return ad - bc
      result := (arg(arg'low(1), arg'low(2)) * arg(arg'high(1), arg'high(2))) -
                (arg(arg'low(1), arg'high(2)) * arg(arg'high(1), arg'low(2)));
    else                                -- Go across the top row
      plus   := true;
      result := 0.0;
      for j in arg'range(2) loop
        reduced := exclude (arg, arg'low(1), j);
        prod    := arg (arg'low(1), j) * det (reduced);
        if plus then
          result := result + prod;
        else
          result := result - prod;
        end if;
        plus := not plus;
      end loop;  -- j
    end if;
    return result;
  end function det;

  -- purpose: Inverts a matrix
  -- http://people.richland.edu/james/lecture/m116/matrices/determinant.html
  function inv (
    arg : real_matrix)
    return real_matrix is
    variable i, j : INTEGER;            -- temp variables
    variable plus : BOOLEAN;            -- Used on the last sum
    variable reduced : real_matrix (0 to arg'length(1)-2,
                                    0 to arg'length(2)-2);  -- reduced matrix
    variable cofact : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);   -- minor matrix
    variable result : real_matrix (0 to arg'length(2)-1,
                                   0 to arg'length(1)-1);
    variable deter, prod : REAL;
  begin  -- invert
    if isempty(arg) then
      null;
    elsif arg'length(1) /= arg'length(2) then
      report real_matrix_pkg'instance_name & "invert " &
        " Matrix is not square " & INTEGER'image(arg'length(1)) &
        " /= " & INTEGER'image(arg'length(2)) severity error;
      result := zeros (result'length(1), result'length(2));
    elsif arg'length(1) = 1 then        -- 1x1 case
      if arg (arg'low(1), arg'low(2)) = 0.0 then
        report real_matrix_pkg'instance_name & "invert " &
          " Matrix is not invertible, Determinant = 0"
          severity error;
        result (0, 0) := 0.0;
      else
        result (0, 0) := 1.0 / arg(arg'low(1), arg'low(2));
      end if;
    elsif arg'length(1) = 2 then        -- 2x2 case
      deter := det (arg);
      if deter = 0.0 then
        report real_matrix_pkg'instance_name & "invert " &
          " Matrix is not invertible, Determinant = 0"
          severity error;
        result := zeros (2, 2);
      else
        prod          := 1.0/deter;
        result (0, 0) := arg (arg'high(1), arg'high(2)) * prod;
        result (0, 1) := -arg (arg'low(1), arg'high(2)) * prod;
        result (1, 0) := -arg (arg'high(1), arg'low(2)) * prod;
        result (1, 1) := arg (arg'low(1), arg'low(2)) * prod;
      end if;
    else
      -- reduce the matrix to a matrix of cofactors
      plus := true;
      for i in arg'range(1) loop
        for j in arg'range(2) loop
          reduced := exclude (arg, i, j);
          deter   := det (reduced);
          if plus then
            cofact (i-arg'low(1), j-arg'low(2)) := deter;
          else
            cofact (i-arg'low(1), j-arg'low(2)) := -deter;
          end if;
          plus := not plus;
        end loop;  -- j
      end loop;  -- i
      -- Find the determinant of the entire matrix.
      -- Since I already have a matrix of cofactors, I can just add it up.
      deter := 0.0;
      for j in arg'range(2) loop
        prod  := arg (arg'low(1), j) * cofact(0, j-arg'low(2));
        deter := deter + prod;
      end loop;  -- j
      if deter = 0.0 then
        report real_matrix_pkg'instance_name & "invert " &
          " Matrix is not invertible, Determinant = 0"
          severity error;
        result := zeros (result'length(1), result'length(2));
      else
        -- multiply the transposed cofactors by 1/determinant
        result := (1.0/deter) * transpose (cofact);
      end if;
    end if;
    return result;
  end function inv;

  -- Solve a linear equation
  -- This is done via the "lower triangle" method.
  function linsolve (
    l : real_matrix;
    r : real_vector)
    return real_vector is
    -- Augmented matrix
    variable augmat : real_matrix (0 to l'length(1)-1, 0 to l'length(2));
    variable result : real_vector (0 to r'length-1);
    variable var    : REAL;
  begin
    if l'length(1) /= r'length then
      report real_matrix_pkg'instance_name & "linsolve " &
        "Width of matrix does not equal length of vector "
        & INTEGER'image(l'length(2)) & " /= " &
        INTEGER'image(r'length) severity error;
      return r;
    else
      BuildMatrix (l, augmat, 0, 0);    -- Put matrix l at position 0,0
      -- Put vector r vertically at position 0,3
      InsertColumn (r, augmat, 0, l'length(2));
      -- Perform a "lower triangle" solution
      for j in 0 to l'length(2)-1 loop
        for i in 0 to l'length(1)-1 loop
          if i = j then
            -- divide this row by augmat(i,j)
            var := augmat (i, j);
            if var = 0.0 then
              report real_matrix_pkg'instance_name & "linsolve " &
                "Linear system has no solution" severity error;
              print_matrix (augmat);
              return r;
            end if;
            for k in j to l'length(2) loop
              augmat (i, k) := augmat (i, k)/var;
            end loop;
          elsif i > j then
            -- subtract last diagonal row *-(i,j)
            var := augmat(i, j);
            for k in j to l'length(2) loop
              augmat (i, k) := augmat (i, k) - (var * augmat (j, k));
            end loop;
          end if;
        end loop;
      end loop;
      -- reverse the diagonal to solve
      for k in result'range loop
        result(k) := augmat (k, augmat'high(2));
      end loop;
--      result := SubMatrix (augmat, 0, augmat'high(2), result'length, 1);
      for m in result'high-1 downto 0 loop
        for n in m+1 to l'length(1) -1 loop
          result(m) := result(m) - (augmat(m, n) * result(n));
        end loop;
      end loop;
      return result;
    end if;
    ---------------------------------------------------------------------------
    -- I could have done this as inv(l)*r, (mldivide) but this is faster.
    ---------------------------------------------------------------------------
  end function linsolve;

  -- Normalize a Matrix
  function normalize (
    arg           : real_matrix;
    constant rval : REAL := 1.0)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1, 0 to arg'length(2)-1);
    variable max    : REAL;             -- largest number in this matrix
  begin
    if not isempty (arg) then
      max := abs(arg (arg'low(1), arg'low(2)));
      for i in arg'range(1) loop
        for j in arg'range(2) loop
          max := maximum (max, abs (arg(i, j)));
        end loop;
      end loop;
      result := arg * (rval/max);
    end if;
    return result;
  end function normalize;

  -- Normalize a Vector
  function normalize (
    arg           : real_vector;
    constant rval : REAL := 1.0)
    return real_vector is
    variable result : real_vector (0 to arg'length-1);
    variable max    : REAL;             -- largest number in this matrix
  begin
    if not isempty (arg) then
      max := abs(arg (arg'low));
      for i in arg'range loop
        max := maximum (max, abs (arg(i)));
      end loop;
      result := arg * (rval/max);
    end if;
    return result;
  end function normalize;

  -- Evaluate the polynomial
  function polyval (
    l, r : real_vector)
    return real_vector is
    variable result : real_vector (r'range);
  begin
    if not (isempty (l) or isempty(r)) then
      for i in r'range loop
        result(i) := 0.0;
        for j in l'range loop
          result(i) := result(i) + (l(j) * (r(i)**REAL(j)));
        end loop;
      end loop;
    end if;
    return result;
  end function polyval;

  -----------------------------------------------------------------------------
  -- Integer versions
  -----------------------------------------------------------------------------
  -- Sum the diagonal
  function trace (
    arg : integer_matrix)
    return INTEGER is
  begin
    return sum (diag(arg));
  end function trace;

  -- Sum a vector
  function sum (
    arg : integer_vector)
    return INTEGER is
    variable result : INTEGER;
  begin
    if isempty (arg) then
      return 0;
    else
      result := arg (arg'low);
      for i in arg'low+1 to arg'high loop
        result := result + arg(i);
      end loop;
      return result;
    end if;
  end function sum;

  -- Sum a matrix and returns a vector
  function sum (
    arg          : integer_matrix;
    constant dim : POSITIVE := 1)                           -- 1 = y, 2 = x
    return integer_vector is
    variable resx : integer_vector (0 to arg'length(2)-1);  -- x vector
    variable resy : integer_vector (0 to arg'length(1)-1);  -- y vector
  begin
    if dim = 1 then
      for i in resx'range loop
        -- Pull out a column
        resy := SubMatrix (arg, arg'low(1), i+arg'low(2),   -- 0,i
                           resy'length, 1);
        resx (i) := sum (resy);
      end loop;
      return resx;
    elsif dim = 2 then
      for i in resy'range loop
        -- Pull out a row
        for j in resx'range loop
          resx (j) := arg (arg'low(1)+i, arg'low(2)+j);
        end loop;
        resy (i) := sum (resx);
      end loop;
      return resy;
    else
      report real_matrix_pkg'instance_name & "sum " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return resx;
    end if;
  end function sum;

  -- Multiply every element in a vector
  function prod (
    arg : integer_vector)
    return INTEGER is
    variable result : INTEGER;
  begin
    if isempty (arg) then
      return 1;
    else
      result := arg (arg'low);
      for i in arg'low+1 to arg'high loop
        result := result * arg(i);
      end loop;
      return result;
    end if;
  end function prod;

  -- Multiply elements in a matrix and returns a vector
  function prod (
    arg          : integer_matrix;
    constant dim : POSITIVE := 1)                           -- 1 = y, 2 = x
    return integer_vector is
    variable resx : integer_vector (0 to arg'length(2)-1);  -- x vector
    variable resy : integer_vector (0 to arg'length(1)-1);  -- y vector
  begin
    if dim = 1 then
      for i in resx'range loop
        -- Pull out a column
        resy := SubMatrix (arg, arg'low(1), i+arg'low(2),   -- 0,i
                           resy'length, 1);
        resx (i) := prod (resy);
      end loop;
      return resx;
    elsif dim = 2 then
      for i in resy'range loop
        -- Pull out a row
        for j in resx'range loop
          resx (j) := arg (arg'low(1)+i, arg'low(2)+j);
        end loop;
        resy (i) := prod (resx);
      end loop;
      return resy;
    else
      report real_matrix_pkg'instance_name & "prod " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return resx;
    end if;
  end function prod;

  -- purpose: Dot product of two vectors
  function dot (
    l, r : integer_vector)
    return INTEGER is
    variable result : INTEGER;
  begin
    result := 0;
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Dot " &
        "Vectors lengths do not match l(" & INTEGER'image(l'length)
        & ") /= r("& INTEGER'image(r'length) & ")"
        severity error;
    else
      for i in 0 to l'length-1 loop
        result := result + (l (l'low+i) * r (r'low+i));
      end loop;
    end if;
    return result;
  end function dot;

  -- purpose: cross product of two vectors
  function cross (
    l, r : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to l'length-1);
  begin
    if l'length /= r'length then
      report real_matrix_pkg'instance_name & "Cross " &
        "Vectors do not match l(" & INTEGER'image(l'length) & ") /= r("&
        INTEGER'image(r'length) & ")"
        severity error;
    elsif l'length /= 3 then
      report real_matrix_pkg'instance_name & "Cross " &
        "function only works on a vector length of 3, length given was "
        & INTEGER'image(l'length)
        severity error;
    else
      result(0) := l(l'low+1)*r(r'low+2) - l(l'low+2)*r(r'low+1);
      result(1) := l(l'low+2)*r(r'low+0) - l(l'low+0)*r(r'low+2);
      result(2) := l(l'low+0)*r(r'low+1) - l(l'low+1)*r(r'low+0);
    end if;
    return result;
  end function cross;

  -- purpose: cross product of two matrices
  function cross (
    l, r : integer_matrix)
    return integer_matrix is
    variable a, b, c : integer_vector (0 to l'length(1)-1);     -- variables
    variable result  : integer_matrix (0 to l'length(1)-1, 0 to l'length(2)-1);
  begin
    if l'length(1) /= r'length(1) and l'length(2) /= r'length(2) then
      report real_matrix_pkg'instance_name & "Cross " &
        "Matrices do not match l(" & INTEGER'image(l'length(1)) & "," &
        INTEGER'image(l'length(2)) & ") /= r("&
        INTEGER'image(r'length(1)) & "," & INTEGER'image(r'length(2)) & ")"
        severity error;
    elsif l'length(2) /= 3 then
      report real_matrix_pkg'instance_name & "Cross " &
        "function only works on a matrix length of 3, length given was ("
        & INTEGER'image(l'length(1)) & "," & INTEGER'image(l'length(2)) & ")"
        severity error;
    else
      for i in result'range(2) loop
        a := SubMatrix (l, l'low(1), i+l'low(2), a'length, 1);  -- return column i
        b := SubMatrix (r, r'low(1), i+l'low(2), b'length, 1);
        c := cross (a, b);
        InsertColumn (c, result, 0, i);  -- Put result in column i
      end loop;
    end if;
    return result;
  end function cross;

  -- Kronecker product.
  function kron (
    l, r : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to (l'length(1)*r'length(1))-1,
                                      0 to (l'length(2)*r'length(2))-1);
  begin
    for i in 0 to l'length(1)-1 loop
      for j in 0 to l'length(2)-1 loop
        for m in 0 to r'length(1)-1 loop
          for n in 0 to r'length(2)-1 loop
            result ((i*r'length(1))+m, (j*r'length(2))+n) :=
              l(i, j) * r(m, n);
          end loop;  -- n
        end loop;  -- m
      end loop;  -- j
    end loop;  -- i
    return result;
  end function kron;

  function det (
    arg : integer_matrix)
    return INTEGER is
    variable i, j : INTEGER;            -- temp variables
    variable plus : BOOLEAN;            -- Used on the last sum
    variable reduced : integer_matrix (0 to arg'length(1)-2,
                                       0 to arg'length(2)-2);  -- reduced matrix
    variable result, prod : INTEGER;
  begin  -- determinant
    if isempty(arg) then
      result := 0;
    elsif arg'length(1) /= arg'length(2) then
      report real_matrix_pkg'instance_name & "determinant " &
        " Matrix is not square " & INTEGER'image(arg'length(1)) &
        " /= " & INTEGER'image(arg'length(2)) severity error;
      result := 0;
    elsif arg'length(1) = 1 then        -- 1x1 matrix.
      result := arg(arg'low(1), arg'low(2));
    elsif arg'length(1) = 2 then        -- 2x2 matrix
      -- return ad - bc
      result := (arg(arg'low(1), arg'low(2)) * arg(arg'high(1), arg'high(2))) -
                (arg(arg'low(1), arg'high(2)) * arg(arg'high(1), arg'low(2)));
    else                                -- Go across the top row
      plus   := true;
      result := 0;
      for j in arg'range(2) loop
        reduced := exclude (arg, arg'low(1), j);
        prod    := arg (arg'low(1), j) * det (reduced);
        if plus then
          result := result + prod;
        else
          result := result - prod;
        end if;
        plus := not plus;
      end loop;  -- j
    end if;
    return result;
  end function det;

  -- Evaluate the polynomial
  function polyval (
    l, r : integer_vector)
    return integer_vector is
    variable result : integer_vector (r'range);
  begin
    if not (isempty (l) or isempty(r)) then
      for i in r'range loop
        result(i) := 0;
        for j in l'range loop
          result(i) := result(i) + (l(j) * (r(i)**j));
        end loop;
      end loop;
    end if;
    return result;
  end function polyval;

  -----------------------------------------------------------------------------
  -- These functions manipulate the data in a matrix non mathematically
  -----------------------------------------------------------------------------

  -- purpose: Returns "true" if a matrix is null.
  function isempty (
    arg : real_matrix)
    return BOOLEAN is
  begin
    if arg'length(1) < 1 or arg'length(2) < 1 then
      return true;
    else
      return false;
    end if;
  end function isempty;

  -- purpose: Returns "true" if a matrix is null.
  function isempty (
    arg : real_vector)
    return BOOLEAN is
  begin
    if arg'length < 1 then
      return true;
    else
      return false;
    end if;
  end function isempty;

  -- purpose: Transpose a matrix
  function transpose (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(2)-1,
                                   0 to arg'length(1)-1);
  begin  -- transpose
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (j+arg'low(1), i+arg'low(2));
      end loop;  -- j
    end loop;  -- i
    return result;
  end function transpose;

  -- purpose: Transpose a matrix
  function transpose (
    arg : real_vector)
    return real_matrix is
    -- return a matrix with 1 column
    variable result : real_matrix (0 to arg'length-1, 0 to 0);
  begin  -- transpose
    for i in result'range(1) loop
      result (i, 0) := arg (i+arg'low);
    end loop;  -- i
    return result;
  end function transpose;

  -- purpose: Transpose a matrix
  function transpose (
    arg : real_matrix)
    return real_vector is
    variable result : real_vector (0 to arg'length(1)-1);
  begin  -- transpose
    if arg'length(2) /= 1 then
      report real_matrix_pkg'instance_name &
        "Transpose (Matrix) return Vector: " &
        "input vector must have one column, found " &
        INTEGER'image(arg'length(2)) severity error;
    else
      for i in result'range loop
        result (i) := arg (i+arg'low(1), arg'low(2));
      end loop;  -- i
    end if;
    return result;
  end function transpose;

  -- purpose: returns a matrix of zeros
  function zeros (
    rows, columns : NATURAL)
    return real_matrix is
  begin  -- zeros
    return repmat (arg     => 0.0,
                   rows    => rows,
                   columns => columns);
  end function zeros;

  -- purpose: returns a matrix of zeros
  function zeros (
    rows, columns : NATURAL)
    return real_vector is
  begin  -- zeros
    return repmat (arg     => 0.0,
                   rows    => rows,
                   columns => columns);
  end function zeros;

  -- purpose: returns a matrix of zeros
  function ones (
    rows, columns : NATURAL)
    return real_matrix is
  begin  -- ones
    return repmat (arg     => 1.0,
                   rows    => rows,
                   columns => columns);
  end function ones;

  -- purpose: returns a matrix of zeros
  function ones (
    rows, columns : NATURAL)
    return real_vector is
  begin  -- ones
    return repmat (arg     => 1.0,
                   rows    => rows,
                   columns => columns);
  end function ones;

  -- purpose: Returns an identity matrix
  function eye (
    rows, columns : NATURAL)
    return real_matrix is
    variable result : real_matrix (0 to rows-1, 0 to columns-1);
  begin  -- eye
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i = j then
          result (i, j) := 1.0;
        else
          result (i, j) := 0.0;
        end if;
      end loop;  -- j
    end loop;  -- i
    return result;
  end function eye;

  -- Concatenates two matrices together
  function cat (
    constant dim : POSITIVE;            -- 1 = y, 2 = x
    l, r         : real_matrix)
    return real_matrix is
  begin
    if dim = 1 then
      return vertcat (l, r);
    elsif dim = 2 then
      return horzcat (l, r);
    else
      report real_matrix_pkg'instance_name & "cat " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return l;
    end if;
  end function cat;

  -- Concatenates two matrices together
  function horzcat (
    l, r : real_matrix)
    return real_matrix is
    variable rx : real_matrix (0 to l'length(1)-1,
                               0 to (l'length(2) + r'length(2)-1));
    variable m, n : INTEGER;            -- index variables
  begin
    if l'length (1) = r'length(1) then
      for i in rx'range(1) loop
        for j in 0 to l'length(2)-1 loop
          rx (i, j) := l (i+l'low(1), j+l'low(2));
        end loop;
      end loop;
      for i in rx'range(1) loop
        for j in 0 to r'length(2)-1 loop
          rx (i, j+l'length(2)) := r (i+r'low(1), j+r'low(2));
        end loop;
      end loop;
    else
      report real_matrix_pkg'instance_name & "horzcat " &
        "row dimension does not match " & INTEGER'image(l'length(1)) &
        " /= " & INTEGER'image(r'length(1)) severity error;
    end if;
    return rx;
  end function horzcat;

  -- Concatenates two matrices together
  function vertcat (
    l, r : real_matrix)
    return real_matrix is
    variable ry : real_matrix (0 to (l'length(1) + r'length(1)-1),
                               0 to l'length(2)-1);
    variable m, n : INTEGER;            -- index variables
  begin
    if l'length (2) = r'length(2) then
      for i in 0 to l'length(1)-1 loop
        for j in ry'range(2) loop
          ry (i, j) := l (i+l'low(1), j+l'low(2));
        end loop;
      end loop;
      for i in 0 to r'length(1)-1 loop
        for j in ry'range(2) loop
          ry (i+l'length(1), j) := r (i+r'low(1), j+r'low(2));
        end loop;
      end loop;
    else
      report real_matrix_pkg'instance_name & "vertcat " &
        "column dimension does not match " & INTEGER'image(l'length(2)) &
        " /= " & INTEGER'image(r'length(2)) severity error;
    end if;
    return ry;
  end function vertcat;

  -- Flip the dimensions on a matrix
  function flipdim (
    arg          : real_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return real_matrix is
  begin
    if dim = 1 then
      return flipup (arg);
    elsif dim = 2 then
      return fliplr (arg);
    else
      report real_matrix_pkg'instance_name & "flipdim " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return arg;
    end if;
  end function flipdim;

  -- flip left to right
  function fliplr (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
    variable i, j : INTEGER;
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (arg'low(1)+i, arg'high(2)-j);
      end loop;
    end loop;
    return result;
  end function fliplr;

  -- Flip up and down
  function flipup (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1, 0 to arg'length(2)-1);
    variable i, j   : INTEGER;
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (arg'high(1)-i, arg'low(2)+j);
      end loop;
    end loop;
    return result;
  end function flipup;

  -- flip a vector
  function fliplr (
    arg : real_vector)
    return real_vector is
    variable result : real_vector (0 to arg'length-1);
    variable i      : INTEGER;
  begin
    for i in result'range(1) loop
      result (i) := arg (arg'high-i);
    end loop;
    return result;
  end function fliplr;

  -- Matrix rotation
  function rot90 (
    arg          : real_matrix;
    constant dim : INTEGER := 1)
    return real_matrix is
    variable rx : real_matrix (0 to arg'length(1)-1,
                                 0 to arg'length(2)-1);
    variable ry : real_matrix (0 to arg'length(2)-1,
                                 0 to arg'length(1)-1);
    variable i, j : INTEGER;
  begin
    if dim = 1 or dim = -3 then
      for i in ry'range(1) loop
        for j in ry'range(2) loop
          ry (i, j) := arg (arg'low(1)+j, arg'high(2)-i);
        end loop;
      end loop;
      return ry;
    elsif dim = 2 or dim = -2 then
      for i in rx'range(1) loop
        for j in rx'range(2) loop
          rx (i, j) := arg (arg'high(1)-i, arg'high(2)-j);
        end loop;
      end loop;
      return rx;
    elsif dim = 3 or dim = -1 then
      for i in ry'range(1) loop
        for j in ry'range(2) loop
          ry (i, j) := arg (arg'high(1)-j, arg'low(2)+i);
        end loop;
      end loop;
      return ry;
    else
      return arg;
    end if;
  end function rot90;

  -- Change the shape of a matrix
  function reshape (
    arg                    : real_matrix;
    constant rows, columns : POSITIVE)
    return real_matrix is
    variable result     : real_matrix (0 to rows-1, 0 to columns-1);  -- result
    variable i, j, k, l : INTEGER;
  begin
    if arg'length(1)*arg'length(2) < rows*columns then
      report real_matrix_pkg'instance_name & "reshape " &
        "not enough elements in arg (" & INTEGER'image(arg'length(1)) &
        "," & INTEGER'image(arg'length(2)) & ") < result (" &
        INTEGER'image(rows) & "," & INTEGER'image(columns) & ")"
        severity error;
    else
      k := arg'low(1);
      l := arg'low(2);
      for i in result'range(2) loop
        for j in result'range(1) loop
          result (j, i) := arg (k, l);
          if k = arg'high(1) then
            k := arg'low(1);
            l := l + 1;
          else
            k := k + 1;
          end if;
        end loop;
      end loop;
    end if;
    return result;
  end function reshape;

  -- Change the shape of a matrix
  function reshape (
    arg                    : real_vector;
    constant rows, columns : POSITIVE)
    return real_matrix is
    variable result  : real_matrix (0 to rows-1, 0 to columns-1);  -- result
    variable i, j, k : INTEGER;
  begin
    if arg'length < rows*columns then
      report real_matrix_pkg'instance_name & "reshape " &
        "not enough elements in arg (" & INTEGER'image(arg'length) &
        ") < result (" & INTEGER'image(rows) & "," &
        INTEGER'image(columns) & ")"
        severity error;
    else
      k := arg'low;
      for i in result'range(2) loop
        for j in result'range(1) loop
          result (j, i) := arg (k);
          k             := k + 1;
        end loop;
      end loop;
    end if;
    return result;
  end function reshape;

  function reshape (
    arg           : real_matrix;
    rows, columns : POSITIVE)
    return real_vector is
    variable rx         : real_vector (0 to rows-1);
    variable ry         : real_vector (0 to columns-1);
    variable i, j, k, l : INTEGER;
  begin
    if rows = 1 then
      if arg'length(1) * arg'length(2) < ry'length then
        report real_matrix_pkg'instance_name & "reshape " &
          "not enough elements in arg (" & INTEGER'image(arg'length(1)) &
          "," & INTEGER'image(arg'length(2)) & ") < result (" &
          INTEGER'image (ry'length) & ")"
          severity error;
        return ry;
      else
        k := arg'low(2);
        l := arg'low(1);
        for j in ry'range loop
          ry (j) := arg (l, k);
          if k = arg'high(2) then
            k := arg'low(2);
            l := l + 1;
          else
            k := k + 1;
          end if;
        end loop;
        return ry;
      end if;
    elsif columns = 1 then
      if arg'length(1) * arg'length(2) < rx'length then
        report real_matrix_pkg'instance_name & "reshape " &
          "not enough elements in arg (" & INTEGER'image(arg'length(1)) &
          "," & INTEGER'image(arg'length(2)) & ") < result (" &
          INTEGER'image (rx'length) & ")"
          severity error;
        return rx;
      else
        k := arg'low(1);
        l := arg'low(2);
        for j in rx'range loop
          rx (j) := arg (k, l);
          if k = arg'high(1) then
            k := arg'low(1);
            l := l + 1;
          else
            k := k + 1;
          end if;
        end loop;
        return rx;
      end if;
    else
      report real_matrix_pkg'instance_name & "reshape " &
        "rows or columns need to be 1 got " & INTEGER'image(rows) & "," &
        INTEGER'image(columns) severity error;
      return rx;
    end if;
  end function reshape;

  -- returns the size of a matrix
  function size (
    arg : real_matrix)
    return integer_vector is
    variable result : integer_vector (0 to 1);
  begin
    result (0) := arg'length(1);
    result (1) := arg'length(2);
    return result;
  end function size;

  -- True if matrix is one dimensional
  function isvector (
    arg : real_matrix)
    return BOOLEAN is
  begin
    if arg'length(1) = 1 or arg'length(2) = 1 then
      return true;
    else
      return false;
    end if;
  end function isvector;

  -- True if a 1/1 matrix
  function isscalar (
    arg : real_matrix)
    return BOOLEAN is
  begin
    if arg'length(1) = 1 and arg'length(2) = 1 then
      return true;
    else
      return false;
    end if;
  end function isscalar;

  -- returns the number of elements in a matrix
  function numel (
    arg : real_matrix)
    return INTEGER is
  begin
    if isempty (arg) then
      return 0;
    else
      return arg'length(1) * arg'length(2);
    end if;
  end function numel;

  -- Return the diagonal of a matrix
  function diag (
    arg : real_matrix)
    return real_vector is
    variable result : real_vector (0 to minimum (arg'length(2),
                                                 arg'length(1))-1);
  begin
    for i in result'range loop
      result (i) := arg (i+arg'low(1), i+arg'low(2));
    end loop;
    return result;
  end function diag;

  -- Return a matrix with the vector as the diagonal
  function diag (
    arg : real_vector)
    return real_matrix is
    variable result : real_matrix (0 to arg'length-1, 0 to arg'length-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i = j then
          result (i, j) := arg (i+arg'low);
        else
          result (i, j) := 0.0;
        end if;
      end loop;
    end loop;
    return result;
  end function diag;

  -- Return the matrix of a diagonal
  function blkdiag (
    arg : real_vector)
    return real_matrix is
    variable result : real_matrix (0 to arg'length-1, 0 to arg'length-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i = j then
          result (i, j) := arg (i+arg'low);
        else
          result (i, j) := 0.0;
        end if;
      end loop;
    end loop;
    return result;
  end function blkdiag;

  -- Creates a block diagonal matrix from "arg", repeated "rep" times
  -- This differs from the function of "blkdiag" in Matlab
  function blockdiag (
    arg : real_matrix;
    rep : POSITIVE)
    return real_matrix is
    variable result : real_matrix (0 to (arg'length(1)*rep)-1,
                                   0 to (arg'length(2)*rep)-1);
  begin
    -- Zero out the result matrix
    result := repmat (0.0, arg'length(1)*rep, arg'length(2)*rep);
    -- Fill in across the diagonal
    for k in 0 to rep-1 loop
      for m in 0 to arg'length(1)-1 loop
        for n in 0 to arg'length(2)-1 loop
          result ((k*arg'length(1))+m, (k*arg'length(2))+n) :=
            arg (m+arg'low(1), n+arg'low(2));
        end loop;
      end loop;
    end loop;
    return result;
  end function blockdiag;

  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : REAL;
    constant rows, columns : NATURAL)
    return real_matrix is
    variable result : real_matrix (0 to rows-1, 0 to columns-1);
  begin  -- ones
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg;
      end loop;  -- j
    end loop;  -- i
    return result;
  end function repmat;

  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : REAL;
    constant rows, columns : NATURAL)
    return real_vector is
    variable result : real_vector (0 to columns-1);
  begin  -- ones
    if rows /= 1 then
      report real_matrix_pkg'instance_name & "repmat" &
        " return vector, number of rows not 1, was " &
        INTEGER'image(rows) severity error;
    else
      for i in result'range loop
        result (i) := arg;
      end loop;  -- i
    end if;
    return result;
  end function repmat;

  -- Replicate a matrix row/column times
  function repmat (
    arg                    : real_matrix;
    constant rows, columns : NATURAL)
    return real_matrix is
    variable result : real_matrix (0 to (arg'length(1)*rows)-1,
                                   0 to (arg'length(2)*columns)-1);
    variable i, j, m, n : INTEGER;      -- index variables
  begin
    m := 0;
    n := 0;
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (m+arg'low(1), n+arg'low(2));
        if n = arg'length(2)-1 then
          n := 0;
        else
          n := n + 1;
        end if;
      end loop;
      if m = arg'length(1)-1 then
        m := 0;
      else
        m := m + 1;
      end if;
    end loop;
    return result;
  end function repmat;

  -- Return the lower triangle of a matrix
  function tril (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i > j then
          result (i, j) := arg (i+ arg'low(1), j+arg'low(2));
        else
          result (i, j) := 0.0;
        end if;
      end loop;
    end loop;
    return result;
  end function tril;

  -- Return the upper triangle of a matrix
  function triu (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i < j then
          result (i, j) := arg (i+ arg'low(1), j+arg'low(2));
        else
          result (i, j) := 0.0;
        end if;
      end loop;
    end loop;
    return result;
  end function triu;

  -----------------------------------------------------------------------------
  -- Integer versions
  -----------------------------------------------------------------------------

  -- purpose: Returns "true" if a matrix is null.
  function isempty (
    arg : integer_matrix)
    return BOOLEAN is
  begin
    if arg'length(1) < 1 or arg'length(2) < 1 then
      return true;
    else
      return false;
    end if;
  end function isempty;

  -- purpose: Returns "true" if a matrix is null.
  function isempty (
    arg : integer_vector)
    return BOOLEAN is
  begin
    if arg'length < 1 then
      return true;
    else
      return false;
    end if;
  end function isempty;

  -- purpose: Transpose a matrix
  function transpose (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(2)-1,
                                      0 to arg'length(1)-1);
  begin  -- transpose
    for i in 0 to result'high(1) loop
      for j in 0 to result'high(2) loop
        result (i, j) := arg (j+arg'low(1), i+arg'low(2));
      end loop;  -- j
    end loop;  -- i
    return result;
  end function transpose;

  -- purpose: Transpose a matrix
  function transpose (
    arg : integer_vector)
    return integer_matrix is
    -- return a matrix with 1 column
    variable result : integer_matrix (0 to arg'length-1, 0 to 0);
  begin  -- transpose
    for i in result'range(1) loop
      result (i, 0) := arg (i+arg'low);
    end loop;  -- i
    return result;
  end function transpose;

  -- purpose: Transpose a matrix
  function transpose (
    arg : integer_matrix)
    return integer_vector is
    variable result : integer_vector (0 to arg'length(1)-1);
  begin  -- transpose
    if arg'length(2) /= 1 then
      report real_matrix_pkg'instance_name &
        "Transpose (Matrix) return Vector: " &
        "input vector must have one column, found " &
        INTEGER'image(arg'length(2)) severity error;
    else
      for i in result'range loop
        result (i) := arg (i+arg'low(1), arg'low(2));
      end loop;  -- i
    end if;
    return result;
  end function transpose;

  -- purpose: returns a matrix of zeros
  function zeros (
    rows, columns : NATURAL)
    return integer_matrix is
  begin  -- zeros
    return repmat (arg     => 0,
                   rows    => rows,
                   columns => columns);
  end function zeros;

  -- purpose: returns a matrix of zeros
  function zeros (
    rows, columns : NATURAL)
    return integer_vector is
  begin  -- zeros
    return repmat (arg     => 0,
                   rows    => rows,
                   columns => columns);
  end function zeros;

  -- purpose: returns a matrix of zeros
  function ones (
    rows, columns : NATURAL)
    return integer_matrix is
  begin  -- ones
    return repmat (arg     => 1,
                   rows    => rows,
                   columns => columns);
  end function ones;

  -- purpose: returns a matrix of zeros
  function ones (
    rows, columns : NATURAL)
    return integer_vector is
  begin  -- ones
    return repmat (arg     => 1,
                   rows    => rows,
                   columns => columns);
  end function ones;

  -- purpose: Returns an identity matrix
  function eye (
    rows, columns : NATURAL)
    return integer_matrix is
    variable result : integer_matrix (0 to rows-1, 0 to columns-1);
  begin  -- eye
    for i in 0 to result'high(1) loop
      for j in 0 to result'high(2) loop
        if i = j then
          result (i, j) := 1;
        else
          result (i, j) := 0;
        end if;
      end loop;  -- j
    end loop;  -- i
    return result;
  end function eye;

  -- Concatenates two matrices together
  function cat (
    constant dim : POSITIVE;            -- 1 = y, 2 = x
    l, r         : integer_matrix)
    return integer_matrix is
  begin
    if dim = 1 then
      return vertcat (l, r);
    elsif dim = 2 then
      return horzcat (l, r);
    else
      report real_matrix_pkg'instance_name & "cat " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return l;
    end if;
  end function cat;

  -- Concatenates two matrices together
  function horzcat (
    l, r : integer_matrix)
    return integer_matrix is
    variable rx : integer_matrix (0 to l'length(1)-1,
                                  0 to (l'length(2)-1) + (r'length(2)-1));
    variable m, n : INTEGER;            -- index variables
  begin
    if l'length (1) = r'length(1) then
      for i in rx'range(1) loop
        for j in 0 to l'length(2)-1 loop
          rx (i, j) := l (i+l'low(1), j+l'low(2));
        end loop;
      end loop;
      for i in rx'range(1) loop
        for j in 0 to r'length(2)-1 loop
          rx (i, j+l'length(2)) := r (i+r'low(1), j+r'low(2));
        end loop;
      end loop;
    else
      report real_matrix_pkg'instance_name & "horzcat " &
        "row dimension does not match " & INTEGER'image(l'length(1)) &
        " /= " & INTEGER'image(r'length(1)) severity error;
    end if;
    return rx;
  end function horzcat;

  -- Concatenates two matrices together
  function vertcat (
    l, r : integer_matrix)
    return integer_matrix is
    variable ry : integer_matrix (0 to (l'length(1)-1) + (r'length(1)-1),
                                  0 to l'length(2));
    variable m, n : INTEGER;            -- index variables
  begin
    if l'length (2) = r'length(2) then
      for i in 0 to l'length(1)-1 loop
        for j in ry'range(2) loop
          ry (i, j) := l (i+l'low(1), j+l'low(2));
        end loop;
      end loop;
      for i in 0 to r'length(1)-1 loop
        for j in ry'range(2) loop
          ry (i+l'length(1), j) := r (i+r'low(1), j+r'low(2));
        end loop;
      end loop;
    else
      report real_matrix_pkg'instance_name & "vertcat " &
        "column dimension does not match " & INTEGER'image(l'length(2)) &
        " /= " & INTEGER'image(r'length(2)) severity error;
    end if;
    return ry;
  end function vertcat;

  -- Flip the dimensions on a matrix
  function flipdim (
    arg          : integer_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return integer_matrix is
  begin
    if dim = 1 then
      return flipup (arg);
    elsif dim = 2 then
      return fliplr (arg);
    else
      report real_matrix_pkg'instance_name & "flipdim " &
        "dim input must be 1 or 2, was " & INTEGER'image(dim)
        severity error;
      return arg;
    end if;
  end function flipdim;

  -- flip left to right
  function fliplr (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(1)-1,
                                      0 to arg'length(2)-1);
    variable i, j : INTEGER;
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (arg'low(1)+i, arg'high(2)-j);
      end loop;
    end loop;
    return result;
  end function fliplr;

  -- Flip up and down
  function flipup (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(1)-1, 0 to arg'length(2)-1);
    variable i, j   : INTEGER;
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (arg'high(1)-i, arg'low(2)+j);
      end loop;
    end loop;
    return result;
  end function flipup;

  -- flip a vector
  function fliplr (
    arg : integer_vector)
    return integer_vector is
    variable result : integer_vector (0 to arg'length-1);
    variable i      : INTEGER;
  begin
    for i in result'range(1) loop
      result (i) := arg (arg'high-i);
    end loop;
    return result;
  end function fliplr;

  -- Matrix rotation
  function rot90 (
    arg          : integer_matrix;
    constant dim : INTEGER := 1)        -- 1 = y, 2 = x
    return integer_matrix is
    variable rx : integer_matrix (0 to arg'length(1)-1,
                                    0 to arg'length(2)-1);
    variable ry : integer_matrix (0 to arg'length(2)-1,
                                    0 to arg'length(1)-1);
    variable i, j : INTEGER;
  begin
    if dim = 1 or dim = -3 then
      for i in ry'range(1) loop
        for j in ry'range(2) loop
          ry (i, j) := arg (arg'low(1)+j, arg'high(2)-i);
        end loop;
      end loop;
      return ry;
    elsif dim = 2 or dim = -2 then
      for i in rx'range(1) loop
        for j in rx'range(2) loop
          rx (i, j) := arg (arg'high(1)-i, arg'high(2)-j);
        end loop;
      end loop;
      return rx;
    elsif dim = 3 or dim = -1 then
      for i in ry'range(1) loop
        for j in ry'range(2) loop
          ry (i, j) := arg (arg'high(1)-j, arg'low(2)+i);
        end loop;
      end loop;
      return ry;
    else
      return arg;
    end if;
  end function rot90;

  -- Change the shape of a matrix
  function reshape (
    arg                    : integer_matrix;
    constant rows, columns : POSITIVE)
    return integer_matrix is
    variable result     : integer_matrix (0 to rows-1, 0 to columns-1);  -- result
    variable i, j, k, l : INTEGER;
  begin
    if arg'length(1)*arg'length(2) < rows*columns then
      report real_matrix_pkg'instance_name & "reshape " &
        "not enough elements in arg (" & INTEGER'image(arg'length(1)) &
        "," & INTEGER'image(arg'length(2)) & ") < result (" &
        INTEGER'image(rows) & "," & INTEGER'image(columns) & ")"
        severity error;
    else
      k := arg'low(1);
      l := arg'low(2);
      for i in result'range(2) loop
        for j in result'range(1) loop
          result (j, i) := arg (k, l);
          if k = arg'high(1) then
            k := arg'low(1);
            l := l + 1;
          else
            k := k + 1;
          end if;
        end loop;
      end loop;
    end if;
    return result;
  end function reshape;

  -- Change the shape of a matrix
  function reshape (
    arg                    : integer_vector;
    constant rows, columns : POSITIVE)
    return integer_matrix is
    variable result  : integer_matrix (0 to rows-1, 0 to columns-1);  -- result
    variable i, j, k : INTEGER;
  begin
    if arg'length < rows*columns then
      report real_matrix_pkg'instance_name & "reshape " &
        "not enough elements in arg (" & INTEGER'image(arg'length) &
        ") < result (" & INTEGER'image(rows) & "," &
        INTEGER'image(columns) & ")"
        severity error;
    else
      k := arg'low;
      for i in result'range(2) loop
        for j in result'range(1) loop
          result (j, i) := arg (k);
          k             := k + 1;
        end loop;
      end loop;
    end if;
    return result;
  end function reshape;

  function reshape (
    arg           : integer_matrix;
    rows, columns : POSITIVE)
    return integer_vector is
    variable rx         : integer_vector (0 to rows-1);
    variable ry         : integer_vector (0 to columns-1);
    variable i, j, k, l : INTEGER;
  begin
    if rows = 1 then
      if arg'length(1) * arg'length(2) < ry'length then
        report real_matrix_pkg'instance_name & "reshape " &
          "not enough elements in arg (" & INTEGER'image(arg'length(1)) &
          "," & INTEGER'image(arg'length(2)) & ") < result (" &
          INTEGER'image (ry'length) & ")"
          severity error;
        return ry;
      else
        k := arg'low(2);
        l := arg'low(1);
        for j in ry'range loop
          ry (j) := arg (l, k);
          if k = arg'high(2) then
            k := arg'low(2);
            l := l + 1;
          else
            k := k + 1;
          end if;
        end loop;
        return ry;
      end if;
    elsif columns = 1 then
      if arg'length(1) * arg'length(2) < rx'length then
        report real_matrix_pkg'instance_name & "reshape " &
          "not enough elements in arg (" & INTEGER'image(arg'length(1)) &
          "," & INTEGER'image(arg'length(2)) & ") < result (" &
          INTEGER'image (rx'length) & ")"
          severity error;
        return rx;
      else
        k := arg'low(1);
        l := arg'low(2);
        for j in rx'range loop
          rx (j) := arg (k, l);
          if k = arg'high(1) then
            k := arg'low(1);
            l := l + 1;
          else
            k := k + 1;
          end if;
        end loop;
        return rx;
      end if;
    else
      report real_matrix_pkg'instance_name & "reshape " &
        "rows or columns need to be 1 got " & INTEGER'image(rows) & "," &
        INTEGER'image(columns) severity error;
      return rx;
    end if;
  end function reshape;

  -- returns the size of a matrix
  function size (
    arg : integer_matrix)
    return integer_vector is
    variable result : integer_vector (0 to 1);
  begin
    result (0) := arg'length(1);
    result (1) := arg'length(2);
    return result;
  end function size;

  -- True if matrix is one dimensional
  function isvector (
    arg : integer_matrix)
    return BOOLEAN is
  begin
    if arg'length(1) = 1 or arg'length(2) = 1 then
      return true;
    else
      return false;
    end if;
  end function isvector;

  -- True if a 1/1 matrix
  function isscalar (
    arg : integer_matrix)
    return BOOLEAN is
  begin
    if arg'length(1) = 1 and arg'length(2) = 1 then
      return true;
    else
      return false;
    end if;
  end function isscalar;

  -- returns the number of elements in a matrix
  function numel (
    arg : integer_matrix)
    return INTEGER is
  begin
    if isempty (arg) then
      return 0;
    else
      return arg'length(1) * arg'length(2);
    end if;
  end function numel;

  -- Return the diagonal of a matrix
  function diag (
    arg : integer_matrix)
    return integer_vector is
    variable result : integer_vector (0 to minimum (arg'length(2),
                                                    arg'length(1))-1);
  begin
    for i in result'range loop
      result (i) := arg (i+arg'low(1), i+arg'low(2));
    end loop;
    return result;
  end function diag;

  -- Return a matrix with the vector as the diagonal
  function diag (
    arg : integer_vector)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length-1, 0 to arg'length-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i = j then
          result (i, j) := arg (i+arg'low);
        else
          result (i, j) := 0;
        end if;
      end loop;
    end loop;
    return result;
  end function diag;

  -- Return the matrix of a diagonal
  function blkdiag (
    arg : integer_vector)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length-1, 0 to arg'length-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i = j then
          result (i, j) := arg (i+arg'low);
        else
          result (i, j) := 0;
        end if;
      end loop;
    end loop;
    return result;
  end function blkdiag;

  -- Creates a block diagonal matrix from "arg", repeated "rep" times
  -- This differed from the function of "blkdiag" in Matlab
  function blockdiag (
    arg : integer_matrix;
    rep : POSITIVE)
    return integer_matrix is
    variable result : integer_matrix (0 to (arg'length(1)*rep)-1,
                                      0 to (arg'length(2)*rep)-1);
  begin
    -- Zero out the result matrix
    result := repmat (0, arg'length(1)*rep, arg'length(2)*rep);
    -- Fill in across the diagonal
    for k in 0 to rep-1 loop
      for m in 0 to arg'length(1)-1 loop
        for n in 0 to arg'length(2)-1 loop
          result ((k*arg'length(1))+m, (k*arg'length(2))+n) :=
            arg (m+arg'low(1), n+arg'low(2));
        end loop;
      end loop;
    end loop;
    return result;
  end function blockdiag;

  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : INTEGER;
    constant rows, columns : NATURAL)
    return integer_matrix is
    variable result : integer_matrix (0 to rows-1, 0 to columns-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg;
      end loop;  -- j
    end loop;  -- i
    return result;
  end function repmat;

  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : INTEGER;
    constant rows, columns : NATURAL)
    return integer_vector is
    variable result : integer_vector (0 to columns-1);
  begin  -- ones
    if rows /= 1 then
      report real_matrix_pkg'instance_name & "repmat" &
        " return vector, number of rows not 1, was " &
        INTEGER'image(rows) severity error;
    else
      for i in result'range loop
        result (i) := arg;
      end loop;  -- i
    end if;
    return result;
  end function repmat;

  -- Replicate a matrix row/column times
  function repmat (
    arg                    : integer_matrix;
    constant rows, columns : NATURAL)
    return integer_matrix is
    variable result : integer_matrix (0 to (arg'length(1)*rows)-1,
                                      0 to (arg'length(2)*columns)-1);
    variable i, j, m, n : INTEGER;      -- index variables
  begin
    m := 0;
    n := 0;
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (m+arg'low(1), n+arg'low(2));
        if n = arg'length(2)-1 then
          n := 0;
        else
          n := n + 1;
        end if;
      end loop;
      if m = arg'length(1)-1 then
        m := 0;
      else
        m := m + 1;
      end if;
    end loop;
    return result;
  end function repmat;

  -- Return the lower triangle of a matrix
  function tril (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(1)-1,
                                      0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i > j then
          result (i, j) := arg (i+ arg'low(1), j+arg'low(2));
        else
          result (i, j) := 0;
        end if;
      end loop;
    end loop;
    return result;
  end function tril;

  -- Return the upper triangle of a matrix
  function triu (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(1)-1,
                                      0 to arg'length(2)-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        if i < j then
          result (i, j) := arg (i+ arg'low(1), j+arg'low(2));
        else
          result (i, j) := 0;
        end if;
      end loop;
    end loop;
    return result;
  end function triu;

  -----------------------------------------------------------------------------
  -- These functions allow you to do matrix and vector slicing
  -----------------------------------------------------------------------------
  -- returns an rows/columns matrix from position l,r in the input matrix
  function SubMatrix (
    arg                    : real_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return real_matrix is
    variable result : real_matrix (0 to rows-1, 0 to columns-1);
  begin
    if arg'length(1)-x < rows or arg'length(2)-y < columns then
      report real_matrix_pkg'instance_name & "SubMatrix " &
        "Matrix size does not match, can not extract a (" &
        INTEGER'image(rows) & "," & INTEGER'image(columns) &
        ") matrix from a (" & INTEGER'image (arg'length(1)-x) & "," &
        INTEGER'image (arg'length(2)-y) & ") matrix"
        severity error;
    else
      for i in result'range(1) loop
        for j in result'range(2) loop
          result (i, j) := arg (x + i, y + j);
        end loop;
      end loop;
    end if;
    return result;
  end function SubMatrix;

  -- returns a row from a matrix starting at position l,r in the input matrix
  function SubMatrix (
    arg                    : real_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return real_vector is
    variable result2 : real_vector (0 to columns-1);
  begin
    if rows /= 1 then
      report real_matrix_pkg'instance_name & "SubMatrix " &
        "Vector version can only have 1 row.  Number of rows entered was "
        & INTEGER'image(rows) severity error;
    elsif arg'length(2)-y < columns then
      report real_matrix_pkg'instance_name & "SubMatrix " &
        "Vector length does not match " & INTEGER'image (arg'length(2)-y) &
        " /= " & INTEGER'image(columns)
        severity error;
    else
      for i in result2'range loop
        result2 (i) := arg (x, y+i);
      end loop;
    end if;
    return result2;
  end function SubMatrix;

  -- returns a rows/columns matrix from position l,r in the input matrix
  procedure BuildMatrix (
    arg           : in    real_matrix;
    result        : inout real_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    if isempty (arg) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "arg input was an empty matrix"
--        severity error;
      return;
    elsif isempty(result) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "result input was an empty matrix"
--        severity error;
      return;
    elsif (arg'length(1) > result'length(1)-(x-result'low(1))) or
      (arg'length(2) > result'length(2)-(y-result'low(2))) then
      report real_matrix_pkg'instance_name & "BuildMatrix " &
        "Dimensions of arg (" & INTEGER'image(arg'length(1)) & "," &
        INTEGER'image(arg'length(2)) & ") > result range (" &
        INTEGER'image(result'high(1)-(x-result'low(1))) & "," &
        INTEGER'image(result'high(2)-(y-result'low(2))) & ")"
        severity error;
      return;
    else
      for i in 0 to arg'length(1)-1 loop
        for j in 0 to arg'length(2)-1 loop
          result (x+i, y+j) := arg (i+arg'low(1), j+arg'low(2));
        end loop;
      end loop;
    end if;
  end procedure BuildMatrix;

  -- Places the vector "arg" into matrix "result" along "x" axis starting
  -- at x,y
  procedure BuildMatrix (
    arg           : in    real_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    if isempty (arg) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "arg input was an empty vector"
--        severity error;
      return;
    elsif isempty(result) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "result input was an empty matrix"
--        severity error;
      return;
    elsif arg'length > result'length(2)-(y-result'low(2)) then
      report real_matrix_pkg'instance_name & "BuildMatrix " &
        "Dimension of arg(" & INTEGER'image(arg'length) &
        ") larger than result (" & INTEGER'image(x) & "," &
        INTEGER'image(result'length(2)-(y-result'low(2))) & ")"
        severity error;
      return;
    else
      for i in 0 to arg'length-1 loop
        result (x, y+i) := arg (i+arg'low);
      end loop;
    end if;
  end procedure BuildMatrix;

  -- Places the vector "arg" into matrix "result" along "y" axis starting
  -- at x,y
  procedure InsertColumn (
    arg           : in    real_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    if isempty (arg) then
--      report real_matrix_pkg'instance_name & "InsertColumn " &
--        "arg input was an empty vector"
--        severity error;
      return;
    elsif isempty(result) then
--      report real_matrix_pkg'instance_name & "InsertColumn " &
--        "result input was an empty matrix"
--        severity error;
      return;
    elsif arg'length > result'length(1)-(x-result'low(1)) then
      report real_matrix_pkg'instance_name & "InsertColumn " &
        "Dimension of arg(" & INTEGER'image(arg'length) &
        ") larger than result (" &
        INTEGER'image(result'length(1)-(x-result'low(1))) & "," &
        INTEGER'image(y) & ")"
        severity error;
      return;
    else
      for i in 0 to arg'length-1 loop
        result (x+i, y) := arg (i+arg'low);
      end loop;
    end if;
  end procedure InsertColumn;

  -- purpose: SubMatrix returns a matrix with 1 less row and column
  -- Used by determinant function
  function exclude (
    arg                  : real_matrix;
    constant row, column : NATURAL)     -- row and column to exclude
    return real_matrix is
    variable i, j, k, l : INTEGER;      -- loop variables
    variable result : real_matrix (0 to arg'length(1)-2,
                                   0 to arg'length(2)-2);  -- SubMatrix
  begin  -- SubMatrix
    if arg'length(1) < 3 then
      report real_matrix_pkg'instance_name & "exclude " &
        "arg is smaller than 3x3" severity error;
    else
      k := 0;
      l := 0;
      for i in arg'low(1) to arg'high(1) loop
        for j in arg'low(2) to arg'high(2) loop
          if not (i = row or j = column) then  -- exclude this row/column
            result (k, l) := arg (i, j);
            if l = result'high(2) then
              k := k + 1;
              l := 0;
            else
              l := l + 1;
            end if;
          end if;
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function exclude;

  ---------------------------------------------------------------------------
  -- Integer version
  ---------------------------------------------------------------------------
  -- returns an rows/columns matrix from position l,r in the input matrix
  function SubMatrix (
    arg                    : integer_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return integer_matrix is
    variable result : integer_matrix (0 to rows-1, 0 to columns-1);
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := arg (x + i, y + j);
      end loop;
    end loop;
    return result;
  end function SubMatrix;

  -- returns an rows/columns matrix from position l,r in the input matrix
  function SubMatrix (
    arg                    : integer_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return integer_vector is
    variable result1 : integer_vector (0 to rows-1);
    variable result2 : integer_vector (0 to columns-1);
  begin
    if rows > 1 then
      if arg'length(1)-x < rows then
        report real_matrix_pkg'instance_name & "SubMatrix " &
          "Vector length does not match " & INTEGER'image (arg'length(1)-x) &
          " /= " & INTEGER'image(rows)
          severity error;
      else
        for i in result1'range loop
          result1 (i) := arg (x+i, y);
        end loop;
      end if;
      return result1;
    else
      if arg'length(2)-y < columns then
        report real_matrix_pkg'instance_name & "SubMatrix " &
          "Vector length does not match " & INTEGER'image (arg'length(2)-y) &
          " /= " & INTEGER'image(columns)
          severity error;
      else
        for i in result2'range loop
          result2 (i) := arg (x, y+i);
        end loop;
      end if;
      return result2;
    end if;
  end function SubMatrix;

  -- returns an rows/columns matrix from position l,r in the input matrix
  procedure BuildMatrix (
    arg           : in    integer_matrix;
    result        : inout integer_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    if isempty (arg) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "arg input was an empty matrix"
--        severity error;
      return;
    elsif isempty(result) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "result input was an empty matrix"
--        severity error;
      return;
    elsif (arg'length(1) > result'length(1)-(x-result'low(1))) or
      (arg'length(2) > result'length(2)-(y-result'low(2))) then
      report real_matrix_pkg'instance_name & "BuildMatrix " &
        "Dimensions of arg (" & INTEGER'image(arg'length(1)) & "," &
        INTEGER'image(arg'length(2)) & ") > result range (" &
        INTEGER'image(result'high(1)-(x-result'low(1))) & "," &
        INTEGER'image(result'high(2)-(y-result'low(2))) & ")"
        severity error;
      return;
    else
      for i in 0 to arg'length(1)-1 loop
        for j in 0 to arg'length(2)-1 loop
          result (x+i, y+j) := arg (i+arg'low(1), j+arg'low(2));
        end loop;
      end loop;
    end if;
  end procedure BuildMatrix;

  -- Places the vector "arg" into matrix "result" along "x" axis starting
  -- at x,y
  procedure BuildMatrix (
    arg           : in    integer_vector;
    result        : inout integer_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    if isempty (arg) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "arg input was an empty vector"
--        severity error;
      return;
    elsif isempty(result) then
--      report real_matrix_pkg'instance_name & "BuildMatrix " &
--        "result input was an empty matrix"
--        severity error;
      return;
    elsif arg'length > result'length(2)-(y-result'low(2)) then
      report real_matrix_pkg'instance_name & "BuildMatrix " &
        "Dimension of arg(" & INTEGER'image(arg'length) &
        ") larger than result (" & INTEGER'image(x) & "," &
        INTEGER'image(result'length(2)-(y-result'low(2))) & ")"
        severity error;
      return;
    else
      for i in 0 to arg'length-1 loop
        result (x, y+i) := arg (i+arg'low);
      end loop;
    end if;
  end procedure BuildMatrix;

  -- Places the vector "arg" into matrix "result" along "y" axis starting
  -- at x,y
  procedure InsertColumn (
    arg           : in    integer_vector;
    result        : inout integer_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    if isempty (arg) then
--      report real_matrix_pkg'instance_name & "InsertColumn " &
--        "arg input was an empty vector"
--        severity error;
      return;
    elsif isempty(result) then
--      report real_matrix_pkg'instance_name & "InsertColumn " &
--        "result input was an empty matrix"
--        severity error;
      return;
    elsif arg'length > result'length(1)-(x-result'low(1)) then
      report real_matrix_pkg'instance_name & "InsertColumn " &
        "Dimension of arg(" & INTEGER'image(arg'length) &
        ") larger than result (" &
        INTEGER'image(result'length(1)-(x-result'low(1))) & "," &
        INTEGER'image(y) & ")"
        severity error;
      return;
    else
      for i in 0 to arg'length-1 loop
        result (x+i, y) := arg (i+arg'low);
      end loop;
    end if;
  end procedure InsertColumn;

  -- purpose: SubMatrix returns a matrix with 1 less row and column
  -- Used by determinant function
  function exclude (
    arg                  : integer_matrix;
    constant row, column : NATURAL)     -- row and column to exclude
    return integer_matrix is
    variable i, j, k, l : INTEGER;      -- loop variables
    variable result : integer_matrix (0 to arg'length(1)-2,
                                      0 to arg'length(2)-2);  -- SubMatrix
  begin  -- exclude
    if arg'length(1) < 3 then
      report real_matrix_pkg'instance_name & "exclude " &
        "arg is smaller than 3x3" severity error;
    else
      k := 0;
      l := 0;
      for i in arg'low(1) to arg'high(1) loop
        for j in arg'low(2) to arg'high(2) loop
          if not (i = row or j = column) then  -- exclude this row/column
            result (k, l) := arg (i, j);
            if l = result'high(2) then
              k := k + 1;
              l := 0;
            else
              l := l + 1;
            end if;
          end if;
        end loop;  -- j
      end loop;  -- i
    end if;
    return result;
  end function exclude;

  -----------------------------------------------------------------------------
  -- Type conversion functions
  -----------------------------------------------------------------------------

  function to_integer (
    arg : real_matrix)
    return integer_matrix is
    variable result : integer_matrix (arg'range(1), arg'range(2));
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := INTEGER (arg (i, j));
      end loop;
    end loop;
    return result;
  end function to_integer;

  function to_integer (
    arg : real_vector)
    return integer_vector is
    variable result : integer_vector (arg'range);
  begin
    for i in result'range loop
      result (i) := INTEGER (arg (i));
    end loop;
    return result;
  end function to_integer;

  function to_real (
    arg : integer_matrix)
    return real_matrix is
    variable result : real_matrix (arg'range(1), arg'range(2));
  begin
    for i in result'range(1) loop
      for j in result'range(2) loop
        result (i, j) := REAL (arg (i, j));
      end loop;
    end loop;
    return result;
  end function to_real;

  function to_real (
    arg : integer_vector)
    return real_vector is
    variable result : real_vector (arg'range);
  begin
    for i in result'range loop
      result (i) := REAL (arg (i));
    end loop;
    return result;
  end function to_real;

  -----------------------------------------------------------------------------
  -- Overloads, Mixed types functions
  -----------------------------------------------------------------------------
  function "*" (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return l * to_real(r);
  end function "*";

  function "*" (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return to_real(l) * r;
  end function "*";

  function "*" (
    l : real_matrix;
    r : integer_vector)
    return real_matrix is
  begin
    return l * to_real(r);
  end function "*";

  function "*" (
    l : integer_matrix;
    r : real_vector)
    return real_matrix is
  begin
    return to_real(l) * r;
  end function "*";

  function "*" (
    l : real_vector;
    r : integer_matrix)
    return real_vector is
  begin
    return l * to_real(r);
  end function "*";

  function "*" (
    l : integer_vector;
    r : real_matrix)
    return real_vector is
  begin
    return to_real(l) * r;
  end function "*";

  function "*" (
    l : real_matrix;
    r : INTEGER)
    return real_matrix is
  begin
    return l * REAL (r);
  end function "*";

  function "*" (
    l : INTEGER;
    r : real_matrix)
    return real_matrix is
  begin
    return REAL(l) * r;
  end function "*";

  function "*" (
    l : real_vector;
    r : INTEGER)
    return real_vector is
  begin
    return l * REAL (r);
  end function "*";

  function "*" (
    l : INTEGER;
    r : real_vector)
    return real_vector is
  begin
    return REAL(l) * r;
  end function "*";

  function "+" (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return l + to_real(r);
  end function "+";

  function "+" (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return to_real(l) + r;
  end function "+";

  function "+" (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return l + to_real(r);
  end function "+";

  function "+" (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return to_real (l) + r;
  end function "+";

  function "-" (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return l - to_real(r);
  end function "-";

  function "-" (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return to_real(l) - r;
  end function "-";

  function "-" (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return l - to_real(r);
  end function "-";

  function "-" (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return to_real(l) - r;
  end function "-";

  function times (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return times(l, to_real(r));
  end function times;

  function times (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return times(to_real(l), r);
  end function times;

  function times (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return times(l, to_real(r));
  end function times;

  function times (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return times(to_real(l), r);
  end function times;

  function rdivide (
    l, r : integer_matrix)
    return real_matrix is
  begin
    return rdivide(to_real(l), to_real(r));
  end function rdivide;

  function rdivide (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return rdivide(l, to_real(r));
  end function rdivide;

  function rdivide (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return rdivide(to_real(l), r);
  end function rdivide;

  function rdivide (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return rdivide(l, to_real(r));
  end function rdivide;

  function rdivide (
    l, r : integer_vector)
    return real_vector is
  begin
    return rdivide(to_real(l), to_real(r));
  end function rdivide;

  function rdivide (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return rdivide(to_real(l), r);
  end function rdivide;

  function "/" (
    l, r : integer_matrix)
    return real_matrix is
  begin
    return mrdivide (to_real(l), to_real(r));
  end function "/";

  function "/" (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return mrdivide (l, to_real(r));
  end function "/";

  function "/" (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return mrdivide (to_real(l), r);
  end function "/";

  function "/" (
    l : real_matrix;
    r : INTEGER)
    return real_matrix is
  begin
    return l / REAL(r);
  end function "/";

  function "/" (
    l : real_vector;
    r : INTEGER)
    return real_vector is
  begin
    return l / REAL(r);
  end function "/";

  function mrdivide (
    l, r : integer_matrix)
    return real_matrix is
  begin
    return mrdivide(to_real(l), to_real(r));
  end function mrdivide;

  function mrdivide (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return mrdivide(l, to_real(r));
  end function mrdivide;

  function mrdivide (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return mrdivide(to_real(l), r);
  end function mrdivide;

  function mldivide (
    l, r : integer_matrix)
    return real_matrix is
  begin
    return mldivide(to_real(l), to_real(r));
  end function mldivide;

  function mldivide (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return mldivide(l, to_real(r));
  end function mldivide;

  function mldivide (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return mldivide(to_real(l), r);
  end function mldivide;

  function pow (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return pow (l, to_real(r));
  end function pow;

  function pow (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return pow (to_real(l), r);
  end function pow;

  function pow (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return pow (l, to_real(r));
  end function pow;

  function pow (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return pow (to_real(l), r);
  end function pow;

  function cross (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return cross (l, to_real(r));
  end function cross;

  function cross (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return cross (to_real(l), r);
  end function cross;

  function cross (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return cross (l, to_real(r));
  end function cross;

  function cross (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return cross (to_real(l), r);
  end function cross;

  function kron (
    l : real_matrix;
    r : integer_matrix)
    return real_matrix is
  begin
    return kron (l, to_real(r));
  end function kron;

  function kron (
    l : integer_matrix;
    r : real_matrix)
    return real_matrix is
  begin
    return kron (to_real(l), r);
  end function kron;

  function linsolve (
    l : integer_matrix;
    r : integer_vector)
    return real_vector is
  begin
    return linsolve (to_real(l), to_real(r));
  end function linsolve;

  function linsolve (
    l : real_matrix;
    r : integer_vector)
    return real_vector is
  begin
    return linsolve (l, to_real(r));
  end function linsolve;

  function linsolve (
    l : integer_matrix;
    r : real_vector)
    return real_vector is
  begin
    return linsolve (to_real(l), r);
  end function linsolve;

  function inv (
    arg : integer_matrix)
    return real_matrix is
  begin
    return inv (to_real(arg));
  end function inv;

  function polyval (
    l : real_vector;
    r : integer_vector)
    return real_vector is
  begin
    return polyval (l, to_real(r));
  end function polyval;

  function polyval (
    l : integer_vector;
    r : real_vector)
    return real_vector is
  begin
    return polyval (to_real(l), r);
  end function polyval;

  function normalize (
    arg           : integer_matrix;
    constant rval : INTEGER := 1)
    return real_matrix is
  begin
    return normalize (to_real(arg), REAL(rval));
  end function normalize;

  function normalize (
    arg           : integer_vector;
    constant rval : INTEGER := 1)
    return real_vector is
  begin
    return normalize (to_real(arg), REAL(rval));
  end function normalize;

  -- Places the matrix "arg" at location X,Y in matrix "result"
  procedure BuildMatrix (
    arg           : in    integer_matrix;
    result        : inout real_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    BuildMatrix (
      arg    => to_real(arg),
      result => result,
      x      => x,
      y      => y);
  end procedure BuildMatrix;

  -- Places the vector "arg" into matrix "result" along "x" axis starting
  -- at x,y
  procedure BuildMatrix (
    arg           : in    integer_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    BuildMatrix (
      arg    => to_real(arg),
      result => result,
      x      => x,
      y      => y);
  end procedure BuildMatrix;

  -- Same interface as "BuildMatrix", but it inserts a column, not a row.
  procedure InsertColumn (
    arg           : in    integer_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL) is   -- index into the matrix
  begin
    InsertColumn (
      arg    => to_real(arg),
      result => result,
      x      => x,
      y      => y);
  end procedure InsertColumn;

  -----------------------------------------------------------------------------
  -- Textio section
  -----------------------------------------------------------------------------
-- rtl_synthesis off
--%VHDL2008%   alias SWRITE is WRITE [LINE, STRING, SIDE, WIDTH];

  -- to_string (integer_vector) SHOULD be defined in VHDL 2008
  function to_string (
    value : integer_vector)
    return STRING is
    variable L : LINE;
  begin
    for i in value'range loop
      write (L     => L,
             value => value (i));
      swrite (L, " ");
    end loop;  -- i
    return L.all;
  end function to_string;

  function to_string (
    value : real_vector)
    return STRING is
    variable L : LINE;
  begin
    for i in value'range loop
      write (L      => L,
             value  => value (i),
             digits => 4);
      swrite (L, " ");
    end loop;  -- i
    return L.all;
  end function to_string;

  function to_string (
    value : real_matrix)
    return STRING is
    variable L : LINE;                  -- output line
  begin
    for i in value'range(1) loop
      for j in value'range(2) loop
        write (L      => L,
               value  => value (i, j),
               digits => 4);
        swrite (L, " ");
      end loop;  -- j
      if i /= value'high(1) then
        write (L, LF);
      end if;
    end loop;  -- i
    return L.all;
  end function to_string;

  function to_string (
    value : integer_matrix)
    return STRING is
    variable L : LINE;                  -- output line
  begin
    for i in value'range(1) loop
      for j in value'range(2) loop
        write (L     => L,
               value => value (i, j));
        swrite (L, " ");
      end loop;  -- j
      if i /= value'high(1) then
        write (L, LF);
      end if;
    end loop;  -- i
    return L.all;
  end function to_string;

  -- purpose: writes real_vector into a line
  procedure write (
    L      : inout LINE;                -- input line
    VALUE  : in    real_vector;
    DIGITS : in    POSITIVE := 4) is
  begin
    swrite (L, "( ");
    for i in VALUE'range loop
      write (L      => L,
             value  => VALUE (i),
             digits => DIGITS);
      if i /= VALUE'high then
        swrite (L, ", ");
      end if;
    end loop;
    swrite (L, " )");
  end procedure write;

  -- purpose: writes real_matrix into a line
  procedure write (
    L      : inout LINE;                -- input line
    VALUE  : in    real_matrix;
    DIGITS : in    POSITIVE := 4) is
  begin
    swrite (L, "( ");
    for i in VALUE'range(1) loop
      swrite (L, "( ");
      for j in VALUE'range(2) loop
        write (L      => L,
               value  => VALUE(i, j),
               digits => DIGITS);
        if j /= VALUE'high(2) then
          swrite (L, ", ");
        end if;
      end loop;
      if i /= VALUE'high(1) then
        swrite (L, " ),");
      else
        swrite (L, " )");
      end if;
    end loop;
    swrite (L, " )");
  end procedure write;

  -- purpose: writes integer_vector into a line
  procedure write (
    L         : inout LINE;             -- input line
    VALUE     : in    integer_vector;   -- fixed point input
    JUSTIFIED : in    SIDE  := right;
    FIELD     : in    WIDTH := 0) is
  begin
    swrite (L, "(");
    for i in VALUE'range loop
      write (L, VALUE(i), JUSTIFIED, FIELD);
      if i /= VALUE'high then
        swrite (L, ", ");
      end if;
    end loop;
    swrite (L, ")");
  end procedure write;

  -- purpose: writes integer_matrix into a line
  procedure write (
    L         : inout LINE;             -- input line
    VALUE     : in    integer_matrix;   -- fixed point input
    JUSTIFIED : in    SIDE  := right;
    FIELD     : in    WIDTH := 0) is
  begin
    swrite (L, "(");
    for i in VALUE'range(1) loop
      swrite (L, "(");
      for j in VALUE'range(2) loop
        write (L, VALUE(i, j), JUSTIFIED, FIELD);
        swrite (L, " ");
      end loop;
    end loop;
    swrite (L, ")");
  end procedure write;

  constant NBSP : CHARACTER := CHARACTER'val(160);  -- space character
  -- purpose: Skips white space or punctuation
  procedure skip_whitespace_or_pc (
    L : inout LINE) is
    variable readOk : BOOLEAN;
    variable c      : CHARACTER;
  begin
    while L /= null and L.all'length /= 0 loop
      if (L.all(1) = ' ' or L.all(1) = NBSP or L.all(1) = HT or L.all(1) = CR
          or L.all(1) = '(' or L.all(1) = ')' or L.all(1) = ',') then
        read (l, c, readOk);
      else
        exit;
      end if;
    end loop;
  end procedure skip_whitespace_or_pc;

  procedure READ(L     : inout LINE;
                 VALUE : out   real_vector) is
  begin
    for i in VALUE'range loop
      skip_whitespace_or_pc(l);
      READ (L, VALUE(i));
    end loop;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   real_matrix) is
  begin
    for i in VALUE'range(1) loop
      for j in VALUE'range(2) loop
        skip_whitespace_or_pc(l);
        READ (L, VALUE(i, j));
      end loop;
    end loop;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   integer_vector) is
  begin
    for i in VALUE'range loop
      skip_whitespace_or_pc(l);
      READ (L, VALUE(i));
    end loop;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   integer_matrix) is
  begin
    for i in VALUE'range(1) loop
      for j in VALUE'range(2) loop
        skip_whitespace_or_pc(l);
        READ (L, VALUE(i, j));
      end loop;
    end loop;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   real_vector;
                 GOOD  : out   BOOLEAN) is
    variable isgood, wasgood : BOOLEAN;
  begin
    wasgood := true;
    for i in VALUE'range loop
      skip_whitespace_or_pc(l);
      READ (L, VALUE(i), isgood);
      wasgood := isgood and wasgood;
    end loop;
    GOOD := wasgood;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   real_matrix;
                 GOOD  : out   BOOLEAN) is
    variable isgood, wasgood : BOOLEAN;
  begin
    wasgood := true;
    for i in VALUE'range(1) loop
      for j in VALUE'range(2) loop
        skip_whitespace_or_pc(l);
        READ (L, VALUE(i, j), isgood);
        wasgood := isgood and wasgood;
      end loop;
    end loop;
    GOOD := wasgood;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   integer_vector;
                 GOOD  : out   BOOLEAN) is
    variable isgood, wasgood : BOOLEAN;
  begin
    wasgood := true;
    for i in VALUE'range loop
      skip_whitespace_or_pc(l);
      READ (L, VALUE(i), isgood);
      wasgood := isgood and wasgood;
    end loop;
    GOOD := wasgood;
  end procedure READ;

  procedure READ(L     : inout LINE;
                 VALUE : out   integer_matrix;
                 GOOD  : out   BOOLEAN) is
    variable isgood, wasgood : BOOLEAN;
  begin
    wasgood := true;
    for i in VALUE'range(1) loop
      for j in VALUE'range(2) loop
        skip_whitespace_or_pc(l);
        READ (L, VALUE(i, j), isgood);
        wasgood := isgood and wasgood;
      end loop;
    end loop;
    GOOD := wasgood;
  end procedure READ;

  -- purpose: Prints out a matrix
  procedure print_matrix (
    arg   : in real_matrix;
    index : in BOOLEAN := false) is
    variable L : LINE;                  -- output line
  begin  -- print_matrix
    if not index then
      write (L, STRING'("(" & INTEGER'image(arg'length(1))
                        & "," & INTEGER'image(arg'length(2)) & ")"));
      writeline (output, L);
      write (L, to_string (arg));
      writeline (output, L);
    else
      for i in arg'range(1) loop
        for j in arg'range(2) loop
          if index then
            write (L, STRING'("(" & INTEGER'image(i)
                              & "," & INTEGER'image(j) & ") = "));
          end if;
          write (L      => L,
                 VALUE  => arg (i, j),
                 digits => 4);
          swrite (L, " ");
        end loop;  -- j
        writeline (output, L);
      end loop;  -- i
    end if;
  end procedure print_matrix;

  -- purpose: Prints out a vector
  procedure print_vector (
    arg   : in real_vector;
    index : in BOOLEAN := false) is
    variable L : LINE;                  -- output line
  begin  -- print_vector
    for i in arg'range loop
      if index then
        write (L, STRING'("(" & INTEGER'image(i) & ") = "));
      end if;
      write (L      => L,
             VALUE  => arg (i),
             digits => 4);
      swrite (L, " ");
    end loop;  -- i
    writeline (output, L);
  end procedure print_vector;

  -- purpose: Prints out a matrix
  procedure print_matrix (
    arg   : in integer_matrix;
    index : in BOOLEAN := false) is
    variable L : LINE;                  -- output line
  begin  -- print_matrix
    if not index then
      write (L, STRING'("(" & INTEGER'image(arg'length(1))
                        & "," & INTEGER'image(arg'length(2)) & ")"));
      writeline (output, L);
      write (L, to_string (arg));
      writeline (output, L);
    else
      for i in arg'range(1) loop
        for j in arg'range(2) loop
          if index then
            write (L, STRING'("(" & INTEGER'image(i)
                              & "," & INTEGER'image(j) & ") = "));
          end if;
          write (L     => L,
                 VALUE => arg (i, j));
          swrite (L, " ");
        end loop;  -- j
        writeline (output, L);
      end loop;  -- i
    end if;
  end procedure print_matrix;

  -- purpose: Prints out a vector
  procedure print_vector (
    arg   : in integer_vector;
    index : in BOOLEAN := false) is
    variable L : LINE;                  -- output line
  begin  -- print_vector
    for i in arg'range loop
      if index then
        write (L, STRING'("(" & INTEGER'image(i) & ") = "));
      end if;
      write (L     => L,
             VALUE => arg (i));
      swrite (L, " ");
    end loop;  -- i
    writeline (output, L);
  end procedure print_vector;

  -- protected type for the random number generator seeds
  -- This code is down here because the Emacs VHDL mode indenter has a
  -- problem with it.
  type random_seeds is protected body
    variable Local_seed1 : INTEGER := 12345;
  variable Local_seed2        : INTEGER := 67890;
  procedure Set (SEED1, SEED2 : INTEGER) is
  begin
    Local_seed1 := SEED1;
    Local_seed2 := SEED2;
  end procedure Set;
  procedure Get (SEED1, SEED2 : out INTEGER) is
  begin
    SEED1 := Local_seed1;
    SEED2 := Local_seed2;
  end procedure Get;
end protected body random_seeds;

shared variable seeds : random_seeds;   -- random seeds

-- returns a random matrix
impure function rand (
  rows, columns : POSITIVE)
  return real_matrix is
  -- Seed for random number
  variable checkreal    : REAL;
  variable seed1, seed2 : INTEGER;      -- seeds
  variable result       : real_matrix (0 to rows-1, 0 to columns-1);
begin
  for i in result'range(1) loop
    for j in result'range(2) loop
      seeds.Get (seed1, seed2);
      uniform (seed1, seed2, checkreal);
      seeds.set(seed1, seed2);
      result (i, j) := checkreal;
    end loop;  -- j
  end loop;  -- i
  return result;
end function rand;
-- rtl_synthesis on

end package body real_matrix_pkg;
