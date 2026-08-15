#!/bin/bash
# ==============================================================================
# 1-Click Execution Script: Grain-128 LFSR-NFSR 128-bit (Yosys + OpenROAD + STA)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}  Grain-128 LFSR-NFSR  |  128-bit  |  NanGate 45nm ASIC Flow  ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Navigate to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."
mkdir -p flow_45nm_128bit/results

# ── Step 1: RTL Functional Simulation ────────────────────────────────────────
echo -e "${YELLOW}[1/4] Running Icarus Verilog Simulation (Encryption Demo)...${NC}"
iverilog -o flow_45nm_128bit/results/sim_128bit \
    flow_45nm_128bit/rtl/LFSR.v \
    flow_45nm_128bit/rtl/NFSR.v \
    flow_45nm_128bit/rtl/keystream.v \
    flow_45nm_128bit/rtl/encrypt.v \
    flow_45nm_128bit/rtl/decrypt.v \
    flow_45nm_128bit/rtl/lfsr_nfsr_top.v \
    flow_45nm_128bit/tb/tb_lfsr_nfsr.v
vvp flow_45nm_128bit/results/sim_128bit
echo -e "${GREEN}✓ Simulation Completed!${NC}\n"

# ── Step 2: Yosys RTL Synthesis (NanGate 45nm Mapped) ────────────────────────
echo -e "${YELLOW}[2/4] Running Yosys Synthesis for 128-bit Grain-128...${NC}"
yosys -s flow_45nm_128bit/synth_128bit.ys
echo -e "${GREEN}✓ Synthesis Completed! Netlist → flow_45nm_128bit/results/synth_netlist_128bit.v${NC}\n"

# ── Step 3: OpenROAD Place & Route ───────────────────────────────────────────
echo -e "${YELLOW}[3/4] Running OpenROAD Place & Route (45nm Layout)...${NC}"
if command -v docker &> /dev/null; then
    docker run --rm \
        -v "$PWD":/work \
        -v /home/jeevan/vlsi_libraries:/home/jeevan/vlsi_libraries \
        -w /work \
        efabless/openlane:2023.09.07 \
        openroad flow_45nm_128bit/openroad_pnr_128bit.tcl
    echo -e "${GREEN}✓ 45nm Layout Created! DEF → flow_45nm_128bit/results/lfsr_nfsr_top_45nm.def${NC}\n"
else
    echo -e "${YELLOW}⚠ Docker not available. Skipping PnR step.${NC}\n"
fi

# ── Step 4: OpenSTA Static Timing Analysis ───────────────────────────────────
echo -e "${YELLOW}[4/4] Running OpenSTA Static Timing Analysis (128-bit)...${NC}"
if command -v sta &> /dev/null; then
    sta -exit flow_45nm_128bit/sta_128bit.tcl \
        | tee flow_45nm_128bit/results/sta_report_128bit.txt
    echo -e "${GREEN}✓ STA Report → flow_45nm_128bit/results/sta_report_128bit.txt${NC}\n"
else
    echo -e "${YELLOW}⚠ OpenSTA not installed. Skipping STA step.${NC}\n"
fi

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}  Grain-128 128-bit Flow Finished! Check results/ folder.      ${NC}"
echo -e "${GREEN}================================================================${NC}"
