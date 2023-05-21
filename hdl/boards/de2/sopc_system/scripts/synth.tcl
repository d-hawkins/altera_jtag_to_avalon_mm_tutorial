# -----------------------------------------------------------------
# boards/de2/sopc_system/scripts/synth.tcl
#
# 2/20/2012 D. W. Hawkins (dwh@caltech.edu)
#
# Quartus synthesis script.
#
# -----------------------------------------------------------------
# Usage
# -----
#
# 1. From within Quartus, change to the project folder, and type
#
#    source scripts/synth.tcl
#
# 2. Command-line processing. Change to the project folder,
#    and type either;
#
#    a) quartus_sh -s
#       tcl> source scripts/synth.tcl
#
#    b)  quartus_sh -t scripts/synth.tcl
#
# -----------------------------------------------------------------

puts ""
puts "Synthesizing the DE2 'sopc_system' design"
puts "-----------------------------------------"

# -----------------------------------------------------------------
# Tcl packages
# -----------------------------------------------------------------

package require ::quartus::project
package require ::quartus::flow

# -----------------------------------------------------------------
# Tutorial HDL folder
# -----------------------------------------------------------------
#
# Determine the altera_jtag_to_avalon_mm_tutorial/hdl directory
#
# * current location should be altera_jtag_to_avalon_mm_tutorial/
#   hdl/boards/de2/sopc_system, so strip off the last
#   few directories from the current directory
#
set path [file split [pwd]]
set len  [llength $path]
set hdl  [eval file join [lrange $path 0 [expr {$len-4}]]]

# Check the directory name
if {![string match [file tail $hdl] "hdl"]} {
	puts [concat \
		"Error: this script should be sourced from the "\
		"BeMicro sopc_system/ project directory. Please "\
		"change to that directory and try again."]
	return
}

# -----------------------------------------------------------------
# Design paths
# -----------------------------------------------------------------

# Design parameters
set board      de2
set design     sopc_system

# Design paths
set constraints $hdl/boards/$board/share/scripts/constraints.tcl
set top  		$hdl/boards/$board/$design
set scripts     $top/scripts
set src         $top/src
set share_src   $hdl/boards/share/src

# -----------------------------------------------------------------
# Quartus work
# -----------------------------------------------------------------

global quartus
puts " - Quartus $quartus(version)"

# Build directory
set qwork  $top/qwork
if {![file exists $qwork]} {
    puts " - Creating the Quartus work directory"
    puts "   * $qwork"
    file mkdir $qwork
}

# Create all the generated files in the work directory
cd $qwork

# -----------------------------------------------------------------
# Quartus project
# -----------------------------------------------------------------

puts " - Create the project '$board'"

# Close any open project
# * since all the projects are named after the board, close
#   the current project to clear the files list. This avoids the
#   top-level files from another project being picked up if the
#   previous project was not closed.
#
if {[is_project_open]} {
	puts "   * close the project"
	project_close
}

# Best to name the project your "top" component name.
#
#  * $quartus(project) contains the project name
#  * project_exist $board returns 1 only in the work directory,
#    since that is where the Quartus project file is located
#
if {[project_exists $board]} {
	puts "   * open the existing $board project"
	project_open -revision $board $board
} else {
	puts "   * create a new $board project"
	project_new -revision $board $board
}

# -----------------------------------------------------------------
# SOPC System
# -----------------------------------------------------------------
#

# Generate the SOPC system
#
# 1) SOPC file
#    - if it does not exist, copy it to the build area
#
# 2) Ideally the script would detect if sopc_system.vhd is older
#    than the .sopc file or perhaps a timestamp file, and rebuild
#    if it if needed, however, I cannot figure out how to call
#    sopc_builder from Tcl. So for now, just make the user do it.
#
# The SOPC system has to be copied to the project directory,
# since it generates files in the same folder as the SOPC
# file. It would be better if the tool could generate the
# files in a user-specified folder.
#
puts " - Check the SOPC system"
if {![file exists sopc_system.sopc]} {
	puts "   * Copying the SOPC system file to the build directory"
	file copy $hdl/sopc_system/scripts/sopc_system.sopc $qwork/sopc_system.sopc
}

# Check the top-level SOPC system Verilog file exists
# * assume the other SOPC files have not been deleted
if {![file exists sopc_system.v]} {
	puts "   * Please run SOPC Builder, 'generate' the SOPC system,"
	puts "     and then re-run this script"
	cd $top
	return
}

# Add the SOPC system files
set_global_assignment -name SOPC_FILE    $qwork/sopc_system.sopc
set_global_assignment -name QIP_FILE     $qwork/sopc_system.qip

# -----------------------------------------------------------------
# HDL files
# -----------------------------------------------------------------

puts " - Creating the design files list"

# Verilog/SystemVerilog files:
#
# SOPC system generated files
# * the .qip file should really include these automatically
set_global_assignment -name VERILOG_FILE $qwork/sopc_system.v
set_global_assignment -name VERILOG_FILE $qwork/bfm_master.v
set_global_assignment -name VERILOG_FILE $qwork/jtag_master.v
set_global_assignment -name VERILOG_FILE $qwork/led_pio.v
set_global_assignment -name VERILOG_FILE $qwork/button_pio.v
set_global_assignment -name VERILOG_FILE $qwork/onchip_ram.v

# Hex display
set_global_assignment -name SYSTEMVERILOG_FILE $share_src/hex_display.sv

# Top-level SystemVerilog file
set_global_assignment -name SYSTEMVERILOG_FILE $src/de2.sv

# -----------------------------------------------------------------
# Design constraints
# -----------------------------------------------------------------

puts " - Applying constraints"

# Device type, logic, and pin assignments
source $constraints
set_default_constraints

# Timing (SDC) constraints
set_global_assignment -name SDC_FILE $scripts/de2.sdc

# -----------------------------------------------------------------
# Process the design
# -----------------------------------------------------------------

puts " - Processing the design"

execute_flow -compile

# Use one of the following to save the settings
#project_close
export_assignments

# Return to the top directory
cd $top

puts " - Processing completed"
puts ""

