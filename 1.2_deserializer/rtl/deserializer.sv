module deserializer (
input  logic          clk_i,
input  logic          srst_i,
input  logic          data_i,
input  logic          data_val_i,
output logic [15:0]   deser_data_o,
output logic          deser_data_val_o);

logic        [15:0]   result;
logic        [4:0]    count;

always_ff @( posedge clk_i )
begin
if ( srst_i )
  begin
  result               <= 0;
  count                <= 0;
  deser_data_o         <= 0;
  deser_data_val_o     <= 1'b0;
  end
else
  begin
  if ( count == 16 )
    begin
    if ( data_val_i )
      begin
      count            <= 1;
      deser_data_val_o <= 1'b1;
      deser_data_o     <= result;
      result[0]        <= data_i;
      end
    else
      begin
      deser_data_o     <= result;
      deser_data_val_o <= 1'b1;
      count            <= 0;
      end
    end
  else
    if ( data_val_i )
      begin
      result[count]    <= data_i;
      count            <= count + 1;
      deser_data_val_o <= 1'b0;
      end
  end
end
endmodule