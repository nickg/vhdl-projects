-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

entity avalon is
	port(
		reset                      : in  std_logic;
		clock                      : in  std_logic;
		mem_i                      : in  mem_in_type;
		mem_o                      : out mem_out_type;
		-- Master Avalon interface
		m_avalon_address           : out std_logic_vector(63 downto 0);
		m_avalon_byteenable        : out std_logic_vector(7 downto 0);
		m_avalon_debugaccess       : out std_logic;
		m_avalon_read              : out std_logic;
		m_avalon_readdata          : in  std_logic_vector(63 downto 0);
		m_avalon_response          : in  std_logic_vector(1 downto 0);
		m_avalon_write             : out std_logic;
		m_avalon_writedata         : out std_logic_vector(63 downto 0);
		m_avalon_lock              : out std_logic;
		m_avalon_waitrequest       : in  std_logic;
		m_avalon_readdatavalid     : in  std_logic;
		m_avalon_writereponsevalid : in  std_logic;
		m_avalon_burstcount        : out std_logic
	);
end avalon;

architecture behavior of avalon is

	type state_type is (IDLE, ACTIVE);

	type register_type is record
		state             : state_type;
		avalon_address    : std_logic_vector(63 downto 0);
		avalon_byteenable : std_logic_vector(7 downto 0);
		avalon_read       : std_logic;
		avalon_readdata   : std_logic_vector(63 downto 0);
		avalon_response   : std_logic_vector(1 downto 0);
		avalon_write      : std_logic;
		avalon_writedata  : std_logic_vector(63 downto 0);
		avalon_ready      : std_logic;
	end record;

	constant init_register : register_type := (
		state             => IDLE,
		avalon_address    => (others => '0'),
		avalon_byteenable => (others => '0'),
		avalon_read       => '0',
		avalon_readdata   => (others => '0'),
		avalon_response   => (others => '0'),
		avalon_write      => '0',
		avalon_writedata  => (others => '0'),
		avalon_ready      => '0'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,mem_i,m_avalon_readdata,m_avalon_response,m_avalon_waitrequest,
					m_avalon_readdatavalid,m_avalon_writereponsevalid)

	variable v : register_type;

	begin

		v := r;

		case r.state is
			when IDLE =>
				if mem_i.mem_valid = '1' then
					v.state := ACTIVE;
				end if;
			when ACTIVE =>
				if m_avalon_waitrequest = '0' then
					v.state := IDLE;
				end if;
			when others =>
				null;
		end case;

		case r.state is
			when IDLE =>
				v.avalon_address := mem_i.mem_addr;
				v.avalon_byteenable := mem_i.mem_strb;
				v.avalon_read := mem_i.mem_valid and not(mem_i.mem_write);
				v.avalon_write := mem_i.mem_valid and mem_i.mem_write;
				v.avalon_writedata := mem_i.mem_wdata;
				v.avalon_readdata := (others => '0');
				v.avalon_response := (others => '0');
				v.avalon_ready := '0';
			when ACTIVE =>
				v.avalon_readdata := m_avalon_readdata;
				v.avalon_response := m_avalon_response;
				v.avalon_ready := not(m_avalon_waitrequest);
			when others =>
				v.avalon_readdata := (others => '0');
				v.avalon_response := (others => '0');
				v.avalon_ready := '0';
		end case;

		rin <= v;

		m_avalon_address <= v.avalon_address;
		m_avalon_byteenable <= v.avalon_byteenable;
		m_avalon_debugaccess <= '0';
		m_avalon_read <= v.avalon_read;
		m_avalon_write <= v.avalon_write;
		m_avalon_writedata <= v.avalon_writedata;
		m_avalon_lock <= '0';
		m_avalon_burstcount <= '1';

		mem_o.mem_flush <= '0';
		mem_o.mem_error <= '0';
		mem_o.mem_busy <= '0';
		mem_o.mem_rdata <= r.avalon_readdata;
		mem_o.mem_ready <= r.avalon_ready and nor_reduce(r.avalon_response);

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				r <= init_register;
			else
				r <= rin;
			end if;

		end if;

	end process;

end architecture;
