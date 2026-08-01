# -----------------------------------------------------------------------------
# Cadence Genus Synthesis Script for 45nm LFSR-NFSR PRNG
# -----------------------------------------------------------------------------

# 1. Set 45nm Target & Link Multi-Vth Liberty Libraries for Low-Leakage Optimization
set_db target_library [list \
    ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib \
    ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_low_temp.lib \
]
set_db link_library   [get_db target_library]

# 2. Read Verilog RTL Source Files
read_hdl [glob rtl/*.v]

# 3. Elaborate Top Level Design
elaborate lfsr_nfsr_top

# 4. Apply SDC Clock Constraints
read_sdc constraints.sdc

# 5. Enable Low-Power Optimization Targets (Multi-Vt Swapping & Automatic Clock Gating)
set_db leak_power_effort high
set_db lp_insert_clock_gating true

# 6. Run Synthesis Stages (Generic -> Mapping -> Optimization with Leakage & Dynamic Power Reduction)
syn_generic
syn_map
syn_opt -leakage_power

# 7. Generate Netlist & SDC Outputs
write_hdl > cadence_45nm_flow/netlist_genus_45nm.v
write_sdc > cadence_45nm_flow/constraints_genus_45nm.sdc

# 8. Write Synthesis Performance Reports (Area, Timing, Gate Count & Leakage Power)
report_area   > cadence_45nm_flow/reports_genus_area.txt
report_gates  > cadence_45nm_flow/reports_genus_gates.txt
report_timing > cadence_45nm_flow/reports_genus_timing.txt
report_power  > cadence_45nm_flow/reports_genus_power.txt

puts "Cadence Genus Multi-Vth Low-Leakage Synthesis completed successfully!"
exit

