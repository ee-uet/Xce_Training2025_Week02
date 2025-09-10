typedef enum logic [2:0] {
    Start        = 3'b000,
    five         = 3'b001,
    ten          = 3'b010,
    fifteen      = 3'b011,
    twenty       = 3'b100,
    twenty_five  = 3'b101,
    jam          = 3'b111
} state_t;

module vending_machine (
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

    // State registers
    state_t current_state, next_state;

    // Small counter for “two pulses of return_10”, etc.
    logic [1:0] extra_10;

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= Start;
        else
            current_state <= next_state;
    end

   
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            extra_10 <= 2'd0;
        end else if (current_state == twenty_five && coin_25) begin
            extra_10 <= 2'd2;
        end else if (coin_return && current_state == twenty) begin
            // example: returning two tens on coin_return
            extra_10 <= 2'd2;
        end else if (extra_10 > 0) begin
            extra_10 <= extra_10 - 1'b1;
        end
    end

   
    always_comb begin
        // default: stay put unless a transition condition matches
        next_state = current_state;

        unique case (current_state)
            Start: begin
                if (coin_5)       next_state = five;
                else if (coin_10) next_state = ten;
                else if (coin_25) next_state = twenty_five;
            end

            five: begin
                if (coin_5)       next_state = ten;
                else if (coin_10) next_state = fifteen;
                else if (coin_25) next_state = Start;
            end

            ten: begin
                if (coin_5)       next_state = fifteen;
                else if (coin_10) next_state = twenty;
                else if (coin_25) next_state = Start;
            end

            fifteen: begin
                if (coin_5)       next_state = twenty;
                else if (coin_10) next_state = twenty_five;
                else if (coin_25) next_state = Start;
            end

            twenty: begin
                if (coin_5)       next_state = twenty_five;
                else if (coin_10) next_state = Start;
                else if (coin_25) next_state = Start;
            end

            twenty_five: begin
                if (coin_5)       next_state = Start;
                else if (coin_10) next_state = Start;
                else if (coin_25) next_state = Start;
            end


            jam: begin
                if (~(coin_5 || coin_10 || coin_25))
                    next_state = Start; // capitalization fixed
                else
                    next_state = jam;
            end
        endcase

        // Enter jam if a coin is seen but no state change was selected
        if ((coin_5 || coin_10 || coin_25) && (next_state == current_state))
            next_state = jam;
    end

    
    always_comb begin
        // defaults
        dispense_item  = 1'b0;
        return_5       = 1'b0;
        return_10      = 1'b0;
        return_25      = 1'b0;
        amount_display = 6'd0;

        // pulse return_10 while extra_10 > 0
        if (extra_10 > 0)
            return_10 = 1'b1;

        unique case (current_state)
            Start: begin
                if (coin_5)       amount_display = 6'd5;
                else if (coin_10) amount_display = 6'd10;
                else if (coin_25) amount_display = 6'd25;
            end

            five: begin
                if (coin_5)       amount_display = 6'd10;
                else if (coin_10) amount_display = 6'd15;
                else if (coin_25) begin
                    amount_display = 6'd30;
                    dispense_item  = 1'b1;
                end
            end

            ten: begin
                if (coin_5)       amount_display = 6'd15;
                else if (coin_10) amount_display = 6'd20;
                else if (coin_25) begin
                    amount_display = 6'd35;
                    dispense_item  = 1'b1;
                    return_5       = 1'b1;
                end
            end

            fifteen: begin
                if (coin_5)       amount_display = 6'd20;
                else if (coin_10) amount_display = 6'd25;
                else if (coin_25) begin
                    amount_display = 6'd40;
                    dispense_item  = 1'b1;
                    return_10      = 1'b1;
                end
            end

            twenty: begin
                if (coin_5)       amount_display = 6'd25;
                else if (coin_10) begin
                    amount_display = 6'd30;
                    dispense_item  = 1'b1;
                end
                else if (coin_25) begin
                    amount_display = 6'd45;
                    dispense_item  = 1'b1;
                    return_10      = 1'b1;
                    return_5       = 1'b1;
                end
            end

            twenty_five: begin
                if (coin_5) begin
                    amount_display = 6'd30;
                    dispense_item  = 1'b1;
                end else if (coin_10) begin
                    amount_display = 6'd35;
                    dispense_item  = 1'b1;
                    return_5       = 1'b1;
                end else if (coin_25) begin
                    amount_display = 6'd50;
                    dispense_item  = 1'b1;
                end
            end

            default: /* Start, jam */ ;
        endcase

        // Handle coin_return outputs
        if (coin_return) begin
            unique case (current_state)
                five: begin
                    return_5  = 1'b1;
                end
                ten: begin
                    return_10 = 1'b1;
                end
                fifteen: begin
                    return_10 = 1'b1;
                    return_5  = 1'b1;
                end
                twenty_five: begin
                    return_25 = 1'b1;
                end
                default: ;
            endcase
        end
    end

endmodule
