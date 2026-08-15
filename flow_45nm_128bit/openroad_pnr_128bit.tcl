# -----------------------------------------------------------------------------
# OpenROAD Place & Route — Grain-128 LFSR-NFSR 128-bit (NanGate 45nm Full Flow)
# Includes: Floorplan + Power Grid (PDN) + Placement + CTS + Routing
# -----------------------------------------------------------------------------

# 1. Read NanGate 45nm PDK Libraries
read_lef     /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef
read_lef     /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef
read_liberty /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 2. Read Synthesised Netlist and SDC Constraints
read_verilog flow_45nm_128bit/results/synth_netlist_128bit.v
link_design  lfsr_nfsr_top
read_sdc     flow_45nm_128bit/constraints.sdc

# 3. Floorplanning
initialize_floorplan -utilization 45 -aspect_ratio 1.0 -core_space 8.0
make_tracks

# 4. Power Distribution Network (PDN Power Grid & Straps)
add_global_connection -net VDD -pin_pattern VDD -power
add_global_connection -net VSS -pin_pattern VSS -ground
set_voltage_domain -name CORE -power VDD -ground VSS

define_pdn_grid -name core_grid -voltage_domains CORE
add_pdn_stripe -grid core_grid -layer metal4 -width 1.6 -pitch 20.0 -offset 5.0
add_pdn_stripe -grid core_grid -layer metal5 -width 1.6 -pitch 20.0 -offset 5.0
add_pdn_connect -grid core_grid -layers {metal4 metal5}
add_pdn_connect -grid core_grid -layers {metal1 metal4}
pdngen

# 5. I/O Pin Placement
place_pins -hor_layers metal3 -ver_layers metal2

# 6. Global & Detailed Placement
global_placement -density 0.55
detailed_placement

# 7. Global & Detailed Routing (Metal Wires & Vias)
global_route
detailed_route

# 8. Write Output DEF File
write_def flow_45nm_128bit/results/lfsr_nfsr_top_45nm.def

puts "========================================================="
puts "  Full 45nm Routed Layout with Power Grid Created!       "
puts "  Saved to: flow_45nm_128bit/results/lfsr_nfsr_top_45nm.def"
puts "========================================================="
exit
