# 🔐 Grain-PRG 45 — 128-bit Stream Cipher ASIC on NanGate 45nm

> **Integrated LFSR–NFSR with 8-Bit Parallel Combinational Unrolling**  
> Department of ECE · Don Bosco Institute of Technology  
> Authors: Jeevan R · Navyashree S · Pallavi Y · Kushal N S

---

## 📖 Documentation

| Document | Description |
|:---|:---|
| **[COMPLETE_PROJECT_GUIDE_AND_THEORY.md](COMPLETE_PROJECT_GUIDE_AND_THEORY.md)** | Full deep-dive: theory, math, code walkthrough, layout analysis, viva Q&A |
| **[README.md](README.md)** | This file — project overview, results, visualizer app, and quick-start commands |
| **[visualizer/](visualizer/)** | Interactive Web Application — 8-Bit Step-by-Step Encryption & Decryption Guide |

---

## 🌐 Interactive Web Application & Manual Calculation Guide

We have created an interactive web application in [`visualizer/`](visualizer/) designed specifically for project presentations, demonstrations, and viva preparation.

### 🌟 Features of the Web App:
1. **8-Bit Single-Character Manual Mode**: Process 1 character at a time (e.g. `'H'`) to follow every calculation step by step.
2. **Text to 8-Bit Binary Converter**: Shows ASCII value (`72`), Hex (`0x48`), and Binary (`01001000`) mapped to `P[7]` down to `P[0]`.
3. **Register Tap Extraction**: Displays exact bit values for `s124, s102, s81, s63, s57, s34` and `b125, b118, b112, b91, b87, b79, b63, b54, b39, b38`.
4. **Interactive 8-Bit Keystream Inspector (Z[7] to Z[0])**:
   - Inspect $h(x)$ filter function & 5 evaluated AND-terms for any of the 8 unrolled bits.
   - Computes $Z[k] = h(x) \oplus \text{linear taps}$.
5. **Interactive 8-Bit Bitwise XOR Tables**:
   - **Encryption Table**: $C[k] = P[k] \oplus Z[k]$ for Bits 7 down to 0.
   - **Decryption Table**: $P[k] = C[k] \oplus Z[k]$ verifying recovery of original character.
6. **Pop-up Tap Reference Table**: Displays the official ECRYPT Grain-128 fixed tap specification for LFSR, NFSR, $h(x)$, and linear output taps.

### 🚀 Running the Web Application:
To run and view the visualizer web app in your browser:

```bash
# 1. Start local web server (runs on port 8000)
python3 -m http.server 8000 --directory "/home/jeevan/Desktop/my projects/Grain-PRG-45/visualizer"

# 2. Open in your default browser
xdg-open http://localhost:8000
```
Or simply open **[http://localhost:8000](http://localhost:8000)** in Chrome/Firefox.

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
Grain-PRG-45/
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
│   ├── openroad_45nm_full_chip.png          Full routed chip layout (45nm NanGate)
│   ├── openroad_45nm_gui_overview.png       OpenROAD GUI environment & Inspector overview
│   ├── openroad_45nm_cell_rows.png          Zoomed standard cell rows & power grid
│   ├── openroad_45nm_pins_timing.png        Top I/O signal pins & OpenSTA timing tab
│   └── openroad_45nm_zoomed_gate_detail.png Zoomed gate layout (MUX2_X1 cell & metal routing)
│
├── visualizer/                              ← Interactive Step-by-Step Web Application
│   ├── index.html                           7-Step Page-by-Page HTML Walkthrough
│   ├── style.css                            Dark-mode glassmorphic CSS design system
│   └── app.js                               Grain-128 8-bit manual calculation JS engine
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

### 1. NanGate 45nm — Full Chip View (Routed Layout)
![45nm Full Chip Routed Layout](./docs/images/openroad_45nm_full_chip.png)

### 2. OpenROAD GUI Environment Overview
![OpenROAD GUI Overview](./docs/images/openroad_45nm_gui_overview.png)

### 3. Detailed Gate & Routing Metal Layers (`MUX2_X1` Instance)
![Zoomed Gate Layout and Routing](./docs/images/openroad_45nm_zoomed_gate_detail.png)

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

### IMPORTANT: Terminal Working Directory
Make sure your terminal is in the project root folder **`Grain-PRG-45`**:

```bash
cd "/home/jeevan/Desktop/my projects/Grain-PRG-45"
```

---

### Option 1 — 1-Click Full ASIC Flow (Simulation + Synthesis + P&R + STA)
Run from project root `Grain-PRG-45`:
```bash
cd "/home/jeevan/Desktop/my projects/Grain-PRG-45"
bash flow_45nm_128bit/run_128bit.sh
```

---

### Option 2 — Generate All PPA Reports (Area + Timing + Power)
Run from project root `Grain-PRG-45`:
```bash
cd "/home/jeevan/Desktop/my projects/Grain-PRG-45"
bash flow_45nm_128bit/gen_ppa_reports.sh
```
Outputs report files to `flow_45nm_128bit/reports/synthesis/` and `flow_45nm_128bit/reports/signoff/`.

---

### Option 3 — View Silicon Layout in OpenROAD GUI
`view_45nm_layout.sh` is located in the root `Grain-PRG-45` folder:
```bash
cd "/home/jeevan/Desktop/my projects/Grain-PRG-45"
bash view_45nm_layout.sh
```

---

### Option 4 — If You Are Already Inside `flow_45nm_128bit/`
If your terminal current directory is `Grain-PRG-45/flow_45nm_128bit`:
```bash
# If you are inside flow_45nm_128bit, run scripts directly without the prefix:
bash run_128bit.sh
bash gen_ppa_reports.sh

# To view the layout from inside flow_45nm_128bit:
bash ../view_45nm_layout.sh
```

---

### Option 5 — Step-by-Step Command Execution (From `Grain-PRG-45` Root)

```bash
cd "/home/jeevan/Desktop/my projects/Grain-PRG-45"

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

# Step 2: View Signal Waveforms (GTKWave)
gtkwave flow_45nm_128bit/results/wave_128bit.vcd &

# Step 3: Logic Synthesis (Yosys → NanGate 45nm)
yosys -s flow_45nm_128bit/synth_128bit.ys

# Step 4: Place & Route (OpenROAD via Docker)
docker run --rm \
    -v "$PWD":/work \
    -v vlsi_libraries:vlsi_libraries \
    -w /work \
    efabless/openlane:2023.09.07 \
    openroad flow_45nm_128bit/openroad_pnr_128bit.tcl

# Step 5: Static Timing Analysis (OpenSTA)
sta flow_45nm_128bit/sta_128bit.tcl

# Step 6: Generate All PPA Reports
bash flow_45nm_128bit/gen_ppa_reports.sh

# Step 7: View Layout in OpenROAD GUI
bash view_45nm_layout.sh
```

---

> 💡 For detailed theory, math, RTL code walkthrough, layout image explanation, and viva Q&A — see **[COMPLETE_PROJECT_GUIDE_AND_THEORY.md](COMPLETE_PROJECT_GUIDE_AND_THEORY.md)**

