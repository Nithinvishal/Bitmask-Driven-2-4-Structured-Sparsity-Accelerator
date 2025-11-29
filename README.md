# Bitmask-Driven-2-4-Structured-Sparsity-Accelerator

🚀 Project Overview

This project implements a custom hardware accelerator targeting AI Matrix Multiplication. Standard "dense" multipliers waste significant energy/area processing zero-values in Neural Network weights. This design exploits 2:4 Structured Sparsity (similar to NVIDIA Ampere architecture) to intelligently skip redundant operations.

The project covers the full ASIC flow: RTL Design -> Verification -> Synthesis -> Physical Implementation (GDSII).

⚡ Key Features

Zero-Skipping Logic: Custom bitmask decoder selects only non-zero activations.

Hardware Efficient: Achieved 50% reduction in DSP (Multiplier) usage compared to standard INT8 MAC units.

High Reliability: Validated against a Python Golden Reference Model with 10,000 constrained-random test vectors.

Silicon Ready: Physically implemented using the Google/SkyWater 130nm PDK.

📊 PPA Analysis (Power, Performance, Area)

### PPA Analysis (Power, Performance, Area)

| Metric               | Standard (Dense) PE | Sparse PE (My Design)   | Improvement               |
|----------------------|---------------------|-------------------------|---------------------------|
| Compute Units (DSP)  | 4                   | 2                       | **50% Reduction**         |
| Logic Cells (LUTs)   | ~140                | ~170                    | Slight MUX overhead       |
| Throughput           | 4 Ops / Cycle       | 2 Effective Ops / Cycle | Functionally Equivalent   |


🛠️ Tech Stack

RTL Design: Verilog HDL

Verification: Python (Golden Model), Icarus Verilog, GTKWave

Synthesis: Yosys (Open Source Synthesis Suite)

Physical Design: OpenLane (Docker-based ASIC Flow), KLayout, Magic

📂 Architecture & Verification

Verification Strategy (UVM-Style)

A Python-Verilog Co-Simulation environment was built to verify the sparsity logic.

Python Script: Generates random weights/activations, applies 2:4 pruning, calculates expected results, and generates a Bitmask.

Verilog Testbench: Reads the generated hex files, drives the DUT (Device Under Test), and compares the output cycle-by-cycle.

Figure 2: GTKWave simulation showing cycle-accurate matching between Hardware Result and Golden Expected Value.

🚀 How to Run

1. Functional Verification

# Generate random test vectors (Hex files)
python3 scripts/gen_data.py

# Compile and Run Simulation
iverilog -o pe_test.vvp rtl/sparse_pe.v tb/tb_sparse_pe.v
vvp pe_test.vvp


2. Logic Synthesis (Yosys)

# Run comparison script
yosys scripts/compare.ys


3. Physical Design (OpenLane)

# Inside OpenLane Docker container
./flow.tcl -design sparse_pe


📜 License

This project is open-source under the MIT License.
