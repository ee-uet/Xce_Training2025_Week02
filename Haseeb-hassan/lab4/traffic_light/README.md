# Traffic Light Controller - Lab 4

## Problem Description
This lab implements a traffic light controller for a four-way intersection using a finite state machine. The controller manages North-South and East-West traffic lights in a timed sequence, handles pedestrian crossing requests, and provides emergency vehicle override capability. The system operates on a 1Hz clock where each cycle represents 1 second. The controller includes seven states: startup flash, four normal traffic states (NS green/yellow, EW green/yellow), pedestrian crossing, and emergency override.

## Approach
The traffic controller uses a **finite state machine (FSM) with timer-based transitions**:

* **7-State FSM**: STARTUP_FLASH → NS_GREEN_EW_RED → NS_YELLOW_EW_RED → NS_RED_EW_GREEN → NS_RED_EW_YELLOW → (cycle repeats)
* **Timer Module**: Configurable countdown timer using pulse-based start signal and load value
* **Priority System**: Emergency (highest) → Pedestrian → Normal traffic flow
* **Request Latching**: Pedestrian requests are latched and served at safe yellow-to-red transitions
* **State Entry Detection**: Uses previous state comparison to trigger timer initialization on state entry
* **Light Encoding**: 2-bit output where 00=RED, 01=YELLOW, 10=GREEN

The timer controls state durations: startup flash (5s), green lights (30s), yellow lights (5s), pedestrian crossing (10s). Emergency override immediately forces all lights red and returns to startup when cleared.

## Folder Structure
```
traffic_light/
├── traffic_controller.sv                 
├── timer.sv                               
├── tb_traffic_controller.sv             
├── documentation/
     ├── signal_description.txt
 │   └── logical_fsm
 │   └── waves               
└── README.md                            
```

## How to Run
### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps
Using ModelSim/QuestaSim:
```bash
# Compile design and testbench
vlog timer.sv traffic_controller.sv tb_traffic_controller.sv

# Start simulation  
vsim tb_traffic_controller

# Run simulation
run -all
```

Using Vivado:
```bash
# Create project and add all .sv files
# Set tb_traffic_controller as top module
# Run behavioral simulation
```

The testbench runs for ~140 clock cycles testing reset, normal operation, pedestrian request, and emergency scenarios.

## Examples

### Test Sequence
* **Reset Phase**: rst_n=0, emergency=0, pedestrian_req=0 for 20ns
* **Normal Operation**: Release reset, observe normal traffic light cycling for 500ns
* **Pedestrian Test**: Assert pedestrian_req=1 for 200ns, then release
* **Emergency Test**: Assert emergency=1 for 200ns, then release  
* **Final Phase**: Run additional 500ns to observe recovery and normal operation

The testbench runs for total simulation time of 1420ns and automatically finishes. Monitor ns_lights, ew_lights, ped_walk, and emergency_active outputs to verify correct FSM operation.