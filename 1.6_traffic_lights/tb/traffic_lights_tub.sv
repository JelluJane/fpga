module testbench_traffic_lights ();
bit          clk;
bit          srst;
bit          rst_done;
logic [2:0]  cmd_type;
logic        cmd_valid;
logic [15:0] cmd_data;
logic        red;
logic        yellow;
logic        green;

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

initial
  begin
    srst = 1'b0;
    @( posedge clk );
    srst = 1'b1;
    @( posedge clk );
    srst = 1'b0;
    rst_done = 1'b1;
    $display( "RESET DONE" );
  end

initial
  begin
    wait(rst_done);
	##1;
	cmd_valid = 1'b1;
	cmd_type = 3'd1; //выключаем.
	##1;
	cmd_type = 3'd3; // устанавливаем зелёный.
	cmd_data = 5;
	##1;
	cmd_type = 3'd4; // устанавливаем красный.
	cmd_data = 5;
	##1;
	cmd_type = 3'd5; // устанавливаем желтый.
	cmd_data = 5;
	##1;
	cmd_type = 3'd2; // неуправляемый.
	##1;
	cmd_valid = 1'b0; //отпускаем моргать.
	##100;//поморгали жёлтым
	cmd_valid = 1'b1; 
	cmd_type = 3'd1; //выключаем.
	##1;
	cmd_valid = 1'b0; //отпускаем ничего не делать.
	##100;//поничего-не-делали.
	cmd_valid = 1'b1; 
	cmd_type = 3'd0; //включаем.
	##1;
	cmd_valid = 1'b0; //отпускаем работать
	##1000;
  end
endmodule