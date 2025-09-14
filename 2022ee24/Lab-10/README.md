
# AXI4-Lite Slave Controller

## Write Channel FSM

| Current State | Next State | Condition | Actions |
|---------------|------------|-----------|---------|
| **W_IDLE**    | W_ADDR     | `awvalid == 1` | Assert `awready = 1` |
| W_IDLE        | W_IDLE     | `awvalid == 0` | Keep `awready = 0` |
| **W_ADDR**    | W_DATA     | `wvalid == 1` | Assert `wready = 1`, Latch address and strobe |
| W_ADDR        | W_ADDR     | `wvalid == 0` | Keep `wready = 1` |
| **W_DATA**    | W_RESP     | (Always after 1 cycle) | Generate response, Deassert `wready` |
| **W_RESP**    | W_IDLE     | `bready == 1` | Assert `bvalid = 1`, Deassert `bvalid` after handshake |
| W_RESP        | W_RESP     | `bready == 0` | Keep `bvalid = 1` |

## Read Channel FSM

| Current State | Next State | Condition | Actions |
|---------------|------------|-----------|---------|
| **R_IDLE**    | R_ADDR     | `arvalid == 1` | Assert `arready = 1` |
| R_IDLE        | R_IDLE     | `arvalid == 0` | Keep `arready = 0` |
| **R_ADDR**    | R_DATA     | (Always after 1 cycle) | Latch address, Generate response and read data |
| **R_DATA**    | R_IDLE     | `rready == 1` | Assert `rvalid = 1`, Deassert `rvalid` after handshake |
| R_DATA        | R_DATA     | `rready == 0` | Keep `rvalid = 1` |

## Key Characteristics

### Write Transaction Flow:
1. **Address Phase**: Master sends address → Slave acknowledges with `awready`
2. **Data Phase**: Master sends data → Slave acknowledges with `wready`
3. **Processing**: Slave performs read-modify-write operation
4. **Response**: Slave sends `bvalid` with response code (`OKAY`/`SLVERR`)

### Read Transaction Flow:
1. **Address Phase**: Master sends address → Slave acknowledges with `arready`
2. **Processing**: Slave fetches data from register bank
3. **Data Phase**: Slave sends `rvalid` with data and response code

### Response Codes:
- `00` (OKAY): Normal access success
- `10` (SLVERR): Slave error (invalid address access)

### Protocol Rules:
- VALID must not depend on READY (no combinatorial loops)
- All transactions must receive responses
- Byte-level writes supported via `wstrb` signals
- Address alignment: 4-byte word aligned (bits [1:0] = 2'b00)


## AI Usage
- Assistance in understanding AXI4-Lite and coding in system verilog
- Documentation
