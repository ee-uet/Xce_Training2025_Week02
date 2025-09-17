# UART Receiver System

A complete UART (Universal Asynchronous Receiver Transmitter) receiver implementation in SystemVerilog, featuring configurable baud rates, start bit detection, frame error checking, and robust data reception capabilities.

## Problem Statement

Serial communication is fundamental in digital systems, requiring reliable data reception over single-wire interfaces. Key challenges include:

- **Timing Synchronization**: Accurately sampling incoming serial data at the correct baud rate
- **Start Bit Detection**: Reliably identifying the beginning of data transmission
- **Data Recovery**: Correctly shifting in 8-bit data frames (LSB first)
- **Error Detection**: Identifying frame errors (invalid stop bits)
- **Flow Control**: Managing receiver readiness and busy states
- **Clock Domain Management**: Handling different clock frequencies for various baud rates

This project implements a complete UART receiver solution addressing all these requirements with a modular, parameterizable design.

## Architecture & Approach

The system uses a **hierarchical modular architecture** with 6 specialized components:

### 1. **Top Module (`Top.sv`)**
- System integrator with configurable clock frequency and baud rate
- Connects all submodules and manages signal routing
- Provides clean external interface

### 2. **Clock Generator (`ClkGenUART.sv`)**
- **Parameterizable frequency divider**
- Generates precise baud rate clock from system clock
- Supports any baud rate with 50% duty cycle output
- Formula: `DIV_COUNT = CLK_FREQ / (2 * BAUD_RATE)`

### 3. **Start Bit Detector (`BitDetection.sv`)**
- **Edge detection circuit** for UART start bits
- Detects high-to-low transitions (idle → start)
- Provides synchronization point for data reception

### 4. **UART FSM Controller (`UARTFSM_R.sv`)**
- **3-state finite state machine**:
  - `IDLE`: Waiting for start bit, receiver ready
  - `START`: Actively receiving data bits
  - `CHECK_ERROR`: Validating frame completion
- Coordinates all receiver operations

### 5. **Bit Counter (`Count.sv`)**
- **10-bit counter** (1 start + 8 data + 1 stop)
- Tracks reception progress
- Auto-wraps after complete frame

### 6. **Shift Register (`ShiftReg.sv`)**
- **9-bit serial-to-parallel converter**
- Samples data on negative clock edge
- Performs frame error detection (stop bit validation)

### Key Features

- **Configurable Parameters**: Clock frequency and baud rate
- **Standard UART Protocol**: 8-N-1 format (8 data, no parity, 1 stop)
- **Frame Error Detection**: Invalid stop bit detection
- **Flow Control**: Ready/busy status indicators
- **LSB-First Reception**: Standard UART bit ordering
- **Robust Reset**: Proper initialization of all components

## Signal Interface

### Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `CLK_FREQ` | 50,000,000 | Input clock frequency (Hz) |
| `BAUD_RATE` | 25,000,000 | UART baud rate (bps) |

### Inputs
| Signal | Width | Description |
|--------|-------|-------------|
| `clk` | 1 | System clock |
| `rst_n` | 1 | Active-low asynchronous reset |
| `rx_serial` | 1 | Serial data input line |

### Outputs
| Signal | Width | Description |
|--------|-------|-------------|
| `rx_data` | 8 | Received data byte |
| `rx_ready` | 1 | Receiver ready for new data |
| `frame_error` | 1 | Frame error indicator |
| `rx_busy` | 1 | Reception in progress |

## UART Protocol Details

### Frame Format (8-N-1)
```
Idle  Start  D0  D1  D2  D3  D4  D5  D6  D7  Stop  Idle
 1     0     b   b   b   b   b   b   b   b    1     1
      └─────────── Data Bits (LSB First) ──────────┘
```

### Timing Specifications
- **Bit Duration**: `1 / BAUD_RATE` seconds
- **Frame Duration**: 10 bit periods (start + 8 data + stop)
- **Sampling**: Data sampled on negative edge of baud clock
- **Idle State**: Logic high (1)

## How to Run

### Prerequisites
- SystemVerilog simulator (ModelSim, VCS, Xcelium, Verilator)
- Understanding of UART protocol and serial communication

### Simulation Steps

1. **Compile all design files:**
   ```bash
   # ModelSim/QuestaSim
   vlog ClkGenUART.sv BitDetection.sv Count.sv ShiftReg.sv UARTFSM_R.sv Top.sv Top_tb.sv
   
   # VCS  
   vcs ClkGenUART.sv BitDetection.sv Count.sv ShiftReg.sv UARTFSM_R.sv Top.sv Top_tb.sv
   ```

2. **Run simulation:**
   ```bash
   # ModelSim/QuestaSim
   vsim Top_tb
   run -all
   
   # VCS
   ./simv
   ```

3. **View timing diagrams:**
   ```bash
   # Add to testbench for waveform generation
   $dumpfile("uart_rx.vcd");
   $dumpvars(0, Top_tb);
   ```

### Expected Output
```
RX Data = 10100101
RX Ready = 1
Frame Error = 0  
RX Busy = 0
```

## Usage Examples

