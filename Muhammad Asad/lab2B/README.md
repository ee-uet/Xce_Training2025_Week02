# Binary to BCD Converter Project

## Overview

This project implements an 8-bit binary to 12-bit BCD (Binary Coded Decimal) converter in SystemVerilog. The converter takes an 8-bit binary number and converts it to its BCD representation using the double-dabble algorithm.

## Problem

Design and implement a binary to BCD converter that:
- Converts 8-bit binary input (0-255) to BCD format
- Outputs 12-bit BCD representing hundreds, tens, and ones digits
- Uses combinational logic for real-time conversion
- Implements the double-dabble shift-and-add-3 algorithm

## Approach

The BCD converter is implemented using the double-dabble algorithm with combinational logic. The design uses a 20-bit temporary register and iteratively shifts the binary input while adding 3 to any BCD digit that is 5 or greater before shifting. This process is repeated for 8 iterations to handle the 8-bit input, ensuring proper BCD conversion.

## Project Structure

```
lab2B/
├── Documentation/          # Contains block diagram, waveform, and signal specification
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── BCD_converter.sv       # Main BCD converter module
    └── BCD_converter_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the BCD converter behavior.

## Examples

### Single Digit Conversion
```systemverilog
binary_in = 8'd9;
// Expected result: bcd = 12'h009 (0 hundreds, 0 tens, 9 ones)
```

### Two Digit Conversion
```systemverilog
binary_in = 8'd45;
// Expected result: bcd = 12'h045 (0 hundreds, 4 tens, 5 ones)
```

### Three Digit Conversion
```systemverilog
binary_in = 8'd123;
// Expected result: bcd = 12'h123 (1 hundreds, 2 tens, 3 ones)
```