# UART Transmitter System

A complete UART (Universal Asynchronous Receiver Transmitter) transmitter implementation in SystemVerilog, featuring configurable baud rates, parallel-to-serial conversion, flow control, and robust data transmission capabilities.

## Problem Statement

Serial data transmission is essential in embedded systems and communication interfaces. Key challenges include:

- **Timing Precision**: Generating accurate baud rate clocks for reliable communication
- **Data Serialization**: Converting 8-bit parallel data to serial bit stream
- **Protocol Compliance**: Implementing standard UART frame format (8-N-1)
- **Flow Control**: Managing transmitter readiness and busy states
- **Bit Ordering**: Correct LSB-first transmission sequence
- **Frame Structure**: Proper start bit, data bits, and stop bit generation
- **Resource Efficiency**: Minimal hardware utilization while maintaining performance

This project implements a complete UART transmitter solution with a modular, parameterizable architecture suitable for various communication requirements.

## Architecture & Approach

The system uses a **hierarchical modular design** with 5 specialized components:

### 1. **Top Module (`Top.sv`)**
- System integrator with configurable parameters
- Instantiates and connects all submodules
- Provides clean external interface for easy integration

### 2. **Clock Generator (`ClkGenUART.sv`)**
- **Precision frequency divider** for baud rate generation
- Parameterizable for any system clock and baud rate combination  
- Generates 50% duty cycle divided clock
- Formula: `DIVISOR = CLK_FREQ / (2 * BAUD_RATE)`

### 3. **UART FSM Controller (`UART_FSM.sv`)**
- **5-state finite state machine** managing transmission flow:
  - `IDLE`: Ready to accept new data
  - `LOAD`: Load parallel data into shift register
  - `START_BIT`: Transmit start bit (logic 0)
  - `DATA_BITS`: Shift out 8 data bits (LSB first)
  - `STOP_BIT`: Transmit stop bit (logic 1)

### 4. **Bit Counter (`UART_counter.sv`)**
- **8-bit data counter** tracking transmission progress
- Counts from 0 to 8 for complete data byte transmission
- Provides count_done signal for state transitions

### 5. **Shift Register (`ShiftReg.sv`)**
- **8-bit parallel-to-serial converter**
- Loads parallel data and shifts out LSB first
- Manages start bit, data bits, and stop bit transmission
- Maintains proper idle state (logic 1)

### Key Features

- **Standard UART Protocol**: 8-N-1 format (8 data, no parity, 1 stop bit)
- **Configurable Parameters**: System clock frequency and baud rate
- **LSB-First Transmission**: Industry-standard bit ordering
- **Flow Control**: Ready/busy handshaking for reliable operation
- **Robust Reset**: Proper initialization to idle state
- **Resource Efficient**: Minimal logic utilization

## Signal Interface

### Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `CLK_FREQ` | 50,000,000 | System clock frequency (Hz) |
| `BAUD_RATE` | 25,000,000 | UART transmission baud rate (bps) |

### Inputs
| Signal | Width | Description |
|--------|-------|-------------|
| `clk` | 1 | System clock |
| `rst_n` | 1 | Active-low asynchronous reset |
| `tx_valid` | 1 | Data valid signal (start transmission) |
| `tx_data` | 8 | Parallel data to transmit |

### Outputs
| Signal | Width | Description |
|--------|-------|-------------|
| `tx_serial` | 1 | Serial data output line |
| `tx_ready` | 1 | Transmitter ready for new data |
| `tx_busy` | 1 | Transmission in progress indicator |

## UART Protocol Implementation

### Frame Format (8-N-1)
```
Idle  Start  D0  D1  D2  D3  D4  D5  D6  D7  Stop  Idle
 1     0     b   b   b   b   b   b   b   b    1     1
      └─────────── Data Bits (LSB First) ──────────┘
```

### Transmission Sequence
1. **Idle State**: `tx_serial = 1` (high)
2. **Start Bit**: `tx_serial = 0` for 1 baud period
3. **Data Bits**: Transmit `tx_data[7:0]` LSB first, 1 bit per baud period
4. **Stop Bit**: `tx_serial = 1` for 1 baud period
5. **Return to Idle**: Ready for next transmission

### Timing Specifications
- **Total Frame Time**: 10 baud periods (1 start + 8 data + 1 stop)
- **Bit Duration**: `1 / BAUD_RATE` seconds
- **Minimum Inter-frame Gap**: 1 idle period (recommended)

## How to Run

### Prerequisites
- SystemVerilog simulator (ModelSim, VCS, Xcelium, Verilator)
- Understanding of UART protocol and serial communication
- Basic knowledge of digital simulation

### Simulation Steps

