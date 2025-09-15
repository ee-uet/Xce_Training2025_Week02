# 32-bit Barrel Shifter Project

## Overview

This project implements a 32-bit barrel shifter in SystemVerilog. The barrel shifter can perform left/right shifts and rotations on 32-bit data with variable shift amounts up to 31 positions in a single clock cycle.

## Problem

Design and implement a 32-bit barrel shifter that:
- Performs left and right shifts on 32-bit input data
- Supports both logical shift and rotate operations
- Accepts shift amounts from 0 to 31 positions
- Operates combinationally for single-cycle execution
- Uses a 5-bit shift amount control signal

## Approach

The barrel shifter is implemented using a 5-stage pipeline architecture with combinational logic. Each stage handles a specific bit position (1, 2, 4, 8, 16 bits) based on the corresponding bit in the shift amount. The design uses multiplexers controlled by shift amount bits to selectively apply shifts at each stage, enabling any shift amount from 0 to 31 in one cycle.

## Project Structure

```
lab2A/
├── Documentation/          # Contains block diagram, waveform, and signal specification
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── barrel_shifter.sv       # Main barrel shifter module
    └── barrel_shifter_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the barrel shifter behavior.

## Examples

### Left Shift by 1
```systemverilog
data_in = 32'h8000_0001; shift_amt = 5'b00001; left_right = 0; shift_rotate = 0;
// Expected result: data_out = 32'h0000_0002
```

### Left Rotate by 1
```systemverilog
data_in = 32'h8000_0001; shift_amt = 5'b00001; left_right = 0; shift_rotate = 1;
// Expected result: data_out = 32'h0000_0003
```

### Right Rotate by 2
```systemverilog
data_in = 32'h0000_0003; shift_amt = 5'b00010; left_right = 1; shift_rotate = 1;
// Expected result: data_out = 32'hC000_0000
```

### Left Shift by 8
```systemverilog
data_in = 32'h1234_5678; shift_amt = 5'b01000; left_right = 0; shift_rotate = 0;
// Expected result: data_out = 32'h3456_7800
```