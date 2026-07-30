# -----------------------------------------------------------------------------
# Laptop OpenSTA Timing Script for 45nm LFSR-NFSR PRNG
# -----------------------------------------------------------------------------

# 1. Read 45nm Liberty Timing File
read_liberty ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 2. Read Synthesized 45nm Netlist
read_verilog laptop_45nm_flow/synth_netlist_45nm.v

# 3. Link Top Design
link_design lfsr_nfsr_top

# 4. Read SDC Clock Constraints
read_sdc constraints.sdc

# 5. Report Max (Setup) Delay & Min (Hold) Delay Checks
puts "\n=============== SETUP TIME CHECK (MAX DELAY) ==============="
report_checks -path_delay max -format full

puts "\n=============== HOLD TIME CHECK (MIN DELAY) ==============="
report_checks -path_delay min -format full

exit
