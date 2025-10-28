# AXI4-Lite Interface in SystemVerilog

## Problem Statement

This project implements a complete AXI4-Lite interface system that enables standardized communication between a master and slave device. AXI4-Lite is a simplified version of the AMBA AXI4 protocol, commonly used in System-on-Chip (SoC) designs for register access and configuration interfaces.

The system needs to:
- Provide a standard AXI4-Lite compliant interface for register access
- Support both read and write operations with proper handshaking
- Handle address decoding and range validation
- Generate appropriate response codes for valid and invalid transactions
- Maintain protocol timing and state machine behavior
- Support byte-level write strobes for partial register updates

## Approach

### Design Architecture

The AXI4-Lite system is implemented using SystemVerilog with the following modular design:

**Core Components:**
- `axi4_lite_if.sv` - SystemVerilog interface defining all AXI4-Lite signals
- `axi4_lite_master.sv` - Master controller with FSM-based transaction handling
- `axi4_lite_slave.sv` - Slave device with register bank and address decoding
- `axi4_lite_top.sv` - Top-level integration module
- `tb_axi4_lite.sv` - Comprehensive testbench

### AXI4-Lite Protocol Implementation

**Five Channel Architecture:**
1. **Write Address Channel (AW)**: `write_address`, `write_address_valid/ready`
2. **Write Data Channel (W)**: `write_data`, `write_strb`, `write_data_valid/ready`  
3. **Write Response Channel (B)**: `write_response`, `write_response_valid/ready`
4. **Read Address Channel (AR)**: `read_address`, `read_address_valid/ready`
5. **Read Data Channel (R)**: `read_data`, `read_response`, `read_data_valid/ready`

### Master Controller Features

**Write Transaction FSM:**
- `W_IDLE` → `W_ADDR` → `W_DATA` → `W_RESP` → `W_IDLE`
- Simultaneous address and data channel initiation
- Response collection and status reporting

**Read Transaction FSM:**
- `R_IDLE` → `R_ADDR` → `R_DATA` → `R_IDLE`
- Address setup followed by data reception
- Response code handling

**Local Interface:**
- Simple request/done handshaking for CPU integration
- Separate write and read request interfaces
- Status and response code outputs

### Slave Controller Features

**Register Bank:**
- 16 × 32-bit registers (64 bytes total)
- Base address: `0x0000_0000`
- Word-aligned access (4-byte boundaries)
- Configurable read-only registers

**Address Decoding:**
- Range validation: `0x0000_0000` to `0x0000_003C`
- Alignment checking: Must be 32-bit word aligned
- Index calculation: `address[5:2]` for register selection

**Access Control:**
- Register 0: Read/Write (Control register)
- Register 1: Read-Only (ID register, default: `0xABCD_1234`)
- Register 2: Read-Only (Status register, default: `0x0000_0000`)
- Register 3: Read/Write (Version register, default: `0x0001_0000`)
- Registers 4-15: Read/Write (General purpose)

**Response Generation:**
- `RESP_OKAY (2'b00)`: Successful transaction
- `RESP_SLVERR (2'b10)`: Address error or write to read-only register
- Error data: `0xDEAD_BEEF` for invalid read addresses

### Interface Modports

**Master Modport:**
- Outputs: All `valid` signals, addresses, data, strobes, response ready
- Inputs: All `ready` signals, read data, responses

**Slave Modport:**
- Inputs: All `valid` signals, addresses, data, strobes, response ready  
- Outputs: All `ready` signals, read data, responses

## How to Run

Run the simulation on QuestaSim. The testbench file `tb_axi4_lite.sv` provides comprehensive testing of read/write operations, error conditions, and protocol compliance.

## Examples

### Test Sequence Analysis

The testbench demonstrates various AXI4-Lite operations with a 100 MHz clock (10ns period):

### Test Cases

**1. Write to Register 0 (Control - R/W)**
```
Address: 0x0000_0000
Data: 0x1234_5678
Strobe: 0xF (all bytes)
Expected: RESP_OKAY, successful write
```

**2. Read from Register 0**
```
Address: 0x0000_0000
Expected: Data = 0x1234_5678, RESP_OKAY
```

**3. Write to Register 1 (ID - Read-Only)**
```
Address: 0x0000_0004
Data: 0xAABBCCDD
Expected: RESP_SLVERR (write to read-only register)
```

**4. Read from Register 1**
```
Address: 0x0000_0004
Expected: Data = 0xABCD_1234 (unchanged), RESP_OKAY
```

**5. Write to Register 2 (Status - Read-Only)**
```
Address: 0x0000_0008
Data: 0xDEAD_BEEF
Expected: RESP_SLVERR (write to read-only register)
```

**6. Read from Register 2**
```
Address: 0x0000_0008
Expected: Data = 0x0000_0000 (unchanged), RESP_OKAY
```

**7. Write to Register 3 (Version - R/W)**
```
Address: 0x0000_000C
Data: 0x0F0F_F0F0
Expected: RESP_OKAY, successful write
```

**8. Read from Register 3**
```
Address: 0x0000_000C
Expected: Data = 0x0F0F_F0F0, RESP_OKAY
```

### Expected Timing Behavior

**Write Transaction Timing:**
1. `write_req` asserted for 1 clock cycle
2. Master FSM: `W_IDLE` → `W_ADDR` → `W_DATA` → `W_RESP`
3. Slave FSM: `W_IDLE` → `W_ADDR` → `W_DATA` → `W_RESP`
4. `write_done` asserted when response received
5. Total latency: ~4-6 clock cycles

**Read Transaction Timing:**
1. `read_req` asserted for 1 clock cycle  
2. Master FSM: `R_IDLE` → `R_ADDR` → `R_DATA`
3. Slave FSM: `R_IDLE` → `R_ADDR` → `R_DATA`
4. `read_done` asserted when data received
5. Total latency: ~3-4 clock cycles

### Key Features Demonstrated

**Protocol Compliance:**
- Proper valid/ready handshaking on all channels
- FSM-based state management ensuring protocol adherence
- Correct response code generation

**Address Decoding:**
- Word-aligned address validation
- Range checking (0x00-0x3C)
- Register index extraction

**Access Control:**
- Read-only register protection
- Write strobe support for byte-level access
- Error response generation

**Data Integrity:**
- Register values persist across transactions  
- Read-only registers remain unchanged
- Proper reset initialization

**Error Handling:**
- Invalid address detection
- Write-protection enforcement
- Standardized error responses

This implementation provides a complete, protocol-compliant AXI4-Lite interface suitable for integration into larger SoC designs and serves as a reference for AXI4-Lite protocol understanding.