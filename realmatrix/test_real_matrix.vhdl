-------------------------------------------------------------------------------
-- Title      : testbench for Matrix Math package for type REAL
-- Project    : IEEE 1076.1-201x
-------------------------------------------------------------------------------
-- File       : test_real_matrix.vhdl
-- Author     : David Bishop  <dbishop@vhdl.org>
-- Company    :
-- Created    : 2010-04-15
-- Last update: 2023-10-30
-- Platform   :
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Matrix math package testbench for type REAL
-------------------------------------------------------------------------------
-- Copyright (c) 2010
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-04-15  1.0      dbishop@vhdl.org Created
-------------------------------------------------------------------------------

--

entity test_real_matrix is
  generic (
    quiet : BOOLEAN := true);          -- make the simulation quiet
end entity test_real_matrix;

use std.textio.all;
library ieee;
use ieee.math_real.all;
library ieee_proposed;
use ieee_proposed.real_matrix_pkg.all;

architecture testbench of test_real_matrix is

  -- purpose: converts "downto" and none zero ranges into normal matrices
  function reorder (
    arg : real_matrix)
    return real_matrix is
    variable result : real_matrix (0 to arg'length(1)-1,
                                   0 to arg'length(2)-1);
  begin
    for i in arg'low(1) to arg'high(1) loop
      for j in arg'low(2) to arg'high(2) loop
        result (i - arg'low(1), j - arg'low(2)) := arg(i, j);
      end loop;
    end loop;
    return result;
  end function reorder;

  function reorder (
    arg : integer_matrix)
    return integer_matrix is
    variable result : integer_matrix (0 to arg'length(1)-1,
                                      0 to arg'length(2)-1);
  begin
    for i in arg'low(1) to arg'high(1) loop
      for j in arg'low(2) to arg'high(2) loop
        result (i - arg'low(1), j - arg'low(2)) := arg(i, j);
      end loop;
    end loop;
    return result;
  end function reorder;

  signal start_ktest  : BOOLEAN := false;  -- start the test
  signal ktest_done   : BOOLEAN := false;  -- test done
  signal start_ktesti : BOOLEAN := false;  -- start the test
  signal ktesti_done  : BOOLEAN := false;  -- test done

  signal shape_test : BOOLEAN := false;  -- start the test
  signal shape_done : BOOLEAN := false;  -- test done

  signal submat_test    : BOOLEAN := false;  -- start the test
  signal submat_done    : BOOLEAN := false;  -- test done
  signal testeri_start  : BOOLEAN := false;  -- start the test
  signal testeri_done   : BOOLEAN := false;  -- test done
  signal start_tstring  : BOOLEAN := false;  -- start string test
  signal tstring_done   : BOOLEAN := false;  -- test done
  signal start_itstring : BOOLEAN := false;  -- start string test
  signal itstring_done  : BOOLEAN := false;  -- test done
  signal start_zmat     : BOOLEAN := false;  -- start zero matrix test
  signal zmat_done      : BOOLEAN := false;  -- zero matrix test done
  signal trm_start      : BOOLEAN := false;  -- start real matrix test
  signal trm_done       : BOOLEAN := false;
  signal mixed_start    : BOOLEAN := false;  -- mixed int and REAL
  signal mixed_done     : BOOLEAN := false;  -- mixed int and REAL

  subtype m3x3 is real_matrix (0 to 2, 0 to 2);           -- 3x3 matrix
  subtype m3x3p is real_matrix (9 downto 7, 6 downto 4);  -- mixed up range
  subtype a3 is real_vector (0 to 2);
  subtype a3p is real_vector (12 downto 10);
begin

  tester : process is
  begin
    -- Test shape functions
    shape_test <= true;
    wait until shape_done;
    -- Main real matrix test.
    trm_start  <= true;
    wait until trm_done;
    -- Run the Kronecker test
    start_ktest <= true;
    wait until ktest_done;

    -- Submatrix function test
    submat_test <= true;
    wait until submat_done;

    -- Integer matrix test
    testeri_start <= true;
    wait until testeri_done;

    -- Run the Kronecker integer test
    start_ktesti <= true;
    wait until ktesti_done;

    -- String test
    start_tstring <= true;
    wait until tstring_done;

    -- Integer string test
    start_itstring <= true;
    wait until itstring_done;

    mixed_start <= true;
    wait until mixed_done;

    -- Null and zero matrix test
    start_zmat <= true;
    wait until zmat_done;

    report "test_real_matrix completed" severity note;
    wait;
  end process tester;

  -- purpose: apply stims
  trm : process is
    constant mones : real_matrix := ((1.0, 1.0, 1.0),
                                     (1.0, 1.0, 1.0),
                                     (1.0, 1.0, 1.0));      --matrix
    constant am : real_matrix := ((7.0, 3.0), (2.0, 5.0),
                                  (6.0, 8.0), (9.0, 0.0));
    constant bm     : real_matrix := ((7.0, 4.0, 9.0), (8.0, 1.0, 5.0));
    variable e1, e2 : real_matrix (0 to 1, 0 to 1);         -- bm * am
    constant ambmans : real_matrix := ((73.0, 31.0, 78.0),
                                       (54.0, 13.0, 43.0),
                                       (106.0, 32.0, 94.0),
                                       (63.0, 36.0, 81.0));      -- am * bm
    variable ambm      : real_matrix (0 to 3, 0 to 2);      -- am * bm
    constant amv       : real_vector := (1.0, 4.0, 6.0);    -- real_vector
    constant bmv       : real_matrix := ((2.0, 3.0), (5.0, 8.0), (7.0, 9.0));
    constant amvbmvans : real_vector := (64.0, 89.0);
    variable amvbmv    : real_vector (0 to 1);              -- amv * bmv
    constant avm : real_matrix := ((1.0, 2.0, 3.0),
                                   (4.0, 5.0, 6.0),
                                   (7.0, 8.0, 9.0));
    constant bvm        : real_vector := (3.0, 5.0, 7.0);
    variable avmm, bvmm : real_matrix (0 to 2, 0 to 0);
    variable avmbvm     : real_matrix (0 to 2, 0 to 0);     -- matrix * vector
    constant avmbvmans  : real_vector := (34.0, 79.0, 124.0);
    constant avv        : real_vector := (-1.0, -2.0);
    variable avvm       : real_matrix (0 to 1, 0 to 0);
    constant bvv        : real_vector := (-1.0, 1.0, 5.0);
    variable avvbvv     : real_matrix (0 to 1, 0 to 2);     -- matrix
    variable avvbvvy    : real_matrix (0 to 1, 0 to 2);     -- matrix
    variable avvbvvt    : real_matrix (0 to 2, 0 to 1);     -- matrix
    variable avvbvvx    : real_matrix (0 to 2, 0 to 1);     -- matrix
    -- vector * vector (assuming left is a column not a row)
    constant avvbvvans : real_matrix := ((1.0, -1.0, -5.0),
                                         (2.0, -2.0, -10.0));
    constant dtestx : real_matrix := ((3.0, 2.0, 0.0, 1.0),
                                      (4.0, 0.0, 1.0, 2.0),
                                      (3.0, 0.0, 2.0, 1.0),
                                      (9.0, 2.0, 3.0, 1.0));
    variable mx5x5              : real_matrix (0 to 4, 0 to 4);  -- 4x4
    variable submatx, submatans : real_matrix (0 to 1, 0 to 1);
    variable iv2                : integer_vector (0 to 1);  -- integer vector
    variable a, b, c, d         : m3x3;
    variable ap, bp, cp, dp     : m3x3p;
    variable av, bv, cv, dv     : a3;
    variable avx, bvx, cvx      : real_matrix (0 to 0, 0 to 2);  -- 1x3
    variable avp, bvp, cvp, dvp : a3p;
    variable av4, bv4           : real_vector (0 to 3);
    variable a3x4               : real_matrix (0 to 2, 0 to 3);
    variable m, n               : REAL;
    variable mm, nn             : real_vector (0 to 0);
    variable mmm, nnn           : real_matrix (0 to 0, 0 to 0);
    variable i, j               : INTEGER;
    variable bool               : BOOLEAN;
  begin
    -- Basic test  Make sure the compare functions work.
    -- Test ones and Zeros functions
    wait until trm_start;
    a    := ones (3, 3);
    bool := (mones = a);
    if not bool then
      report "mones = ones(a)" severity error;
    end if;
    bool := (mones /= a);
    if bool then
      report "mones /= ones(a)" severity error;
    end if;
    a    := zeros (3, 3);
    bool := (mones = a);
    if bool then
      report "mones = zeros(a)" severity error;
    end if;
    bool := (mones /= a);
    if not bool then
      report "mones /= zeros(a)" severity error;
    end if;
    -- Test identity (eye) function
    a := eye (3, 3);
    b := ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0));
    if a /= b then
      report "eye not working" severity error;
      print_matrix (a);
    end if;
    bool := (a = mones);
    if bool then
      report "identity = ones returned true" severity error;
    end if;
    a  := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    ap := a;
    -- missed up matrix index
    if ap /= a then
      report "Index test, should be equal" severity error;
      print_matrix (ap, true);
    end if;
    bp := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    if bp /= a then
      report "Index test, should be equal" severity error;
      print_matrix (bp, true);
    end if;
    -- Create a matrix that is identical to another, but with the last
    -- row missing.
    a := ((73.0, 31.0, 78.0),
          (54.0, 13.0, 43.0),
          (106.0, 32.0, 94.0));
    bool := (a = ambmans);  -- Note this line give a compile warning.
    if bool then
      report "Compare - extra row not detected" severity error;
    end if;
    -- Test multiply
    ambm := am * bm;
    if ambm /= ambmans then
      report "matrix multiply problem" severity error;
      print_matrix (ambm);
    end if;
    -- vector * matrix
    amvbmv := amv * bmv;
    if amvbmv /= amvbmvans then
      report "vector * matrix problem" severity error;
      print_vector (amvbmv);
      print_vector (amvbmvans);
    end if;
    -- Matrix * vector
    bvmm   := transpose(bvm);
    avmbvm := avm * bvmm;
    if avmbvm /= reshape (avmbvmans, 3, 1) then
      report "matrix * vector problem" severity error;
      print_matrix (avmbvm);
      print_vector (avmbvmans);
    end if;
    -- vector * vector (assuming left is a column not a row)
