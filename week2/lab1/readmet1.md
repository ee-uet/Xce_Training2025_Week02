# 8-bit ALU

## Introduction
This document describes an **8-bit Arithmetic Logic Unit (ALU)** implemented in SystemVerilog.  
The unit accepts two signed 8-bit operands (A, B), a 3-bit operation select (`op_sel`), and produces an 8-bit result with three status flags: **Zero (zero)**, **Carry (carry)**, and **Overflow (overflow)**.  
The ALU is purely combinational and is suitable for single-cycle datapaths on FPGAs.

---



### Inputs
- **A, B**: signed [7:0] operands  
- **op_sel**: [2:0] operation select  

### Outputs
- **result**: [7:0] ALU result  
- **zero**: 1 when result == 8'h00  
- **carry**: operation-dependent (see below)  
- **overflow**: signed overflow indicator for ADD/SUB  

---
## Diagram:
![alt text](image-1.png)
---
## Operation Encoding

| op_sel | Operation | Result Expression | Flags Used |
|--------|-----------|-------------------|------------|
| 000    | ADD       | `sum = {0,A} + {0,B}; result = sum[7:0]` | carry = sum[8]; overflow; zero |
| 001    | AND       | `result = A & B`  | zero |
| 010    | OR        | `result = A | B`  | zero |
| 011    | XOR       | `result = A ^ B`  | zero |
| 100    | SUB       | `sub = {0,A} - {0,B}; result = ~sub[7:0]` | carry = sub[8]; overflow; zero |
| 101    | NOT       | `result = ~A`     | zero |
| 110    | SLL       | `result = A << B` | zero |
| 111    | SRL       | `result = A >> B` | zero |

---

## Operation Descriptions

### 1. ADD (`op_sel=000`)
- Unsigned and signed addition of A and B.  
- The 9th bit (`sum[8]`) is exposed as carry.  
- Signed overflow is detected when `A[7]` and `B[7]` are equal and differ from `result[7]`.

**1-bit ADD (no carry-in) truth table**

| A | B | Sum (= A ^ B) | Carry (= A · B) |
|---|---|----------------|------------------|
| 0 | 0 | 0              | 0                |
| 0 | 1 | 1              | 0                |
| 1 | 0 | 1              | 0                |
| 1 | 1 | 0              | 1                |

---

### 2. AND (`001`)
- Bitwise conjunction. Useful for masking.  
- Flags: zero reflects whether the result is all zeros.

| A | B | A & B |
|---|---|-------|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

---

### 3. OR (`010`)
- Bitwise inclusive OR. Useful for setting bits.  
- Flags: zero only.

| A | B | A \| B |
|---|---|--------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

---

### 4. XOR (`011`)
- Bitwise exclusive OR. Useful for parity/toggling.  
- Flags: zero only.

| A | B | A ^ B |
|---|---|-------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

---

### 5. SUB (`100`)
- Computes `result = A - B`.  
- Implemented in hardware as `A + (~B + 1)` (two’s complement subtraction).  
- **carry** = indicates borrow (1 = no borrow, 0 = borrow occurred).  
- **overflow** = `(A[7] != B[7]) && (result[7] != A[7])`.  

**1-bit SUB (no borrow-in) truth table**

| A | B | Diff (= A ⊕ B) | Borrow (= ¬A · B) |
|---|---|----------------|-------------------|
| 0 | 0 | 0              | 0                 |
| 0 | 1 | 1              | 1                 |
| 1 | 0 | 1              | 0                 |
| 1 | 1 | 0              | 0                 |


### 6. NOT (`101`)
- Unary bitwise inversion of A.  
- B is ignored.  
- Flags: zero only.

| A | ~A |
|---|----|
| 0 | 1 |
| 1 | 0 |

---

### 7. SLL (`110`)
- Logical left shift by variable amount B.  
- Bits shift toward MSB; zeros fill LSBs.  
- Large shift amounts (B ≥ 8) drive result to zero.  
- Only the zero flag is set.

---

### 8. SRL (`111`)
- Logical right shift by variable amount B.  
- Bits shift toward LSB; zeros fill MSBs.  
- Only the zero flag is set.

---

## Status Flags

| Flag     | Set in   | Rule |
|----------|----------|------|
| zero     | All ops  | 1 when result == 8'h00 |
| carry    | ADD, SUB | ADD: `sum[8]`; SUB: `sub[8]` (borrow indicator) |
| overflow | ADD, SUB | ADD: `(A[7] == B[7]) && (result[7] != A[7])`; SUB: `(A[7] != B[7]) && (result[7] != A[7])` |


---

## More 

## Problem
Design and document an 8-bit ALU that supports arithmetic and logic operations, produces status flags.

---

## Approach
- Purely combinational design.  
- 8 operations (ADD, AND, OR, XOR, SUB, NOT, SLL, SRL).  
- Carry and overflow detection included for ADD/SUB.  
- Verified operations using 1-bit truth tables and edge-case examples.

---
## Examples

### Example 1: ADD
A = 8'h05 (00000101)  
B = 8'h03 (00000011)  
op_sel = `000` (ADD)  

**Result:** 8'h08 (00001000)  
**Flags:** zero=0, carry=0, overflow=0  

---

### Example 2: SUB
A = 8'h01 (00000001)  
B = 8'h03 (00000011)  
op_sel = `100` (SUB)  

**Result:** (A + (− B)) =  11111110
**Flags:** zero=0, carry=0 (borrow), overflow=0  

---

### Example 3: AND
A = 8'hF0 (11110000)  
B = 8'h0F (00001111)  
op_sel = `001` (AND)  

**Result:** 00000000  
**Flags:** zero=1, carry=0, overflow=0  

---

### Example 4: OR
A = 8'hA0 (10100000)  
B = 8'h0A (00001010)  
op_sel = `010` (OR)  

**Result:** 10101010  
**Flags:** zero=0, carry=0, overflow=0  

---

### Example 5: XOR
A = 8'hFF (11111111)  
B = 8'h0F (00001111)  
op_sel = `011` (XOR)  

**Result:** 11110000  
**Flags:** zero=0, carry=0, overflow=0  

---

### Example 6: NOT
A = 8'h0F (00001111)  
B = ignored  
op_sel = `101` (NOT)  

**Result:** 11110000  
**Flags:** zero=0, carry=0, overflow=0  

---

### Example 7: SLL (Shift Left Logical)
A = 8'h01 (00000001)  
B = 2  
op_sel = `110` (SLL)  

**Result:** 00000100  
**Flags:** zero=0, carry=0, overflow=0  

---

### Example 8: SRL (Shift Right Logical)
A = 8'h80 (10000000)  
B = 3  
op_sel = `111` (SRL)  

**Result:** 00010000  
**Flags:** zero=0, carry=0, overflow=0  


## AI Usage
- Used AI to assist with indentation and formatting.  
- Verified correctness of operations, truth tables.  
- Converted the initial Word-format documentation into a Markdown README with AI guidance.  

