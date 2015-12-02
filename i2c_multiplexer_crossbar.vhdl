--==============================================================================
-- GSI
-- I2C multoplexer core
--==============================================================================
--
-- author: Piotr Miedzik (P.Miedzik@gsi.de)
--
-- date of creation: 2015-12-02
--
-- version: 1.0
--
-- description:
--
-- dependencies:
--
-- references:
--    [1] The I2C bus specification, version 2.1, NXP Semiconductor, Jan. 2000
--        http://www.nxp.com/documents/other/39340011.pdf
--    [2] PCA9547BS - 8-channel I2C-bus multiplexer with reset
--        http://www.nxp.com/documents/data_sheet/PCA9547.pdf
--
--==============================================================================
-- GNU LESSER GENERAL PUBLIC LICENSE
--==============================================================================
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version. This source is distributed in the hope that it
-- will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details. You should have
-- received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html
--==============================================================================
-- last changes:
--    2015-12-02   Piotr Miedzik      File created
--==============================================================================
-- TODO:
--    - description
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_multiplexer_pkg.all;

entity i2c_multiplexer_crossbar is
	generic(
		g_slave_count : natural := 4
	);
	port(
		clk_i            : in  std_logic;
		rst_i            : in  std_logic;

		channels_enbabled_i : in std_logic_vector(g_slave_count downto 0);

		scl_i            : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
		sda_i            : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
		scl_o            : out STD_LOGIC_VECTOR(g_slave_count downto 0);
		sda_o            : out STD_LOGIC_VECTOR(g_slave_count downto 0);
		scl_dir_o        : out STD_LOGIC_VECTOR(g_slave_count downto 0);
		sda_dir_o        : out STD_LOGIC_VECTOR(g_slave_count downto 0);

		i2c_start_i      : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
		i2c_stop_i       : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
		i2c_scl_raise_i  : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
		i2c_scl_fall_i   : in  STD_LOGIC_VECTOR(g_slave_count downto 0);

		i2c_transfer_start_o :out std_logic;
		i2c_transfer_stop_o :out std_logic;
		i2c_ack_req_o    : out std_logic;
		i2c_ack_i        : in  std_logic;
		i2c_chip_addr_o  : out std_logic_vector(7 downto 0);
		i2c_chip_addr_valid_o : out std_logic; 
		i2c_valid_data_o : out std_logic;
		i2c_data_o       : out std_logic_vector(7 downto 0);
		i2c_data_i       : in  std_logic_vector(7 downto 0)
	);
end entity i2c_multiplexer_crossbar;

architecture RTL of i2c_multiplexer_crossbar is
	signal r_idle           : std_logic;
	signal r_first_byte     : std_logic;
	signal r_current_master : std_logic_vector(g_slave_count downto 0);
	signal r_current_slave  : std_logic_vector(g_slave_count downto 0);
	signal r_current_busy   : std_logic_vector(g_slave_count - 1 downto 0);

	signal s_current_enabled : std_logic_vector(g_slave_count downto 0);


	signal s_scl_and_enable   : std_logic_vector(g_slave_count downto 0);
	signal s_sda_and_enable   : std_logic_vector(g_slave_count downto 0);
	signal s_start_and_enable : std_logic_vector(g_slave_count downto 0);

	signal s_master_scl_raise : std_logic;
	signal s_master_scl_fall  : std_logic;
	signal s_master_start     : std_logic;
	signal s_master_stop      : std_logic;

	signal r_counter : natural range 0 to 9;

	signal s_master_write    : std_logic := '1'; -- sygnal pochodzi z dekodera/fsm i2c
	signal s_master_wait_ack : std_logic := '1'; -- sygnal pochodzi z dekodera/fsm i2c
	signal s_master_scl      : std_logic;
	signal s_master_sda      : std_logic;
	signal s_slave_sda       : std_logic;
	signal s_sda             : std_logic;
	

	signal r_data_tmp : std_logic_vector(7 downto 0);
	signal r_data     : std_logic_vector(7 downto 0);
	signal r_address  : std_logic_vector(7 downto 0);
	signal r_ack      : std_logic;
	signal r_data_tmp_out : std_logic_vector(7 downto 0);
	signal r_data_bit_out: std_logic;
