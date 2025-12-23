# 8-to-3 Priority Encoder Project

## Overview

This project implements an 8-to-3 priority encoder in SystemVerilog. The priority encoder takes an 8-bit input and encodes the position of the highest priority (most significant) active bit into a 3-bit output code.

## Problem

Design and implement an 8-to-3 priority encoder that:
- Encodes the position of the highest priority bit from an 8-bit input
- Provides a valid output signal indicating successful encoding
- Includes an enable signal for controlling the encoder operation
- Outputs the binary position of the most significant '1' bit

## Approach

The priority encoder is implemented using a combinational always block with a casez statement to handle priority encoding. The casez statement uses wildcard patterns to match the highest priority bit position, ensuring that the most significant '1' bit takes precedence over lower priority bits.

## Project Structure

```
lab1B/
├── Documentation/          # Contains block diagram, waveform, and signal specification
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── priority_encoder_8to3.sv       # Main priority encoder module
    └── priority_encoder_8to3_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the priority encoder behavior.

## Examples

### Disabled State
```systemverilog
enable = 0; data_in = 8'b10101010;
// Expected result: encoded_out = 3'b000, valid = 0
```

### Single Bit Active
```systemverilog
enable = 1; data_in = 8'b00010000;
// Expected result: encoded_out = 3'b100, valid = 1
```

### Multiple Bits Active (Priority Encoding)
```systemverilog
enable = 1; data_in = 8'b01011000;
// Expected result: encoded_out = 3'b110, valid = 1 (bit 6 has highest priority)
```

### All Zeros Input
```systemverilog
enable = 1; data_in = 8'b00000000;
// Expected result: encoded_out = 3'b000, valid = 0
```