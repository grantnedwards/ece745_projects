onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clock
add wave -noupdate /top/reset
add wave -noupdate -divider rv_bus
add wave -noupdate /top/rv_bus/clk
add wave -noupdate /top/rv_bus/rst
add wave -noupdate /top/rv_bus/ready
add wave -noupdate /top/rv_bus/valid
add wave -noupdate /top/rv_bus/data
add wave -noupdate -divider {rv_bus cb}
add wave -noupdate /top/rv_bus/cb/ready
add wave -noupdate /top/rv_bus/cb/valid
add wave -noupdate /top/rv_bus/cb/data
add wave -noupdate /top/rv_bus/cb/cb_event
add wave -noupdate -divider {task drive}
add wave -noupdate /top/rv_bus/drive/data_in
add wave -noupdate /top/rv_bus/drive/delay_in
add wave -noupdate -divider {task monitor}
add wave -noupdate /top/rv_bus/monitor/data_out
add wave -noupdate -divider DUT
add wave -noupdate /top/rv_dut/ready
add wave -noupdate /top/rv_dut/bus/clk
add wave -noupdate /top/rv_dut/bus/rst
add wave -noupdate /top/rv_dut/bus/ready
add wave -noupdate /top/rv_dut/bus/valid
add wave -noupdate /top/rv_dut/bus/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {130 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 281
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
WaveRestoreZoom {0 ns} {525 ns}
