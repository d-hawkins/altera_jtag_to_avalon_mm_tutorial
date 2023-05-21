onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sopc_system_bfm_master_tb/test_number
add wave -noupdate /sopc_system_bfm_master_tb/clk
add wave -noupdate /sopc_system_bfm_master_tb/reset_n
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/led
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/button
add wave -noupdate -divider {BFM Master}
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_write
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_read
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_address
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_byteenable
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_writedata
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_readdata
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_waitrequest
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_bfm_master/avm_readdatavalid
add wave -noupdate -divider {LED PIO}
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_led_pio/chipselect
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_led_pio/write_n
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_led_pio/address
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_led_pio/writedata
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_led_pio/readdata
add wave -noupdate -divider {Button PIO}
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_button_pio/address
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_button_pio/readdata
add wave -noupdate -divider {On-chip RAM}
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_onchip_ram/chipselect
add wave -noupdate /sopc_system_bfm_master_tb/dut/the_onchip_ram/write
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_onchip_ram/address
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_onchip_ram/byteenable
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_onchip_ram/readdata
add wave -noupdate -radix hexadecimal /sopc_system_bfm_master_tb/dut/the_onchip_ram/writedata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {480277 ps} 0}
configure wave -namecolwidth 342
configure wave -valuecolwidth 85
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {66412500 ps}
