# 🔐 128-bit Grain-128 Stream Cipher ASIC — NanGate 45nm

> **Integrated LFSR–NFSR with 8-Bit Parallel Combinational Unrolling**  
> Department of ECE · Don Bosco Institute of Technology  
> Authors: Jeevan R · Navyashree S · Pallavi Y · Kushal N S

---

## 📖 Documentation

| Document | Description |
|:---|:---|
| **[COMPLETE_PROJECT_GUIDE_AND_THEORY.md](COMPLETE_PROJECT_GUIDE_AND_THEORY.md)** | Full deep-dive: theory, math, code walkthrough, layout analysis, viva Q&A |
| **[README.md](README.md)** | This file — project overview, results, and quick-start commands |

---

## 🧠 About This Project

### What Is It?

This project implements a **hardware encryption engine** at the silicon level — the goal isn't just software code, but an actual chip design that can be fabricated into real silicon and deployed on IoT devices, smart cards, or embedded security modules.

The encryption algorithm is **Grain-128**, a lightweight stream cipher standardized by the **European eSTREAM project** for hardware security. It uses two 128-bit registers — an **LFSR** (Linear Feedback Shift Register) and an **NFSR** (Nonlinear Feedback Shift Register) — coupled together to generate a cryptographically secure pseudorandom keystream. Every byte of plaintext is XOR'd with a byte of this keystream to encrypt it, and XOR'd again to decrypt it.

### Why Does It Matter?

Modern cryptography like AES consumes significant area and power, making it too heavy for billions of IoT devices (temperature sensors, BLE medical patches, RFID tags) that run on coin-cell batteries. **Grain-128 achieves 128-bit security with a fraction of AES's resource cost**, making it ideal for constrained hardware.

### What's Our Innovation?

A standard Grain-128 generates **1 bit per clock cycle** — 128 cycles to encrypt a single 16-character message. We redesigned the core with **8-bit parallel combinational unrolling**: the circuit predicts the next 8 cipher states as pure wire logic (no extra clocks, no extra registers), producing a full byte every clock edge.

| Benefit | Standard Grain-128 | Our Design |
|:---|:---:|:---:|
| Throughput @ 100 MHz | 100 Mbps | **800 Mbps** |
| Cycles per 128-bit block | 128 | **16** |
| Energy per encryption | ~665 nJ | **~26 nJ** |
| Silicon area (45nm) | — | **2,376 µm²** |

### What Did We Actually Build?

| Stage | Outcome | Tool |
|:---|:---|:---|
| RTL Design | 6 Verilog modules (LFSR, NFSR, Keystream, Encrypt, Decrypt, Top) | — |
| Functional Simulation | `"LFSR NFSR 128BIT"` — all 16 bytes encrypted & verified | Icarus Verilog |
| Logic Synthesis | 1,106 NanGate 45nm standard cells · 2,376 µm² silicon area | Yosys |
| Physical Design | Floorplan + PDN + Routing · **0 DRC violations** · 6,808 vias | OpenROAD |
| Timing Analysis | Setup slack **+8.55 ns** at 100 MHz · capable of 400+ MHz | OpenSTA |

---

## 🏗️ Repository Structure

