# Multi-Mode Timer Controller - Lab 5

## Problem Description
This lab implements a configurable timer system with four operating modes: OFF, One-shot, Periodic, and PWM generation. The timer uses a 16-bit prescaler for clock division and a 32-bit main counter for timing control. The system combines a finite state machine (FSM) controller with a datapath module to handle different timing requirements. The timer operates at 1MHz and can generate precise timing intervals, periodic signals, and PWM waveforms with configurable duty cycles.

## Approach
The timer system uses a **hierarchical FSM-datapath architecture** with the following components:

* **5-State FSM Controller**: OFF → LOAD → RUN → (TIMEOUT/RELOAD) managing timer operation
* **16-bit Prescaler**: Clock divider creating slower tick signals for the main counter
* **32-bit Main Counter**: Down-counter with configurable reload values
* **PWM Generator**: Combinational logic comparing counter with duty cycle value
* **Mode Control**: 00=OFF, 01=One-shot, 10=Periodic, 11=PWM operation
* **Hierarchical Design**: Separate FSM and datapath modules integrated in top-level wrapper

The FSM controls counter loading, enabling, and reload behavior based on mode selection. The datapath handles prescaling, counting, and PWM generation with the FSM providing control signals.

## Folder Structure
```
lab5/
├── top_timer.sv                         
├── timer_fsm.sv                        
├── timer_datapath.sv                   
├── tb_top_timer.sv 
├──  documentation                   
    ├── datapath.txt                        
    ├── fsm_truthtables.txt                 
    ├── signal_description.txt
    ├── waves
    ├── fsm_rough          
└── README.md                          
```

## How to Run
### Prerequisites
* SystemVerilog compatible simulator (ModelSim, QuestaSim, Vivado, etc.)

### Simulation Steps
Using ModelSim/QuestaSim:
```bash
# Compile design and testbench
vlog top_timer.sv tb_top_timer.sv

# Start simulation
vsim tb_top_timer

# Run simulation
run -all
```

Using Vivado:
```bash
# Create project and add all .sv files
# Set tb_top_timer as top module
# Run behavioral simulation
```

The testbench tests all three active modes with prescaler=4, reload_val=20, and compare_val=5 for PWM duty cycle.

## Examples

### Test Sequence
* **Reset Phase**: rst_n=0 for 2ns, then release reset with prescaler=4, reload_val=20
* **Test 1 - One-shot Mode**: Set mode=01, pulse start signal, observe single timeout after counter reaches 0
* **Test 2 - Periodic Mode**: Set mode=10, pulse start signal, observe repeated timeout pulses every 20×5=100 clock cycles
* **Test 3 - PWM Mode**: Set mode=11 with compare_val=5, observe pwm_out high for first 5 counts, low for remaining 15 counts

The testbench runs for 253ns total simulation time and automatically finishes. Monitor current_count, timeout, and pwm_out signals to verify correct operation in each mode.