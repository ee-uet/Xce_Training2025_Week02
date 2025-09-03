module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,       
    input  logic        load,
    input  logic        enable,
    input  logic        up_down,     // 1 = up, 0 = down
    input  logic [7:0]  load_value,
    input  logic [7:0]  max_count,
    output logic [7:0]  count,
    output logic        tc,          
    output logic        zero         
);

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 8'd0;
        end
        else if (load) begin
            
            count <= load_value;
        end
        else if (enable) begin
            if (up_down) begin
                
                if (count == max_count)
                    count <= 8'd0;
                else
                    count <= count + 8'd1;
            end
            else begin
                
                if (count == 8'd0)
                    count <= max_count;
                else
                    count <= count - 8'd1;
            end
        end
        
    end

    
    always_comb begin
        tc   = (count == max_count);
        zero = (count == 8'd0);
    end




endmodule
