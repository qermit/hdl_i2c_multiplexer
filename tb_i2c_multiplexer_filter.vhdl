

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


use work.i2c_multiplexer_pkg.all;


entity tb_i2c_multiplexer_filter is
end tb_i2c_multiplexer_filter;

architecture Behavioral of tb_i2c_multiplexer_filter is
	constant CLK_FREQ : natural := 125000000;
	constant period : time := 10 ns;
	constant i2c_period : time := 200 ns;
	constant c_change_on : std_logic := '0';
	
	
	signal clk : STD_LOGIC;
	signal rst_i : STD_LOGIC;
	signal m_scl_io : STD_LOGIC;
	signal m_sda_io : STD_LOGIC;

	
	signal i2c_data_recv: std_logic_vector(7 downto 0);
	signal i2c_data_master_recv: std_logic_vector(7 downto 0);
	
	signal s_ack : std_logic;
	signal i2c_start : std_logic;
	signal i2c_stop : std_logic;
	signal i2c_scl_raise : std_logic;
	signal i2c_scl_fall : std_logic;
	signal slave_scl_in_o : STD_LOGIC;
	signal slave_sda_in_o : STD_LOGIC;
	signal slave_scl_out_i : STD_LOGIC;
	signal slave_scl_dir_i : STD_LOGIC;
	signal slave_sda_out_i : STD_LOGIC;
	signal slave_sda_dir_i : STD_LOGIC;
	

begin
	
	clock_driver : process
		
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	
	
	dut_i2c_filter: entity work.i2c_multiplexer_filter
		generic map(
			g_use_tristate => true,
			g_use_filter   => true
		)
		port map(
			clk_i           => clk,
			rst_i           => rst_i,
			m_scl_io        => m_scl_io,
			m_sda_io        => m_sda_io,
			m_sda_i         => '1',
			m_scl_i         => '1',
			m_sda_o         => open,
			m_scl_o         => open,
			m_sda_dir       => open,
			m_scl_dir       => open,
			
			slave_scl_in_o  => slave_scl_in_o,
			slave_sda_in_o  => slave_sda_in_o,
			slave_scl_out_i => slave_scl_out_i,
			slave_sda_out_i => slave_sda_out_i,
			slave_scl_dir_i => slave_scl_dir_i,
			slave_sda_dir_i => slave_sda_dir_i,
			
			i2c_start       => i2c_start,
			i2c_stop        => i2c_stop,
			i2c_scl_raise   => i2c_scl_raise,
			i2c_scl_fall    => i2c_scl_fall
		);
	
	stim_proc : process is
	begin
		m_sda_io <= 'H';
		m_scl_io <= 'H';
		s_ack <= '0';
		
		wait for 15 ns - now;
		rst_i <= '1';
		wait for 30 ns - now;
		rst_i <= '0';
		wait for i2c_period;
		--wait for period / 2;
		
		tb_i2c_start(i2c_period, m_scl_io, m_sda_io ); -- command 
		tb_i2c_transmit_byte(i2c_period, m_scl_io, m_sda_io, "11110000", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, m_scl_io, m_sda_io);
				wait;
		end if;
--		
		tb_i2c_transmit_byte(i2c_period, m_scl_io, m_sda_io, "10000000", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, m_scl_io, m_sda_io);
				wait;
		end if;
--		
		tb_i2c_transmit_byte(i2c_period, m_scl_io, m_sda_io, x"AB", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, m_scl_io, m_sda_io);
				wait;
		end if;

		tb_i2c_start(i2c_period, m_scl_io, m_sda_io);
		
		
		tb_i2c_transmit_byte(i2c_period, m_scl_io, m_sda_io, "11110001", i2c_data_recv, i2c_data_master_recv, s_ack);
		if (s_ack = '0') then
			tb_i2c_stop(i2c_period, m_scl_io, m_sda_io);
				wait;
		end if;
		
		tb_i2c_stop(i2c_period, m_scl_io, m_sda_io);
		wait;
	end process stim_proc;


	
	stim2_proc: process is
	begin
		slave_scl_out_i <= '1';
		slave_scl_dir_i <= '0';
		
		
		slave_sda_out_i <= '0';
		slave_sda_dir_i <= '0';
		
		wait for 2030 ns - now;
		slave_sda_dir_i <= '1';
		wait for 2230 ns - now;
		slave_sda_dir_i <= '0';
--		slave_sda_io(0) <= '0';
--		wait for 4000 ns - now; 
--		slave_sda_io(0) <= 'H'; 
--		wait for 5600 ns - now;
--		slave_sda_io(0) <= '0';
--		wait for 5800 ns - now; 
--		slave_sda_io(0) <= 'H'; 
		wait;
	end process;
	
end architecture Behavioral;
