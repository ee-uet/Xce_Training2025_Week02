 ############################################## Asynchronous FIFO ########################################

This module implements an Asynchronous FIFO with independent write and read clock domains. It uses binary and Gray-coded pointers for safe cross-domain synchronization and generates status flags for flow control.

##Features

Parameterized Depth (DEPTH) and Data Width (DATA_WIDTH).

Separate write clock (clk_wr) and read clock (clk_rd) domains.

Safe reset synchronization in both domains.

Gray code pointers with 3-FF synchronizers for metastability protection.

FIFO status flags:

fifo_empty

fifo_full

fifo_almost_full (≤ 2 slots left)

fifo_almost_empty (≤ 1 slot left)

Internal function gray2bin for Gray → Binary conversion.

Handles clock domain crossing (CDC) safely.

Interfaces

##Inputs

write_enable: Enable write operation.

read_enable: Enable read operation.

clk_wr: Write domain clock.

clk_rd: Read domain clock.

rst: Asynchronous reset.

data_in [DATA_WIDTH-1:0]: Data to be written.

##Outputs

data_out [DATA_WIDTH-1:0]: Data read from FIFO.

fifo_empty: FIFO is empty.

fifo_full: FIFO is full.

fifo_almost_full: FIFO is almost full.

fifo_almost_empty: FIFO is almost empty.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah