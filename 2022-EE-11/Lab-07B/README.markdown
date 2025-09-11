# Asynchronous FIFO Module

## Overview
The `asynchronous_fifo` module is a Verilog implementation of an asynchronous First-In-First-Out (FIFO) buffer. It supports two clock domains for write (wclk) and read (rclk) operations, using Gray-coded pointers for safe clock domain crossing. The FIFO is parameterized for depth and data width.

## Features
- **Parameters**:
  - `DEPTH`: Number of entries (default: 8, power-of-2 recommended).
  - `DATA_WIDTH`: Width of data (default: 8 bits).
- **Inputs**:
  - `wclk`: Write clock.
  - `wrst_n`: Active-low write reset.
  - `rclk`: Read clock.
  - `rrst_n`: Active-low read reset.
  - `w_en`: Write enable.
  - `r_en`: Read enable.
  - `data_in` (DATA_WIDTH bits): Data to write.
- **Outputs**:
  - `data_out` (DATA_WIDTH bits): Data read from FIFO.
  - `full`: FIFO is full (write side).
  - `empty`: FIFO is empty (read side).

## Implementation Details
- **Module Structure**:
  - Composed of submodules: two `synchronizer`s for pointer crossing, `wptr_handler` for write pointer and full flag, `rptr_handler` for read pointer and empty flag, and `fifo_mem` for storage.
  - Pointer width `PTR_WIDTH = $clog2(DEPTH)`.
  - Binary pointers (`b_wptr`, `b_rptr`) for addressing; Gray-coded pointers (`g_wptr`, `g_rptr`) for synchronization.
- **Gray Pointer Arithmetic**:
  - Gray codes ensure only one bit changes per increment, preventing metastability during clock domain crossing.
  - Conversion: `g_ptr_next = (b_ptr_next >> 1) ^ b_ptr_next` (binary-reflected Gray code).
  - Pointers are `PTR_WIDTH+1` bits: extra MSB for wrap-around detection (distinguishes full from empty).
- **Synchronization**:
  - `synchronizer` uses two flip-flops (`q1`, `d_out`) to synchronize Gray pointers across domains, reducing metastability risk.
  - Write domain receives synchronized read pointer (`g_rptr_sync`); read domain receives synchronized write pointer (`g_wptr_sync`).
- **Flag Handling**:
  - **Full Flag (Write Domain)**: Set when FIFO cannot accept more writes.
    - Computed as `wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]})`.
    - This detects when next write would make pointers match in a wrapped state: inverts top two bits of synchronized read pointer for comparison, accounting for extra bit and Gray coding.
    - Flopped to `full` for stability.
    - Write pointer only advances if `w_en & !full`.
  - **Empty Flag (Read Domain)**: Set when no data to read.
    - Computed as `rempty = (g_wptr_sync == g_rptr_next)`.
    - Direct equality check in Gray domain: empty when pointers match.
    - Flopped to `empty` for stability.
    - Read pointer only advances if `r_en & !empty`.
- **Pointer Updates**:
  - Binary pointers increment linearly, wrap at `DEPTH` (but extra bit tracks laps).
  - Gray pointers derived from next binary for comparison.
- **Memory**:
  - `fifo_mem` uses array `fifo[0:DEPTH-1]` for storage.
  - Write: Synchronous to `wclk` if `w_en & !full`, at `b_wptr[PTR_WIDTH-1:0]`.
  - Read: Combinational `data_out = fifo[b_rptr[PTR_WIDTH-1:0]]` (pointer advances on `rclk`).

## Edge Cases
1. **Clock Domain Differences**:
   - Handles asynchronous `wclk` and `rclk`; assumes synchronizers mitigate metastability.
2. **Full/Empty Simultaneous**:
   - Flags prevent invalid operations: no write when full, no read when empty.
3. **Reset**:
   - Separate resets (`wrst_n`, `rrst_n`): write side resets `b_wptr`, `g_wptr`, `full`; read side resets `b_rptr`, `g_rptr`, `empty`.
4. **Pointer Wrap-Around**:
   - Extra bit in pointers distinguishes full (wrapped) from empty (equal).
5. **Metastability**:
   - Gray codes and double flops minimize, but not eliminate, risks in high-speed domains.
6. **Non-Power-of-2 Depth**:
   - Works but may waste space; pointers use full width.

## Usage
To use this module:
1. Instantiate with parameters `DEPTH`, `DATA_WIDTH`.
2. Connect write side (`wclk`, `wrst_n`, `w_en`, `data_in`) and read side (`rclk`, `rrst_n`, `r_en`).
3. Monitor `data_out`, `full`, `empty`.
This FIFO is suitable for buffering data across clock domains in SoCs or multi-clock systems.