1. **Compile design files:**
   ```bash
   # ModelSim/QuestaSim
   vlog ClkGenUART.sv UART_counter.sv UART_FSM.sv ShiftReg.sv Top.sv Top_tb.sv
   
   # VCS
   vcs ClkGenUART.sv UART_counter.sv UART_FSM.sv ShiftReg.sv Top.sv Top_tb.sv
   ```

2. **Run simulation:**
   ```bash
   # ModelSim/QuestaSim
   vsim top_module_tb
   run -all
   
   # VCS
   ./simv
   ```

3. **Generate waveforms:**
   ```bash
   # Add to testbench for VCD output
   $dumpfile("uart_tx.vcd");
   $dumpvars(0, top_module_tb);
   ```

### Expected Behavior
- **Reset**: System initializes with `tx_serial = 1`, `tx_ready = 1`, `tx_busy = 0`
- **Data Load**: When `tx_valid` asserted, system loads data and begins transmission
- **Transmission**: Serial data appears on `tx_serial` with proper timing
- **Completion**: `tx_ready` asserted when transmission complete

## Usage Examples

### Example 1: Basic UART Transmitter
```systemverilog
// Standard configuration for 115.2k baud
Top #(
    .CLK_FREQ(50_000_000),    // 50 MHz system clock
    .BAUD_RATE(115_200)       // 115.2k baud
) uart_tx (
    .clk(system_clock),
    .rst_n(reset_n),
    .tx_valid(send_enable),
    .tx_data(byte_to_send),
    .tx_serial(uart_tx_line),
    .tx_ready(ready_for_data),
    .tx_busy(transmission_active)
);
```

### Example 2: High-Speed Communication
```systemverilog
// High-speed configuration for 1 Mbps
Top #(
    .CLK_FREQ(100_000_000),   // 100 MHz
    .BAUD_RATE(1_000_000)     // 1 Mbps
) high_speed_tx (
    .clk(fast_clock),
    .rst_n(sys_reset_n),
    .tx_valid(hs_valid),
    .tx_data(hs_data),
    .tx_serial(hs_tx_out),
    .tx_ready(hs_ready),
    .tx_busy(hs_busy)
);
```

### Example 3: Sending Data (Control Logic)
```systemverilog
// Simple transmission control
always_ff @(posedge clk) begin
    if (!rst_n) begin
        tx_valid <= 1'b0;
        tx_data <= 8'h00;
    end
    else if (tx_ready && data_available) begin
        tx_data <= next_byte;     // Load new data
        tx_valid <= 1'b1;        // Start transmission
    end
    else begin
        tx_valid <= 1'b0;        // Clear valid after 1 cycle
    end
end
```

### Example 4: Testbench Data Transmission
```systemverilog
// Send multiple bytes with proper handshaking
task send_byte(input [7:0] data);
    begin
        @(posedge clk);
        tx_data = data;
        tx_valid = 1'b1;
        @(posedge clk);
        tx_valid = 1'b0;
        
        // Wait for completion
        wait(tx_ready == 1'b1);
    end
endtask

// Usage examples
initial begin
    send_byte(8'hA5);  // Send 0xA5
    send_byte(8'h3C);  // Send 0x3C  
    send_byte(8'hFF);  // Send 0xFF
end
```

## State Machine Operation

### State Diagram
```
     ┌──────┐  tx_valid   ┌──────┐           ┌───────────┐
     │ IDLE │────────────▶│ LOAD │──────────▶│ START_BIT │
     │      │             │      │           │           │
     └──────┘             └──────┘           └───────────┘
         ▲                                        │
         │                                        ▼
    ┌─────────┐                            ┌───────────┐  count_done
    │ STOP_BIT│                            │ DATA_BITS │─────────────┐
    │         │                            │           │             │
    └─────────┘                            └───────────┘             │
         ▲                                        ▲                  │
         └────────────────────────────────────────┴──────────────────┘
```

### State Functions
| State | Duration | Function | Active Outputs |
|-------|----------|----------|----------------|
| `IDLE` | Variable | Wait for data | `tx_ready` |
| `LOAD` | 1 cycle | Load shift register | `load`, `tx_busy` |
| `START_BIT` | 1 baud period | Send start bit | `start`, `start_count`, `tx_busy` |
| `DATA_BITS` | 8 baud periods | Send data bits | `start_shift`, `start_count`, `tx_busy` |
| `STOP_BIT` | 1 baud period | Send stop bit | `tx_busy` |

## Timing Analysis

### Clock Domain Relationships
- **System Clock**: User-defined (e.g., 50 MHz, 100 MHz)
- **Baud Clock**: `div_clk = CLK_FREQ / (2 * BAUD_RATE)`
- **Transmission Rate**: 1 bit per baud period

