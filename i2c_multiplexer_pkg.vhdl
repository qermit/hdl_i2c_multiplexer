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

package i2c_multiplexer_pkg is
	procedure tb_i2c_transmit_byte(
		constant i2c_period    : time;
		signal tmp_i2c_scl     : inout std_logic;
		signal tmp_i2c_sda     : inout std_logic;
		constant data_o        : in    std_logic_vector(7 downto 0);
		signal tmp_data_o      : out   std_logic_vector(7 downto 0);
		signal tmp_data_master : out   std_logic_vector(7 downto 0);
		signal ack_o           : out   std_logic);

	procedure tb_i2c_stop(
		constant i2c_period : time;
		signal tmp_i2c_scl  : inout std_logic;
		signal tmp_i2c_sda  : inout std_logic);

	procedure tb_i2c_start(
		constant i2c_period : time;
		signal tmp_i2c_scl  : inout std_logic;
		signal tmp_i2c_sda  : inout std_logic);

	function and_reduct(slv : in std_logic_vector) return std_logic;
	function or_reduct(slv : in std_logic_vector) return std_logic;
	function or_expand(slv : in std_logic_vector; operator : in std_logic) return std_logic_vector;

	component i2c_multiplexer
		generic(CLK_FREQ       : natural                      := 125000000;
			    g_use_tristate : boolean                      := true;
			    g_slave_count  : natural                      := 4;
			    g_chip_address : std_logic_vector(7 downto 0) := x"E0");
		port(clk_i         : in    STD_LOGIC;
			 rst_i         : in    STD_LOGIC;
			 slave_scl_io  : inout STD_LOGIC_VECTOR(g_slave_count downto 0);
			 slave_sda_io  : inout STD_LOGIC_VECTOR(g_slave_count downto 0);
			 slave_scl_i   : in    STD_LOGIC_VECTOR(g_slave_count downto 0) := (others => '1');
			 slave_sda_i   : in    STD_LOGIC_VECTOR(g_slave_count downto 0) := (others => '1');
			 slave_scl_o   : out   STD_LOGIC_VECTOR(g_slave_count downto 0);
			 slave_sda_o   : out   STD_LOGIC_VECTOR(g_slave_count downto 0);
			 slave_scl_dir : out   STD_LOGIC_VECTOR(g_slave_count downto 0);
			 slave_sda_dir : out   STD_LOGIC_VECTOR(g_slave_count downto 0));
	end component i2c_multiplexer;

	component i2c_multiplexer_ctl
		generic(g_slave_count  : natural                      := 4;
			    g_chip_address : std_logic_vector(7 downto 0) := x"E0");
		port(clk_i                : in  std_logic;
			 rst_i                : in  std_logic;
			 transfer_start_i     : in  std_logic;
			 transfer_stop_i      : in  std_logic;
			 chip_addres_i        : in  std_logic_vector(7 downto 0);
			 chip_address_valid_i : in  std_logic;
			 ack_req_i            : in  std_logic;
			 ack_req_o            : out std_logic;
			 data_valid_i         : in  std_logic;
			 data_in_i            : in  std_logic_vector(7 downto 0);
			 data_out_o           : out std_logic_vector(7 downto 0);
			 channel_enabled_o    : out std_logic_vector(g_slave_count - 1 downto 0));
	end component i2c_multiplexer_ctl;

	component i2c_multiplexer_crossbar
		generic(g_slave_count : natural := 4);
		port(clk_i                 : in  std_logic;
			 rst_i                 : in  std_logic;

			 channels_enbabled_i   : in  std_logic_vector(g_slave_count downto 0);

			 scl_i                 : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
			 sda_i                 : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
			 scl_o                 : out STD_LOGIC_VECTOR(g_slave_count downto 0);
			 sda_o                 : out STD_LOGIC_VECTOR(g_slave_count downto 0);
			 scl_dir_o             : out STD_LOGIC_VECTOR(g_slave_count downto 0);
			 sda_dir_o             : out STD_LOGIC_VECTOR(g_slave_count downto 0);
			 i2c_start_i           : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
			 i2c_stop_i            : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
			 i2c_scl_raise_i       : in  STD_LOGIC_VECTOR(g_slave_count downto 0);
			 i2c_scl_fall_i        : in  STD_LOGIC_VECTOR(g_slave_count downto 0);

			 i2c_transfer_start_o  : out std_logic;
			 i2c_transfer_stop_o   : out std_logic;
			 i2c_ack_req_o         : out std_logic;
			 i2c_ack_i             : in  std_logic;
			 i2c_chip_addr_o       : out std_logic_vector(7 downto 0);
			 i2c_chip_addr_valid_o : out std_logic;
			 i2c_valid_data_o      : out std_logic;
			 i2c_data_o            : out std_logic_vector(7 downto 0);
			 i2c_data_i            : in  std_logic_vector(7 downto 0));
	end component i2c_multiplexer_crossbar;

	component i2c_multiplexer_filter
		generic(g_use_tristate : boolean := true;
			    g_use_filter   : boolean := true);
		port(clk_i             : in    std_logic;
			 rst_i             : in    std_logic;

			 channel_enabled_i : in    std_logic;

			 m_scl_io          : inout STD_LOGIC;
			 m_sda_io          : inout STD_LOGIC;
			 m_sda_i           : in    STD_LOGIC;
			 m_scl_i           : in    STD_LOGIC;
			 m_sda_o           : out   STD_LOGIC;
			 m_scl_o           : out   STD_LOGIC;
			 m_sda_dir         : out   std_logic;
			 m_scl_dir         : out   std_logic;
			 slave_scl_in_o    : out   STD_LOGIC;
			 slave_sda_in_o    : out   STD_LOGIC;
			 slave_scl_out_i   : in    STD_LOGIC;
			 slave_sda_out_i   : in    STD_LOGIC;
			 slave_scl_dir_i   : in    STD_LOGIC;
			 slave_sda_dir_i   : in    STD_LOGIC;
			 i2c_start         : out   std_logic;
			 i2c_stop          : out   std_logic;
			 i2c_scl_raise     : out   std_logic;
			 i2c_scl_fall      : out   std_logic);
	end component i2c_multiplexer_filter;
