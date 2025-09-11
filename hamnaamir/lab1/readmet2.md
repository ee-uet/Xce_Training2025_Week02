# 8-to-3 Priority Encoder with Enable

## Introduction
A **priority encoder** is a combinational circuit that encodes multiple input lines into a binary code based on the highest-priority active input.  

- In an **8-to-3 priority encoder**, there are 8 input lines (`I7..I0`) and 3 output lines (`Y2, Y1, Y0`).  
- **Priority:** `I7` has the highest priority, and `I0` has the lowest.  
- **Enable input (E):** When `E=0`, the encoder is disabled.  
- **Valid output (V):** Asserted when at least one input is active *and* `E=1`.  

---
![alt text](image.png)
---
## Truth Table

| I7 | I6 | I5 | I4 | I3 | I2 | I1 | I0 | Y2 | Y1 | Y0 |
|----|----|----|----|----|----|----|----|----|----|----|
| 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  | 0  | 0  | 0  |
| 0  | 0  | 0  | 0  | 0  | 0  | 1  | X  | 0  | 0  | 1  |
| 0  | 0  | 0  | 0  | 0  | 1  | X  | X  | 0  | 1  | 0  |
| 0  | 0  | 0  | 0  | 1  | X  | X  | X  | 0  | 1  | 1  |
| 0  | 0  | 0  | 1  | X  | X  | X  | X  | 1  | 0  | 0  |
| 0  | 0  | 1  | X  | X  | X  | X  | X  | 1  | 0  | 1  |
| 0  | 1  | X  | X  | X  | X  | X  | X  | 1  | 1  | 0  |
| 1  | X  | X  | X  | X  | X  | X  | X  | 1  | 1  | 1  |



---

## Problem
Design and document an **8-to-3 priority encoder with enable and valid outputs**.  
The encoder should output the binary index of the highest active input. When no inputs are active, or when enable is low, the output must be disabled.

---

## Approach
- **Priority checking:** Inputs are checked starting from `I7` down to `I0`.  
- **Encoding:** The binary code for the first detected `1` is assigned to `(Y2, Y1, Y0)`.  
- **Enable handling:** If `E=0`, outputs are forced inactive.  
- **Valid signal:** Output `V=1` only when at least one input is `1` *and* `E=1`.  

---

## Examples
- **Case 1:**  
  `E=1, I7=0, I6=0, I5=1, others=0` → Output = `101`, V=1  
- **Case 2:**  
  `E=1, I0=1` → Output = `000`, V=1  
- **Case 3:**  
  `E=0, any inputs` → Output disabled, V=0  

---



## AI Usage
- Used AI to refine indentation, formatting, and structure of the documentation.  

---

 
  