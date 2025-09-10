
##  Vending Machine Controller  

## Introduction  
This lab implements a vending machine controller using a finite state machine (FSM).  
The machine accepts coins of 5¢, 10¢, and 25¢, tracks the total amount inserted, and dispenses an item when the required cost is met.  
It also supports a coin return feature, returning the balance using the correct denominations.  

---

## Problem  
Design an FSM-based vending machine that accepts 5¢, 10¢, and 25¢ coins, dispenses an item when the target cost is reached, and returns change or the balance when requested.  

---

## Approach  
The system is modeled as a Mealy FSM, where outputs depend on both the current state and the coin/return input.  
- Each state represents the current balance (e.g., 0¢, 5¢, 10¢ … 25¢).  
- Transitions occur when a coin is inserted or the return button is pressed.  
- On dispense, the FSM either resets to IDLE or also returns extra coins.  
  

---


## Interface Signals  

### Inputs  
- clk: System clock for FSM timing.  
- rst_n: Active-low reset; initializes machine to IDLE with 0 balance.  
- coin_5: Indicates a 5¢ coin is inserted.  
- coin_10: Indicates a 10¢ coin is inserted.  
- coin_25: Indicates a 25¢ coin is inserted.  
- coin_return: User presses coin return to get back balance.  

### Outputs  
- dispense_item: High when item is dispensed.  
- return_5: High when a 5¢ coin is returned.  
- return_10: High when a 10¢ coin is returned.  
- return_25: High when a 25¢ coin is returned.  
- amount_display [5:0]: Shows current balance in cents.  

---

## FSM Description  

### FSM Type  
- **Mealy FSM**: Outputs (dispense, return, display) depend on both state and current input.  

### States  
- IDLE (0¢)  
- cent_5 (5¢)  
- cent_10 (10¢)  
- cent_15 (15¢)  
- cent_20 (20¢)  
- cent_25 (25¢)  

### Reset State  
- On reset (rst_n=0), FSM → IDLE with balance = 0.  
![alt text](image-1.png)
---

## State Transition Table  

| Current State | Input Condition      | Next State | Outputs (disp, r25, r10, r5, display) |
|---------------|----------------------|------------|----------------------------------------|
| IDLE (0¢)     | coin_5=1             | cent_5     | 0,0,0,0,5 |
|               | coin_10=1            | cent_10    | 0,0,0,0,10 |
|               | coin_25=1            | cent_25    | 0,0,0,0,25 |
|               | coin_return=1        | IDLE       | 0,0,0,0,0 |
|               | no input             | IDLE       | 0,0,0,0,0 |
| cent_5 (5¢)   | coin_5=1             | cent_10    | 0,0,0,0,10 |
|               | coin_10=1            | cent_15    | 0,0,0,0,15 |
|               | coin_25=1            | IDLE       | 1,0,0,0,30 |
|               | coin_return=1        | IDLE       | 0,0,0,1,0 |
|               | no input             | cent_5     | 0,0,0,0,5 |
| cent_10 (10¢) | coin_5=1             | cent_15    | 0,0,0,0,15 |
|               | coin_10=1            | cent_20    | 0,0,0,0,20 |
|               | coin_25=1            | IDLE       | 1,0,0,1,35 |
|               | coin_return=1        | IDLE       | 0,0,1,0,0 |
|               | no input             | cent_10    | 0,0,0,0,10 |
| cent_15 (15¢) | coin_5=1             | cent_20    | 0,0,0,0,20 |
|               | coin_10=1            | cent_25    | 0,0,0,0,25 |
|               | coin_25=1            | IDLE       | 1,0,1,0,40 |
|               | coin_return=1        | IDLE       | 0,0,1,1,0 |
|               | no input             | cent_15    | 0,0,0,0,15 |
| cent_20 (20¢) | coin_5=1             | cent_25    | 0,0,0,0,25 |
|               | coin_10=1            | IDLE       | 1,0,0,0,30 |
|               | coin_25=1            | IDLE       | 1,0,1,1,45 |
|               | coin_return=1        | IDLE       | 0,0,1,0,0 |
|               | no input             | cent_20    | 0,0,0,0,20 |
| cent_25 (25¢) | coin_5=1             | IDLE       | 1,0,0,0,30 |
|               | coin_10=1            | IDLE       | 1,0,0,1,35 |
|               | coin_25=1            | IDLE       | 1,0,1,0,50 |
|               | coin_return=1        | IDLE       | 0,1,0,0,0 |
|               | no input             | cent_25    | 0,0,0,0,25 |

---

## Examples  

### Example 1: Exact Payment  
- Insert 30¢ directly.  
- FSM goes: IDLE → cent_25 → cent_25 → dispense → IDLE.  

### Example 2: Overpayment with Change  
- Insert 10¢ then 25¢.  
- FSM goes: IDLE → cent_10 → dispense with return_5=1 → IDLE.  

### Example 3: Coin Return  
- Insert 15¢ (10¢ + 5¢), then press coin_return.  
- FSM goes: cent_15 → return 10¢ + 5¢ → IDLE.  

---



## AI Usage  
- Used AI to reformat Word notes into Markdown.  
- Used AI to help with that returning 2 tens at once case.  

---

