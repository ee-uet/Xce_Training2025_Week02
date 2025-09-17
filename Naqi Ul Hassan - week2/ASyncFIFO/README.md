# Asynchronous FIFO in SystemVerilog

## Problem Statement

This project implements an Asynchronous FIFO (First In, First Out) buffer that enables safe data transfer between two different clock domains. Clock domain crossing is a critical challenge in digital design where data needs to be transferred between subsystems operating at different frequencies or phases.

The FIFO needs to:
- Handle write operations in one clock domain and read operations in another
- Prevent data corruption during clock domain crossing
- Generate accurate full and empty flags to prevent overflow and underflow
- Maintain data integrity without requiring external synchronization

## Approach

### Design Architecture

The Asynchronous FIFO is implemented using SystemVerilog with the following key components:

**Main Module (`ASyncFIFO.sv`):**
- Parameterizable width and depth
- Dual-clock operation (separate write and read clocks)
- Gray code pointers for safe clock domain crossing
- Full and empty flag generation

**Supporting Modules:**
- `B2G.sv` - Binary to Gray code converter
- `G2B.sv` - Gray to Binary code converter (for reference)
- `Syncgen.sv` - Two-stage synchronizer for clock domain crossing

### Key Design Features

**Gray Code Pointers:**
- Binary pointers are converted to Gray code to ensure only one bit changes at a time
- Eliminates metastability issues during clock domain crossing
- Enables safe comparison across clock domains

**Synchronization Strategy:**
- Write pointer (Gray) synchronized into read clock domain for empty flag generation
- Read pointer (Gray) synchronized into write clock domain for full flag generation
- Two flip-flop synchronizers minimize metastability risk

**Flag Generation:**
- **Empty Flag**: `rd_ptr_gray == wr_ptr_gray_sync_rdclk`
- **Full Flag**: `wr_ptr_gray == {~rd_ptr_gray_sync_wrclk[MSB:MSB-1], rd_ptr_gray_sync_wrclk[MSB-2:0]}`

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| WIDTH     | 8       | Data bus width in bits |
| DEPTH     | 16      | FIFO depth (number of entries) |

### Interface Signals

**Write Domain:**
- `wr_clk` - Write clock
- `wr_en` - Write enable
- `wr_data[WIDTH-1:0]` - Data to write
- `full` - Full flag output

**Read Domain:**
- `rd_clk` - Read clock
- `rd_en` - Read enable  
- `rd_data[WIDTH-1:0]` - Data read output
- `empty` - Empty flag output

**Common:**
- `rst_n` - Active-low asynchronous reset

## How to Run

Run the simulation on QuestaSim. The testbench file `ASyncFIFO_tb.sv` demonstrates the FIFO operation with different clock frequencies for write and read domains.

## Examples

### Test Scenario Analysis

The testbench demonstrates asynchronous operation with:
- **Write Clock**: 10ns period (100 MHz)
- **Read Clock**: 14ns period (~71.4 MHz)

### Test Sequence

1. **Reset Phase**: 
   - System reset for 3 time units
   - All pointers initialized to zero
   - Flags: `empty=1, full=0`

2. **Write Phase**:
   - Write 5 consecutive values: `0x0A, 0x14, 0x1E, 0x28, 0x32`
   - Each write occurs on `wr_clk` positive edge
   - `full` flag remains low (FIFO not full)
   - `empty` flag goes low after first write

3. **Read Phase**:
   - Read 5 values from FIFO
   - Each read occurs on `rd_clk` positive edge
   - Data retrieved in FIFO order: `0x0A, 0x14, 0x1E, 0x28, 0x32`
   - `empty` flag goes high after last read

### Expected Behavior

**Timing Relationships:**
```
Time 0-3:    Reset active, pointers cleared
Time 3+:     Reset released, ready for operation
Time 8+:     First write (wr_data = 0x0A)
Time 18+:    Second write (wr_data = 0x14)
...
Time 10+:    First read opportunity
Time 24+:    Second read opportunity
```

**Flag Behavior:**
- `empty` transitions: `1 → 0 → 1` (starts empty, has data, becomes empty)
- `full` remains `0` throughout test (FIFO never fills completely)

### Key Features Demonstrated

1. **Clock Domain Independence**: Write and read operations proceed independently at different rates
2. **Data Integrity**: All written data is read back correctly despite clock domain crossing
3. **Safe Flag Generation**: Full and empty flags accurately reflect FIFO status
4. **Metastability Prevention**: Gray code pointers and synchronizers prevent corruption
5. **Parameterizable Design**: WIDTH and DEPTH can be easily modified for different applications

### Design Verification Points

- **Functional Correctness**: Data written equals data read
- **Timing Safety**: No setup/hold violations across clock domains
- **Flag Accuracy**: Full/empty flags correctly prevent overflow/underflow
- **Reset Behavior**: Clean initialization of all state elements
- **Cross-Clock Synchronization**: Proper operation with different clock frequencies

This implementation provides a robust, parameterizable solution for asynchronous data buffering in multi-clock digital systems.