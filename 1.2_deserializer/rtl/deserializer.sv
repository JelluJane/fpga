module deserializer (
input  logic          clk_i,
input  logic          srst_i,
input  logic          data_i,
input  logic          data_val_i,
output logic [15:0]   deser_data_o,
output logic          deser_data_val_o);

logic        [4:0]    count;

always_comb
begin
  if ( srst_i )
    deser_data_val_o = 1'b0;
  else
    if   ( ( count == 16 ) & data_val_i )
      deser_data_val_o = 1'b1;
    else
      deser_data_val_o = 1'b0;
end

always_ff @( posedge clk_i )  //я всё ещё помню про одно присваивание на always_ff блок, но тут опять у двух переменных абсолютно одинаковые условия изменения.
begin
  if ( srst_i )
    begin
      count                <= 5'd0;
      deser_data_o         <= '0;
    end
  else
    begin
      if ( count == 16 )
        begin
          if ( data_val_i )
            begin
              count            <= 5'd0;
              deser_data_o[0]  <= data_i;
            end
        end
      else
        if ( data_val_i )
          begin
            deser_data_o[count]    <= data_i;
            count                  <= count + 1;
          end
    end
end
endmodule