onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 25 /axi4_lite_slave_tb/clk
add wave -noupdate -height 25 /axi4_lite_slave_tb/rst_n
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/awaddr
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/awvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/awready
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/wdata
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/wstrb
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/wvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/wready
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/bresp
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/bvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/bready
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/araddr
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/arvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/arready
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/rdata
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/rvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/rready
add wave -noupdate -height 25 /axi4_lite_slave_tb/axi_if/rresp
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/clk
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/rst_n
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/write_addr_index
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/read_addr_index
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/addr_valid_write
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/addr_valid_read
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/c_write_state
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/n_write_state
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/c_read_state
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/n_read_state
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/awaddr
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/awvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/awready
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/wdata
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/wstrb
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/wvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/wready
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/bresp
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/bvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/bready
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/araddr
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/arvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/arready
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/rdata
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/rresp
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/rvalid
add wave -noupdate -height 25 /axi4_lite_slave_tb/dut/axi_if/rready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {126 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 279
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {236 ns}
