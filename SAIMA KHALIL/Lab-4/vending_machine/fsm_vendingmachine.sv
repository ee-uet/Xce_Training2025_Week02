module fsm_vendingmachine (
    input  logic        clk,
    input  logic        rst,
    input  logic       coin_5,      // 5-cent coin inserted 
    input  logic       coin_10,     // 10-cent coin inserted 
    input  logic       coin_25,     // 25-cent coin inserted 
    input  logic       coin_return,
    output logic       dispense_item,    // dispense item
    output logic       return_5,  // return coin5
    output logic       return_10, // return coin10
    output logic       return_25, // return coin25
    output logic [5:0] amount_display 
    //this fsm can return more than 1 coin at a time
);
    typedef enum logic [2:0] {
        IDLE   = 3'b00,
        COIN_5 = 3'b01,
        COIN_10 = 3'b10,
        COIN_15 = 3'b11,
        COIN_20 = 3'b100,
        COIN_25 = 3'b101
    } state_t;

    state_t current_state, next_state;
    logic return_mode;

    always_ff @(posedge clk or posedge rst) begin
    if (rst)
        return_mode <= 0;
    else if (coin_return && current_state==COIN_20)
        return_mode <= 1;     // trigger
    else if (current_state == COIN_10 && return_mode) 
        return_mode <= 0;     // clear after 2nd coin return
    end


     always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
          next_state = current_state;
          case (current_state)  
            IDLE:begin
                 if(coin_5)begin
                    next_state = COIN_5;
                end
                else if(coin_10)begin
                    next_state = COIN_10;
                end
                else if(coin_25)begin
                    next_state = COIN_25;
                end
                else begin
                    next_state = IDLE;
                end
            end
            COIN_5: begin
                if(!coin_return)begin
                    if(coin_5)begin
                        next_state = COIN_10;
                    end
                    else if(coin_10)begin
                        next_state = COIN_15;
                     end
                    else if(coin_25)begin
                        next_state = IDLE;
                    end
                end
                else if(coin_return)begin
                    next_state = IDLE;
                end
            end 
            COIN_10: begin
                 if (return_mode) begin
                // return mode ON → last 10 return karo
                        next_state     = IDLE;   // return complete
                end 
                else if(!coin_return) begin
                    if(coin_5) begin
                        next_state     = COIN_15;
                    end
                    else if(coin_10) begin
                        next_state     = COIN_20;
                    end
                    else if(coin_25) begin
                        next_state     = COIN_5;
                    end
                    
                end
                else if (coin_return) begin
                 
                    next_state     = IDLE;   // return complete
                end 
        end

            COIN_15: begin
                if(!coin_return)begin
                    if(coin_5)begin
                        next_state = COIN_20;
                    end
                    else if(coin_10)begin
                        next_state = COIN_25;
                     end
                    else if(coin_25)begin
                        next_state = COIN_10;
                    end
                end
                else if(coin_return)begin
                    next_state = IDLE;
                end
            end 
            COIN_20: begin
                if (coin_return) begin
                    next_state=COIN_10;
                end
                else if(!coin_return)begin
                    if(coin_5)begin
                        next_state = COIN_25;
                    end
                    else if(coin_10)begin
                        next_state = IDLE;
                     end
                    else if(coin_25)begin
                        next_state = COIN_15;
                    end
                end
            end
            COIN_25: begin
                if(!coin_return)begin
                    if(coin_5)begin
                        next_state = IDLE;
                    end
                    else if(coin_10)begin
                        next_state = COIN_5;
                     end
                    else if(coin_25)begin
                        next_state = COIN_20;
                    end
                else if(coin_return)begin
                    next_state = IDLE;
                end
                end
                
            end
            
        endcase
    end

    always_comb begin
        dispense_item  = 0;
        return_5       = 0;
        return_10      = 0;
        return_25      = 0;
        amount_display = 0;
         case(current_state) 
            IDLE:begin
                dispense_item = 0;
                return_5 = 0;
                return_10 = 0;
                return_25 = 0;
                amount_display = 6'd0;
            end
            COIN_5:begin
                if(!coin_return)begin
                    if(coin_5)begin
                        dispense_item = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd10;
                    end 
                    else if(coin_10)begin
                        dispense_item = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd15;
                    end
                    else if(coin_25)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd0;
                    end
                end
                else if(coin_return)begin
                        dispense_item = 0;
                        return_5 = 1;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd0;
            end
        end
            COIN_10: begin
                if (return_mode ) begin
                    // return mode ON → last 10 return karo
                    dispense_item  = 0;
                    return_5       = 0;
                    return_10      = 1;
                    return_25      = 0;
                    amount_display = 6'd0;   // sab paisa wapas
                end
                else if(!coin_return) begin
                    if(coin_5) begin
                        dispense_item  = 0;
                        return_5       = 0;
                        return_10      = 0;
                        return_25      = 0;
                        amount_display = 6'd15;
                    end
                    else if(coin_10) begin
                        dispense_item  = 0;
                        return_5       = 0;
                        return_10      = 0;
                        return_25      = 0;
                        amount_display = 6'd20;
                    end
                    else if(coin_25) begin
                        dispense_item  = 1;
                        return_5       = 0;
                        return_10      = 0;
                        return_25      = 0;
                        amount_display = 6'd5;
                    end
                end
                else if (coin_return) begin
                        dispense_item  = 0;
                        return_5       = 0;
                        return_10      = 1;
                        return_25      = 0;
                        amount_display = 6'd0;   // sab paisa wapas
                end
            end

            COIN_15:begin
                if(!coin_return)begin
                    if(coin_5)begin
                        dispense_item = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd20;
                    end
                    else if(coin_10)begin
                        dispense_item = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd25;
                    end 
                    else if(coin_25)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd10;
                    end
                end
                else if(coin_return)begin
                        dispense_item = 0;
                        return_5 = 1;
                        return_10 = 1;
                        return_25 = 0;
                        amount_display = 6'd0;
                    end
                end
            
            COIN_20:begin
                if(!coin_return)begin
                    if(coin_5)begin
                        dispense_item = 0;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd25;
                    end
                    else if(coin_10)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd0;
                    end
                    else if(coin_25)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd15;
                    end
                end
                else if(coin_return)begin
                    dispense_item  = 0;
                    return_5       = 0;
                    return_10      = 1;     // ek 10 wapas
                    return_25      = 0;
                    amount_display = 6'd10;
                end

            end
            COIN_25:begin
                if(!coin_return )begin //jsy e state coin_30 mn aye ,always dispense item coin_return ho ya na ho
                    if(coin_5)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd0;
                    end
                    else if(coin_10)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0;
                        return_25 = 0;
                        amount_display = 6'd5;
                    end
                    else if(coin_25)begin
                        dispense_item = 1;
                        return_5 = 0;
                        return_10 = 0; 
                        return_25 = 0;
                        amount_display = 6'd20;
                    end
                end
                else if(coin_return)begin
                    dispense_item  = 0;
                    return_5       = 0;
                    return_10      = 0; 
                    return_25      = 1;    // 25 ka coin return
                    amount_display = 6'd0;
                end

            end
        
        endcase

    end
endmodule  