# -----------------------------------------------------------------
# jtag_client.tcl
#
# 9/14/2011 D. W. Hawkins (dwh@caltech.edu)
#
# Altera JTAG socket client Tcl/Tk GUI.
#
# The client application can run from any Tcl/Tk shell, eg.,
# the following were tested under Windows
#
#  * wish (ActiveState ActiveTcl 8.4.16.0)
#  * quartus_stp (Quartus II 10.1)
#  * Modelsim-SE 6.5b
#  * The Quartus II Tcl console (Quartus II 10.1)
#
# The client does not work for;
#
#  * SystemConsole
#    Altera has somehow managed to break Tk support there
#
#  * Modelsim Altera-Edition (Modelsim-AE)
#    The 'free' version does not support Tk.
#
# -----------------------------------------------------------------
# Notes:
# ------
#
# 1. Command line operation
#
#    quartus_stp -t jtag_client.tcl <port>
#
#    where
#
#    <port>   Server port number (defaults to 2540)
#
# 2. Console operation
#
#    quartus_stp -s
#    tcl> source jtag_client.tcl
#
#    or to connect to a different server port number
#
#    quartus_stp -s
#    tcl> set port 2541
#    tcl> source jtag_client.tcl
#
# -----------------------------------------------------------------
# References
# ----------
#
# 1. Brent Welch, "Practical Programming in Tcl and Tk",
#    3rd Ed, 2000.
#
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Load the client commands
# -----------------------------------------------------------------
#
source ./jtag_client_cmds.tcl

# -----------------------------------------------------------------
# Tool detection
# -----------------------------------------------------------------
#
# The client GUI can be run from any console that supports Tk.
#
# Tcl usually allows you to detect the toolname using
# 'info nameofexecutable', however, under SystemConsole this
# is an empty string. In other cases, the global argv0
# holds the application name, but under the Quartus Tcl console
# there is no argv0! However, nameofexecutable does work there,
# so start with that, and if its empty, try argv0.
#
proc detect_tool {} {
	global jtag argv0

	# Get the tool name
	set toolname [info nameofexecutable]
	if {[string length $toolname] == 0} {
		if {[info exists argv0]} {
			set toolname $argv0
		}
	}

	# Strip the name to just that of the application
	set toolname [file rootname [file tail $toolname]]

	# Example toolname strings;
	#
	#  -----------------------------------------------
	# | Application                  | String         |
	# |------------------------------|----------------|
	# |                              |                |
	# | Quartus II                   | quartus        |
	# | SystemConsole                | system-console |
	# | quartus_stp                  | quartus_stp    |
	# | Modelsim                     | vish           |
	# | ActiveState ActiveTcl Wish84 | wish84         |
	# |                              |                |
	#  -----------------------------------------------
	#
	set jtag(tool_ok) 0
	if {[string first wish $toolname] == 0} {
		# Toolname starts with 'wish'
		set jtag(tool) wish
		set jtag(tool_ok) 1
	} elseif {[string first vish $toolname] == 0} {
		# Modelsim starts vish.exe
		# (alternatively argv0 ends in vsim)
		#
		# Note:
		# Modelsim-Altera does not have Tk support
		# (package require Tk fails)
		#
		set jtag(tool) modelsim
		set jtag(tool_ok) 1
	} elseif {[string first quartus $toolname] == 0} {
		# Quartus also has a global called quartus
		# that can be detected using [info exists quartus].
		set jtag(tool) $toolname
		set jtag(tool_ok) 1
	}
	return
}

proc is_tool_ok {} {
	global jtag
	if {![info exists jtag(tool_ok)]} {
		detect_tool
	}
	return $jtag(tool_ok)
}

# Console message
detect_tool
if {![is_tool_ok]} {
	puts "Sorry, this script can only run using a tool with Tk support"
	return
}
puts [format " \nJTAG client running under %s\n " $jtag(tool)]

