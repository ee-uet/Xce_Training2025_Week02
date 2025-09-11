# Binary-Coded Decimal (BCD) Converter

## Introduction
A **Binary-Coded Decimal (BCD) converter** changes a binary number into its decimal form, where each decimal digit is represented by 4 bits.  

This is useful for systems like calculators and digital displays that need to show decimal digits.  

---
![alt text](image-1.png)
---
## Double-Dabble Algorithm 

The **Double-Dabble** algorithm is a simple way to convert binary to BCD in hardware.  

### Step-by-Step Process
1. **Setup:**  
   - Create a shift register large enough for both BCD digits and the binary input.  
   - For an 8-bit input, use 20 bits total (12 for BCD + 8 for binary).  
   - Example: `shift_reg = {12'b0, binary_in}`.  

2. **Repeat for each input bit (8 times for an 8-bit number):**  
   - Check each BCD digit:  
     - If any digit ≥ 5, add 3 to that digit.  
   - Shift the whole register left by 1 bit.  

3. **Finish:**  
   - After all shifts, the top 12 bits contain the BCD result (hundreds, tens, ones).  

---

## Design
- **Type:** Combinational circuit .  
- **Input range:** 8-bit binary numbers (0–255).  
- **Outputs:** 3 BCD digits (hundreds, tens, ones).  

---

## Examples


### Example 2: Binary 45
- **Binary input:** `00101101`   
- **BCD output:** `0000 0100 0101` → 0 4 5  

---

### Example 3: Binary 9
- **Binary input:** `00001001` (9)  
- **BCD output:** `0000 0000 1001` → 009  

---



## AI Usage
- AI helped simplify the step-by-step explanation of the Double-Dabble algorithm.  
- Improved formatting into a clean Markdown structure.  
  

---

 
