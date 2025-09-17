# Timer Counter System

## Problem

This project implements a versatile timer/counter system in SystemVerilog that can operate in multiple modes. The system addresses the need for a configurable timing solution that can handle different timing requirements including one-shot timing, periodic operations, PWM generation, and an off state. The design provides precise timing control through a prescaler mechanism and supports 32-bit counter values for extended timing ranges.

## Approach

The system follows a modular design approach with five main components working together:

### 1. Clock Prescaler (`Clk_Gen_Prescaler.sv`)
- Generates a prescaled clock from the input clock
- Uses a 16-bit prescale value to divide the input clock frequency
- Toggles the output clock when the counter reaches the prescale value

### 2. Countdown Counter (`CountDown.sv`)
- Implements a 32-bit down counter
- Supports reload functionality to reset the counter to a specified value
- Handles PWM mode by loading the compare value when needed
- Decrements the counter when enabled

### 3. Logic Comparator (`LogicComparater.sv`)
- Determines the operating mode based on current count and mode settings
- Generates control signals for different timer modes:
  - One-shot: Triggers when count reaches zero
  - Periodic: Triggers repeatedly when count reaches zero
  - PWM: Compares current count with compare value
  - Off: Disables the timer

### 4. Finite State Machine (`CountFSM.sv`)
- Controls the overall system behavior through seven states:
  - `IDLE`: Initial state, ready to start
  - `RUNNING`: Transition state to determine mode
  - `ONE_SHOT`: Single timing event
  - `PERIODIC`: Repeating timing events
  - `PWM`: PWM initialization
  - `PWM_RUN`: Active PWM generation
  - `OFF`: Timer disabled
- Generates enable, reload, and timeout signals based on current state

### 5. Top Module (`Top.sv`)
- Integrates all components
- Provides the main interface with input/output ports
- Handles signal routing between modules

The system operates by first prescaling the input clock, then using the FSM to control the counter based on the selected mode. The comparator continuously evaluates the counter value to determine when mode-specific actions should occur.

## How to Run

Run the testbench on QuestaSim.

## Examples

### Mode Configuration

The system supports four different modes controlled by the 2-bit `mode` input:

**Mode 2'b01 - One-Shot Timer**
```systemverilog
mode = 2'b01;
reload_value = 32'd100;  // Count down from 100
```
- Timer counts down once from reload_value to 0
- Generates a timeout signal when count reaches 0
- Returns to IDLE state after completion

**Mode 2'b10 - Periodic Timer**
```systemverilog
mode = 2'b10;
reload_value = 32'd50;   // Repeat every 50 counts
```
- Timer continuously counts down from reload_value to 0
- Generates timeout signals periodically
- Automatically reloads and continues

**Mode 2'b11 - PWM Mode**
```systemverilog
mode = 2'b11;
reload_value = 32'd20;    // PWM period
compare_value = 32'd8;    // PWM duty cycle threshold
```
- Generates PWM output with configurable duty cycle
- PWM high when current_count >= compare_value
- PWM low when current_count < compare_value
- Period determined by reload_value

**Mode 2'b00 - Off Mode**
```systemverilog
mode = 2'b00;
```
- Timer is disabled
- No counting or output generation
- Can be re-enabled by changing mode and asserting start

### Sample Timing Configuration

```systemverilog
prescale_val = 16'd100;      // Divide input clock by 100
reload_value = 32'd1000;     // Count for 1000 prescaled cycles
compare_value = 32'd300;     // PWM threshold at 300 counts
```

This configuration creates timing events based on (input_clock_period × 100 × 1000) for the total period, with PWM duty cycle of 70% (700/1000) when in PWM mode.