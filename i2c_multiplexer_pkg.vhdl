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
	function or_expand(slv : in std_logic_vector; operator: in std_logic) return std_logic_vector;

end package i2c_multiplexer_pkg;

package body i2c_multiplexer_pkg is

function and_reduct(slv : in std_logic_vector) return std_logic is
  variable res_v : std_logic := '1';  -- Null slv vector will also return '1'
begin
  for i in slv'range loop
    res_v := res_v and slv(i);
  end loop;
  return res_v;
end function;

function or_reduct(slv : in std_logic_vector) return std_logic is
  variable res_v : std_logic := '0';  -- Null slv vector will also return '1'
begin
  for i in slv'range loop
    res_v := res_v or slv(i);
  end loop;
  return res_v;
end function;

function or_expand(slv : in std_logic_vector; operator: in std_logic) return std_logic_vector is
	variable res_v: std_logic_vector(slv'left downto 0);
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