--    avvm := reshape (avv, 2, 1);
--    avvbvv := avvm * bvv;
--    if avvbvv /= avvbvvans then
--      report "vector * vector problem" severity error;
--      print_matrix (avvbvv, true);
--    end if;
    -- vector * vector (assuming left is row, right is column)
    bvmm  := transpose (bvv);
    mm    := bvm * bvmm;
    nn(0) := 37.0;
    if mm /= nn then
      report "vector * vector = real problem, result was "
        severity error;
      print_vector(mm);
    end if;

    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    c := a * b;
    d := ((30.0, 36.0, 42.0), (66.0, 81.0, 96.0), (102.0, 126.0, 150.0));
    if d /= c then
      report "matrix * matrix 3x3" severity error;
      print_matrix (c, true);
      print_matrix (d, true);
    end if;
    a  := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    ap := a;
    bp := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    cp := ap * bp;
    dp := ((30.0, 36.0, 42.0), (66.0, 81.0, 96.0), (102.0, 126.0, 150.0));
    -- Need to reverse the order of this matrix to compare it.
    b  := reorder (dp);
    if b /= cp then
      report "matrix * matrix odd range problem" severity error;
      print_matrix (cp, true);
      print_matrix (b, true);
    end if;

    a    := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    bv   := (2.0, 3.0, 4.0);
    bvmm := transpose (bv);
    avmm := a * bvmm;
    dv   := (20.0, 47.0, 74.0);
    bvmm := reshape (dv, 3, 1);
    if avmm /= bvmm then
      report "matrix * vector problem" severity error;
      print_matrix (avmm);
    end if;
    ap   := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    bvp  := (2.0, 3.0, 4.0);
    bvmm := transpose (bvp);
    avmm := ap * bvmm;
    dv   := (74.0, 47.0, 20.0);         -- Backward because of "downto"
    bvmm := reshape (dv, 3, 1);
    if avmm /= bvmm then
      report "matrix * vector problem odd range" severity error;
      print_matrix (avmm);
    end if;

    a  := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    bv := (2.0, 3.0, 4.0);
    cv := bv * a;
    dv := (42.0, 51.0, 60.0);
    if cv /= dv then
      report "vector * matrix problem" severity error;
      print_vector (cv);
    end if;
    ap  := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    -- ap  := reorder (ap);                -- flip it to make it work.
    bvp := (2.0, 3.0, 4.0);
    cvp := bvp * ap;
    dvp := (60.0, 51.0, 42.0);          -- backwards because of "downto"
    if cvp /= dvp then
      report " vector * matrix problem odd range" severity error;
      print_vector (cvp);
    end if;

    if not QUIET then
      -- Cause some errors
      report "Expect 3 multiply errors here" severity note;
      e1     := bm * am;                -- 2x3 * 4x2
      a3x4   := bmv * av4;              -- 3x2 * 4
      amvbmv := av4 * bmv;              -- 4 * 3x2
    end if;

    iv2 := size (ambmans);
    assert iv2(0) = 4 report "Size returned the wrong Y dimension "
      & INTEGER'image(iv2(0)) severity error;
    assert iv2(1) = 3 report "Size returned the wrong X dimension "
      & INTEGER'image(iv2(1)) severity error;

    av   := (1.0, 2.0, 3.0);
    bv   := (4.0, 5.0, 6.0);
    avmm := reshape (av, 3, 1);
    c    := avmm * bv;
    d    := ((4.0, 5.0, 6.0), (8.0, 10.0, 12.0), (12.0, 15.0, 18.0));
    if c /= d then
      report " vector * vector 3x3 problem" severity error;
      print_matrix (c);
    end if;
    avp  := (1.0, 2.0, 3.0);
    bvp  := (4.0, 5.0, 6.0);
    avmm := reshape (avp, 3, 1);
    c    := avmm * bvp;
    a    := rot90 (d, 2);               -- mirror because of "downto"
    if c /= a then
      report " vector * vector problem odd range" severity error;
      print_matrix (c);
    end if;

    -- Matrix * real
    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    m := 3.0;
    b := m * a;
    c := ((3.0, 6.0, 9.0), (12.0, 15.0, 18.0), (21.0, 24.0, 27.0));
    if c /= b then
      report "real * Matrix problem" severity error;
      print_matrix (b);
    end if;
    b := a * m;
    if c /= b then
      report "Matrix * real problem" severity error;
      print_matrix (b);
    end if;
    av := (2.0, 3.0, 4.0);
    m  := 10.0;
    bv := av * m;
    cv := (20.0, 30.0, 40.0);
    if bv /= cv then
      report "Vector * real problem" severity error;
      print_vector (bv);
    end if;
    bv := m * av;
    if bv /= cv then
      report "REAL * vector problem" severity error;
      print_vector (bv);
    end if;

    av := (1.0, 2.0, 3.0);
    bv := (4.0, 5.0, 6.0);
    cv := av + bv;
    dv := (5.0, 7.0, 9.0);
    if cv /= dv then
      report " vector + vector problem" severity error;
      print_vector (cv);
    end if;

    avp := (1.0, 2.0, 3.0);
    bvp := (4.0, 5.0, 6.0);
    cvp := avp + bvp;
    dvp := (9.0, 7.0, 5.0);
    if cvp /= dvp then
      report " vector + vector problem odd range" severity error;
      print_vector (cvp);
    end if;

    if not QUIET then
      report "Expect 3 addition errors here" severity note;
      a  := mones + bm;                 -- 3x3 + 3x2
      a  := mones + dtestx;             -- 3x3 + 4x4
      av := avmbvmans + avv;            -- 1x3 + 1x2
    end if;

    av := (1.0, 2.0, 3.0);
    bv := (4.0, 5.0, 6.0);
    cv := av - bv;
    dv := (-3.0, -3.0, -3.0);
    if cv /= dv then
      report " vector - vector problem" severity error;
      print_vector (cv);
    end if;
    av := (1.0, 2.0, 3.0);
    bv := (4.0, 5.0, 6.0);
    av := times (av, bv);
    bv := (4.0, 10.0, 18.0);
    if av /= bv then
      report " vector .* vector (times) problem" severity error;
      print_vector (av);
    end if;

    avp := (1.0, 2.0, 3.0);
    bvp := (4.0, 5.0, 6.0);
    avp := times (avp, bvp);
    bvp := (18.0, 10.0, 4.0);           -- reversed because of "downto"
    if avp /= bvp then
      report " vector .* vector (times) problem odd range" severity error;
      print_vector (avp);
    end if;

    av := (1.0, 2.0, 3.0);
    bv := (4.0, 5.0, 6.0);
    av := rdivide (bv, av);
    bv := (4.0, 2.5, 2.0);
    if av /= bv then
      report " vector ./ vector (rdivide) problem" severity error;
      print_vector (av);
    end if;

    avp := (1.0, 2.0, 3.0);
    bvp := (4.0, 5.0, 6.0);
    avp := rdivide (bvp, avp);
    bvp := (2.0, 2.5, 4.0);             -- reversed because of "downto"
    if avp /= bvp then
      report " vector ./ vector (rdivide) problem odd range" severity error;
      print_vector (avp);
    end if;

    -- Addition and subtraction
    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b := transpose(a);
    c := a + b;
    d := ((2.0, 6.0, 10.0), (6.0, 10.0, 14.0), (10.0, 14.0, 18.0));
    if d /= c then
      report "matrix + matrix problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    ap := a;
    bp := b;
    cp := ap + bp;
    d  := ((2.0, 6.0, 10.0), (6.0, 10.0, 14.0), (10.0, 14.0, 18.0));
    if d /= reorder(cp) then
      report "matrix + matrix odd range problem" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    c := a - b;
    d := ((0.0, -2.0, -4.0), (2.0, 0.0, -2.0), (4.0, 2.0, 0.0));
    if d /= c then
      report "matrix - matrix problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    ap := a;
    bp := b;
    cp := ap - bp;
    d  := ((0.0, -2.0, -4.0), (2.0, 0.0, -2.0), (4.0, 2.0, 0.0));
    if d /= reorder(cp) then
      report "matrix - matrix odd range problem" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    if not QUIET then
      report "Expect 3 subtraction errors here" severity note;
      a  := mones - bm;                 -- 3x3 + 3x2
      a  := mones - dtestx;             -- 3x3 + 4x4
      av := avmbvmans - avv;
    end if;
    -- element by element multiply
    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b := transpose(a);
    c := times(a, b);
    d := ((1.0, 8.0, 21.0), (8.0, 25.0, 48.0), (21.0, 48.0, 81.0));
    if d /= c then
      report "times(matrix, matrix) problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    cp := times (ap, bp);
    d  := ((1.0, 8.0, 21.0), (8.0, 25.0, 48.0), (21.0, 48.0, 81.0));
    if d /= reorder(cp) then
      report "times(matrix, matrix) problem odd range" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    if not QUIET then
      report "Expect 3 times errors here" severity note;
      a  := times(mones, bm);           -- 3x3 + 3x2
      a  := times(mones, dtestx);       -- 3x3 + 4x4
      av := times(avmbvmans, avv);
    end if;
    -- element by element divide
    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b := transpose(a);
    c := ((1.0, 4.0, 7.0), (2.0, 5.0, 8.0), (3.0, 6.0, 9.0));
    if b /= c then
      report "Transpose problem" severity error;
      print_matrix (b);
      print_matrix (c);
    end if;
    c := rdivide (a, b);
    d := ((1.0, 0.5, 3.0/7.0), (2.0, 1.0, 6.0/8.0), (7.0/3.0, 8.0/6.0, 1.0));
    if d /= c then
      report "rdivide(matrix, matrix) problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    cp := rdivide (ap, bp);
    d  := ((1.0, 0.5, 3.0/7.0), (2.0, 1.0, 6.0/8.0), (7.0/3.0, 8.0/6.0, 1.0));
    if d /= reorder(cp) then
      report "rdivide(matrix, matrix) problem odd range" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    if not QUIET then
      report "Expect 3 rdivide errors here" severity note;
      a  := rdivide(mones, bm);         -- 3x3 + 3x2
      a  := rdivide(mones, dtestx);     -- 3x3 + 4x4
      av := rdivide(avmbvmans, avv);
    end if;
    avvbvvt := transpose (avvbvvans);
    avvbvvx := ((1.0, 2.0), (-1.0, -2.0), (-5.0, -10.0));
    if avvbvvt /= avvbvvx then
      report "2x3 transpose problem" severity error;
      print_matrix (avvbvvt);
    end if;
    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b := a * 2;                         -- test overload
    m := 2.0;
    c := b / m;
    if c /= a then
      report "Matrix / real problem" severity error;
      print_matrix (c);
    end if;
    av := (4.0, 5.0, 6.0);
    bv := 2 * av;
    m  := 2.0;
    cv := bv / m;
    if av /= cv then
      report "vector / real issue severity" severity error;
      print_vector (cv);
    end if;
    avvbvv  := abs (avvbvvans);
    avvbvvy := ((1.0, 1.0, 5.0), (2.0, 2.0, 10.0));
    if avvbvv /= avvbvvy then
      report "abs(matrix) problem" severity error;
      print_matrix (avvbvv);
    end if;
    av := (1.0, -2.0, -9.0);
    bv := abs (av);
    cv := (1.0, 2.0, 9.0);
    if bv /= cv then
      report "abs(vector) problem" severity error;
      print_vector (bv);
    end if;

    -- Submatrix test
    a         := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    submatx   := exclude (a, 1, 1);
    submatans := ((1.0, 3.0), (7.0, 9.0));
    if submatx /= submatans then
      report "Submatrix(1,1) problem" severity error;
      print_matrix (submatx);
    end if;
    submatx   := exclude (a, 2, 0);
    submatans := ((2.0, 3.0), (5.0, 6.0));
    if submatx /= submatans then
      report "Submatrix(2,0) problem" severity error;
      print_matrix (submatx);
    end if;
    submatx   := exclude (a, 0, 2);
    submatans := ((4.0, 5.0), (7.0, 8.0));
    if submatx /= submatans then
      report "Submatrix(0,2) problem" severity error;
      print_matrix (submatx);
    end if;
    ap        := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    submatx   := exclude (ap, 7, 4);
    submatans := ((5.0, 4.0), (2.0, 1.0));
    if submatx /= submatans then
      report "Submatrix(7,4) odd range problem" severity error;
      print_matrix (submatx);
    end if;

    -- Determinant test
    submatx := ((1.0, 2.0), (4.0, 3.0));
    m       := det (submatx);
    if m /= -5.0 then
      report "Determinant -5 /= "& REAL'image(m) severity error;
      print_matrix(submatx);
    end if;
    submatx := ((3.0, 2.0), (5.0, 2.0));
    m       := det (submatx);
    if m /= -4.0 then
      report "Determinant -4 /= "& REAL'image(m) severity error;
      print_matrix(submatx);
    end if;
    submatx := ((13.0, 5.0), (2.0, 4.0));
    m       := det (submatx);
    if m /= 42.0 then
      report "Determinant 2x2 42 /= " & REAL'image(m) severity error;
    end if;
    -- 1/1
    mmm(0, 0) := 2.0;
    m         := det (mmm);
    if m /= 2.0 then
      report "det(1x1) = " & REAL'image (m) severity error;
    end if;
    -- 3x3
    a := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    m := det (a);
    if m /= 17.0 then
      report "Determinant 17 /= "& REAL'image(m) severity error;
      print_matrix(a);
    end if;
    ap := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    m  := det (ap);
    if m /= 17.0 then
      report "Determinant odd range 17 /= "& REAL'image(m) severity error;
      print_matrix(ap);
    end if;
    a := ((12.0, 6.0, -9.0), (3.0, 8.0, 15.0), (4.0, 11.0, 5.0));
    m := det (a);
    if m /= -1239.0 then
      report "Determinant 3x3 -1239 /= " & REAL'image(m) severity error;
    end if;
    -- Try a larger matrix
    m := det (dtestx);                  -- 4x4 matrix
    if m /= 24.0 then
      report "Determinant 24 /= "& REAL'image(m) severity error;
      print_matrix(dtestx);
    end if;
    -- from http://answers.yahoo.com/question/index?qid=20070123154335AAIVKZd
    mx5x5 := ((5.0, 2.0, 0.0, 0.0, -2.0),
              (0.0, 1.0, 4.0, 3.0, 2.0),
              (0.0, 0.0, 2.0, 6.0, 3.0),
              (0.0, 0.0, 3.0, 4.0, 1.0),
              (0.0, 0.0, 0.0, 0.0, 2.0));
    m := det (mx5x5);
    if m /= -100.0 then
      report "Determinant 5x5 problem = "& REAL'image(m) severity error;
    end if;
    if not quiet then
      report "Expect 2 DET/inv error here" severity note;
      m       := det (avvbvvans);        -- Not square
      avvbvvt := inv (avvbvvans);
    end if;

    -- Invert a matrix
    a := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    c := inv(a);
    d := ((-13.0/17.0, 4.0/17.0, 7.0/17.0),
          (-2.0/17.0, -2.0/17.0, 5.0/17.0),
          (18.0/17.0, 1.0/17.0, -11.0/17.0));
    if c /= d then
      report "Invert problem " severity error;
      print_matrix(c, true);
      print_matrix(d, true);
    end if;

    -- 2/2
    submatx   := ((1.0, 2.0), (3.0, 4.0));
    submatx   := inv (submatx);
    submatans := ((-2.0, 1.0), (1.5, -0.5));
    if submatx /= submatans then
      report "inv(2x2) problem" severity error;
      print_matrix (submatx);
    end if;

    -- 1/1
    mmm(0, 0) := 2.0;
    nnn       := inv (mmm);
    if nnn (0, 0) /= 0.5 then
      report "inv(1x1) = " & REAL'image (nnn(0, 0)) severity error;
    end if;

    -- mldivide
    -- Create a magic matrix.
    a      := ((8.0, 1.0, 6.0), (3.0, 5.0, 7.0), (4.0, 9.0, 2.0));
    av     := (1.0, 2.0, 3.0);
    avmm   := reshape (av, 3, 1);
    bvmm   := mldivide (a, avmm);
    bv     := (0.05, 0.3, 0.05);
    avmbvm := reshape (bv, 3, 1);

    bvmm := round(bvmm, 15);               -- round result
    if bvmm /= avmbvm then
      report "mldivide problem" severity error;
      print_matrix (bvmm);
      print_matrix (avmbvm);
      report "(0) = " & REAL'image (bvmm(0, 0) - avmbvm(0, 0)) &
        " (1) = " & REAL'image (bvmm(1, 0) - avmbvm(1, 0)) &
        " (2) = " & REAL'image (bvmm(2, 0) - avmbvm(2, 0)) severity note;
    end if;

    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 0.0));
    b := ((2.0, 4.0, 6.0), (0.0, 3.0, 7.0), (9.0, 8.0, 1.0));
    c := a / b;
    d := ((0.5, 0.0, 0.0), (3.6875, -2.25, -0.375), (-8.3125, 6.75, 2.625));
    if c /= d then
      report "matrix / matrix" severity error;
      print_matrix (c);
      print_matrix(d);
    end if;
    -- Check mrdivide interface
    c := mrdivide (a, b);
    if c /= d then
      report "mrdivide" severity error;
      print_matrix (c);
      print_matrix(d);
    end if;

    -- dot product
    m := dot (amv, bvm);
    assert m = 65.0
      report "Dot product problem, expected 65, and got " & REAL'image(m)
      severity error;
    m := dot (amv, bvv);
    assert m = 33.0
      report "Dot product problem, expected 33, and got " & REAL'image(m)
      severity error;
    if not quiet then
      report "Expect 1 dot error here" severity note;
      m := dot (amv, av4);              -- Not the same length
    end if;

    -- Test sum and trace
    m := sum (amv);
    if m /= 11.0 then
      report "sum (vector) problem, result was " & REAL'image(m)
        severity error;
    end if;

    m := trace (ambmans);
    if m /= 180.0 then
      report "trace problem, result was " & REAL'image(m)
        severity error;
    end if;

    m := trace (am);
    if m /= 12.0 then
      report "trace (2) problem, result was " & REAL'image(m)
        severity error;
    end if;

    av := sum (ambmans, 1);             -- Sum along Y
    bv := (296.0, 112.0, 296.0);
    if av /= bv then
      report "Sum (x,2) problem" severity error;
      print_vector (av);
    end if;

    av4 := sum (ambmans, 2);            -- Sum along X
    bv4 := (182.0, 110.0, 232.0, 180.0);
    if av4 /= bv4 then
      report "Sum (x,1) problem" severity error;
      print_vector (av4);
    end if;

    av := (8.0, 1.0, 6.0);
    m  := prod (av);
    if m /= 48.0 then
      report "prod (vector) problem "& REAL'image(m) severity error;
    end if;

    a := ((8.0, 1.0, 6.0),
          (3.0, 5.0, 7.0),
          (4.0, 9.0, 2.0));
    av := prod(a);
    bv := (96.0, 45.0, 84.0);
    if av /= bv then
      report "prod(1) problem" severity error;
      print_vector (av);
    end if;
    av := prod(a, 2);
    bv := (48.0, 105.0, 72.0);
    if av /= bv then
      report "prod(2) problem" severity error;
      print_vector (av);
    end if;

    if not quiet then
      report "Expect 3 sum/prod dim errors here" severity note;
      av := sum (a, 3);
      av := prod (a, 3);
      b  := flipdim (a, 3);
    end if;

    -- Flip a few Matrices...
    b := fliplr (avm);
    c := ((3.0, 2.0, 1.0),
          (6.0, 5.0, 4.0),
          (9.0, 8.0, 7.0));
    if b /= c then
      report "Fliplr problem " severity error;
      print_matrix (b);
    end if;

    b := flipdim (avm, 2);
    c := ((3.0, 2.0, 1.0),
          (6.0, 5.0, 4.0),
          (9.0, 8.0, 7.0));
    if b /= c then
      report "Flipdim 2 problem " severity error;
      print_matrix (b);
    end if;


    b := flipup (avm);
    c := ((7.0, 8.0, 9.0),
          (4.0, 5.0, 6.0),
          (1.0, 2.0, 3.0));
    if b /= c then
      report "Flipup problem " severity error;
      print_matrix (b);
    end if;

    b := flipdim (avm, 1);
    c := ((7.0, 8.0, 9.0),
          (4.0, 5.0, 6.0),
          (1.0, 2.0, 3.0));
    if b /= c then
      report "Flipdim 1 problem " severity error;
      print_matrix (b);
    end if;


    b := rot90 (avm);
    c := ((3.0, 6.0, 9.0),
          (2.0, 5.0, 8.0),
          (1.0, 4.0, 7.0));
    if b /= c then
      report "rot90 problem " severity error;
      print_matrix (b);
    end if;
    b := rot90 (avm, 1);
    if b /= c then
      report "rot90 1 problem " severity error;
      print_matrix (b);
    end if;
    b := rot90 (avm, -3);
    if b /= c then
      report "rot90 -3 problem " severity error;
      print_matrix (b);
    end if;

    b := rot90 (avm, 0);
    c := avm;
    if b /= c then
      report "rot90 0 problem " severity error;
      print_matrix (b);
    end if;
    b := rot90 (avm, 4);
    c := avm;
    if b /= c then
      report "rot90 4 problem " severity error;
      print_matrix (b);
    end if;
    b := rot90 (avm, -4);
    c := avm;
    if b /= c then
      report "rot90 -4 problem " severity error;
      print_matrix (b);
    end if;

    b := rot90 (avm, 2);
    c := ((9.0, 8.0, 7.0),
          (6.0, 5.0, 4.0),
          (3.0, 2.0, 1.0));
    if b /= c then
      report "rot90 2 problem " severity error;
      print_matrix (b);
    end if;
    b := rot90 (avm, -2);
    if b /= c then
      report "rot90 -2 problem " severity error;
      print_matrix (b);
    end if;

    b := rot90 (avm, 3);
    c := ((7.0, 4.0, 1.0),
          (8.0, 5.0, 2.0),
          (9.0, 6.0, 3.0));
    if b /= c then
      report "rot90 3 problem " severity error;
      print_matrix (b);
    end if;
    b := rot90 (avm, -1);
    if b /= c then
      report "rot90 -1 problem " severity error;
      print_matrix (b);
    end if;

    a := tril(avm);
    c := ((0.0, 0.0, 0.0),
          (4.0, 0.0, 0.0),
          (7.0, 8.0, 0.0));
    if a /= c then
      report "tril problem" severity error;
      print_matrix (a);
    end if;

    av := diag (avm);
    bv := (1.0, 5.0, 9.0);
    if av /= bv then
      report "diag problem" severity error;
      print_vector (av);
    end if;

    av := (5.0, 6.0, 7.0);
    a  := diag (av);
    b := ((5.0, 0.0, 0.0),
          (0.0, 6.0, 0.0),
          (0.0, 0.0, 7.0));
    if a /= b then
      report "diag(vector) problem" severity error;
      print_matrix (a);
    end if;

    a := blkdiag (bvv);
    b := ((-1.0, 0.0, 0.0),
          (0.0, 1.0, 0.0),
          (0.0, 0.0, 5.0));
    if a /= b then
      report "blkdiag problem" severity error;
      print_matrix (a);
    end if;

    a := triu (avm);
    c := ((0.0, 2.0, 3.0),
          (0.0, 0.0, 6.0),
          (0.0, 0.0, 0.0));
    if a /= c then
      report "triu problem" severity error;
      print_matrix (a);
    end if;
    av := (1.0, 2.0, 3.0);
    bv := (4.0, 5.0, 6.0);
    cv := cross (av, bv);
    dv := (-3.0, 6.0, -3.0);
    if cv /= dv then
      report "Cross product problem" severity error;
      print_vector (cv);
    end if;
    a := avm;
    b := rot90(avm, 2);
    c := cross (a, b);
    d := ((-30.0, -30.0, -30.0),
          (60.0, 60.0, 60.0),
          (-30.0, -30.0, -30.0));
    if c /= d then
      report "Cross product (matrix) problem" severity error;
      print_matrix (c);
    end if;

    a := ((1.0, 1.0, -1.0),
          (2.0, -1.0, 1.0),
          (-1.0, 2.0, 2.0));
    av := (-2.0, 5.0, 1.0);
    bv := linsolve (a, av);
    cv := (1.0, -1.0, 2.0);
    if bv /= cv then
      report "Linsolve problem" severity error;
      print_vector (bv);
    end if;
    -- Another way to solve a linear equation is to do inv(a)*av, which also
    -- happens to be the same as the mldivide algorithm
    bvmm   := mldivide (a, reshape(av, 3, 1));
    avmbvm := reshape (cv, 3, 1);
    bvmm   := round (bvmm, 15);
