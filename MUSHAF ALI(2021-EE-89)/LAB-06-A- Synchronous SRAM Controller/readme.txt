###################################################### SRAM Controller #############################################

This module implements a Finite State Machine (FSM)-based controller for interfacing a CPU with an SRAM memory device. It handles read and write operations, address setup, and data bus direction using a tri-state bus.

##Features

Supports read and write transactions.

##FSM with 4 states:

IDLE: Waits for CPU request.

ADDRESS_SETUP: Places address on SRAM bus.

ACCESS_WAIT: Provides access delay before data transfer.

CAPTURE_HOLD: Completes the transaction, captures read data or writes to SRAM.

Handles tri-state data bus (sram_data) correctly:

High-Z for reads (SRAM → CPU).

Driven by CPU for writes (CPU → SRAM).

Uses a wait counter to simulate memory access latency.

Provides ready signal to CPU when idle.

Interfaces
CPU Side

##Inputs

read_req: Request a read from SRAM.

write_req: Request a write to SRAM.

data_cpu [15:0]: Data from CPU (for write).

addr_cpu [14:0]: Address from CPU.

##Outputs

read_data [15:0]: Data read from SRAM.

ready: High when controller is idle/ready for new request.

##SRAM Side

sram_addr [14:0]: Address to SRAM.

sram_data [15:0]: Bi-directional data bus.

oe: Output Enable (active-low).

we: Write Enable (active-low).

ce: Chip Enable (active-low).

dq_oe: Data bus drive enable (1 = CPU drives bus, 0 = High-Z).


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah