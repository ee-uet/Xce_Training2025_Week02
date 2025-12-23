module vending_mach (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       coin_5,
    input  logic       coin_10,
    input  logic       coin_25,
    input  logic       coin_return,
    output logic       dispense_item,
    output logic       return_5,
    output logic       return_10,
    output logic       return_25,
    output logic [5:0] amount_display
);
    parameter ITEM_PRICE = 30;

    typedef enum logic [1:0] {
        IDLE,
        ACCUMULATE,
        DISPENSE,
        RETURN_COINS
    } state_t;

    state_t current_state, next_state;
    logic [5:0] balance;
    logic [5:0] coin_sum;

    // sequential logic: update state and balance on clock edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            balance <= 6'd0; // reset balance to 0
        end else begin
            current_state <= next_state;
            
            // balance update based on next state
            case (next_state)
                IDLE: begin
                    balance <= 6'd0; // clear balance
                end
                ACCUMULATE: begin
                    balance <= balance + coin_sum; // add coin value to balance
                end
                DISPENSE: begin
                    balance <= (balance + coin_sum) - ITEM_PRICE; // subtract item price
                end
                RETURN_COINS: begin
                    // decrement balance based on returned coin
                    if (return_25)
                        balance <= balance - 6'd25;
                    else if (return_10)
                        balance <= balance - 6'd10;
                    else if (return_5)
                        balance <= balance - 6'd5;
                    else
                        balance <= balance; // no change if no coin returned
                end
                default: balance <= 6'd0; // default to zero balance
            endcase
        end
    end

    // determine next state and coin sum
    always_comb begin
        // default assignments
        next_state = current_state;
        coin_sum = 6'd0;

        // calculate total coin value inserted
        if (coin_5)   coin_sum += 6'd5;
        if (coin_10)  coin_sum += 6'd10;
        if (coin_25)  coin_sum += 6'd25;

        case (current_state)
            IDLE: begin
                if (coin_sum > 6'd0)
                    next_state = ACCUMULATE; // move to accumulate on coin input
                else if (coin_return && balance > 6'd0)
                    next_state = RETURN_COINS; // return coins if balance exists
                else if (coin_return && balance == 6'd0)
                    next_state = IDLE; // stay idle if no balance
                else 
                    next_state = IDLE; // default stay in idle
            end
            ACCUMULATE: begin
                if ((balance + coin_sum) >= ITEM_PRICE)
                    next_state = DISPENSE; // dispense if enough money
                else if (coin_return)
                    next_state = RETURN_COINS; // return coins if requested
                else if (balance == 6'd0)
                    next_state = IDLE; // return to idle if no balance
                else 
                    next_state = ACCUMULATE; // continue accumulating
            end
            DISPENSE: begin
                if (balance > 6'd0)
                    next_state = ACCUMULATE; // accumulate if balance remains
                else if (coin_return && balance >= 6'd0)
                    next_state = RETURN_COINS; // return coins if requested
                else
                    next_state = IDLE; // return to idle after dispensing
            end
            RETURN_COINS: begin
                if (balance >= 6'd5)
                    next_state = RETURN_COINS; // continue returning coins
                else
                    next_state = IDLE; // return to idle when no balance
            end
            default: next_state = IDLE; // default to idle
        endcase
    end

    // determine outputs
    always_comb begin
        // default output assignments
        dispense_item = 1'b0;
        return_5 = 1'b0;
        return_10 = 1'b0;
        return_25 = 1'b0;
        amount_display = balance; // display current balance

        case (current_state)
            DISPENSE: begin
                dispense_item = 1'b1; // activate dispense signal
            end
            RETURN_COINS: begin
                // return largest possible coin based on balance
                if (balance >= 6'd25)
                    return_25 = 1'b1;
                else if (balance >= 6'd10)
                    return_10 = 1'b1;
                else if (balance >= 6'd5)
                    return_5 = 1'b1;
            end
        endcase
    end

endmodule