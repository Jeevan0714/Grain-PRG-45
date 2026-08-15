#!/bin/bash
# =============================================================================
# Generate All PPA Reports — OpenLane-Style
# Grain-128 LFSR-NFSR 128-bit | NanGate 45nm
#
# Output:
#   flow_45nm_128bit/reports/synthesis/area_utilization.rpt
#   flow_45nm_128bit/reports/signoff/timing_setup.rpt
#   flow_45nm_128bit/reports/signoff/timing_hold.rpt
#   flow_45nm_128bit/reports/signoff/timing_summary.rpt
#   flow_45nm_128bit/reports/signoff/power.rpt
# =============================================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

LIB="/home/jeevan/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib"
NETLIST="flow_45nm_128bit/results/synth_netlist_128bit.v"
SDC="flow_45nm_128bit/constraints.sdc"
RPT="flow_45nm_128bit/reports"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  Generating OpenLane-Style PPA Reports — NanGate 45nm     ${NC}"
echo -e "${BLUE}============================================================${NC}"

mkdir -p "$RPT/synthesis" "$RPT/signoff"

# ── 1. AREA (Yosys) ──────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Area & Cell Utilization (Yosys)...${NC}"
{
  echo "============================================================"
  echo "  DESIGN AREA & CELL UTILIZATION REPORT"
  echo "  Design  : lfsr_nfsr_top"
  echo "  Process : NanGate 45nm (typical corner)"
  echo "============================================================"
  echo ""
  yosys -p "
    read_verilog flow_45nm_128bit/rtl/LFSR.v \
                 flow_45nm_128bit/rtl/NFSR.v \
                 flow_45nm_128bit/rtl/keystream.v \
                 flow_45nm_128bit/rtl/encrypt.v \
                 flow_45nm_128bit/rtl/decrypt.v \
                 flow_45nm_128bit/rtl/lfsr_nfsr_top.v
    hierarchy -check -top lfsr_nfsr_top
    proc; opt; techmap
    dfflibmap -liberty $LIB
    abc -liberty $LIB
    flatten; clean
    stat -liberty $LIB
  " 2>&1 | grep -A 30 "=== lfsr_nfsr_top ===" | head -25
} > "$RPT/synthesis/area_utilization.rpt"
echo -e "${GREEN}  ✓ reports/synthesis/area_utilization.rpt${NC}"

# Helper function — run sta and save to file
run_sta() {
  local tcl_cmds="$1"
  local outfile="$2"
  {
    sta -exit << STAEOF
read_liberty $LIB
read_verilog $NETLIST
link_design  lfsr_nfsr_top
read_sdc     $SDC
$tcl_cmds
STAEOF
  } > "$outfile" 2>&1
}

# ── 2. SETUP TIMING ──────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/5] Setup Timing Report (OpenSTA)...${NC}"
run_sta '
puts "============================================================"
puts "  SETUP TIMING REPORT (MAX PATH DELAY)"
puts "  Design: lfsr_nfsr_top  |  Clock: 100 MHz (10.000 ns)"
puts "============================================================"
puts ""
report_checks -path_delay max -format full_clock_expanded -fields {slew cap input_pins nets} -digits 4
puts ""
puts "------------------------------------------------------------"
puts "  Worst Negative Slack (WNS) — Setup:"
report_worst_slack -max
report_tns
puts "------------------------------------------------------------"
' "$RPT/signoff/timing_setup.rpt"
echo -e "${GREEN}  ✓ reports/signoff/timing_setup.rpt${NC}"

# ── 3. HOLD TIMING ───────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/5] Hold Timing Report (OpenSTA)...${NC}"
run_sta '
puts "============================================================"
puts "  HOLD TIMING REPORT (MIN PATH DELAY)"
puts "  Design: lfsr_nfsr_top  |  Clock: 100 MHz (10.000 ns)"
puts "============================================================"
puts ""
report_checks -path_delay min -format full_clock_expanded -fields {slew cap input_pins nets} -digits 4
puts ""
puts "------------------------------------------------------------"
puts "  Worst Negative Slack (WNS) — Hold:"
report_worst_slack -min
puts "------------------------------------------------------------"
' "$RPT/signoff/timing_hold.rpt"
echo -e "${GREEN}  ✓ reports/signoff/timing_hold.rpt${NC}"

# ── 4. TIMING SUMMARY ────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/5] Timing Summary (OpenSTA)...${NC}"
run_sta '
puts "============================================================"
puts "  TIMING SUMMARY REPORT"
puts "  Design : lfsr_nfsr_top  |  NanGate 45nm"
puts "  Clock  : 100 MHz  |  Period: 10.000 ns"
puts "============================================================"
puts ""
puts "  Setup (Max Path):"
report_worst_slack -max
report_tns
puts ""
puts "  Hold (Min Path):"
report_worst_slack -min
puts ""
puts "============================================================"
' "$RPT/signoff/timing_summary.rpt"
echo -e "${GREEN}  ✓ reports/signoff/timing_summary.rpt${NC}"

# ── 5. POWER ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/5] Power Estimation (OpenSTA)...${NC}"
run_sta '
puts "============================================================"
puts "  POWER ESTIMATION REPORT"
puts "  Design  : lfsr_nfsr_top  |  NanGate 45nm"
puts "  Voltage : 1.1V  |  Activity: default (0.5 toggle rate)"
puts "============================================================"
puts ""
report_power
puts "============================================================"
' "$RPT/signoff/power.rpt"
echo -e "${GREEN}  ✓ reports/signoff/power.rpt${NC}"

# ── FINAL SUMMARY ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  All PPA Reports Generated!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  📁 flow_45nm_128bit/reports/"
echo "      ├── synthesis/"
echo "      │   └── area_utilization.rpt   ← Cell count + chip area"
echo "      └── signoff/"
echo "          ├── timing_setup.rpt       ← Setup slack + critical path"
echo "          ├── timing_hold.rpt        ← Hold slack + min path"
echo "          ├── timing_summary.rpt     ← WNS/TNS summary"
echo "          └── power.rpt              ← Internal/Switching/Leakage power"
echo ""
