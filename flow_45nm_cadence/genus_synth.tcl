# -----------------------------------------------------------------------------
# Cadence Genus Synthesis Script for 45nm LFSR-NFSR PRNG (Low-Power Multi-Vt)
# -----------------------------------------------------------------------------

# 1. Set 45nm Target & Link Multi-Vth Liberty Libraries
set_db target_library [list \
    ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib \
    ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_low_temp.lib \
]
set_db link_library   [get_db target_library]

# 2. Read Verilog RTL Source Files from flow_45nm_cadence/rtl/
read_hdl [glob flow_45nm_cadence/rtl/*.v]

# 3. Elaborate Top Level Module
elaborate lfsr_nfsr_top

# 4. Apply SDC Clock Constraints
read_sdc flow_45nm_cadence/constraints.sdc

# 5. Enable Low-Power Optimization Targets (Multi-Vt Swapping & Clock Gating)
set_db leak_power_effort high
set_db lp_insert_clock_gating true

# 6. Run Synthesis Stages (Generic -> Mapping -> Optimization)
syn_generic
syn_map
syn_opt -leakage_power

# 7. Export Gate-Level Netlist & SDC Outputs to results/
write_hdl > flow_45nm_cadence/results/netlist_genus_45nm.v
write_sdc > flow_45nm_cadence/results/constraints_genus_45nm.sdc

# 8. Write Synthesis Performance Reports (Area, Timing, Gate Count & Power)
report_area   > flow_45nm_cadence/results/reports_genus_area.txt
report_gates  > flow_45nm_cadence/results/reports_genus_gates.txt
report_timing > flow_45nm_cadence/results/reports_genus_timing.txt
report_power  > flow_45nm_cadence/results/reports_genus_power.txt

puts "Cadence Genus Multi-Vth Low-Power Synthesis completed successfully!"
exit
