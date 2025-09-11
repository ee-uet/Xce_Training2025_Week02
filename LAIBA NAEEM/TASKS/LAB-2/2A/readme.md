# LAB 02: Advanced Combinational Logic 
**LAB 2A: 32-bit Barrel Shifter**  
Module: barrel_shifter   

Purpose: The barrel shifter performs high-speed shifting and rotating operations on a 32-bit input word. Unlike a simple shifter, it can shift or rotate the input by any number of positions in a single cycle. It supports four operations: 
1.	Logical Left Shift 
2.	Logical Right Shift 
3.	Rotate Left 
4.	Rotate Right 
#
**Signals**   

Inputs   
•	data_in [31:0]: The 32-bit input word to be shifted or rotated.   
•	shift_amt [4:0]: 5-bit control specifying the amount (0–31) of shift/rotate.   
•	left_right: Direction control (0 = left, 1 = right).   
•	shift_rotate: Operation control (0 = shift, 1 = rotate).   
Output   
•	data_out [31:0]: The 32-bit result after shifting or rotating.   
#
**Shifting and Rotating operation**   
•	Shift Operation   
 
-	Logical shift left (LSL): Moves all bits to the left by the shift amount. The vacant least significant bits (LSBs) are filled with zeros. 
-	Logical shift right (LSR): Moves all bits to the right. The vacant most significant bits (MSBs) are filled with zeros. 
 
• Rotate Operation   
-	Rotate left (ROL): Moves bits to the left, with bits shifted out from the MSB re-entering at the LSB. 
-	Rotate right (ROR): Moves bits to the right, with bits shifted out from the LSB reentering at the MSB. 
#
**Barrel Shifter Architecture**  

The 32-bit barrel shifter has 5 stages, each shifting the input by 1, 2, 4, 8, or 16 bits based on `shift_amt`.  
The `left_right` signal controls the direction: 0 for left shift/rotate, 1 for right shift/rotate.  
The `shift_rotate` signal selects between **shift** (fills with zeros) and **rotate** (wraps bits around).  
Each stage updates intermediate results, and the final output `data_out` reflects all selected shifts and rotations.
#
**32-Bit Barrel Shifter Stages**

| Stage   | Shift Amount | Purpose                    |
|---------|-------------|----------------------------|
| Stage 0 | 1           | Shift if `shift_amt[0] = 1` |
| Stage 1 | 2           | Shift if `shift_amt[1] = 1` |
| Stage 2 | 4           | Shift if `shift_amt[2] = 1` |
| Stage 3 | 8           | Shift if `shift_amt[3] = 1` |
| Stage 4 | 16          | Shift if `shift_amt[4] = 1` |
#
**Diagram**

![Alt text](datapath.png)

#
**Resources**
 
- Watched a YouTube video about barrel shifters.  
- Checked Google to clarify some shifting logic.  
- Asked AI to understand multi-stage shifting and fill bits.
#
**Code Quality Checklist for 32-Bit Barrel Shifter**

- [x] Consistent naming (`data_in`, `data_out`, `shift_amt`, `left_right`, `shift_rotate`)  
- [x] Proper module hierarchy (all logic in one clean module)  
- [x] All outputs driven in all conditions (`data_out` assigned in every case)  
- [x] No combinational loops (`always_comb` used safely)  
- [x] No unintended latches (default assignments handled in each stage)  
- [x] Reset/disable behavior consistent (data_out has a defined value in all cases)  
- [x] Comments explain design intent (stages, shift vs rotate, left vs right)  