module bit_population_counter #(
parameter                      WIDTH=8
)(
input  logic                   clk_i,
input  logic                   srst_i,
input  logic [WIDTH-1:0]       data_i,
input  logic                   data_val_i,
output logic [$clog2(WIDTH):0] data_o,
output logic                   data_val_o);

logic        [$clog2(WIDTH):0] count;
logic                          busy;
logic        [WIDTH-1:0]       work_data;

always_ff @( posedge clk_i )
if ( srst_i )
begin
  data_o           <= '0;
  data_val_o       <= 1'b0;
  count            <= 1'b0;
  busy             <= 1'b0;
end
else
begin
  if ( data_val_i & ( ~busy ) ) /*забираем данные для работы и блокируем модуль как и в прошлой задаче*/
    begin
      work_data          <= data_i;
      busy               <= 1'b1;
      data_val_o         <= 1'b0;
      count              <= 1'b0;
    end
  if ( busy )  
    begin
      if ( ~|work_data ) /*частный случай*/
        begin
          data_o         <= 0;
          data_val_o     <= 1'b1;
          busy           <= 1'b0;
        end
      else
        begin
          if ( & work_data ) /*ещё один частный случай*/
            begin
              data_o     <= WIDTH;
              data_val_o <= 1'b1;
              busy       <= 1'b0;
            end
          else /*а теперь можно и посчитать*/
            begin
              if ( count != (WIDTH-1) ) /*счётчик для полного перебора, хз сработает ли*/
                begin
                  count                            <= count + 1;
                  if ( work_data[count] ) data_o   <= data_o + 1;            
                end
              else 
                begin
                  if ( work_data[count] ) data_o   <= data_o + 1;
                    data_val_o                     <= 1'b1;  
                    busy                           <= 1'b0;      
                end
            end
        end
    end
end
endmodule