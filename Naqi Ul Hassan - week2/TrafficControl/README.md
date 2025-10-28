# Traffic Light Control System

A comprehensive traffic light control system implemented in SystemVerilog, featuring normal traffic flow, pedestrian crossing requests, and emergency vehicle override functionality.

## Problem Statement

Traditional traffic intersections require intelligent control systems to:
- Manage safe traffic flow in both North-South (NS) and East-West (EW) directions
- Handle pedestrian crossing requests safely
- Provide emergency vehicle override capabilities
- Ensure proper timing sequences to prevent accidents
- Maintain system reliability with proper reset and startup procedures

This project implements a finite state machine (FSM) based solution that addresses all these requirements while providing a modular, testable design.

## Architecture & Approach

The system uses a **hierarchical modular design** with three main components:

### 1. **Top Module (`Top.sv`)**
- Acts as the system integrator
- Instantiates and connects the FSM controller and timer modules
- Provides clean interface to external world

### 2. **Traffic Control FSM (`TrafficControl_FSM.sv`)**
- **7-state finite state machine** controlling traffic flow:
  - `STARTUP_FLASH`: Initial startup with all lights off (10 cycles)
  - `NS_GREEN_EW_RED`: North-South green, East-West red (30 cycles)
  - `NS_YELLOW_EW_RED`: North-South yellow, East-West red (5 cycles)
  - `NS_RED_EW_GREEN`: North-South red, East-West green (30 cycles)
  - `NS_RED_EW_YELLOW`: North-South red, East-West yellow (5 cycles)
  - `PEDESTRIAN_CROSSING`: All directions red, pedestrian walk enabled (10 cycles)
  - `EMERGENCY_ALL_RED`: Emergency override, all lights red

### 3. **Timer Module (`Count.sv`)**
- Configurable down-counter (5-bit, supports 0-31 cycles)
- Provides timing control for each traffic state
- Generates `count_done` signal for state transitions

### Key Features

- **Priority-based Control**: Emergency > Pedestrian > Normal Traffic
- **Safe Transitions**: Yellow phases prevent abrupt red-to-green changes
- **Pedestrian Integration**: Dedicated crossing phase with all-red traffic lights
- **Emergency Override**: Immediate transition to all-red state
- **Robust Reset**: Proper startup sequence from reset condition

## Signal Interface

### Inputs
| Signal | Width | Description |
|--------|-------|-------------|
| `clk` | 1 | System clock |
| `rst_n` | 1 | Active-low asynchronous reset |
| `emergency` | 1 | Emergency vehicle override |
| `pedestrian_req` | 1 | Pedestrian crossing request |

### Outputs
| Signal | Width | Description | Encoding |
|--------|-------|-------------|----------|
| `ns_lights` | 2 | North-South traffic lights | `00`=Off, `01`=Green, `10`=Yellow, `11`=Red |
| `ew_lights` | 2 | East-West traffic lights | `00`=Off, `01`=Green, `10`=Yellow, `11`=Red |
| `ped_walk` | 1 | Pedestrian walk signal | `1`=Walk enabled |
| `emergency_active` | 1 | Emergency mode indicator | `1`=Emergency active |

## How to Run

### Prerequisites
- SystemVerilog simulator (ModelSim, VCS, Xcelium, or Verilator)
- Basic knowledge of digital simulation tools

### Simulation Steps

1. **Compile the design files:**
   ```bash
   # For ModelSim/QuestaSim
   vlog Count.sv TrafficControl_FSM.sv Top.sv TrafficControl_tb.sv
   
   # For VCS
   vcs Count.sv TrafficControl_FSM.sv Top.sv TrafficControl_tb.sv
   ```

2. **Run the simulation:**
   ```bash
   # ModelSim/QuestaSim
   vsim TrafficControl_tb
   run -all
   
   # VCS
   ./simv
   ```

3. **View waveforms (optional):**
   ```bash
   # Add to testbench for waveform generation
   $dumpfile("traffic_control.vcd");
   $dumpvars(0, TrafficControl_tb);
   ```

### Expected Output
```
Time | NS | EW | Ped | Emerg
   0 | 00 | 00 |  0  |   0
  15 | 00 | 00 |  0  |   0    // Startup flash
 115 | 01 | 11 |  0  |   0    // NS Green
 415 | 10 | 11 |  0  |   0    // NS Yellow
 465 | 11 | 01 |  0  |   0    // EW Green
 765 | 11 | 10 |  0  |   0    // EW Yellow
 815 | 11 | 11 |  1  |   0    // Pedestrian crossing
 915 | 01 | 11 |  0  |   0    // Back to NS Green
```

## Usage Examples

### Example 1: Normal Traffic Cycle
```systemverilog
// Reset the system
rst_n = 0;
#10 rst_n = 1;

// System will automatically cycle:
// Startup (10 cycles) → NS Green (30) → NS Yellow (5) → 
// EW Green (30) → EW Yellow (5) → repeat
```

### Example 2: Pedestrian Crossing Request
```systemverilog
// During EW Yellow phase, request pedestrian crossing
pedestrian_req = 1;
// Wait for current cycle to complete
// System will enter PEDESTRIAN_CROSSING state
// All traffic lights = RED, ped_walk = 1
```

### Example 3: Emergency Override
```systemverilog
// At any time, activate emergency
emergency = 1;
// System immediately transitions to EMERGENCY_ALL_RED
// All traffic lights = RED, emergency_active = 1

// Deactivate emergency
emergency = 0;
// System returns to STARTUP_FLASH, then normal operation
```

## Timing Specifications

| State | Duration (Clock Cycles) | Purpose |
|-------|------------------------|---------|
| Startup Flash | 10 | System initialization |
| Green Lights | 30 | Main traffic flow |
| Yellow Lights | 5 | Transition warning |
| Pedestrian Crossing | 10 | Safe crossing time |
| Emergency | Indefinite | Until emergency cleared |

## Testing

The included testbench (`TrafficControl_tb.sv`) provides:
- Complete state sequence verification
- Pedestrian request testing
- Emergency override validation
- Timing verification
- Signal monitoring with formatted output

### Test Scenarios Covered
1. ✅ Power-on reset and startup sequence
2. ✅ Normal traffic light cycling
3. ✅ Pedestrian crossing request handling
4. ✅ Emergency vehicle override
5. ✅ Recovery from emergency mode
6. ✅ Signal timing verification

## Files Structure

```
├── Count.sv                 # Configurable timer module
├── TrafficControl_FSM.sv    # Main FSM controller
├── Top.sv                   # System integrator
└── TrafficControl_tb.sv     # Comprehensive testbench
```

## Future Enhancements

- **Variable Timing**: Configurable timing parameters via inputs
- **Traffic Density**: Adaptive timing based on sensor inputs
- **Multiple Intersections**: Network of coordinated traffic lights
- **Advanced Pedestrian**: Countdown timers and audio signals
- **Communication Interface**: Integration with traffic management systems

## License

This project is provided as-is for educational and development purposes.