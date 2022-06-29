module testbench_priority_encoder #(
parameter              WIDTH = 8
)();
logic    [WIDTH-1:0]   data;
logic                  data_val;
logic    [WIDTH-1:0]   data_left;
logic    [WIDTH-1:0]   data_right;
logic                  deser_data_val;
logic    [WIDTH-1:0]   tmp_data;
logic    [WIDTH-1:0]   tmp_left;
logic    [WIDTH-1:0]   tmp_right;
logic    [WIDTH-1:0]   r_res;
logic    [WIDTH-1:0]   r_test;
logic    [WIDTH-1:0]   l_res;
logic    [WIDTH-1:0]   l_test;

parameter              TEST_LEN = 1000;

bit                    clk;
logic                  srst;

mailbox                r_ref_result;
mailbox                r_result;
mailbox                l_ref_result;
mailbox                l_result;

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

priority_encoder #(
.WIDTH            (WIDTH          )
) dut (
.clk_i            (clk            ),
.srst_i           (srst           ), 
.data_i           (data           ),
.data_val_i       (data_val       ),
.data_left_o      (data_left      ), 
.data_right_o     (data_right     ),
.data_val_o       (deser_data_val )
);


task create_trans();
  tmp_data  = $urandom();
  tmp_left  = '0;
  tmp_right = '0;
  if ( $urandom_range(10) > 2 )
    data_val = 1'b1;
  else
    data_val = 1'b0;
  data       = tmp_data;
  if( data_val )
    begin
      for( int i = 0; i < WIDTH; i++ ) 
        begin  
          if ( tmp_data[i] )
            begin
              tmp_right[i] = 1;
              break;
            end
        end
      for( int i = 0; i < WIDTH; i++ )  
        begin 
          if ( tmp_data[( WIDTH-1 ) -i] )
            begin
              tmp_left[( WIDTH-1 ) -i] = 1;
              break;
            end
        end
    end
  if ( data_val )
    begin
      r_ref_result.put( tmp_right );
      l_ref_result.put( tmp_left );
    end
  ##1;  
endtask

task accumd();
  forever
    begin
      if( deser_data_val === 1'b1 )
        begin
          r_result.put( data_right );
          l_result.put( data_left );
        end
      ##1;
    end
endtask

task check();
  forever
    begin
      r_ref_result.get ( r_test );
	  l_ref_result.get ( l_test );
      r_result.get ( r_res );
      l_result.get ( l_res );
      if( r_test !=  r_res )
        $error("error %b, %b", r_test, r_res); 
      if( l_test !=  l_res )
        $error("error %b, %b", l_test, l_res); 
    end
endtask

initial
  begin
    r_result = new();
    r_ref_result = new();
	l_result = new();
    l_ref_result = new();
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