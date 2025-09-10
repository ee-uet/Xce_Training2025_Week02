
# 6.2 Lab 4A: Traffic Light Controller
 
#### Overview
This fsm manages North-South (NS) and East-West (EW) traffic lights, pedestrian signals, and handles emergency overrides.  
The controller ensures safe traffic flow with proper timing for **green, yellow, red lights**, and **pedestrian walk requests**.

---
#### Block Diagram

![FSM_block](traffic_lab04.jpg)
#### FSM
![table](traffic_fsm.jpg)
 
 --- 
 
#### Features
- Startup flashing sequence on reset.
- Normal traffic cycle with green, yellow, and red phases.
- Pedestrian crossing mode with dedicated walk time.
- Emergency override mode (all lights turn red, emergency flag active).
- Timer-based state transitions for accurate durations.

---

#### FSM States
1. **STARTUP_FLASH** : Initial blinking mode for safety on reset.  
2. **NS_GREEN_EW_RED** : North-South traffic moves, East-West stops.  
3. **NS_YELLOW_EW_RED** : Transition from NS green to red.  
4. **NS_RED_EW_GREEN** : East-West traffic moves, North-South stops.  
5. **NS_RED_EW_YELLOW** : Transition from EW green to red.  
6. **PEDESTRIAN_CROSSING** : Pedestrian walk signal active, all traffic stopped.  
7. **EMERGENCY_ALL_RED** : Emergency mode, all signals red.  

---
### Assumptions

##### Pedestrian request:
Whenever pedestrian_req is asserted, the controller allows the current state’s duration to complete first, and only then transitions to the PEDESTRIAN_CROSSING state.

##### Emergency override:
An emergency overrides all states immediately. After the emergency condition is cleared, the controller resumes normal operation starting from the NS_GREEN_EW_RED state.

---

#### Parameters / Durations
| State                 | Duration (seconds) |
|------------------------|--------------------|
| STARTUP_FLASH          | 2  |
| N       | 30 |
| NS_YELLOW_EW_RED       | 5  |
| NS_RED_EW_GREEN        | 30 |
| NS_RED_EW_YELLOW       | 5  |
| PEDESTRIAN_CROSSING    | 10 |
| EMERGENCY_ALL_RED      | 1  |

---

#### Interface (I/O)
| Signal            | Direction | Description                                |
|-------------------|-----------|--------------------------------------------|
| `clk`             | Input     | System clock                         |
| `rst_n`           | Input     | Active low reset                           |
| `emergency`       | Input     | Emergency override request                 |
| `pedestrian_req`  | Input     | Pedestrian crossing request                |
| `ns_lights[1:0]`  | Output    | NS lights: `00=Red`, `01=Green`, `10=Yellow` |
| `ew_lights[1:0]`  | Output    | EW lights: same encoding as NS             |
| `ped_walk`        | Output    | Pedestrian walk signal                     |
| `emergency_active`| Output    | Indicates emergency mode is active         |

 
---
### Simulation
![kuchb](traffic_sim.jpg)
Even when ped_req was asserted, the NS_GREEN_EW_RED state continued until its duration was completed. However, when emergency was asserted, it immediately overrode the NS_GREEN_EW_RED state.

---