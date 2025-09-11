# UART Transmitter

## Problem
The goal of this project is to design and verify a **UART Transmitter** that supports configurable baud rates, standard UART frame format, and integrates with a transmit FIFO. The UART transmitter must correctly serialize data bytes into asynchronous UART frames while managing FIFO and transmission states.

### Specifications
- Configurable baud rate: **9600, 19200, 38400, 115200**
- Frame format: **8-bit data, 1 start bit, 1 stop bit, optional parity**
- Transmit FIFO with configurable depth
- Status flags: **busy, full, empty**
- FSM-based controller for transmission
- Baud rate generator for precise timing

### Design Steps
1. Calculate baud rate generation and create timing diagram.  
2. Draw UART frame format (start, data, parity, stop).  
3. Design a transmit state machine (IDLE → LOAD → START_BIT → DATA_BITS → PARITY → STOP_BIT → IDLE).  
4. Integrate with FIFO for buffered transmission.  

---

## Approach
The design consists of the following modules:

- **`baud_rate`**: Generates transmission (`tick_tx`) and reception (`tick_rx`) ticks based on the configured baud rate.  
- **`fifo`**: Stores data bytes for transmission, provides flow control with full/empty and almost full/empty flags.  
- **`controller`**: Implements the transmit FSM, controlling when to load, transmit, and return to idle.  
- **`tx_datapath`**: Prepares the UART frame (start, data, parity, stop), shifts data out on each baud tick, and generates the serial TX output.  
- **`tx_top`**: Integrates baud rate generator, FIFO, controller, and datapath into a top-level transmitter design.  
- **`tb_tx_top`**: Testbench that applies reset, writes multiple bytes to the FIFO, and verifies transmission timing and serial output.

Key techniques:
- **Parity Bit**: Even parity is computed as the XOR of all data bits.  
- **FSM States**: IDLE, LOAD, TRANSMIT ensure proper sequencing.  
- **FIFO Integration**: Allows buffering of multiple bytes to smooth transmission bursts.  

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Compile and simulate `tx_top.sv` and its submodules with `tb_tx_top.sv` using **QuestaSim**.  
- Observe TX waveform and baud rate ticks in the transcript or waveform viewer.  

### Synthesis
- Import all design files into **Vivado**.  
- Run synthesis and implementation for your target FPGA board.  
- Connect TX pin to a serial-to-USB converter and verify using a terminal emulator (e.g., PuTTY) at the chosen baud rate.  

---

## Results
- **Simulation confirms correct UART transmission**  
- The transmitter correctly outputs start bit (`0`), data bits (LSB first), parity, and stop bits (`1`).  
- FIFO operation verified: multiple bytes (`0xFF`, `0x3C`, `0xF0`) are queued and transmitted sequentially.  
- Baud ticks are generated consistently at the configured baud rate (default: 115200).  
- Testbench logs indicate baud tick events and TX transitions, validating timing and correctness.

- Simulation Waveform:
	Inputs = Blue Signals (Read_data).
	Outputs = Yellow Signals (Tx_bits).
	States = Cyan Signals.