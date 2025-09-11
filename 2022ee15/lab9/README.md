# 9 SPI Master Controller

## Specification
- Configurable **clock polarity (CPOL)** and **clock phase (CPHA)** for all four SPI modes  
- Programmable **clock frequency** using a divider  
- Automatic **slave select** handling (multi-slave support)  
- Full-duplex (bidirectional) data transfer with TX and RX shift registers  

---

## Design Methodology
1. Understand SPI timing for all **CPOL/CPHA** combinations  
2. Draw timing diagrams for each mode (Mode 0, 1, 2, 3)  
3. Implement **shift registers** for parallel-to-serial and serial-to-parallel conversion  
4. Plan **slave select (CS)** timing during transfers  
5. Add **clock divider and edge detection** logic for correct sampling and setup events  

---

## Module Overview

###  `spi_master`
The main SPI Master controller integrates:
- **FSM Controller** – Controls states: `IDLE → START → TRANSFER → STOP`  
- **Clock Generator** – Divides system clock, supports CPOL/CPHA modes  
- **Shift Registers** – For MOSI (TX) and MISO (RX) paths  
- **Slave Select** – Controls multiple slaves with active-low CS  

**FSM States**
- **IDLE** → Wait for `start_transfer`  
- **START** → Load transmit data and assert selected slave CS  
- **TRANSFER** → Perform serial shift on MOSI, sample MISO, count bits  
- **STOP** → Raise `transfer_done`, deassert CS, return to IDLE  

**Key I/O Ports**
- Inputs:  
  - `tx_data` → Data word to transmit  
  - `slave_sel` → Which slave to enable  
  - `start_transfer` → Begins transfer  
  - `cpol`, `cpha` → Select SPI mode  
  - `clk_div` → Clock division factor for SPI clock  

- Outputs:  
  - `rx_data` → Received data word  
  - `transfer_done` → Signals end of transfer  
  - `busy` → High during transfer  
  - `spi_clk`, `spi_mosi`, `spi_cs_n[]` → SPI bus signals  

---

##  Parameters
| Parameter      | Description                          | Default |
|----------------|--------------------------------------|---------|
| `NUM_SLAVES`   | Number of supported SPI slaves       | 4       |
| `DATA_WIDTH`   | Width of TX/RX data                  | 8 bits  |

---

##  Features
- Supports **all 4 SPI modes (Mode 0–3)** via CPOL/CPHA control  
- Configurable **SPI clock frequency** with `clk_div`  
- Automatic **slave select** (`spi_cs_n[slave_sel] = 0`)  
- Handles **full-duplex** TX/RX data transfer  
- **Busy/Done status** signals for handshake with master logic  

---

##  Testbench (`spi_master_tb`)
- Generates a **100 MHz clock**  
- Implements a **loopback slave model** (MOSI → MISO)  
- Tests all 4 SPI modes with different slaves:  
  - **Mode 00** (CPOL=0, CPHA=0) → TX=0xA5  
  - **Mode 01** (CPOL=0, CPHA=1) → TX=0x3C  
  - **Mode 10** (CPOL=1, CPHA=0) → TX=0x5A  
  - **Mode 11** (CPOL=1, CPHA=1) → TX=0xF0  


	
