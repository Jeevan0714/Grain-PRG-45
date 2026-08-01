#!/bin/bash
# ==============================================================================
# 1-Click Laptop Execution Script: Open-Source 45nm Flow (Yosys + OpenROAD + STA)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Starting Open-Source 45nm Laptop Flow              ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."
mkdir -p flow_45nm_open_source/results

# Step 1: RTL Functional Simulation
echo -e "${YELLOW}[1/4] Running Icarus Verilog Simulation...${NC}"
iverilog -o flow_45nm_open_source/results/sim_45nm_os flow_45nm_open_source/rtl/*.v flow_45nm_open_source/tb/tb_lfsr_nfsr.v
vvp flow_45nm_open_source/results/sim_45nm_os
echo -e "${GREEN}✓ Simulation Completed!${NC}\n"

# Step 2: Yosys RTL Synthesis
echo -e "${YELLOW}[2/4] Running Yosys Synthesis for 45nm...${NC}"
yosys -s flow_45nm_open_source/synth_45nm.ys
echo -e "${GREEN}✓ Synthesis Completed! Netlist saved to flow_45nm_open_source/results/synth_netlist_45nm.v${NC}\n"

# Step 3: OpenROAD Place & Route (if installed)
echo -e "${YELLOW}[3/4] Running OpenROAD Place & Route...${NC}"
if command -v openroad &> /dev/null; then
    openroad -exit flow_45nm_open_source/openroad_pnr_45nm.tcl
    echo -e "${GREEN}✓ OpenROAD Place & Route Completed! DEF saved to flow_45nm_open_source/results/lfsr_nfsr_top_45nm.def${NC}\n"
else
    echo -e "${YELLOW}OpenROAD ('openroad') not installed on laptop. Skipping PnR step.${NC}\n"
fi

# Step 4: OpenSTA Static Timing Analysis (if installed)
echo -e "${YELLOW}[4/4] Running OpenSTA Static Timing Analysis...${NC}"
if command -v sta &> /dev/null; then
    sta -exit flow_45nm_open_source/sta_45nm.tcl | tee flow_45nm_open_source/results/sta_report_45nm.txt
    echo -e "${GREEN}✓ STA Report saved to flow_45nm_open_source/results/sta_report_45nm.txt${NC}\n"
else
    echo -e "${YELLOW}OpenSTA ('sta') not installed on laptop. Skipping STA step.${NC}\n"
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}  Open-Source 45nm Laptop Flow Execution Finished!  ${NC}"
echo -e "${GREEN}====================================================${NC}"
