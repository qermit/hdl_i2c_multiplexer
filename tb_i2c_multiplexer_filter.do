restart -nowave  -force



if { 1 } { 
add wave -noupdate -position end -label rst_i sim:/tb_i2c_multiplexer_filter/rst_i

add wave -noupdate -position end -label clk sim:/tb_i2c_multiplexer_filter/clk
}

if { 0 } {

add wave -noupdate -position end -label m_sda_io  sim:/tb_i2c_multiplexer/m_sda_io
add wave -noupdate -position end -label m_scl_io  sim:/tb_i2c_multiplexer/m_scl_io
add wave -noupdate -position end -label slave_sda_out_i  sim:/tb_i2c_multiplexer_filter/slave_sda_out_i
add wave -noupdate -position end -label slave_scl_out_i  sim:/tb_i2c_multiplexer_filter/slave_scl_out_i
add wave -noupdate -position end -label slave_sda_in_o  sim:/tb_i2c_multiplexer_filter/slave_sda_in_o
add wave -noupdate -position end -label slave_scl_in_o  sim:/tb_i2c_multiplexer_filter/slave_scl_in_o
add wave -noupdate -position end -label slave_sda_dir  sim:/tb_i2c_multiplexer_filter/slave_sda_dir_i
add wave -noupdate -position end -label slave_scl_dir  sim:/tb_i2c_multiplexer_filter/slave_scl_dir_i


add wave -noupdate -position end -label i2c_start  sim:/tb_i2c_multiplexer_filter/i2c_start
add wave -noupdate -position end -label i2c_stop  sim:/tb_i2c_multiplexer_filter/i2c_stop
add wave -noupdate -position end -label i2c_scl_raise  sim:/tb_i2c_multiplexer_filter/i2c_scl_raise
add wave -noupdate -position end -label i2c_scl_fall  sim:/tb_i2c_multiplexer_filter/i2c_scl_fall

}

if { 0 }  {

add wave -noupdate -position end -label monitor_state  sim:/tb_i2c_bridge/dut_i2c_bridge/monitor_state
add wave -noupdate -position end -label cnt  sim:/tb_i2c_bridge/dut_i2c_bridge/cnt

add wave -noupdate -position end -label r_current_byte  sim:/tb_i2c_bridge/dut_i2c_bridge/r_current_byte
add wave -noupdate -position end -label r_addr_h  sim:/tb_i2c_bridge/dut_i2c_bridge/r_addr_h
add wave -noupdate -position end -label r_addr_l  sim:/tb_i2c_bridge/dut_i2c_bridge/r_addr_l
add wave -noupdate -position end -label i2c_data_tmp  sim:/tb_i2c_bridge/dut_i2c_bridge/i2c_data_tmp

add wave -noupdate -position end -label s_sda_dir  sim:/tb_i2c_bridge/dut_i2c_bridge/s_sda_dir
add wave -noupdate -position end -label s_sda_o  sim:/tb_i2c_bridge/dut_i2c_bridge/s_sda_o

add wave -noupdate -position end -label SCL_high  sim:/tb_i2c_bridge/dut_i2c_bridge/SCL_high
add wave -noupdate -position end -label SCL_low   sim:/tb_i2c_bridge/dut_i2c_bridge/SCL_low


add wave -noupdate -position end -label s_ack  sim:/tb_i2c_bridge/s_ack


add wave -noupdate -position end -label s_slave_sda_o  sim:/tb_i2c_bridge/dut_i2c_bridge/s_slave_sda_o(0)
add wave -noupdate -position end -label s_slave_sda_dir  sim:/tb_i2c_bridge/dut_i2c_bridge/s_slave_sda_dir(0)
add wave -noupdate -position end -label s_slave_scl_o  sim:/tb_i2c_bridge/dut_i2c_bridge/s_slave_scl_o(0)
add wave -noupdate -position end -label s_slave_scl_dir  sim:/tb_i2c_bridge/dut_i2c_bridge/s_slave_scl_dir(0)



}

if { 1 } {
set RunLength 9000ns
run
wave zoom full
}