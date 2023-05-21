# -----------------------------------------------------------------
# jtag_cmds_sc.tcl
#
# 2/20/2012 D. W. Hawkins (dwh@caltech.edu)
#
# JTAG-to-Avalon-MM tutorial SystemConsole commands for the
# BeMicro-SDK.
#
#  Address    Device
# ---------  --------
#  0x0000     8-bit LEDs (7-bits to the on-board LEDs)
#  0x0010     [1:0] switch state, [2] push-button state
#  0x1000     4kB of on-chip SRAM
#
# -----------------------------------------------------------------

# =================================================================
# Master access
# =================================================================
#
# -----------------------------------------------------------------
# Open the JTAG master service
# -----------------------------------------------------------------

# Open the first Avalon-MM master service
proc jtag_open {} {
	global jtag

	# Close any open service
	if {[info exists jtag(master)]} {
		jtag_close
	}

	set master_paths [get_service_paths master]
	if {[llength $master_paths] == 0} {
		puts "Sorry, no master nodes found"
		return
	}

	# Select the first master service
	set jtag(master) [lindex $master_paths 0]

	open_service master $jtag(master)
	return
}

# -----------------------------------------------------------------
# Close the JTAG master service
# -----------------------------------------------------------------
#
proc jtag_close {} {
	global jtag

	if {[info exists jtag(master)]} {
		close_service master $jtag(master)
		unset jtag(master)
	}
	return
}

# =================================================================
# Master commands
# =================================================================
#
# LED read
proc led_read {} {
	global jtag
	if {![info exists jtag(master)]} {
		jtag_open
	}
	return [master_read_8 $jtag(master) 0 1]
}

# LED write
proc led_write {val} {
	global jtag
	if {![info exists jtag(master)]} {
		jtag_open
	}
	master_write_8 $jtag(master) 0 $val
	return
}

# Switch read
proc sw {} {
	global jtag
	if {![info exists jtag(master)]} {
		jtag_open
	}
	set data [master_read_8 $jtag(master) 0x10 1]
	return [expr {$data & 0x3}]
}

# Push-button read
proc pb {} {
	global jtag
	if {![info exists jtag(master)]} {
		jtag_open
	}
	set data [master_read_8 $jtag(master) 0x10 1]
	return [expr {($data >> 2) & 1}]
}

# On-chip SRAM read (32-bit)
# * offset in bytes, 4-byte aligned
proc sram_read {offset} {
	global jtag
	if {![info exists jtag(master)]} {
		jtag_open
	}
	set addr [expr {0x1000 + ($offset & ~3)}]
	return [master_read_32 $jtag(master) $addr 1]
}

# On-chip SRAM write (32-bit)
# * offset in bytes, 4-byte aligned
proc sram_write {offset data} {
	global jtag
	if {![info exists jtag(master)]} {
		jtag_open
	}
	set addr [expr {0x1000 + ($offset & ~3)}]
	master_write_32 $jtag(master) $addr $data
	return
}





