module testbench_priority_encoder #(
parameter              WIDTH = 8
)();
logic    [WIDTH-1:0]   data;
logic                  srst;
logic                  data_val;
logic    [WIDTH-1:0]   data_left;
logic    [WIDTH-1:0]   data_right;
logic                  deser_data_val;


bit                    rst_done;
bit                    clk;

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

priority_encoder #(
.WIDTH            (WIDTH          )
) dut (
.clk_i            (clk            ),
.srst_i           (srst           ), 
.data_i           (data           ),
.data_val_i       (data_val       ),
.data_left_o      (data_left      ), 
.data_right_o     (data_right     ),
.data_val_o       (deser_data_val )
);

initial
  begin
    srst = 1'b0;
    @( posedge clk );
    srst = 1'b1;
    @( posedge clk );
    srst = 1'b0;
    rst_done = 1'b1;
    $display( "RESET DONE" );
  end
initial
  begin
    wait(rst_done);
    ##1;
    data = 8'b01001000;  //это нам в работу
    data_val = 1'b1;
    ##1;
    data = 8'b11111111;  //а это должно проигнорироваться
    ##1;
    data_val = 1'b0;
    ##8;
    data_val = 1'b1;
    data=8'b00000000;  // частный случай, который может вызывать проблему
    ##1;
    data_val = 1'b0;
    ##4;
    data_val = 1'b1;
    data=8'b00100010; // напоследок ещё разок
    ##1;
    data_val = 1'b0;
  end
endmodule