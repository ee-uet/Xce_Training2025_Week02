# UART Receiver - Lab 08

## Problem Description
This lab implements a complete UART (Universal Asynchronous Receiver-Transmitter) receiver system that converts serial data into parallel format following the standard UART protocol. The design receives serial data with a start bit (0), 8 data bits (LSB first), and a stop bit (1) at a configurable baud rate. The system includes a start bit detector to identify incoming transmissions, a clock divider for baud rate generation, a finite state machine to control the reception sequence, a bit counter to track received bits, and a shift register to deserialize the incoming data. The receiver provides ready/busy status signals, frame error detection for invalid stop bits, and supports continuous reception with proper synchronization.

## Approach
The UART receiver is implemented using **modular design** with the following key components:

* **Clock Generator**: Divides the system clock (50MHz) to generate baud rate clock (115200 Hz) for synchronized sampling
* **Bit Detector**: Monitors rx_serial for start bit detection (falling edge from idle high to start low)
* **Finite State Machine (FSM)**: Controls reception sequence through states: IDLE, START, and CHECK_ERROR
* **Bit Counter**: Counts received bits (0 to 9) including start bit, 8 data bits, and stop bit
* **Shift Register**: Deserializes incoming data by shifting in bits from MSB to LSB, sampling at negative clock edge for mid-bit timing
* **Frame Error Detection**: Validates stop bit to detect transmission errors and corrupted frames
* **Status Signaling**: Provides rx_ready and rx_busy signals for flow control and reception status indication

The design uses negative edge sampling (negedge div_clk) in the shift register to sample incoming bits at the middle of each bit period for optimal timing margin. The FSM coordinates all modules to ensure proper bit synchronization and error detection throughout the reception process.

## Folder Structure

```
uart_rx/
├── clk_generator.sv                    
├── bit_detector.sv                     
├── counter.sv                            
├── shift_reg.sv                         
├── uart_rx_fsm.sv                        
├── top_module.sv                         
├── tb_uart_rx.sv                         
├── documentation/
│   ├── fsm_truthtable.txt               
│   └── signal_description.txt  
│   └── datapath
│   └── fsm
│   └── waves             
└── README.md                           
```

## How to Run

### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

**Using ModelSim/QuestaSim:**
```bash
# Compile the design and testbench
vlog clk_generator.sv bit_detector.sv counter.sv shift_reg.sv uart_rx_fsm.sv top_module.sv tb_uart_rx.sv

# Start simulation
vsim tb_uart_rx

# Run the simulation
run -all
```

**Using Vivado:**
```bash
# Create new project and add source files
# Set tb_uart_rx as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests the complete UART reception sequence including start bit detection, serial bit sampling timing, parallel data reconstruction, stop bit validation, and ready/busy status transitions, then finishes automatically.

## Examples

### Test Case 1: System Reset and Initialization
* **Input**: rst_n = 0, then rst_n = 1 after 50 time units, rx_serial = 1 (idle high)
* **Expected Output**: rx_ready = 1, rx_busy = 0, frame_error = 0, all internal counters reset

### Test Case 2: Wait for System Ready
* **Input**: wait(rx_ready) after 100 time unit delay
* **Expected Output**: rx_ready = 1 (system ready for reception), FSM in IDLE state

### Test Case 3: Start Bit Detection
* **Input**: rx_serial = 0 (start bit begins), 868ns duration
* **Expected Output**: zero_detected = 1, rx_ready = 0, rx_busy = 1, FSM transitions to START

### Test Case 4: Data Bit 0 Reception (LSB First)
* **Input**: rx_serial = 1 for 868ns (bit 0 of 0x55)
* **Expected Output**: Bit sampled and shifted into register, counter increments

### Test Case 5: Data Bit 1 Reception
* **Input**: rx_serial = 0 for 868ns (bit 1 of 0x55)
* **Expected Output**: Second bit sampled and shifted, counter = 2

### Test Case 6: Data Bit 2 Reception
* **Input**: rx_serial = 1 for 868ns (bit 2 of 0x55)
* **Expected Output**: Third bit sampled and shifted, counter = 3

### Test Case 7: Data Bit 3 Reception
* **Input**: rx_serial = 0 for 868ns (bit 3 of 0x55)
* **Expected Output**: Fourth bit sampled and shifted, counter = 4

### Test Case 8: Continue Data Bits 4-7 Reception
* **Input**: rx_serial follows pattern 1,0,1,0 for bits 4-7 (remaining bits of 0x55)
* **Expected Output**: All data bits properly sampled and shifted, counter increments to 8

### Test Case 9: Stop Bit Reception
* **Input**: rx_serial = 1 for 868ns (stop bit)
* **Expected Output**: Stop bit sampled into shift_reg[8], counter reaches 9

### Test Case 10: Count Done Signal
* **Input**: Counter reaches count 9 (all bits received)
* **Expected Output**: count_done = 1 (one cycle pulse), FSM transitions to CHECK_ERROR

### Test Case 11: Frame Error Check (Valid Frame)
* **Input**: Stop bit = 1 (valid), start_check = 1
* **Expected Output**: frame_error = 0, rx_data = 8'h55, data successfully received

### Test Case 12: Reception Complete
* **Input**: FSM returns to IDLE state after error check
* **Expected Output**: rx_ready = 1, rx_busy = 0, system ready for next reception

### Test Case 13: Complete UART Frame Verification
* **Input**: Serial input "0 10101010 1" (start + data + stop)
* **Expected Output**: rx_data = 8'h55 (01010101 binary), frame_error = 0

### Test Case 14: Bit Timing Verification
* **Input**: Each bit held for 868ns (BIT_TIME parameter)
* **Expected Output**: Proper sampling at mid-bit timing, synchronized with baud rate clock

### Test Case 15: Frame Error Detection (Conceptual)
* **Input**: Invalid stop bit (rx_serial = 0 instead of 1)
* **Expected Output**: frame_error = 1, indicating corrupted transmission