module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        load,
    input  logic        enable,
    input  logic        up_down,
    input  logic [7:0]  load_value,
    input  logic [7:0]  max_count,
    output logic [7:0]  count,
    output logic        tc,          // Terminal count
    output logic        zero
);

   always_ff @(posedge clk)begin
   if (rst_n ==0)begin   //
      count <= 0;
   end  
    else if (load==1)begin
       count <= load_value;
    end   
   else if ((enable ==1) && (up_down == 1))begin 
    if(count < max_count)begin
      count <= count + 1;
    end
    else begin
      //hold
    end  
   end
   else if((enable ==1) && (up_down == 0) ) begin
    if (count > 0)begin
      count <= count -1;
    end 
    else begin
      //hold
    end    
   end 
   else begin
     //hold
   end 
   
    zero <= (count == 0);
    tc <=  (count == max_count && up_down ==1 );
    
   end
    
endmodule
