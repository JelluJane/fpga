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

logic       [15:0] work_data;
logic       [4:0]  ser_long;  
logic       [4:0]  count;       

assign ser_data_val_o = busy_o;     

always_comb
begin
  if ( srst_i )
                        busy_o = 1'b0;
  else
    if (count == 1'b0 ) busy_o = 1'b0;
	else                busy_o = 1'b1;
end

always_ff @ (posedge clk_i)
begin
  if ( srst_i )
    ser_long <= 5'd0;
  else
    if ( ( data_val_i ) & ( count == 5'd0 ) & ( data_mod_i != 4'd1 ) & ( data_mod_i != 4'd2  ) )
	  if ( data_mod_i )   ser_long            <= data_mod_i;
      else                ser_long        	  <= 5'd16;
end

always_ff @ ( posedge clk_i )
begin
  if ( srst_i )
    work_data <= 16'd0;
  else
    if ( ( data_val_i ) & ( count == 5'd0 ) & ( data_mod_i != 4'd1 ) & ( data_mod_i != 4'd2  ) )
	  work_data <= data_i;
end

always_ff @ (posedge clk_i) //я помню про одно присваивание на always_ff блок, но тут у двух переменных абсолютно одинаковые условия изменения. Зачем загромождать код в такой ситуации?
begin
  if (srst_i)
    begin
      ser_data_o             <= 1'b0;
      count                  <= 5'd0;
    end
  else
    begin
      if ( ( data_val_i ) & ( count == 5'd0 ) & ( data_mod_i != 4'd1 ) & ( data_mod_i != 4'd2  ) )
        begin
          ser_data_o         <= data_i[15]; 
		  count              <= 5'd1;
        end
      else
        begin
          if (count == ser_long)
            begin
              ser_data_o               <= work_data[15-count];
              count                    <= 5'd0;
            end
          else
		    begin
              ser_data_o               <= work_data[15-count];
              count                    <= count + 1;            
            end
        end
    end
end
   
endmodule
