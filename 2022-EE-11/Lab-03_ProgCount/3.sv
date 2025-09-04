module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        load,
    input  logic        enable,
    input  logic        up_down,	// 0: up, 1: down
    input  logic [7:0]  load_value,
    input  logic [7:0]  max_count,
    output logic [7:0]  count,
    output logic        tc,          // Terminal count
    output logic        zero	     // Assuming 0 is the lower limit of counter.	
);

    // TODO: Implement counter logic
    // Consider: What happens when max_count changes during operation?
    always_ff @(posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
    		count <= #1 0;
    	end
    	else begin
    		case({up_down, enable, load})
    			3'b001: count <= (load_value > max_count) ? max_count : load_value;
    			3'b010: count <= tc ? max_count : count + 1;
    			3'b110: count <= zero ? count : count - 1;
    		endcase
    	end
    end
    
    assign zero = (count == 0);
    assign tc = (count >= max_count);
    
endmodule

