module testbench_serializer ();
logic        srst;
logic [15:0] data;
logic [3:0]  data_mod;
logic        data_val;
logic        ser_data;
logic        ser_data_val;
logic        busy;

parameter    TEST_LEN = 1000;

int          i=0;
bit          rst_done;
bit          clk;

logic        all_sended;
logic [15:0] res_tmp;
logic [3:0]  mod_tmp;
logic [15:0] realy_send    [$];
logic [15:0] send_data     [$];
logic [3:0]  send_data_mod [$];
logic [3:0]  results       [$];

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
    ##1;
	rst_done = 1'b1;
	$display( "RESET DONE" );
  end

task automatic get_res ( output logic [15:0] res );
  int cnt = 15;
  repeat( 16 )
    begin
      wait ( ser_data_val );
      @( posedge clk );
      res[cnt] = ser_data;
      cnt = cnt - 1;
    end
endtask

task send_data_task ( input logic [15:0] data_in, 
                      input logic [3:0]  mod );
  data = data_in;
  if ( $urandom_range(10) > 2 )
    data_val = 1'b1;
  data_mod = mod;
  @(posedge clk);
  data_val = 1'b0;
endtask

initial
  begin
    all_sended = 1'b0;
    for ( i=0; i < TEST_LEN; i++ )
      begin
        send_data.push_back( $random() );
	    send_data_mod.push_back( $random() );
      end
    wait ( rst_done == 1'b1 );
    for ( i=0; i < TEST_LEN; i++ )
      begin
	    if ( ~busy )
		  begin
		    send_data_task( send_data[i], send_data_mod[i] );
		    if ( data_val )
              realy_send.push_back( send_data[i] );
            else
              @( posedge clk );
		  end
        else
          ##1;
      end
    all_sended = 1'b1;
  end

initial
  begin
    wait ( rst_done == 1'b1 );
    forever
      begin
        get_res ( res_tmp );
        results.push_back( res_tmp );
      end
  end

initial
  begin
    wait( all_sended );
    ##16;
    for ( i=0; i< TEST_LEN; i++ )
      if ( ( send_data_mod[i] != 1 ) && ( send_data_mod[i] != 2 ) )
        if( realy_send[i] != results[i] )
          $error( "ERROR" );
	$finish;
  end
endmodule