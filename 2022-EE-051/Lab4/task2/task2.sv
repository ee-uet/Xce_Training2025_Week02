typedef enum logic [3:0] {
    S0       = 4'd0,
    S5       = 4'd1,
    S10      = 4'd2,
    S15      = 4'd3,
    S20      = 4'd4,
    S25      = 4'd5,
    COIN_JAM = 4'd6
} state_t;

module vending_machine_fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic coin_5,
    input  logic coin_10,
    input  logic coin_25,
    input  logic coin_return,
    output logic dispense_item,
    output logic return_10,
    output logic return_5,
    output logic return_25,
    output logic [5:0] amount_display
);

    state_t current_state, next_state;
    logic [5:0] amount_reg;
    logic [5:0] last_amount;
    logic [1:0] return_10_count;

    // State register update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S0;
            last_amount   <= 0;
        end else begin
            current_state <= next_state;
            if (next_state != COIN_JAM)
                last_amount <= amount_reg;
        end
    end

    // Next-state logic
    always_comb begin
        next_state = current_state;

        // Coin jam detection
        if ((coin_5 || coin_10 || coin_25) && (current_state == S0 || current_state == COIN_JAM)) begin
            next_state = COIN_JAM;
        end else begin
            case (current_state)
                S0: begin
                    if (coin_5)      next_state = S5;
                    else if (coin_10) next_state = S10;
                    else if (coin_25) next_state = S25;
                end
                S5: begin
                    if (coin_return) next_state = S0;
                    else if (coin_5) next_state = S10;
                    else if (coin_10) next_state = S15;
                    else if (coin_25) next_state = S0;
                end
                S10: begin
                    if (coin_return) next_state = S0;
                    else if (coin_5) next_state = S15;
                    else if (coin_10) next_state = S20;
                    else if (coin_25) next_state = S0;
                end
                S15: begin
                    if (coin_return) next_state = S0;
                    else if (coin_5) next_state = S20;
                    else if (coin_10) next_state = S25;
                    else if (coin_25) next_state = S0;
                end
                S20: begin
                    if (coin_return) next_state = S0;
                    else if (coin_5) next_state = S25;
                    else if (coin_10 || coin_25) next_state = S0;
                end
                S25: begin
                    if (coin_return) next_state = S0;
                    else if (coin_5 || coin_10 || coin_25) next_state = S0;
                end
                COIN_JAM: next_state = COIN_JAM;
            endcase
        end
    end

    // Output logic
    always_comb begin
        dispense_item   = 0;
        return_5        = 0;
        return_10       = 0;
        return_25       = 0;
        return_10_count = 0;
        amount_reg      = 0;

        case (current_state)
            S0: amount_reg = 0;

            S5: begin
                amount_reg = 5;
                if (coin_return) return_5 = 1;
            end

            S10: begin
                amount_reg = 10;
                if (coin_return) return_10_count = 1;
                else if (coin_25) return_5 = 1;
            end

            S15: begin
                amount_reg = 15;
                if (coin_return) begin
                    return_10_count = 1;
                    return_5 = 1;
                end else if (coin_25) begin
                    return_10_count = 1;
                end
            end

            S20: begin
                amount_reg = 20;
                if (coin_return) return_10_count = 2;
                else if (coin_25) begin
                    return_10_count = 1;
                    return_5 = 1;
                end
            end

            S25: begin
                amount_reg = 25;
                if (coin_return) return_25 = 1;
                else if (coin_5) dispense_item = 1;
                else if (coin_10) begin
                    dispense_item = 1;
                    return_5 = 1;
                end else if (coin_25) begin
                    dispense_item = 1;
                    return_10_count = 2;
                end
            end

            COIN_JAM: amount_reg = last_amount;
        endcase

        if (return_10_count > 0) return_10 = 1;
    end
    
    // display amount
    assign amount_display = amount_reg;

endmodule
