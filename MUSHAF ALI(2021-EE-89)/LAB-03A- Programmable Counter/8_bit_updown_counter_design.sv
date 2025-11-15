module programe_able_updown_counter (
    input logic clk,rst,enable,updown,load,
    input logic [7:0] load_data,
    input logic [7:0] upper_limit,lower_limit,
    output logic terminal_count,zero_count,
    output logic [7:0] count
);

//internal signals

logic up_res,down_res; ///gave the final result as 1 bit for upper and lower match
logic [7:0] next_count;

//sequential logic

always_ff @(posedge clk) begin

    // Reset logic
    if(rst) begin
    count<=8'b0;
    end

// data loading in count register
    else if (load) begin
        count<=load_data;
    end
    
    else if(enable) begin
        if(updown==1) begin
            if(up_res==1) begin
                count<=count; //hold the counter value at upper_limit
            end
            else begin
                count<=next_count; // go to next state (do increment by 1)
            end
        end
        else begin
            if(down_res==1) begin
                count<=count; //hold the counter value at lower_limit
            end
            else begin
                count<=next_count; // go to next state (do decrement by 1)
            end
            end
        
        end


    // if upper_limit  changes dynamically 
    if(count>upper_limit) begin
        count<=upper_limit;
    end

    // if lower_limit  changes dynamically 
    else if(count<lower_limit) begin
        count<=lower_limit;
    end

    end




//Combinational logic

always_comb begin

    //setting (initializing) outputs with zero just to avoid unintentional latches
    terminal_count=0;
    zero_count=0;
    next_count=count;

//comparator logic to check upper limit and lower limit reach

    up_res = (count == upper_limit);
    down_res = (count == lower_limit);


//next_count logic 

    if(enable) begin 
        if(updown==1) begin
            next_count=count+1; //increment by 1 in counter value
        end
        else begin
            next_count=count-1;  //decrement by 1 in counter value
        end
    end

    terminal_count = ((enable==1 && updown==1 && up_res==1) || (enable==1 && updown==0 && down_res==1)); //if any upper or lower active limit reaches then turn terminal_count high
    zero_count = ~|count;
end
endmodule