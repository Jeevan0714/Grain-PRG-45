#!/bin/bash
# ==============================================================================
# 1-Click Master Execution Script: SkyWater 130nm ASIC Flow (Laptop Execution)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Starting SkyWater 130nm Flow Execution            ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

# Step 1: RTL Functional Simulation
echo -e "${YELLOW}[1/3] Running Icarus Verilog Simulation...${NC}"
mkdir -p flow_130nm_skywater/results
iverilog -o flow_130nm_skywater/results/sim_130nm flow_130nm_skywater/rtl/*.v flow_130nm_skywater/tb/tb_lfsr_nfsr.v
vvp flow_130nm_skywater/results/sim_130nm
echo -e "${GREEN}✓ Simulation Completed Successfully!${NC}\n"

# Step 2: Yosys RTL Synthesis
echo -e "${YELLOW}[2/3] Running Yosys Synthesis for SkyWater 130nm...${NC}"
yosys -s flow_130nm_skywater/synth_sky130nm.ys
echo -e "${GREEN}✓ Synthesis Completed! Netlist saved to flow_130nm_skywater/results/synth_netlist_sky130.v${NC}\n"

# Step 3: OpenSTA Static Timing Analysis
echo -e "${YELLOW}[3/3] Running OpenSTA Static Timing Analysis...${NC}"
if command -v sta &> /dev/null; then
    sta -exit flow_130nm_skywater/sta_sky130nm.tcl | tee flow_130nm_skywater/results/sta_report_130nm.txt
    echo -e "${GREEN}✓ STA Report saved to flow_130nm_skywater/results/sta_report_130nm.txt${NC}\n"
else
    echo -e "${YELLOW}OpenSTA ('sta') tool not installed on laptop. Skipping STA.${NC}\n"
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}  SkyWater 130nm Flow Execution Finished!           ${NC}"
echo -e "${GREEN}====================================================${NC}"
