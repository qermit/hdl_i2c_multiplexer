library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_multiplexer_filter is
	generic(
		g_use_tristate : boolean := true;
		g_use_filter   : boolean := true
	);
	port(
		clk_i         : in    std_logic;
		rst_i         : in    std_logic;

		m_scl_io      : inout STD_LOGIC;
		m_sda_io      : inout STD_LOGIC;

		m_sda_i       : in    STD_LOGIC;
		m_scl_i       : in    STD_LOGIC;

		m_sda_o       : out   STD_LOGIC;
		m_scl_o       : out   STD_LOGIC;
		m_sda_dir     : out   std_logic;
		m_scl_dir     : out   std_logic;

		slave_scl_in_o  : out    STD_LOGIC;
		slave_sda_in_o  : out   STD_LOGIC;
		slave_scl_out_i : in   STD_LOGIC;
		slave_sda_out_i : in   STD_LOGIC;
		slave_scl_dir_i : in   STD_LOGIC;
		slave_sda_dir_i : in   STD_LOGIC;
		
		
		i2c_start : out std_logic;
		i2c_stop : out std_logic;
		i2c_scl_raise: out std_logic;
		i2c_scl_fall: out std_logic
		
		
	);
end entity i2c_multiplexer_filter;

architecture RTL of i2c_multiplexer_filter is
	
	signal s_sda_i, s_scl_i                 : std_logic;
	signal s_sda_o, s_scl_o                 : std_logic;
	-- filter master
	signal SCL_Q1, SCL_Q2, SCL_EN: std_logic;
    signal SDA_Q1, SDA_Q2, SDA_EN: std_logic;


   signal start, stop: std_logic;
   signal SDA_sig_prev,SCL_sig_prev: std_logic;
   signal scl_raise, scl_fall: std_logic;
begin
	

	GEN_USE_TRISTATE : if g_use_tristate = true generate
		m_scl_io <= '0' when slave_scl_dir_i = '1' and slave_scl_out_i = '0' else 'Z';
		m_sda_io <= '0' when slave_sda_dir_i = '1' and slave_sda_out_i = '0' else 'Z';
		
		s_sda_i  <= '0' when m_sda_io = '0' else '1';
		s_scl_i  <= '0' when m_scl_io = '0' else '1';
	end generate GEN_USE_TRISTATE;

	GEN_USE_RAW : if g_use_tristate /= true generate
		s_sda_i   <= '0' when m_sda_i = '0' else '1';
		s_scl_i   <= '0' when m_scl_i = '0' else '1';
		m_sda_o   <= slave_sda_out_i;
		m_scl_o   <= slave_scl_out_i;
		m_scl_dir <= slave_scl_dir_i;
		m_sda_dir <= slave_sda_dir_i;
	end generate GEN_USE_RAW;

slave_sda_in_o <= s_sda_o;
slave_scl_in_o <= s_scl_o;
GEN_DONT_USE_FILTER : if g_use_filter = false generate
	SCL_Q1 <= s_scl_i;
	SCL_Q2 <= s_scl_i;
	SDA_Q1 <= s_sda_i;
	SDA_Q2 <= s_sda_i;

	SCL_antyglitch : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				s_sda_o <= '1';
				s_scl_o <= '1';
			else
				if (SCL_EN = '1') then
					s_scl_o <= SCL_Q2;
				end if;
				if (SDA_EN = '1') then
					s_sda_o <= SDA_Q2;
				end if;

			end if;
		end if;
	end process;
	
end generate GEN_DONT_USE_FILTER;

SCL_EN <= not (SCL_Q2 xor SCL_Q1);
SDA_EN <= not (SDA_Q2 xor SDA_Q1);


GEN_USE_FILTER : if g_use_filter = true generate

	SCL_antyglitch : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				SCL_Q1  <= '1';
				SCL_Q2  <= '1';
				SDA_Q1  <= '1';
				SDA_Q2  <= '1';
				s_sda_o <= '1';
				s_scl_o <= '1';
			else
				SDA_Q1 <= s_sda_i;
				SDA_Q2 <= SDA_Q1;
				SCL_Q1 <= s_scl_i;
				SCL_Q2 <= SCL_Q1;
				if (SCL_EN = '1') then
					s_scl_o <= SCL_Q2;
				end if;
				if (SDA_EN = '1') then
					s_sda_o <= SDA_Q2;
				end if;

			end if;
		end if;
	end process;

end generate GEN_USE_FILTER;


start <= SDA_sig_prev and not SDA_Q2 and not SDA_Q2 and SCL_sig_prev;
stop  <= not SDA_sig_prev and SDA_Q2 and SDA_Q2 and SCL_sig_prev;

process_StartStopDetect : process(clk_i)
begin
  if rising_edge(clk_i) then
	if (rst_i = '1') then
		SDA_sig_prev <= '0';
	elsif clk_i'event and clk_i='1' then
		if SCL_EN = '1' then
			SDA_sig_prev <= SDA_Q2;
		end if;
	end if;
  end if;
end process;

i2c_start <= start;
i2c_stop <= stop;


--scl_raise <= SCL_sig_prev and 
scl_raise <= not SCL_sig_prev and SCL_Q2 and SCL_Q1;
scl_fall  <= SCL_sig_prev and not SCL_Q2 and not SCL_Q1;

process_SCLDetect : process(clk_i)
begin
	if rising_edge(clk_i) then
		if (rst_i = '1') then
			SCL_sig_prev     <= '0';
		else
			if SCL_EN = '1' then
				SCL_sig_prev <= SCL_Q2;
			end if;
		end if;
	end if;
end process;

i2c_scl_raise <= scl_raise;
i2c_scl_fall <= scl_fall;

end architecture RTL;


	
