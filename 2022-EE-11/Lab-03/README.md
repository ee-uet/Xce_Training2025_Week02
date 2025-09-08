Programmable Counter Module
Overview
The programmable_counter module is a Verilog implementation of an 8-bit programmable counter. It supports up/down counting, loading a preset value, and configurable maximum count, with outputs for the current count, terminal count (tc), and zero detection (zero).
Features

Inputs:
clk: Clock signal for synchronous operation.
rst_n: Active-low reset.
load: Loads load_value into the counter.
enable: Enables counting.
up_down: 0 for up-counting, 1 for down-counting.
load_value (8-bit): Value to load into the counter.
max_count (8-bit): Maximum count value.


Outputs:
count (8-bit): Current counter value.
tc: Terminal count, set when count >= max_count.
zero: Set when count == 0.



Operations

Reset: When rst_n = 0, count resets to 0.
Load: When load = 1, count is set to load_value (capped at max_count if load_value > max_count).
Up Counting (up_down = 0, enable = 1): Increments count unless tc = 1, then wraps to max_count.
Down Counting (up_down = 1, enable = 1): Decrements count unless zero = 1, then holds at 0.
Idle: If enable = 0 and load = 0, count remains unchanged.

Implementation Details

Module Structure:
Uses always_ff for sequential logic, triggered on posedge clk or negedge rst_n.
A case statement handles operation modes based on {up_down, enable, load}.
zero is assigned as count == 0.
tc is assigned as count >= max_count.


Behavior:
On reset, count is set to 0.
On load, count is set to load_value if load_value <= max_count, else max_count.
During up-counting, count increments unless tc is set, then loads max_count.
During down-counting, count decrements unless zero is set, then holds at 0.



Edge Cases

Load Value Exceeds Max Count:
If load_value > max_count, count is set to max_count.


Max Count Change During Operation:
If max_count changes, tc updates immediately (count >= max_count). Existing count values above the new max_count trigger tc but are not automatically adjusted unless load or counting occurs.


Zero and Terminal Count:
zero = 1 when count = 0, stopping down-counting.
tc = 1 when count >= max_count, causing up-counting to wrap to max_count.


Simultaneous Load and Enable:
Load takes precedence over counting when load = 1.


Invalid States:
Unhandled {up_down, enable, load} combinations (e.g., 011, 111) result in no count update.



Usage
To use this module:

Instantiate it in your Verilog design.
Connect clk, rst_n, load, enable, up_down, load_value, and max_count.
Monitor count, tc, and zero.This counter is suitable for timers, state machines, or control systems requiring flexible counting.
