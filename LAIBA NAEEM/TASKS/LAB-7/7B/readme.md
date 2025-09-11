# LAB 07: Asynchronous FIFO

module: async_fifo  
Purpose:  
The async_fifo module implements a parameterized asynchronous FIFO buffer for transferring data between two independent clock domains. It uses Gray-coded pointers and multi-flop synchronizers to safely handle cross-domain reads and writes. Full, empty, almost_full, and almost_empty flags provide early warnings of FIFO status, making it suitable for reliable data transfer between clock domains.

---

**Interface Signals**

**Inputs**  
- wr_clk → write domain clock  
- rd_clk → read domain clock  
- rst_n → active-low asynchronous reset  
- wr_en → write enable signal  
- wr_data → data to write, DATA_WIDTH wide  
- rd_en → read enable signal  

**Outputs**  
- rd_data → data read from FIFO, DATA_WIDTH wide  
- full → high when FIFO is full  
- empty → high when FIFO is empty  
- almost_full → high when FIFO occupancy reaches almost full threshold  
- almost_empty → high when FIFO occupancy reaches almost empty threshold  
- wr_count → number of entries in write domain  
- rd_count → number of entries in read domain  

---

### Overview of Working  

1. **Memory Array**  
   - Stores FIFO data. Indexed by write and read pointers.  

2. **Write Pointer**  
   - wr_ptr_bin tracks write location in binary.  
   - wr_ptr_gray converts binary to Gray code for safe cross-domain sampling.  

3. **Read Pointer**  
   - rd_ptr_bin tracks read location in binary.  
   - rd_ptr_gray converts binary to Gray code.  

4. **Pointer Synchronization**  
   - Multi-flop synchronizers safely bring Gray-coded pointers to opposite clock domains.  

5. **Binary Conversion**  
   - Synchronized Gray pointers are converted back to binary for occupancy calculation and flag generation.  

6. **Counters and Flags**  
   - Write and read counts are calculated in respective domains.  
   - Full/Almost-Full flags in write domain, Empty/Almost-Empty flags in read domain.  

7. **FIFO Operation**  
   - Write Domain: Writes data if not full, increments pointer, updates Gray code.  
   - Read Domain: Reads data if not empty, increments pointer, updates Gray code.  
   - Cross-Domain Synchronization: Each domain samples the opposite pointer via multi-flop synchronizers to generate reliable occupancy counts.  

---

**Design Considerations**  
- Gray code prevents metastability when pointers cross clock domains.  
- Multi-flop synchronizers ensure safe pointer sampling.  
- Flag logic is based on synchronized pointers and counts.  
- Asynchronous reset ensures consistent initialization across both clock domains.  

---

**Resources**  
- I implemented this asynchronous FIFO myself using Gray-coded pointers and multi-flop synchronizers for safe cross-domain data transfer.  

---

**Code Quality Checklist**  
- [x] Pointers increment in binary and converted to Gray code for synchronization  
- [x] Multi-flop synchronizers used to avoid metastability  
- [x] Flags (full, empty, almost_full, almost_empty) are accurate in each domain  
- [x] Asynchronous reset properly initializes pointers, counts, and flags  
- [x] Parameterized DATA_WIDTH, FIFO_DEPTH, and threshold values for reusability  
