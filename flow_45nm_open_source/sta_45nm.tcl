# -----------------------------------------------------------------------------
# OpenSTA Static Timing Analysis Script for Open-Source 45nm Laptop Flow
# -----------------------------------------------------------------------------

read_liberty ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib
read_verilog flow_45nm_open_source/results/synth_netlist_45nm.v
link_design lfsr_nfsr_top
read_sdc flow_45nm_open_source/constraints.sdc

puts "\n=========================================="
puts "  OPEN-SOURCE 45NM SETUP TIMING REPORT   "
puts "=========================================="
report_checks -path_delay max -format full

puts "\n=========================================="
puts "  OPEN-SOURCE 45NM HOLD TIMING REPORT    "
puts "=========================================="
report_checks -path_delay min -format full
exit
