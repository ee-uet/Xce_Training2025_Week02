module vending_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       coin_5,      // 5-cent coin inserted
    input  logic       coin_10,     // 10-cent coin inserted
    input  logic       coin_25,     // 25-cent coin inserted
    input  logic       coin_return,
    output logic       dispense_item,
    output logic       return_5,    // Return 5-cent
    output logic       return_10,   // Return 10-cent
    output logic       return_25,   // Return 25-cent
    output logic [5:0] amount_display
);

    // TODO: Implement vending machine FSM
    // Consider: Coin input synchronization and debouncing
// Define state enumeration
typedef enum logic [2:0] {
    IDLE = 3'b000,
    cent_5 = 3'b001,
    cent_10 = 3'b010,
    cent_15 = 3'b011,
    cent_20 = 3'b100,
    cent_25 = 3'b101
} state_t;
state_t current_state, next_state;
    // State register - ALWAYS separate this
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
   always_comb begin
    next_state = current_state; // Default assignment prevents latches
    case (current_state)
        IDLE:
            if (coin_5)
                next_state = cent_5;
            else if (coin_10)
                next_state = cent_10;
            else if (coin_25)
                next_state = cent_25;
            else if (coin_return)
                next_state = IDLE;
            else
                next_state = IDLE;

        cent_5:
            if (coin_5)
                next_state = cent_10;
            else if (coin_10)
                next_state = cent_15;
            else if (coin_25)
                next_state = IDLE; // dispense item
             else if (coin_return)
                next_state = IDLE;
            else
                next_state = cent_5;

        cent_10:
            if (coin_5)
                next_state = cent_15;
            else if (coin_10)
                next_state = cent_20;
            else if (coin_25)
                next_state = IDLE;
            else
                next_state = cent_10;

        cent_15:
            if (coin_5)
                next_state = cent_20;
            else if (coin_10)
                next_state = cent_25;
            else if (coin_25)
                next_state = IDLE;
            else
                next_state = cent_15;

        cent_20:
            if (coin_5)
                next_state = cent_25;
            else if (coin_10)
                next_state = IDLE;
            else if (coin_25)
                next_state = IDLE;
            else
                next_state = cent_20;

        cent_25:
            if (coin_5)
                next_state = IDLE;
            else if (coin_10)
                next_state = IDLE;
            else if (coin_25)
                next_state = IDLE;
            else
                next_state = cent_25;
    endcase
end

always_comb begin
  dispense_item = 0;
     return_10 = 0;
     return_25 = 0;
     return_5  = 0;
     amount_display = 0;

  case (current_state) 
  
    IDLE:begin
    dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5 = 0;
    amount_display = 0;
     if (coin_5) begin
      amount_display = 5;
      dispense_item = 0;
      return_10 = 0;
      return_25 = 0;
      return_5  = 0;
    end
    else if (coin_10) begin
      amount_display = 10;
      dispense_item = 0;
      return_10 = 0;
      return_25 = 0;
      return_5  = 0;
    end
    else if (coin_25) begin
      amount_display = 25;
      dispense_item = 0;
      return_10 = 0;
      return_25 = 0;
      return_5  = 0;
    end
    else begin
       dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5 = 0;
    amount_display = 0;
    end
    end
    cent_5: begin
    // Default outputs
    dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5  = 0;
    amount_display = 5;

    if (coin_return) begin
        amount_display = 0;
        dispense_item = 0;
        return_5 = 1;    // return the 5 cents
        return_10 = 0;
        return_25 = 0;
    end
    else begin
        if (coin_5) begin
            amount_display = 10;
            dispense_item = 0;
             return_5 = 0;   
             return_10 = 0;
             return_25 = 0;
        end
        else if (coin_10) begin
            amount_display = 15;
            dispense_item = 0;
            return_5 = 0;   
            return_10 = 0;
            return_25 = 0;
        end
        else if (coin_25) begin
            amount_display = 30;
          if (coin_return) begin
            dispense_item = 0;  
            return_5 = 1;   
            return_10 = 0;
            return_25 = 1;
          end
          else begin
            dispense_item = 1;
            return_5 = 0;   
            return_10 = 0;
            return_25 = 0;
        end
        end
    end
end
    cent_10: begin
    dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5 = 0;
    amount_display = 10;
     if (coin_return) begin
        amount_display = 0;
        dispense_item = 0;
        return_5 = 0;    // return the 10 cents
        return_10 = 1;
        return_25 = 0;
     end
     else begin
       if (coin_5)  begin
           amount_display = 15;
           dispense_item = 0;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
    else if (coin_10) begin
           amount_display = 20;
           dispense_item = 0;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
     else if (coin_25) begin
           amount_display = 35;
           dispense_item = 1;
            return_10 = 0;
            return_25 = 0;
            return_5 = 1;
    end
     else  begin
        dispense_item = 0;
        return_10 = 0;
        return_25 = 0;
        return_5 = 0;
    end
    end
    end
    cent_15: begin
    dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5 = 0;
    amount_display = 15;
    if (coin_return) begin
        amount_display = 0;
        dispense_item = 0;
        return_5 = 1;    // return the 10 cents
        return_10 = 1;
        return_25 = 0;
     end
     else begin
    if (coin_5)  begin
           amount_display = 20;
           dispense_item = 0;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
     else if (coin_10) begin
           amount_display = 25;
           dispense_item = 0;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
     else if (coin_25) begin
           amount_display = 40;
           dispense_item = 1;
            return_10 = 1;
            return_25 = 0;
            return_5 = 0;
    end
     else  begin
        dispense_item = 0;
        return_10 = 0;
        return_25 = 0;
        return_5 = 0;
    end
    end
    end
    cent_20: begin
    dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5 = 0;
    amount_display = 20;
     if (coin_return) begin
        amount_display = 0;
        dispense_item = 0;
        return_5 = 0;   
        return_10 = 1;  /////
        return_25 = 0;
       end
     else begin
     if (coin_5)  begin
           amount_display = 25;
           dispense_item = 0;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
     else if (coin_10) begin
           amount_display = 30;
           dispense_item = 1;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
     else if (coin_25) begin
           amount_display = 45;
           dispense_item = 1;
            return_10 = 1;
            return_25 = 0;
            return_5 = 1;
    end
     else  begin
        dispense_item = 0;
        return_10 = 0;
        return_25 = 0;
        return_5 = 0;
    end
    end
    end
    cent_25: begin
    dispense_item = 0;
    return_10 = 0;
    return_25 = 0;
    return_5 = 0;
    amount_display = 25;
     if (coin_return) begin
        amount_display = 0;
        dispense_item = 0;
        return_5 =  0;    // return the 25 cents
        return_10 = 0;
        return_25 = 1;
       end
    if (coin_5)  begin
           amount_display = 30;
           dispense_item = 1;
            return_10 = 0;
            return_25 = 0;
            return_5 = 0;
    end
    else if (coin_10) begin
           amount_display = 35;
           dispense_item = 1;
            return_10 = 0;
            return_25 = 0;
            return_5 = 1;
    end
    else if (coin_25) begin
           amount_display = 50;
           dispense_item = 1;
            return_10 = 1;
            return_25 = 0;
            return_5 = 0;
    end
    else  begin
        dispense_item = 0;
        return_10 = 0;
        return_25 = 0;
        return_5 = 0;
    end
    end

endcase
    // Output logic - Separate from state logic
end // TODO: Implement Moore or Mealy outputs
endmodule