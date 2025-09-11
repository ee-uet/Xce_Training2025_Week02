## Overview of Tasks
The Makefile supports 15 Verilog projects, each in a dedicated directory (Lab-01A_ALU to Lab-10_Axi4LiteSlave), covering digital design components:
- **Lab-01A**: 8-bit ALU with operations like add, subtract, AND, OR, XOR.
- **Lab-01B**: 8-to-3 priority encoder.
- **Lab-02A**: 32-bit barrel shifter for shift/rotate operations.
- **Lab-02B**: 8-bit binary to BCD converter.
- **Lab-03**: Programmable 8-bit up/down counter.
- **Lab-04A**: Traffic light controller with pedestrian/emergency modes.
- **Lab-04B**: Vending machine controller with coin handling.
- **Lab-05**: Multi-mode timer (off, one-shot, periodic, PWM).
- **Lab-06**: SRAM controller for read/write operations.
- **Lab-07A**: Synchronous FIFO with configurable depth/width.
- **Lab-07B**: Asynchronous FIFO with dual clock domains.
- **Lab-08A**: UART transmitter with FIFO buffering.
- **Lab-08B**: UART receiver with FIFO buffering.
- **Lab-09**: SPI master controller with multi-slave support.
- **Lab-10**: AXI4-Lite slave with 16x32-bit register bank.

## Using the Makefile
The Makefile automates compilation, simulation, waveform viewing, and cleanup for all tasks using Icarus Verilog (`iverilog`), VVP (`vvp`), and GTKWave (`gtkwave`).

### Prerequisites
- Install Icarus Verilog and GTKWave.
- Ensure Verilog source files (`<prefix>.sv`) and testbenches (`<prefix>_tb.sv`) exist in each task directory (e.g., `Lab-01A/1A.sv`, `Lab-01A/1A_tb.sv`).

### Directory Structure
- Each task resides in its own directory (e.g., `Lab-01A`).
- File naming: `<prefix>.sv` for module, `<prefix>_tb.sv` for testbench, `<prefix>.vcd` for waveform output.

### Makefile Targets
Run commands from the root directory containing the task directories:
1. **Compile all modules**:
   ```bash
   make compile
   ```
   - Compiles each task’s source and testbench into an executable (`<prefix>_test`) using `iverilog -g2012`.
2. **Run all simulations**:
   ```bash
   make run
   ```
   - Executes each compiled testbench using `vvp`, generating `<prefix>.vcd` waveform files.
3. **Compile and run all**:
   ```bash
   make all
   ```
   - Combines `compile` and `run` targets.
4. **View all waveforms**:
   ```bash
   make wave
   ```
   - Opens all `.vcd` files in GTKWave (runs in background).
5. **Clean generated files**:
   ```bash
   make clean
   ```
   - Removes compiled executables (`*_test`) and waveform files (`*.vcd`).
6. **Display help**:
   ```bash
   make help
   ```
   - Lists available targets and their descriptions.

### Usage Notes
- **Execution**: Run `make <target>` in the root directory.
- **Directory Iteration**: The Makefile loops through `TASKS` (e.g., `Lab-01A`), extracting the prefix (e.g., `1A`) for file naming.
- **Dependencies**: Ensure `7A.sv` (SyncFIFO) is available for `Lab-08A`, `Lab-08B`, and other dependent labs.
- **Waveforms**: `.vcd` files must exist for `wave` target; run `make run` first.
- **Customization**: Modify `TASKS` to include/exclude labs or adjust tool paths (`IVERILOG`, `VVP`, `GTKWAVE`).
- **Exception**: Run xg.bat (for waveform view) or xc.bat in case of using task 10. Questasim is required.
