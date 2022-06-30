module debouncer #(
parameter                  CLK_FREQ_MHZ   = 100,
parameter                  GLITCH_TIME_NS = 100
) (
input  logic               key_i,
input  logic               clk_i,

output logic               key_pressed_stb_o =1'b0
);
logic [$clog2(GLITCH)+1:0] count  ='0;
logic                      busy   =1'b0;
 
localparam                 GLITCH = (GLITCH_TIME_NS * CLK_FREQ_MHZ / 1000 );
    
always_ff @( posedge clk_i )
  begin
    if ( ~busy )
      if ( count == GLITCH )
        count   <= '0;
      else
        if ( key_i )
          count <= count+1;
        else   
          count <= '0;
end

always_ff @( posedge clk_i )
  begin
    if ( ~busy )
      if ( count == GLITCH )
            key_pressed_stb_o <= 1'b1;
    if ( key_pressed_stb_o )
      key_pressed_stb_o       <= 1'b0;

  end

always_ff @( posedge clk_i )
  begin
    if ( ~busy )
      if ( count == GLITCH )
        busy <= 1'b1;
    if ( ~key_i )
      busy   <= 1'b0;
  end

endmodule
