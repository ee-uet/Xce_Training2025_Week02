module vending_machine (
    input  logic clk,
    input  logic rst_n,
    input  logic coin_5,
    input  logic coin_10,
    input  logic coin_25,
    input  logic coin_return,
    output logic dispense,
    output logic [5:0] amount_display,
    output logic return_5,
    output logic [1:0] return_10,
    output logic return_25
);

typedef enum logic [2:0] {S0, S5, S10, S15, S20, S25, S30, S_Dispense} state;
state current_state, next_state;
logic [5:0] paid_amount;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= S0;
        paid_amount   <= 6'd0;
    end
    else begin
        current_state <= next_state;
        if (next_state == S_Dispense) begin
            paid_amount <= amount_display;
        end
        else if (current_state == S_Dispense) begin
            paid_amount <= 6'd0;
        end
    end
end

always_comb begin
    next_state = current_state;
    case (current_state)
        S0:   if (coin_5)  next_state = S5;
              else if (coin_10) next_state = S10;
              else if (coin_25) next_state = S25;
        S5:   if (coin_5)  next_state = S10;
              else if (coin_10) next_state = S15;
              else if (coin_25) next_state = S30;
        S10:  if (coin_5)  next_state = S15;
              else if (coin_10) next_state = S20;
              else if (coin_25) next_state = S_Dispense;
        S15:  if (coin_5)  next_state = S20;
              else if (coin_10) next_state = S25;
              else if (coin_25) next_state = S_Dispense;
        S20:  if (coin_5)  next_state = S25;
              else if (coin_10) next_state = S30;
              else if (coin_25) next_state = S_Dispense;
        S25:  if (coin_5)  next_state = S30;
              else if (coin_10) next_state = S_Dispense;
              else if (coin_25) next_state = S_Dispense;
        S30:  next_state = S_Dispense;
        S_Dispense: next_state = S0;
    endcase
end

always_comb begin
    dispense     = 1'b0;
    return_5     = 1'b0;
    return_10    = 2'b00;
    return_25    = 1'b0;
    amount_display = 6'd0;
    case (current_state)
        S0:   amount_display = 6'd0;
        S5:   amount_display = 6'd5;
        S10:  amount_display = 6'd10;
        S15:  amount_display = 6'd15;
        S20:  amount_display = 6'd20;
        S25:  amount_display = 6'd25;
        S30:  amount_display = 6'd30;
        S_Dispense: begin
            dispense = 1'b1;
            amount_display = paid_amount;
            if (paid_amount > 6'd30) begin
                case (paid_amount - 6'd30)
                    6'd5:   return_5  = 1'b1;
                    6'd10:  return_10 = 2'b01;
                    6'd15:  begin return_10 = 2'b01; return_5 = 1'b1; end
                    6'd20:  return_10 = 2'b10;
                    6'd25:  return_25 = 1'b1;
                endcase
            end
        end
    endcase
    if (coin_return) begin
        case (current_state)
            S5:   return_5  = 1'b1;
            S10:  return_10 = 2'b01;
            S15:  begin return_10 = 2'b01; return_5 = 1'b1; end
            S20:  return_10 = 2'b10;
            S25:  return_25 = 1'b1;
        endcase
        next_state = S0;
    end
end

endmodule
