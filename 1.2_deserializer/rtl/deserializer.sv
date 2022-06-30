module deserializer (
input  logic          clk_i,
input  logic          srst_i,
input  logic          data_i,
input  logic          data_val_i,
output logic [15:0]   deser_data_o = '0,
output logic          deser_data_val_o = 1'b0);

logic        [4:0]    count;
logic                 first_bite;

always_ff @( posedge clk_i )  
  begin
    if ( srst_i )
      deser_data_val_o <= 1'd0;
    else
      if ( deser_data_val_o )     
        deser_data_val_o <= 1'b0;
      else
        if ( ( count == 5'd0 ) && data_val_i )
          deser_data_val_o <= 1'b1;
  end

always_ff @( posedge clk_i )  
  begin
    if ( srst_i )
        count <= 5'd15;
    else
      if ( data_val_i )
        if ( count == 5'd0 )
          count <= 5'd15;
        else
          count <= count - 1;
  end
  
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
     deser_data_o <= '0;
    else
      if ( (count != 5'd15) && ( data_val_i ) )
        begin
          deser_data_o[count ] <= data_i;
          deser_data_o[15] <= first_bite;
        end
  end
  
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      first_bite <= 1'b0; 
    else
       if ( ( count == 5'd15 ) && data_val_i )   
         first_bite <= data_i;
  end
endmodule