8-Bit Arithmetic Logic Unit (ALU) Module
Overview
The alu_8bit module is a Verilog implementation of an 8-bit Arithmetic Logic Unit (ALU). It performs arithmetic and logical operations on two 8-bit inputs (a and b) based on a 3-bit operation selector (op_sel). The module outputs an 8-bit result and three status flags: zero, carry, and overflow.
Features

Inputs:
a (8-bit): First operand.
b (8-bit): Second operand.
op_sel (3-bit): Selects the operation to perform.


Outputs:
result (8-bit): Result of the operation.
zero: Set to 1 if the result is zero.
carry: Carry-out for arithmetic operations (addition/subtraction).
overflow: Indicates overflow in arithmetic operations.



Operations
The ALU supports the following operations based on op_sel:



op_sel
Operation
Description



000
Addition
result = a + b


001
Subtraction
result = a - b


010
Bitwise AND
result = a & b


011
Bitwise OR
`result = a


100
Bitwise XOR
result = a ^ b


101
Bitwise NOT
result = ~a (ignores b)


110
Left Shift
result = a << b[2:0]


111
Right Shift
result = a >> b[2:0]


Implementation Details

Module Structure:
Uses always_comb for combinational logic, ensuring immediate response to input changes.
A case statement selects the operation based on op_sel.
Default case sets result = 0 for undefined op_sel values.


Flags:
zero: Set when result == 0.
carry: Set for addition/subtraction, representing carry-out or borrow.
overflow: Calculated for addition ((~a[7] & ~b[7] & result[7]) | (a[7] & b[7] & ~result[7])) and subtraction ((~a[7] & b[7] & result[7]) | (a[7] & ~b[7] & ~result[7])).


Shift Operations:
Use only the lower მო�



System: 3 bits (b[2:0]) of the second operand for shift amount.
Edge Cases

Overflow in Arithmetic Operations:
Addition: Overflow occurs when two positive numbers yield a negative result or two negative numbers yield a positive result.
Subtraction: Overflow occurs when a positive number minus a negative number yields a negative result, or vice versa.


Shift Amount:
For shift operations (op_sel = 110 or 111), only the lower 3 bits of b are used (b[2:0]). If b[2:0] > 7, the shift amount exceeds the 8-bit width, resulting in result = 0 (all bits shifted out).


Undefined Operation:
If op_sel is outside the range 0-7, the result defaults to 8'b0.


NOT Operation:
The b input is ignored for op_sel = 5 (NOT operation), as it only uses a.
