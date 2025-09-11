# Digital Design Lab Deliverables Repository

Welcome to the **Digital Design Lab Submissions Repository**.  
This repository will serve as the **submission portal for all lab deliverables** throughout the week. Students are required to follow the given structure and guidelines strictly while submitting their work.  

---

## Lab Manual Outline

The course is structured around a progressive lab manual that introduces **SystemVerilog-based Digital Design** concepts and FPGA synthesis methodology. The labs (the lab manual is attached [here]([url](https://docs.google.com/document/d/1OXFfLt3pLThsZbMhK5p9150xLZNFo4R9T_oMhC6NobY/edit?usp=sharing))) are divided into **combinational, sequential, FSM, interface, and integration-based designs**.  

### Contents
1. **Introduction to Digital Design Methodology**
   - Design Flow Overview, Principles, Documentation Requirements
2. **SystemVerilog Fundamentals for Digital Design**
   - Constructs, Data Types, Always Blocks, Synthesis Guidelines
3. **Lab 1: Basic Combinational Circuits**
   - 8-bit ALU  
   - Priority Encoder with Enable
4. **Lab 2: Advanced Combinational Logic**
   - 32-bit Barrel Shifter  
   - Binary Coded Decimal (BCD) Converter
5. **Lab 3: Sequential Circuit Fundamentals**
   - Programmable Counter
6. **Lab 4: Finite State Machines**
   - Traffic Light Controller  
   - Vending Machine Controller
7. **Lab 5: Counters and Timers**
   - Multi-Mode Timer
8. **Lab 6: Memory Interfaces**
   - Synchronous SRAM Controller
9. **Lab 7: FIFO Design**
   - Synchronous FIFO  
   - Asynchronous FIFO (CDC)
10. **Lab 8: UART Controller**
    - UART Transmitter  
    - UART Receiver
11. **Lab 9: SPI Controller**
    - SPI Master Controller
12. **Lab 10: AXI4-Lite Interface Design**
    - AXI4-Lite Slave Design  
    - Protocol Compliance & Performance
13. **FPGA Synthesis Guidelines**
    - Synthesis-Friendly Coding, Constraints, Resource/Timing Reports
14. **Design Documentation Standards**
    - Block Diagrams, FSM Documentation, Timing Diagrams, Interface Specs
15. **Lab Exercise Guidelines**
    - Pre-Lab Prep, During Lab, Post-Lab, Grading
16. **Additional Resources**
    - Recommended Reading, Tools, Software, Online Resources

---

## 📝 Submission Instructions

- Each student must **fork this repository** and create a folder with their **roll number or name**.  
- Place your deliverables in the folder structure:

```

<Your_Folder_Name>/
|- Lab-XX/
||-- \<your\_code>.sv <testbench>.sv
||-- documentation.pdf
||-- synthesis\_reports/
||-- <Output waveform screenshot>
|- Lab-XY/
----

```

- **Documentation Requirements (Compulsory):**
  - Block diagrams
  - State diagrams (for FSM labs)
  - Timing diagrams (where applicable)
  - Interface specifications (AXI4-Lite, UART, SPI, etc.)
---

## 📂 Example Directory Structure

```

YOUR FOLDER/
|- Lab-01A-ALU/
||-- alu.sv
||-- tb\_alu.sv
||-- report.pdf
|- Lab-01B-PriorityEncoder/
||-- priority\_encoder.sv
||-- tb\_priority\_encoder.sv
||-- report.pdf
|- Lab-02A-BarrelShifter/
|- Lab-02B-BCDConverter/
...

```

---

## Grading Criteria

- **Correctness of Design & Functionality**
- **Code Quality & Synthesis-Friendliness**
- **Documentation Completeness**
- **Testbench & Simulation Evidence**
- **Optimization & Extra Effort**

---

## ⚡ Tools & Software

- **HDL Language**: SystemVerilog  
- **Simulator**: ModelSim / Questa / iverilog + GTKWave  
- **Synthesis**: Xilinx Vivado  

---

## Important Notes

- Late submissions will **not be entertained** unless approved.  
- Plagiarism will result in **zero marks** and disciplinary action.  
- Each student must be able to **defend their submitted code** in viva sessions.  