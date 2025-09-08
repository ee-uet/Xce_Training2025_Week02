# 8-bit ALU (Arithmetic Logic Unit) - Lab 1

## Problem Description

This lab implements a comprehensive 8-bit Arithmetic Logic Unit (ALU) that performs various arithmetic, logical, and shift operations. The ALU is a fundamental component in processor design, capable of executing 8 different operations based on a 3-bit operation selector (ADD, SUB, AND, OR, XOR, NOT, Shift Left, Shift Right). The design includes proper flag generation for status monitoring including zero, carry, and overflow detection.

## Approach

The ALU is implemented using a **combinational logic design** with the following key components:

- **Combinational Design**: Uses `always_comb` for immediate output response to input changes
- **Case Statement**: Operation selection based on 3-bit `op_sel` input for clean code organization
- **Flag Generation**: Dedicated logic for carry, overflow, and zero flag detection using a 9-bit temporary variable for arithmetic operations
- **Modular Structure**: Clean separation of operation logic and flag computation

The design handles all 8 operations (000-111) with proper edge case handling including signed overflow detection for arithmetic operations and carry-out detection for shift operations.

## Folder Structure

```
lab1/
├── alu_8bit.sv                           # Main ALU module implementation
├── tb_alu_8bit.sv                        
├── documentation/
│   └── truthtable+signal_description.txt+waves # Documentation and truth table
└── README.md                             
```

## How to Run

### Prerequisites
- SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

#### Using ModelSim/QuestaSim:
```bash
# Compile the design and testbench
vlog alu_8bit.sv tb_alu_8bit.sv

# Start simulation
vsim tb_alu_8bit

# Run the simulation
run -all
```

#### Using Vivado:
```bash
# Create new project and add source files
# Set tb_alu_8bit as top module for simulation
# Run behavioral simulation
```

The testbench automatically runs through all 8 operations with predefined test vectors and stops after completion.

## Examples

### Test Case 1: Addition (op_sel = 000)
- **Input**: a = 10, b = 5
- **Expected Output**: result = 15, carry = 0, overflow = 0, zero = 0

### Test Case 2: Subtraction (op_sel = 001)  
- **Input**: a = 15, b = 20
- **Expected Output**: result = 251 (8-bit wraparound), carry = 1, zero = 0

### Test Case 3: Logical AND (op_sel = 010)
- **Input**: a = 0xF0, b = 0x0F
- **Expected Output**: result = 0x00, zero = 1

### Test Case 4: Logical OR (op_sel = 011)
- **Input**: a = 0xF0, b = 0x0F
- **Expected Output**: result = 0xFF, zero = 0

### Test Case 5: XOR (op_sel = 100)
- **Input**: a = 0xAA, b = 0x55
- **Expected Output**: result = 0xFF, zero = 0

### Test Case 6: NOT (op_sel = 101)
- **Input**: a = 0x5A, b = 0x00 (ignored)
- **Expected Output**: result = 0xA5, zero = 0

### Test Case 7: Shift Left (op_sel = 110)
- **Input**: a = 0x81, b = 0x00 (ignored)
- **Expected Output**: result = 0x02, carry = 1 (MSB shifted out)

### Test Case 8: Shift Right (op_sel = 111)
- **Input**: a = 0x81, b = 0x00 (ignored)
- **Expected Output**: result = 0x40, carry = 1 (LSB shifted out)