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
int                    i;

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
    wait ( rst_done );
    ##1;
	i        = 0;
    data     = 8'b01001000;  
    data_val = 1'b1;
    ##1
	assert (data_left      === 8'b01000000) else begin $error("failed"); i++; end
	assert (data_right     === 8'b00001000) else begin $error("failed"); i++; end
	assert (deser_data_val === 1'b1       ) else begin $error("failed"); i++; end
    data     = 8'b11001001;
	##1
	assert (data_left      === 8'b10000000) else begin $error("failed"); i++; end
	assert (data_right     === 8'b00000001) else begin $error("failed"); i++; end
	assert (deser_data_val === 1'b1       ) else begin $error("failed"); i++; end
	##1;
	data     = 8'b00111100; 
	data_val = 1'b0;
	##1;
	assert (deser_data_val === 1'b0       ) else begin $error("failed"); i++; end
	if ( i )
	  $display (" simulation finishing with %d errors ", i);
    else
      $display (" simulation finishing without errors ");
    ##1;
    $finish;
  end
endmodule