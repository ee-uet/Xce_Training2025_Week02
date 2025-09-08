# 32-bit Barrel Shifter - Lab 2

## Problem Description

This lab implements a 32-bit barrel shifter that can perform four different operations: left shift, right shift, left rotate, and right rotate. The barrel shifter can shift or rotate data by any amount from 0 to 31 positions in a single clock cycle. Unlike sequential shifters that require multiple cycles, this barrel shifter uses a multi-stage approach with 5 stages of multiplexers to achieve any shift amount efficiently. The operation type is controlled by two input signals: `left_right` (direction) and `shift_rotate` (mode).

## Approach

The barrel shifter is implemented using a **5-stage cascaded multiplexer design** with the following key components:

- **Multi-Stage Architecture**: 5 stages (s0, s1, s2, s3, y) where each stage can shift by powers of 2 (1, 2, 4, 8, 16 bits)
- **Binary Decomposition**: The 5-bit shift amount controls each stage independently - `shift_amt[i]` controls stage i
- **Direction Control**: `left_right` signal determines shift direction (0=left, 1=right)
- **Mode Control**: `shift_rotate` signal selects between logical shift (zero fill) and rotate operations
- **Combinational Logic**: Pure combinational design using `always_comb` for single-cycle operation

Each stage either passes the input unchanged or performs a specific shift amount (1, 2, 4, 8, or 16 positions). The final shift amount is the sum of all active stages, allowing any value from 0-31.

## Folder Structure

```
barrelshifter/
├── barrel_shifter.sv                    
├── tb_barrel_shifter.sv                 
├── documentation/
│   └── truthtable
│   └── signal_description.txt
│   └──  waves 
└── README.md                           
```

## How to Run

### Prerequisites
- SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

#### Using ModelSim/QuestaSim:
```bash
# Compile the design and testbench
vlog barrel_shifter.sv tb_barrel_shifter.sv

# Start simulation
vsim tb_barrel_shifter

# Run the simulation
run -all
```

#### Using Vivado:
```bash
# Create new project and add source files
# Set tb_barrel_shifter as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests all four operation modes with different shift amounts and finishes automatically.

## Examples

### Test Case 1: Left Shift by 1
- **Input**: a = 32'hA5A5A5A5, shift_amt = 5'd1, left_right = 0, shift_rotate = 0
- **Expected Output**: y = 32'h4B4B4B4A (logical left shift, LSB filled with 0)

### Test Case 2: Right Shift by 4
- **Input**: a = 32'h1234ABCD, shift_amt = 5'd4, left_right = 1, shift_rotate = 0
- **Expected Output**: y = 32'h01234ABC (logical right shift, MSBs filled with 0)

### Test Case 3: Left Rotate by 8
- **Input**: a = 32'hDEADBEEF, shift_amt = 5'd8, left_right = 0, shift_rotate = 1
- **Expected Output**: y = 32'hADBEEFDE (left rotate, MSB bits wrap to LSB)

### Test Case 4: Right Rotate by 16
- **Input**: a = 32'hCAFEBABE, shift_amt = 5'd16, left_right = 1, shift_rotate = 1
- **Expected Output**: y = 32'hBABECAFE (right rotate, LSB bits wrap to MSB)