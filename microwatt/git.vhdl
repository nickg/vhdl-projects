library ieee;
use ieee.std_logic_1164.all;

library work;

package git is
    constant GIT_HASH : std_ulogic_vector(55 downto 0) := x"41da88e6d120f2";
    constant GIT_DIRTY : std_ulogic := '0';
end git;
