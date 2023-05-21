# -----------------------------------------------------------------
# jtag_client_cmds.tcl
#
# 9/14/2011 D. W. Hawkins (dwh@caltech.edu)
#
# Altera JTAG socket client Tcl commands.
#
# The JTAG server provides remote hardware access/control functions
# to clients.
#
# The server accept Tcl string commands from the client, issues the
# command to the hardware, and then returns any response data
# to the client.
#
# -----------------------------------------------------------------
# Notes:
# ------
#
# 1. Only a *single* client connection is supported.
#
#    This limitation comes about due to the desire for a simple
#    API. If multiple clients were to be supported, then some
#    form of client identifier would be needed in the API, eg.
#
#    jtag_read $client $addr
#
#    and the GUI elements would need to track GUI element
#    state on a per client GUI basis. The GUI elements track
#    the client connection status via a trace on jtag(socket).
#    If multiple client connections were allowed, then each
#    GUI would require a trace on its own socket connection.
#    This limition means that only a single GUI instance is
#    allowed, eg., see jtag_client_gui.tcl for how the Tk
#    GUI routines only allow one client per process
#    (the top-level window name is checked).
#
#    The single client connection is not really a limitation,
#    since multiple client connections can be created using
#    separate processes, eg., multiple quartus_stp consoles.
#
# 2. To use the commands via a console, use:
#
#    quartus_stp -s
#    tcl> source jtag_client_cmds.tcl
#    tcl> client_open 2540
#    tcl> jtag_write 0 0x12345678
#    tcl> jtag_read 0
#    0x12345678
#
#    Multiple clients (from different clients processes) can
#    connect to the server when the server is running from
#    quartus_stp.
#
# -----------------------------------------------------------------
# References
# ----------
#
# 1. Brent Welch, "Practical Programming in Tcl and Tk",
#    3rd Ed, 2000.
#
# -----------------------------------------------------------------

# =================================================================
# Client socket
# =================================================================
#
# For details on socket programming, see Welch Ch. 17 [1].
#
# Open a connection to the server
proc client_open {{port 2540}} {
	global jtag
	if {[info exists jtag(socket)]} {
		client_close
	}
	if {[catch {socket localhost $port} result]} {
		error "Error: Check that the server is running\n -> '$result'"
	}
	set jtag(port)   $port
	set jtag(socket) $result

	# Configure the client for blocking, line-based communication
	fconfigure $jtag(socket) -buffering line -blocking 1
	return
}

proc client_close {} {
	global jtag
	if {[info exists jtag(socket)]} {
		catch {close $jtag(socket)}
		unset jtag(socket)
	}
	return
}

# =================================================================
# Client-to-server commands
# =================================================================
#
proc jtag_read {addr} {
	global jtag
	if {![info exists jtag(port)]} {
		# Default port
		set jtag(port) 2540
	}
	if {![info exists jtag(socket)]} {
		client_open $jtag(port)
	}

	# Check the argument is a valid value by reformatting
	# the address as an 8-bit hex value
	set addr [expr {$addr & 0xFFFFFFFF}]
	if {[catch {format "0x%.8X" $addr} addr]} {
		error "Error: Invalid address\n -> '$addr'"
	}

	# Send the command
	set cmd "jtag_read $addr"
	if {[catch {puts $jtag(socket) $cmd} result]} {
		# Server connection lost?
		client_close
#		error "Error: Check that the server is running\n -> '$result'"

		# Retry the command
		# * if the server is back up, then read will succeed,
		#   otherwise open will return an error
		return [jtag_read $addr]
	}

	# Read the response
	if {[catch {gets $jtag(socket)} result]} {
		# Server connection lost?
		client_close
#		error "Error: Check that the server is running\n -> '$result'"

		# Retry the command
		# * if the server is back up, then read will succeed,
		#   otherwise open will return an error
		return [jtag_read $addr]
	}
	return $result
}

proc jtag_write {addr data} {
	global jtag
	if {![info exists jtag(port)]} {
		# Default port
		set jtag(port) 2540
	}
	if {![info exists jtag(socket)]} {
		client_open $jtag(port)
	}

	# Check the arguments are valid values by reformatting
	# them as 8-bit hex values
	set addr [expr {$addr & 0xFFFFFFFF}]
	if {[catch {format "0x%.8X" $addr} addr]} {
		error "Error: Invalid address\n -> '$addr'"
	}
	set data [expr {$data & 0xFFFFFFFF}]
	if {[catch {format "0x%.8X" $data} data]} {
		error "Error: Invalid write data\n -> '$data'"
	}

	# Send the command
	set cmd "jtag_write $addr $data"
	if {[catch {puts $jtag(socket) $cmd} result]} {
		# Server connection lost?
		client_close
#		error "Error: Check that the server is running\n -> '$result'"

		# Retry the command
		# * if the server is back up, then write will succeed,
		#   otherwise open will return an error
		jtag_write $addr $data
		return
	}
	return
}

