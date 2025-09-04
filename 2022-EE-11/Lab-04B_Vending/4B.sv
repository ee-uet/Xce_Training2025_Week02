module vending_machine (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       coin_5,      // 5-cent coin inserted
    input  logic       coin_10,     // 10-cent coin inserted
    input  logic       coin_25,     // 25-cent coin inserted
    input  logic       coin_return,
    output logic       dispense_item,
    output logic       return_5,    // Return 5-cent
    output logic       return_10,   // Return 10-cent
    output logic       return_25,   // Return 25-cent
    output logic [5:0] amount_display
);

    typedef enum {
        s_coin_0,
        s_coin_5,
        s_coin_10,
        s_coin_15,
        s_coin_20,
        s_coin_25,
        s_returning    // Single return state that handles sequential returns
    } state_t;
    
    state_t curr_state, next_state;
    
    logic [1:0] return_25_count, 
    		return_10_count, 
		return_5_count;
		
    logic [1:0] next_return_25_count, 
    		next_return_10_count, 
    		next_return_5_count;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            return_25_count 	<= #1 0;
            return_10_count 	<= #1 0;
            return_5_count 	    <= #1 0;
            curr_state 		    <= #1 s_coin_0;
        end else begin
            curr_state 		    <= #1 next_state;
            return_5_count 	    <= #1 next_return_5_count;
            return_25_count 	<= #1 next_return_25_count;
            return_10_count 	<= #1 next_return_10_count;
        end
    end
    
    always_comb begin
        // Default outputs
        return_5 		= 0;
        return_10 		= 0;
        return_25 		= 0;
        
        next_state 		= curr_state;
        
        amount_display 		= 0;
        dispense_item		= 0;
        
        next_return_5_count 	= return_5_count;
        next_return_25_count 	= return_25_count;
        next_return_10_count 	= return_10_count;
        
        case(curr_state) 
            s_coin_0: begin
                amount_display 		= 0;
                case({coin_25, coin_10, coin_5})
                    3'b001: next_state 	= s_coin_5;
                    3'b010: next_state 	= s_coin_10;
                    3'b100: next_state 	= s_coin_25;
                    default: next_state = s_coin_0;
                endcase
            end
            
            s_coin_5: begin
                amount_display 			= 5;
                case({coin_return, coin_25, coin_10, coin_5})
                    4'b0001: next_state 	= s_coin_10;
                    4'b0010: next_state 	= s_coin_15;
                    4'b0100: begin 
                    	next_state 	    = s_returning;
                    	dispense_item	= 1;
    		        end
                    4'b1000: begin
                        next_state 		        = s_returning;
                        next_return_5_count 	= 1;
                    end
                    default: next_state 	    = s_coin_5;
                endcase
            end
            
            s_coin_10: begin
                amount_display = 10;
                case({coin_return, coin_25, coin_10, coin_5})
                    4'b0001: next_state 	= s_coin_15;
                    4'b0010: next_state 	= s_coin_20;
                    4'b0100: begin  // 35 cents, dispense and return 5
                        dispense_item 		    = 1;
                        next_return_5_count 	= 1;
                        next_state 		        = s_returning;
                    end
                    4'b1000: begin
                        next_state 		= s_returning;
                        next_return_10_count 	= 1;
                    end
                    default: next_state 	= s_coin_10;
                endcase
            end
            
            s_coin_15: begin
                amount_display 			= 15;
                case({coin_return, coin_25, coin_10, coin_5})
                    4'b0001: next_state 	= s_coin_20;
                    4'b0010: next_state 	= s_coin_25;
                    4'b0100: begin  // 40 cents, dispense and return 10
                        dispense_item 		    = 1;
                        next_state 		        = s_returning;
                        next_return_10_count 	= 1;
                    end
                    4'b1000: begin  // Return 15 cents: 10 + 5
                        next_state = s_returning;
                        next_return_10_count 	= 1;
                        next_return_5_count 	= 1;
                    end
                    default: next_state = s_coin_15;
                endcase
            end
            
            s_coin_20: begin
                amount_display 			= 20;
                case({coin_return, coin_25, coin_10, coin_5})
                    4'b0001: next_state 	= s_coin_25;
                    4'b0010: begin 
                    	dispense_item		= 1;
                    	next_state 		= s_returning;
    		        end
                    4'b0100: begin  // 45 cents, dispense and return 15 (10 + 5)
                        dispense_item 		= 1;
                        next_return_10_count 	= 1;
                        next_return_5_count 	= 1;
                        next_state 		= s_returning;
                    end
                    4'b1000: begin  // Return 20 cents: 10 + 10
                        next_state 		= s_returning;
                        next_return_10_count 	= 2;
                    end
                    default: next_state = s_coin_20;
                endcase
            end
            
            s_coin_25: begin
                amount_display 			= 25;
                case({coin_return, coin_25, coin_10, coin_5})
                    4'b0001: begin 
                    	next_state 		= s_returning;
                    	dispense_item		= 1;
    		    end
                    4'b0010: begin  // 35 cents, dispense and return 5
                        dispense_item 		= 1;
                        next_state 		= s_returning;
                        next_return_5_count 	= 1;
                    end
                    4'b0100: begin  // 50 cents, dispense and return 20 (10 + 10)
                        dispense_item 		= 1;
                        next_state 		= s_returning;
                        next_return_10_count 	= 2;
                    end
                    4'b1000: begin
                        next_state 		= s_returning;
                        next_return_25_count 	= 1;
                    end
                    default: next_state 	= s_coin_25;
                endcase
            end
            
            s_returning: begin
                // Return coins one at a time, prioritizing larger denominations
                case({|return_25_count, |return_10_count, |return_5_count})
                    3'b100: begin  // Return 25-cent coin
                        return_25 = 1;
                        next_return_25_count = return_25_count - 1;
                        case(return_25_count)
                            2'b01: begin  // Last 25-cent coin
                                case({|return_10_count, |return_5_count})
                                    2'b10: next_state = s_returning;
                                    2'b01: next_state = s_returning;
                                    default: next_state = s_coin_0;
                                endcase
                            end
                            default: next_state = s_returning;
                        endcase
                    end
                    3'b010: begin  // Return 10-cent coin
                        return_10 = 1;
                        next_return_10_count = return_10_count - 1;
                        case(return_10_count)
                            2'b01: begin  // Last 10-cent coin
                                case(|return_5_count)
                                    1'b1: next_state = s_returning;
                                    default: next_state = s_coin_0;
                                endcase
                            end
                            default: next_state = s_returning;
                        endcase
                    end
                    3'b001: begin  // Return 5-cent coin
                        return_5 = 1;
                        next_return_5_count = return_5_count - 1;
                        case(return_5_count)
                            2'b01: next_state = s_coin_0;  // Last coin
                            default: next_state = s_returning;
                        endcase
                    end
                    default: next_state = s_coin_0;  // No coins to return
                endcase
            end
        endcase
    end
endmodule
