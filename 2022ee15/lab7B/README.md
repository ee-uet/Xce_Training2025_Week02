# Asynchronous FIFO (Clock Domain Crossing)

## Problem
The goal of this task is to design and verify an **Asynchronous FIFO** that allows safe data transfer between two different clock domains. Traditional FIFOs assume a single clock, but in many SoC and FPGA systems, data must cross boundaries between independent clock regions. This requires careful handling to avoid metastability, synchronization issues, and incorrect full/empty flag detection.

## Approach
The design uses the following techniques:
- **Gray Code Pointers:** Write and read pointers are maintained in binary and converted to Gray code for safe synchronization across domains.
- **Two-Stage Synchronizers:** To mitigate metastability, pointers crossing clock domains are passed through 2-flop synchronizers.
- **Full/Empty Detection:**  
  - *Full:* Occurs when the write pointer equals the read pointer with inverted MSB.  
  - *Empty:* Occurs when the read pointer equals the synchronized write pointer.
- **Memory Array:** A dual-port memory is inferred, enabling simultaneous read and write operations.
- **Reset Handling:** Asynchronous resets ensure proper initialization across both clock domains.

The **testbench** drives random data into the FIFO, writes a sequence of values, and reads them back to verify correct operation under mismatched clock frequencies.

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Use **QuestaSim** to compile and simulate `async_fifo.sv` along with `tb_lab7b.sv`.
- Observe write and read operations in the transcript and waveform viewer.

### Synthesis
- Import `async_fifo.sv` into **Vivado**.
- Run synthesis and implementation targeting your FPGA device.

## Results
- The FIFO correctly stores and retrieves data across different clock domains.  
- The `full` and `empty` flags are accurately generated without glitches.  
- Simulation demonstrates successful handling of asynchronous clocks (100 MHz write, ~71 MHz read).  
- The testbench prints out write and read transactions, confirming correct data integrity.  

- Simulation Waveform:
	Inputs = Blue Signals.
	Outputs = Yellow Signals
	
