module deserializer (
input  logic          clk_i,
input  logic          srst_i,
input  logic          data_i,
input  logic          data_val_i,
output logic [15:0]   deser_data_o = '0,
output logic          deser_data_val_o = 1'b0);

logic        [3:0]    count;

always_comb
  begin
    if ( ( count == 4'd0 ) & data_val_i )
      deser_data_val_o = 1'b1;
    else
      deser_data_val_o = 1'b0;
  end

always_ff @( posedge clk_i )  
  begin
    if ( srst_i )
      begin
        count <= 4'd15;
      end
    else
      if ( data_val_i )
          begin
            if ( count == 4'd0 )
              count <= 4'd15;
            else
              count <= count - 1;
          end
  end
  
always_comb
  begin
    if ( data_val_i )
      deser_data_o[count] = data_i;
  end
endmodule