end package i2c_multiplexer_pkg;

package body i2c_multiplexer_pkg is
	function and_reduct(slv : in std_logic_vector) return std_logic is
		variable res_v : std_logic := '1'; -- Null slv vector will also return '1'
	begin
		for i in slv'range loop
			res_v := res_v and slv(i);
		end loop;
		return res_v;
	end function;

	function or_reduct(slv : in std_logic_vector) return std_logic is
		variable res_v : std_logic := '0'; -- Null slv vector will also return '1'
	begin
		for i in slv'range loop
			res_v := res_v or slv(i);
		end loop;
		return res_v;
	end function;

	function or_expand(slv : in std_logic_vector; operator : in std_logic) return std_logic_vector is
		variable res_v : std_logic_vector(slv'left downto 0);
	begin
		for i in slv'range loop
			res_v(i) := slv(i) or operator;
		end loop;
		return res_v;
	end function;

	procedure tb_i2c_start(
		constant i2c_period : time;
		signal tmp_i2c_scl  : inout std_logic;
		signal tmp_i2c_sda  : inout std_logic) is
	begin
		tmp_i2c_sda <= 'H';
		wait for i2c_period / 4;
		tmp_i2c_scl <= 'H';
		wait for i2c_period / 4;
		tmp_i2c_sda <= '0';
		wait for i2c_period / 4;
		tmp_i2c_scl <= '0';
		wait for i2c_period / 4;
	end tb_i2c_start;

	procedure tb_i2c_stop(
		constant i2c_period : time;
		signal tmp_i2c_scl  : inout std_logic;
		signal tmp_i2c_sda  : inout std_logic) is
	begin
		tmp_i2c_sda <= '0';
		tmp_i2c_scl <= '0';
		wait for i2c_period / 4;
		tmp_i2c_scl <= 'H';
		wait for i2c_period / 4;
		--tmp_i2c_sda <= '0';
		--tmp_i2c_scl <= '1';
		--wait for i2c_period / 2;
		tmp_i2c_sda <= 'H';
		wait for i2c_period / 4;

	end tb_i2c_stop;

	procedure tb_i2c_transmit_byte(
		constant i2c_period    : time;
		signal tmp_i2c_scl     : inout std_logic;
		signal tmp_i2c_sda     : inout std_logic;
		constant data_o        : in    std_logic_vector(7 downto 0);
		signal tmp_data_o      : out   std_logic_vector(7 downto 0);
		signal tmp_data_master : out   std_logic_vector(7 downto 0);
		signal ack_o           : out   std_logic) is
	begin
		ack_o           <= '0';
		tmp_data_o      <= (others => '1');
		tmp_data_master <= (others => '1');
		for i in 7 downto 0 loop
			if (data_o(i) = '0') then
				tmp_i2c_sda <= '0';
			else
				tmp_i2c_sda <= 'H';
			end if;
			wait for i2c_period / 4;
			tmp_i2c_scl <= '1';
			wait for i2c_period / 2;
			tmp_i2c_scl <= '0';
			wait for i2c_period / 4;
		end loop;

		tmp_i2c_sda <= 'H';
		wait for i2c_period / 4;
		tmp_i2c_scl <= '1';
		wait for i2c_period / 4;
		if (tmp_i2c_sda = '0') then
			ack_o <= '1';
		else
			ack_o <= '0';
		end if;
		wait for i2c_period / 4;
		tmp_i2c_scl <= '0';
		wait for i2c_period / 4;
		tmp_i2c_sda <= '0';

	end tb_i2c_transmit_byte;

end package body i2c_multiplexer_pkg;
