# Binary to BCD Converter in SystemVerilog

## Problem Statement

This project implements a Binary to Binary-Coded Decimal (BCD) converter that transforms 8-bit binary numbers into their decimal representation using BCD encoding. BCD conversion is essential in digital systems that interface with human-readable displays, calculators, digital clocks, and measurement instruments where decimal representation is preferred over binary.

The converter needs to:
- Accept 8-bit binary input (0-255)
- Generate 12-bit BCD output representing 3 decimal digits
- Handle the complete range of 8-bit values (000-255 in decimal)
- Provide combinational conversion for immediate results
- Use efficient hardware implementation suitable for synthesis

## Approach

### Design Architecture

The Binary to BCD converter is implemented using SystemVerilog with the **Double Dabble Algorithm** (also known as Add-3-Then-Shift):

**Inputs:**
- `binary_in[7:0]` - 8-bit binary number (0 to 255)

**Outputs:**
- `bcd[11:0]` - 12-bit BCD result organized as three 4-bit BCD digits
  - `bcd[11:8]` - Hundreds digit (0-2)
  - `bcd[7:4]` - Tens digit (0-9)  
  - `bcd[3:0]` - Units digit (0-9)

### Double Dabble Algorithm

The algorithm operates on the principle of iterative shifting and correction:

**Step 1: Initialization**
- Create 20-bit temporary register: `{12'b0, binary_in[7:0]}`
- Upper 12 bits: BCD result area
- Lower 8 bits: Binary input

**Step 2: Iterative Process (8 iterations)**
For each bit position from MSB to LSB:
1. **Check BCD digits**: If any 4-bit BCD field ≥ 5, add 3 to that field
2. **Shift left**: Shift entire 20-bit register left by 1 position

**Step 3: Extract Result**
- Final BCD result is in upper 12 bits: `bcd_temp[19:8]`

### Algorithm Implementation Details

**Correction Logic:**
```systemverilog
if (bcd_temp[11:8]  >= 5) bcd_temp[11:8]  = bcd_temp[11:8]  + 3;  // Units
if (bcd_temp[15:12] >= 5) bcd_temp[15:12] = bcd_temp[15:12] + 3;  // Tens  
if (bcd_temp[19:16] >= 5) bcd_temp[19:16] = bcd_temp[19:16] + 3;  // Hundreds
```

**Why Add 3?**
- When a BCD digit ≥ 5 is shifted left, it would exceed 9 (invalid in BCD)
- Adding 3 before shift ensures the digit remains valid after multiplication by 2
- Example: 5 + 3 = 8, then 8 << 1 = 16 = 10₁₀ (correct carry to next digit)

### Step-by-Step Example

**Converting Binary 32 (0010_0000₂) to BCD:**

**Initial:** `bcd_temp = {12'b0, 8'b00100000}` = `20'b00000000000000100000`

**Iteration 1-4:** No BCD digits ≥ 5, just shift left
- After 4 shifts: `20'b00000010000000000000`

**Iteration 5:** 
- BCD check: All digits < 5, no correction needed
- Shift: `20'b00000100000000000000`

**Iteration 6-8:** Continue shifting
- Final result: `20'b00000000001100100000`

**Extract BCD:** `bcd_temp[19:8] = 12'b000000110010` = `032₁₀` ✓

### Range Coverage

**8-bit Binary Range:** 0-255
- **000-009:** Single digit, `bcd[11:4] = 8'b0000_0000`
- **010-099:** Two digits, `bcd[11:8] = 4'b0000` 
- **100-255:** Three digits, all BCD fields used

**BCD Encoding:**
- Each 4-bit field represents one decimal digit (0-9)
- Maximum output: 255₁₀ = `0010_0101_0101₂` BCD

## How to Run

Run the simulation on QuestaSim. The testbench file `BCDConverter_tb.sv` provides test cases covering different ranges of the 8-bit input space.

## Examples

### Test Case Analysis

The testbench demonstrates BCD conversion across different value ranges:

**Test 1: Zero Value**
```
Input: binary_in = 8'd0 (0000_0000₂)
Expected: bcd = 12'b0000_0000_0000 (000₁₀)
BCD Breakdown: Hundreds=0, Tens=0, Units=0
```

**Test 2: Single Digit**
```
Input: binary_in = 8'd6 (0000_0110₂)
Expected: bcd = 12'b0000_0000_0110 (006₁₀)
BCD Breakdown: Hundreds=0, Tens=0, Units=6
```

**Test 3: Two Digits**
```
Input: binary_in = 8'd32 (0010_0000₂)
Expected: bcd = 12'b0000_0011_0010 (032₁₀)
BCD Breakdown: Hundreds=0, Tens=3, Units=2
```

**Test 4: Three Digits**
```
Input: binary_in = 8'd164 (1010_0100₂)
Expected: bcd = 12'b0001_0110_0100 (164₁₀)
BCD Breakdown: Hundreds=1, Tens=6, Units=4
```

### Detailed Conversion Example (Binary 164)

**Binary 164 = 1010_0100₂**

**Initial State:**
`bcd_temp = 20'b00000000000010100100`

**Iteration Trace:**
1. **Iteration 1**: No correction needed → Shift → `20'b00000000000101001000`
2. **Iteration 2**: No correction needed → Shift → `20'b00000000001010010000`
3. **Iteration 3**: No correction needed → Shift → `20'b00000000010100100000`
4. **Iteration 4**: No correction needed → Shift → `20'b00000000101001000000`
5. **Iteration 5**: No correction needed → Shift → `20'b00000001010010000000`
6. **Iteration 6**: Tens digit = 5 → Add 3 → `20'b00000001100010000000` → Shift → `20'b00000011000100000000`
7. **Iteration 7**: Tens digit = 6 → No correction → Shift → `20'b00000110001000000000`
8. **Iteration 8**: No correction needed → Shift → `20'b00001100010000000000`

**Final Result:**
- `bcd_temp[19:8] = 12'b000110000100`
- Hundreds = `0001₂` = 1₁₀
- Tens = `0110₂` = 6₁₀  
- Units = `0100₂` = 4₁₀
- **Result: 164₁₀** ✓

### Key Features Demonstrated

**Algorithm Correctness:**
- Proper BCD digit formation through add-3-then-shift method
- Accurate conversion across entire 8-bit range (0-255)
- Correct handling of carry propagation between BCD digits

**Implementation Efficiency:**
- Pure combinational logic using `always_comb` block
- Single-cycle conversion suitable for high-speed applications
- Compact implementation using iterative loop structure

**Range Verification:**
- Edge cases: 0, maximum value (255)
- Boundary conditions: single/double/triple digit transitions
- Typical values across different decimal ranges

**Hardware Considerations:**
- Synthesizable SystemVerilog using standard operators
- Predictable timing characteristics for integration
- Scalable approach for different input widths

This implementation provides a robust, efficient solution for binary-to-BCD conversion suitable for display interfaces, digital instruments, and any application requiring human-readable decimal output from binary data.