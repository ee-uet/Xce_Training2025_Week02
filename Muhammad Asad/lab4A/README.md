# Traffic Light Controller Project

## Overview

This project implements a traffic light controller system in SystemVerilog with pedestrian crossing and emergency vehicle functionality. The system includes a finite state machine (FSM) for traffic light control, a timer module for timing control, and a top-level integration module.

## Problem

Design and implement a traffic light controller that:
- Controls North-South and East-West traffic lights with proper sequencing
- Supports pedestrian crossing requests with dedicated walk signals
- Handles emergency vehicle priority with all-red state
- Includes startup flashing mode for system initialization
- Uses configurable timing for different light phases
- Maintains safe traffic flow with yellow transition periods

## Approach

The traffic light controller is implemented using a hierarchical design with three main modules: FSM for state control, timer for timing management, and top module for integration. The FSM uses enumerated states to represent different traffic phases and handles priority logic for emergency and pedestrian requests. The timer module provides configurable countdown functionality for each state duration.

## Project Structure

```
lab4A/
├── Documentation/          # Contains block diagram, waveform, signal specification and state diagram
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── fsm_traffic.sv       # Traffic light FSM module
    ├── timer.sv            # Timer module
    ├── top_module.sv       # Top-level integration module
    └── top_module_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the traffic light controller behavior.

## Examples

### Normal Traffic Sequence
```systemverilog
rst_n = 1; emergency = 0; pedestrian_req = 0;
// Expected result: Cycles through STARTUP_FLASH → NS_GREEN_EW_RED → NS_YELLOW_EW_RED → NS_RED_EW_GREEN → NS_RED_EW_YELLOW
```

### Pedestrian Request
```systemverilog
pedestrian_req = 1;
// Expected result: After EW_YELLOW phase completes, enters PEDESTRIAN_CROSSING state with ped_walk = 1
```

### Emergency Vehicle Priority
```systemverilog
emergency = 1;
// Expected result: Immediately transitions to EMERGENCY_ALL_RED state with emergency_active = 1
```

### Return to Normal Operation
```systemverilog
emergency = 0; pedestrian_req = 0;
// Expected result: Returns to STARTUP_FLASH state and resumes normal traffic sequence
```