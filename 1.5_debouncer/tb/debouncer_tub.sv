module testbench_debouncer #(
parameter CLK_FREQ_MHZ = 150,
parameter GLITCH_TIME_NS = 100)
();
logic key;
logic key_pressed_stb;

bit clk;


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


initial
  begin
    ##1;
    key = 1'b0;
    ##5;
    key = 1'b1;
    ##10;
    key = 1'b0;
    ##1;
    key = 1'b1;
    ##35;
    key = 1'b0;
    ##1;
    key = 1'b1;
    ##30;
    key = 1'b0;
  end
endmodule