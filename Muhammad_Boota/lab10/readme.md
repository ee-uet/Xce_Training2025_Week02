# Lab 12.2: AXI4-Lite Slave Design

## Specification
- Register bank with 16 x 32-bit registers
- Read/write access to all registers
- Address decode logic for valid register access
- Proper AXI4-Lite response handling
- Error responses for invalid addresses

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab10/docx/axi4_lite.png)

## AXI4-Lite Timing Diagrams
- Read channel: ![Read Timing](/Muhammad_Boota/lab10/docx/axi4_lite_read_timming_diagrame.png)
- Write channel: ![Write Timing](/Muhammad_Boota/lab10/docx/axi4_lite_write_timming_diagrame.png)

## Inputs
- `clk`: System clock
- `rst_n`: Active-low reset
- `axi_if`: AXI4-Lite slave interface

## Features
- Implements AXI4-Lite protocol for register access
- Decodes addresses to select registers
- Handles read and write transactions with valid/ready handshakes
- Generates error responses for invalid addresses

## Source Files
- [`axi4_lite_slave.sv`](src/axi4_lite_slave.sv): AXI4-Lite slave module
- [`axi4_lite_if.sv`](src/axi4_lite_if.sv): AXI4-Lite interface definition

## Description
This module implements an AXI4-Lite slave with a 16 x 32-bit register bank. It supports read and write operations, address decoding, and proper AXI4-Lite protocol responses, including error signaling for invalid addresses.
