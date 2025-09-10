############################################ AXI4-Lite Slave System ###################################3

This design implements a simplified AXI4-Lite slave with support for read and write transactions. It includes:

AXI4-Lite interface definition (axi4_lite)

Address decoders (decoder for write, read_decoder for read)

AXI4-Lite slave module (axi4_slave) that handles protocol handshaking, data storage, and responses

##Components

1. axi4_lite (Interface)

Defines the AXI4-Lite signals and provides modports for master and slave roles:

Read Address Channel: ARADDR, ARVALID, ARREADY

Read Data Channel: RDATA, RVALID, RREADY, RRESP

Write Address Channel: AWADDR, AWVALID, AWREADY

Write Data Channel: WDATA, WVALID, WREADY, WSTRB

Write Response Channel: BRESP, BVALID, BREADY

2. decoder (Write Address Decoder)

Validates and decodes write addresses.

Generates valid, invalid, and a register index (index).

Ensures alignment and range checking (base address 0x40000000, offset up to 0x3C).

3. read_decoder (Read Address Decoder)

Similar to decoder, but for read addresses.

Produces read_valid, read_invalid, and read_index.

4. axi4_slave (Slave Module)

Implements the AXI4-Lite protocol handling with two FSMs:

Write FSM: Handles write address, data, and response phases.

Read FSM: Handles read address and data phases.

Internal Features:

Register file: 16 × 32-bit (registers[0:15])

Write strobes (WSTRB) supported for partial writes

Proper AXI4-Lite responses:

OKAY (2’b00)

SLVERR (2’b10)

##Key Behaviors

Write transaction flow: AWVALID → decode → WVALID → update register → BRESP

Read transaction flow: ARVALID → decode → RDATA + RRESP

Misaligned or out-of-range addresses return SLVERR.

Supports byte-level writes with WSTRB.

Registers reset to 0x0 on reset.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah