module programmable_counter_tb #(TEST=1000)();
logic clk;
logic rst_n;
logic load;
logic enable;
logic up_down;
logic [7:0] load_value;
logic [7:0] max_count;
logic [7:0] count;
logic tc; // Terminal 
logic zero;
// TOD: 

programmable_counter Programmable_Counter(
    .*
);

initial begin
    clk=0;
    forever #1 clk=~clk;
end

initial begin
    rst_n=0;
    @(posedge clk);
    rst_n=1;
    @(posedge clk);
    for (int i=0 ;i<TEST ;i++) begin
        load=$urandom_range(0,1);
        enable=$urandom_range(0,1);
        up_down=$urandom_range(0,1);
        load_value=$urandom_range(0,255);
        max_count=$urandom_range(0,255);
        @(posedge clk);
        $display("rst_n:%d,load:%d,load_value:%d,enable:%d,up_down:%d,count:%d,tc_flag:%d,zero_flag:%d",rst_n,load,load_value,enable,up_down,count,tc,zero);
    end
    $finish;
end
endmodule