# UART Transmitter - Lab 8

## Problem Description
This lab implements a complete UART (Universal Asynchronous Receiver-Transmitter) transmitter system that converts parallel data into serial transmission format following the standard UART protocol. The design transmits 8-bit data bytes with a start bit (0), 8 data bits (LSB first), and a stop bit (1) at a configurable baud rate. The system includes a clock divider to generate the appropriate baud rate from the system clock, a finite state machine to control the transmission sequence, a bit counter to track transmitted bits, and a shift register to serialize the parallel data. The transmitter provides ready/busy status signals and supports back-to-back transmissions with proper handshaking.

## Approach
The UART transmitter is implemented using **modular design** with the following key components:

* **Clock Generator**: Divides the system clock (50MHz) to generate baud rate clock (115200 Hz) using parameterizable frequency division
* **Finite State Machine (FSM)**: Controls transmission sequence through states: IDLE, LOAD, START_BIT, DATA_BITS, and STOP_BIT
* **Bit Counter**: Tracks the number of data bits transmitted (counts 0 to 8) to determine when data transmission is complete
* **Shift Register**: Serializes 8-bit parallel data by shifting right and outputting LSB first, with automatic stop bit insertion
* **Handshaking Protocol**: Provides tx_ready and tx_busy signals for flow control and transmission status indication
* **Mealy FSM Design**: Uses combinational output logic that responds immediately to state transitions for precise timing control
* **Modular Architecture**: Separates clock generation, counting, shifting, and control logic into distinct modules for clarity and reusability

The design follows standard UART protocol timing where each bit is transmitted for exactly one baud period. The FSM coordinates all modules to ensure proper sequencing: load data, transmit start bit, shift out 8 data bits (LSB first), then transmit stop bit before returning to idle state.

## Folder Structure

```
uart_tx/
├── clk_generator.sv                      
├── counter.sv                            
├── shift_reg.sv                          
├── uart_tx_fsm.sv                        
├── top_module.sv                       
├── tb_uart_tx.sv                         
├── documentation/
│   ├── fsm_truthtable.txt                
│   └── signal_description.txt
│   ├── fsm
│   ├── datapath
│   ├── waves               
└── README.md                            
```

## How to Run

### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

**Using ModelSim/QuestaSim:**
```bash
# Compile the design and testbench
vlog clk_generator.sv counter.sv shift_reg.sv uart_tx_fsm.sv top_module.sv tb_uart_tx.sv

# Start simulation
vsim tb_uart_tx

# Run the simulation
run -all
```

**Using Vivado:**
```bash
# Create new project and add source files
# Set tb_uart_tx as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests the complete UART transmission sequence including system initialization, data loading, serial bit transmission timing, and ready/busy status transitions, then finishes automatically.

## Examples

### Test Case 1: System Reset and Initialization
* **Input**: rst_n = 0, then rst_n = 1 after 50 time units
* **Expected Output**: tx_ready = 1, tx_busy = 0, tx_serial = 1 (idle high), all internal counters reset

### Test Case 2: Wait for System Ready
* **Input**: wait(tx_ready) after 100 time unit delay
* **Expected Output**: tx_ready = 1 (system ready for transmission), tx_serial = 1 (idle state)

### Test Case 3: Initiate Data Transmission
* **Input**: tx_data = 8'h55 (binary: 01010101), tx_valid = 1 for 20 time units
* **Expected Output**: tx_ready = 0, tx_busy = 1, FSM transitions to LOAD state

### Test Case 4: Start Bit Transmission
* **Input**: FSM enters START_BIT state after LOAD
* **Expected Output**: tx_serial = 0 (start bit), counter begins counting, shift register loaded

### Test Case 5: Data Bit 0 Transmission (LSB First)
* **Input**: FSM in DATA_BITS state, first bit transmission
* **Expected Output**: tx_serial = 1 (bit 0 of 0x55), counter = 1, shift register shifts right

### Test Case 6: Data Bit 1 Transmission
* **Input**: Second data bit transmission
* **Expected Output**: tx_serial = 0 (bit 1 of 0x55), counter = 2

### Test Case 7: Data Bit 2 Transmission
* **Input**: Third data bit transmission
* **Expected Output**: tx_serial = 1 (bit 2 of 0x55), counter = 3

### Test Case 8: Data Bit 3 Transmission
* **Input**: Fourth data bit transmission
* **Expected Output**: tx_serial = 0 (bit 3 of 0x55), counter = 4

### Test Case 9: Continue Data Bits 4-7
* **Input**: Remaining data bits transmission
* **Expected Output**: tx_serial follows pattern 1,0,1,0 (bits 4-7 of 0x55), counter increments to 8

### Test Case 10: Counter Done Signal
* **Input**: counter reaches count 8 (all data bits transmitted)
* **Expected Output**: count_done = 1 (one cycle pulse), FSM transitions to STOP_BIT

### Test Case 11: Stop Bit Transmission
* **Input**: FSM enters STOP_BIT state
* **Expected Output**: tx_serial = 1 (stop bit), transmission completing

### Test Case 12: Transmission Complete
* **Input**: FSM returns to IDLE state after stop bit
* **Expected Output**: tx_ready = 1, tx_busy = 0, system ready for next transmission

### Test Case 13: Complete UART Frame Verification
* **Input**: Complete transmission of 0x55
* **Expected Serial Output**: Start(0) + Data(10101010) + Stop(1) = "01010101 0 1"

### Test Case 14: Baud Rate Timing
* **Input**: 50MHz system clock with 115200 baud rate
* **Expected Output**: Each bit transmitted for 434 system clock cycles (div_clk period)