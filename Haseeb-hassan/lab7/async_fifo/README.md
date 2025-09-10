# Asynchronous FIFO - Lab 7

## Problem Description
This lab implements an asynchronous FIFO (First In, First Out) buffer that operates across different clock domains, allowing data to be written and read using independent clock signals. The design handles the critical challenge of clock domain crossing by using Gray code pointers and synchronizers to prevent metastability and ensure reliable data transfer between different clock frequencies. The FIFO provides separate reset signals for write and read domains, enabling independent control of each clock domain while maintaining data integrity during asynchronous operations.

## Approach
The asynchronous FIFO is implemented using **dual-clock domain design** with the following key components:

* **Dual-Clock Operation**: Separate write clock (`wr_clk`) and read clock (`rd_clk`) operating at different frequencies
* **Gray Code Pointers**: Converts binary pointers to Gray code to ensure only one bit changes at a time during clock domain crossing
* **Synchronizer Modules**: Two-stage flip-flop synchronizers to safely transfer Gray code pointers across clock domains
* **Binary to Gray Conversion**: Converts binary pointers to Gray code for safe synchronization
* **Gray to Binary Conversion**: Converts synchronized Gray code pointers back to binary for comparison logic
* **Independent Reset Logic**: Separate active-low reset signals (`w_rst_n`, `r_rst_n`) for each clock domain
* **Full/Empty Detection**: Compares synchronized pointers to detect full and empty conditions safely across clock domains
* **Memory Array**: Dual-port memory accessed by lower address bits of pointers

The design uses Gray code encoding because only one bit changes between consecutive Gray code values, minimizing the risk of metastability during clock domain crossing. Synchronizers ensure that Gray code pointers are properly synchronized before being converted back to binary for comparison operations.

## Folder Structure

```
async_fifo/
├── async_fifo.sv                     
├── synchronizer.sv                      
├── tb_async_fifo.sv                      
├── documentation/
│   └── signal_description.txt
│   └── waves
│   └── truthtable.txt
│   └── datapath    
└── README.md                           
```

## How to Run

### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

**Using ModelSim/QuestaSim:**
```bash
# Compile the design and testbench
vlog async_fifo.sv synchronizer.sv tb_async_fifo.sv

# Start simulation
vsim tb_async_fifo

# Run the simulation
run -all
```

**Using Vivado:**
```bash
# Create new project and add source files
# Set tb_async_fifo as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests various scenarios including independent reset functionality, write operations at 100MHz, read operations at ~71MHz, cross-clock domain data transfer, and boundary conditions, then finishes automatically.

## Examples

### Test Case 1: Independent Reset Functionality
* **Input**: w_rst_n = 0, r_rst_n = 0
* **Expected Output**: wr_ptr = 0, rd_ptr = 0, empty = 1, full = 0

### Test Case 2: Reset Release and Initialization
* **Input**: w_rst_n = 1, r_rst_n = 1 (after 30ns delay)
* **Expected Output**: FIFO ready for operation, empty = 1

### Test Case 3: First Write Operation (Data = 1)
* **Input**: @(posedge wr_clk), wr_data = 1, wr_en = 1
* **Expected Output**: Data stored in mem[0], wr_ptr = 1, empty = 0

### Test Case 4: Sequential Writes (8 operations)
* **Input**: wr_data increments 1-8, wr_en = 1 for 8 clock cycles
* **Expected Output**: 8 data elements stored, wr_ptr = 8, empty = 0

### Test Case 5: First Read Operation
* **Input**: @(posedge rd_clk), rd_en = 1 (after 50ns delay)
* **Expected Output**: rd_data = 1, rd_ptr = 1

### Test Case 6: Sequential Reads (5 operations)
* **Input**: rd_en = 1 for 5 read clock cycles
* **Expected Output**: rd_data = 1,2,3,4,5 in sequence, rd_ptr = 5

### Test Case 7: Fill FIFO to Capacity
* **Input**: wr_data increments 9-24, wr_en = 1 for 16 clock cycles
* **Expected Output**: FIFO becomes full, full = 1, wr_ptr = 24 (wrapped)

### Test Case 8: Write Attempt When Full
* **Input**: wr_en = 1, full = 1
* **Expected Output**: Write ignored, FIFO remains full

### Test Case 9: Clock Domain Crossing Verification
* **Input**: Write at 100MHz (10ns period), Read at ~71MHz (14ns period)
* **Expected Output**: Data successfully transferred between clock domains without corruption

### Test Case 10: Gray Code Synchronization
* **Input**: Pointer changes across clock domains
* **Expected Output**: Gray code pointers synchronized properly, no metastability issues

### Test Case 11: Empty Detection After Reads
* **Input**: Continue reading until FIFO empty
* **Expected Output**: empty = 1 when rd_ptr catches up to wr_ptr