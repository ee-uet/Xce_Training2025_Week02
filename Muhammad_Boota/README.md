# Digital Design and Verification Training

## Overview
This directory contains all lab modules, documentation, and source code for the Digital Design and Verification Training using SystemVerilog. Each lab focuses on a key digital design concept, progressing from basic combinational logic to advanced interface protocols and verification techniques.

## Directory Structure
- **lab1**: Basic Combinational Circuits (ALU, Priority Encoder)
- **lab2**: Advanced Combinational Logic (Barrel Shifter, BCD Converter)
- **lab3**: Sequential Circuit Fundamentals (Programmable Counter)
- **lab4**: Finite State Machines (Traffic Light Controller, Vending Machine Controller)
- **lab5**: Counters and Timers (Multi-Mode Timer)
- **lab6**: Memory Interfaces (SRAM Controller)
- **lab7**: FIFO Design (Synchronous and Asynchronous FIFO)
- **lab8**: UART Controller (Transmitter, Receiver)
- **lab9**: SPI Controller (Master Controller)
- **lab10**: AXI4-Lite Interface Design (Slave Module)

## Documentation
Each lab folder contains:
- **readme.md**: Lab objectives, specifications, block diagrams, state diagrams, timing diagrams, and code framework.
- **docx/**: Design documentation, diagrams, and synthesis reports.
- **src/**: SystemVerilog source code for each module.
- **tests/**: Testbenches and makefiles for simulation and verification.

## Getting Started
1. Review the lab manual and specifications in each lab's `readme.md`.
2. Study the block diagrams and state diagrams before coding.
3. Follow the design steps and code frameworks provided.
4. Use the testbenches to verify functionality after implementation.
---
For details on each lab, see the respective `readme.md` files in each subdirectory.


## Testing
To test a module
1. Clone the repo.
2. Go to lab and then task(if present) which you want to run.
3. Go to test folder and open its makefile.
4. replace the **PROJECT_ROOT** by the your directory of project .For example ![makefile_project](/Muhammad_Boota/docx/makefile_project.png)
then save it.
5. for compile file run in terminal **make c**
6. For simulation run **make sim**
7. for terminal view tests run **make**