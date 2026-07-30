#!/usr/bin/env bash
# =============================================================================
# Master 1-Click Execution Script for 45nm ASIC Flow on Personal Laptop
# =============================================================================

set -e

echo "=================================================================="
echo "🚀 1. RUNNING RTL SIMULATION (Icarus Verilog)"
echo "=================================================================="
iverilog -o laptop_45nm_flow/sim.out tb/tb_lfsr_nfsr.v rtl/*.v
vvp laptop_45nm_flow/sim.out

echo "=================================================================="
echo "⚙️ 2. RUNNING 45nm LOGIC SYNTHESIS (Yosys)"
echo "=================================================================="
yosys -s laptop_45nm_flow/synth_45nm.ys

echo "=================================================================="
echo "⏱️ 3. RUNNING 45nm STATIC TIMING ANALYSIS (OpenSTA)"
echo "=================================================================="
opensta laptop_45nm_flow/sta_45nm.tcl

echo "=================================================================="
echo "🎨 4. RUNNING 45nm PLACE & ROUTE (OpenROAD)"
echo "=================================================================="
if command -v openroad &> /dev/null; then
    openroad laptop_45nm_flow/openroad_pnr_45nm.tcl
else
    echo "⚠️ OpenROAD is not installed on path. Skipping physical P&R stage."
    echo "To view layout, ensure OpenROAD or KLayout is installed."
fi

echo "=================================================================="
echo "✅ 45nm LAPTOP FLOW COMPLETED SUCCESSFULLY!"
echo "Outputs generated inside laptop_45nm_flow/ directory."
echo "=================================================================="
