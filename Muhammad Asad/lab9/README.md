# SPI Master Controller

## Overview

This project implements a SPI (Serial Peripheral Interface) Master controller using finite state machine (FSM) architecture in SystemVerilog. The design supports configurable clock polarity (CPOL) and clock phase (CPHA) settings, multiple slave selection, and full-duplex data transmission.

## Problem

Design and implement a complete SPI Master controller that can communicate with multiple SPI slave devices. The controller must support all four SPI modes (0,1,2,3) defined by CPOL and CPHA combinations, provide configurable clock generation, handle 8-bit data transfers, and manage chip select signals for multiple slaves.

## Approach

The SPI Master controller is implemented using a modular approach with the following key components:

- **FSM Controller**: Manages the state transitions (IDLE, LOAD, TRANSFER, FINISH)
- **Clock Generator**: Generates SPI clock with configurable frequency and polarity
- **Shift Registers**: Separate modules for MOSI data transmission on rising and falling edges
- **Sample Registers**: Dedicated modules for MISO data reception on rising and falling edges  
- **Counter Module**: Tracks bit transmission count (8 bits)
- **Slave Selection**: Manages chip select signals for up to 4 slaves
- **Top Module**: Integrates all components and handles signal routing

## Folder Structure

```
lab9/
├── documents/          # Contains block diagram, and signal specifications
├── src/               # Source code files
└── simulation/        # Questa Sim files
```

## How to Run

Use Questa Sim to run the simulation files located in the simulation folder.

## Code Examples

