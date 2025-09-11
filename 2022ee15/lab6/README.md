# Lab 6A: Synchronous SRAM Controller

## Problem
Design and implement a **controller for a 32Kx16 synchronous SRAM** with the following requirements:
- Support **single-cycle read and write operations**.
- Correct handling of **chip enable (CE)**, **output enable (OE)**, and **write enable (WE)** signals.
- Provide an interface with **address and data buses** ensuring valid setup/hold timing.
- Controller must handle both **read and write cycles** seamlessly.
- Include a **testbench** to verify functionality.

---

## Approach
1. **Understanding SRAM Interface**
   - SRAM uses **active-low control signals** (`CE_n`, `OE_n`, `WE_n`).
   - `inout` bus for data (`sram_data`) requires tri-state logic to separate read and write phases.

2. **Controller FSM**
   - **IDLE**: Wait for read or write request.
   - **READ**: Assert `CE_n=0`, `OE_n=0`, `WE_n=1`, and capture data from SRAM.
   - **WRITE**: Assert `CE_n=0`, `OE_n=1`, `WE_n=0`, and drive data to SRAM.
   - Return to **IDLE** after operation.

3. **SRAM Model**
   - Implemented as a **32Kx16 memory array** in SystemVerilog.
   - Supports:
     - **Synchronous write** on clock edge when `CE_n=0` and `WE_n=0`.
     - **Combinational read** when `CE_n=0` and `OE_n=0`.

4. **Tri-State Bus Handling**
   - During write: Controller drives `sram_data`.
   - During read: Controller releases `sram_data` (set to `z`) and captures memory output.

5. **Testbench**
   - Generates clock and reset.
   - Performs:
     - Write to specific address, then read back to verify correctness.
     - Multiple write/read cycles to confirm stability.
   - Displays results with `$display`.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Compile `Top_SRAM.sv`, `SRAM_Controller.sv`, `SRAM.sv`, and `tb_top_sram.sv` in **QuestaSim**.
- Run the testbench.
- Observe:
  - Proper assertion of SRAM control signals.
  - Data being written to and read from memory.
  - `ready` signal indicating transaction completion.

### Synthesis
- Import RTL files into **Xilinx Vivado**.
- Run synthesis and implementation.
- Verify resource usage and timing constraints for FPGA deployment.

---

## Results
Simulation validates correct SRAM controller functionality:

1. **Write Operation**
   - Example: Writing `0xABCD` at address `10`.
   - Controller asserts correct signals (`CE_n=0`, `OE_n=1`, `WE_n=0`).
   - Data stored in SRAM successfully.

2. **Read Operation**
   - Example: Reading back from address `10` → returns `0xABCD`.
   - Controller asserts (`CE_n=0`, `OE_n=0`, `WE_n=1`).
   - Data retrieved correctly.

4. **FSM Behavior**
   - Single-cycle read/write transitions.
   - Controller always returns to **IDLE** after operation.
   - `ready` asserted to indicate valid completion.

- Simulation Waveform: 
	Outputs = Yellow signals 
