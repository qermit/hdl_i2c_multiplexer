

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
	
	
	dut_i2c_multiplexer: entity work.i2c_multiplexer
		generic map(
			CLK_FREQ       => CLK_FREQ,
			g_use_tristate => true,
			g_slave_count  => c_slave_count
		)
		port map(
			clk_i         => clk,
			rst_i         => rst_i,
			slave_scl_io  => slave_scl_io,
			slave_sda_io  => slave_sda_io,
			slave_scl_i   => (others => '1'),
			slave_sda_i   => (others => '1'),
			slave_scl_o   => open,
			slave_sda_o   => open,
			slave_scl_dir => open,
			slave_sda_dir => open
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
		
--		tb_i2c_transmit_byte(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count), "10000000", i2c_data_recv, i2c_data_master_recv, s_ack);
--		if (s_ack = '0') then
--			tb_i2c_stop(i2c_period, slave_scl_io(c_slave_count), slave_sda_io(c_slave_count));
--				wait;
--		end if;
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
