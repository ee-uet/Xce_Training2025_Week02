///////////////////////////////////////////// MOORE model of FSM ////////////////////////////////////////////////////////


//so idea is to aloign coin signals with clock to avoid from metastability state (in coin changes very close to the clock)
//so approach used is (back to back flip flops which will make coins stable as input to FSM)
module synchronization_for_coins (
    input logic clk,rst,
    input logic coin_5,coin_10,coin_25,
    output logic coin_5_pulse,coin_10_pulse,coin_25_pulse
);


//internal signals 
logic ff1,ff2;
logic ff3,ff4;
logic ff5,ff6;
logic prev_5,prev_10,prev_25;


always_ff @(posedge clk) begin
if(rst) begin
    ff1<=0;
    ff2<=0;
    ff3<=0;
    ff4<=0;
    ff5<=0;
    ff6<=0;
    prev_5<=0;
    prev_10<=0;
    prev_25<=0;
end
else begin
    ff1<=coin_5;
    ff2<=ff1;
    prev_5<=ff2;
    ff3<=coin_10;
    ff4<=ff3;
    prev_10<=ff4;
    ff5<=coin_25;
    ff6<=ff5;
    prev_25<=ff6;
end
end
assign coin_5_pulse = ff2 && !prev_5;
assign coin_10_pulse = ff4 && !prev_10;
assign coin_25_pulse = ff6 && !prev_25;
endmodule























module vending_machine (
    input logic clk,rst,
    input logic coin_5_pulse,coin_10_pulse,coin_25_pulse,
    input logic return_req,
    output logic return_5,return_10,return_25,
    output logic dispense_item,
    output logic [7:0] amount
);

//internal signal
logic [5:0] display_amount;
logic [7:0] change_reg;
logic exact_change_only;

//how much coins of 5,10 and 25 machine had

logic [2:0]quantity_of_coin_5; //Machine had 8 (coin_5)
logic [2:0]quantity_of_coin_10;//8(coin_10)
logic [2:0]quantity_of_coin_25;//8(coin_25)



typedef enum logic [3:0] {
    S0,S5,S10,S15,S20,S25,S30,RETURN_MONEY,DISPENSE_ITEM
} state_t;

state_t current_state,next_state;

//sequential logic (current_state logic)

always_ff @(posedge clk) begin //SYNCHROUS active high reset
if(rst) begin
    current_state<=S0;
    amount<=0;
    quantity_of_coin_5 <=8;
    quantity_of_coin_10<=8;
    quantity_of_coin_25<=8;
    change_reg<=0;
    temp_change_reg<=0;
end
else begin
    current_state<=next_state; 
    change_reg<=amount - 30;

    if(coin_5_pulse) begin
    amount <= amount+5;
    quantity_of_coin_5 <= quantity_of_coin_5+1;
    end
    else if (coin_10_pulse) begin
         amount <= amount+10;
         quantity_of_coin_10 <= quantity_of_coin_10+1;
    end
    else if (coin_25_pulse) begin
          amount<=amount+25;
          quantity_of_coin_25 <= quantity_of_coin_25+1;
    end



     //assigning temp_change_reg to a change_reg variabe

    if(current_state == DISPENSE_ITEM && next_state == RETURN_MONEY ) temp_change_reg<=change_reg;

    // reseting amount to 0 if an item dispenced 
    if(current_state == RETURN_MONEY && next_state==S0 && temp_change_reg==0) amount<=0;


   


    // return money trackin
    if(current_state==RETURN_MONEY) begin
        if(return_25) temp_change_reg <= temp_change_reg - 25;
        else if (return_10) temp_change_reg <= temp_change_reg - 10;
        else if (return_5) temp_change_reg <= temp_change_reg - 5;
    end




// subtract coin after returning coin to the customer
    if(return_5==1) quantity_of_coin_5 <= quantity_of_coin_5-1;
    else if (return_10==1) quantity_of_coin_10 <= quantity_of_coin_10-1;
    else if (return_25==1) quantity_of_coin_25 <= quantity_of_coin_25-1;
end
end


//state transitions

