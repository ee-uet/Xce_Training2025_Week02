# Asynchronous FIFO Project

## Overview

This project implements an asynchronous FIFO (First In, First Out) buffer in SystemVerilog with separate write and read clock domains. The FIFO uses Gray code counters and synchronizers to handle clock domain crossing safely and prevent metastability issues.

## Problem

Design and implement an asynchronous FIFO that:
- Operates with independent write and read clock domains
- Prevents data corruption during clock domain crossing
- Uses Gray code counters to avoid metastability
- Implements proper synchronization between clock domains
- Generates accurate full and empty flags
- Supports configurable data width and FIFO depth

## Approach

The asynchronous FIFO is implemented using Gray code counters for write and read pointers to ensure only one bit changes at a time during pointer updates. The design includes binary-to-Gray code converters and multi-stage synchronizers to safely transfer pointer values between clock domains. Full and empty detection logic compares synchronized Gray code pointers with appropriate bit manipulation.

## Project Structure

```
lab7B/
├── Documentation/          # Contains block diagram, waveform, signal specification.
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── async_fifo.sv        # Main asynchronous FIFO module
    ├── async_fifo_tb.sv     # Testbench
    ├── binary2gray.sv       # Binary to Gray code converter
    ├── gray2binary.sv       # Gray to binary code converter
    └── synchronizer.sv      # Multi-stage synchronizer
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the asynchronous FIFO behavior.

## Examples

### Write Operation
```systemverilog
wr_en = 1; wr_data = 8'hAB; // On write clock domain
// Expected result: Data written to FIFO, write pointer incremented in Gray code
```

### Read Operation
```systemverilog
rd_en = 1; // On read clock domain
// Expected result: Data read from FIFO, read pointer incremented in Gray code
```

### Cross-Clock Domain Synchronization
```systemverilog
// Write pointer synchronized to read clock domain
// Expected result: wr_ptr_gray_sync_rdclk updated after 2 read clock cycles
```

### Full/Empty Flag Generation
```systemverilog
// Full condition: wr_ptr_gray == {~rd_ptr_gray_sync_wrclk[MSB:MSB-1], rd_ptr_gray_sync_wrclk[remaining]}
// Empty condition: rd_ptr_gray == wr_ptr_gray_sync_rdclk
```