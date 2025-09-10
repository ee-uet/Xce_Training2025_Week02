# SRAM Controller - Lab 6

## Problem Description
This lab implements a memory controller for interfacing with external SRAM chips. The controller manages read and write operations to 32K x 16-bit SRAM using proper timing and control signals. It provides a CPU-side interface with ready/request handshaking and handles the SRAM-side signals including chip enable, output enable, and write enable. The controller uses a bidirectional data bus with tristate control for read/write operations and includes internal registers for address and data latching.

## Approach
The SRAM controller uses a **4-state FSM with separate datapath architecture**:

* **4-State FSM Controller**: IDLE → READ/WRITE → DONE → IDLE managing operation sequencing  
* **Datapath Registers**: Separate address, write data, and read data latches with control signals
* **Bidirectional Bus Control**: Tristate buffer management for SRAM data bus during read/write
* **Control Signal Generation**: FSM generates timing signals for SRAM chip (CE, OE, WE)
* **CPU Interface**: Ready signal indicates when controller accepts new requests
* **Hierarchical Design**: FSM and datapath modules integrated in top-level wrapper

The FSM controls register latching and SRAM timing while the datapath handles data flow and bus management. Read operations latch address, enable SRAM outputs, and capture data. Write operations latch address/data, drive the bus, and enable SRAM writes.

## Folder Structure
```
lab6/
├── sram_top.sv                         
├── sram_fsm.sv                         
├── sram_datapath.sv                    
├── tb_sram_top.sv    
├── documentation
    ├── waves                  
    ├── fsm_truthtables.txt                
    ├── signal_description.txt              
    ├── simple_datapath.txt  
    ├── fsm               
└── README.md                        
```

## How to Run
### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps
Using ModelSim/QuestaSim:
```bash
# Compile design and testbench
vlog sram_top.sv tb_sram_top.sv

# Start simulation
vsim tb_sram_top

# Run simulation
run -all
```

Using Vivado:
```bash
# Create project and add all .sv files
# Set tb_sram_top as top module
# Run behavioral simulation
```

The testbench includes a behavioral SRAM model and tests basic write operation with address=0x1234 and data=0xABCD.

## Examples

### Test Sequence
* **Reset Phase**: rst_n=0 for 20ns, then release reset and wait 20ns
* **Write Test**: Set address=0x1234, write_data=0xABCD, pulse write_req for 10ns
* **Completion**: Wait 100ns for operation completion and observe SRAM memory update

The testbench runs for approximately 150ns total simulation time. Monitor ready signal, SRAM control signals (sram_ce_n, sram_oe_n, sram_we_n), and the internal SRAM memory model to verify correct write opera