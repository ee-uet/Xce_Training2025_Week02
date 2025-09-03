module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        load,
    input  logic        enable,
    input  logic        up_down,
    input  logic [7:0]  load_value,
    input  logic [7:0]  max_count,
    output logic [7:0]  count,
    output logic        tc,          // Terminal count
    output logic        zero
);
    logic [7:0] next_count;

    always_comb begin

        next_count = count;

        if (load) begin
            next_count = load_value;
        end

        else if (enable) begin

            if (up_down) begin
                if (count < max_count) begin
                    next_count = count + 1;
                end
                else begin
                    next_count = 0;
                end
            end 
            else begin
                if (count > 0) begin
                    next_count = count - 1;
                end 
                else begin
                    next_count = max_count;
                end
            end

        end

    end

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            count <= 8'd0;
        end 
        else begin
            count <= next_count;
        end
        
    end

    assign zero = (next_count == 8'd0);
    assign tc   = (up_down && next_count == max_count) || (!up_down && next_count == 8'd0);


endmodule
