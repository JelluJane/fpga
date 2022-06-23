module testbench_deserializer ();

logic            srst;
logic            data;
logic            data_val;
logic [15:0]     deser_data;
logic            deser_data_val;

bit              rst_done;
bit              clk;
int              i;

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

deserializer dut     (
.clk_i               (clk            ), 
.srst_i              (srst           ), 
.data_i              (data           ),
.data_val_i          (data_val       ),
.deser_data_o        (deser_data     ), 
.deser_data_val_o    (deser_data_val )
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
    data_val = 1'b1;
    data     = 1'b1;
    wait ( deser_data_val );
    #1;
    assert (deser_data === 16'b1111111111111111) else begin $error("failed"); i++; end
    data     = 0;
    ##4;
    data_val = 1'b0;
    data     = 1;
    ##4;
    data_val = 1'b1;
    data     = 0;
    wait ( deser_data_val );
    assert (deser_data === 16'b0000000000000000) else begin $error("failed"); i++; end
    ##1;
    if ( i )
      $display (" simulation finishing with %d errors ", i);
    else
      $display (" simulation finishing without errors ");
    ##1;
    $finish;
    end
endmodule