# SPI Core Module

## Overview
The `SPI_Core` module, paired with the `SPI` submodule, is a Verilog implementation of an SPI (Serial Peripheral Interface) master controller. It supports communication with multiple slaves (default 4), configurable clock polarity (`cpol`), phase (`cpha`), and clock divider (`dvsr`). The module handles data transmission and reception with timing parameters for setup, hold, and turnaround.

## Features
- **Parameters**:
  - `sl`: Number of slaves (default: 4).
  - `t_setup`: Setup time cycles (default: 512).
  - `t_hold`: Hold time cycles (default: 512).
  - `t_turn`: Turnaround time cycles (default: 1024).
- **Inputs**:
  - `clk`: System clock.
  - `reset`: Active-high reset.
  - `write`: Initiates write operation.
  - `cpol_i`: Clock polarity input.
  - `cpha_i`: Clock phase input.
  - `spi_miso`: Master In Slave Out serial data.
  - `instr` (2-bit): Instruction type (01=slave select, 10=SPI data, 11=control).
  - `ss_n` (sl bits): Slave select input (active-low).
  - `data_reg` (8-bit): Data to transmit.
  - `dvsr_in` (16-bit): Clock divider input.
- **Outputs**:
  - `spi_done`: Signals transaction completion.
  - `spi_sclk`: SPI clock to slaves.
  - `spi_mosi`: Master Out Slave In serial data.
  - `out_reg` (8-bit): Received data.
  - `spi_ss_n` (sl bits): Slave select lines (active-low).

## FSM Description (SPI Submodule)
The `SPI` submodule uses a finite state machine (FSM) with 7 states (Moore machine, outputs depend on current state) to manage SPI transactions.

| State      | Description                     | Action                              | Outputs                     |
|------------|---------------------------------|-------------------------------------|-----------------------------|
| Idle       | Waiting for start signal.       | Ready high, `ss_n_out=1`.           | `ready=1`, `spi_done_tick=0` |
| ss_setup   | Setup slave select.             | Wait `t_setup` cycles, load `Din`.  | `ss_n_out=0` when complete  |
| p0         | Clock phase 0 (data sample/send). | Sample `miso`, shift `so_reg`.     | `sclk` based on `cpol`, `cpha` |
| p1         | Clock phase 1 (data send/sample). | Shift `so_reg`, send `mosi`.       | `sclk` based on `cpol`, `cpha` |
| ss_hold    | Hold slave select.              | Wait `t_hold`, signal done.         | `spi_done_tick=1`           |
| ss_turn    | Turnaround time.                | Wait `t_turn`, `ss_n_out=1`.        | None                        |

### Transition Mechanism
- Transitions occur on `posedge clk`.
- State register (`stt_reg`) updates on clock or reset to `Idle`.
- Next state logic (`always_comb`):
  - `Idle`: To `ss_setup` if `start=1`.
  - `ss_setup`: To `p0` after `ss_s_cycle` cycles.
  - `p0`: To `p1` after `dvsr` cycles (clock divider).
  - `p1`: To `p0` if `n_reg<7` (bit counter), else to `ss_hold` after `dvsr` cycles.
  - `ss_hold`: To `ss_turn` after `ss_h_cycle` cycles.
  - `ss_turn`: To `Idle` after `ss_t_cycle` cycles.
- Reset forces `Idle`, clearing registers.

## Implementation Details
- **Module Structure**:
  - `SPI_Core` integrates `SPI` submodule, managing slave selection and control registers.
  - `SPI` handles serial communication with FSM, pointers, and shift registers.
- **SPI_Core**:
  - Registers: `ss_n_reg` (slave select), `cpol`, `cpha`, `dvsr` (clock divider).
  - Control signals: `wr_en=write`, `wr_ss` (slave select write), `wr_spi` (data write), `wr_ctrl` (control write) based on `instr`.
  - `spi_ss_n = ss_n_reg | {sl{ss_en}}`: Combines registered slave select with enable signal.
  - `out_reg = spi_out`, `spi_done = spi_ready`.
- **SPI Submodule**:
  - `c_reg` (16-bit): Counts cycles for timing (`ss_s_cycle`, `ss_h_cycle`, `ss_t_cycle`, `dvsr`).
  - `n_reg` (3-bit): Tracks 8 data bits.
  - `si_reg` (8-bit): Shift register for input (`miso`).
  - `so_reg` (8-bit): Shift register for output (`Din` to `mosi`).
  - `sclk`: Generated based on `cpol`, `cpha` using `pclk` (phase-dependent clock).
  - `pclk = (stt_next == p1 && ~cpha) || (stt_next == p0 && cpha)`.
  - `sclk_next = cpol ? ~pclk : pclk`.
  - `Dout = si_reg`, `mosi = so_reg[0]`.

## Flag Handling
- **Ready Flag (`ready`)**:
  - Set in `Idle` state, indicating readiness for new transactions.
  - Cleared in all other states.
  - Drives `spi_done` in `SPI_Core`, glitch-free due to registered state transitions.
- **Done Flag (`spi_done_tick`)**:
  - Pulsed in `ss_hold` after `t_hold` cycles, signaling transaction completion.
  - Registered to avoid glitches.
- Flags are stable due to synchronous updates and single-cycle pulses.

## Gray Pointer Arithmetic
- Not applicable; this module uses binary counters (`c_reg`, `n_reg`) for timing and bit counting, not Gray-coded pointers (unlike asynchronous FIFO).

## Edge Cases
1. **Simultaneous Instructions**:
   - `instr` selects one operation (slave select, data, control); only one processed per `write` pulse.
2. **Reset**:
   - Forces `Idle`, resets `cpol`, `cpha`, `dvsr=512`, `ss_n_reg` to all 1s, clears registers.
3. **Invalid Slave Select**:
   - `ss_n=11...1` (all high) selects no slave; `spi_ss_n` reflects this.
4. **Timing Parameters**:
   - Large `t_setup`, `t_hold`, `t_turn`, or `dvsr` values extend transaction time but function correctly.
5. **CPOL/CPHA Changes**:
   - Updated only in `wr_ctrl` (`instr=11`), applied to next transaction.
6. **MISO Noise**:
   - Data sampled in `p0` may include noise; no error detection implemented.

## Usage
To use this module:
1. Instantiate `SPI_Core` with parameters `sl`, `t_setup`, `t_hold`, `t_turn`.
2. Connect `clk`, `reset`, `write`, `cpol_i`, `cpha_i`, `spi_miso`, `instr`, `ss_n`, `data_reg`, `dvsr_in`.
3. Monitor `spi_done`, `spi_sclk`, `spi_mosi`, `out_reg`, `spi_ss_n`.
This module is suitable for SPI master communication in embedded systems with multiple slaves.