# Traffic Light Controller

## Overview
This project implements a traffic light controller for a 4-way intersection with North-South (NS) and East-West (EW) directions, including normal traffic cycles, emergency override, and pedestrian crossing request handling.

## Design Requirements
- **Intersection**: 4-way with North-South and East-West directions
- **Normal Cycle**: 
  - Green: 30 seconds
  - Yellow: 5 seconds
  - Red: Transition state
- **Emergency Override**: All red lights with flashing
- **Pedestrian Crossing**: Handles pedestrian requests
- **Clock Input**: 1 Hz clock (timer to be created by students)
- **Control Inputs**:
  - `clk`: 1 Hz clock signal
  - `rst_n`: Active-low reset
  - `emergency`: Emergency override signal
  - `pedestrian_req`: Pedestrian crossing request
- **Outputs**:
  - `ns_lights`: North-South traffic lights
  - `ew_lights`: East-West traffic lights
  - `ped_walk`: Pedestrian walk signal
  - `emergency_active`: Emergency mode indicator

## Functionality
The controller manages the traffic light sequence for both NS and EW directions in a normal cycle (Green → Yellow → Red) with specified timing. It supports an emergency override mode that sets all lights to flashing red. Pedestrian crossing requests are handled to provide safe crossing intervals. The design operates synchronously with a 1 Hz clock input.

## Implementation Notes
- A timer must be implemented by students to handle the 30s Green and 5s Yellow phases.
- The state machine transitions between normal operation, emergency mode, and pedestrian crossing states.
- Emergency mode overrides all other states, setting all lights to flashing red.

## Usage
- Connect the `clk` signal to a 1 Hz clock source.
- Use `rst_n` to reset the controller (active low).
- Activate `emergency` to trigger the emergency override mode.
- Send `pedestrian_req` to request a pedestrian crossing.
- Monitor `ns_lights` and `ew_lights` for traffic light states, `ped_walk` for pedestrian signals, and `emergency_active` for emergency mode status.

## Diagrams
![Traffic Controller Diagram](/Muhammad_Boota/lab4/task_1/docx/traffic_controller.png)
![Programmable Counter Diagram](/Muhammad_Boota/lab4/task_1/docx/traffic_controller-datapath.png)
![State Machine Diagram](/Muhammad_Boota/lab4/task_1/docx/traffic_controller-state_machine.png)
---