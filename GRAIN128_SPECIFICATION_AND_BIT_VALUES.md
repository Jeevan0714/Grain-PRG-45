# Grain-128 Master Architecture, Tap Specifications & Bit Values

> **Document Version**: 3.0 (Unified Master Reference)  
> **Target Design**: `lfsr_nfsr_top` (128-Bit Integrated LFSR–NFSR Pseudorandom Generator)  
> **Technology Node**: NanGate 45nm Open Cell Library (Typical Corner, 1.1V, 25°C)  
> **Primary Innovation**: 8-Bit Parallel Combinational Unrolling (8x Throughput Acceleration)

---

## 📑 Table of Contents
1. [Register Architecture Overview](#1-register-architecture-overview)
2. [Key & IV State Initialization](#2-key--iv-state-initialization)
3. [Master 128-Bit Tap & Initial Value Table (Bits 127 down to 0)](#3-master-128-bit-tap--initial-value-table-bits-127-down-to-0)
4. [Non-Linear Filter Function h(x) & Keystream Equations](#4-non-linear-filter-function-hx--keystream-equations)
5. [Feedback Functions Lfb and Nfb](#5-feedback-functions-lfb-and-nfb)
6. [8-Bit Parallel Combinational Unrolling Matrix](#6-8-bit-parallel-combinational-unrolling-matrix)

---

## 1. Register Architecture Overview

Grain-128 consists of two 128-bit shift registers:

1. **`s` Vector (LFSR `L[127:0]`)**: 
   * **Length**: 128 bits (`s0` to `s127`).
   * **Role**: Linear Feedback Shift Register providing maximum sequence period ($2^{128}-1$).
   * **Shift Direction**: Left shift toward index 127. New feedback (`Lfb`) enters at LSB (`s0`), while oldest state sits at MSB (`s127`).

2. **`b` Vector (NFSR `N[127:0]`)**:
   * **Length**: 128 bits (`b0` to `b127`).
   * **Role**: Non-Linear Feedback Shift Register providing high cryptographic non-linearity ($2^{128}$ complexity).
   * **Shift Direction**: Left shift toward index 127. New feedback (`Nfb`) enters at LSB (`b0`), while oldest state sits at MSB (`b127`).

---

## 2. Key & IV State Initialization

When the cipher initializes:
* **Secret Key (128 bits)**: Loaded directly into the NFSR vector `b[127:0]`.
* **Initialization Vector (IV, 96 bits)**: Loaded into the upper bits of LFSR `s[127:32]`.
* **LFSR Padding (32 bits)**: The lower bits `s[31:1]` are filled with `1`s, and `s[0]` is filled with `0` (except bit 82 in NFSR which is set to `1` per spec).

```text
==============================================================================================
STATE S0 INITIALIZATION CONFIGURATION
==============================================================================================
 NFSR Vector (b[127:0]) ──► Secret Key (128 bits) ──► e.g. 128'h123456789ABCDEF0123456789ABCDEF0
 LFSR Vector (s[127:0]) ──► IV (96 bits) + Padding  ──► e.g. 128'hACE123456789ABCDFFFFFFFFFFFFFFFE
==============================================================================================
```

---

## 3. Master 128-Bit Tap & Initial Value Table (Bits 127 down to 0)

Below is the complete, bit-by-bit specification showing the **tap role** and **initial bit value in State S0** for every single bit position from 127 down to 0:

| Bit Index | LFSR Tap Function (`s`) | LFSR Bit ($s_i$) | NFSR Tap Function (`b`) | NFSR Bit ($b_i$) |
| :---: | :--- | :---: | :--- | :---: |
| **127** | **LFSR & NFSR Feedback** (`Lfb`, `Nfb`) | `0` | **NFSR Feedback** (`Nfb`) | `0` |
| **126** | State Storage | `0` | State Storage | `0` |
| **125** | State Storage | `0` | **Linear Keystream Tap** ($Z$) | `0` |
| **124** | **Filter $h(x)$ Term 1 & 5** (`x0`) | `0` | NFSR Non-linear Product (`b124 · b60`) | `1` |
| **123..121** | State Storage | `0` | State Storage | `0` |
| **120** | **LFSR Feedback** (`Lfb`) | `0` | State Storage | `0` |
| **119** | State Storage | `0` | State Storage | `0` |
| **118** | State Storage | `0` | **Filter $h(x)$ Term 3** (`x5`) | `0` |
| **117** | State Storage | `0` | State Storage | `0` |
| **116** | State Storage | `0` | NFSR Non-linear Product (`b116 · b114`) | `1` |
| **115** | State Storage | `0` | State Storage | `0` |
| **114** | State Storage | `0` | NFSR Non-linear Product (`b116 · b114`) | `1` |
| **113** | State Storage | `0` | State Storage | `0` |
| **112** | State Storage | `0` | **Linear Keystream Tap** ($Z$) | `0` |
| **111** | State Storage | `0` | State Storage | `0` |
| **110** | State Storage | `0` | NFSR Non-linear Product (`b110 · b109`) | `1` |
| **109** | State Storage | `0` | NFSR Non-linear Product (`b110 · b109`) | `1` |
| **108..103** | State Storage | `0` | State Storage | `0` |
| **102** | **Filter $h(x)$ Term 1** (`x1`) | `1` | State Storage | `0` |
| **101** | State Storage | `0` | **NFSR Feedback** (`Nfb`) | `1` |
| **100** | State Storage | `0` | NFSR Non-linear Product (`b100 · b68`) | `1` |
| **99..92** | State Storage | `0` | State Storage | `0` |
| **91** | State Storage | `1` | **Linear Keystream Tap** ($Z$) | `1` |
| **90** | State Storage | `1` | State Storage | `0` |
| **89** | **LFSR Feedback** (`Lfb`) | `1` | State Storage | `1` |
nooo redesign thesee , i want a very less content page , not thesee bigg. keep content less but must be efective . let the projects have veryyy small detailss. redesign to make it look simole and profeesional , nt all thngs are equiredd, keep only which tools and thngs give weightage .| **88** | State Storage | `1` | State Storage | `1` |
| **87** | State Storage | `0` | **Filter $h(x)$ Term 4**, Product (`b87 · b79`) | `1` |
| **86..83** | State Storage | `0` | State Storage | `1` |
| **82** | State Storage | `0` | **Linear Keystream Tap** ($Z$), Spec Constant | **`1`** |
| **81** | **Filter $h(x)$ Term 2** (`x2`) | `0` | State Storage | `0` |
| **80** | State Storage | `0` | State Storage | `1` |
| **79** | State Storage | `0` | **Filter $h(x)$ Term 4**, Product (`b87 · b79`) | `1` |
| **78..72** | State Storage | `0` | State Storage | `1` |
| **71** | State Storage | `0` | **NFSR Feedback** (`Nfb`) | `1` |
| **70..64** | State Storage | `0` | State Storage | `1` |
| **63** | **Filter $h(x)$ Term 2** (`x3`) | `1` | **Linear Keystream Tap** ($Z$) | `0` |
| **62** | State Storage | `0` | NFSR Non-linear Product (`b66 · b62`) | `1` |
| **61** | State Storage | `0` | State Storage | `1` |
| **60** | State Storage | `0` | NFSR Non-linear Product (`b124 · b60`) | `1` |
| **59** | State Storage | `0` | NFSR Non-linear Product (`b59 · b43`) | `1` |
| **58** | State Storage | `0` | State Storage | `1` |
| **57** | **LFSR Feedback** (`Lfb`), **Filter $h(x)$ Term 3 & 5** | `1` | State Storage | `0` |
| **56..55** | State Storage | `1` | State Storage | `0` |
| **54** | State Storage | `1` | **Linear Keystream Tap** ($Z$) | `0` |
| **53..47** | State Storage | `1` | State Storage | `0` |
| **46** | **LFSR Feedback** (`Lfb`) | `0` | State Storage | `0` |
| **45..44** | State Storage | `1` | State Storage | `0` |
| **43** | State Storage | `1` | NFSR Non-linear Product (`b59 · b43`) | `0` |
| **42..40** | State Storage | `1` | State Storage | `0` |
| **39** | State Storage | `1` | **Filter $h(x)$ Term 5** (`y4`) | `0` |
| **38** | State Storage | `1` | **Linear Keystream Tap** ($Z$) | `1` |
| **37** | State Storage | `1` | State Storage | `1` |
| **36** | State Storage | `1` | **NFSR Feedback** (`Nfb`) | `1` |
| **35** | State Storage | `1` | State Storage | `1` |
| **34** | **Linear Keystream Tap** ($Z$) | `1` | State Storage | `1` |
| **33..32** | State Storage | `1` | State Storage | `1` |
| **31** | **LFSR Feedback** (`Lfb`) | `1` | **NFSR Feedback** (`Nfb`) | `1` |
| **30..1** | State Storage | `1` | State Storage | `0` |
| **0** | State Storage | `0` | State Storage | `0` |

---

## 4. Non-Linear Filter Function h(x) & Keystream Equations

The non-linear filter function $h(x)$ evaluates 5 AND-product terms sampled from specific taps in the LFSR (`s`) and NFSR (`b`):

$$\begin{aligned}
h(x) = &(s_{124} \cdot s_{102}) \oplus (s_{81} \cdot s_{63}) \oplus (s_{57} \cdot b_{118}) \\
&\oplus (b_{87} \cdot b_{79}) \oplus (s_{124} \cdot s_{57} \cdot b_{39})
\end{aligned}$$

The final keystream bit $Z$ is calculated by XORing $h(x)$ with 1 LFSR linear tap and 8 NFSR linear taps:

$$Z = h(x) \oplus s_{34} \oplus b_{125} \oplus b_{112} \oplus b_{91} \oplus b_{82} \oplus b_{63} \oplus b_{54} \oplus b_{38}$$

---

## 5. Feedback Functions Lfb and Nfb

1. **LFSR Feedback `Lfb`**:
   $$\text{Lfb} = s_{127} \oplus s_{120} \oplus s_{89} \oplus s_{57} \oplus s_{46} \oplus s_{31}$$

2. **NFSR Feedback `Nfb`**:
   $$\begin{aligned}
   \text{Nfb} = &s_{127} \oplus b_{127} \oplus b_{101} \oplus b_{71} \oplus b_{36} \oplus b_{31} \\
   &\oplus (b_{124} \cdot b_{60}) \oplus (b_{116} \cdot b_{114}) \oplus (b_{110} \cdot b_{109}) \\
   &\oplus (b_{100} \cdot b_{68}) \oplus (b_{87} \cdot b_{79}) \oplus (b_{66} \cdot b_{62}) \oplus (b_{59} \cdot b_{43})
   \end{aligned}$$

---

## 6. 8-Bit Parallel Combinational Unrolling Matrix

In our custom 45nm ASIC chip (`lfsr_nfsr_top`), 8 consecutive states ($S_0 \dots S_7$) are computed in a single clock cycle to produce an entire 8-bit keystream byte ($Z[7:0]$):

```text
==============================================================================================
8-BIT PARALLEL UNROLLING MATRIX (keystream.v)
==============================================================================================
 State S0 ──► Evaluates Z[7] using s[127:0] and b[127:0]
 State S1 ──► Evaluates Z[6] using s_s1[127:0] (with Lfb0 at s0) and b_s1[127:0] (with Nfb0 at b0)
 State S2 ──► Evaluates Z[5] using s_s2[127:0] (with Lfb1 at s0) and b_s2[127:0] (with Nfb1 at b0)
 State S3 ──► Evaluates Z[4] using s_s3[127:0] (with Lfb2 at s0) and b_s3[127:0] (with Nfb2 at b0)
 State S4 ──► Evaluates Z[3] using s_s4[127:0] (with Lfb3 at s0) and b_s4[127:0] (with Nfb3 at b0)
 State S5 ──► Evaluates Z[2] using s_s5[127:0] (with Lfb4 at s0) and b_s5[127:0] (with Nfb4 at b0)
 State S6 ──► Evaluates Z[1] using s_s6[127:0] (with Lfb5 at s0) and b_s6[127:0] (with Nfb5 at b0)
 State S7 ──► Evaluates Z[0] using s_s7[127:0] (with Lfb6 at s0) and b_s7[127:0] (with Nfb6 at b0)
==============================================================================================
 Output: Z[7:0] (8-Bit Keystream Byte) ──► Ciphertext Byte C[7:0] = P[7:0] ^ Z[7:0]
==============================================================================================
```

---
*Unified Master Specification for the Design and ASIC Implementation of Integrated LFSR-NFSR Based Pseudorandom Generator Using 45nm Technology.*
