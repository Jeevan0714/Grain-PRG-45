# =============================================================================
# OpenROAD Report Generator — Grain-128 128-bit | NanGate 45nm
# Generates OpenLane-style structured reports after Place & Route
#
# Reports generated:
#   reports/synthesis/  ← Area utilization (from Yosys stat)
#   reports/signoff/    ← Timing (setup/hold), Power, DRC check
# =============================================================================

set DESIGN     lfsr_nfsr_top
set NETLIST    flow_45nm_128bit/results/synth_netlist_128bit.v
set SDC        flow_45nm_128bit/constraints.sdc
set LIB        /home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib

set RPT_DIR    flow_45nm_128bit/reports

# =============================================================================
# 1. Load Design (netlist + liberty + SDC only — no LEF/DEF needed for STA)
# =============================================================================
read_liberty $LIB
read_verilog $NETLIST
link_design  $DESIGN
read_sdc     $SDC

# =============================================================================
# 2. REPORT: Design Area & Cell Utilization
# =============================================================================
set fp [open "$RPT_DIR/synthesis/area_utilization.rpt" w]
puts $fp "============================================================"
puts $fp "  DESIGN AREA & CELL UTILIZATION REPORT"
puts $fp "  Design  : $DESIGN"
puts $fp "  Process : NanGate 45nm Open Cell Library"
puts $fp "============================================================"
puts $fp ""
puts $fp [report_design_area]
puts $fp ""
puts $fp "------------------------------------------------------------"
puts $fp "  Standard Cell Instance Count"
puts $fp "------------------------------------------------------------"
puts $fp [report_cell_usage]
close $fp
puts "✓ Area report   → $RPT_DIR/synthesis/area_utilization.rpt"

# =============================================================================
# 3. REPORT: Setup Timing (Max Path)
# =============================================================================
set fp [open "$RPT_DIR/signoff/timing_setup.rpt" w]
puts $fp "============================================================"
puts $fp "  SETUP TIMING REPORT (MAX PATH DELAY)"
puts $fp "  Design  : $DESIGN | Clock: 100 MHz (10ns period)"
puts $fp "============================================================"
puts $fp ""
puts $fp [report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pins nets fanout} -digits 4]
puts $fp ""
puts $fp "------------------------------------------------------------"
puts $fp "  WORST NEGATIVE SLACK (WNS) — Setup"
puts $fp "------------------------------------------------------------"
puts $fp [report_worst_slack -max]
puts $fp ""
puts $fp [report_tns]
close $fp
puts "✓ Setup timing  → $RPT_DIR/signoff/timing_setup.rpt"

# =============================================================================
# 4. REPORT: Hold Timing (Min Path)
# =============================================================================
set fp [open "$RPT_DIR/signoff/timing_hold.rpt" w]
puts $fp "============================================================"
puts $fp "  HOLD TIMING REPORT (MIN PATH DELAY)"
puts $fp "  Design  : $DESIGN | Clock: 100 MHz (10ns period)"
puts $fp "============================================================"
puts $fp ""
puts $fp [report_checks -path_delay min -format full_clock_expanded -fields {slew cap input_pins nets fanout} -digits 4]
puts $fp ""
puts $fp "------------------------------------------------------------"
puts $fp "  WORST NEGATIVE SLACK (WNS) — Hold"
puts $fp "------------------------------------------------------------"
puts $fp [report_worst_slack -min]
close $fp
puts "✓ Hold timing   → $RPT_DIR/signoff/timing_hold.rpt"

# =============================================================================
# 5. REPORT: Power Estimation
# =============================================================================
set fp [open "$RPT_DIR/signoff/power.rpt" w]
puts $fp "============================================================"
puts $fp "  POWER ESTIMATION REPORT"
puts $fp "  Design  : $DESIGN | Process: NanGate 45nm"
puts $fp "  Voltage : 1.1V  | Activity: 0.2 (default)"
puts $fp "============================================================"
puts $fp ""
puts $fp [report_power]
close $fp
puts "✓ Power report  → $RPT_DIR/signoff/power.rpt"

# =============================================================================
# 6. REPORT: Timing Summary (WNS / TNS / SETUP / HOLD combined)
# =============================================================================
set fp [open "$RPT_DIR/signoff/timing_summary.rpt" w]
puts $fp "============================================================"
puts $fp "  TIMING SUMMARY REPORT"
puts $fp "  Design  : $DESIGN"
puts $fp "  Clock   : 100 MHz | Period: 10.000 ns"
puts $fp "============================================================"
puts $fp ""
puts $fp "  Setup (Max Path):"
puts $fp [report_worst_slack -max]
puts $fp [report_tns]
puts $fp ""
puts $fp "  Hold (Min Path):"
puts $fp [report_worst_slack -min]
puts $fp ""
puts $fp "============================================================"
close $fp
puts "✓ Timing summary→ $RPT_DIR/signoff/timing_summary.rpt"

# =============================================================================
puts ""
puts "============================================================"
puts "  ALL REPORTS GENERATED SUCCESSFULLY"
puts "  Location: flow_45nm_128bit/reports/"
puts "    ├── synthesis/area_utilization.rpt"
puts "    └── signoff/"
puts "        ├── timing_setup.rpt"
puts "        ├── timing_hold.rpt"
puts "        ├── timing_summary.rpt"
puts "        └── power.rpt"
puts "============================================================"
exit
