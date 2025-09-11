# UART Receiver Module

## Overview
The `uart_receiver` module is a Verilog implementation of a UART receiver with an integrated synchronous FIFO. It receives serial data with 8 data bits, even parity, and one stop bit at a configurable baud rate, buffering received data in a FIFO for downstream processing.

## Features
- **Parameters**:
  - `CLK_FREQ`: System clock frequency (default: 50 MHz).
  - `BAUD_RATE`: Reception baud rate (default: 115200).
  - `FIFO_DEPTH`: FIFO buffer depth (default: 16).
- **Inputs**:
  - `clk`: System clock (default: 50 MHz).
  - `rst_n`: Active-low reset.
  - `rx_serial`: Serial input (UART receive line).
  - `rx_ready`: Signal to pop data from FIFO.
- **Outputs**:
  - `rx_valid`: FIFO not empty, data available.
  - `rx_data` (8-bit): Data read from FIFO.
  - `rx_error`: Indicates parity or stop bit error.

## FSM Description
The module uses a finite state machine (FSM) with 5 states (Moore machine, outputs depend on current state). States manage UART frame reception.

| State      | Description                     | Action                              | Outputs                     |
|------------|---------------------------------|-------------------------------------|-----------------------------|
| IDLE       | Waiting for start bit.          | Detect falling edge on `rx_serial`. | None                        |
| START_BIT  | Sample start bit (mid-point).   | Wait for half baud period.          | None                        |
| DATA_BITS  | Receive 8 data bits (MSB first).| Sample at baud tick, shift right.   | None                        |
| PARITY     | Receive even parity bit.        | Sample at baud tick.                | None                        |
| STOP_BIT   | Verify stop bit, validate frame. | Check stop bit, parity; push to FIFO. | `rx_error`, `val_frm`, `rx_reg` |

### Transition Mechanism
- Transitions occur on `posedge clk`.
- State register (`curr_state`) updates on clock or reset to `IDLE`.
- Next state logic (`always_comb`) evaluates:
  - `IDLE`: To `START_BIT` on falling edge of `rx_serial` (start bit).
  - `START_BIT`: To `DATA_BITS` on `baud_half_tick` (mid-point of start bit).
  - `DATA_BITS`: To `PARITY` when `bit_complete` (8 bits received, `bit_counter=7` and `baud_tick`).
  - `PARITY`: To `STOP_BIT` on `baud_tick`.
  - `STOP_BIT`: To `IDLE` on `baud_tick`.
- Reset forces `IDLE`, clearing counters and registers.

## Implementation Details
- **Module Structure**:
  - Integrates `sync_fifo` (from Lab-07A) for buffering received data (`DATA_WIDTH=8`, `FIFO_DEPTH=16`, `ALMOST_FULL_THRESH=14`, `ALMOST_EMPTY_THRESH=2`).
  - `always_ff` blocks manage state, `baud_counter`, `bit_counter`, `shift_register`, `received_parity`, `rx_reg`, `rx_error`, and `val_frm`.
  - `always_comb` handles FSM transitions and output assignments.
- **Baud Rate**:
  - `BAUD_COUNT_MAX = CLK_FREQ / BAUD_RATE - 1` (e.g., 50M/115200 ≈ 434).
  - `baud_counter` increments each cycle, resets at `BAUD_COUNT_MAX` (`baud_tick`) or half (`baud_half_tick` in `START_BIT`).
  - Sampling at bit mid-point improves reliability.
- **FIFO Interface**:
  - `val_frm` writes `rx_reg` to FIFO in `STOP_BIT` if parity and stop bit are valid.
  - `rx_ready` pops FIFO data to `rx_data`.
  - `rx_valid = ~em_flag`: Data available when FIFO not empty.
- **Data Reception**:
  - `shift_register` shifts right, capturing `rx_serial` (MSB first) on `baud_tick` in `DATA_BITS`.
  - `received_parity` sampled in `PARITY` on `baud_tick`.
  - Even parity computed as `parity_bit = ^shift_register`.
- **Error Detection**:
  - In `STOP_BIT`, `rx_error = (rx_serial == 0) | (received_parity != parity_bit)` (stop bit low or parity mismatch).
  - `val_frm = (rx_serial == 1) && (received_parity == parity_bit)` enables FIFO write.

## Flag Handling
- **Full Flag (`fl_flag`)**: From FIFO, set when count ≥ `FIFO_DEPTH`. Prevents writes if full.
- **Empty Flag (`em_flag`)**: From FIFO, set when count = 0. `rx_valid = ~em_flag` indicates data availability.
- Flags are glitch-free due to synchronous FIFO updates and registered outputs.

## Edge Cases
1. **FIFO Full**:
   - Valid frames discarded if `fl_flag=1` during `STOP_BIT`.
2. **FIFO Empty**:
   - `rx_valid=0`, no data available until frame received.
3. **Reset**:
   - Forces `IDLE`, clears `baud_counter`, `bit_counter`, `shift_register`, `rx_reg`, `rx_error`, resets FIFO.
4. **Baud Rate Precision**:
   - Non-integer `CLK_FREQ/BAUD_RATE` truncates, may cause timing errors.
5. **False Start Bit**:
   - Noise causing early `rx_serial` fall may trigger `START_BIT`, but invalid stop/parity sets `rx_error`.
6. **Back-to-Back Frames**:
   - Transitions to `IDLE` ensure proper start bit detection; FIFO buffers multiple frames.

## Usage
To use this module:
1. Include `sync_fifo` module (`7A.sv`).
2. Instantiate with parameters `CLK_FREQ`, `BAUD_RATE`, `FIFO_DEPTH`.
3. Connect `clk`, `rst_n`, `rx_serial`, `rx_ready`.
4. Monitor `rx_valid`, `rx_data`, `rx_error`.
This module is suitable for UART-based serial communication in embedded systems.