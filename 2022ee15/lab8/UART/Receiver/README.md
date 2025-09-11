# 8.2 UART Receiver

## Design Challenges
- Start bit detection and validation  
- Data sampling at optimal points (oversampling at 16×)  
- Frame error detection for invalid stop bits  
- Receive FIFO integration for reliable data storage  
- Parity bit extraction  

---

##  Module Overview

###  `uart_rx_top`
Top-level UART Receiver module integrating:
- **Baud Rate Generator** – generates oversampling tick for RX.  
- **FSM Controller (`rx_controller`)** – detects start, samples data, validates stop bit, and signals data availability.  
- **Datapath (`rx_datapath`)** – shift register to capture serial bits, outputs parallel data, and extracts parity.  
- **FIFO (`rx_fifo`)** – stores received data, provides `almost_full` / `almost_empty` status.  

**Key I/O Ports**
- `rxd` → Serial input line  
- `rx_data` → Received parallel data word  
- `write` → Asserted when data is ready for FIFO write  
- `rd_en` → External read enable for FIFO  
- `frame_error` → High if stop bit is invalid  
- `parity_bit` → Extracted parity bit  

---

###  `rx_controller`
Implements UART **FSM** with states:
- **IDLE** → Wait for start bit  
- **START** → Validate start bit at mid-point  
- **DATA** → Sample each data bit (16× oversampling)  
- **STOP** → Validate stop bit  

**Outputs:**
- `shift_en` → Enables datapath shifting at correct sampling points  
- `data_valid` → High when a complete word is received  
- `frame_error` → High if stop bit = `0`  
- `write` → Signals FIFO write at end of frame  

---

###  `rx_datapath`
- **Shift Register**: Captures incoming serial data LSB-first.  
- **Output Register**: Stores valid received byte on `data_valid`.  
- **Parity Extraction**: Captures parity bit after data reception.  

---

###  `rx_fifo`
- Depth: `16` entries (configurable).  
- Tracks **`full`**, **`empty`**, **`almost_full`**, and **`almost_empty`** flags.  
- Supports simultaneous read & write operations.  
- Maintains `count` of stored words.  

---

###  `baud_rate`
- Generates **`tick_tx`** (normal baud tick) and **`tick_rx`** (oversampling tick).  
- Configurable using parameters:  
  - `CLK_FREQ = 50 MHz`  
  - `BAUD_RATE = 115200`  
  - `SAMPLES_PER_BIT = 16`  

---

## ️ Parameters
| Parameter               | Description                           | Default   |
|-------------------------|---------------------------------------|-----------|
| `CLK_FREQ`              | System clock frequency                | 50 MHz    |
| `BAUD_RATE`             | UART baud rate                        | 115200    |
| `DATA_BITS`             | Number of data bits per frame         | 8         |
| `SAMPLES_PER_BIT`       | Oversampling factor                   | 16        |
| `FIFO_DEPTH`            | FIFO storage depth                    | 16        |

---

##  Features
- Oversampling for robust start/data/stop detection.  
- Start, data, and stop bit validation.  
- FIFO buffering to prevent data loss.  
- Parity bit extraction.  
- Frame error detection.  

---
##  Results
- Simulation Waveform:
	Inputs = Blue Signals.
	Outputs = Yellow Signals.
	
	