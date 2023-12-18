`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//TP_2
//Módulo que funciona como interfaz entre la alu y el modulo uart como tal
//Instancia la alu
//Recibe a la entrada un valor de 8 bits, que almacenará en dato_A, dato_B y dato_op
//según corresponda.
//A su salida, tiene el resultado de la ALU al aplicar la operación dato_op sobre 
//dato_A y dato_B.
//////////////////////////////////////////////////////////////////////////////////


module Interfaz
#(  //PARAMETER DEFINITION
    parameter                           NB_DATA=8      
)
(   //OUTPUTS
    output  wire    [NB_DATA-1:0]       o_resultado ,
    output  wire                        o_valid     ,
    //INPUTS
    input   wire                        i_clk       ,
    input   wire                        i_reset     ,
    input   wire                        i_valid_rx  ,
    input   wire                        i_valid_tx  ,
    input   wire    [NB_DATA-1:0]       i_data      

);
//LOCALPARAMS
    localparam  num_states  = 4'd5              ;
    localparam  nb_states   = $clog2(num_states);
    localparam  state_1     = 5'b00001           ;
    localparam  state_2     = 5'b00010           ;
    localparam  state_3     = 5'b00100           ;
    localparam  state_4     = 5'b01000           ;
    localparam  state_5     = 5'b10000           ;
    
    localparam  NB_OP       = 6                 ;


//INTERNAL WIRES & REGS
    wire [NB_DATA-1:0]       dato_a          ;
    wire [NB_DATA-1:0]       dato_b          ;
    wire [NB_DATA-1:0]       dato_op         ;
    

    reg [NB_DATA-1:0]       nxt_dato_a          ;
    reg [NB_DATA-1:0]       nxt_dato_b          ;
    reg [NB_DATA-1:0]       nxt_dato_op         ;
    
    reg [NB_DATA-1:0]       reg_dato_a          ;
    reg [NB_DATA-1:0]       reg_dato_b          ;
    reg [NB_DATA-1:0]       reg_dato_op         ;
    
        
    reg  [NB_DATA*3-1 :0]    data            ;
    reg  [num_states-1:0]    state           ;
    reg  [num_states-1:0]    next_state      ;
    reg  [NB_DATA-1:0]       reg_resultado   ;
    reg                      aux_o_valid     ;
    reg                      reg_o_valid     ;

    wire[NB_DATA-1:0]       resultado        ;
    
//MEMORY
    always @(posedge i_clk) begin
        if(i_reset) begin
            state   <=  state_1             ;
            data    <=  {NB_DATA*3{1'b0}}   ;
            reg_dato_a <= 0;
            reg_dato_b <= 0;
            reg_dato_op<= 0;
            reg_o_valid<= 0;
        end
        else begin
            state           <=  next_state  ;
            reg_resultado   <=  resultado   ;
            reg_o_valid     <=  aux_o_valid ;
            reg_dato_a      <=  nxt_dato_a  ;
            reg_dato_b      <=  nxt_dato_b  ;
            reg_dato_op     <=  nxt_dato_op ;
                                    
        end
    end 

//NEXT STATE LOGIC
    always @(*) begin
        next_state    = state       ;
        nxt_dato_a = reg_dato_a     ;
        nxt_dato_b = reg_dato_b     ;
        nxt_dato_op = reg_dato_op   ;
        aux_o_valid = reg_o_valid   ;
        
        
        case(state)
            state_1 : if(i_valid_rx)begin           
                        next_state=state_2;
                        nxt_dato_a = i_data;
                      end

            state_2 : if(i_valid_rx)begin           
                        next_state=state_3;
                        nxt_dato_b = i_data;
                      end

            state_3 : if(i_valid_rx)begin         
                        next_state=state_4;
                        nxt_dato_op = i_data;
                      end

            state_4 :   begin
                        next_state=state_5;
                        aux_o_valid = 1'b1;
                        end
                        
            state_5 : begin 
                        aux_o_valid = 1'b0;
                        if(i_valid_rx && i_valid_tx)  begin
                            next_state=state_2;
                            nxt_dato_a = i_data;
                        end
                      end

            default:    next_state=state_1;
        endcase 
    end
    
//COMBINATIONAL LOGIC
    assign dato_a       =  reg_dato_a                   ;
    assign dato_b       =  reg_dato_b                   ;
    assign dato_op      =  reg_dato_op                  ;
    
//OUTPUT ASSIGN
    assign o_resultado  = reg_resultado                 ;
    assign o_valid      = reg_o_valid                   ;
    

//OUTPUT LOGIC
//    always @(*) begin
//        case(state)
//            state_2 : begin
//                        data        = (data&~mask_a) | {{2*NB_DATA{1'b0}},i_data}               ;
//                        aux_o_valid = 1'b0                                                      ;
//                      end
//            state_3 : begin
//                        data        = (data&~mask_b) | {{NB_DATA{1'b0}},i_data,{NB_DATA{1'b0}}} ;
//                        aux_o_valid = 1'b0                                                      ;
//                      end
//            state_4 : begin
//                        data        = (data&~mask_op)| {i_data,{2*NB_DATA{1'b0}}}               ;
//                        aux_o_valid = 1'b0                                                      ;
//                      end
//            state_5 : begin
//                        data        = data                                                      ; 
//                        aux_o_valid = 1'b1                                                      ;
                      
//            end
//            default : begin
//                        data        = {NB_DATA*3{1'b0}}                                         ;
//                        aux_o_valid = 1'b0                                                      ;
//                      end
//        endcase 
//    end        


////OUTPUT LOGIC
//    always @(*) begin
//        case(state)
//            state_2 : begin
//                        if(i_valid_rx) nxt_dato_a = i_data      ;
//                        else           nxt_dato_a = reg_dato_a  ;
//                        nxt_dato_b = reg_dato_b;
//                        nxt_dato_op = reg_dato_op;
//                      end
//            state_3 : begin
//                        nxt_dato_a = reg_dato_a                 ;
//                        if(i_valid_rx) nxt_dato_b = i_data      ;
//                        else           nxt_dato_b = reg_dato_b  ;
//                        nxt_dato_op = reg_dato_op               ;
//                      end                        
                      
//            state_4 : begin
//                        nxt_dato_a = reg_dato_a;
//                        nxt_dato_a = reg_dato_b;
//                        nxt_dato_a = i_data;
//                      end
//            default:  
//             begin    nxt_dato_a = {NB_DATA{1'b0}}  ;
//                      nxt_dato_b = {NB_DATA{1'b0}}  ;
//                      nxt_dato_op= {NB_DATA{1'b0}}  ;   
//                      end
//        endcase 
//    end        


//MODULE INSTANTIATION
  alu
  #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
  )
  u_alu      
  (
        .i_a        (dato_a)                        ,
        .i_b        (dato_b)                        ,
        .i_op       (dato_op[NB_OP-1:0])            ,
        .o_data     (resultado[NB_DATA-1:0])        
  );
endmodule
