# Altera JTAG-to-Avalon-MM Tutorial

5/20/2023 David W. Hawkins (dwh@caltech.edu)

# Introduction

This repository contains the original version of the JTAG-to-Avalon-MM tutorial created using Altera Quartus II 11.1sp1 in March 2012. The tutorial example for the BeMicro-SDK (Cyclone IV) board was synthesized under Quartus Prime Lite 22.1.1.

The JTAG-to-Avalon-MM tutorial was created when Altera was transitioning their system design tool from SOPC Builder to Qsys. Altera was purchased by Intel in 2015 (https://en.wikipedia.org/wiki/Altera). The development tool is now called Intel Quartus Prime, and the system design tool is called Platform Designer. Intel Platform Designer and Altera Qsys generate system design files using the same .qsys extension and format.

The tutorial was reimplemented using Quartus Prime Lite 22.1.1, with the SOPC System section removed, and the Qsys section updated for Platform Designer.

JTAG-to-Avalon-MM Tutorial repository                          | Tool Version
---------------------------------------------------------------|--------------
https://github.com/d-hawkins/altera_jtag_to_avalon_mm_tutorial | Altera Quartus II 11.1sp1
https://github.com/d-hawkins/intel_jtag_to_avalon_mm_tutorial  | Intel Quartus Prime 22.1.1

The original tutorial documentation was updated to change the tutorial links to point to this github repo.

# Quartus Synthesis Tests

## Quartus II 64-bit 14.1.0.186 Web Edition (Windows 7)

The BeMicro-SDK (Cyclone IV) example design was built as follows:

~~~
# Quartus version
tcl> puts $quartus(version)
Version 14.1.0 Build 186 12/03/2014 SJ Web Edition

# Create the tutorial Qsys system
tcl> set TUTORIAL [file normalize {c:\github\altera_jtag_to_avalon_mm_tutorial}]
tcl> cd $TUTORIAL/hdl/boards/bemicro_sdk/qsys_system
tcl> source scripts/synth.tcl

Synthesizing the BeMicro-SDK 'qsys_system' design
-------------------------------------------------
 - Quartus Version 14.1.0 Build 186 12/03/2014 SJ Web Edition
 - Creating the Quartus work directory
   * c:/github/altera_jtag_to_avalon_mm_tutorial/hdl/boards/bemicro_sdk/qsys_system/qwork
 - Create the project 'bemicro_sdk'
   * create a new bemicro_sdk project
 - Check the Qsys system
   * Copying the Qsys system file to the build directory
   * Please run Qsys, click on the 'Generation' tab, select 'Verilog'
     for 'Create simulation model', and click the 'Generate' button
     to generate the Qsys system,  and then re-run this script

# Per the instructions, use the Tools > Qsys GUI to generate the Qsys system files.
# Open qsys_system.qsys and the 11.1 IP gets upgraded to 14.1 without issue.
# Click Generate HDL, disable .bsf, enable Verilog simulation, and click Generate.

# Synthesis the complete design
tcl> source scripts/synth.tcl

Synthesizing the BeMicro-SDK 'qsys_system' design
-------------------------------------------------
 - Quartus Version 14.1.0 Build 186 12/03/2014 SJ Web Edition
 - Create the project 'bemicro_sdk'
   * close the project
   * open the existing bemicro_sdk project
 - Check the Qsys system
 - Creating the design files list
 - Applying constraints
 - Processing the design
 - Processing completed
 - Processing completed
~~~

The only issue observed after synthesis, was that Timing Analyzer reported unconstrained paths;
 * Inputs: pb, sw, JTAG TMS and TDI
 * Outputs: JTAG TDO
These unconstrained paths will be corrected in the updated version of the tutorial.

## Quartus II 64-bit 15.0.0.145 Full Edition (Windows 7)

The BeMicro-SDK (Cyclone IV) example design was built as follows:

~~~
# Quartus version
tcl> puts $quartus(version)
Version 15.0.0 Build 145 04/22/2015 SJ Full Version

# Create the tutorial Qsys system
tcl> set TUTORIAL [file normalize {c:\github\altera_jtag_to_avalon_mm_tutorial}]
tcl> cd $TUTORIAL/hdl/boards/bemicro_sdk/qsys_system
tcl> source scripts/synth.tcl

Synthesizing the BeMicro-SDK 'qsys_system' design
-------------------------------------------------
 - Quartus Version 15.0.0 Build 145 04/22/2015 SJ Full Version
 - Creating the Quartus work directory
   * c:/github/altera_jtag_to_avalon_mm_tutorial/hdl/boards/bemicro_sdk/qsys_system/qwork
 - Create the project 'bemicro_sdk'
   * create a new bemicro_sdk project
 - Check the Qsys system
   * Copying the Qsys system file to the build directory
   * Please run Qsys, click on the 'Generation' tab, select 'Verilog'
     for 'Create simulation model', and click the 'Generate' button
     to generate the Qsys system,  and then re-run this script

# Per the instructions, use the Tools > Qsys GUI to generate the Qsys system files.
# Open qsys_system.qsys and the 11.1 IP gets upgraded to 15.0 without issue.
# Click Generate HDL, disable .bsf, enable Verilog simulation, and click Generate.

# Synthesis the complete design
tcl> source scripts/synth.tcl

Synthesizing the BeMicro-SDK 'qsys_system' design
-------------------------------------------------
 - Quartus Version 15.0.0 Build 145 04/22/2015 SJ Full Version
 - Create the project 'bemicro_sdk'
   * close the project
   * open the existing bemicro_sdk project
 - Check the Qsys system
 - Creating the design files list
 - Applying constraints
 - Processing the design
 - Processing completed
~~~

Timing Analyzer reported the same unconstrained paths as for the 14.1 build.

## Quartus Prime 64-bit 22.1.1.917 Lite (Windows 10)

The BeMicro-SDK (Cyclone IV) example design was built as follows:

~~~
# Quartus version
tcl> puts $quartus(version)
Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition

# Create the tutorial Qsys system
tcl> set TUTORIAL [file normalize {c:\github\altera_jtag_to_avalon_mm_tutorial}]
tcl> cd $TUTORIAL/hdl/boards/bemicro_sdk/qsys_system
tcl> source scripts/synth.tcl

Synthesizing the BeMicro-SDK 'qsys_system' design
-------------------------------------------------
 - Quartus Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition
 - Creating the Quartus work directory
   * c:/github/altera_jtag_to_avalon_mm_tutorial/hdl/boards/bemicro_sdk/qsys_system/qwork
 - Create the project 'bemicro_sdk'
   * create a new bemicro_sdk project
 - Check the Qsys system
   * Copying the Qsys system file to the build directory
   * Please run Qsys, click on the 'Generation' tab, select 'Verilog'
     for 'Create simulation model', and click the 'Generate' button
     to generate the Qsys system,  and then re-run this script

# Use the Tools > Platform Designer GUI to generate the Qsys system files.
# Open qsys_system.qsys and the 11.1 IP gets upgraded to 22.1 without issue.
# Click Generate HDL, disable .bsf, enable Verilog simulation, and click Generate.

# Synthesis the complete design
tcl> source scripts/synth.tcl

Synthesizing the BeMicro-SDK 'qsys_system' design
-------------------------------------------------
 - Quartus Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition
 - Create the project 'bemicro_sdk'
   * close the project
   * open the existing bemicro_sdk project
 - Check the Qsys system
 - Creating the design files list
 - Applying constraints
 - Processing the design
 - Processing completed
~~~

Timing Analyzer reported the same unconstrained paths as for the 14.1 build.

# Modelsim and Questasim Simulation Tests

## Avalon-MM BFM Simulation

The Qsys system simulation script (hdl/qsys_system/scripts/sim.tcl) needs several minor edits to operate in newer versions of the simulator. Run the sim.tcl script in the simulator first, and it will be obvious which of the following edits are needed.

1. Library name change

 Lines 138 and 139 in the script:
 ~~~
 vlog -sv $hdl/qsys_system/test/qsys_system_bfm_master_tb.sv -L qsys_system_bfm_master
 vlog -sv $hdl/qsys_system/test/qsys_system_jtag_master_tb.sv -L qsys_system_bfm_master
 ~~~
 Need to be changed to:
 ~~~
 vlog -sv $hdl/qsys_system/test/qsys_system_bfm_master_tb.sv -L altera_common_sv_packages
 vlog -sv $hdl/qsys_system/test/qsys_system_jtag_master_tb.sv -L altera_common_sv_packages
 ~~~

2. The elab Tcl variable ELAB_OPTIONS needs to be visible within the two testbench procedures

 Lines 166 and 178 in the script:
 ~~~
 global hdl QSYS_SIMDIR
 ~~~
 Need to be changed to:
 ~~~
 global hdl QSYS_SIMDIR ELAB_OPTIONS
 ~~~

3. Questasim waveform display is empty

 Add the following statements to each of the testbench procedures starting lines 170 and 182:
 ~~~
 set USER_DEFINED_ELAB_OPTIONS "-voptargs=+acc"
 ~~~

Of the Quartus Modelsim and Questasim free editions tested, the following edits were required:
 - v14.1 required 1
 - v15.0 required 1+2
 - v22.1 required 1+2+3


## JTAG Simulation

The testbench hdl/qsys_system/test/qsys_system_jtag_master_tb.sv uses the JTAG node buried within the JTAG-to-Avalon-MM bridge to exercise the JTAG TAP (read the header comments to understand how VTAP is defined). In the newer versions of Quartus tested, the generated JTAG-to-Avalon-MM master code no longer contains the 'node' instance representing the TAP controller. The generated code now contains JTAG SLD Virtual JTAG ports that are connected through the design hierarchy until the JTAG component instance within the top-level jtag_master, where the JTAG TAP ports are tied off to zeros. The new Intel JTAG-to-Avalon-MM version of this tutorial will update the testbench to control the JTAG TAP ports.

