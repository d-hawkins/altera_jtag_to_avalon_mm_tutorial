# -----------------------------------------------------------------
# bemicro/cyclone3/share/scripts/constraints.tcl
#
# 2/21/2012 D. W. Hawkins (dwh@caltech.edu)
#
# Arrow/Altera BeMicro Cyclone III USB kit constraints.
#
# The Tcl procedures in this constraints file can be used by
# project synthesis files to setup the default device constraints
# and pinout.
#
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Device assignment
# -----------------------------------------------------------------
#
proc set_device_assignment {} {

	set_global_assignment -name FAMILY "Cyclone III"
	set_global_assignment -name DEVICE EP3C16F256C8

}

# -----------------------------------------------------------------
# Default assignments
# -----------------------------------------------------------------
#
proc set_default_assignments {} {

	# Tri-state unused I/O
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
#	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED WITH WEAK PULL-UP"

	# Set the default I/O logic standard to 3.3V
#	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVCMOS"

	# JTAG IDCODE (so that its not the default FFFFFFFF)
	set_global_assignment -name STRATIX_JTAG_USER_CODE DEADBEEF

	# Dual-purpose pins
	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"

	return
}

# -----------------------------------------------------------------
# Pin constraints
# -----------------------------------------------------------------
#
# The pin constraints can be displayed in Tcl using;
#
# tcl> get_pin_constraints pin
# tcl> parray pin
#
# The pin constraints for each pin (port) on the design are
# specified as a comma separated list of {key = value} pairs.
# The procedure set_pin_constraints converts those pairs
# into Altera Tcl constraints.
#
proc get_pin_constraints {arg} {

	# Make the input argument 'arg' visible as pin
	upvar $arg pin

	# -------------------------------------------------------------
	# Clocks
	# -------------------------------------------------------------
	#
	# 16MHz clock
	set pin(clk_16MHz)			{PIN = E2}

	# -------------------------------------------------------------
	# LEDs
	# -------------------------------------------------------------
	#
	# * LEDs turn on for low logic level
	#   - led[0] closest to FPGA
	#   - led[7] closest to USB connector
	#
	set pin(led[0])		{PIN = B4, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[1])		{PIN = C2, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[2])		{PIN = C3, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[3])		{PIN = D6, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[4])		{PIN = E6, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[5])		{PIN = B3, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[6])		{PIN = A7, DRIVE = "MAXIMUM CURRENT"}
	set pin(led[7])		{PIN = B1, DRIVE = "MAXIMUM CURRENT"}

	# -------------------------------------------------------------
	# SRAM
	# -------------------------------------------------------------
	#
	# * the user manual lists sram_dq[12] as L6
	#   but the example project Tcl script uses L4
	#
	set pin(sram_csN)			{PIN = L1}
	set pin(sram_cs)			{PIN = F2}
	set pin(sram_oeN)			{PIN = R6}
	set pin(sram_weN)			{PIN = T2}
	set pin(sram_beN[0])		{PIN = P6}
	set pin(sram_beN[1])		{PIN = P3}
	set pin(sram_addr[0])		{PIN = L3}
	set pin(sram_addr[1])		{PIN = K1}
	set pin(sram_addr[2])		{PIN = K2}
	set pin(sram_addr[3])		{PIN = J1}
	set pin(sram_addr[4])		{PIN = J2}
	set pin(sram_addr[5])		{PIN = T7}
	set pin(sram_addr[6])		{PIN = T6}
	set pin(sram_addr[7])		{PIN = R7}
	set pin(sram_addr[8])		{PIN = F1}
	set pin(sram_addr[9])		{PIN = F3}
	set pin(sram_addr[10])		{PIN = D5}
	set pin(sram_addr[11])		{PIN = D1}
	set pin(sram_addr[12])		{PIN = D3}
	set pin(sram_addr[13])		{PIN = T5}
	set pin(sram_addr[14])		{PIN = R5}
	set pin(sram_addr[15])		{PIN = T4}
	set pin(sram_addr[16])		{PIN = R4}
	set pin(sram_addr[17])		{PIN = T3}

	set pin(sram_dq[0])			{PIN = L2}
	set pin(sram_dq[1])			{PIN = N3}
	set pin(sram_dq[2])			{PIN = N1}
	set pin(sram_dq[3])			{PIN = N2}
	set pin(sram_dq[4])			{PIN = P1}
	set pin(sram_dq[5])			{PIN = P2}
	set pin(sram_dq[6])			{PIN = R1}
	set pin(sram_dq[7])			{PIN = R3}
	set pin(sram_dq[8])			{PIN = G1}
	set pin(sram_dq[9])			{PIN = G2}
	set pin(sram_dq[10])		{PIN = G5}
	set pin(sram_dq[11])		{PIN = K5}
	set pin(sram_dq[12])		{PIN = L4}
	set pin(sram_dq[13])		{PIN = M6}
	set pin(sram_dq[14])		{PIN = N6}
	set pin(sram_dq[15])		{PIN = N5}

	# -------------------------------------------------------------
	# USB Serial
	# -------------------------------------------------------------
	#
	set pin(rxd)				{PIN = C8}
	set pin(txd)				{PIN = D8}

	# -------------------------------------------------------------
	# 80-pin edge connector
	# -------------------------------------------------------------
	#
	# Reset input
	set pin(ext_rstN)			{PIN = T12}

	# Expansion board present (when high)
	set pin(exp)				{PIN = A10}

	# GPIO
	set pin(gpio[0])			{PIN = R12}
	set pin(gpio[1])			{PIN = T10}
	set pin(gpio[2])			{PIN = T13}
	set pin(gpio[3])			{PIN = R10}
	set pin(gpio[4])			{PIN = R13}
	set pin(gpio[5])			{PIN = T14}
	set pin(gpio[6])			{PIN = T11}
	set pin(gpio[7])			{PIN = R14}
	set pin(gpio[8])			{PIN = R11}
	set pin(gpio[9])			{PIN = T15}
	set pin(gpio[10])			{PIN = N11}
	set pin(gpio[11])			{PIN = R16}
	set pin(gpio[12])			{PIN = N14}
	set pin(gpio[13])			{PIN = P14}
	set pin(gpio[14])			{PIN = N12}
	set pin(gpio[15])			{PIN = P16}
	set pin(gpio[16])			{PIN = M11}
	set pin(gpio[17])			{PIN = P15}
	set pin(gpio[18])			{PIN = L11}
	set pin(gpio[19])			{PIN = N16}
	set pin(gpio[20])			{PIN = L13}
	set pin(gpio[21])			{PIN = N15}
	set pin(gpio[22])			{PIN = L14}
	set pin(gpio[23])			{PIN = L16}
	set pin(gpio[24])			{PIN = L15}
	set pin(gpio[25])			{PIN = K15}
	set pin(gpio[26])			{PIN = K12}
	set pin(gpio[27])			{PIN = K16}
	set pin(gpio[28])			{PIN = J15}
	set pin(gpio[29])			{PIN = J16}
	set pin(gpio[30])			{PIN = J14}
	set pin(gpio[31])			{PIN = H16}
	set pin(gpio[32])			{PIN = J13}
	set pin(gpio[33])			{PIN = H15}
	set pin(gpio[34])			{PIN = G16}
	set pin(gpio[35])			{PIN = J12}
	set pin(gpio[36])			{PIN = G15}
	set pin(gpio[37])			{PIN = G11}
	set pin(gpio[38])			{PIN = F16}
	set pin(gpio[39])			{PIN = F14}
	set pin(gpio[40])			{PIN = F15}
	set pin(gpio[41])			{PIN = F13}
	set pin(gpio[42])			{PIN = D15}
	set pin(gpio[43])			{PIN = E11}
	set pin(gpio[44])			{PIN = D16}
	set pin(gpio[45])			{PIN = E10}
	set pin(gpio[46])			{PIN = C15}
	set pin(gpio[47])			{PIN = D14}
	set pin(gpio[48])			{PIN = C16}
	set pin(gpio[49])			{PIN = D12}
	set pin(gpio[50])			{PIN = C14}
	set pin(gpio[51])			{PIN = A13}
	set pin(gpio[52])			{PIN = B16}
	set pin(gpio[53])			{PIN = C11}
	set pin(gpio[54])			{PIN = A15}
	set pin(gpio[55])			{PIN = C9}
	set pin(gpio[56])			{PIN = B14}
	set pin(gpio[57])			{PIN = B11}
	set pin(gpio[58])			{PIN = A14}
	set pin(gpio[59])			{PIN = A11}
	set pin(gpio[60])			{PIN = B13}
	set pin(gpio[61])			{PIN = B10}
	set pin(gpio[62])			{PIN = B12}
	set pin(gpio[63])			{PIN = A12}

	return
}

