# 📜 Step-by-Step Guide: Open-Source 45nm Laptop ASIC Flow (Yosys + OpenROAD + OpenSTA)

This guide provides step-by-step instructions for running lightweight, open-source ASIC synthesis, place & route, and timing analysis for the **LFSR-NFSR PRNG** targeting **Nangate 45nm Technology** directly on your personal laptop.

---

## 📁 Directory Structure Overview

```
flow_45nm_open_source/
├── rtl/                            ├── Verilog RTL source files
├── tb/                             ├── Simulation Testbench
├── constraints.sdc                 ├── SDC Timing Constraints
├── synth_45nm.ys                   ├── Yosys Logic Synthesis Script
├── openroad_pnr_45nm.tcl           ├── OpenROAD Placement & Routing Script
├── sta_45nm.tcl                    ├── OpenSTA Static Timing Analysis Script
├── run_opensource_45nm.sh          ├── 1-Click Laptop Master Shell Script
└── results/                        └── Synthesized Netlists & Output DEF Layouts
    ├── synth_netlist_45nm.v        ├── Synthesized Gate-Level Netlist
    ├── lfsr_nfsr_top_45nm.def      ├── Physical Design DEF Layout File
    └── sta_report_45nm.txt         ├── Setup & Hold Timing Report
```

---

## ⚡ 1-Click Laptop Execution Command

Run simulation, synthesis, PnR, and timing analysis in one command:

```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_45nm_open_source/run_opensource_45nm.sh
```

---

## 🛠️ Step-by-Step Individual Commands

### Step 1: RTL Functional Simulation
```bash
iverilog -o flow_45nm_open_source/results/sim_45nm_os flow_45nm_open_source/rtl/*.v flow_45nm_open_source/tb/tb_lfsr_nfsr.v
vvp flow_45nm_open_source/results/sim_45nm_os
gtkwave wave.vcd
```

### Step 2: RTL Logic Synthesis using Yosys
```bash
yosys -s flow_45nm_open_source/synth_45nm.ys
```

### Step 3: Physical Design (PnR) using OpenROAD
```bash
openroad -exit flow_45nm_open_source/openroad_pnr_45nm.tcl
```

### Step 4: Static Timing Analysis using OpenSTA
```bash
sta flow_45nm_open_source/sta_45nm.tcl
```
