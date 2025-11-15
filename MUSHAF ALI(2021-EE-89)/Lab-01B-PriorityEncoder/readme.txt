 ############################################################## 8-to-3 Priority Encoder ####################################333

##Overview

This project implements an 8-to-3 Priority Encoder in SystemVerilog. The encoder checks an 8-bit input (in) and outputs the highest-priority active bit’s index. Bit 7 has the highest priority, and bit 0 the lowest. The circuit also provides a valid flag and supports an enable input.

##Features

##Inputs:

enable → Enables the encoder

in[7:0] → 8-bit input (bit 7 = highest priority)

Outputs:

out[2:0] → Encoded index of the highest-priority 1

valid → High if at least one input bit is 1

##Operation

If enable = 0 → Output remains 000, valid = 0.

If enable = 1:

##Example: in = 8'b00101000 → Output = 101 (index 5), valid = 1.

##Example: in = 8'b00000000 → Output = xxx, valid = 0.

##Priority Order

in[7] > in[6] > in[5] > in[4] > in[3] > in[2] > in[1] > in[0]


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah
