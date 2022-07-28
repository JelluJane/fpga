`timescale 1 ps / 1 ps
module top_tb;

parameter DWIDTH             = 4;
parameter AWIDTH             = 16;
parameter ALMOST_FULL_VALUE  = 10;
parameter ALMOST_EMPTY_VALUE = 3;
parameter TEST_LEN = 1000;

logic              srst;
logic [DWIDTH-1:0] data;
logic              wrreq;
logic              rdreq;

logic [DWIDTH-1:0] q_dut, q_ref;
logic              empty_dut, empty_ref;
logic              full_dut, full_ref;
logic [DWIDTH:0]   usedw_dut, usedw_ref;
logic              almost_full_dut, almost_full_ref;
logic              almost_empty_dut, almost_empty_ref;

bit                clk;

logic [DWIDTH-1:0] test_data [$];
logic [DWIDTH-1:0] read_data_ref  [$];
logic [DWIDTH-1:0] read_data_dut  [$];

initial
  forever
    #5 clk = !clk;

default clocking cb
  @ (posedge clk);
endclocking

fifo #(
  .DWIDTH             ( DWIDTH             ),
  .AWIDTH             ( AWIDTH             ),
  .ALMOST_FULL_VALUE  ( ALMOST_FULL_VALUE  ),
  .ALMOST_EMPTY_VALUE ( ALMOST_EMPTY_VALUE )
) dut (
  .clk_i              ( clk                ),
  .srst_i             ( srst               ),
  .data_i             ( data               ),

  .wrreq_i            ( wrreq              ),
  .rdreq_i            ( rdreq              ),
  .q_o                ( q_dut              ),
  .empty_o            ( empty_dut          ),
  .full_o             ( full_dut           ),
  .usedw_o            ( usedw_dut          ),

  .almost_full_o      ( almost_full_dut    ),
  .almost_empty_o     ( almost_empty_dut   )
);

scfifo #(
  .lpm_width               ( DWIDTH                ),
  .lpm_widthu              ( AWIDTH                ),
  .lpm_numwords            ( 2 ** AWIDTH           ),
  .lpm_showahead           ( "ON"                  ),
  .lpm_type                ( "scfifo"              ),
  .lpm_hint                ( "RAM_BLOCK_TYPE=M10K" ),
  .intended_device_family  ( "Cyclone V"           ),
  .underflow_checking      ( "ON"                  ),
  .overflow_checking       ( "ON"                  ),
  .allow_rwcycle_when_full ( "OFF"                 ),
  .use_eab                 ( "ON"                  ),
  .add_ram_output_register ( "OFF"                 ),
  .almost_full_value       ( ALMOST_FULL_VALUE     ),
  .almost_empty_value      ( ALMOST_EMPTY_VALUE    ),
  .maximum_depth           ( 0                     ),
  .enable_ecc              ( "FALSE"               )
) golden_model (
  .clock                   ( clk                   ),
  .data                    ( data                  ),
  .rdreq                   ( rdreq                 ),
  .sclr                    ( srst                  ),
  .wrreq                   ( wrreq                 ),
  .almost_empty            ( almost_empty_ref      ),
  .almost_full             ( almost_full_ref       ),
  .empty                   ( empty_ref             ),
  .full                    ( full_ref              ),
  .q                       ( q_ref                 ),
  .usedw                   ( usedw_ref             ),
  .aclr                    (                       ),
  .eccstatus               (                       )
);

task generate_data();
  logic [DWIDTH-1:0] tmp;
  for ( int i = 0; i < TEST_LEN; i++ ) 
    begin
      tmp = $urandom();  
      test_data.push_back(tmp);
    end
endtask

task write_dut ();
  int i;
  do
    begin
      wait ( ~full_dut )
      if ( ( almost_empty_dut & almost_full_dut ) == 0 )
        if ( $urandom_range (1, 100) <= 50 )
          begin
            wrreq = 1'b1;
            data = test_data[i];
            i++;
          end
        else
          begin
            wrreq = 1'b0;
            ##1;
          end
      else if ( almost_empty_dut )
        if ( $urandom_range (1, 100) <= 75 )
          begin
            wrreq = 1'b1;
            data = test_data[i];
            i++;
          end
        else
          begin
            wrreq = 1'b0;
            ##1;
          end
      else
        if ( $urandom_range (1, 100) <= 25 )
          begin
            wrreq = 1'b1;
            data = test_data[i];
            i++;
          end
        else
          begin
            wrreq = 1'b0;
            ##1;
          end
    end
  while ( i < TEST_LEN );
endtask

task read_dut ();
  int i;
  do
    begin
      wait ( ~empty_dut )
      if ( ( almost_empty_dut & almost_full_dut ) == 0 )
        if ( $urandom_range (1, 100) <= 50 )
          begin
            rdreq = 1'b1;
            read_data_dut.push_back(q_dut);
            i++;
          end
        else
          begin
            rdreq = 1'b0;
            ##1;
          end
      else if ( almost_empty_dut )
        if ( $urandom_range (1, 100) <= 25 )
          begin
            rdreq = 1'b1;
            read_data_dut.push_back(q_dut);
            i++;
          end
        else
          begin
            rdreq = 1'b0;
            ##1;
          end
      else
        if ( $urandom_range (1, 100) <= 75 )
          begin
            rdreq = 1'b1;
            read_data_dut.push_back(q_dut);
            i++;
          end
        else
          begin
            rdreq = 1'b0;
            ##1;
          end
    end
  while ( i < TEST_LEN );
endtask

task read_ref ();
  do
    begin
      @( posedge clk )
      if ( rdreq )
        read_data_ref.push_back(q_ref);
    end
  while ( read_ref.size < TEST_LEN );
endtask

task check_rd_wr ();
  for (int i = 0; i < TEST_LEN; i++)
    begin
    if ( read_data_dut[i] != read_data_ref[i] )
       $error( "the result does not match the standard" );
    if ( read_data_dut[i] != test_data[i] )
       $error( "the result does not match the initial data" );
    end
endtask

task comare_signals_dut_ref ();
  forever
    begin
       ##1;
       if( almost_empty_ref !== almost_empty_dut )
         $error( "almost_empty mismatch" );

       if( almost_full_ref !== almost_full_dut )
         $error( "almost_full mismatch" );
         
    end
endtask

initial
  begin
    generate_data();
    ##1;
    
    fork
      comare_signals_dut_ref();
    join_none
    
    fork
      write_dut();
      read_dut();
      read_ref();
    join

    check_rd_wr();

    $stop();
  end
  
endmodule
