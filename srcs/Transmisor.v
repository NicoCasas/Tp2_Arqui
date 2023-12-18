`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module Transmisor
#(
    //PARAMETERS
    parameter                       NB_DATA         =   8               ,
    parameter                       NB_STOP         =   2               ,
    parameter                       NB_STOP_TICKS   =   16 * NB_STOP
 )
 (
    //OUTPUTS
    output wire                     o_data                              ,
    output wire                     o_ready                             ,
    //INPUTS
    input  wire                     i_clk                               ,
    input  wire                     i_reset                             ,
    input  wire                     i_tick                              ,
    input  wire                     i_valid                             ,
    input  wire     [NB_DATA-1:0]   i_data                                
  );
  
  //LOCALPARAMS
   localparam  idle_STATE     = 4'b0001           ;
   localparam  start_STATE    = 4'b0010           ;
   localparam  sending_STATE  = 4'b0100           ;
   localparam  stop_STATE     = 4'b1000           ;
      
  //INTERNAL REGS & WIRES
  reg   [NB_DATA-1:0]   buffer          ;
  reg   [NB_DATA-1:0]   next_buffer     ;
  reg                   reg_data        ;
  reg                   next_reg_data   ;
  reg   [5-1:0]         cnt             ;           ////////////////////VER EL TAMAÑO
  reg   [5-1:0]         next_cnt        ;           
  reg   [3-1:0]         n_bit           ;           ////////////////////IGUAL
  reg   [3-1:0]         next_n_bit      ;
  reg   [4-1:0]         state           ;
  reg   [4-1:0]         next_state      ;
  reg                   aux_ready       ;        
  reg                   aux_ready_reg   ;
  
  //MEMORY
    always @(posedge i_clk) begin
        if(i_reset) begin
            state           <=  idle_STATE         ;
            n_bit           <=  0               ;
            cnt             <=  0               ;
            reg_data        <=  1'b1            ;
            buffer          <=  0               ;
            aux_ready_reg   <=  0               ;
        end
        else begin
            state           <=  next_state     ;
            n_bit           <=  next_n_bit     ;
            cnt             <=  next_cnt       ;
            reg_data        <=  next_reg_data  ;
            buffer          <=  next_buffer    ;
            aux_ready_reg   <=  aux_ready      ;
        end
    end 

//NEXT STATE LOGIC
    always @(*) begin
        next_state    = state           ;
        next_n_bit    = n_bit           ;
        next_cnt      = cnt             ;
        next_reg_data = reg_data        ;
        next_buffer   = buffer          ;
        aux_ready     = aux_ready_reg   ;
        case(state)
        
            idle_STATE : 
            begin
                        aux_ready     = 1'b1;
                        next_reg_data = 1'b1;
                        if(i_valid)begin 
                                aux_ready       = 1'b0          ;       
                                next_cnt        = 0             ;
                                next_state      = start_STATE   ;
                                next_buffer     = i_data        ;
                        end
            end
                      
            start_STATE : 
            begin
                        next_reg_data = 1'b0;
                        if(i_tick) begin
                            if(cnt==15) begin

                                 next_cnt    = 0                ;
                                 next_n_bit  = 0                ;
                                 next_state  = sending_STATE    ;
                            end
                            else next_cnt    = cnt + 1   ;
                        end
            end
                      
            sending_STATE : begin
                         next_reg_data = buffer[n_bit];
                         if(i_tick) begin
                            if(cnt==15) begin
                                next_cnt        = 0         ;
                                
                                if(n_bit==NB_DATA-1) begin
                                    next_state = stop_STATE    ;
                                end
                                else begin
                                    next_n_bit = n_bit + 1  ;
                                end
                            end    
                            
                            else    next_cnt = cnt + 1'b1   ;

                         end
            end
                      
            stop_STATE : begin
                        next_reg_data = 1'b1                ;
                        if(i_tick) begin
                            if(cnt==NB_STOP_TICKS-1)begin
                                next_state  = idle_STATE       ;
                            end
                            else next_cnt = cnt + 1'b1      ;
                        end         
            end
            
            default:   next_state=idle_STATE;
        endcase 
    end


  //OUTPUT ASSIGN
  assign o_data  = reg_data         ;
  assign o_ready = aux_ready_reg    ;
    
endmodule
