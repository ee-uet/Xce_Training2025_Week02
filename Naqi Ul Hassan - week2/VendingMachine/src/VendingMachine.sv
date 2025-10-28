typedef enum logic [3:0] {
    ZERO        = 4'b0000,
    FIVE        = 4'b0001,
    TEN         = 4'b0010,
    FIFTEEN     = 4'b0011,
    TWENTY      = 4'b0100,
    TWENTYFIVE  = 4'b0101,
    THIRTY      = 4'b0110,
    THIRTYFIVE  = 4'b0111,
    FORTY       = 4'b1000,
    FORTYFIVE   = 4'b1001,
    FIFTY       = 4'b1010,
    RETURN      = 4'b1011
} state_t;

module VendingMachine (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        coin_5,
    input  logic        coin_10,
    input  logic        coin_25,
    input  logic        coin_return,
    output logic        dispense_item,
    output logic        ret_5,
    output logic        ret_10,
    output logic        ret_25,
    output logic [5:0]  amount_display
);

    state_t c_state, n_state;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            c_state <= ZERO;
        else
            c_state <= n_state;
    end

    // Next state logic
    always_comb begin
        n_state = c_state; // default assignment

        case (c_state)
            ZERO: begin
                if      (coin_5)      n_state = FIVE;
                else if (coin_10)     n_state = TEN;
                else if (coin_25)     n_state = TWENTYFIVE;
                else if (coin_return) n_state = RETURN;
            end
            FIVE: begin
                if      (coin_return) n_state = RETURN;
                else if (coin_5)      n_state = TEN;
                else if (coin_10)     n_state = FIFTEEN;
                else if (coin_25)     n_state = THIRTY;
            end
            TEN: begin
                if      (coin_return) n_state = RETURN;
                else if (coin_5)      n_state = FIFTEEN;
                else if (coin_10)     n_state = TWENTY;
                else if (coin_25)     n_state = THIRTYFIVE;
            end
            FIFTEEN: begin
                if      (coin_return) n_state = RETURN;
                else if (coin_5)      n_state = TWENTY;
                else if (coin_10)     n_state = TWENTYFIVE;
                else if (coin_25)     n_state = FORTY;
            end
            TWENTY: begin
                if      (coin_return) n_state = RETURN;
                else if (coin_5)      n_state = TWENTYFIVE;
                else if (coin_10)     n_state = THIRTY;
                else if (coin_25)     n_state = FORTYFIVE;
            end
            TWENTYFIVE: begin
                if      (coin_return) n_state = RETURN;
                else if (coin_5)      n_state = THIRTY;
                else if (coin_10)     n_state = THIRTYFIVE;
                else if (coin_25)     n_state = FIFTY;
            end
            // Dispense and RETURN states go back to ZERO
            THIRTY,
            THIRTYFIVE,
            FORTY,
            FORTYFIVE,
            FIFTY,
            RETURN: n_state = ZERO;
            default: n_state = ZERO;
        endcase
    end

    // Output logic
    always_comb begin
        dispense_item  = 0;
        ret_5          = 0;
        ret_10         = 0;
        ret_25         = 0;
        amount_display = 6'd0;

        case (c_state)
            ZERO: begin
                amount_display = 6'd0;
            end
            FIVE: begin
                amount_display = 6'd5;
                if (coin_return) begin
                    ret_5          = 1;
                    amount_display = 6'd0;
                end
            end
            TEN: begin
                amount_display = 6'd10;
                if (coin_return) begin
                    ret_10         = 1;
                    amount_display = 6'd0;
                end
            end
            FIFTEEN: begin
                amount_display = 6'd15;
                if (coin_return) begin
                    ret_10         = 1;
                    ret_5          = 1;
                    amount_display = 6'd0;
                end
            end
            TWENTY: begin
                amount_display = 6'd20;
                if (coin_return) begin
                    ret_5          = 1;
                    amount_display = 6'd15;
                end
            end
            TWENTYFIVE: begin
                amount_display = 6'd25;
                if (coin_return) begin
                    ret_25         = 1;
                    amount_display = 6'd0;
                end
            end
            THIRTY: begin
                dispense_item = 1;
            end
            THIRTYFIVE: begin
                dispense_item = 1;
                ret_5         = 1;
            end
            FORTY: begin
                dispense_item = 1;
                ret_10        = 1;
            end
            FORTYFIVE: begin
                dispense_item = 1;
                ret_10        = 1;
                ret_5         = 1;
            end
            FIFTY: begin
                dispense_item = 1;
                ret_10        = 1;
                ret_5         = 1;
                amount_display = 6'd5;
            end
            RETURN: begin
                amount_display = 6'd0;
            end
            default: begin
                dispense_item  = 0;
                ret_5          = 0;
                ret_10         = 0;
                ret_25         = 0;
                amount_display = 6'd0;
            end
        endcase
    end

endmodule
