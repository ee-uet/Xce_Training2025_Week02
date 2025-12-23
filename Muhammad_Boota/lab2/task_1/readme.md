# Lab 2A: 32-bit Barrel Shifter

## 📌 Overview
This lab implements a **32-bit Barrel Shifter** in SystemVerilog.  
A barrel shifter allows shifting or rotating a data word by a specified number of bit positions in a **single cycle**.  

---

## 🖼 Block Diagram
![Barrel Shifter Block Diagram](/Muhammad_Boota/lab2/task_1/docx/barrel_shifter.png)

---

## 🔧 Design Requirements
- **Inputs**:
  - `data_in[31:0]` → 32-bit input data  
  - `shift_amt[4:0]` → 5-bit shift amount (`0–31`)  
  - `left_right` → Direction control (`0 = left`, `1 = right`)  
  - `shift_rotate` → Mode control (`0 = shift`, `1 = rotate`)  

- **Outputs**:
  - `out[31:0]` → 32-bit shifted or rotated result  

- **Behavior**:
  - **Shift**: Vacated bit positions filled with zeros.  
  - **Rotate**: Bits shifted out wrap around to the other side.  
  - **Single cycle operation** for all cases.  

---