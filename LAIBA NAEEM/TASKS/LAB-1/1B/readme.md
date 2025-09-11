# LAB1: BASIC COMBINATIONAL CIRCUITS   
**LAB1B: 8-to-3 Priority Encoder with Enable**

Module: priority_encoder_8to3   

Purpose: The purpose of this module is to encode the highest-priority active input among 8 input lines (I7 to I0) into a 3-bit binary code.   
•	I7 has the highest priority.   
•	I0 has the lowest priority.    
•	If multiple inputs are active, the encoder always selects the highest one.    
•	The enable signal allows the encoder to be activated or deactivated.   
•	The valid output indicates whether any input is active when the encoder is enabled.   

**Signals**  

  Inputs   
•	enable: Activates the encoder. If 0, outputs are forced to zero.   
•	data_in[7:0]: 8-bit input lines (I7..I0).   
 Outputs   
•	encoded_out[2:0]: Binary code of the highest-priority active input.   
•	valid: Indicates whether at least one input is active (and enable=1).   
#
**Truth Table**

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

#

**Data Path**
![Alt text](priority_datapath.png)

#
 **Resources**

- Learned priority encoder logic from google.  
- Learned how to use casez in SystemVerilog with help from AI explanations.
#
**Code Quality Checklist for 8-to-3 Priority Encoder**

- [x] Consistent naming conventions (`enable`, `data_in`, `encoded_out`, `valid`)  
- [x] No combinational loops (uses `always_comb` safely)  
- [x] No unintended latches (default assignments prevent latches)  
- [x] Comments explain design intent (priority encoding logic, use of `casez`, valid signal generation) 