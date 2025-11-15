############################################################## Binary to BCD Converter #################################################

##Overview

This project implements an 8-bit Binary to BCD (Binary Coded Decimal) converter using the Double Dabble (Shift-and-Add-3) algorithm in SystemVerilog.
The converter takes an 8-bit binary number (0–255) as input and produces a 12-bit BCD output (hundreds, tens, and units).

##Features

Supports full 8-bit range (0–255).

Uses combinational logic (always_comb).

Implements the standard double dabble algorithm.

##Output format:

bcd[11:8] → Hundreds

bcd[7:4] → Tens

bcd[3:0] → Units

##How it Works

Initialize BCD to 0.

Loop through 8 binary bits.

For each BCD digit ≥ 5, add 3.

Shift BCD left, inserting the MSB of the binary input.

Repeat until all 8 bits are processed.

##Usage

Instantiate the module in your design:

bin_to_bcd converter (
    .bin(binary_input),
    .bcd(bcd_output)
);


##Example:

Input: bin = 8'b01100100 (100)

Output: bcd = 12'b0001_0000_0000 → Hundreds=1, Tens=0, Units=0




################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah