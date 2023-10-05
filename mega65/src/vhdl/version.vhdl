library ieee;
use Std.TextIO.all;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package version is

  constant gitcommit : string := "master,20231005.12,f938570~";
  constant fpga_commit : unsigned(31 downto 0) := x"f9385701";
  constant fpga_datestamp : unsigned(15 downto 0) := to_unsigned(1376,16);

end version;
