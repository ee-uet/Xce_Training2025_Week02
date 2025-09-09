# UART Receiver Project

## Overview

This project implements a UART (Universal Asynchronous Receiver-Transmitter) receiver in SystemVerilog with frame error detection. The system includes clock generation, bit detection, FSM-based control, bit counting, and shift register functionality for serial data reception.

## Problem

Design and implement a UART receiver that:
- Receives 8-bit serial data with start and stop bit detection
- Supports configurable baud rate and system clock frequency
- Uses FSM-based control for reception states
- Implements frame error detection for invalid stop bits
- Provides ready and busy status signals
- Uses shift register for serial-to-parallel conversion

## Approach

The UART receiver is implemented using a modular design with separate components for clock generation, start bit detection, FSM control, bit counting, and shift register operations. The system uses a divided clock for baud rate generation, bit detector for start bit recognition, FSM for state management through IDLE, START, and CHECK_ERROR states, and frame error detection by checking the stop bit validity.

## Project Structure

```
lab8B/
├── Documentation/          # Contains block diagram, waveform, signal specification and state diagram
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── bit_detector.sv      # Start bit detector module
    ├── clk_generator.sv     # Clock generator module
    ├── counter.sv          # Bit counter module
    ├── shift_reg.sv        # Shift register module
    ├── uart_rx_fsm.sv      # UART receiver FSM
    ├── top_module.sv       # Top-level integration module
    └── top_module_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the UART receiver behavior.

## Examples

### Start Bit Detection
```systemverilog
rx_serial = 0; // Start bit detected
// Expected result: zero_detected = 1, FSM transitions to START state
```

### Data Reception
```systemverilog
// In START state with start_shift = 1
// Expected result: Serial data shifted into register, counter increments
```

### Frame Error Detection
```systemverilog
// After 9 bits received, checking stop bit
// Expected result: frame_error = 1 if stop bit is 0, frame_error = 0 if stop bit is 1
```

### Reception Complete
```systemverilog
// After valid frame received
// Expected result: rx_data contains received byte, rx_ready = 1, FSM returns to IDLE
```