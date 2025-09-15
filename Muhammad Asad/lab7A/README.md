# Synchronous FIFO Project

## Overview

This project implements a synchronous FIFO (First In, First Out) buffer in SystemVerilog with configurable data width and depth. The FIFO includes almost full and almost empty threshold detection for flow control and status monitoring.

## Problem

Design and implement a synchronous FIFO that:
- Supports configurable data width and FIFO depth
- Provides write and read operations with enable controls
- Generates full and empty status flags
- Includes almost full and almost empty threshold detection
- Maintains accurate count of stored elements
- Uses separate read and write pointers for circular buffer operation

## Approach

The synchronous FIFO is implemented using a circular buffer with separate read and write pointers. The design uses clocked always blocks for pointer management and data storage, with combinational logic for flag generation. The count mechanism tracks the number of stored elements and enables proper full/empty detection and threshold comparison.

## Project Structure

```
lab7A/
├── Documentation/          # Contains block diagram, waveform, signal specification.
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── sync_fifo.sv        # Main synchronous FIFO module
    └── sync_fifo_tb.sv     # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the synchronous FIFO behavior.

## Examples

### Write Operation
```systemverilog
wr_en = 1; wr_data = 8'hAB;
// Expected result: Data written to FIFO at write pointer location, count incremented
```

### Read Operation
```systemverilog
rd_en = 1;
// Expected result: Data read from FIFO at read pointer location, count decremented
```

### Almost Full Threshold
```systemverilog
// When count >= ALMOST_FULL_THRESH (14)
// Expected result: almost_full = 1
```

### Almost Empty Threshold
```systemverilog
// When count <= ALMOST_EMPTY_THRESH (2)
// Expected result: almost_empty = 1
```