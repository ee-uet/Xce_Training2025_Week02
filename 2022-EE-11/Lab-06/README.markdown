# SRAM Controller Module

## Overview
The `sram_controller` module is a Verilog implementation of a controller for interfacing with an external Static Random-Access Memory (SRAM). It handles read and write operations for a 15-bit address space and 16-bit data, managing the SRAM's control signals and bidirectional data bus.

## Features
- **Inputs**:
  - `clk`: Clock signal for synchronous operation.
  - `rst_n`: Active-low reset.
  - `read_req`: Initiates a read operation.
  - `write_req`: Initiates a write operation.
  - `address` (15-bit): SRAM memory address.
  - `write_data` (16-bit): Data to write to SRAM.
- **Outputs**:
  - `read_data` (16-bit): Data read from SRAM.
  - `ready`: Indicates controller is ready for a new operation.
  - `sram_addr` (15-bit): Address output to SRAM.
  - `sram_data` (16-bit, inout): Bidirectional SRAM data bus.
  - `sram_ce_n`: Chip enable (active-low).
  - `sram_oe_n`: Output enable (active-low).
  - `sram_we_n`: Write enable (active-low).

## FSM Description
The module uses a finite state machine (FSM) with 3 states (Moore machine, outputs depend on current state). States are defined in an enum `state_t`.

| State         | Description                          | SRAM Signals                     | Outputs                     |
|---------------|--------------------------------------|----------------------------------|-----------------------------|
| IDLE          | Ready for new operations.            | `ce_n=0`, `oe_n=0`, `we_n=1`     | `ready=1`                   |
| READ_ACTIVE   | Performs read operation (1 cycle).   | `ce_n=0`, `oe_n=0`, `we_n=1`     | `ready=0`, captures `read_data` |
| WRITE_ACTIVE  | Performs write operation (1 cycle).  | `ce_n=0`, `oe_n=1`, `we_n=0`     | `ready=0`, drives `sram_data` |

### Transition Mechanism
- Transitions occur on `posedge clk`.
- State register (`curr_state`) updates on clock or reset to `IDLE`.
- Next state logic (`always_comb`) evaluates based on `read_req` and `write_req`:
  - From `IDLE`:
    - If `read_req=1` and `write_req=0`, transitions to `READ_ACTIVE`.
    - If `write_req=1` and `read_req=0`, transitions to `WRITE_ACTIVE`.
    - If both or neither asserted, stays in `IDLE`.
  - From `READ_ACTIVE` or `WRITE_ACTIVE`: Returns to `IDLE` after one cycle.
- Reset forces `IDLE`, clearing `sram_addr` and `read_data`.

## Implementation Details
- **Module Structure**:
  - `always_ff` updates state, `sram_addr`, and `read_data`.
  - `always_comb` sets control signals (`sram_ce_n`, `sram_oe_n`, `sram_we_n`), `ready`, and `drive_data` for bidirectional bus control.
  - Bidirectional `sram_data` driven with `write_data` during `WRITE_ACTIVE` (`drive_data=1`), else high-impedance (`16'bz`).
  - Address latched when `ready=1` and `read_req` or `write_req` asserted.
  - Read data captured in `READ_ACTIVE` when `sram_oe_n=0`.
- **Operation Timing**: Single-cycle read/write operations; `ready=1` in `IDLE` signals availability.
- **Assumption**: `read_req` and `write_req` are mutually exclusive per cycle.

## Edge Cases
1. **Simultaneous Read and Write Requests**:
   - If `read_req=1` and `write_req=1`, stays in `IDLE`, no operation performed.
2. **Reset During Operation**:
   - Forces `IDLE`, clears `sram_addr` and `read_data`.
3. **Consecutive Operations**:
   - Must wait for `ready=1` (in `IDLE`) to start a new read/write.
4. **Invalid Address/Data**:
   - Module passes `address` and `write_data` directly to SRAM; no validation (assumes valid within 15-bit/16-bit ranges).
5. **SRAM Data Bus**:
   - During read, `sram_data` is input; during write, driven by `data_out`. High-impedance otherwise to avoid bus contention.

## Usage
To use this module:
1. Instantiate it in your Verilog design.
2. Connect `clk`, `rst_n`, `read_req`, `write_req`, `address`, `write_data`, and `sram_data` (inout).
3. Monitor `read_data`, `ready`, `sram_addr`, `sram_ce_n`, `sram_oe_n`, `sram_we_n`.
This controller is suitable for interfacing with external SRAM in embedded systems or memory-intensive applications.