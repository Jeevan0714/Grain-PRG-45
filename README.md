# 🔐 Design and ASIC Implementation of Integrated LFSR–NFSR Based Pseudorandom Generator Using 45nm Technology

## 📌 Overview
This project presents the design and ASIC implementation of an integrated LFSR–NFSR based Pseudorandom Number Generator (PRNG) for lightweight cryptographic applications.  
The design is implemented in Verilog HDL and synthesized using OpenLane targeting 45nm technology.

## 🎯 Objectives
- Design a high-speed PRNG using LFSR and NFSR combination
- Implement encryption and decryption modules
- Perform ASIC synthesis using OpenLane
- Analyze area, power, and timing metrics

---

## 🏗️ Architecture

The system consists of:
- Linear Feedback Shift Register (LFSR)
- Non-Linear Feedback Shift Register (NFSR)
- Non-linear combining function
- Encryption module (XOR-based stream cipher)
- Decryption module

---

## 🧠 Working Principle

1. LFSR generates linear pseudorandom sequence
2. NFSR introduces non-linearity for enhanced security
3. Both outputs are combined to produce keystream
4. Plaintext ⊕ Keystream = Ciphertext
5. Ciphertext ⊕ Keystream = Plaintext

---

## 📂 Folder Structure

- `rtl/` → Verilog source files  
- `tb/` → Testbench files  
- `simulation/` → Waveform outputs  
- `synthesis/` → OpenLane configuration  
- `docs/` → Block diagrams and project report  
- `results/` → Area, timing, and power reports  

---

## 🛠 Tools Used

- Icarus Verilog
- GTKWave
- OpenLane
- Skywater 45nm Technology

---

## ▶️ How to Run Simulation

```bash
iverilog -o sim lfsr_nfsr_core.v encrypt.v decrypt.v tb_16bit.v
vvp sim
gtkwave waveform.vcd
```

---

## 📊 ASIC Results (Example)

| Parameter | Value |
|-----------|--------|
| Area      | XX µm² |
| Power     | XX mW |
| Frequency | XX MHz |

---

## 🔒 Applications
- Lightweight cryptography
- IoT security
- Stream cipher implementations
- Embedded secure systems

---

## 📚 Future Improvements
- Implementation in 18nm technology
- Integration with AES for hybrid security
- FPGA validation using Vivado

---

## 👨‍💻 Author
Jeevan R  
Electronics and Communication Engineering  
Don Bosco Institute of Technology

---

## 📜 License
This project is licensed under the MIT License.