# -----------------------------------------------------------------
# Set Quartus pin assignments
# -----------------------------------------------------------------
#
# This procedure parses the entries in the Tcl pin constraints
# array and issues Quartus Tcl constraints commands.
#
proc set_pin_constraints {} {

	# Get the pin and I/O standard assignments
	get_pin_constraints pin

	# Loop over each pin in the design
	foreach port [array names pin] {

		# Convert the pin assignments into an options list,
		# eg., {PIN = AV22} { IOSTD = LVDS}
		set options [split $pin($port) ,]
		foreach option $options {

			# Split each option into a key/value pair
			set keyval [split $option =]
			set key [lindex $keyval 0]
			set val [lindex $keyval 1]

			# Strip leading and trailing whitespace
			# and force to uppercase
			set key [string toupper [string trim $key]]
			set val [string toupper [string trim $val]]

			# Make the Quartus assignments
			#
			# The keys used in the assignments list are an abbreviation of
			# the Quartus setting name. The abbreviations supported are;
			#
			#   DRIVE   = drive current
			#   HOLD    = bus hold (ON/OFF)
			#   IOSTD   = I/O standard
			#   PIN     = pin number/name
			#   PULLUP  = weak pull-up (ON/OFF)
			#   SLEW    = slew rate (a number between 0 and 3)
			#   TERMIN  = input termination (string value)
			#   TERMOUT = output termination (string value)
			#
			switch $key {
				DRIVE   {set_instance_assignment -name CURRENT_STRENGTH_NEW $val -to $port}
				HOLD    {set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY $val -to $port}
				IOSTD   {set_instance_assignment -name IO_STANDARD $val -to $port}
				PIN     {set_location_assignment -to $port "Pin_$val"}
				PULLUP  {set_instance_assignment -name WEAK_PULL_UP_RESISTOR $val -to $port}
				SLEW    {set_instance_assignment -name SLEW_RATE $val -to $port}
				TERMIN  {set_instance_assignment -name INPUT_TERMINATION $val -to $port}
				TERMOUT {set_instance_assignment -name OUTPUT_TERMINATION $val -to $port}
				default {error "Unknown setting: KEY = '$key', VALUE = '$val'"}
			}
		}
	}
}

# -----------------------------------------------------------------
# Set the default constraints
# -----------------------------------------------------------------
#
proc set_default_constraints {} {
	set_device_assignment
	set_default_assignments
	set_pin_constraints
}

