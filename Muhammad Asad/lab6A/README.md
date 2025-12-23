# SRAM Controller Project

## Overview

This project implements an SRAM controller in SystemVerilog with separate FSM and datapath modules. The controller manages read and write operations to external SRAM memory through a standardized interface with proper timing control and data latching.

## Problem

Design and implement an SRAM controller that:
- Manages read and write operations to external SRAM memory
- Provides proper timing control for SRAM access cycles
- Uses FSM-based control for state management
- Implements datapath for address and data handling
- Supports bidirectional data bus with tri-state control
- Generates appropriate control signals (CE, OE, WE)

## Approach

The SRAM controller is implemented using a modular design with separate FSM and datapath modules integrated through a top-level module. The FSM manages state transitions between IDLE, READ, WRITE, and DONE states, while the datapath handles address and data latching with tri-state buffer control for the bidirectional SRAM data bus.

## Project Structure

```
lab6A/
├── Documentation/          # Contains block diagram, waveform, signal specification and state diagram
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── datapath.sv          # Datapath module
    ├── fsm_sram.sv         # SRAM FSM module
    ├── top_module.sv       # Top-level integration module
    └── top_module_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the SRAM controller behavior.

## Examples

### Write Operation
```systemverilog
address = 15'h0010; write_data = 16'hABCD; write_req = 1;
// Expected result: FSM transitions to WRITE state, data written to SRAM address 0x0010
```

### Read Operation
```systemverilog
address = 15'h0010; read_req = 1;
// Expected result: FSM transitions to READ state, data read from SRAM address 0x0010
```

### Ready Signal
```systemverilog
// Controller in IDLE state
// Expected result: ready = 1, controller available for new operations
```

### Control Signals
```systemverilog
// During WRITE state
// Expected result: sram_ce = 0, sram_we = 0, drive_data_en = 1
```