```
new_lsfr/
├── README.md                               ← Project overview (this file)
├── COMPLETE_PROJECT_GUIDE_AND_THEORY.md    ← Full deep-dive: theory, math, code, viva Q&A
├── LICENSE
├── .gitignore
│
├── flow_45nm_128bit/                        ← [PRIMARY] 45nm 8-bit Parallel ASIC Flow
│   ├── rtl/
│   │   ├── LFSR.v                           128-bit LFSR (8-step state jump)
│   │   ├── NFSR.v                           128-bit NFSR (8-step state jump)
│   │   ├── keystream.v                      Core: 8-step combinational unroll
│   │   ├── encrypt.v                        8-bit parallel XOR encryptor
│   │   ├── decrypt.v                        8-bit parallel XOR decryptor
│   │   └── lfsr_nfsr_top.v                  Top-level integration module
│   ├── tb/
│   │   └── tb_lfsr_nfsr.v                   Testbench: 16-byte ASCII encryption demo
│   ├── synth_128bit.ys                      Yosys synthesis → NanGate 45nm cells
│   ├── openroad_pnr_128bit.tcl              OpenROAD: Floorplan + PDN + P&R
│   ├── sta_128bit.tcl                       OpenSTA: timing analysis
│   ├── constraints.sdc                      100 MHz clock constraint
│   ├── run_128bit.sh                        1-click: full flow end-to-end
│   ├── gen_ppa_reports.sh                   Generate all PPA reports
│   ├── generate_reports.tcl                 OpenSTA report helper (used by above)
│   ├── results/
│   │   ├── wave_128bit.vcd                  GTKWave signal dump
│   │   ├── synth_netlist_128bit.v           NanGate 45nm gate-level netlist
│   │   ├── lfsr_nfsr_top_45nm.def           Final routed silicon layout
│   │   └── sta_report_128bit.txt            Raw STA timing report
│   └── reports/                             ← OpenLane-style PPA reports
│       ├── synthesis/area_utilization.rpt   Cell count + chip area
│       └── signoff/
│           ├── timing_setup.rpt             Setup slack + critical path
│           ├── timing_hold.rpt              Hold slack + min path
│           ├── timing_summary.rpt           WNS/TNS combined
│           └── power.rpt                    Internal/Switching/Leakage
│
├── flow_130nm_skywater/                     ← [BASELINE] SkyWater 130nm (for PPA comparison)
│   ├── rtl/                                 Bit-serial Grain-128 RTL
│   ├── tb/                                  Testbench
│   ├── synth_sky130nm.ys                    Yosys → SkyWater 130nm cells
│   ├── sta_sky130nm.tcl                     OpenSTA timing
│   ├── run_flow_130nm.sh                    1-click flow
│   ├── constraints.sdc
│   └── results/                             DEF, GDS, netlist, waveforms, STA
│
├── docs/images/                             ← OpenROAD layout screenshots
│   ├── openroad_45nm_full_chip.png          Full routed chip (45nm)
│   ├── openroad_45nm_dff_cell_layout.png    Zoomed DFF_X1 cell (NFSR bit 102)
│   └── openroad_130nm_full_chip.png         Baseline 130nm chip
│
├── view_45nm_layout.sh                      Open 45nm layout in OpenROAD GUI
└── view_130nm_layout.sh                     Open 130nm layout in OpenROAD GUI
```

---

## 📊 Key Results

### Synthesis (Yosys → NanGate 45nm)

| Metric | Value |
|:---|:---|
| Total Standard Cells | **1,106** |
| D Flip-Flops (`DFF_X1`) | 256 (128 LFSR + 128 NFSR state bits) |
| Logic Gates (`AND2`, `XOR2`, `NAND2`, `MUX2`, `XNOR2`, `OR2`) | 850 |
| Silicon Core Area | **2,375.91 µm²** |
| Report | [`reports/synthesis/area_utilization.rpt`](flow_45nm_128bit/reports/synthesis/area_utilization.rpt) |

### Physical Design (OpenROAD)

| Metric | Value |
|:---|:---|
| DRC Violations | **0** ✅ |
| Routing Vias | 6,808 |
| PDN Layers | Metal4 (VDD) + Metal5 (VSS) |
| Output | `results/lfsr_nfsr_top_45nm.def` |

### Static Timing Analysis (OpenSTA @ 100 MHz)

| Metric | Value |
|:---|:---|
| Clock Period | 10.00 ns (100 MHz) |
| Worst Data Path | 0.75 ns |
| Setup Slack | **+8.55 ns MET** ✅ |
| Hold Slack | -0.06 ns (pre-CTS; resolves after clock tree) |
| Max Achievable Frequency | **~400–500 MHz** |
| Report | [`reports/signoff/timing_summary.rpt`](flow_45nm_128bit/reports/signoff/timing_summary.rpt) |

### Power Estimation (OpenSTA)

| Group | Power | % |
|:---|:---:|:---:|
| Sequential (DFFs) | 196 µW | 60.4% |
| Combinational logic | 128 µW | 39.6% |
| **Total** | **324 µW** | 100% |
| *(breakdown)* | Internal: 242 µW · Switching: 36 µW · Leakage: 45 µW | — |
| Report | [`reports/signoff/power.rpt`](flow_45nm_128bit/reports/signoff/power.rpt) |

