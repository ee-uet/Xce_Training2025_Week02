# Binary to BCD Converter - Lab 2

## Problem Description

This lab implements a binary to BCD (Binary Coded Decimal) converter that transforms an 8-bit unsigned binary number (0-255) into its equivalent 12-bit BCD representation. BCD encoding represents each decimal digit using 4 bits, so the output consists of three BCD digits: hundreds, tens, and ones. The converter uses the "Double Dabble" algorithm, which is an efficient method for binary-to-BCD conversion that processes the input bit by bit while applying correction factors when needed.

## Approach

The binary to BCD converter is implemented using the **Double Dabble Algorithm** with the following key components:

- **Iterative Processing**: 8-stage loop processing each bit of the input from MSB to LSB
- **Add-3 Correction**: Before each shift, any BCD digit ≥ 5 gets 3 added to prevent invalid BCD codes
- **Shift and Combine**: Uses a 20-bit combined register `{bcd[11:0], shift_reg[7:0]}` for unified shifting
- **Combinational Design**: Implemented using `always_comb` with a for-loop for clean, readable code

The algorithm works by:
1. Initialize BCD digits to 0 and load binary input into shift register
2. For each of the 8 iterations:
   - Check each BCD digit (hundreds, tens, ones) - if ≥ 5, add 3
   - Shift the entire combined register left by 1 position
   - Update BCD and shift register from the combined result
3. Final BCD output contains the decimal representation

## Folder Structure

```
doubble_dabble/
├── binary_to_bcd.sv                      
├── tb_binary_to_bcd.sv                   
├── documentation/
│   └── truthtable
│   └── signal_description.txt
│   └── waves 
└── README.md                             
```

## How to Run

### Prerequisites
- SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

#### Using ModelSim/QuestaSim:
```bash
# Compile the design and testbench
vlog binary_to_bcd.sv tb_binary_to_bcd.sv

# Start simulation
vsim tb_binary_to_bcd

# Run the simulation
run -all
```

#### Using Vivado:
```bash
# Create new project and add source files
# Set tb_binary_to_bcd as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests various input values and stops after completion.

## Examples

### Test Case 1: Zero Input
- **Input**: binary_in = 8'd0 (8'b00000000)
- **Expected Output**: bcd_out = 12'h000 (000 in BCD)

### Test Case 2: Single Digit
- **Input**: binary_in = 8'd9 (8'b00001001)
- **Expected Output**: bcd_out = 12'h009 (009 in BCD)

### Test Case 3: Two Digits
- **Input**: binary_in = 8'd45 (8'b00101101)
- **Expected Output**: bcd_out = 12'h045 (045 in BCD)

### Test Case 4: Two Digits Max
- **Input**: binary_in = 8'd99 (8'b01100011)
- **Expected Output**: bcd_out = 12'h099 (099 in BCD)

### Test Case 5: Three Digits
- **Input**: binary_in = 8'd123 (8'b01111011)
- **Expected Output**: bcd_out = 12'h123 (123 in BCD)

### Test Case 6: Maximum Value
- **Input**: binary_in = 8'd255 (8'b11111111)
- **Expected Output**: bcd_out = 12'h255 (255 in BCD)