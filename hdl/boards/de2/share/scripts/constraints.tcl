# -----------------------------------------------------------------
# de2/cyclone2/share/scripts/constraints.tcl
#
# 2/21/2012 D. W. Hawkins (dwh@caltech.edu)
#
# Terasic/Altera DE2 Cyclone II kit constraints.
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

	set_global_assignment -name FAMILY "Cyclone II"
	set_global_assignment -name DEVICE EP2C35F672C6

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
	#
	# * The Cyclone II I/O standards for "3.3-V LVCMOS" and "3.3-V LVTTL"
	#   have the same drive current options, so the default I/O standard
	#   can be either setting.
	#
#	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVCMOS"

	# JTAG IDCODE (so that its not the default FFFFFFFF)
	set_global_assignment -name STRATIX_JTAG_USER_CODE DEADBEEF

	# Dual-purpose pins
	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS INPUT TRI-STATED"

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
	# Inputs
	set pin(clk_50MHz)  {PIN = N2}
	set pin(clk_27MHz)  {PIN = D13}
	set pin(clk_sma)    {PIN = P26}

	# -----------------------------------------------------------------
	# Push-button inputs
	# -----------------------------------------------------------------
	#
	set pin(key[0])     {PIN = G26}
	set pin(key[1])     {PIN = N23}
	set pin(key[2])     {PIN = P23}
	set pin(key[3])     {PIN = W26}

	# -----------------------------------------------------------------
	# Switch inputs
	# -----------------------------------------------------------------
	#
	set pin(sw[0])      {PIN = N25}
	set pin(sw[1])      {PIN = N26}
	set pin(sw[2])      {PIN = P25}
	set pin(sw[3])      {PIN = AE14}
	set pin(sw[4])      {PIN = AF14}
	set pin(sw[5])      {PIN = AD13}
	set pin(sw[6])      {PIN = AC13}
	set pin(sw[7])      {PIN = C13}
	set pin(sw[8])      {PIN = B13}
	set pin(sw[9])      {PIN = A13}
	set pin(sw[10])     {PIN = N1}
	set pin(sw[11])     {PIN = P1}
	set pin(sw[12])     {PIN = P2}
	set pin(sw[13])     {PIN = T7}
	set pin(sw[14])     {PIN = U3}
	set pin(sw[15])     {PIN = U4}
	set pin(sw[16])     {PIN = V1}
	set pin(sw[17])     {PIN = V2}

	# -----------------------------------------------------------------
	# Red and Green LEDs
	# -----------------------------------------------------------------
	#
	# The LEDs were testing with the I/O DRIVE set to "MAXIMUM CURRENT"
	# and to "MINIMUM CURRENT", but it made no difference to their
	# brightness. Set the current to minimum.
	#
	#
	set pin(led_r[0])  {PIN = AE23, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[1])  {PIN = AF23, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[2])  {PIN = AB21, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[3])  {PIN = AC22, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[4])  {PIN = AD22, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[5])  {PIN = AD23, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[6])  {PIN = AD21, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[7])  {PIN = AC21, DRIVE = "MINIMUM CURRENT"}

	set pin(led_r[8])  {PIN = AA14, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[9])  {PIN = Y13,  DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[10]) {PIN = AA13, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[11]) {PIN = AC14, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[12]) {PIN = AD15, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[13]) {PIN = AE15, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[14]) {PIN = AF13, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[15]) {PIN = AE13, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[16]) {PIN = AE12, DRIVE = "MINIMUM CURRENT"}
	set pin(led_r[17]) {PIN = AD12, DRIVE = "MINIMUM CURRENT"}

	set pin(led_g[0])  {PIN = AE22, DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[1])  {PIN = AF22, DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[2])  {PIN = W19,  DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[3])  {PIN = V18,  DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[4])  {PIN = U18,  DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[5])  {PIN = U17,  DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[6])  {PIN = AA20, DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[7])  {PIN = Y18,  DRIVE = "MINIMUM CURRENT"}
	set pin(led_g[8])  {PIN = Y12,  DRIVE = "MINIMUM CURRENT"}

	# -----------------------------------------------------------------
	# Hex displays
	# -----------------------------------------------------------------
	#
	set pin(hex_a[0]) {PIN = AF10, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_a[1]) {PIN = AB12, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_a[2]) {PIN = AC12, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_a[3]) {PIN = AD11, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_a[4]) {PIN = AE11, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_a[5]) {PIN = V14,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_a[6]) {PIN = V13,  DRIVE = "MINIMUM CURRENT"}

	set pin(hex_b[0]) {PIN = V20,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_b[1]) {PIN = V21,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_b[2]) {PIN = W21,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_b[3]) {PIN = Y22,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_b[4]) {PIN = AA24, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_b[5]) {PIN = AA23, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_b[6]) {PIN = AB24, DRIVE = "MINIMUM CURRENT"}

	set pin(hex_c[0]) {PIN = AB23, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_c[1]) {PIN = V22,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_c[2]) {PIN = AC25, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_c[3]) {PIN = AC26, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_c[4]) {PIN = AB26, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_c[5]) {PIN = AB25, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_c[6]) {PIN = Y24,  DRIVE = "MINIMUM CURRENT"}

	set pin(hex_d[0]) {PIN = Y23,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_d[1]) {PIN = AA25, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_d[2]) {PIN = AA26, DRIVE = "MINIMUM CURRENT"}
	set pin(hex_d[3]) {PIN = Y26,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_d[4]) {PIN = Y25,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_d[5]) {PIN = U22,  DRIVE = "MINIMUM CURRENT"}
	set pin(hex_d[6]) {PIN = W24,  DRIVE = "MINIMUM CURRENT"}

	set pin(hex_e[0]) {PIN = U9,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_e[1]) {PIN = U1,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_e[2]) {PIN = U2,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_e[3]) {PIN = T4,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_e[4]) {PIN = R7,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_e[5]) {PIN = R6,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_e[6]) {PIN = T3,   DRIVE = "MINIMUM CURRENT"}

	set pin(hex_f[0]) {PIN = T2,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_f[1]) {PIN = P6,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_f[2]) {PIN = P7,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_f[3]) {PIN = T9,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_f[4]) {PIN = R5,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_f[5]) {PIN = R4,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_f[6]) {PIN = R3,   DRIVE = "MINIMUM CURRENT"}

	set pin(hex_g[0]) {PIN = R2,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_g[1]) {PIN = P4,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_g[2]) {PIN = P3,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_g[3]) {PIN = M2,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_g[4]) {PIN = M3,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_g[5]) {PIN = M5,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_g[6]) {PIN = M4,   DRIVE = "MINIMUM CURRENT"}

	set pin(hex_h[0]) {PIN = L3,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_h[1]) {PIN = L2,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_h[2]) {PIN = L9,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_h[3]) {PIN = L6,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_h[4]) {PIN = L7,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_h[5]) {PIN = P9,   DRIVE = "MINIMUM CURRENT"}
	set pin(hex_h[6]) {PIN = N9,   DRIVE = "MINIMUM CURRENT"}

	# -----------------------------------------------------------------
	# Character LCD
	# -----------------------------------------------------------------
	#
	set pin(lcd_on)   {PIN = L4}
	set pin(lcd_blon) {PIN = K2}
	set pin(lcd_rs)   {PIN = K1}
	set pin(lcd_en)   {PIN = K3}
	set pin(lcd_rw)   {PIN = K4}
	set pin(lcd_d[0]) {PIN = J1}
	set pin(lcd_d[1]) {PIN = J2}
	set pin(lcd_d[2]) {PIN = H1}
	set pin(lcd_d[3]) {PIN = H2}
	set pin(lcd_d[4]) {PIN = J4}
	set pin(lcd_d[5]) {PIN = J3}
	set pin(lcd_d[6]) {PIN = H4}
	set pin(lcd_d[7]) {PIN = H3}

	# -----------------------------------------------------------------
	# USB OTG Controller
	# -----------------------------------------------------------------
	#
	set pin(otg_resetN)     {PIN = G5}
	set pin(otg_csN)        {PIN = F1}
	set pin(otg_rdN)        {PIN = G2}
	set pin(otg_wrN)        {PIN = G1}
	set pin(otg_fspeed)     {PIN = F3}
	set pin(otg_lspeed)     {PIN = G6}
	set pin(otg_irq[0])     {PIN = B3}
	set pin(otg_irq[1])     {PIN = C3}
	set pin(otg_dreq[0])    {PIN = F6}
	set pin(otg_dreq[1])    {PIN = E5}
	set pin(otg_dackN[0])   {PIN = C2}
	set pin(otg_dackN[1])   {PIN = B2}

	set pin(otg_addr[0])    {PIN = K7}
	set pin(otg_addr[1])    {PIN = F2}

	set pin(otg_dq[0])      {PIN = F4}
	set pin(otg_dq[1])      {PIN = D2}
	set pin(otg_dq[2])      {PIN = D1}
	set pin(otg_dq[3])      {PIN = F7}
	set pin(otg_dq[4])      {PIN = J5}
	set pin(otg_dq[5])      {PIN = J8}
	set pin(otg_dq[6])      {PIN = J7}
	set pin(otg_dq[7])      {PIN = H6}
	set pin(otg_dq[8])      {PIN = E2}
	set pin(otg_dq[9])      {PIN = E1}
	set pin(otg_dq[10])     {PIN = K6}
	set pin(otg_dq[11])     {PIN = K5}
	set pin(otg_dq[12])     {PIN = G4}
	set pin(otg_dq[13])     {PIN = G3}
	set pin(otg_dq[14])     {PIN = J6}
	set pin(otg_dq[15])     {PIN = K8}

	# -----------------------------------------------------------------
	# Audio interface
	# -----------------------------------------------------------------
	#
	set pin(aud_adclrck)    {PIN = C5}
	set pin(aud_daclrck)    {PIN = C6}
	set pin(aud_dacdat)     {PIN = A4}
	set pin(aud_bclk)       {PIN = B4}
	set pin(aud_xck)        {PIN = A5}
	set pin(aud_adcdat)     {PIN = B5}

	# -----------------------------------------------------------------
	# I2C bus (audio interface and TV decoder control)
	# -----------------------------------------------------------------
	#
	set pin(i2c_sdat)       {PIN = B6}
	set pin(i2c_sclk)       {PIN = A6}

	# -----------------------------------------------------------------
	# TV Decoder
	# -----------------------------------------------------------------
	#
	set pin(td_resetN)      {PIN = C4}
	set pin(td_hs)          {PIN = D5}
	set pin(td_vs)          {PIN = K9}
	set pin(td_d[0])        {PIN = J9}
	set pin(td_d[1])        {PIN = E8}
	set pin(td_d[2])        {PIN = H8}
	set pin(td_d[3])        {PIN = H10}
	set pin(td_d[4])        {PIN = G9}
	set pin(td_d[5])        {PIN = F9}
	set pin(td_d[6])        {PIN = D7}
	set pin(td_d[7])        {PIN = C7}

	# -----------------------------------------------------------------
	# VGA
	# -----------------------------------------------------------------
	#
	set pin(vga_blankN)     {PIN = D6}
	set pin(vga_syncN)      {PIN = B7}
	set pin(vga_hs)         {PIN = A7}
	set pin(vga_vs)         {PIN = D8}
	set pin(vga_clock)      {PIN = B8}

	set pin(vga_r[0])       {PIN = C8}
	set pin(vga_r[1])       {PIN = F10}
	set pin(vga_r[2])       {PIN = G10}
	set pin(vga_r[3])       {PIN = D9}
	set pin(vga_r[4])       {PIN = C9}
	set pin(vga_r[5])       {PIN = A8}
	set pin(vga_r[6])       {PIN = H11}
	set pin(vga_r[7])       {PIN = H12}
	set pin(vga_r[8])       {PIN = F11}
	set pin(vga_r[9])       {PIN = E10}

	set pin(vga_g[0])       {PIN = B9}
	set pin(vga_g[1])       {PIN = A9}
	set pin(vga_g[2])       {PIN = C10}
	set pin(vga_g[3])       {PIN = D10}
	set pin(vga_g[4])       {PIN = B10}
	set pin(vga_g[5])       {PIN = A10}
	set pin(vga_g[6])       {PIN = G11}
	set pin(vga_g[7])       {PIN = D11}
	set pin(vga_g[8])       {PIN = E12}
	set pin(vga_g[9])       {PIN = D12}

	set pin(vga_b[0])       {PIN = J13}
	set pin(vga_b[1])       {PIN = J14}
	set pin(vga_b[2])       {PIN = F12}
	set pin(vga_b[3])       {PIN = G12}
	set pin(vga_b[4])       {PIN = J10}
	set pin(vga_b[5])       {PIN = J11}
	set pin(vga_b[6])       {PIN = C11}
	set pin(vga_b[7])       {PIN = B11}
	set pin(vga_b[8])       {PIN = C12}
	set pin(vga_b[9])       {PIN = B12}

	# -----------------------------------------------------------------
	# USB Blaster interface
	# -----------------------------------------------------------------
	#
	set pin(link_in[0])     {PIN = B14}
	set pin(link_in[1])     {PIN = A14}
	set pin(link_in[2])     {PIN = D14}
	set pin(link_out)       {PIN = F14}

	# -----------------------------------------------------------------
	# Ethernet controller
	# -----------------------------------------------------------------
	#
	# Clock
	set pin(enet_clk)       {PIN = B24}

	# Controls
	set pin(enet_resetN)    {PIN = B23}
	set pin(enet_csN)       {PIN = A23}
	set pin(enet_cmd)       {PIN = A21}
	set pin(enet_irqN)      {PIN = B21}
	set pin(enet_iowN)      {PIN = B22}
	set pin(enet_iorN)      {PIN = A22}

	# Data bus
	set pin(enet_dq[0])     {PIN = D17}
	set pin(enet_dq[1])     {PIN = C17}
	set pin(enet_dq[2])     {PIN = B18}
	set pin(enet_dq[3])     {PIN = A18}
	set pin(enet_dq[4])     {PIN = B17}
	set pin(enet_dq[5])     {PIN = A17}
	set pin(enet_dq[6])     {PIN = B16}
	set pin(enet_dq[7])     {PIN = B15}
	set pin(enet_dq[8])     {PIN = B20}
	set pin(enet_dq[9])     {PIN = A20}
	set pin(enet_dq[10])    {PIN = C19}
	set pin(enet_dq[11])    {PIN = D19}
	set pin(enet_dq[12])    {PIN = B19}
	set pin(enet_dq[13])    {PIN = A19}
	set pin(enet_dq[14])    {PIN = E18}
	set pin(enet_dq[15])    {PIN = D18}

	# -----------------------------------------------------------------
	# RS232
	# -----------------------------------------------------------------
	#
	set pin(uart_txd)       {PIN = B25}
	set pin(uart_rxd)       {PIN = C25}

	# -----------------------------------------------------------------
	# PS/2
	# -----------------------------------------------------------------
	#
	set pin(ps2_dat)        {PIN = C24}
	set pin(ps2_clk)        {PIN = D26}

	# -----------------------------------------------------------------
	# SD Card interface
	# -----------------------------------------------------------------
	#
	set pin(sd_cmd)         {PIN = Y21}
	set pin(sd_dat)         {PIN = AD24}
	set pin(sd_clk)         {PIN = AD25}
	set pin(sd_dat3)        {PIN = AC23}

	# -----------------------------------------------------------------
	# IrDA interface
	# -----------------------------------------------------------------
	#
	set pin(irda_txd)       {PIN = AE24}
	set pin(irda_rxd)       {PIN = AE25}

	# -----------------------------------------------------------------
	# SDRAM
	# -----------------------------------------------------------------
	#
	# Output clock
	set pin(sdram_clk)      {PIN = AA7}

	# SDRAM controls
	set pin(sdram_cke)      {PIN = AA6}
	set pin(sdram_csN)      {PIN = AC3}
	set pin(sdram_rasN)     {PIN = AB4}
	set pin(sdram_casN)     {PIN = AB3}
	set pin(sdram_weN)      {PIN = AD3}
	set pin(sdram_ba[0])    {PIN = AE2}
	set pin(sdram_ba[1])    {PIN = AE3}
	set pin(sdram_dqm[0])   {PIN = AD2}
	set pin(sdram_dqm[1])   {PIN = Y5}

	set pin(sdram_addr[0])  {PIN = T6}
	set pin(sdram_addr[1])  {PIN = V4}
	set pin(sdram_addr[2])  {PIN = V3}
	set pin(sdram_addr[3])  {PIN = W2}
	set pin(sdram_addr[4])  {PIN = W1}
	set pin(sdram_addr[5])  {PIN = U6}
	set pin(sdram_addr[6])  {PIN = U7}
	set pin(sdram_addr[7])  {PIN = U5}
	set pin(sdram_addr[8])  {PIN = W4}
	set pin(sdram_addr[9])  {PIN = W3}
	set pin(sdram_addr[10]) {PIN = Y1}
	set pin(sdram_addr[11]) {PIN = V5}

	set pin(sdram_dq[0])    {PIN = V6}
	set pin(sdram_dq[1])    {PIN = AA2}
	set pin(sdram_dq[2])    {PIN = AA1}
	set pin(sdram_dq[3])    {PIN = Y3}
	set pin(sdram_dq[4])    {PIN = Y4}
	set pin(sdram_dq[5])    {PIN = R8}
	set pin(sdram_dq[6])    {PIN = T8}
	set pin(sdram_dq[7])    {PIN = V7}
	set pin(sdram_dq[8])    {PIN = W6}
	set pin(sdram_dq[9])    {PIN = AB2}
	set pin(sdram_dq[10])   {PIN = AB1}
	set pin(sdram_dq[11])   {PIN = AA4}
	set pin(sdram_dq[12])   {PIN = AA3}
	set pin(sdram_dq[13])   {PIN = AC2}
	set pin(sdram_dq[14])   {PIN = AC1}
	set pin(sdram_dq[15])   {PIN = AA5}

	# -----------------------------------------------------------------
	# Flash
	# -----------------------------------------------------------------
	#
	set pin(flash_resetN)   {PIN = AA18}
	set pin(flash_ceN)      {PIN = V17}
	set pin(flash_weN)      {PIN = AA17}
	set pin(flash_oeN)      {PIN = W17}

	set pin(flash_addr[0])  {PIN = AC18}
	set pin(flash_addr[1])  {PIN = AB18}
	set pin(flash_addr[2])  {PIN = AE19}
	set pin(flash_addr[3])  {PIN = AF19}
	set pin(flash_addr[4])  {PIN = AE18}
	set pin(flash_addr[5])  {PIN = AF18}
	set pin(flash_addr[6])  {PIN = Y16}
	set pin(flash_addr[7])  {PIN = AA16}
	set pin(flash_addr[8])  {PIN = AD17}
	set pin(flash_addr[9])  {PIN = AC17}
	set pin(flash_addr[10]) {PIN = AE17}
	set pin(flash_addr[11]) {PIN = AF17}
	set pin(flash_addr[12]) {PIN = W16}
	set pin(flash_addr[13]) {PIN = W15}
	set pin(flash_addr[14]) {PIN = AC16}
	set pin(flash_addr[15]) {PIN = AD16}
	set pin(flash_addr[16]) {PIN = AE16}
	set pin(flash_addr[17]) {PIN = AC15}
	set pin(flash_addr[18]) {PIN = AB15}
	set pin(flash_addr[19]) {PIN = AA15}
	set pin(flash_addr[20]) {PIN = Y15}
	set pin(flash_addr[21]) {PIN = Y14}

	set pin(flash_dq[0])    {PIN = AD19}
	set pin(flash_dq[1])    {PIN = AC19}
	set pin(flash_dq[2])    {PIN = AF20}
	set pin(flash_dq[3])    {PIN = AE20}
	set pin(flash_dq[4])    {PIN = AB20}
	set pin(flash_dq[5])    {PIN = AC20}
	set pin(flash_dq[6])    {PIN = AF21}
	set pin(flash_dq[7])    {PIN = AE21}

	# -----------------------------------------------------------------
	# SRAM
	# -----------------------------------------------------------------
	#
	set pin(sram_ceN)       {PIN = AC11}
	set pin(sram_weN)       {PIN = AE10}
	set pin(sram_oeN)       {PIN = AD10}
	set pin(sram_beN[0])    {PIN = AE9}
	set pin(sram_beN[1])    {PIN = AF9}

	set pin(sram_addr[0])   {PIN = AE4}
	set pin(sram_addr[1])   {PIN = AF4}
	set pin(sram_addr[2])   {PIN = AC5}
	set pin(sram_addr[3])   {PIN = AC6}
	set pin(sram_addr[4])   {PIN = AD4}
	set pin(sram_addr[5])   {PIN = AD5}
	set pin(sram_addr[6])   {PIN = AE5}
	set pin(sram_addr[7])   {PIN = AF5}
	set pin(sram_addr[8])   {PIN = AD6}
	set pin(sram_addr[9])   {PIN = AD7}
	set pin(sram_addr[10])  {PIN = V10}
	set pin(sram_addr[11])  {PIN = V9}
	set pin(sram_addr[12])  {PIN = AC7}
	set pin(sram_addr[13])  {PIN = W8}
	set pin(sram_addr[14])  {PIN = W10}
	set pin(sram_addr[15])  {PIN = Y10}
	set pin(sram_addr[16])  {PIN = AB8}
	set pin(sram_addr[17])  {PIN = AC8}

	set pin(sram_dq[0])     {PIN = AD8}
	set pin(sram_dq[1])     {PIN = AE6}
	set pin(sram_dq[2])     {PIN = AF6}
	set pin(sram_dq[3])     {PIN = AA9}
	set pin(sram_dq[4])     {PIN = AA10}
	set pin(sram_dq[5])     {PIN = AB10}
	set pin(sram_dq[6])     {PIN = AA11}
	set pin(sram_dq[7])     {PIN = Y11}
	set pin(sram_dq[8])     {PIN = AE7}
	set pin(sram_dq[9])     {PIN = AF7}
	set pin(sram_dq[10])    {PIN = AE8}
	set pin(sram_dq[11])    {PIN = AF8}
	set pin(sram_dq[12])    {PIN = W11}
	set pin(sram_dq[13])    {PIN = W12}
	set pin(sram_dq[14])    {PIN = AC9}
	set pin(sram_dq[15])    {PIN = AC10}

	# -----------------------------------------------------------------
	# GPIO
	# -----------------------------------------------------------------
	#
	set pin(gpio_a[0])      {PIN = D25}
	set pin(gpio_a[1])      {PIN = J22}
	set pin(gpio_a[2])      {PIN = E26}
	set pin(gpio_a[3])      {PIN = E25}
	set pin(gpio_a[4])      {PIN = F24}
	set pin(gpio_a[5])      {PIN = F23}
	set pin(gpio_a[6])      {PIN = J21}
	set pin(gpio_a[7])      {PIN = J20}
	set pin(gpio_a[8])      {PIN = F25}
	set pin(gpio_a[9])      {PIN = F26}
	set pin(gpio_a[10])     {PIN = N18}
	set pin(gpio_a[11])     {PIN = P18}
	set pin(gpio_a[12])     {PIN = G23}
	set pin(gpio_a[13])     {PIN = G24}
	set pin(gpio_a[14])     {PIN = K22}
	set pin(gpio_a[15])     {PIN = G25}
	set pin(gpio_a[16])     {PIN = H23}
	set pin(gpio_a[17])     {PIN = H24}
	set pin(gpio_a[18])     {PIN = J23}
	set pin(gpio_a[19])     {PIN = J24}
	set pin(gpio_a[20])     {PIN = H25}
	set pin(gpio_a[21])     {PIN = H26}
	set pin(gpio_a[22])     {PIN = H19}
	set pin(gpio_a[23])     {PIN = K18}
	set pin(gpio_a[24])     {PIN = K19}
	set pin(gpio_a[25])     {PIN = K21}
	set pin(gpio_a[26])     {PIN = K23}
	set pin(gpio_a[27])     {PIN = K24}
	set pin(gpio_a[28])     {PIN = L21}
	set pin(gpio_a[29])     {PIN = L20}
	set pin(gpio_a[30])     {PIN = J25}
	set pin(gpio_a[31])     {PIN = J26}
	set pin(gpio_a[32])     {PIN = L23}
	set pin(gpio_a[33])     {PIN = L24}
	set pin(gpio_a[34])     {PIN = L25}
	set pin(gpio_a[35])     {PIN = L19}

	set pin(gpio_b[0])      {PIN = K25}
	set pin(gpio_b[1])      {PIN = K26}
	set pin(gpio_b[2])      {PIN = M22}
	set pin(gpio_b[3])      {PIN = M23}
	set pin(gpio_b[4])      {PIN = M19}
	set pin(gpio_b[5])      {PIN = M20}
	set pin(gpio_b[6])      {PIN = N20}
	set pin(gpio_b[7])      {PIN = M21}
	set pin(gpio_b[8])      {PIN = M24}
	set pin(gpio_b[9])      {PIN = M25}
	set pin(gpio_b[10])     {PIN = N24}
	set pin(gpio_b[11])     {PIN = P24}
	set pin(gpio_b[12])     {PIN = R25}
	set pin(gpio_b[13])     {PIN = R24}
	set pin(gpio_b[14])     {PIN = R20}
	set pin(gpio_b[15])     {PIN = T22}
	set pin(gpio_b[16])     {PIN = T23}
	set pin(gpio_b[17])     {PIN = T24}
	set pin(gpio_b[18])     {PIN = T25}
	set pin(gpio_b[19])     {PIN = T18}
	set pin(gpio_b[20])     {PIN = T21}
	set pin(gpio_b[21])     {PIN = T20}
	set pin(gpio_b[22])     {PIN = U26}
	set pin(gpio_b[23])     {PIN = U25}
	set pin(gpio_b[24])     {PIN = U23}
	set pin(gpio_b[25])     {PIN = U24}
	set pin(gpio_b[26])     {PIN = R19}
	set pin(gpio_b[27])     {PIN = T19}
	set pin(gpio_b[28])     {PIN = U20}
	set pin(gpio_b[29])     {PIN = U21}
	set pin(gpio_b[30])     {PIN = V26}
	set pin(gpio_b[31])     {PIN = V25}
	set pin(gpio_b[32])     {PIN = V24}
	set pin(gpio_b[33])     {PIN = V23}
	set pin(gpio_b[34])     {PIN = W25}
	set pin(gpio_b[35])     {PIN = W23}

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

