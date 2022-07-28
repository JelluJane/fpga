module fifo #(
parameter                 DWIDTH = 16,
parameter                 AWIDTH = 8,
parameter                 SHOWAHEAD = 1,
parameter                 ALMOST_FULL_VALUE = 240,
parameter                 ALMOST_EMPTY_VALUE = 16,
parameter                 REGISTER_OUTPUT = 0 
)(
input                     clk_i,
input                     srst_i,

input        [DWIDTH-1:0] data_i,
input                     wrreq_i,
input                     rdreq_i,

output logic[DWIDTH-1:0]  q_o,
output                    empty_o,
output                    full_o,
output      [AWIDTH-1:0]  usedw_o,

output                    almost_full_o,
output                    almost_empty_o
);

localparam                LENGHT = 2**AWIDTH;

logic       [DWIDTH-1:0]  memory   [0: LENGHT-1];
logic       [LENGHT-1:0]  w_addr;
logic       [LENGHT-1:0]  r_addr;
logic       [LENGHT-1:0]  cnt;
logic       [DWIDTH-1:0]  read;

assign usedw_o = cnt;
assign full_o  = & cnt;
assign empty_o = ~( | cnt);
assign almost_full_o  = cnt >= ( LENGHT - 1 ) - ALMOST_FULL_VALUE;
assign almost_empty_o = cnt < ALMOST_EMPTY_VALUE;

always_ff @( posedge clk_i )
  begin
    if ( wrreq_i )
      memory [w_addr] <= data_i;
  end
  
always_ff @( posedge clk_i )
  begin
    if ( SHOWAHEAD )
      read <= memory [r_addr + 1];
    else
      if ( rdreq_i )
        read <= memory [r_addr];        
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      w_addr <= '0;
    else
      if ( wrreq_i )
        w_addr <= w_addr + 1'b1;
   end
  
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      r_addr <= '0;
    else
      if ( rdreq_i )
        r_addr <= r_addr + 1'b1;
  end
  
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      cnt <= '0;
    else 
      if (wrreq_i & ~ rdreq_i)
        cnt <= cnt + 1'b1;
      if (rdreq_i & ~ wrreq_i)
        cnt <= cnt - 1'b1;
  end
endmodule