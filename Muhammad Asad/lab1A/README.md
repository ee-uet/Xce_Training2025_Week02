# 8-bit ALU Project

## Overview

This project implements an 8-bit Arithmetic Logic Unit (ALU) in SystemVerilog. The ALU performs various arithmetic and logical operations on 8-bit signed inputs and provides status flags for zero, carry, and overflow conditions.

## Problem

Design and implement an 8-bit ALU that can perform the following operations:
- Addition
- Subtraction  
- Bitwise AND
- Bitwise OR
- Bitwise XOR
- Bitwise NOT
- Left Shift
- Right Shift

The ALU should output appropriate status flags (zero, carry, overflow) based on the operation results.

## Approach

The ALU is implemented using a combinational always block with a case statement to select operations based on the 3-bit operation selector input. Each operation is handled separately with appropriate flag generation logic.

## Project Structure

```
lab1A/
├── Documentation/          # Contains block diagram, waveform, and signal specification
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── alu_8bit.sv       # Main ALU module
    └── alu_8bit_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the priority encoder behavior.

## Examples

### Addition Operation
```systemverilog
a = 8'd100; b = 8'd50; op_sel = 3'b000;
// Expected result: 150, zero = 0, carry = 0, overflow = 0
```

### Subtraction Operation
```systemverilog
a = 8'h9C; b = 8'h32; op_sel = 3'b001;  // a = -100, b = 50
// Expected result: -150, zero = 0, carry = 1, overflow = 0
```

### Bitwise AND Operation
```systemverilog
a = 8'hFF; b = 8'h0F; op_sel = 3'b010;
// Expected result: 8'h0F, zero = 0, carry = 0, overflow = 0
```

### Left Shift Operation
```systemverilog
a = 8'h81; b = 8'h00; op_sel = 3'b110;
// Expected result: 8'h02, zero = 0, carry = 1, overflow = 0
```