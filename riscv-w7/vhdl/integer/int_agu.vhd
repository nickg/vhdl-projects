-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.functions.all;
use work.int_constants.all;
use work.int_wire.all;

entity int_agu is
	port(
		int_agu_i : in  int_agu_in_type;
		int_agu_o : out int_agu_out_type
	);
end int_agu;

architecture behavior of int_agu is

begin

	process(int_agu_i)

		variable imem_acc : std_logic;
		variable dmem_acc : std_logic;
		variable sel_pc   : std_logic;

		variable exc      : std_logic;
		variable etval    : std_logic_vector(63 downto 0);
		variable ecause   : std_logic_vector(3 downto 0);

		variable mem_base : std_logic_vector(63 downto 0);
		variable mem_addr : std_logic_vector(63 downto 0);
		variable mem_byte : std_logic_vector(7 downto 0);

		variable misalign : std_logic;

	begin

		imem_acc    := int_agu_i.jal or int_agu_i.jalr or int_agu_i.branch;
		dmem_acc    := int_agu_i.load or int_agu_i.store;
		sel_pc      := int_agu_i.auipc or int_agu_i.jal or int_agu_i.branch;

		exc         := '0';
		etval       := X"0000000000000000";
		ecause      := X"0";

		mem_base    := multiplexer(int_agu_i.rs1, int_agu_i.pc, sel_pc);
		mem_addr    := std_logic_vector(signed(mem_base) + signed(int_agu_i.imm));
		mem_addr(0) := mem_addr(0) and (not int_agu_i.jalr);
		mem_byte    := X"00";

		misalign    := '0';

		if dmem_acc = '1' then

			if (int_agu_i.store_op.mem_sb or int_agu_i.load_op.mem_lb or int_agu_i.load_op.mem_lbu) = '1' then

				case mem_addr(2 downto 0) is
					when "000"  => mem_byte := "00000001";
					when "001"  => mem_byte := "00000010";
					when "010"  => mem_byte := "00000100";
					when "011"  => mem_byte := "00001000";
					when "100"  => mem_byte := "00010000";
					when "101"  => mem_byte := "00100000";
					when "110"  => mem_byte := "01000000";
					when "111"  => mem_byte := "10000000";
					when others => misalign := '1';
				end case;

			elsif (int_agu_i.store_op.mem_sh or int_agu_i.load_op.mem_lh or int_agu_i.load_op.mem_lhu) = '1' then

				case mem_addr(2 downto 0) is
					when "000"  => mem_byte := "00000011";
					when "010"  => mem_byte := "00001100";
					when "100"  => mem_byte := "00110000";
					when "110"  => mem_byte := "11000000";
					when others => misalign := '1';
				end case;

			elsif (int_agu_i.store_op.mem_sw or int_agu_i.load_op.mem_lw or int_agu_i.load_op.mem_lwu) = '1' then

				case mem_addr(2 downto 0) is
					when "000"  => mem_byte := "00001111";
					when "100"  => mem_byte := "11110000";
					when others => misalign := '1';
				end case;

			elsif (int_agu_i.store_op.mem_sd or int_agu_i.load_op.mem_ld) = '1' then

				case mem_addr(2 downto 0) is
					when "000"  => mem_byte := "11111111";
					when others => misalign := '1';
				end case;

			end if;

		elsif imem_acc = '1' then

			case mem_addr(0) is
				when '0' => null;
				when others => misalign := '1';
			end case;

		end if;

		if misalign = '1' then
			if imem_acc = '1' then
				exc := '1';
				etval := mem_addr;
				ecause := except_instr_addr_misalign;
			elsif dmem_acc = '1' then
				exc := '1';
				etval := mem_addr;
				if int_agu_i.load = '1' then
					ecause := except_load_addr_misalign;
				elsif int_agu_i.store = '1' then
					ecause := except_store_addr_misalign;
				end if;
			end if;
		elsif or_reduce(mem_addr(63 downto 56)) = '1' then
			if imem_acc = '1' then
				exc := '1';
				etval := mem_addr;
				ecause := except_instr_access_fault;
			elsif dmem_acc = '1' then
				exc := '1';
				etval := mem_addr;
				if int_agu_i.load = '1' then
					ecause := except_load_access_fault;
				elsif int_agu_i.store = '1' then
					ecause := except_store_access_fault;
				end if;
			end if;
		end if;

		int_agu_o.mem_addr <= mem_addr;
		int_agu_o.mem_byte <= mem_byte;

		int_agu_o.exc <= exc;
		int_agu_o.etval <= etval;
		int_agu_o.ecause <= ecause;

	end process;

end architecture;