# -----------------------------------------------------------------
# Initialize Tk
# -----------------------------------------------------------------
#
# Check for the Tk package (fails for Modelsim-AE)
if {[catch {package require Tk}]} {

	# If Tk is not available, generate an error to the console
	error [concat \
		"Error: the package 'Tk' was not found. "\
		"Please use an application that supports Tcl/Tk." ]

}

# Quartus shells need to initialize Tk
if {[string compare $jtag(tool) quartus] == 0} {
	init_tk
}

# -----------------------------------------------------------------
# Command line argument?
# -----------------------------------------------------------------
#
# The Modelsim-SE GUI starts with an argc of 1 with an argv
# of '-gui'. So check the command line arguments are numbers
# before using them.
#
# Server port number?
if {$argc > 0} {
	set port [lindex $argv 0]
	if {![string is digit $port]} {
		unset port
	}
}
if {![info exists port]} {
	set port 2540
}
set jtag(port) $port
unset port

# =================================================================
# Tk GUI
# =================================================================
#
#------------------------------------------------------------------
# GUI helper procedures
#------------------------------------------------------------------
#
# Wish console show/hide
proc console_update {} {
	global jtag
	if {![info exists jtag(console)]} {
		return
	}
	if {$jtag(console) == 1} {
		puts "<console_update> show"
		console show
	} else {
		puts "<console_update> hide"
		console hide
	}
}

# Tool-specific exit sequence
# * 'quit' is a command in Modelsim, so use a different name
proc gui_quit {win} {
	global jtag
	if {[info exists jtag(socket)]} {
		client_close
	}
	puts "Quit"

    if {(([string compare $jtag(tool) wish] == 0) && ($jtag(console) == 1)) ||
         ([string compare $jtag(tool) modelsim] == 0) ||
         ([string first quartus $jtag(tool)] == 0)} {

			# File->Exit has a $win value corresponding to
			# the path to the menu element, eg. .topX.mbar.file.menu,
			# whereas exit using the window manager 'x' button
			# generates the $win value .topX.
			#
			# Only destroy the main window
			set win ".[lindex [split $win .] 1]"
			destroy $win
			return
	}
	# Otherwise exit (eg. wish, with console not visible)
	exit
}

# Socket connection status trace
#
# * the trace callback executes whenever jtag(socket) is created
#   (on client open), or unset (on client close).
#
# * this allows the read/write buttons to be pressed when the
#   client connection is not established, and the connection
#   status will update.
#
# * it also means that when the server goes down and a client
#   read fails, the GUI will update the connection status
#   to disconnected.
#
proc socket_trace {name1 name2 op} {
	global jtag

#   name1 = jtag, name2 = socket, op = w or u
#	puts "socket trace: $name1 $name2 $op"

	switch $op {
		w {
			set jtag(port_status) "Connected"
			$jtag(port_status_label)  configure -bg green
			$jtag(port_status_button) configure -text "Disconnect"
		}
		u {
			set jtag(port_status) "Disconnected"
			$jtag(port_status_label)  configure -bg yellow
			$jtag(port_status_button) configure -text "Connect"

			# Since jtag(socket) was unset, setup a new
			# trace for the new variable with that name
			trace variable jtag(socket) wu socket_trace
		}
	}
}

# Check that an entry box widget only contains decimal digits
proc validate_isdigit {action new} {
	if {$action == 1} {
		# Insert
		return [string is digit $new]
	} else {
		# Delete
		return 1
	}
}

# Check that an entry box widget contains no more than 8
# hexdecimal digits
proc validate_isxdigit {action new} {
	set status 0
	if {$action == 1} {
		# Insert
		if {[string is xdigit $new] && ([string length $new] <= 8)} {
			set status 1
		}
	} else {
		# Delete
		set status 1
	}
	return $status
}

# Client connect/disconnect button callback
proc connect_button {} {
	global jtag
	if {[info exists jtag(socket)]} {
		client_close
	} else {
		client_open $jtag(port)
	}
}

