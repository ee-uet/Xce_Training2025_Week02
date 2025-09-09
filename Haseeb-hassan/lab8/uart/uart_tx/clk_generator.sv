module clk_generator #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic clk,
    input  logic rst_n,
    output logic div_clk
);

    localparam int DIVISOR = CLK_FREQ / BAUD_RATE; // Should be 434
    localparam int COUNTER_WIDTH = $clog2(DIVISOR); // Should be 9
    
    logic [COUNTER_WIDTH-1:0] counter;
    
    // Debug: Add these to your testbench waveform
    logic [31:0] debug_divisor = DIVISOR;
    logic [31:0] debug_width = COUNTER_WIDTH;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
            div_clk <= 1'b0;
        end
        else begin
            if (counter == (DIVISOR - 1)) begin // counter == 433
                counter <= '0;
                div_clk <= 1'b1;
            end
            else begin
                counter <= counter + 1;
                div_clk <= 1'b0;
            end
        end
    end

endmodule
/*
        jitter version
module clk_generator #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200


)(
    input logic clk,
    input logic rst_n,
    output logic div_clk,
);

int logic [31:0] counter;
always_ff @(posedge clk)  begin
    if (!rst_n) begin
        counter <= 0;
        div_clk <= 0;
    end else if (counter >= CLK_FREQ) begin
        div_clk <= 1;
        counter <= counter - CLK_FREQ;
    end else begin
        counter <= counter + BAUD_RATE;
        div_clk <= 0;
    end
    
end
endmodule
*/