module testbench_bit_population_counter #(
parameter               WIDTH = 8
)();
logic                   srst;
logic [WIDTH-1:0]       data;
logic                   data_val;
logic [$clog2(WIDTH):0] data_result;
logic                   data_val_result;

bit                     rst_done;
bit                     clk;

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

bit_population_counter #(.WIDTH (WIDTH)) dut 
(
.clk_i                 (clk            ), 
.srst_i                (srst           ), 
.data_i                (data           ),
.data_val_i            (data_val       ),
.data_o                (data_result    ), 
.data_val_o            (data_val_result)
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
    data_val = 1'b1;
    data = 14; //кормим модуль данными
    ##1;
    data = 1; // а эти данные он проигнорирует, ибо занят
    ##1;
    data_val = 1'b0;
    ##8;
    data_val = 1'b1;
    data = 0; // частный случай
    ##1;
    data_val = 1'b0;
    ##8;
    data_val = 1'b1;
    data = '1; // ещё один
    ##1;
    data_val = 1'b0;
    ##8;
  end
endmodule
