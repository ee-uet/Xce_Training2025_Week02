module counter(
    input logic reset,
    input logic clk,    // Clock signal
    output logic bc,
    output logic baud_clk16,
    output logic sof
);
   wire  logic baud_clk;
   //assign bc=baud_clk;
   wire logic baud_clk166;
    assign bc=baud_clk;
    assign baud_clk16=baud_clk166;
    
    sampleCounter uut (
        .reset(reset),
        .rxEnable(rxEnable),
        .baud_clk16(baud_clk166),
        .sof(sof)
    );

    // Instantiate baud rate clock generators
    baud inst_baud (
        .clk(clk), 
        .reset(reset),
        .baud_clk(baud_clk)
    );
    
    baud16 inst_baud16 (
        .clk(clk), 
        .reset(reset),
        .baud_clk16(baud_clk166)
    );

endmodule