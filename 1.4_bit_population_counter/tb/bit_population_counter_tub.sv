module testbench_bit_population_counter #(
parameter               WIDTH = 8
)();
logic [WIDTH-1:0]       data;
logic                   data_val;
logic [$clog2(WIDTH):0] data_result;
logic                   data_val_result;



logic                   srst;
bit                     clk;

parameter    TEST_LEN = 1000;

mailbox                 ref_result;
mailbox                 result;

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

bit_population_counter #(
.WIDTH                 (WIDTH          )
) dut (
.clk_i                 (clk            ), 
.srst_i                (srst           ), 
.data_i                (data           ),
.data_val_i            (data_val       ),
.data_o                (data_result    ), 
.data_val_o            (data_val_result)
);

task create_trans();
  logic [WIDTH-1:0]       tmp_data;
  logic [$clog2(WIDTH):0] tmp_data_result;
  tmp_data = $urandom();
  tmp_data_result = '0;
  if ( $urandom_range(10) > 2 )
    data_val = 1'b1;
  else
    data_val = 1'b0;
  data       = tmp_data;
  tmp_data_result = $countones (tmp_data);
  if( data_val )
    ref_result.put ( tmp_data_result );
  ##1;
endtask

task accumd();
  forever
    begin
      if( data_val_result === 1'b1 )
        result.put( data_result );
      ##1;
    end
endtask

task check();
  logic [$clog2(WIDTH):0] res;
  logic [$clog2(WIDTH):0] test;
  forever
    begin
      result.get ( test );
      ref_result.get ( res );
      
      if( test !=  res )
        $error("error %b, %b", test, res);
    end
endtask


initial
  begin
    result = new();
    ref_result = new();
    srst = 1'b0;
    ##1;
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    ##1;
    fork
      accumd();
      check();
    join_none
    repeat (TEST_LEN) create_trans();
    ##16;
    $finish;
  end
endmodule