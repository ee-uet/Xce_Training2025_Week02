# Lab 4A: Traffic Light Controller

## Problem
Design a **traffic light controller** for a 4-way intersection (North-South and East-West) with the following requirements:  
- **Normal Operation:**  
  - North-South and East-West alternate between Green → Yellow → Red.  
  - Green = 30s, Yellow = 5s.  
- **Emergency Override:**  
  - All lights Red with flashing until emergency cleared.  
- **Pedestrian Crossing:**  
  - On request, all vehicle lights Red, pedestrian walk signal active.  
- **Startup:**  
  - All Red flashing for safety before entering normal cycle.  
- Must be clock-driven using a **1 Hz timer module** for delays.  

---

## Approach
1. **FSM Design**  
   - States:  
     - `STARTUP_FLASH` – blinking red lights on reset.  
     - `NS_GREEN_EW_RED` – NS traffic moves, EW stopped.  
     - `NS_YELLOW_EW_RED` – NS yellow before switching.  
     - `NS_RED_EW_GREEN` – EW traffic moves, NS stopped.  
     - `NS_RED_EW_YELLOW` – EW yellow before switching.  
     - `PEDESTRIAN_CROSSING` – all red, pedestrian walk active.  
     - `EMERGENCY_ALL_RED` – flashing red during emergency.  

2. **Timer Module**  
   - A synchronous counter triggered by 1 Hz clock.  
   - Resets on state transitions to measure correct duration.  

3. **Pedestrian Handling**  
   - Pedestrian requests are **latched** until served.  
   - Inserted after a yellow phase for safe transition.  
   - Priority: served before resuming normal cycle.  

4. **Emergency Handling**  
   - Immediate override to `EMERGENCY_ALL_RED`.  
   - Flashing red lights to stop all traffic.  
   - System returns to `STARTUP_FLASH` once cleared.  

5. **Output Encodings**  
   - Lights encoded on 2 bits (`RED=00`, `GREEN=01`, `YELLOW=10`, `OFF=11`).  
   - Pedestrian walk and emergency indicators provided as separate outputs.  

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Open **QuestaSim**  
- Compile `traffic_controller.sv`, `timer.sv`, and `traffic_controller_tb.sv`.  
- Run the testbench to observe:  
  - Normal traffic cycles (NS ↔ EW).  
  - Pedestrian crossing service after request.  
  - Emergency override with flashing red.  
  - Safe startup sequence.  

### Synthesis
- Import `traffic_controller.sv` and `timer.sv` into **Xilinx Vivado**.  
- Run synthesis and implementation to verify FPGA resource mapping.  

---

## Results
Simulation demonstrates correct functionality:  

- **Startup Phase:** All lights flash red for a few cycles before normal operation.  
- **Normal Operation:**  
  - NS stays green for 30s, then yellow for 5s, before switching to EW.  
  - EW follows the same timing sequence.  
- **Pedestrian Requests:**  
  - When a pedestrian presses the button, system waits for a safe transition point.  
  - Both NS and EW go red, pedestrian walk signal asserts for 10s.  
  - Cycle resumes at the stored return state (ensuring fairness).  
- **Emergency Override:**  
  - Triggering emergency causes all lights to flash red.  
  - Once cleared, system restarts from `STARTUP_FLASH`.  

Outform Waveform:
	Inputs : Blue color Signals (Emergency, Pedestrian_req).
	FSM States : Cyan color Signals (State, Next_state, Rteurn_state, Next_return_state)
	Outputs : Yellow Color Signals (EW and NS Lights).
