# Lab 5A: Multi-Mode Timer

## Specification

- 32-bit programmable timer with multiple modes:
  - **One-shot**: Counts down once and stops
  - **Periodic**: Reloads and restarts automatically
  - **PWM**: Generates PWM with programmable duty cycle
- 1 MHz input clock, programmable prescaler
- Interrupt generation capability

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab5/docx/multi_mode_timer.png)

## Modes Description
- **One-shot**: Timer counts down from the reload value to zero, then stops and asserts the timeout signal.
- **Periodic**: Timer counts down from the reload value to zero, then automatically reloads and repeats, asserting timeout each cycle.
- **PWM**: Timer generates a PWM output with duty cycle set by `compare_val`.

## Example Operation
![Operation Examples](/Muhammad_Boota/lab5/docx/multimode_wave_diagrame.png)

## Inputs
- `clk`: 1 MHz clock
- `rst_n`: Active-low reset
- `mode`: Timer mode (off, one-shot, periodic, PWM)
- `prescaler`: Clock divider
- `reload_val`: Initial value to load
- `compare_val`: PWM duty cycle value
- `start`: Start signal

## Outputs
- `timeout`: Indicates timer has reached zero
- `pwm_out`: PWM output signal
- `current_count`: Current timer value

## Features
- Handles mode changes during operation
- Provides current count for monitoring
- Generates interrupts via `timeout` signal

## Source File
See [`multi_mode_timer.sv`](src/multi_mode_timer.sv) for implementation details.
