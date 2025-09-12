# Lab 9A: Synchronous FIFO

## Specification
- Parameterizable data width and FIFO depth
- Full and empty flag generation
- Almost-full and almost-empty thresholds
- Efficient FPGA block RAM utilization

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab7/task_1/docx/sync_fifo.png)

## Inputs
- `clk`: Clock signal
- `rst_n`: Active-low reset
- `wr_en`: Write enable
- `wr_data`: Data to write (parameterizable width)
- `rd_en`: Read enable

## Outputs
- `rd_data`: Data read from FIFO
- `full`: FIFO is full
- `empty`: FIFO is empty
- `almost_full`: FIFO is almost full (threshold parameter)
- `almost_empty`: FIFO is almost empty (threshold parameter)
- `count`: Number of items in FIFO

## Features
- FIFO logic implemented with parameterizable width and depth
- Flags for full, empty, almost-full, and almost-empty

## Source File
See [`sync_fifo.sv`](src/sync_fifo.sv) for implementation details.
