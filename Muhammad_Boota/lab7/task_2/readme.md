# Lab 9B: Asynchronous FIFO (Clock Domain Crossing)

## Specification
- Handles different clock domains for read and write operations
- Uses Gray code pointers for safe domain crossing
- Metastability protection via multi-flop synchronizers
- Proper flag synchronization (full/empty)

## Critical Design Points
1. **Gray code pointer generation and comparison**
2. **Multi-flop synchronizers for domain crossing**
3. **Flag generation timing to avoid false flags**
4. **Reset handling across clock domains**

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab7/task_2/doc/Asynchronous_fifo.png)

## Inputs
- `wclk`, `wrst_n`: Write clock and reset
- `rclk`, `rrst_n`: Read clock and reset
- `w_en`: Write enable
- `r_en`: Read enable
- `data_in`: Data to write

## Outputs
- `data_out`: Data read from FIFO
- `full`: FIFO is full (write domain)
- `empty`: FIFO is empty (read domain)

## Features
- Gray code pointers for safe pointer transfer between clock domains
- Multi-flop synchronizers for metastability protection
- Flag generation logic to avoid glitches and false flags
- Separate resets for each clock domain

## Source Files
- [`asynchronous_fifo.sv`](src/asynchronous_fifo.sv): Main FIFO logic
- [`synchronizer.sv`](src/synchronizer.sv): Multi-flop synchronizer module
