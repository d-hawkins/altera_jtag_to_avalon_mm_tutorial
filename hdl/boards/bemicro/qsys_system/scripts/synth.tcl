# -----------------------------------------------------------------
# boards/bemicro/qsys_system/scripts/synth.tcl
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
# References
# ----------
#
# [1] Altera. "Quartus II Scripting Reference Manual",
#     v9.1, 2009.
#
# [2] Altera. "Quartus II Settings File Reference Manual",
#     v7.0, 2010.
#
#
# -----------------------------------------------------------------

puts ""
puts "Synthesizing the BeMicro 'qsys_system' design"
puts "---------------------------------------------"

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
#   hdl/boards/bemicro/qsys_system, so strip off the last
#   few directories from the current directory
#
set path [file split [pwd]]
set len  [llength $path]
set hdl  [eval file join [lrange $path 0 [expr {$len-4}]]]

# Check the directory name
if {![string match [file tail $hdl] "hdl"]} {
	puts [concat \
		"Error: this script should be sourced from the "\
		"BeMicro qsys_system/ project directory. Please "\
		"change to that directory and try again."]
	return
}

# -----------------------------------------------------------------
# Design paths
# -----------------------------------------------------------------

# Design parameters
set board      bemicro
set design     qsys_system

# Design paths
set constraints $hdl/boards/$board/share/scripts/constraints.tcl
set top  		$hdl/boards/$board/$design
set scripts     $top/scripts
set src         $top/src

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
# Qsys System
# -----------------------------------------------------------------
#

# Generate the SOPC system
#
# 1) SOPC file
#    - if it does not exist, copy it to the build area
#
# 2) Ideally the script would detect if qsys_system.v is older
#    than the .qsys file or perhaps a timestamp file, and rebuild
#    if it if needed, however, I have not looked out how to call
#    Qsys from Tcl. So for now, just make the user do it.
#
# The Qsys system has to be copied to the project directory,
# since it generates files in a subfolder of the directory
# containing the Qsys file.
#
puts " - Check the Qsys system"
if {![file exists qsys_system.qsys]} {
	puts "   * Copying the Qsys system file to the build directory"
	file copy $hdl/qsys_system/scripts/qsys_system.qsys $qwork/qsys_system.qsys
}

# Check the top-level SOPC system Verilog file exists
# * assume the other SOPC files have not been deleted
if {![file exists qsys_system/synthesis/qsys_system.v]} {
	puts "   * Please run Qsys, click on the 'Generation' tab, select 'Verilog'"
	puts "     for 'Create simulation model', and click the 'Generate' button"
	puts "     to generate the Qsys system,  and then re-run this script"
	cd $top
	return
}

# Add the Qsys IP file (which adds all the required files)
set_global_assignment -name QIP_FILE $qwork/qsys_system/synthesis/qsys_system.qip

# -----------------------------------------------------------------
# HDL files
# -----------------------------------------------------------------

puts " - Creating the design files list"

# Top-level SystemVerilog file
set_global_assignment -name SYSTEMVERILOG_FILE $src/bemicro.sv

# -----------------------------------------------------------------
# Design constraints
# -----------------------------------------------------------------

puts " - Applying constraints"

# Device type, logic, and pin assignments
source $constraints
set_default_constraints

# Timing (SDC) constraints
set_global_assignment -name SDC_FILE $scripts/bemicro.sdc

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

