# Programmable Counter Project

## Overview

This project implements an 8-bit programmable counter in SystemVerilog. The counter features up/down counting, loadable initial values, configurable maximum count, and status outputs for terminal count and zero detection.

## Problem

Design and implement a programmable counter that:
- Counts up or down based on control signal
- Supports loading of initial count values
- Has configurable maximum count limit
- Provides terminal count and zero flag outputs
- Includes enable functionality for count control
- Operates synchronously with clock and asynchronous reset

## Approach

The programmable counter is implemented using a clocked always block with asynchronous reset. The design incorporates priority logic where reset has highest priority, followed by load, then enable. The counter automatically wraps around when reaching maximum count (up counting) or zero (down counting), providing continuous operation within the defined range.

## Project Structure

```
lab3A/
├── Documentation/          # Contains block diagram, waveform, and signal specification
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── prog_counter.sv       # Main programmable counter module
    └── prog_counter_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the programmable counter behavior.

## Examples

### Load Initial Value
```systemverilog
rst_n = 1; load = 1; load_value = 8'd5; max_count = 8'd10;
// Expected result: count = 8'd5
```

### Up Counting
```systemverilog
enable = 1; load = 0; up_down = 1;
// Expected result: count increments from current value, wraps to 0 after max_count
```

### Down Counting
```systemverilog
enable = 1; up_down = 0;
// Expected result: count decrements from current value, wraps to max_count after 0
```

### Disable Counter
```systemverilog
enable = 0;
// Expected result: count remains at current value
```