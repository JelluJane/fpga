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
    wait(rst_done)
    $monitor("Value of output is: %d Value of output valid %d", ser_data, ser_data_val);
    ##1;
    data = '1;
    data_val = 1'b1;
    data_mod = 0;
    ##1;
    data_val = 1'b0;
    ##17;
    data = 16'b1000100010001000;
    data_mod = 14;
    data_val = 1'b1;
    ##1;
    data_val = 1'b0;
    ##14;
    data = 16'b1010101010101010;
    data_mod = 2;
    data_val = 1'b1;
    ##1;
    data_val = 1'b0;
    ##2;
    data_val = 1'b1;
    data = 16'b1011100010101010;
    data_mod = 12;
    ##1;
    data_val = 1'b0;
    ##12;
    srst = 1'b1;
  end
endmodule