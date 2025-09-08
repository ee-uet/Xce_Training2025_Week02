# Synchronous FIFO - Lab 7

## Problem Description
This lab implements a parameterizable synchronous FIFO (First In, First Out) buffer that allows data to be written to and read from a circular buffer in a synchronized manner. The FIFO provides essential control signals including full/empty status flags and almost-full/almost-empty indicators for flow control. The design supports configurable data width, FIFO depth, and threshold values for the almost-full and almost-empty conditions. The FIFO operates on a single clock domain and uses separate read and write pointers to manage data flow efficiently.

## Approach
The synchronous FIFO is implemented using **sequential logic** with the following key components:

* **Dual-Port Memory Array**: Uses a memory array `mem[FIFO_DEPTH-1:0]` to store data elements
* **Pointer Management**: Maintains separate write pointer (`w_ptr`) and read pointer (`r_ptr`) that wrap around circularly
* **Counter-Based Status**: Uses a `count` register to track the number of elements stored, enabling accurate status flag generation
* **Parameterizable Design**: Supports configurable data width, FIFO depth, and threshold parameters
* **Status Flag Generation**: Provides `full`, `empty`, `almost_full`, and `almost_empty` signals for external flow control
* **Synchronous Operations**: All operations are synchronized to the positive edge of the clock with active-low reset

The design uses separate always_ff blocks for data operations and status flag updates. The write operation stores data at the current write pointer location and increments both the pointer and count. The read operation outputs data from the current read pointer location and increments the pointer while decrementing the count. Status flags are updated based on the current count value compared to the FIFO depth and threshold parameters.

## Folder Structure

```
sync_fifo/
├── sync_fifo.sv                      
├── tb_sync_fifo.sv                       
├── documentation/
│   ├── fifo_op_truthtable.txt           
│   └── signal_description.txt
    └── waves
    └── basic_datapath            
└── README.md                            
```

## How to Run

### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps

**Using ModelSim/QuestaSim:**
```bash
# Compile the design and testbench
vlog sync_fifo.sv tb_sync_fifo.sv

# Start simulation
vsim tb_sync_fifo

# Run the simulation
run -all
```

**Using Vivado:**
```bash
# Create new project and add source files
# Set tb_sync_fifo as top module for simulation
# Run behavioral simulation
```

The testbench automatically tests various scenarios including reset functionality, basic read/write operations, almost-full/almost-empty conditions, full/empty boundary conditions, and attempts to read from empty or write to full FIFO, then finishes automatically.

## Examples

### Test Case 1: Reset Functionality
* **Input**: rst_n = 0
* **Expected Output**: count = 0, empty = 1, full = 0, almost_empty = 1, almost_full = 0, rd_data = 0

### Test Case 2: Write First Data Element
* **Input**: rst_n = 1, wr_en = 1, wr_data = 8'hAA, rd_en = 0
* **Expected Output**: count = 1, empty = 0, data stored in FIFO

### Test Case 3: Write Second Data Element
* **Input**: rst_n = 1, wr_en = 1, wr_data = 8'hBB, rd_en = 0
* **Expected Output**: count = 2, empty = 0, almost_empty = 1

### Test Case 4: Write Third Data Element
* **Input**: rst_n = 1, wr_en = 1, wr_data = 8'hCC, rd_en = 0
* **Expected Output**: count = 3, empty = 0, almost_empty = 0

### Test Case 5: Read First Data Element (FIFO Order)
* **Input**: rst_n = 1, wr_en = 0, rd_en = 1
* **Expected Output**: rd_data = 8'hAA, count = 2

### Test Case 6: Read Second Data Element
* **Input**: rst_n = 1, wr_en = 0, rd_en = 1
* **Expected Output**: rd_data = 8'hBB, count = 1

### Test Case 7: Fill FIFO to Almost Full (14 elements)
* **Input**: rst_n = 1, wr_en = 1 (repeated 12 times), incremental wr_data
* **Expected Output**: count = 14, almost_full = 1, full = 0

### Test Case 8: Fill FIFO to Full (16 elements)
* **Input**: rst_n = 1, wr_en = 1, wr_data = 8'hFF
* **Expected Output**: count = 16, full = 1, almost_full = 1

### Test Case 9: Write Attempt When Full
* **Input**: rst_n = 1, wr_en = 1, wr_data = 8'h11, full = 1
* **Expected Output**: Write ignored, count = 16, full = 1 (unchanged)

### Test Case 10: Empty FIFO Completely
* **Input**: rst_n = 1, rd_en = 1 (repeated 16 times)
* **Expected Output**: count = 0, empty = 1, almost_empty = 1

### Test Case 11: Read Attempt When Empty
* **Input**: rst_n = 1, rd_en = 1, empty = 1
* **Expected Output**: Read ignored, count = 0, empty = 1 (unchanged)