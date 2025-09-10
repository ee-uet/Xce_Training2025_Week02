 ################################## Cache Controller (Direct-Mapped, Write-Back, Write-Allocate) ################################

##Overview

This project implements a cache controller in SystemVerilog for interfacing between a CPU and main memory. The cache is direct-mapped, with 256 blocks, each storing 16 bytes (128 bits). It supports read, write, and flush operations, and uses a write-back, write-allocate policy.

##Features

Direct-mapped cache with:

Tag (20 bits), Index (8 bits), Offset (4 bits).

Data array: 256 × 128-bit blocks.

Valid and Dirty bits per block.

Write-back policy: Writes update cache first, dirty blocks are written to memory on replacement or flush.

Write-allocate: On write miss, the block is first fetched from memory, then updated.

Flush mechanism: Sequentially writes back all dirty blocks to memory and invalidates entries.

##Interface

CPU ↔ Cache

Inputs: read_req, write_req, flush_req, address, cpu_to_cache_data

Outputs: cache_to_cpu_data, stall

Cache ↔ Main Memory

##Outputs: cache_to_main_mem_data, read_mem_req, write_mem_req, block_address

##Inputs: main_mem_to_cache_data, read_mem_ack, write_mem_ack

##State Machine

IDLE – Waits for CPU request or flush command.

PROCESS_REQUEST – Checks for hit/miss by comparing tag bits.

CACHE_ALLOCATE – On miss, issues memory read request to bring block into cache.

WRITE_BACK – Writes dirty block to main memory before replacement.

FLUSH – Iterates through all cache blocks, writing back dirty entries.

##Address Breakdown

tag_bits = address[31:12] (20 bits)

index_bits = address[11:4] (8 bits)

offset_bits = address[3:0] (4 bits, selects word within block)

##Policies

Hit: Serve read/write directly from/to cache.

Read Miss: Fetch block from memory → load into cache → serve CPU.

Write Miss: If dirty, write-back old block first → allocate new block from memory → update with CPU data.

Flush: Write back all dirty blocks, reset valid bits.


################################################### AI USAGE ################################
NOTE#01 : Design code is written by me and fully understand the working 
NOTE#02 :Testbench is taken from chatgpt to completely test the module basic tb is easy but to test design in detail i take help from chatgpt but next week     is totally for verification so inshallah i will learn to write detailed layered tb as by myself inshallah