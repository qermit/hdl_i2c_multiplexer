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
		g_slave_count  : natural := 4
	);
	Port(clk_i         : in    STD_LOGIC;
		 rst_i         : in    STD_LOGIC;

		 slave_scl_io  : inout STD_LOGIC_VECTOR(g_slave_count downto 0);
		 slave_sda_io  : inout STD_LOGIC_VECTOR(g_slave_count downto 0);

		 slave_scl_i   : in    STD_LOGIC_VECTOR(g_slave_count downto 0);
		 slave_sda_i   : in    STD_LOGIC_VECTOR(g_slave_count downto 0);
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

	signal r_channels_active : std_logic_vector(g_slave_count - 1 downto 0);
	-- components

	component i2c_multiplexer_filter
		generic(g_use_tristate : boolean := true;
			    g_use_filter   : boolean := true);
		port(clk_i           : in    std_logic;
			 rst_i           : in    std_logic;
			 m_scl_io        : inout STD_LOGIC;
			 m_sda_io        : inout STD_LOGIC;
			 m_sda_i         : in    STD_LOGIC;
			 m_scl_i         : in    STD_LOGIC;
			 m_sda_o         : out   STD_LOGIC;
			 m_scl_o         : out   STD_LOGIC;
			 m_sda_dir       : out   std_logic;
			 m_scl_dir       : out   std_logic;
			 slave_scl_in_o  : out   STD_LOGIC;
			 slave_sda_in_o  : out   STD_LOGIC;
			 slave_scl_out_i : in    STD_LOGIC;
			 slave_sda_out_i : in    STD_LOGIC;
			 slave_scl_dir_i : in    STD_LOGIC;
			 slave_sda_dir_i : in    STD_LOGIC;
			 i2c_start       : out   std_logic;
			 i2c_stop        : out   std_logic;
			 i2c_scl_raise   : out   std_logic;
			 i2c_scl_fall    : out   std_logic);
	end component i2c_multiplexer_filter;

	component i2c_multiplexer_crossbar
		generic(g_slave_count : natural := 4);
		port(clk_i            : in  std_logic;
			 rst_i            : in  std_logic;
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

			 i2c_ack_req_o    : out std_logic;
			 i2c_ack_i        : in  std_logic;
			 i2c_chip_addr_o  : out std_logic_vector(7 downto 0);
			 i2c_valid_data_o : out std_logic;
			 i2c_data_o       : out std_logic_vector(7 downto 0);
			 i2c_data_i       : in  std_logic_vector(7 downto 0));
	end component i2c_multiplexer_crossbar;
	
	component i2c_multiplexer_ctl
		generic(g_slave_count  : natural                      := 4;
			    g_chip_address : std_logic_vector(7 downto 0) := x"E0");
		port(clk_i                 : in  std_logic;
			 rst_i                 : in  std_logic;
			 transfer_start_i      : in  std_logic;
			 transfer_stop_i       : in  std_logic;
			 chip_addres_i         : in  std_logic_vector(7 downto 0);
			 ack_req_i             : in  std_logic;
			 ack_req_o             : out std_logic;
			 data_valid_i          : in  std_logic;
			 data_in_i             : in  std_logic_vector(7 downto 0);
			 data_out_o            : out std_logic_vector(7 downto 0);
			 channel_disable_req_o : out std_logic_vector(g_slave_count - 1 downto 0);
			 channel_enable_req_o  : out std_logic_vector(g_slave_count - 1 downto 0);
			 channel_enabled_i     : in  std_logic_vector(g_slave_count downto 0));
	end component i2c_multiplexer_ctl;

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
			
			i2c_ack_i        => ack_req_o,
			i2c_ack_req_o    => ack_req_i,
			i2c_data_i       => data_out_o,
			i2c_data_o       => data_in_i,
			i2c_chip_addr_o  => chip_addres_i,
			i2c_valid_data_o => data_valid_i
		);

	inst_i2c_ctrl: i2c_multiplexer_ctl
		generic map(
			g_slave_count  => g_slave_count,
			g_chip_address => x"E0"
		)
		port map(
			clk_i                 => clk_i,
			rst_i                 => rst_i,
			transfer_start_i      => '0',
			transfer_stop_i       => '0',
			chip_addres_i         => chip_addres_i,
			ack_req_i             => ack_req_i,
			ack_req_o             => ack_req_o,
			data_valid_i          => data_valid_i,
			data_in_i             => data_in_i,
			data_out_o            => data_out_o,
			
			channel_disable_req_o => open,
			channel_enable_req_o  => open,
			channel_enabled_i     => (others => '1')
		);
--s_scl_o(g_slave_count) <= and_reduct(s_scl_i(g_slave_count-1 downto 0));
--s_sda_o(g_slave_count) <= and_reduct(s_sda_i(g_slave_count-1 downto 0));
--
--GEN_I2C_SLAVE2 : for i in 0 to g_slave_count-1 generate
--	s_scl_o(i) <= s_scl_i(g_slave_count) or not r_channels_active(i);
--	s_sda_o(i) <= s_sda_i(g_slave_count) or not r_channels_active(i);
--end generate GEN_I2C_SLAVE2;


end architecture;

