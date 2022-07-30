module sort #(
parameter           DWIDTH = 8,
parameter           MAX_PKT_LEN = 1024
)(
input               clk_i,
input               srst_i,
input [DWIDTH-1:0]  snk_data_i,
input               snk_startofpacket_i,
input               snk_endofpacket_i,
input               snk_valid_i,

input               src_ready_i,

output logic        snk_ready_o,
output [DWIDTH-1:0] src_data_o,
output logic        src_startofpacket_o,
output logic        src_endofpacket_o,
output logic        src_valid_o
);

//вспомогательные переменные

localparam                      ADDR_W = $clog2(MAX_PKT_LEN);

logic                           in_rec;
logic                           check;
logic [ADDR_W-1:0]              sorting_count;



//память 

logic                           wren_a;
logic                           wren_b;
logic [ADDR_W-1:0] w_addr;
logic [ADDR_W-1:0] r_addr;
logic [ADDR_W-1:0] addr_a;
logic [ADDR_W-1:0] addr_b;
logic [DWIDTH-1:0]              data_a;
logic [DWIDTH-1:0]              data_b;
logic [DWIDTH-1:0]              q_a;
logic [DWIDTH-1:0]              q_b;

assign write_data = in_rec  && snk_valid_i;

assign wren_a = snk_ready_o ? write_data : ( q_b < q_a );
assign wren_b = snk_ready_o ? 1'b0       : ( q_b < q_a );
assign data_a = snk_ready_o ? snk_data_i : q_b;
assign data_b = q_a;
assign addr_a = snk_ready_o ? w_addr     : sorting_count;
assign addr_b = addr_a + 1'b1;

assign src_data_o = q_a;

//не будет ли проблем от того, что я повсеместно использую как сигнал занятости модуля для внутренних исходящий сигнал лоджик snk_ready_o?
//жопой чую, что такое количество комбинационной логики мне аукнется петлями.
//write and read data

RAM2p #() memory (
.address_a       ( addr_a ),
.address_b       ( addr_b ),
.clock           ( clk_i  ),
.data_a          ( data_a ),
.data_b          ( data_b ),
.wren_a          ( wren_a ),
.wren_b          ( wren_b ),
.q_a             ( q_a    ),
.q_b             ( q_b    )
);

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      in_rec <= 1'b0;
    else
      if ( snk_endofpacket_i && snk_valid_i )
        in_rec <= 1'b0;
      else
        if ( snk_startofpacket_i && snk_valid_i )
          in_rec <= 1'b1;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      snk_ready_o <= 1'b1;
    else
      if ( snk_endofpacket_i && snk_valid_i )
        snk_ready_o <= 1'b0;
      else if ( src_endofpacket_o )
        snk_ready_o <= 1'b1;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      w_addr <= '0;
    else
      if ( write_data )
        w_addr <= w_addr + 1'b1;
      else if ( ~in_rec )
        w_addr <= '0;
  end
  
//////////////////////////////////////////////////////////////////////////////////

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      sorting_count <= '0;
    else
      if ( src_valid_o )
        if ( ~snk_ready_o && ( sorting_count < MAX_PKT_LEN - 1 ) && src_ready_i )
          sorting_count <= sorting_count + 1'b1;
        else
          if ( ~snk_ready_o && ( sorting_count < MAX_PKT_LEN - 1 ) && ~src_ready_i )
            sorting_count <= sorting_count;
          else
            sorting_count <= '0;  
      else
        if ( ~snk_ready_o && ( sorting_count < MAX_PKT_LEN - 2 ) )
          sorting_count <= sorting_count + 1'b1;
        else
          sorting_count <= '0;  
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      check <= 1'b1;
    else
      if ( src_valid_o )
        check <= 1'b0;
      else
        if ( sorting_count == '0 )
          check <= 1'b1;
        else
          if ( q_a > q_b )
            check <= 1'b0;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      src_valid_o <= 1'b0;
    else
      if ( ( sorting_count == MAX_PKT_LEN - 2) && check )
        src_valid_o <= 1'b1;
      else if ( sorting_count == MAX_PKT_LEN - 1 )
        src_valid_o <= 1'b0;
  end
 
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      src_startofpacket_o <= 1'b0;
    else
      if ( ( sorting_count == MAX_PKT_LEN - 2) && check )
        src_startofpacket_o <= 1'b1;
      else
        src_startofpacket_o <= 1'b0;
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      src_endofpacket_o <= 1'b0;
    else
      if ( ( sorting_count == MAX_PKT_LEN - 2) && src_valid_o )
        src_endofpacket_o <= 1'b1;
      else
        src_endofpacket_o <= 1'b0;
  
  end

endmodule 