`timescale 1ns / 1ps
/////////////////////////////////////////////
//Genera un tick en o_tick 16 veces por BaudRate
//
//
//
/////////////////////////////////////////////
module Baudrate
#(
    //PARAMETERS
    parameter                   F_CLOCK     = 50000000              ,
    parameter                   BAUDRATE    = 9600                  ,
    parameter                   N_COUNT     = F_CLOCK/(BAUDRATE*16) 
   )
   (
    //OUTPUTS
    output      wire            o_tick      ,
    //INPUT
    input       wire            i_clk       ,
    input       wire            i_reset     
   );
   
   //Localparams
   localparam   nb_cnt = $clog2(N_COUNT);
   
   //Internal regs & wires
   wire [nb_cnt-1:0] next_count;
   reg  [nb_cnt-1:0] count;
   
   //Combinational Logic
   assign next_count = count + {{nb_cnt-1{1'b0}},1'b1};
   
   //Secuential Logic
   always @(posedge i_clk) begin : cuenta
        if(i_reset|(count==N_COUNT)) begin
            count <= {nb_cnt{1'b0}};
        end
        else begin
            count <= next_count;
        end
   end  
   
   //Output Assign
   assign o_tick = count == N_COUNT-1;
   
endmodule
