# de2.sdc
#
# 2/21/2012 D. W. Hawkins (dwh@caltech.edu)
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
set clk clk_50MHz
create_clock -period $clk_period -name $clk [get_ports $clk]

# Derive the clock uncertainty parameter
# * For the DE2 board Cyclone II device, this setting produces the
#   message 'Family doesn't support jitter analysis', so skip it.
#derive_clock_uncertainty

# -----------------------------------------------------------------
# Cut timing paths
# -----------------------------------------------------------------
#
# The timing for the I/Os in this design is arbitrary, so cut all
# paths to the I/Os, even the ones that are used in the design,
# i.e., the LEDs, switches, and hex displays.
#

# Push button (key) inputs
set_false_path -from [get_ports key[*]] -to *

# LED and hex displays outputs
set_false_path -from * -to [get_ports {led_* hex_*}]

