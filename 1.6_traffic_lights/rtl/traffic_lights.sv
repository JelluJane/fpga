module traffic_lights (
input  logic         clk_i,
input  logic         srst_i,
input  logic [2:0]   cmd_type_i,
input  logic         cmd_valid_i,
input  logic [15:0]  cmd_data_i,
output logic         red_o,
output logic         yellow_o,
output logic         green_o
);
bit                  free_mod;
bit                  turn_off;
bit                  blink_on;
logic       [16:0]   red_time; /*в тактах нужно будет удваивать полученное параметром число в мс, так что лишний бит*/
logic       [16:0]   yellow_time;
logic       [16:0]   green_time;
logic       [15:0]   count;
logic       [15:0]   blink_count;
logic       [15:0]   blink_time;   
logic       [15:0]   red_yel_time;
logic       [15:0]   green_blink_time;

//тут меняем интервал мигания для мигающих состояний и длительность непрограммируемых состояний.
//1 мс = 2 такта

assign red_yel_time     = 16'd6;
assign green_blink_time = 16'd6;
assign blink_time       = 16'd2;



enum logic [2:0] {RED,
                  RED_YEL,
                  GREEN,
                  GREEN_BLINK,
                  YELLOW,
                  YELLOW_BLINK,
                  WAITING_MOD } state, next_state;


// сначала конечный автомат.


always_ff @( posedge clk_i )
begin
  if (srst_i)
    state <= RED;
  else
    state <= next_state;
end

//условия переходов

always_comb
begin
  case ( state )
    RED:
      if ( turn_off )
        next_state     = WAITING_MOD;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK;
        else  
          if ( count == red_time )
            next_state = RED_YEL;
    RED_YEL:
      if ( turn_off )
        next_state     = WAITING_MOD;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK;
        else  
          if ( count == red_yel_time )
            next_state = GREEN;
    GREEN:
      if ( turn_off )
        next_state     = WAITING_MOD;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK;
        else  
          if ( count == green_time )
            next_state = GREEN_BLINK;
    GREEN_BLINK:
      if ( turn_off )
        next_state     = WAITING_MOD;
      else    
        if ( free_mod )
          next_state   = YELLOW_BLINK;
        else    
          if ( count == green_blink_time )
            next_state = YELLOW;
    YELLOW:
      if ( turn_off )
        next_state     = WAITING_MOD;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK;
        else  
          if ( count == yellow_time )
            next_state = RED;
    YELLOW_BLINK:
      if ( turn_off )
        next_state     = WAITING_MOD;
      else
        if ( ~free_mod )
          next_state   = RED;
    WAITING_MOD:
      if ( ~turn_off )
        if ( free_mod )
          next_state   = YELLOW_BLINK;
        else  
          next_state   = RED;
      
    default:
      next_state = RED;
  endcase
end

  
//выходы
  
always_comb
begin
  case ( state )
    RED:
      begin
      red_o    = 1'b1;
      yellow_o = 1'b0;
      green_o  = 1'b0;
      end
    RED_YEL:
      begin
      red_o    = 1'b1;
      yellow_o = 1'b1;
      green_o  = 1'b0;
      end
    GREEN:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b0;
      green_o  = 1'b1;
      end
    GREEN_BLINK:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b0;
      green_o  = blink_on;
      end
    YELLOW:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b1;
      green_o  = 1'b0;
      end
    YELLOW_BLINK:
      begin
      red_o    = 1'b0;
      yellow_o = blink_on;
      green_o  = 1'b0;
      end
    WAITING_MOD:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b0;
      green_o  = 1'b0;
      end
    default:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b0;
      green_o  = 1'b0;
      end
  endcase
end

//счётчики
  
always_ff @( posedge clk_i )
begin
  if ( srst_i )
    begin
      blink_count <= 1'd0;
      count       <= 16'd0;
    end
  else
    case ( state )
      RED:
        if ( count == red_time )
          count    <= 16'd0;
        else
          count    <= count + 1;
      RED_YEL:
        if ( count == red_yel_time )
          count    <= 16'd0;
        else
          count    <= count + 1;
      GREEN:
        if ( count == green_time )
          count    <= 16'd0;
        else
          count    <= count + 1;
      GREEN_BLINK:
        begin
        if ( count       == green_blink_time )
          begin
            count        <= 16'd0;
            blink_count  <= 16'd0;
          end
        else
          count          <= count + 1;
        if ( blink_count == blink_time )
          begin
            blink_on     <= ~ blink_on;  
            blink_count  <= 1'd0;
          end
        else
          blink_count    <= blink_count + 1;  
        end
      YELLOW:
        if (count        == yellow_time)
          count          <= 16'd0;
        else
          count          <= count + 1;
      YELLOW_BLINK:
        if ( blink_count == blink_time )
          begin
            blink_on     <= ~ blink_on;  
            blink_count  <= 16'd0;
          end
        else
          blink_count    <= blink_count + 1;
      WAITING_MOD:
        ;
      default:
        ;
    endcase
end

// настройки

always_ff @(posedge clk_i)
begin
  if(srst_i)
    begin
      free_mod           <=1'b0;
      turn_off           <=1'b0;
    end
  else
    if (cmd_valid_i)
      case (cmd_type_i)
        3'd0:
          begin
            turn_off     <= 1'b0;
            free_mod     <= 1'b0;
          end
        3'd1:
            turn_off     <= 1'b1;
        3'd2:
          begin
            free_mod     <= 1'b1;
            turn_off     <= 1'b0;
          end
        3'd3:
            green_time   <= cmd_data_i * 2;
        3'd4:
            red_time     <= cmd_data_i * 2;
        3'd5:
            yellow_time  <= cmd_data_i * 2;
        default:
            ;
      endcase  
end  
  
endmodule