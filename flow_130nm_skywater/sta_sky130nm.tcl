# -----------------------------------------------------------------------------
# OpenSTA Static Timing Analysis Script for SkyWater 130nm Flow
# -----------------------------------------------------------------------------

read_verilog flow_130nm_skywater/results/synth_netlist_sky130.v
link_design lfsr_nfsr_top
read_sdc flow_130nm_skywater/constraints.sdc

puts "\n=========================================="
puts "  SKYWATER 130NM SETUP TIMING REPORT      "
puts "=========================================="
report_checks -path_delay max -format full

puts "\n=========================================="
puts "  SKYWATER 130NM HOLD TIMING REPORT       "
puts "=========================================="
report_checks -path_delay min -format full
exit
