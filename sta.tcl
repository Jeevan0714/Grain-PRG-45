# 1. Read the Nangate 45nm standard cell library
read_liberty ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 2. Read your newly generated synthesized netlist
read_verilog synth_netlist.v

# 3. Link the design to your top module
link_design lfsr_nfsr_top

# 4. Read the clock constraints you just made
read_sdc constraints.sdc

# 5. Report Setup time (Max delay) - Are signals arriving too late?
report_checks -path_delay max -format full

# 6. Report Hold time (Min delay) - Are signals arriving too fast?
report_checks -path_delay min -format full