--    avmbvm (0,0) := avmbvm(0,0) - 1.110223e-16;  -- rounding
    if bvmm /= avmbvm then
      report "mldivide / linsolve" severity error;
      print_matrix (bvmm);
      print_matrix (avmbvm);
      report "(0) = " & REAL'image (bvmm(0, 0) - avmbvm(0, 0)) &
        " (1) = " & REAL'image (bvmm(1, 0) - avmbvm(1, 0)) &
        " (2) = " & REAL'image (bvmm(2, 0) - avmbvm(2, 0)) severity note;
    end if;

    a := ((3.0, 2.0, -1.0),
          (2.0, -2.0, 4.0),
          (-1.0, 0.5, -1.0));
    av := (1.0, -2.0, 0.0);
    bv := linsolve (a, av);
    -- Because of the "3", this answer needs rounding
    bv := round (bv, 10);
    cv := (1.0, -2.0, -2.0);
    if bv /= cv then
      report "Linsolve problem 2" severity error;
      print_vector (bv);
    end if;
    -- Also, through mldivide
    bvmm   := mldivide (a, reshape(av, 3, 1));
    avmbvm := reshape (cv, 3, 1);
    bvmm   := round (bvmm, 15);
    if bvmm /= avmbvm then
      report "mldivide / linsolve" severity error;
      print_matrix (bvmm);
      print_matrix (avmbvm);
      report "(0) = " & REAL'image (bvmm(0, 0) - avmbvm(0, 0)) &
        " (1) = " & REAL'image (bvmm(1, 0) - avmbvm(1, 0)) &
        " (2) = " & REAL'image (bvmm(2, 0) - avmbvm(2, 0)) severity note;
    end if;

    a := ((2.0, 2.0, -1.0),
          (2.0, -2.0, -4.0),
          (-1.0, 0.5, -1.0));
    b := normalize (a);
    c := ((0.5, 0.5, -0.25),
          (0.5, -0.5, -1.0),
          (-0.25, 0.125, -0.25));
    if b /= c then
      report "Normalization error" severity error;
      print_matrix (b);
    end if;

    a := ((2.0, 2.0, -1.0),
          (2.0, -2.0, -4.0),
          (-1.0, 0.5, -1.0));
    b := normalize (a, 2.0);
    c := ((1.0, 1.0, -0.5),
          (1.0, -1.0, -2.0),
          (-0.5, 0.25, -0.5));
    if b /= c then
      report "Normalization by 2 error" severity error;
      print_matrix (b);
    end if;

    av := (1.0, 2.0, -4.0);
    bv := normalize (av);
    cv := (0.25, 0.5, -1.0);
    if bv /= cv then
      report "Normalization vector error" severity error;
      print_vector (bv);
    end if;

    av := (1.0, 2.0, 3.0);              -- 3*x^2 + 2*x + 1
    bv := (5.0, 7.0, 9.0);
    cv := polyval (av, bv);
    dv := (86.0, 162.0, 262.0);
    if cv /= dv then
      report "Polyval problem" severity error;
      print_vector (cv);
    end if;

    -- Matrix raised to a power.
    b := avm**2;
    c := ((30.0, 36.0, 42.0),
          (66.0, 81.0, 96.0),
          (102.0, 126.0, 150.0));
    if b /= c then
      report "matrix ** 2 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**1;
    if b /= avm then
      report "matrix ** 1 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**3;
    c := ((468.0, 576.0, 684.0),
          (1062.0, 1305.0, 1548.0),
          (1656.0, 2034.0, 2412.0));
    if b /= c then
      report "matrix ** 3 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**4;
    c := ((7560.0, 9288.0, 11016.0),
          (17118.0, 21033.0, 24948.0),
          (26676.0, 32778.0, 38880.0));
    if b /= c then
      report "matrix ** 4 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**5;
    c := ((121824.0, 149688.0, 177552.0),
          (275886.0, 338985.0, 402084.0),
          (429948.0, 528282.0, 626616.0));
    if b /= c then
      report "matrix ** 5 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**0;
    c := ones(3, 3);
    if b /= c then
      report "matrix ** 0 problem" severity error;
      print_matrix (b);
    end if;

    -- The "1,2,3" matrix does not scale well.
    a := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    b := a**(-1);
    c := inv(a);
    if b /= c then
      report "matrix ** -1 problem" severity error;
      print_matrix (b);
    end if;

    a := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    b := a**(-2);
    c := inv(a);
    c := c * c;
    if b /= c then
      report "matrix ** -2 problem" severity error;
      print_matrix (b);
    end if;

    -- Test "pow" function
    av := (4.0, 25.0, 81.0);
    bv := repmat (0.5, 1, 3);
    cv := pow(av, bv);
    dv := (2.0, 5.0, 9.0);
    if cv /= dv then
      report "pow (vector, vector)" severity error;
      print_vector (cv);
    end if;
    a := ((8.0, 1.0, 6.0),
          (3.0, 5.0, 7.0),
          (4.0, 9.0, 2.0));
    b := repmat (2.0, 3, 3);
    c := pow(a, b);
    d := ((64.0, 1.0, 36.0),
          (9.0, 25.0, 49.0),
          (16.0, 81.0, 4.0));
    if c /= d then
      report "pow (3x3,3x3)" severity error;
      print_matrix(c);
    end if;


    av := (4.0, 25.0, 81.0);
    bv := sqrt (av);
    cv := (2.0, 5.0, 9.0);
    if bv /= cv then
      report "sqrt(vector) problem" severity error;
      print_vector (bv);
    end if;

    a := ((81.0, 64.0, 49.0),
          (36.0, 25.0, 16.0),
          (9.0, 4.0, 1.0));
    b := sqrt(a);
    c := ((9.0, 8.0, 7.0),
          (6.0, 5.0, 4.0),
          (3.0, 2.0, 1.0));
    if b /= c then
      report "sqrt (matrix) problem" severity error;
      print_matrix (b);
    end if;

    av := (1.0, 2.0, 0.5);
    cv := exp (av);
    dv := (math_e, math_e**2, sqrt (math_e));
    cv := round(cv, 10);               -- round results.
    dv := round(dv, 10);
    if cv /= dv then
      report "exp (vector)" severity error;
      print_vector (cv);
      print_vector (dv);
    end if;

    a := ((1.0, 2.0, 0.5), (1.0, 2.0, 0.5), (1.0, 2.0, 0.5));
    c := exp (a);
    d := ((math_e, math_e**2, sqrt (math_e)),
          (math_e, math_e**2, sqrt (math_e)),
          (math_e, math_e**2, sqrt (math_e)));
    c := round(c, 10);
    d := round(d, 10);
    if c /= d then
      report "exp (matrix)" severity error;
      print_matrix (c);
    end if;

    av := (math_e, math_e**2, sqrt (math_e));
    cv := log (av);
    dv := (1.0, 2.0, 0.5);
    cv := round (cv, 10);
    if cv /= dv then
      report "log (vector)" severity error;
      print_vector (cv);
      print_vector (dv);
    end if;

    a := ((math_e, math_e**2, sqrt (math_e)),
          (math_e, math_e**2, sqrt (math_e)),
          (math_e, math_e**2, sqrt (math_e)));
    c := log(a);
    d := ((1.0, 2.0, 0.5), (1.0, 2.0, 0.5), (1.0, 2.0, 0.5));
    c := round (c, 10);
    if c /= d then
      report "log (matrix)" severity error;
      print_matrix (c);
    end if;

    assert not isvector (a)
      report "isvector (3x3) returned true" severity error;
    assert isvector (avx)
      report "isvector (1x3) returned false" severity error;
    assert isvector (avmm)
      report "isvector (3x1) returned false" severity error;
    assert isvector (mmm)
      report "isvector (1x1) returned false" severity error;

    assert not isscalar (a)
      report "isscalar (3x3) returned true" severity error;
    assert not isscalar (avx)
      report "isscalar (1x3) returned true" severity error;
    assert not isscalar (avmm)
      report "isscalar (3x1) returned true" severity error;
    assert isscalar (mmm)
      report "isscalar (1x1) returned false" severity error;

    -- Random matrix
    a := rand (3, 3);
--        print_matrix(a);
    b := rand (3, 3);
--        print_matrix(b);
    if a = b then
      report "rand function not random" severity error;
      print_matrix (a);
      print_matrix (b);
    end if;
    avvbvv := rand (2, 3);
