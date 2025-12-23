# UART Receiver

## Specification
- Configurable baud rate (default: 115200)
- 8-bit data, 1 start bit, 1 stop bit, optional parity
- Receive FIFO with configurable depth
- Status flags: parity error, stop bit error

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab8/task_2/doc/UART_RX.png)

## State Machine
![State Machine](/Muhammad_Boota/lab8/task_2/doc/UART_RX-rx_controller.png)

## Inputs
- `clk`: System clock
- `rst_n`: Active-low reset
- `uart_rx_en`: Receiver enable
- `data_in`: Serial data input
- `Tx_Ready`: FIFO ready for new data

## Outputs
- `Tx_Data`: 8-bit received data
- `Tx_Valid`: Data valid flag
- `parity_error_o`: Parity error status
- `stop_bit_error_o`: Stop bit error status

## Features
- Baud rate and sampling counters for accurate data recovery
- Shift register for serial-to-parallel conversion
- FIFO for buffering received data
- Status register for error detection
- State machine for RX protocol control

## Source Files
- [`uart_receiver.sv`](src/uart_receiver.sv): Top-level UART receiver
- [`rx_controller.sv`](src/rx_controller.sv): RX state machine controller
- [`rx_shift_reg.sv`](src/rx_shift_reg.sv): Shift register for RX data
- [`fifo.sv`](src/fifo.sv): Receive FIFO
- [`counter.sv`](src/counter.sv): Baud rate and bit count generator
- [`sampling_counter.sv`](src/sampling_counter.sv): Sampling counter
- [` uart_status_reg.sv`](src/ uart_status_reg.sv): Status register for error flags

## Description
This module implements a UART receiver with configurable baud rate and FIFO depth. It supports 8-bit data, start/stop bits, and optional parity. The design includes error detection for parity and stop bit, and uses a state machine for protocol control and data sampling.
