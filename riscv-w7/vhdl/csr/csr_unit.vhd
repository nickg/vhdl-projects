-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.csr_constants.all;
use work.csr_wire.all;

entity csr_unit is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		csr_unit_i : in  csr_unit_in_type;
		csr_unit_o : out csr_unit_out_type
	);
end csr_unit;

architecture behavior of csr_unit is

	component csr_file
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			csr_ri : in  csr_read_in_type;
			csr_wi : in  csr_write_in_type;
			csr_o  : out csr_out_type;
			csr_ei : in  csr_exception_in_type;
			csr_eo : out csr_exception_out_type;
			csr_ci : in  csr_counter_in_type
		);
	end component;

	component csr_alu
		port(
			csr_alu_i : in  csr_alu_in_type;
			csr_alu_o : out csr_alu_out_type
		);
	end component;

begin

	csr_file_comp : csr_file
		port map(
			reset  => reset,
			clock  => clock,
			csr_ri => csr_unit_i.csr_ri,
			csr_wi => csr_unit_i.csr_wi,
			csr_o  => csr_unit_o.csr_o,
			csr_ei => csr_unit_i.csr_ei,
			csr_eo => csr_unit_o.csr_eo,
			csr_ci => csr_unit_i.csr_ci
		);

	csr_alu_comp : csr_alu
		port map(
			csr_alu_i => csr_unit_i.csr_alu_i,
			csr_alu_o => csr_unit_o.csr_alu_o
		);

end architecture;
