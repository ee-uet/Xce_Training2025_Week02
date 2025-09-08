Synchronous FIFO Module
Overview
The sync_fifo module is a Verilog implementation of a synchronous First-In-First-Out (FIFO) buffer. It supports parameterized data width and depth, with flags for full, empty, almost full, and almost empty conditions. The FIFO operates with a single clock domain for both read and write operations.
Features

Parameters:
DATA_WIDTH: Width of data (default: 8 bits).
FIFO_DEPTH: Number of entries (default: 16).
ALMOST_FULL_THRESH: Threshold for almost full flag (default: 14).
ALMOST_EMPTY_THRESH: Threshold for almost empty flag (default: 2).


Inputs:
clk: Clock signal (1 MHz assumed).
rst_n: Active-low reset.
wr_en: Write enable.
wr_data (DATA_WIDTH bits): Data to write.
rd_en: Read enable.


Outputs:
rd_data (DATA_WIDTH bits): Data read from FIFO.
full: FIFO is full.
empty: FIFO is empty.
almost_full: FIFO count ≥ ALMOST_FULL_THRESH.
almost_empty: FIFO count ≤ ALMOST_EMPTY_THRESH.
count ($clog2(FIFO_DEPTH)+1 bits): Number of entries in FIFO.



Description
Operations are controlled by wr_en, rd_en, full, and empty.



Operation
Condition
Behavior



Write Only
wr_en=1, rd_en=0, !full
Write wr_data to fifo[wr_ptr], increment wr_ptr, count+1.


Read Only
rd_en=1, wr_en=0, !empty
Read fifo[rd_ptr] to rd_data, increment rd_ptr, count-1.


Simultaneous R/W
wr_en=1, rd_en=1, !full, !empty
Write to wr_ptr, read from rd_ptr, update pointers, count unchanged.


Idle/Blocked
Other combinations
No action (e.g., write when full, read when empty).


Operating Mechanism

Write: If wr_en=1 and !full, stores wr_data at fifo[wr_ptr], increments wr_ptr (wraps at FIFO_DEPTH-1), increments count.
Read: If rd_en=1 and !empty, outputs fifo[rd_ptr] to rd_data, increments rd_ptr (wraps at FIFO_DEPTH-1), decrements count.
Simultaneous Read/Write: If wr_en=1, rd_en=1, !full, !empty, performs both operations, updating pointers without changing count.
Reset: On rst_n=0, resets wr_ptr, rd_ptr, count, rd_data to 0, clears fifo array.

Implementation Details

Module Structure:
Uses always_ff for synchronous updates of pointers, count, and FIFO array.
fifo is an array of DATA_WIDTH-bit entries with FIFO_DEPTH depth.
rd_ptr and wr_ptr ($clog2(FIFO_DEPTH) bits) track read/write positions.
count tracks number of valid entries.
Flags (full, empty, almost_full, almost_empty) derived combinationally.


Flag Generation:
full = (rd_ptr == wr_ptr) && almost_full: Ensures glitch-free by using count >= ALMOST_FULL_THRESH.
empty = (rd_ptr == wr_ptr) && almost_empty: Uses count <= ALMOST_EMPTY_THRESH.
almost_full = (count >= ALMOST_FULL_THRESH).
almost_empty = (count <= ALMOST_EMPTY_THRESH).
Flags avoid glitches by relying on stable count updated synchronously.


Assumption: Single read or write per cycle is prioritized unless both are valid.

Edge Cases

Simultaneous Read and Write:
If !full and !empty, both operations occur, maintaining count.


Full FIFO:
Write requests (wr_en=1) ignored if full=1.


Empty FIFO:
Read requests (rd_en=1) ignored if empty=1.


Reset During Operation:
Clears fifo, resets pointers and count to 0, sets rd_data=0.


Threshold Edge Cases:
If ALMOST_FULL_THRESH >= FIFO_DEPTH, almost_full may always be 1.
If ALMOST_EMPTY_THRESH = 0, almost_empty aligns with empty.


Parameter Misconfiguration:
Non-power-of-2 FIFO_DEPTH handled correctly via $clog2.
Invalid thresholds may skew flag behavior but don’t affect core functionality.
