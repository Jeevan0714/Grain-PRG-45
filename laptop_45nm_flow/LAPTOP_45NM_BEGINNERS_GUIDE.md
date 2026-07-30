# Personal Laptop Guide: 45nm ASIC Flow using Open-Source EDA Tools

This guide gives complete, step-by-step instructions to run the entire **45nm ASIC Design & Verification Flow** on your **personal laptop** (Ubuntu / Linux / WSL) without needing Cadence commercial licenses.

---

## 🛠️ Open-Source Tools Used on Personal Laptops

| Cadence Tool (College Lab) | Laptop Open-Source Equivalent | What It Does on your Laptop |
| :--- | :--- | :--- |
| **Cadence NC-Sim / Xcelium** | **Icarus Verilog (`iverilog`)** | Verilog RTL Simulation & Waveform Generation |
| **Cadence SimVision** | **GTKWave** | Graphical Waveform Viewer (`wave.vcd`) |
| **Cadence Genus** | **Yosys Open Synthesis Engine** | RTL Synthesis mapped to 45nm Nangate Cells |
| **Cadence Tempus** | **OpenSTA** | Static Timing Analysis (Setup/Hold Slack) |
| **Cadence Innovus** | **OpenROAD Engine** | Floorplanning, Power Grid, Placement, CTS, NanoRoute |
| **Cadence Virtuoso** | **KLayout** | 45nm GDSII Layout Viewer |

---

## 📋 Prerequisites & One-Time Laptop Setup

To install all required open-source tools on your Ubuntu / Linux laptop, open a terminal and run:

```bash
sudo apt update
sudo apt install -y iverilog gtkwave yosys opensta klayout
```
*(If using OpenROAD, install via package manager or Docker container).*

---

## 📁 Laptop 45nm Flow Directory Structure

All scripts for your laptop are stored inside the `laptop_45nm_flow` folder:

```text
new_lsfr/
└── laptop_45nm_flow/
    ├── LAPTOP_45NM_BEGINNERS_GUIDE.md   <-- (This Guide)
    ├── run_laptop_45nm.sh              <-- Master 1-Click Execution Script
    ├── synth_45nm.ys                   <-- Yosys 45nm Synthesis Script
    ├── sta_45nm.tcl                    <-- OpenSTA 45nm Timing Script
    └── openroad_pnr_45nm.tcl           <-- OpenROAD 45nm Place & Route Script
```

---

## 🚀 Step-by-Step Instructions

### Step 1: RTL Simulation & Waveform Inspection
Simulate your design using Icarus Verilog to confirm the LFSR-NFSR PRNG logic, encryption, and decryption are working correctly.

```bash
# 1. Navigate to your project folder
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"

# 2. Compile RTL files and testbench
iverilog -o sim_laptop.out tb/tb_lfsr_nfsr.v rtl/*.v

# 3. Run simulation to produce wave.vcd
vvp sim_laptop.out

# 4. View simulation waveforms in GTKWave
gtkwave wave.vcd &
```

---

### Step 2: 45nm Logic Synthesis (Yosys)
Synthesize your behavioral RTL code into a gate-level netlist mapped to 45nm standard cells.

```bash
yosys -s laptop_45nm_flow/synth_45nm.ys
```
- **Output Generated**: `laptop_45nm_flow/synth_netlist_45nm.v`
- **What to check**: Scroll to the bottom of the terminal output to see the cell count report (number of Flip-Flops, NAND gates, etc.).

---

### Step 3: Static Timing Analysis (OpenSTA)
Check setup time, hold time, and maximum clock frequency for your 45nm synthesized netlist.

```bash
opensta laptop_45nm_flow/sta_45nm.tcl
```
- **What to check**: Look at the `slack` value at the bottom of the timing report:
  - **Slack $\ge 0$ ns**: ✅ Design meets timing!
  - **Slack $< 0$ ns**: ❌ Timing violation (Clock speed too fast).

---

### Step 4: Physical Design - Floorplan, Place & Route (OpenROAD)
Perform automated placement, power routing, Clock Tree Synthesis (CTS), and detail routing on your laptop.

```bash
openroad laptop_45nm_flow/openroad_pnr_45nm.tcl
```
- **Outputs Generated**:
  - `laptop_45nm_flow/lfsr_nfsr_45nm.def` (Design Exchange Format)
  - `laptop_45nm_flow/lfsr_nfsr_45nm.gds` (Final Chip Layout)

---

### Step 5: View 45nm Layout in KLayout
Open and inspect your 45nm silicon chip layout:

```bash
klayout laptop_45nm_flow/lfsr_nfsr_45nm.gds &
```

---

## ⚡ Master 1-Click Execution Script

You can run the ENTIRE simulation, synthesis, timing analysis, and physical design flow in a single command using the master script:

```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash laptop_45nm_flow/run_laptop_45nm.sh
```
