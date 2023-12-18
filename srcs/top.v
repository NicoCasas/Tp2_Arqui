`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module top
#(//PARAMETERS
    parameter           NB_DATA =   8           ,
    parameter           NB_OP   =   6           ,
    parameter           NB_STOP =   2           ,
    parameter           F_CLOCK =   80000000
    
  )
  (//OUTPUTS
    output      wire    o_tx            ,
    output      wire    o_tx_wire       ,
   //INPUTS
    input       wire    i_rx            ,
    input       wire    i_clk           ,
    input       wire    i_reset         
    
    );
    
    //LOCALPARAMS
    
    //INTERNAL WIRES & REGS
    wire                    tick        ;
    wire   [NB_DATA-1:0]    data_rx     ;
    wire                    valid_rx    ;
    wire   [NB_DATA-1:0]    resultado   ;
    wire                    valid_alu   ;
    wire                    ready_tx    ;

// CLK
wire clk;
wire reset;
wire locked;

assign o_tx_wire = o_tx;

assign reset = i_reset | (~locked);        

clk_wiz_0 inst
  (
  // Clock out ports  
  .clk(clk),
  // Status and control signals               
  .reset(i_reset), 
  .locked(locked),
 // Clock in ports
  .i_clk(i_clk)
  );       
        
//MODULE INSTANTIATION
  //BAUDRATE  
  Baudrate
  #(
        .F_CLOCK(F_CLOCK)                       
  )
  u_baudrate      
  (
        .o_tick     (tick)                        ,
        .i_clk      (clk)                         ,
        .i_reset    (reset)                       
  );
  
Receptor
#(
    //PARAMETERS
    .NB_DATA(NB_DATA)
 )
 u_receptor
 (
    //OUTPUTS
        .o_data (data_rx)                         ,
        .o_valid(valid_rx)                        ,
    //INPUTS
        .i_clk  (clk)                             ,
        .i_reset(reset)                           ,
        .i_tick (tick)                            ,
        .i_rx   (i_rx)
        
  );
  
//TRANSMISOR  
Transmisor
#(
    //PARAMETERS
        .NB_DATA(NB_DATA)
 )
 u_transmisor
 (
    //OUTPUTS
        .o_data (o_tx)                              ,
        .o_ready(ready_tx)                          ,
    //INPUTS
        .i_clk  (clk)                             ,
        .i_reset(reset)                           ,
        .i_tick (tick)                              ,
        .i_valid(valid_alu)                         ,       
        .i_data (resultado)     
        
  );
  
 //INTERFAZ 
  Interfaz
  #(
        .NB_DATA(NB_DATA)
   )
   u_interfaz
   (//OUTPUTS
        .o_resultado    (resultado)                 ,
        .o_valid        (valid_alu)                 ,
    //INPUTS
        .i_clk          (clk)                       ,
        .i_reset        (reset)                     ,
        .i_valid_rx     (valid_rx)                  ,
        .i_valid_tx     (ready_tx)                  ,
        .i_data         (data_rx)   
   );
endmodule
