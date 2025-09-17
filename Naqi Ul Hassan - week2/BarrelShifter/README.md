# 32-bit Barrel Shifter in SystemVerilog

## Problem Statement

This project implements a 32-bit barrel shifter that performs fast bit shifting and rotation operations in a single clock cycle. Barrel shifters are essential components in processors and digital signal processing units where efficient bit manipulation is required for arithmetic operations, data packing/unpacking, and algorithm implementations.

The barrel shifter needs to:
- Support both left and right directional shifts/rotations
- Handle shift amounts from 0 to 31 bits
- Perform both logical shifts (filling with zeros) and rotations (circular shifts)
- Complete operations in combinational logic for single-cycle execution
- Provide flexible control for different operation modes

## Approach

### Design Architecture

The 32-bit barrel shifter is implemented using SystemVerilog with a 5-stage combinational design:

**Inputs:**
- `data_in[31:0]` - 32-bit input data to be shifted
- `shift_amt[4:0]` - 5-bit shift amount (0-31 positions)
- `left_right` - Direction control (0=left, 1=right)
- `shift_rotate` - Operation mode (0=shift with zeros, 1=rotate/circular)

**Output:**
- `data_out[31:0]` - 32-bit result after shift/rotate operation

### Multi-Stage Implementation

The barrel shifter uses a 5-stage approach where each stage handles one bit of the shift amount:

**Stage 0 (shift_amt[0]):** 1-bit shift
- Left shift: `{data_in[30:0], fill_bit}`
- Right shift: `{fill_bit, data_in[31:1]}`
- Fill bit: `data_in[31]` (rotate) or `1'b0` (shift)

**Stage 1 (shift_amt[1]):** 2-bit shift
- Operates on Stage 0 output
- Left: `{stage0[29:0], fill_bits[1:0]}`
- Right: `{fill_bits[1:0], stage0[31:2]}`

**Stage 2 (shift_amt[2]):** 4-bit shift
- Operates on Stage 1 output
- Similar pattern with 4-bit granularity

**Stage 3 (shift_amt[3]):** 8-bit shift
- Operates on Stage 2 output
- 8-bit granularity operations

**Stage 4 (shift_amt[4]):** 16-bit shift
- Final stage operating on Stage 3 output
- 16-bit granularity for MSB control

### Operation Modes

**Logical Left Shift (left_right=0, shift_rotate=0):**
- Shifts bits left, fills LSBs with zeros
- `data_out = data_in << shift_amt`

**Logical Right Shift (left_right=1, shift_rotate=0):**
- Shifts bits right, fills MSBs with zeros
- `data_out = data_in >> shift_amt`

**Left Rotation (left_right=0, shift_rotate=1):**
- Circular left shift, MSBs wrap to LSBs
- `data_out = (data_in << shift_amt) | (data_in >> (32-shift_amt))`

**Right Rotation (left_right=1, shift_rotate=1):**
- Circular right shift, LSBs wrap to MSBs
- `data_out = (data_in >> shift_amt) | (data_in << (32-shift_amt))`

### Design Advantages

**Single Cycle Operation:**
- Pure combinational logic eliminates clock dependency
- All operations complete in one combinational delay
- Suitable for pipelined processor integration

**Hierarchical Structure:**
- Each stage handles specific bit positions
- Scalable design for different word sizes
- Easy verification and debugging

**Control Flexibility:**
- Independent direction and mode control
- Supports all common shift/rotate operations
- Simple interface for integration

## How to Run

Run the simulation on QuestaSim. The testbench file `BarrelShifter_tb.sv` contains test cases demonstrating various shift and rotation operations.

## Examples

### Test Case Analysis

The testbench includes the following comprehensive test scenarios:

**Test 1: Left Logical Shift by 1**
```
Input: data_in = 0x8000_0001, shift_amt = 1, left_right = 0, shift_rotate = 0
Expected: data_out = 0x0000_0002
Operation: Left shift by 1, MSB discarded, LSB filled with 0
```

**Test 2: Left Rotation by 1**
```
Input: data_in = 0x8000_0001, shift_amt = 1, left_right = 0, shift_rotate = 1
Expected: data_out = 0x0000_0003
Operation: Left rotate by 1, MSB (1) wraps to LSB position
```

**Test 3: Right Rotation by 2**
```
Input: data_in = 0x0000_0003, shift_amt = 2, left_right = 1, shift_rotate = 1
Expected: data_out = 0xC000_0000
Operation: Right rotate by 2, LSBs (11) wrap to MSB positions
```

**Test 4: Left Logical Shift by 8**
```
Input: data_in = 0x1234_5678, shift_amt = 8, left_right = 0, shift_rotate = 0
Expected: data_out = 0x3456_7800
Operation: Left shift by 8, equivalent to multiplying by 256
```

**Test 5: Left Rotation by 8**
```
Input: data_in = 0x1234_5678, shift_amt = 8, left_right = 0, shift_rotate = 1
Expected: data_out = 0x3456_7812
Operation: Left rotate by 8, upper byte (0x12) wraps to lower byte
```

### Stage-by-Stage Operation Example

**For Test 1 (0x8000_0001, left shift by 1):**

- **Stage 0**: shift_amt[0] = 1, left shift → `{0x8000_0001[30:0], 1'b0}` = `0x0000_0002`
- **Stage 1**: shift_amt[1] = 0, no operation → `0x0000_0002`
- **Stage 2**: shift_amt[2] = 0, no operation → `0x0000_0002`
- **Stage 3**: shift_amt[3] = 0, no operation → `0x0000_0002`
- **Stage 4**: shift_amt[4] = 0, no operation → `0x0000_0002`
- **Final**: data_out = `0x0000_0002`

### Timing Characteristics

**Combinational Delay:**
- Total propagation delay: 5 stages of multiplexer delays
- No clock dependency - purely combinational
- Typical delay: 2-3ns in modern FPGA/ASIC technology

**Resource Utilization:**
- 32 × 5 = 160 multiplexers (2:1 each)
- Minimal area overhead for high performance
- Suitable for area-constrained designs

### Key Features Demonstrated

**Versatility:**
- Supports all common shift/rotate operations in single design
- Configurable operation mode through control signals
- Full 32-bit word processing capability

**Performance:**
- Single-cycle operation for maximum throughput
- No pipeline stalls or multi-cycle dependencies
- Ideal for high-frequency processor designs

**Correctness:**
- Proper handling of edge cases (zero shift, maximum shift)
- Accurate bit positioning across all shift amounts
- Correct wrap-around behavior for rotation operations

This implementation provides an efficient, high-performance barrel shifter suitable for integration into arithmetic logic units, digital signal processors, and general-purpose processors requiring fast bit manipulation capabilities.