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

entity i2c_multiplexer_ctl is
	generic(
		g_slave_count  : natural                      := 4;
		g_chip_address : std_logic_vector(7 downto 0) := x"E0" -- 8 bit address, last bit is ignored
	);

	port(
		clk_i                 : in  std_logic;
		rst_i                 : in  std_logic;

		transfer_start_i	  : in  std_logic;
		transfer_stop_i 	  : in  std_logic;
		chip_addres_i         : in  std_logic_vector(7 downto 0);
		chip_address_valid_i  : in  std_logic;
		ack_req_i             : in  std_logic;
		ack_req_o             : out std_logic;
		data_valid_i          : in  std_logic;
		data_in_i             : in  std_logic_vector(7 downto 0);
		data_out_o            : out std_logic_vector(7 downto 0);

		channel_enabled_o     : out std_logic_vector(g_slave_count - 1 downto 0)
	);
end entity i2c_multiplexer_ctl;

architecture RTL of i2c_multiplexer_ctl is
	signal r_control_register : std_logic_vector(7 downto 0);
	signal s_channels_enabled: std_logic_vector(7 downto 0);
	
	signal r_ack_out: std_logic;
	signal r_rst_last: std_logic;
	
	signal s_read, s_write: std_logic;
begin
	s_read <= chip_addres_i(0);
	s_write <= not chip_addres_i(0);
	
	s_channels_enabled <= "00000001" when r_control_register(3 downto 0) = "1000" else
						  "00000010" when r_control_register(3 downto 0) = "1001" else
						  "00000100" when r_control_register(3 downto 0) = "1010" else
						  "00001000" when r_control_register(3 downto 0) = "1011" else
						  "00010000" when r_control_register(3 downto 0) = "1100" else
						  "00100000" when r_control_register(3 downto 0) = "1101" else
						  "01000000" when r_control_register(3 downto 0) = "1110" else
						  "10000000" when r_control_register(3 downto 0) = "1111" else
						  "00000000";
						  
						  
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			r_rst_last <= rst_i;
			if rst_i = '1' then
				channel_enabled_o <= (others => '0');
			end if;
			if rst_i = '0' and r_rst_last='1' then
				channel_enabled_o <= s_channels_enabled(g_slave_count - 1 downto 0);
			end if;
			if transfer_stop_i = '1' then
				channel_enabled_o <= s_channels_enabled(g_slave_count - 1 downto 0);
			end if;
		end if;
	end process;
	
	data_out_o <= r_control_register;
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				r_control_register <= "00001000"; -- channel 0 enabled by default
			elsif data_valid_i = '1' and chip_addres_i(7 downto 1) = g_chip_address (7 downto 1) and s_write='1' then
				r_control_register <= data_in_i;
			end if;
		end if;
	end process;
	
	
	proc_ack: process(clk_i) 
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				r_ack_out <= '0';
			else
				if chip_addres_i( 7 downto 1 ) =  g_chip_address (7 downto 1)  then
					r_ack_out <= '1';
				else
					r_ack_out <= '0';
				end if;
			end if;
		end if;		
	end process;
	ack_req_o <= r_ack_out;
	
end architecture RTL;
