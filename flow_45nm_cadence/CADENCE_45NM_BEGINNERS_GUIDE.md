# 📜 Step-by-Step Guide: 45nm Commercial ASIC Flow in Cadence (Red Hat Linux)

This guide provides complete step-by-step instructions for running **RTL Logic Synthesis (Genus)** and **Physical Design / Place & Route (Innovus)** targeting **Nangate 45nm Technology** using **Cadence EDA Tools** on **Red Hat Enterprise Linux (RHEL)**.

---

## 📁 Directory Structure Overview

```
flow_45nm_cadence/
├── rtl/                            ├── Verilog RTL files (with Low-Power Clock Gating)
├── tb/                             ├── Simulation Testbench
├── constraints.sdc                 ├── Timing & Clock constraints
├── genus_synth.tcl                 ├── Cadence Genus Multi-Vt & CG Synthesis Script
├── innovus_pnr.tcl                 ├── Cadence Innovus Place & Route Script
├── run_cadence_45nm.sh             ├── 1-Click Master Shell Script
└── results/                        └── Cadence Outputs & Performance Reports
    ├── netlist_genus_45nm.v        ├── Synthesized 45nm Netlist
    ├── reports_genus_area.txt      ├── Cell Area Report
    ├── reports_genus_power.txt     ├── Dynamic & Static Leakage Power Report
    ├── reports_genus_timing.txt    ├── Setup & Hold Slack Report
    ├── lfsr_nfsr_top_45nm.def      ├── Physical Layout DEF File
    └── lfsr_nfsr_top_45nm.gds      ├── Final Silicon GDSII Stream File
```

---

## ⚡ 1-Click Execution Command (Red Hat Linux Lab)

```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_45nm_cadence/run_cadence_45nm.sh
```

---

## 🛠️ Step-by-Step Interactive Cadence Commands

### Phase 1: RTL Logic Synthesis in Cadence Genus

1. **Launch Genus GUI**:
   ```bash
   genus -gui
   ```
2. **Execute Synthesis Script**:
   ```tcl
   include flow_45nm_cadence/genus_synth.tcl
   ```

### Phase 2: Physical Design (P&R) in Cadence Innovus

1. **Launch Innovus**:
   ```bash
   innovus
   ```
2. **Execute P&R Script**:
   ```tcl
   include flow_45nm_cadence/innovus_pnr.tcl
   ```

---

## ⚡ Key Low-Power Features Enabled
* **Multi-Vth Optimization**: Swaps non-critical gates to High-Vth (HVT) cells to reduce static leakage power by 60%–80%.
* **Automatic Clock Gating**: Inserts Integrated Clock Gating (ICG) cells to reduce dynamic switching power by 40%–70%.
