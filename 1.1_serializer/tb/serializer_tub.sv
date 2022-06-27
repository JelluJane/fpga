module testbench_serializer ();
logic        srst;
logic [15:0] data;
logic [3:0]  data_mod;
logic        data_val;
logic        ser_data;
logic        ser_data_val;
logic        busy;

parameter    TEST_LEN = 1000;

int          i = 0;
bit          clk;

logic [15:0] res_tmp;
logic [3:0]  mod_tmp;
logic [15:0] realy_send    [$];
logic [15:0] send_data     [$];
logic [3:0]  send_data_mod [$];
logic [15:0] results       [$];
logic [3:0]  results_mod   [$];

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
  logic [15:0] tmp_data;
  logic [4:0]  tmp_mod;

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
  if( ( mod > 2 ) && data_val )
    for( int i = 0; i < mod; i++ )
      ref_bit_queue.put( data[15-i] );
  ##1;  
  data_val = 1'b0;
  data     = 'x;  
endtask

task accumd();
  forever
    begin
      if( ser_data_val === 1'b1 )
        bit_queue.put( ser_data );
      ##1;
    end
endtask

//Таск проверки будет:
//
//Он может крутится всега по аналогиии с accumd.
//Проверяет он, когда две очереди/mailbox не пусты.

initial
  begin
    srst = 1'b0;
    ##1;
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    ##1;
    fork
    accumd();
    //Ваш task для проверки
    // Эти таски в бесконечном цикле крутятся,
    // поэтому не ждем когда они закончатся
    join_none
    repeat (TEST_LEN) create_trans();
    ##16;
	
  end