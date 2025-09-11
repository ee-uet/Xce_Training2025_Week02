# Lab 5A: Multi-Mode Timer

## Problem
Design a **32-bit programmable timer** with the following specifications:
- **Modes of Operation:**
  - **One-shot:** Counts down once and stops.
  - **Periodic:** Automatically reloads and restarts after reaching zero.
  - **PWM:** Generates a PWM waveform with programmable duty cycle.
- **1 MHz input clock** with a programmable **prescaler**.
- **Interrupt capability** via `timeout` flag.
- **Programmable reload and compare values** for flexible operation.

---

## Approach
1. **Prescaler Design**
   - A prescaler divides the input clock to generate a slower `tick`.
   - This `tick` drives the main counter.

2. **Mode Control Logic**
   - `00` → Off (timer disabled).
   - `01` → One-shot (counter decrements until zero, then halts).
   - `10` → Periodic (counter decrements to zero, then reloads automatically).
   - `11` → PWM (counter decrements and reloads; `pwm_out` is high when `count ≤ compare_val`).

3. **Reload Mechanism**
   - In **one-shot mode**, counter stops at zero.
   - In **periodic/PWM modes**, counter reloads from `reload_val` when it hits zero.

4. **PWM Duty Cycle Calculation**
   - PWM output high time is determined by:
     ```
     Duty Cycle (%) = (compare_val / reload_val) * 100
     ```
   - Provides flexible control for applications like motor drivers or signal generation.

5. **Outputs**
   - `timeout`: Goes high when counter reaches zero (in all modes except off).
   - `pwm_out`: Active only in PWM mode.
   - `current_count`: Exposes current timer value.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Compile `Multi_Mode_Timer.sv` and `Multi_Mode_Timer_tb.sv` in **QuestaSim**.
- Run the testbench to observe:
  - One-shot countdown behavior.
  - Periodic auto-reload operation.
  - PWM waveform generation with configurable duty cycle.
  - Proper timeout signaling.

### Synthesis
- Import `Multi_Mode_Timer.sv` into **Xilinx Vivado**.
- Run synthesis and implementation.
- Check FPGA resource utilization and timing reports.

---

## Results
Simulation confirms correct operation across modes:

1. **One-Shot Mode (`01`)**
   - Counter decrements once from `reload_val` to zero.
   - Stops at zero; `timeout` asserted once.

2. **Periodic Mode (`10`)**
   - Counter decrements to zero.
   - Automatically reloads to `reload_val` and continues counting.
   - `timeout` asserted periodically.

3. **PWM Mode (`11`)**
   - Counter reloads continuously.
   - `pwm_out` toggles based on `compare_val` relative to `reload_val`.
   - Example: `reload_val = 4`, `compare_val = 1` → ~30% duty cycle.

4. **Timer Off (`00`)**
   - Counter frozen at 0, no activity on outputs.

- Simulation Waveform:
	Inputs = Blue Signals.
	Outputs = Yellow Signals.