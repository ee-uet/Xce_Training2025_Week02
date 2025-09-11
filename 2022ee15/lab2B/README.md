# Lab 2B: Binary Coded Decimal (BCD) Converter

## Problem
Design and implement an **8-bit Binary to 3-digit BCD Converter** in SystemVerilog with the following requirements:  
- **Input:** 8-bit binary number (0–255)  
- **Output:** 3-digit BCD (000–255)  
- **Implementation:** Purely combinational logic  
- **Algorithm:** Double Dabble (Shift-and-Add-3)  

---

## Approach
1. **Algorithm Selection** – Used the **Double Dabble algorithm** (also known as the shift-and-add-3 algorithm), which efficiently converts binary to BCD using shifts and conditional additions.  
2. **Temporary Register** – Created a 20-bit temporary register to hold the input binary value and intermediate BCD digits.  
3. **Iteration** – For each of the 8 input bits:
   - Check each BCD digit (hundreds, tens, ones).  
   - If a digit ≥ 5, add 3 (correction step).  
   - Shift the entire register left by 1.  
4. **Output Mapping** – After 8 iterations, extract the 3-digit BCD result from the register and assign it to the output.  
5. **Verification** – A self-checking **testbench** (`tb_lab2b.sv`) applies multiple test values and displays the converted BCD digits.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Open **QuestaSim**  
- Compile the `lab2b.sv` and `tb_lab2b.sv` files  
- Run the simulation to observe the binary-to-BCD conversion results in the console  

### Synthesis
- Import the `lab2b.sv` file into **Xilinx Vivado**  
- Run synthesis and implementation to check FPGA resource usage and verify functionality  

---

## Results
- The design successfully converts binary values (0–255) into their equivalent **3-digit BCD** representation.  
- Simulation waveform:
	Inputs = Blue signals.
	Output = Yellow Signals.
