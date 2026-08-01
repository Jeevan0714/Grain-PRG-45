#!/bin/bash
# ==============================================================================
# 1-Click Master Execution Script: Cadence 45nm Flow (Red Hat Linux Lab)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Starting Cadence 45nm ASIC Flow Execution          ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."
mkdir -p flow_45nm_cadence/results

# Step 1: RTL Functional Simulation
echo -e "${YELLOW}[1/3] Running Icarus Verilog Simulation...${NC}"
iverilog -o flow_45nm_cadence/results/sim_45nm flow_45nm_cadence/rtl/*.v flow_45nm_cadence/tb/tb_lfsr_nfsr.v
vvp flow_45nm_cadence/results/sim_45nm
echo -e "${GREEN}✓ Simulation Completed!${NC}\n"

# Step 2: Cadence Genus RTL Logic Synthesis
echo -e "${YELLOW}[2/3] Running Cadence Genus RTL Synthesis...${NC}"
if command -v genus &> /dev/null; then
    genus -files flow_45nm_cadence/genus_synth.tcl
    echo -e "${GREEN}✓ Synthesis Completed! Netlist saved to flow_45nm_cadence/results/netlist_genus_45nm.v${NC}\n"
else
    echo -e "${YELLOW}Cadence 'genus' command not found in PATH. Make sure you are on Red Hat Linux with Cadence licenses loaded.${NC}\n"
fi

# Step 3: Cadence Innovus Place & Route
echo -e "${YELLOW}[3/3] Running Cadence Innovus Place & Route...${NC}"
if command -v innovus &> /dev/null; then
    innovus -files flow_45nm_cadence/innovus_pnr.tcl
    echo -e "${GREEN}✓ Physical Layout Completed! DEF/GDS saved to flow_45nm_cadence/results/${NC}\n"
else
    echo -e "${YELLOW}Cadence 'innovus' command not found in PATH.${NC}\n"
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}  Cadence 45nm Flow Execution Finished!             ${NC}"
echo -e "${GREEN}====================================================${NC}"
