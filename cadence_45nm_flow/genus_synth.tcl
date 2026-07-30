# -----------------------------------------------------------------------------
# Cadence Genus Synthesis Script for 45nm LFSR-NFSR PRNG
# -----------------------------------------------------------------------------

# 1. Set 45nm Target & Link Liberty Libraries
set_db target_library ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib
set_db link_library   ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

# 2. Read Verilog RTL Source Files
read_hdl [glob rtl/*.v]

# 3. Elaborate Top Level Design
elaborate lfsr_nfsr_top

# 4. Apply SDC Clock Constraints
read_sdc constraints.sdc

# 5. Run Synthesis Stages (Generic -> Mapping -> Optimization)
syn_generic
syn_map
syn_opt

# 6. Generate Netlist & SDC Outputs
write_hdl > cadence_45nm_flow/netlist_genus_45nm.v
write_sdc > cadence_45nm_flow/constraints_genus_45nm.sdc

# 7. Write Synthesis Performance Reports
report_area   > cadence_45nm_flow/reports_genus_area.txt
report_gates  > cadence_45nm_flow/reports_genus_gates.txt
report_timing > cadence_45nm_flow/reports_genus_timing.txt
report_power  > cadence_45nm_flow/reports_genus_power.txt

puts "Cadence Genus Synthesis completed successfully!"
exit
