module testbench_serializer ();
logic        srst;
logic [15:0] data;
logic [3:0]  data_mod;
logic        data_val;
logic        ser_data;
logic        ser_data_val;
logic        busy;

bit          rst_done;
bit          clk;
int          i;

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

serializer dut  (
.clk_i          (clk             ), 
.srst_i         (srst            ), 
.data_i         (data            ), 
.data_mod_i     (data_mod        ), 
.data_val_i     (data_val        ), 
.ser_data_o     (ser_data        ), 
.ser_data_val_o (ser_data_val    ), 
.busy_o         (busy            )
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
    data     = 16'b1101101010101100;
    data_val = 1'b1;
    data_mod = 0;
    wait ( ser_data_val );
    data_val = 1'b0;
    #1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b0) else begin $error("failed"); i++; end
    wait ( ~busy );
    data_val   = 1'b1;
    data       = '1;
    data_mod   = 4'd5;
    wait ( ser_data_val );
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##1;
    assert (ser_data === 1'b1) else begin $error("failed"); i++; end
    ##2;    
    assert (busy === 1'b0) else begin $error("failed"); i++; end
    if ( i )
      $display (" the simulation is finished with  %d errors ", i);
    else
      $display (" the simulation is finished without  errors ");
    ##1;
    $finish;
  end
endmodule