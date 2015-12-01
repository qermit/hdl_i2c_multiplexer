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
		ack_req_i             : in  std_logic;
		ack_req_o             : out std_logic;
		data_valid_i          : in  std_logic;
		data_in_i             : in  std_logic_vector(7 downto 0);
		data_out_o            : out std_logic_vector(7 downto 0);

		channel_disable_req_o : out std_logic_vector(g_slave_count - 1 downto 0);
		channel_enable_req_o  : out std_logic_vector(g_slave_count - 1 downto 0);
		channel_enabled_i     : in  std_logic_vector(g_slave_count downto 0)
	);
end entity i2c_multiplexer_ctl;

architecture RTL of i2c_multiplexer_ctl is
	signal r_control_register : std_logic_vector(7 downto 0);
	
	signal r_have_address : std_logic; 
	
	signal r_ack_out: std_logic;
	
	signal s_read, s_write: std_logic;
begin
	s_read <= chip_addres_i(0);
	s_write <= not chip_addres_i(0);
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				r_control_register <= (others => '0');
				r_have_address <= '0';
			elsif transfer_start_i = '1' then
				r_have_address <= '0';
			elsif data_valid_i = '1' and chip_addres_i(7 downto 1) = g_chip_address (7 downto 1) then
				if r_have_address = '1' then
					r_control_register <= std_logic_vector(unsigned(r_control_register) + 1) ;
				else
					r_control_register <= data_in_i;
				end if;
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
	
	data_out_o <= x"8A";
	
end architecture RTL;
