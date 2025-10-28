# 8-to-3 Priority Encoder in SystemVerilog

## Problem Statement

This project implements an 8-to-3 Priority Encoder that identifies the highest priority (most significant bit) set in an 8-bit input vector and outputs its corresponding 3-bit binary position. Priority encoders are essential components in digital systems for interrupt handling, arbitration circuits, leading zero detection, and resource allocation where multiple requests need to be prioritized.

The priority encoder needs to:
- Accept 8-bit input data representing priority requests or conditions
- Identify the highest priority bit (MSB has highest priority)
- Output a 3-bit encoded position of the highest priority active bit
- Generate a valid signal indicating if any input bit is active
- Support enable/disable functionality for system control
- Handle the case where no inputs are active (all zeros)

## Approach

### Design Architecture

The 8-to-3 Priority Encoder is implemented using SystemVerilog with the following specifications:

**Inputs:**
- `enable` - Enable signal for encoder operation
- `data_in[7:0]` - 8-bit input vector with priority bits

**Outputs:**
- `encoded_out[2:0]` - 3-bit encoded output representing bit position
- `valid` - Valid signal indicating at least one input bit is active

### Priority Scheme

The encoder uses **highest bit priority** where bit 7 has the highest priority and bit 0 has the lowest priority:

| Input Bit | Priority Level | Encoded Output |
|-----------|----------------|----------------|
| data_in[7] | Highest (7)   | 3'b111 |
| data_in[6] | 6             | 3'b110 |
| data_in[5] | 5             | 3'b101 |
| data_in[4] | 4             | 3'b100 |
| data_in[3] | 3             | 3'b011 |
| data_in[2] | 2             | 3'b010 |
| data_in[1] | 1             | 3'b001 |
| data_in[0] | Lowest (0)    | 3'b000 |

### Implementation Method

**Casez Statement Approach:**
The design uses `casez` statement with don't-care (`?`) wildcards for efficient priority encoding:

```systemverilog
casez (data_in)
    8'b1???????:  encoded_out = 3'b111;  // Bit 7 active (highest priority)
    8'b01??????:  encoded_out = 3'b110;  // Bit 6 active, bit 7 inactive
    8'b001?????:  encoded_out = 3'b101;  // Bit 5 active, bits 7:6 inactive
    // ... and so on
    8'b00000001:  encoded_out = 3'b000;  // Only bit 0 active (lowest priority)
    default:      encoded_out = 0;       // No bits active
endcase
```

**Don't-Care Logic:**
- `?` represents don't-care conditions for lower priority bits
- When a higher priority bit is found, lower bits are ignored
- Ensures highest priority bit always takes precedence

**Enable Control:**
- When `enable = 0`: outputs are forced to zero regardless of inputs
- When `enable = 1`: normal priority encoding operation
- Provides system-level control for conditional operation

**Valid Signal Generation:**
- `valid = 1`: At least one input bit is active and encoder is enabled
- `valid = 0`: No input bits active or encoder is disabled
- Essential for downstream logic to determine if output is meaningful

## How to Run

Run the simulation on QuestaSim. The testbench file `PriorityEncoder823_m_tb.sv` demonstrates various input combinations and encoder behavior including enable control and edge cases.

## Examples

### Test Case Analysis

The testbench demonstrates comprehensive priority encoder operation:

**Test 1: Encoder Disabled**
```
Input: enable = 0, data_in = 8'b10101010
Expected: encoded_out = 3'b000, valid = 0
Result: Encoder disabled, outputs forced to zero regardless of input
```

**Test 2: Single Bit Active (Bit 4)**
```
Input: enable = 1, data_in = 8'b00010000
Expected: encoded_out = 3'b100, valid = 1
Analysis: Only bit 4 is active, so position 4 is encoded as 3'b100
```

**Test 3: Multiple Bits Active (Priority Resolution)**
```
Input: enable = 1, data_in = 8'b01011000
Binary breakdown: 0-1-0-1-1-0-0-0
Active bits: 6, 4, 3
Expected: encoded_out = 3'b110, valid = 1
Analysis: Bit 6 has highest priority among active bits, encoded as 3'b110
```

**Test 4: No Bits Active**
```
Input: enable = 1, data_in = 8'b00000000
Expected: encoded_out = 3'b000, valid = 0
Result: No active inputs, valid signal indicates invalid output
```

### Detailed Priority Resolution Example

**For Test 3 (data_in = 8'b01011000):**

**Step-by-step Casez Evaluation:**
1. `8'b1???????`: No match (bit 7 = 0)
2. `8'b01??????`: **Match!** (bit 6 = 1, bit 7 = 0)
   - Result: `encoded_out = 3'b110`, `valid = 1`
   - Lower priority bits (4, 3) are ignored

**Priority Verification:**
- Bit positions active: 6, 4, 3
- Highest priority: Bit 6 (position 6)
- Encoded output: 6₁₀ = 110₂ ✓
- Other active bits (4, 3) correctly ignored

### Truth Table Examples

| data_in[7:0] | Highest Active Bit | encoded_out | valid | Description |
|--------------|-------------------|-------------|-------|-------------|
| 10000000     | 7                 | 111         | 1     | MSB priority |
| 01000000     | 6                 | 110         | 1     | Second highest |
| 00100000     | 5                 | 101         | 1     | Third highest |
| 11111111     | 7                 | 111         | 1     | MSB wins all |
| 00000001     | 0                 | 000         | 1     | LSB only |
| 00000000     | None              | 000         | 0     | No active bits |

### Timing Characteristics

**Combinational Logic:**
- Pure combinational implementation using `always_comb`
- Zero clock delay, immediate response to input changes
- Propagation delay: Single level of logic (casez evaluation)

**Enable Response:**
- Immediate disable when `enable = 0`
- Instant enable when `enable = 1`
- No clock dependency for enable control

### Key Features Demonstrated

**Priority Resolution:**
- Correct identification of highest priority active bit
- Proper masking of lower priority bits
- Consistent behavior across all input combinations

**Enable Control:**
- Clean disable functionality with zero outputs
- Immediate response to enable signal changes
- System-level integration capability

**Edge Case Handling:**
- Proper response to all-zero input (valid = 0)
- Correct behavior when all bits are active (MSB priority)
- Single bit activation scenarios

**Output Validity:**
- Valid signal accurately reflects meaningful output
- Clear indication of encoder state
- Essential for downstream decision logic

### Applications

**Interrupt Controllers:**
- Highest priority interrupt identification
- Nested interrupt handling
- System resource arbitration

**Memory Systems:**
- Cache line replacement algorithms
- Memory bank selection
- Address decoding with priority

**Communication Systems:**
- Channel arbitration in multi-channel systems
- Priority-based packet scheduling
- Resource allocation in network switches

This implementation provides a robust, efficient priority encoder suitable for various digital system applications requiring priority-based selection and arbitration functionality.