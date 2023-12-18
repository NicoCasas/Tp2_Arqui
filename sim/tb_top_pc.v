`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2023 13:36:07
// Design Name: 
// Module Name: tb_top_pc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top_pc();

parameter F_CLOCK = 100000000;
parameter T       = 10;
parameter NB_DATA =  8;

wire [NB_DATA-1:0]  o_data;
wire                o_valid;
wire                o_pc_tx_ready; 

reg clk   = 0;
reg reset = 1;

reg [NB_DATA-1:0]   pc_tx_data;
reg                 pc_tx_valid = 0;

reg aux;

// clk
always begin
    #(T/2)
    clk = ~clk; 
end

//sim
initial begin
    #(1.5*T)
    reset = 1'b0;
    #(2*T)
    // dato_A
    while(~o_pc_tx_ready) begin
        #T
        aux = 0;
    end
    pc_tx_data = 8'b01000011;
    pc_tx_valid = 1'b1;
    
    #T
    pc_tx_valid = 1'b0;

    // dato_B
    while(~o_pc_tx_ready) begin
        #T
        aux = 0;
    end
    pc_tx_data = 8'b00100001;
    pc_tx_valid = 1'b1;
    
    #T
    pc_tx_valid = 1'b0;

    // dato_OP
    while(~o_pc_tx_ready) begin
        #T
        aux = 0;
    end
    pc_tx_data = 8'b00100000;
    pc_tx_valid = 1'b1;
    
    #T
    pc_tx_valid = 1'b0;

    // Espero al resultado
    while(~o_valid) begin
        #T
        aux = 0;
    end

    #(80000*T)
    $display("dout: b%b",o_data);
    $finish();
end

top_con_rx_tx
#(//PARAMETERS
    .F_CLOCK(F_CLOCK)
 )
 uut_top_pc
 (
    //OUTPUTS
    .o_data         (o_data ),
    .o_valid        (o_valid),
    .o_pc_tx_ready  (o_pc_tx_ready)   ,
    //INPUTS
    .i_data         (pc_tx_data)      ,
    .i_valid        (pc_tx_valid)     ,
    .i_clk          (clk)             ,
    .i_reset        (reset)           
    
    );



endmodule
