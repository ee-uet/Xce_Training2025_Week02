module lab4b (
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
	  // TODO: Implement Controller for Vending Machine
    parameter ITEM_PRICE = 30;

    typedef enum logic [1:0] {
        IDLE,
        ACCUMULATE,
        DISPENSE,
        RETURN_COINS
    } state_t;

    state_t state, next_state;
    logic [5:0] current_balance;
    logic [5:0] coin_sum;

    // Sequential Logic: Update state and balance on clock edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= IDLE;
            current_balance <= 6'd0;
        end else begin
            state <= next_state;
            
            // Balance update based on the next state
            case (next_state)
                IDLE: begin
                    current_balance <= 6'd0;
                end
                ACCUMULATE: begin
                    current_balance <= current_balance + coin_sum;
                end
                DISPENSE: begin
                    current_balance <= (current_balance + coin_sum) - ITEM_PRICE;
                end
                RETURN_COINS: begin
                    // Balance is decremented based on the coin returned in the previous state's output
                    if (return_25)
                        current_balance <= current_balance - 6'd25;
                    else if (return_10)
                        current_balance <= current_balance - 6'd10;
                    else if (return_5)
                        current_balance <= current_balance - 6'd5;
                    else
                        current_balance <= current_balance; // No change if no coin is returned
                end
                default: current_balance <= 6'd0;
            endcase
        end
    end

    // Combinational Logic 1: Determine next state and coin sum
    always_comb begin
        // Defaults
        next_state   = state;
        coin_sum     = 6'd0;

        if (coin_5)   coin_sum += 6'd5;
        if (coin_10)  coin_sum += 6'd10;
        if (coin_25)  coin_sum += 6'd25;

        case (state)
            IDLE: begin
                if (coin_sum > 6'd0)
                    next_state = ACCUMULATE;
                else if (coin_return && current_balance > 6'd0)
                    next_state = RETURN_COINS;
				else if (coin_return && current_balance == 6'd0)
                    next_state = IDLE;
				else 
                    next_state = IDLE;
            end
            ACCUMULATE: begin
                if ((current_balance + coin_sum) >= ITEM_PRICE)
                    next_state = DISPENSE;
                else if (coin_return)
                    next_state = RETURN_COINS;
				else if (current_balance == 6'd0)
					next_state = IDLE;
				else 
					next_state = ACCUMULATE;
            end
            DISPENSE: begin
                if (current_balance > 6'd0)
                    next_state = ACCUMULATE;
				else if (coin_return && current_balance >= 6'd0)
					next_state = RETURN_COINS;
                else
                    next_state = IDLE;
            end
            RETURN_COINS: begin
                if (current_balance >= 6'd5)
                    next_state = RETURN_COINS;
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Combinational Logic 2: Determine outputs
    always_comb begin
        dispense_item = 1'b0;
        return_5      = 1'b0;
        return_10     = 1'b0;
        return_25     = 1'b0;
        amount_display = current_balance;

        case (state)
            DISPENSE: begin
                dispense_item = 1'b1;
            end
            RETURN_COINS: begin
                if (current_balance >= 6'd25)
                    return_25 = 1'b1;
                else if (current_balance >= 6'd10)
                    return_10 = 1'b1;
                else if (current_balance >= 6'd5)
                    return_5 = 1'b1;
            end
        endcase
    end

endmodule