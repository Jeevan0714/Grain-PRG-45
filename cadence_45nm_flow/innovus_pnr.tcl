# -----------------------------------------------------------------------------
# Cadence Innovus Physical Design (P&R) Script for 45nm LFSR-NFSR PRNG
# -----------------------------------------------------------------------------

# 1. Define Design Inputs & 45nm LEF Libraries
set init_gnd_net VSS
set init_vdd_net VDD
set init_top_cell lfsr_nfsr_top
set init_verilog cadence_45nm_flow/netlist_genus_45nm.v
set init_lef_file {
  ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef 
  ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef
}

# 2. Initialize Design
init_design

# 3. Floorplanning (Core utilization = 0.6, Margins = 10um)
floorPlan -r 1.0 0.6 10 10 10 10

# 4. Power Grid Generation (VDD/VSS Rings & Stripes)
addRing -type core_rings -nets {VDD VSS} -width 1.0 -spacing 0.5 -layer {top M7 bottom M7 left M6 right M6}
sroute -connect { corePin }

# 5. Standard Cell Placement
place_design

# 6. Clock Tree Synthesis (CTS)
ccopt_design

# 7. Global & Detail Routing (NanoRoute)
routeDesign

# 8. Physical DRC Verification & Signoff
verify_drc
verifyConnectivity

# 9. Stream Out DEF & GDSII Files
defOut -floorplan -routing cadence_45nm_flow/lfsr_nfsr_top_45nm.def
streamOut cadence_45nm_flow/lfsr_nfsr_top_45nm.gds -merge {~/vlsi_libraries/nangate45/NangateOpenCellLibrary.gds}

puts "Cadence Innovus Place and Route completed successfully!"
exit
