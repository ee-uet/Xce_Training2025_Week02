############################################# Synchronous FIFO #####################################

This module implements a Synchronous FIFO where both read and write operations share the same clock domain. It supports configurable depth and data width with status flag generation for flow control.

##Features

Parameterized Depth (DEPTH) and Data Width (DATA_WIDTH).

Single clock (clk) for both read and write operations.

##FIFO status flags:

fifo_empty

fifo_full

fifo_almost_full (based on threshold)

fifo_almost_empty (based on threshold)

Wrap-around pointer logic using modulo (% DEPTH), works for power-of-2 and arbitrary depths.

Occupancy counter to track the number of stored elements.

Interfaces

##Inputs

clk : System clock.

rst : Active-high synchronous reset.

write_enable : Enable signal for writing data.

read_enable : Enable signal for reading data.

data_in [DATA_WIDTH-1:0] : Input data to be written.

##Outputs

data_out [DATA_WIDTH-1:0] : Data read from FIFO.

fifo_empty : FIFO has no data.

fifo_full : FIFO is completely filled.

fifo_almost_full : FIFO is close to full (≤ threshold space left).

fifo_almost_empty : FIFO is close to empty (≤ threshold data left).


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah