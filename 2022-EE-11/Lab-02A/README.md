32-Bit Barrel Shifter Module
Overview
The barrel_shifter module is a Verilog implementation of a 32-bit barrel shifter. It performs left or right shifts/rotates on a 32-bit input (data_in) based on a 5-bit shift amount (shift_amt) and control signals for direction (left_right) and mode (shift_rotate). The result is output as data_out.
Features

Inputs:
data_in (32-bit): Input data to shift/rotate.
shift_amt (5-bit): Number of positions to shift/rotate (0 to 31).
left_right (1-bit): 0 for left, 1 for right.
shift_rotate (1-bit): 0 for shift, 1 for rotate.


Output:
data_out (32-bit): Result of the shift/rotate operation.



Operations
The module supports four operations based on left_right and shift_rotate:



left_right
shift_rotate
Operation
Description



0
0
Left Shift
Shifts left, fills LSBs with 0s.


1
0
Right Shift
Shifts right, fills MSBs with 0s.


0
1
Left Rotate
Rotates left, wraps MSBs to LSBs.


1
1
Right Rotate
Rotates right, wraps LSBs to MSBs.


Implementation Details

Module Structure:
Uses always_comb for combinational logic.
Implements a five-stage barrel shifter (stages 0–4) for shifts of 1, 2, 4, 8, and 16 bits, controlled by shift_amt[0:4].
Each stage conditionally shifts/rotates based on the corresponding bit of shift_amt.
Final result is assigned to data_out from the last stage (stage4).


Shift/Rotate Logic:
Left Shift: Shifts data_in left, filling LSBs with 0s.
Right Shift: Shifts data_in right, filling MSBs with 0s.
Left Rotate: Shifts left, wrapping MSBs to LSBs.
Right Rotate: Shifts right, wrapping LSBs to MSBs.
Each stage uses bit slicing to handle the appropriate shift/rotate amount.



Edge Cases

Zero Shift Amount:
If shift_amt = 5'b00000, data_out = data_in (no shift/rotate).


Maximum Shift Amount:
If shift_amt = 5'b11111 (31), shifts/rotates by 31 positions.
For shifts, this results in nearly all bits being 0 (except possibly one bit).
For rotates, the result is equivalent to a 31-bit rotation.


Shift vs. Rotate:
Shifts fill vacated bits with 0s, while rotates recycle bits from the opposite end.


Invalid Shift Amounts:
Since shift_amt is 5 bits, values are inherently valid (0–31). Larger values are not possible due to input width.

