# AXI4-Lite Master/Slave - Lab 10

## Problem Description
This lab implements a complete AXI4-Lite communication system featuring a master and slave module connected through a standard AXI4-Lite interface. The design demonstrates the AXI4-Lite protocol implementation with separate read and write channels, each having their own address, data, and response phases. The master module converts simple CPU-style read/write requests into proper AXI4-Lite protocol transactions, while the slave module implements a 16-register memory-mapped register bank with configurable read-only registers. The system includes proper handshaking, address decoding, byte-level write strobing, and error response generation for invalid transactions.

## Approach
The AXI4-Lite system is implemented using **protocol-based communication** with the following key components:

* **AXI4-Lite Interface**: SystemVerilog interface with modports defining master and slave signal directions
* **Master FSM Design**: Separate finite state machines for write (W_IDLE, W_ADDR, W_DATA, W_RESP) and read (R_IDLE, R_ADDR, R_DATA) operations
* **Slave FSM Design**: Independent state machines for handling write and read transactions with proper handshaking
* **Register Bank**: 16 x 32-bit memory-mapped registers with configurable write permissions
* **Address Decoding**: Word-aligned address validation with range checking (0x00 to 0x3C)
* **Byte-Level Write Strobing**: Selective byte updating using wstrb signals for partial register writes
* **Error Response Generation**: SLVERR responses for invalid addresses or write attempts to read-only registers
* **Handshaking Protocol**: Full AXI4-Lite valid/ready handshaking for all channels

The design separates write and read operations into independent channels, allowing for concurrent processing. The master module provides a simple CPU interface while handling the complexity of AXI4-Lite protocol timing. The slave implements proper address decoding, supports partial writes through byte strobes, and generates appropriate error responses for protocol violations.

## Folder Structure

```
lab9/
├── axi4_lite_if.sv                      
├── axi4_lite_master.sv                   
├── axi4_lite_slave.sv                   
├── axi4_lite_top.sv                   
├── tb_axi4_lite.sv                       
├── documentation/
│   ├── adressdecode.txt           
│   └── channel_description.txt
│   ├── fsm_truthtbles.txt
│   ├── interface
│   ├── masterfsm_rough
│   ├── signal_description
│   ├──slavefsm_rough
│   ├── wave                 
└── README.md                          
```

## How to Run

### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

**Using ModelSim/QuestaSim:**
```bash
# Compile the design and testbench
vlog axi4_lite_if.sv axi4_lite_master.sv axi4_lite_slave.sv axi4_lite_top.sv tb_axi4_lite.sv

# Start simulation
vsim tb_axi4_lite

# Run the simulation
run -all
```

**Using Vivado:**
```bash
# Create new project and add source files
# Set tb_axi4_lite as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests various scenarios including reset functionality, basic write/read operations, address validation, byte strobing, and error response generation, then finishes automatically.

## Examples

### Test Case 1: System Reset
* **Input**: rst_n = 0
* **Expected Output**: All FSMs in idle state, register bank initialized with default values

### Test Case 2: System Initialization
* **Input**: rst_n = 1 (after 50ns), wait 100ns
* **Expected Output**: System ready for transactions, default register values loaded

### Test Case 3: Write to Address 0x00
* **Input**: write_addr = 32'h00000000, write_data = 32'h12345678, write_strb = 4'hF, write_req = 1
* **Expected Output**: write_done = 1, write_resp = 2'b00 (OKAY), register[0] = 32'h12345678

### Test Case 4: Read from Address 0x00
* **Input**: read_addr = 32'h00000000, read_req = 1
* **Expected Output**: read_done = 1, read_data = 32'h12345678, read_resp = 2'b00 (OKAY)

### Test Case 5: Write to Address 0x04
* **Input**: write_addr = 32'h00000004, write_data = 32'hAABBCCDD, write_strb = 4'hF, write_req = 1
* **Expected Output**: write_done = 1, write_resp = 2'b00 (OKAY), register[1] = 32'hAABBCCDD

### Test Case 6: Read from Address 0x04
* **Input**: read_addr = 32'h00000004, read_req = 1
* **Expected Output**: read_done = 1, read_data = 32'hAABBCCDD, read_resp = 2'b00 (OKAY)

### Test Case 7: AXI4-Lite Write Protocol Sequence
* **Input**: Master initiates write transaction
* **Expected Output**: awvalid→awready handshake, wvalid→wready handshake, bvalid→bready response

### Test Case 8: AXI4-Lite Read Protocol Sequence
* **Input**: Master initiates read transaction
* **Expected Output**: arvalid→arready handshake, rvalid→rready data transfer

### Test Case 9: Byte-Level Write Strobing (Conceptual)
* **Input**: write_strb = 4'b0101, write_data = 32'hAABBCCDD
* **Expected Output**: Only bytes 0 and 2 updated, bytes 1 and 3 preserved

### Test Case 10: Write to Read-Only Register (Conceptual)
* **Input**: write to register[1] (status register - read-only)
* **Expected Output**: write_resp = 2'b10 (SLVERR), register unchanged

### Test Case 11: Invalid Address Access (Conceptual)
* **Input**: read_addr = 32'h00000100 (out of range)
* **Expected Output**: read_resp = 2'b10 (SLVERR), read_data = 32'hDEADBEEF

### Test Case 12: Misaligned Address Access (Conceptual)
* **Input**: write_addr = 32'h00000002 (not word-aligned)
* **Expected Output**: write_resp = 2'b10 (SLVERR), write ignored