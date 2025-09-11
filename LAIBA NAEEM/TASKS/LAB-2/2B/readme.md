# LAB 2B: Binary Coded Decimal (BCD) Converter 

Module: binary_to_bcd  
Purpose: This module converts an 8-bit binary number into its equivalent 3-digit Binary-Coded Decimal (BCD) format. 
It uses the Double-Dabble algorithm, where each step shifts bits left and adjusts digits by adding 3 if a nibble ≥ 5, ensuring proper BCD formatting. 
#
**Signals**  
Inputs   
•	binary_in [7:0] → The input binary number (0–255).   
Outputs   
•	bcd_out [11:0] → The converted 3-digit BCD output.   
▪	[11:8] = Hundreds digit (BCD)   
▪	[7:4] = Tens digit (BCD) ▪ [3:0] = Ones digit (BCD)   
Internal  
•	temp [11:0] → Temporary register for holding intermediate results during conversion.   
•	i (integer) → Loop index for processing all 8 input bits.   
#

**Double-Dabble Algorithm** 

The Double-Dabble algorithm is a widely used methd for converting binary numbers to BCD. It is also known as the shift-and-add-3 algorithm. The algorithm works as follows: 
Steps: 
1.	Initialize a shift register wide enough to hold the BCD digits plus the input binary number. For an 8-bit input, shift_reg = {12’b0, binary_in}. Here, 12 bits are reserved for 3 BCD digits, and 8 bits hold the binary input. 
2.	Iteratively shift left the entire register by 1 bit. Perform this shift as many times as the number of bits in the input (8 in this case). 
3.	Add 3 to each BCD digit if its current value is ≥ 5. This ensures that after the next shift, no BCD digit exceeds 9. 
4.	Continue until all input bits are shifted into the BCD portion. 
5.	Extract the final BCD result from the upper bits of the shift register. 

#
**Example**

Binary input: 8'd45      
BCD Output: 12'b0000_0100_0101 (Decimal 45)  

#
**Resources**  
Watched a YouTube video about binary-to-BCD conversion.
#
**Code Quality Checklist**

- [x] Consistent naming (`binary_in`, `bcd_out`, `temp`)  
- [x] Proper module hierarchy (all logic in one clean module)  
- [x] All outputs driven in all conditions (`bcd_out` always assigned)  
- [x] No combinational loops (`always_comb` used safely)  
- [x] No unintended latches (default assignment handled in `temp`)  
- [x] Comments explain design intent (Double-Dabble steps and shifting logic)  