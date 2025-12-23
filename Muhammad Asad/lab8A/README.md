# UART Transmitter Project

## Overview

This project implements a UART (Universal Asynchronous Receiver-Transmitter) transmitter in SystemVerilog with configurable baud rate and clock frequency. The system includes clock generation, FSM-based control, bit counting, and shift register functionality for serial data transmission.

## Problem

Design and implement a UART transmitter that:
- Transmits 8-bit data serially with start and stop bits
- Supports configurable baud rate and system clock frequency
- Uses FSM-based control for transmission states
- Implements proper timing for serial bit transmission
- Provides ready and busy status signals
- Uses shift register for parallel-to-serial conversion

## Approach

The UART transmitter is implemented using a modular design with separate components for clock generation, FSM control, bit counting, and shift register operations. The system uses a divided clock for baud rate generation, FSM for state management through IDLE, LOAD, START_BIT, DATA_BITS, and STOP_BIT states, and coordinated control signals between modules.

## Project Structure

```
lab8A/
├── Documentation/          # Contains block diagram, waveform, signal specification and state diagram
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── clk_generator.sv     # Clock generator module
    ├── counter.sv          # Bit counter module
    ├── shift_reg.sv        # Shift register module
    ├── uart_tx_fsm.sv      # UART transmitter FSM
    ├── top_module.sv       # Top-level integration module
    └── top_module_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the UART transmitter behavior.

## Examples

### Data Transmission Start
```systemverilog
tx_valid = 1; tx_data = 8'hA5;
// Expected result: FSM transitions to LOAD state, data loaded into shift register
```

### Start Bit Transmission
```systemverilog
// In START_BIT state
// Expected result: tx_serial = 0, counter starts, FSM moves to DATA_BITS
```

### Data Bits Transmission
```systemverilog
// In DATA_BITS state with start_shift = 1
// Expected result: LSB transmitted first, shift register shifts right each clock
```

### Transmission Complete
```systemverilog
// After 8 data bits transmitted
// Expected result: FSM moves to STOP_BIT state, tx_serial = 1, then returns to IDLE
```