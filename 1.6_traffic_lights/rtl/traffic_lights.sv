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
logic       [15:0]   g_blink_count;
logic       [15:0]   y_blink_count;

//тут меняем интервал мигания для мигающих состояний и длительность непрограммируемых состояний.
//1 мс = 2 такта

localparam  [15:0]   blink_time       = 16'd100;   
localparam  [15:0]   red_yel_time     = 16'd100;
localparam  [15:0]   green_blink_time = 16'd10;

enum logic [2:0] {RED_S,
                  RED_YEL_S,
                  GREEN_S,
                  GREEN_BLINK_S,
                  YELLOW_S,
                  YELLOW_BLINK_S,
                  WAITING_MOD_S } state, next_state;


// сначала конечный автомат.


always_ff @( posedge clk_i )
begin
  if (srst_i)
    state <= RED_S;
  else
    state <= next_state;
end

//условия переходов

always_comb
begin
  case ( state )
    RED_S:
      if ( turn_off )
        next_state     = WAITING_MOD_S;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK_S;
        else  
          if ( count == red_time )
            next_state = RED_YEL_S;
    RED_YEL_S:
      if ( turn_off )
        next_state     = WAITING_MOD_S;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK_S;
        else  
          if ( count == red_yel_time )
            next_state = GREEN_S;
    GREEN_S:
      if ( turn_off )
        next_state     = WAITING_MOD_S;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK_S;
        else  
          if ( count == green_time )
            next_state = GREEN_BLINK_S;
    GREEN_BLINK_S:
      if ( turn_off )
        next_state     = WAITING_MOD_S;
      else    
        if ( free_mod )
          next_state   = YELLOW_BLINK_S;
        else    
          if ( count == green_blink_time )
            next_state = YELLOW_S;
    YELLOW_S:
      if ( turn_off )
        next_state     = WAITING_MOD_S;
      else
        if ( free_mod )
          next_state   = YELLOW_BLINK_S;
        else  
          if ( count == yellow_time )
            next_state = RED_S;
    YELLOW_BLINK_S:
      if ( turn_off )
        next_state     = WAITING_MOD_S;
      else
        if ( ~free_mod )
          next_state   = RED_S;
    WAITING_MOD_S:
      if ( ~turn_off )
        if ( free_mod )
          next_state   = YELLOW_BLINK_S;
        else  
          next_state   = RED_S;
      
    default:
      next_state = RED_S;
  endcase
end

  
//выходы
  
always_comb
begin
  case ( state )
    RED_S:
      begin
      red_o    = 1'b1;
      yellow_o = 1'b0;
      green_o  = 1'b0;
      end
    RED_YEL_S:
      begin
      red_o    = 1'b1;
      yellow_o = 1'b1;
      green_o  = 1'b0;
      end
    GREEN_S:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b0;
      green_o  = 1'b1;
      end
    GREEN_BLINK_S:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b0;
      green_o  = blink_on;
      end
    YELLOW_S:
      begin
      red_o    = 1'b0;
      yellow_o = 1'b1;
      green_o  = 1'b0;
      end
    YELLOW_BLINK_S:
      begin
      red_o    = 1'b0;
      yellow_o = blink_on;
      green_o  = 1'b0;
      end
    WAITING_MOD_S:
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
      g_blink_count <= 16'd0;
	  y_blink_count <= 16'd0;
      count         <= 16'd0;
	  blink_on      <= 1'b0;
	end
  else
    case ( state )
      RED_S:
        if ( count == red_time )
          count    <= 16'd0;
        else
          count    <= count + 1;
      RED_YEL_S:
        if ( count == red_yel_time )
          count    <= 16'd0;
        else
          count    <= count + 1;
      GREEN_S:
        if ( count == green_time )
          count    <= 16'd0;
        else
          count    <= count + 1;
      GREEN_BLINK_S:
        begin
        if ( count       == green_blink_time )
          begin
            count        <= 16'd0;
            g_blink_count<= 16'd0;
			blink_on     <= 1'b0;
          end
        else
          count          <= count + 1;
        if ( g_blink_count == blink_time )
          begin
            blink_on     <= ~ blink_on;  
            g_blink_count<= 1'd0;
          end
        else
          g_blink_count  <= g_blink_count + 1;  
        end
      YELLOW_S:
        if (count        == yellow_time)
          count          <= 16'd0;
        else
          count          <= count + 1;
      YELLOW_BLINK_S:
        if ( y_blink_count == blink_time )
          begin
            blink_on     <= ~ blink_on;  
            y_blink_count<= 16'd0;
          end
        else
          y_blink_count  <= y_blink_count + 1;
      WAITING_MOD_S:
        count            <= 16'd0;
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