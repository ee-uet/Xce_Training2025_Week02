# Vending Machine FSM Project

## Overview

This project implements a vending machine finite state machine (FSM) in SystemVerilog. The vending machine accepts coins of 5, 10, and 25 cents, dispenses items when 30 cents or more is accumulated, returns appropriate change, and supports coin return functionality.

## Problem

Design and implement a vending machine FSM that:
- Accepts coins of 5, 10, and 25 cents denominations
- Dispenses item when total reaches 30 cents or more
- Returns correct change when overpayment occurs
- Supports coin return functionality at any time
- Displays current accumulated amount
- Resets to zero state after item dispensing or coin return

## Approach

The vending machine FSM is implemented using enumerated states representing different accumulated amounts (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 cents) and a return state. The design uses combinational logic for next state transitions based on coin inputs and current state, with separate output logic for dispensing items and returning change.

## Project Structure

```
lab4B/
├── Documentation/          # Contains block diagram, waveform, and signal specification
├── simulation/            # Contains Questa Sim files
└── Src/                  # Contains code files
    ├── fsm_vending.sv       # Main vending machine FSM module
    └── fsm_vending_tb.sv    # Testbench
```

## How to Run

Use Questa Sim to run the files. Load the design and testbench files, then execute the simulation to observe the vending machine FSM behavior.

## Examples

### Coin Insertion Sequence
```systemverilog
coin_5 = 1; // Insert 5 cent coin
// Expected result: amount_display = 6'd5, state transitions to FIVE
```

### Exact Payment
```systemverilog
// After inserting 5c + 10c + 25c = 40c total
// Expected result: dispense_item = 1, ret_10 = 1, amount_display = 6'd0
```

### Coin Return Function
```systemverilog
coin_return = 1; // Press return button with 5c accumulated
// Expected result: ret_5 = 1, amount_display = 6'd0, state returns to ZERO
```

### Overpayment with Change
```systemverilog
// After inserting 25c + 25c = 50c total
// Expected result: dispense_item = 1, ret_5 = 1, ret_10 = 1, amount_display = 6'd5
```