begin
	GEN_MASTER : for i in 0 to g_slave_count generate
		process(clk_i)
		begin
			if rising_edge(clk_i) then
				if (rst_i = '1') then
					r_current_master(i) <= '0';
					r_current_slave(i)  <= '0';
				else
					if s_master_start = '1' and r_idle = '1' then
						if i2c_start_i(i) = '1' then
							r_current_master(i) <= '1';
							r_current_slave(i)  <= '0';
						else
							r_current_slave(i)  <= '1' ;
							r_current_master(i) <= '0';
						end if;
					end if;

					if s_master_stop = '1' and r_idle = '0' then
						r_current_master(i) <= '0';
						r_current_slave(i)  <= '0';
					end if;

				end if;
			end if;
		end process;
	end generate GEN_MASTER;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				r_idle <= '1';
			elsif s_master_start = '1' then
				r_idle <= '0';
			elsif s_master_stop = '1' then
				r_idle <= '1';
			end if;
		end if;

	end process;

	GEN_BUSY : for i in 0 to g_slave_count - 1 generate
		process(clk_i)
		begin
			if rising_edge(clk_i) then
				if (rst_i = '1') then
					r_current_busy(i) <= '0';
				else
					if s_current_enabled(i) = '0' then
						if i2c_start_i(i) = '1' then
							r_current_busy(i) <= '1';
						end if;
					end if;
				end if;
			end if;
		end process;
	end generate GEN_BUSY;

	s_current_enabled <= channels_enbabled_i;
	

	s_master_scl_raise <= or_reduct(i2c_scl_raise_i and r_current_master);
	s_master_scl_fall  <= or_reduct(i2c_scl_fall_i and r_current_master);
	s_master_start     <= or_reduct(i2c_start_i and (or_expand(r_current_master, r_idle)));
	s_master_stop      <= or_reduct(i2c_stop_i and r_current_master);

	s_master_scl <= and_reduct(scl_i or not r_current_master);
	s_master_sda <= and_reduct(sda_i or not r_current_master);
	s_slave_sda  <= and_reduct(sda_i or not r_current_slave) and r_data_bit_out;
	
	s_sda <= s_slave_sda when  r_counter = 0 else
			 s_master_sda;
	
	
	i2c_transfer_start_o <= s_master_start;
	i2c_transfer_stop_o <= s_master_stop;
	--s_start_and_enable <= i2c_start_i and '1' & r_current_enabled(g_slave_count - 1 downto 0);

	--s_scl_and_enable <= scl_i(g_slave_count downto 0) or not r_current_enabled(g_slave_count downto 0);
	--s_sda_and_enable <= sda_i(g_slave_count downto 0) or not r_current_enabled(g_slave_count downto 0);

	--scl_o(g_slave_count) <= and_reduct(s_scl_and_enable(g_slave_count - 1 downto 0));
	--sda_o(g_slave_count) <= and_reduct(s_sda_and_enable(g_slave_count - 1 downto 0));

	GEN_SDA_SCL : for i in 0 to g_slave_count generate
		scl_o(i) <= s_master_scl or not s_current_enabled(i);
		sda_o(i) <= s_sda or not s_current_enabled(i);
	end generate GEN_SDA_SCL;
	
	

	GEN_DIR : for i in 0 to g_slave_count generate
		scl_dir_o(i) <= '0' when r_idle = '1' else '1' when r_current_slave(i) = '1' else '0' when r_current_master(i) = '1' else '0';

		sda_dir_o(i) <= '0' when r_idle = '1' else '1' when r_current_slave(i) = '1' and s_master_wait_ack = '0' else '0' when r_current_slave(i) = '1' and s_master_wait_ack = '1' else '0' when r_current_master(i) = '1' and s_master_wait_ack = '0' else '1' when r_current_master(i) = '1' and
			s_master_wait_ack = '1' else '0';
	end generate GEN_DIR;

	proc_counter : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				r_counter <= 9;
			else
				if r_idle = '1' then
					r_counter <= 9;
				elsif s_master_scl_fall = '1' then
					if r_counter = 0 then
						r_counter <= 8;
					else
						r_counter <= r_counter - 1;
					end if;
				end if;

			end if;
		end if;
	end process;

	proc_data : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' or r_idle = '1' or s_master_start = '1' then
				r_data_tmp <= (others => '0');
				r_data     <= (others => '0');
				r_ack      <= '0';
				r_first_byte <= '1';
				r_address <= (others => '0');
				i2c_chip_addr_valid_o <= '0';
			else
				i2c_valid_data_o <= '0';
				i2c_chip_addr_valid_o <= '0';
				if s_master_scl_raise = '1' then
					if r_counter = 1 then
						if r_first_byte = '1' then
							i2c_chip_addr_valid_o <= '1';
							r_address <= r_data_tmp(6 downto 0) & s_master_sda;
						else
							r_data <= r_data_tmp(6 downto 0) & s_master_sda;
							i2c_valid_data_o <= '1';
						end if;
						r_data_tmp <= r_data_tmp(6 downto 0) & s_master_sda;
					elsif r_counter = 0 then
						r_first_byte <= '0';
						r_ack  <= not s_master_sda or i2c_ack_i;
					else
						r_data_tmp <= r_data_tmp(6 downto 0) & s_master_sda;
					end if;
				end if;

			end if;
		end if;
	end process;
	
	
	
	i2c_chip_addr_o <= r_address;
	i2c_data_o <= r_data;
	s_master_wait_ack <= '1' when r_counter = 0 else '0';
	
	
	proc_internal_response: process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' or s_master_start = '1' then
				r_data_tmp_out <= (others => '1');
			else
				if s_master_scl_fall  = '1' then
					if r_counter = 0 then
						r_data_tmp_out <= i2c_data_i;
					else
						r_data_tmp_out <= r_data_tmp_out(7 downto 1) & '1';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	r_data_bit_out <= not i2c_ack_i when r_counter = 0 else
					  r_data_tmp_out(7) when r_first_byte = '0' else
					  '1' ;

end architecture RTL;
