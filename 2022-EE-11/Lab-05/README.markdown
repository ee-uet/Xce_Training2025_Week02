# Multi-Mode Timer Module

## Overview
The `multi_mode_timer` module is a Verilog implementation of a 32-bit timer supporting four modes: off, one-shot, periodic, and PWM. It operates with a 1 MHz clock, uses a programmable prescaler for clock division, and includes configurable reload and compare values for flexible timing control.

## Features
- **Inputs**:
  - `clk`: 1 MHz clock signal.
  - `rst_n`: Active-low reset.
  - `mode` (2-bit): Timer mode (00=off, 01=one-shot, 10=periodic, 11=PWM).
  - `prescaler` (16-bit): Clock divider (0–65535).
  - `reload_val` (32-bit): Value to reload counter.
  - `compare_val` (32-bit): PWM duty cycle threshold.
  - `start`: Initiates timer operation.
- **Outputs**:
  - `timeout`: Signals when counter reaches 0.
  - `pwm_out`: PWM output signal (active in PWM mode).
  - `current_count` (32-bit): Current counter value.

## FSM Description
The module uses a finite state machine (FSM) with 4 states (Moore machine, outputs depend on current state). States are defined in an enum `state_t`.

| State      | Description                          | Counter Behavior                     | Outputs                     |
|------------|--------------------------------------|--------------------------------------|-----------------------------|
| LOAD       | Timer off, loads `reload_val`.       | Counter loads `reload_val`.          | `timeout`, `pwm_out` = 0    |
| ONE_SHOT   | Counts down once, stops at 0.        | Decrements until 0, then stops.      | `timeout` = 1 at 0          |
| PERIODIC   | Counts down, reloads at 0.           | Decrements, reloads `reload_val` at 0.| `timeout` = 1 at 0          |
| PWM        | Counts down, reloads, PWM output.    | Decrements, reloads at 0.            | `pwm_out` = 1 if `count <= compare_val` |

### Transition Mechanism
- Transitions occur on `posedge clk`.
- State register (`curr_state`) updates on clock or reset to `LOAD`.
- Next state logic (`always_comb`) evaluates based on `start`, `mode`, `timeout`, and mode changes:
  - From `LOAD`: Transitions to `ONE_SHOT`, `PERIODIC`, or `PWM` if `start = 1` and `mode` matches (01, 10, 11); else stays in `LOAD`.
  - From `ONE_SHOT`: Returns to `LOAD` on `timeout` or if `mode` changes.
  - From `PERIODIC`: Stays unless `mode` changes, then to `LOAD`. Reloads counter on `timeout`.
  - From `PWM`: Stays unless `mode` changes, then to `LOAD`. Reloads counter on `timeout`.
- Reset forces `LOAD`, resetting counter and prescaler.

## Implementation Details
- **Module Structure**:
  - `always_ff` updates 16-bit prescaler counter (`clk_div`), resetting on overflow (`div_of`) or reset.
  - `div_of = (clk_div == prescaler)` enables counter updates at divided clock rate.
  - `always_ff` updates state and 32-bit counter (`current_count`).
  - Counter decrements when enabled (`counter_en`) and prescaler overflows, or loads `reload_val` when `counter_load = 1`.
  - `timeout = (current_count == 0)`.
  - In `PWM` mode, `pwm_out = (current_count > compare_val) ? 0 : 1`.
- **Prescaler**: Divides 1 MHz clock by `prescaler + 1` (1–65536).
- **Counter**: 32-bit, decrements or reloads based on state.

## Edge Cases
1. **Mode Change During Operation**:
   - If `mode` changes, the FSM transitions to `LOAD`, resetting the counter to `reload_val`. Ongoing operations (e.g., PWM output) are interrupted.
2. **Prescaler = 0**:
   - Acts as divide-by-1, counter updates every clock cycle.
3. **Reload Value = 0**:
   - Counter stays at 0, `timeout = 1` continuously in `ONE_SHOT`/`PERIODIC`/`PWM`.
4. **Compare Value in PWM**:
   - If `compare_val >= reload_val`, `pwm_out` may stay high (duty cycle near 100%).
   - If `compare_val = 0`, `pwm_out` stays low.
5. **Start Signal**:
   - Ignored unless in `LOAD` state with matching `mode`.
6. **Reset**:
   - Forces `LOAD`, resets `current_count` to all 1s, clears `clk_div`.

## Usage
To use this module:
1. Instantiate it in your Verilog design.
2. Connect `clk` (1 MHz), `rst_n`, `mode`, `prescaler`, `reload_val`, `compare_val`, `start`.
3. Monitor `timeout`, `pwm_out`, `current_count`.
This timer is suitable for applications requiring precise timing, periodic signals, or PWM generation, such as motor control or event scheduling.