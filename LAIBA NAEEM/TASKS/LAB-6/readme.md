# LAB: SRAM Controller

**Module:** sram_controller

### Purpose
The sram_controller module interfaces with an external SRAM memory. It supports simple **read and write operations** and provides a ready signal to indicate when an operation is complete. This makes it reusable for systems that need external memory access.

---

### Interface Signals

**Inputs**

- clk → system clock signal  
- rst_n → active-low reset to initialize the controller  
- read_req → signal to start a read operation  
- write_req → signal to start a write operation  
- address → 15-bit memory address to read from or write to  
- write_data → 16-bit data to write into SRAM  

**Outputs**

- read_data → 16-bit data read from SRAM  
- ready → goes high when a read or write operation is complete  

**SRAM Interface Signals**

- sram_addr → address sent to SRAM  
- sram_data → bidirectional 16-bit data bus connecting to SRAM  
- sram_ce_n → chip enable, active low  
- sram_oe_n → output enable, active low  
- sram_we_n → write enable, active low  

---

### Overview of Working

The module has **three states**:

1. **IDLE**  
   - No read or write operation is happening  
   - SRAM signals are inactive (CE_N, OE_N, WE_N = 1)  
   - ready signal = 0  

2. **WRITE**  
   - Triggered when write_req is high in IDLE state  
   - SRAM chip is enabled, write enable (WE_N) is low  
   - Data from write_data is written into memory at the given address  
   - ready = 1 to indicate write completion  

3. **READ**  
   - Triggered when read_req is high in IDLE state  
   - SRAM chip is enabled, output enable (OE_N) is low, write enable (WE_N) = 1  
   - Data from memory at address is read into read_data  
   - ready = 1 to indicate read completion  

---

### State Transition Table

FSM implemented as a Moore machine.

| Current State | Input        | Next State | Notes                     |
|---------------|-------------|------------|---------------------------|
| IDLE          | write_req=1 | WRITE      | Write operation starts     |
| IDLE          | read_req=1  | READ       | Read operation starts      |
| IDLE          | 0           | IDLE       | No operation               |

---

### Resources

- Understood SRAM controller concepts using **YouTube tutorials, online blogs, and AI assistance**.  
- Faced difficulty with bidirectional data bus and read/write timing; AI helped clarify signal assignments and FSM logic.  

---

### Code Quality Checklist

- [x] FSM implemented using **typedef enum** and `always_ff`/`always_comb`  
- [x] Proper **active-low reset** handling  
- [x] **Unique case statements** used to avoid latches     
- [x] Signal names and comments are **clear and descriptive**  
 

