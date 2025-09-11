module timer #(
    parameter INPUT_FREQ = 50_000_000,  // e.g., 50 MHz input clock
    parameter WIDTH      = 6            // enough for 0–63 seconds
) (
    input  logic       clk,     // fast clock (not 1 Hz anymore!)
    input  logic       rst_n,
    input  logic       start,   // reset timer when high
    output logic [WIDTH-1:0] count  // current seconds
);

    // Divider to generate 1 Hz tick
    localparam integer COUNT_MAX = INPUT_FREQ - 1;
    logic [$clog2(INPUT_FREQ)-1:0] div_count;
    logic tick_1hz;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_count <= 0;
            tick_1hz  <= 0;
        end else if (div_count == COUNT_MAX) begin
            div_count <= 0;
            tick_1hz  <= 1;    // pulse every 1 second
        end else begin
            div_count <= div_count + 1;
            tick_1hz  <= 0;
        end
    end

    // Seconds counter (driven by 1 Hz tick)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (start)
            count <= 0;
        else if (tick_1hz)
            count <= count + 1;
    end
endmodule