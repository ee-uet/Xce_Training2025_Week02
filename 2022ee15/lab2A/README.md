# Lab 2A: 32-bit Barrel Shifter

## Problem
Design and implement a **32-bit Barrel Shifter** in SystemVerilog with the following features:
- **Data width:** 32-bit input and output  
- **Shift amount:** 5-bit control (supports 0–31 positions)  
- **Direction control:** Left (0) or Right (1)  
- **Mode control:** Shift (0) or Rotate (1)  
- **Operation:** Single-cycle, purely combinational  

---

## Approach
1. **Datapath Design** – Implemented a 5-stage multiplexer-based shifting network. Each stage shifts/rotates by `2^i` positions (1, 2, 4, 8, 16).  
2. **Direction Control** – Added conditional logic for left/right shifts and rotates.  
3. **Mode Control** – Incorporated rotation support by wrapping shifted-out bits back into the word.  
4. **FPGA Optimization** – Used parallel multiplexers for minimal delay and better FPGA routing resource utilization.  

The design is **fully combinational** and produces results in a single cycle. A self-checking **SystemVerilog testbench** (`barrel_shifter_tb.sv`) was created to verify shift and rotate operations in both directions.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Open **QuestaSim**  
- Compile the `barrel_shifter.sv` and `barrel_shifter_tb.sv` files  
- Run the simulation to observe `$display` results (PASS/FAIL messages)  

### Synthesis
- Import the `barrel_shifter.sv` file into **Xilinx Vivado**  
- Run synthesis and implementation to check FPGA resource usage and timing performance  

---

## Results
- All **shift and rotate modes** (left/right) work correctly for arbitrary shift amounts (0–31).  
- The **testbench outputs PASS/FAIL messages** for each case, ensuring correctness.  
- Verified cases include:
  - **Shift Left**: Logical shifts with zero fill  
  - **Shift Right**: Logical shifts with zero fill  
  - **Rotate Left**: Bits shifted out on the left reappear on the right  
  - **Rotate Right**: Bits shifted out on the right reappear on the left  
- Simulation Waveform:
	Inputs = Blue Signals.
	Outputs = Yellow Signals.
