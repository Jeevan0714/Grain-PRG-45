#!/usr/bin/env bash
# =============================================================================
# Master 1-Click Execution Script for Cadence 45nm Flow (Red Hat Linux Lab)
# =============================================================================

set -e

echo "=================================================================="
echo "⚙️ 1. RUNNING CADENCE GENUS 45nm LOGIC SYNTHESIS"
echo "=================================================================="
if command -v genus &> /dev/null; then
    genus -files cadence_45nm_flow/genus_synth.tcl
else
    echo "❌ Error: 'genus' command not found!"
    echo "Make sure you sourced your lab environment (e.g., source /tools/cadence/env.sh)"
    exit 1
fi

echo "=================================================================="
echo "🎨 2. RUNNING CADENCE INNOVUS 45nm PLACE & ROUTE"
echo "=================================================================="
if command -v innovus &> /dev/null; then
    innovus -files cadence_45nm_flow/innovus_pnr.tcl
else
    echo "❌ Error: 'innovus' command not found!"
    echo "Make sure you sourced your lab environment (e.g., source /tools/cadence/env.sh)"
    exit 1
fi

echo "=================================================================="
echo "✅ CADENCE 45nm FLOW COMPLETED SUCCESSFULLY!"
echo "Outputs & GDSII saved inside cadence_45nm_flow/ directory."
echo "=================================================================="
