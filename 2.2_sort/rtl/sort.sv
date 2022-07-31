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

logic                           check;
logic [ADDR_W-1:0]              sort_cnt;
logic [ADDR_W-1:0]              w_cnt;
logic [ADDR_W-1:0]              r_cnt;

//память 

logic                           wren_a;
logic                           wren_b;
logic [ADDR_W-1:0]              addr_a;
logic [ADDR_W-1:0]              addr_b;
logic [DWIDTH-1:0]              data_a;
logic [DWIDTH-1:0]              data_b;
logic [DWIDTH-1:0]              q_a;
logic [DWIDTH-1:0]              q_b;

//всякие нужности

assign src_data_o = q_a;

RAM2p memory (
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

//FSM

enum logic [1:0] {IDLE_S,
                  WRITE_S,
                  SORT_S,
                  READ_S} 
                  state, next_state;
                  
always_ff @( posedge clk_i )
  begin
    if (srst_i)
      state <= IDLE_S;
    else
      state <= next_state;
  end

always_comb
  begin
    case ( state )
    IDLE_S:
      if ( snk_valid_i && snk_startofpacket_i )
        next_state = WRITE_S;
    WRITE_S:
      if ( snk_valid_i && snk_endofpacket_i )
        next_state = SORT_S;
    SORT_S:
      if ( w_cnt == (ADDR_W)'(1) )
        next_state = READ_S;
      else if ( ( sort_cnt === w_cnt ) && check )
        next_state = READ_S;
    READ_S:
      if ( r_cnt == w_cnt )
        next_state = IDLE_S;
    endcase
  end

always_comb
  begin
    case ( state )
    IDLE_S:
      begin
        snk_ready_o = 1'b1;
        src_valid_o = 1'b0;
        wren_a = snk_valid_i;
        addr_a = '0;
        data_a = snk_data_i;
      end
    WRITE_S:
      begin
        snk_ready_o = 1'b0;
        wren_a = snk_valid_i;
        addr_a = w_cnt;
        data_a = snk_data_i;
      end
    SORT_S:
      begin
        data_a = q_b;
        data_b = q_a;
        wren_a = q_b < q_a;
        wren_b = q_b < q_a;
        addr_a = sort_cnt;
        addr_b = sort_cnt + (ADDR_W)'(1);
      end
    READ_S:
      begin
        addr_a = r_cnt;
        src_valid_o = 1'b1;
      end
    endcase
  end

// адресс для записи и он же счётчик полученных слов

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      w_cnt <= '0;
    else if ( state == IDLE_S )
      w_cnt <= '0;
    else if ( ( state == WRITE_S ) && snk_valid_i )
      w_cnt <= w_cnt + (ADDR_W)'(1);
  end

//выбор адресса для сортировки

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      sort_cnt <= '0;
    else if ( ( state == SORT_S ) && ( sort_cnt < (w_cnt - (ADDR_W)'(1)) ) )
      sort_cnt <= sort_cnt + (ADDR_W)'(1);
    else
      sort_cnt <= '0;
  end
  
// и адресс для чтения

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      r_cnt <= '0;
    else if ( state == READ_S )
      r_cnt <= r_cnt + src_ready_i;
    else
      r_cnt <= '0;
  end

//флаг отсортированного массива
  
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      check <= 1'b1;
    else
      if ( state != SORT_S )
        check <= 1'b0;
      else
        if ( sort_cnt == '0 )
          check <= 1'b1;
        else
          if ( q_a > q_b )
            check <= 1'b0;
  end

//начало транзакции на выходе

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      src_startofpacket_o <= 1'b0;
    else
      if ( src_startofpacket_o )
        src_startofpacket_o <= 1'b0;
      else if ( ( state == READ_S ) && ( r_cnt == '0 ) )
        src_startofpacket_o <= 1'b1;
  end

//завершение транзакции на выходе

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      src_endofpacket_o <= 1'b0;
    else
      if ( src_endofpacket_o )
        src_endofpacket_o <= 1'b0;
      else if ( ( state == READ_S ) && ( r_cnt == w_cnt ) )
        src_endofpacket_o <= 1'b1;
  end

endmodule 