UART Transmitter Module
Overview
The uart_transmitter module is a Verilog implementation of a UART transmitter with an integrated synchronous FIFO. It transmits 8-bit data with even parity and one stop bit at a configurable baud rate, using a FIFO to buffer incoming data.
Features

Parameters:
CLK_FREQ: System clock frequency (default: 50 MHz).
BAUD_RATE: Transmission baud rate (default: 115200).
FIFO_DEPTH: FIFO buffer depth (default: 8).


Inputs:
clk: System clock (default: 50 MHz).
rst_n: Active-low reset.
tx_data (8-bit): Data to transmit.
tx_valid: Indicates valid data to write to FIFO.


Outputs:
tx_ready: FIFO not full, ready to accept data.
tx_serial: Serial output (UART transmit line).
tx_busy: Transmitter is active (not in IDLE).



FSM Description
The module uses a finite state machine (FSM) with 6 states (Moore machine, outputs depend on current state). States manage UART frame transmission.



State
Description
tx_serial
tx_busy
Action



IDLE
Waiting for FIFO data.
1 (high)
0
Pop FIFO if not empty.


LOAD
Load FIFO data to shift reg.
1 (high)
1
Compute parity, prepare start bit.


START_BIT
Transmit start bit.
0 (low)
1
Wait for baud tick.


DATA_BITS
Transmit 8 data bits (LSB first).
Shift reg[0]
1
Shift right per baud tick.


PARITY
Transmit even parity bit.
Parity bit
1
Wait for baud tick.


STOP_BIT
Transmit stop bit.
1 (high)
1
Return to IDLE after baud tick.


Transition Mechanism

Transitions occur on posedge clk.
State register (curr_state) updates on clock or reset to IDLE.
Next state logic (always_comb) evaluates:
IDLE: To LOAD if FIFO not empty (!em_flag), pops FIFO (pop_dat=1).
LOAD: To START_BIT immediately.
START_BIT: To DATA_BITS on baud_tick.
DATA_BITS: To PARITY when bit_complete (8 bits sent, bit_counter=7 and baud_tick).
PARITY: To STOP_BIT on baud_tick.
STOP_BIT: To IDLE on baud_tick.


Reset forces IDLE, clearing counters and registers.

Implementation Details

Module Structure:
Integrates sync_fifo (from Lab-07A) for data buffering (FIFO_DEPTH=8, ALMOST_FULL_THRESH=7, ALMOST_EMPTY_THRESH=1).
always_ff blocks manage state, baud_counter, bit_counter, shift_register, and parity_bit.
always_comb handles FSM logic and output assignments.


Baud Rate:
BAUD_COUNT_MAX = CLK_FREQ / BAUD_RATE - 1 (e.g., 50M/115200 ≈ 434).
baud_counter increments each cycle, resets at BAUD_COUNT_MAX, generating baud_tick.


FIFO Interface:
tx_valid writes tx_data to FIFO if tx_ready=1 (!fl_flag).
pop_dat triggers FIFO read in IDLE when not empty.


Data Transmission:
shift_register loads FIFO data in LOAD, shifts right in DATA_BITS.
Even parity (parity_bit = ^rd_data) computed in LOAD.
bit_counter tracks 8 data bits.


Outputs:
tx_ready = ~fl_flag: Indicates FIFO can accept data.
tx_serial: Outputs start (0), data (LSB first), parity, stop (1) bits.
tx_busy: High in all states except IDLE.



Flag Handling

Full Flag (fl_flag): From FIFO, set when count ≥ FIFO_DEPTH. Prevents writes, sets tx_ready=0.
Empty Flag (em_flag): From FIFO, set when count = 0. Prevents pops in IDLE.
Flags are glitch-free due to synchronous FIFO updates and registered outputs.

Edge Cases

FIFO Full:
tx_ready=0, tx_valid ignored until space available.


FIFO Empty:
Stays in IDLE, no transmission until data available.


Reset:
Forces IDLE, clears baud_counter, bit_counter, shift_register, parity_bit, resets FIFO.


Baud Rate Precision:
Non-integer CLK_FREQ/BAUD_RATE truncates to nearest integer, may cause slight timing errors.


Simultaneous Inputs:
tx_valid only processed if tx_ready=1. FIFO handles multiple writes; transmitter processes one frame at a time.


Fast Data Input:
FIFO buffers data, allowing continuous writes while transmitting, up to FIFO_DEPTH.

