module vending_machine (
    input  logic       clk,           // Clock signal
    input  logic       rst_n,         // Active-low reset
    input  logic       coin_5,        // 5-cent coin inserted
    input  logic       coin_10,       // 10-cent coin inserted
    input  logic       coin_25,       // 25-cent coin inserted
    input  logic       coin_return,   // Coin return request
    output logic       dispense_item, // Dispense item signal
    output logic       return_5,      // Return 5-cent coin
    output logic       return_10,     // Return 10-cent coin
    output logic       return_25,     // Return 25-cent coin
    output logic [5:0] amount_display // LED display for current amount
);

    // State encoding
    typedef enum logic [2:0] {
        S0  = 3'd0,  // 0 cent
        S5  = 3'd1,  // 5 cent
        S10 = 3'd2,  // 10 cent
        S15 = 3'd3,  // 15 cent
        S20 = 3'd4,  // 20 cent
        S25 = 3'd5,  // 25 cent
        S30 = 3'd6   // 30 cent (post-dispense)
    } state_t;

    state_t state, next_state;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    // Next state and output logic
    always_comb begin
        // Default assignments
        next_state = state;
        dispense_item = 0;
        return_5 = 0;
        return_10 = 0;
        return_25 = 0;
        amount_display = 6'd0;

        // Priority encoder for mutually exclusive inputs
        case (state)
            S0: begin
                amount_display = 6'd0;
                if (coin_5) begin
                    next_state = S5;
                    amount_display = 6'd5;
                end else if (coin_10) begin
                    next_state = S10;
                    amount_display = 6'd10;
                end else if (coin_25) begin
                    next_state = S25;
                    amount_display = 6'd25;
                end else if (coin_return) begin
                    next_state = S0;
                    amount_display = 6'd0;
                end
            end
            S5: begin
                amount_display = 6'd5;
                if (coin_5) begin
                    next_state = S10;
                    amount_display = 6'd10;
                end else if (coin_10) begin
                    next_state = S15;
                    amount_display = 6'd15;
                end else if (coin_25) begin
                    next_state = S30;
                    dispense_item = 1;
                    amount_display = 6'd30;
                end else if (coin_return) begin
                    next_state = S0;
                    return_5 = 1;
                    amount_display = 6'd0;
                end
            end
            S10: begin
                amount_display = 6'd10;
                if (coin_5) begin
                    next_state = S15;
                    amount_display = 6'd15;
                end else if (coin_10) begin
                    next_state = S20;
                    amount_display = 6'd20;
                end else if (coin_25) begin
                    next_state = S30;
                    dispense_item = 1;
                    return_5 = 1;
                    amount_display = 6'd35;
                end else if (coin_return) begin
                    next_state = S0;
                    return_10 = 1;
                    amount_display = 6'd0;
                end
            end
            S15: begin
                amount_display = 6'd15;
                if (coin_5) begin
                    next_state = S20;
                    amount_display = 6'd20;
                end else if (coin_10) begin
                    next_state = S25;
                    amount_display = 6'd25;
                end else if (coin_25) begin
                    next_state = S30;
                    dispense_item = 1;
                    return_10 = 1;
                    amount_display = 6'd40;
                end else if (coin_return) begin
                    next_state = S0;
                    return_5 = 1;
                    return_10 = 1;
                    amount_display = 6'd0;
                end
            end
            S20: begin
                amount_display = 6'd20;
                if (coin_5) begin
                    next_state = S25;
                    amount_display = 6'd25;
                end else if (coin_10) begin
                    next_state = S30;
                    dispense_item = 1;
                    amount_display = 6'd30;
                end else if (coin_25) begin
                    next_state = S30;
                    dispense_item = 1;
                    return_5 = 1;
                    return_10 = 1;
                    amount_display = 6'd45;
                end else if (coin_return) begin
                    next_state = S5;
                    return_5 = 1;
                    return_10 = 1;
                    amount_display = 6'd5;
                end
            end
            S25: begin
                amount_display = 6'd25;
                if (coin_5) begin
                    next_state = S30;
                    dispense_item = 1;
                    amount_display = 6'd30;
                end else if (coin_10) begin
                    next_state = S30;
                    dispense_item = 1;
                    return_5 = 1;
                    amount_display = 6'd35;
                end else if (coin_25) begin
                    next_state = S5;
                    dispense_item = 1;
                    return_5 = 1;
                    return_10 = 1;
                    amount_display = 6'd50;
                end else if (coin_return) begin
                    next_state = S0;
                    return_25 = 1;
                    amount_display = 6'd0;
                end
            end
            S30: begin
                amount_display = 6'd0;
                if (coin_5) begin
                    next_state = S5;
                    amount_display = 6'd5;
                end else if (coin_10) begin
                    next_state = S10;
                    amount_display = 6'd10;
                end else if (coin_25) begin
                    next_state = S25;
                    amount_display = 6'd25;
                end else if (coin_return) begin
                    next_state = S0;
                    amount_display = 6'd0;
                end
            end
            default: begin
                next_state = S0;
                amount_display = 6'd0;
            end
        endcase
    end

endmodule