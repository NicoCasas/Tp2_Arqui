`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module top_con_rx_tx
#(//PARAMETERS
    parameter NB_DATA = 8,
    parameter F_CLOCK = 25000000
 )
 (
    //OUTPUTS
    output wire    [NB_DATA-1:0]    o_data          ,
    output wire                     o_valid         ,
    output wire                     o_pc_tx_ready   ,
    //INPUTS
    input wire     [NB_DATA-1:0]    i_data    ,
    input wire                      i_valid   ,
    input wire                      i_clk     ,
    input wire                      i_reset 
    
    );
    
    
 //REGS & WIRES
    reg                     clk     ;
    reg                     reset   ;
    wire                    tick    ;    
//    wire                    conn    ;
    //PAL TOP
    wire                    pc_tx;
    wire                    pc_rx ;
    wire                    pc_tx_ready;

//MODULE INSTANTIATION
  //BAUDRATE  
  Baudrate
  #(                    
        .F_CLOCK(F_CLOCK) 
  )
  pc_baudrate      
  (
        .o_tick     (tick)                        ,
        .i_clk      (i_clk)                       ,
        .i_reset    (i_reset)                       
  );
  
Receptor
#(
    //PARAMETERS
    .NB_DATA(NB_DATA)
 )
 pc_receptor
 (
    //OUTPUTS
        .o_data (o_data)                          ,
        .o_valid(o_valid)                         ,
    //INPUTS
        .i_clk  (i_clk)                           ,
        .i_reset(i_reset)                         ,
        .i_tick (tick)                            ,
        .i_rx   (pc_rx)
        
  );
  
//TRANSMISOR  
Transmisor
#(
    //PARAMETERS
        .NB_DATA(NB_DATA)
 )
 pc_transmisor
 (
    //OUTPUTS
        .o_data (pc_tx)                             ,
        .o_ready(pc_tx_ready)                       ,
    //INPUTS
        .i_clk  (i_clk)                             ,
        .i_reset(i_reset)                           ,
        .i_tick (tick)                              ,
        .i_valid(i_valid)                           ,       
        .i_data (i_data)     
        
  );
    
assign o_pc_tx_ready = pc_tx_ready;    
    
top
#(
    //PARAMETERS
    .NB_DATA(NB_DATA)    
)
u_top    
(
    //OUTPUT
    .o_tx   (pc_rx),
    //INPUT
    .i_clk  (i_clk),
    .i_reset(i_reset),
    .i_rx   (pc_tx)
);

endmodule
