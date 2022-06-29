module debouncer #(
parameter CLK_FREQ_MHZ   = 100,
parameter GLITCH_TIME_NS = 100
) (
input  logic key_i,
input  logic clk_i,

output logic key_pressed_stb_o
);
logic [$clog2(GLITCH)+1:0] count;
logic                      status = 1'b1;
 
localparam                 GLITCH = (GLITCH_TIME_NS * CLK_FREQ_MHZ / 1000 );
    
always_ff @( posedge clk_i )
  begin
   if ( key_pressed_stb_o )
      key_pressed_stb_o   <= 1'b0;
   else
      if ( count == GLITCH )
	    key_pressed_stb_o <= 1'b1;
  end
  
always_comb
  begin
    if ( key_pressed_stb_o )
	  status = ~status;
  end

always_ff @( posedge clk_i )
  begin
    if ( status )
      begin
	    if ( key_i )
		  begin
          if ( count == GLITCH )
            count         <= '0;  
          else			  
            count         <= count+1;
          end
		else
		  count         <= '0;
	  end
	else
	  begin
	    if ( ~key_i )
		  begin
          if ( count == GLITCH )
            count         <= '0;  
          else			  
            count         <= count+1;
          end
		else
		  count         <= '0;
	  end
           
  end

endmodule