# Pressing the read/write buttons will automatically connect
# to the client if needed. The trace on jtag(socket) will
# cause the connection status GUI elements to update
#
proc read_button {} {
	global jtag

	# The address and data entry boxes contain only digits,
	# so add the leading 0x to the address
	set data [jtag_read 0x$jtag(address)]

	# and then strip the response 0x
	set jtag(data) [format %X $data]
}

proc write_button {} {
	global jtag

	# The address and data entry boxes contain only digits,
	# so add the leading 0x to the command
	jtag_write 0x$jtag(address) 0x$jtag(data)
}

#------------------------------------------------------------------
# GUI commands
#------------------------------------------------------------------
#
# Create a 'File' menu at the top of the GUI main window.
# The menu has an 'Exit' option under all Tk GUIs. Under wish
# it also has an option to show the console.
#
proc file_menu_init {win} {
	global jtag

    # Create the menu
    menu $win -tearoff false
    #
    # Add selections
    #
	# If using wish, provide a way to show/hide the console
    if {[string compare $jtag(tool) wish] == 0} {
		$win add check  -label "Console" \
			-variable jtag(console) \
			-command {console_update}
	}

	# These exit methods do not work well (see comments above)
#	$win add command -label "Exit" -command {exit}
#	$win add command -label "Exit" -command {destroy .top}

	# This exit method works for all cases.
	$win add command -label "Exit" -command [list gui_quit $win]

}

proc draw_menu {win} {

    # Menu buttons
    menubutton $win.file -text "File" \
    	-menu $win.file.menu -padx 10

    # Menu contents:
    file_menu_init   $win.file.menu

	# Pack the elements into their frame
    pack $win.file   -side left
}

proc draw_client_status {win} {
	global jtag

	# Create a frame so that elements can be packed
	# and some padding added
	frame $win.f1

	# Title
	label $win.f1.l1 -text "Client connection status:"

	# Connection status text
	set jtag(port_status) "Disconnected"
	label $win.f1.l2 -textvariable jtag(port_status) \
		-width 15 -relief groove \
		-padx 10 -pady 5 -background yellow

	# Port number text
	label $win.f1.l3 -text "Port number:"

	# An numeric entry box with the default port number
	entry $win.f1.e1 -textvariable jtag(port) \
		-width 12 -justify right \
		-relief sunken -validate key \
		-validatecommand {validate_isdigit %d %P}

	# Copy the label path so the color can be updated
	set jtag(port_status_label) $win.f1.l2

	# A connect/disconnect button
	button $win.f1.b1 -text "Connect" \
		-command connect_button -padx 10 -width 14

	# Copy the button path so the text can be updated
	set jtag(port_status_button) $win.f1.b1

	# Arrange the elements into their frame
	#
	# The title
	grid $win.f1.l1 -column 0 -columnspan 2 -row 0 -sticky w -padx 5 -pady 2
	#
	# Connection status
	grid $win.f1.l2 -column 2 -row 0 -sticky w -padx 5 -pady 2
	#
	# The port connect elements
	grid $win.f1.l3 -column 0 -row 1 -sticky w -padx 5 -pady 2
	grid $win.f1.e1 -column 1 -row 1 -sticky w -padx 5 -pady 2
	grid $win.f1.b1 -column 2 -row 1 -sticky w -padx 5 -pady 2
	pack $win.f1    -padx 10 -pady 10
}

