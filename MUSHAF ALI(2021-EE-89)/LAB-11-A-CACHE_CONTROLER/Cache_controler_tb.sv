`timescale 1ns/1ps

module tb_cache_controller;

  logic clk, rst;

  // CPU interface
  logic read_req, write_req, flush_req;
  logic [31:0] address;
  logic [31:0] cpu_to_cache_data;
  logic [31:0] cache_to_cpu_data;

  // Memory interface
  logic [127:0] cache_to_main_mem_data;
  logic [127:0] main_mem_to_cache_data;
  logic read_mem_ack;
  logic read_mem_req;
  logic write_mem_req;
  logic write_mem_ack;
  logic [31:0] block_address;

  // Instantiate DUT
  chache_controler dut (
    .clk(clk), .rst(rst),
    .read_req(read_req), .write_req(write_req), .flush_req(flush_req),
    .address(address), .cpu_to_cache_data(cpu_to_cache_data),
    .cache_to_cpu_data(cache_to_cpu_data),

    .cache_to_main_mem_data(cache_to_main_mem_data),
    .main_mem_to_cache_data(main_mem_to_cache_data),
    .read_mem_ack(read_mem_ack),
    .read_mem_req(read_mem_req),
    .write_mem_req(write_mem_req),
    .write_mem_ack(write_mem_ack),
    .block_address(block_address)
  );

  // Clock
  always #5 clk = ~clk;

  // Simple memory model with latency
  initial begin
    read_mem_ack  = 0;
    write_mem_ack = 0;
    main_mem_to_cache_data = 128'hDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF;
  end

  task automatic mem_model();
    forever begin
      @(posedge clk);
      if (read_mem_req) begin
        repeat(2) @(posedge clk);
        read_mem_ack <= 1;
        @(posedge clk);
        read_mem_ack <= 0;
      end
      if (write_mem_req) begin
        repeat(2) @(posedge clk);
        write_mem_ack <= 1;
        @(posedge clk);
        write_mem_ack <= 0;
      end
    end
  endtask

  // CPU tasks
  task automatic cpu_read(input [31:0] addr);
    begin
      @(posedge clk);
      read_req <= 1; address <= addr;
      @(posedge clk);
      read_req <= 0;
      wait(dut.stall == 0);
      $display("[%0t] CPU READ addr=%h -> data=%h", $time, addr, cache_to_cpu_data);
    end
  endtask

  task automatic cpu_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      write_req <= 1; address <= addr; cpu_to_cache_data <= data;
      @(posedge clk);
      write_req <= 0;
      wait(dut.stall == 0);
      $display("[%0t] CPU WRITE addr=%h data=%h", $time, addr, data);
    end
  endtask

  task automatic cpu_flush();
    begin
      @(posedge clk);
      flush_req <= 1;
      @(posedge clk);
      flush_req <= 0;
      wait(dut.flush_done == 1);
      $display("[%0t] CPU FLUSH done", $time);
    end
  endtask

  // Test sequence
  initial begin
    clk = 0;
    rst = 1;
    read_req = 0; write_req = 0; flush_req = 0;
    address = 0; cpu_to_cache_data = 0;
    repeat(5) @(posedge clk);
    rst = 0;

    fork
      mem_model();
    join_none

    // ---------------- Test cases ----------------
    // 1. Read miss ? allocate
    cpu_read(32'h0000_0040); 

    // 2. Read hit (same block)
    cpu_read(32'h0000_0044);

    // 3. Write hit
    cpu_write(32'h0000_0048, 32'hAAAA_BBBB);

    // 4. Conflict miss with dirty block ? write-back + allocate
    cpu_read(32'h0001_0040);

    // 5. Flush request (invalidate all lines, write dirty back)
    cpu_flush();

    // Extra: Write miss (clean block) ? direct allocate
    cpu_write(32'h0002_0050, 32'hCCCC_DDDD);

    // 6. Verify read hit again after allocate
    cpu_read(32'h0002_0050);

    repeat(20) @(posedge clk);
    $display("ALL TEST CASES COMPLETED");
    $finish;
  end

endmodule
