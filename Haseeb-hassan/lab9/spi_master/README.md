# SPI Master Controller - Lab 9

## Problem Description
This lab implements a complete SPI (Serial Peripheral Interface) master controller that enables communication with multiple SPI slave devices. The design supports all four SPI modes (0-3) with configurable clock polarity (CPOL) and clock phase (CPHA), handles full-duplex data transmission and reception, manages up to 4 slave devices through individual chip select signals, and provides configurable SPI clock generation with programmable divider values. The system includes proper handshaking with busy/done status signals and supports back-to-back transfers with automatic slave selection and data management.

## Approach
The SPI master is implemented using **modular design** with the following key components:

* **SPI Clock Generator**: Generates SPI clock from system clock with configurable frequency division and CPOL support
* **Finite State Machine (FSM)**: Controls SPI transfer sequence through states: IDLE, LOAD, TRANSFER, and FINISH
* **Bit Counter**: Tracks transmitted/received bits (counts 0 to 8) to determine when 8-bit transfer is complete
* **Dual Shift Registers**: Separate posedge and negedge shift registers for MOSI data transmission based on SPI mode
* **Dual Sample Registers**: Separate posedge and negedge sample registers for MISO data reception based on SPI mode
* **Slave Select Logic**: Manages chip select signals for up to 4 slaves with active-low assertion during transfers
* **SPI Mode Support**: Implements all four SPI modes with proper clock polarity and phase timing relationships
* **Modular Architecture**: Separates clock generation, counting, shifting, sampling, and control logic into distinct modules

The design follows standard SPI protocol where master generates clock, controls chip select, transmits data on MOSI, and receives data on MISO. The FSM coordinates all modules to ensure proper sequencing based on selected SPI mode.

## Folder Structure

```
lab9/
├── counter.sv                            # 4-bit counter (counts 0-8) for bit tracking
├── shiftReg_posedge.sv                   # Posedge-triggered shift register for MOSI
├── shiftReg_negedge.sv                   # Negedge-triggered shift register for MOSI  
├── smpleReg_posedge.sv                   # Posedge-triggered sample register for MISO
├── smpleReg_negedge.sv                   # Negedge-triggered sample register for MISO
├── slave_sel.sv                          # Slave select logic for 4 slaves
├── spiClk_generator.sv                   # SPI clock generator with CPOL support
├── fsm_spi.sv                            # SPI master finite state machine
├── top_module.sv                         # Top-level SPI master integration
├── tb_spi_master.sv                      
├── documentation/
│   ├── block_diagram               
│   └── modes 
        state_diagram                
└── README.md                            
```

## How to Run

### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

**Using ModelSim/QuestaSim:**
```bash
# Compile the design and testbench
vlog counter.sv shiftReg_posedge.sv shiftReg_negedge.sv smpleReg_posedge.sv smpleReg_negedge.sv slave_sel.sv spiClk_generator.sv fsm_spi.sv top_module.sv tb_spi_master.sv

# Start simulation
vsim tb_spi_master

# Run the simulation
run -all
```

**Using Vivado:**
```bash
# Create new project and add source files
# Set tb_spi_master as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests all four SPI modes (0-3) with different data patterns and slave selections, verifying proper clock generation, data transmission/reception timing, and slave select management, then finishes automatically.

## Examples

### Test Case 1: System Reset and Initialization
* **Input**: rst_n = 0, then rst_n = 1 after 50 time units
* **Expected Output**: busy = 0, transfer_done = 0, spi_cs_n = 4'b1111 (all slaves deselected), spi_clk idle state

### Test Case 2: SPI Mode 0 Configuration (CPOL=0, CPHA=0)
* **Input**: cpol = 0, cpha = 0, clk_div = 16'd8
* **Expected Output**: SPI clock idles low, data sampled on rising edge, data shifted on falling edge

### Test Case 3: SPI Mode 0 Transfer Initiation
* **Input**: tx_data = 8'h55, slave_sel = 2'b00, start_transfer = 1 for 20 time units
* **Expected Output**: busy = 1, spi_cs_n = 4'b1110 (slave 0 selected), FSM enters LOAD state

### Test Case 4: Data Loading Phase
* **Input**: FSM in LOAD state
* **Expected Output**: load_en = 1, shift register loaded with tx_data, sample register prepared

### Test Case 5: Transfer Phase - Bit 0 Transmission
* **Input**: FSM enters TRANSFER state, first SPI clock cycle
* **Expected Output**: MOSI = MSB of tx_data, MISO sampled, counter = 1

### Test Case 6: Transfer Phase - Continue Data Bits
* **Input**: Subsequent SPI clock cycles in TRANSFER state
* **Expected Output**: MOSI shifts through tx_data bits (MSB first), MISO continuously sampled, counter increments

### Test Case 7: Transfer Complete Detection
* **Input**: Counter reaches 8 (all bits transferred)
* **Expected Output**: count_done = 1, FSM transitions to FINISH state

### Test Case 8: Transfer Completion
* **Input**: FSM in FINISH state
* **Expected Output**: transfer_done = 1, busy = 0, rx_data contains received data, spi_cs_n = 4'b1111

### Test Case 9: SPI Mode 1 Configuration (CPOL=0, CPHA=1)
* **Input**: cpol = 0, cpha = 1, tx_data = 8'hAA, slave_sel = 2'b01
* **Expected Output**: SPI clock idles low, data shifted on rising edge, data sampled on falling edge, slave 1 selected

### Test Case 10: SPI Mode 2 Configuration (CPOL=1, CPHA=0)
* **Input**: cpol = 1, cpha = 0, tx_data = 8'hCC, slave_sel = 2'b10
* **Expected Output**: SPI clock idles high, data sampled on falling edge, data shifted on rising edge, slave 2 selected

### Test Case 11: SPI Mode 3 Configuration (CPOL=1, CPHA=1)
* **Input**: cpol = 1, cpha = 1, tx_data = 8'h33, slave_sel = 2'b11
* **Expected Output**: SPI clock idles high, data shifted on falling edge, data sampled on rising edge, slave 3 selected

### Test Case 12: Clock Divider Functionality
* **Input**: clk_div = 16'd8, 50MHz system clock
* **Expected Output**: SPI clock frequency = 50MHz / (2 × 8) = 3.125MHz

### Test Case 13: Multiple Slave Selection
* **Input**: Different slave_sel values (2'b00, 2'b01, 2'b10, 2'b11)
* **Expected Output**: Corresponding spi_cs_n patterns (4'b1110, 4'b1101, 4'b1011, 4'b0111)

### Test Case 14: Full-Duplex Operation Verification
* **Input**: Transmit known pattern while receiving random MISO data
* **Expected Output**: MOSI transmits correct pattern, rx_data captures MISO data, simultaneous operation

### Test Case 15: Back-to-Back Transfer Support
* **Input**: Multiple consecutive start_transfer pulses with different configurations
* **Expected Output**: Each transfer completes properly with correct busy/done handshaking