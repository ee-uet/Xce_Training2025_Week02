# SRAM Controller in SystemVerilog

## Problem Statement

This project implements a complete SRAM (Static Random Access Memory) controller that provides a bridge between a CPU interface and external SRAM memory. SRAM controllers are critical components in embedded systems and microprocessors where fast, reliable memory access is required for data storage and retrieval operations.

The SRAM controller needs to:
- Manage read and write operations to external SRAM memory
- Handle proper timing and control signal generation for SRAM interface
- Provide a simple CPU-side interface with handshaking protocols
- Control bidirectional data bus with tristate logic
- Implement proper state machine for sequential memory operations
- Support 32K x 16-bit memory addressing (15-bit address, 16-bit data)
- Generate appropriate control signals (chip enable, output enable, write enable)

## Approach

### Design Architecture

The SRAM controller uses a modular approach with three main components:

**Core Modules:**
- `Sram_fsm.sv` - Finite State Machine for control logic
- `Sram_datapath.sv` - Data path with registers and tristate control
- `Top.sv` - Integration module connecting FSM and datapath
- `Top_tb.sv` - Comprehensive testbench with SRAM model

### Finite State Machine Design

**State Definition:**
```systemverilog
typedef enum logic [1:0] {
    IDLE  = 2'b00,  // Ready for new requests
    READ  = 2'b01,  // Executing read operation
    WRITE = 2'b10,  // Executing write operation
    DONE  = 2'b11   // Transaction completion
} state_t;
```

**State Transitions:**
- **IDLE → READ**: When `read_req` is asserted
- **IDLE → WRITE**: When `write_req` is asserted  
- **READ → DONE**: After one cycle (read completion)
- **WRITE → DONE**: After one cycle (write completion)
- **DONE → IDLE**: Return to ready state

**Control Signal Generation:**
Each state generates specific control signals for datapath and SRAM:

| State | ready | latch_addr | latch_data | latch_read | drive_data_en | sram_ce_n | sram_oe_n | sram_we_n |
|-------|-------|------------|------------|------------|---------------|-----------|-----------|-----------|
| IDLE  | 1     | 0          | 0          | 0          | 0             | 1         | 1         | 1         |
| READ  | 0     | 1          | 0          | 1          | 0             | 0         | 0         | 1         |
| WRITE | 0     | 1          | 1          | 0          | 1             | 0         | 1         | 0         |
| DONE  | 1     | 0          | 0          | 0          | 0             | 1         | 1         | 1         |

### Datapath Implementation

**Register Set:**
- `addr_reg[14:0]` - Latched address register
- `write_reg[15:0]` - Latched write data register  
- `read_reg[15:0]` - Latched read data register

**Control Logic:**
- **Address Latch**: Captures CPU address when `latch_addr` is active
- **Write Data Latch**: Captures CPU write data when `latch_data` is active
- **Read Data Latch**: Captures SRAM data when `latch_read` is active
- **Tristate Control**: Drives SRAM data bus only during write operations

**Tristate Bus Management:**
```systemverilog
assign sram_data = (drive_data_en) ? write_reg : 'bz;
```

### Interface Specifications

**CPU-Side Interface:**
- `address[14:0]` - 15-bit memory address input
- `write_data[15:0]` - 16-bit write data input
- `read_data[15:0]` - 16-bit read data output
- `read_req` - Read operation request
- `write_req` - Write operation request  
- `ready` - Controller ready for new operations

**SRAM Interface:**
- `sram_addr[14:0]` - Address lines to SRAM
- `sram_data[15:0]` - Bidirectional data bus (inout)
- `sram_ce_n` - Chip enable (active low)
- `sram_oe_n` - Output enable (active low)
- `sram_we_n` - Write enable (active low)

## How to Run

Run the simulation on QuestaSim. The testbench file `Top_tb.sv` includes a complete SRAM model and demonstrates both read and write operations with proper timing verification.

## Examples

### Test Sequence Analysis

The testbench demonstrates a complete write-then-read sequence:

**Test Phase 1: System Initialization**
```
Time 0-3ns: rst_n = 0 (system reset)
Time 3ns: rst_n = 1 (system ready)
Initial State: FSM in IDLE, all registers cleared
```

**Test Phase 2: Write Operation**
```
Clock 1: write_req = 1, address = 0x0010, write_data = 0xABCD
Clock 2: write_req = 0 (request deasserted)
```

**Write Cycle Timing:**
- **Clock 1 → Clock 2**: FSM: IDLE → WRITE
  - `latch_addr = 1` → Address 0x0010 latched
  - `latch_data = 1` → Data 0xABCD latched  
  - `drive_data_en = 1` → Data bus driven with 0xABCD
  - `sram_ce_n = 0, sram_we_n = 0` → SRAM write enabled

- **Clock 2 → Clock 3**: FSM: WRITE → DONE
  - Write operation completes
  - SRAM memory[0x0010] = 0xABCD
  - `ready = 1` → Transaction done signal

**Test Phase 3: Read Operation**  
```
Clock 4: read_req = 1, address = 0x0010
Clock 5: read_req = 0 (request deasserted)
```

**Read Cycle Timing:**
- **Clock 4 → Clock 5**: FSM: IDLE → READ
  - `latch_addr = 1` → Address 0x0010 latched
  - `latch_read = 1` → SRAM data latched into read_reg
  - `drive_data_en = 0` → Data bus released (high impedance)
  - `sram_ce_n = 0, sram_oe_n = 0` → SRAM read enabled

- **Clock 5 → Clock 6**: FSM: READ → DONE  
  - Read operation completes
  - `read_data = 0xABCD` → Data available to CPU
  - `ready = 1` → Transaction done signal

### SRAM Model Behavior

**Testbench SRAM Model:**
```systemverilog
// 32K x 16 memory array
reg [15:0] mem [0:(1<<15)-1];

// Write operation (when ce_n=0, we_n=0)
if (!sram_ce_n && !sram_we_n)
    mem[sram_addr] <= sram_data;

// Read operation (when ce_n=0, oe_n=0, we_n=1)  
if (!sram_ce_n && !sram_oe_n && sram_we_n)
    sram_dout <= mem[sram_addr];
```

### Expected Results

**Write Verification:**
- Memory location 0x0010 should contain 0xABCD after write cycle
- FSM should return to IDLE state with ready=1

**Read Verification:**
- `read_data` output should show 0xABCD
- Console output: "Read Data from 0x0010 = 0xABCD"
- Confirms successful write-then-read operation

### Timing Characteristics

**Operation Latency:**
- **Write Operation**: 2 clock cycles (IDLE → WRITE → DONE)
- **Read Operation**: 2 clock cycles (IDLE → READ → DONE)  
- **Ready Signal**: Available in IDLE and DONE states

**Bus Control:**
- Data bus driven only during WRITE state
- Bus released to high impedance in all other states
- No bus contention issues

### Key Features Demonstrated

**FSM Control:**
- Clean state transitions with proper control signal generation
- Separate states for read and write operations
- Ready/done handshaking protocol

**Data Path Management:**
- Proper latching of address, write data, and read data
- Tristate bus control preventing conflicts
- Register-based data storage for timing isolation

**SRAM Interface Compliance:**
- Correct control signal timing (ce_n, oe_n, we_n)
- Proper setup and hold times
- Bidirectional data bus management

**System Integration:**
- Modular design with clear interface boundaries
- CPU-friendly request/ready protocol
- Testbench with realistic SRAM model

This implementation provides a complete, production-ready SRAM controller suitable for embedded systems requiring reliable, fast memory access with proper timing control and interface management.