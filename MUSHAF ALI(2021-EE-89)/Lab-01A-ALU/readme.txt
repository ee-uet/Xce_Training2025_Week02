######################################################### 8-bit ALU  ##########################3

##Overview

This project implements an 8-bit Arithmetic Logic Unit (ALU) in SystemVerilog. The ALU performs common arithmetic and logical operations on two 8-bit inputs (A, B) and generates status flags (zero, carry, overflow).

##Features

##Inputs:

A, B → 8-bit operands

op_sel → 3-bit operation selector

##Outputs:

y → 8-bit result

zero → High if result = 0

carry → Carry flag for addition/subtraction

overflow → Signed overflow flag

##Operations (op_sel)

000 → AND (A & B)

001 → OR (A | B)

010 → XOR (A ^ B)

011 → NOT (~A)

100 → ADD (A + B)

101 → SUB (A - B)

110 → Shift Left (A << B[2:0])

111 → Shift Right (A >> B[2:0])

##Example

Input: A=8'b01100100 (100), B=8'b00000011 (3), op_sel=100

Operation: 100 → ADD

Output: y=103, carry=0, overflow=0, zero=0



################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah

