module programmable_counter (
    input  logic        clk,    
    input  logic        rst, 
    input  logic        load,       //signal to load 
    input  logic        enable,     //enable counter      
    input  logic        up_down,    //mode to count up or down
    input  logic  [7:0] load_value, //value that is loaded
    input  logic  [7:0] max_count,  //value to count upto
    output logic  [7:0] count,      //current count
    output logic        tc,         //signal when max count reached
    output logic        zero        //signal when zero reached
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 8'd0;     
        end
        else if (load) begin
            count <= load_value;   // start from programmable load value
        end
        else if (enable) begin
            if (up_down) begin   // UP counter
                if (count == max_count)
                    count <= max_count;   // hold at max
                else
                    count <= count + 1;
            end
            else begin   // DOWN counter
                if (count == 0)
                    count <= 0;           // hold at 0
                else
                    count <= count - 1;
            end
        end
    end

    // Status outputs
    assign tc   = (up_down && count == max_count);  
    assign zero = (!up_down && count == 0);

endmodule

