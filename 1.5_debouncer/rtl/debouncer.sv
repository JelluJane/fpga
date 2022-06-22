module debouncer #(
parameter CLK_FREQ_MHZ   = 100,
parameter GLITCH_TIME_NS = 100
) (
input  logic key_i,
input  logic clk_i,

output logic key_pressed_stb_o
);
logic [$clog2(GLITCH)+1:0] count;
logic                      busy;
 
localparam                 GLITCH = (GLITCH_TIME_NS * CLK_FREQ_MHZ / 1000 );
    



//счётчик
always_ff @( posedge clk_i )
begin
if ( ~busy )
	if ( count == GLITCH )
		begin
		count             <= '0;
		key_pressed_stb_o <= 1'b1;
		busy              <= 1'b1;
		end
	else
		if ( key_i )
			count         <= count+1;
		else    
			count         <= '0;

if ( key_pressed_stb_o )
    key_pressed_stb_o     <= 1'b0;

if ( ~key_i )
	busy                  <= 1'b0;
end

endmodule


