# -----------------------------------------------------------------------------
# Laptop OpenROAD Place & Route Script for 45nm LFSR-NFSR PRNG
# -----------------------------------------------------------------------------

# 1. Read 45nm LEF Technology & Cell Libraries
read_lef ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef
read_lef ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef

# 2. Read 45nm Liberty Timing Library
read_liberty ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 3. Read Synthesized Netlist & SDC
read_verilog laptop_45nm_flow/synth_netlist_45nm.v
link_design lfsr_nfsr_top
read_sdc constraints.sdc

# 4. Initialize Floorplan (60% core utilization, 10um margins)
initialize_floorplan -utilization 60 -aspect_ratio 1.0 -core_space 10

# 5. Place IO Pins
place_pins -hor_layers metal3 -ver_layers metal2

# 6. Global & Detailed Cell Placement
global_placement
detailed_placement

# 7. Clock Tree Synthesis (CTS)
clock_tree_synthesis -root_buf CLKBUF_X1

# 8. Detailed Routing
global_route
detail_route

# 9. Write DEF and GDSII Layout Files
write_def laptop_45nm_flow/lfsr_nfsr_45nm.def
write_gds laptop_45nm_flow/lfsr_nfsr_45nm.gds

puts "OpenROAD Place and Route completed successfully!"
exit
