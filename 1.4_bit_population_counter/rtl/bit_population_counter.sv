module bit_population_counter #(
parameter                      WIDTH=8
)(
input  logic                   clk_i,
input  logic                   srst_i,

input  logic [WIDTH-1:0]       data_i,
input  logic                   data_val_i,

output logic [$clog2(WIDTH):0] data_o,
output logic                   data_val_o
);
logic        [WIDTH-1:0]       work_data;

always_comb
  begin
    work_data = '0;
    if ( data_val_i )
      for ( int i = 0; i < WIDTH; i++ ) 
        begin
          if ( data_i[i] )
            work_data = work_data + 1;
	    end
  end
  
always_ff @ ( posedge clk_i )
  begin
    data_o <= work_data;
  end

always_ff @ ( posedge clk_i )
  begin
    data_val_o <= data_val_i;
  end

endmodule