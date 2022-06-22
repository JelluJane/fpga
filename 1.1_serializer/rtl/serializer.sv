module serializer (
input logic        clk_i,
input logic        srst_i,
input logic [15:0] data_i,
input logic [3:0]  data_mod_i,
input logic        data_val_i,

output logic       ser_data_o,
output logic       ser_data_val_o,
output logic       busy_o
);

logic       [15:0] to_ser_temp;
logic       [4:0]  ser_long;  
logic       [4:0]  count;       

always_ff @ (posedge clk_i)
begin
  if (srst_i)
    begin
      to_ser_temp            <= '0;
      busy_o                 <= 1'b0;
      ser_data_val_o         <= 1'b0;
      ser_data_o             <= 1'b0;
      count                  <= 5'd0;
    end
  else
    begin
      if ( data_val_i & ~busy_o & ~(data_mod_i == 2 | data_mod_i == 1 ) ) 
        begin
          to_ser_temp        <= data_i; 
          busy_o             <= 1'b1;
          if (data_mod_i)
            ser_long         <= data_mod_i;    
          else        
            ser_long         <= 5'd16;
        end
      else
        begin
          if ((count != ser_long) & busy_o)
            begin
              ser_data_val_o <= 1'b1;
              ser_data_o     <= to_ser_temp[15-count];
              count          <= count + 1;            
            end
          else
            begin
              busy_o         <= 1'b0;
              ser_data_val_o <= 1'b0;
              count          <= 5'd0;
            end
        end
    end
end
endmodule
