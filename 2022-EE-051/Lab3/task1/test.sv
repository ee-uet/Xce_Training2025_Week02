module programmable_counter_tb();
  // Testbench signals
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
  programmable_counter uut(
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


  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    
    rst_n      = 0;  
    load       = 0;
    enable     = 0;
    up_down    = 0;
    load_value = 0;
    max_count  = 0;

    
    @(posedge clk);
    rst_n = 1; 

   
    @(posedge clk);
    load       = 1;
    load_value = 8'b00000011; //240
    max_count  = 8'b11111111; //255

    @(posedge clk);
    load = 0; 

   
    enable  = 1;
    up_down = 0; 

   
    repeat(10) @(posedge clk) begin
      $display("time=%0t | count=%0d | tc=%b | zero=%b",
                $time, count, tc, zero);
    end
    enable = 0;
    $finish;
  end
endmodule
