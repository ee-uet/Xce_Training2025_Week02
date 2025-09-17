# Synchronous FIFO in SystemVerilog

## Problem Statement

This project implements a Synchronous FIFO (First In, First Out) buffer that enables efficient data buffering within a single clock domain. Synchronous FIFOs are essential components in digital systems for rate matching, data streaming, pipeline buffering, and communication interfaces where producer and consumer operate at different rates but share the same clock.

The FIFO needs to:
- Provide parameterizable data width and depth for flexible applications
- Support simultaneous read and write operations
- Generate accurate status flags (full, empty, almost_full, almost_empty)
- Maintain data integrity with proper pointer management
- Provide real-time count information for system monitoring
- Handle edge cases like simultaneous read/write when near full/empty
- Support configurable threshold levels for almost_full/almost_empty flags

## Approach

### Design Architecture

The Synchronous FIFO is implemented using SystemVerilog with the following parameterizable design:

**Parameters:**
- `DATA_WIDTH = 8` - Configurable data bus width
- `FIFO_DEPTH = 16` - Configurable FIFO depth (number of entries)
- `ALMOST_FULL_THRESH = 14` - Threshold for almost_full flag
- `ALMOST_EMPTY_THRESH = 2` - Threshold for almost_empty flag

**Inputs:**
- `clk` - System clock
- `rst_n` - Active-low asynchronous reset
- `wr_en` - Write enable
- `wr_data[DATA_WIDTH-1:0]` - Write data input
- `rd_en` - Read enable

**Outputs:**
- `rd_data[DATA_WIDTH-1:0]` - Read data output
- `full` - Full flag (no more writes allowed)
- `empty` - Empty flag (no more reads allowed)
- `almost_full` - Almost full warning flag
- `almost_empty` - Almost empty warning flag
- `count[$clog2(FIFO_DEPTH):0]` - Current number of entries

### Implementation Strategy

**Memory Structure:**
```systemverilog
logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;
```
- Circular buffer implementation using memory array
- Separate read and write pointers for independent access
- Automatic wrap-around when pointers reach FIFO_DEPTH-1

**Pointer Management:**
```systemverilog
// Write pointer advancement
if (wr_ptr == FIFO_DEPTH-1)
    wr_ptr <= '0;
else
    wr_ptr <= wr_ptr + 1;
```
- Circular pointer arithmetic for efficient memory utilization
- Independent read and write pointer control
- Automatic rollover at memory boundaries

**Count Tracking:**
The FIFO maintains an accurate count using case-based logic:
```systemverilog
case ({wr_en && !full, rd_en && !empty})
    2'b10: count <= count + 1;  // Write only
    2'b01: count <= count - 1;  // Read only
    default: count <= count;    // Hold or simultaneous read/write
endcase
```

**Status Flag Generation:**
```systemverilog
empty        = (count == 0);
full         = (count == FIFO_DEPTH);
almost_empty = (count <= ALMOST_EMPTY_THRESH);
almost_full  = (count >= ALMOST_FULL_THRESH);
```

### Key Design Features

**Simultaneous Operations:**
- Supports simultaneous read and write when not full and not empty
- Count remains stable during simultaneous operations
- No data corruption during concurrent access

**Protection Logic:**
- Write operations ignored when FIFO is full
- Read operations ignored when FIFO is empty
- Prevents overflow and underflow conditions

**Configurable Thresholds:**
- Programmable almost_full and almost_empty levels
- Early warning system for buffer management
- Supports flow control implementations

## How to Run

Run the simulation on QuestaSim. The testbench file `SyncFIFO_tb.sv` includes a comprehensive reference model and tests write operations, read operations, and mixed read/write scenarios.

## Examples

### Test Sequence Analysis

The testbench performs three main test phases with a reference model for verification:

**Test Phase 1: Sequential Write Operations**
```
Operation: Write 8 random values (0-255)
Purpose: Test basic write functionality and status flags
Expected Behavior:
- count increments from 0 to 8
- empty flag deasserts after first write
- almost_empty flag behavior based on threshold (2)
- Data stored in circular buffer memory
```

**Sample Write Sequence:**
```
WRITE: A3 (size=1) - First write, empty flag clears
WRITE: 7F (size=2) - Below almost_empty threshold
WRITE: C2 (size=3) - Above almost_empty threshold
...
WRITE: 45 (size=8) - Final write in sequence
```

**Test Phase 2: Sequential Read Operations**
```
Operation: Read 4 values
Purpose: Verify FIFO ordering and read functionality
Expected Behavior:
- Data read in FIFO order (first written, first read)
- count decrements from 8 to 4
- Read data matches reference model
- Status flags update correctly
```

**Sample Read Sequence:**
```
READ: A3 (size=7) - First written value read first
READ: 7F (size=6) - Second written value
READ: C2 (size=5) - Third written value  
READ: [next] (size=4) - Fourth value, maintaining FIFO order
```

**Test Phase 3: Mixed Read/Write Operations**
```
Operation: 10 cycles of random read/write combinations
Purpose: Test simultaneous operations and edge cases
Behavior:
- Random write enable (when not full)
- Random read enable (when not empty)  
- Count tracking during mixed operations
- Data integrity verification
```

### Expected Test Results

**Write Phase Results:**
- All 8 write operations complete successfully
- count reaches 8 after write sequence
- No data loss or corruption
- Status flags reflect correct buffer state

**Read Phase Results:**
- All 4 read operations return correct data
- FIFO ordering maintained (first-in, first-out)
- count decrements properly (8→4)
- Reference model matches DUT output

**Mixed Operation Results:**
- Simultaneous read/write handled correctly
- Count tracking remains accurate
- No data corruption during concurrent access
- Buffer state consistency maintained

### Timing Characteristics

**Write Operation:**
- Data latched on positive clock edge when wr_en=1 and !full
- Pointer advancement synchronous with write
- Status flags update immediately (combinational)

**Read Operation:**
- Data available on next clock edge after rd_en assertion
- Read pointer advancement synchronous with read
- Pipeline latency: 1 clock cycle

**Status Flags:**
- Combinational logic provides immediate status updates
- Flags valid within same clock cycle as count changes
- No additional latency for flag generation

### Key Features Demonstrated

**Data Integrity:**
- Reference model comparison ensures correct FIFO behavior
- All written data matches read data in proper order
- No corruption during mixed read/write operations

**Flow Control:**
- almost_full flag provides early warning at threshold 14/16
- almost_empty flag indicates low buffer state at threshold 2/16
- Proper full/empty protection prevents overflow/underflow

**Performance Features:**
- Single-cycle write and read operations
- Simultaneous read/write capability
- Efficient circular buffer implementation
- Real-time count monitoring

**Robustness:**
- Reset functionality clears all state
- Protected operations prevent data corruption
- Configurable parameters for different applications

### Application Examples

**Data Streaming:**
- Audio/video buffer management
- Network packet buffering
- Sensor data collection

**Rate Matching:**
- Producer/consumer rate differences
- Burst data handling
- Pipeline stage buffering

**Communication Interfaces:**
- UART transmit/receive buffers
- SPI data staging
- Inter-module data transfer

This implementation provides a robust, parameterizable synchronous FIFO suitable for a wide range of applications requiring reliable data buffering with comprehensive status monitoring and flow control capabilities.