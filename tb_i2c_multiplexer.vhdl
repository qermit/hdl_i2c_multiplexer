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


entity tb_i2c_multiplexer is
end tb_i2c_multiplexer;

architecture TestBench of tb_i2c_multiplexer is
	constant CLK_FREQ : natural := 125000000;
	constant period : time := 10 ns;
	constant i2c_period : time := 200 ns;
	constant c_change_on : std_logic := '0';
	constant c_slave_count: natural:= 1;
	
	signal clk : STD_LOGIC;
	signal rst_i : STD_LOGIC;
	
	signal slave_scl_io : STD_LOGIC_vector(c_slave_count downto 0);
	signal slave_sda_io : STD_LOGIC_vector(c_slave_count downto 0);
	signal i2c_data_recv : STD_LOGIC_vector( 7 downto 0);
	signal i2c_data_master_recv : STD_LOGIC_vector( 7 downto 0);
	signal s_ack :std_logic;

begin
	
	clock_driver : process
		
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	
	dut_i2c_multiplexer: i2c_multiplexer
		generic map(
			CLK_FREQ       => CLK_FREQ,
			g_use_tristate => true,
			g_slave_count  => c_slave_count,
			g_chip_address => x"E0"
		)
		port map(
			clk_i         => clk,
			rst_i         => rst_i,
			slave_scl_io  => slave_scl_io,
			slave_sda_io  => slave_sda_io
		);
	
	
		
	stim_proc_master : process is
	begin
		slave_scl_io(c_slave_count) <= 'H';
		slave_sda_io(c_slave_count) <= 'H';
		s_ack <= '0';
		
		wait for 15 ns - now;
		rst_i <= '1';
		wait for 30 ns - now;
		rst_i <= '0';
		wait for i2c_period;
		--wait for period / 2;
		
		tb_i2c_start(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count) ); -- command 
		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count), x"E0", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
				wait;
		end if;
		
		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count), "00000000", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
				wait;
		end if;
		
		tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
		

		tb_i2c_start(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count) ); -- command 
		
		
		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count),  x"E0", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
				wait;
		end if;
		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count), "00001000", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
				wait;
		end if;
		tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
		
		tb_i2c_start(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count) ); -- command 
		
		
				
--
--		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count), x"AB", i2c_data_recv, i2c_data_master_recv, s_ack);
--		if (s_ack = '0') then
--			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
--				wait;
--		end if;
--
--		tb_i2c_start(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
--		
--		
--		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count), "11110001", i2c_data_recv, i2c_data_master_recv, s_ack);
--		if (s_ack = '0') then
--			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
--				wait;
--		end if;
		
		tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
		wait;
	end process stim_proc_master;


	
	stim2_proc: process is
	begin
		slave_scl_io(0) <= 'H';
		slave_sda_io(0) <= 'H';
		wait for 2005 ns - now;
		--slave_sda_io(0) <= '0';
		wait for 2205 ns - now;
		slave_sda_io(0) <= 'H';
		wait;
	end process;
	
end architecture TestBench;
