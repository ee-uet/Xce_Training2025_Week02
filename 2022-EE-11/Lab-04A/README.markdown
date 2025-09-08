# Traffic Light Controller Module

## Overview
The `traffic_controller` module is a Verilog implementation of a traffic light controller for a four-way intersection. It manages north-south (NS) and east-west (EW) lights, handles emergency vehicles, pedestrian requests, and includes a startup flash sequence. The clock is assumed to be 1 Hz for real-time operation (timings in seconds).

## Features
- **Inputs**:
  - `clk`: 1 Hz clock signal.
  - `rst_n`: Active-low reset.
  - `emergency`: Emergency vehicle signal (overrides normal operation).
  - `pedestrian_req`: Pedestrian crossing request.
- **Outputs**:
  - `ns_lights` (2-bit): NS lights control (00=OFF, 01=GREEN, 10=RED, 11=YELLOW).
  - `ew_lights` (2-bit): EW lights control (same encoding).
  - `ped_walk`: Pedestrian walk signal (1=walk).
  - `emergency_active`: Indicates emergency mode is active.

## FSM Description
The module uses a finite state machine (FSM) with 7 states to control traffic flow. It's a Moore machine where outputs depend solely on the current state. States are defined in an enum `state_t`.

| State                | Description                          | NS Lights | EW Lights | Ped Walk | Emergency Active | Timeout (cycles) |
|----------------------|--------------------------------------|-----------|-----------|----------|------------------|------------------|
| STARTUP_FLASH       | Initial flashing for 10s (alternating RED/OFF). | Alternating RED/OFF | Alternating RED/OFF | 0 | 0 | 10 |
| NS_GREEN_EW_RED     | NS green, EW red for 30s.           | GREEN    | RED      | 0 | 0 | 30 |
| NS_YELLOW_EW_RED    | NS yellow, EW red for 5s.           | YELLOW   | RED      | 0 | 0 | 5  |
| NS_RED_EW_GREEN     | NS red, EW green for 30s.           | RED      | GREEN    | 0 | 0 | 30 |
| NS_RED_EW_YELLOW    | NS red, EW yellow for 5s.           | RED      | YELLOW   | 0 | 0 | 5  |
| EMERGENCY_ALL_RED   | All flashing RED/OFF (no timeout).  | Alternating RED/OFF | Alternating RED/OFF | 0 | 1 | None |
| PEDESTRIAN_CROSSING | All red, pedestrian walk for 15s.   | RED      | RED      | 1 | 0 | 15 |

### Transition Mechanism
- Transitions occur on `posedge clk`.
- Next state logic is combinational (`always_comb`), based on current state, `emergency`, `pedestrian_req`, and counter overflow (`counter_of`).
- A 5-bit counter tracks time in each state, resetting on state entry or overflow.
- Timeout values vary by state (e.g., 30s for green, 5s for yellow).
- Priorities: Emergency overrides all; pedestrian requests are checked at yellow transitions or startup.
- From STARTUP_FLASH: To EMERGENCY_ALL_RED if emergency; to PEDESTRIAN_CROSSING if pedestrian_req; to NS_GREEN_EW_RED on timeout.
- Normal cycle: NS_GREEN_EW_RED → NS_YELLOW_EW_RED → NS_RED_EW_GREEN → NS_RED_EW_YELLOW → NS_GREEN_EW_RED (with checks for emergency/pedestrian at yellows).
- EMERGENCY_ALL_RED: Exits to NS_GREEN_EW_RED when emergency clears (no timeout).
- PEDESTRIAN_CROSSING: To EMERGENCY_ALL_RED if emergency; to NS_GREEN_EW_RED on timeout.
- Reset forces STARTUP_FLASH.

## Implementation Details
- **Module Structure**:
  - State register updates on clock/reset.
  - Counter increments each cycle, resets on overflow or reset.
  - Overflow logic sets `counter_of` based on state-specific timeouts.
  - FSM logic sets outputs and next_state in a `case` on curr_state.
  - Flashing uses `counter[0]` for alternation.
- **Assumptions**: Clock is 1 Hz; lights encoding is fixed.

## Edge Cases
1. **Reset During Operation**:
   - Forces STARTUP_FLASH, counter reset to 0.
2. **Emergency Activation**:
   - From any state (except EMERGENCY_ALL_RED), transitions immediately to EMERGENCY_ALL_RED on emergency=1.
   - Flashes RED/OFF; exits only when emergency=0, to NS_GREEN_EW_RED.
3. **Pedestrian Request**:
   - Honored at end of yellow phases or startup/pedestrian timeout; ignored during green if not at transition point.
   - During PEDESTRIAN_CROSSING, emergency overrides to EMERGENCY_ALL_RED.
4. **Counter Overflow**:
   - Triggers transitions in timed states; no overflow in EMERGENCY_ALL_RED.
5. **Simultaneous Inputs**:
   - Emergency takes priority over pedestrian_req.
6. **Startup with Inputs**:
   - If emergency or pedestrian_req during STARTUP_FLASH, transitions accordingly before timeout.

## Usage
To use this module:
1. Instantiate it in your Verilog design.
2. Connect `clk` (1 Hz), `rst_n`, `emergency`, `pedestrian_req`.
3. Monitor `ns_lights`, `ew_lights`, `ped_walk`, `emergency_active`.
This controller is suitable for simulating or implementing basic traffic management systems.