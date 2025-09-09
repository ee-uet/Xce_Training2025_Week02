# AXI4-Lite Protocol Implementation

## Overview

This project implements the AXI4-Lite protocol using SystemVerilog with separate master and slave components. The design provides a simplified AXI interface supporting 32-bit data transfers with configurable addressing and includes a register bank for data storage in the slave module.

## Problem

Design and implement a complete AXI4-Lite protocol interface that enables communication between a master and slave device. The system must support both read and write operations, handle proper handshaking protocols, implement address validation, and provide error responses for invalid transactions.

## Approach

The AXI4-Lite implementation follows a modular approach with the following key components:

- **AXI4-Lite Interface**: Defines all required AXI signals with master and slave modports
- **AXI4-Lite Master**: Implements FSM-based master controller for read and write operations  
- **AXI4-Lite Slave**: Manages register bank with address decoding and response generation
- **Top Module**: Integrates master and slave components with interface connections
- **Testbench**: Provides verification environment for protocol functionality

## Folder Structure

```
lab10/
├── documents/          # Contains block diagram, waveforms, and signal specifications
├── src/               # Source code files
└── simulation/        # Questa Sim files
```

## How to Run

Use Questa Sim to run the simulation files located in the simulation folder.



