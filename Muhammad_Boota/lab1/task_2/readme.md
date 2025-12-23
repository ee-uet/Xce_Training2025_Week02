# Lab 1B: Priority Encoder with Enable

## 📌 Overview
This lab implements an **8-to-3 Priority Encoder** in SystemVerilog.  
The encoder selects the highest-priority active input and outputs its index in binary form.  
It includes an **enable input** and a **valid output** to indicate when the result is meaningful.

---

## 🖼 Block Diagram
![Priority Encoder Block Diagram](/Muhammad_Boota/lab1/task_2/docx/Priority_Encoder.png)

---

## 🔧 Design Requirements
- **Inputs**:
  - `operand[7:0]` → Active-high inputs (bit 7 = highest priority, bit 0 = lowest)  
  - `enable` → Active-high enable signal  

- **Outputs**:
  - `out[2:0]` → 3-bit binary encoded index of highest-priority active input  
  - `valid` → High when a valid input is detected (else `0`)  

- **Behavior**:
  - If multiple inputs are high → Output the **highest-priority (MSB) index**  
  - If all inputs are `0` → `valid = 0`, output undefined/ignored  
  - Encoder only works when `enable = 1`  

---