### Example 1: Basic UART Reception
```systemverilog
// Configure for standard baud rates
Top #(
    .CLK_FREQ(50_000_000),    // 50 MHz system clock
    .BAUD_RATE(115_200)       // 115.2k baud
) uart_rx (
    .clk(sys_clk),
    .rst_n(reset_n),
    .rx_serial(uart_in),
    .rx_data(received_byte),
    .rx_ready(data_valid),
    .frame_error(error_flag),
    .rx_busy(receiving)
);
```

### Example 2: High-Speed Communication
```systemverilog
// High-speed configuration
Top #(
    .CLK_FREQ(100_000_000),   // 100 MHz
    .BAUD_RATE(1_000_000)     // 1 Mbps
) high_speed_uart (
    // ... connections
);
```

### Example 3: Sending Test Data (in testbench)
```systemverilog
task send_byte(input [7:0] data);
    integer i;
    begin
        rx_serial = 0;           // Start bit
        @(posedge baud_clk);
        
        for (i = 0; i < 8; i++) begin
            rx_serial = data[i]; // Data bits (LSB first)
            @(posedge baud_clk);
        end
        
        rx_serial = 1;           // Stop bit
        @(posedge baud_clk);
    end
endtask

// Usage
send_byte(8'hA5);  // Send 0xA5 (10100101)
send_byte(8'h42);  // Send 0x42 (01000010)
```

## State Machine Operation

### State Transitions
```
     ┌─────────┐  start_bit   ┌─────────┐  count_done  ┌─────────────┐
     │  IDLE   │─────────────▶│  START  │─────────────▶│ CHECK_ERROR │
     │         │              │         │              │             │
     └─────────┘              └─────────┘              └─────────────┘
          ▲                                                      │
          └──────────────────────────────────────────────────────┘
                              frame_complete
```

### State Functions
| State | Function | Outputs Active |
|-------|----------|----------------|
| `IDLE` | Wait for start bit | `rx_ready` |
| `START` | Shift data bits | `rx_busy`, `start_count`, `start_shift` |
| `CHECK_ERROR` | Validate stop bit | `start_check`, `rx_ready` |

## Timing Analysis

### Clock Relationships
- **System Clock**: User-defined (typically 50-100 MHz)
- **Baud Clock**: `div_clk = CLK_FREQ / (2 * BAUD_RATE)`
- **Data Sampling**: Negative edge of `div_clk`

### Common Baud Rates
| Baud Rate | 50MHz Divisor | Actual Frequency |
|-----------|---------------|------------------|
| 9,600 | 2,604 | 9,600 Hz |
| 115,200 | 217 | 115,207 Hz |
| 1,000,000 | 25 | 1,000,000 Hz |

## Testing & Verification

The testbench (`Top_tb.sv`) provides comprehensive testing:

### Test Scenarios
1. ✅ **Reset Functionality**: Proper initialization
2. ✅ **Start Bit Detection**: Edge detection accuracy
3. ✅ **Data Reception**: 8-bit data capture (LSB first)
4. ✅ **Frame Validation**: Stop bit checking
5. ✅ **Flow Control**: Ready/busy state management
6. ✅ **Clock Generation**: Baud rate accuracy

### Verification Features
- **Configurable Test Data**: Easy modification of test patterns
- **Automated Byte Transmission**: Task-based stimulus generation
- **Result Validation**: Automatic pass/fail checking
- **Timing Analysis**: Clock relationship verification

## File Structure

```
├── ClkGenUART.sv        # Configurable clock divider
├── BitDetection.sv      # Start bit edge detector  
├── Count.sv            # 10-bit frame counter
├── ShiftReg.sv         # Serial-to-parallel converter
├── UARTFSM_R.sv        # Main receiver FSM controller
├── Top.sv              # System integrator
└── Top_tb.sv           # Comprehensive testbench
```

## Performance Specifications

- **Maximum Baud Rate**: Limited by clock frequency and timing constraints
- **Frame Error Detection**: 100% stop bit validation
- **Latency**: 10 baud clock periods per frame
- **Resource Usage**: Minimal (small counters, simple FSM)
- **Power Consumption**: Low (clock gating in idle state)

## Common Applications

- **Microcontroller Communication**: Arduino, ARM, PIC interfaces
- **Sensor Data Collection**: Serial sensor readings
- **Debug Interfaces**: UART-based debugging and logging
- **Wireless Modules**: ESP32, Bluetooth, WiFi module communication
- **Industrial Control**: RS-232/RS-485 protocol implementation

## Future Enhancements

- **Parity Support**: Even/odd parity checking
- **Variable Frame Format**: 7/8/9 bit data, 1/2 stop bits
- **FIFO Buffer**: Multi-byte buffering capability
- **Baud Rate Detection**: Automatic baud rate discovery
- **Error Recovery**: Advanced error handling and recovery
- **Full Duplex**: Combined transmitter implementation

## Troubleshooting

### Common Issues
- **Frame Errors**: Check stop bit timing and signal integrity
- **Missing Data**: Verify baud rate calculation and clock stability
- **False Start Bits**: Ensure proper idle state and noise filtering
- **Timing Violations**: Validate setup/hold times at high baud rates

## License

This project is provided as-is for educational and development purposes.