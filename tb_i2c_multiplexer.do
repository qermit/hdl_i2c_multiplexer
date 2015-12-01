restart -nowave  -force



if { 1 } { 
add wave -noupdate -position end -label rst_i sim:/tb_i2c_multiplexer/rst_i

add wave -noupdate -position end -label clk sim:/tb_i2c_multiplexer/clk
}

if { 1 } {

add wave -noupdate -divider -height 16 "I2C MASTER"

add wave -noupdate -position end -label m_sda_io  sim:/tb_i2c_multiplexer/slave_sda_io(1)
add wave -noupdate -position end -label m_scl_io  sim:/tb_i2c_multiplexer/slave_scl_io(1)

add wave -noupdate -position end -label m_sda_o  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_sda_o(1)
add wave -noupdate -position end -label m_scl_o  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_scl_o(1)
add wave -noupdate -position end -label m_sda_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_sda_i(1)
add wave -noupdate -position end -label m_scl_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_scl_i(1)
add wave -noupdate -position end -label m_sda_dir  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_sda_dir(1)
add wave -noupdate -position end -label m_scl_dir  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_scl_dir(1)


add wave -noupdate -position end -label m_stop sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_stop_i(1)
add wave -noupdate -position end -label m_start sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_start_i(1)
add wave -noupdate -position end -label m_scl_rise sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_scl_raise_i(1)
add wave -noupdate -position end -label m_scl_fall sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_scl_fall_i(1)

}

if { 0 } {
add wave -noupdate -divider -height 16 "I2C SLAVE"

add wave -noupdate -position end -label s_sda_io  sim:/tb_i2c_multiplexer/slave_sda_io(0)
add wave -noupdate -position end -label s_scl_io  sim:/tb_i2c_multiplexer/slave_scl_io(0)

add wave -noupdate -position end -label s_sda_o  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_sda_o(0)
add wave -noupdate -position end -label s_scl_o  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_scl_o(0)
add wave -noupdate -position end -label s_sda_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_sda_i(0)
add wave -noupdate -position end -label s_scl_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_scl_i(0)
add wave -noupdate -position end -label s_sda_dir  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_sda_dir(0)
add wave -noupdate -position end -label s_scl_dir  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/s_scl_dir(0)

add wave -noupdate -position end -label s_stop sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_stop_i(0)
add wave -noupdate -position end -label s_start sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_start_i(0)
add wave -noupdate -position end -label s_scl_rise sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_scl_raise_i(0)
add wave -noupdate -position end -label s_scl_fall sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/i2c_scl_fall_i(0)


}

if { 1 } {

add wave -noupdate -divider -height 16 CROSSBAR
add wave -noupdate -position end -label r_counter  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_counter


add wave -noupdate -position end -label s_master_write sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_write
add wave -noupdate -position end -label r_idle  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_idle
add wave -noupdate -position end -label r_current_master  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_current_master
add wave -noupdate -position end -label r_current_slave  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_current_slave
add wave -noupdate -position end -label r_current_busy  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_current_busy
add wave -noupdate -position end -label r_current_enabled  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_current_enabled
add wave -noupdate -position end -label r_req_enable  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_req_enable
add wave -noupdate -position end -label r_req_disable  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/r_req_disable
add wave -noupdate -position end -label s_req_enable  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_req_enable
add wave -noupdate -position end -label s_req_disable  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_req_disable

add wave -noupdate -position end -label s_master_scl_raise  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_scl_raise
add wave -noupdate -position end -label s_master_scl_fall  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_scl_fall
add wave -noupdate -position end -label s_master_start  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_start
add wave -noupdate -position end -label s_master_stop  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_stop
add wave -noupdate -position end -label s_master_scl  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_scl
add wave -noupdate -position end -label s_master_sda  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_master_sda
add wave -noupdate -position end -label s_slave_sda  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_crossbar/s_slave_sda

}

if { 1 }  {

add wave -noupdate -divider -height 16 CTL
add wave -noupdate -position end -label chip_addres_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/chip_addres_i
add wave -noupdate -position end -label s_read  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/s_read
add wave -noupdate -position end -label s_write  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/s_write
add wave -noupdate -position end -label r_ack_out  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/r_ack_out
add wave -noupdate -position end -label data_valid_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/data_valid_i
add wave -noupdate -position end -label data_in_i  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/data_in_i
add wave -noupdate -position end -label data_out_o  sim:/tb_i2c_multiplexer/dut_i2c_multiplexer/inst_i2c_ctrl/data_out_o

}

if { 1 } {
set RunLength 6500ns
run
wave zoom full
}