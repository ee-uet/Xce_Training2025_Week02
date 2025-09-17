module Counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       load,
    input  logic       enable,
    input  logic       up_down,
    input  logic [7:0] load_value,
    input  logic [7:0] max_count,
    output logic [7:0] count,
    output logic       tc,
    output logic       zero
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (load)
            count <= load_value;
        else if (enable) begin
            if (up_down) begin
                if (count == max_count) count <= 0;
                else count <= count + 1;
            end else begin
                if (count == 0) count <= max_count;
                else count <= count - 1;
            end
        end
    end

    assign tc   = (count == max_count);
    assign zero = (count == 0);

endmodule
