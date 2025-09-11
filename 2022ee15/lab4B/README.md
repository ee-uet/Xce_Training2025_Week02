# Lab 4B: Vending Machine Controller

## Problem
Design a **Vending Machine Controller** with the following requirements:
- Accepts **5¢, 10¢, and 25¢ coins**
- Dispenses an item priced at **30¢**
- Provides **correct change** if overpaid
- Supports **coin return request** at any time
- Displays the **current balance** on LEDs

---

## Approach
1. **State Machine Design**
   - Defined states:
     - `IDLE`: Waiting for coin or reset
     - `ACCUMULATE`: Collecting balance as coins are inserted
     - `DISPENSE`: Item is dispensed once balance ≥ 30¢
     - `RETURN_COINS`: Refund coins if return is requested or overpayment exists
   - Each state transition is triggered by coin insertions or return signals.

2. **Balance Tracking**
   - Balance stored in `current_balance` register.
   - Updated every cycle depending on coin insertion, item dispense, or coin return.

3. **Change-Making Logic**
   - Returns the **largest possible coin** first (`25¢ > 10¢ > 5¢`).
   - Iteratively subtracts from balance until it reaches zero.

4. **Output Handling**
   - `dispense_item` asserted when an item is dispensed.
   - `return_25`, `return_10`, or `return_5` asserted during refund cycles.
   - `amount_display` shows the live balance.

5. **Error Handling**
   - Handles reset cleanly by returning to `IDLE`.
   - Safe transitions ensure no invalid balance is displayed.

---

## How to Run

### Prerequisites
To run this project, you need the following tools:

- **Simulator:** QuestaSim (Mentor Graphics) for functional verification  
- **Synthesis Tool:** Xilinx Vivado for FPGA synthesis and implementation  

### Simulation
- Compile `lab4b.sv` and `tb_lab4b.sv` in **QuestaSim**.
- Run the testbench to verify:
  - Exact payment (e.g., 10¢ + 20¢).
  - Overpayment handling with correct change.
  - Coin return before purchase.
  - Reset functionality.

### Synthesis
- Import `lab4b.sv` into **Xilinx Vivado**.
- Run synthesis and implementation.
- Verify hardware mapping and resource utilization.

---

## Results
Simulation produces the expected vending machine behavior:

1. **Exact Payment (30¢):**
   - Machine dispenses item with no change.

2. **Overpayment (e.g., 25¢ + 10¢ = 35¢):**
   - Item dispensed.
   - Machine refunds 5¢ automatically or on `coin_return`.

3. **Coin Return Before Purchase:**
   - User inserts coins, then presses `coin_return`.
   - Machine refunds correct coins in priority order.

4. **Reset Behavior:**
   - Balance clears, machine returns to `IDLE`.

- SImulation Waveform:
		Inputs = Blue Signals.
		Outputs = Yellow Signals.
		States = Cyan Signals.