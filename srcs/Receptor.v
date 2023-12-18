`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module Receptor
#(
    //PARAMETERS
    parameter                       NB_DATA         =   8               ,
    parameter                       NB_STOP         =   2               ,
    parameter                       NB_STOP_TICKS   =   16 * NB_STOP
 )
 (
    //OUTPUTS
    output wire [NB_DATA-1:0]       o_data                              ,
    output wire                     o_valid                             ,
    //INPUTS
    input  wire                     i_clk                               ,
    input  wire                     i_reset                             ,
    input  wire                     i_tick                              ,
    input  wire                     i_rx    
  );
  
  //LOCALPARAMS
   localparam  idle_STATE      = 4'b0001           ;
   localparam  start_STATE     = 4'b0010           ;
   localparam  receiving_STATE = 4'b0100           ;
   localparam  stop_STATE      = 4'b1000           ;
      
  //INTERNAL REGS & WIRES
  reg   [NB_DATA-1:0]   reg_data        ;
  reg   [NB_DATA-1:0]   next_reg_data   ;
  reg   [5-1:0]         cnt             ;           ////////////////////VER EL TAMAÑO
  reg   [5-1:0]         next_cnt        ;           
  reg   [3-1:0]         n_bit           ;           ////////////////////IGUAL
  reg   [3-1:0]         next_n_bit      ;
  reg   [4-1:0]         state           ;
  reg   [4-1:0]         next_state      ;
  reg                   aux_valid       ;
  reg                   reg_valid       ;        
  
  //MEMORY
    always @(posedge i_clk) begin
        if(i_reset) begin
            state       <=  idle_STATE             ;
            n_bit       <=  0                   ;
            cnt         <=  0                   ;
            reg_data    <=  0                   ;
            reg_valid   <=  0                   ;
        end
        else begin
            state       <=  next_state          ;
            n_bit       <=  next_n_bit          ;
            cnt         <=  next_cnt            ;
            reg_data    <=  next_reg_data       ;
            reg_valid   <=  aux_valid           ;
        end
    end 

//NEXT STATE LOGIC
    always @(*) begin
        next_state    = state       ;        
        next_n_bit    = n_bit       ;
        next_cnt      = cnt         ;
        next_reg_data = reg_data    ;
        aux_valid     = reg_valid   ;
        
        case(state)
        
            idle_STATE : begin
                        aux_valid = 1'b0;
                        if(!i_rx)begin        
                                next_cnt    = 0         ;
                                next_state  = start_STATE   ;
                        end
                      end
                      
            start_STATE : begin
                        if(i_tick) begin
                            if(cnt==7) begin
                                 next_cnt    = 0         ;
                                 next_n_bit  = 0         ;
                                 next_state  = receiving_STATE   ;
                            end
                            else next_cnt    = cnt + 1   ;
                        end
                      end
                      
            receiving_STATE : begin
                         if(i_tick) begin
                            if(cnt==15) begin
                                next_cnt        = 0                         ;
                                next_reg_data   = {i_rx, reg_data[7:1]}     ;
                                
                                if(n_bit==NB_DATA-1) begin
                                    next_state = stop_STATE;
                                end
                                
                                else begin
                                    next_n_bit = n_bit + 1;
                                end
                            end    
                            
                            else    next_cnt = cnt +1;

                         end
                      end
                      
            stop_STATE : begin
                        if(i_tick) begin
                            if(cnt==NB_STOP_TICKS-1)begin
                                aux_valid   = 1'b1      ;
                                next_state  = idle_STATE   ;
                            end
                            else next_cnt = cnt + 1'b1  ;
                        end         
            end
            
            default:                      next_state=idle_STATE;
        endcase 
    end


  //OUTPUT ASSIGN
  assign o_data  = reg_data;
  assign o_valid = reg_valid;
    
endmodule
