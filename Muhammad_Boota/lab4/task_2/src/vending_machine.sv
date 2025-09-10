import pkg::*;
module vending_machine (
input  logic clk,
input  logic rst_n,
input  logic coin_5,
// 5-cent coin inserted
input  logic coin_10, // 10-cent coin inserted
input  logic coin_25, // 25-cent coin inserted
input  logic coin_return,
output logic dispense_item,
output logic return_5, // Return 5-cent
output logic return_10, // Return 10-cent
output logic return_25, // Return 25-cent
output display [5:0] amount_display
);
coins curr_state,next_state;
// TOD: Implement vending machine FSM
always_ff @( posedge clk ) begin : blockName
    if (!rst_n)
        curr_state<=C_0;
    else 
        curr_state<=next_state;
end

always_comb begin 
    dispense_item=1'b0;
    return_10=1'b0;
    return_25=1'b0;
    return_5 =1'b0;
    case (curr_state)
        C_0:case (1'b1)
            coin_5 : next_state=C_5;
            coin_10: next_state=C_10;
            coin_25: next_state=C_25;
            default: next_state=curr_state;
        endcase
        C_5:case (1'b1)
            coin_return:begin
                return_5=1'b1;
                next_state=C_0;
                end 
            coin_5     : next_state=C_10;
            coin_10    : next_state=C_25;
            coin_25:begin
                next_state=C_0;
                dispense_item=1;
                end 
            default: next_state=curr_state;
             endcase
        C_10:case (1'b1)
            coin_return:begin
                return_10=1'b1;
                next_state=C_0;
                end
            coin_5 : next_state=C_15;
            coin_10: next_state=C_20;
            coin_25:begin
                next_state=C_5;
                dispense_item=1;
                end
            default: next_state=curr_state;
            endcase
        C_25:case (1'b1)
            coin_return:begin
                return_25=1'b1;
                next_state=C_0;
                end
            coin_5 :begin
                next_state=C_0;
                dispense_item=1;
                end
            coin_10:begin
                next_state=C_5;
                dispense_item=1;
                end 
            coin_25:begin
                next_state=C_20;
                dispense_item=1;
                end
            default: next_state=curr_state;
            endcase
        C_15:case (1'b1)
            coin_return:begin
                return_5=1'b1;
                next_state=C_10;
                end
            coin_5 :next_state=C_20;
            coin_10:next_state=C_25;
            coin_25:begin
                next_state=C_10;
                dispense_item=1;
                end
            default: next_state=curr_state;
            endcase
        C_20:case (1'b1)
            coin_return:begin
                return_10=1'b1;
                next_state=C_10;
            end
            coin_5 :next_state=C_25;
            coin_10:begin
                next_state=C_0;
                dispense_item=1;
            end 
            coin_25:begin
                next_state=C_15;
                dispense_item=1;
            end
            default: next_state=curr_state;
            endcase
        default: begin
            dispense_item=1'b0;
            next_state=C_0;
        end
    endcase
end

always_comb begin 
    case (curr_state)
        C_0: amount_display=COIN_0;
        C_5: amount_display=COIN_5;
        C_10:amount_display=COIN_10;
        C_15:amount_display=COIN_15;
        C_20:amount_display=COIN_20;
        C_25:amount_display=COIN_25; 
        default:amount_display=ERROR; 
    endcase
end
// Consider: Coin input synchronization and debouncing
endmodule