# AXI4-Lite Slave Module

## Overview
The `axi4_lite_slave` module is a Verilog implementation of an AXI4-Lite slave interface, managing read and write transactions to a 16 x 32-bit register bank. It uses separate state machines for read and write channels, adhering to the AXI4-Lite protocol with address decoding and byte-enable support.

## Features
- **Interface**:
  - `axi4_lite_if.slave`: AXI4-Lite slave interface with write address, write data, write response, read address, and read data channels.
- **Inputs**:
  - `clk`: System clock.
  - `rst_n`: Active-low reset.
  - `axi_if`: AXI4-Lite slave signals (awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready).
- **Outputs**:
  - `axi_if`: AXI4-Lite slave signals (awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid).
- **Internal**:
  - 16 x 32-bit register bank, addressable via 4-bit index (awaddr[5:2], araddr[5:2]).
  - All registers are read-write.

## FSM Description
The module uses two independent finite state machines (FSMs) for write and read channels (Moore machines, outputs depend on current state).

### Write Channel FSM
| State    | Description                     | Action                              | Outputs                     |
|----------|---------------------------------|-------------------------------------|-----------------------------|
| W_IDLE   | Wait for write address.         | Monitor `awvalid`.                  | `awready=0`, `wready=0`, `bvalid=0` |
| W_ADDR   | Receive write address.          | Set `awready=1`, latch address.     | `awready=1`                 |
| W_DATA   | Receive write data.             | Set `wready=1`, write to register.  | `wready=1`                  |
| W_RESP   | Send write response.            | Set `bvalid=1`, `bresp=00` (OKAY).  | `bvalid=1`, `bresp=00`      |

#### Write Transition Mechanism
- Transitions on `posedge clk`.
- `c_write_state` updates to `n_write_state` or resets to `W_IDLE`.
- Next state logic (`always_comb`):
  - `W_IDLE`: To `W_ADDR` if `awvalid=1`.
  - `W_ADDR`: To `W_DATA` if `awvalid=1`.
  - `W_DATA`: To `W_RESP` if `wvalid=1`.
  - `W_RESP`: To `W_IDLE` if `bready=1`.
- Reset forces `W_IDLE`.

### Read Channel FSM
| State    | Description                     | Action                              | Outputs                     |
|----------|---------------------------------|-------------------------------------|-----------------------------|
| R_IDLE   | Wait for read address.          | Monitor `arvalid`.                  | `arready=0`, `rvalid=0`     |
| R_ADDR   | Receive read address.           | Set `arready=1`, latch address.     | `arready=1`                 |
| R_DATA   | Send read data.                 | Set `rvalid=1`, `rresp=00` (OKAY).  | `rvalid=1`, `rresp=00`, `rdata` |

#### Read Transition Mechanism
- Transitions on `posedge clk`.
- `c_read_state` updates to `n_read_state` or resets to `R_IDLE`.
- Next state logic (`always_comb`):
  - `R_IDLE`: To `R_ADDR` if `arvalid=1`.
  - `R_ADDR`: To `R_DATA` if `arvalid=1`.
  - `R_DATA`: To `R_IDLE` if `rready=1`.
- Reset forces `R_IDLE`.

## Implementation Details
- **Module Structure**:
  - Two FSMs handle write and read channels independently.
  - `always_ff` updates state registers (`c_write_state`, `c_read_state`) and address indices (`write_addr_index`, `read_addr_index`).
  - `always_comb` sets control signals (`awready`, `wready`, `bvalid`, `bresp`, `arready`, `rvalid`, `rresp`) and next states.
  - Register bank: 16 x 32-bit array (`register_bank[0:15]`).
- **Address Decoding**:
  - `write_addr_index = awaddr[5:2]`, `read_addr_index = araddr[5:2]` (4-bit, addressing 16 registers).
  - `addr_valid_write = awvalid & awready`, `addr_valid_read = arvalid & arready` ensure address latching only on valid handshake.
- **Write Operation**:
  - Writes to `register_bank[write_addr_index]` on `wvalid & wready`.
  - `wstrb` (byte enables) controls which bytes are written:
    - `4'b0001`: Write `wdata[7:0]` to `[7:0]`.
    - `4'b0010`: Write `wdata[15:8]` to `[15:8]`.
    - `4'b0100`: Write `wdata[23:16]` to `[23:16]`.
    - `4'b1000`: Write `wdata[31:24]` to `[31:24]`.
    - Default: Write entire `wdata` (32 bits).
- **Read Operation**:
  - `rdata = register_bank[read_addr_index]` when `rvalid=1`, else 0.
- **Reset**:
  - Clears `register_bank` to 0, sets states to `W_IDLE`/`R_IDLE`, clears address indices.

## Flag Handling
- **Write Flags**:
  - `awready`: High in `W_ADDR` to accept address.
  - `wready`: High in `W_DATA` to accept data.
  - `bvalid`: High in `W_RESP` to signal response.
  - `bresp`: Always `2'b00` (OKAY) for successful writes.
- **Read Flags**:
  - `arready`: High in `R_ADDR` to accept address.
  - `rvalid`: High in `R_DATA` to signal valid data.
  - `rresp`: Always `2'b00` (OKAY) for successful reads.
- Flags are glitch-free due to synchronous state updates and combinational logic tied to state.

## Edge Cases
1. **Invalid Address**:
   - Addresses beyond `awaddr[5:2]` or `araddr[5:2]` (i.e., >15) are not checked; higher bits ignored.
2. **Simultaneous Read/Write**:
   - Independent FSMs allow concurrent read and write transactions.
3. **Reset During Transaction**:
   - Forces `W_IDLE`/`R_IDLE`, clears `register_bank`, aborts ongoing operations.
4. **Outstanding Transactions**:
   - Single-transaction FSMs; no pipelining, so only one transaction per channel at a time.
5. **wstrb Misuse**:
   - Non-standard `wstrb` patterns (e.g., `4'b1100`) default to full 32-bit write.
6. **No Error Handling**:
   - Always returns `bresp=00`, `rresp=00`; no SLVERR or DECERR for invalid accesses.

## Usage
To use this module:
1. Include `axi4_lite_if` interface definition.
2. Instantiate with `clk`, `rst_n`, and `axi_if` (slave modport).
3. Connect master signals to `axi_if`.
4. Monitor `axi_if` outputs (`awready`, `wready`, `bresp`, `bvalid`, `arready`, `rdata`, `rresp`, `rvalid`).
This module is suitable for AXI4-Lite slave peripherals in SoCs, such as register files or control interfaces.