proc draw_read_write {win} {
	global jtag

	# Create a frame so that elements can be packed
	# and some padding added
	frame $win.f1

	# Title
	label $win.f1.l1 -text "JTAG read/write:"

	# Address text
	label $win.f1.l2 -text "Address (hex):"

	# A hex entry box with the default address
	set jtag(address) 0
	entry $win.f1.e1 -textvariable jtag(address) \
		-width 12 -justify right \
		-relief sunken -validate key \
		-validatecommand {validate_isxdigit %d %P}

	# Data text
	label $win.f1.l3 -text "Data (hex):"

	# A hex entry box with the default data
	set jtag(data) 0
	entry $win.f1.e2 -textvariable jtag(data) \
		-width 12 -justify right \
		-relief sunken -validate key \
		-validatecommand {validate_isxdigit %d %P}

	# Read/write buttons
	button $win.f1.b1 -text "Read" \
		-command read_button -padx 10 -width 14
	button $win.f1.b2 -text "Write" \
		-command write_button -padx 10 -width 14

	# Arrange the elements into their frame
	#
	# The title
	grid $win.f1.l1 -column 0 -columnspan 3 -row 0 -sticky w -padx 5 -pady 2
	#
	# Text + entry + button
	grid $win.f1.l2 -column 0 -row 1 -sticky e -padx 5 -pady 2
	grid $win.f1.e1 -column 1 -row 1 -sticky w -padx 5 -pady 2
	grid $win.f1.b1 -column 2 -row 1 -sticky w -padx 5 -pady 2
	grid $win.f1.l3 -column 0 -row 2 -sticky e -padx 5 -pady 2
	grid $win.f1.e2 -column 1 -row 2 -sticky w -padx 5 -pady 2
	grid $win.f1.b2 -column 2 -row 2 -sticky w -padx 5 -pady 2
	pack $win.f1    -padx 10 -pady 10
}

proc create_gui {win} {
    global jtag

    # Top-of-window menu bar
    # ----------------------
    frame $win.mbar -borderwidth 1 -relief raised
	draw_menu $win.mbar
	# The menu bar fills the window width
    pack $win.mbar -fill x

    # Client status
    # ---------------
    frame $win.port -borderwidth 2 -relief raised
	draw_client_status $win.port
    pack $win.port -padx 10 -pady 10

    # JTAG read/write
    # ---------------
    frame $win.rw -borderwidth 2 -relief raised
	draw_read_write $win.rw
    pack $win.rw -padx 10 -pady 10

	# Change the title of the main frame
	wm title $win "JTAG-to-Avalon-MM Client"

	# Turn off window resizing
	# * first need to give it a reasonable size
	wm minsize $win 400 250
#	wm maxsize $win 500 300
	wm resizable $win 0 0

	# Connect the close (X) button to the gui_quit handler
	wm protocol $win WM_DELETE_WINDOW [list gui_quit $win]

	# Execute socket_trace when jtag(socket) changes
	trace variable jtag(socket) wu socket_trace

}

# -----------------------------------------------------------------
# GUI construction
# -----------------------------------------------------------------
#
# Create a top-level window in which to pack widgets
#  * Standard Tcl/Tk has the window . that can be used
#  * Quartus hides the top-level . window, so create a new one
#  * Modelsim uses the top-level . window, so create a new one
#
if {([string compare $jtag(tool) wish] == 0) ||
    ([string compare $jtag(tool) quartus_stp] == 0)} {
	# Hide the top-level window
	wm state . withdraw
}

# Create a new top-level window called .top
if {[winfo exists .top]} {
	# Quartus and wish can be used to start multiple GUIs
	# but that is not allowed as the socket trace gets messed up
	# (there is only one jtag(socket) variable)
	#
	# Note:
	#   puts " ", with a space between the quotes is needed
	#   under Quartus Tcl, otherwise the blank line is
	#   suppressed.
	#
	puts " ==> Error: the client GUI is already running!"
	puts " "
	puts "     If you want multiple clients, they must be started"
	puts "     using multiple processes."
	puts " "
	return
}

# Note: the variable 'top' is used below for the tkwait
set top [toplevel .top]
create_gui $top

if {[string first "quartus_" $jtag(tool)] == 0} {
	# Quartus command-line tool-specific wait
	tkwait window $top
} elseif {[string compare $jtag(tool) wish] == 0} {
	# Display the Tcl console
	if {$jtag(console) == 1} {
		console show
	} else {
		console hide
	}
}
