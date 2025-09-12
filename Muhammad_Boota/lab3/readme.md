# Programmable Counter

## Overview
This project implements an 8-bit up/down counter with programmable limits, designed for synchronous operation with proper reset functionality.

## Design Requirements
- **Counter Type**: 8-bit up/down counter
- **Programmable Limits**: Configurable maximum and load values
- **Control Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `load`: Load control
  - `enable`: Enable control
  - `up_down`: Direction control (up or down)
- **Status Outputs**:
  - `count`: 8-bit count output
  - `tc`: Terminal count indicator
  - `zero`: Zero detect indicator
- **Operation**: Synchronous with proper reset

## Functionality
The programmable counter supports counting up or down based on the `up_down` input, with the ability to load a specific value and set a maximum count. The counter resets synchronously when `rst_n` is low. Status outputs `tc` and `zero` indicate when the count reaches the terminal value or zero, respectively.

## Implementation Notes
- The design ensures synchronous operation with all control inputs synchronized to the clock.
- The counter can be enabled or disabled using the `enable` input.
- Programmable limits are set via `load_value` and `max_count` inputs.

## Usage
- Connect the `clk` signal to a clock source.
- Use `rst_n` to reset the counter (active low).
- Set `load` and `load_value` to load a specific count value.
- Control counting direction with `up_down` (high for up, low for down).
- Enable or disable counting with `enable`.
- Monitor `count` for the current value, `tc` for terminal count, and `zero` for zero detection.

## Diagram
![Programmable Counter Diagram](/Muhammad_Boota/lab3/docx/programmable_counter.png)