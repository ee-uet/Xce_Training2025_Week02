# Programmable Timer Project

## Overview

This project implements a programmable timer system in SystemVerilog with multiple operating modes including one-shot, periodic, and PWM functionality. The system includes a prescaler for clock division, FSM for control logic, down counter for timing, and compare logic for mode detection.

## Problem

Design and implement a programmable timer that:
- Supports multiple operating modes: off, one-shot, periodic, and PWM
- Uses configurable prescaler for clock frequency division
- Implements down counter with reload capability
- Provides compare logic for different timing modes
- Generates timeout signals and PWM output
- Uses FSM-based control for state management

## Approach

The programmable timer is implemented using a modular hierarchical design with five main components: prescaler for clock scaling, FSM for state control, down counter for timing operations, compare logic for mode detection, and top-level integration. The FSM manages state transitions between idle, running, and mode-specific states while the counter provides precise timing control.

## Project Structure

```
lab5/
├── Documentation/          # Contains block diagram, waveform, signal specification and state diagram
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── comapre_logic.sv       # Compare logic module
    ├── counter_fsm.sv         # Counter FSM module
    ├── down_counter.sv        # Down counter module
    ├── Prescalar.sv           # Prescaler module
    ├── top_module.sv          # Top-level integration module
    └── top_module_tb.sv       # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the programmable timer behavior.

## Examples

### One-Shot Mode
```systemverilog
mode = 2'b01; start = 1; reload_value = 32'd10;
// Expected result: Timer counts down once, generates time_out when reaching zero
```

### Periodic Mode
```systemverilog
mode = 2'b10; start = 1; reload_value = 32'd10;
// Expected result: Timer counts down repeatedly, reloading after each timeout
```

### PWM Mode
```systemverilog
mode = 2'b11; start = 1; reload_value = 32'd10; compare_value = 32'd5;
// Expected result: PWM output high for compare_value duration, low for remaining period
```

### Off Mode
```systemverilog
mode = 2'b00;
// Expected result: Timer disabled, all outputs inactive
```