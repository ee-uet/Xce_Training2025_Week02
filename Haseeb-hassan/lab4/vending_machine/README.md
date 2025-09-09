# Vending Machine Controller - Lab 4

## Problem Description
This lab implements a vending machine controller FSM that accepts coins (5¢, 10¢, 25¢) and dispenses an item costing 30¢. The machine tracks accumulated credit, automatically dispenses when 30¢ or more is reached, and returns correct change. It includes coin return functionality to refund all inserted coins. The controller displays the current amount and handles change distribution using individual coin return signals.

## Approach
The vending machine uses an **8-state FSM with automatic dispensing and change calculation**:

* **State Representation**: S0(0¢), S5(5¢), S10(10¢), S15(15¢), S20(20¢), S25(25¢), S30(30¢), S_Dispense
* **Automatic Transition**: States ≥30¢ automatically transition to S_Dispense then back to S0
* **Change Logic**: Calculates excess payment and returns appropriate coin combinations
* **Coin Return**: Returns exact amount based on current state when coin_return is pressed
* **Display Update**: 6-bit amount_display shows current accumulated credit
* **Change Distribution**: Separate signals for 5¢, 10¢ (encoded count), and 25¢ returns

The FSM transitions based on coin inputs, with states representing accumulated amounts. When reaching 30¢, the machine dispenses and calculates change using a combinational case statement.

## Folder Structure
```
lab2/
├── vending_machine.sv                    
├── tb_vending_machine.sv                
├── documentation
     ├──   vending_machine.txt  
 │   └──  fsm_rough  
 │   └── waves                
└── README.md                            
```

## How to Run
### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps
Using ModelSim/QuestaSim:
```bash
# Compile design and testbench
vlog vending_machine.sv tb_vending_machine.sv

# Start simulation
vsim tb_vending_machine

# Run simulation
run -all
```

Using Vivado:
```bash
# Create project and add all .sv files
# Set tb_vending_machine as top module
# Run behavioral simulation
```

The testbench runs three test scenarios: exact payment, overpayment with change, and coin return functionality.

## Examples

### Test Sequence
* **Reset Phase**: rst_n=0 for 20ns, then release reset
* **Test 1 - Exact Payment**: Insert three 10¢ coins (total 30¢), observe dispense=1 with no change
* **Test 2 - Overpayment**: Insert 25¢ + 10¢ (total 35¢), observe dispense=1 with return_5=1 (5¢ change)
* **Test 3 - Coin Return**: Insert 25¢, then press coin_return, observe return_25=1

The testbench runs for approximately 420ns and automatically finishes. Monitor amount_display, dispense, and return signals to verify correct FSM operation and change calculation.