--        print_matrix(avvbvv);

    trm_done <= true;
    wait;
  end process trm;

  -- purpose: test the shape function

  shapper : process is
    constant a : real_matrix := ((1.0, 4.0, 7.0, 10.0),
                                 (2.0, 5.0, 8.0, 11.0),
                                 (3.0, 6.0, 9.0, 12.0));
    variable b : real_matrix (0 to 1, 0 to 5);
    constant bt : real_matrix := ((1.0, 3.0, 5.0, 7.0, 9.0, 11.0),
                                  (2.0, 4.0, 6.0, 8.0, 10.0, 12.0));
    variable a1d, c1d   : real_matrix (0 to 2, 0 to 0);  -- 1d matrix
    variable b1d        : real_matrix (0 to 0, 0 to 2);  -- 1d matrix
    variable a3, b3, c3 : real_matrix (0 to 2, 0 to 2);
    variable a34, b34   : real_matrix (0 to 2, 0 to 3);
    variable a43, b43   : real_matrix (0 to 3, 0 to 2);
    variable a36, b36   : real_matrix (0 to 2, 0 to 5);
    variable a63, b63   : real_matrix (0 to 5, 0 to 2);
    variable av9, bv9   : real_vector (0 to 8);
    variable av3, bv3   : real_vector (0 to 2);

  begin
    wait until shape_test;
    b := reshape (a, 2, 6);
    if b /= bt then
      report "reshape problem" severity error;
      print_matrix (b);
    end if;

    av9 := (1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    a3  := reshape (av9, 3, 3);
    b3 := ((1.0, 4.0, 7.0),
           (2.0, 5.0, 8.0),
           (3.0, 6.0, 9.0));
    if a3 /= b3 then
      report "reshape(vector) problem" severity error;
      print_matrix(a3);
    end if;

    b3 := transpose (a3);
    c3 := ((1.0, 2.0, 3.0),
           (4.0, 5.0, 6.0),
           (7.0, 8.0, 9.0));
    if b3 /= c3 then
      report "Transpose(reshape) issue" severity error;
      print_matrix(b3);
    end if;
    av3 := (10.0, -20.0, 42.0);
    a1d := transpose (av3);
    c1d (0, 0) := 10.0;
    c1d (1, 0) := -20.0;
    c1d (2, 0) := 42.0;
    if a1d /= c1d then
      report "transpose(vector) return matrix" severity error;
      print_matrix (a1d);
    end if;
    bv3 := transpose (a1d);
    if av3 /= bv3 then
      report "tanspose (matrix) return vector" severity error;
      print_vector (bv3);
    end if;

    a3 := ((1.0, 2.0, 3.0),
           (4.0, 5.0, 6.0),
           (7.0, 8.0, 9.0));
    a1d := SubMatrix (a3, 0, 2, 3, 1);
    -- Pull a column (3 wide) starting at (0,2) = 3
    av3 := (3.0, 6.0, 9.0);
    c1d := reshape (av3, 3, 1);
    if a1d /= c1d then
      report "SubMatrix (1dmat)" severity error;
      print_matrix (a1d);
    end if;
    b1d := SubMatrix (a3, 2, 0, 1, 3);
    -- Pull a column (3 wide) starting at (0,2) = 3
    av3 := (7.0, 8.0, 9.0);
    if b1d /= av3 then
      report "SubMatrix (1dmaty)" severity error;
      print_matrix (b1d);
    end if;

    a3 := ((1.0, 2.0, 3.0),
           (4.0, 5.0, 6.0),
           (7.0, 8.0, 9.0));

    av3 := reshape (a3, 1, 3);
    bv3 := (1.0, 2.0, 3.0);
    if av3 /= bv3 then
      report "reshape(mat,1,3)" severity error;
      print_vector (av3);
    end if;

    av3 := reshape (a3, 3, 1);
    bv3 := (1.0, 4.0, 7.0);
    if av3 /= bv3 then
      report "reshape(mat,3,1)" severity error;
      print_vector (av3);
    end if;

    av9 := reshape (a3, 1, 9);
    bv9 := (1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    if av9 /= bv9 then
      report "reshape (mat, 1, 9)" severity error;
      print_vector (av9);
    end if;
    av9 := reshape (a3, 9, 1);
    bv9 := (1.0, 4.0, 7.0, 2.0, 5.0, 8.0, 3.0, 6.0, 9.0);
    if av9 /= bv9 then
      report "reshape (mat, 9, 1)" severity error;
      print_vector (av9);
    end if;

    a3  := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b3  := ((11.0, 12.0, 13.0), (14.0, 15.0, 16.0), (17.0, 18.0, 19.0));
    a36 := horzcat (a3, b3);
    b36 := ((1.0, 2.0, 3.0, 11.0, 12.0, 13.0),
            (4.0, 5.0, 6.0, 14.0, 15.0, 16.0),
            (7.0, 8.0, 9.0, 17.0, 18.0, 19.0));
    if a36 /= b36 then
      report "horzcat (3x3,3x3)" severity error;
      print_matrix (a36);
    end if;
    a1d (0, 0) := 21.0;
    a1d (1, 0) := 22.0;
    a1d (2, 0) := 23.0;
    a34        := horzcat (a3, a1d);
    b34 := ((1.0, 2.0, 3.0, 21.0),
            (4.0, 5.0, 6.0, 22.0),
            (7.0, 8.0, 9.0, 23.0));
    if a34 /= b34 then
      report "horzcat (3x3, 1x3)" severity error;
      print_matrix(a34);
    end if;
    a34 := horzcat (a1d, a3);
    b34 := ((21.0, 1.0, 2.0, 3.0),
            (22.0, 4.0, 5.0, 6.0),
            (23.0, 7.0, 8.0, 9.0));
    if a34 /= b34 then
      report "horzcat (1x3, 3x3)" severity error;
      print_matrix(a34);
    end if;
    if not quiet then
      a36 := horzcat (a3, a63);
    end if;

    a63 := vertcat (a3, b3);
    b63 := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0),
            (11.0, 12.0, 13.0), (14.0, 15.0, 16.0), (17.0, 18.0, 19.0));
    if a63 /= b63 then
      report "vertcat (3x3, 3x3)" severity error;
      print_matrix (a63);
    end if;
    b1d (0, 0) := 31.0;
    b1d (0, 1) := 32.0;
    b1d (0, 2) := 33.0;
    a43        := vertcat (a3, b1d);
    b43 := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0),
            (7.0, 8.0, 9.0), (31.0, 32.0, 33.0));
    if a43 /= b43 then
      report "vertcat (3x3, 1x3)" severity error;
      print_matrix (a43);
    end if;
    a43 := vertcat (b1d, a3);
    b43 := ((31.0, 32.0, 33.0), (1.0, 2.0, 3.0),
            (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    if a43 /= b43 then
      report "vertcat (1x3, 3x3)" severity error;
      print_matrix (a43);
    end if;
    if not quiet then
      a63 := vertcat (a3, a36);
    end if;

    a63 := cat (1, a3, b3);
    b63 := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0),
            (11.0, 12.0, 13.0), (14.0, 15.0, 16.0), (17.0, 18.0, 19.0));
    if a63 /= b63 then
      report "cat (1, 3x3, 3x3)" severity error;
      print_matrix (a63);
    end if;
    b1d (0, 0) := 31.0;
    b1d (0, 1) := 32.0;
    b1d (0, 2) := 33.0;
    a43        := cat (1, a3, b1d);
    b43 := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0),
            (7.0, 8.0, 9.0), (31.0, 32.0, 33.0));
    if a43 /= b43 then
      report "cat (1, 3x3, 1x3)" severity error;
      print_matrix (a43);
    end if;
    a43 := cat (1, b1d, a3);
    b43 := ((31.0, 32.0, 33.0), (1.0, 2.0, 3.0),
            (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    if a43 /= b43 then
      report "cat (1, 1x3, 3x3)" severity error;
      print_matrix (a43);
    end if;
    if not quiet then
      b3  := cat (3, a3, a36);
      a63 := cat (1, a3, a36);
    end if;

    a3  := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b3  := ((11.0, 12.0, 13.0), (14.0, 15.0, 16.0), (17.0, 18.0, 19.0));
    a36 := cat (2, a3, b3);
    b36 := ((1.0, 2.0, 3.0, 11.0, 12.0, 13.0),
            (4.0, 5.0, 6.0, 14.0, 15.0, 16.0),
            (7.0, 8.0, 9.0, 17.0, 18.0, 19.0));
    if a36 /= b36 then
      report "cat (2, 3x3,3x3)" severity error;
      print_matrix (a36);
    end if;
    a1d (0, 0) := 21.0;
    a1d (1, 0) := 22.0;
    a1d (2, 0) := 23.0;
    a34        := cat (2, a3, a1d);
    b34 := ((1.0, 2.0, 3.0, 21.0),
            (4.0, 5.0, 6.0, 22.0),
            (7.0, 8.0, 9.0, 23.0));
    if a34 /= b34 then
      report "cat (2, 3x3, 1x3)" severity error;
      print_matrix(a34);
    end if;
    a34 := cat (2, a1d, a3);
    b34 := ((21.0, 1.0, 2.0, 3.0),
            (22.0, 4.0, 5.0, 6.0),
            (23.0, 7.0, 8.0, 9.0));
    if a34 /= b34 then
      report "cat (2, 1x3, 3x3)" severity error;
      print_matrix(a34);
    end if;
    if not quiet then
      a36 := cat (2, a3, a63);
    end if;




    shape_done <= true;
    wait;
  end process shapper;

  -- purpose: Kronecker test
  -- type   : combinational
  -- inputs :
  -- outputs:
  ktest : process is
    -- Test case from the Wikipedia article.
    constant va   : real_matrix := ((1.0, 2.0), (3.0, 4.0));  -- a
    constant vb   : real_matrix := ((0.0, 5.0), (6.0, 7.0));  -- b
    variable krop : real_matrix (0 to 3, 0 to 3);  -- kronecker product
    constant kropt : real_matrix := ((0.0, 5.0, 0.0, 10.0),
                                     (6.0, 7.0, 12.0, 14.0),
                                     (0.0, 15.0, 0.0, 20.0),
                                     (18.0, 21.0, 24.0, 28.0));

    constant vb3 : real_matrix := ((1.0, 2.0),
                                   (4.0, 5.0),
                                   (7.0, 8.0));
    variable krop3 : real_matrix (0 to 5, 0 to 3);  -- Kronecker (2x2, 3x2)
    constant kropt3 : real_matrix := ((1.0, 2.0, 2.0, 4.0),
                                      (4.0, 5.0, 8.0, 10.0),
                                      (7.0, 8.0, 14.0, 16.0),
                                      (3.0, 6.0, 4.0, 8.0),
                                      (12.0, 15.0, 16.0, 20.0),
                                      (21.0, 24.0, 28.0, 32.0));
  begin

    wait until start_ktest;
    krop := Kron (va, vb);
    if krop /= kropt then
      report "Kronecker product problem" severity error;
      print_matrix (krop, false);
      print_matrix (kropt, false);
    end if;
    krop3 := Kron (va, vb3);
    if krop3 /= kropt3 then
      report "Kronecker product problem 2x2 3x2" severity error;
      print_matrix (krop3, false);
      print_matrix (kropt3, false);
    end if;
    ktest_done <= true;
    wait;
  end process ktest;


  -- purpose: Kronecker test
  -- type   : combinational
  -- inputs :
  -- outputs:
  ktesti : process is
    -- Test case from the Wikipedia article.
    constant va   : integer_matrix := ((1, 2), (3, 4));  -- a
    constant vb   : integer_matrix := ((0, 5), (6, 7));  -- b
    variable krop : integer_matrix (0 to 3, 0 to 3);     -- kronecker product
    constant kropt : integer_matrix := ((0, 5, 0, 10),
                                        (6, 7, 12, 14),
                                        (0, 15, 0, 20),
                                        (18, 21, 24, 28));

    constant vb3 : integer_matrix := ((1, 2),
                                      (4, 5),
                                      (7, 8));
    variable krop3 : integer_matrix (0 to 5, 0 to 3);  -- Kronecker (2x2, 3x2)
    constant kropt3 : integer_matrix := ((1, 2, 2, 4),
                                         (4, 5, 8, 10),
                                         (7, 8, 14, 16),
                                         (3, 6, 4, 8),
                                         (12, 15, 16, 20),
                                         (21, 24, 28, 32));
  begin

    wait until start_ktesti;
    krop := Kron (va, vb);
    if krop /= kropt then
      report "Kronecker product problem" severity error;
      print_matrix (krop, false);
      print_matrix (kropt, false);
    end if;
    krop3 := Kron (va, vb3);
    if krop3 /= kropt3 then
      report "Kronecker product problem 2x2 3x2" severity error;
      print_matrix (krop3, false);
      print_matrix (kropt3, false);
    end if;
    ktesti_done <= true;
    wait;
  end process ktesti;

  submattst : process is
    constant avm : real_matrix := ((1.0, 2.0, 3.0),
                                   (4.0, 5.0, 6.0),
                                   (7.0, 8.0, 9.0));
    variable a, b, c    : real_matrix (0 to 8, 0 to 8);
    variable a3, b3     : m3x3;
    variable a4, b4, c4 : real_matrix (0 to 3, 0 to 3);
    variable a2, b2     : real_matrix (0 to 1, 0 to 1);
    variable av, bv     : real_vector (0 to 2);
    variable avmm, bvmm : real_matrix (0 to 2, 0 to 0);
    variable av4, bv4   : real_vector (0 to 3);
    variable bv4m       : real_matrix (0 to 3, 0 to 0);
    variable bv3m       : real_matrix (0 to 2, 0 to 0);
    variable a13        : real_matrix (0 to 2, 5 to 5);  -- 1D matrix
    variable a31        : real_matrix (5 to 5, 0 to 2);  -- 1D matrix
  begin
    wait until submat_test;
    a := repmat (avm, 3, 3);
    b := ((1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0),
          (4.0, 5.0, 6.0, 4.0, 5.0, 6.0, 4.0, 5.0, 6.0),
          (7.0, 8.0, 9.0, 7.0, 8.0, 9.0, 7.0, 8.0, 9.0),
          (1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0),
          (4.0, 5.0, 6.0, 4.0, 5.0, 6.0, 4.0, 5.0, 6.0),
          (7.0, 8.0, 9.0, 7.0, 8.0, 9.0, 7.0, 8.0, 9.0),
          (1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0),
          (4.0, 5.0, 6.0, 4.0, 5.0, 6.0, 4.0, 5.0, 6.0),
          (7.0, 8.0, 9.0, 7.0, 8.0, 9.0, 7.0, 8.0, 9.0));
    if a /= b then
      report "repmat problem" severity error;
      print_matrix (a);
    end if;
    a := blockdiag (avm, 3);
    b := ((1.0, 2.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
          (4.0, 5.0, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
          (7.0, 8.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 1.0, 2.0, 3.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 4.0, 5.0, 6.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 7.0, 8.0, 9.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.0, 3.0),
          (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 5.0, 6.0),
          (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 8.0, 9.0));
    if a /= b then
      report "blockdiag problem" severity error;
      print_matrix (a);
    end if;
    a3 := SubMatrix (b, 2, 2, 3, 3);    -- return a 3x3 matrix from x=2, y=2
    b3 := ((9.0, 0.0, 0.0),
           (0.0, 1.0, 2.0),
           (0.0, 4.0, 5.0));
    if a3 /= b3 then
      report "SubMatrix problem" severity error;
      print_matrix (a3);
    end if;

    BuildMatrix (avm, b, 6, 2);                  -- Put matrix avm at x=6, y=2
    a := ((1.0, 2.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
          (4.0, 5.0, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
          (7.0, 8.0, 9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 1.0, 2.0, 3.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 4.0, 5.0, 6.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 0.0, 7.0, 8.0, 9.0, 0.0, 0.0, 0.0),
          (0.0, 0.0, 1.0, 2.0, 3.0, 0.0, 1.0, 2.0, 3.0),
          (0.0, 0.0, 4.0, 5.0, 6.0, 0.0, 4.0, 5.0, 6.0),
          (0.0, 0.0, 7.0, 8.0, 9.0, 0.0, 7.0, 8.0, 9.0));
    if a /= b then
      report "BuildMatrix problem" severity error;
      print_matrix (b);
    end if;
    a3   := avm;
    avmm := SubMatrix (a3, 0, 1, av'length, 1);  -- return column 1
    bv   := (2.0, 5.0, 8.0);
    bvmm := reshape (bv, 3, 1);
    if avmm /= bvmm then
      report "SubMatrix column 1" severity error;
      print_matrix (avmm);
    end if;
    av := SubMatrix (a3, 1, 0, 1, av'length);    -- return row 1
    bv := (4.0, 5.0, 6.0);
    if av /= bv then
      report "SubMatrix row 1" severity error;
      print_vector (av);
    end if;
    a4 := ((1.0, 2.0, 3.0, 4.0),
           (5.0, 6.0, 7.0, 8.0),
           (9.0, 10.0, 11.0, 12.0),
           (13.0, 14.0, 15.0, 16.0));
    a2 := SubMatrix (a4, 1, 1, 2, 2);
    b2 := ((6.0, 7.0), (10.0, 11.0));
    if a2 /= b2 then
      report "SubMatrix (A, 1,1,2,2) issue " severity error;
      print_matrix (a2);
    end if;
    av := SubMatrix (a4, 1, 0, 1, 3);
    bv := (5.0, 6.0, 7.0);
    if av /= bv then
      report "SubMatrix (a4, 1,0, 1, 3) issue" severity error;
      print_vector (av);
    end if;

    -- Play with SubMatrix a bit
    a2 := ((7.0, 2.0), (3.0, 4.0));
    a4 := ones (a4'length(1), a4'length(2));
    BuildMatrix (a2, a4, 1, 1);
    b4 := ((1.0, 1.0, 1.0, 1.0),
           (1.0, 7.0, 2.0, 1.0),
           (1.0, 3.0, 4.0, 1.0),
           (1.0, 1.0, 1.0, 1.0));
    if a4 /= b4 then
      report "BuildMatrix problem" severity error;
      print_matrix (a4);
    end if;

    -- Example for BuildMatrix (return vector) and InsertColumn
    a4  := ones (a4'length(1), a4'length(2));
    av4 := (5.0, 6.0, 7.0, 8.0);
    bv4 := (10.0, 11.0, 12.0, 13.0);
    BuildMatrix (av4, a4, 2, 0);
    InsertColumn (bv4, a4, 0, 2);
    b4 := ((1.0, 1.0, 10.0, 1.0),
           (1.0, 1.0, 11.0, 1.0),
           (5.0, 6.0, 12.0, 8.0),
           (1.0, 1.0, 13.0, 1.0));
    if a4 /= b4 then
      report "BuildMatrix x/y problem" severity error;
      print_matrix (a4);
    end if;


    -- Do some matrix = vector boolean test
    bv := (5.0, 6.0, 7.0);
--    a13 (0, 5) := 5.0;
--    a13 (1, 5) := 6.0;
--    a13 (2, 5) := 7.0;
--    if a13 = bv then
--      null;
--    else
--      report "matrix = vector problem" severity error;
--    end if;
--    if bv = a13 then
--      null;
--    else
--      report "vector = matrix problem" severity error;
--    end if;
--    if a13 /= bv then
--      report "matrix /= vector problem" severity error;
--    end if;
--    if bv /= a13 then
--      report "vector /= matrix problem" severity error;
--    end if;
--    a13 (2, 5) := 9.0;
--    if a13 = bv then
--      report "matrix = vector (false) problem" severity error;
--    end if;
--    if bv = a13 then
--      report "vector = matrix (false) problem" severity error;
--    end if;
--    if a13 /= bv then
--      null;
--    else
--      report "matrix /= vector (false) problem" severity error;
--    end if;
--    if bv /= a13 then
--      null;
--    else
--      report "vector /= matrix (false) problem" severity error;
--    end if;

    a31 (5, 0) := 5.0;
    a31 (5, 1) := 6.0;
    a31 (5, 2) := 7.0;
    if a31 = bv then
      null;
    else
      report "matrix(1:3) = vector problem" severity error;
    end if;
    if bv = a31 then
      null;
    else
      report "vector = matrix(1:3) problem" severity error;
    end if;
    if a31 /= bv then
      report "matrix(1:3) /= vector problem" severity error;
    end if;
    if bv /= a31 then
      report "vector /= matrix(1:3) problem" severity error;
    end if;
    a31 (5, 1) := 5.0;
    if a31 = bv then
      report "matrix(1:3) = vector (false) problem" severity error;
    end if;
    if bv = a31 then
      report "vector = matrix(1:3) (false) problem" severity error;
    end if;
    if a31 /= bv then
      null;
    else
      report "matrix(1:3) /= vector (false) problem" severity error;
    end if;
    if bv /= a31 then
      null;
    else
      report "vector /= matrix(1:3) (false) problem" severity error;
    end if;
    if a4 = bv then
      report "4x4 = 3 compare problem" severity error;
    end if;
    if bv = a4 then
      report "3 = 4x4 compare problem" severity error;
    end if;
    if a4 /= bv then
      null;
    else
      report "4x4 /= 3 compare problem" severity error;
    end if;
    if bv /= a4 then
      null;
    else
      report "3 /= 4x4 compare problem" severity error;
    end if;
    av          := real_vector'(avm(0, 0), avm(0, 1), avm(0, 2));
    submat_done <= true;
    wait;
  end process;

  -- purpose: apply stims
  testeri : process is
    constant mones : integer_matrix := ((1, 1, 1),
                                        (1, 1, 1),
                                        (1, 1, 1));         --matrix
    constant am : integer_matrix := ((7, 3), (2, 5),
                                     (6, 8), (9, 0));
    constant bm : integer_matrix := ((7, 4, 9), (8, 1, 5));
    variable e1 : integer_matrix (0 to 1, 0 to 1);          -- bm * am
    constant ambmans : integer_matrix := ((73, 31, 78),
                                          (54, 13, 43),
                                          (106, 32, 94),
                                          (63, 36, 81));    -- am * bm
    variable ambm      : integer_matrix (0 to 3, 0 to 2);   -- am * bm
    constant amv       : integer_vector := (1, 4, 6);       -- integer_vector
    constant bmv       : integer_matrix := ((2, 3), (5, 8), (7, 9));
    constant amvbmvans : integer_vector := (64, 89);
    variable amvbmv    : integer_vector (0 to 1);           -- amv * bmv
    constant avm : integer_matrix := ((1, 2, 3),
                                      (4, 5, 6),
                                      (7, 8, 9));
    constant bvm        : integer_vector := (3, 5, 7);
    variable avmm, bvmm : integer_matrix (0 to 2, 0 to 0);
    variable avmbvm     : integer_matrix (0 to 2, 0 to 0);  -- matrix * vector
    constant avmbvmans  : integer_vector := (34, 79, 124);
    constant avv        : integer_vector := (-1, -2);
    variable avvm       : integer_matrix (0 to 1, 0 to 0);
    constant bvv        : integer_vector := (-1, 1, 5);
    variable avvbvv     : integer_matrix (0 to 1, 0 to 2);  -- matrix
    variable avvbvvy    : integer_matrix (0 to 1, 0 to 2);  -- matrix
    variable avvbvvt    : integer_matrix (0 to 2, 0 to 1);  -- matrix
    variable avvbvvx    : integer_matrix (0 to 2, 0 to 1);  -- matrix
    -- vector * vector (assuming left is a column not a row)
    constant avvbvvans : integer_matrix := ((1, -1, -5),
                                            (2, -2, -10));
    constant dtestx : integer_matrix := ((3, 2, 0, 1),
                                         (4, 0, 1, 2),
                                         (3, 0, 2, 1),
                                         (9, 2, 3, 1));
    variable mx5x5              : integer_matrix (0 to 4, 0 to 4);  -- 4x4
    variable submatx, submatans : integer_matrix (0 to 1, 0 to 1);
    variable iv2                : integer_vector (0 to 1);  -- integer vector
    variable a, b, c, d         : integer_matrix (0 to 2, 0 to 2);
    variable ap, bp, cp, dp     : integer_matrix (9 downto 7, 6 downto 4);
    variable av, bv, cv, dv     : integer_vector (0 to 2);
    variable avp, bvp, cvp, dvp : integer_vector (12 downto 10);
    variable av4, bv4           : integer_vector (0 to 3);
    variable a3x4               : integer_matrix (0 to 2, 0 to 3);
    variable m, n               : INTEGER;
    variable mm, nn             : integer_vector (0 to 0);
    variable i, j               : INTEGER;
    variable bool               : BOOLEAN;
  begin
    wait until testeri_start;
    -- Basic test  Make sure the compare functions work.
    -- Test ones and Zeros functions
    a    := ones (3, 3);
    bool := (mones = a);
    if not bool then
      report "mones = ones(a)" severity error;
    end if;
    bool := (mones /= a);
    if bool then
      report "mones /= ones(a)" severity error;
    end if;
    a    := zeros (3, 3);
    bool := (mones = a);
    if bool then
      report "mones = zeros(a)" severity error;
    end if;
    bool := (mones /= a);
    if not bool then
      report "mones /= zeros(a)" severity error;
    end if;
    -- Test identity (eye) function
    a := eye (3, 3);
    b := ((1, 0, 0), (0, 1, 0), (0, 0, 1));
    if a /= b then
      report "eye not working" severity error;
      print_matrix (a);
    end if;
    bool := (a = mones);
    if bool then
      report "identity = ones returned true" severity error;
    end if;
    a  := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    ap := a;
    -- missed up matrix index
    if ap /= a then
      report "Index test, should be equal" severity error;
      print_matrix (ap, true);
    end if;
    bp := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    if bp /= a then
      report "Index test, should be equal" severity error;
      print_matrix (bp, true);
    end if;
    -- Create a matrix that is identical to another, but with the last
    -- row missing.
    a := ((73, 31, 78),
          (54, 13, 43),
          (106, 32, 94));
    bool := (a = ambmans);  -- Note this line give a compile warning.
    if bool then
      report "Compare - extra row not detected" severity error;
    end if;
    -- Test multiply
    ambm := am * bm;
    if ambm /= ambmans then
      report "matrix multiply problem" severity error;
      print_matrix (ambm);
    end if;
    -- vector * matrix
    amvbmv := amv * bmv;
    if amvbmv /= amvbmvans then
      report "vector * matrix problem" severity error;
      print_vector (amvbmv);
      print_vector (amvbmvans);
    end if;
    -- Matrix * vector
    bvmm   := transpose (bvm);
    avmbvm := avm * bvmm;
    if avmbvm /= reshape (avmbvmans, 3, 1) then
      report "matrix * vector problem" severity error;
      print_matrix (avmbvm);
      print_vector (avmbvmans);
    end if;
    -- vector * vector (assuming left is a column not a row)
--   avvm := reshape (avv, 3, 1);
--    avvbvv := avvm * bvv;
--    if avvbvv /= avvbvvans then
--      report "vector * vector problem" severity error;
--      print_matrix (avvbvv, true);
--    end if;
    -- vector * vector (assuming left is row, right is column)
    bvmm  := transpose (bvv);
    mm    := bvm * bvmm;
    nn(0) := 37;
    if mm /= nn then
      report "vector * vector = real problem, result was " & INTEGER'image (m)
        severity error;
    end if;

    a := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    b := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    c := a * b;
    d := ((30, 36, 42), (66, 81, 96), (102, 126, 150));
    if d /= c then
      report "matrix * matrix 3x3" severity error;
      print_matrix (c, true);
      print_matrix (d, true);
    end if;
    a  := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    ap := a;
    bp := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    cp := ap * bp;
    dp := ((30, 36, 42), (66, 81, 96), (102, 126, 150));
    -- Need to reverse the order of this matrix to compare it.
    b  := reorder (dp);
    if b /= cp then
      report "matrix * matrix odd range problem" severity error;
      print_matrix (cp, true);
      print_matrix (b, true);
    end if;

    a    := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    bv   := (2, 3, 4);
    bvmm := transpose (bv);
    avmm := a * bvmm;
    dv   := (20, 47, 74);
    bvmm := reshape (dv, 3, 1);
    if avmm /= bvmm then
      report "matrix * vector problem" severity error;
      print_matrix (avmm);
    end if;
    ap   := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    bvp  := (2, 3, 4);
    bvmm := transpose (bvp);
    avmm := ap * bvmm;
    dvp  := (20, 47, 74);               -- Backward because of "downto"
    bvmm := reshape (dvp, 3, 1);
    if avmm /= bvmm then
      report "matrix * vector problem odd range" severity error;
      print_matrix (avmm);
    end if;

    a  := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    bv := (2, 3, 4);
    cv := bv * a;
    dv := (42, 51, 60);
    if cv /= dv then
      report "vector * matrix problem" severity error;
      print_vector (cv);
    end if;
    ap  := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    -- ap  := reorder (ap);                -- flip it to make it work.
    bvp := (2, 3, 4);
    cvp := bvp * ap;
    dvp := (60, 51, 42);                -- backwards because of "downto"
    if cvp /= dvp then
      report " vector * matrix problem odd range" severity error;
      print_vector (cvp);
    end if;

    if not QUIET then
      -- Cause some errors
      report "Expect 3 multiply errors here" severity note;
      e1     := bm * am;                -- 2x3 * 4x2
      a3x4   := bmv * av4;              -- 3x2 * 4
      amvbmv := av4 * bmv;              -- 4 * 3x2
    end if;

    iv2 := size (ambmans);
    assert iv2(0) = 4 report "Size returned the wrong Y dimension "
      & INTEGER'image(iv2(0)) severity error;
    assert iv2(1) = 3 report "Size returned the wrong X dimension "
      & INTEGER'image(iv2(1)) severity error;

    av   := (1, 2, 3);
    bv   := (4, 5, 6);
    avmm := reshape (av, 3, 1);
    c    := avmm * bv;
    d    := ((4, 5, 6), (8, 10, 12), (12, 15, 18));
    if c /= d then
      report " vector * vector 3x3 problem" severity error;
      print_matrix (c);
    end if;
    avp  := (1, 2, 3);
    bvp  := (4, 5, 6);
    avmm := reshape (avp, 3, 1);
    c    := avmm * bvp;
    a    := rot90 (d, 2);               -- mirror because of "downto"
    if c /= a then
      report " vector * vector problem odd range" severity error;
      print_matrix (c);
    end if;
    -- Matrix * integer
    a := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    m := 3;
    b := m * a;
    c := ((3, 6, 9), (12, 15, 18), (21, 24, 27));
    if c /= b then
      report "integer * Matrix problem" severity error;
      print_matrix (b);
    end if;
    b := a * m;
    if c /= b then
      report "Matrix * integer problem" severity error;
      print_matrix (b);
    end if;
    av := (2, 3, 4);
    m  := 10;
    bv := av * m;
    cv := (20, 30, 40);
    if bv /= cv then
      report "Vector * integer problem" severity error;
      print_vector (bv);
    end if;
    bv := m * av;
    if bv /= cv then
      report "integer * vector problem" severity error;
      print_vector (bv);
    end if;

    av := (1, 2, 3);
    bv := (4, 5, 6);
    cv := av + bv;
    dv := (5, 7, 9);
    if cv /= dv then
      report " vector + vector problem" severity error;
      print_vector (cv);
    end if;

    avp := (1, 2, 3);
    bvp := (4, 5, 6);
    cvp := avp + bvp;
    dvp := (9, 7, 5);                   -- Downto reversed order
    if cv /= dv then
      report " vector + vector problem odd range" severity error;
      print_vector (cvp);
    end if;

    if not QUIET then
      report "Expect 3 addition errors here" severity note;
      a  := mones + bm;                 -- 3x3 + 3x2
      a  := mones + dtestx;             -- 3x3 + 4x4
      av := avmbvmans + avv;
    end if;

    av := (1, 2, 3);
    bv := (4, 5, 6);
    cv := av - bv;
    dv := (-3, -3, -3);
    if cv /= dv then
      report " vector - vector problem" severity error;
      print_vector (cv);
    end if;
    av := (1, 2, 3);
    bv := (4, 5, 6);
    av := times (av, bv);
    bv := (4, 10, 18);
    if av /= bv then
      report " vector .* vector (times) problem" severity error;
      print_vector (av);
    end if;

    avp := (1, 2, 3);
    bvp := (4, 5, 6);
    avp := times (avp, bvp);
    bvp := (18, 10, 4);                 -- reversed because of "downto"
    if avp /= bvp then
      report " vector .* vector (times) problem odd range" severity error;
      print_vector (avp);
    end if;

    -- Addition and subtraction
    a := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    b := transpose(a);
    c := a + b;
    d := ((2, 6, 10), (6, 10, 14), (10, 14, 18));
    if d /= c then
      report "matrix + matrix problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    ap := a;
    bp := b;
    cp := ap + bp;
    d  := ((2, 6, 10), (6, 10, 14), (10, 14, 18));
    if d /= reorder(cp) then
      report "matrix + matrix odd range problem" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    c := a - b;
    d := ((0, -2, -4), (2, 0, -2), (4, 2, 0));
    if d /= c then
      report "matrix - matrix problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    ap := a;
    bp := b;
    cp := ap - bp;
    d  := ((0, -2, -4), (2, 0, -2), (4, 2, 0));
    if d /= reorder(cp) then
      report "matrix - matrix odd range problem" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    if not QUIET then
      report "Expect 3 subtraction errors here" severity note;
      a  := mones - bm;                 -- 3x3 + 3x2
      a  := mones - dtestx;             -- 3x3 + 4x4
      av := avmbvmans - avv;
    end if;
    -- element by element multiply
    a := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    b := transpose(a);
    c := times(a, b);
    d := ((1, 8, 21), (8, 25, 48), (21, 48, 81));
    if d /= c then
      report "times(matrix, matrix) problem" severity error;
      print_matrix (c);
      print_matrix (d);
    end if;
    cp := times (ap, bp);
    d  := ((1, 8, 21), (8, 25, 48), (21, 48, 81));
    if d /= reorder(cp) then
      report "times(matrix, matrix) problem odd range" severity error;
      print_matrix (cp);
      print_matrix (d);
    end if;
    if not QUIET then
      report "Expect 3 times errors here" severity note;
      a  := times(mones, bm);           -- 3x3 + 3x2
      a  := times(mones, dtestx);       -- 3x3 + 4x4
      av := times(avmbvmans, avv);
    end if;
    -- transpose
    a := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    b := transpose(a);
    c := ((1, 4, 7), (2, 5, 8), (3, 6, 9));
    if b /= c then
      report "Transpose problem" severity error;
      print_matrix (b);
      print_matrix (c);
    end if;

    avvbvvt := transpose (avvbvvans);
    avvbvvx := ((1, 2), (-1, -2), (-5, -10));
    if avvbvvt /= avvbvvx then
      report "2x3 transpose problem" severity error;
      print_matrix (avvbvvt);
    end if;
    avvbvv  := abs (avvbvvans);
    avvbvvy := ((1, 1, 5), (2, 2, 10));
    if avvbvv /= avvbvvy then
      report "abs(matrix) problem" severity error;
      print_matrix (avvbvv);
    end if;
    av := (1, -2, -9);
    bv := abs (av);
    cv := (1, 2, 9);
    if bv /= cv then
      report "abs(vector) problem" severity error;
      print_vector (bv);
    end if;

    -- SubMatrix test
    a         := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    submatx   := exclude (a, 1, 1);
    submatans := ((1, 3), (7, 9));
    if submatx /= submatans then
      report "SubMatrix(1,1) problem" severity error;
      print_matrix (submatx);
    end if;
    submatx   := exclude (a, 2, 0);
    submatans := ((2, 3), (5, 6));
    if submatx /= submatans then
      report "SubMatrix(2,0) problem" severity error;
      print_matrix (submatx);
    end if;
    submatx   := exclude (a, 0, 2);
    submatans := ((4, 5), (7, 8));
    if submatx /= submatans then
      report "SubMatrix(0,2) problem" severity error;
      print_matrix (submatx);
    end if;
    ap        := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    submatx   := exclude (ap, 7, 4);
    submatans := ((5, 4), (2, 1));
    if submatx /= submatans then
      report "SubMatrix(7,4) odd range problem" severity error;
      print_matrix (submatx);
    end if;

    -- Determinant test
    submatx := ((1, 2), (4, 3));
    m       := det (submatx);
    if m /= -5 then
      report "Determinant -5 /= "& INTEGER'image(m) severity error;
      print_matrix(submatx);
    end if;
    submatx := ((3, 2), (5, 2));
    m       := det (submatx);
    if m /= -4 then
      report "Determinant -4 /= "& INTEGER'image(m) severity error;
      print_matrix(submatx);
    end if;
    a := ((1, 3, 2), (4, 1, 3), (2, 5, 2));
    m := det (a);
    if m /= 17 then
      report "Determinant 17 /= "& INTEGER'image(m) severity error;
      print_matrix(a);
    end if;
    ap := ((1, 3, 2), (4, 1, 3), (2, 5, 2));
    m  := det (ap);
    if m /= 17 then
      report "Determinant odd range 17 /= "& INTEGER'image(m) severity error;
      print_matrix(ap);
    end if;
    -- Try a larger matrix
    m := det (dtestx);                  -- 4x4 matrix
    if m /= 24 then
      report "Determinant 24 /= "& INTEGER'image(m) severity error;
      print_matrix(dtestx);
    end if;
    -- from http://answers.yahoo.com/question/index?qid=20070123154335AAIVKZd
    mx5x5 := ((5, 2, 0, 0, -2),
              (0, 1, 4, 3, 2),
              (0, 0, 2, 6, 3),
              (0, 0, 3, 4, 1),
              (0, 0, 0, 0, 2));
    m := det (mx5x5);
    if m /= -100 then
      report "Determinant 5x5 problem = "& INTEGER'image(m) severity error;
    end if;
    if not quiet then
      report "Expect 2 DET/inv error here" severity note;
      m := det (avvbvvans);             -- Not square
    end if;

    -- dot product
    m := dot (amv, bvm);
    assert m = 65
      report "Dot product problem, expected 65, and got " & INTEGER'image(m)
      severity error;
    m := dot (amv, bvv);
    assert m = 33
      report "Dot product problem, expected 33, and got " & INTEGER'image(m)
      severity error;
    if not quiet then
      report "Expect 1 dot error here" severity note;
      m := dot (amv, av4);              -- Not the same length
    end if;

    -- Test sum and trace
    m := sum (amv);
    if m /= 11 then
      report "sum (vector) problem, result was " & INTEGER'image(m)
        severity error;
    end if;

    m := trace (ambmans);
    if m /= 180 then
      report "trace problem, result was " & INTEGER'image(m)
        severity error;
    end if;

    m := trace (am);
    if m /= 12 then
      report "trace (2) problem, result was " & INTEGER'image(m)
        severity error;
    end if;

    av := sum (ambmans, 1);             -- Sum along Y
    bv := (296, 112, 296);
    if av /= bv then
      report "Sum (x,2) problem" severity error;
      print_vector (av);
    end if;

    av4 := sum (ambmans, 2);            -- Sum along X
    bv4 := (182, 110, 232, 180);
    if av4 /= bv4 then
      report "Sum (x,1) problem" severity error;
      print_vector (av4);
    end if;

    av := (8, 1, 6);
    m  := prod (av);
    if m /= 48 then
      report "prod (vector) problem "& INTEGER'image(m) severity error;
    end if;

    a := ((8, 1, 6),
          (3, 5, 7),
          (4, 9, 2));
    av := prod(a);
    bv := (96, 45, 84);
    if av /= bv then
      report "prod(1) problem" severity error;
      print_vector (av);
    end if;
    av := prod(a, 2);
    bv := (48, 105, 72);
    if av /= bv then
      report "prod(2) problem" severity error;
      print_vector (av);
    end if;

    if not quiet then
      report "Expect 3 sum/prod dim errors here" severity note;
      av := sum (a, 3);
      av := prod (a, 3);
      b  := flipdim (a, 3);
    end if;

    -- Flip a few Matrices...
    b := fliplr (avm);
    c := ((3, 2, 1),
          (6, 5, 4),
          (9, 8, 7));
    if b /= c then
      report "Fliplr problem " severity error;
      print_matrix (b);
    end if;

    b := flipdim (avm, 2);
    c := ((3, 2, 1),
          (6, 5, 4),
          (9, 8, 7));
    if b /= c then
      report "Flipdim 2 problem " severity error;
      print_matrix (b);
    end if;


    b := flipup (avm);
    c := ((7, 8, 9),
          (4, 5, 6),
          (1, 2, 3));
    if b /= c then
      report "Flipup problem " severity error;
      print_matrix (b);
    end if;

    b := flipdim (avm, 1);
    c := ((7, 8, 9),
          (4, 5, 6),
          (1, 2, 3));
    if b /= c then
      report "Flipdim 1 problem " severity error;
      print_matrix (b);
    end if;


    b := rot90 (avm);
    c := ((3, 6, 9),
          (2, 5, 8),
          (1, 4, 7));
    if b /= c then
      report "rot90 problem " severity error;
      print_matrix (b);
    end if;

    b := rot90 (avm, 2);
    c := ((9, 8, 7),
          (6, 5, 4),
          (3, 2, 1));
    if b /= c then
      report "rot90 2 problem " severity error;
      print_matrix (b);
    end if;

    b := rot90 (avm, 3);
    c := ((7, 4, 1),
          (8, 5, 2),
          (9, 6, 3));
    if b /= c then
      report "rot90 3 problem " severity error;
      print_matrix (b);
    end if;

    a := tril(avm);
    c := ((0, 0, 0),
          (4, 0, 0),
          (7, 8, 0));
    if a /= c then
      report "tril problem" severity error;
      print_matrix (a);
    end if;

    av := diag (avm);
    bv := (1, 5, 9);
    if av /= bv then
      report "diag problem" severity error;
      print_vector (av);
    end if;

    av := (5, 6, 7);
    a  := diag (av);
    b := ((5, 0, 0),
          (0, 6, 0),
          (0, 0, 7));
    if a /= b then
      report "diag(vector) problem" severity error;
      print_matrix (a);
    end if;

    a := blkdiag (bvv);
    b := ((-1, 0, 0),
          (0, 1, 0),
          (0, 0, 5));
    if a /= b then
      report "blkdiag problem" severity error;
      print_matrix (a);
    end if;

    a := triu (avm);
    c := ((0, 2, 3),
          (0, 0, 6),
          (0, 0, 0));
    if a /= c then
      report "triu problem" severity error;
      print_matrix (a);
    end if;
    av := (1, 2, 3);
    bv := (4, 5, 6);
    cv := cross (av, bv);
    dv := (-3, 6, -3);
    if cv /= dv then
      report "Cross product problem" severity error;
      print_vector (cv);
    end if;
    a := avm;
    b := rot90(avm, 2);
    c := cross (a, b);
    d := ((-30, -30, -30),
          (60, 60, 60),
          (-30, -30, -30));
    if c /= d then
      report "Cross product (matrix) problem" severity error;
      print_matrix (c);
    end if;


    av := (1, 2, 3);                    -- 3*x^2 + 2*x + 1
    bv := (5, 7, 9);
    cv := polyval (av, bv);
    dv := (86, 162, 262);
    if cv /= dv then
      report "Polyval problem" severity error;
      print_vector (cv);
    end if;

    -- Matrix raised to a power.
    b := avm**2;
    c := ((30, 36, 42),
          (66, 81, 96),
          (102, 126, 150));
    if b /= c then
      report "matrix ** 2 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**1;
    if b /= avm then
      report "matrix ** 1 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**3;
    c := ((468, 576, 684),
          (1062, 1305, 1548),
          (1656, 2034, 2412));
    if b /= c then
      report "matrix ** 3 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**4;
    c := ((7560, 9288, 11016),
          (17118, 21033, 24948),
          (26676, 32778, 38880));
    if b /= c then
      report "matrix ** 4 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**5;
    c := ((121824, 149688, 177552),
          (275886, 338985, 402084),
          (429948, 528282, 626616));
    if b /= c then
      report "matrix ** 5 problem" severity error;
      print_matrix (b);
    end if;

    b := avm**0;
    c := ones(3, 3);
    if b /= c then
      report "matrix ** 0 problem" severity error;
      print_matrix (b);
    end if;

    -- Test "pow" function
    av := (2, 5, 9);
    bv := repmat (2, 1, 3);
    cv := pow(av, bv);
    dv := (4, 25, 81);
    if cv /= dv then
      report "pow (vector, vector)" severity error;
      print_vector (cv);
    end if;
    a := ((8, 1, 6),
          (3, 5, 7),
          (4, 9, 2));
    b := repmat (2, 3, 3);
    c := pow(a, b);
    d := ((64, 1, 36),
          (9, 25, 49),
          (16, 81, 4));
    if c /= d then
      report "pow (3x3,3x3)" severity error;
      print_matrix(c);
    end if;


    testeri_done <= true;
    wait;
  end process testeri;

  -- purpose: test the string functions
  test_strings : process is
    variable a, b, c    : real_matrix (0 to 2, 0 to 2);  -- real matrix
    variable av, bv, cv : real_vector (0 to 2);          -- real vector
    variable l          : LINE;                          -- line variable
    variable good       : BOOLEAN;                       -- for reads
  begin
    wait until start_tstring;
    l  := new STRING'("1.0 2.0 3.0");
    read (l, av);
    bv := (1.0, 2.0, 3.0);
    if av /= bv then
      report "real vector Read no boolean" severity error;
      print_vector (av);
    end if;
    deallocate (L);
    bv := (1.0, 2.0, 3.0);
    write (L, to_string(bv));
    read (l, av);
    if av /= bv then
      report "real vector to_string/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_vector (av);
    end if;
    deallocate (L);
    bv := (1.0, 2.0, 3.0);
    write (L, bv);
    read (l, av);
    if av /= bv then
      report "real vector write/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_vector (av);
    end if;
    deallocate (L);
    bv := (1.0, 2.0, 3.0);
    write (L, bv);
    read (l, av, good);
    if av /= bv or not good then
      report "real vector write/Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_vector (av);
    end if;
    deallocate (L);
    l := new STRING'("1.0 x.0 3.0");
    read (l, av, good);
    if good then
      report "real vector Read good = " & BOOLEAN'image(good)
        severity error;
      print_vector (av);
    end if;
    deallocate (L);

    -- Real matrix test
    l := new STRING'("1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0");
    read (L, a);
    b := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    if a /= b then
      report "real matrix Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    l := new STRING'("((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0))");
    read (L, a);
    b := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    if a /= b then
      report "real matrix Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    b := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    write (L, to_string(b));
    read (L, a);
    if a /= b then
      report "real matrix to_string/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    b := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    write (L, b);
    read (L, a);
    if a /= b then
      report "real matrix write/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    b := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    write (L, b);
    read (l, a, good);
    if a /= b or not good then
      report "real matrix write/Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    -- Some bad reads
    l := new STRING'("1.0 2.0 3.0 4.0 x.0 6.0 7.0 8.0 9.0");
    read (l, a, good);
    if good then
      report "real matrix Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    l := new STRING'("1.0 x.0 3.0");
    read (l, a, good);
    if good then
      report "real matrix Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);

    tstring_done <= true;
    wait;
  end process test_strings;

  -- purpose: test the string functions
  test_istrings : process is
    variable a, b, c    : integer_matrix (0 to 2, 0 to 2);  -- real matrix
    variable av, bv, cv : integer_vector (0 to 2);          -- real vector
    variable l          : LINE;                             -- line variable
    variable good       : BOOLEAN;                          -- for reads
  begin
    wait until start_itstring;
    l  := new STRING'("1 2 3");
    read (l, av);
    bv := (1, 2, 3);
    if av /= bv then
      report "integer vector Read no boolean" severity error;
      print_vector (av);
    end if;
    deallocate (L);
    bv := (1, 2, 3);
    write (L, to_string(bv));
    read (l, av);
    if av /= bv then
      report "integer vector to_string/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_vector (av);
    end if;
    deallocate (L);
    bv := (1, 2, 3);
    write (L, bv);
    read (l, av);
    if av /= bv then
      report "integer vector write/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_vector (av);
    end if;
    deallocate (L);
    bv := (1, 2, 3);
    write (L, bv);
    read (l, av, good);
    if av /= bv or not good then
      report "integer vector write/Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_vector (av);
    end if;
    deallocate (L);
    l := new STRING'("1 x 3");
    read (l, av, good);
    if good then
      report "integer vector Read good = " & BOOLEAN'image(good)
        severity error;
      print_vector (av);
    end if;
    deallocate (L);

    -- Integer matrix test
    l := new STRING'("1 2 3 4 5 6 7 8 9");
    read (L, a);
    b := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    if a /= b then
      report "integer matrix Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    l := new STRING'("((1, 2, 3), (4, 5, 6), (7, 8, 9))");
    read (L, a);
    b := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    if a /= b then
      report "integer matrix Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    b := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    write (L, to_string(b));
    read (L, a);
    if a /= b then
      report "integer matrix to_string/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    b := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    write (L, b);
    read (L, a);
    if a /= b then
      report "integer matrix write/Read no BOOLEAN " severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    b := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    write (L, b);
    read (l, a, good);
    if a /= b or not good then
      report "integer matrix write/Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    -- Some bad reads
    l := new STRING'("1 2 3 4 x 6 7 8 9");
    read (l, a, good);
    if good then
      report "integer matrix Read good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);
    l := new STRING'("1 x 3");
    read (l, a, good);
    if good then
      report "integer matrix Read2 good = " & BOOLEAN'image(good)
        severity error;
      writeline (output, L);
      print_matrix (a);
    end if;
    deallocate (L);


    itstring_done <= true;
    wait;
  end process test_istrings;

  -- purpose: Mixed integer_matrix and real_matrix test
  mixediandr : process is
    variable ar, br, cr, dr     : real_matrix (0 to 2, 0 to 2);  -- real matrix
    variable avr, bvr, cvr, dvr : real_vector (0 to 2);     -- real_vector
    variable ai, bi, ci, di     : integer_matrix (0 to 2, 0 to 2);  -- integer matrix
    variable avi, bvi, cvi, dvi : integer_vector (0 to 2);  -- integer vector
    variable ai2 : integer_matrix (0 to 1, 0 to 1);  -- 2x2 matrix
  begin

    wait until mixed_start;

    avi := (1, 2, 3);
    avr := to_real(avi);
    bvr := (1.0, 2.0, 3.0);
    if avr /= bvr then
      report "to_real(vector)" severity error;
      print_vector(avr);
    end if;
    cvr := round (bvr);
    if cvr /= bvr then
      report "round(vector)" severity error;
      print_vector (cvr);
    end if;

    ai := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    ar := to_real (ai);
    br := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    if ar /= br then
      report "to_real(matrix)" severity error;
      print_matrix(ar);
    end if;
    cr := round (br);
    if cr /= br then
      report "round(matrix)" severity error;
      print_matrix (cr);
    end if;
    avr := (1.0, 2.0, 3.0);
    avi := to_integer (avr);
    bvi := (1, 2, 3);
    if avi /= bvi then
      report "to_integer(vector)" severity error;
      print_vector(avi);
    end if;
    ar := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    ai := to_integer (ar);
    bi := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    if ai /= bi then
      report "to_integer(matrix)" severity error;
      print_matrix(ai);
    end if;
    -- Make sure that rounding works
    avr := (1.1, 1.5, 1.7);
    avi := to_integer (avr);
    bvi := (1, 2, 2);
    if avi /= bvi then
      report "to_integer (vector, round)" severity error;
      print_vector (avi);
      print_vector (avr);
    end if;
    cvr := round (avr);
    bvr := (1.0, 2.0, 2.0);
    if cvr /= bvr then
      report "round(uneven vector)" severity error;
      print_vector (cvr);
    end if;
    ar := ((1.1, 1.5, 1.7), (2.4, 2.5, 2.6), (-1.5, -2.5, -3.9));
    ai := to_integer (ar);
    bi := ((1, 2, 2), (2, 3, 3), (-2, -3, -4));
    if ai /= bi then
      report "to_integer(matrix, round)" severity error;
      print_matrix(ai);
      print_matrix(ar);
    end if;
    cr := round (ar);
    br := ((1.0, 2.0, 2.0), (2.0, 3.0, 3.0), (-2.0, -3.0, -4.0));
    if cr /= br then
      report "round(uneven matrix)" severity error;
      print_matrix (cr);
    end if;
    -- Mixed multiply overloads, we only need to check the matrix/matrix
    -- and vector/vector, because of the strong typing in VHDL.
    -- With a matrix, a*b /= b*a unless a = b
    ai := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    br := ((9.0, 8.0, 7.0), (6.0, 5.0, 4.0), (3.0, 2.0, 1.0));
    cr := ai * br;
    dr := ((30.0, 24.0, 18.0), (84.0, 69.0, 54.0), (138.0, 114.0, 90.0));
    if dr /= cr then
      report "imatrix * rmatrix 3x3" severity error;
      print_matrix (cr, true);
    end if;
    ar := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    bi := ((9, 8, 7), (6, 5, 4), (3, 2, 1));
    cr := ar * bi;
    dr := ((30.0, 24.0, 18.0), (84.0, 69.0, 54.0), (138.0, 114.0, 90.0));
    if dr /= cr then
      report "rmatrix * imatrix 3x3" severity error;
      print_matrix (cr, true);
    end if;

    ai := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    br := ((9.0, 8.0, 7.0), (6.0, 5.0, 4.0), (3.0, 2.0, 1.0));
    cr := ai + br;
    dr := ((10.0, 10.0, 10.0), (10.0, 10.0, 10.0), (10.0, 10.0, 10.0));
    if dr /= cr then
      report "imatrix + rmatrix 3x3" severity error;
      print_matrix (cr, true);
    end if;
    ar := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    bi := ((9, 8, 7), (6, 5, 4), (3, 2, 1));
    cr := ar + bi;
    if dr /= cr then
      report "rmatrix + imatrix 3x3" severity error;
      print_matrix (cr, true);
    end if;
    ai := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    br := ((9.0, 8.0, 7.0), (6.0, 5.0, 4.0), (3.0, 2.0, 1.0));
    cr := ai - br;
    dr := ((-8.0, -6.0, -4.0), (-2.0, 0.0, 2.0), (4.0, 6.0, 8.0));
    if dr /= cr then
      report "imatrix - rmatrix 3x3" severity error;
      print_matrix (cr, true);
    end if;
    ar := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    bi := ((9, 8, 7), (6, 5, 4), (3, 2, 1));
    cr := ar - bi;
    if dr /= cr then
      report "rmatrix - imatrix 3x3" severity error;
      print_matrix (cr, true);
    end if;

    ai := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    br := transpose (to_real(ai));
    cr := times(ai, br);
    dr := ((1.0, 8.0, 21.0), (8.0, 25.0, 48.0), (21.0, 48.0, 81.0));
    if dr /= cr then
      report "times(imatrix, rmatrix) problem" severity error;
      print_matrix (cr);
    end if;
    ar := to_real (ai);
    bi := to_integer (br);
    cr := times(ar, bi);
    if dr /= cr then
      report "times(rmatrix, imatrix) problem" severity error;
      print_matrix (cr);
    end if;

    ai := ((1, 2, 3), (4, 5, 6), (7, 8, 9));
    bi := transpose (ai);
    dr := ((1.0, 0.5, 3.0/7.0), (2.0, 1.0, 6.0/8.0), (7.0/3.0, 8.0/6.0, 1.0));
    cr := rdivide (ai, bi);
    if dr /= cr then
      report "rdivide(imatrix, imatrix)" severity error;
      print_matrix (cr);
    end if;
    br := to_real (bi);
    cr := rdivide (ai, br);
    if dr /= cr then
      report "rdivide(imatrix, rmatrix)" severity error;
      print_matrix (cr);
    end if;
    ar := to_real (ai);
    cr := rdivide (ar, bi);
    if dr /= cr then
      report "rdivide(rmatrix, imatrix)" severity error;
      print_matrix (cr);
    end if;

    ar := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 0.0));
    br := ((2.0, 4.0, 6.0), (0.0, 3.0, 7.0), (9.0, 8.0, 1.0));
    ai := to_integer(ar);
    bi := to_integer(br);
    dr := ((0.5, 0.0, 0.0), (3.6875, -2.25, -0.375), (-8.3125, 6.75, 2.625));
    cr := ai / bi;
    if cr /= dr then
      report "imatrix / imatrix" severity error;
      print_matrix (cr);
    end if;
    cr := ar / bi;
    if cr /= dr then
      report "rmatrix / imatrix" severity error;
      print_matrix (cr);
    end if;
    cr := ai / br;
    if cr /= dr then
      report "imatrix / rmatrix" severity error;
      print_matrix (cr);
    end if;
    cr := mrdivide (ai, bi);
    if cr /= dr then
      report "mrdivide (imatrix, imatrix)" severity error;
      print_matrix (cr);
    end if;
    cr := mrdivide (ar, bi);
    if cr /= dr then
      report "mrdivide (rmatrix, imatrix)" severity error;
      print_matrix (cr);
    end if;
    cr := mrdivide (ai, br);
    if cr /= dr then
      report "mrdivide (imatrix, rmatrix)" severity error;
      print_matrix (cr);
    end if;
    ar := ones (ar'length(1), ar'length(2));
    ai2 := ((6, 7), (8, 9));
    BuildMatrix (ai2, ar, 1, 1);
    br := ((1.0, 1.0, 1.0), (1.0, 6.0, 7.0), (1.0, 8.0, 9.0));
    if ar /= br then
      report "BuildMatrix (int, real)" severity error;
      print_matrix (ar);
    end if;

    mixed_done <= true;
    wait;
  end process mixediandr;


  -- purpose: Zero size matrix test

  zmat : process is
    ---------------------------------------------------------------------------
    -- These null matrix definitions will cause warnings with many tools.
    -- In Modeltech they can be suppressed with the -nowarn 3 option.
    ---------------------------------------------------------------------------
    variable az3, bz3   : real_matrix (1 to 0, 0 to 2);     -- null in X
    variable az1, bz1   : real_matrix (1 to 0, 0 to 0);     -- null in X, 1
    variable cz3, dz3   : real_matrix (0 to 2, 1 to 0);     -- null in Y
    variable cz1, dz1   : real_matrix (0 to 0, 1 to 0);     -- null in Y, 1
    variable acz, bdz   : real_matrix (1 to 0, 1 to 0);     -- null in X and Y
    variable avz, bvz   : real_vector (1 to 0);     -- null vector
    variable av3, bv3   : real_vector (0 to 2);     -- 1 vector
    variable av1, bv1   : real_vector (0 to 0);     -- 1 vector
    variable a, b, c    : real_matrix (0 to 2, 0 to 2);
    variable a1, b1, c1 : real_matrix (0 to 0, 0 to 0);
    variable k1         : real_matrix (1 to 0, 0 to 8);     -- Kron return
    variable i2, i2b    : integer_vector (0 to 1);  -- from size function
    variable m, n       : REAL;
    variable i, j       : INTEGER;
    variable az3i       : integer_matrix (1 to 0, 0 to 2);  -- null in X
    variable cz3i       : integer_matrix (0 to 2, 1 to 0);  -- null in Y
    variable aczi       : integer_matrix (1 to 0, 1 to 0);  -- null in X and Y
    variable avzi       : integer_vector (1 to 0);  -- null vector
  begin
    wait until start_zmat;

    -- Test "isempty"
    assert isempty(avz)
      report "isempty(0) returned false" severity error;
    assert isempty(az1)
      report "isempty(0,1) returned false" severity error;
    assert isempty(az3)
      report "isempty(0,3) returned false" severity error;
    assert isempty(cz1)
      report "isempty(1,0) returned false" severity error;
    assert isempty(cz3)
      report "isempty(1,0) returned false" severity error;
    assert isempty(acz)
      report "isempty(0,0) returned false" severity error;

    assert not isempty(a)
      report "report isempty(3,3) return true" severity error;
    assert not isempty(a1)
      report "report isempty(1,1) return true" severity error;
    assert not isempty(av1)
      report "report isempty(1) return true" severity error;

    i2  := size (az3);
    i2b := (0, 3);
    if i2 /= i2b then
      report "size (0, 3) returned" severity error;
      print_vector (i2);
    end if;
    i2  := size (cz3);
    i2b := (3, 0);
    if i2 /= i2b then
      report "size (3, 0) returned" severity error;
      print_vector (i2);
    end if;
    i2  := size (acz);
    i2b := (0, 0);
    if i2 /= i2b then
      report "size (0, 0) returned" severity error;
      print_vector (i2);
    end if;

    -- Silently return the bad values
    az3 := repmat (5.0, 0, 3);
    cz3 := repmat (5.0, 3, 0);
    acz := repmat (5.0, 0, 0);
    az3 := zeros (0, 3);
    cz3 := zeros (3, 0);
    acz := zeros (0, 0);
    az3 := ones (0, 3);
    cz3 := ones (3, 0);
    acz := ones (0, 0);
    az3 := transpose (cz3);
    acz := transpose (bdz);
    ---------------------------------------------------------------------------
    -- Null matrix functionality is defined as follows:
    -- (a,0) * (0,d) = (a,d) zeros (0 = 0)
    -- zeros (3,0) = Null matrix
    ---------------------------------------------------------------------------
    a   := cz3 * az3;
    b   := zeros (3, 3);
    if a /= b then
      report "(3,n) * (n,3) problem" severity error;
      print_matrix (a);
    end if;
    -- Should silently return a null matrix
    acz := az3 * cz3;                   -- 0x0 = 0x3 * 3x0
    bz3 := az3 * a;                     -- 0x3 = 0x3 * 3x3
    dz3 := a * cz3;                     -- 3x0 = 3x3 * 3x0
    if not quiet then
      b := a * az3;                     -- 3x3 = 3x3 * 0x3 w/ error (3/=0)
      b := cz3 * a;                     -- 3x3 = 3x0 * 3x3 w/ error (0/=3)
    end if;

    -- matrix * vector
    -- Should silently return a null matrix
    acz := az1 * avz;                   -- 0x0 = 0x1 * 0
    if not quiet then
      cz1 := cz1 * avz;                 -- 1x0 = 1x0 * 0 w/ error (l(2) /= 1)
      a1  := cz1 * av1;                 -- 1x1 = 1x0 * 1 w/ error (l(2) /= 1)
      cz1 := a1 * avz;                  -- 0x0 = 1x1 * 0 w/ error (l(1) /= r)
    end if;

    -- vector * matrix
    -- 1x3 = 1x0 * 0x3 = 0 * 0x3 (because a vector is assumed to be one row)
    av3 := avz * az3;                   -- 3 = 0 * 0x3 (return 3 zeros)
    bv3 := zeros (1, bv3'length);
    -- Should silently return a null matrix
    avz := avz * bdz;                   -- 0 = 0 * 0x0
    avz := bv3 * cz3;                   -- 3 = 3 * 3x0
    if not quiet then
      av3 := bv3 * az3;                 -- 3 = 3 * 0x3
      av3 := avz * a;                   -- 3 = 0 * 3x3
      avz := bv3 * acz;                 -- 0 = 3 * 0x0
    end if;

    -- real * matrix
    -- silently return the bad range
    az3 := m * bz3;
    acz := m * bdz;
    cz3 := m * dz3;
    az3 := bz3 * m;
    acz := bdz * m;
    cz3 := dz3 * m;
    avz := m * bvz;
    avz := bvz * m;

    az3 := bz3 / m;
    acz := bdz / m;
    cz3 := dz3 / m;
    avz := bvz / m;

    az3 := az3 + bz3;
    cz3 := cz3 + dz3;
    acz := acz + bdz;
    avz := avz + bvz;

    az3 := az3 - bz3;
    cz3 := cz3 - dz3;
    acz := acz - bdz;
    avz := avz - bvz;

    az3 := - bz3;
    cz3 := - dz3;
    acz := - bdz;
    avz := - bvz;

    az3 := abs (bz3);
    cz3 := abs (dz3);
    acz := abs (bdz);
    avz := abs (bvz);

    az3 := times (az3, bz3);
    cz3 := times (cz3, dz3);
    acz := times (acz, bdz);
    avz := times (avz, bvz);

    az3 := rdivide (az3, bz3);
    cz3 := rdivide (cz3, dz3);
    acz := rdivide (acz, bdz);
    avz := rdivide (avz, bvz);

    -- An "Inv" will transpose the output matrix.
    az3 := inv(cz3);
    cz3 := inv(az3);
    acz := inv(bdz);

    -- mrdivide
    a := mrdivide (cz3, dz3);
    b := zeros (3, 3);
    if a /= b then
      report "mrdivide (3,n) (3,n) problem" severity error;
      print_matrix (a);
    end if;
    acz := mrdivide (az3, bz3);
    a   := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    bz3 := mrdivide (az3, a);
    dz3 := mrdivide (a, az3);
    -- /
    a   := cz3 / dz3;
    b   := zeros (3, 3);
    if a /= b then
      report "(3,n) / (3,n) problem" severity error;
      print_matrix (a);
    end if;
    acz := az3 / bz3;
    a   := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    bz3 := az3 / a;
    dz3 := a / az3;

    -- mldivide = inv(l) * r
    a := mldivide (az3, bz3);
    b := zeros (3, 3);
    if a /= b then
      report "mldivide (n,3) (n,3) problem" severity error;
      print_matrix (a);
    end if;
    acz := mldivide (cz3, dz3);
    a   := ((1.0, 3.0, 2.0), (4.0, 1.0, 3.0), (2.0, 5.0, 2.0));
    bz3 := mldivide (cz3, a);
    dz3 := mldivide (a, cz3);

    acz := bdz ** 2;
    acz := bdz ** (-1);
    acz := bdz ** 0;

    az3 := pow (az3, bz3);
    dz3 := pow (cz3, dz3);
    acz := pow (acz, bdz);
    avz := pow (avz, bvz);

    az3 := sqrt (bz3);
    cz3 := sqrt (dz3);
    acz := sqrt (bdz);
    avz := sqrt (bvz);

    az3 := exp (bz3);
    cz3 := exp (dz3);
    acz := exp (bdz);
    avz := exp (bvz);

    az3 := log (bz3);
    cz3 := log (dz3);
    acz := log (bdz);
    avz := log (bvz);

    m := trace (az3);
    assert m = 0.0 report "trace (3x0) returned " & REAL'image(m)
      severity error;
    m := trace (dz3);
    assert m = 0.0 report "trace (0x3) returned " & REAL'image(m)
      severity error;
    m := trace (acz);
    assert m = 0.0 report "trace (0x0) returned " & REAL'image(m)
      severity error;

    -- sum of an empty matrix is 0
    m := sum (bvz);
    assert m = 0.0 report "sum (0) returned " & REAL'image(m)
      severity error;

    av3 := sum (az3);
    bv3 := zeros (1, 3);
    if av3 /= bv3 then
      report "sum (3x0) returned "
        severity error;
      print_vector (av3);
    end if;
    av3 := sum (dz3, 2);
    bv3 := zeros (1, 3);
    if av3 /= bv3 then
      report "sum (0x3,2) returned "
        severity error;
      print_vector (av3);
    end if;
    avz := sum (acz, 1);
    avz := sum (acz, 2);

    -- prod of an empty matrix is 1.
    m := prod (bvz);
    assert m = 1.0 report "prod (0) returned " & REAL'image(m)
      severity error;

    av3 := prod (az3);
    bv3 := ones (1, 3);
    if av3 /= bv3 then
      report "prod (3x0) returned "
        severity error;
      print_vector (av3);
    end if;
    av3 := prod (dz3, 2);
    bv3 := ones (1, 3);
    if av3 /= bv3 then
      report "prod (0x3,2) returned "
        severity error;
      print_vector (av3);
    end if;
    avz := prod (acz, 1);
    avz := prod (acz, 2);

    m := dot (avz, bvz);
    assert m = 0.0 report "dot (0) = " & REAL'image(m) severity error;

    acz := kron (az3, cz3);
    k1  := kron (az3, bz3);

    m := det (az3);
    assert m = 0.0 report "det (0,3) = " & REAL'image(m) severity error;
    m := det (cz3);
    assert m = 0.0 report "det (3,0) = " & REAL'image(m) severity error;
    m := det (acz);
    assert m = 0.0 report "det (0,0) = " & REAL'image(m) severity error;

    avz := linsolve (az3, bvz);

    az3 := normalize (bz3);
    cz3 := normalize (dz3);
    acz := normalize (bdz);
    avz := normalize (bvz);

    avz := polyval (avz, bvz);

    acz := eye (0, 0);

    a := ((1.0, 2.0, 3.0), (4.0, 5.0, 6.0), (7.0, 8.0, 9.0));
    b := horzcat (a, cz3);
    if a /= b then
      report "horzcat (3x3, 3x0)" severity error;
      print_matrix (b);
    end if;
    b := horzcat (cz3, a);
    if a /= b then
      report "horzcat (3x0, 3x3)" severity error;
      print_matrix (b);
    end if;
    b := cat (2, a, cz3);
    if a /= b then
      report "cat (2, 3x3, 3x0)" severity error;
      print_matrix (b);
    end if;

    b := vertcat (a, az3);
    if a /= b then
      report "vertcat (3x3, 0x3)" severity error;
      print_matrix (b);
    end if;
    b := vertcat (az3, a);
    if a /= b then
      report "vertcat (0x3, 3x3)" severity error;
      print_matrix (b);
    end if;
    b := cat (1, a, az3);
    if a /= b then
      report "cat (1, 3x3, 0x3)" severity error;
      print_matrix (b);
    end if;

    az3 := fliplr (bz3);
    cz3 := fliplr (dz3);
    acz := fliplr (bdz);
    avz := fliplr (bvz);
    az3 := flipup (bz3);
    cz3 := flipup (dz3);
    acz := flipup (bdz);

    az3 := rot90 (dz3);
    cz3 := rot90 (bz3);
    acz := rot90 (bdz);
    az3 := rot90 (bz3, 2);
    cz3 := rot90 (dz3, 2);
    acz := rot90 (bdz, 2);
    az3 := rot90 (dz3, 3);
    cz3 := rot90 (bz3, 3);
    acz := rot90 (bdz, 3);

    assert not isvector (acz)
      report "isvector (0x0) returned true" severity error;
    assert not isscalar (acz)
      report "isscalar (0x0) returned true" severity error;

    i := numel (az3);
    assert i = 0
      report "numel (0, 3) = " & INTEGER'image(i) severity error;
    i := numel (cz3);
    assert i = 0
      report "numel (3, 0) = " & INTEGER'image(i) severity error;
    i := numel (acz);
    assert i = 0
      report "numel (0, 0) = " & INTEGER'image(i) severity error;

    avz := diag (az3);
    avz := diag (cz3);
    avz := diag (acz);
    acz := diag (avz);
    acz := blkdiag (avz);
    acz := blockdiag (acz, 3);
    acz := repmat (acz, 3, 3);
    az3 := repmat (az1, 3, 3);
    cz3 := repmat (cz1, 3, 3);

    az3 := tril (bz3);
    cz3 := tril (dz3);
    acz := tril (bdz);
    az3 := triu (bz3);
    cz3 := triu (dz3);
    acz := triu (bdz);

    -- pass null ranges via conversion functions
    az3i := to_integer (az3);
    cz3i := to_integer (cz3);
    aczi := to_integer (acz);
    avzi := to_integer (avz);
    az3  := to_real (az3i);
    cz3  := to_real (cz3i);
    acz  := to_real (aczi);
    avz  := to_real (avzi);

--    report "Got here!" severity note;
    zmat_done <= true;
    wait;

  end process zmat;

end architecture testbench;
