module serializer (
input logic        clk_i,
input logic        srst_i,
input logic [15:0] data_i,
input logic [3:0]  data_mod_i,
input logic        data_val_i,

output logic       ser_data_o,
output logic       ser_data_val_o,
output logic       busy_o = 1'b0
);

logic       [15:0] work_data;
logic       [3:0]  ser_long;  
logic       [3:0]  count;    
logic              start;

assign start          = ( (     data_val_i     ) & (   count == 4'd15    ) & 
                          ( data_mod_i != 4'd1 ) & ( data_mod_i != 4'd2  ) );
assign ser_data_val_o = ( ( count != 4'd15 ) || start ) ? 1'b1 : 1'b0;     

always_ff @(posedge clk_i)
  begin
    if ( srst_i )
      busy_o <= 1'b0;
    else
      if ( start ) 
        busy_o <= 1'b1;
      else
        if ( count == ( 15 - ser_long ) )
          busy_o <= 1'b0;
  end
  
always_comb
  begin  
    if ( start )
      ser_data_o = data_i[15]; 
    else
      if ( busy_o )
        ser_data_o = work_data[count];
  end
 
always_ff @ (posedge clk_i)
  begin
    if ( srst_i )
      ser_long <= 4'd0;
    else
      if ( start )
        if ( data_mod_i == 0 )   
          ser_long <= 4'd15;
        else        
          ser_long <= data_mod_i - 1;
  end

always_ff @ ( posedge clk_i )
  begin
    if ( srst_i )
      work_data   <= 16'd0;
    else
      if ( start )
        work_data <= data_i;
  end

always_ff @ ( posedge clk_i ) 
  begin
    if ( srst_i )
        count <= 4'd15;
    else
      if ( start )
        count <= count - 1;
      else
        if ( count == ( 15 - ser_long ) )
          count <= 4'd15;           
        else
          if ( busy_o )
            count <= count - 1; 
  end
  
endmodule
