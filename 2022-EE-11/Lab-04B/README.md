Vending Machine Controller Module
Overview
The vending_machine module is a Verilog implementation of a vending machine controller. It accepts 5-cent, 10-cent, and 25-cent coins, dispenses an item when 25 cents or more is inserted, and returns change sequentially. The module displays the accumulated amount and handles coin returns.
Features

Inputs:
clk: Clock signal for synchronous operation.
rst_n: Active-low reset.
coin_5: 5-cent coin inserted (pulse).
coin_10: 10-cent coin inserted (pulse).
coin_25: 25-cent coin inserted (pulse).
coin_return: Request to return accumulated amount.


Outputs:
dispense_item: Signals item dispensing (when amount ≥ 25 cents).
return_5: Dispenses a 5-cent coin.
return_10: Dispenses a 10-cent coin.
return_25: Dispenses a 25-cent coin.
amount_display (6-bit): Displays accumulated amount (0–25 cents).



FSM Description
The module uses a finite state machine (FSM) with 7 states (Moore machine, outputs depend on current state). States track accumulated coin amounts and handle returns.



State
Description
Amount Display (cents)
Outputs



s_coin_0
No coins inserted (0 cents).
0
None


s_coin_5
5 cents accumulated.
5
None (unless dispensing/returning)


s_coin_10
10 cents accumulated.
10
None (unless dispensing/returning)


s_coin_15
15 cents accumulated.
15
None (unless dispensing/returning)


s_coin_20
20 cents accumulated.
20
None (unless dispensing/returning)


s_coin_25
25 cents accumulated.
25
None (unless dispensing/returning)


s_returning
Returning change (one coin per cycle).
0
return_5, return_10, or return_25


Transition Mechanism

Transitions occur on posedge clk.
State register (curr_state) updates on clock or reset to s_coin_0.
Next state logic (always_comb) evaluates {coin_return, coin_25, coin_10, coin_5} or return counters:
From s_coin_0: Transitions to s_coin_5, s_coin_10, or s_coin_25 based on coin input.
From coin states (s_coin_5 to s_coin_25):
Coin input: Advances to next amount state (e.g., s_coin_5 + 10 cents → s_coin_15).
Coin input ≥ 25 cents: Sets dispense_item = 1, calculates change (e.g., 35 cents → return 10), transitions to s_returning.
coin_return = 1: Sets return counters (e.g., 15 cents → one 10-cent, one 5-cent), transitions to s_returning.


From s_returning: Returns one coin per cycle (25-cent, then 10-cent, then 5-cent priority). Transitions to s_coin_0 when all coins returned.


Reset forces s_coin_0 and clears return counters.

Implementation Details

Module Structure:
always_ff updates state and 2-bit return counters (return_25_count, return_10_count, return_5_count).
always_comb sets outputs and next state/counters based on current state and inputs.
Assumes single coin input per cycle (one-hot encoding for coins).


Return Logic:
Change calculated to return largest denominations (e.g., 20 cents → two 10-cent coins).
s_returning dispenses one coin per cycle, prioritizing 25-cent, then 10-cent, then 5-cent.


Display: Shows accumulated amount (0, 5, 10, 15, 20, 25) in coin states; 0 in s_returning.

Edge Cases

Multiple Coin Inputs:
Only one coin processed per cycle (others ignored).


Overpayment:
Amounts ≥ 25 cents trigger dispense_item and return change (e.g., 50 cents → dispense, return two 10-cent coins).


Coin Return Request:
Returns accumulated amount in largest denominations (e.g., 20 cents → two 10-cent coins).


Reset During Operation:
Resets to s_coin_0, clears counters, stops dispensing/returning.


Return Sequencing:
In s_returning, coins are returned one per cycle, extending return over multiple cycles for multiple coins.


No Input:
Stays in current state if no coin or return request.



Usage
To use this module:

Instantiate it in your Verilog design.
Connect clk, rst_n, coin_5, coin_10, coin_25, coin_return.
Monitor dispense_item, return_5, return_10, return_25, amount_display.This module is suitable for vending machine applications requiring coin-based transactions and change handling.
