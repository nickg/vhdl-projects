-------------------------------------------------------------------------------
-- Title      : Matrix Math package for type REAL
-- Project    : IEEE 1076.1-201x
-------------------------------------------------------------------------------
-- File       : real_matrix_pkg.vhdl
-- Author     : David Bishop  <dbishop@vhdl.org>
-- Company    :
-- Created    : 2010-04-15
-- Last update: 2023-10-30
-- Platform   :
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Matrix math package for type REAL and integer
-------------------------------------------------------------------------------
-- Copyright (c) 2011
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-04-15  1.0      dbishop Created
-- 2011-01-10  3.0      dbishop
-------------------------------------------------------------------------------

--
use std.textio.all;

package real_matrix_pkg is

  -- Define arrays of vectors
  -- %%% "real_vector" and "integer_vector" are defined in VHDL-2008
--%VHDL2008%  type real_vector is array (NATURAL range <>) of REAL;        -- array
--%VHDL2008%  type integer_vector is array (NATURAL range <>) of INTEGER;  -- array

  -- Define the main type
  type real_matrix is array (NATURAL range <>, NATURAL range <>) of REAL;  -- real matrix
  type integer_matrix is array (NATURAL range <>, NATURAL range <>) of INTEGER;

  -----------------------------------------------------------------------------
  -- A Matrix is assumed to be in COLUMN,ROW format (a concession to C)
  -- Thus for the matrix:
  -- 1 2 3
  -- 4 5 6
  -- 7 8 9
  -- A(0,2) = 7
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Operators
  -----------------------------------------------------------------------------

  -- Matrix math operations
  -- purpose: matrix multiply
  function "*" (l, r : real_matrix) return real_matrix;
  function "*" (l    : real_matrix; r : real_vector) return real_matrix;
  function "*" (l    : real_vector; r : real_matrix) return real_vector;
  function "*" (l    : REAL; r : real_matrix) return real_matrix;
  function "*" (l    : real_matrix; r : REAL) return real_matrix;
  function "*" (l    : real_vector; r : REAL) return real_vector;
  function "*" (l    : REAL; r : real_vector) return real_vector;

  -- purpose: divide matrix by a scalar
  function "/" (l : real_matrix; r : REAL) return real_matrix;
  function "/" (l : real_vector; r : REAL) return real_vector;

  -- purpose: matrix addition and subtraction
  function "+" (l, r : real_matrix) return real_matrix;
  function "+" (l, r : real_vector) return real_vector;
  function "-" (l, r : real_matrix) return real_matrix;
  function "-" (l, r : real_vector) return real_vector;
  function "-" (arg  : real_matrix) return real_matrix;
  function "-" (arg  : real_vector) return real_vector;

  -- Absolute value
  function "abs" (arg : real_matrix) return real_matrix;
  function "abs" (arg : real_vector) return real_vector;

  -- Matlab .* operator
  function times (l, r : real_matrix) return real_matrix;
  function times (l, r : real_vector) return real_vector;

  -- Matlab ./ operator
  function rdivide (l, r : real_matrix) return real_matrix;
  function rdivide (l, r : real_vector) return real_vector;

  -- Matlab / operator (calls mrdivide)
  function "/" (l, r      : real_matrix) return real_matrix;
  function mrdivide (l, r : real_matrix) return real_matrix;

  -- Matlab \ operator
  function mldivide (l, r : real_matrix) return real_matrix;

  -- Raise a matrix to a power ^ operator
  function "**" (arg : real_matrix; pow : INTEGER) return real_matrix;

  -- same as the matlab .^ function
  function pow (l, r : real_matrix) return real_matrix;
  function pow (l, r : real_vector) return real_vector;

  -- purpose: Performs an element by element square root
  function sqrt (arg : real_matrix) return real_matrix;
  function sqrt (arg : real_vector) return real_vector;

  -- purpose: Performs an element by element e**arg
  function exp (arg : real_matrix) return real_matrix;
  function exp (arg : real_vector) return real_vector;

  -- purpose: Performs an element by element ln
  function log (arg : real_matrix) return real_matrix;
  function log (arg : real_vector) return real_vector;

  -- Compare functions (use the defaults when possible)
  function "=" (l  : real_matrix; r : real_vector) return BOOLEAN;
  function "=" (l  : real_vector; r : real_matrix) return BOOLEAN;
  function "/=" (l : real_matrix; r : real_vector) return BOOLEAN;
  function "/=" (l : real_vector; r : real_matrix) return BOOLEAN;

  -- Integer versions, where it is logical to do them.
  -- purpose: matrix multiply
  function "*" (l, r : integer_matrix) return integer_matrix;
  function "*" (l    : integer_matrix; r : integer_vector)
    return integer_matrix;
  function "*" (l : integer_vector; r : integer_matrix)
    return integer_vector;
  function "*" (l : INTEGER; r : integer_matrix) return integer_matrix;
  function "*" (l : integer_matrix; r : INTEGER) return integer_matrix;
  function "*" (l : integer_vector; r : INTEGER) return integer_vector;
  function "*" (l : INTEGER; r : integer_vector) return integer_vector;

  -- purpose: matrix addition and subtraction
  function "+" (l, r : integer_matrix) return integer_matrix;
  function "+" (l, r : integer_vector) return integer_vector;
  function "-" (l, r : integer_matrix) return integer_matrix;
  function "-" (l, r : integer_vector) return integer_vector;
  function "-" (arg  : integer_matrix) return integer_matrix;
  function "-" (arg  : integer_vector) return integer_vector;

  -- Absolute value
  function "abs" (arg : integer_matrix) return integer_matrix;
  function "abs" (arg : integer_vector) return integer_vector;

  -- Matlab .* operator
  function times (l, r : integer_matrix) return integer_matrix;
  function times (l, r : integer_vector) return integer_vector;

  -- Raise a matrix to a power ^ operator
  function "**" (arg : integer_matrix; pow : NATURAL) return integer_matrix;

  -- same as the matlab .^ function
  function pow (l, r : integer_matrix) return integer_matrix;
  function pow (l, r : integer_vector) return integer_vector;

  -- Compare functions (use the defaults when possible)
  function "=" (l  : integer_matrix; r : integer_vector) return BOOLEAN;
  function "=" (l  : integer_vector; r : integer_matrix) return BOOLEAN;
  function "/=" (l : integer_matrix; r : integer_vector) return BOOLEAN;
  function "/=" (l : integer_vector; r : integer_matrix) return BOOLEAN;

  -----------------------------------------------------------------------------
  -- Algorithmic functions
  -----------------------------------------------------------------------------
  -- Round (by default to an integer)
  function round (
    arg             : real_matrix;
    constant places : INTEGER := 0)
    return real_matrix;

  function round (
    arg             : real_vector;
    constant places : INTEGER := 0)
    return real_vector;

  -- Sum the diagonal
  function trace (arg : real_matrix) return REAL;

  -- Sum a vector
  function sum (arg : real_vector) return REAL;

  -- Sum a matrix and returns a vector
  function sum (
    arg          : real_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return real_vector;

  -- multiply a vector
  function prod (arg : real_vector) return REAL;

  -- multiply a matrix and returns a vector
  function prod (
    arg          : real_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return real_vector;

  -- purpose: Dot product of two vectors
  function dot (l, r : real_vector) return REAL;

  -- purpose: cross product
  function cross (l, r : real_matrix) return real_matrix;
  function cross (l, r : real_vector) return real_vector;

  -- Kronecker product.
  function kron (l, r : real_matrix) return real_matrix;

  -- purpose: Finds the determinant of a matrix
  function det (arg : real_matrix) return REAL;

  -- purpose: Inverts a matrix
  function inv (arg : real_matrix) return real_matrix;

  -- Solve a linear equation
  function linsolve (l : real_matrix; r : real_vector) return real_vector;

  -- Normalize a Matrix
  function normalize (
    arg           : real_matrix;
    constant rval : REAL := 1.0)
    return real_matrix;
  function normalize (
    arg           : real_vector;
    constant rval : REAL := 1.0)
    return real_vector;

  -- Evaluate the polynomial
  function polyval (l, r : real_vector) return real_vector;

  -- Integer versions
  -- Sum the diagonal
  function trace (arg : integer_matrix) return INTEGER;

  -- Sum a vector
  function sum (arg : integer_vector) return INTEGER;

  -- Sum a matrix and returns a vector
  function sum (
    arg          : integer_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return integer_vector;

  -- multiply a vector
  function prod (arg : integer_vector) return INTEGER;

  -- multiply a matrix and returns a vector
  function prod (
    arg          : integer_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return integer_vector;

  -- purpose: Dot product of two vectors
  function dot (l, r : integer_vector) return INTEGER;

  -- purpose: cross product
  function cross (l, r : integer_matrix) return integer_matrix;
  function cross (l, r : integer_vector) return integer_vector;

  -- Kronecker product.
  function kron (l, r : integer_matrix) return integer_matrix;

  -- purpose: Finds the determinant of a matrix
  function det (arg : integer_matrix) return INTEGER;

  -- Evaluate the polynomial
  function polyval (l, r : integer_vector) return integer_vector;

  -----------------------------------------------------------------------------
  -- These functions manipulate the data in a matrix non mathematically
  -----------------------------------------------------------------------------

  -- Returns true if this is a null matrix
  function isempty (arg : real_matrix) return BOOLEAN;
  function isempty (arg : real_vector) return BOOLEAN;

  -- purpose: Transpose a matrix (Similar to matlab A' syntax)
  function transpose (arg : real_matrix) return real_matrix;
  function transpose (arg : real_vector) return real_matrix;
  function transpose (arg : real_matrix) return real_vector;

  -- purpose: returns a matrix of zeros
  function zeros (rows, columns : NATURAL) return real_matrix;
  function zeros (rows, columns : NATURAL) return real_vector;

  -- purpose: returns a matrix of ones
  function ones (rows, columns : NATURAL) return real_matrix;
  function ones (rows, columns : NATURAL) return real_vector;

  -- purpose: Returns an identity matrix
  function eye (rows, columns : NATURAL) return real_matrix;

  -- returns a random matrix
  impure function rand (rows, columns : POSITIVE) return real_matrix;

  -- Puts two matrices together to form one
  function cat (
    constant dim  : POSITIVE;                    -- 1 = y, 2 = x
    l, r : real_matrix)
    return real_matrix;
  function horzcat (l, r : real_matrix) return real_matrix;
  function vertcat (l, r : real_matrix) return real_matrix;

  -- Rotate a matrix
  function flipdim (
    arg          : real_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return real_matrix;
  function fliplr (arg : real_matrix) return real_matrix;
  function flipup (arg : real_matrix) return real_matrix;
  function fliplr (arg : real_vector) return real_vector;
  function rot90 (
    arg          : real_matrix;
    constant dim : INTEGER := 1)
    return real_matrix;

  -- Uses the elements of the input matrix to create one of a new shape
  function reshape (
    arg           : real_matrix;
    constant rows, columns : POSITIVE)
    return real_matrix;

  function reshape (
    arg           : real_vector;
    constant rows, columns : POSITIVE)
    return real_matrix;

  function reshape (
    arg           : real_matrix;
    rows, columns : POSITIVE)
    return real_vector;

  -- returns the size of a matrix
  function size (arg      : real_matrix) return integer_vector;
  -- True if matrix is one dimensional
  function isvector (arg  : real_matrix) return BOOLEAN;
  -- True if a 1/1 matrix
  function isscalar (arg  : real_matrix) return BOOLEAN;
  -- returns the number of elements in a matrix
  function numel (arg     : real_matrix) return INTEGER;
  -- Return the diagonal of a matrix
  function diag (arg      : real_matrix) return real_vector;
  -- Return a matrix with the vector as the diagonal
  function diag (arg      : real_vector) return real_matrix;
  -- Return the matrix of a diagonal
  function blkdiag (arg   : real_vector) return real_matrix;
  -- Creates a block diagonal matrix from "arg", repeated "rep" times
  function blockdiag (arg : real_matrix; rep : POSITIVE) return real_matrix;

  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : REAL;
    constant rows, columns : NATURAL)
    return real_matrix;

  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : REAL;
    constant rows, columns : NATURAL)
    return real_vector;

  -- Replicate a matrix row/column times
  function repmat (
    arg                    : real_matrix;
    constant rows, columns : NATURAL)
    return real_matrix;

  -- Return the lower triangle of a matrix
  function tril (arg : real_matrix) return real_matrix;
  -- Return the upper triangle of a matrix
  function triu (arg : real_matrix) return real_matrix;

  -- Integer version
  -- Returns true if this is a null matrix
  function isempty (arg   : integer_matrix) return BOOLEAN;
  function isempty (arg   : integer_vector) return BOOLEAN;
  -- purpose: Transpose a matrix (Similar to matlab A' syntax)
  function transpose (arg : integer_matrix) return integer_matrix;
  function transpose (arg : integer_vector) return integer_matrix;
  function transpose (arg : integer_matrix) return integer_vector;

  -- purpose: returns a matrix of zeros
  function zeros (rows, columns : NATURAL) return integer_matrix;
  function zeros (rows, columns : NATURAL) return integer_vector;

  -- purpose: returns a matrix of ones
  function ones (rows, columns : NATURAL) return integer_matrix;
  function ones (rows, columns : NATURAL) return integer_vector;

  -- purpose: Returns an identity matrix
  function eye (rows, columns : NATURAL) return integer_matrix;
  -- Puts two matrices together to form one
  function cat (
    constant dim  : POSITIVE;                    -- 1 = y, 2 = x
    l, r : integer_matrix)
    return integer_matrix;
  function horzcat (l, r : integer_matrix) return integer_matrix;
  function vertcat (l, r : integer_matrix) return integer_matrix;
  -- Rotate a matrix
  function flipdim (
    arg          : integer_matrix;
    constant dim : POSITIVE := 1)       -- 1 = y, 2 = x
    return integer_matrix;
  function fliplr (arg : integer_matrix) return integer_matrix;
  function flipup (arg : integer_matrix) return integer_matrix;
  function fliplr (arg : integer_vector) return integer_vector;
  function rot90 (
    arg          : integer_matrix;
    constant dim : INTEGER := 1)
    return integer_matrix;
  -- Uses the elements of the input matrix to create one of a new shape
  function reshape (
    arg           : integer_matrix;
    constant rows, columns : POSITIVE)
    return integer_matrix;

  function reshape (
    arg           : integer_vector;
    constant rows, columns : POSITIVE)
    return integer_matrix;

  function reshape (
    arg           : integer_matrix;
    rows, columns : POSITIVE)
    return integer_vector;

  -- returns the size of a matrix
  function size (arg      : integer_matrix) return integer_vector;
  -- True if matrix is one dimensional
  function isvector (arg  : integer_matrix) return BOOLEAN;
  -- True if a 1/1 matrix
  function isscalar (arg  : integer_matrix) return BOOLEAN;
  -- returns the number of elements in a matrix
  function numel (arg     : integer_matrix) return INTEGER;
  -- Return the diagonal of a matrix
  function diag (arg      : integer_matrix) return integer_vector;
  -- Return a matrix with the vector as the diagonal
  function diag (arg      : integer_vector) return integer_matrix;
  -- Return the matrix of a diagonal
  function blkdiag (arg   : integer_vector) return integer_matrix;
  -- Creates a block diagonal matrix from "arg", repeated "rep" times
  function blockdiag (arg : integer_matrix; rep : POSITIVE)
    return integer_matrix;
  -- Creates a matrix set to the value "val"
  function repmat (
    arg                    : INTEGER;
    constant rows, columns : NATURAL)
    return integer_matrix;
  function repmat (
    arg                    : INTEGER;
    constant rows, columns : NATURAL)
    return integer_vector;
  -- Replicate a matrix row/column times
  function repmat (
    arg                    : integer_matrix;
    constant rows, columns : NATURAL)
    return integer_matrix;

  -- Return the lower triangle of a matrix
  function tril (arg : integer_matrix) return integer_matrix;
  -- Return the upper triangle of a matrix
  function triu (arg : integer_matrix) return integer_matrix;

  -----------------------------------------------------------------------------
  -- These functions allow you to do matrix and vector slicing
  -----------------------------------------------------------------------------
  -- returns an rows/columns matrix from position x,y in the input matrix
  function SubMatrix (
    arg                    : real_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return real_matrix;

  -- returns an rows/columns matrix from position l,r in the input matrix
  function SubMatrix (
    arg                    : real_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return real_vector;

  -- Places the matrix "arg" at location X,Y in matrix "result"
  procedure BuildMatrix (
    arg           : in    real_matrix;
    result        : inout real_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- Places the vector "arg" into matrix "result" along "x" axis starting
  -- at x,y
  procedure BuildMatrix (
    arg           : in    real_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- Same interface as "BuildMatrix", but it inserts a column, not a row.
  procedure InsertColumn (
    arg           : in    real_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- purpose: SubMatrix returns a matrix with 1 less row and column
  -- Used by determinant function
  function exclude (
    arg                  : real_matrix;
    constant row, column : NATURAL)     -- row and column to exclude
    return real_matrix;

  -- returns an rows/columns matrix from position x,y in the input matrix
  function SubMatrix (
    arg                    : integer_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return integer_matrix;

  -- Integer versions
  -- returns an rows/columns matrix from position l,r in the input matrix
  function SubMatrix (
    arg                    : integer_matrix;
    constant x, y          : NATURAL;   -- index into the matrix
    constant rows, columns : NATURAL)   -- rows and columns in new matrix
    return integer_vector;

  -- Places the matrix "arg" at location X,Y in matrix "result"
  procedure BuildMatrix (
    arg           : in    integer_matrix;
    result        : inout integer_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- Places the vector "arg" into matrix "result" along "x" axis starting
  -- at x,y
  procedure BuildMatrix (
    arg           : in    integer_vector;
    result        : inout integer_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- Same interface as "BuildMatrix", but it inserts a column, not a row.
  procedure InsertColumn (
    arg           : in    integer_vector;
    result        : inout integer_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- purpose: SubMatrix returns a matrix with 1 less row and column
  -- Used by determinant function
  function exclude (
    arg                  : integer_matrix;
    constant row, column : NATURAL)     -- row and column to exclude
    return integer_matrix;
  -----------------------------------------------------------------------------
  -- Type conversion functions
  -----------------------------------------------------------------------------

  function to_integer (arg : real_matrix) return integer_matrix;
  function to_integer (arg : real_vector) return integer_vector;

  function to_real (arg : integer_matrix) return real_matrix;
  function to_real (arg : integer_vector) return real_vector;

  -----------------------------------------------------------------------------
  -- Overloads Mixed types functions
  -----------------------------------------------------------------------------
  function "*" (l : real_matrix; r : integer_matrix) return real_matrix;
  function "*" (l : integer_matrix; r : real_matrix) return real_matrix;
  function "*" (l : real_matrix; r : integer_vector) return real_matrix;
  function "*" (l : integer_matrix; r : real_vector) return real_matrix;
  function "*" (l : real_vector; r : integer_matrix) return real_vector;
  function "*" (l : integer_vector; r : real_matrix) return real_vector;
  function "*" (l : real_matrix; r : integer) return real_matrix;
  function "*" (l : integer; r : real_matrix) return real_matrix;
  function "*" (l : real_vector; r : integer) return real_vector;
  function "*" (l : integer; r : real_vector) return real_vector;

  function "+" (l : real_matrix; r : integer_matrix) return real_matrix;
  function "+" (l : integer_matrix; r : real_matrix) return real_matrix;
  function "+" (l : real_vector; r : integer_vector) return real_vector;
  function "+" (l : integer_vector; r : real_vector) return real_vector;
  function "-" (l : real_matrix; r : integer_matrix) return real_matrix;
  function "-" (l : integer_matrix; r : real_matrix) return real_matrix;
  function "-" (l : real_vector; r : integer_vector) return real_vector;
  function "-" (l : integer_vector; r : real_vector) return real_vector;

  function times (l : real_matrix; r : integer_matrix) return real_matrix;
  function times (l : integer_matrix; r : real_matrix) return real_matrix;
  function times (l : real_vector; r : integer_vector) return real_vector;
  function times (l : integer_vector; r : real_vector) return real_vector;

  function rdivide (l, r : integer_matrix) return real_matrix;
  function rdivide (l    : real_matrix; r : integer_matrix) return real_matrix;
  function rdivide (l    : integer_matrix; r : real_matrix) return real_matrix;
  function rdivide (l, r : integer_vector) return real_vector;
  function rdivide (l    : real_vector; r : integer_vector) return real_vector;
  function rdivide (l    : integer_vector; r : real_vector) return real_vector;

  function "/" (l, r : integer_matrix) return real_matrix;
  function "/" (l    : real_matrix; r : integer_matrix) return real_matrix;
  function "/" (l    : integer_matrix; r : real_matrix) return real_matrix;
  function "/" (l    : real_matrix; r : integer) return real_matrix;
  function "/" (l    : real_vector; r : integer) return real_vector;

  function mrdivide (l, r : integer_matrix) return real_matrix;
  function mrdivide (l    : real_matrix; r : integer_matrix) return real_matrix;
  function mrdivide (l    : integer_matrix; r : real_matrix) return real_matrix;

  function mldivide (l, r : integer_matrix) return real_matrix;
  function mldivide (l    : real_matrix; r : integer_matrix) return real_matrix;
  function mldivide (l    : integer_matrix; r : real_matrix) return real_matrix;

  function pow (l : real_matrix; r : integer_matrix) return real_matrix;
  function pow (l : integer_matrix; r : real_matrix) return real_matrix;
  function pow (l : real_vector; r : integer_vector) return real_vector;
  function pow (l : integer_vector; r : real_vector) return real_vector;

  function cross (l : real_matrix; r : integer_matrix) return real_matrix;
  function cross (l : integer_matrix; r : real_matrix) return real_matrix;
  function cross (l : real_vector; r : integer_vector) return real_vector;
  function cross (l : integer_vector; r : real_vector) return real_vector;

  function kron (l : real_matrix; r : integer_matrix) return real_matrix;
  function kron (l : integer_matrix; r : real_matrix) return real_matrix;

  function linsolve (l : integer_matrix; r : integer_vector) return real_vector;
  function linsolve (l : real_matrix; r : integer_vector) return real_vector;
  function linsolve (l : integer_matrix; r : real_vector) return real_vector;

  function inv (arg : integer_matrix) return real_matrix;

  function polyval (l : real_vector; r : integer_vector) return real_vector;
  function polyval (l : integer_vector; r : real_vector) return real_vector;

  function normalize (
    arg           : integer_matrix;
    constant rval : INTEGER := 1)
    return real_matrix;

  function normalize (
    arg           : integer_vector;
    constant rval : INTEGER := 1)
    return real_vector;

  -- Places the matrix "arg" at location X,Y in matrix "result"
  procedure BuildMatrix (
    arg           : in    integer_matrix;
    result        : inout real_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- Places the vector "arg" into matrix "result" along "x" axis starting
  -- at x,y
  procedure BuildMatrix (
    arg           : in    integer_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix

  -- Same interface as "BuildMatrix", but it inserts a column, not a row.
  procedure InsertColumn (
    arg           : in    integer_vector;
    result        : inout real_matrix;
    constant x, y : in    NATURAL);     -- index into the matrix


  -----------------------------------------------------------------------------
  -- TextIO functions
  -----------------------------------------------------------------------------
-- rtl_synthesis off

  -- to_string (integer_vector) SHOULD be defined in VHDL 2008
  function to_string (value : integer_vector) return STRING;
  function to_string (value : real_vector) return STRING;
  function to_string (value : real_matrix) return STRING;
  function to_string (value : integer_matrix) return STRING;

  procedure write (
    L      : inout LINE;
    VALUE  : in    real_vector;
    DIGITS : in    POSITIVE := 4);
  procedure write (
    L      : inout LINE;
    VALUE  : in    real_matrix;
    DIGITS : in    POSITIVE := 4);
  procedure write (
    L         : inout LINE;
    VALUE     : in    integer_vector;
    JUSTIFIED : in    SIDE  := right;
    FIELD     : in    WIDTH := 0);
  procedure write (
    L         : inout LINE;
    VALUE     : in    integer_matrix;
    JUSTIFIED : in    SIDE  := right;
    FIELD     : in    WIDTH := 0);

  procedure READ(L     : inout LINE;
                 VALUE : out   real_vector);
  procedure READ(L     : inout LINE;
                 VALUE : out   real_matrix);
  procedure READ(L     : inout LINE;
                 VALUE : out   integer_vector);
  procedure READ(L     : inout LINE;
                 VALUE : out   integer_matrix);
  procedure READ(L     : inout LINE;
                 VALUE : out   real_vector;
                 GOOD  : out   BOOLEAN);
  procedure READ(L     : inout LINE;
                 VALUE : out   real_matrix;
                 GOOD  : out   BOOLEAN);
  procedure READ(L     : inout LINE;
                 VALUE : out   integer_vector;
                 GOOD  : out   BOOLEAN);
  procedure READ(L     : inout LINE;
                 VALUE : out   integer_matrix;
                 GOOD  : out   BOOLEAN);

  -- purpose: Prints out a matrix
  procedure print_matrix (
    arg   : in real_matrix;
    index : in BOOLEAN := false);

  -- purpose: Prints out a vector
  procedure print_vector (
    arg   : in real_vector;
    index : in BOOLEAN := false);

  -- purpose: Prints out a matrix
  procedure print_matrix (
    arg   : in integer_matrix;
    index : in BOOLEAN := false);

  -- purpose: Prints out a vector
  procedure print_vector (
    arg   : in integer_vector;
    index : in BOOLEAN := false);

  -- protected type for the random number generator seeds
  type random_seeds is protected
    procedure Set (SEED1, SEED2 : INTEGER);
    procedure Get (SEED1, SEED2 : out INTEGER);
  end protected random_seeds;
-- rtl_synthesis on

end package real_matrix_pkg;
