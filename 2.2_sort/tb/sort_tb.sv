`timescale 1 ps / 1 ps
module sort_tb;

localparam          MAX_PKT_LEN = 1024;
localparam          DWIDTH = 8;

int                 test_len;

bit                 clk;
bit                 srst;

logic [DWIDTH-1:0]  snk_data;
logic               snk_startofpacket;
logic               snk_endofpacket;
logic               snk_valid;

logic               src_ready;

logic               snk_ready;
logic [DWIDTH-1:0]  src_data;
logic               src_startofpacket;
logic               src_endofpacket;
logic               src_valid;



logic [DWIDTH-1:0]  test_data     [$];
logic [DWIDTH-1:0]  read_data_dut [$];
logic [DWIDTH-1:0]  read_data_ref [$];

initial
  forever
    #5 clk = !clk;

default clocking cb
  @ (posedge clk);
endclocking

sort #(
  .DWIDTH                ( DWIDTH            ),
  .MAX_PKT_LEN           ( MAX_PKT_LEN       )
) dut (
  .clk_i                 ( clk               ),
  .srst_i                ( srst              ),
  .snk_data_i            ( snk_data          ),
  .snk_startofpacket_i   ( snk_startofpacket ),
  .snk_endofpacket_i     ( snk_endofpacket   ),
  .snk_valid_i           ( snk_valid         ),
  .src_ready_i           ( src_ready         ),
  .snk_ready_o           ( snk_ready         ),
  .src_data_o            ( src_data          ),
  .src_startofpacket_o   ( src_startofpacket ),
  .src_endofpacket_o     ( src_endofpacket   ),
  .src_valid_o           ( src_valid         )
);

task generate_data();
  logic [DWIDTH-1:0] tmp;
  test_data = {};
  read_data_ref = {};
  for ( int i = 0; i < test_len; i++ ) 
    begin
      tmp = $urandom();  
      test_data.push_back( tmp );
      read_data_ref.push_back( tmp );
    end
  read_data_ref.sort;
endtask

task send();
  begin
    int i;
    wait ( snk_ready );
    snk_startofpacket = 1'b1;
    do
      begin
        snk_data = test_data[i];
        if ( $urandom_range(10) > 4 )
          begin
            snk_valid = 1'b1;
            i++;
            ##1;
            snk_startofpacket = 1'b0;
            if ( i == test_len - 1 )
              snk_endofpacket = 1'b1;
          end
        else
          begin
            snk_valid = 1'b0;
            ##1;
          end
      end
    while ( i < test_len );
    ##1;
    snk_endofpacket = 1'b0;
  end
endtask
  
task read();
  begin
    wait ( src_startofpacket );
    repeat ( test_len )
      begin
        read_data_dut.push_back( src_data );
        ##1;
      end
  end
endtask

task check();
  begin
//    logic [DWIDTH-1:0] tmp_dut;
//    logic [DWIDTH-1:0] tmp_ref;
  for ( int i = 0; i < test_len; i++ )
    begin
      if ( read_data_dut[i] !== read_data_ref[i] )
        $error( "the result does not match the standard" );
    end
  end
endtask

initial
  begin
    test_len = 10;
    generate_data();
    ##1;
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    ##1;
    send();
    read();
    check();
    repeat ( 3 )
      begin
        ##1;
        generate_data();
        test_len = $urandom_range( 100,1000 );
        send();
        read();
        check();
      end
    ##1;
    test_len = 1024;
    generate_data();
    send();
    read();
    check();
    $stop();
  end
  
endmodule