always_comb begin

    //all outputs initialized just to avoiud unintentional latches
    return_5=0;
    return_10=0;
    return_25=0;
    dispense_item=0;
    exact_change_only=0;
    display_amount = amount;
    exact_change_only=(quantity_of_coin_10==0 && quantity_of_coin_5==0 && quantity_of_coin_25==0); 


    //just to avoid unintentional latches
    next_state=current_state;

   unique case(current_state)
        S0: begin
            if(coin_5_pulse) begin
                if(amount+5>=30) next_state = DISPENSE_ITEM;
                else next_state = S5;
            end
            else if(coin_10_pulse) begin
                if(amount+10>=30) next_state = DISPENSE_ITEM;
                else next_state = S10;
            end
            else if(coin_25_pulse) begin
                if(amount+25>=30) next_state = DISPENSE_ITEM;
                else next_state = S25;
            end
            else begin
                next_state = S0;
            end
            end



        S5: begin
            if(coin_5_pulse) begin
                if(amount+5>=30) next_state = DISPENSE_ITEM;
                else next_state = S10;
            end
            else if(coin_10_pulse) begin
                if(amount+10>=30) next_state = DISPENSE_ITEM;
                else next_state = S15;
            end
            else if(coin_25_pulse) begin
                if(amount+25>=30) next_state = DISPENSE_ITEM;
                else next_state = S30;
            end
            else begin
                next_state = S5;
            end
            end




        S10: begin
            if(coin_5_pulse) begin
                if(amount+5>=30) next_state = DISPENSE_ITEM;
                else next_state = S15;
            end
            else if(coin_10_pulse) begin
                if(amount+10>=30) next_state = DISPENSE_ITEM;
                else next_state = S20;
            end
            else if(coin_25_pulse) begin
                if(amount+25>=30) next_state = DISPENSE_ITEM;
                else next_state = DISPENSE_ITEM;
            end
            else begin
                next_state = S10;
            end
            end


        S15: begin
            if(coin_5_pulse) begin
                if(amount+5>=30) next_state = DISPENSE_ITEM;
                else next_state = S20;
            end
            else if(coin_10_pulse) begin
                if(amount+10>=30) next_state = DISPENSE_ITEM;
                else next_state = S25;
            end
            else if(coin_25_pulse) begin
                if(amount+25>=30) next_state = DISPENSE_ITEM;
                else next_state = DISPENSE_ITEM;
            end
            else begin
                next_state = S15;
            end
            end



        S20: begin
            if(coin_5_pulse) begin
                if(amount+5>=30) next_state = DISPENSE_ITEM;
                else next_state = S25;
            end
            else if(coin_10_pulse) begin
                if(amount+10>=30) next_state = DISPENSE_ITEM;
                next_state = S30;
            end
            else if(coin_25_pulse) begin
                if(amount+25>=30) next_state = DISPENSE_ITEM;
                else next_state = DISPENSE_ITEM;
            end
            else begin
                next_state = S20;
            end
            end


        S25: begin
            if(coin_5_pulse) begin
                if(amount+5>=30) next_state = DISPENSE_ITEM;
                else next_state = S30;
            end
            else if(coin_10_pulse) begin
                if(amount+10>=30) next_state = DISPENSE_ITEM;
                else next_state = DISPENSE_ITEM;
            end
            else if(coin_25_pulse) begin
                if(amount+25>=30) next_state = DISPENSE_ITEM;
                else next_state = DISPENSE_ITEM;
            end
            else begin
                next_state = S25;
            end
            end


        S30: begin
            if(coin_5_pulse && amount+5>=30) next_state = DISPENSE_ITEM;
            else if(coin_10_pulse && amount+10>=30) next_state = DISPENSE_ITEM;
            else if(coin_25_pulse && amount+25>=30) next_state = DISPENSE_ITEM;
            else next_state = S30;
            end


// i comes to this state only and only when my (amount>=30) here now i just need to dispense.
        DISPENSE_ITEM : begin
            dispense_item=1;
            if (amount>30 || return_req==1) next_state = RETURN_MONEY;
            else next_state = S0;
        end

    //approach is gready give minimum coins like if need to give 20 then give two 10 not four 5 if two 10 not available then gave one 10 and two 5 if still not one 10 then gave four 5. 
        RETURN_MONEY : begin                            
            if(temp_change_reg>=25 && quantity_of_coin_25>0) begin
                 return_25=1;
                 next_state = RETURN_MONEY;
            end
            else if (temp_change_reg>=10 && quantity_of_coin_10>0) begin 
                return_10=1;
                next_state = RETURN_MONEY;
            end
            else if (temp_change_reg>=5 && quantity_of_coin_5>0) begin 
                return_5=1;
                next_state = RETURN_MONEY;
            end
            else begin
                next_state = S0;
            end
        end
   endcase
end
endmodule
