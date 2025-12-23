# Lab 9: SPI Master Controller

## Specification
- Configurable clock polarity and phase (CPOL/CPHA)
- Variable clock frequency (programmable divider)
- Automatic slave select control for multiple slaves
- Bidirectional data transfer (MOSI/MISO)

## Block Diagram
![Block Diagram](/Muhammad_Boota/lab9/doc/spi_master.png)

## SPI Timing Diagrams
- CPOL=0, CPHA=0: ![Timing](/Muhammad_Boota/lab9/doc/timing_diagram_for_cpha_0_and_cpol_0.png)
- CPOL=0, CPHA=1: ![Timing](/Muhammad_Boota/lab9/doc/timing_diagram_for_cpha_1_and_cpol_0.png)
- CPOL=1, CPHA=0: ![Timing](/Muhammad_Boota/lab9/doc/timing_diagram_for_cpha_0_and_cpol_1.png)
- CPOL=1, CPHA=1: ![Timing](/Muhammad_Boota/lab9/doc/timing_diagram_for_cpha_1_and_cpol_1.png)
- All phase transitions options: ![Timing](/Muhammad_Boota/lab9/doc/timming_diagrame_for_mode_transitions.png)

## Inputs
- `clk`: System clock
- `rst_n`: Active-low reset
- `tx_data`: Data to transmit (parameterizable width)
- `slave_sel`: Slave select (parameterizable number)
- `start_transfer`: Initiate SPI transfer
- `cpol`: Clock polarity
- `cpha`: Clock phase
- `clk_div`: Clock divider for SPI frequency
- `spi_miso`: Data from slave

## Outputs
- `rx_data`: Data received from slave
- `transfer_done`: Transfer complete flag
- `busy`: SPI busy status
- `spi_clk`: SPI clock output
- `spi_mosi`: Data to slave
- `spi_cs_n`: Slave select signals (active low)

## Features
- Supports all four SPI modes (CPOL/CPHA)
- Programmable clock frequency for SPI bus
- Automatic slave select management
- Handles bidirectional data transfer

## Source File
See [`spi_master.sv`](src/spi_master.sv) for implementation details.
