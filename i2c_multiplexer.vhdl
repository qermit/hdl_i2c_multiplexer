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



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.i2c_multiplexer_pkg.all;

entity i2c_multiplexer is
	generic(
		CLK_FREQ       : natural := 125000000;
		g_use_tristate : boolean := true;
		g_slave_count  : natural := 4;
		g_chip_address : std_logic_vector(7 downto 0) := x"E0"
	);
	Port(clk_i         : in    STD_LOGIC;
		 rst_i         : in    STD_LOGIC;

		 slave_scl_io  : inout STD_LOGIC_VECTOR(g_slave_count downto 0);
		 slave_sda_io  : inout STD_LOGIC_VECTOR(g_slave_count downto 0);

		 slave_scl_i   : in    STD_LOGIC_VECTOR(g_slave_count downto 0) := (others => '1');
		 slave_sda_i   : in    STD_LOGIC_VECTOR(g_slave_count downto 0) := (others => '1');
		 slave_scl_o   : out   STD_LOGIC_VECTOR(g_slave_count downto 0);
		 slave_sda_o   : out   STD_LOGIC_VECTOR(g_slave_count downto 0);
		 slave_scl_dir : out   STD_LOGIC_VECTOR(g_slave_count downto 0);
		 slave_sda_dir : out   STD_LOGIC_VECTOR(g_slave_count downto 0)
	);

end i2c_multiplexer;

architecture Behavioral of i2c_multiplexer is
	signal s_scl_i   : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal s_sda_i   : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal s_scl_o   : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal s_sda_o   : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal s_scl_dir : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal s_sda_dir : STD_LOGIC_VECTOR(g_slave_count downto 0);

	signal i2c_stop_i      : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal i2c_start_i     : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal i2c_scl_raise_i : STD_LOGIC_VECTOR(g_slave_count downto 0);
	signal i2c_scl_fall_i  : STD_LOGIC_VECTOR(g_slave_count downto 0);
	
	
	signal chip_addres_i : std_logic_vector(7 downto 0);
	signal ack_req_o : std_logic;
	signal ack_req_i : std_logic;
	signal data_valid_i : std_logic;
	signal data_in_i : std_logic_vector(7 downto 0);
	signal data_out_o : std_logic_vector(7 downto 0);
	signal chip_address_valid : std_logic;
	signal s_channels_enabled : std_logic_vector(g_slave_count downto 0);
	signal transfer_stop : std_logic;
	signal transfer_start : std_logic;

begin
	GEN_I2C_SLAVE : for i in 0 to g_slave_count generate
		inst_i2c_filter : i2c_multiplexer_filter
			generic map(
				g_use_tristate => g_use_tristate,
				g_use_filter   => true
			)
			port map(
				clk_i           => clk_i,
				rst_i           => rst_i,
				channel_enabled_i => s_channels_enabled(i),
				m_scl_io        => slave_scl_io(i),
				m_sda_io        => slave_sda_io(i),
				m_sda_i         => slave_sda_i(i),
				m_scl_i         => slave_scl_i(i),
				m_sda_o         => slave_sda_o(i),
				m_scl_o         => slave_scl_o(i),
				m_sda_dir       => slave_sda_dir(i),
				m_scl_dir       => slave_scl_dir(i),
				slave_scl_in_o  => s_scl_i(i),
				slave_sda_in_o  => s_sda_i(i),
				slave_scl_out_i => s_scl_o(i),
				slave_sda_out_i => s_sda_o(i),
				slave_scl_dir_i => s_scl_dir(i),
				slave_sda_dir_i => s_sda_dir(i),
				i2c_start       => i2c_start_i(i),
				i2c_stop        => i2c_stop_i(i),
				i2c_scl_raise   => i2c_scl_raise_i(i),
				i2c_scl_fall    => i2c_scl_fall_i(i)
			);
	end generate GEN_I2C_SLAVE;

	inst_i2c_crossbar : i2c_multiplexer_crossbar
		generic map(
			g_slave_count => g_slave_count
		)
		port map(
			clk_i            => clk_i,
			rst_i            => rst_i,
			channels_enbabled_i => s_channels_enabled,
			scl_i            => s_scl_i,
			sda_i            => s_sda_i,
			scl_o            => s_scl_o,
			sda_o            => s_sda_o,
			scl_dir_o        => s_scl_dir,
			sda_dir_o        => s_sda_dir,
			i2c_start_i      => i2c_start_i,
			i2c_stop_i       => i2c_stop_i,
			i2c_scl_raise_i  => i2c_scl_raise_i,
			i2c_scl_fall_i   => i2c_scl_fall_i,
			
			i2c_transfer_stop_o => transfer_stop,
			i2c_transfer_start_o => transfer_start,
			i2c_ack_i        => ack_req_o,
			i2c_ack_req_o    => ack_req_i,
			i2c_data_i       => data_out_o,
			i2c_data_o       => data_in_i,
			i2c_chip_addr_o  => chip_addres_i,
			i2c_chip_addr_valid_o => chip_address_valid,
			i2c_valid_data_o => data_valid_i
		);

	inst_i2c_ctrl: i2c_multiplexer_ctl
		generic map(
			g_slave_count  => g_slave_count,
			g_chip_address => g_chip_address
		)
		port map(
			clk_i                 => clk_i,
			rst_i                 => rst_i,
			transfer_start_i      => transfer_start,
			transfer_stop_i       => transfer_stop,
			chip_addres_i         => chip_addres_i,
			chip_address_valid_i  => chip_address_valid,
			ack_req_i             => ack_req_i,
			ack_req_o             => ack_req_o,
			data_valid_i          => data_valid_i,
			data_in_i             => data_in_i,
			data_out_o            => data_out_o,
			
			channel_enabled_o => s_channels_enabled(g_slave_count-1 downto 0)
		);
		s_channels_enabled(g_slave_count) <= '1';

end architecture;

