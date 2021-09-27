-------------------------------------------------------------------------------
-- Testbench for the to_string (real) function
-- Test the "printf" functionality of the to_string function
-- Last Modified: $Date: 2006-08-23 16:16:54-04 $
-- RCS ID: $Id: test_realstring.vhdl,v 1.1 2006-08-23 16:16:54-04 l435385 Exp $
--
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org)
-------------------------------------------------------------------------------
entity test_realstring is
  generic (
    quiet : BOOLEAN := false);
end entity test_realstring;

use std.textio.all;
architecture testbench of test_realstring is
  -- purpose: report an error
  procedure report_error (
    constant errmes : in STRING;
    actual : in STRING;
    expected : in STRING) is
  begin
    assert (actual = expected)
      report errmes & CR &
      "Actual:   """ & actual & '"' & CR &
      "Expected: """ & expected & '"' severity error;  
  end procedure report_error;
begin
  -- purpose: test the to_string funciton
  tester : process is
    variable x : REAL;
    variable t, t1 : TIME;
    variable L1, L2 : LINE;  -- lines
  begin
    -- Test of the standard to_string(real) funciton
    -- Expected results are from the "printf" function in gcc 2.95
    x := 1.0;
    write (L1, to_string(x));
    write (L2, real'image(x));
    report_error("1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(x));
    write (L2, real'image(x));
    report_error ("5000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(x));
    write (L2, real'image(x));
    report_error ("500000000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(x));
    -- L2 := new string'("1.801440e+16");
    write (L2, real'image(x));
    report_error ("2**54 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(x));
    -- L2 := new string'("5.000000e-10");
    write (L2, real'image(x));
    report_error ("5e-9 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(x));
    -- L2 := new string'("3.141593e+00");
    write (L2, real'image(x));
    report_error ("PI = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(x));
    -- L2 := new string'("-1.000000e+01");
    write (L2, real'image(x));
    report_error ("-10.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- Check the "digits" version first
    x := 1.0;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("1.0 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 6));
    write (L2, VALUE => x, DIGITS => 6);
    report_error ("1.0 D6 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("5000.0 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 7));
    write (L2, VALUE => x, DIGITS => 7);
    report_error ("5000.0 D7 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("500000000.0 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("2**54 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("5e-10 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 9));
    -- write (L2, VALUE => x, DIGITS => 9); -- NOT ROUNDED CORRECTLY!
    L2 := new string'("0.000000000");  -- Rounded to "0"
    report_error ("5e-10 D9 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 10));
    write (L2, VALUE => x, DIGITS => 10);
    report_error ("5e-10 D10 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 11));
    write (L2, VALUE => x, DIGITS => 11);
    report_error ("5e-10 D11 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("PI D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 3));
    write (L2, VALUE => x, DIGITS => 3);
    report_error ("PI D3 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 5));
    write (L2, VALUE => x, DIGITS => 5);
    report_error ("PI D5 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, DIGITS => 1));
    write (L2, VALUE => x, DIGITS => 1);
    report_error ("-10 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string(VALUE => x, DIGITS => 20));
    write (L2, VALUE => x, DIGITS => 20);
    report_error ("-10 D20 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- Play with Justify a little
    x := 0.07;
    write (L1, justify (VALUE => to_string( VALUE => x,
                                            DIGITS => 1),
                         JUSTIFIED => RIGHT,
                         FIELD => 5));
    write (L => L2,
           VALUE => x,
           JUSTIFIED => RIGHT,
           FIELD => 5,
           DIGITS => 1);
    report_error ("0.07 right 5 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, justify (VALUE => to_string( VALUE => x,
                                            DIGITS => 1),
                         JUSTIFIED => LEFT,
                         FIELD => 5));
    write (L => L2,
           VALUE => x,
           JUSTIFIED => LEFT,
           FIELD => 5,
           DIGITS => 1);
    report_error ("0.07 left 5 D1 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, justify (VALUE => to_string(VALUE => x,
                                           DIGITS => 2),
                         JUSTIFIED => LEFT,
                         FIELD => 5));
    write (L => L2,
            VALUE => x,
            JUSTIFIED => LEFT,
            FIELD => 5,
            DIGITS => 2);
    report_error ("0.07 left 5 D2 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, justify (VALUE => to_string(VALUE => x,
                                           digits => 2),
                         JUSTIFIED => RIGHT,
                         FIELD => 5));
    write (L => L2,
           VALUE => x,
           JUSTIFIED => RIGHT,
           FIELD => 5,
           DIGITS => 2);
    report_error ("0.07 right 5 D2 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, justify (VALUE => to_string(x, 3),
                         JUSTIFIED => LEFT,
                         FIELD => 5));
    write (L => L2,
           VALUE => x,
           JUSTIFIED => LEFT,
           FIELD => 5,
           DIGITS => 3);
    report_error ("0.07 left 5 D3 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, justify (VALUE => to_string(x,3),
                         JUSTIFIED => RIGHT,
                         FIELD => 5));
    write (L => L2,
           VALUE => x,
           JUSTIFIED => RIGHT,
           FIELD => 5,
           DIGITS => 3);
    report_error ("0.07 right 5 D3 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, justify (VALUE => to_string(x,3),
                         JUSTIFIED => RIGHT,
                         FIELD => 4));
    write (L => L2,
           VALUE => x,
           JUSTIFIED => RIGHT,
           FIELD => 4,
           DIGITS => 3);
    report_error ("0.07 right 4 D3 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);


    -- begin test of the new format string
    -- %f
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("1.000000");
    report_error ("%f 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("5000.000000");
    report_error ("%f 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("500000000.000000");
    report_error ("%f 500000000 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.005;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("0.005000");
    report_error ("%f 5e-3 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("18014398509481984.000000");
    report_error ("%f 2**54 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("3.141593");
    report_error ("f PI = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("-10.000000");
    report_error ("f -10.0 ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.001;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("-0.001000");
    report_error ("%f -.001 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.09999999999;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("0.100000");
    report_error ("%f .0999 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("0.000000");
    report_error ("%f 5e-9 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("0.000000");
    report_error ("%f 0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 105.7;
    write (L1, to_string(VALUE => x, format => "%f"));
    L2 := new string'("105.700000");
    report_error ("f 105.7", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 105.7;
    write (L1, to_string(VALUE => x, format => "%F"));
    L2 := new string'("105.700000");
    report_error ("F 105.7", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %6.2f
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  1.00");
    report_error ("%6.2f 1.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("5000.00");
    report_error ("%6.2f 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("500000000.00");
    report_error ("%6.2f 500000000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("18014398509481984.00");
    report_error ("%6.2f 2**54 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.005;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.00");
    report_error ("%6.2f 5e-3 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.005;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'(" -0.00");
    report_error ("%6.2f -5e-3 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.001;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.00");
    report_error ("%6.2f .001 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.001;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'(" -0.00");
    report_error ("%6.2f -.001 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.007;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.01");
    report_error ("%6.2f .007 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.007;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'(" -0.01");
    report_error ("%6.2f -.007 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.015;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.01");
    report_error ("%6.2f .015 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.015;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'(" -0.01");
    report_error ("%6.2f -.015 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.011;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.01");
    report_error ("%6.2f .011 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.011;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'(" -0.01");
    report_error ("%6.2f -.011 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.017;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.02");
    report_error ("%6.2f .017 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.017;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'(" -0.02");
    report_error ("%6.2f -.017 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.09999999999;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.10");
    report_error ("%6.2f .0999 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.00");
    report_error ("%6.2f 5e-9 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  0.00");
    report_error ("%6.2f 0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("  3.14");
    report_error ("6.2f PI = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 105.7;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("105.70");
    report_error ("%6.2f 105.7 " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%6.2f"));
    L2 := new string'("-10.00");
    report_error ("%6.2f -10.0 " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%6.2F"));
    L2 := new string'("-10.00");
    report_error ("%6.2F -10.0 " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %e
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("1.000000e+00");
    report_error ("%e 1.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("5.000000e+03");
    report_error ("%e 5000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("5.000000e+08");
    report_error ("%e 5000000000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("1.801440e+16");
    report_error ("%e 2**54 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.09999999999;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("1.000000e-01");
    report_error ("%e .09999 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("5.000000e-10");
    report_error ("%e 5e-9 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("3.141593e+00");
    report_error ("%e PI = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%e"));
    L2 := new string'("-1.000000e+01");
    report_error ("%e -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %6.2e
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("1.00e+00");
    report_error ("6.2e 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("5.00e+03");
    report_error ("6.2e 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("5.00e+08");
    report_error ("6.2e 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("1.80e+16");
    report_error ("6.2e 2**54 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.09999999999;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("1.00e-01");
    report_error ("6.2e .09999 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("5.00e-10");
    report_error ("6.2e 5e-10 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("3.14e+00");
    report_error ("6.2e PI = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 102.7;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("1.03e+02");
    report_error ("6.2e 102.7 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%6.2e"));
    L2 := new string'("-1.00e+01");
    report_error ("6.2e -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- "%E"
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("1.000000E+00");
    report_error ("%E 1.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("5.000000E+03");
    report_error ("%E 5000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("5.000000E+08");
    report_error ("%E 5000000000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("1.801440E+16");
    report_error ("%E 2**54 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("5.000000E-10");
    report_error ("%E 5e-9 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("3.141593E+00");
    report_error ("%E PI = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 102.7;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("1.027000E+02");
    report_error ("%E 102.7 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%E"));
    L2 := new string'("-1.000000E+01");
    report_error ("%E -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %6.2E
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("1.00E+00");
    report_error ("6.2E 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("5.00E+03");
    report_error ("6.2E 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("5.00E+08");
    report_error ("6.2E 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("1.80E+16");
    report_error ("6.2E 2**54 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("5.00E-10");
    report_error ("6.2E 5e-10 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("3.14E+00");
    report_error ("6.2E PI = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -102.7;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("-1.03E+02");
    report_error ("6.2E -102.7 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%6.2E"));
    L2 := new string'("-1.00E+01");
    report_error ("6.2E -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %12.6e = "%e"
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("1.000000e+00");
    report_error ("%12.6e 1.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("5.000000e+03");
    report_error ("%12.6e 5000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("5.000000e+08");
    report_error ("%12.6e 5000000000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("1.801440e+16");
    report_error ("%12.6e 2**54 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("5.000000e-10");
    report_error ("%12.6e 5e-9 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("3.141593e+00");
    report_error ("%12.6e PI = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%12.6e"));
    L2 := new string'("-1.000000e+01");
    report_error ("%12.6e -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- 13.6e
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'(" 1.000000e+00");
    report_error ("%13.6e 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'(" 5.000000e+03");
    report_error ("%13.6e 5000.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'(" 1.801440e+16");
    report_error ("%13.6e 2**54 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'(" 5.000000e-10");
    report_error ("%13.6e 5e-9 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'(" 3.141593e+00");
    report_error ("%13.6e PI = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 102.7;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'(" 1.027000e+02");
    report_error ("%13.6e 102.7 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%13.6e"));
    L2 := new string'("-1.000000e+01");
    report_error ("%13.6e -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- check - and .
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%-13.6e"));
    L2 := new string'("1.000000e+00 ");  -- left justified
    report_error ("%-13.6e 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%.13.6e"));
    L2 := new string'("1.000000e+00 ");  -- left justified
    report_error ("%.13.6e 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- 12.3e
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%12.3e"));
    L2 := new string'("   1.000e+00");
    report_error ("%12.3e 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%12.3e"));
    L2 := new string'("   5.000e+03");
    report_error ("%12.3e 5555 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%12.3e"));
    L2 := new string'("   5.000e-10");
    report_error ("%12.3e .000005 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%12.3e"));
    L2 := new string'("   3.142e+00");
    report_error ("%12.3e PI = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%12.3e"));
    L2 := new string'("  -1.000e+01");
    report_error ("%12.3e -10 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- 13.3e
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%13.3e"));
    L2 := new string'("    1.000e+00");
    report_error ("%13.3e 1 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%-13.3e"));
    L2 := new string'("1.000e+00    ");  -- left justified
    report_error ("%-13.3e 1 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%.13.3e"));
    L2 := new string'("1.000e+00    ");  -- left justified
    report_error ("%.13.3e 1 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%.6.3e"));
    L2 := new string'("1.000e+00");  -- too small
    report_error ("%.6.3e 1 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %g
    x := 1.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("1");
    report_error ("%g 1", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("5000");
    report_error ("%g 5000", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 50000.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("50000");
    report_error ("%g 50000", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("500000");
    report_error ("%g 500000", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000000.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("5e+06");
    report_error ("%g 5000000", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("1.80144e+16");
    report_error ("%g ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("5e+08");
    report_error ("%g 50000000000", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("5e-10");
    report_error ("%g .0000005", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.09999999999;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("0.1");
    report_error ("%g .09999", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.005;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("0.005");
    report_error ("%g .005", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.001;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("-0.001");
    report_error ("%g -.001", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.0001;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("-0.0001");
    report_error ("%g -0.0001", L1.all, L2.all);
    x := -0.00001;
    deallocate (L1); deallocate (L2);
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("-1e-05");
    report_error ("%g -1e-5", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.001;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("0.001");
    report_error ("%g .001", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0001;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("0.0001");
    report_error ("%g 0.0001", L1.all, L2.all);
    x := 0.00001;
    deallocate (L1); deallocate (L2);
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("1e-05");
    report_error ("%g 1e-5", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("0");
    report_error ("%g 0.0", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("3.14159");
    report_error ("%g PI", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 102.7;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("102.7");
    report_error ("%g 102.7", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write(L1, to_string(VALUE => x, format => "%g"));
    L2 := new string'("-10");
    report_error ("%g -10.0", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write(L1, to_string(VALUE => x, format => "%G"));
    L2 := new string'("-10");
    report_error ("%G -10.0", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- %6.2g
    x := 1.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("     1");
    report_error ("6.2g 1.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 5e+03");
    report_error ("6.2g 5000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 50000.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 5e+04");
    report_error ("6.2g 50000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 5e+05");
    report_error ("6.2g 500000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 5000000.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 5e+06");
    report_error ("6.2g 5000000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 2.0**54;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("1.8e+16");
    report_error ("6.2g 2**54 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 500000000.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 5e+08");
    report_error ("6.2g 50000000.0 = " , L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.0000000005;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 5e-10");
    report_error ("6.2g 5e-9 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.09999999999;
    write(L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("   0.1");
    report_error ("%6.2g .09999", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.9999999999;
    write(L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("     1");
    report_error ("%6.2g .99999", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.000000009999999999;
    write(L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 1e-08");
    report_error ("%6.2g .0000009999", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 0.005;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 0.005");
    report_error ("6.2g 5e-3 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 3.1415926535;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("   3.1");
    report_error ("6.2g PI = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := 102.7;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'(" 1e+02");
    report_error ("6.2g 102.7 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -10.0;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("   -10");
    report_error ("6.2g -10.0 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.001;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("-0.001");
    report_error ("6.2g -.001 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.0001;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("-0.0001");
    report_error ("6.2g -.0001 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.00001;
    write (L1, to_string(VALUE => x, format => "%6.2g"));
    L2 := new string'("-1e-05");
    report_error ("6.2g -1e-5 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    x := -0.00001;
    write (L1, to_string(VALUE => x, format => "%6.2G"));
    L2 := new string'("-1E-05");
    report_error ("6.2G -1e-5 = ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    -- Check some error conditions
    if (not quiet) then
      report "Expect 8 to_string format errors here." severity note;
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "%i"));
      L2 := new string'("");
      report_error ("%i 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "i"));
      L2 := new string'("");
      report_error ("i 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "6.2f"));
      L2 := new string'("");
      report_error ("6.2f 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "6f"));
      L2 := new string'("");
      report_error ("6f 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "f"));
      L2 := new string'("");
      report_error ("f 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "%6i"));
      L2 := new string'("");
      report_error ("%6i 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "%6.2i"));
      L2 := new string'("");
      report_error ("%6.2i 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
      x := 12.34;
      write (L1, to_string(VALUE => x, format => "%-6.2i"));
      L2 := new string'("");
      report_error ("%-6.2i 12.34 = ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
    end if;
    assert (quiet) report "Real string test complete" severity note;
    -- Check to_string(time)
    t := 50 ns;
    write (L1, to_string (VALUE => t, UNIT => ns));
    L2 := new string'("50 ns");
    report_error ("50 ns ns ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    if (not quiet) then
      write (L1, to_string (VALUE => t, UNIT => ps));
      L2 := new string'("50 ns");
      report_error ("50 ns ps ", L1.all, L2.all);
      deallocate (L1); deallocate (L2);
    end if;
    write (L1, to_string (VALUE => t, UNIT => us));
    L2 := new string'("0.05 us");
    report_error ("50 ns us ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string (VALUE => t, UNIT => ms));
    L2 := new string'("0.00005 ms");
    report_error ("50 ns ms ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string (VALUE => t, UNIT => 1 ns));
    L2 := new string'("50 ns");
    report_error ("50 ns 1 ns ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string (VALUE => t, UNIT => 1 us));
    L2 := new string'("0.05 us");
    report_error ("50 ns 10 ns ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string (VALUE => t, UNIT => 1 us));
    L2 := new string'("0.05 us");
    report_error ("50 ns 5 ns ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    t := 1.567 sec;
    write (L1, to_string (VALUE => t, UNIT => ns));
    L2 := new string'("1567000000 ns");
    report_error ("1.567 sec ns ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);
    write (L1, to_string (VALUE => t, UNIT => ms));
    L2 := new string'("1567 ms");
    report_error ("1.567 sec ms ", L1.all, L2.all);
    deallocate (L1); deallocate (L2);



--    t := 50 ns;
--    t1 := 1 ns;
--    write (L1, to_string (VALUE => t));  -- default to 1 ns resolution
--    L2 := new string'("50 ns");
--    report_error ("50 ns", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 50 ns;
--    t1 := 1 ns;    
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50 ns");
--    report_error ("50 ns", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 1.567 sec;
--    t1 := 1 ns;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("1567000000 ns");
--    report_error ("1.567 sec", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
---- check the new algorithm
--    t := 50 ns;
--    t1 := 10 ns;    
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50 ns");
--    report_error ("50 ns r = 10 ns", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    assert (quiet) report "Expect a to_string resolution error here"
--      severity note;
--    if (not quiet) then
--      t := 50 ns;
--      t1 := 1 ps;
--      write (L1, to_string (VALUE => t, resolution => t1));
--      L2 := new string'("0 ns");
--      report_error ("50 ns r = 1 ps", L1.all, L2.all);
--      deallocate (L1); deallocate (L2);
--    end if;
--    t := 50 us;
--    t1 := 1 us;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50 us");
--    report_error ("50 us r = 1 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 50 ms;
--    t1 := 1 us;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50000 us");
--    report_error ("50 ms r = 1 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 50 ms;
--    t1 := 10 us;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50000 us");
--    report_error ("50 ms r = 10 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 50 ms;
--    t1 := 100 us;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50000 us");
--    report_error ("50 ms r = 100 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);    
--    t := 50 sec;
--    t1 := 100 us;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("50000000 us");
--    report_error ("50 sec r = 100 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 1 ns;
--    t1 := 1 us;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("0 us");
--    report_error ("1 ns r = 1 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 1.567 us;
--    t1 := 10 ns;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("1560 ns");
--    report_error ("1 ns r = 1 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
--    t := 1.567 sec;
--    t1 := 10 ns;
--    write (L1, to_string (VALUE => t, resolution => t1));
--    L2 := new string'("1567000000 ns");
--    report_error ("1 ns r = 1 us", L1.all, L2.all);
--    deallocate (L1); deallocate (L2);
    assert (quiet) report "time string test complete" severity note;
    report "Real and Time string testing complete" severity note;
    wait;
  end process tester;

end architecture testbench;
