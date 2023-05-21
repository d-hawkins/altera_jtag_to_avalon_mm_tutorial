# -----------------------------------------------------------------
# bemicro_sdk/cyclone4/share/scripts/constraints.tcl
#
# 1/15/2011 D. W. Hawkins (dwh@caltech.edu)
#
# Arrow/Altera BeMicro-SDK Cyclone IV kit constraints.
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

	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE22F17C7

}

# -----------------------------------------------------------------
# Default assignments
# -----------------------------------------------------------------
#
proc set_default_assignments {} {

	# Tri-state unused pins
#	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED WITH WEAK PULL-UP"

	# Set the default I/O logic standard to 3.3V
#	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVCMOS"

	# JTAG IDCODE (so that its not the default FFFFFFFF)
	set_global_assignment -name STRATIX_JTAG_USER_CODE DEADBEEF

	# Dual purpose pin nCEO (F16) is used for eth_rxd[2]
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
	# Global Clocks
	# -------------------------------------------------------------
	#
	# Input
	set pin(clkin_50MHz) {PIN = E1, IOSTD = "3.3-V LVCMOS"}

	# -------------------------------------------------------------
	# Push buttons
	# -------------------------------------------------------------
	#
	# Inputs
	set pin(cpu_rstN) {PIN = R7, IOSTD = "3.3-V LVCMOS"}
	set pin(pb)       {PIN = C2, IOSTD = "3.3-V LVCMOS"}

	# -------------------------------------------------------------
	# Switches
	# -------------------------------------------------------------
	#
	# Inputs
	set pin(sw[1])    {PIN = T14, IOSTD = "3.3-V LVCMOS"}
	set pin(sw[2])    {PIN = R13, IOSTD = "3.3-V LVCMOS"}

	# -------------------------------------------------------------
	# LEDs
	# -------------------------------------------------------------
	#
	# The LEDs use "3.3-V LVTTL" rather than "3.3-V LVCMOS" as
	# the Pin Planner shows that LVTTL has 8mA maximum current,
	# whereas LVCMOS is only 2mA.
	#
	# Outputs
	set pin(led[0])	{PIN = N15, IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[1])	{PIN = K5 , IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[2])	{PIN = P9 , IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[3])	{PIN = P15, IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[4])	{PIN = R10, IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[5])	{PIN = L13, IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[6])	{PIN = D1 , IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}
	set pin(led[7])	{PIN = B1 , IOSTD = "3.3-V LVTTL", DRIVE = "MAXIMUM CURRENT", SLEW = 2}

	# -------------------------------------------------------------
	# SPI temperature sensor
	# -------------------------------------------------------------
	#
	# Note that spi_mosi and spi_miso are actually both connected
	# to a common net on the PCB (the net TEMP_SIO).
	#
	# Outputs
	set pin(spi_sck)  {PIN = T4, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(spi_csN)  {PIN = R6, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(spi_mosi) {PIN = R5, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# Input
	set pin(spi_miso) {PIN = T5, IOSTD = "3.3-V LVCMOS"}

	# -------------------------------------------------------------
	# Ethernet PHY
	# -------------------------------------------------------------
	#
	# I2C interface
	set pin(eth_mdc)     {PIN = R14, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_mdio)    {PIN = T15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# PHY interface
	set pin(eth_tx_clk)  {PIN = E16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_rx_clk)  {PIN = E15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(eth_rstN)    {PIN = F14, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_col)     {PIN = D15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_crs)     {PIN = C15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(eth_rx_er)   {PIN = C16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_rx_dv)   {PIN = B16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_tx_en)   {PIN = G15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(eth_txd[0])  {PIN = G16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_txd[1])  {PIN = J16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_txd[2])  {PIN = J15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_txd[3])  {PIN = K16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(eth_rxd[0])  {PIN = D16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_rxd[1])  {PIN = F15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_rxd[2])  {PIN = F16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(eth_rxd[3])  {PIN = F13, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# -------------------------------------------------------------
	# MicroSD card slot
	# -------------------------------------------------------------
	#
	set pin(sd_clk)    {PIN = R4,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(sd_cmd)    {PIN = T12, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(sd_dat[0]) {PIN = R11, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(sd_dat[1]) {PIN = T6,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(sd_dat[2]) {PIN = T13, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(sd_dat[3]) {PIN = R12, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# -------------------------------------------------------------
	# Mobile DDR memory
	# -------------------------------------------------------------
	#
	# Differential clock (TODO: Define this clock as differential?)
	set pin(ddr_ck_p)   {PIN = A3,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_ck_n)   {PIN = A2,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# Controls
	set pin(ddr_csN)    {PIN = C6,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_rasN)   {PIN = A15, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_casN)   {PIN = D14, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_weN)    {PIN = C14, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_cke)    {PIN = E9,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# Data mask (write byte-enable)
	set pin(ddr_dqm[0]) {PIN = D9,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dqm[1]) {PIN = A4,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# Data strobe
	set pin(ddr_dqs[0]) {PIN = C8,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dqs[1]) {PIN = A6,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# Address outputs
	set pin(ddr_a[0])   {PIN = B3,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[1])   {PIN = C3,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[2])   {PIN = B4,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[3])   {PIN = F8,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[4])   {PIN = D11, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[5])   {PIN = D12, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[6])   {PIN = B14, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[7])   {PIN = A13, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[8])   {PIN = E11, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[9])   {PIN = A14, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[10])  {PIN = D6,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[11])  {PIN = E10, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[12])  {PIN = F9,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_a[13])  {PIN = D8,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(ddr_ba[0])  {PIN = D5,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_ba[1])  {PIN = D3,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# Bidirectional 16-bit data bus
	set pin(ddr_dq[0])  {PIN = C9,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[1])  {PIN = A10, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[2])  {PIN = B10, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[3])  {PIN = A11, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[4])  {PIN = B12, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[5])  {PIN = B11, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[6])  {PIN = B13, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[7])  {PIN = A12, IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[8])  {PIN = E8,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[9])  {PIN = E7,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[10]) {PIN = E6,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[11]) {PIN = A7,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[12]) {PIN = B7,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[13]) {PIN = B6,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[14]) {PIN = B5,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(ddr_dq[15]) {PIN = A5,  IOSTD = "1.8 V", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	# -------------------------------------------------------------
	# GPIO (expansion connector)
	# -------------------------------------------------------------
	#
	# The BeMicro and BeMicro-SDK use the same expansion header
	# (which is used by Hitex for its USB-Stick products).
	# The GPIO numbering scheme used in this constraints file
	# indexes the GPIO starting from 0, and increments the GPIO
	# number index relative to header pin number (starting from
	# the top and moving down).
	#
	# The BeMicro-SDK schematic numbers the header pins
	# P1 to P29, skips 5 pins, then has pin numbers P35 to P60,
	# and then skips 4 pins, i.e., of the 64 GPIO pins on the
	# header, the BeMicro-SDK only connects 55. The BeMicro
	# connects all 64 GPIOs.
	#
	# The numbering scheme used in this constraints file results
	# in the GPIO indexes being continuous from 0 to 54. This
	# indexing scheme is the same as used in the BeMicro
	# constraints file.
	#
	# The first four signals on the connector route to global
	# inputs, so the GPIO bus needed to be split into
	# GPIN[3:0] and GPIO[54:4].
	#

	# Reset from the expansion board
	set pin(exp_rstN)     {PIN = T3,  IOSTD = "3.3-V LVCMOS"}

	# Expansion board present (when high)
	set pin(exp_present)  {PIN = N9,  IOSTD = "3.3-V LVCMOS"}

	# GPINs
	set pin(exp_gpin[0])  {PIN = T9,  IOSTD = "3.3-V LVCMOS"}
	set pin(exp_gpin[1])  {PIN = T8,  IOSTD = "3.3-V LVCMOS"}
	set pin(exp_gpin[2])  {PIN = R9,  IOSTD = "3.3-V LVCMOS"}
	set pin(exp_gpin[3])  {PIN = R8,  IOSTD = "3.3-V LVCMOS"}

	# GPIOs
	set pin(exp_gpio[4])  {PIN = R3,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[5])  {PIN = P8,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[6])  {PIN = P6,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[7])  {PIN = P1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(exp_gpio[8])  {PIN = N8,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[9])  {PIN = M8,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[10]) {PIN = M7,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[11]) {PIN = P2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[12]) {PIN = L8,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[13]) {PIN = N6,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[14]) {PIN = L7,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[15]) {PIN = R1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(exp_gpio[16]) {PIN = M6,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[17]) {PIN = N5,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[18]) {PIN = T2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[19]) {PIN = K1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[20]) {PIN = G5,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[21]) {PIN = K2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[22]) {PIN = F3,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[23]) {PIN = P11, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(exp_gpio[24]) {PIN = N16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[25]) {PIN = L2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[26]) {PIN = L1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[27]) {PIN = P16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[28]) {PIN = R16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[29]) {PIN = P3,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[30]) {PIN = N3,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[31]) {PIN = N1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(exp_gpio[32]) {PIN = N2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[33]) {PIN = L4,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[34]) {PIN = L3,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[35]) {PIN = J2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[36]) {PIN = J1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[37]) {PIN = T11, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[38]) {PIN = T10, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[39]) {PIN = N11, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(exp_gpio[40]) {PIN = G2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[41]) {PIN = P14, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[42]) {PIN = G1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[43]) {PIN = N12, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[44]) {PIN = N14, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[45]) {PIN = L14, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[46]) {PIN = F1,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[47]) {PIN = L15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

	set pin(exp_gpio[48]) {PIN = L16, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[49]) {PIN = K15, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[50]) {PIN = F2,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[51]) {PIN = J14, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[52]) {PIN = J13, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[53]) {PIN = T7,  IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}
	set pin(exp_gpio[54]) {PIN = M10, IOSTD = "3.3-V LVCMOS", DRIVE = "MINIMUM CURRENT", SLEW = 2}

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

