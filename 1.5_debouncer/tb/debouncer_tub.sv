module testbench_debouncer #(
parameter    CLK_FREQ_MHZ = 150,
parameter    GLITCH_TIME_NS = 100)
();
logic        key;
logic        key_pressed_stb;

bit          clk;
int          count;

parameter    TEST_LEN = 1000;
localparam   GLITCH = (GLITCH_TIME_NS * CLK_FREQ_MHZ / 1000 );

initial
  begin
    clk = 1'b0;
      forever
        begin
          #10 clk = !clk;
        end
  end

default clocking cb
  @( posedge clk );
endclocking

debouncer #(
.CLK_FREQ_MHZ         (CLK_FREQ_MHZ       ),
.GLITCH_TIME_NS       (GLITCH_TIME_NS     ))
 dut 
(
.clk_i                (clk                ),
.key_i                (key                ),
.key_pressed_stb_o    (key_pressed_stb    )
);

task send ();
  if ( $urandom_range(100) > 3 )
    key = 1'b1;
  else
    key = 1'b0;
  if (key)
    count += 1;
  else
    count = 0;
  ##1;
endtask

task check ();
  logic tmp;
  forever
    begin
	  ##1;
	  tmp = key_pressed_stb;
      if ( ( count == ( GLITCH + 2 ) ) & ( tmp = 1'b0 ) )
	    $error("error");
    end
endtask

initial
  begin
    ##1;
	fork
	  check();
	  repeat ( TEST_LEN ) send();
	join_any
	##1;
    $finish;
	
  end
endmodule