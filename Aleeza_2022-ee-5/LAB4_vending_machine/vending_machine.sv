module vending_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       coin_5,      // Inserted a 5-cent coin
    input  logic       coin_10,     // Inserted a 10-cent coin
    input  logic       coin_25,     // Inserted a 25-cent coin
    input  logic       coin_return, // User pressed coin return button
    output logic       dispense_item, // Give the item to the customer
    output logic       return_5,    // Return a 5-cent coin
    output logic       return_10,   // Return a 10-cent coin
    output logic       return_25,   // Return a 25-cent coin
    output logic [5:0] amount_display // Show how much has been inserted
);

    //--- State machine to track how much money is currently inserted ---
    typedef enum logic [2:0] {
        IDLE = 3'b000, // No money inserted
        S5   = 3'b001, // 5 cents total
        S10  = 3'b010, // 10 cents total
        S15  = 3'b011, // 15 cents total
        S20  = 3'b100, // 20 cents total
        S25  = 3'b101  // 25 cents total
    } state_t;

    state_t current_state, next_state;

    //--- State register: update on clock or reset ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE; // Start with no money
        else
            current_state <= next_state; // Otherwise go to next state
    end
    
    //--- Next state logic: decide how much money we’ll have after new coins ---
    always_comb begin
        next_state = current_state; // Default: stay in same state
        case (current_state)
            // In each state, check which coin came in and move to next
            IDLE:
                if (coin_5)
                    next_state = S5;
                else if (coin_10)
                    next_state = S10;
                else if (coin_25)
                    next_state = S25;
                else if (coin_return)
                    next_state = IDLE;
                else
                    next_state = IDLE;

            S5:
                if (coin_5)
                    next_state = S10;
                else if (coin_10)
                    next_state = S15;
                else if (coin_25)
                    next_state = IDLE; // Enough to dispense
                else if (coin_return)
                    next_state = IDLE;
                else
                    next_state = S5;

            S10:
                if (coin_5)
                    next_state = S15;
                else if (coin_10)
                    next_state = S20;
                else if (coin_25)
                    next_state = IDLE;
                else if (coin_return)
                    next_state = IDLE;                
                else
                    next_state = S10;

            S15:
                if (coin_5)
                    next_state = S20;
                else if (coin_10)
                    next_state = S25;
                else if (coin_25)
                    next_state = IDLE;
                else if (coin_return)
                    next_state = IDLE;
                else
                    next_state = S15;

            S20:
                if (coin_5)
                    next_state = S25;
                else if (coin_10)
                    next_state = IDLE; // Enough money to dispense
                else if (coin_25)
                    next_state = IDLE;
                else if (coin_return)
                    next_state = IDLE;
                else
                    next_state = S20;

            S25:
                if (coin_5)
                    next_state = IDLE; // Overpay, dispense & reset
                else if (coin_10)
                    next_state = IDLE;
                else if (coin_25)
                    next_state = IDLE;
                else if (coin_return)
                    next_state = IDLE;
                else
                    next_state = S5;
        endcase
    end

    //--- Output logic: show amount, dispense item, and coin returns ---
    always_comb begin
        // Default outputs (safe)
        dispense_item  = 0;
        return_10      = 0;
        return_25      = 0;
        return_5       = 0;
        amount_display = 0;

        // Handle outputs for each state
        case (current_state) 
            // Each state displays how much money so far,
            // and decides when to dispense or return coins

            IDLE: begin
                amount_display = 0;
                // If coins inserted while in IDLE, show them immediately
                if (coin_5)      amount_display = 5;
                else if (coin_10) amount_display = 10;
                else if (coin_25) amount_display = 25;
            end

            S5: begin
                amount_display = 5; // Show 5 cents
                if (coin_return) begin
                    // User pressed return
                    return_5 = 1;
                    amount_display = 0;
                end else begin
                    // Insert more coins, accumulate amount
                    if (coin_5)      amount_display = 10;
                    else if (coin_10) amount_display = 15;
                    else if (coin_25) begin
                        // Enough money, dispense
                        amount_display = 30;
                        dispense_item  = 1;
                    end
                end
            end

            S10: begin
                amount_display = 10;
                if (coin_return) begin
                    return_10 = 1;
                    amount_display = 0;
                end else begin
                    if (coin_5)       amount_display = 15;
                    else if (coin_10) amount_display = 20;
                    else if (coin_25) begin
                        // Overpay: dispense + return change
                        amount_display = 35;
                        dispense_item  = 1;
                        return_5       = 1; // return extra 5
                    end
                end
            end

            S15: begin
                amount_display = 15;
                if (coin_return) begin
                    return_5  = 1;
                    return_10 = 1;
                    amount_display = 0;
                end else begin
                    if (coin_5)       amount_display = 20;
                    else if (coin_10) amount_display = 25;
                    else if (coin_25) begin
                        amount_display = 40;
                        dispense_item  = 1;
                        return_10      = 1; // return extra 10
                    end
                end
            end

            S20: begin
                amount_display = 20;
                if (coin_return) begin
                    return_10 = 1;
                    amount_display = 0;
                end else begin
                    if (coin_5)       amount_display = 25;
                    else if (coin_10) begin
                        amount_display = 30;
                        dispense_item  = 1; // Enough money
                    end else if (coin_25) begin
                        amount_display = 45;
                        dispense_item  = 1;
                        return_10      = 1;
                        return_5       = 1; // return extra coins
                    end
                end
            end

            S25: begin
                amount_display = 25;
                if (coin_return) begin
                    return_25 = 1;
                    amount_display = 0;
                end else begin
                    if (coin_5) begin
                        amount_display = 30;
                        dispense_item  = 1;
                    end else if (coin_10) begin
                        amount_display = 35;
                        dispense_item  = 1;
                        return_5       = 1;
                    end else if (coin_25) begin
                        amount_display = 50;
                        dispense_item  = 1;
                        return_10      = 1; // return extra 10
                    end
                end
            end
        endcase
    end 
endmodule

