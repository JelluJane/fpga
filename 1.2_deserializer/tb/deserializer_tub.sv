module testbench_deserializer ();
logic            data;
logic            data_val;
logic [15:0]     deser_data;
logic            deser_data_val;



parameter        TEST_LEN = 1000;

logic            srst;
bit              clk;

mailbox          ref_result;
mailbox          result;

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

task create_trans();
  logic            tmp_data;
  tmp_data = $urandom();
  
  if ( $urandom_range(10) > 2 )
    data_val = 1'b1;
  else
    data_val = 1'b0;
  data       = tmp_data;
  if( data_val )
    ref_result.put( data );
  ##1;
endtask

task accumd();
  forever
    begin
    @( posedge clk );
      if( deser_data_val === 1'b1 )
        result.put( deser_data );
    end
endtask

task check();
  logic            tmp;
  logic [15:0]     res;
  logic [15:0]     test;
  forever
    begin
      for ( int i = 0; i < 16; i++ )
        begin
          ref_result.get( tmp );
          test[(15-i)] = tmp;
        end 
      result.get ( res );
      if( res != test )
        $error("error %b, %b", test, res);
      else
        ##1;
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
      repeat (TEST_LEN) create_trans();
    join_any
    ##16;
    $finish;
  end
endmodule