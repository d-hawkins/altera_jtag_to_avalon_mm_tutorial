# -----------------------------------------------------------------
# sim.tcl
#
# 2/20/2012 D. W. Hawkins (dwh@caltech.edu)
#
# JTAG-to-Avalon-MM tutorial SOPC System Modelsim simulation
# script.
#
# -----------------------------------------------------------------
# Usage
# -----
#
# From within Modelsim, change to the project folder, and type
#
#    source scripts/synth.tcl
#
# -----------------------------------------------------------------
# Notes:
# ------
#
# Tested with both Modelsim Altera Starter Edition and Modelsim-SE.
#
# -----------------------------------------------------------------

echo ""
echo "JTAG-to-Avalon-MM tutorial 'sopc_system' simulation script"
echo "----------------------------------------------------------"
echo ""

# -----------------------------------------------------------------
# Tutorial HDL folder
# -----------------------------------------------------------------
#
# Determine the altera_jtag_to_avalon_mm_tutorial/hdl directory
#
# * current location should be altera_jtag_to_avalon_mm_tutorial/
#   hdl/sopc_system, so strip off the last directory from the
#   current directory
#
set path [file split [pwd]]
set len  [llength $path]
set hdl  [eval file join [lrange $path 0 [expr {$len-2}]]]

# Check the directory name
if {![string match [file tail $hdl] "hdl"]} {
	puts [concat \
		"Error: this script should be sourced from the "\
		"sopc_system/ project directory. Please "\
		"change to that directory and try again."]
	return
}

# -----------------------------------------------------------------
# Create the Modelsim work directory
# -----------------------------------------------------------------
#
set mwork $hdl/sopc_system/mwork
if {![file exists $mwork]} {
	echo " * Creating the Modelsim work folder; $mwork"
	vlib mwork
}
# Create the mapping each time, since 'work' may have been
# redefined by another script.
vmap work mwork

# -----------------------------------------------------------------
# SOPC System
# -----------------------------------------------------------------
#
# Quartus must be used to create the 'generated' SOPC system.
# However, the generated files are pretty much independent of
# of the FPGA type. Unfortunately, Quartus needs an FPGA type
# to create a project, from which SOPC builder can be run.
# Use the sopc_system files from the BeMicro-SDK project.
#
set qwork $hdl/boards/bemicro_sdk/sopc_system/qwork
if {![file exists $qwork]} {
	echo [concat \
		"This simulation needs to compile source code generated " \
		"by Quartus for the BeMicro-SDK project. Please use "\
		"Quartus to run the synthesis script for that project. "\
		"This script can be run after SOPC Builder has been "\
		"used to 'generate' the SOPC system (full synthesis "\
		"of the Quartus project is not required)."]
	return
}

# -----------------------------------------------------------------
# Quartus IP directory
# -----------------------------------------------------------------
#
# NOTE: if you have multiple versions of Quartus installed,
# then you might want to edit this or the environment variable
# to force the use of a specific version.
#
echo " * Using QUARTUS_ROOTDIR = $env(QUARTUS_ROOTDIR)"

# Tcl variables
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
set ALTERA_IP_PATH  $QUARTUS_ROOTDIR/../ip/altera
set SOPC_IP_PATH    $ALTERA_IP_PATH/sopc_builder_ip

# -----------------------------------------------------------------
# SOPC system files
# -----------------------------------------------------------------
#
# Most of the files needed to build the SOPC system are inline
# in the generated sopc_system.v file. The +incdir+ option
# to vlog compiles them.
#

# Avalon-MM BFM
vlog -sv $SOPC_IP_PATH/verification/lib/verbosity_pkg.sv
vlog -sv $SOPC_IP_PATH/verification/lib/avalon_mm_pkg.sv
vlog -sv $SOPC_IP_PATH/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv

# The SOPC system (and its inlined include files)
vlog +incdir+$qwork $qwork/sopc_system.v;

# -----------------------------------------------------------------
# Testbenches
# -----------------------------------------------------------------
#
vlog -sv test/sopc_system_bfm_master_tb.sv
vlog -sv test/sopc_system_jtag_master_tb.sv

echo ""
echo "JTAG-to-Avalon-MM tutorial testbench procedures"
echo "-----------------------------------------------"
echo ""
echo "  sopc_system_bfm_master_tb  - run the Avalon-MM BFM testbench"
echo "  sopc_system_jtag_master_tb - run the JTAG-to-Avalon-MM testbench"

proc sopc_system_bfm_master_tb {} {
	global hdl
	vsim -novopt -t ps +nowarnTFMPC sopc_system_bfm_master_tb
	do $hdl/sopc_system/scripts/sopc_system_bfm_master_tb.do
	run -a
}

proc sopc_system_jtag_master_tb {} {
	global hdl
	vsim -novopt -t ps +nowarnTFMPC sopc_system_jtag_master_tb
	do $hdl/sopc_system/scripts/sopc_system_jtag_master_tb.do
	run -a
}

