module lifo_tb;

localparam int      DWIDTH       = 16;
localparam int      AWIDTH       = 8;
localparam int      ALMOST_FULL  = 14;
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

task automatic generate_data();
  logic [DWIDTH-1:0] tmp;
  test_data = {};
  for ( int i = 0; i < 1000; i++ ) 
    begin
      tmp = $urandom();  
      test_data.push_back( tmp );
    end
endtask
  
task automatic send_data_wo();
  logic [DWIDTH-1:0] tmp;
  read_data_ref = {};
  repeat ( test_len )
    begin
      tmp = test_data.pop_back();
      read_data_ref.push_front( tmp );
      data = tmp;
      wrreq = 1'b1;
      ##1;
    end  
  wrreq = 1'b0;
endtask

task get_data_ro ();
  rdreq = 1'b1;
  repeat ( test_len )
    begin
      ##1;
      read_data_dut.push_back( q );
    end
endtask

task check_data ();
    logic [DWIDTH-1:0] tmp_dut;
    logic [DWIDTH-1:0] tmp_ref;
      repeat ( test_len )
        begin
          tmp_dut = read_data_dut.pop_back();
          tmp_ref = read_data_ref.pop_back();
          if ( tmp_dut != tmp_ref )
            $error( "the data does not match" );
        end
endtask      
      
initial
  begin
    //read_data_dut = new();
    //read_data_ref = new();
    generate_data();
    ##1;
    srst = 1'b1;
    ##1;
    srst = 1'b0;
    ##1;
    test_len = 16;
    // whrite only
    send_data_wo();
    // read only
    get_data_ro();
    check_data();
    $stop;
  end
endmodule