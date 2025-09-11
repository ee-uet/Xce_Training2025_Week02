# Lab 3A: Programmable Counter

## Problem
Design and implement an **8-bit programmable up/down counter** with the following requirements:  
- **Control Inputs:**  
  - `load`: Load a specific value into the counter  
  - `enable`: Enable counting  
  - `up_down`: Direction control (up = 1, down = 0)  
  - `reset`: Synchronous reset to 0  
- **Programmable Limits:** Counter must operate between `0` and a user-defined `max_count`.  
- **Outputs:**  
  - `count`: Current count value  
  - `tc`: Terminal count (asserted at max in up-count or 0 in down-count)  
  - `zero`: Asserted when count equals zero  
- Must handle **runtime changes in `max_count`** gracefully.  

---

## Approach
1. **State Machine Design**  
   - Defined four states: `IDLE`, `LOAD`, `COUNT_UP`, and `COUNT_DOWN`.  
   - State transitions are based on `enable`, `load`, and `up_down` inputs.  

2. **Synchronous Reset & Load Logic**  
   - On reset, counter goes to `0` and enters `IDLE`.  
   - In `LOAD` state, counter loads `load_value`, but clamps it to `max_count` if exceeded.  

3. **Up/Down Counting**  
   - In `COUNT_UP`, the counter increments until reaching `max_count`, then wraps to `0`.  
   - In `COUNT_DOWN`, the counter decrements until reaching `0`, then wraps to `max_count`.  

4. **Status Outputs**  
   - `zero` is asserted when `count == 0`.  
   - `tc` (terminal count) asserted when:  
     - Counting up and `count == max_count`.  
     - Counting down and `count == 0`.  

5. **Runtime Handling of `max_count`**  
   - If `max_count` changes dynamically, counter value is adjusted to stay within valid range.  

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Open **QuestaSim**  
- Compile `Programmable_Counter.sv` and `Programmable_Counter_tb.sv`  
- Run the testbench to verify state transitions, load operation, and up/down counting  

### Synthesis
- Import `Programmable_Counter.sv` into **Xilinx Vivado**  
- Run synthesis and implementation to check FPGA resource utilization  

---

## Results
Simulation demonstrates correct functionality:  

- Reset initializes counter to `0`.  
- Load operation correctly loads value (with clamping to `max_count`).  
- Up-count cycles from 0 → max_count → wrap to 0.  
- Down-count cycles from max_count → 0 → wrap to max_count.  
- `tc` and `zero` outputs assert at correct points.  

- Simulation Waveform:
	Inputs = Blue Signals.
	Outputs = Yellow Signals.



