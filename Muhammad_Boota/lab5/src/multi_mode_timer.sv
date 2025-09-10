import pkg::*;
module multi_mode_timer (
input logic clk,
// 1 MHz
input logic rst_n,
input timer_mode mode,
// 00=off, 01=one-shot, 10=periodic, 11=PWM
input logic [15:0] prescaler, // Clock divider
input logic [31:0] reload_val,
input logic [31:0] compare_val, // For PWM duty cycle
input logic start,
output logic timeout,
output logic pwm_out,
output logic [31:0] current_count
);

logic pre_scale_clk,pre_scale_clk_next;
logic [31:0] compare_val_reg,compare_val_reg_n;
logic [15:0] scale,scale_next,pre_scale_reg,pre_scale_reg_n;


always_ff @( posedge clk ) begin 
    if (!rst_n) begin
        pre_scale_clk  <=0;
        scale          <=16'b0;
        pre_scale_reg  <=0;
        compare_val_reg<=0;
    end else begin
        compare_val_reg<=compare_val_reg_n;
        pre_scale_clk  <=pre_scale_clk_next;
        scale          <=scale_next;
        pre_scale_reg  <=pre_scale_reg_n;
    end
end


always_comb begin 
    if (scale==(pre_scale_reg)) begin
        compare_val_reg_n=compare_val;
        scale_next=0;
        pre_scale_clk_next=!pre_scale_clk;
        pre_scale_reg_n=prescaler;
    end else begin
        compare_val_reg_n=compare_val_reg;
        scale_next=scale+1;
        pre_scale_clk_next=pre_scale_clk;
        pre_scale_reg_n=pre_scale_reg;
    end
end


// TOD: Implement timer with all modes
logic load;
logic enable;
logic [31:0] load_value;
logic [31:0] count,count_n;
logic zero;

always_ff @(posedge pre_scale_clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            count <= count_n;
        end
    end
assign zero=(count==0);
always_comb begin 
    if (load && zero) begin
        count_n=load_value;
    end else begin
        count_n=(enable) ? count-1:count;
    end
end

timer_mode curr_mode,next_mode;
// Consider: How to handle mode changes during operation?
always_comb begin 
    timeout=0;
    pwm_out=0;;
    case (curr_mode)
        ONE_SHORT:begin
           timeout=zero;
        end
        PERIODIC:begin
            timeout=zero;
        end
        PWM:begin
            pwm_out=(count>compare_val_reg);
            timeout=zero;
        end
        default: begin end
    endcase
end

always_comb begin
    next_mode=OFF;
    load_value=0;
    load=0;
    enable=0;
    case (curr_mode)
        OFF:begin
            next_mode=mode;
            load_value=(mode ==2'b00) ? 0:reload_val;
            load=1;
        end
        ONE_SHORT:begin
            if (zero) begin
               next_mode=mode;
               load_value=(mode==2'b00) ? 0:reload_val;
               load=1; 
               enable=start;
            end else begin
                next_mode=ONE_SHORT;
                enable=1;
            end
        end
        PERIODIC:begin
            if (zero) begin
               next_mode=mode; 
               load_value=(mode ==2'b00) ? 0:reload_val;
               load=1;
               enable=(mode==2'b10) ? 1:start;
            end else begin
                next_mode=PERIODIC;
                enable=1;
            end
        end
        PWM:begin
           if (zero) begin
               next_mode=mode;
               load_value=(mode ==2'b00) ? 0:reload_val;
               load=1; 
               enable=(mode==2'b11)? 1:start;
           end else begin
                next_mode=PWM;
                enable=1;
            end
        end
        default: begin end
    endcase
end

always_ff @( posedge clk ) begin 
    if (!rst_n) begin
        curr_mode<=OFF;
    end else begin
        curr_mode<=next_mode;
    end
end

assign current_count=count;
endmodule