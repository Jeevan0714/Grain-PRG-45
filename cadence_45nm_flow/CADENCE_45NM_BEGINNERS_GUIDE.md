# Beginner's Step-by-Step Guide to 45nm ASIC Design in Cadence (Red Hat Linux)

This guide provides complete, step-by-step instructions for running **RTL Synthesis** and **Physical Design (Place & Route)** for a 45nm ASIC project using **Cadence EDA Tools** on **Red Hat Enterprise Linux (RHEL)**.

---

## 📚 Overview of Cadence Tools Used

In digital ASIC design, you will use two main Cadence software tools:

1. **Cadence Genus (Synthesis Solution)**: Converts your human-readable Verilog code (`.v`) into a gate-level netlist of 45nm standard logic gates (AND, OR, Flip-Flops).
2. **Cadence Innovus (Implementation System)**: Takes the gate-level netlist and places standard cells onto a silicon die area, routes copper wires between them, builds the clock network, and generates the final chip layout file (**GDSII**).

---

## 📁 Required Files Checklist

Before starting, ensure all these files exist in your project folder (`new_lsfr`):

| File Type | Description | Location in Project |
| :--- | :--- | :--- |
| **RTL Code** | Verilog hardware files | `rtl/*.v` (`lfsr_nfsr_top.v`, `LFSR.v`, etc.) |
| **Constraints** | SDC file defining clock frequency & pin delays | `constraints.sdc` |
| **45nm Liberty (.lib)** | Timing & power specs for 45nm standard cells | `~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib` |
| **45nm LEF (.lef)** | Physical dimensions and metal layer definitions | `~/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef` |

---

## 🚀 Phase 0: Environment Setup (Red Hat Linux Lab)

### Step 1: Open Red Hat Linux Terminal
Press `Ctrl + Alt + T` or right-click on your desktop and select **Open Terminal**.

### Step 2: Navigate to your project directory
```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
```

### Step 3: Load Cadence Tool Environment & License
In college lab environments, Cadence license paths and environment variables must be loaded into your Linux shell. Run your lab's tool setup script (ask your lab instructor for the exact setup command if different):

```bash
# Common college setup script examples:
source /tools/cadence/env.sh
# OR
source /cadence/setup.csh
```

To verify Cadence tools are accessible, type:
```bash
which genus
which innovus
```

---

## ⚙️ Phase 1: RTL Logic Synthesis using Cadence Genus

Synthesis transforms your Verilog code into 45nm logic gates. You can run Genus interactively line-by-line or automatically via script.

### Method A: Interactive Command-by-Command (Recommended for Beginners)

#### Step 1: Launch Genus in GUI mode
```bash
genus -gui
```

#### Step 2: Set the 45nm Standard Cell Library
```tcl
set_db target_library ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib
set_db link_library   ~/vlsi_libraries/nangate45/NangateOpenCellLibrary_typical.lib
```

#### Step 3: Read your Verilog RTL files
```tcl
read_hdl [glob rtl/*.v]
```

#### Step 4: Elaborate the Top-Level Module
```tcl
elaborate lfsr_nfsr_top
```

#### Step 5: Read Clock & Timing Constraints
```tcl
read_sdc constraints.sdc
```

#### Step 6: Run Synthesis Stages
```tcl
syn_generic
syn_map
syn_opt
```

#### Step 7: View Synthesis Reports (Area, Power, Timing)
```tcl
report_area   > cadence_45nm_flow/reports_genus_area.txt
report_gates  > cadence_45nm_flow/reports_genus_gates.txt
report_timing > cadence_45nm_flow/reports_genus_timing.txt
report_power  > cadence_45nm_flow/reports_genus_power.txt
```

#### Step 8: Export Gate-Level Netlist and SDC File
```tcl
write_hdl > cadence_45nm_flow/netlist_genus_45nm.v
write_sdc > cadence_45nm_flow/constraints_genus_45nm.sdc
```

#### Step 9: Exit Genus
```tcl
exit
```

---

### Method B: Automated Genus Script Mode
Run the pre-written TCL script inside `cadence_45nm_flow`:
```bash
genus -files cadence_45nm_flow/genus_synth.tcl
```

---

## 🎨 Phase 2: Physical Design (P&R) using Cadence Innovus

Physical design places standard cells onto the chip floorplan, routes copper metal tracks, builds clock distribution trees, and generates the final layout.

### Step 1: Launch Cadence Innovus
```bash
innovus
```

### Step 2: Import Design and LEF Files
```tcl
set init_gnd_net VSS
set init_vdd_net VDD
set init_top_cell lfsr_nfsr_top
set init_verilog cadence_45nm_flow/netlist_genus_45nm.v
set init_lef_file {~/vlsi_libraries/nangate45/NangateOpenCellLibrary.tech.lef ~/vlsi_libraries/nangate45/NangateOpenCellLibrary.lef}
init_design
```

### Step 3: Floorplanning
```tcl
floorPlan -r 1.0 0.6 10 10 10 10
```

### Step 4: Power Planning (VDD / VSS Power Grid)
```tcl
addRing -type core_rings -nets {VDD VSS} -width 1.0 -spacing 0.5 -layer {top M7 bottom M7 left M6 right M6}
sroute -connect { corePin }
```

### Step 5: Standard Cell Placement
```tcl
place_design
```

### Step 6: Clock Tree Synthesis (CTS)
```tcl
ccopt_design
```

### Step 7: Routing (NanoRoute)
```tcl
routeDesign
```

### Step 8: Physical Verification & DRC / LVS Signoff
```tcl
verify_drc
verifyConnectivity
```

### Step 9: Export GDSII Layout Stream File
```tcl
defOut -floorplan -routing cadence_45nm_flow/lfsr_nfsr_top_45nm.def
streamOut cadence_45nm_flow/lfsr_nfsr_top_45nm.gds -merge {~/vlsi_libraries/nangate45/NangateOpenCellLibrary.gds}
exit
```

---

## ⚡ Master 1-Click Execution Script for Cadence Lab

Run the entire synthesis and physical design flow in one command:

```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash cadence_45nm_flow/run_cadence_45nm.sh
```
