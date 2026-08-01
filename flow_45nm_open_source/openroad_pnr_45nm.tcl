# -----------------------------------------------------------------------------
# OpenROAD Place & Route (P&R) Script for Open-Source 45nm Laptop Flow
# -----------------------------------------------------------------------------

# 1. Read LEF and Liberty Libraries
read_lef ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef
read_lef ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef
read_liberty ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 2. Read Synthesized Netlist & SDC Constraints
read_verilog flow_45nm_open_source/results/synth_netlist_45nm.v
link_design lfsr_nfsr_top
read_sdc flow_45nm_open_source/constraints.sdc

# 3. Floorplanning
initialize_floorplan -utilization 40 -aspect_ratio 1.0 -core_space 10.0

# 4. Tapcell Insertion & Power Grid
make_tracks
global_placement

# 5. Detailed Placement & Clock Tree Synthesis
detailed_placement
clock_tree_synthesis

# 6. Global & Detailed Routing
global_route
detailed_route

# 7. Write Output DEF File
write_def flow_45nm_open_source/results/lfsr_nfsr_top_45nm.def
puts "OpenROAD Place & Route Completed Successfully!"
exit
