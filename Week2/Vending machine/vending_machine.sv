module vending_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       coin_5,
    input  logic       coin_10,
    input  logic       coin_25,
    input  logic       coin_return,
    output logic       dispense,
    output logic [5:0] amount_display,
    output logic       return_5,
    output logic [1:0] return_10,
    output logic       return_25
);

    // State encoding
    typedef enum logic [2:0] {
        IDLE,
        ST5,
        ST10,
        ST15,
        ST20,
        ST25,
        ST30,
        ST_DISPENSE
    } state_t;

    state_t cs, ns;
    logic [5:0] balance;

    // ------------------------------------------------------------
    // Sequential logic: state register and balance update
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs      <= IDLE;
            balance <= 6'd0;
        end 
        else begin
            cs <= ns;
            if (ns == ST_DISPENSE)       balance <= amount_display;
            else if (cs == ST_DISPENSE)  balance <= 6'd0;
        end
    end

    // ------------------------------------------------------------
    // Next state logic
    // ------------------------------------------------------------
    always_comb begin
        ns = cs;

        unique case (cs)
            IDLE: begin
                if      (coin_5)   ns = ST5;
                else if (coin_10)  ns = ST10;
                else if (coin_25)  ns = ST25;
            end

            ST5: begin
                if      (coin_5)   ns = ST10;
                else if (coin_10)  ns = ST15;
                else if (coin_25)  ns = ST30;
            end

            ST10: begin
                if      (coin_5)   ns = ST15;
                else if (coin_10)  ns = ST20;
                else if (coin_25)  ns = ST_DISPENSE;
            end

            ST15: begin
                if      (coin_5)   ns = ST20;
                else if (coin_10)  ns = ST25;
                else if (coin_25)  ns = ST_DISPENSE;
            end

            ST20: begin
                if      (coin_5)   ns = ST25;
                else if (coin_10)  ns = ST30;
                else if (coin_25)  ns = ST_DISPENSE;
            end

            ST25: begin
                if      (coin_5)   ns = ST30;
                else if (coin_10)  ns = ST_DISPENSE;
                else if (coin_25)  ns = ST_DISPENSE;
            end

            ST30:        ns = ST_DISPENSE;
            ST_DISPENSE: ns = IDLE;
        endcase
    end

    // ------------------------------------------------------------
    // Output logic
    // ------------------------------------------------------------
    always_comb begin
        // Default outputs
        dispense       = 1'b0;
        return_5       = 1'b0;
        return_10      = 2'b00;
        return_25      = 1'b0;
        amount_display = 6'd0;

        // Amount display and dispense
        unique case (cs)
            IDLE:        amount_display = 6'd0;
            ST5:         amount_display = 6'd5;
            ST10:        amount_display = 6'd10;
            ST15:        amount_display = 6'd15;
            ST20:        amount_display = 6'd20;
            ST25:        amount_display = 6'd25;
            ST30:        amount_display = 6'd30;

            ST_DISPENSE: begin
                dispense       = 1'b1;
                amount_display = balance;

                if (balance > 6'd30) begin
                    unique case (balance - 6'd30)
                        6'd5:   return_5  = 1'b1;
                        6'd10:  return_10 = 2'b01;
                        6'd15:  begin
                                    return_10 = 2'b01;
                                    return_5  = 1'b1;
                                end
                        6'd20:  return_10 = 2'b10;
                        6'd25:  return_25 = 1'b1;
                    endcase
                end
            end
        endcase

        // Coin return override
        if (coin_return) begin
            unique case (cs)
                ST5:   return_5  = 1'b1;
                ST10:  return_10 = 2'b01;
                ST15:  begin
                           return_10 = 2'b01;
                           return_5  = 1'b1;
                       end
                ST20:  return_10 = 2'b10;
                ST25:  return_25 = 1'b1;
            endcase
            ns = IDLE;
        end
    end

endmodule
