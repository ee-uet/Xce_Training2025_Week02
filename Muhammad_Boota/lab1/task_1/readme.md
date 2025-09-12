# Lab 1A: 8-bit Arithmetic Logic Unit (ALU)

## Overview
This lab implements an **8-bit Arithmetic Logic Unit (ALU)** in SystemVerilog.  
The ALU performs common arithmetic and logic operations and generates useful status flags.  
It is optimized for **FPGA implementation**.

---

## Block Diagram
![ALU Block Diagram](/Muhammad_Boota/lab1/task_1/docx/ALU.png)

---

##  Design Requirements
- **Data width**: 8 bits  
- **Operation select**: 3-bit control (`op`)  
- **Supported operations**:
  - `000` → ADD  
  - `001` → SUB  
  - `010` → AND  
  - `011` → OR  
  - `100` → XOR  
  - `101` → NOT (on `num1`)  
  - `110` → SLL (Shift Left Logical)  
  - `111` → SRL (Shift Right Logical)  

- **Status outputs**:
  1. `zero` → High if result = 0  
  2. `carry` → Carry out from ADD/SUB  
  3. `overflow` → Signed overflow detection  

