`timescale 1ns/1ps
/// Timmer Module

module clk_to_timer (

    input logic clk,rst,
    input logic emergency_reset,padestrian_reset,
    output logic time_30s,time_10s,time_5s

);

//internal signals
    logic [4:0]count_30;
    logic [2:0]count_5;
    logic [3:0]count_10;

always_ff @(posedge clk) begin
    if(rst || emergency_reset || padestrian_reset) begin //synchronous actihe high reset
        count_10<=0;
        count_30<=0;
        count_5<=0;
        time_10s<=0;
        time_30s<=0;
        time_5s<=0;
    end
    
    else begin

        time_10s<=0;
        time_30s<=0;
        time_5s<=0;

        count_10 <= count_10 + 1;
        count_30 <= count_30 + 1;
        count_5  <= count_5  + 1;

        if(count_10==9) begin
            time_10s<=1;
            count_10<=0;
        end
        if (count_30==29) begin
            time_30s<=1;
            count_30<=0;
        end 
        if(count_5==4) begin
            time_5s<=1;
            count_5<=0;
        end

    end
end
endmodule




//Trafic light controler FSM


module trafic_light_controler (
    input logic clk,rst,
    input logic time_10s,time_30s,time_5s,
    input logic emergency,padestrian_req,
    output logic emergency_reset,padestrian_reset,
    output logic [2:0] ns_lights,    //0 => green, 1=> yellow, 2=> red
    output logic [2:0] es_lights,     //0 => green, 1=> yellow, 2=> red
    output logic ps_walk       //Padestrian 1 => WALK  , 0 =>Not_WALK
);


//internal signals 
logic last_ns_green;
logic padestrian_panding;

typedef enum logic [2:0]{
    STARTUP_FLASH,NS_G_EW_R,NS_Y_EW_R,NS_R_EW_G,NS_R_EW_Y,ALL_RED_EMERGIENCY,PADESTRIAN_REQ
} state_t;

state_t current_state,next_state;

//sequential logic (current state logic)
always_ff @ (posedge clk) begin
    if(rst) begin //synchrous active high reset 
    current_state<=STARTUP_FLASH;
    last_ns_green<=1; //set in default 
    padestrian_panding<=0; 
    end
    else begin
    current_state<=next_state;

    if(padestrian_req==1) 
        padestrian_panding<=1;
    else if(current_state==PADESTRIAN_REQ && time_10s) 
        padestrian_panding<=0;

    if(current_state==NS_G_EW_R) last_ns_green<=1; //now 1 will be stored acros other cycles
    else if(current_state==NS_R_EW_G) last_ns_green<=0;
end
end

//State transition
always_comb begin
    next_state=current_state;
// initializing outputs just to avoid unintentional latches
unique case(current_state)
    STARTUP_FLASH   : begin
        if (emergency==1) next_state = ALL_RED_EMERGIENCY;
        else if (time_10s==1) next_state = NS_G_EW_R;
        else if (padestrian_req==1) next_state = NS_G_EW_R;
    end
    NS_G_EW_R       : begin
        if(emergency==1) next_state = ALL_RED_EMERGIENCY;
        else if (time_30s==1) begin
            if (padestrian_panding==1) next_state = PADESTRIAN_REQ; 
            else next_state = NS_Y_EW_R;
        end
    end
    PADESTRIAN_REQ  : begin
        if(emergency==1) next_state = ALL_RED_EMERGIENCY;
        else if (time_10s==1) begin
            if(last_ns_green==1) next_state = NS_Y_EW_R;
            else next_state = NS_R_EW_Y; 
        end
        else next_state = PADESTRIAN_REQ;
    end
    NS_Y_EW_R       : begin
        if(emergency==1) next_state =  ALL_RED_EMERGIENCY; 
        else if(time_5s==1) next_state = NS_R_EW_G;
    end
    NS_R_EW_G       : begin
        if(emergency==1) next_state = ALL_RED_EMERGIENCY;
        else if(time_30s==1) begin
            if (padestrian_panding==1) next_state = PADESTRIAN_REQ;
            else next_state = NS_R_EW_Y;
        end
    end
    NS_R_EW_Y       : begin
        if(emergency==1) next_state =  ALL_RED_EMERGIENCY;
        else if (time_5s==1) next_state = NS_G_EW_R;
    end
    ALL_RED_EMERGIENCY: begin
        if(emergency==1) next_state = ALL_RED_EMERGIENCY;
        else next_state = STARTUP_FLASH;
    end
endcase
end



//output logic
always_comb begin

    //NORTH-SOUTH lights (green , yellow , red)
    ns_lights[0]=0;
    ns_lights[1]=0;
    ns_lights[2]=0;
    //EAST-WEST lights (green , yellow , red)
    es_lights[0]=0;
    es_lights[1]=0;
    es_lights[2]=0;
    // padestrian walk/no walk
     ps_walk=0;
    //timer reset flags initialized to avoid unintentional latches
    emergency_reset=0;
    padestrian_reset=0;






// Timer reset flags for emergency case and for padestrian reuest case
if(current_state != ALL_RED_EMERGIENCY && next_state==ALL_RED_EMERGIENCY) begin
    emergency_reset=1;
end
if(current_state != PADESTRIAN_REQ && next_state==PADESTRIAN_REQ) begin
    padestrian_reset=1;
end











//lets make emergency state separate from the normal 
if(current_state==ALL_RED_EMERGIENCY) begin
    ns_lights[2]=1; //NS_red TURN ON
    es_lights[2]=1; //EW_red TURN ON
    ps_walk=0;   //no walk
end

else begin
    unique case(current_state)
        STARTUP_FLASH : begin        //if NS_yelow and EW_yellow are on it means its starting state (STARTUP_STATE)
            ns_lights[1]=1;//NS_yellow
            es_lights[1]=1;//EW_yellow
        end    
        NS_G_EW_R     : begin    
            ns_lights[0]=1;//NS_green
            es_lights[2]=1;//EW_red
        end        
        PADESTRIAN_REQ : begin
            ps_walk=1;
            ns_lights[2]=1;
            es_lights[2]=1;
        end
        NS_Y_EW_R     : begin
            ns_lights[1]=1;//NS_yellow
            es_lights[2]=1;//EW_red
        end          
        NS_R_EW_G     : begin
            ns_lights[2]=1;// NS_red
            es_lights[0]=1;//EW_green
        end        
        NS_R_EW_Y     : begin
            ns_lights[2]=1;//NS_red
            es_lights[1]=1;//EW_yellow  
        end      
    endcase
end
end
endmodule