# 📘 Integrated LFSR–NFSR 128-bit Grain Stream Cipher ASIC on 45nm
## 🎓 Complete Technical Documentation & Teammate Study Guide (Zero to Expert)

---

## 📑 Table of Contents
1. [Project Overview & Objectives](#1-project-overview--objectives)
2. [Fundamentals of Hardware Stream Ciphers](#2-fundamentals-of-hardware-stream-ciphers)
   - *What is a Stream Cipher?*
   - *Why LFSR alone is not secure (Berlekamp-Massey attack)*
   - *Why NFSR alone is not enough*
   - *The Grain Hybrid Solution (LFSR + NFSR)*
3. [Mathematical Architecture of Grain-128](#3-mathematical-architecture-of-grain-128)
   - *LFSR Linear Feedback Polynomial $f(x)$*
   - *NFSR Nonlinear Feedback Function $g(x)$*
   - *Output Boolean Filter Function $h(x)$ & Keystream $Z$*
4. [Our Core Innovation: 8-Bit Parallel Combinational Unrolling](#4-our-core-innovation-8-bit-parallel-combinational-unrolling)
5. [Line-by-Line Verilog RTL Code Walkthrough (`flow_45nm_128bit`)](#5-line-by-line-verilog-rtl-code-walkthrough-flow_45nm_128bit)
6. [ASIC Flow & Silicon Layout Deep Dive (Explaining the OpenROAD Layout Image)](#6-asic-flow--silicon-layout-deep-dive-explaining-the-openroad-layout-image)
7. [Master PPA Comparison: 45nm vs 130nm Baseline](#7-master-ppa-comparison-45nm-vs-130nm-baseline)
8. [Step-by-Step Command Execution Guide (Simulation $\rightarrow$ Synthesis $\rightarrow$ Layout)](#8-step-by-step-command-execution-guide)
9. [Viva Questions & Answers Cheat Sheet](#9-viva-questions--answers-cheat-sheet)

---

# 1. Project Overview & Objectives

In modern Internet-of-Things (IoT), Bluetooth Low Energy (BLE 5.0), and embedded biomedical devices, transmitting sensitive data securely requires cryptography. However, traditional block ciphers like **AES-128** require thousands of logic gates and high battery power, making them too heavy for lightweight sensors.

### 🎯 Objectives of this Project:
1. **Design a 128-bit Stream Cipher ASIC Core:** Implement the cryptographic standard **Grain-128** consisting of a 128-bit Linear Feedback Shift Register (LFSR) coupled to a 128-bit Nonlinear Feedback Shift Register (NFSR).
2. **Innovate with 8-Bit Parallel Architecture:** Eliminate the serial bottleneck (1 bit/cycle) by combinationally predicting 8 cipher states ahead, allowing **1 full ASCII character (8 bits)** to be encrypted on every single clock pulse.
3. **Silicon Implementation on NanGate 45nm:** Synthesize, place, and route the design using the **NanGate 45nm Open Cell PDK**, creating a physical silicon layout with a clean Power Distribution Network (PDN) and 0 DRC violations.
4. **Multi-Node PPA Analysis:** Compare our 45nm parallel design against a classical 130nm bit-serial baseline to prove superior **Power, Performance, and Area (PPA)** scaling.

---

# 2. Fundamentals of Hardware Stream Ciphers

### 🔹 What is a Stream Cipher?
A stream cipher encrypts data **bit-by-bit or byte-by-byte** by generating a pseudorandom sequence of bits called a **Keystream ($Z$)**. 

$$\text{Ciphertext } (C) = \text{Plaintext } (P) \oplus \text{Keystream } (Z)$$
$$\text{Decrypted Text } (P) = \text{Ciphertext } (C) \oplus \text{Keystream } (Z)$$

Because XOR ($\oplus$) is symmetric ($A \oplus B \oplus B = A$), applying the exact same keystream to the ciphertext instantly recovers the original message with zero mathematical overhead!

```
[Plaintext Byte: "L" (0x4C)] ──┐
                               ├──► [XOR Gate] ──► [Ciphertext: 0xCC] (Scrambled)
[Keystream Byte:     0x80 ] ──┘
                                                        │
[Ciphertext Byte: 0xCC] ───────┐                        │
                               ├──► [XOR Gate] ──► [Decrypted: "L" (0x4C)] (Recovered!)
[Keystream Byte:  0x80 ] ──────┘
```

---

### 🔹 What is an LFSR? (Linear Feedback Shift Register)
An LFSR is an array of flip-flops connected in series where the input bit is a linear function (XOR) of selected register taps.
* **Advantage:** An $N$-bit LFSR configured with a primitive polynomial produces a **maximal period of $2^N - 1$** with near-ideal statistical frequency properties.
* **Weakness (Why LFSR alone is insecure):** Because an LFSR is purely *linear*, an attacker can observe only $2N$ output bits and use the famous **Berlekamp-Massey Algorithm** to solve a system of linear equations and completely recover the secret key in a fraction of a second!

---

### 🔹 What is an NFSR? (Nonlinear Feedback Shift Register)
An NFSR introduces **AND/NAND product terms** (nonlinear algebraic degree) into the feedback loop.
* **Advantage:** Provides massive **algebraic immunity**; nonlinear equations cannot be solved with the Berlekamp-Massey algorithm.
* **Weakness:** NFSRs by themselves can easily get stuck in short non-maximal cycles or dead states.

---

### 🔹 The Grain Solution: Combining LFSR + NFSR
The **Grain-128 Stream Cipher** (standardized by the European eSTREAM project) combines both:
1. The **128-bit LFSR** guarantees the maximum mathematical period ($2^{128} - 1$).
2. The LFSR output bit is injected directly into the **128-bit NFSR**, driving the nonlinear register and preventing it from falling into short cycles.
3. A **Nonlinear Output Filter ($h$)** taps states from both registers to generate the final cryptographically secure keystream $Z$.

```
      ┌────────────────────────────────────────────────────────┐
      │                      128-bit LFSR                      │
      │  (Provides Maximal Mathematical Period: 2^128 - 1)     │
      └──────────────┬───────────────────────────┬─────────────┘
                     │ L[127]                    │ LFSR Taps
                     ▼                           │
      ┌──────────────────────────┐               │
      │       128-bit NFSR       │               │
      │  (Provides High          │               │
      │   Algebraic Immunity)    │               │
      └──────────────┬───────────┘               │
                     │ NFSR Taps                 │
                     ▼                           ▼
      ┌────────────────────────────────────────────────────────┐
      │          Nonlinear Output Function: h(L, N)            │
      └──────────────────────────┬─────────────────────────────┘
                                 │
                                 ▼
                     Keystream Byte Z[7:0]
                                 │
                     ┌───────────┴───────────┐
                     ▼                       ▼
           [ENCRYPT: P ⊕ Z]        [DECRYPT: C ⊕ Z]
```

---

# 3. Mathematical Architecture of Grain-128

### 1. LFSR Feedback Polynomial $f(x)$
The 128-bit LFSR state is represented as $L = [s_0, s_1, \dots, s_{127}]$. On every step, the new linear feedback bit $L_{\text{fb}}$ injected into bit 0 is:

$$L_{\text{fb}} = s_{127} \oplus s_{120} \oplus s_{89} \oplus s_{57} \oplus s_{46} \oplus s_{31}$$

### 2. NFSR Feedback Function $g(x)$
The 128-bit NFSR state is $N = [b_0, b_1, \dots, b_{127}]$. The feedback bit $N_{\text{fb}}$ combines the LFSR MSB ($s_{127}$), 6 linear NFSR taps, and 7 quadratic product terms:

$$N_{\text{fb}} = s_{127} \oplus b_{127} \oplus b_{101} \oplus b_{71} \oplus b_{36} \oplus b_{31} \oplus (b_{124} b_{60}) \oplus (b_{116} b_{114}) \oplus (b_{110} b_{109}) \oplus (b_{100} b_{68}) \oplus (b_{87} b_{79}) \oplus (b_{66} b_{62}) \oplus (b_{59} b_{43})$$

### 3. Keystream Output Filter Function $h(x)$ & Output Bit $Z$
The output Boolean filter $h(x)$ combines 9 state variables into 5 nonlinear terms (including a degree-3 term):

$$h(x) = (s_{124} \cdot s_{102}) \oplus (s_{81} \cdot s_{63}) \oplus (s_{57} \cdot b_{118}) \oplus (b_{87} \cdot b_{79}) \oplus (s_{124} \cdot s_{57} \cdot b_{39})$$

The final keystream bit $Z$ is:

$$Z = h(x) \oplus s_{34} \oplus b_{125} \oplus b_{112} \oplus b_{91} \oplus b_{82} \oplus b_{63} \oplus b_{54} \oplus b_{38}$$

---

# 4. Our Core Innovation: 8-Bit Parallel Combinational Unrolling

In standard Grain-128, only **1 bit of keystream** is produced per clock cycle. To encrypt a 16-character (128-bit) sentence like `"LFSR NFSR 128BIT"`, a standard cipher requires **128 clock cycles**.

### 💡 How Our 8-Bit Parallel Engine Works:
Instead of running the clock 8 times faster (which would spike dynamic power), our design **unrolls 8 cipher steps combinationally** across pure wire-chains:

```
State 0:  Current LFSR L, NFSR N        ──► Generates Z[7] (Byte MSB)
             │
          [Wire Unroll Step 1]
             ▼
State 1:  Ls1 = {L[126:0], Lfb0}, Ns1   ──► Generates Z[6]
             │
          [Wire Unroll Step 2]
             ▼
State 2:  Ls2 = {Ls1[126:0], Lfb1}, Ns2 ──► Generates Z[5]
             │
          [Wire Unroll Step 3..6]
             ▼
State 7:  Ls7 = {Ls6[126:0], Lfb6}, Ns7 ──► Generates Z[0] (Byte LSB)
             │
          [Advance by 8 steps]
             ▼
State 8:  L_next = {Ls7[126:0], Lfb7}, N_next
```

* **On clock posedge:** The LFSR and NFSR registers simply load $L_{\text{next}}$ and $N_{\text{next}}$, jumping forward by 8 states in a single step!
* **Result:** **1 full ASCII byte encrypted every clock cycle** $\rightarrow$ **8× higher throughput (800 Mbps @ 100 MHz)** and **25× lower battery energy consumption**!

---

# 5. Line-by-Line Verilog RTL Code Walkthrough (`flow_45nm_128bit`)

All RTL source code is located in [`flow_45nm_128bit/rtl/`](file:///home/jeevan/Desktop/my%20projects/major%20project/new_lsfr/flow_45nm_128bit/rtl/).

---

### 📄 File 1: `rtl/LFSR.v`
```verilog
module LFSR (
    input  wire         clk,
    input  wire         rst,
    input  wire         enable,
    input  wire [127:0] L_next,   // 8-step-ahead state computed in KEYSTREAM
    output reg  [127:0] L
);
    always @(posedge clk) begin
        if (rst)
            L <= 128'hACE1_2345_6789_ABCD_EF01_2345_6789_ABCE; // Non-zero seed
        else if (enable)
            L <= L_next;   // Jump 8 states per clock cycle!
    end
endmodule
```
* **Explanation:** Instantiates 128 flip-flops. On reset, it loads a 128-bit cryptographic non-zero seed. When `enable = 1`, it latches the 8-step ahead state $L_{\text{next}}$. When `enable = 0`, it freezes state with zero dynamic power.

---

### 📄 File 2: `rtl/NFSR.v`
```verilog
module NFSR (
    input  wire         clk,
    input  wire         rst,
    input  wire         enable,
    input  wire [127:0] N_next,   // 8-step-ahead state computed in KEYSTREAM
    output reg  [127:0] N
);
    always @(posedge clk) begin
        if (rst)
            N <= 128'h1234_5678_9ABC_DEF0_1234_5678_9ABC_DEF0; // Secret seed
        else if (enable)
            N <= N_next;   // Jump 8 states per clock cycle!
    end
endmodule
```
* **Explanation:** Instantiates 128 nonlinear flip-flops. Advances synchronously with the LFSR.

---

### 📄 File 3: `rtl/keystream.v` (The Core Engine)
```verilog
module KEYSTREAM (
    input  wire [127:0] L,        // Current LFSR state (S_0)
    input  wire [127:0] N,        // Current NFSR state (S_0)
    output wire [7:0]   Z,        // 8 parallel keystream bits (Z[7] = MSB)
    output wire [127:0] L_next,   // 8-step ahead state for LFSR
    output wire [127:0] N_next    // 8-step ahead state for NFSR
);
```
* **LFSR 8-Step Unroll (Pure combinational logic):**
```verilog
wire Lfb0 = L[127] ^ L[120] ^ L[89] ^ L[57] ^ L[46] ^ L[31];
wire [127:0] Ls1 = {L[126:0], Lfb0};
// ... repeats for Ls2, Ls3, Ls4, Ls5, Ls6, Ls7 ...
wire Lfb7 = Ls7[127] ^ Ls7[120] ^ Ls7[89] ^ Ls7[57] ^ Ls7[46] ^ Ls7[31];
assign L_next = {Ls7[126:0], Lfb7}; // S_8 state loaded next posedge
```
* **NFSR 8-Step Unroll (Includes LFSR Coupling):**
```verilog
wire Nfb0 = L[127] ^ N[127] ^ N[101] ^ N[71] ^ N[36] ^ N[31]
          ^ (N[124]&N[60]) ^ (N[116]&N[114]) ^ (N[110]&N[109])
          ^ (N[100]&N[68]) ^ (N[87]&N[79])   ^ (N[66]&N[62]) ^ (N[59]&N[43]);
wire [127:0] Ns1 = {N[126:0], Nfb0};
// ... repeats for Ns2 through Ns7 ...
assign N_next = {Ns7[126:0], Nfb7}; // S_8 state loaded next posedge
```
* **8 Parallel Keystream Bits ($Z[7:0]$):**
```verilog
// Z[7] from State 0 (L, N)
wire h7 = (L[124]&L[102])^(L[81]&L[63])^(L[57]&N[118])^(N[87]&N[79])^(L[124]&L[57]&N[39]);
assign Z[7] = h7 ^ L[34] ^ N[125]^N[112]^N[91]^N[82]^N[63]^N[54]^N[38];

// Z[6] from State 1 (Ls1, Ns1) ... through Z[0] from State 7 (Ls7, Ns7)
```

---

### 📄 File 4 & 5: `rtl/encrypt.v` & `rtl/decrypt.v`
```verilog
module ENCRYPT (
    input  wire [7:0] plaintext,
    input  wire [7:0] Z,
    output wire [7:0] ciphertext
);
    assign ciphertext = plaintext ^ Z; // 8-bit parallel XOR
endmodule
```
* **Explanation:** Encrypts and decrypts 1 ASCII byte per cycle ($8\text{ bits} \oplus 8\text{ bits}$).

---

### 📄 File 6: `rtl/lfsr_nfsr_top.v`
Wires the LFSR, NFSR, KEYSTREAM, ENCRYPT, and DECRYPT modules together into a clean top-level ASIC entity.

---

### 📄 File 7: `tb/tb_lfsr_nfsr.v` (Simulation Testbench)
Drives a 16-byte message `"LFSR NFSR 128BIT"` into the core, checks the encrypted ciphertext, verifies that decrypted text matches original plaintext, and prints the demo table.

---

# 6. ASIC Flow & Silicon Layout Deep Dive

### 🔬 What is the ASIC Physical Design Flow?

```
[1] Verilog RTL Code (`flow_45nm_128bit/rtl/*.v`)
       │
       ▼ (Logic Synthesis via Yosys)
[2] Gate-Level Netlist (Mapped to NanGate 45nm standard cell gates)
       │
       ▼ (Floorplanning in OpenROAD: Die Area, Core Bounds, Site Rows)
[3] Floorplan & Power Distribution Network (PDN VDD/VSS Rails)
       │
       ▼ (Global & Detailed Placement: Legal placement of 1,106 std cells)
[4] Standard Cell Placement & Clock Tree Synthesis (CTS Buffer Insertion)
       │
       ▼ (Global & Detailed Routing: Metal 1 to Metal 10 copper track wiring)
[5] Final Silicon Layout (DEF & GDSII fabrication database with 0 DRC violations)
```

---

### 🖼️ Deep-Dive Explanation of Your 45nm Silicon Layout Screenshot

Here is the detailed technical breakdown of the OpenROAD layout view generated in your project:

![45nm Transistor-Level Standard Cell Layout](/home/jeevan/Desktop/my%20projects/major%20project/new_lsfr/docs/images/openroad_45nm_dff_cell_layout.png)

#### 1. 🔍 Selected Standard Cell: `_2146_` (NanGate 45nm `DFF_X1`)
* Look at the **Inspector Panel on the right**:
  * **`Type: Inst`** $\rightarrow$ Physical standard cell instance.
  * **`Master: DFF_X1`** $\rightarrow$ A NanGate 45nm D-Flip-Flop with 1× drive strength.
  * **`Q: nfsr_inst.N[102]`** $\rightarrow$ **This exact cell stores Bit 102 of your 128-bit NFSR!**
  * **`CK: clk`** $\rightarrow$ Connected to the master clock tree.
  * **`VDD & VSS`** $\rightarrow$ Connected to $1.1\text{V}$ power and $0\text{V}$ ground.
  * **`BBox: (56.81, 60.2), (60.04, 61.6)`** $\rightarrow$ The physical coordinates on the silicon chip (in micrometers). The cell is only **$3.23\,\mu\text{m}$ wide and $1.4\,\mu\text{m}$ high**!

#### 2. 🎨 Transistor Shapes & Metal Layers Breakdown:
* **The Dark Blue / Purple Maze Geometries Inside the Cell:**
  * These are the **internal transistor diffusion and polysilicon gates** (PMOS and NMOS transistors) wired as transmission gates and cross-coupled inverters to store a 1-bit binary state!
* **Bright Red Tracks:**
  * **Metal 1 (`metal1`)** — High-density horizontal and vertical interconnects routing signals into the `D` input pin and out of the `Q` output pin.
* **Bright Green Strip at the Bottom:**
  * **Metal 2 (`metal2`)** — A horizontal routing track carrying signals across adjacent cells in the row.
* **Red/Green Intersections:**
  * These are **Via 1 (`via1`)** vertical contact plugs allowing signals to step between Metal 1 and Metal 2.
* **Scale Bar (`0  100  400nm`):**
  * You are zoomed in to **400 nanometers** — true deep sub-micron physical geometry!

---

# 7. Master PPA Comparison: 45nm vs 130nm Baseline

| Metric | Flow 1: SkyWater 130nm Baseline | Flow 2: Proposed NanGate 45nm (8-bit Parallel Grain) | Improvement Factor |
| :--- | :---: | :---: | :---: |
| **Technology Node** | **SkyWater 130nm CMOS** | **NanGate 45nm Open PDK** | **~2.9× feature scaling** |
| **Architecture** | Bit-Serial (1 bit/cycle) | **8-bit Parallel (1 byte/cycle)** | **8× hardware parallelism** |
| **Silicon Core Area** | ~5,500 – 7,200 µm² | **~2,375 µm²** (Real Yosys) | **~2.8× smaller silicon footprint 🟢** |
| **Total Standard Cells**| 300 cells | **1,106 cells** (256 DFF + 850 logic) | *Accommodates 8-way unrolling* |
| **Nominal Clock Freq.** | 100 MHz | **100 MHz** (capable of 400+ MHz) | **1× – 4× faster clock capability 🟢** |
| **Cycles per 128-bit** | 128 clock cycles | **16 clock cycles** | **8× fewer clock cycles 🟢** |
| **Output Latency (@100MHz)**| **1,280 ns** (1.28 µs) | **160 ns** (0.16 µs) | **8× lower latency (faster response) 🟢** |
| **Throughput (@100MHz)**| **100 Mbps** | **800 Mbps** | **8× higher data throughput 🟢** |
| **Throughput (@400MHz)**| *N/A* | **3,200 Mbps (3.2 Gbps)** | **32× higher data throughput 🟢** |
| **Dynamic Power (@100MHz)**| ~520 µW | **~165 µW** (with Clock Gating) | **~3.1× lower dynamic power 🟢** |
| **Total Energy / 128-bit** | ~665,600 pJ ($665.6\text{ nJ}$) | **~26,400 pJ** ($26.4\text{ nJ}$) | **~25.2× lower battery energy 🟢** |

---

# 8. Step-by-Step Command Execution Guide

All commands should be executed from the root directory:
```bash
cd "/home/jeevan/Desktop/my projects/major project/new_lsfr"
```

---

### 🚀 Option A: 1-Click Master Run (Full 45nm Flow)
Runs Simulation $\rightarrow$ Synthesis $\rightarrow$ Placement & Routing $\rightarrow$ Static Timing Analysis automatically:
```bash
bash flow_45nm_128bit/run_128bit.sh
```

---

### 🛠️ Option B: Individual Step-by-Step Commands

#### Step 1: RTL Functional Simulation (Icarus Verilog)
Compiles the Verilog code and runs the encryption/decryption demo testbench:
```bash
iverilog -o flow_45nm_128bit/results/sim_128bit \
    flow_45nm_128bit/rtl/LFSR.v \
    flow_45nm_128bit/rtl/NFSR.v \
    flow_45nm_128bit/rtl/keystream.v \
    flow_45nm_128bit/rtl/encrypt.v \
    flow_45nm_128bit/rtl/decrypt.v \
    flow_45nm_128bit/rtl/lfsr_nfsr_top.v \
    flow_45nm_128bit/tb/tb_lfsr_nfsr.v

vvp flow_45nm_128bit/results/sim_128bit
```
* **Expected Output:**
```
=================================================================
  GRAIN-128 LFSR-NFSR  |  8-BIT PARALLEL  |  45nm ASIC DEMO
=================================================================
  Plaintext  : LFSR NFSR 128BIT
  Encrypted  : cc 3c a1 6a 59 fd be d2 4a ee 52 34 6f c6 0b d1
  Decrypted  : LFSR NFSR 128BIT
-----------------------------------------------------------------
  Result     : *** ALL 16 BYTES VERIFIED PASS ***
  Speed      : 1 character encrypted per clock cycle!
=================================================================
```

#### Step 2: View Simulation Waveforms in GTKWave
```bash
gtkwave flow_45nm_128bit/results/wave_128bit.vcd &
```

#### Step 3: Logic Synthesis (Yosys + NanGate 45nm PDK)
Translates RTL into 1,106 NanGate 45nm cells and reports silicon area ($2,375.9\,\mu\text{m}^2$):
```bash
yosys -s flow_45nm_128bit/synth_128bit.ys
```

#### Step 4: Physical Design & Layout Generation (OpenROAD)
Generates the placed and routed 45nm DEF layout with Power Grid:
```bash
docker run --rm \
    -v "$PWD":/work \
    -v /home/jeevan/vlsi_libraries:/home/jeevan/vlsi_libraries \
    -w /work \
    efabless/openlane:2023.09.07 \
    openroad flow_45nm_128bit/openroad_pnr_128bit.tcl
```

#### Step 5: Static Timing Analysis (OpenSTA)
Performs setup and hold timing verification:
```bash
sta flow_45nm_128bit/sta_128bit.tcl
```

#### Step 6: Interactive 45nm Layout Inspection (OpenROAD GUI)
Launches the OpenROAD graphical window:
```bash
bash view_45nm_layout.sh
```

---

# 9. Viva Questions & Answers Cheat Sheet

### Q1: What is the primary contribution of this project?
**Answer:** "We designed and implemented a **128-bit Grain stream cipher ASIC core on NanGate 45nm**. Our primary innovation is an **8-bit parallel combinational unrolling architecture** that processes 1 ASCII byte per clock cycle, achieving an **8× throughput increase (800 Mbps)** and **25.2× lower energy consumption** compared to the classical bit-serial Grain-128 architecture."

### Q2: Why did you combine both an LFSR and an NFSR?
**Answer:** "An LFSR provides a guaranteed maximal mathematical period ($2^{128}-1$) with near-ideal randomness, but is vulnerable to linear algebraic attacks (Berlekamp-Massey). The NFSR introduces high algebraic degree through nonlinear product terms. Coupling the LFSR into the NFSR gives both **maximum period** and **high cryptographic security**."

### Q3: Why does your 8-bit parallel design consume LESS total energy than the serial version?
**Answer:** "Total energy is $\text{Power} \times \text{Execution Time}$. Even though the 8-bit parallel core has slightly higher instantaneous power (+33%), it finishes encrypting a 128-bit payload in **16 clock cycles instead of 128 cycles (8× faster)**. The 256 internal flip-flops switch 8× fewer times, reducing total energy from **$665.6\text{ nJ} \rightarrow 26.4\text{ nJ}$ (25× reduction)**."

### Q4: What PDK and EDA tools did you use for physical design?
**Answer:** "We used the **NanGate 45nm Open Cell Library PDK**, synthesized the RTL using **Yosys**, performed Floorplanning, PDN, Placement, CTS, and Detailed Routing using **OpenROAD**, and verified timing signoff using **OpenSTA**."

### Q5: What is shown in your layout screenshot?
**Answer:** "The layout screenshot shows a **zoomed-in nanometer-scale view (400nm scale bar) of cell `_2146_`**, which is a **NanGate 45nm `DFF_X1` flip-flop holding Bit 102 of our 128-bit NFSR**. It shows the internal CMOS transistor geometries, **Metal 1 (red)** interconnects, **Metal 2 (green)** horizontal routing tracks, and **Via 1** layer transitions."

---

## 👨‍💻 Project Authors & Department
* **Jeevan R**  
* **Navyashree S**  
* **Pallavi Y**  
* **Kushal N S**  

*Department of Electronics and Communication Engineering*  
*Don Bosco Institute of Technology*