### Common Configurations
| System Clock | Baud Rate | Divisor | Actual Baud |
|--------------|-----------|---------|-------------|
| 50 MHz | 9,600 | 2,604 | 9,600 |
| 50 MHz | 115,200 | 217 | 115,207 |
| 100 MHz | 1,000,000 | 50 | 1,000,000 |

### Performance Metrics
- **Maximum Throughput**: `BAUD_RATE * 8/10` bits/second (accounting for start/stop bits)
- **Latency**: 10 baud periods per byte
- **Efficiency**: 80% (8 data bits per 10 total frame bits)

## Testing & Verification

### Testbench Features (`Top_tb.sv`)
- **Configurable Parameters**: Easy modification of clock and baud rates
- **Multiple Byte Transmission**: Sequential data sending
- **Flow Control Verification**: Ready/busy state checking
- **Waveform Generation**: VCD output for timing analysis

### Verification Points
1. ✅ **Reset Functionality**: Proper idle state initialization
2. ✅ **Data Loading**: Correct parallel-to-serial conversion
3. ✅ **Frame Format**: Valid start bit, data bits (LSB first), stop bit
4. ✅ **Timing Accuracy**: Precise baud rate generation
5. ✅ **Flow Control**: Proper ready/busy handshaking
6. ✅ **Multiple Transmissions**: Back-to-back byte sending

### Test Scenarios
```systemverilog
// Test Pattern Examples
send_byte(8'h00);    // All zeros
send_byte(8'hFF);    // All ones  
send_byte(8'hA5);    // Alternating pattern (10100101)
send_byte(8'h55);    // Alternating pattern (01010101)
```

## File Structure

```
├── ClkGenUART.sv       # Configurable baud rate generator
├── UART_counter.sv     # 8-bit data transmission counter
├── UART_FSM.sv         # 5-state transmission controller
├── ShiftReg.sv         # Parallel-to-serial converter
├── Top.sv              # System integrator module
└── Top_tb.sv           # Comprehensive testbench
```

## Integration Guidelines

### Connection to UART Receiver
```systemverilog
// Connect transmitter output to receiver input
wire uart_line;

uart_transmitter tx (
    // ... tx connections
    .tx_serial(uart_line)
);

uart_receiver rx (
    // ... rx connections  
    .rx_serial(uart_line)
);
```

### Microcontroller Interface
```systemverilog
// Typical MCU interface
always_ff @(posedge clk) begin
    if (mcu_write_enable && tx_ready) begin
        tx_data <= mcu_data_bus;
        tx_valid <= 1'b1;
    end
    else begin
        tx_valid <= 1'b0;
    end
end

assign mcu_tx_ready = tx_ready;
assign mcu_tx_busy = tx_busy;
```

## Real-World Applications

- **Microcontroller Communication**: Arduino, STM32, PIC interfaces
- **Debug Consoles**: Serial debugging and logging systems
- **Sensor Networks**: Data transmission from sensors to controllers
- **Industrial Control**: RS-232, RS-485 communication systems
- **Wireless Modules**: ESP32, Bluetooth, WiFi module interfaces
- **Embedded Systems**: Boot loaders, firmware update protocols

## Advanced Features & Extensions

### Potential Enhancements
- **Parity Generation**: Even/odd parity bit insertion
- **Variable Data Width**: 5, 6, 7, 8, or 9-bit data support
- **Multiple Stop Bits**: 1, 1.5, or 2 stop bit options
- **FIFO Buffer**: Multi-byte transmission queue
- **Flow Control**: RTS/CTS hardware handshaking
- **Error Injection**: Testing and validation capabilities

## Troubleshooting

### Common Issues
| Problem | Symptoms | Solution |
|---------|----------|----------|
| Incorrect Baud Rate | Data corruption | Verify clock frequency and divisor calculation |
| Missing Start/Stop Bits | Frame errors | Check FSM state transitions |
| Wrong Bit Order | Garbled data | Ensure LSB-first transmission |
| Timing Violations | Intermittent failures | Validate setup/hold times |

### Debug Checklist
- ✅ Clock frequency and baud rate parameters correct
- ✅ Reset sequence properly implemented  
- ✅ tx_valid handshaking followed correctly
- ✅ Adequate inter-frame spacing provided
- ✅ Serial line idle state maintained (logic 1)

## Performance Optimization

### Resource Utilization
- **Logic Elements**: ~50-100 (depending on target device)
- **Memory**: Minimal (small counters and registers)
- **Clock Resources**: 1 global clock + 1 generated clock

### Power Optimization
- **Clock Gating**: Disable baud clock when idle
- **State Encoding**: Optimize FSM encoding for low power
- **Signal Activity**: Minimize unnecessary signal transitions

## License

This project is provided as-is for educational and commercial development purposes.