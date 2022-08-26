module lifo_tb;

localparam int      DWIDTH       = 16;
localparam int      AWIDTH       = 8;
localparam int      ALMOST_FULL  = 2;
localparam int      ALMOST_EMPTY = 2;

bit                 clk;
bit                 srst;

logic [DWIDTH-1:0]  data;
logic               wrreq;

logic               rdreq;
logic [DWIDTH-1:0]  q;

logic               almost_empty;
logic               empty;
logic               almost_full;
logic               full;
logic [AWIDTH:0]    usedw;       

int                 test_len;

logic [DWIDTH-1:0]  test_data[$];
logic [DWIDTH-1:0]  temp_data[$];
logic [DWIDTH-1:0]  read_data_dut[$];
logic [DWIDTH-1:0]  read_data_ref[$];  

initial
  forever
    #5 clk = !clk;

default clocking cb
  @ (posedge clk);
endclocking

lifo #(
  .DWIDTH          ( DWIDTH       ),
  .AWIDTH          ( AWIDTH       ),
  .ALMOST_FULL     ( ALMOST_FULL  ),
  .ALMOST_EMPTY    ( ALMOST_EMPTY )
) dut (
  .clk_i           ( clk          ),
  .srst_i          ( srst         ),
  .wrreq_i         ( wrreq        ),
  .data_i          ( data         ),
  .rdreq_i         ( rdreq        ),
  .q_o             ( q            ),
  .almost_empty_o  ( almost_empty ),
  .empty_o         ( empty        ),
  .almost_full_o   ( almost_full  ),
  .full_o          ( full         ),
  .usedw_o         ( usedw        )
);

task wr_only();
  wrreq = 1'b1;
  rdreq = 1'b0;
  data = $urandom();
  read_data_ref.push_front( data );
  ##1;
endtask

task write_with_read();
  wrreq = 1'b1;
  repeat ( test_len )
    begin
      data = $urandom();
      read_data_ref.push_back( data );
      ##1;
    end
  wrreq = 1'b0;
endtask

task read_with_write();
  wait ( usedw > (AWIDTH+1)'(1) )
  rdreq = 1'b1;
  repeat ( test_len + 1 )
    begin
      ##1;
      read_data_dut.push_back( data );
    end
  rdreq = 1'b0;
  ##1;
  read_data_dut.push_front ( data );
  
endtask

task rd_only();
  rdreq = 1'b1;
  wrreq = 1'b0;
  ##1;
  read_data_dut.push_back( q );
endtask

task idle();
  ##1;
  rdreq = 1'b0;
  wrreq = 1'b0;
  ##1;
endtask 

task check_data ();
    logic [DWIDTH-1:0] tmp_dut;
    logic [DWIDTH-1:0] tmp_ref;
      for ( int i = 0; i < test_len; i++)
        begin
          tmp_dut = read_data_dut.pop_back();
          tmp_ref = read_data_ref.pop_back(); 
          $display("%d dut is %b ref is %b", i, tmp_dut, tmp_ref);
          if ( tmp_dut != tmp_ref )
            begin
              $error( "the data does not match" );
            end
        end
endtask

task testcase0();
  read_data_dut = {};
  read_data_ref = {};
  test_len = ( 2**AWIDTH ) + 1 ;
  $display( "Testcase0: write until full, then read until empty.");
  repeat( ( 2**AWIDTH ) + 1  ) wr_only();
  repeat( ( 2**AWIDTH ) + 1  ) rd_only();
  idle();
  check_data ();
endtask

task testcase1();
  $display( "Testcase1: read from empty." );
  repeat ( 3 ) rd_only();
  ##1;
  if ( usedw !== '0 )
    $error( "read from empty lifo" );
endtask

task testcase2();
  read_data_dut = {};
  read_data_ref = {};
  test_len = ( 2**AWIDTH );
  $display( "Testcase2: write until overflow, then read until empty.");
  repeat( 2**AWIDTH ) wr_only();
  ##1;
  //лишний такт обеспечит попытку записи в полный модуль, но не сохранит эту попытку в очередь с результатами.
  if ( usedw > ( 2**AWIDTH - 1 ) )
    $error( "overflow lifo" );
  repeat( 2**AWIDTH ) rd_only();
  idle();
  //check_data ();
endtask

task testcase3();
  logic [DWIDTH-1:0] tmp;
  read_data_dut = {};
  read_data_ref = {};
  test_len = ( 2**AWIDTH );
  $display( "Testcase3: write and read %d iteration", test_len);
  fork
    write_with_read();
    read_with_write();
  join
  idle();
  check_data ();
endtask

initial
  begin
    ##1;
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    idle();
    //запись до конца, чтение до конца.
    testcase0();
    //чтение из пустой
    testcase1();
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    ##1;
    //запись с переполнением, чтение до конца.
    testcase2();
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    ##1;
    testcase3();
    $stop;
  end
endmodule