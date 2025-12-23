# Lab 6A: SRAM Controller

## Specification
- Controls synchronous SRAM for read and write operations
- Supports 15-bit address and 16-bit data width
- Handles chip select, output enable, and write enable signals
- Provides ready signal for operation status

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab6/doc/sram_controller.png)

## Write Operation Timing
![Write Timing](/Muhammad_Boota/lab6/doc/sram_write_timming_diagrame.png)

## Read Operation Timing
![Read Timing](/Muhammad_Boota/lab6/doc/sram_read_timming_diagrame.png)

## Inputs
- `clk`: Clock signal
- `rst_n`: Active-low reset
- `read_req`: Read request
- `write_req`: Write request
- `address`: 15-bit memory address
- `write_data`: 16-bit data to write

## Outputs
- `read_data`: 16-bit data read from SRAM
- `ready`: Indicates controller is ready for new operation
- `sram_addr`: Address to SRAM
- `sram_data`: Data bus to/from SRAM
- `sram_ce_n`: Chip select (active low)
- `sram_oe_n`: Output enable (active low)
- `sram_we_n`: Write enable (active low)

## Description
This module implements a state machine to control SRAM read and write cycles. It manages address, data, and control signals according to standard SRAM timing requirements. The controller asserts the `ready` signal when idle or after completing an operation.

## Source File
See [`sram_controller.sv`](src/sram_controller.sv) for implementation details.
