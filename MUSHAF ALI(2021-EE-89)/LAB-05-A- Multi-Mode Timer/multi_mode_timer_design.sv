/*
module clock_divider (
    input  logic clk, rst,
    input  logic [15:0] prescaler,
    output logic divided_clk
);

    logic [15:0] count = 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            count       <= 0;
            divided_clk <= 0;
        end
        else if (count == prescaler) begin
            count       <= 0;
            divided_clk <= ~divided_clk;
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

*/







module multi_mode_timer (
    input logic  divided_clk,rst, //divided clock and reset
    input logic [1:0] mode_sel, //for selecting mode
    input logic start, //for overall working of counter        
    input logic [31:0] duty_cycle, //for pwm mode only
    input logic [31:0] Load_Value, // used in all 4 modes
    output logic pwm_out, //for pwm mode
    output logic one_shot_mode_interupt,periodic_mode_interupt, pwm_mode_interupt, // interupts
    output logic [31:0] count_out //conter value
);

// internal signals
logic counting;  //1=>COUNT , 0==>NOT_COUNT

//sequential logic
always_ff @(posedge divided_clk) begin
    if(rst) begin
        one_shot_mode_interupt<=0;
        periodic_mode_interupt<=0;
        pwm_mode_interupt<=0;
        counting<=0;
        count_out<=0;
        pwm_out<=0;
    end 
    else begin
        one_shot_mode_interupt<=0;
        periodic_mode_interupt<=0;
        pwm_mode_interupt<=0;
        if(start) begin
            if(counting==0) begin
            count_out<=Load_Value;
            counting<=1;
            end
            else if(counting==1) begin
                case(mode_sel)
                    2'b00: count_out<=Load_Value; //hold the loaded value dont to decrement just keep it as it is.
                    2'b01: begin // one_shot_mode
                        if(count_out>0)
                        count_out<=count_out-1;
                        else begin
                            one_shot_mode_interupt<=1;
                        end
                        end
                    2'b10 : begin // period_mode
                        if(count_out>0)
                        count_out<=count_out-1;
                        else begin
                            count_out<=Load_Value;
                            periodic_mode_interupt<=1;
                        end
                    end
                    2'b11 : begin
                        if(count_out>0) begin
                        pwm_out <= (count_out > duty_cycle) ? 1 : 0;
                         count_out<=count_out-1;
                        end
                        else begin
                            count_out<=Load_Value;
                            pwm_mode_interupt<=1;
                        end
                    end
                endcase
            end
        end
        else begin
            pwm_out<=0;
            counting<=0;
    end
end
end
endmodule
    
