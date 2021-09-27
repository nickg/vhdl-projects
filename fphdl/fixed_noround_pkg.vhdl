-- --------------------------------------------------------------------
-- Last Modified: $Date: 2007-09-12 08:55:57-04 $
-- RCS ID: $Id: fixed_noround_pkg.vhdl,v 1.3 2007-09-12 08:55:57-04 l435385 Exp $
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org)
-- --------------------------------------------------------------------
library ieee;
use ieee.fixed_float_types.all;

package fixed_noround_pkg is new ieee.fixed_generic_pkg
  generic map (
    fixed_round_style    => fixed_truncate,  -- Truncate, don't round
    fixed_overflow_style => fixed_wrap,  -- Wrap, don't saturate
    fixed_guard_bits     => 0,    -- no guard bits
    no_warning           => true  -- do not show warnings
    );
