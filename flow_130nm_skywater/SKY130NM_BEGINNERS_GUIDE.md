# 📜 Step-by-Step Guide: SkyWater 130nm ASIC Flow (OpenLane / Yosys / OpenROAD)

This guide provides step-by-step instructions for synthesizing, analyzing timing, and inspecting silicon layouts for the **LFSR-NFSR PRNG** targeting the **SkyWater 130nm (Sky130) Open-Source Commercial PDK**.

---

## 📁 Directory Structure Overview

```
flow_130nm_skywater/
├── rtl/                        ├── Verilog HDL source files
├── tb/                         ├── Testbench files
├── constraints.sdc             ├── Timing & Clock constraints
├── synth_sky130nm.ys           ├── Yosys Synthesis Script
├── sta_sky130nm.tcl            ├── OpenSTA Timing Analysis Script
├── run_flow_130nm.sh           ├── 1-Click Master Execution Script
└── results/                    └── Output DEF, GDSII, and Netlists
    ├── lfsr_nfsr_top.def       ├── Physical Placement & Routing DEF Layout
    ├── lfsr_nfsr_top.gds       ├── Final GDSII Silicon Stream File
    └── synth_netlist_sky130.v  ├── Gate-Level Synthesized Netlist
```

---

## ⚡ 1-Click Master Execution (Laptop Command)

To run simulation, synthesis, and timing reports in one command:

```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_130nm_skywater/run_flow_130nm.sh
```

---

## 🛠️ Step-by-Step Individual Commands

### Step 1: RTL Functional Simulation
```bash
iverilog -o flow_130nm_skywater/results/sim_130nm flow_130nm_skywater/rtl/*.v flow_130nm_skywater/tb/tb_lfsr_nfsr.v
vvp flow_130nm_skywater/results/sim_130nm
gtkwave wave.vcd
```

### Step 2: RTL Logic Synthesis using Yosys
```bash
yosys -s flow_130nm_skywater/synth_sky130nm.ys
```

### Step 3: OpenSTA Static Timing Analysis
```bash
sta flow_130nm_skywater/sta_sky130nm.tcl
```

### Step 4: OpenLane Tapeout Flow (eFabless / Tiny Tapeout)
If running inside the Docker-based OpenLane environment for real tapeout:
```bash
make mount
./flow.tcl -design lfsr_nfsr_top -tag sky130_run
```

---

## 📊 Key Highlights of SkyWater 130nm Flow
* **Foundry-Fabricable**: Fully open-source commercial PDK backed by Google & eFabless.
* **Ultra-Low Static Leakage**: Excellent for battery-operated IoT security sensors in idle mode.
* **Silicon Layout**: Preserved in `results/lfsr_nfsr_top.gds` and `results/lfsr_nfsr_top.def`.
