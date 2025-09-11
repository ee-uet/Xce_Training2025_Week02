# Lab 3: Sequential Circuit Fundamentals

**Lab 3A: Programmable Counter**

Module: programmable_counter  

Purpose:
This module is an 8-bit programmable counter that can count **up or down** based on control signals. It supports:  
- Loading a starting value (`load_value`)  
- Setting a maximum count value (`max_count`) for up counting  
- Generating flags when the counter reaches zero or the maximum count  
#
**Top Diagram**
![Alt text](top_diagram.png)

#

**Signals**

**Inputs**  
- `clk` (logic): System clock; counter increments or decrements on rising edge  
- `rst_n` (logic): Active-low asynchronous reset; resets counter to 0  
- `load` (logic): Loads `load_value` into the counter when asserted  
- `enable` (logic): Enables counting when high  
- `up_down` (logic): Counting direction  
  - `1` → Up counter (counts from `load_value` to `max_count`)  
  - `0` → Down counter (counts from `load_value` to 0)  
- `load_value [7:0]`: Initial value to load into the counter  
- `max_count [7:0]`: Maximum value for up-counting  

**Outputs**  
- `count [7:0]`: Current value of the counter  
- `tc` (logic): Terminal count flag; set when counter reaches `max_count` in up mode  
- `zero` (logic): Zero flag; set when counter reaches 0 in down mode  

#

**State Machine**

**States**
- **Reset** → initializes counter to 0  
- **Wait (Idle)** → counter waits for load signal  
- **Load** → loads `load_value` into the counter  
- **Count** → counter increments (up) or decrements (down)  

**FSM Type**
- This is a **Moore FSM**, as outputs (`tc`, `zero`) depend on the state and counter value, not directly on inputs in the same clock cycle  

![Alt text](FSM.png)

### Outputs per State
| State | Output |
|-------|--------|
| Reset | count = 0, tc = 0, zero = 1 |
| Wait  | Holds previous outputs |
| Load  | count = load_value, tc = 0, zero = (load_value == 0) |
| Count | Up → tc = 1 if count = max_count <br> Down → zero = 1 if count = 0 |

### State Transition Table

| Current State | Input Condition        | Next State | Output                  |
|---------------|----------------------|------------|-------------------------|
| Reset         | rst_n = 0             | Reset      | tc = 0, zero = 0        |
| Reset         | enable = 0, load = 0  | Wait       | tc = 0, zero = 0        |
| Wait          | load = 1, enable = 0  | Load       | tc = 0, zero = 0        |
| Load          | load = 0, enable = 1  | Count      | tc = 0, zero = 0        |
| Count         | load = 0, enable = 1  | Count      | tc = 1 (up), zero = 1 (down) |
| Count         | load = 0, enable = 0  | Wait       | tc = 0, zero = 0        |

#
**Resources** 

Did by myself.
#
**Design Review Checklist**
- [x] Specification understood: Programmable up/down counter with load, enable, terminal count (`tc`), and zero flag  
- [x] Block diagrams prepared showing counter datapath and control signals  
- [x] State diagrams reviewed (Reset, Load, Count-Up, Count-Down, Wait)  
- [x] Interface timing analyzed (synchronous to `clk`, async reset active-low)  
- [x] Clock domain strategy defined (single clock domain, no CDC issues)  
- [x] Consistent naming conventions (`clk`, `rst_n`, `enable`, `up_down`, `count`, `tc`, `zero`)  
- [x] No combinational loops  
- [x] No unintended latches (all registers updated in sequential `always_ff`)  
- [x] Reset strategy consistent (asynchronous active-low)  
