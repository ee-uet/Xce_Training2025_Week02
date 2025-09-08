Binary to BCD Converter Module
Overview
The binary_to_bcd module is a Verilog implementation of an 8-bit binary to Binary-Coded Decimal (BCD) converter. It takes an 8-bit binary input (binary_in) and produces a 12-bit BCD output (bcd_out), representing three decimal digits (hundreds, tens, units).
Features

Input:
binary_in (8-bit): Binary number (0 to 255).


Output:
bcd_out (12-bit): BCD representation with three 4-bit digits (hundreds: bcd_out[11:8], tens: bcd_out[7:4], units: bcd_out[3:0]).



Operation

Converts an 8-bit binary number (0–255) to a 12-bit BCD number.
Each 4-bit segment of bcd_out represents a decimal digit (0–9).
Example: Binary 11111010 (250) → BCD 0010_0101_0000 (250 in decimal).

Implementation Details

Module Structure:
Uses always_comb for combinational logic.
Employs the double-dabble (shift-and-add-3) algorithm.
A 20-bit temporary register (temp) holds intermediate results, initialized with binary_in padded with 12 leading zeros.


Algorithm:
For each of the 8 bits in binary_in:
If any 4-bit BCD digit (hundreds, tens, units) is greater than 4, add 3 to that digit.
Shift temp left by 1 bit.


After 8 iterations, bcd_out is assigned the top 12 bits of temp (temp[19:8]), containing the BCD digits.



Edge Cases

Input Range:
Valid inputs: binary_in from 0 to 255 (8-bit range).
Values > 255 are not supported due to input width; higher bits would be truncated in a larger system.


Zero Input:
binary_in = 8'b00000000 → bcd_out = 12'b0000_0000_0000 (BCD for 0).


Maximum Input:
binary_in = 8'b11111111 (255) → bcd_out = 12'b0010_0101_0101 (BCD for 255).


Digit Overflow:
The algorithm ensures digits remain valid (0–9) by adding 3 when a digit exceeds 4 before shifting.



Usage
To use this module:

Instantiate it in your Verilog design.
Connect an 8-bit binary_in.
Monitor the 12-bit bcd_out for the BCD result.This module is ideal for applications requiring decimal display, such as calculators or digital counters.
