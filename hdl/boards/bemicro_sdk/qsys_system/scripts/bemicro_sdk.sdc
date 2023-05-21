# bemicro_sdk.sdc
#
# 4/26/2011 D. W. Hawkins (dwh@caltech.edu)
#
# Quartus II synthesis TimeQuest SDC timing constraints.
#
# -----------------------------------------------------------------
# Notes:
# ------
#
# 1. The results of this script can be analyzed using the
#    TimeQuest GUI
#
#    a) From Quartus, select Tools->TimeQuest Timing Analyzer
#    b) In TimeQuest, Netlist->Create Timing Netlist, Ok
#    c) Run any of the analysis tasks
#       eg. 'Check Timing' and 'Report Unconstrained Paths'
#       show the design is constrained.
#
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Clock
# -----------------------------------------------------------------
#
# 50MHz clock (20ns period)
set clk_period 20

# External 50MHz clock (internal logic clock)
set clk clkin_50MHz
create_clock -period $clk_period -name $clk [get_ports $clk]

# Derive the clock uncertainty parameter
derive_clock_uncertainty

# -----------------------------------------------------------------
# Cut timing paths
# -----------------------------------------------------------------
#
# The timing for the I/Os in this design is arbitrary, so cut all
# paths to the I/Os, even the ones that are used in the design,
# i.e., reset and the LEDs.
#

# External asynchronous reset
set_false_path -from [get_ports cpu_rstN] -to *

# LED output path
set_false_path -from * -to [get_ports led*]

