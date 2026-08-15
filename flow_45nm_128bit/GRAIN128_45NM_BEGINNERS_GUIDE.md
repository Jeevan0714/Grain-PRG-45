# 📘 Grain-128 45nm ASIC Flow (8-bit Parallel Architecture) — Beginner's Guide

This guide explains how to simulate, synthesize, place & route, and analyze the **128-bit Grain Stream Cipher with 8-bit Parallel Data Processing** on the **NanGate 45nm Open Cell Library**.

---

## 🚀 1-Click Master Execution

To run the complete flow from Verilog RTL to GDS/DEF silicon layout:

```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
bash flow_45nm_128bit/run_128bit.sh
```

---

## 🛠️ Step-by-Step Tool Execution

### Step 1: RTL Functional Simulation & Verification (Icarus Verilog)
Verifies encryption and decryption of ASCII text `"LFSR NFSR 128BIT"` at 1 byte per clock cycle:
```bash
iverilog -o flow_45nm_128bit/results/sim_128bit \
    flow_45nm_128bit/rtl/*.v flow_45nm_128bit/tb/tb_lfsr_nfsr.v
vvp flow_45nm_128bit/results/sim_128bit
```

### Step 2: Logic Synthesis (Yosys + NanGate 45nm PDK)
Converts high-level Verilog RTL into real NanGate 45nm standard cells (`DFF_X1`, `XOR2_X1`, `NAND2_X1`):
```bash
yosys -s flow_45nm_128bit/synth_128bit.ys
```
* Output netlist: `flow_45nm_128bit/results/synth_netlist_128bit.v`

### Step 3: Physical Design (OpenROAD Floorplanning, PDN, Placement & Routing)
Creates the full 45nm silicon layout with Power Distribution Network (PDN) and detailed routing:
```bash
docker run --rm \
    -v "$PWD":/work \
    -v /home/jeevan/vlsi_libraries:/home/jeevan/vlsi_libraries \
    -w /work efabless/openlane:2023.09.07 \
    openroad flow_45nm_128bit/openroad_pnr_128bit.tcl
```
* Output layout: `flow_45nm_128bit/results/lfsr_nfsr_top_45nm.def`

---

## 🖥️ Viewing the 45nm Silicon Layout

### View in OpenROAD GUI:
```bash
bash view_45nm_layout.sh
```

### View in KLayout (High-Definition):
```bash
bash view_45nm_klayout.sh
```
