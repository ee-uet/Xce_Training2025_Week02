# SPI Master Module

A parameterizable SystemVerilog SPI (Serial Peripheral Interface) Master controller with support for multiple slaves and configurable timing parameters.

## Features

- **Multi-slave support**: Configurable number of slave devices (default: 4)
- **Parameterizable data width**: Default 8-bit, easily configurable
- **Full SPI mode support**: All four SPI modes (CPOL/CPHA combinations)
- **Programmable clock divider**: Flexible SPI clock generation
- **State machine based**: Clean, predictable operation
- **Complete interface**: Standard SPI signals (CLK, MOSI, MISO, CS)

## Module Parameters

| Parameter    | Default | Description                           |
|--------------|---------|---------------------------------------|
| `NUM_SLAVES` | 4       | Number of connected SPI slave devices |
| `DATA_WIDTH` | 8       | Width of SPI data transactions        |

## Port Description

### Input Ports
| Port             | Width                | Description                                                     |
|------------------|----------------------|-----------------------------------------------------------------|
| `clk`            | 1                    | System clock                                                    |
| `rst_n`          | 1                    | Active-low asynchronous reset                                   |
| `tx_data`        | `DATA_WIDTH`         | Data to transmit                                                |
| `slave_sel`      | `$clog2(NUM_SLAVES)` | Slave selection index                                           |
| `start_transfer` | 1                    | Start SPI transfer (pulse)                                      |
| `cpol`           | 1                    | Clock polarity (0: idle low, 1: idle high)                      |
| `cpha`           | 1                    | Clock phase (0: sample on first edge, 1: sample on second edge) |
| `clk_div`        | 16                   | Clock divider for SPI clock generation                          |
| `spi_miso`       | 1                    | SPI Master In Slave Out                                         |

### Output Ports
| Port            | Width        | Description                      |
|-----------------|--------------|----------------------------------|
| `rx_data`       | `DATA_WIDTH` | Received data from slave         |
| `transfer_done` | 1            | Transfer completion flag         |
| `busy`          | 1            | SPI controller busy flag         |
| `spi_clk`       | 1            | SPI clock output                 |
| `spi_mosi`      | 1            | SPI Master Out Slave In          |
| `spi_cs_n`      | `NUM_SLAVES` | Chip select outputs (active low) |

## SPI Modes

The module supports all four standard SPI modes:

| Mode | CPOL | CPHA | Description                             |
|------|------|------|-----------------------------------------|
| 0    | 0    | 0    | Clock idle low, sample on rising edge   |
| 1    | 0    | 1    | Clock idle low, sample on falling edge  |
| 2    | 1    | 0    | Clock idle high, sample on falling edge |
| 3    | 1    | 1    | Clock idle high, sample on rising edge  |

## Operation

### State Machine
The controller uses a 4-state machine:

1. **IDLE**: Waiting for start_transfer signal
2. **SETUP**: Assert chip select, prepare for transfer
3. **TRANSFER**: Clock data in/out according to CPOL/CPHA settings
4. **COMPLETE**: Signal transfer completion

### Basic Usage

1. Configure SPI parameters (`cpol`, `cpha`, `clk_div`)
2. Set target slave (`slave_sel`) and data (`tx_data`)
3. Assert `start_transfer` for one clock cycle
4. Wait for `transfer_done` or monitor `busy` signal
5. Read received data from `rx_data`

## Timing

### Clock Generation
- SPI clock frequency = System clock / `clk_div`
- Minimum `clk_div` value: 2 (for proper edge detection)
- Clock duty cycle: approximately 50%

### Transfer Timing
- Setup time: 1 system clock cycle
- Transfer time: `DATA_WIDTH` × `clk_div` system clock cycles
- Complete time: 1 system clock cycle
- Total: `(DATA_WIDTH × clk_div) + 2` system clock cycles

## Example Usage

```systemverilog
// Configure for 1MHz SPI clock (assuming 100MHz system clock)
clk_div = 100;
cpol = 0;      // Clock idle low
cpha = 0;      // Sample on rising edge
slave_sel = 2; // Select slave 2
tx_data = 8'hA5; // Data to send

// Start transfer
start_transfer = 1;
@(posedge clk);
start_transfer = 0;

// Wait for completion
wait(transfer_done);

// Read received data
received_data = rx_data;
```

## Testbench

The included testbench (`spi_master_tb`) provides:
- Comprehensive testing of all four SPI modes
- Loopback testing (MOSI data verification)
- MISO data capture and verification
- Automatic pass/fail reporting

### Running the Test

```bash
# Using ModelSim/QuestaSim
vlog spi_master.sv spi_master_tb.sv
vsim -c spi_master_tb -do "run -all; quit"

# Using other simulators
# Compile both files and run spi_master_tb module
```

## Design Considerations

### Clock Domain
- All logic operates in single clock domain
- SPI clock is generated from system clock
- No clock domain crossing issues

### Reset Behavior
- Asynchronous reset clears all internal registers
- SPI outputs driven to safe states during reset
- All chip selects deasserted during reset

### Performance
- Maximum SPI clock: System clock / 2
- Back-to-back transfers supported
- Minimal latency state machine

## Files

- `spi_master.sv` - Main SPI master module
- `spi_master_tb.sv` - Comprehensive testbench
- `README.md` - This documentation

## License

This design is provided as-is for educational and commercial use. No warranty is provided.

## Version History

- v1.0 - Initial implementation with full SPI mode support
- Parameterizable design with comprehensive testbench