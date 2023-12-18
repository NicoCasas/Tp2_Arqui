`timescale 1ns / 1ps

//ALU
module alu
#(
    //Parameters
    parameter                                  NB_DATA         = 8 ,
    parameter                                  NB_OP           = 6
  )
  (
    //Inputs
    input   wire signed [NB_DATA  - 1 :0]      i_a                 ,
    input   wire signed [NB_DATA  - 1 :0]      i_b                 ,
    input   wire        [NB_OP    - 1 :0]      i_op                ,
    //Outputs
    output  wire signed [NB_DATA  - 1 :0]      o_data                  
  );
  
  //LOCALPARAMS
  localparam        op_add = 6'b100_000    ;
  localparam        op_sub = 6'b100_010    ;
  localparam        op_and = 6'b100_100    ;
  localparam        op_or  = 6'b100_101    ;
  localparam        op_xor = 6'b100_110    ;
  localparam        op_sra = 6'b000_011    ;
  localparam        op_srl = 6'b000_010    ;
  localparam        op_nor = 6'b100_111    ;  
  
  //Internal regs and wires
  reg            [NB_DATA-1:0]      resultado;
  
  always @(*) begin : alu_op
    case (i_op)
        op_add :    resultado =  i_a  +  i_b                        ;  //Sum
        op_sub :    resultado =  i_a  -  i_b                        ;  //Rest
        op_and :    resultado =  i_a  &  i_b                        ;  //And
        op_or  :    resultado =  i_a  |  i_b                        ;  //Or
        op_xor :    resultado =  i_a  ^  i_b                        ;  //x_or
        op_sra :    resultado =  i_a >>> $unsigned(i_b)             ;  //sra
        op_srl :    resultado =  i_a >>  $unsigned(i_b)             ;  //srl
        op_nor :    resultado = ~(i_a |  i_b)                       ;  //nor
        default:    resultado = {NB_DATA{1'b0}}                     ;
    endcase
    
  end

//Output assign
assign o_data   =   resultado [NB_DATA-1 : 0];

endmodule
