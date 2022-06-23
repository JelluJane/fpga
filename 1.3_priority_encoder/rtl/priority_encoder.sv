module priority_encoder #(
parameter WIDTH = 8
)(
input  logic             clk_i,
input  logic [WIDTH-1:0] data_i,
input  logic             srst_i,
input  logic             data_val_i,
output logic [WIDTH-1:0] data_left_o,
output logic [WIDTH-1:0] data_right_o,
output logic             data_val_o
);

logic [WIDTH-1:0]        data_left_w;
logic [WIDTH-1:0]        data_right_w;
    
always_comb                                                                     
begin        
data_right_w = '0;                                                          
data_left_w  = '0;  
if ( data_val_i )                                                        
  for( int i = 0; i < WIDTH; i++ )                                              
    begin                                                                   
        if (data_i[i] == 1)                                                  
        begin                                                           
          data_right_w[i] = 1'b1;                                         
          break;                                          
        end 
    end
  for(int i = 0; i < WIDTH; i++)                                              
    begin                                                                   
      if (data_i[(WIDTH-1)-i] == 1)                                        
        begin                                                           
          data_left_w[(WIDTH-1)-i] = 1'b1;                                        
          break;                                        
        end                                             
    end                                               
end

always_ff @ ( posedge clk_i )
data_left_o  <= data_left_w;

always_ff @ ( posedge clk_i )
data_right_o <= data_right_w;

always_ff @ ( posedge clk_i )
data_val_o   <= data_val_i;

endmodule
