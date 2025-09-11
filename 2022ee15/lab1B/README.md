# Lab 1B: 8-to-3 Priority Encoder with Enable

## Problem
Design and implement an **8-to-3 Priority Encoder** in SystemVerilog with the following specifications:
- **Input:** 8 active-high inputs, with MSB having the highest priority.  
- **Control:** Input **enable** signal.  
- **Outputs:**
  - 3-bit **encoded value** representing the position of the highest-priority active input.  
  - **Valid** signal that indicates whether at least one input is active.  
- Must correctly handle the **all-zero input case** (no active inputs).  

---

## Approach
1. **Truth Table Construction** – Created the full truth table for 8 inputs with priority given to the MSB.  
2. **K-map Optimization** – Simplified output logic equations to minimize hardware usage.  
3. **Efficient Implementation** – Used a `casez` statement in SystemVerilog to handle **don’t-care conditions** and ensure concise priority checking.  
4. **Enable Control** – Incorporated logic to force outputs to `000` and mark `valid = 0` when `enable = 0`.  

The design was verified with a **SystemVerilog Testbench** (`Priority_Encoder_tb.sv`) that applied multiple input combinations to validate priority behavior, valid signal functionality, and enable control.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Open **QuestaSim**  
- Compile the `Priority_Encoder.sv` and `Priority_Encoder_tb.sv` files  
- Run the simulation and check the `$display` outputs or waveform  

### Synthesis
- Import the `Priority_Encoder.sv` file into **Xilinx Vivado**  
- Run synthesis and implementation to verify FPGA resource usage  

---

## Results
- The **priority encoder correctly outputs the highest-priority active input** (MSB = highest priority).  
- The **valid signal** behaves as expected:
  - `valid = 0` when all inputs are `0` or when `enable = 0`  
  - `valid = 1` when any input is active and `enable = 1`  
 
- The design was verified with multiple test cases, including **single input active, multiple inputs active, all-zero inputs, and enable disabled**.
- Simulation waveform:
	Inputs = Blue signals.
	Outputs = Yellow signals.

