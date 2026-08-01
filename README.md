# 🔐 Integrated LFSR–NFSR PRNG ASIC Design & Multi-Node ASIC Flow

This repository contains the complete design, RTL implementation, functional verification, and ASIC physical design flows for an **Integrated LFSR–NFSR Pseudorandom Number Generator (PRNG)** targeting lightweight cryptographic and IoT security applications.

The project is structured into **3 self-contained ASIC implementation flows**:

---

## 🏗️ Repository Architecture

```
new_lsfr/
├── README.md                           ◄── Master Repository Guide
│
├── flow_130nm_skywater/                ◄── [FLOW 1] SkyWater 130nm Commercial Open-Source PDK Flow
│   ├── rtl/                            ├── Verilog Source Code
│   ├── tb/                             ├── Simulation Testbench
│   ├── constraints.sdc                 ├── Sky130 SDC Constraints
│   ├── synth_sky130nm.ys               ├── Yosys Synthesis Script
│   ├── sta_sky130nm.tcl                ├── OpenSTA Timing Analysis Script
│   ├── run_flow_130nm.sh               ├── 1-Click Laptop Shell Execution Script
│   ├── SKY130NM_BEGINNERS_GUIDE.md     ├── Step-by-Step Guide
│   └── results/                        └── Silicon Artifacts (DEF, GDSII, Netlists)
│
├── flow_45nm_cadence/                  ◄── [FLOW 2] Nangate 45nm Cadence Commercial Flow (Red Hat Linux)
│   ├── rtl/                            ├── Verilog RTL (with Low-Power Clock Gating)
│   ├── tb/                             ├── Simulation Testbench
│   ├── constraints.sdc                 ├── Clean SDC Constraints
│   ├── genus_synth.tcl                 ├── Cadence Genus Multi-Vt & CG Synthesis Script
│   ├── innovus_pnr.tcl                 ├── Cadence Innovus Place & Route Script
│   ├── run_cadence_45nm.sh             ├── 1-Click Master Shell Script
│   ├── CADENCE_45NM_BEGINNERS_GUIDE.md ├── Step-by-Step Cadence Lab Guide
│   └── results/                        └── Cadence Output Reports & Layout Files
│
└── flow_45nm_open_source/              ◄── [FLOW 3] Nangate 45nm Laptop Open-Source Flow
    ├── rtl/                            ├── Verilog Source Code
    ├── tb/                             ├── Simulation Testbench
    ├── constraints.sdc                 ├── SDC Constraints
    ├── synth_45nm.ys                   ├── Yosys Synthesis Script
    ├── openroad_pnr_45nm.tcl           ├── OpenROAD Placement & Routing Script
    ├── sta_45nm.tcl                    ├── OpenSTA Timing Analysis Script
    ├── run_opensource_45nm.sh          ├── 1-Click Laptop Execution Script
    ├── OPENSOURCE_45NM_BEGINNERS_GUIDE.md ├── Step-by-Step Laptop Guide
    └── results/                        └── Netlists, DEF Layouts & Reports
```

---

## 🚀 Quick Execution Guide

### 1️⃣ Run SkyWater 130nm Flow (Laptop / OpenLane)
```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_130nm_skywater/run_flow_130nm.sh
```
*📘 Full Guide: [SKY130NM_BEGINNERS_GUIDE.md](file:///home/jeevan/Desktop/my%20projects/major%20project/new_lsfr/flow_130nm_skywater/SKY130NM_BEGINNERS_GUIDE.md)*

### 2️⃣ Run Cadence 45nm Flow (Red Hat Linux Lab)
```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_45nm_cadence/run_cadence_45nm.sh
```
*📘 Full Guide: [CADENCE_45NM_BEGINNERS_GUIDE.md](file:///home/jeevan/Desktop/my%20projects/major%20project/new_lsfr/flow_45nm_cadence/CADENCE_45NM_BEGINNERS_GUIDE.md)*

### 3️⃣ Run Open-Source 45nm Flow (Laptop Yosys/OpenROAD/STA)
```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_45nm_open_source/run_opensource_45nm.sh
```
*📘 Full Guide: [OPENSOURCE_45NM_BEGINNERS_GUIDE.md](file:///home/jeevan/Desktop/my%20projects/major%20project/new_lsfr/flow_45nm_open_source/OPENSOURCE_45NM_BEGINNERS_GUIDE.md)*

---

## 🧠 Low-Power ASIC Features Implemented
* **Multi-Vth Optimization**: Swaps non-critical gates to High-Vth (HVT) cells to reduce static leakage power by 60%–80%.
* **Automatic Clock Gating**: Freezes internal clock tree when idle to reduce dynamic switching power by 40%–70%.

---

## 👨‍💻 Authors
- Jeevan R  
- Navyashree S  
- Pallavi Y  
- Kushal N S  

Electronics and Communication Engineering — Don Bosco Institute of Technology
