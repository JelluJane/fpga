module testbench_traffic_lights ();
logic [2:0]  cmd_type;
logic        cmd_valid;
logic [15:0] cmd_data;
logic        red;
logic        yellow;
logic        green;

logic [15:0] tmp_r;
logic [15:0] tmp_y;
logic [15:0] tmp_g;

parameter    TEST_LEN = 10;

int          cnt;
bit          clk;
bit          srst;

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


traffic_lights dut (
.clk_i             (clk         ),
.srst_i            (srst        ),
.cmd_type_i        (cmd_type    ),
.cmd_valid_i       (cmd_valid   ),
.cmd_data_i        (cmd_data    ),
.red_o             (red         ),
.yellow_o          (yellow      ),
.green_o           (green       )
);

task gen_properties ();
  cmd_valid = 1'b1;
  cmd_type  = 3'd1;
  ##10;
  tmp_r = ( $urandom_range( 10, 2 ) * 10 );
  tmp_y = ( $urandom_range( 10, 2 ) * 10 );
  tmp_g = ( $urandom_range( 10, 2 ) * 10 );
  cmd_type = 3'd3;
  cmd_data = tmp_g;
  ##1;
  cmd_type = 3'd4;
  cmd_data = tmp_r;
  ##1;
  cmd_type = 3'd5;
  cmd_data = tmp_y;
  ##1;
  cmd_type = 3'd0;
  ##1;
  cmd_valid = 1'b0;
  ##1;
endtask

task check ();
  cnt = 0;
  wait ( red );
  do
    begin
    cnt += 1;
       ##1;
    end
  while ( red && ( yellow == 1'b0 ) );
  if ( cnt != ( ( tmp_r * 2 ) + 1 ) )
    $error("error with red, cnt = %d, tmp_r = %d", cnt, tmp_r);
  cnt = 0;
  wait ( green )
  do
    begin
    cnt += 1;
       ##1;
    end
  while ( green );
  if ( cnt != ( ( tmp_g * 2 ) + 2 ) ) //хоть убейте не понимаю, почему тут смещение на 2... в красном логичное смещение на 1, а тут...
    $error("error with green, cnt = %d, tmp_g = %d", cnt, tmp_g);
  cnt = 0;    
  wait ( yellow )
  do
    begin
    cnt += 1;
       ##1;
    end
  while ( yellow );
  if ( cnt != ( ( tmp_y * 2 ) + 2 ) ) // та же фигня
    $error("error with yellow, cnt = %d, tmp_y = %d", cnt, tmp_y);
  ##1000;
endtask

initial
  begin
    srst = 1'b0;
    @( posedge clk );
    srst = 1'b1;
    @( posedge clk );
    srst = 1'b0;
    ##1;
    repeat ( TEST_LEN )
      begin
      gen_properties();
      check ();
      end      
    $finish;
  end
endmodule