### Simulation (Icarus Verilog)

```
Plaintext  : LFSR NFSR 128BIT
Encrypted  : cc 3c a1 6a 59 fd be d2 4a ee 52 34 6f c6 0b d1
Decrypted  : LFSR NFSR 128BIT
Result     : *** ALL 16 BYTES VERIFIED PASS ***
```

---

## 📐 Silicon Layout (OpenROAD GUI)

### NanGate 45nm — Full Chip View (Routed Layout)
![45nm Full Chip Routed Layout](docs/images/openroad_45nm_full_chip.png)

### NanGate 45nm — Zoomed In (DFF_X1 Cell — NFSR Bit 102)
![45nm DFF Standard Cell Zoomed](docs/images/openroad_45nm_dff_cell_layout.png)

### SkyWater 130nm — Full Chip View (Baseline Reference)
![130nm Full Chip Layout](docs/images/openroad_130nm_full_chip.png)

---

## ⚡ PPA Comparison: 45nm vs 130nm

| Metric | SkyWater 130nm (Serial) | NanGate 45nm — Ours (Parallel) | Improvement |
|:---|:---:|:---:|:---:|
| Architecture | 1 bit/cycle | **8 bits/cycle** | 8× parallelism |
| Silicon Area | ~6,000 µm² | **2,376 µm²** | **~2.5× smaller** 🟢 |
| Cycles / 128-bit | 128 cycles | **16 cycles** | **8× fewer** 🟢 |
| Throughput @ 100 MHz | 100 Mbps | **800 Mbps** | **8× higher** 🟢 |
| Throughput @ 400 MHz | N/A | **3,200 Mbps** | **32× higher** 🟢 |
| Total Power | ~520 µW (est.) | **324 µW** (real OpenSTA) | **~1.6× lower** 🟢 |
| Energy / 128-bit | ~665 nJ | **~26 nJ** | **~25× lower** 🟢 |

---

## 🚀 Quick Execution Guide

All commands run from the project root:
```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
```

### Option 1 — 1-Click Full Flow (Simulation + Synthesis + P&R + STA)
```bash
bash flow_45nm_128bit/run_128bit.sh
```

### Option 2 — Generate All PPA Reports (Area + Timing + Power)
```bash
bash flow_45nm_128bit/gen_ppa_reports.sh
```
Outputs to `flow_45nm_128bit/reports/synthesis/` and `flow_45nm_128bit/reports/signoff/`

### Option 3 — Step by Step

```bash
# Step 1: RTL Simulation (Icarus Verilog)
iverilog -o flow_45nm_128bit/results/sim_128bit \
    flow_45nm_128bit/rtl/LFSR.v \
    flow_45nm_128bit/rtl/NFSR.v \
    flow_45nm_128bit/rtl/keystream.v \
    flow_45nm_128bit/rtl/encrypt.v \
    flow_45nm_128bit/rtl/decrypt.v \
    flow_45nm_128bit/rtl/lfsr_nfsr_top.v \
    flow_45nm_128bit/tb/tb_lfsr_nfsr.v
vvp flow_45nm_128bit/results/sim_128bit

# Step 2: View Waveforms
gtkwave flow_45nm_128bit/results/wave_128bit.vcd &

# Step 3: Logic Synthesis (Yosys → NanGate 45nm)
yosys -s flow_45nm_128bit/synth_128bit.ys

# Step 4: Place & Route (OpenROAD via Docker)
docker run --rm \
    -v "$PWD":/work \
    -v /home/jeevan/vlsi_libraries:/home/jeevan/vlsi_libraries \
    -w /work \
    efabless/openlane:2023.09.07 \
    openroad flow_45nm_128bit/openroad_pnr_128bit.tcl

# Step 5: Static Timing Analysis
sta flow_45nm_128bit/sta_128bit.tcl

# Step 6: Generate All PPA Reports
bash flow_45nm_128bit/gen_ppa_reports.sh

# Step 7: View Layout in OpenROAD GUI
bash view_45nm_layout.sh
```

---

> 💡 For detailed theory, math, RTL code walkthrough, layout image explanation, and viva Q&A — see **[COMPLETE_PROJECT_GUIDE_AND_THEORY.md](COMPLETE_PROJECT_GUIDE_AND_THEORY.md)**
