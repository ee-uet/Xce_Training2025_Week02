module tb_programmable_counter();
    logic        clk;
    logic        rst_n;
    logic        load;
    logic        enable;
    logic        up_down;
    logic [7:0]  load_value;
    logic [7:0]  max_count;
    logic [7:0]  count;
    logic        tc;
    logic        zero;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Instantiate the counter
    programmable_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .enable(enable),
        .up_down(up_down),
        .load_value(load_value),
        .max_count(max_count),
        .count(count),
        .tc(tc),
        .zero(zero)
    );
    
    initial begin
        // Initialize VCD dump
        $dumpfile("3.vcd");
        $dumpvars(0, tb_programmable_counter);
        
        // Initialize signals
        clk = 0;
        rst_n = 0;
        load = 0;
        enable = 0;
        up_down = 0;
        load_value = 0;
        max_count = 8'd10;
        
        // Test 1: Reset
        #10;
        rst_n = 1;
        #10;
        $display("Reset: count=%d, tc=%b, zero=%b", count, tc, zero);
        
        // Test 2: Count up
        enable = 1;
        up_down = 0;
        #100;
        $display("Count up: count=%d, tc=%b, zero=%b", count, tc, zero);
        
        // Test 3: Load value
        enable = 0;
        load = 1;
        load_value = 8'd5;
        #10;
        load = 0;
        $display("Load: count=%d, tc=%b, zero=%b", count, tc, zero);
        
        // Test 4: Count down
        enable = 1;
        up_down = 1;
        #60;
        $display("Count down: count=%d, tc=%b, zero=%b", count, tc, zero);
        
        // Test 5: Change max_count
        enable = 0;
        max_count = 8'd3;
        #10;
        enable = 1;
        up_down = 0;
        #40;
        $display("New max: count=%d, tc=%b, zero=%b", count, tc, zero);
        
        // Finish simulation
        #10 $finish;
    end
endmodule
