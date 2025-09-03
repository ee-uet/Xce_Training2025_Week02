/*
        Vending Machine FSM
        Accepts coins of 5, 10, and 25 cents.
        Dispenses item when 30 cents or more is reached and return remaining.
        Returns coins if return button is pressed.
*/

typedef enum logic [3:0] {
    ZERO =       4'b0000,
    FIVE =       4'b0001,
    TEN =        4'b0010,
    FIFTEEN =    4'b0011,
    TWENTY =     4'b0100,
    TWENTYFIVE = 4'b0101,
    THIRTY =     4'b0110,
    THIRTYFIVE = 4'b0111,
    FORTY =      4'b1000,
    FORTYFIVE =  4'b1001,
    FIFTY =      4'b1010,
    RETURN =     4'b1011,
} state_t;


module fsm_vending (
    input logic         clk,
    input logic         rst_n,
    input logic         coin_5,
    input logic         coin_10,
    input logic         coin_25,
    input logic         coin_return,
    output logic        dispense_item,
    output logic        ret_5,
    output logic        ret_10,
    output logic        ret_25
    output logic [4:0]  amount_display
);
state_t c_state, n_state;

always_ff @( posedge clk ) begin
    if (!rst_n) begin
        c_state <= ZERO;
    end
    else begin
        c_state <= n_state;
    end

end

// next state logic
always_comb begin
    case (c_state)
        ZERO: begin
            if (coin_5) n_state = FIVE;
            else if (coin_10) n_state = TEN;
            else if (coin_25) n_state = TWENTYFIVE;
            else n_state = ZERO;
        end
        FIVE: begin
            if (coin_return) n_state = RETURN;
            else if (coin_5) n_state = TEN;
            else if (coin_10) n_state = FIFTEEN;
            else if (coin_25) n_state = THIRTY;
            else n_state = FIVE;
        end
        TEN: begin
            if (coin_return) n_state = RETURN;
            else if (coin_5) n_state = FIFTEEN;
            else if (coin_10) n_state = TWENTY;
            else if (coin_25) n_state = THIRTYFIVE;
            else n_state = TEN;
        end
        FIFTEEN: begin
            if (coin_return) n_state = RETURN;
            else if (coin_5) n_state = TWENTY;
            else if (coin_10) n_state = TWENTYFIVE;
            else if (coin_25) n_state = FORTY;
            else n_state = FIFTEEN;
        end
        TWENTY: begin
            if (coin_return) n_state = FIFTEEN;
            else if (coin_5) n_state = TWENTYFIVE;
            else if (coin_10) n_state = THIRTY;
            else if (coin_25) n_state = FORTYFIVE;
            else n_state = TWENTY;
        end
        TWENTYFIVE: begin
            if (coin_return) n_state = RETURN;
            else if (coin_5) n_state = THIRTY;
            else if (coin_10) n_state = THIRTYFIVE;
            else if (coin_25) n_state = FIFTY;
            else n_state = TWENTYFIVE;
        end
        THIRTY: begin
            n_state = ZERO;
        end
        THIRTYFIVE: begin
            n_state = ZERO;
        end
        FORTY: begin
            n_state = ZERO;
        end
        FORTYFIVE: begin
            n_state = ZERO;
        end
        FIFTY: begin
            n_state = FIVE;
        end
        RETURN: begin
            n_state = ZERO;
        end




    endcase
end
// output logic
always_comb begin
    dispense_item = 0;
    ret_5 = 0;
    ret_10 = 0;
    ret_25 = 0;
    amount_display = 5'd0;
    case (c_state)
    ZERO: begin
        if (coin_5) amount_display = 5'd5;
        else if (coin_10) amount_display = 5'd10;
        else if (coin_25) amount_display = 5'd25;
        else if (coin_return) amount_display = 5'd0;
        else amount_display = 5'd0;
    end
    FIVE: begin
        if (coin_5) amount_display = 5'd10;
        else if (coin_10) amount_display = 5'd15;
        else if (coin_25) amount_display = 5'd30;
        else if (coin_return) begin
            ret_5 = 1;
            amount_display = 5'd0;
        end
        else amount_display = 5'd5;
    end
    TEN: begin
        if (coin_5) amount_display = 5'd15;
        else if (coin_10) amount_display = 5'd20;
        else if (coin_25) amount_display = 5'd35;
        else if (coin_return) begin
            ret_10 = 1;
            amount_display = 5'd0;
        end
        else amount_display = 5'd10;
    end
    FIFTEEN: begin
        if (coin_5) amount_display = 5'd20;
        else if (coin_10) amount_display = 5'd25;
        else if (coin_25) amount_display = 5'd40;
        else if (coin_return) begin
            ret_10 = 1;
            ret_5 = 1;
            amount_display = 5'd0;
        end
        else amount_display = 5'd15;
    end
    TWENTY: begin
        if (coin_5) amount_display = 5'd25;
        else if (coin_10) amount_display = 5'd30;
        else if (coin_25) amount_display = 5'd45;
        else if (coin_return) begin
            ret_5 = 1;
            amount_display = 5'd15;
        end
        else amount_display = 5'd20;
    end
    TWENTYFIVE: begin
        if (coin_5) amount_display = 5'd30;
        else if (coin_10) amount_display = 5'd35;
        else if (coin_25) amount_display = 5'd50;
        else if (coin_return) begin
            ret_25 = 1;
            amount_display = 5'd0;
        end
        else amount_display = 5'd25;
    end
    THIRTY: begin
        dispense_item = 1;
        amount_display = 5'd0;
    end
    THIRTYFIVE: begin
        dispense_item = 1;
        amount_display = 5'd0;
        ret_5 = 1;
    end
    FORTY: begin
        dispense_item = 1;
        amount_display = 5'd0;
        ret_10 = 1;
    end
    FORTYFIVE: begin
        dispense_item = 1;
        amount_display = 5'd0;
        ret_10 = 1;
        ret_5 = 1;
    end
    FIFTY: begin
        dispense_item = 1;
        amount_display = 5'd5;
        ret_5 = 1;
        ret_10 = 1;
    end
    //RETURN state has all outputs  = 0; (no change)
    endcase
end
    

endmodule