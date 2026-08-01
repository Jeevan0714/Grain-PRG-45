# -----------------------------------------------------------------------------
# Cadence Innovus Place & Route (P&R) Script for 45nm LFSR-NFSR PRNG
# -----------------------------------------------------------------------------

# 1. Design & LEF Library Initialization
set init_gnd_net VSS
set init_vdd_net VDD
set init_top_cell lfsr_nfsr_top
set init_verilog flow_45nm_cadence/results/netlist_genus_45nm.v
set init_lef_file {~/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef}
init_design

# 2. Floorplanning (Core Area Definition)
floorPlan -r 1.0 0.6 10 10 10 10

# 3. Power Planning (VDD/VSS Core Power Ring & Power Straps)
addRing -type core_rings -nets {VDD VSS} -width 1.0 -spacing 0.5 -layer {top M7 bottom M7 left M6 right M6}
sroute -connect { corePin }

# 4. Standard Cell Placement
place_design

# 5. Clock Tree Synthesis (CTS)
ccopt_design

# 6. Routing (NanoRoute Engine)
routeDesign

# 7. Verification Signoff (DRC & Connectivity)
verify_drc          -limit 1000 -output flow_45nm_cadence/results/innovus_drc.rpt
verifyConnectivity -type all   -output flow_45nm_cadence/results/innovus_conn.rpt

# 8. Export Physical DEF Layout and GDSII Stream Files
defOut -floorplan -routing flow_45nm_cadence/results/lfsr_nfsr_top_45nm.def
streamOut flow_45nm_cadence/results/lfsr_nfsr_top_45nm.gds -merge {~/vlsi_libraries/nangate45/NangateOpenCellLibrary.gds}

puts "Cadence Innovus Place & Route completed successfully!"
exit
