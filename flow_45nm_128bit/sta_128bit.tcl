# -----------------------------------------------------------------------------
# OpenSTA Static Timing Analysis — Grain-128 LFSR-NFSR 128-bit (NanGate 45nm)
# -----------------------------------------------------------------------------

read_liberty /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib
read_verilog flow_45nm_128bit/results/synth_netlist_128bit.v
link_design  lfsr_nfsr_top
read_sdc     flow_45nm_128bit/constraints.sdc

puts "\n==========================================="
puts "  128-BIT GRAIN-128  |  SETUP TIMING      "
puts "==========================================="
report_checks -path_delay max -format full

puts "\n==========================================="
puts "  128-BIT GRAIN-128  |  HOLD TIMING       "
puts "==========================================="
report_checks -path_delay min -format full

puts "\n==========================================="
puts "  WORST SLACK & TIMING SUMMARY            "
puts "==========================================="
report_worst_slack -max
report_worst_slack -min
exit
