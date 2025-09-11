# Programmable Counter - Lab 3

## Problem Description

This lab implements an 8-bit programmable counter with bidirectional counting capability, programmable load functionality, and configurable maximum count value. The counter can count up or down, load preset values, wrap around at programmable limits, and provides status flags for terminal count and zero detection. This type of counter is commonly used in digital systems for timing, sequencing, and control applications where flexible counting behavior is required.

## Approach

The programmable counter is implemented using **sequential logic** with the following key components:

- **Clocked Register**: Uses `always_ff` for synchronous counting with asynchronous reset
- **Priority Control Logic**: Reset has highest priority, followed by load, then enable
- **Bidirectional Counting**: `up_down` signal controls increment/decrement operation
- **Wraparound Logic**: Automatic wrapping at boundaries (0 and max_count)
- **Status Flag Generation**: Combinational logic for terminal count and zero detection

The design follows a clear priority hierarchy:
1. **Reset**: Asynchronous reset to 0 (highest priority)
2. **Load**: Synchronous load of preset value
3. **Enable**: Controls counting operation when active
4. **Hold**: Maintains current count when enable is inactive

## Folder Structure

```
lab3/
├── programmable_counter.sv              
├── tb_programmable_counter.sv            
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
vlog programmable_counter.sv tb_programmable_counter.sv

# Start simulation
vsim tb_programmable_counter

# Run the simulation
run -all
```

#### Using Vivado:
```bash
# Create new project and add source files
# Set tb_programmable_counter as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests reset, load, up counting, down counting, and hold operations with a 10ns clock period.

## Examples

### Test Case 1: Reset Operation
- **Input**: rst_n = 0 (for 20ns)
- **Expected Output**: count = 0, tc = 0, zero = 1

### Test Case 2: Load Operation
- **Input**: load = 1, load_value = 8'd5, max_count = 8'd10
- **Expected Output**: count = 5, tc = 0, zero = 0

### Test Case 3: Count Up Operation
- **Input**: enable = 1, up_down = 1, max_count = 8'd10
- **Expected Behavior**: 
  - Count: 5 → 6 → 7 → 8 → 9 → 10 → 0 → 1... (wraps at max_count)
  - tc = 1 when count = 10, zero = 1 when count = 0

### Test Case 4: Count Down Operation
- **Input**: enable = 1, up_down = 0
- **Expected Behavior**:
  - Count: current → current-1 → ... → 1 → 0 → 10 → 9... (wraps to max_count)
  - zero = 1 when count = 0, tc = 1 when count = 10

### Test Case 5: Hold Operation
- **Input**: enable = 0
- **Expected Output**: count maintains its current value regardless of other inputs