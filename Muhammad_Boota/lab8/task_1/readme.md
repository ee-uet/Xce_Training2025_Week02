# Lab 10A: UART Transmitter

## Specification
- Configurable baud rate (9600, 19200, 38400, 115200)
- 8-bit data, 1 start bit, 1 stop bit, optional parity
- Transmit FIFO with configurable depth
- Status flags: busy, FIFO full/empty

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab8/task_1/doc/UART_Tx-data_path.png)

## State Machine
![State Machine](/Muhammad_Boota/lab8/task_1/doc/UART_Tx-controller.png)

## Inputs
- `clk`: System clock
- `rst_n`: Active-low reset
- `tx_data`: 8-bit data to transmit
- `tx_en`: Transmit enable
- `tx_valid`: Data valid for FIFO

## Outputs
- `tx_ready`: FIFO ready for new data
- `tx_serial`: UART serial output
- `tx_busy`: Transmitter busy status

## Features
- Baud rate generator for accurate timing
- FIFO for buffering transmit data
- Parity generation (optional, configurable)
- Shift register for serializing data
- Controller for managing transmission states

## Source Files
- [`uart_transmitter.sv`](src/uart_transmitter.sv): Top-level UART transmitter
- [`counter.sv`](src/counter.sv): Baud rate and bit count generator
- [`fifo.sv`](src/fifo.sv): Transmit FIFO
- [`Shift_Reg.sv`](src/Shift_Reg.sv): Shift register for serial output
- [`tx_controller.sv`](src/tx_controller.sv): Transmission state controller

## Description
This module implements a UART transmitter with configurable baud rate and FIFO depth. It supports 8-bit data, start/stop bits, and optional parity. The design includes status flags for busy, FIFO full, and FIFO empty, and uses a state machine for transmission control.
