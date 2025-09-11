# Lab 7: FIFO Design – Synchronous FIFO

## Problem
Design a **parameterizable synchronous FIFO** with the following requirements:
- Configurable **data width** and **FIFO depth**.
- Correct **full** and **empty** flag generation.
- Support **almost-full** and **almost-empty** thresholds for early warnings.
- Efficient use of **FPGA block RAM resources**.
- Provide **functional testbench** to validate read/write behavior.

---

## Approach
1. **FIFO Memory Design**
   - Implemented as a **register array** (`fifo`).
   - Data is written at `wr_ptr` and read from `rd_ptr`.

2. **Pointer Management**
   - Separate **write pointer** and **read pointer** with wrap-around logic.
   - Pointer width determined by `$clog2(FIFO_DEPTH)`.

3. **Counter-Based Status Flags**
   - `count` tracks the number of elements in FIFO.
   - `full` asserted when `count == FIFO_DEPTH - 1`.
   - `empty` asserted when `count == 0`.
   - `almost_full` and `almost_empty` triggered when thresholds are reached.

4. **Simultaneous Read/Write**
   - If both `wr_en` and `rd_en` are asserted:
     - Both pointers update simultaneously.
     - Count remains unchanged (data passes through efficiently).

5. **Testbench Features**
   - Generates **clock and reset**.
   - Performs multiple scenarios:
     - Write sequence.
     - Partial readback.
     - Write until full.
     - Read until empty.
   - Displays results with `$display`.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Compile `sync_fifo.sv` and `tb_lab7a.sv` in **QuestaSim**.
- Run the testbench.
- Observe:
  - Data flow between write and read operations.
  - Proper assertion of `full`, `empty`, `almost_full`, and `almost_empty` flags.
  - Counter updates as FIFO is written and read.

### Synthesis
- Import RTL files into **Xilinx Vivado**.
- Run synthesis and implementation.
- Confirm efficient **BRAM inference** for large depths.

---

## Results
Simulation verifies FIFO functionality:

1. **Write Phase**
   - 10 values successfully written into FIFO.
   - `almost_full` flag asserted near threshold.

2. **Read Phase**
   - 5 values read back correctly.
   - `almost_empty` asserted as FIFO neared empty state.

3. **Full Condition**
   - FIFO filled to maximum capacity.
   - `full` flag asserted, blocking further writes.

4. **Empty Condition**
   - FIFO completely drained.
   - `empty` flag asserted, blocking further reads.

5. **Simultaneous R/W**
   - Data passes through while maintaining correct count.

- Simulation Waveform 
	Inputs = Blue Signals.
	Outputs = Yellow Signals.
