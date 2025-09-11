# LAB: AXI4-Lite Slave Design

**Module:** axi4_lite_slave_register

### Purpose
The module implements a lightweight AXI4-Lite slave that allows a master to read and write a set of 16 memory-mapped 32-bit registers.  
It is designed to work with a simplified AXI4-Lite protocol, supporting only single 32-bit transfers, making it ideal for low-complexity control and configuration interfaces.

---

### Interface Signals

**Inputs**

- clk → system clock signal  
- rst_n → active-low reset to initialize the slave  
- axi_if.slave → AXI4-Lite slave interface (defined using SystemVerilog interface)

**AXI4-Lite Slave Signals**

- Write Address Channel:  
  - awaddr → 32-bit address to write to  
  - awvalid → write address valid from master  
  - awready → slave ready to accept write address  

- Write Data Channel:  
  - wdata → 32-bit data from master  
  - wstrb → byte write enable signals  
  - wvalid → write data valid from master  
  - wready → slave ready to accept write data  

- Write Response Channel:  
  - bresp → 2-bit write response (OKAY, SLVERR, etc.)  
  - bvalid → write response valid from slave  
  - bready → master ready to accept write response  

- Read Address Channel:  
  - araddr → 32-bit read address from master  
  - arvalid → read address valid from master  
  - arready → slave ready to accept read address  

- Read Data Channel:  
  - rdata → 32-bit read data from slave  
  - rresp → 2-bit read response  
  - rvalid → read data valid from slave  
  - rready → master ready to accept read data  

---

### Overview of Working

The slave module contains a register bank of 16 registers, each 32 bits wide.  
The module handles word-aligned addresses and performs read/write operations based on the AXI4-Lite handshake.

**Address Decoding**

- write_addr_index = upper bits [5:2] of awaddr → selects which register to write  
- read_addr_index = upper bits [5:2] of araddr → selects which register to read  
- addr_valid_write = awaddr[1:0] == 00 and index < 16 → ensures valid word-aligned write address  
- addr_valid_read = araddr[1:0] == 00 and index < 16 → ensures valid word-aligned read address  

**Write Operation**

1. Master asserts awvalid and wvali with valid address and data.  
2. Slave checks addr_valid_write and responds with awready and wready.  
3. If handshake succeeds, data is written into the selected register.  
4. Slave asserts bvalid to acknowledge the write, and master asserts bready to complete the transfer.  

**Read Operation**

1. Master asserts arvalid with the read address.  
2. Slave checks addr_valid_read and asserts arready.  
3. When handshake succeeds, rdata is driven with the selected register’s content.  
4. Slave asserts rvalid and master asserts`rready to complete the transfer.  

This design ensures **simple, reliable single-word transactions** with proper **address validation** and handshake control. It is lightweight and easy to integrate with any AXI4-Lite master.
#
### State Machine
#
**Write operation**

**FSM**

![](FSM(WO).png)

### Write Operation State Transition Table

| Current State | Inputs          | Next State                     | Outputs (awready, wready, bvalid, bresp)                      |
|---------------|----------------|--------------------------------|----------------------------------------------------------------|
| W_IDLE        | awvalid, wvalid | W_ADDR (if both captured) / W_IDLE | awready = !aw_captured<br>wready = !w_captured<br>bvalid = 0<br>bresp = 00 |
| W_ADDR        | -              | W_DATA                         | awready = 0<br>wready = 0<br>bvalid = 0<br>bresp = 00        |
| W_DATA        | -              | W_RESP                         | awready = 0<br>wready = 0<br>bvalid = 1<br>bresp = 00 (if valid) / 10 (if error) |
| W_RESP        | bready         | W_IDLE                         | awready = 0<br>wready = 0<br>bvalid = 0<br>bresp = same as W_DATA |

#

**Read operation**

**FSM**

![](FSM(R0).png)

### Read Operation State Transition Table

| Current State | Inputs   | Next State | Outputs (arready, rvalid, rdata, rresp) |
|---------------|----------|------------|-----------------------------------------|
| R_IDLE        | arvalid  | R_ADDR     | arready = !rvalid                        |
| R_ADDR        | -        | R_DATA     | arready = 0<br>rvalid = 1<br>rdata = register_bank[read_addr_index] (if valid) / 32'h0 (if error)<br>rresp = 00 (if valid) / 10 (if error) |
| R_DATA        | rready   | R_IDLE     | arready = 0<br>rvalid = 0<br>rdata = same as previous<br>rresp = same as previous |

---

### Resources

  The AXI4-Lite module code was not written entirely by me. The tasks in our group were divided — my teammate implemented the AXI4-Lite slave module and later explained it to me. Now, I have a complete understanding of how the AXI4-Lite protocol works (channels, signals, handshake mechanism, FSM transitions, response generation, etc.), but the original coding work was done by my group member. I used class notes,  lab slides, and AI explanations to strengthen my understanding of the AXI4-Lite design.

---

### Code Quality Checklist

- [x] Register bank is **word-addressable** and safe from invalid accesses  
- [x] AXI4-Lite handshakes implemented with **VALID/READY signals**   
- [x] Clear **signal naming and comments** for readability  
- [x] Modular design using **SystemVerilog interface and modports**  
