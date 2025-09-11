# Lab 1A: 8-bit Arithmetic Logic Unit (ALU)

## Problem
Design and implement an **8-bit Arithmetic Logic Unit (ALU)** in SystemVerilog with the following features:
- Supported operations: **ADD, SUB, AND, OR, XOR, NOT, Shift Left Logical (SLL), Shift Right Logical (SRL)**
- Operation selection via a **3-bit control input**
- Status outputs:
  - **Zero** (set when result = 0)
  - **Carry** (set when addition/subtraction produces a carry/borrow or when shift operations discard a bit)
  - **Overflow** (set for signed overflow in arithmetic operations)
- The ALU is optimized for **FPGA implementation**.

---

## Approach
1. **Truth Table Creation** – Defined the behavior for each of the 8 operations using a 3-bit selector.
2. **Datapath Design** – Drew the block diagram showing ALU operations and status signal logic.
3. **Carry/Overflow Optimization** – Implemented efficient logic for carry and signed overflow detection in addition and subtraction.
4. **FPGA-Friendly Implementation** – Ensured synthesis compatibility with **Xilinx Vivado**, using concise always-combinational blocks.

The ALU was tested with a **SystemVerilog Testbench** (`tb_alu.sv`) that validates:
- Arithmetic operations with and without carry/overflow
- Bitwise operations (AND, OR, XOR, NOT)
- Shift operations with correct carry handling
- Correct setting of **Zero** and **Overflow** flags

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Open **QuestaSim**  
- Compile the `alu.sv` and `tb_alu.sv` files  
- Run the simulation to observe waveforms and `$display` outputs  

### Synthesis
- Import the `alu.sv` file into **Xilinx Vivado**  
- Run synthesis and implementation for FPGA resource utilization and timing analysis  

---

## Results
- All 8 ALU operations were successfully implemented and verified.  
- Simulation waveform:
		Inputs: Blue color
		outputs: Yellow Color 
   

