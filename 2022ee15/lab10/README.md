# 10 AXI4-Lite Interface Design

## Protocol Overview
AXI4-Lite is a simplified subset of AXI4 with **single-beat transactions** and no burst support.  

**Key Characteristics**
- 32-bit address and data buses  
- Separate **read** and **write** address channels  
- **Write response channel** to acknowledge completion  
- Handshake protocol uses `VALID` and `READY`  
- No bursts → only single transfers  

**Channel Structure**
- **Write Address**: `AWADDR`, `AWVALID`, `AWREADY`  
- **Write Data**: `WDATA`, `WSTRB`, `WVALID`, `WREADY`  
- **Write Response**: `BRESP`, `BVALID`, `BREADY`  
- **Read Address**: `ARADDR`, `ARVALID`, `ARREADY`  
- **Read Data**: `RDATA`, `RRESP`, `RVALID`, `RREADY`  

---

## Design Methodology
1. Study AXI4-Lite spec (VALID/READY handshakes).  
2. Draw timing diagrams for read and write.  
3. Implement **address decoder** → 16 × 32-bit register bank.  
4. Build **FSMs** for read and write channels.  
5. Add proper **AXI4-Lite response logic**:  
   - `OKAY` (2'b00) for valid addresses  
   - `SLVERR` (2'b10) for invalid addresses  

---

## Module Overview

### `axi4_lite_if` (Interface)
- Defines all **AXI4-Lite signals**.  
- Provides **`modport master`** and **`modport slave`** views.  
- Simplifies connection between DUT and testbench.  

### `axi4_lite_slave`
Implements the AXI4-Lite slave protocol with a **register bank**.

**Register Bank**
- 16 × 32-bit registers (`register_bank[0:15]`)  
- Address decoding: `AWADDR[5:2]` or `ARADDR[5:2]` (word-aligned)  

**Write Channel FSM**
- `W_IDLE` → Wait for address (`AWVALID`)  
- `W_ADDR` → Capture address, check validity  
- `W_DATA` → Accept data if `WVALID`, update register bank with `WSTRB` byte enables  
- `W_RESP` → Send response (`BRESP` = `OKAY` or `SLVERR`)  

**Read Channel FSM**
- `R_IDLE` → Wait for address (`ARVALID`)  
- `R_ADDR` → Decode and prepare data (`RDATA`), response (`RRESP`)  
- `R_DATA` → Send data when `RREADY` asserted, then return to idle  

---

## Features
- AXI4-Lite compliant **slave** design  
- Supports **read & write transactions**  
- **Byte-enable writes** with `WSTRB`  
- Error handling for invalid addresses (`SLVERR`)  
- Uses **FSMs** for both read and write paths  

---

## Testbench (`tb_axi4_lite_slave`)
- Generates a **100 MHz clock** and reset.  
- Stimulus includes:  
  1. **Write #1** → `reg[0] = 0xABCDEFCC` (full write with `WSTRB=1111`)  
  2. **Write #2** → `reg[1]` partial write with `WSTRB=0101`  
  3. **Read #1** → `reg[0]` → expect `0xABCDEFCC`  
  4. **Read #2** → `reg[1]` → expect partially updated value  

**Expected $display / waveform observation**  
- Write acknowledged with `BRESP=OKAY`  
- Read data matches register contents  
- Invalid addresses return `RRESP=SLVERR` and data = `0xDEADBEEF`  

---

## Summary
This lab implements an **AXI4-Lite slave interface** with a 16-register bank.  
The design demonstrates proper **VALID/READY handshaking**, **address decoding**, **byte-enable writes**, and **error handling**.  
The testbench verifies functionality through simple read/write operations, validating compliance with AXI4-Lite protocol.
