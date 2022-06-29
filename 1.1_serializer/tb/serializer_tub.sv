module testbench_serializer ();
logic [15:0] data;
logic [3:0]  data_mod;
logic        data_val;
logic        ser_data;
logic        ser_data_val;
logic        busy;
logic [15:0] tmp_data;
logic [4:0]  tmp_mod;
logic        res;
logic        test;

parameter    TEST_LEN = 1000;

bit          clk;
logic        srst;


mailbox      ref_bit_queue;
mailbox      bit_queue;


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

task create_trans();
  tmp_data = $urandom();
  tmp_mod  = $urandom_range( 1,16 );
  do  
    ##1;
  while( busy );
  if ( $urandom_range(10) > 2 )
    data_val = 1'b1;
  else
    data_val = 1'b0;
  data       = tmp_data;
  data_mod   = tmp_mod[3:0];
  if ( ( tmp_mod > 2 ) && ( data_val ) )
    for( int i = 0; i < ( tmp_mod ) ; i++ )
      ref_bit_queue.put( tmp_data[15-i] );
  ##1; 
endtask

task accumd();
  forever
    begin
    @( posedge clk );
    if( ser_data_val == 1'b1 )
        bit_queue.put( ser_data );
    end
endtask

task check();
  forever
    begin
	  bit_queue.get ( res );
	  ref_bit_queue.get ( test );
	  
	  if( test !=  res )
        $error("error %b, %b", test, res);
     
    end
endtask

initial
  begin
    bit_queue = new();
	ref_bit_queue = new();
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